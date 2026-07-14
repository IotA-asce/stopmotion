import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/editor/data/editor_repository.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/frame_adjustments.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

import 'timeline_test.dart' show frame;

void main() {
  test('timeline edits and fps survive database restart', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'editor_repo_',
    );
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    AppDatabase database = AppDatabase.open(paths.databaseFile);
    final ProjectRepository projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    );
    final Project project = await projects.createProject(
      ProjectDraft(
        title: 'Persisted editor',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 12,
        backgroundColorValue: 0,
      ),
    );
    final EditorRepository repository = EditorRepository(database: database);
    final List<ProjectFrame> frames =
        <ProjectFrame>[
              frame('a').copyWith(position: 0),
              frame('b', hold: 4).copyWith(
                position: 1,
                adjustments: const FrameAdjustments(exposure: 0.75),
              ),
              frame('c').copyWith(position: 2),
            ]
            .map(
              (ProjectFrame value) => ProjectFrame(
                id: value.id,
                projectId: project.id,
                relativeSourcePath: value.relativeSourcePath,
                position: value.position,
                holdFrames: value.holdFrames,
                createdAt: value.createdAt,
                sourceWidth: value.sourceWidth,
                sourceHeight: value.sourceHeight,
                missing: value.missing,
                adjustments: value.adjustments,
              ),
            )
            .toList();

    final EditorCommitResult committed = await repository.saveTimeline(
      project.id,
      TimelineSnapshot(frames: frames.reversed.toList(), fps: 18),
    );
    expect(committed.revision, 1);
    await database.close();

    database = AppDatabase.open(paths.databaseFile);
    final TimelineSnapshot restored = await EditorRepository(
      database: database,
    ).loadTimeline(project.id);
    expect(restored.fps, 18);
    expect(restored.frames.map((ProjectFrame value) => value.id), <String>[
      'c',
      'b',
      'a',
    ]);
    expect(restored.frames[1].holdFrames, 4);
    expect(restored.frames[1].adjustments.exposure, 0.75);

    await database.close();
    await root.delete(recursive: true);
  });
}
