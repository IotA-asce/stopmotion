import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/frame.dart';
import '../domain/frame_adjustments.dart';
import '../domain/timeline.dart';

class EditorCommitResult {
  const EditorCommitResult({required this.timeline, required this.revision});

  final TimelineSnapshot timeline;
  final int revision;
}

class EditorRepository {
  EditorRepository({required AppDatabase database, DateTime Function()? now})
    : this._(database, now ?? _utcNow);

  EditorRepository._(this._database, this._now);

  final AppDatabase _database;
  final DateTime Function() _now;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Future<TimelineSnapshot> loadTimeline(String projectId) async {
    final ProjectRecord project = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).getSingle();
    final List<FrameRecord> rows =
        await (_database.select(_database.frameRecords)
              ..where((FrameRecords table) => table.projectId.equals(projectId))
              ..orderBy(<OrderingTerm Function(FrameRecords)>[
                (FrameRecords table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    return TimelineSnapshot(
      frames: rows.map(_mapFrame).toList(growable: false),
      fps: project.framesPerSecond,
    );
  }

  Future<EditorCommitResult> saveTimeline(
    String projectId,
    TimelineSnapshot timeline,
  ) async {
    return _database.transaction(() async {
      final ProjectRecord project =
          await (_database.select(_database.projectRecords)
                ..where((ProjectRecords table) => table.id.equals(projectId)))
              .getSingle();
      final List<FrameRecord> existing =
          await (_database.select(_database.frameRecords)..where(
                (FrameRecords table) => table.projectId.equals(projectId),
              ))
              .get();
      final Set<String> existingIds = existing
          .map((FrameRecord row) => row.id)
          .toSet();
      final Set<String> retainedIds = timeline.frames
          .map((ProjectFrame frame) => frame.id)
          .where(existingIds.contains)
          .toSet();

      await _database.customUpdate(
        'UPDATE frame_records SET position = position + 1000000 '
        'WHERE project_id = ?',
        variables: <Variable<Object>>[Variable<String>(projectId)],
        updates: <TableInfo<Table, Object?>>{_database.frameRecords},
      );

      for (final FrameRecord row in existing) {
        if (!retainedIds.contains(row.id)) {
          await (_database.delete(
            _database.frameRecords,
          )..where((FrameRecords table) => table.id.equals(row.id))).go();
        }
      }

      for (final ProjectFrame frame in timeline.frames) {
        if (retainedIds.contains(frame.id)) {
          await (_database.update(
            _database.frameRecords,
          )..where((FrameRecords table) => table.id.equals(frame.id))).write(
            FrameRecordsCompanion(
              position: Value<int>(frame.position),
              holdFrames: Value<int>(frame.holdFrames),
              adjustmentsJson: Value<String>(frame.adjustments.encode()),
            ),
          );
        } else {
          await _database
              .into(_database.frameRecords)
              .insert(
                FrameRecordsCompanion.insert(
                  id: frame.id,
                  projectId: projectId,
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
        }
      }

      final int revision = project.currentRevision + 1;
      await (_database.update(
        _database.projectRecords,
      )..where((ProjectRecords table) => table.id.equals(projectId))).write(
        ProjectRecordsCompanion(
          framesPerSecond: Value<int>(timeline.fps),
          currentRevision: Value<int>(revision),
          updatedAt: Value<DateTime>(_now()),
        ),
      );

      final TimelineSnapshot verified = await loadTimeline(projectId);
      if (verified.frames.length != timeline.frames.length ||
          verified.fps != timeline.fps) {
        throw StateError('Timeline read-back verification failed.');
      }
      for (var index = 0; index < verified.frames.length; index++) {
        final ProjectFrame actual = verified.frames[index];
        final ProjectFrame expected = timeline.frames[index];
        if (actual.id != expected.id ||
            actual.holdFrames != expected.holdFrames ||
            actual.adjustments.cacheKey != expected.adjustments.cacheKey) {
          throw StateError('Timeline ordering verification failed.');
        }
      }
      return EditorCommitResult(timeline: verified, revision: revision);
    });
  }

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
