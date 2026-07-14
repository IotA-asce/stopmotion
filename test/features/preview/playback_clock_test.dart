import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/preview/domain/playback_clock.dart';

import '../editor/timeline_test.dart' show frame;

void main() {
  test('monotonic clock stays exact over two minutes and loops', () {
    final FakeTimeSource time = FakeTimeSource();
    final PlaybackClock clock = PlaybackClock(timeSource: time);
    final TimelineSnapshot timeline = TimelineSnapshot(
      frames: List.generate(2880, (int index) => frame('$index')),
      fps: 24,
    );

    clock.play();
    time.value = const Duration(minutes: 1, seconds: 59, milliseconds: 990);
    expect(
      (clock.position(timeline.duration) - time.value).inMilliseconds.abs(),
      lessThan(40),
    );
    clock.loop = true;
    time.value = const Duration(minutes: 2, milliseconds: 500);
    expect(
      clock.position(timeline.duration),
      const Duration(milliseconds: 500),
    );
  });

  test('audio position becomes authoritative when attached', () {
    final PlaybackClock clock = PlaybackClock(timeSource: FakeTimeSource());
    clock.audioPosition = () => const Duration(seconds: 7);
    expect(
      clock.position(const Duration(seconds: 10)),
      const Duration(seconds: 7),
    );
  });
}

class FakeTimeSource implements PlaybackTimeSource {
  Duration value = Duration.zero;

  @override
  Duration get elapsed => value;
}
