import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/capture/domain/capture_frame.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';
import 'package:stop_motion/features/projects/domain/project.dart';
import 'package:stop_motion/features/settings/data/settings_repository.dart';
import 'package:stop_motion/features/settings/domain/app_settings.dart';

void main() {
  test(
    'settings round trip all capture, export, and accessibility defaults',
    () {
      const AppSettings settings = AppSettings(
        appearance: AppAppearance.dark,
        reducedMotion: ReducedMotionPreference.on,
        captureDefaults: CaptureDefaults(
          aspectRatio: ProjectAspectRatio.square,
          resolution: ProjectResolution.hd720,
          framesPerSecond: 8,
          grid: CaptureGrid.thirds,
          onionOpacity: 0.7,
          timerSeconds: 5,
          volumeButtonShutter: false,
        ),
        exportDefaults: ExportSettings(
          format: ExportFormat.gif,
          resolution: ExportResolution.hd720,
          quality: ExportQuality.high,
          gifLoopMode: GifLoopMode.count,
          gifLoopCount: 3,
          imageSequenceFormat: ImageSequenceFormat.jpeg,
        ),
        highContrastTimeline: true,
        keepAwakeDuringCapture: false,
        hapticsEnabled: false,
      );

      final AppSettings restored = AppSettings.decode(settings.encode());

      expect(restored.appearance, AppAppearance.dark);
      expect(restored.reducedMotion, ReducedMotionPreference.on);
      expect(restored.captureDefaults.aspectRatio, ProjectAspectRatio.square);
      expect(restored.captureDefaults.grid, CaptureGrid.thirds);
      expect(restored.captureDefaults.onionOpacity, 0.7);
      expect(restored.exportDefaults.format, ExportFormat.gif);
      expect(restored.exportDefaults.gifLoopCount, 3);
      expect(restored.highContrastTimeline, isTrue);
      expect(restored.keepAwakeDuringCapture, isFalse);
      expect(restored.hapticsEnabled, isFalse);
    },
  );

  test('invalid persisted settings fall back to shipped defaults', () {
    final AppSettings restored = AppSettings.decode('{not-json');

    expect(restored.appearance, AppAppearance.system);
    expect(restored.captureDefaults.framesPerSecond, 12);
    expect(restored.exportDefaults.format, ExportFormat.movie);
  });

  test('memory repository persists and resets settings', () async {
    final MemorySettingsRepository repository = MemorySettingsRepository();
    final AppSettings saved = const AppSettings(
      appearance: AppAppearance.light,
    );

    await repository.save(saved);
    expect((await repository.load()).appearance, AppAppearance.light);
    await repository.reset();
    expect((await repository.load()).appearance, AppAppearance.system);
  });
}
