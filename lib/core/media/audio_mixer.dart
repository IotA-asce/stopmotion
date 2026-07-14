import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/audio/domain/audio_clip.dart';
import '../../features/audio/domain/audio_timeline.dart';
import '../../features/preview/domain/playback_clock.dart';

enum AudioFocusEvent { pause, duck, resume, unduck }

abstract interface class AudioPlayerNode {
  Duration get position;
  bool get playing;

  Future<void> load(File file, Duration trimStart, Duration trimEnd);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> dispose();
}

abstract interface class AudioFocusService {
  Stream<AudioFocusEvent> get interruptions;
  Stream<void> get becomingNoisy;

  Future<void> configure();
  Future<bool> activate();
  Future<void> deactivate();
}

class AudioMixerSnapshot {
  const AudioMixerSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playing = false,
    this.loop = false,
    this.ducked = false,
  });

  final Duration position;
  final Duration duration;
  final bool playing;
  final bool loop;
  final bool ducked;
}

abstract interface class AudioMixer {
  AudioMixerSnapshot get snapshot;
  Stream<AudioMixerSnapshot> get snapshots;

  Future<void> load(
    AudioTimeline timeline,
    File Function(AudioClip clip) resolve,
  );
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setLoop(bool loop);
  Future<void> handleLifecycle({required bool active});
  Future<void> dispose();
}

class ScheduledAudioMixer implements AudioMixer {
  ScheduledAudioMixer({
    required AudioPlayerNode Function() createPlayer,
    required AudioFocusService focus,
    PlaybackTimeSource? timeSource,
  }) : this._(createPlayer, focus, PlaybackClock(timeSource: timeSource));

  ScheduledAudioMixer._(this._createPlayer, this._focus, this._clock);

  final AudioPlayerNode Function() _createPlayer;
  final AudioFocusService _focus;
  final PlaybackClock _clock;
  final StreamController<AudioMixerSnapshot> _snapshots =
      StreamController<AudioMixerSnapshot>.broadcast(sync: true);
  final List<_ScheduledNode> _nodes = <_ScheduledNode>[];
  StreamSubscription<AudioFocusEvent>? _focusSubscription;
  StreamSubscription<void>? _noisySubscription;
  Timer? _ticker;
  AudioTimeline? _timeline;
  bool _configured = false;
  bool _ducked = false;
  bool _resumeAfterInterruption = false;
  bool _disposed = false;

  @override
  AudioMixerSnapshot get snapshot {
    final Duration duration = _duration;
    return AudioMixerSnapshot(
      position: _clock.position(duration),
      duration: duration,
      playing: _clock.isPlaying,
      loop: _clock.loop,
      ducked: _ducked,
    );
  }

  @override
  Stream<AudioMixerSnapshot> get snapshots => _snapshots.stream;

  Duration get _duration =>
      Duration(milliseconds: _timeline?.projectDurationMilliseconds ?? 0);

  @override
  Future<void> load(
    AudioTimeline timeline,
    File Function(AudioClip clip) resolve,
  ) async {
    await _ensureFocus();
    final bool wasPlaying = _clock.isPlaying;
    _ticker?.cancel();
    _ticker = null;
    await _disposeNodes();
    if (wasPlaying) {
      await _focus.deactivate();
    }
    _timeline = timeline;
    _clock
      ..stop()
      ..loop = false
      ..audioPosition = null;
    if (timeline.muted || timeline.masterVolume == 0) {
      _emit();
      return;
    }
    for (final AudioClip clip in timeline.clips.where(
      (AudioClip clip) => clip.audible,
    )) {
      final File file = resolve(clip);
      if (!await file.exists()) {
        continue;
      }
      final AudioPlayerNode player = _createPlayer();
      try {
        await player.load(
          file,
          Duration(milliseconds: clip.trimStartMilliseconds),
          Duration(milliseconds: clip.trimEndMilliseconds),
        );
        _nodes.add(_ScheduledNode(clip, player));
      } on Object {
        await player.dispose();
      }
    }
    _emit();
  }

