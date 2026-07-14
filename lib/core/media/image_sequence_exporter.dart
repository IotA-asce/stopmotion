import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../../features/export/domain/export_job.dart';
import '../../features/export/domain/export_record.dart';
import 'export_engine.dart';
import 'export_frame_renderer.dart';

class ImageSequenceExporter implements ExportEngine {
  const ImageSequenceExporter({
    ExportFrameRenderer frameRenderer = const ExportFrameRenderer(),
  }) : this._(frameRenderer);

  const ImageSequenceExporter._(this._frameRenderer);

  final ExportFrameRenderer _frameRenderer;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ExportResult> export(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  }) async {
    if (request.settings.format != ExportFormat.imageSequence) {
      throw ArgumentError('ImageSequenceExporter requires imageSequence.');
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    final ExportDimensions dimensions = ExportDimensions.forProject(
      request.project,
      request.settings,
    );
    final String extension =
        request.settings.imageSequenceFormat == ImageSequenceFormat.png
        ? 'png'
        : 'jpg';
    final ZipFileEncoder encoder = ZipFileEncoder();
    var opened = false;
    try {
      await request.temporaryDirectory.create(recursive: true);
      await request.output.parent.create(recursive: true);
      encoder.create(request.output.path);
      opened = true;
      for (var index = 0; index < request.timeline.frames.length; index++) {
        cancellation.throwIfCancelled();
        final File frame = await _frameRenderer.renderFrame(
          request: request,
          frame: request.timeline.frames[index],
          dimensions: dimensions,
          extension: extension,
          index: index,
        );
        await encoder.addFile(frame, p.basename(frame.path));
        await frame.delete();
        onProgress(
          ExportProgress(
            stage: ExportStage.packaging,
            fraction: (index + 1) / request.timeline.frames.length * 0.95,
            elapsed: stopwatch.elapsed,
          ),
        );
      }
      encoder.addArchiveFile(
        ArchiveFile.string(
          'manifest.json',
          const JsonEncoder.withIndent('  ').convert(<String, Object?>{
            'schemaVersion': 1,
            'projectTitle': request.project.title,
            'fps': request.timeline.fps,
            'exportFps':
                request.settings.framesPerSecond ?? request.timeline.fps,
            'width': dimensions.width,
            'height': dimensions.height,
            'format': extension == 'png' ? 'PNG' : 'JPEG',
            'transparentBackground':
                request.settings.transparentBackground && extension == 'png',
            'frames': <Map<String, Object>>[
              for (
                var index = 0;
                index < request.timeline.frames.length;
                index++
              )
                <String, Object>{
                  'file':
                      'frame_${index.toString().padLeft(6, '0')}.$extension',
                  'holdFrames': request.timeline.frames[index].holdFrames,
                },
            ],
          }),
        ),
      );
      await encoder.close();
      opened = false;
      cancellation.throwIfCancelled();
      final InputFileStream input = InputFileStream(request.output.path);
      try {
        final Archive archive = ZipDecoder().decodeStream(input);
        final List<String> names = archive.files
            .map((ArchiveFile file) => file.name)
            .toList(growable: false);
        final int frameEntries = names.where((String name) {
          return name.startsWith('frame_') && name.endsWith('.$extension');
        }).length;
        if (frameEntries != request.timeline.frames.length ||
            !names.contains('manifest.json')) {
          throw StateError('Image-sequence archive validation failed.');
        }
      } finally {
        await input.close();
      }
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
      if (opened) {
        try {
          await encoder.close();
        } on Object {
          // The incomplete archive is removed below.
        }
      }
      if (await request.output.exists()) await request.output.delete();
      rethrow;
    } finally {
      if (await request.temporaryDirectory.exists()) {
        await request.temporaryDirectory.delete(recursive: true);
      }
    }
  }
}
