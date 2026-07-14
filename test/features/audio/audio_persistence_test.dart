import 'dart:io';

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
  test('audio media and edits survive database close and reopen', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'audio_persistence_',
    );
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    AppDatabase database = AppDatabase.open(paths.databaseFile);
    OperationJournalRepository journal = OperationJournalRepository(database);
    final Project project =
        await ProjectRepository(
          database: database,
          paths: paths,
          journal: journal,
        ).createProject(
          ProjectDraft(
            title: 'Persistent audio',
            aspectRatio: ProjectAspectRatio.widescreen,
            resolution: ProjectResolution.hd720,
            framesPerSecond: 12,
            backgroundColorValue: Colors.black.toARGB32(),
          ),
        );
    final File picked = await File(
      '${root.path}/picked.m4a',
    ).writeAsBytes(<int>[1, 2, 3, 4]);
    AudioRepository repository = AudioRepository(
      database: database,
      paths: paths,
      journal: journal,
    );
    final AudioClip clip = await repository.accept(
      projectId: project.id,
      source: picked,
      name: 'Persistent music',
      trackType: AudioTrackType.music,
      duration: const Duration(seconds: 5),
      recording: false,
    );
    AudioTimeline timeline = await repository.load(project.id);
    timeline = timeline
        .replace(
          clip.copyWith(
            startMilliseconds: 750,
            trimStartMilliseconds: 250,
            volume: 1.25,
          ),
        )
        .copyWith(masterVolume: 0.75);
    await repository.save(timeline);
    await database.close();

    database = AppDatabase.open(paths.databaseFile);
    journal = OperationJournalRepository(database);
    repository = AudioRepository(
      database: database,
      paths: paths,
      journal: journal,
    );
    final AudioTimeline restored = await repository.load(project.id);

    expect(restored.clips.single.startMilliseconds, 750);
    expect(restored.clips.single.trimStartMilliseconds, 250);
    expect(restored.clips.single.volume, 1.25);
    expect(restored.masterVolume, 0.75);
    expect(
      await paths
          .resolveRelativeFile(restored.clips.single.relativeSourcePath)
          .readAsBytes(),
      <int>[1, 2, 3, 4],
    );

    await database.close();
    await root.delete(recursive: true);
  });
}
