import 'dart:async';

import 'package:flutter/foundation.dart';

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
  }) : this._(
         projectId,
         initialFrame,
         editor,
         projects,
         clock ?? PlaybackClock(),
       );

  PreviewController._(
    this.projectId,
    this.initialFrame,
    this._editor,
    this._projects,
    this._clock,
  );

  final String projectId;
  final int initialFrame;
  final EditorRepository _editor;
  final ProjectRepository _projects;
  final PlaybackClock _clock;
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
      _clock.seek(timeline.elapsedAtFrame(frame));
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
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    _update(_state.copyWith(playing: true));
    showControls(autoHide: true);
  }

  void pause() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline != null) {
      _clock.pause(timeline.duration);
    }
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
    _tick();
  }

  void toggleLoop() {
    _clock.loop = !_state.loop;
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
    super.dispose();
  }
}
