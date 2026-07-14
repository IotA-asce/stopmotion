import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/database/tables.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  late AppDatabase database;
  late Directory root;
  late ProjectPaths paths;
  late ProjectRepository repository;

  setUp(() async {
    database = AppDatabase.memory();
    root = await Directory.systemTemp.createTemp('project_repository_');
    paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    repository = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
      now: () => DateTime.utc(2026, 7, 14),
    );
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  ProjectDraft draft(String title) => ProjectDraft(
    title: title,
    aspectRatio: ProjectAspectRatio.widescreen,
    resolution: ProjectResolution.fullHd1080,
    framesPerSecond: 12,
    backgroundColorValue: 0xFF000000,
  );

  test('creates, renames, trashes, and restores a durable project', () async {
    final Project created = await repository.createProject(draft('Film'));

    expect(await paths.framesDirectory(created.id).exists(), isTrue);
    expect((await repository.watchProjects().first).single.title, 'Film');

    await repository.renameProject(created.id, 'Renamed');
    expect((await repository.getProject(created.id))!.title, 'Renamed');

    await repository.moveToTrash(created.id);
    expect(await repository.watchProjects().first, isEmpty);

    await repository.restoreFromTrash(created.id);
    expect((await repository.watchProjects().first).single.id, created.id);
  });

  test('duplicates media and frame records independently', () async {
    final Project source = await repository.createProject(draft('Film'));
    final File sourceFile = File(
      '${paths.framesDirectory(source.id).path}/one.jpg',
    );
    await sourceFile.writeAsBytes(<int>[4, 5, 6]);
    await database
        .into(database.frameRecords)
        .insert(
          FrameRecordsCompanion.insert(
            id: 'frame',
            projectId: source.id,
            relativeSourcePath: paths.relativeToRoot(sourceFile),
            position: 0,
            createdAt: DateTime.utc(2026, 7, 14),
            sourceWidth: 100,
            sourceHeight: 100,
          ),
        );
    final File sourceAudio = await File(
      '${paths.audioDirectory(source.id).path}/narration.m4a',
    ).writeAsBytes(<int>[10, 11]);
    await database
        .into(database.audioClipRecords)
        .insert(
          AudioClipRecordsCompanion.insert(
            id: 'audio',
            projectId: source.id,
            relativeSourcePath: paths.relativeToRoot(sourceAudio),
            name: 'Narration',
            trackType: 'narration',
            startMilliseconds: 0,
            trimStartMilliseconds: 0,
            trimEndMilliseconds: 2000,
          ),
        );

    final Project duplicate = await repository.duplicateProject(source.id);
    final FrameRecord duplicatedFrame =
        await (database.select(database.frameRecords)..where(
              (FrameRecords table) => table.projectId.equals(duplicate.id),
            ))
            .getSingle();
    final File duplicatedFile = paths.resolveRelativeFile(
      duplicatedFrame.relativeSourcePath,
    );

    expect(await duplicatedFile.readAsBytes(), <int>[4, 5, 6]);
    await duplicatedFile.writeAsBytes(<int>[9]);
    expect(await sourceFile.readAsBytes(), <int>[4, 5, 6]);
    final AudioClipRecord duplicatedAudio =
        await (database.select(database.audioClipRecords)..where(
              (AudioClipRecords table) => table.projectId.equals(duplicate.id),
            ))
            .getSingle();
    expect(duplicatedAudio.name, 'Narration');
    expect(
      await paths
          .resolveRelativeFile(duplicatedAudio.relativeSourcePath)
          .readAsBytes(),
      <int>[10, 11],
    );
  });

  test('project metadata survives closing and reopening SQLite', () async {
    final File databaseFile = File('${root.path}/persistent.sqlite');
    final AppDatabase firstDatabase = AppDatabase.open(databaseFile);
    final ProjectRepository firstRepository = ProjectRepository(
      database: firstDatabase,
      paths: paths,
      journal: OperationJournalRepository(firstDatabase),
    );
    final Project created = await firstRepository.createProject(
      draft('Persistent film'),
    );
    await firstDatabase.close();

    final AppDatabase reopenedDatabase = AppDatabase.open(databaseFile);
    final ProjectRepository reopenedRepository = ProjectRepository(
      database: reopenedDatabase,
      paths: paths,
      journal: OperationJournalRepository(reopenedDatabase),
    );
    final Project? reopened = await reopenedRepository.getProject(created.id);

    expect(reopened?.title, 'Persistent film');
    expect(reopened?.framesPerSecond, 12);
    await reopenedDatabase.close();
  });

  test('create interruption leaves no phantom project or directory', () async {
    final ProjectRepository failingRepository = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
      onFaultPoint: (ProjectFaultPoint point) async {
        if (point == ProjectFaultPoint.afterCreateDirectory) {
          throw FileSystemException('Injected interruption.');
        }
      },
    );

    await expectLater(
      failingRepository.createProject(draft('Interrupted')),
      throwsA(isA<FileSystemException>()),
    );

    expect(await database.select(database.projectRecords).get(), isEmpty);
    expect(
      await paths.projectsRoot
          .list()
          .where((FileSystemEntity entity) => entity is Directory)
          .isEmpty,
      isTrue,
    );
  });

  test('duplicate interruption preserves the only valid source copy', () async {
    final Project source = await repository.createProject(draft('Original'));
    final File sourceFile = await File(
      '${paths.framesDirectory(source.id).path}/source.jpg',
    ).writeAsBytes(<int>[7, 8, 9]);
    final ProjectRepository failingRepository = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
      onFaultPoint: (ProjectFaultPoint point) async {
        if (point == ProjectFaultPoint.afterDuplicateMedia) {
          throw FileSystemException('Injected interruption.');
        }
      },
    );

    await expectLater(
      failingRepository.duplicateProject(source.id),
      throwsA(isA<FileSystemException>()),
    );

    expect(await sourceFile.readAsBytes(), <int>[7, 8, 9]);
    expect((await repository.watchProjects().first).single.id, source.id);
  });

  test('permanent delete removes metadata, media, and cache', () async {
    final Project project = await repository.createProject(draft('Delete me'));
    await File(
      '${paths.framesDirectory(project.id).path}/frame.jpg',
    ).writeAsBytes(<int>[1]);
    await paths.thumbnailDirectory(project.id).create(recursive: true);
    await File(
      '${paths.thumbnailDirectory(project.id).path}/latest.jpg',
    ).writeAsBytes(<int>[2]);

    await repository.moveToTrash(project.id);
    expect(
      (await repository.watchTrashedProjects().first).single.id,
      project.id,
    );
    await repository.permanentlyDelete(project.id);

    expect(await repository.getProject(project.id), isNull);
    expect(await paths.projectDirectory(project.id).exists(), isFalse);
    expect(await paths.thumbnailDirectory(project.id).exists(), isFalse);
  });
}
