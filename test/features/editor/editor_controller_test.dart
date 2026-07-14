import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/editor/data/editor_repository.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/editor/presentation/editor_controller.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

import 'timeline_test.dart' show frame;

void main() {
  test('committed commands undo and redo for the current session', () async {
    final _EditorHarness harness = await _EditorHarness.create();
    final EditorController controller = harness.controller;
    await controller.initialize();

    expect(controller.state.timeline!.frames.length, 3);
    await controller.duplicateSelection();
    expect(controller.state.timeline!.frames.length, 4);
    expect(controller.state.autosave, AutosaveStatus.saved);
    expect(controller.canUndo, isTrue);

    await controller.undo();
    expect(controller.state.timeline!.frames.length, 3);
    expect(controller.canRedo, isTrue);
    await controller.redo();
    expect(controller.state.timeline!.frames.length, 4);

    await harness.dispose();
  });

  test('selection, clipboard, hold, fps, and delete persist', () async {
    final _EditorHarness harness = await _EditorHarness.create();
    final EditorController controller = harness.controller;
    await controller.initialize();
    controller.selectAll();
    await controller.setHold(5);
    controller.copySelection();
    await controller.setFps(20);
    await controller.deleteSelection();

    expect(controller.state.timeline!.frames, isEmpty);
    expect(controller.state.timeline!.fps, 20);
    await controller.paste();
    expect(controller.state.timeline!.frames.length, 3);
    expect(
      controller.state.timeline!.frames.every(
        (ProjectFrame value) => value.holdFrames == 5,
      ),
      isTrue,
    );

    await harness.dispose();
  });
}

class _EditorHarness {
  _EditorHarness(this.root, this.database, this.controller);

  final Directory root;
  final AppDatabase database;
  final EditorController controller;

  static Future<_EditorHarness> create() async {
    final Directory root = await Directory.systemTemp.createTemp(
      'editor_controller_',
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
        title: 'Controller film',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 12,
        backgroundColorValue: 0,
      ),
    );
    final List<ProjectFrame> frames = List<ProjectFrame>.generate(3, (
      int index,
    ) {
      final ProjectFrame value = frame('$index');
      return ProjectFrame(
        id: value.id,
        projectId: project.id,
        relativeSourcePath: value.relativeSourcePath,
        position: index,
        holdFrames: value.holdFrames,
        createdAt: value.createdAt,
        sourceWidth: value.sourceWidth,
        sourceHeight: value.sourceHeight,
        missing: true,
      );
    });
    final EditorRepository editor = EditorRepository(database: database);
    await editor.saveTimeline(
      project.id,
      TimelineSnapshot(frames: frames, fps: 12),
    );
    return _EditorHarness(
      root,
      database,
      EditorController(
        projectId: project.id,
        repository: editor,
        projects: projects,
      ),
    );
  }

  Future<void> dispose() async {
    controller.dispose();
    await database.close();
    await root.delete(recursive: true);
  }
}
