enum CameraFacing { rear, front, external }

enum CameraFlash { off, auto, on, torch }

class CameraCapabilities {
  const CameraCapabilities({
    required this.cameraCount,
    required this.facing,
    required this.minimumZoom,
    required this.maximumZoom,
    required this.minimumExposure,
    required this.maximumExposure,
    this.supportsFocusPoint = true,
    this.supportsExposurePoint = true,
    this.supportsFocusLock = true,
    this.supportsExposureLock = true,
    this.supportsWhiteBalanceLock = false,
    this.supportsVolumeShutter = true,
    this.flashModes = const <CameraFlash>{CameraFlash.off},
  });

  final int cameraCount;
  final CameraFacing facing;
  final double minimumZoom;
  final double maximumZoom;
  final double minimumExposure;
  final double maximumExposure;
  final bool supportsFocusPoint;
  final bool supportsExposurePoint;
  final bool supportsFocusLock;
  final bool supportsExposureLock;
  final bool supportsWhiteBalanceLock;
  final bool supportsVolumeShutter;
  final Set<CameraFlash> flashModes;

  bool get canSwitchCamera => cameraCount > 1;
}
