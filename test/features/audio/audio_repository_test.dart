import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/audio/data/audio_repository.dart';
import 'package:stop_motion/features/audio/domain/audio_clip.dart';
import 'package:stop_motion/features/audio/domain/audio_timeline.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  late Directory root;
  late ProjectPaths paths;
  late AppDatabase database;
  late AudioRepository audio;
  late Project project;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('audio_repository_');
    paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    database = AppDatabase.memory();
    final OperationJournalRepository journal = OperationJournalRepository(
      database,
    );
    project =
        await ProjectRepository(
          database: database,
          paths: paths,
          journal: journal,
        ).createProject(
          ProjectDraft(
            title: 'Audio project',
            aspectRatio: ProjectAspectRatio.widescreen,
            resolution: ProjectResolution.hd720,
            framesPerSecond: 10,
            backgroundColorValue: Colors.black.toARGB32(),
          ),
        );
    await database
        .into(database.frameRecords)
        .insert(
          FrameRecordsCompanion.insert(
            id: 'frame',
            projectId: project.id,
            relativeSourcePath: 'projects/${project.id}/frames/frame.jpg',
            position: 0,
            holdFrames: const Value<int>(50),
            createdAt: DateTime.utc(2026),
            sourceWidth: 100,
            sourceHeight: 100,
          ),
        );
    audio = AudioRepository(database: database, paths: paths, journal: journal);
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test(
    'imports into project storage and persists non-destructive edits',
    () async {
      final File source = await File(
        '${root.path}/picked.mp3',
      ).writeAsBytes(<int>[9, 8, 7, 6]);
      final AudioClip imported = await audio.accept(
        projectId: project.id,
        source: source,
        name: 'Music',
        trackType: AudioTrackType.music,
        duration: const Duration(seconds: 4),
        recording: false,
      );

      expect(await source.readAsBytes(), <int>[9, 8, 7, 6]);
      final File owned = paths.resolveRelativeFile(imported.relativeSourcePath);
      expect(await owned.readAsBytes(), <int>[9, 8, 7, 6]);

      AudioTimeline timeline = await audio.load(project.id);
      expect(timeline.projectDurationMilliseconds, 5000);
      timeline = timeline.replace(
        imported.copyWith(
          startMilliseconds: 500,
          trimStartMilliseconds: 250,
          trimEndMilliseconds: 3500,
          volume: 1.5,
          fadeInMilliseconds: 250,
        ),
      );
      await audio.save(timeline.copyWith(masterVolume: 0.8, muted: true));

      final AudioTimeline restored = await audio.load(project.id);
      expect(restored.clips.single.startMilliseconds, 500);
      expect(restored.clips.single.trimStartMilliseconds, 250);
      expect(restored.clips.single.volume, 1.5);
      expect(restored.masterVolume, 0.8);
      expect(restored.muted, isTrue);
    },
  );

  test(
    'missing media is muted and marked without blocking the project',
    () async {
      await database
          .into(database.audioClipRecords)
          .insert(
            AudioClipRecordsCompanion.insert(
              id: 'missing',
              projectId: project.id,
              relativeSourcePath: 'projects/${project.id}/audio/missing.m4a',
              name: 'Missing narration',
              trackType: AudioTrackType.narration.name,
              startMilliseconds: 0,
              trimStartMilliseconds: 0,
              trimEndMilliseconds: 1000,
            ),
          );

      final AudioTimeline restored = await audio.load(project.id);

      expect(restored.clips.single.missing, isTrue);
      expect(restored.clips.single.muted, isTrue);
      final AudioClipRecord row = await database
          .select(database.audioClipRecords)
          .getSingle();
      expect(row.missing, isTrue);
      expect(row.muted, isTrue);
    },
  );
}
