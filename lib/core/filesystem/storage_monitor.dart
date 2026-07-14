import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../features/projects/data/project_repository.dart';
import '../../features/projects/domain/project.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import 'project_paths.dart';

abstract interface class AvailableStorageReader {
  Future<int?> availableBytes(Directory directory);
}

class PlatformAvailableStorageReader implements AvailableStorageReader {
  const PlatformAvailableStorageReader({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('stop_motion/storage');

  final MethodChannel _channel;

  @override
  Future<int?> availableBytes(Directory directory) async {
    try {
      return await _channel.invokeMethod<int>(
        'availableStorageBytes',
        <String, Object?>{'path': directory.path},
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class StorageSummary {
  const StorageSummary({
    required this.projectMediaBytes,
    required this.exportBytes,
    required this.cacheBytes,
    required this.trashBytes,
    required this.availableBytes,
    required this.expiredTrashCount,
  });

  static const int lowSpaceThresholdBytes = 512 * 1024 * 1024;

  final int projectMediaBytes;
  final int exportBytes;
  final int cacheBytes;
  final int trashBytes;
  final int? availableBytes;
  final int expiredTrashCount;

  int get knownBytes =>
      projectMediaBytes + exportBytes + cacheBytes + trashBytes;

  bool get lowSpace =>
      availableBytes != null && availableBytes! < lowSpaceThresholdBytes;
}

class StorageMonitor {
  factory StorageMonitor({
    required AppDatabase database,
    required ProjectPaths paths,
    required ProjectRepository projects,
    AvailableStorageReader? availableStorage,
    DateTime Function()? now,
    Duration trashRetention = const Duration(days: 7),
  }) => StorageMonitor._(
    database,
    paths,
    projects,
    availableStorage ?? const PlatformAvailableStorageReader(),
    now ?? _utcNow,
    trashRetention,
  );

  StorageMonitor._(
    this._database,
    this._paths,
    this._projects,
    this._availableStorage,
    this._now,
    this.trashRetention,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final ProjectRepository _projects;
  final AvailableStorageReader _availableStorage;
  final DateTime Function() _now;
  final Duration trashRetention;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Future<StorageSummary> inspect() async {
    final List<ProjectRecord> rows = await _database
        .select(_database.projectRecords)
        .get();
    var projectMediaBytes = 0;
    var trashBytes = 0;
    var expiredTrashCount = 0;
    final DateTime expiresBefore = _now().subtract(trashRetention);
    for (final ProjectRecord row in rows) {
      final int size = await _directoryBytes(_paths.projectDirectory(row.id));
      if (row.deletedAt == null) {
        projectMediaBytes += size;
      } else {
        trashBytes += size;
        if (row.deletedAt!.isBefore(expiresBefore)) {
          expiredTrashCount++;
        }
      }
    }
    return StorageSummary(
      projectMediaBytes: projectMediaBytes,
      exportBytes: await _directoryBytes(_paths.exportsRoot),
      cacheBytes: await _directoryBytes(_paths.cacheRoot),
      trashBytes: trashBytes,
      availableBytes: await _availableStorage.availableBytes(_paths.root),
      expiredTrashCount: expiredTrashCount,
    );
  }

  Future<void> clearCache() async {
    if (await _paths.cacheRoot.exists()) {
      await _paths.cacheRoot.delete(recursive: true);
    }
    await _paths.cacheRoot.create(recursive: true);
  }

  Future<List<Project>> expiredTrash() async {
    final DateTime expiresBefore = _now().subtract(trashRetention);
    final List<ProjectRecord> rows =
        await (_database.select(_database.projectRecords)..where(
              (ProjectRecords table) =>
                  table.deletedAt.isNotNull() &
                  table.deletedAt.isSmallerThanValue(expiresBefore),
            ))
            .get();
    final List<Project> projects = <Project>[];
    for (final ProjectRecord row in rows) {
      final Project? project = await _projects.getProject(row.id);
      if (project != null) projects.add(project);
    }
    return projects;
  }

  Future<void> emptyExpiredTrash() async {
    for (final Project project in await expiredTrash()) {
      await _projects.permanentlyDelete(project.id);
    }
  }

  Future<void> emptyTrash() async {
    final List<ProjectRecord> rows = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.deletedAt.isNotNull())).get();
    for (final ProjectRecord row in rows) {
      await _projects.permanentlyDelete(row.id);
    }
  }

  Future<int> _directoryBytes(Directory directory) async {
    if (!await directory.exists()) return 0;
    var bytes = 0;
    await for (final FileSystemEntity entity in directory.list(
      recursive: true,
    )) {
      if (entity is File) bytes += await entity.length();
    }
    return bytes;
  }
}
