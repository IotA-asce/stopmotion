import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/app_logger.dart';
import '../../../core/diagnostics/diagnostic_exporter.dart';
import '../../../core/filesystem/storage_monitor.dart';
import '../../projects/presentation/project_providers.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (Ref ref) => MemorySettingsRepository(),
);

final initialAppSettingsProvider = Provider<AppSettings>(
  (Ref ref) => const AppSettings(),
);

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialAppSettingsProvider);

  Future<void> update(AppSettings value) async {
    await ref.read(settingsRepositoryProvider).save(value);
    state = value;
  }

  Future<void> reset() async {
    await ref.read(settingsRepositoryProvider).reset();
    state = const AppSettings();
  }
}

final storageMonitorProvider = Provider<StorageMonitor>((Ref ref) {
  return StorageMonitor(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    projects: ref.watch(projectRepositoryProvider),
  );
});

final appLoggerProvider = Provider<AppLogger>((Ref ref) {
  return AppLogger(paths: ref.watch(projectPathsProvider));
});

final diagnosticExporterProvider = Provider<DiagnosticExporter>((Ref ref) {
  return DiagnosticExporter(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

ThemeMode themeModeFor(AppAppearance appearance) => switch (appearance) {
  AppAppearance.system => ThemeMode.system,
  AppAppearance.light => ThemeMode.light,
  AppAppearance.dark => ThemeMode.dark,
};
