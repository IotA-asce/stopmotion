import 'dart:io';

import 'package:drift/drift.dart';
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
  testWidgets('editor workspace matches phone composition', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    final Directory root =
        await tester.runAsync(
              () => Directory.systemTemp.createTemp('editor_golden_'),
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
          title: 'Paper planets',
          aspectRatio: ProjectAspectRatio.widescreen,
          resolution: ProjectResolution.fullHd1080,
          framesPerSecond: 12,
          backgroundColorValue: Colors.black.toARGB32(),
        ),
      ),
    ))!;
    await database.batch((Batch batch) {
      for (var index = 0; index < 6; index++) {
        batch.insert(
          database.frameRecords,
          FrameRecordsCompanion.insert(
            id: 'golden-$index',
            projectId: project.id,
            relativeSourcePath: 'projects/${project.id}/frames/$index.jpg',
            position: index,
            holdFrames: Value<int>(index == 2 ? 3 : 1),
            createdAt: DateTime.utc(2026),
            sourceWidth: 1920,
            sourceHeight: 1080,
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
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
          ),
          home: EditorPage(projectId: project.id),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('files/editor_phone.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await tester.runAsync(database.close);
    await tester.runAsync(() => root.delete(recursive: true));
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }, skip: !Platform.isMacOS);
}
