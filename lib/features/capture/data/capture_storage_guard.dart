import '../../../core/filesystem/storage_monitor.dart';

abstract interface class CaptureStorageGuard {
  Future<bool> hasSpaceForFrame();
}

class AssumeAvailableStorageGuard implements CaptureStorageGuard {
  const AssumeAvailableStorageGuard();

  @override
  Future<bool> hasSpaceForFrame() async => true;
}

class StorageMonitorCaptureGuard implements CaptureStorageGuard {
  const StorageMonitorCaptureGuard(
    this._monitor, {
    this.minimumAvailableBytes = 8 * 1024 * 1024,
  });

  final StorageMonitor _monitor;
  final int minimumAvailableBytes;

  @override
  Future<bool> hasSpaceForFrame() async {
    final int? available = (await _monitor.inspect()).availableBytes;
    return available == null || available >= minimumAvailableBytes;
  }
}
