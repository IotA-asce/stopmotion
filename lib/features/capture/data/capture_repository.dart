import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/filesystem/atomic_file_store.dart';
import '../../../core/filesystem/project_paths.dart';
import '../../../core/media/image_validation_service.dart';
import '../../../core/recovery/operation.dart';
import '../../../core/recovery/operation_journal.dart';
import '../../editor/domain/frame.dart';
import '../../editor/domain/frame_adjustments.dart';
import '../../projects/data/project_thumbnail_repository.dart';
import '../domain/capture_frame.dart';

class CaptureRepository {
  CaptureRepository({
    required AppDatabase database,
    required ProjectPaths paths,
    required OperationJournalRepository journal,
    required ProjectThumbnailRepository thumbnails,
    AtomicFileStore fileStore = const AtomicFileStore(),
    ImageValidationService imageValidation = const ImageValidationService(),
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : this._(
         database,
         paths,
         journal,
         thumbnails,
         fileStore,
         imageValidation,
         uuid,
         now ?? _utcNow,
       );

  CaptureRepository._(
    this._database,
    this._paths,
    this._journal,
    this._thumbnails,
    this._fileStore,
    this._imageValidation,
    this._uuid,
    this._now,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final OperationJournalRepository _journal;
  final ProjectThumbnailRepository _thumbnails;
  final AtomicFileStore _fileStore;
  final ImageValidationService _imageValidation;
  final Uuid _uuid;
  final DateTime Function() _now;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Stream<List<ProjectFrame>> watchFrames(String projectId) {
    final SimpleSelectStatement<FrameRecords, FrameRecord> query =
        _database.select(_database.frameRecords)
          ..where((FrameRecords table) => table.projectId.equals(projectId))
          ..orderBy(<OrderingTerm Function(FrameRecords)>[
            (FrameRecords table) => OrderingTerm.asc(table.position),
          ]);
    return query.watch().map(
      (List<FrameRecord> rows) => rows.map(_mapFrame).toList(growable: false),
    );
  }

  Future<List<ProjectFrame>> getFrames(String projectId) async {
    final List<FrameRecord> rows =
        await (_database.select(_database.frameRecords)
              ..where((FrameRecords table) => table.projectId.equals(projectId))
              ..orderBy(<OrderingTerm Function(FrameRecords)>[
                (FrameRecords table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    return rows.map(_mapFrame).toList(growable: false);
  }

  Future<ProjectFrame> acceptFrame({
    required String projectId,
    required CaptureSource source,
    OperationType operationType = OperationType.capture,
  }) async {
    final _PreparedMedia prepared = await _prepareMedia(
      projectId: projectId,
      source: source,
      operationType: operationType,
    );
    late final ProjectFrame frame;
    try {
      frame = await _database.transaction(() async {
        final Expression<int> maximum = _database.frameRecords.position.max();
        final TypedResult result =
            await (_database.selectOnly(_database.frameRecords)
                  ..addColumns(<Expression<Object>>[maximum])
                  ..where(_database.frameRecords.projectId.equals(projectId)))
                .getSingle();
        final int position = (result.read(maximum) ?? -1) + 1;
        final DateTime now = _now();
        await _database
            .into(_database.frameRecords)
            .insert(
              FrameRecordsCompanion.insert(
                id: prepared.frameId,
                projectId: projectId,
                relativeSourcePath: _paths.relativeToRoot(prepared.file),
                position: position,
                createdAt: now,
                sourceWidth: prepared.image.width,
                sourceHeight: prepared.image.height,
              ),
            );
        await _incrementProjectRevision(projectId, now);
        final FrameRecord inserted =
            await (_database.select(_database.frameRecords)..where(
                  (FrameRecords table) => table.id.equals(prepared.frameId),
                ))
                .getSingle();
        if (!await prepared.file.exists() ||
            await prepared.file.length() == 0) {
          throw const FileSystemException(
            'Final frame failed read-back verification.',
          );
        }
        return _mapFrame(inserted);
      });
    } on Object catch (error) {
      await _rollbackPreparedMedia(prepared, error);
      rethrow;
    }
    await _finishAcceptedMedia(prepared, source);
    return frame;
  }

  Future<ProjectFrame> retakeFrame({
    required String projectId,
    required String frameId,
    required CaptureSource source,
  }) async {
    final _PreparedMedia prepared = await _prepareMedia(
      projectId: projectId,
      source: source,
      operationType: OperationType.capture,
    );
    late final ProjectFrame frame;
    try {
      frame = await _database.transaction(() async {
        final FrameRecord existing =
            await (_database.select(_database.frameRecords)..where(
                  (FrameRecords table) =>
                      table.id.equals(frameId) &
                      table.projectId.equals(projectId),
                ))
                .getSingle();
        final DateTime now = _now();
        await (_database.update(
          _database.frameRecords,
        )..where((FrameRecords table) => table.id.equals(frameId))).write(
          FrameRecordsCompanion(
            relativeSourcePath: Value<String>(
              _paths.relativeToRoot(prepared.file),
            ),
            createdAt: Value<DateTime>(now),
            sourceWidth: Value<int>(prepared.image.width),
            sourceHeight: Value<int>(prepared.image.height),
            missing: const Value<bool>(false),
          ),
        );
        await _incrementProjectRevision(projectId, now);
        if (!await prepared.file.exists() ||
            await prepared.file.length() == 0) {
          throw const FileSystemException(
            'Retaken frame could not be verified.',
          );
        }
        return _mapFrame(
          existing.copyWith(
            relativeSourcePath: _paths.relativeToRoot(prepared.file),
            createdAt: now,
            sourceWidth: prepared.image.width,
            sourceHeight: prepared.image.height,
            missing: false,
          ),
        );
      });
    } on Object catch (error) {
      await _rollbackPreparedMedia(prepared, error);
      rethrow;
    }
    await _finishAcceptedMedia(prepared, source);
    return frame;
  }

  Future<ProjectFrame> duplicateFrame(String projectId, String frameId) async {
    return _database.transaction(() async {
      final FrameRecord source =
          await (_database.select(_database.frameRecords)..where(
                (FrameRecords table) =>
                    table.id.equals(frameId) &
                    table.projectId.equals(projectId),
              ))
              .getSingle();
      final Expression<int> maximum = _database.frameRecords.position.max();
      final TypedResult result =
          await (_database.selectOnly(_database.frameRecords)
                ..addColumns(<Expression<Object>>[maximum])
                ..where(_database.frameRecords.projectId.equals(projectId)))
              .getSingle();
      final String id = _uuid.v4();
      final DateTime now = _now();
      await _database
          .into(_database.frameRecords)
          .insert(
            FrameRecordsCompanion.insert(
              id: id,
              projectId: projectId,
              relativeSourcePath: source.relativeSourcePath,
              position: (result.read(maximum) ?? -1) + 1,
              holdFrames: Value<int>(source.holdFrames),
              createdAt: now,
              sourceWidth: source.sourceWidth,
              sourceHeight: source.sourceHeight,
              adjustmentsJson: Value<String>(source.adjustmentsJson),
            ),
          );
      await _incrementProjectRevision(projectId, now);
      return _mapFrame(
        await (_database.select(
          _database.frameRecords,
        )..where((FrameRecords table) => table.id.equals(id))).getSingle(),
      );
    });
  }

  Future<DeletedFrame> deleteFrame(String projectId, String frameId) async {
    return _database.transaction(() async {
      final FrameRecord row =
          await (_database.select(_database.frameRecords)..where(
                (FrameRecords table) =>
                    table.id.equals(frameId) &
                    table.projectId.equals(projectId),
              ))
              .getSingle();
      await (_database.delete(
        _database.frameRecords,
      )..where((FrameRecords table) => table.id.equals(frameId))).go();
      await _database.customUpdate(
        'UPDATE frame_records SET position = position - 1 '
        'WHERE project_id = ? AND position > ?',
        variables: <Variable<Object>>[
          Variable<String>(projectId),
          Variable<int>(row.position),
        ],
        updates: <TableInfo<Table, Object?>>{_database.frameRecords},
      );
      await _incrementProjectRevision(projectId, _now());
      return DeletedFrame(_mapFrame(row));
    });
  }

  Future<void> restoreDeletedFrame(DeletedFrame deleted) async {
    final ProjectFrame frame = deleted.frame;
    await _database.transaction(() async {
      await _database.customUpdate(
        'UPDATE frame_records SET position = position + 100000 '
        'WHERE project_id = ? AND position >= ?',
        variables: <Variable<Object>>[
          Variable<String>(frame.projectId),
          Variable<int>(frame.position),
        ],
        updates: <TableInfo<Table, Object?>>{_database.frameRecords},
      );
      await _database.customUpdate(
        'UPDATE frame_records SET position = position - 99999 '
        'WHERE project_id = ? AND position >= ?',
        variables: <Variable<Object>>[
          Variable<String>(frame.projectId),
          Variable<int>(frame.position + 100000),
        ],
        updates: <TableInfo<Table, Object?>>{_database.frameRecords},
      );
      await _database
          .into(_database.frameRecords)
          .insert(
            FrameRecordsCompanion.insert(
              id: frame.id,
              projectId: frame.projectId,
              relativeSourcePath: frame.relativeSourcePath,
              position: frame.position,
              holdFrames: Value<int>(frame.holdFrames),
              createdAt: frame.createdAt,
              sourceWidth: frame.sourceWidth,
              sourceHeight: frame.sourceHeight,
              missing: Value<bool>(frame.missing),
              adjustmentsJson: Value<String>(frame.adjustments.encode()),
            ),
          );
      await _incrementProjectRevision(frame.projectId, _now());
    });
  }

  Future<_PreparedMedia> _prepareMedia({
    required String projectId,
    required CaptureSource source,
    required OperationType operationType,
  }) async {
    final String frameId = _uuid.v4();
    final File temporary = File(
      '${_paths.temporaryDirectory(projectId).path}/$frameId.tmp',
    );
    final File destination = File(
      '${_paths.framesDirectory(projectId).path}/$frameId.jpg',
    );
    final String journalId = await _journal.begin(
      type: operationType,
      projectId: projectId,
      temporaryPath: _paths.relativeToRoot(temporary),
      finalPath: _paths.relativeToRoot(destination),
    );
    ValidatedImage? normalized;
    try {
      final File accepted = await _fileStore.accept(
        source: source.file,
        temporary: temporary,
        destination: destination,
        validate: (File file) async {
          await _imageValidation.inspect(file);
          return true;
        },
        transform: (File file) async {
          normalized = await _imageValidation.normalizeOrientation(file);
        },
      );
      await _journal.setState(journalId, OperationState.mediaReady);
      return _PreparedMedia(
        frameId: frameId,
        journalId: journalId,
        file: accepted,
        image: normalized!,
      );
    } on Object catch (error) {
      await _journal.setState(
        journalId,
        OperationState.failed,
        errorCode: error.runtimeType.toString(),
      );
      rethrow;
    }
  }

  Future<void> _finishAcceptedMedia(
    _PreparedMedia prepared,
    CaptureSource source,
  ) async {
    try {
      await _journal.setState(
        prepared.journalId,
        OperationState.databaseCommitted,
      );
    } on Object {
      // The verified frame is authoritative if journal finalization fails.
    }
    try {
      if (source.deleteAfterAccept && await source.file.exists()) {
        await source.file.delete();
      }
    } on Object {
      // Temporary plugin output can be reclaimed by the operating system.
    }
    try {
      await _thumbnails.generate(
        _projectIdFromFramePath(prepared.file),
        prepared.file,
      );
    } on Object {
      // Thumbnails are disposable; a durable frame must remain successful.
    }
    try {
      await _journal.setState(prepared.journalId, OperationState.complete);
    } on Object {
      // Launch recovery can reconcile a committed operation journal later.
    }
  }

  Future<void> _rollbackPreparedMedia(
    _PreparedMedia prepared,
    Object error,
  ) async {
    if (await prepared.file.exists()) {
      await prepared.file.delete();
    }
    await _journal.setState(
      prepared.journalId,
      OperationState.failed,
      errorCode: error.runtimeType.toString(),
    );
  }

  Future<void> _incrementProjectRevision(String projectId, DateTime now) async {
    final ProjectRecord project = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).getSingle();
    await (_database.update(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).write(
      ProjectRecordsCompanion(
        currentRevision: Value<int>(project.currentRevision + 1),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  String _projectIdFromFramePath(File frame) =>
      frame.parent.parent.path.split(Platform.pathSeparator).last;

  ProjectFrame _mapFrame(FrameRecord row) => ProjectFrame(
    id: row.id,
    projectId: row.projectId,
    relativeSourcePath: row.relativeSourcePath,
    position: row.position,
    holdFrames: row.holdFrames,
    createdAt: row.createdAt,
    sourceWidth: row.sourceWidth,
    sourceHeight: row.sourceHeight,
    missing: row.missing,
    adjustments: FrameAdjustments.decode(row.adjustmentsJson),
  );
}

class _PreparedMedia {
  const _PreparedMedia({
    required this.frameId,
    required this.journalId,
    required this.file,
    required this.image,
  });

  final String frameId;
  final String journalId;
  final File file;
  final ValidatedImage image;
}
