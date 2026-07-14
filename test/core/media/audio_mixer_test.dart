import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/media/audio_mixer.dart';
import 'package:stop_motion/features/audio/domain/audio_clip.dart';
import 'package:stop_motion/features/audio/domain/audio_timeline.dart';
import 'package:stop_motion/features/preview/domain/playback_clock.dart';

void main() {
  late Directory root;
  late File source;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('audio_mixer_');
    source = await File('${root.path}/source.m4a').writeAsBytes(<int>[1]);
  });

  tearDown(() => root.delete(recursive: true));

  test(
    'schedules overlapping clips with volume, fades, seek, and mute',
    () async {
      final List<_FakePlayer> players = <_FakePlayer>[];
      final _FakeFocus focus = _FakeFocus();
      final ScheduledAudioMixer mixer = ScheduledAudioMixer(
        createPlayer: () {
          final _FakePlayer player = _FakePlayer();
          players.add(player);
          return player;
        },
        focus: focus,
        timeSource: _FakeTimeSource(),
      );
      final AudioClip narration = _clip(
        'narration',
        AudioTrackType.narration,
        duration: 4000,
      ).copyWith(volume: 0.8, fadeInMilliseconds: 1000);
      final AudioClip music = _clip(
        'music',
        AudioTrackType.music,
        duration: 4000,
      ).copyWith(startMilliseconds: 500, volume: 0.5);
      final AudioTimeline timeline = AudioTimeline(
        projectId: 'project',
        projectDurationMilliseconds: 5000,
        clips: <AudioClip>[narration, music],
        masterVolume: 0.5,
      );
      await mixer.load(timeline, (_) => source);

      await mixer.seek(const Duration(milliseconds: 750));
      await mixer.play();

      expect(players[0].position, const Duration(milliseconds: 750));
      expect(players[1].position, const Duration(milliseconds: 250));
      expect(players[0].volume, closeTo(0.3, 0.0001));
      expect(players[1].volume, closeTo(0.25, 0.0001));
      expect(players.every((_FakePlayer player) => player.playing), isTrue);

      await mixer.load(timeline.copyWith(muted: true), (_) => source);
      expect(
        players.take(2).every((_FakePlayer player) => player.disposed),
        isTrue,
      );
      expect(mixer.snapshot.playing, isFalse);
      await mixer.dispose();
      await focus.close();
    },
  );

  test(
    'native audio position is authoritative within 40 ms over two minutes',
    () async {
      late _FakePlayer player;
      final _FakeFocus focus = _FakeFocus();
      final ScheduledAudioMixer mixer = ScheduledAudioMixer(
        createPlayer: () => player = _FakePlayer(),
        focus: focus,
        timeSource: _FakeTimeSource(),
      );
      await mixer.load(
        AudioTimeline(
          projectId: 'project',
          projectDurationMilliseconds: 120000,
          clips: <AudioClip>[
            _clip('music', AudioTrackType.music, duration: 120000),
          ],
        ),
        (_) => source,
      );
      await mixer.play();
      player.position = const Duration(
        minutes: 1,
        seconds: 59,
        milliseconds: 990,
      );

      final int drift = (mixer.snapshot.position - player.position)
          .inMilliseconds
          .abs();
      expect(drift, lessThan(40));
      await mixer.dispose();
      await focus.close();
    },
  );

  test(
    'focus, headphones, loop, pause, and lifecycle release playback',
    () async {
      late _FakePlayer player;
      final _FakeFocus focus = _FakeFocus();
      final ScheduledAudioMixer mixer = ScheduledAudioMixer(
        createPlayer: () => player = _FakePlayer(),
        focus: focus,
        timeSource: _FakeTimeSource(),
      );
      await mixer.load(
        AudioTimeline(
          projectId: 'project',
          projectDurationMilliseconds: 4000,
          clips: <AudioClip>[
            _clip('effect', AudioTrackType.effect, duration: 4000),
          ],
        ),
        (_) => source,
      );
      await mixer.setLoop(true);
      await mixer.play();
      expect(mixer.snapshot.loop, isTrue);

      focus.emit(AudioFocusEvent.duck);
      await Future<void>.delayed(Duration.zero);
      expect(mixer.snapshot.ducked, isTrue);
      expect(player.volume, closeTo(0.2, 0.0001));
      focus.emit(AudioFocusEvent.unduck);
      await Future<void>.delayed(Duration.zero);
      expect(player.volume, 1);

      focus.emit(AudioFocusEvent.pause);
      await Future<void>.delayed(Duration.zero);
      expect(mixer.snapshot.playing, isFalse);
      focus.emit(AudioFocusEvent.resume);
      await Future<void>.delayed(Duration.zero);
      expect(mixer.snapshot.playing, isTrue);
      focus.emitNoisy();
      await Future<void>.delayed(Duration.zero);
      expect(mixer.snapshot.playing, isFalse);

      await mixer.handleLifecycle(active: false);
      await mixer.dispose();
      expect(player.disposed, isTrue);
      expect(focus.deactivations, greaterThan(0));
      await focus.close();
    },
  );
}

AudioClip _clip(String id, AudioTrackType type, {required int duration}) =>
    AudioClip(
      id: id,
      projectId: 'project',
      relativeSourcePath: 'source.m4a',
      name: id,
      trackType: type,
      startMilliseconds: 0,
      trimStartMilliseconds: 0,
      trimEndMilliseconds: duration,
      volume: 1,
      fadeInMilliseconds: 0,
      fadeOutMilliseconds: 0,
      muted: false,
    );

class _FakePlayer implements AudioPlayerNode {
  @override
  Duration position = Duration.zero;
  @override
  bool playing = false;
  double volume = 1;
  bool disposed = false;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  Future<void> load(File file, Duration trimStart, Duration trimEnd) async {}

  @override
  Future<void> pause() async => playing = false;

  @override
  Future<void> play() async => playing = true;

  @override
  Future<void> seek(Duration position) async => this.position = position;

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;
}

class _FakeFocus implements AudioFocusService {
  final StreamController<AudioFocusEvent> _interruptions =
      StreamController<AudioFocusEvent>.broadcast(sync: true);
  final StreamController<void> _noisy = StreamController<void>.broadcast(
    sync: true,
  );
  int deactivations = 0;

  @override
  Stream<void> get becomingNoisy => _noisy.stream;

  @override
  Stream<AudioFocusEvent> get interruptions => _interruptions.stream;

  void emit(AudioFocusEvent event) => _interruptions.add(event);
  void emitNoisy() => _noisy.add(null);

  @override
  Future<bool> activate() async => true;

  @override
  Future<void> configure() async {}

  @override
  Future<void> deactivate() async => deactivations++;

  Future<void> close() async {
    await _interruptions.close();
    await _noisy.close();
  }
}

class _FakeTimeSource implements PlaybackTimeSource {
  Duration value = Duration.zero;

  @override
  Duration get elapsed => value;
}
