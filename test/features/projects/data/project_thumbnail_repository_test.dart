import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/features/projects/data/project_thumbnail_repository.dart';

void main() {
  late Directory root;
  late ProjectThumbnailRepository repository;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('project_thumbnail_');
    repository = ProjectThumbnailRepository(
      ProjectPaths(
        root: Directory('${root.path}/support'),
        cacheRoot: Directory('${root.path}/cache'),
      ),
    );
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('generates a bounded disposable JPEG thumbnail', () async {
    final image.Image sourceImage = image.Image(width: 1200, height: 800);
    final File source = await File(
      '${root.path}/source.png',
    ).writeAsBytes(image.encodePng(sourceImage));

    final File thumbnail = await repository.generate('project', source);
    final image.Image? decoded = image.decodeJpg(await thumbnail.readAsBytes());

    expect(decoded, isNotNull);
    expect(decoded!.width, 640);
    expect(decoded.height, 427);
    expect((await repository.read('project'))?.path, thumbnail.path);

    await repository.clear('project');
    expect(await repository.read('project'), isNull);
  });

  test('invalid replacement leaves the last valid thumbnail intact', () async {
    final File valid = await File(
      '${root.path}/valid.png',
    ).writeAsBytes(image.encodePng(image.Image(width: 10, height: 10)));
    final File invalid = await File(
      '${root.path}/invalid.jpg',
    ).writeAsBytes(<int>[1, 2, 3]);
    final File first = await repository.generate('project', valid);
    final List<int> originalBytes = await first.readAsBytes();

    await expectLater(
      repository.generate('project', invalid),
      throwsFormatException,
    );

    expect(await first.readAsBytes(), originalBytes);
  });
}
