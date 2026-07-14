import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stop_motion/core/media/frame_renderer.dart';
import 'package:stop_motion/features/editor/domain/frame_adjustments.dart';

void main() {
  test(
    'renders deterministic bounded output without changing source bytes',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'frame_renderer_',
      );
      final File source = File('${root.path}/source.png');
      final img.Image fixture = img.Image(width: 1200, height: 800);
      for (final img.Pixel pixel in fixture) {
        pixel
          ..r = (pixel.x * 255 ~/ fixture.width)
          ..g = (pixel.y * 255 ~/ fixture.height)
          ..b = 96;
      }
      await source.writeAsBytes(img.encodePng(fixture));
      final Uint8List before = await source.readAsBytes();
      const FrameRenderer renderer = FrameRenderer();
      const FrameAdjustments adjustments = FrameAdjustments(
        crop: NormalizedCrop(left: 0.1, top: 0.1, right: 0.9, bottom: 0.9),
        straighten: 3,
        quarterTurns: 1,
        flipHorizontal: true,
        fit: FrameFit.fill,
        exposure: -0.5,
        contrast: 0.2,
        highlights: -0.2,
        shadows: 0.3,
        temperature: 0.2,
        tint: -0.1,
        saturation: 0.3,
        sharpening: 0.4,
      );
      final RenderedFrame first = await renderer.render(
        source: source,
        adjustments: adjustments,
        targetWidth: 320,
        targetHeight: 180,
        backgroundColor: 0xff000000,
      );
      final RenderedFrame second = await renderer.render(
        source: source,
        adjustments: adjustments,
        targetWidth: 320,
        targetHeight: 180,
        backgroundColor: 0xff000000,
      );

      expect(first.width, 320);
      expect(first.height, 180);
      expect(first.bytes, orderedEquals(second.bytes));
      expect(await source.readAsBytes(), orderedEquals(before));
      expect(img.decodeImage(first.bytes), isNotNull);

      await root.delete(recursive: true);
    },
  );

  test('fit preserves background and cache stays within byte budget', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'frame_cache_',
    );
    final File source = File('${root.path}/source.png');
    final img.Image fixture = img.Image(width: 100, height: 300)
      ..clear(img.ColorRgb8(255, 0, 0));
    await source.writeAsBytes(img.encodePng(fixture));
    final FramePreviewCache cache = FramePreviewCache(maximumBytes: 30000);
    final RenderedFrame fitted = await cache.read(
      source: source,
      adjustments: const FrameAdjustments(),
      targetWidth: 320,
      targetHeight: 180,
      backgroundColor: 0xff00ff00,
    );
    final img.Image decoded = img.decodeJpg(fitted.bytes)!;
    final img.Pixel corner = decoded.getPixel(0, 0);
    expect(corner.g, greaterThan(corner.r));
    for (var index = 0; index < 8; index++) {
      await cache.read(
        source: source,
        adjustments: FrameAdjustments(exposure: index / 10),
        targetWidth: 320,
        targetHeight: 180,
        backgroundColor: 0xff000000,
      );
    }
    expect(cache.bytesUsed, lessThanOrEqualTo(cache.maximumBytes));
    expect(cache.entryCount, lessThan(8));

    await root.delete(recursive: true);
  });
}
