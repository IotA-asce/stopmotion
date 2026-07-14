import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/media/audio_mixer.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/audio/data/audio_repository.dart';
import 'package:stop_motion/features/audio/domain/audio_clip.dart';
import 'package:stop_motion/features/audio/domain/audio_timeline.dart';
import 'package:stop_motion/features/editor/data/editor_repository.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/preview/domain/playback_clock.dart';
import 'package:stop_motion/features/preview/presentation/preview_controller.dart';
import 'package:stop_motion/features/preview/presentation/preview_quality_menu.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

import '../editor/timeline_test.dart' show frame;

void main() {
  test('preview restores initial frame and owns playback lifecycle', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'preview_controller_',
    );
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    final AppDatabase database = AppDatabase.memory();
    final ProjectRepository projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    );
    final Project project = await projects.createProject(
      ProjectDraft(
        title: 'Preview film',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 2,
        backgroundColorValue: 0,
      ),
    );
    final List<ProjectFrame> frames = List<ProjectFrame>.generate(6, (
      int index,
    ) {
      final ProjectFrame value = frame('$index');
      return ProjectFrame(
        id: value.id,
        projectId: project.id,
        relativeSourcePath: value.relativeSourcePath,
        position: index,
        holdFrames: 1,
        createdAt: value.createdAt,
        sourceWidth: value.sourceWidth,
        sourceHeight: value.sourceHeight,
        missing: false,
      );
    });
    final EditorRepository editor = EditorRepository(database: database);
    await editor.saveTimeline(
      project.id,
      TimelineSnapshot(frames: frames, fps: 2),
    );
    final File audioSource = paths.resolveRelativeFile(
      'projects/${project.id}/audio/music.m4a',
    );
    await audioSource.parent.create(recursive: true);
    await audioSource.writeAsBytes(<int>[1, 2, 3]);
    await database
        .into(database.audioClipRecords)
        .insert(
          AudioClipRecordsCompanion.insert(
            id: 'music',
            projectId: project.id,
            relativeSourcePath: paths.relativeToRoot(audioSource),
            name: 'Music',
            trackType: AudioTrackType.music.name,
            startMilliseconds: 0,
            trimStartMilliseconds: 0,
            trimEndMilliseconds: 3000,
          ),
        );
    final MutableTimeSource time = MutableTimeSource();
    final _FakeMixer mixer = _FakeMixer();
    final PreviewController controller = PreviewController(
      projectId: project.id,
      initialFrame: 2,
      editor: editor,
      projects: projects,
      clock: PlaybackClock(timeSource: time),
      audio: AudioRepository(
        database: database,
        paths: paths,
        journal: OperationJournalRepository(database),
      ),
      mixer: mixer,
      paths: paths,
    );
    await controller.initialize();
    expect(controller.state.frameIndex, 2);
    expect(mixer.snapshot.position, const Duration(seconds: 1));
    controller.setQuality(PreviewQuality.performance);
    controller.toggleLoop();
    controller.togglePlayback();
    mixer.position = const Duration(seconds: 2);
    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(controller.state.frameIndex, 4);
    controller.pause();
    expect(controller.state.playing, isFalse);
    expect(controller.state.quality, PreviewQuality.performance);
    expect(controller.state.loop, isTrue);
    expect(mixer.pauses, greaterThan(0));

    controller.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(mixer.disposed, isTrue);
    await database.close();
    await root.delete(recursive: true);
  });
}

class _FakeMixer implements AudioMixer {
  final StreamController<AudioMixerSnapshot> _snapshots =
      StreamController<AudioMixerSnapshot>.broadcast(sync: true);
  Duration position = Duration.zero;
  bool playing = false;
  bool loop = false;
  int pauses = 0;
  bool disposed = false;

  @override
  AudioMixerSnapshot get snapshot => AudioMixerSnapshot(
    position: position,
    duration: const Duration(seconds: 3),
    playing: playing,
    loop: loop,
  );

  @override
  Stream<AudioMixerSnapshot> get snapshots => _snapshots.stream;

  @override
  Future<void> dispose() async {
    disposed = true;
    await _snapshots.close();
  }

  @override
  Future<void> handleLifecycle({required bool active}) async {
    if (!active) {
      await pause();
    }
  }

  @override
  Future<void> load(
    AudioTimeline timeline,
    File Function(AudioClip clip) resolve,
  ) async {}

  @override
  Future<void> pause() async {
    pauses++;
    playing = false;
    _snapshots.add(snapshot);
  }

  @override
  Future<void> play() async {
    playing = true;
    _snapshots.add(snapshot);
  }

  @override
  Future<void> seek(Duration position) async {
    this.position = position;
    _snapshots.add(snapshot);
  }

  @override
  Future<void> setLoop(bool loop) async {
    this.loop = loop;
    _snapshots.add(snapshot);
  }
}

class MutableTimeSource implements PlaybackTimeSource {
  Duration value = Duration.zero;

  @override
  Duration get elapsed => value;
}
