import 'dart:async';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';

import '../../features/export/domain/export_job.dart';

class MediaCommandResult {
  const MediaCommandResult({
    required this.success,
    required this.cancelled,
    this.error,
  });

  final bool success;
  final bool cancelled;
  final String? error;
}

abstract interface class MediaCommandRunner {
  Future<MediaCommandResult> run(
    List<String> arguments, {
    required Duration duration,
    required ExportCancellationToken cancellation,
    required void Function(double fraction) onProgress,
  });
}

class FfmpegCommandRunner implements MediaCommandRunner {
  const FfmpegCommandRunner();

  @override
  Future<MediaCommandResult> run(
    List<String> arguments, {
    required Duration duration,
    required ExportCancellationToken cancellation,
    required void Function(double fraction) onProgress,
  }) async {
    final Completer<MediaCommandResult> completer =
        Completer<MediaCommandResult>();
    FFmpegSession? active;
    cancellation.onCancel(() {
      final int? sessionId = active?.getSessionId();
      unawaited(FFmpegKit.cancel(sessionId));
    });
    active = await FFmpegKit.executeWithArgumentsAsync(
      arguments,
      (FFmpegSession session) async {
        final ReturnCode? code = await session.getReturnCode();
        if (!completer.isCompleted) {
          completer.complete(
            MediaCommandResult(
              success: ReturnCode.isSuccess(code),
              cancelled: ReturnCode.isCancel(code) || cancellation.isCancelled,
              error: ReturnCode.isSuccess(code)
                  ? null
                  : _redactedError(await session.getOutput()),
            ),
          );
        }
      },
      null,
      (statistics) {
        final int total = duration.inMilliseconds;
        onProgress(total == 0 ? 0 : (statistics.getTime() / total).clamp(0, 1));
      },
    );
    if (cancellation.isCancelled) {
      await FFmpegKit.cancel(active.getSessionId());
    }
    return completer.future;
  }

  static String _redactedError(String? output) {
    if (output == null || output.trim().isEmpty) {
      return 'Media encoder failed.';
    }
    final List<String> lines = output.trim().split('\n');
    return lines.last
        .replaceAll(RegExp(r'(/[^\s:]+)+'), '<path>')
        .replaceAll(RegExp(r'[A-Za-z]:\\[^\s]+'), '<path>');
  }
}
