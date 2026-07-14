abstract interface class CaptureStorageGuard {
  Future<bool> hasSpaceForFrame();
}

class AssumeAvailableStorageGuard implements CaptureStorageGuard {
  const AssumeAvailableStorageGuard();

  @override
  Future<bool> hasSpaceForFrame() async => true;
}
