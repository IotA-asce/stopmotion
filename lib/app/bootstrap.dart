import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/filesystem/project_paths.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/projects/presentation/project_providers.dart';
import 'app.dart';
import 'router.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ProjectPaths paths = await ProjectPaths.resolve();
  final AppDatabase database = AppDatabase.open(paths.databaseFile);
  final OnboardingRepository onboarding =
      SharedPreferencesOnboardingRepository();
  final bool hasCompletedOnboarding = await onboarding.isComplete();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        projectPathsProvider.overrideWithValue(paths),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
      ],
      child: StopMotionApp(
        router: createAppRouter(
          initialLocation: hasCompletedOnboarding
              ? AppRoutes.projects
              : AppRoutes.onboarding,
        ),
      ),
    ),
  );
}
