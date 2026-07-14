import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import 'camera_capabilities.dart';
import 'camera_service.dart';

class PackageCameraService implements CameraService {
  final StreamController<CameraSnapshot> _snapshots =
      StreamController<CameraSnapshot>.broadcast(sync: true);
  List<CameraDescription> _cameras = const <CameraDescription>[];
  CameraController? _controller;
  int _selectedIndex = 0;
  CameraSnapshot _snapshot = const CameraSnapshot(
    availability: CameraAvailability.idle,
  );

  @override
  CameraSnapshot get snapshot => _snapshot;

  @override
  Stream<CameraSnapshot> get snapshots => _snapshots.stream;

  @override
  Future<void> initialize() async {
    _emit(const CameraSnapshot(availability: CameraAvailability.initializing));
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw const CameraFailure(
          CameraFailureKind.unavailable,
          'No camera is available on this device.',
        );
      }
      final int rearIndex = _cameras.indexWhere(
        (CameraDescription camera) =>
            camera.lensDirection == CameraLensDirection.back,
      );
      if (_controller == null && rearIndex >= 0) {
        _selectedIndex = rearIndex;
      }
      await _initializeSelectedController();
    } on CameraFailure catch (error) {
      _emitFailure(error);
      rethrow;
    } on CameraException catch (error) {
      final CameraFailure failure = _mapException(error);
      _emitFailure(failure);
      throw failure;
    } on Object catch (error) {
      final CameraFailure failure = CameraFailure(
        CameraFailureKind.unknown,
        'Camera could not start.',
        code: error.runtimeType.toString(),
      );
      _emitFailure(failure);
      throw failure;
    }
  }

  Future<void> _initializeSelectedController() async {
    await _controller?.dispose();
    final CameraController controller = CameraController(
      _cameras[_selectedIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    await controller.initialize();
    final List<double> limits = await Future.wait(<Future<double>>[
      controller.getMinZoomLevel(),
      controller.getMaxZoomLevel(),
      controller.getMinExposureOffset(),
      controller.getMaxExposureOffset(),
    ]);
    _emit(
      CameraSnapshot(
        availability: CameraAvailability.ready,
        capabilities: CameraCapabilities(
          cameraCount: _cameras.length,
          facing: _mapFacing(_cameras[_selectedIndex].lensDirection),
          minimumZoom: limits[0],
          maximumZoom: limits[1],
          minimumExposure: limits[2],
          maximumExposure: limits[3],
          flashModes: const <CameraFlash>{
            CameraFlash.off,
            CameraFlash.auto,
            CameraFlash.on,
            CameraFlash.torch,
          },
        ),
      ),
    );
  }

  @override
  Widget buildPreview() {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.expand();
    }
    return CameraPreview(controller);
  }

  @override
  Future<File> capture() async {
    final CameraController controller = _requireController();
    try {
      final XFile result = await controller.takePicture();
      return File(result.path);
    } on CameraException catch (error) {
      throw CameraFailure(
        CameraFailureKind.capture,
        'The camera could not capture this frame.',
        code: error.code,
      );
    }
  }

  @override
  Future<void> switchCamera() async {
    if (_cameras.length < 2) {
      return;
    }
    _selectedIndex = (_selectedIndex + 1) % _cameras.length;
    _emit(const CameraSnapshot(availability: CameraAvailability.initializing));
    await _initializeSelectedController();
  }

  @override
  Future<void> setFlash(CameraFlash flash) =>
      _requireController().setFlashMode(_mapFlash(flash));

  @override
  Future<void> setZoom(double zoom) async {
    final CameraCapabilities capabilities = _requireCapabilities();
    await _requireController().setZoomLevel(
      zoom.clamp(capabilities.minimumZoom, capabilities.maximumZoom),
    );
  }

  @override
  Future<void> setExposure(double exposure) async {
    final CameraCapabilities capabilities = _requireCapabilities();
    await _requireController().setExposureOffset(
      exposure.clamp(
        capabilities.minimumExposure,
        capabilities.maximumExposure,
      ),
    );
  }

  @override
  Future<void> setFocusAndExposure(Offset point) async {
    final Offset normalized = Offset(
      point.dx.clamp(0, 1),
      point.dy.clamp(0, 1),
    );
    final CameraController controller = _requireController();
    await Future.wait<void>(<Future<void>>[
      controller.setFocusPoint(normalized),
      controller.setExposurePoint(normalized),
    ]);
  }

  @override
  Future<void> setLocks({required bool locked}) async {
    final CameraController controller = _requireController();
    await Future.wait<void>(<Future<void>>[
      controller.setFocusMode(locked ? FocusMode.locked : FocusMode.auto),
      controller.setExposureMode(
        locked ? ExposureMode.locked : ExposureMode.auto,
      ),
    ]);
  }

  @override
  Future<void> pause() async {
    await _controller?.dispose();
    _controller = null;
    _emit(const CameraSnapshot(availability: CameraAvailability.paused));
  }

  @override
  Future<void> resume() => initialize();

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    await _snapshots.close();
  }

  CameraController _requireController() {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraFailure(
        CameraFailureKind.unavailable,
        'Camera is not ready.',
      );
    }
    return controller;
  }

  CameraCapabilities _requireCapabilities() {
    final CameraCapabilities? capabilities = _snapshot.capabilities;
    if (capabilities == null) {
      throw const CameraFailure(
        CameraFailureKind.unavailable,
        'Camera capabilities are unavailable.',
      );
    }
    return capabilities;
  }

  void _emit(CameraSnapshot snapshot) {
    _snapshot = snapshot;
    if (!_snapshots.isClosed) {
      _snapshots.add(snapshot);
    }
  }

  void _emitFailure(CameraFailure failure) {
    _emit(
      CameraSnapshot(
        availability: switch (failure.kind) {
          CameraFailureKind.denied => CameraAvailability.denied,
          CameraFailureKind.restricted => CameraAvailability.restricted,
          CameraFailureKind.unavailable => CameraAvailability.unavailable,
          CameraFailureKind.capture ||
          CameraFailureKind.unknown => CameraAvailability.failed,
        },
        message: failure.message,
      ),
    );
  }
}

CameraFailure _mapException(CameraException error) {
  return switch (error.code) {
    'CameraAccessDenied' || 'CameraAccessDeniedWithoutPrompt' => CameraFailure(
      CameraFailureKind.denied,
      'Camera access is off. Enable it in system settings or import images.',
      code: error.code,
    ),
    'CameraAccessRestricted' => CameraFailure(
      CameraFailureKind.restricted,
      'Camera access is restricted on this device.',
      code: error.code,
    ),
    _ => CameraFailure(
      CameraFailureKind.unavailable,
      error.description ?? 'Camera is unavailable.',
      code: error.code,
    ),
  };
}

CameraFacing _mapFacing(CameraLensDirection direction) => switch (direction) {
  CameraLensDirection.back => CameraFacing.rear,
  CameraLensDirection.front => CameraFacing.front,
  CameraLensDirection.external => CameraFacing.external,
};

FlashMode _mapFlash(CameraFlash flash) => switch (flash) {
  CameraFlash.off => FlashMode.off,
  CameraFlash.auto => FlashMode.auto,
  CameraFlash.on => FlashMode.always,
  CameraFlash.torch => FlashMode.torch,
};
