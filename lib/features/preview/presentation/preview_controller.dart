import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/filesystem/project_paths.dart';
import '../../../core/media/audio_mixer.dart';
import '../../audio/data/audio_repository.dart';
import '../../audio/domain/audio_clip.dart';
import '../../editor/data/editor_repository.dart';
import '../../editor/domain/timeline.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/domain/project.dart';
import '../domain/playback_clock.dart';
import 'preview_quality_menu.dart';

class PreviewViewState {
  const PreviewViewState({
    this.project,
    this.timeline,
    this.frameIndex = 0,
    this.playing = false,
    this.loop = false,
    this.controlsVisible = true,
    this.quality = PreviewQuality.automatic,
    this.errorMessage,
  });

  final Project? project;
  final TimelineSnapshot? timeline;
  final int frameIndex;
  final bool playing;
  final bool loop;
  final bool controlsVisible;
  final PreviewQuality quality;
  final String? errorMessage;

  PreviewViewState copyWith({
    Project? project,
    TimelineSnapshot? timeline,
    int? frameIndex,
    bool? playing,
    bool? loop,
    bool? controlsVisible,
    PreviewQuality? quality,
    String? errorMessage,
  }) => PreviewViewState(
    project: project ?? this.project,
    timeline: timeline ?? this.timeline,
    frameIndex: frameIndex ?? this.frameIndex,
    playing: playing ?? this.playing,
    loop: loop ?? this.loop,
    controlsVisible: controlsVisible ?? this.controlsVisible,
    quality: quality ?? this.quality,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class PreviewController extends ChangeNotifier {
  PreviewController({
    required String projectId,
    required int initialFrame,
    required EditorRepository editor,
    required ProjectRepository projects,
    PlaybackClock? clock,
    AudioRepository? audio,
    AudioMixer? mixer,
    ProjectPaths? paths,
  }) : this._(
         projectId,
         initialFrame,
         editor,
         projects,
         clock ?? PlaybackClock(),
         audio,
         mixer,
         paths,
       );

  PreviewController._(
    this.projectId,
    this.initialFrame,
    this._editor,
    this._projects,
    this._clock,
    this._audio,
    this._mixer,
    this._paths,
  );

  final String projectId;
  final int initialFrame;
  final EditorRepository _editor;
  final ProjectRepository _projects;
  final PlaybackClock _clock;
  final AudioRepository? _audio;
  final AudioMixer? _mixer;
  final ProjectPaths? _paths;
  Timer? _ticker;
  Timer? _hideTimer;
  bool _disposed = false;
  PreviewViewState _state = const PreviewViewState();

  PreviewViewState get state => _state;

  Future<void> initialize() async {
    try {
      final Project? project = await _projects.getProject(projectId);
      final TimelineSnapshot timeline = await _editor.loadTimeline(projectId);
      if (project == null || timeline.isEmpty) {
        throw StateError('Preview requires a project with frames.');
      }
      final int frame = initialFrame.clamp(0, timeline.frames.length - 1);
      final Duration initialPosition = timeline.elapsedAtFrame(frame);
      _clock.seek(initialPosition);
      if (_audio != null && _mixer != null && _paths != null) {
        final audioTimeline = await _audio.load(projectId);
        await _mixer.load(
          audioTimeline,
          (AudioClip clip) =>
              _paths.resolveRelativeFile(clip.relativeSourcePath),
        );
        if (audioTimeline.hasAudibleAudio) {
          await _mixer.seek(initialPosition);
          _clock.audioPosition = () => _mixer.snapshot.position;
        }
      }
      _update(
        _state.copyWith(
          project: project,
          timeline: timeline,
          frameIndex: frame,
        ),
      );
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Preview could not open: $error'));
    }
  }

  void togglePlayback() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null) {
      return;
    }
    if (_state.playing) {
      pause();
      return;
    }
    if (_clock.position(timeline.duration) >= timeline.duration) {
      _clock.seek(Duration.zero);
    }
    _clock.play();
    unawaited(_mixer?.play());
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    _update(_state.copyWith(playing: true));
    showControls(autoHide: true);
  }

  void pause() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline != null) {
      _clock.pause(timeline.duration);
    }
    unawaited(_mixer?.pause());
    _ticker?.cancel();
    _update(_state.copyWith(playing: false, controlsVisible: true));
  }

  void seekFraction(double fraction) {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null) {
      return;
    }
    _clock.seek(
      Duration(
        microseconds: (timeline.duration.inMicroseconds * fraction.clamp(0, 1))
            .round(),
      ),
    );
    unawaited(_mixer?.seek(_clock.position(timeline.duration)));
    _tick();
  }

  void toggleLoop() {
    _clock.loop = !_state.loop;
    unawaited(_mixer?.setLoop(_clock.loop));
    _update(_state.copyWith(loop: _clock.loop));
  }

  void setQuality(PreviewQuality quality) =>
      _update(_state.copyWith(quality: quality));

  void toggleControls({required bool keepAccessible}) {
    if (keepAccessible) {
      showControls(autoHide: false);
      return;
    }
    _hideTimer?.cancel();
    _update(_state.copyWith(controlsVisible: !_state.controlsVisible));
  }

  void showControls({required bool autoHide}) {
    _hideTimer?.cancel();
    _update(_state.copyWith(controlsVisible: true));
    if (autoHide && _state.playing) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        _update(_state.copyWith(controlsVisible: false));
      });
    }
  }

  void _tick() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null) {
      return;
    }
    final Duration position = _clock.position(timeline.duration);
    final bool ended = !_state.loop && position >= timeline.duration;
    if (ended) {
      _ticker?.cancel();
      _clock.pause(timeline.duration);
    }
    _update(
      _state.copyWith(
        frameIndex: timeline.frameIndexAt(position),
        playing: ended ? false : _state.playing,
        controlsVisible: ended ? true : _state.controlsVisible,
      ),
    );
  }

  void _update(PreviewViewState state) {
    if (_disposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _hideTimer?.cancel();
    unawaited(_mixer?.dispose());
    super.dispose();
  }
}
