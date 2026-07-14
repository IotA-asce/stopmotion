import 'dart:convert';
import 'dart:io';

import '../../audio/domain/audio_timeline.dart';
import '../../editor/domain/timeline.dart';
import '../../projects/domain/project.dart';
import 'export_record.dart';

enum ExportResolution { hd720, fullHd1080 }

enum ExportQuality { compact, balanced, high }

enum GifLoopMode { forever, count, once }

enum ImageSequenceFormat { png, jpeg }

enum ExportStage { preflight, rendering, mixingAudio, packaging, validating }

enum ExportIssueCode {
  noFrames,
  missingFrame,
  missingAudio,
  unsupportedDimensions,
  unsupportedTransparency,
  insufficientStorage,
  encoderUnavailable,
}

class ExportSettings {
  const ExportSettings({
    this.format = ExportFormat.movie,
    this.resolution = ExportResolution.fullHd1080,
    this.quality = ExportQuality.balanced,
    this.gifMaximumDimension = 640,
    this.gifLoopMode = GifLoopMode.forever,
    this.gifLoopCount = 2,
    this.imageSequenceFormat = ImageSequenceFormat.png,
    this.transparentBackground = false,
    this.framesPerSecond,
  });

  factory ExportSettings.decode(String source) {
    try {
      final Map<String, Object?> json =
          (jsonDecode(source) as Map<Object?, Object?>).cast<String, Object?>();
      T byName<T extends Enum>(List<T> values, String key, T fallback) {
        final String? name = json[key] as String?;
        return values.where((T value) => value.name == name).firstOrNull ??
            fallback;
      }

      return ExportSettings(
        format: byName(ExportFormat.values, 'format', ExportFormat.movie),
        resolution: byName(
          ExportResolution.values,
          'resolution',
          ExportResolution.fullHd1080,
        ),
        quality: byName(
          ExportQuality.values,
          'quality',
          ExportQuality.balanced,
        ),
        gifMaximumDimension:
            (json['gifMaximumDimension'] as num?)?.toInt() ?? 640,
        gifLoopMode: byName(
          GifLoopMode.values,
          'gifLoopMode',
          GifLoopMode.forever,
        ),
        gifLoopCount: (json['gifLoopCount'] as num?)?.toInt() ?? 2,
        imageSequenceFormat: byName(
          ImageSequenceFormat.values,
          'imageSequenceFormat',
          ImageSequenceFormat.png,
        ),
        transparentBackground: json['transparentBackground'] as bool? ?? false,
        framesPerSecond: (json['framesPerSecond'] as num?)?.toInt(),
      );
    } on Object {
      return const ExportSettings();
    }
  }

  final ExportFormat format;
  final ExportResolution resolution;
  final ExportQuality quality;
  final int gifMaximumDimension;
  final GifLoopMode gifLoopMode;
  final int gifLoopCount;
  final ImageSequenceFormat imageSequenceFormat;
  final bool transparentBackground;
  final int? framesPerSecond;

  ExportSettings copyWith({
    ExportFormat? format,
    ExportResolution? resolution,
    ExportQuality? quality,
    int? gifMaximumDimension,
    GifLoopMode? gifLoopMode,
    int? gifLoopCount,
    ImageSequenceFormat? imageSequenceFormat,
    bool? transparentBackground,
    int? framesPerSecond,
    bool clearFramesPerSecond = false,
  }) => ExportSettings(
    format: format ?? this.format,
    resolution: resolution ?? this.resolution,
    quality: quality ?? this.quality,
    gifMaximumDimension: gifMaximumDimension ?? this.gifMaximumDimension,
    gifLoopMode: gifLoopMode ?? this.gifLoopMode,
    gifLoopCount: gifLoopCount ?? this.gifLoopCount,
    imageSequenceFormat: imageSequenceFormat ?? this.imageSequenceFormat,
    transparentBackground: transparentBackground ?? this.transparentBackground,
    framesPerSecond: clearFramesPerSecond
        ? null
        : framesPerSecond ?? this.framesPerSecond,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'format': format.name,
    'resolution': resolution.name,
    'quality': quality.name,
    'gifMaximumDimension': gifMaximumDimension,
    'gifLoopMode': gifLoopMode.name,
    'gifLoopCount': gifLoopCount,
    'imageSequenceFormat': imageSequenceFormat.name,
    'transparentBackground': transparentBackground,
    'framesPerSecond': framesPerSecond,
  };

