import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../../../core/filesystem/project_paths.dart';

class ProjectThumbnailRepository {
  const ProjectThumbnailRepository(this._paths);

  final ProjectPaths _paths;

  File thumbnailFile(String projectId) =>
      File('${_paths.thumbnailDirectory(projectId).path}/latest.jpg');

  Future<File?> read(String projectId) async {
    final File file = thumbnailFile(projectId);
    if (!await file.exists() || await file.length() == 0) {
      return null;
    }
    return file;
  }

  Future<File> generate(String projectId, File source) async {
    if (!await source.exists()) {
      throw FileSystemException(
        'Thumbnail source does not exist.',
        source.path,
      );
    }
    final Uint8List sourceBytes = await source.readAsBytes();
    final Uint8List thumbnailBytes = await Isolate.run(
      () => _createThumbnail(sourceBytes),
    );
    final File destination = thumbnailFile(projectId);
    final File temporary = File('${destination.path}.tmp');
    final File backup = File('${destination.path}.bak');
    await destination.parent.create(recursive: true);

    try {
      final RandomAccessFile output = await temporary.open(
        mode: FileMode.write,
      );
      await output.writeFrom(thumbnailBytes);
      await output.flush();
      await output.close();
      if (await destination.exists()) {
        if (await backup.exists()) {
          await backup.delete();
        }
        await destination.rename(backup.path);
      }
      final File accepted = await temporary.rename(destination.path);
      if (await accepted.length() == 0) {
        throw const FormatException('Generated thumbnail is empty.');
      }
      if (await backup.exists()) {
        await backup.delete();
      }
      return accepted;
    } on Object {
      if (await temporary.exists()) {
        await temporary.delete();
      }
      if (!await destination.exists() && await backup.exists()) {
        await backup.rename(destination.path);
      }
      rethrow;
    }
  }

  Future<void> clear(String projectId) async {
    final Directory directory = _paths.thumbnailDirectory(projectId);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

Uint8List _createThumbnail(Uint8List bytes) {
  image.Image? decoded;
  try {
    decoded = image.decodeImage(bytes);
  } on Object {
    throw const FormatException('Unsupported or damaged image.');
  }
  if (decoded == null) {
    throw const FormatException('Unsupported or damaged image.');
  }
  decoded = image.bakeOrientation(decoded);
  final image.Image resized = decoded.width > decoded.height
      ? image.copyResize(decoded, width: 640)
      : image.copyResize(decoded, height: 640);
  return image.encodeJpg(resized, quality: 82);
}
