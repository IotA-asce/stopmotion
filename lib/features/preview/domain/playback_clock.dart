import '../../editor/domain/timeline.dart';

abstract interface class PlaybackTimeSource {
  Duration get elapsed;
}

class StopwatchTimeSource implements PlaybackTimeSource {
  StopwatchTimeSource() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  Duration get elapsed => _stopwatch.elapsed;
}

class PlaybackClock {
  PlaybackClock({PlaybackTimeSource? timeSource})
    : _timeSource = timeSource ?? StopwatchTimeSource();

  final PlaybackTimeSource _timeSource;
  Duration _position = Duration.zero;
  Duration _startedAt = Duration.zero;
  bool _playing = false;
  bool loop = false;
  Duration Function()? audioPosition;

  bool get isPlaying => _playing;

  Duration position(Duration duration) {
    Duration current = audioPosition?.call() ?? _position;
    if (_playing && audioPosition == null) {
      current += _timeSource.elapsed - _startedAt;
    }
    if (duration <= Duration.zero) {
      return Duration.zero;
    }
    if (loop) {
      return Duration(
        microseconds: current.inMicroseconds % duration.inMicroseconds,
      );
    }
    return current > duration ? duration : current;
  }

  int frameIndex(TimelineSnapshot timeline) =>
      timeline.frameIndexAt(position(timeline.duration));

  void play() {
    if (_playing) {
      return;
    }
    _startedAt = _timeSource.elapsed;
    _playing = true;
  }

  void pause(Duration duration) {
    if (!_playing) {
      return;
    }
    _position = position(duration);
    _playing = false;
  }

  void seek(Duration position) {
    _position = position < Duration.zero ? Duration.zero : position;
    _startedAt = _timeSource.elapsed;
  }

  void stop() {
    _position = Duration.zero;
    _playing = false;
  }
}
