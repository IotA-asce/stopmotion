import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/filesystem/project_paths.dart';
import '../../../core/media/audio_service.dart';
import '../data/audio_picker.dart';
import '../data/audio_probe.dart';
import '../data/audio_repository.dart';
import '../data/waveform_service.dart';
import '../domain/audio_clip.dart';
import '../domain/audio_timeline.dart';

enum NarrationState { idle, countIn, recording, paused }

class AudioViewState {
  const AudioViewState({
    this.timeline,
    this.permission = MicrophonePermission.notRequested,
    this.recording = NarrationState.idle,
    this.countIn = 0,
    this.level = 0,
    this.elapsed = Duration.zero,
    this.playheadMilliseconds = 0,
    this.waveforms = const <String, List<double>>{},
    this.busy = false,
    this.errorMessage,
  });

  final AudioTimeline? timeline;
  final MicrophonePermission permission;
  final NarrationState recording;
  final int countIn;
  final double level;
  final Duration elapsed;
  final int playheadMilliseconds;
  final Map<String, List<double>> waveforms;
  final bool busy;
  final String? errorMessage;

  AudioViewState copyWith({
    AudioTimeline? timeline,
    MicrophonePermission? permission,
    NarrationState? recording,
    int? countIn,
    double? level,
    Duration? elapsed,
    int? playheadMilliseconds,
    Map<String, List<double>>? waveforms,
    bool? busy,
    String? errorMessage,
    bool clearError = false,
  }) => AudioViewState(
    timeline: timeline ?? this.timeline,
    permission: permission ?? this.permission,
    recording: recording ?? this.recording,
    countIn: countIn ?? this.countIn,
    level: level ?? this.level,
    elapsed: elapsed ?? this.elapsed,
    playheadMilliseconds: playheadMilliseconds ?? this.playheadMilliseconds,
    waveforms: waveforms ?? this.waveforms,
    busy: busy ?? this.busy,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class AudioController extends ChangeNotifier {
  AudioController({
    required String projectId,
    required AudioRepository repository,
    required AudioRecordingService recorder,
    required AudioPicker picker,
    required AudioProbe probe,
    required WaveformService waveforms,
    required ProjectPaths paths,
    Uuid uuid = const Uuid(),
    Duration countInStep = const Duration(seconds: 1),
  }) : this._(
         projectId,
         repository,
         recorder,
         picker,
         probe,
         waveforms,
         paths,
         uuid,
         countInStep,
       );

  AudioController._(
    this.projectId,
    this._repository,
    this._recorder,
    this._picker,
    this._probe,
    this._waveformService,
    this._paths,
    this._uuid,
    this._countInStep,
  );

  final String projectId;
  final AudioRepository _repository;
  final AudioRecordingService _recorder;
  final AudioPicker _picker;
  final AudioProbe _probe;
  final WaveformService _waveformService;
  final ProjectPaths _paths;
  final Uuid _uuid;
  final Duration _countInStep;
  AudioViewState _state = const AudioViewState();
  StreamSubscription<double>? _levelSubscription;
  Timer? _elapsedTimer;
  File? _recordingFile;
  DateTime? _recordingStarted;
  Duration _elapsedBeforeResume = Duration.zero;
  bool _cancelCountIn = false;
  bool _disposed = false;

  AudioViewState get state => _state;

  Future<void> initialize() async {
    await _guard(() async {
      final AudioTimeline timeline = await _repository.load(projectId);
      final MicrophonePermission permission = await _recorder.permission(
        request: false,
      );
      _update(
        _state.copyWith(
          timeline: timeline,
          permission: permission,
          busy: false,
        ),
      );
      unawaited(_loadWaveforms(timeline));
    });
  }

  Future<void> importAudio({AudioTrackType type = AudioTrackType.music}) async {
    await _guard(() async {
      final PickedAudio? picked = await _picker.pick();
      if (picked == null) {
        return;
      }
      final Duration duration = await _probe.duration(picked.file);
      await _repository.accept(
        projectId: projectId,
        source: picked.file,
        name: picked.name,
        trackType: type,
        duration: duration,
        recording: false,
      );
      await _reload();
    });
  }

  Future<void> startNarration() async {
    final AudioTimeline? timeline = _state.timeline;
    if (timeline == null ||
        timeline.clips.any(
          (AudioClip clip) => clip.trackType == AudioTrackType.narration,
        )) {
      _error('Only one narration track is available.');
      return;
    }
    final MicrophonePermission permission = await _recorder.permission(
      request: true,
    );
    _update(_state.copyWith(permission: permission, clearError: true));
    if (permission != MicrophonePermission.granted) {
      _error('Microphone access is denied. Import audio remains available.');
      return;
    }
    _cancelCountIn = false;
    for (var value = 3; value > 0; value--) {
      _update(
        _state.copyWith(recording: NarrationState.countIn, countIn: value),
      );
      await Future<void>.delayed(_countInStep);
      if (_cancelCountIn || _disposed) {
        _update(_state.copyWith(recording: NarrationState.idle, countIn: 0));
        return;
      }
    }
    final File destination = File(
      '${_paths.temporaryDirectory(projectId).path}/${_uuid.v4()}.m4a',
    );
    await _recorder.start(destination);
    _recordingFile = destination;
    _elapsedBeforeResume = Duration.zero;
    _recordingStarted = DateTime.now();
    _levelSubscription = _recorder.levels.listen(
      (double level) => _update(_state.copyWith(level: level)),
    );
    _elapsedTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _update(_state.copyWith(elapsed: _currentElapsed, countIn: 0)),
    );
    _update(
      _state.copyWith(
        recording: NarrationState.recording,
        elapsed: Duration.zero,
        countIn: 0,
      ),
    );
  }

  void cancelCountIn() => _cancelCountIn = true;

  Future<void> pauseRecording() async {
    if (_state.recording != NarrationState.recording) {
      return;
    }
    _elapsedBeforeResume = _currentElapsed;
    _recordingStarted = null;
    await _recorder.pause();
    _update(
      _state.copyWith(
        recording: NarrationState.paused,
        elapsed: _elapsedBeforeResume,
        level: 0,
      ),
    );
  }

  Future<void> resumeRecording() async {
    if (_state.recording != NarrationState.paused) {
      return;
    }
    await _recorder.resume();
    _recordingStarted = DateTime.now();
    _update(_state.copyWith(recording: NarrationState.recording));
  }

  Future<void> stopRecording() async {
    if (_state.recording != NarrationState.recording &&
        _state.recording != NarrationState.paused) {
      return;
    }
    await _guard(() async {
      _elapsedTimer?.cancel();
      _elapsedTimer = null;
      await _levelSubscription?.cancel();
      _levelSubscription = null;
      final File? recorded = await _recorder.stop() ?? _recordingFile;
      if (recorded == null || !await recorded.exists()) {
        throw StateError('Narration recording did not produce a file.');
      }
      final Duration duration = await _probe.duration(recorded);
      await _repository.accept(
        projectId: projectId,
        source: recorded,
        name: 'Narration',
        trackType: AudioTrackType.narration,
        duration: duration,
        recording: true,
      );
      if (await recorded.exists()) {
        await recorded.delete();
      }
      _recordingFile = null;
      _recordingStarted = null;
      _elapsedBeforeResume = Duration.zero;
      _update(
        _state.copyWith(
          recording: NarrationState.idle,
          elapsed: Duration.zero,
          level: 0,
        ),
      );
      await _reload();
    });
  }

  Future<void> updateClip(AudioClip clip) =>
      _persist(_state.timeline!.replace(clip));

  Future<void> deleteClip(String id) => _persist(_state.timeline!.remove(id));

  Future<void> duplicateClip(String id) async {
    final AudioClip source = _state.timeline!.clips.firstWhere(
      (AudioClip clip) => clip.id == id,
    );
    await _persist(
      _state.timeline!.add(
        source.copyWith(
          id: _uuid.v4(),
          name: '${source.name} copy',
          startMilliseconds: source.startMilliseconds + 250,
        ),
      ),
    );
  }

  Future<void> splitClip(String id) => _persist(
    _state.timeline!.split(
      id: id,
      playheadMilliseconds: _state.playheadMilliseconds,
      newId: _uuid.v4(),
    ),
  );

  Future<void> setMasterVolume(double value) =>
      _persist(_state.timeline!.copyWith(masterVolume: value.clamp(0, 2)));

  void previewMasterVolume(double value) => _update(
    _state.copyWith(
      timeline: _state.timeline!.copyWith(masterVolume: value.clamp(0, 2)),
    ),
  );

  Future<void> toggleMasterMute() =>
      _persist(_state.timeline!.copyWith(muted: !_state.timeline!.muted));

  void seek(int milliseconds) {
    final int maximum = _state.timeline?.projectDurationMilliseconds ?? 0;
    _update(
      _state.copyWith(playheadMilliseconds: milliseconds.clamp(0, maximum)),
    );
  }

  void clearError() => _update(_state.copyWith(clearError: true));

  Future<void> _persist(AudioTimeline timeline) async {
    await _guard(() async {
      await _repository.save(timeline);
      _update(_state.copyWith(timeline: await _repository.load(projectId)));
    });
  }

  Future<void> _reload() async {
    final AudioTimeline timeline = await _repository.load(projectId);
    _update(_state.copyWith(timeline: timeline));
    unawaited(_loadWaveforms(timeline));
  }

  Future<void> _loadWaveforms(AudioTimeline timeline) async {
    final Map<String, List<double>> values = <String, List<double>>{
      ..._state.waveforms,
    };
    for (final AudioClip clip in timeline.clips.where(
      (AudioClip clip) => !clip.missing,
    )) {
      try {
        values[clip.id] = await _waveformService.read(
          file: _paths.resolveRelativeFile(clip.relativeSourcePath),
          samples: 160,
        );
        _update(_state.copyWith(waveforms: Map.unmodifiable(values)));
      } on Object {
        // The missing/unreadable state is handled by repository reload.
      }
    }
  }

  Duration get _currentElapsed =>
      _elapsedBeforeResume +
      (_recordingStarted == null
          ? Duration.zero
          : DateTime.now().difference(_recordingStarted!));

  Future<void> _guard(Future<void> Function() operation) async {
    _update(_state.copyWith(busy: true, clearError: true));
    try {
      await operation();
    } on Object catch (error) {
      _error(error.toString());
    } finally {
      _update(_state.copyWith(busy: false));
    }
  }

  void _error(String message) =>
      _update(_state.copyWith(errorMessage: message, busy: false));

  void _update(AudioViewState state) {
    if (_disposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelCountIn = true;
    _elapsedTimer?.cancel();
    unawaited(_levelSubscription?.cancel());
    unawaited(_recorder.dispose());
    unawaited(_waveformService.cancel());
    super.dispose();
  }
}
