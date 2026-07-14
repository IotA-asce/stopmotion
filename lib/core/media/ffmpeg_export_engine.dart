import 'dart:io';

import 'package:path/path.dart' as p;

import '../../features/audio/domain/audio_clip.dart';
import '../../features/export/domain/export_job.dart';
import '../../features/export/domain/export_record.dart';
import 'export_engine.dart';
import 'export_frame_renderer.dart';
import 'export_output_validator.dart';
import 'ffmpeg_command_runner.dart';

class FfmpegExportEngine implements ExportEngine {
  const FfmpegExportEngine({
    MediaCommandRunner runner = const FfmpegCommandRunner(),
    ExportFrameRenderer frameRenderer = const ExportFrameRenderer(),
    ExportOutputValidator validator = const FfprobeExportOutputValidator(),
    String? videoEncoder,
  }) : this._(runner, frameRenderer, validator, videoEncoder);

  const FfmpegExportEngine._(
    this._runner,
    this._frameRenderer,
    this._validator,
    this._videoEncoder,
  );

  final MediaCommandRunner _runner;
  final ExportFrameRenderer _frameRenderer;
  final ExportOutputValidator _validator;
  final String? _videoEncoder;

  @override
  Future<bool> isAvailable() async => Platform.isAndroid || Platform.isIOS;

