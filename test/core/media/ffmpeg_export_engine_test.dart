import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/media/export_output_validator.dart';
import 'package:stop_motion/core/media/ffmpeg_command_runner.dart';
import 'package:stop_motion/core/media/ffmpeg_export_engine.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';

import '../../helpers/export_fixtures.dart';

class _FakeRunner implements MediaCommandRunner {
  List<String>? arguments;

  @override
  Future<MediaCommandResult> run(
    List<String> arguments, {
    required Duration duration,
    required ExportCancellationToken cancellation,
    required void Function(double fraction) onProgress,
  }) async {
    this.arguments = arguments;
    onProgress(0.5);
    if (cancellation.isCancelled) {
      return const MediaCommandResult(success: false, cancelled: true);
    }
    final File output = File(arguments.last);
    await output.parent.create(recursive: true);
    await output.writeAsBytes(<int>[0, 1, 2, 3]);
    return const MediaCommandResult(success: true, cancelled: false);
  }
}

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('movie_export_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'movie command contains H.264, AAC, timing, fades, and metadata',
    () async {
      final _FakeRunner runner = _FakeRunner();
      final FfmpegExportEngine engine = FfmpegExportEngine(
        runner: runner,
        validator: const NoOpExportOutputValidator(),
        videoEncoder: 'h264_test_encoder',
      );
      final request = await exportRequest(root, withAudio: true);

      final result = await engine.export(
        request,
        cancellation: ExportCancellationToken(),
        onProgress: (_) {},
      );
      final String command = runner.arguments!.join(' ');

      expect(result.bytes, 4);
      expect(command, contains('-c:v h264_test_encoder'));
      expect(command, contains('-c:a aac'));
      expect(command, contains('atrim=start=0.1:end=0.3'));
      expect(command, contains('adelay=delays=40:all=1'));
      expect(command, contains('afade=t=in'));
      expect(command, contains('afade=t=out'));
      expect(command, contains('volume=0.7'));
      expect(command, contains('title=Paper planets'));
      expect(await request.temporaryDirectory.exists(), isFalse);
    },
  );

  test('GIF command excludes audio and carries explicit loop count', () async {
    final _FakeRunner runner = _FakeRunner();
    final FfmpegExportEngine engine = FfmpegExportEngine(
      runner: runner,
      validator: const NoOpExportOutputValidator(),
    );
    final request = await exportRequest(
      root,
      settings: const ExportSettings(
        format: ExportFormat.gif,
        gifLoopMode: GifLoopMode.count,
        gifLoopCount: 3,
      ),
      withAudio: true,
    );

    await engine.export(
      request,
      cancellation: ExportCancellationToken(),
      onProgress: (_) {},
    );
    final String command = runner.arguments!.join(' ');

    expect(command, contains('palettegen'));
    expect(command, contains('-loop 3'));
    expect(command, isNot(contains('-c:a')));
    expect(command, isNot(contains('voice.m4a')));
  });

  test(
    'cancelled command removes partial output and temporary frames',
    () async {
      final _FakeRunner runner = _FakeRunner();
      final FfmpegExportEngine engine = FfmpegExportEngine(
        runner: runner,
        validator: const NoOpExportOutputValidator(),
      );
      final request = await exportRequest(root);
      final ExportCancellationToken token = ExportCancellationToken()..cancel();

      expect(
        () => engine.export(request, cancellation: token, onProgress: (_) {}),
        throwsA(isA<ExportCancelled>()),
      );
      expect(await request.output.exists(), isFalse);
      expect(await request.temporaryDirectory.exists(), isFalse);
    },
  );
}