  String encode() => jsonEncode(toJson());

  void validate() {
    if (gifMaximumDimension < 160 || gifMaximumDimension > 960) {
      throw const FormatException('GIF size must be between 160 and 960.');
    }
    if (gifLoopMode == GifLoopMode.count &&
        (gifLoopCount < 1 || gifLoopCount > 100)) {
      throw const FormatException('GIF loop count must be between 1 and 100.');
    }
    if (framesPerSecond != null &&
        (framesPerSecond! < 1 || framesPerSecond! > 60)) {
      throw const FormatException(
        'Export frame rate must be between 1 and 60.',
      );
    }
    if (transparentBackground && format != ExportFormat.imageSequence) {
      throw const FormatException(
        'Transparent backgrounds are available only for image sequences.',
      );
    }
    if (transparentBackground &&
        imageSequenceFormat != ImageSequenceFormat.png) {
      throw const FormatException('Transparency requires PNG output.');
    }
  }
}

class ExportDimensions {
  const ExportDimensions(this.width, this.height);

  factory ExportDimensions.forProject(
    Project project,
    ExportSettings settings,
  ) {
    final int longEdge = settings.format == ExportFormat.gif
        ? settings.gifMaximumDimension
        : switch (settings.resolution) {
            ExportResolution.hd720 => 1280,
            ExportResolution.fullHd1080 => 1920,
          };
    final double ratio = project.aspectRatio.value;
    int width;
    int height;
    if (ratio >= 1) {
      width = longEdge;
      height = (longEdge / ratio).round();
    } else {
      height = longEdge;
      width = (longEdge * ratio).round();
    }
    width -= width % 2;
    height -= height % 2;
    return ExportDimensions(width, height);
  }

  final int width;
  final int height;
}

class ExportIssue {
  const ExportIssue({
    required this.code,
    required this.message,
    this.frameId,
    this.blocking = true,
  });

  final ExportIssueCode code;
  final String message;
  final String? frameId;
  final bool blocking;
}

class ExportPreflight {
  const ExportPreflight({
    required this.issues,
    required this.estimatedBytes,
    required this.dimensions,
    required this.duration,
  });

  final List<ExportIssue> issues;
  final int estimatedBytes;
  final ExportDimensions dimensions;
  final Duration duration;

  bool get canExport => !issues.any((ExportIssue issue) => issue.blocking);
}

class ExportProgress {
  const ExportProgress({
    required this.stage,
    required this.fraction,
    required this.elapsed,
  });

  final ExportStage stage;
  final double fraction;
  final Duration elapsed;
}

class ExportRequest {
  const ExportRequest({
    required this.id,
    required this.project,
    required this.timeline,
    required this.audio,
    required this.settings,
    required this.projectRoot,
    required this.temporaryDirectory,
    required this.output,
  });

  final String id;
  final Project project;
  final TimelineSnapshot timeline;
  final AudioTimeline audio;
  final ExportSettings settings;
  final Directory projectRoot;
  final Directory temporaryDirectory;
  final File output;
}

class ExportResult {
  const ExportResult({
    required this.output,
    required this.bytes,
    required this.duration,
  });

  final File output;
  final int bytes;
  final Duration duration;
}

class ExportCancelled implements Exception {
  const ExportCancelled();
}

class ExportCancellationToken {
  bool _cancelled = false;
  final List<void Function()> _listeners = <void Function()>[];

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final void Function() listener in List.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  void onCancel(void Function() listener) {
    if (_cancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }

  void throwIfCancelled() {
    if (_cancelled) throw const ExportCancelled();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
