import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/filesystem/atomic_file_store.dart';
import '../../../core/media/camera_service.dart';
import '../../../core/media/package_camera_service.dart';
import '../../projects/presentation/project_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/capture_feedback.dart';
import '../data/capture_repository.dart';
import '../data/capture_storage_guard.dart';
import '../data/capture_wake_lock.dart';
import '../data/frame_picker.dart';
import '../data/system_settings_service.dart';
import 'capture_controller.dart';

final cameraServiceProvider = Provider.autoDispose
    .family<CameraService, String>(
      (Ref ref, String projectId) => PackageCameraService(),
    );

final framePickerProvider = Provider<FramePicker>(
  (Ref ref) => PackageFramePicker(),
);

final captureWakeLockProvider = Provider<CaptureWakeLock>(
  (Ref ref) => ref.watch(appSettingsProvider).keepAwakeDuringCapture
      ? const PackageCaptureWakeLock()
      : const NoopCaptureWakeLock(),
);

final captureStorageGuardProvider = Provider<CaptureStorageGuard>(
  (Ref ref) => StorageMonitorCaptureGuard(ref.watch(storageMonitorProvider)),
);

final captureFeedbackProvider = Provider<CaptureFeedback>(
  (Ref ref) => ref.watch(appSettingsProvider).hapticsEnabled
      ? const HapticCaptureFeedback()
      : const NoopCaptureFeedback(),
);

final systemSettingsServiceProvider = Provider<SystemSettingsService>(
  (Ref ref) => const PackageSystemSettingsService(),
);

final captureRepositoryProvider = Provider<CaptureRepository>((Ref ref) {
  return CaptureRepository(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    journal: ref.watch(operationJournalProvider),
    thumbnails: ref.watch(projectThumbnailRepositoryProvider),
    fileStore: const AtomicFileStore(),
    logger: ref.watch(appLoggerProvider),
  );
});

final captureControllerProvider = Provider.autoDispose
    .family<CaptureController, String>((Ref ref, String projectId) {
      final CaptureController controller = CaptureController(
        projectId: projectId,
        camera: ref.watch(cameraServiceProvider(projectId)),
        captureRepository: ref.watch(captureRepositoryProvider),
        projectRepository: ref.watch(projectRepositoryProvider),
        paths: ref.watch(projectPathsProvider),
        picker: ref.watch(framePickerProvider),
        wakeLock: ref.watch(captureWakeLockProvider),
        storageGuard: ref.watch(captureStorageGuardProvider),
        feedback: ref.watch(captureFeedbackProvider),
        initialState: CaptureViewState(
          grid: ref.watch(appSettingsProvider).captureDefaults.grid,
          onionOpacity: ref
              .watch(appSettingsProvider)
              .captureDefaults
              .onionOpacity,
          timerSeconds: ref
              .watch(appSettingsProvider)
              .captureDefaults
              .timerSeconds,
        ),
        onAccepted: () {
          ref.invalidate(projectThumbnailProvider(projectId));
          ref.invalidate(projectsProvider);
        },
      );
      ref.onDispose(controller.dispose);
      return controller;
    });
