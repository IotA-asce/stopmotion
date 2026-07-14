import 'dart:async';

abstract interface class CancelableInterval {
  void cancel();
}

abstract interface class CaptureScheduler {
  Future<void> delay(Duration duration);
  CancelableInterval periodic(Duration duration, void Function() callback);
}

class DartCaptureScheduler implements CaptureScheduler {
  const DartCaptureScheduler();

  @override
  Future<void> delay(Duration duration) => Future<void>.delayed(duration);

  @override
  CancelableInterval periodic(Duration duration, void Function() callback) =>
      _TimerInterval(Timer.periodic(duration, (_) => callback()));
}

class _TimerInterval implements CancelableInterval {
  const _TimerInterval(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