  @override
  Future<void> play() async {
    if (_timeline == null || _duration <= Duration.zero) {
      return;
    }
    if (!await _focus.activate()) {
      return;
    }
    if (_clock.position(_duration) >= _duration && !_clock.loop) {
      _clock.seek(Duration.zero);
    }
    _clock.play();
    await _synchronize(forceSeek: true);
    _ticker ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => unawaited(_tick()),
    );
    _emit();
  }

  @override
  Future<void> pause() async {
    _clock.pause(_duration);
    _clock.audioPosition = null;
    _ticker?.cancel();
    _ticker = null;
    await Future.wait<void>(
      _nodes.map((_ScheduledNode node) => node.player.pause()),
    );
    if (_configured) {
      await _focus.deactivate();
    }
    _emit();
  }

  @override
  Future<void> seek(Duration position) async {
    final Duration bounded = position < Duration.zero
        ? Duration.zero
        : position > _duration
        ? _duration
        : position;
    _clock
      ..audioPosition = null
      ..seek(bounded);
    await _synchronize(forceSeek: true);
    _emit();
  }

  @override
  Future<void> setLoop(bool loop) async {
    _clock.loop = loop;
    _emit();
  }

  @override
  Future<void> handleLifecycle({required bool active}) async {
    if (!active) {
      await pause();
    }
  }

  Future<void> _tick() async {
    if (!_clock.isPlaying) {
      return;
    }
    final Duration position = _clock.position(_duration);
    if (!_clock.loop && position >= _duration) {
      await pause();
      return;
    }
    await _synchronize(forceSeek: false);
    _emit();
  }

  Future<void> _synchronize({required bool forceSeek}) async {
    final AudioTimeline? timeline = _timeline;
    if (timeline == null) {
      return;
    }
    final Duration timelinePosition = _clock.position(_duration);
    _ScheduledNode? authority;
    for (final _ScheduledNode node in _nodes) {
      final AudioClip clip = node.clip;
      final int milliseconds = timelinePosition.inMilliseconds;
      final bool active =
          milliseconds >= clip.startMilliseconds &&
          milliseconds < clip.endMilliseconds;
      if (!active) {
        if (node.player.playing) {
          await node.player.pause();
        }
        continue;
      }
      final Duration expected = Duration(
        milliseconds: milliseconds - clip.startMilliseconds,
      );
      final int drift = (node.player.position - expected).inMilliseconds.abs();
      if (forceSeek || drift >= 40) {
        await node.player.seek(expected);
      }
      final double gain = timeline
          .gainAt(clip, milliseconds)
          .clamp(0, 1)
          .toDouble();
      await node.player.setVolume(gain * (_ducked ? 0.2 : 1));
      if (_clock.isPlaying && !node.player.playing) {
        await node.player.play();
      }
      authority ??= node;
    }
    _clock.audioPosition = authority == null
        ? null
        : () => Duration(
            milliseconds:
                authority!.clip.startMilliseconds +
                authority.player.position.inMilliseconds,
          );
  }

  Future<void> _ensureFocus() async {
    if (_configured) {
      return;
    }
    _configured = true;
    await _focus.configure();
    _focusSubscription = _focus.interruptions.listen((AudioFocusEvent event) {
      unawaited(_handleFocus(event));
    });
    _noisySubscription = _focus.becomingNoisy.listen((_) {
      unawaited(pause());
    });
  }

  Future<void> _handleFocus(AudioFocusEvent event) async {
    switch (event) {
      case AudioFocusEvent.pause:
        _resumeAfterInterruption = _clock.isPlaying;
        await pause();
      case AudioFocusEvent.duck:
        _ducked = true;
        await _synchronize(forceSeek: false);
        _emit();
      case AudioFocusEvent.resume:
        if (_resumeAfterInterruption) {
          _resumeAfterInterruption = false;
          await play();
        }
      case AudioFocusEvent.unduck:
        _ducked = false;
        await _synchronize(forceSeek: false);
        _emit();
    }
  }

  void _emit() {
    if (!_disposed) {
      _snapshots.add(snapshot);
    }
  }

  Future<void> _disposeNodes() async {
    await Future.wait<void>(
      _nodes.map((_ScheduledNode node) => node.player.dispose()),
    );
    _nodes.clear();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _ticker?.cancel();
    await _focusSubscription?.cancel();
    await _noisySubscription?.cancel();
    await _disposeNodes();
    if (_configured) {
      await _focus.deactivate();
    }
    await _snapshots.close();
  }
}

class _ScheduledNode {
  const _ScheduledNode(this.clip, this.player);

  final AudioClip clip;
  final AudioPlayerNode player;
}

class JustAudioPlayerNode implements AudioPlayerNode {
  JustAudioPlayerNode() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Duration get position => _player.position;

  @override
  bool get playing => _player.playing;

  @override
  Future<void> load(File file, Duration trimStart, Duration trimEnd) => _player
      .setAudioSource(
        ClippingAudioSource(
          child: AudioSource.file(file.path),
          start: trimStart,
          end: trimEnd,
        ),
      )
      .then((_) {});

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() async {
    unawaited(_player.play());
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> dispose() => _player.dispose();
}

class PackageAudioFocusService implements AudioFocusService {
  AudioSession? _session;

  Future<AudioSession> get _instance async =>
      _session ??= await AudioSession.instance;

  @override
  Stream<void> get becomingNoisy => Stream<AudioSession>.fromFuture(
    _instance,
  ).asyncExpand((AudioSession session) => session.becomingNoisyEventStream);

  @override
  Stream<AudioFocusEvent> get interruptions =>
      Stream<AudioSession>.fromFuture(_instance).asyncExpand(
        (AudioSession session) => session.interruptionEventStream.map((
          AudioInterruptionEvent event,
        ) {
          if (event.type == AudioInterruptionType.duck) {
            return event.begin ? AudioFocusEvent.duck : AudioFocusEvent.unduck;
          }
          return event.begin ? AudioFocusEvent.pause : AudioFocusEvent.resume;
        }),
      );

  @override
  Future<void> configure() async {
    await (await _instance).configure(const AudioSessionConfiguration.music());
  }

  @override
  Future<bool> activate() =>
      _instance.then((AudioSession session) => session.setActive(true));

  @override
  Future<void> deactivate() async {
    await (await _instance).setActive(false);
  }
}

AudioMixer createPackageAudioMixer() => ScheduledAudioMixer(
  createPlayer: JustAudioPlayerNode.new,
  focus: PackageAudioFocusService(),
);
