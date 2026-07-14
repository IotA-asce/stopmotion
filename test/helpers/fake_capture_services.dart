import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stop_motion/core/media/camera_capabilities.dart';
import 'package:stop_motion/core/media/camera_service.dart';
import 'package:stop_motion/features/capture/data/capture_feedback.dart';
import 'package:stop_motion/features/capture/data/capture_storage_guard.dart';
import 'package:stop_motion/features/capture/data/capture_wake_lock.dart';
import 'package:stop_motion/features/capture/data/frame_picker.dart';
import 'package:stop_motion/features/capture/domain/capture_frame.dart';
import 'package:stop_motion/features/capture/domain/capture_scheduler.dart';

class FakeCameraService implements CameraService {
  FakeCameraService({
    CameraAvailability initialAvailability = CameraAvailability.idle,
    this.captureCompleter,
    this.initializedSnapshot,
    this.initializeFailure,
  }) : _snapshot = CameraSnapshot(availability: initialAvailability);

  final Queue<File> sources = Queue<File>();
  final StreamController<CameraSnapshot> _snapshots =
      StreamController<CameraSnapshot>.broadcast(sync: true);
  final Completer<File>? captureCompleter;
  final CameraSnapshot? initializedSnapshot;
  final CameraFailure? initializeFailure;
  CameraSnapshot _snapshot;
  int captureCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  CameraFlash flash = CameraFlash.off;
  double zoom = 1;
  double exposure = 0;
  bool locked = false;

  @override
  CameraSnapshot get snapshot => _snapshot;

  @override
  Stream<CameraSnapshot> get snapshots => _snapshots.stream;

  @override
  Future<void> initialize() async {
    final CameraSnapshot ready =
        initializedSnapshot ??
        const CameraSnapshot(
          availability: CameraAvailability.ready,
          capabilities: CameraCapabilities(
            cameraCount: 2,
            facing: CameraFacing.rear,
            minimumZoom: 1,
            maximumZoom: 4,
            minimumExposure: -2,
            maximumExposure: 2,
            flashModes: <CameraFlash>{
              CameraFlash.off,
              CameraFlash.auto,
              CameraFlash.on,
            },
          ),
        );
    _emit(ready);
    if (initializeFailure case final CameraFailure failure) {
      throw failure;
    }
  }

  @override
  Widget buildPreview() => const ColoredBox(
    key: Key('fake-camera-preview'),
    color: Color(0xFF263238),
  );

  @override
  Future<File> capture() {
    captureCalls++;
    if (captureCompleter case final Completer<File> completer) {
      return completer.future;
    }
    if (sources.isEmpty) {
      throw const CameraFailure(
        CameraFailureKind.capture,
        'No fake source queued.',
      );
    }
    return Future<File>.value(sources.removeFirst());
  }

  @override
  Future<void> switchCamera() async {}

  @override
  Future<void> setFlash(CameraFlash flash) async => this.flash = flash;

  @override
  Future<void> setZoom(double zoom) async => this.zoom = zoom;

  @override
  Future<void> setExposure(double exposure) async => this.exposure = exposure;

  @override
  Future<void> setFocusAndExposure(Offset point) async {}

  @override
  Future<void> setLocks({required bool locked}) async => this.locked = locked;

  @override
  Future<void> pause() async {
    pauseCalls++;
    _emit(const CameraSnapshot(availability: CameraAvailability.paused));
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
    await initialize();
  }

  @override
  Future<void> dispose() async {
    await _snapshots.close();
  }

  void emit(CameraSnapshot snapshot) => _emit(snapshot);

  void _emit(CameraSnapshot snapshot) {
    _snapshot = snapshot;
    if (!_snapshots.isClosed) {
      _snapshots.add(snapshot);
    }
  }
}

class FakeFramePicker implements FramePicker {
  List<CaptureSource> picked = <CaptureSource>[];
  List<CaptureSource> recovered = <CaptureSource>[];

  @override
  Future<List<CaptureSource>> pickImages() async => picked;

  @override
  Future<List<CaptureSource>> recoverLostImages() async => recovered;
}

class FakeWakeLock implements CaptureWakeLock {
  int enables = 0;
  int disables = 0;

  @override
  Future<void> enable() async => enables++;

  @override
  Future<void> disable() async => disables++;
}

class FakeCaptureFeedback implements CaptureFeedback {
  int accepted = 0;

  @override
  Future<void> frameAccepted() async => accepted++;
}

class FakeStorageGuard implements CaptureStorageGuard {
  bool available = true;

  @override
  Future<bool> hasSpaceForFrame() async => available;
}

class FakeCaptureScheduler implements CaptureScheduler {
  void Function()? callback;
  bool cancelled = false;

  @override
  Future<void> delay(Duration duration) async {}

  @override
  CancelableInterval periodic(Duration duration, void Function() callback) {
    this.callback = callback;
    return _FakeInterval(this);
  }

  void tick() => callback?.call();
}

class _FakeInterval implements CancelableInterval {
  const _FakeInterval(this.scheduler);

  final FakeCaptureScheduler scheduler;

  @override
  void cancel() => scheduler.cancelled = true;
}
