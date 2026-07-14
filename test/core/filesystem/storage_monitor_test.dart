import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/filesystem/storage_monitor.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';

void main() {
  late Directory root;
  late AppDatabase database;
  late ProjectPaths paths;
  late StorageMonitor monitor;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('stop_motion_storage_');
    paths = ProjectPaths(
      root: Directory('${root.path}/data'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    database = AppDatabase.memory();
    final ProjectRepository projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: OperationJournalRepository(database),
      now: () => DateTime.utc(2026, 7, 15),
    );
    monitor = StorageMonitor(
      database: database,
      paths: paths,
      projects: projects,
      availableStorage: const _FakeStorageReader(100),
      now: () => DateTime.utc(2026, 7, 15),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  Future<void> insertProject(String id, {DateTime? deletedAt}) => database
      .into(database.projectRecords)
      .insert(
        ProjectRecordsCompanion.insert(
          id: id,
          title: id,
          aspectRatio: 'widescreen',
          resolution: 'fullHd1080',
          framesPerSecond: 12,
          backgroundColor: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          deletedAt: Value<DateTime?>(deletedAt),
          status: 'draft',
        ),
      );

  test(
    'reports source, export, cache, trash, and low-space categories',
    () async {
      await insertProject('active');
      await insertProject('trashed', deletedAt: DateTime.utc(2026, 7, 1));
      await _write('${paths.framesDirectory('active').path}/frame.jpg', 11);
      await _write('${paths.framesDirectory('trashed').path}/frame.jpg', 13);
      await _write('${paths.exportsRoot.path}/active/output.mp4', 17);
      await _write('${paths.cacheRoot.path}/thumbnails/active/image.jpg', 19);

      final StorageSummary summary = await monitor.inspect();

      expect(summary.projectMediaBytes, 11);
      expect(summary.trashBytes, 13);
      expect(summary.exportBytes, 17);
      expect(summary.cacheBytes, 19);
      expect(summary.lowSpace, isTrue);
      expect(summary.expiredTrashCount, 1);
    },
  );

  test(
    'clearing cache preserves project-owned source media and exports',
    () async {
      await _write('${paths.framesDirectory('active').path}/frame.jpg', 11);
      await _write('${paths.exportsRoot.path}/active/output.mp4', 17);
      await _write('${paths.cacheRoot.path}/thumbnails/active/image.jpg', 19);

      await monitor.clearCache();

      expect(
        await File(
          '${paths.framesDirectory('active').path}/frame.jpg',
        ).exists(),
        isTrue,
      );
      expect(
        await File('${paths.exportsRoot.path}/active/output.mp4').exists(),
        isTrue,
      );
      expect(await paths.cacheRoot.list().isEmpty, isTrue);
    },
  );
}

class _FakeStorageReader implements AvailableStorageReader {
  const _FakeStorageReader(this.bytes);

  final int bytes;

  @override
  Future<int?> availableBytes(Directory directory) async => bytes;
}

Future<void> _write(String path, int bytes) async {
  final File file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(List<int>.filled(bytes, 1));
}
