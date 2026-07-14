import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/capture/data/capture_repository.dart';
import 'package:stop_motion/features/capture/domain/capture_frame.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/data/project_thumbnail_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  test(
    'captured and imported files survive database close and relaunch',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'capture_persistence_',
      );
      final ProjectPaths paths = ProjectPaths(
        root: Directory('${root.path}/support'),
        cacheRoot: Directory('${root.path}/cache'),
      );
      final AppDatabase firstDatabase = AppDatabase.open(paths.databaseFile);
      final OperationJournalRepository firstJournal =
          OperationJournalRepository(firstDatabase);
      final ProjectRepository projectRepository = ProjectRepository(
        database: firstDatabase,
        paths: paths,
        journal: firstJournal,
      );
      final Project project = await projectRepository.createProject(
        ProjectDraft(
          title: 'Persistent capture',
          aspectRatio: ProjectAspectRatio.widescreen,
          resolution: ProjectResolution.fullHd1080,
          framesPerSecond: 12,
          backgroundColorValue: 0,
        ),
      );
      final CaptureRepository firstCaptures = CaptureRepository(
        database: firstDatabase,
        paths: paths,
        journal: firstJournal,
        thumbnails: ProjectThumbnailRepository(paths),
      );
      final File cameraSource = await _source(root, 'camera', 24);
      final File pickerSource = await _source(root, 'picker', 36);
      await firstCaptures.acceptFrame(
        projectId: project.id,
        source: CaptureSource(file: cameraSource, deleteAfterAccept: true),
      );
      await firstCaptures.acceptFrame(
        projectId: project.id,
        source: CaptureSource(file: pickerSource),
        operationType: OperationType.import,
      );
      await firstDatabase.close();

      final AppDatabase reopened = AppDatabase.open(paths.databaseFile);
      final CaptureRepository reopenedCaptures = CaptureRepository(
        database: reopened,
        paths: paths,
        journal: OperationJournalRepository(reopened),
        thumbnails: ProjectThumbnailRepository(paths),
      );
      final List<ProjectFrame> frames = await reopenedCaptures.getFrames(
        project.id,
      );

      expect(frames.map((ProjectFrame frame) => frame.position), <int>[0, 1]);
      expect(frames.map((ProjectFrame frame) => frame.sourceWidth), <int>[
        24,
        36,
      ]);
      for (final ProjectFrame frame in frames) {
        final File owned = paths.resolveRelativeFile(frame.relativeSourcePath);
        expect(await owned.exists(), isTrue);
        expect(await owned.length(), greaterThan(0));
      }
      expect(await cameraSource.exists(), isFalse);
      expect(await pickerSource.exists(), isTrue);

      await reopened.close();
      await root.delete(recursive: true);
    },
  );
}

Future<File> _source(Directory root, String name, int width) => File(
  '${root.path}/$name.jpg',
).writeAsBytes(image.encodeJpg(image.Image(width: width, height: 18)));
