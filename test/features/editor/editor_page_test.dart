import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/editor/presentation/editor_page.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

void main() {
  testWidgets('renders editor controls and virtualizes a 1000-frame timeline', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final _EditorWidgetHarness harness = await _EditorWidgetHarness.create(
      tester,
      frameCount: 1000,
    );
    await harness.pump(tester, const Size(1024, 768));

    expect(find.text('1000 frames'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Frame actions'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Frame 1, hold 1')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Frame 1000, hold 1')), findsNothing);
    final Semantics frameSemantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics && widget.properties.label == 'Frame 1, hold 1',
      ),
    );
    expect(frameSemantics.properties.value, 'Playhead');
    expect(
      frameSemantics.properties.hint,
      'Double tap to select. Long press to add or remove from selection.',
    );
    expect(tester.takeException(), isNull);

    semantics.dispose();
    await harness.dispose(tester);
  });

  testWidgets('landscape editor remains usable at 200 percent text scale', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    final _EditorWidgetHarness harness = await _EditorWidgetHarness.create(
      tester,
      frameCount: 8,
    );
    await harness.pump(tester, const Size(844, 390));

    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.text('8 frames'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await harness.dispose(tester);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

class _EditorWidgetHarness {
  _EditorWidgetHarness({
    required this.root,
    required this.paths,
    required this.database,
    required this.project,
    required this.container,
  });

  final Directory root;
  final ProjectPaths paths;
  final AppDatabase database;
  final Project project;
  final ProviderContainer container;

  static Future<_EditorWidgetHarness> create(
    WidgetTester tester, {
    required int frameCount,
  }) async {
    final Directory root =
        await tester.runAsync(
              () => Directory.systemTemp.createTemp('editor_page_'),
            )
            as Directory;
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
    final Project project = (await tester.runAsync(
      () => projects.createProject(
        ProjectDraft(
          title: 'Timeline film',
          aspectRatio: ProjectAspectRatio.widescreen,
          resolution: ProjectResolution.fullHd1080,
          framesPerSecond: 12,
          backgroundColorValue: Colors.black.toARGB32(),
        ),
      ),
    ))!;
    await database.batch((Batch batch) {
      for (var index = 0; index < frameCount; index++) {
        batch.insert(
          database.frameRecords,
          FrameRecordsCompanion.insert(
            id: 'frame-$index',
            projectId: project.id,
            relativeSourcePath: 'projects/${project.id}/frames/$index.jpg',
            position: index,
            createdAt: DateTime.utc(2026),
            sourceWidth: 640,
            sourceHeight: 360,
            missing: const Value<bool>(true),
          ),
        );
      }
    });
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        projectPathsProvider.overrideWithValue(paths),
      ],
    );
    return _EditorWidgetHarness(
      root: root,
      paths: paths,
      database: database,
      project: project,
      container: container,
    );
  }

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EditorPage(projectId: project.id)),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await tester.runAsync(database.close);
    await tester.runAsync(() => root.delete(recursive: true));
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}
