import 'package:wakelock_plus/wakelock_plus.dart';

abstract interface class CaptureWakeLock {
  Future<void> enable();
  Future<void> disable();
}

class PackageCaptureWakeLock implements CaptureWakeLock {
  const PackageCaptureWakeLock();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

class NoopCaptureWakeLock implements CaptureWakeLock {
  const NoopCaptureWakeLock();

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}
