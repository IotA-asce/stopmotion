import 'dart:io';
import 'dart:math' as math;

import 'package:ffmpeg_kit_flutter_new_min/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/media_information.dart';
import 'package:ffmpeg_kit_flutter_new_min/stream_information.dart';

import '../../features/export/domain/export_job.dart';
import '../../features/export/domain/export_record.dart';

abstract interface class ExportOutputValidator {
  Future<void> validate(ExportRequest request, File output);
}

class NoOpExportOutputValidator implements ExportOutputValidator {
  const NoOpExportOutputValidator();

  @override
  Future<void> validate(ExportRequest request, File output) async {}
}

class FfprobeExportOutputValidator implements ExportOutputValidator {
  const FfprobeExportOutputValidator();

  @override
  Future<void> validate(ExportRequest request, File output) async {
    if (!await output.exists() || await output.length() == 0) {
      throw StateError('Export validation found an empty output.');
    }
    final session = await FFprobeKit.getMediaInformation(output.path);
    final MediaInformation? media = session.getMediaInformation();
    if (media == null) {
      throw StateError('Export output could not be independently decoded.');
    }
    final List<StreamInformation> streams = media.getStreams();
    final StreamInformation? video = _firstOfType(streams, 'video');
    if (video == null) throw StateError('Export has no video stream.');
    final ExportDimensions expected = ExportDimensions.forProject(
      request.project,
      request.settings,
    );
    if (video.getWidth() != expected.width ||
        video.getHeight() != expected.height) {
      throw StateError('Export dimensions do not match the project canvas.');
    }
    final String expectedCodec = request.settings.format == ExportFormat.movie
        ? 'h264'
        : 'gif';
    if (video.getCodec() != expectedCodec) {
      throw StateError('Export codec is not $expectedCodec.');
    }
    if (request.settings.format == ExportFormat.movie &&
        video.getFormat() != 'yuv420p') {
      throw StateError('Movie pixel format is not broadly compatible.');
    }
    final double? duration = double.tryParse(media.getDuration() ?? '');
    final double expectedSeconds =
        request.timeline.duration.inMicroseconds /
        Duration.microsecondsPerSecond;
    final double tolerance =
        1 / (request.settings.framesPerSecond ?? request.timeline.fps) + 0.02;
    if (duration == null || (duration - expectedSeconds).abs() > tolerance) {
      throw StateError('Export duration does not match the timeline.');
    }
    final bool needsAudio =
        request.settings.format == ExportFormat.movie &&
        request.audio.hasAudibleAudio;
    final StreamInformation? audio = _firstOfType(streams, 'audio');
    if (needsAudio && audio?.getCodec() != 'aac') {
      throw StateError('Movie audio is missing or is not AAC.');
    }
    if (!needsAudio && audio != null) {
      throw StateError('Export unexpectedly contains audio.');
    }
    final double? actualFps = _rational(video.getAverageFrameRate());
    final int expectedFps =
        request.settings.framesPerSecond ?? request.timeline.fps;
    if (actualFps == null || (actualFps - expectedFps).abs() > 0.05) {
      throw StateError('Export frame rate does not match its settings.');
    }
    if (media.getAllProperties().toString().contains(
      request.projectRoot.path,
    )) {
      throw StateError('Export metadata contains a private source path.');
    }
  }

  StreamInformation? _firstOfType(
    List<StreamInformation> streams,
    String type,
  ) {
    for (final StreamInformation stream in streams) {
      if (stream.getType() == type) return stream;
    }
    return null;
  }

  double? _rational(String? value) {
    if (value == null) return null;
    final List<String> parts = value.split('/');
    if (parts.length == 1) return double.tryParse(value);
    final double? numerator = double.tryParse(parts.first);
    final double? denominator = double.tryParse(parts.last);
    if (numerator == null || denominator == null || denominator == 0) {
      return null;
    }
    final double parsed = numerator / denominator;
    return parsed.isFinite ? math.max(0, parsed) : null;
  }
}
