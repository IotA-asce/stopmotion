import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/filesystem/atomic_file_store.dart';
import '../../../core/filesystem/project_paths.dart';
import '../../../core/recovery/operation.dart';
import '../../../core/recovery/operation_journal.dart';
import '../domain/audio_clip.dart';
import '../domain/audio_timeline.dart';

class AudioRepository {
  AudioRepository({
    required AppDatabase database,
    required ProjectPaths paths,
    required OperationJournalRepository journal,
    AtomicFileStore store = const AtomicFileStore(),
    Uuid uuid = const Uuid(),
  }) : this._(database, paths, journal, store, uuid);

  AudioRepository._(
    this._database,
    this._paths,
    this._journal,
    this._store,
    this._uuid,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final OperationJournalRepository _journal;
  final AtomicFileStore _store;
  final Uuid _uuid;

  Future<AudioTimeline> load(String projectId) async {
    final ProjectRecord project = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).getSingle();
    final List<AudioClipRecord> rows =
        await (_database.select(_database.audioClipRecords)
              ..where(
                (AudioClipRecords table) => table.projectId.equals(projectId),
              )
              ..orderBy(<OrderingTerm Function(AudioClipRecords)>[
                (AudioClipRecords table) =>
                    OrderingTerm.asc(table.startMilliseconds),
              ]))
            .get();
    final List<AudioClip> clips = <AudioClip>[];
    for (final AudioClipRecord row in rows) {
      final File source = _paths.resolveRelativeFile(row.relativeSourcePath);
      final bool missing = !await source.exists() || await source.length() == 0;
      if (missing != row.missing || (missing && !row.muted)) {
        await (_database.update(
          _database.audioClipRecords,
        )..where((AudioClipRecords table) => table.id.equals(row.id))).write(
          AudioClipRecordsCompanion(
            missing: Value<bool>(missing),
            muted: Value<bool>(missing || row.muted),
          ),
        );
      }
      clips.add(_map(row, missing: missing));
    }
    final int durationMilliseconds = project.framesPerSecond == 0
        ? 0
        : await _projectDuration(projectId, project.framesPerSecond);
    return AudioTimeline(
      projectId: projectId,
      projectDurationMilliseconds: durationMilliseconds,
      clips: clips,
      masterVolume: project.masterVolume,
      muted: project.audioMuted,
    );
  }

  Future<AudioClip> accept({
    required String projectId,
    required File source,
    required String name,
    required AudioTrackType trackType,
    required Duration duration,
    required bool recording,
  }) async {
    final AudioTimeline existing = await load(projectId);
    final String id = _uuid.v4();
    final String extension = p.extension(source.path).toLowerCase();
    final String safeExtension = extension.isEmpty ? '.m4a' : extension;
    final File temporary = File(
      p.join(_paths.temporaryDirectory(projectId).path, '$id$safeExtension'),
    );
    final File destination = File(
      p.join(_paths.audioDirectory(projectId).path, '$id$safeExtension'),
    );
    final AudioClip clip = AudioClip(
      id: id,
      projectId: projectId,
      relativeSourcePath: _paths.relativeToRoot(destination),
      name: name,
      trackType: trackType,
      startMilliseconds: 0,
      trimStartMilliseconds: 0,
      trimEndMilliseconds: duration.inMilliseconds,
      volume: 1,
      fadeInMilliseconds: 0,
      fadeOutMilliseconds: 0,
      muted: false,
    );
    existing.add(clip);
    final String journalId = await _journal.begin(
      type: recording ? OperationType.recordAudio : OperationType.importAudio,
      projectId: projectId,
      temporaryPath: temporary.path,
      finalPath: destination.path,
    );
    try {
      await _store.accept(
        source: source,
        temporary: temporary,
        destination: destination,
      );
      await _journal.setState(journalId, OperationState.mediaReady);
      await _database.transaction(() async {
        await _database
            .into(_database.audioClipRecords)
            .insert(_companion(clip));
        await _touchProject(projectId);
      });
      final AudioClipRecord verified = await (_database.select(
        _database.audioClipRecords,
      )..where((AudioClipRecords table) => table.id.equals(id))).getSingle();
      if (!await destination.exists() ||
          verified.relativeSourcePath != clip.relativeSourcePath) {
        throw StateError('Accepted audio could not be verified.');
      }
      await _journal.setState(journalId, OperationState.complete);
      return clip;
    } on Object catch (error) {
      if (await destination.exists()) {
        await destination.delete();
      }
      await _journal.setState(
        journalId,
        OperationState.failed,
        errorCode: error.runtimeType.toString(),
      );
      rethrow;
    }
  }

