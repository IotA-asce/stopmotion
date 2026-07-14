import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
  Future<void> reset();
}

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _key = 'app_settings_v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppSettings> load() async =>
      AppSettings.decode(await _preferences.getString(_key));

  @override
  Future<void> save(AppSettings settings) =>
      _preferences.setString(_key, settings.encode());

  @override
  Future<void> reset() => _preferences.remove(_key);
}

class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository([this._settings = const AppSettings()]);

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> reset() async {
    _settings = const AppSettings();
  }
}
