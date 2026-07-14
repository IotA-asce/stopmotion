class IntervalCaptureSettings {
  const IntervalCaptureSettings({required this.seconds})
    : assert(seconds >= 1 && seconds <= 60);

  final int seconds;

  Duration get duration => Duration(seconds: seconds);
}
