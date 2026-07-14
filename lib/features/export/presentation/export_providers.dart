import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/export_engine.dart';
import '../../../core/media/ffmpeg_export_engine.dart';
import '../../../core/media/image_sequence_exporter.dart';
import '../../audio/presentation/audio_providers.dart';
import '../../editor/presentation/editor_providers.dart';
import '../../projects/presentation/project_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/export_handoff.dart';
import '../data/export_repository.dart';
import '../domain/export_record.dart';
import 'export_controller.dart';

final exportPreflightProvider = Provider<ExportPreflightService>(
  (Ref ref) => const ExportPreflightService(),
);

final exportEnginesProvider = Provider<Map<ExportFormat, ExportEngine>>((
  Ref ref,
) {
  const FfmpegExportEngine ffmpeg = FfmpegExportEngine();
  return <ExportFormat, ExportEngine>{
    ExportFormat.movie: ffmpeg,
    ExportFormat.gif: ffmpeg,
    ExportFormat.imageSequence: const ImageSequenceExporter(),
  };
});

final exportRepositoryProvider = Provider<ExportRepository>((Ref ref) {
  return ExportRepository(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    projects: ref.watch(projectRepositoryProvider),
    editor: ref.watch(editorRepositoryProvider),
    audio: ref.watch(audioRepositoryProvider),
    journal: ref.watch(operationJournalProvider),
    preflight: ref.watch(exportPreflightProvider),
    engines: ref.watch(exportEnginesProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final exportHandoffProvider = Provider<ExportHandoff>(
  (Ref ref) => const SystemExportHandoff(),
);

final exportControllerProvider = Provider.autoDispose
    .family<ExportController, String>((Ref ref, String projectId) {
      final ExportController controller = ExportController(
        projectId: projectId,
        repository: ref.watch(exportRepositoryProvider),
        handoff: ref.watch(exportHandoffProvider),
        defaults: ref.watch(appSettingsProvider).exportDefaults,
      );
      ref.onDispose(controller.dispose);
      unawaited(controller.initialize());
      return controller;
    });

final exportHistoryProvider = StreamProvider.autoDispose.family(
  (Ref ref, String projectId) =>
      ref.watch(exportRepositoryProvider).watchHistory(projectId),
);
