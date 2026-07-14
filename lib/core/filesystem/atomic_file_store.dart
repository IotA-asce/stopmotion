import 'dart:io';

typedef FileValidator = Future<bool> Function(File file);
typedef FileTransformer = Future<void> Function(File file);
typedef FileAcceptanceHook = Future<void> Function(FileAcceptancePoint point);

enum FileAcceptancePoint { beforeCopy, afterCopy, afterValidation, afterRename }

class AtomicFileStore {
  const AtomicFileStore({this.validator, this.transformer, this.onPoint});

  final FileValidator? validator;
  final FileTransformer? transformer;
  final FileAcceptanceHook? onPoint;

  Future<File> accept({
    required File source,
    required File temporary,
    required File destination,
    FileValidator? validate,
    FileTransformer? transform,
  }) async {
    if (!await source.exists()) {
      throw FileSystemException('Source file does not exist.', source.path);
    }
    if (await destination.exists()) {
      throw FileSystemException(
        'Destination already exists.',
        destination.path,
      );
    }

    await temporary.parent.create(recursive: true);
    await destination.parent.create(recursive: true);

    try {
      await onPoint?.call(FileAcceptancePoint.beforeCopy);
      final File copied = await source.copy(temporary.path);
      await onPoint?.call(FileAcceptancePoint.afterCopy);
      final RandomAccessFile handle = await copied.open(mode: FileMode.append);
      await handle.flush();
      await handle.close();

      if (await copied.length() == 0) {
        throw const FormatException('Media file is empty.');
      }
      final FileValidator? activeValidator = validate ?? validator;
      final FileTransformer? activeTransformer = transform ?? transformer;
      if (activeValidator != null && !await activeValidator(copied)) {
        throw const FormatException('Media file validation failed.');
      }
      await activeTransformer?.call(copied);
      if (activeValidator != null && !await activeValidator(copied)) {
        throw const FormatException('Transformed media validation failed.');
      }
      await onPoint?.call(FileAcceptancePoint.afterValidation);

      final File accepted = await copied.rename(destination.path);
      await onPoint?.call(FileAcceptancePoint.afterRename);
      if (!await accepted.exists() || await accepted.length() == 0) {
        throw FileSystemException(
          'Accepted file could not be verified.',
          accepted.path,
        );
      }
      return accepted;
    } on Object {
      if (await temporary.exists()) {
        await temporary.delete();
      }
      if (await destination.exists()) {
        await destination.delete();
      }
      rethrow;
    }
  }
}
