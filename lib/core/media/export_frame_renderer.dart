import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../features/editor/domain/frame.dart';
import '../../features/export/domain/export_job.dart';
import 'frame_renderer.dart';

class ExportFrameRenderer {
  const ExportFrameRenderer({FrameRenderer renderer = const FrameRenderer()})
    : this._(renderer);

  const ExportFrameRenderer._(this._renderer);

  final FrameRenderer _renderer;

  Future<File> renderFrame({
    required ExportRequest request,
    required ProjectFrame frame,
    required ExportDimensions dimensions,
    required String extension,
    required int index,
  }) async {
    final File source = File(
      p.join(request.projectRoot.path, frame.relativeSourcePath),
    );
    final RenderedFrame rendered = await _renderer.render(
      source: source,
      adjustments: frame.adjustments,
      targetWidth: dimensions.width,
      targetHeight: dimensions.height,
      backgroundColor: request.project.backgroundColorValue,
    );
    final String name = 'frame_${index.toString().padLeft(6, '0')}.$extension';
    final File output = File(p.join(request.temporaryDirectory.path, name));
    await output.parent.create(recursive: true);
    if (extension == 'jpg') {
      await output.writeAsBytes(rendered.bytes, flush: true);
    } else {
      final img.Image? decoded = img.decodeJpg(rendered.bytes);
      if (decoded == null) {
        throw const FormatException('Rendered frame could not be decoded.');
      }
      await output.writeAsBytes(img.encodePng(decoded), flush: true);
    }
    return output;
  }
}
