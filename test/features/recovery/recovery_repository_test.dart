import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/recovery/operation.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/recovery/data/recovery_repository.dart';
import 'package:stop_motion/features/recovery/domain/recovery_report.dart';

void main() {
  late Directory root;
  late AppDatabase database;
  late ProjectPaths paths;
  late OperationJournalRepository journal;
  late RecoveryRepository recovery;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('stop_motion_recovery_');
    paths = ProjectPaths(
      root: Directory('${root.path}/data'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    database = AppDatabase.memory();
    journal = OperationJournalRepository(database);
    recovery = RecoveryRepository(
      database: database,
      paths: paths,
      journal: journal,
      now: () => DateTime.utc(2026, 7, 15),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  Future<void> insertProject(String id) => database
      .into(database.projectRecords)
      .insert(
        ProjectRecordsCompanion.insert(
          id: id,
          title: 'Film $id',
          aspectRatio: 'widescreen',
          resolution: 'fullHd1080',
          framesPerSecond: 12,
          backgroundColor: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          status: 'draft',
        ),
      );

  test(
    'removes abandoned temporary media without touching a valid final file',
    () async {
      await insertProject('project');
      final File temporary = File(
        '${paths.temporaryDirectory('project').path}/capture.tmp',
      );
      await temporary.parent.create(recursive: true);
      await temporary.writeAsString('temporary');
      final File finalFile = File(
        '${paths.framesDirectory('project').path}/capture.jpg',
      );
      await finalFile.parent.create(recursive: true);
      await finalFile.writeAsString('verified frame');
      await journal.begin(
        type: OperationType.capture,
        projectId: 'project',
        temporaryPath: paths.relativeToRoot(temporary),
        finalPath: paths.relativeToRoot(finalFile),
      );

      final RecoveryReport report = await recovery.scan();

      expect(report.items.single.kind, RecoveryIssueKind.orphanedMedia);
      expect(await finalFile.exists(), isTrue);
      expect(await temporary.exists(), isTrue);
    },
  );

  test(
    'cleans an abandoned temporary file with no valid destination',
    () async {
      await insertProject('project');
      final File temporary = File(
        '${paths.temporaryDirectory('project').path}/capture.tmp',
      );
      await temporary.parent.create(recursive: true);
      await temporary.writeAsString('temporary');
      await journal.begin(
        type: OperationType.capture,
        projectId: 'project',
        temporaryPath: paths.relativeToRoot(temporary),
        finalPath: 'projects/project/frames/capture.jpg',
      );

      expect((await recovery.scan()).items, isEmpty);
      expect(await temporary.exists(), isFalse);
      expect(await journal.listIncomplete(), isEmpty);
    },
  );

  test(
    'repairs an interrupted duplicate from retained project-owned media',
    () async {
      await insertProject('source');
      await database
          .into(database.frameRecords)
          .insert(
            FrameRecordsCompanion.insert(
              id: 'frame',
              projectId: 'source',
              relativeSourcePath: 'projects/source/frames/frame.jpg',
              position: 0,
              createdAt: DateTime.utc(2026),
              sourceWidth: 100,
              sourceHeight: 100,
            ),
          );
      final File copied = File(
        '${paths.framesDirectory('destination').path}/frame.jpg',
      );
      await copied.parent.create(recursive: true);
      await copied.writeAsString('image');
      final File source = File(
        '${paths.framesDirectory('source').path}/frame.jpg',
      );
      await source.parent.create(recursive: true);
      await source.writeAsString('image');
      await journal.begin(
        type: OperationType.duplicateProject,
        projectId: 'source',
        destinationProjectId: 'destination',
      );

      expect(
        (await recovery.scan()).items.single.kind,
        RecoveryIssueKind.interruptedDuplicate,
      );
      expect((await recovery.repair()).items, isEmpty);
      expect(
        await (database.select(
          database.projectRecords,
        )..where((table) => table.id.equals('destination'))).getSingleOrNull(),
        isNotNull,
      );
    },
  );

  test(
    'removes partial export output and marks the journal recovered',
    () async {
      await insertProject('project');
      final File output = File(
        '${paths.exportDirectory('project').path}/export-1.mp4',
      );
      await output.parent.create(recursive: true);
      await output.writeAsString('partial-output');
      final Directory temporary = Directory(
        '${paths.exportTemporaryDirectory('project').path}/export-1',
      );
      await temporary.create(recursive: true);
      await File('${temporary.path}/frame.jpg').writeAsString('partial');
      await database
          .into(database.exportRecords)
          .insert(
            ExportRecordsCompanion.insert(
              id: 'export-1',
              projectId: 'project',
              format: 'movie',
              status: 'pending',
              revision: 0,
              createdAt: DateTime.utc(2026),
            ),
          );
      await journal.begin(
        type: OperationType.export,
        projectId: 'project',
        temporaryPath: temporary.path,
        finalPath: output.path,
      );

      expect((await recovery.scan()).items, isEmpty);
      expect(await output.exists(), isFalse);
      expect(await temporary.exists(), isFalse);
      final ExportRecord row = await (database.select(
        database.exportRecords,
      )..where((table) => table.id.equals('export-1'))).getSingle();
      expect(row.status, 'cancelled');
    },
  );

  test(
    'flags missing sources and removes only missing database entries on demand',
    () async {
      await insertProject('project');
      await database
          .into(database.frameRecords)
          .insert(
            FrameRecordsCompanion.insert(
              id: 'missing',
              projectId: 'project',
              relativeSourcePath: 'projects/project/frames/missing.jpg',
              position: 0,
              createdAt: DateTime.utc(2026),
              sourceWidth: 100,
              sourceHeight: 100,
            ),
          );

      final RecoveryReport report = await recovery.scan();
      expect(report.items.single.missingFrameCount, 1);
      expect((await recovery.removeMissingItems()).items, isEmpty);
      expect(await database.select(database.frameRecords).get(), isEmpty);
    },
  );

  test(
    'requires confirmation repair to finish an interrupted permanent delete',
    () async {
      final Directory project = paths.projectDirectory('deleted-project');
      await project.create(recursive: true);
      await File('${project.path}/source.jpg').writeAsString('source');
      await journal.begin(
        type: OperationType.deleteProject,
        projectId: 'deleted-project',
      );

      expect(
        (await recovery.scan()).items.single.kind,
        RecoveryIssueKind.interruptedDelete,
      );
      expect(await project.exists(), isTrue);
      expect((await recovery.repair()).items, isEmpty);
      expect(await project.exists(), isFalse);
    },
  );
}
