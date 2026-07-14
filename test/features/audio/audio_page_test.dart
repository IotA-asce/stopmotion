import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/media/audio_service.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/audio/data/audio_picker.dart';
import 'package:stop_motion/features/audio/data/audio_probe.dart';
import 'package:stop_motion/features/audio/data/audio_repository.dart';
import 'package:stop_motion/features/audio/data/waveform_service.dart';
import 'package:stop_motion/features/audio/presentation/audio_controller.dart';
import 'package:stop_motion/features/audio/presentation/audio_page.dart';
import 'package:stop_motion/features/audio/presentation/audio_providers.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  testWidgets('audio workspace remains usable at 200 percent text scale', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    final Directory root =
        await tester.runAsync(
              () => Directory.systemTemp.createTemp('audio_page_'),
            )
            as Directory;
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    final AppDatabase database = AppDatabase.memory();
    final OperationJournalRepository journal = OperationJournalRepository(
      database,
    );
    final Project project = (await tester.runAsync(
      () =>
          ProjectRepository(
            database: database,
            paths: paths,
            journal: journal,
          ).createProject(
            ProjectDraft(
              title: 'Audio page',
              aspectRatio: ProjectAspectRatio.widescreen,
              resolution: ProjectResolution.hd720,
              framesPerSecond: 12,
              backgroundColorValue: Colors.black.toARGB32(),
            ),
          ),
    ))!;
    final _DeniedRecorder recorder = _DeniedRecorder();
    final AudioController controller = AudioController(
      projectId: project.id,
      repository: AudioRepository(
        database: database,
        paths: paths,
        journal: journal,
      ),
      recorder: recorder,
      picker: const _EmptyPicker(),
      probe: const _UnusedProbe(),
      waveforms: WaveformService(extractor: _EmptyWaveform()),
      paths: paths,
    );
    await tester.runAsync(controller.initialize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioControllerProvider(project.id).overrideWithValue(controller),
        ],
        child: MaterialApp(home: AudioPage(projectId: project.id)),
      ),
    );

    expect(find.text('Record narration'), findsOneWidget);
    expect(find.text('Import audio'), findsOneWidget);
    expect(find.text('Mute project audio'), findsOneWidget);
    expect(find.text('Select an audio clip'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.runAsync(database.close);
    await tester.runAsync(() => root.delete(recursive: true));
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

class _DeniedRecorder implements AudioRecordingService {
  final StreamController<double> _levels = StreamController<double>.broadcast();

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() => _levels.close();

  @override
  Future<void> pause() async {}

  @override
  Future<MicrophonePermission> permission({required bool request}) async =>
      request ? MicrophonePermission.denied : MicrophonePermission.notRequested;

  @override
  Future<void> resume() async {}

  @override
  Future<void> start(File destination) async {}

  @override
  Future<File?> stop() async => null;
}

class _EmptyPicker implements AudioPicker {
  const _EmptyPicker();

  @override
  Future<PickedAudio?> pick() async => null;
}

class _UnusedProbe implements AudioProbe {
  const _UnusedProbe();

  @override
  Future<Duration> duration(File file) async => Duration.zero;
}

class _EmptyWaveform implements WaveformExtractor {
  @override
  Future<void> cancel() async {}

  @override
  Future<List<double>> extract(File file, int samples) async => <double>[];
}
