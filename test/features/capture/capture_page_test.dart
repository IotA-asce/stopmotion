import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/media/camera_service.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/capture/data/system_settings_service.dart';
import 'package:stop_motion/features/capture/presentation/capture_page.dart';
import 'package:stop_motion/features/capture/presentation/capture_providers.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

import '../../helpers/fake_capture_services.dart';

void main() {
  testWidgets('renders stable camera controls without platform channels', (
    WidgetTester tester,
  ) async {
    final _CaptureWidgetHarness harness = await _CaptureWidgetHarness.create(
      tester,
    );
    await harness.pump(tester);

    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(find.byTooltip('Capture frame'), findsOneWidget);
    expect(find.byTooltip('Onion skin'), findsOneWidget);
    expect(find.byTooltip('Composition grid'), findsOneWidget);
    expect(find.text('Widget film  0'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await harness.dispose(tester);
  });

  testWidgets('denied camera keeps import and settings actions usable', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    final FakeSystemSettings settings = FakeSystemSettings();
    final FakeCameraService camera = FakeCameraService(
      initializedSnapshot: const CameraSnapshot(
        availability: CameraAvailability.denied,
        message: 'Enable camera access in system settings.',
      ),
      initializeFailure: const CameraFailure(
        CameraFailureKind.denied,
        'Enable camera access in system settings.',
      ),
    );
    final _CaptureWidgetHarness harness = await _CaptureWidgetHarness.create(
      tester,
      camera: camera,
      settings: settings,
    );
    await harness.pump(tester);

    expect(find.text('Camera access is off'), findsOneWidget);
    expect(find.text('Import images'), findsWidgets);
    await tester.ensureVisible(find.text('Open settings'));
    await tester.tap(find.text('Open settings'));
    await tester.pump();
    expect(settings.calls, 1);
    expect(tester.takeException(), isNull);

    await harness.dispose(tester);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

class _CaptureWidgetHarness {
  _CaptureWidgetHarness({
    required this.root,
    required this.paths,
    required this.database,
    required this.project,
    required this.camera,
    required this.picker,
    required this.wakeLock,
    required this.storage,
    required this.settings,
    required this.container,
  });

  final Directory root;
  final ProjectPaths paths;
  final AppDatabase database;
  final Project project;
  final FakeCameraService camera;
  final FakeFramePicker picker;
  final FakeWakeLock wakeLock;
  final FakeStorageGuard storage;
  final SystemSettingsService settings;
  final ProviderContainer container;

  static Future<_CaptureWidgetHarness> create(
    WidgetTester tester, {
    FakeCameraService? camera,
    SystemSettingsService? settings,
  }) async {
    final Directory root = Directory.systemTemp.createTempSync('capture_page_');
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
          title: 'Widget film',
          aspectRatio: ProjectAspectRatio.widescreen,
          resolution: ProjectResolution.fullHd1080,
          framesPerSecond: 12,
          backgroundColorValue: 0,
        ),
      ),
    ))!;
    final FakeCameraService resolvedCamera = camera ?? FakeCameraService();
    final FakeFramePicker picker = FakeFramePicker();
    final FakeWakeLock wakeLock = FakeWakeLock();
    final FakeStorageGuard storage = FakeStorageGuard();
    final SystemSettingsService resolvedSettings =
        settings ?? FakeSystemSettings();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        projectPathsProvider.overrideWithValue(paths),
        cameraServiceProvider.overrideWith(
          (Ref ref, String projectId) => resolvedCamera,
        ),
        framePickerProvider.overrideWithValue(picker),
        captureWakeLockProvider.overrideWithValue(wakeLock),
        captureStorageGuardProvider.overrideWithValue(storage),
        systemSettingsServiceProvider.overrideWithValue(resolvedSettings),
      ],
    );
    return _CaptureWidgetHarness(
      root: root,
      paths: paths,
      database: database,
      project: project,
      camera: resolvedCamera,
      picker: picker,
      wakeLock: wakeLock,
      storage: storage,
      settings: resolvedSettings,
      container: container,
    );
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CapturePage(projectId: project.id)),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump();
    container.dispose();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.runAsync(database.close);
    root.deleteSync(recursive: true);
  }
}

class FakeSystemSettings implements SystemSettingsService {
  int calls = 0;

  @override
  Future<bool> openAppSettings() async {
    calls++;
    return true;
  }
}
