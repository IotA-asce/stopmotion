import 'dart:async';
import 'dart:io';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../../../core/filesystem/project_paths.dart';
import '../../../core/media/camera_capabilities.dart';
import '../../../core/media/camera_service.dart';
import '../../../core/recovery/operation.dart';
import '../../editor/domain/frame.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/domain/project.dart';
import '../data/capture_feedback.dart';
import '../data/capture_repository.dart';
import '../data/capture_storage_guard.dart';
import '../data/capture_wake_lock.dart';
import '../data/frame_picker.dart';
import '../domain/capture_frame.dart';
import '../domain/capture_scheduler.dart';
import '../domain/interval_capture.dart';

class CaptureViewState {
  const CaptureViewState({
    this.project,
    this.frames = const <ProjectFrame>[],
    this.camera = const CameraSnapshot(availability: CameraAvailability.idle),
    this.capturing = false,
    this.importing = false,
    this.importProgress = 0,
    this.importTotal = 0,
    this.countdown,
    this.intervalActive = false,
    this.intervalFrameCount = 0,
    this.grid = CaptureGrid.off,
    this.onionMode = OnionMode.off,
    this.onionOpacity = 0.45,
    this.timerSeconds = 0,
    this.flash = CameraFlash.off,
    this.zoom = 1,
    this.exposure = 0,
    this.locksEnabled = false,
    this.errorMessage,
  });

  final Project? project;
  final List<ProjectFrame> frames;
  final CameraSnapshot camera;
  final bool capturing;
  final bool importing;
  final int importProgress;
  final int importTotal;
  final int? countdown;
  final bool intervalActive;
  final int intervalFrameCount;
  final CaptureGrid grid;
  final OnionMode onionMode;
  final double onionOpacity;
  final int timerSeconds;
  final CameraFlash flash;
  final double zoom;
  final double exposure;
  final bool locksEnabled;
  final String? errorMessage;

