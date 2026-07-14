enum AppAppearance { system, light, dark }

class AppSettings {
  const AppSettings({
    this.appearance = AppAppearance.system,
    this.defaultFramesPerSecond = 12,
    this.keepAwakeDuringCapture = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final AppAppearance appearance;
  final int defaultFramesPerSecond;
  final bool keepAwakeDuringCapture;
  final bool hapticsEnabled;
  final bool reducedMotion;
}