  Future<void> save(AudioTimeline timeline) async {
    final Set<String> ids = timeline.clips
        .map((AudioClip clip) => clip.id)
        .toSet();
    await _database.transaction(() async {
      final ProjectRecord project =
          await (_database.select(_database.projectRecords)..where(
                (ProjectRecords table) => table.id.equals(timeline.projectId),
              ))
              .getSingle();
      await (_database.delete(_database.audioClipRecords)..where(
            (AudioClipRecords table) =>
                table.projectId.equals(timeline.projectId) &
                table.id.isNotIn(ids),
          ))
          .go();
      for (final AudioClip clip in timeline.clips) {
        await _database
            .into(_database.audioClipRecords)
            .insertOnConflictUpdate(_companion(clip));
      }
      await (_database.update(_database.projectRecords)..where(
            (ProjectRecords table) => table.id.equals(timeline.projectId),
          ))
          .write(
            ProjectRecordsCompanion(
              masterVolume: Value<double>(timeline.masterVolume),
              audioMuted: Value<bool>(timeline.muted),
              updatedAt: Value<DateTime>(DateTime.now().toUtc()),
              currentRevision: Value<int>(project.currentRevision + 1),
            ),
          );
    });
  }

  Future<int> _projectDuration(String projectId, int fps) async {
    final Expression<int> total = _database.frameRecords.holdFrames.sum();
    final TypedResult result =
        await (_database.selectOnly(_database.frameRecords)
              ..addColumns(<Expression<Object>>[total])
              ..where(_database.frameRecords.projectId.equals(projectId)))
            .getSingle();
    return (((result.read(total) ?? 0) * 1000) / fps).round();
  }

  Future<void> _touchProject(String projectId) async {
    final ProjectRecord project = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).getSingle();
    await (_database.update(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(projectId))).write(
      ProjectRecordsCompanion(
        updatedAt: Value<DateTime>(DateTime.now().toUtc()),
        currentRevision: Value<int>(project.currentRevision + 1),
      ),
    );
  }

  AudioClip _map(AudioClipRecord row, {required bool missing}) => AudioClip(
    id: row.id,
    projectId: row.projectId,
    relativeSourcePath: row.relativeSourcePath,
    name: row.name,
    trackType: AudioTrackType.values.byName(row.trackType),
    startMilliseconds: row.startMilliseconds,
    trimStartMilliseconds: row.trimStartMilliseconds,
    trimEndMilliseconds: row.trimEndMilliseconds,
    volume: row.volume,
    fadeInMilliseconds: row.fadeInMilliseconds,
    fadeOutMilliseconds: row.fadeOutMilliseconds,
    muted: missing || row.muted,
    missing: missing,
  );

  AudioClipRecordsCompanion _companion(AudioClip clip) =>
      AudioClipRecordsCompanion.insert(
        id: clip.id,
        projectId: clip.projectId,
        relativeSourcePath: clip.relativeSourcePath,
        name: clip.name,
        trackType: clip.trackType.name,
        startMilliseconds: clip.startMilliseconds,
        trimStartMilliseconds: clip.trimStartMilliseconds,
        trimEndMilliseconds: clip.trimEndMilliseconds,
        volume: Value<double>(clip.volume),
        fadeInMilliseconds: Value<int>(clip.fadeInMilliseconds),
        fadeOutMilliseconds: Value<int>(clip.fadeOutMilliseconds),
        muted: Value<bool>(clip.muted),
        missing: Value<bool>(clip.missing),
      );
}