  @override
  Future<ExportResult> export(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  }) async {
    if (request.settings.format == ExportFormat.imageSequence) {
      throw ArgumentError('Image sequences use ImageSequenceExporter.');
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    await request.temporaryDirectory.create(recursive: true);
    await request.output.parent.create(recursive: true);
    final ExportDimensions dimensions = ExportDimensions.forProject(
      request.project,
      request.settings,
    );
    final List<File> frames = <File>[];
    try {
      for (var index = 0; index < request.timeline.frames.length; index++) {
        cancellation.throwIfCancelled();
        frames.add(
          await _frameRenderer.renderFrame(
            request: request,
            frame: request.timeline.frames[index],
            dimensions: dimensions,
            extension: 'jpg',
            index: index,
          ),
        );
        onProgress(
          ExportProgress(
            stage: ExportStage.rendering,
            fraction: (index + 1) / request.timeline.frames.length * 0.45,
            elapsed: stopwatch.elapsed,
          ),
        );
      }
      final File concat = await _writeConcat(request, frames);
      final List<String> arguments = request.settings.format == ExportFormat.gif
          ? buildGifArguments(request, concat)
          : buildMovieArguments(request, concat);
      final MediaCommandResult command = await _runner.run(
        arguments,
        duration: request.timeline.duration,
        cancellation: cancellation,
        onProgress: (double fraction) {
          onProgress(
            ExportProgress(
              stage: request.settings.format == ExportFormat.movie
                  ? ExportStage.mixingAudio
                  : ExportStage.packaging,
              fraction: 0.45 + fraction * 0.5,
              elapsed: stopwatch.elapsed,
            ),
          );
        },
      );
      if (command.cancelled) throw const ExportCancelled();
      if (!command.success) {
        throw StateError(command.error ?? 'Media encoder failed.');
      }
      if (!await request.output.exists() ||
          await request.output.length() == 0) {
        throw StateError('Media encoder returned an empty output.');
      }
      await _validator.validate(request, request.output);
      onProgress(
        ExportProgress(
          stage: ExportStage.validating,
          fraction: 1,
          elapsed: stopwatch.elapsed,
        ),
      );
      return ExportResult(
        output: request.output,
        bytes: await request.output.length(),
        duration: request.timeline.duration,
      );
    } on Object {
      if (await request.output.exists()) await request.output.delete();
      rethrow;
    } finally {
      if (await request.temporaryDirectory.exists()) {
        await request.temporaryDirectory.delete(recursive: true);
      }
    }
  }

  List<String> buildMovieArguments(ExportRequest request, File concat) {
    final int fps = request.settings.framesPerSecond ?? request.timeline.fps;
    final ExportDimensions dimensions = ExportDimensions.forProject(
      request.project,
      request.settings,
    );
    final List<AudioClip> clips = request.audio.muted
        ? const <AudioClip>[]
        : request.audio.clips.where((AudioClip clip) => clip.audible).toList();
    final List<String> arguments = <String>[
      '-y',
      '-f',
      'concat',
      '-safe',
      '0',
      '-i',
      concat.path,
    ];
    for (final AudioClip clip in clips) {
      arguments.addAll(<String>[
        '-i',
        p.join(request.projectRoot.path, clip.relativeSourcePath),
      ]);
    }
    if (clips.isNotEmpty) {
      arguments.addAll(<String>[
        '-filter_complex',
        _audioFilter(request, clips),
      ]);
    }
    arguments.addAll(<String>[
      '-map',
      '0:v:0',
      if (clips.isNotEmpty) ...<String>['-map', '[audio_out]'],
      '-vf',
      'scale=${dimensions.width}:${dimensions.height}:flags=lanczos,format=yuv420p',
      '-r',
      '$fps',
      '-c:v',
      _videoEncoder ??
          (Platform.isAndroid ? 'h264_mediacodec' : 'h264_videotoolbox'),
      '-b:v',
      switch (request.settings.quality) {
        ExportQuality.compact => '2500k',
        ExportQuality.balanced => '5000k',
        ExportQuality.high => '9000k',
      },
      if (clips.isNotEmpty) ...<String>['-c:a', 'aac', '-b:a', '128k'],
      if (clips.isEmpty) '-an',
      '-t',
      _seconds(request.timeline.duration),
      '-movflags',
      '+faststart',
      '-metadata',
      'artist=Stop Motion',
      '-metadata',
      'title=${request.project.title}',
      request.output.path,
    ]);
    return arguments;
  }

  List<String> buildGifArguments(ExportRequest request, File concat) {
    final int fps = request.settings.framesPerSecond ?? request.timeline.fps;
    final int loop = switch (request.settings.gifLoopMode) {
      GifLoopMode.forever => 0,
      GifLoopMode.once => -1,
      GifLoopMode.count => request.settings.gifLoopCount,
    };
    return <String>[
      '-y',
      '-f',
      'concat',
      '-safe',
      '0',
      '-i',
      concat.path,
      '-vf',
      'fps=$fps,split[gif_a][gif_b];[gif_a]palettegen=max_colors=256[palette];[gif_b][palette]paletteuse=dither=sierra2_4a',
      '-loop',
      '$loop',
      request.output.path,
    ];
  }

  String _audioFilter(ExportRequest request, List<AudioClip> clips) {
    final List<String> filters = <String>[];
    final List<String> labels = <String>[];
    for (var index = 0; index < clips.length; index++) {
      final AudioClip clip = clips[index];
      final double duration = clip.durationMilliseconds / 1000;
      final String label = 'clip_$index';
      final List<String> chain = <String>[
        '[${index + 1}:a]atrim=start=${clip.trimStartMilliseconds / 1000}:end=${clip.trimEndMilliseconds / 1000}',
        'asetpts=PTS-STARTPTS',
        'adelay=delays=${clip.startMilliseconds}:all=1',
        'volume=${clip.volume}',
        if (clip.fadeInMilliseconds > 0)
          'afade=t=in:st=0:d=${clip.fadeInMilliseconds / 1000}',
        if (clip.fadeOutMilliseconds > 0)
          'afade=t=out:st=${duration - clip.fadeOutMilliseconds / 1000}:d=${clip.fadeOutMilliseconds / 1000}',
      ];
      filters.add('${chain.join(',')}[$label]');
      labels.add('[$label]');
    }
    filters.add(
      '${labels.join()}amix=inputs=${labels.length}:duration=longest:normalize=0,'
      'volume=${request.audio.masterVolume},'
      'atrim=duration=${_seconds(request.timeline.duration)}[audio_out]',
    );
    return filters.join(';');
  }

  Future<File> _writeConcat(ExportRequest request, List<File> frames) async {
    final StringBuffer content = StringBuffer();
    for (var index = 0; index < frames.length; index++) {
      content
        ..writeln("file '${_escapeConcat(frames[index].path)}'")
        ..writeln(
          'duration ${request.timeline.frames[index].holdFrames / request.timeline.fps}',
        );
    }
    if (frames.isNotEmpty) {
      content.writeln("file '${_escapeConcat(frames.last.path)}'");
    }
    final File file = File(
      p.join(request.temporaryDirectory.path, 'frames.txt'),
    );
    await file.writeAsString(content.toString(), flush: true);
    return file;
  }

  String _escapeConcat(String value) => value.replaceAll("'", "'\\''");
  String _seconds(Duration duration) =>
      (duration.inMicroseconds / Duration.microsecondsPerSecond)
          .toStringAsFixed(6);
}
