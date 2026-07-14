import 'dart:convert';

import '../../capture/domain/capture_frame.dart';
import '../../export/domain/export_job.dart';
import '../../projects/domain/project.dart';

enum AppAppearance { system, light, dark }

enum ReducedMotionPreference { system, on, off }

class CaptureDefaults {
  const CaptureDefaults({
    this.aspectRatio = ProjectAspectRatio.widescreen,
    this.resolution = ProjectResolution.fullHd1080,
    this.framesPerSecond = 12,
    this.grid = CaptureGrid.off,
    this.onionOpacity = 0.45,
    this.timerSeconds = 0,
    this.volumeButtonShutter = true,
  });

  final ProjectAspectRatio aspectRatio;
  final ProjectResolution resolution;
  final int framesPerSecond;
  final CaptureGrid grid;
  final double onionOpacity;
  final int timerSeconds;
  final bool volumeButtonShutter;

  CaptureDefaults copyWith({
    ProjectAspectRatio? aspectRatio,
    ProjectResolution? resolution,
    int? framesPerSecond,
    CaptureGrid? grid,
    double? onionOpacity,
    int? timerSeconds,
    bool? volumeButtonShutter,
  }) => CaptureDefaults(
    aspectRatio: aspectRatio ?? this.aspectRatio,
    resolution: resolution ?? this.resolution,
    framesPerSecond: framesPerSecond ?? this.framesPerSecond,
    grid: grid ?? this.grid,
    onionOpacity: onionOpacity ?? this.onionOpacity,
    timerSeconds: timerSeconds ?? this.timerSeconds,
    volumeButtonShutter: volumeButtonShutter ?? this.volumeButtonShutter,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'aspectRatio': aspectRatio.name,
    'resolution': resolution.name,
    'framesPerSecond': framesPerSecond,
    'grid': grid.name,
    'onionOpacity': onionOpacity,
    'timerSeconds': timerSeconds,
    'volumeButtonShutter': volumeButtonShutter,
  };

  static CaptureDefaults fromJson(Object? value) {
    if (value is! Map<Object?, Object?>) return const CaptureDefaults();
    final Map<Object?, Object?> json = value;
    T enumValue<T extends Enum>(List<T> values, String key, T fallback) =>
        values.where((T item) => item.name == json[key]).firstOrNull ??
        fallback;
    final int fps = (json['framesPerSecond'] as num?)?.toInt() ?? 12;
    final double opacity = (json['onionOpacity'] as num?)?.toDouble() ?? 0.45;
    final int timer = (json['timerSeconds'] as num?)?.toInt() ?? 0;
    return CaptureDefaults(
      aspectRatio: enumValue(
        ProjectAspectRatio.values,
        'aspectRatio',
        ProjectAspectRatio.widescreen,
      ),
      resolution: enumValue(
        ProjectResolution.values,
        'resolution',
        ProjectResolution.fullHd1080,
      ),
      framesPerSecond: fps.clamp(1, 30),
      grid: enumValue(CaptureGrid.values, 'grid', CaptureGrid.off),
      onionOpacity: opacity.clamp(0.1, 0.9),
      timerSeconds: timer.clamp(0, 20),
      volumeButtonShutter: json['volumeButtonShutter'] as bool? ?? true,
    );
  }
}

class AppSettings {
  const AppSettings({
    this.appearance = AppAppearance.system,
    this.reducedMotion = ReducedMotionPreference.system,
    this.captureDefaults = const CaptureDefaults(),
    this.exportDefaults = const ExportSettings(),
    this.highContrastTimeline = false,
    this.keepAwakeDuringCapture = true,
    this.hapticsEnabled = true,
  });

  final AppAppearance appearance;
  final ReducedMotionPreference reducedMotion;
  final CaptureDefaults captureDefaults;
  final ExportSettings exportDefaults;
  final bool highContrastTimeline;
  final bool keepAwakeDuringCapture;
  final bool hapticsEnabled;

  AppSettings copyWith({
    AppAppearance? appearance,
    ReducedMotionPreference? reducedMotion,
    CaptureDefaults? captureDefaults,
    ExportSettings? exportDefaults,
    bool? highContrastTimeline,
    bool? keepAwakeDuringCapture,
    bool? hapticsEnabled,
  }) => AppSettings(
    appearance: appearance ?? this.appearance,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    captureDefaults: captureDefaults ?? this.captureDefaults,
    exportDefaults: exportDefaults ?? this.exportDefaults,
    highContrastTimeline: highContrastTimeline ?? this.highContrastTimeline,
    keepAwakeDuringCapture:
        keepAwakeDuringCapture ?? this.keepAwakeDuringCapture,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'appearance': appearance.name,
    'reducedMotion': reducedMotion.name,
    'captureDefaults': captureDefaults.toJson(),
    'exportDefaults': exportDefaults.toJson(),
    'highContrastTimeline': highContrastTimeline,
    'keepAwakeDuringCapture': keepAwakeDuringCapture,
    'hapticsEnabled': hapticsEnabled,
  };

  String encode() => jsonEncode(toJson());

  static AppSettings decode(String? source) {
    if (source == null) return const AppSettings();
    try {
      final Object? decoded = jsonDecode(source);
      if (decoded is! Map<Object?, Object?>) return const AppSettings();
      T enumValue<T extends Enum>(List<T> values, String key, T fallback) =>
          values.where((T item) => item.name == decoded[key]).firstOrNull ??
          fallback;
      final Object? exportValue = decoded['exportDefaults'];
      return AppSettings(
        appearance: enumValue(
          AppAppearance.values,
          'appearance',
          AppAppearance.system,
        ),
        reducedMotion: enumValue(
          ReducedMotionPreference.values,
          'reducedMotion',
          ReducedMotionPreference.system,
        ),
        captureDefaults: CaptureDefaults.fromJson(decoded['captureDefaults']),
        exportDefaults: ExportSettings.decode(
          exportValue is Map<Object?, Object?> ? jsonEncode(exportValue) : '',
        ),
        highContrastTimeline: decoded['highContrastTimeline'] as bool? ?? false,
        keepAwakeDuringCapture:
            decoded['keepAwakeDuringCapture'] as bool? ?? true,
        hapticsEnabled: decoded['hapticsEnabled'] as bool? ?? true,
      );
    } on Object {
      return const AppSettings();
    }
  }
}
