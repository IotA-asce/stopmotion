import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/diagnostics/app_logger.dart';
import '../../../core/filesystem/project_paths.dart';
import '../../../core/media/export_engine.dart';
import '../../../core/recovery/operation.dart';
import '../../../core/recovery/operation_journal.dart';
import '../../audio/data/audio_repository.dart';
import '../../editor/data/editor_repository.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/domain/project.dart';
import '../domain/export_job.dart';
import '../domain/export_record.dart';

abstract interface class ExportGateway {
  Future<ExportRequest> createRequest(
    String projectId,
    ExportSettings settings, {
    String? id,
  });

  Future<ExportPreflight> preflight(String projectId, ExportSettings settings);

  Future<ExportResult> run(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  });

  Future<ExportSettings?> previousSuccessfulSettings(String projectId);
}

class ExportRepository implements ExportGateway {
  ExportRepository({
    required AppDatabase database,
    required ProjectPaths paths,
    required ProjectRepository projects,
    required EditorRepository editor,
    required AudioRepository audio,
    required OperationJournalRepository journal,
    required ExportPreflightService preflight,
    required Map<ExportFormat, ExportEngine> engines,
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
    AppLogger? logger,
  }) : this._(
         database,
         paths,
         projects,
         editor,
         audio,
         journal,
         preflight,
         engines,
         uuid,
         now ?? _utcNow,
         logger,
       );

  ExportRepository._(
    this._database,
    this._paths,
    this._projects,
    this._editor,
    this._audio,
    this._journal,
    this._preflight,
    this._engines,
    this._uuid,
    this._now,
    this._logger,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final ProjectRepository _projects;
  final EditorRepository _editor;
  final AudioRepository _audio;
  final OperationJournalRepository _journal;
  final ExportPreflightService _preflight;
  final Map<ExportFormat, ExportEngine> _engines;
  final Uuid _uuid;
  final DateTime Function() _now;
  final AppLogger? _logger;

  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Future<ExportRequest> createRequest(
    String projectId,
    ExportSettings settings, {
    String? id,
  }) async {
    final Project? project = await _projects.getProject(projectId);
    if (project == null) throw StateError('Project does not exist.');
    final String exportId = id ?? _uuid.v4();
    final String extension = switch (settings.format) {
      ExportFormat.movie => 'mp4',
      ExportFormat.gif => 'gif',
      ExportFormat.imageSequence => 'zip',
    };
    return ExportRequest(
      id: exportId,
      project: project,
      timeline: await _editor.loadTimeline(projectId),
      audio: await _audio.load(projectId),
      settings: settings,
      projectRoot: _paths.root,
      temporaryDirectory: Directory(
        p.join(_paths.exportTemporaryDirectory(projectId).path, exportId),
      ),
      output: File(
        p.join(_paths.exportDirectory(projectId).path, '$exportId.$extension'),
      ),
    );
  }

  @override
  Future<ExportPreflight> preflight(
    String projectId,
    ExportSettings settings,
  ) async {
    final ExportRequest request = await createRequest(projectId, settings);
    final ExportPreflight result = await _preflight.inspect(request);
    final ExportEngine? engine = _engines[settings.format];
    if (engine == null || !await engine.isAvailable()) {
      return ExportPreflight(
        issues: <ExportIssue>[
          ...result.issues,
          const ExportIssue(
            code: ExportIssueCode.encoderUnavailable,
            message: 'This export format is unavailable on this device.',
          ),
        ],
        estimatedBytes: result.estimatedBytes,
        dimensions: result.dimensions,
        duration: result.duration,
      );
    }
    return result;
  }

  @override
  Future<ExportResult> run(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  }) async {
    final ExportPreflight checked = await _preflight.inspect(request);
    if (!checked.canExport) {
      throw FormatException(checked.issues.first.message);
    }
    final ExportEngine? engine = _engines[request.settings.format];
    if (engine == null || !await engine.isAvailable()) {
      throw UnsupportedError('Export engine is unavailable.');
    }
    final DateTime now = _now();
    final String journalId = await _journal.begin(
      type: OperationType.export,
      projectId: request.project.id,
      temporaryPath: request.temporaryDirectory.path,
      finalPath: request.output.path,
    );
    await _log('started', journalId, 'pending');
    await _database
        .into(_database.exportRecords)
        .insert(
          ExportRecordsCompanion.insert(
            id: request.id,
            projectId: request.project.id,
            format: request.settings.format.name,
            status: ExportStatus.pending.name,
            revision: request.project.currentRevision,
            createdAt: now,
            updatedAt: Value<DateTime?>(now),
            settingsJson: Value<String>(request.settings.encode()),
          ),
        );
    try {
      final ExportResult result = await engine.export(
        request,
        cancellation: cancellation,
        onProgress: onProgress,
      );
      await _database.transaction(() async {
        await _updateRecord(
          request.id,
          ExportStatus.complete,
          relativeOutputPath: _paths.relativeToRoot(result.output),
          outputBytes: result.bytes,
        );
        await (_database.update(_database.projectRecords)..where(
              (ProjectRecords table) => table.id.equals(request.project.id),
            ))
            .write(
              ProjectRecordsCompanion(
                lastExportedRevision: Value<int>(
                  request.project.currentRevision,
                ),
                status: Value<String>(ProjectStatus.exported.name),
              ),
            );
      });
      await _journal.setState(journalId, OperationState.complete);
      await _log('completed', journalId, 'complete');
      return result;
    } on ExportCancelled {
      await _updateRecord(request.id, ExportStatus.cancelled);
      await _journal.setState(
        journalId,
        OperationState.failed,
        errorCode: 'cancelled',
      );
      await _log('cancelled', journalId, 'cancelled');
      rethrow;
    } on Object catch (error) {
      await _updateRecord(
        request.id,
        ExportStatus.failed,
        errorCode: error.runtimeType.toString(),
      );
      await _journal.setState(
        journalId,
        OperationState.failed,
        errorCode: error.runtimeType.toString(),
      );
      await _log('failed', journalId, 'failed');
      rethrow;
    }
  }

