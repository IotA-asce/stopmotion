import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/atomic_file_store.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/capture/data/capture_repository.dart';
import 'package:stop_motion/features/capture/domain/capture_frame.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/data/project_thumbnail_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  late AppDatabase database;
  late Directory root;
  late ProjectPaths paths;
  late ProjectRepository projects;
  late CaptureRepository captures;
  late Project project;

  CaptureRepository createCaptureRepository(
    AppDatabase database,
    ProjectPaths paths, {
    AtomicFileStore fileStore = const AtomicFileStore(),
  }) => CaptureRepository(
    database: database,
    paths: paths,
    journal: OperationJournalRepository(database),
    thumbnails: ProjectThumbnailRepository(paths),
    fileStore: fileStore,
    now: () => DateTime.utc(2026, 7, 14),
  );

  setUp(() async {
    database = AppDatabase.memory();
    root = await Directory.systemTemp.createTemp('capture_repository_');
    paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
    );
    captures = createCaptureRepository(database, paths);
    project = await projects.createProject(
      ProjectDraft(
        title: 'Film',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 12,
        backgroundColorValue: 0,
      ),
    );
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  Future<File> source(String name, {int width = 32, int height = 24}) async {
    final File file = File('${root.path}/$name.jpg');
    return file.writeAsBytes(
      image.encodeJpg(image.Image(width: width, height: height)),
    );
  }

  test('accepts, verifies, commits, and thumbnails a frame', () async {
    final File cameraSource = await source('camera');

    final ProjectFrame frame = await captures.acceptFrame(
      projectId: project.id,
      source: CaptureSource(file: cameraSource, deleteAfterAccept: true),
    );

    final File accepted = paths.resolveRelativeFile(frame.relativeSourcePath);
    expect(await cameraSource.exists(), isFalse);
    expect(await accepted.exists(), isTrue);
    expect(frame.position, 0);
    expect(frame.sourceWidth, 32);
    expect((await captures.getFrames(project.id)).single.id, frame.id);
    expect(await ProjectThumbnailRepository(paths).read(project.id), isNotNull);
    expect(
      (await database.select(database.operationJournals).get()).single.state,
      'complete',
    );
  });

  test('rejects damaged input without a row or final file', () async {
    final File damaged = await File(
      '${root.path}/damaged.jpg',
    ).writeAsBytes(<int>[1, 2, 3]);

    await expectLater(
      captures.acceptFrame(
        projectId: project.id,
        source: CaptureSource(file: damaged),
      ),
      throwsFormatException,
    );

    expect(await damaged.exists(), isTrue);
    expect(await captures.getFrames(project.id), isEmpty);
    expect(await paths.framesDirectory(project.id).list().isEmpty, isTrue);
  });

  test(
    'rename interruption preserves source and removes final output',
    () async {
      final File cameraSource = await source('rename_failure');
      final CaptureRepository failing = createCaptureRepository(
        database,
        paths,
        fileStore: AtomicFileStore(
          onPoint: (FileAcceptancePoint point) async {
            if (point == FileAcceptancePoint.afterRename) {
              throw FileSystemException('Injected rename interruption.');
            }
          },
        ),
      );

      await expectLater(
        failing.acceptFrame(
          projectId: project.id,
          source: CaptureSource(file: cameraSource, deleteAfterAccept: true),
        ),
        throwsA(isA<FileSystemException>()),
      );

      expect(await cameraSource.exists(), isTrue);
      expect(await captures.getFrames(project.id), isEmpty);
      expect(await paths.framesDirectory(project.id).list().isEmpty, isTrue);
    },
  );

  test(
    'database failure rolls accepted file back without deleting source',
    () async {
      final File cameraSource = await source('database_failure');

      await expectLater(
        captures.acceptFrame(
          projectId: 'missing-project',
          source: CaptureSource(file: cameraSource, deleteAfterAccept: true),
        ),
        throwsA(isA<Exception>()),
      );

      expect(await cameraSource.exists(), isTrue);
      expect(await database.select(database.frameRecords).get(), isEmpty);
      expect(
        await paths.framesDirectory('missing-project').list().isEmpty,
        isTrue,
      );
    },
  );

  test(
    'retake, duplicate, delete, and undo preserve immutable media',
    () async {
      final ProjectFrame first = await captures.acceptFrame(
        projectId: project.id,
        source: CaptureSource(file: await source('first')),
      );
      await captures.acceptFrame(
        projectId: project.id,
        source: CaptureSource(file: await source('second')),
      );
      final String originalPath = first.relativeSourcePath;

      final ProjectFrame retaken = await captures.retakeFrame(
        projectId: project.id,
        frameId: first.id,
        source: CaptureSource(
          file: await source('retake', width: 48, height: 36),
        ),
      );
      expect(retaken.relativeSourcePath, isNot(originalPath));
      expect(await paths.resolveRelativeFile(originalPath).exists(), isTrue);

      final ProjectFrame duplicate = await captures.duplicateFrame(
        project.id,
        first.id,
      );
      expect(duplicate.relativeSourcePath, retaken.relativeSourcePath);
      expect(duplicate.position, 2);

      final DeletedFrame deleted = await captures.deleteFrame(
        project.id,
        first.id,
      );
      expect(
        (await captures.getFrames(
          project.id,
        )).map((ProjectFrame f) => f.position),
        <int>[0, 1],
      );
      await captures.restoreDeletedFrame(deleted);
      final List<ProjectFrame> restored = await captures.getFrames(project.id);
      expect(restored.map((ProjectFrame f) => f.position), <int>[0, 1, 2]);
      expect(restored.first.id, first.id);
    },
  );
}
