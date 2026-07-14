import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

abstract interface class SystemSettingsService {
  Future<bool> openAppSettings();
}

class PackageSystemSettingsService implements SystemSettingsService {
  const PackageSystemSettingsService();

  @override
  Future<bool> openAppSettings() => permission_handler.openAppSettings();
}
