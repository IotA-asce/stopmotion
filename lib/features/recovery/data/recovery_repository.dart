import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/migrations.dart';
import '../../../core/database/tables.dart';
import '../../../core/diagnostics/app_logger.dart';
import '../../../core/filesystem/project_paths.dart';
import '../../../core/recovery/operation.dart';
import '../../../core/recovery/operation_journal.dart';
import '../../export/domain/export_record.dart';
import '../../projects/domain/project.dart';
import '../domain/recovery_report.dart';

class RecoveryRepository {
  factory RecoveryRepository({
    required AppDatabase database,
    required ProjectPaths paths,
    required OperationJournalRepository journal,
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
    AppLogger? logger,
  }) => RecoveryRepository._(
    database,
    paths,
    journal,
    uuid,
    now ?? _utcNow,
    logger,
  );

  RecoveryRepository._(
    this._database,
    this._paths,
    this._journal,
    this._uuid,
    this._now,
    this._logger,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final OperationJournalRepository _journal;
  final Uuid _uuid;
  final DateTime Function() _now;
  final AppLogger? _logger;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Future<RecoveryReport> scan() async {
    try {
      await verifyDatabaseIntegrity(_database);
    } on Object {
      await _log('scan', 'database_unhealthy');
      return const RecoveryReport(
        databaseHealthy: false,
        items: <RecoveryItem>[
          RecoveryItem(
            id: 'database-integrity',
            kind: RecoveryIssueKind.migration,
            message:
                'The project database needs recovery. Your source files have not been removed.',
          ),
        ],
      );
    }

    final List<RecoveryItem> items = <RecoveryItem>[];
    for (final Operation operation in await _journal.listIncomplete()) {
      final RecoveryItem? item = await _reconcileOperation(operation);
      if (item != null) items.add(item);
    }
    items.addAll(await _flagMissingSources());
    final RecoveryReport report = RecoveryReport(
      items: List<RecoveryItem>.unmodifiable(items),
    );
    await _log('scan', report.requiresAttention ? 'needs_action' : 'complete');
    return report;
  }

  Future<RecoveryReport> repair() async {
    final RecoveryReport report = await scan();
    for (final RecoveryItem item in report.items) {
      if (item.operationId == null) continue;
      switch (item.kind) {
        case RecoveryIssueKind.interruptedDuplicate:
          await _completeDuplicate(item.operationId!);
        case RecoveryIssueKind.interruptedDelete:
          await _completeDelete(item.operationId!);
        case RecoveryIssueKind.missingMedia:
        case RecoveryIssueKind.missingProjectDirectory:
        case RecoveryIssueKind.migration:
        case RecoveryIssueKind.orphanedMedia:
          break;
      }
    }
    final RecoveryReport repaired = await scan();
    await _log(
      'repair',
      repaired.requiresAttention ? 'needs_action' : 'complete',
    );
    return repaired;
  }

  Future<RecoveryReport> removeMissingItems() async {
    final List<FrameRecord> missingFrames = await (_database.select(
      _database.frameRecords,
    )..where((FrameRecords table) => table.missing.equals(true))).get();
    final List<AudioClipRecord> missingAudio = await (_database.select(
      _database.audioClipRecords,
    )..where((AudioClipRecords table) => table.missing.equals(true))).get();
    final Set<String> affectedProjects = <String>{
      ...missingFrames.map((FrameRecord frame) => frame.projectId),
      ...missingAudio.map((AudioClipRecord clip) => clip.projectId),
    };
    await _database.transaction(() async {
      for (final FrameRecord frame in missingFrames) {
        await (_database.delete(
          _database.frameRecords,
        )..where((FrameRecords table) => table.id.equals(frame.id))).go();
      }
      for (final AudioClipRecord clip in missingAudio) {
        await (_database.delete(
          _database.audioClipRecords,
        )..where((AudioClipRecords table) => table.id.equals(clip.id))).go();
      }
      for (final String projectId in affectedProjects) {
        final List<FrameRecord> frames =
            await (_database.select(_database.frameRecords)
                  ..where(
                    (FrameRecords table) => table.projectId.equals(projectId),
                  )
                  ..orderBy(<OrderingTerm Function(FrameRecords)>[
                    (FrameRecords table) => OrderingTerm.asc(table.position),
                  ]))
                .get();
        for (var index = 0; index < frames.length; index++) {
          await (_database.update(_database.frameRecords)..where(
                (FrameRecords table) => table.id.equals(frames[index].id),
              ))
              .write(FrameRecordsCompanion(position: Value<int>(index)));
        }
        await (_database.update(
          _database.projectRecords,
        )..where((ProjectRecords table) => table.id.equals(projectId))).write(
          ProjectRecordsCompanion(
            status: Value<String>(ProjectStatus.draft.name),
            updatedAt: Value<DateTime>(_now()),
          ),
        );
      }
    });
    final RecoveryReport repaired = await scan();
    await _log(
      'remove_missing',
      repaired.requiresAttention ? 'needs_action' : 'complete',
    );
    return repaired;
  }

  Future<RecoveryItem?> _reconcileOperation(Operation operation) async {
    return switch (operation.type) {
      OperationType.capture ||
      OperationType.import ||
      OperationType.importAudio ||
      OperationType.recordAudio => _reconcileMediaOperation(operation),
      OperationType.duplicateProject => _reconcileDuplicate(operation),
      OperationType.deleteProject => _reconcileDelete(operation),
      OperationType.export => _reconcileExport(operation),
    };
  }

  Future<RecoveryItem?> _reconcileMediaOperation(Operation operation) async {
    final File? finalFile = _safeFile(operation.finalPath);
    final File? temporaryFile = _safeFile(operation.temporaryPath);
    final bool finalValid = await _isValidFile(finalFile);
    final bool referenced = await _isReferenced(finalFile, operation.projectId);
    if (finalValid && referenced) {
      await _journal.setState(operation.id, OperationState.complete);
      return null;
    }
    if (finalValid) {
      await _markProjectNeedsRepair(operation.projectId);
      return RecoveryItem(
        id: operation.id,
        kind: RecoveryIssueKind.orphanedMedia,
        projectId: operation.projectId,
        operationId: operation.id,
        message:
            'A verified media file was retained because it has no matching project record.',
      );
    }
    if (referenced) {
      await _markProjectNeedsRepair(operation.projectId);
      return RecoveryItem(
        id: operation.id,
        kind: RecoveryIssueKind.missingMedia,
        projectId: operation.projectId,
        operationId: operation.id,
        message: 'A media operation finished without a readable source file.',
      );
    }
    await _deleteIfPresent(temporaryFile);
    await _journal.markRecovered(operation.id, errorCode: 'abandoned_media');
    return null;
  }

  Future<RecoveryItem?> _reconcileDuplicate(Operation operation) async {
    final String? destinationId = operation.destinationProjectId;
    if (destinationId == null) {
      await _journal.markRecovered(
        operation.id,
        errorCode: 'missing_destination',
      );
      return null;
    }
    final ProjectRecord? destination = await _project(destinationId);
    final Directory destinationDirectory = _paths.projectDirectory(
      destinationId,
    );
    if (destination != null) {
      if (!await destinationDirectory.exists()) {
        await _markProjectNeedsRepair(destinationId);
        return RecoveryItem(
          id: operation.id,
          kind: RecoveryIssueKind.missingProjectDirectory,
          projectId: destinationId,
          operationId: operation.id,
          message:
              'A duplicated project is missing its project-owned directory.',
        );
      }
      await _journal.setState(operation.id, OperationState.complete);
      return null;
    }
    if (!await destinationDirectory.exists()) {
      await _journal.markRecovered(
        operation.id,
        errorCode: 'duplicate_not_started',
      );
      return null;
    }
    if (await _project(operation.projectId) == null) {
      return RecoveryItem(
        id: operation.id,
        kind: RecoveryIssueKind.orphanedMedia,
        projectId: destinationId,
        operationId: operation.id,
        message:
            'A copied project directory was retained because its source project is unavailable.',
      );
    }
    return RecoveryItem(
      id: operation.id,
      kind: RecoveryIssueKind.interruptedDuplicate,
      projectId: destinationId,
      operationId: operation.id,
      message: 'A copied project is ready to be repaired into the library.',
    );
  }

  Future<RecoveryItem?> _reconcileDelete(Operation operation) async {
    final ProjectRecord? project = await _project(operation.projectId);
    final Directory directory = _paths.projectDirectory(operation.projectId);
    if (project != null) {
      if (!await directory.exists()) {
        await _markProjectNeedsRepair(operation.projectId);
        return RecoveryItem(
          id: operation.id,
          kind: RecoveryIssueKind.missingProjectDirectory,
          projectId: operation.projectId,
          operationId: operation.id,
          message:
              'A project record remains but its source directory is missing.',
        );
      }
      await _journal.markRecovered(
        operation.id,
        errorCode: 'delete_not_committed',
      );
      return null;
    }
    if (!await directory.exists()) {
      await _journal.setState(operation.id, OperationState.complete);
      return null;
    }
    return RecoveryItem(
      id: operation.id,
      kind: RecoveryIssueKind.interruptedDelete,
      projectId: operation.projectId,
      operationId: operation.id,
      message:
          'A permanently deleted project still has an on-device source directory.',
    );
  }

  Future<RecoveryItem?> _reconcileExport(Operation operation) async {
    final File? output = _safeFile(operation.finalPath);
    final Directory? temporary = _safeDirectory(operation.temporaryPath);
    final ExportRecord? record =
        await (_database.select(_database.exportRecords)..where(
              (ExportRecords table) => table.id.equals(_exportId(output)),
            ))
            .getSingleOrNull();
    if (record?.status == ExportStatus.complete.name &&
        await _isValidFile(output)) {
      await _journal.setState(operation.id, OperationState.complete);
      return null;
    }
    await _deleteDirectoryIfPresent(temporary);
    await _deleteIfPresent(output);
    if (record != null && record.status == ExportStatus.pending.name) {
      await (_database.update(
        _database.exportRecords,
      )..where((ExportRecords table) => table.id.equals(record.id))).write(
        ExportRecordsCompanion(
          status: Value<String>(ExportStatus.cancelled.name),
          errorCode: const Value<String>('interrupted'),
          updatedAt: Value<DateTime?>(_now()),
        ),
      );
    }
    await _journal.markRecovered(operation.id, errorCode: 'interrupted_export');
    return null;
  }

  Future<List<RecoveryItem>> _flagMissingSources() async {
    final Map<String, _MissingCounts> missing = <String, _MissingCounts>{};
    final List<FrameRecord> frames = await _database
        .select(_database.frameRecords)
        .get();
    for (final FrameRecord frame in frames) {
      final bool absent = !await _isValidFile(
        _safeFile(frame.relativeSourcePath),
      );
      if (absent != frame.missing) {
        await (_database.update(_database.frameRecords)
              ..where((FrameRecords table) => table.id.equals(frame.id)))
            .write(FrameRecordsCompanion(missing: Value<bool>(absent)));
      }
      if (absent) {
        missing.putIfAbsent(frame.projectId, _MissingCounts.new).frames++;
      }
    }
    final List<AudioClipRecord> clips = await _database
        .select(_database.audioClipRecords)
        .get();
    for (final AudioClipRecord clip in clips) {
      final bool absent = !await _isValidFile(
        _safeFile(clip.relativeSourcePath),
      );
      if (absent != clip.missing || (absent && !clip.muted)) {
        await (_database.update(
          _database.audioClipRecords,
        )..where((AudioClipRecords table) => table.id.equals(clip.id))).write(
          AudioClipRecordsCompanion(
            missing: Value<bool>(absent),
            muted: Value<bool>(absent || clip.muted),
          ),
        );
      }
      if (absent) {
        missing.putIfAbsent(clip.projectId, _MissingCounts.new).audio++;
      }
    }
    final List<RecoveryItem> items = <RecoveryItem>[];
    for (final MapEntry<String, _MissingCounts> entry in missing.entries) {
      await _markProjectNeedsRepair(entry.key);
      items.add(
        RecoveryItem(
          id: 'missing-${entry.key}',
          kind: RecoveryIssueKind.missingMedia,
          projectId: entry.key,
          missingFrameCount: entry.value.frames,
          missingAudioCount: entry.value.audio,
          message:
              '${entry.value.frames} frame(s) and ${entry.value.audio} audio clip(s) are missing.',
        ),
      );
    }
    return items;
  }

  Future<void> _completeDuplicate(String operationId) async {
    final Operation? operation = await _operation(operationId);
    if (operation == null || operation.destinationProjectId == null) return;
    final String destinationId = operation.destinationProjectId!;
    if (await _project(destinationId) != null ||
        !await _paths.projectDirectory(destinationId).exists()) {
      return;
    }
    final ProjectRecord? source = await _project(operation.projectId);
    if (source == null) return;
    final DateTime now = _now();
    await _database.transaction(() async {
      await _database
          .into(_database.projectRecords)
          .insert(
            ProjectRecordsCompanion.insert(
              id: destinationId,
              title: '${source.title} copy',
              aspectRatio: source.aspectRatio,
              resolution: source.resolution,
              framesPerSecond: source.framesPerSecond,
              backgroundColor: source.backgroundColor,
              createdAt: now,
              updatedAt: now,
              status: ProjectStatus.draft.name,
              currentRevision: Value<int>(source.currentRevision),
              masterVolume: Value<double>(source.masterVolume),
              audioMuted: Value<bool>(source.audioMuted),
            ),
          );
      for (final FrameRecord frame
          in await (_database.select(_database.frameRecords)..where(
                (FrameRecords table) => table.projectId.equals(source.id),
              ))
              .get()) {
        await _database
            .into(_database.frameRecords)
            .insert(
              FrameRecordsCompanion.insert(
                id: _uuid.v4(),
                projectId: destinationId,
                relativeSourcePath: _replaceProjectId(
                  frame.relativeSourcePath,
                  source.id,
                  destinationId,
                ),
                position: frame.position,
                createdAt: now,
                sourceWidth: frame.sourceWidth,
                sourceHeight: frame.sourceHeight,
                holdFrames: Value<int>(frame.holdFrames),
                missing: Value<bool>(frame.missing),
                adjustmentsJson: Value<String>(frame.adjustmentsJson),
              ),
            );
      }
      for (final AudioClipRecord clip
          in await (_database.select(_database.audioClipRecords)..where(
                (AudioClipRecords table) => table.projectId.equals(source.id),
              ))
              .get()) {
        await _database
            .into(_database.audioClipRecords)
            .insert(
              AudioClipRecordsCompanion.insert(
                id: _uuid.v4(),
                projectId: destinationId,
                relativeSourcePath: _replaceProjectId(
                  clip.relativeSourcePath,
                  source.id,
                  destinationId,
                ),
                name: clip.name,
                trackType: clip.trackType,
                startMilliseconds: clip.startMilliseconds,
                trimStartMilliseconds: clip.trimStartMilliseconds,
                trimEndMilliseconds: clip.trimEndMilliseconds,
                volume: Value<double>(clip.volume),
                fadeInMilliseconds: Value<int>(clip.fadeInMilliseconds),
                fadeOutMilliseconds: Value<int>(clip.fadeOutMilliseconds),
                muted: Value<bool>(clip.muted),
                missing: Value<bool>(clip.missing),
              ),
            );
      }
    });
    await _journal.setState(operation.id, OperationState.complete);
  }

  Future<void> _completeDelete(String operationId) async {
    final Operation? operation = await _operation(operationId);
    if (operation == null || await _project(operation.projectId) != null) {
      return;
    }
    await _deleteDirectoryIfPresent(
      _paths.projectDirectory(operation.projectId),
    );
    await _deleteDirectoryIfPresent(
      _paths.thumbnailDirectory(operation.projectId),
    );
    await _journal.setState(operation.id, OperationState.complete);
  }

  Future<Operation?> _operation(String id) async {
    final OperationJournal? row =
        await (_database.select(_database.operationJournals)
              ..where((OperationJournals table) => table.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return null;
    return Operation(
      id: row.id,
      type: OperationType.values.byName(row.type),
      state: OperationState.values.byName(row.state),
      projectId: row.projectId,
      destinationProjectId: row.destinationProjectId,
      temporaryPath: row.temporaryPath,
      finalPath: row.finalPath,
      errorCode: row.errorCode,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<ProjectRecord?> _project(String id) => (_database.select(
    _database.projectRecords,
  )..where((ProjectRecords table) => table.id.equals(id))).getSingleOrNull();

  Future<void> _markProjectNeedsRepair(String projectId) async {
    await (_database.update(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).write(
      ProjectRecordsCompanion(
        status: Value<String>(ProjectStatus.needsRepair.name),
        updatedAt: Value<DateTime>(_now()),
      ),
    );
  }

  Future<bool> _isReferenced(File? file, String projectId) async {
    if (file == null) return false;
    final String relative = _paths.relativeToRoot(file);
    final FrameRecord? frame =
        await (_database.select(_database.frameRecords)..where(
              (FrameRecords table) =>
                  table.projectId.equals(projectId) &
                  table.relativeSourcePath.equals(relative),
            ))
            .getSingleOrNull();
    if (frame != null) return true;
    final AudioClipRecord? audio =
        await (_database.select(_database.audioClipRecords)..where(
              (AudioClipRecords table) =>
                  table.projectId.equals(projectId) &
                  table.relativeSourcePath.equals(relative),
            ))
            .getSingleOrNull();
    return audio != null;
  }

  File? _safeFile(String? rawPath) {
    if (rawPath == null) return null;
    final String resolved = p.normalize(
      p.isAbsolute(rawPath) ? rawPath : p.join(_paths.root.path, rawPath),
    );
    if (!p.isWithin(_paths.root.path, resolved)) return null;
    return File(resolved);
  }

  Directory? _safeDirectory(String? rawPath) {
    final File? file = _safeFile(rawPath);
    return file == null ? null : Directory(file.path);
  }

  Future<bool> _isValidFile(File? file) async {
    if (file == null || !await file.exists()) return false;
    try {
      return await file.length() > 0;
    } on FileSystemException {
      return false;
    }
  }

  Future<void> _deleteIfPresent(File? file) async {
    if (file != null && await file.exists()) await file.delete();
  }

  Future<void> _deleteDirectoryIfPresent(Directory? directory) async {
    if (directory != null && await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  String _exportId(File? output) =>
      output == null ? '' : p.basenameWithoutExtension(output.path);

  String _replaceProjectId(String value, String source, String destination) {
    final List<String> parts = p.split(value).toList();
    final int index = parts.indexOf(source);
    if (index >= 0) parts[index] = destination;
    return p.joinAll(parts);
  }

  Future<void> _log(String action, String status) async {
    final AppLogger? logger = _logger;
    if (logger == null) return;
    unawaited(_writeLog(logger, action, status));
  }

  Future<void> _writeLog(AppLogger logger, String action, String status) async {
    try {
      await logger.log(
        category: 'recovery',
        action: action,
        attributes: <String, Object?>{'status': status},
      );
    } on Object {
      // Recovery remains available if diagnostic storage is unavailable.
    }
  }
}

class _MissingCounts {
  int frames = 0;
  int audio = 0;
}
