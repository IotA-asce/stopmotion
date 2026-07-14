import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/filesystem/atomic_file_store.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('atomic_file_store_');
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('accepts and verifies a source using atomic rename', () async {
    final File source = await File(
      '${root.path}/source.jpg',
    ).writeAsBytes(<int>[1, 2, 3], flush: true);
    final File temporary = File('${root.path}/project/.tmp/frame.tmp');
    final File destination = File('${root.path}/project/frames/frame.jpg');

    final File accepted = await const AtomicFileStore().accept(
      source: source,
      temporary: temporary,
      destination: destination,
    );

    expect(await accepted.readAsBytes(), <int>[1, 2, 3]);
    expect(await temporary.exists(), isFalse);
  });

  test('cleans temporary output when validation fails', () async {
    final File source = await File(
      '${root.path}/source.jpg',
    ).writeAsBytes(<int>[1]);
    final File temporary = File('${root.path}/project/.tmp/frame.tmp');
    final File destination = File('${root.path}/project/frames/frame.jpg');

    await expectLater(
      AtomicFileStore(
        validator: (File file) async => false,
      ).accept(source: source, temporary: temporary, destination: destination),
      throwsFormatException,
    );

    expect(await temporary.exists(), isFalse);
    expect(await destination.exists(), isFalse);
  });

  test('fault after copy leaves no accepted or temporary file', () async {
    final File source = await File(
      '${root.path}/source.jpg',
    ).writeAsBytes(<int>[1, 2, 3]);
    final File temporary = File('${root.path}/project/.tmp/frame.tmp');
    final File destination = File('${root.path}/project/frames/frame.jpg');

    await expectLater(
      AtomicFileStore(
        onPoint: (FileAcceptancePoint point) async {
          if (point == FileAcceptancePoint.afterCopy) {
            throw FileSystemException('Injected copy interruption.');
          }
        },
      ).accept(source: source, temporary: temporary, destination: destination),
      throwsA(isA<FileSystemException>()),
    );

    expect(await source.readAsBytes(), <int>[1, 2, 3]);
    expect(await temporary.exists(), isFalse);
    expect(await destination.exists(), isFalse);
  });
}
