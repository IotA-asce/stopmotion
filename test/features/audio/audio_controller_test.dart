import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/media/audio_service.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/audio/data/audio_picker.dart';
import 'package:stop_motion/features/audio/data/audio_probe.dart';
import 'package:stop_motion/features/audio/data/audio_repository.dart';
import 'package:stop_motion/features/audio/data/waveform_service.dart';
import 'package:stop_motion/features/audio/domain/audio_clip.dart';
import 'package:stop_motion/features/audio/presentation/audio_controller.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  late Directory root;
  late AppDatabase database;
  late ProjectPaths paths;
  late Project project;
  late AudioRepository repository;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('audio_controller_');
    paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    database = AppDatabase.memory();
    final OperationJournalRepository journal = OperationJournalRepository(
      database,
    );
    project =
        await ProjectRepository(
          database: database,
          paths: paths,
          journal: journal,
        ).createProject(
          ProjectDraft(
            title: 'Audio controller',
            aspectRatio: ProjectAspectRatio.widescreen,
            resolution: ProjectResolution.hd720,
            framesPerSecond: 12,
            backgroundColorValue: Colors.black.toARGB32(),
          ),
        );
    repository = AudioRepository(
      database: database,
      paths: paths,
      journal: journal,
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test('microphone denial does not block imported audio', () async {
    final File picked = await File(
      '${root.path}/picked.mp3',
    ).writeAsBytes(<int>[1, 2, 3]);
    final _FakeRecorder recorder = _FakeRecorder(
      permissionValue: MicrophonePermission.denied,
    );
    final AudioController controller = _createController(
      project: project,
      repository: repository,
      recorder: recorder,
      picker: _FakePicker(PickedAudio(file: picked, name: 'Picked music')),
      paths: paths,
    );
    await controller.initialize();

    await controller.startNarration();
    expect(controller.state.permission, MicrophonePermission.denied);
    expect(controller.state.errorMessage, contains('Import audio'));

    await controller.importAudio();
    expect(controller.state.timeline!.clips, hasLength(1));
    expect(
      controller.state.timeline!.clips.single.trackType,
      AudioTrackType.music,
    );
    controller.dispose();
  });

  test('count-in recording pauses, resumes, and commits narration', () async {
    final _FakeRecorder recorder = _FakeRecorder(
      permissionValue: MicrophonePermission.granted,
    );
    final AudioController controller = _createController(
      project: project,
      repository: repository,
      recorder: recorder,
      picker: const _FakePicker(null),
      paths: paths,
    );
    await controller.initialize();

    await controller.startNarration();
    expect(controller.state.recording, NarrationState.recording);
    await controller.pauseRecording();
    expect(controller.state.recording, NarrationState.paused);
    await controller.resumeRecording();
    recorder.emitLevel(0.75);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.level, 0.75);
    await controller.stopRecording();

    expect(controller.state.recording, NarrationState.idle);
    expect(controller.state.timeline!.clips.single.name, 'Narration');
    expect(recorder.pauses, 1);
    expect(recorder.resumes, 1);
    controller.dispose();
  });
}

AudioController _createController({
  required Project project,
  required AudioRepository repository,
  required _FakeRecorder recorder,
  required AudioPicker picker,
  required ProjectPaths paths,
}) => AudioController(
  projectId: project.id,
  repository: repository,
  recorder: recorder,
  picker: picker,
  probe: const _FakeProbe(),
  waveforms: WaveformService(extractor: _FakeWaveformExtractor()),
  paths: paths,
  countInStep: Duration.zero,
);

class _FakeRecorder implements AudioRecordingService {
  _FakeRecorder({required this.permissionValue});

  final MicrophonePermission permissionValue;
  final StreamController<double> _levels = StreamController<double>.broadcast();
  File? destination;
  int pauses = 0;
  int resumes = 0;

  @override
  Stream<double> get levels => _levels.stream;

  void emitLevel(double value) => _levels.add(value);

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() => _levels.close();

  @override
  Future<void> pause() async => pauses++;

  @override
  Future<MicrophonePermission> permission({required bool request}) async =>
      permissionValue;

  @override
  Future<void> resume() async => resumes++;

  @override
  Future<void> start(File destination) async {
    this.destination = destination;
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(<int>[4, 5, 6]);
  }

  @override
  Future<File?> stop() async => destination;
}

class _FakePicker implements AudioPicker {
  const _FakePicker(this.value);

  final PickedAudio? value;

  @override
  Future<PickedAudio?> pick() async => value;
}

class _FakeProbe implements AudioProbe {
  const _FakeProbe();

  @override
  Future<Duration> duration(File file) async => const Duration(seconds: 3);
}

class _FakeWaveformExtractor implements WaveformExtractor {
  @override
  Future<void> cancel() async {}

  @override
  Future<List<double>> extract(File file, int samples) async => <double>[
    0.2,
    0.5,
    0.8,
  ];
}
