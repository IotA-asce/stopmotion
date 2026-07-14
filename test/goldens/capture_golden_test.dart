import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/capture/data/system_settings_service.dart';
import 'package:stop_motion/features/capture/presentation/capture_page.dart';
import 'package:stop_motion/features/capture/presentation/capture_providers.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

import '../helpers/fake_capture_services.dart';

void main() {
  testWidgets('capture workspace matches phone composition', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    final Directory root = Directory.systemTemp.createTempSync(
      'capture_golden_',
    );
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    final AppDatabase database = AppDatabase.memory();
    final ProjectRepository repository = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    );
    final Project project = (await tester.runAsync(
      () => repository.createProject(
        ProjectDraft(
          title: 'Paper planets',
          aspectRatio: ProjectAspectRatio.widescreen,
          resolution: ProjectResolution.fullHd1080,
          framesPerSecond: 12,
          backgroundColorValue: 0,
        ),
      ),
    ))!;
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        projectPathsProvider.overrideWithValue(paths),
        cameraServiceProvider.overrideWith(
          (Ref ref, String projectId) => FakeCameraService(),
        ),
        framePickerProvider.overrideWithValue(FakeFramePicker()),
        captureWakeLockProvider.overrideWithValue(FakeWakeLock()),
        captureStorageGuardProvider.overrideWithValue(FakeStorageGuard()),
        systemSettingsServiceProvider.overrideWithValue(const _FakeSettings()),
      ],
    );
    const Key boundary = Key('capture-golden');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: CapturePage(projectId: project.id),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();

    await expectLater(
      find.byKey(boundary),
      matchesGoldenFile('files/capture_phone.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump();
    container.dispose();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.runAsync(database.close);
    root.deleteSync(recursive: true);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }, skip: !Platform.isMacOS);
}

class _FakeSettings implements SystemSettingsService {
  const _FakeSettings();

  @override
  Future<bool> openAppSettings() async => true;
}
