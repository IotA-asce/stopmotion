import 'dart:io';

import 'package:path/path.dart' as p;

import '../../features/export/domain/export_job.dart';
import '../../features/export/domain/export_record.dart';

abstract interface class ExportEngine {
  Future<bool> isAvailable();

  Future<ExportResult> export(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  });
}

typedef AvailableStorageReader = Future<int?> Function(Directory directory);

class ExportPreflightService {
  const ExportPreflightService({this.availableStorage});

  final AvailableStorageReader? availableStorage;

  Future<ExportPreflight> inspect(ExportRequest request) async {
    request.settings.validate();
    final List<ExportIssue> issues = <ExportIssue>[];
    if (request.timeline.frames.isEmpty) {
      issues.add(
        const ExportIssue(
          code: ExportIssueCode.noFrames,
          message: 'Add at least one frame before exporting.',
        ),
      );
    }
    for (final frame in request.timeline.frames) {
      final File source = File(
        p.join(request.projectRoot.path, frame.relativeSourcePath),
      );
      if (frame.missing || !await source.exists()) {
        issues.add(
          ExportIssue(
            code: ExportIssueCode.missingFrame,
            frameId: frame.id,
            message: 'A source frame is missing.',
          ),
        );
      }
    }
    for (final clip in request.audio.clips.where((clip) => clip.audible)) {
      final File source = File(
        p.join(request.projectRoot.path, clip.relativeSourcePath),
      );
      if (!await source.exists()) {
        issues.add(
          const ExportIssue(
            code: ExportIssueCode.missingAudio,
            message: 'An audible audio source is missing.',
          ),
        );
      }
    }
    final ExportDimensions dimensions = ExportDimensions.forProject(
      request.project,
      request.settings,
    );
    if (dimensions.width < 2 ||
        dimensions.height < 2 ||
        dimensions.width > 4096 ||
        dimensions.height > 4096) {
      issues.add(
        const ExportIssue(
          code: ExportIssueCode.unsupportedDimensions,
          message: 'The selected dimensions are not supported.',
        ),
      );
    }
    if (request.settings.transparentBackground) {
      issues.add(
        const ExportIssue(
          code: ExportIssueCode.unsupportedTransparency,
          message:
              'Transparency is unavailable because the current render pipeline uses an opaque project canvas.',
        ),
      );
    }
    final int estimatedBytes = estimateBytes(request, dimensions);
    final int? available = await availableStorage?.call(request.output.parent);
    if (available != null && available < estimatedBytes * 2) {
      issues.add(
        const ExportIssue(
          code: ExportIssueCode.insufficientStorage,
          message: 'Free storage is too low for this export.',
        ),
      );
    }
    return ExportPreflight(
      issues: List.unmodifiable(issues),
      estimatedBytes: estimatedBytes,
      dimensions: dimensions,
      duration: request.timeline.duration,
    );
  }

  int estimateBytes(ExportRequest request, ExportDimensions dimensions) {
    final double seconds = request.timeline.duration.inMilliseconds / 1000;
    return switch (request.settings.format) {
      ExportFormat.movie =>
        ((switch (request.settings.quality) {
                      ExportQuality.compact => 2.5,
                      ExportQuality.balanced => 5.0,
                      ExportQuality.high => 9.0,
                    } *
                    1000000 /
                    8 *
                    seconds) +
                (16000 * seconds))
            .ceil(),
      ExportFormat.gif =>
        (dimensions.width * dimensions.height * seconds * 0.55).ceil(),
      ExportFormat.imageSequence =>
        (dimensions.width *
                dimensions.height *
                request.timeline.frames.length *
                (request.settings.imageSequenceFormat == ImageSequenceFormat.png
                    ? 1.2
                    : 0.35))
            .ceil(),
    };
  }
}
