import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/diagnostics/app_logger.dart';
import '../core/filesystem/project_paths.dart';
import '../core/recovery/operation_journal.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/projects/presentation/project_providers.dart';
import '../features/recovery/data/recovery_repository.dart';
import '../features/recovery/domain/recovery_report.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/settings_providers.dart';
import 'app.dart';
import 'router.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ProjectPaths paths = await ProjectPaths.resolve();
  AppDatabase database = AppDatabase.open(paths.databaseFile);
  RecoveryReport recoveryReport;
  try {
    recoveryReport = await RecoveryRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    ).scan();
    if (!recoveryReport.databaseHealthy &&
        await paths.databaseBackupFile.exists()) {
      await database.close();
      await AppDatabase.restoreBackup(paths.databaseFile);
      database = AppDatabase.open(paths.databaseFile);
      recoveryReport = await RecoveryRepository(
        database: database,
        paths: paths,
        journal: OperationJournalRepository(database),
      ).scan();
    }
  } on Object {
    await database.close();
    if (await AppDatabase.restoreBackup(paths.databaseFile)) {
      database = AppDatabase.open(paths.databaseFile);
      try {
        recoveryReport = await RecoveryRepository(
          database: database,
          paths: paths,
          journal: OperationJournalRepository(database),
        ).scan();
      } on Object {
        recoveryReport = const RecoveryReport(
          databaseHealthy: false,
          items: <RecoveryItem>[
            RecoveryItem(
              id: 'database-recovery-unavailable',
              kind: RecoveryIssueKind.migration,
              message:
                  'The database could not be opened. A backup was retained and no project files were removed.',
            ),
          ],
        );
      }
    } else {
      recoveryReport = const RecoveryReport(
        databaseHealthy: false,
        items: <RecoveryItem>[
          RecoveryItem(
            id: 'database-backup-unavailable',
            kind: RecoveryIssueKind.migration,
            message:
                'The database could not be opened. No project files were removed.',
          ),
        ],
      );
    }
  }
  final AppLogger logger = AppLogger(paths: paths);
  await logger.log(
    category: 'lifecycle',
    action: 'launch_recovery_scanned',
    attributes: <String, Object?>{
      'count': recoveryReport.items.length,
      'status': recoveryReport.databaseHealthy ? 'healthy' : 'needs_recovery',
    },
  );
  final OnboardingRepository onboarding =
      SharedPreferencesOnboardingRepository();
  final SettingsRepository settings = SharedPreferencesSettingsRepository();
  final AppSettings appSettings = await settings.load();
  final bool hasCompletedOnboarding = await onboarding.isComplete();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        projectPathsProvider.overrideWithValue(paths),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        settingsRepositoryProvider.overrideWithValue(settings),
        initialAppSettingsProvider.overrideWithValue(appSettings),
      ],
      child: StopMotionApp(
        router: createAppRouter(
          initialLocation: hasCompletedOnboarding
              ? recoveryReport.requiresAttention
                    ? AppRoutes.recovery
                    : AppRoutes.projects
              : AppRoutes.onboarding,
        ),
      ),
    ),
  );
}
