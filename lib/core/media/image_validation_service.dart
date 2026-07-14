import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

class ValidatedImage {
  const ValidatedImage({required this.width, required this.height});

  final int width;
  final int height;
}

class ImageValidationService {
  const ImageValidationService();

  Future<ValidatedImage> inspect(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    return Isolate.run(() => _inspect(bytes));
  }

  Future<ValidatedImage> normalizeOrientation(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final _NormalizedImage normalized = await Isolate.run(
      () => _normalize(bytes),
    );
    final RandomAccessFile output = await file.open(mode: FileMode.write);
    await output.writeFrom(normalized.bytes);
    await output.truncate(normalized.bytes.length);
    await output.flush();
    await output.close();
    return ValidatedImage(width: normalized.width, height: normalized.height);
  }
}

ValidatedImage _inspect(Uint8List bytes) {
  try {
    final image.Image? decoded = image.decodeImage(bytes);
    if (decoded == null || decoded.width < 1 || decoded.height < 1) {
      throw const FormatException('Image is empty or unsupported.');
    }
    return ValidatedImage(width: decoded.width, height: decoded.height);
  } on FormatException {
    rethrow;
  } on Object {
    throw const FormatException('Image is damaged or unsupported.');
  }
}

_NormalizedImage _normalize(Uint8List bytes) {
  try {
    final image.Image? decoded = image.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Image is damaged or unsupported.');
    }
    final image.Image oriented = image.bakeOrientation(decoded);
    return _NormalizedImage(
      bytes: image.encodeJpg(oriented, quality: 95),
      width: oriented.width,
      height: oriented.height,
    );
  } on FormatException {
    rethrow;
  } on Object {
    throw const FormatException('Image is damaged or unsupported.');
  }
}

class _NormalizedImage {
  const _NormalizedImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}
