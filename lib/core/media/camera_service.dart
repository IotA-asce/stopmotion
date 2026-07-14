import 'dart:io';

import 'package:flutter/widgets.dart';

import 'camera_capabilities.dart';

enum CameraAvailability {
  idle,
  initializing,
  ready,
  denied,
  restricted,
  unavailable,
  failed,
  paused,
}

enum CameraFailureKind { denied, restricted, unavailable, capture, unknown }

class CameraFailure implements Exception {
  const CameraFailure(this.kind, this.message, {this.code});

  final CameraFailureKind kind;
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class CameraSnapshot {
  const CameraSnapshot({
    required this.availability,
    this.capabilities,
    this.message,
  });

  final CameraAvailability availability;
  final CameraCapabilities? capabilities;
  final String? message;
}

abstract interface class CameraService {
  CameraSnapshot get snapshot;
  Stream<CameraSnapshot> get snapshots;

  Future<void> initialize();
  Widget buildPreview();
  Future<File> capture();
  Future<void> switchCamera();
  Future<void> setFlash(CameraFlash flash);
  Future<void> setZoom(double zoom);
  Future<void> setExposure(double exposure);
  Future<void> setFocusAndExposure(Offset point);
  Future<void> setLocks({required bool locked});
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}
