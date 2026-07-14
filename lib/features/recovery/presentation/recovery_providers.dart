import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/presentation/project_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/recovery_repository.dart';
import 'recovery_controller.dart';

final recoveryRepositoryProvider = Provider<RecoveryRepository>((Ref ref) {
  return RecoveryRepository(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    journal: ref.watch(operationJournalProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final recoveryControllerProvider =
    NotifierProvider.autoDispose<RecoveryController, RecoveryViewState>(
      RecoveryController.new,
    );