  Stream<List<ProjectExportRecord>> watchHistory(String projectId) {
    final query = _database.select(_database.exportRecords)
      ..where((ExportRecords table) => table.projectId.equals(projectId))
      ..orderBy(<OrderingTerm Function(ExportRecords)>[
        (ExportRecords table) => OrderingTerm.desc(table.createdAt),
      ]);
    return query.watch().map(
      (List<ExportRecord> rows) => rows.map(_mapRecord).toList(growable: false),
    );
  }

  @override
  Future<ExportSettings?> previousSuccessfulSettings(String projectId) async {
    final ExportRecord? row =
        await (_database.select(_database.exportRecords)
              ..where(
                (ExportRecords table) =>
                    table.projectId.equals(projectId) &
                    table.status.equals(ExportStatus.complete.name),
              )
              ..orderBy(<OrderingTerm Function(ExportRecords)>[
                (ExportRecords table) => OrderingTerm.desc(table.createdAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : ExportSettings.decode(row.settingsJson);
  }

  Future<void> _updateRecord(
    String id,
    ExportStatus status, {
    String? relativeOutputPath,
    int? outputBytes,
    String? errorCode,
  }) async {
    await (_database.update(
      _database.exportRecords,
    )..where((ExportRecords table) => table.id.equals(id))).write(
      ExportRecordsCompanion(
        status: Value<String>(status.name),
        updatedAt: Value<DateTime?>(_now()),
        relativeOutputPath: Value<String?>(relativeOutputPath),
        outputBytes: Value<int?>(outputBytes),
        errorCode: Value<String?>(errorCode),
      ),
    );
  }

  Future<void> _log(String action, String operationId, String status) async {
    final AppLogger? logger = _logger;
    if (logger == null) return;
    try {
      await logger.log(
        category: 'export',
        action: action,
        operationId: operationId,
        attributes: <String, Object?>{'status': status},
      );
    } on Object {
      // Diagnostics must not affect an export's lifecycle.
    }
  }

  ProjectExportRecord _mapRecord(ExportRecord row) => ProjectExportRecord(
    id: row.id,
    projectId: row.projectId,
    format: ExportFormat.values.byName(row.format),
    status: ExportStatus.values.byName(row.status),
    revision: row.revision,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt ?? row.createdAt,
    settingsJson: row.settingsJson,
    relativeOutputPath: row.relativeOutputPath,
    outputBytes: row.outputBytes,
    errorCode: row.errorCode,
  );
}