  CaptureViewState copyWith({
    Project? project,
    List<ProjectFrame>? frames,
    CameraSnapshot? camera,
    bool? capturing,
    bool? importing,
    int? importProgress,
    int? importTotal,
    int? countdown,
    bool clearCountdown = false,
    bool? intervalActive,
    int? intervalFrameCount,
    CaptureGrid? grid,
    OnionMode? onionMode,
    double? onionOpacity,
    int? timerSeconds,
    CameraFlash? flash,
    double? zoom,
    double? exposure,
    bool? locksEnabled,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CaptureViewState(
      project: project ?? this.project,
      frames: frames ?? this.frames,
      camera: camera ?? this.camera,
      capturing: capturing ?? this.capturing,
      importing: importing ?? this.importing,
      importProgress: importProgress ?? this.importProgress,
      importTotal: importTotal ?? this.importTotal,
      countdown: clearCountdown ? null : countdown ?? this.countdown,
      intervalActive: intervalActive ?? this.intervalActive,
      intervalFrameCount: intervalFrameCount ?? this.intervalFrameCount,
      grid: grid ?? this.grid,
      onionMode: onionMode ?? this.onionMode,
      onionOpacity: onionOpacity ?? this.onionOpacity,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      flash: flash ?? this.flash,
      zoom: zoom ?? this.zoom,
      exposure: exposure ?? this.exposure,
      locksEnabled: locksEnabled ?? this.locksEnabled,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CaptureController extends ChangeNotifier {
  CaptureController({
    required String projectId,
    required CameraService camera,
    required CaptureRepository captureRepository,
    required ProjectRepository projectRepository,
    required ProjectPaths paths,
    required FramePicker picker,
    required CaptureWakeLock wakeLock,
    required CaptureStorageGuard storageGuard,
    CaptureScheduler scheduler = const DartCaptureScheduler(),
    CaptureFeedback feedback = const NoopCaptureFeedback(),
    CaptureViewState initialState = const CaptureViewState(),
    VoidCallback? onAccepted,
  }) : this._(
         projectId,
         camera,
         captureRepository,
         projectRepository,
         paths,
         picker,
         wakeLock,
         storageGuard,
         scheduler,
         feedback,
         initialState,
         onAccepted ?? _noop,
       );

  CaptureController._(
    this.projectId,
    this._camera,
    this._captureRepository,
    this._projectRepository,
    this._paths,
    this._picker,
    this._wakeLock,
    this._storageGuard,
    this._scheduler,
    this._feedback,
    this._state,
    this._onAccepted,
  );

  final String projectId;
  final CameraService _camera;
  final CaptureRepository _captureRepository;
  final ProjectRepository _projectRepository;
  final ProjectPaths _paths;
  final FramePicker _picker;
  final CaptureWakeLock _wakeLock;
  final CaptureStorageGuard _storageGuard;
  final CaptureScheduler _scheduler;
  final CaptureFeedback _feedback;
  final VoidCallback _onAccepted;
  StreamSubscription<CameraSnapshot>? _cameraSubscription;
  StreamSubscription<List<ProjectFrame>>? _frameSubscription;
  CancelableInterval? _interval;
  var _countdownGeneration = 0;
  var _disposed = false;
  var _captureActive = false;
  Completer<void>? _captureSettled;
  CaptureViewState _state;

  CaptureViewState get state => _state;
  CameraService get camera => _camera;

  Future<void> waitForActiveCapture() =>
      _captureSettled?.future ?? Future<void>.value();

  Future<void> initialize() async {
    _cameraSubscription = _camera.snapshots.listen((CameraSnapshot snapshot) {
      _update(_state.copyWith(camera: snapshot));
    });
    _frameSubscription = _captureRepository
        .watchFrames(projectId)
        .listen(
          (List<ProjectFrame> frames) =>
              _update(_state.copyWith(frames: frames)),
        );
    final Project? project = await _projectRepository.getProject(projectId);
    if (project == null) {
      _update(_state.copyWith(errorMessage: 'Project no longer exists.'));
      return;
    }
    _update(_state.copyWith(project: project));
    try {
      await _camera.initialize();
    } on CameraFailure {
      // The camera snapshot carries the actionable denied/unavailable state.
    }
    try {
      final List<CaptureSource> recovered = await _picker.recoverLostImages();
      if (recovered.isNotEmpty) {
        await importSources(recovered);
      }
    } on Object catch (error) {
      _update(
        _state.copyWith(errorMessage: 'Interrupted import failed: $error'),
      );
    }
  }

  Future<ProjectFrame?> capture({bool skipTimer = false}) async {
    if (_captureActive || _state.importing || _disposed) {
      return null;
    }
    _captureActive = true;
    _captureSettled = Completer<void>();
    _update(_state.copyWith(capturing: true, clearError: true));
    try {
      if (!await _storageGuard.hasSpaceForFrame()) {
        await stopInterval(
          reason: 'Capture stopped because storage is running low.',
        );
        return null;
      }
      if (!skipTimer && _state.timerSeconds > 0) {
        final int generation = ++_countdownGeneration;
        for (var second = _state.timerSeconds; second > 0; second--) {
          _update(_state.copyWith(countdown: second, clearError: true));
          await _scheduler.delay(const Duration(seconds: 1));
          if (generation != _countdownGeneration || _disposed) {
            _update(_state.copyWith(clearCountdown: true));
            return null;
          }
        }
        _update(_state.copyWith(clearCountdown: true));
      }
      final File source = await _camera.capture();
      final ProjectFrame accepted = await _captureRepository.acceptFrame(
        projectId: projectId,
        source: CaptureSource(file: source, deleteAfterAccept: true),
      );
      if (_state.intervalActive) {
        _update(
          _state.copyWith(intervalFrameCount: _state.intervalFrameCount + 1),
        );
      }
      try {
        await _feedback.frameAccepted();
      } on Object {
        // Haptic feedback is optional after the frame is already durable.
      }
      _onAccepted();
      return accepted;
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Frame was not saved: $error'));
      if (_state.intervalActive) {
        await stopInterval(reason: 'Interval capture stopped after a failure.');
      }
      return null;
    } finally {
      _captureActive = false;
      _update(_state.copyWith(capturing: false, clearCountdown: true));
      _captureSettled?.complete();
      _captureSettled = null;
    }
  }

  void cancelCountdown() {
    _countdownGeneration++;
    _update(_state.copyWith(clearCountdown: true));
  }

  Future<void> startInterval(IntervalCaptureSettings settings) async {
    if (_state.intervalActive) {
      return;
    }
    cancelCountdown();
    await _wakeLock.enable();
    _update(
      _state.copyWith(
        intervalActive: true,
        intervalFrameCount: 0,
        clearError: true,
      ),
    );
    _interval = _scheduler.periodic(settings.duration, () {
      if (!_state.capturing) {
        unawaited(capture(skipTimer: true));
      }
    });
  }

  Future<void> stopInterval({String? reason}) async {
    _interval?.cancel();
    _interval = null;
    await _wakeLock.disable();
    _update(
      _state.copyWith(
        intervalActive: false,
        errorMessage: reason,
        clearError: reason == null,
      ),
    );
  }

  Future<void> importFromPicker() async {
    try {
      await importSources(await _picker.pickImages());
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Import could not start: $error'));
    }
  }

  Future<List<CaptureSource>> pickSources() => _picker.pickImages();

  Future<void> importSources(List<CaptureSource> sources) async {
    if (sources.isEmpty || _state.importing || _state.capturing) {
      return;
    }
    _update(
      _state.copyWith(
        importing: true,
        importProgress: 0,
        importTotal: sources.length,
        clearError: true,
      ),
    );
    var failed = 0;
    for (var index = 0; index < sources.length; index++) {
      if (!await _storageGuard.hasSpaceForFrame()) {
        failed += sources.length - index;
        _update(
          _state.copyWith(
            errorMessage: 'Import stopped because storage is running low.',
          ),
        );
        break;
      }
      try {
        await _captureRepository.acceptFrame(
          projectId: projectId,
          source: sources[index],
          operationType: OperationType.import,
        );
        _onAccepted();
      } on Object {
        failed++;
      }
      _update(_state.copyWith(importProgress: index + 1));
    }
    _update(
      _state.copyWith(
        importing: false,
        errorMessage: failed == 0
            ? null
            : '$failed image(s) could not be imported.',
        clearError: failed == 0,
      ),
    );
  }

  Future<void> duplicateFrame(ProjectFrame frame) async {
    await _captureRepository.duplicateFrame(projectId, frame.id);
  }

  Future<DeletedFrame> deleteFrame(ProjectFrame frame) =>
      _captureRepository.deleteFrame(projectId, frame.id);

  Future<void> undoDelete(DeletedFrame deleted) =>
      _captureRepository.restoreDeletedFrame(deleted);

  Future<void> retakeFrame(ProjectFrame frame) async {
    if (_captureActive) {
      return;
    }
    _captureActive = true;
    _captureSettled = Completer<void>();
    _update(_state.copyWith(capturing: true, clearError: true));
    try {
      final File source = await _camera.capture();
      await _captureRepository.retakeFrame(
        projectId: projectId,
        frameId: frame.id,
        source: CaptureSource(file: source, deleteAfterAccept: true),
      );
      _onAccepted();
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Retake was not saved: $error'));
    } finally {
      _captureActive = false;
      _update(_state.copyWith(capturing: false));
      _captureSettled?.complete();
      _captureSettled = null;
    }
  }

  void setGrid(CaptureGrid grid) => _update(_state.copyWith(grid: grid));
  void setOnionMode(OnionMode mode) =>
      _update(_state.copyWith(onionMode: mode));
  void setOnionOpacity(double value) =>
      _update(_state.copyWith(onionOpacity: value.clamp(0.1, 0.9)));
  void setTimerSeconds(int seconds) =>
      _update(_state.copyWith(timerSeconds: seconds));

  Future<void> setFlash(CameraFlash flash) async {
    try {
      await _camera.setFlash(flash);
      _update(_state.copyWith(flash: flash, clearError: true));
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Flash is unavailable: $error'));
    }
  }

  Future<void> switchCamera() async {
    try {
      await _camera.switchCamera();
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Camera switch failed: $error'));
    }
  }

  Future<void> setZoom(double zoom) async {
    try {
      await _camera.setZoom(zoom);
      _update(_state.copyWith(zoom: zoom, clearError: true));
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Zoom is unavailable: $error'));
    }
  }

  Future<void> setExposure(double exposure) async {
    try {
      await _camera.setExposure(exposure);
      _update(_state.copyWith(exposure: exposure, clearError: true));
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Exposure is unavailable: $error'));
    }
  }

  Future<void> focus(Offset point) async {
    try {
      await _camera.setFocusAndExposure(point);
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Focus is unavailable: $error'));
    }
  }

  Future<void> toggleLocks() async {
    final bool locked = !_state.locksEnabled;
    try {
      await _camera.setLocks(locked: locked);
      _update(_state.copyWith(locksEnabled: locked, clearError: true));
    } on Object catch (error) {
      _update(
        _state.copyWith(errorMessage: 'Focus lock is unavailable: $error'),
      );
    }
  }

  File resolveFrame(ProjectFrame frame) =>
      _paths.resolveRelativeFile(frame.relativeSourcePath);

  Future<void> pause() async {
    cancelCountdown();
    await stopInterval();
    await _camera.pause();
  }

  Future<void> resume() => _camera.resume();

  void clearError() => _update(_state.copyWith(clearError: true));

  void _update(CaptureViewState state) {
    if (_disposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _countdownGeneration++;
    _interval?.cancel();
    unawaited(_wakeLock.disable());
    unawaited(_cameraSubscription?.cancel());
    unawaited(_frameSubscription?.cancel());
    unawaited(_camera.dispose());
    super.dispose();
  }
}

void _noop() {}
