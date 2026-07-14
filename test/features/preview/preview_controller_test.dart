import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/editor/data/editor_repository.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/preview/domain/playback_clock.dart';
import 'package:stop_motion/features/preview/presentation/preview_controller.dart';
import 'package:stop_motion/features/preview/presentation/preview_quality_menu.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

import '../editor/timeline_test.dart' show frame;

void main() {
  test('preview restores initial frame and owns playback lifecycle', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'preview_controller_',
    );
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    final AppDatabase database = AppDatabase.memory();
    final ProjectRepository projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    );
    final Project project = await projects.createProject(
      ProjectDraft(
        title: 'Preview film',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 2,
        backgroundColorValue: 0,
      ),
    );
    final List<ProjectFrame> frames = List<ProjectFrame>.generate(6, (
      int index,
    ) {
      final ProjectFrame value = frame('$index');
      return ProjectFrame(
        id: value.id,
        projectId: project.id,
        relativeSourcePath: value.relativeSourcePath,
        position: index,
        holdFrames: 1,
        createdAt: value.createdAt,
        sourceWidth: value.sourceWidth,
        sourceHeight: value.sourceHeight,
        missing: false,
      );
    });
    final EditorRepository editor = EditorRepository(database: database);
    await editor.saveTimeline(
      project.id,
      TimelineSnapshot(frames: frames, fps: 2),
    );
    final MutableTimeSource time = MutableTimeSource();
    final PreviewController controller = PreviewController(
      projectId: project.id,
      initialFrame: 2,
      editor: editor,
      projects: projects,
      clock: PlaybackClock(timeSource: time),
    );
    await controller.initialize();
    expect(controller.state.frameIndex, 2);
    controller.setQuality(PreviewQuality.performance);
    controller.toggleLoop();
    controller.togglePlayback();
    time.value += const Duration(seconds: 1);
    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(controller.state.frameIndex, 4);
    controller.pause();
    expect(controller.state.playing, isFalse);
    expect(controller.state.quality, PreviewQuality.performance);
    expect(controller.state.loop, isTrue);

    controller.dispose();
    await database.close();
    await root.delete(recursive: true);
  });
}

class MutableTimeSource implements PlaybackTimeSource {
  Duration value = Duration.zero;

  @override
  Duration get elapsed => value;
}
