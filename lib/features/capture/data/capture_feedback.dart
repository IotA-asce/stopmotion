import 'package:flutter/services.dart';

abstract interface class CaptureFeedback {
  Future<void> frameAccepted();
}

class HapticCaptureFeedback implements CaptureFeedback {
  const HapticCaptureFeedback();

  @override
  Future<void> frameAccepted() => HapticFeedback.mediumImpact();
}

class NoopCaptureFeedback implements CaptureFeedback {
  const NoopCaptureFeedback();

  @override
  Future<void> frameAccepted() async {}
}
