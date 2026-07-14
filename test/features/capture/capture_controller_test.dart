import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/media/camera_capabilities.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/capture/data/capture_repository.dart';
import 'package:stop_motion/features/capture/domain/capture_frame.dart';
import 'package:stop_motion/features/capture/domain/interval_capture.dart';
import 'package:stop_motion/features/capture/presentation/capture_controller.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/data/project_thumbnail_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

import '../../helpers/fake_capture_services.dart';

void main() {
  late AppDatabase database;
  late Directory root;
  late ProjectPaths paths;
  late ProjectRepository projects;
  late CaptureRepository captures;
  late Project project;
  late FakeFramePicker picker;
  late FakeWakeLock wakeLock;
  late FakeStorageGuard storage;
  late FakeCaptureScheduler scheduler;
  late FakeCaptureFeedback feedback;

  setUp(() async {
    database = AppDatabase.memory();
    root = await Directory.systemTemp.createTemp('capture_controller_');
    paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    );
    project = await projects.createProject(
      ProjectDraft(
        title: 'Controller film',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 12,
        backgroundColorValue: 0,
      ),
    );
    captures = CaptureRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
      thumbnails: ProjectThumbnailRepository(paths),
    );
    picker = FakeFramePicker();
    wakeLock = FakeWakeLock();
    storage = FakeStorageGuard();
    scheduler = FakeCaptureScheduler();
    feedback = FakeCaptureFeedback();
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  Future<File> source(String name, {int width = 20, int height = 14}) => File(
    '${root.path}/$name.jpg',
  ).writeAsBytes(image.encodeJpg(image.Image(width: width, height: height)));

  CaptureController controller(FakeCameraService camera) => CaptureController(
    projectId: project.id,
    camera: camera,
    captureRepository: captures,
    projectRepository: projects,
    paths: paths,
    picker: picker,
    wakeLock: wakeLock,
    storageGuard: storage,
    scheduler: scheduler,
    feedback: feedback,
  );

  test('suppresses duplicate shutter taps until durable acceptance', () async {
    final Completer<File> cameraResult = Completer<File>();
    final FakeCameraService camera = FakeCameraService(
      captureCompleter: cameraResult,
    );
    final CaptureController subject = controller(camera);
    await subject.initialize();

    final Future<Object?> first = subject.capture();
    final Object? duplicate = await subject.capture();
    expect(duplicate, isNull);
    expect(camera.captureCalls, 1);
    expect(feedback.accepted, 0);

    cameraResult.complete(await source('single'));
    expect(await first, isNotNull);
    expect(feedback.accepted, 1);
    expect((await captures.getFrames(project.id)).length, 1);

    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('interval owns wakelock and stops when storage becomes low', () async {
    final FakeCameraService camera = FakeCameraService();
    camera.sources.add(await source('interval'));
    final CaptureController subject = controller(camera);
    await subject.initialize();

    await subject.startInterval(const IntervalCaptureSettings(seconds: 3));
    expect(wakeLock.enables, 1);
    scheduler.tick();
    await _waitFor(() => subject.state.intervalFrameCount == 1);
    expect(subject.state.intervalFrameCount, 1);

    storage.available = false;
    scheduler.tick();
    await _waitFor(() => !subject.state.intervalActive);
    expect(wakeLock.disables, greaterThanOrEqualTo(1));
    expect(subject.state.errorMessage, contains('storage'));

    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('batch import keeps valid frames and reports failed files', () async {
    final File valid = await source('valid_import');
    final File damaged = await File(
      '${root.path}/damaged_import.jpg',
    ).writeAsBytes(<int>[1, 2]);
    picker.picked = <CaptureSource>[
      CaptureSource(file: valid),
      CaptureSource(file: damaged),
    ];
    final CaptureController subject = controller(FakeCameraService());
    await subject.initialize();

    await subject.importFromPicker();

    expect((await captures.getFrames(project.id)).length, 1);
    expect(subject.state.errorMessage, '1 image(s) could not be imported.');
    expect(await valid.exists(), isTrue);
    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('camera controls and overlays remain capability driven', () async {
    final FakeCameraService camera = FakeCameraService();
    final CaptureController subject = controller(camera);
    await subject.initialize();

    subject.setGrid(CaptureGrid.thirds);
    subject.setOnionMode(OnionMode.difference);
    subject.setOnionOpacity(0.7);
    await subject.setFlash(CameraFlash.auto);
    await subject.setZoom(2.5);
    await subject.setExposure(1.25);
    await subject.toggleLocks();

    expect(subject.state.grid, CaptureGrid.thirds);
    expect(subject.state.onionMode, OnionMode.difference);
    expect(subject.state.onionOpacity, 0.7);
    expect(camera.flash, CameraFlash.auto);
    expect(camera.zoom, 2.5);
    expect(camera.exposure, 1.25);
    expect(camera.locked, isTrue);
    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('import preserves confirmed picker order using owned copies', () async {
    final File first = await source('first_order', width: 11);
    final File second = await source('second_order', width: 22);
    picker.picked = <CaptureSource>[
      CaptureSource(file: second),
      CaptureSource(file: first),
    ];
    final CaptureController subject = controller(FakeCameraService());
    await subject.initialize();

    await subject.importFromPicker();
    final frames = await captures.getFrames(project.id);

    expect(frames.map((frame) => frame.sourceWidth), <int>[22, 11]);
    expect(await first.exists(), isTrue);
    expect(await second.exists(), isTrue);
    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('recovers Android picker results during initialization', () async {
    picker.recovered = <CaptureSource>[
      CaptureSource(file: await source('recovered')),
    ];
    final CaptureController subject = controller(FakeCameraService());

    await subject.initialize();

    expect((await captures.getFrames(project.id)).length, 1);
    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('lifecycle pause cancels interval and releases resources', () async {
    final FakeCameraService camera = FakeCameraService();
    final CaptureController subject = controller(camera);
    await subject.initialize();
    await subject.startInterval(const IntervalCaptureSettings(seconds: 5));

    await subject.pause();

    expect(subject.state.intervalActive, isFalse);
    expect(wakeLock.disables, greaterThanOrEqualTo(1));
    expect(camera.pauseCalls, 1);
    await subject.resume();
    expect(camera.resumeCalls, 1);
    subject.dispose();
    await Future<void>.delayed(Duration.zero);
  });
}

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condition did not become true.');
}
