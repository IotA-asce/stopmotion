import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../features/editor/domain/frame_adjustments.dart';

class RenderedFrame {
  const RenderedFrame({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

class FrameRenderer {
  const FrameRenderer();

  Future<RenderedFrame> render({
    required File source,
    required FrameAdjustments adjustments,
    required int targetWidth,
    required int targetHeight,
    required int backgroundColor,
  }) async {
    if (targetWidth < 1 || targetHeight < 1) {
      throw ArgumentError('Render dimensions must be positive.');
    }
    final Uint8List sourceBytes = await source.readAsBytes();
    img.Image? image = img.decodeImage(sourceBytes);
    if (image == null) {
      throw const FormatException('Frame source is not a supported image.');
    }

    image = _crop(image, adjustments.crop);
    image = _boundWorkingImage(image, targetWidth, targetHeight);
    final num rotation = adjustments.quarterTurns * 90 + adjustments.straighten;
    if (rotation != 0) {
      image = img.copyRotate(image, angle: rotation);
    }
    if (adjustments.flipHorizontal) {
      image = img.copyFlip(image, direction: img.FlipDirection.horizontal);
    }
    if (adjustments.flipVertical) {
      image = img.copyFlip(image, direction: img.FlipDirection.vertical);
    }
    image = _color(image, adjustments);
    if (adjustments.sharpening > 0) {
      image = img.convolution(
        image,
        filter: const <num>[0, -1, 0, -1, 5, -1, 0, -1, 0],
        amount: adjustments.sharpening,
      );
    }
    final img.Image fitted = adjustments.fit == FrameFit.fill
        ? _fill(image, targetWidth, targetHeight)
        : _fit(image, targetWidth, targetHeight, backgroundColor);
    return RenderedFrame(
      bytes: Uint8List.fromList(img.encodeJpg(fitted, quality: 90)),
      width: fitted.width,
      height: fitted.height,
    );
  }

  img.Image _crop(img.Image source, NormalizedCrop crop) {
    if (crop.isFull) {
      return source;
    }
    final int x = (crop.left * source.width).round().clamp(0, source.width - 1);
    final int y = (crop.top * source.height).round().clamp(
      0,
      source.height - 1,
    );
    final int width = ((crop.right - crop.left) * source.width).round().clamp(
      1,
      source.width - x,
    );
    final int height = ((crop.bottom - crop.top) * source.height).round().clamp(
      1,
      source.height - y,
    );
    return img.copyCrop(source, x: x, y: y, width: width, height: height);
  }

  img.Image _boundWorkingImage(img.Image source, int width, int height) {
    final int bound = math.max(width, height) * 2;
    final int longest = math.max(source.width, source.height);
    if (longest <= bound) {
      return source;
    }
    final double scale = bound / longest;
    return img.copyResize(
      source,
      width: math.max(1, (source.width * scale).round()),
      height: math.max(1, (source.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
  }

  img.Image _color(img.Image source, FrameAdjustments value) {
    if (value.exposure == 0 &&
        value.contrast == 0 &&
        value.highlights == 0 &&
        value.shadows == 0 &&
        value.temperature == 0 &&
        value.tint == 0 &&
        value.saturation == 0) {
      return source;
    }
    img.Image result = img.adjustColor(
      source,
      contrast: 1 + value.contrast,
      saturation: 1 + value.saturation,
      exposure: value.exposure > 0 ? value.exposure : null,
      brightness: value.exposure < 0 ? math.pow(2, value.exposure) : null,
    );
    if (value.highlights == 0 &&
        value.shadows == 0 &&
        value.temperature == 0 &&
        value.tint == 0) {
      return result;
    }
    if (result.hasPalette) {
      result = result.convert(numChannels: 3);
    }
    for (final img.Pixel pixel in result) {
      double r = pixel.rNormalized.toDouble();
      double g = pixel.gNormalized.toDouble();
      double b = pixel.bNormalized.toDouble();
      final double luminance = (r * 0.2126) + (g * 0.7152) + (b * 0.0722);
      final double highlightWeight = ((luminance - 0.5) * 2).clamp(0, 1);
      final double shadowWeight = ((0.5 - luminance) * 2).clamp(0, 1);
      final double highlightDelta = value.highlights * highlightWeight * 0.35;
      final double shadowDelta = value.shadows * shadowWeight * 0.35;
      r +=
          highlightDelta +
          shadowDelta +
          value.temperature * 0.08 +
          value.tint * 0.03;
      g += highlightDelta + shadowDelta + value.tint * 0.06;
      b +=
          highlightDelta +
          shadowDelta -
          value.temperature * 0.08 +
          value.tint * 0.03;
      pixel
        ..rNormalized = r.clamp(0, 1)
        ..gNormalized = g.clamp(0, 1)
        ..bNormalized = b.clamp(0, 1);
    }
    return result;
  }

  img.Image _fill(img.Image source, int width, int height) {
    final double scale = math.max(width / source.width, height / source.height);
    final img.Image resized = img.copyResize(
      source,
      width: math.max(width, (source.width * scale).round()),
      height: math.max(height, (source.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
    return img.copyCrop(
      resized,
      x: (resized.width - width) ~/ 2,
      y: (resized.height - height) ~/ 2,
      width: width,
      height: height,
    );
  }

  img.Image _fit(img.Image source, int width, int height, int color) {
    final double scale = math.min(width / source.width, height / source.height);
    final img.Image resized = img.copyResize(
      source,
      width: math.max(1, (source.width * scale).round()),
      height: math.max(1, (source.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
    final img.Image canvas = img.Image(
      width: width,
      height: height,
      numChannels: 3,
    );
    img.fill(
      canvas,
      color: img.ColorRgb8(
        (color >> 16) & 0xff,
        (color >> 8) & 0xff,
        color & 0xff,
      ),
    );
    img.compositeImage(
      canvas,
      resized,
      dstX: (width - resized.width) ~/ 2,
      dstY: (height - resized.height) ~/ 2,
    );
    return canvas;
  }
}

class FramePreviewCache {
  FramePreviewCache({
    FrameRenderer renderer = const FrameRenderer(),
    int maximumBytes = 24 * 1024 * 1024,
  }) : this._(renderer, maximumBytes);

  FramePreviewCache._(this._renderer, this.maximumBytes);

  final FrameRenderer _renderer;
  final int maximumBytes;
  final LinkedHashMap<String, RenderedFrame> _entries =
      LinkedHashMap<String, RenderedFrame>();
  int _bytes = 0;

  int get bytesUsed => _bytes;
  int get entryCount => _entries.length;

  Future<RenderedFrame> read({
    required File source,
    required FrameAdjustments adjustments,
    required int targetWidth,
    required int targetHeight,
    required int backgroundColor,
  }) async {
    final FileStat stat = await source.stat();
    final String key =
        '${source.path}|${stat.modified.microsecondsSinceEpoch}|'
        '${stat.size}|${adjustments.cacheKey}|$targetWidth|$targetHeight|$backgroundColor';
    final RenderedFrame? cached = _entries.remove(key);
    if (cached != null) {
      _entries[key] = cached;
      return cached;
    }
    final RenderedFrame rendered = await _renderer.render(
      source: source,
      adjustments: adjustments,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      backgroundColor: backgroundColor,
    );
    _entries[key] = rendered;
    _bytes += rendered.bytes.length;
    while (_bytes > maximumBytes && _entries.length > 1) {
      final String oldest = _entries.keys.first;
      _bytes -= _entries.remove(oldest)!.bytes.length;
    }
    return rendered;
  }

  void clear() {
    _entries.clear();
    _bytes = 0;
  }
}
