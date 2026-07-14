import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/audio_mixer.dart';
import '../../../core/media/audio_service.dart';
import '../../projects/presentation/project_providers.dart';
import '../data/audio_picker.dart';
import '../data/audio_probe.dart';
import '../data/audio_repository.dart';
import '../data/waveform_service.dart';
import 'audio_controller.dart';

final audioRecordingServiceProvider = Provider<AudioRecordingService>(
  (Ref ref) => PackageAudioRecordingService(),
);

final audioPickerProvider = Provider<AudioPicker>(
  (Ref ref) => const PackageAudioPicker(),
);

final audioProbeProvider = Provider<AudioProbe>(
  (Ref ref) => const PackageAudioProbe(),
);

final waveformServiceProvider = Provider<WaveformService>(
  (Ref ref) => WaveformService(extractor: PackageWaveformExtractor()),
);

final audioRepositoryProvider = Provider<AudioRepository>((Ref ref) {
  return AudioRepository(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    journal: ref.watch(operationJournalProvider),
  );
});

final audioMixerProvider = Provider.autoDispose.family<AudioMixer, String>((
  Ref ref,
  String workspaceKey,
) {
  final AudioMixer mixer = createPackageAudioMixer();
  ref.onDispose(() => unawaited(mixer.dispose()));
  return mixer;
});

final audioControllerProvider = Provider.autoDispose
    .family<AudioController, String>((Ref ref, String projectId) {
      final AudioController controller = AudioController(
        projectId: projectId,
        repository: ref.watch(audioRepositoryProvider),
        recorder: ref.watch(audioRecordingServiceProvider),
        picker: ref.watch(audioPickerProvider),
        probe: ref.watch(audioProbeProvider),
        waveforms: ref.watch(waveformServiceProvider),
        paths: ref.watch(projectPathsProvider),
        mixer: ref.watch(audioMixerProvider('audio:$projectId')),
      );
      ref.onDispose(controller.dispose);
      unawaited(controller.initialize());
      return controller;
    });
