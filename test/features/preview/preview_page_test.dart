import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/editor/data/editor_repository.dart';
import 'package:stop_motion/features/preview/presentation/preview_controller.dart';
import 'package:stop_motion/features/preview/presentation/preview_page.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

void main() {
  testWidgets(
    'full-screen preview exposes playback, loop, scrub, and quality',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      final Directory root =
          await tester.runAsync(
                () => Directory.systemTemp.createTemp('preview_page_'),
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
            title: 'Preview page',
            aspectRatio: ProjectAspectRatio.widescreen,
            resolution: ProjectResolution.fullHd1080,
            framesPerSecond: 12,
            backgroundColorValue: Colors.black.toARGB32(),
          ),
        ),
      ))!;
      final File source = paths.resolveRelativeFile(
        'projects/${project.id}/frames/source.png',
      );
      await tester.runAsync(() async {
        await source.parent.create(recursive: true);
        await source.writeAsBytes(
          img.encodePng(
            img.Image(width: 320, height: 180)
              ..clear(img.ColorRgb8(40, 180, 120)),
          ),
        );
        await database
            .into(database.frameRecords)
            .insert(
              FrameRecordsCompanion.insert(
                id: 'preview-frame',
                projectId: project.id,
                relativeSourcePath: paths.relativeToRoot(source),
                position: 0,
                createdAt: DateTime.utc(2026),
                sourceWidth: 320,
                sourceHeight: 180,
              ),
            );
      });
      final PreviewController controller = PreviewController(
        projectId: project.id,
        initialFrame: 0,
        editor: EditorRepository(database: database),
        projects: projects,
      );
      await tester.runAsync(controller.initialize);
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          projectPathsProvider.overrideWithValue(paths),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: PreviewPage(projectId: project.id, controller: controller),
          ),
        ),
      );

      expect(find.byTooltip('Play'), findsOneWidget);
      expect(find.byTooltip('Enable loop'), findsOneWidget);
      expect(find.byTooltip('Preview quality'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      controller.dispose();
      container.dispose();
      await tester.runAsync(database.close);
      await tester.runAsync(() => root.delete(recursive: true));
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    },
  );
}
