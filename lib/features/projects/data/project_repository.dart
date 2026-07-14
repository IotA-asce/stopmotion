import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/filesystem/project_paths.dart';
import '../../../core/recovery/operation.dart';
import '../../../core/recovery/operation_journal.dart';
import '../domain/project.dart';

enum ProjectFaultPoint { afterCreateDirectory, afterDuplicateMedia }

typedef ProjectFaultHook = Future<void> Function(ProjectFaultPoint point);

class ProjectRepository {
  ProjectRepository({
    required AppDatabase database,
    required ProjectPaths paths,
    required OperationJournalRepository journal,
    Uuid? uuid,
    DateTime Function()? now,
    ProjectFaultHook? onFaultPoint,
  }) : this._(
         database,
         paths,
         journal,
         uuid ?? const Uuid(),
         now ?? _utcNow,
         onFaultPoint,
       );

  ProjectRepository._(
    this._database,
    this._paths,
    this._journal,
    this._uuid,
    this._now,
    this._onFaultPoint,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final OperationJournalRepository _journal;
  final Uuid _uuid;
  final DateTime Function() _now;
  final ProjectFaultHook? _onFaultPoint;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Stream<List<Project>> watchProjects({
    ProjectSort sort = ProjectSort.lastEdited,
    ProjectFilter filter = ProjectFilter.all,
    String queryText = '',
  }) {
    final SimpleSelectStatement<ProjectRecords, ProjectRecord> query =
        _database.select(_database.projectRecords)
          ..where((ProjectRecords table) {
            Expression<bool> predicate = table.deletedAt.isNull();
            if (filter == ProjectFilter.draft) {
              predicate =
                  predicate & table.status.equals(ProjectStatus.draft.name);
            } else if (filter == ProjectFilter.exported) {
              predicate =
                  predicate & table.status.equals(ProjectStatus.exported.name);
            }
            final String normalized = queryText.trim();
            if (normalized.isNotEmpty) {
              predicate = predicate & table.title.contains(normalized);
            }
            return predicate;
          });

    query.orderBy(<OrderingTerm Function(ProjectRecords)>[
      switch (sort) {
        ProjectSort.lastEdited => (ProjectRecords table) => OrderingTerm.desc(
          table.updatedAt,
        ),
        ProjectSort.dateCreated => (ProjectRecords table) => OrderingTerm.desc(
          table.createdAt,
        ),
        ProjectSort.title => (ProjectRecords table) => OrderingTerm.asc(
          table.title,
        ),
        ProjectSort.duration => (ProjectRecords table) => OrderingTerm.desc(
          table.updatedAt,
        ),
      },
    ]);

    return query.watch().asyncMap((List<ProjectRecord> rows) async {
      final List<Project> projects = await Future.wait(rows.map(_mapProject));
      if (sort == ProjectSort.duration) {
        projects.sort(
          (Project a, Project b) =>
              b.durationFrames.compareTo(a.durationFrames),
        );
      }
      return projects;
    });
  }

  Stream<List<Project>> watchTrashedProjects() {
    final SimpleSelectStatement<ProjectRecords, ProjectRecord> query =
        _database.select(_database.projectRecords)
          ..where((ProjectRecords table) => table.deletedAt.isNotNull())
          ..orderBy(<OrderingTerm Function(ProjectRecords)>[
            (ProjectRecords table) => OrderingTerm.desc(table.deletedAt),
          ]);
    return query.watch().asyncMap(
      (List<ProjectRecord> rows) => Future.wait(rows.map(_mapProject)),
    );
  }

  Future<Project?> getProject(String id) async {
    final ProjectRecord? row = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapProject(row);
  }

  Future<String> nextUntitledName() async {
    final List<ProjectRecord> rows =
        await (_database.select(_database.projectRecords)..where(
              (ProjectRecords table) => table.title.like('Untitled film%'),
            ))
            .get();
    final Set<String> titles = rows
        .map((ProjectRecord row) => row.title)
        .toSet();
    var index = 1;
    while (titles.contains('Untitled film $index')) {
      index++;
    }
    return 'Untitled film $index';
  }

  Future<Project> createProject(ProjectDraft draft) async {
    final String id = _uuid.v4();
    final DateTime now = _now();
    try {
      await _paths.ensureProject(id);
      await _onFaultPoint?.call(ProjectFaultPoint.afterCreateDirectory);
      await _database
          .into(_database.projectRecords)
          .insert(
            ProjectRecordsCompanion.insert(
              id: id,
              title: draft.title,
              aspectRatio: draft.aspectRatio.storedValue,
              resolution: draft.resolution.storedValue,
              framesPerSecond: draft.framesPerSecond,
              backgroundColor: draft.backgroundColorValue,
              createdAt: now,
              updatedAt: now,
              status: ProjectStatus.draft.name,
            ),
          );
    } on Object {
      final Directory directory = _paths.projectDirectory(id);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
      rethrow;
    }
    return (await getProject(id))!;
  }

  Future<void> renameProject(String id, String title) async {
    final String normalized = title.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Project title cannot be empty.');
    }
    await (_database.update(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(id))).write(
      ProjectRecordsCompanion(
        title: Value<String>(normalized),
        updatedAt: Value<DateTime>(_now()),
      ),
    );
  }

  Future<Project> duplicateProject(String sourceId) async {
    final ProjectRecord source = await (_database.select(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(sourceId))).getSingle();
    final String destinationId = _uuid.v4();
    final String journalId = await _journal.begin(
      type: OperationType.duplicateProject,
      projectId: sourceId,
      destinationProjectId: destinationId,
    );
    final Directory destination = _paths.projectDirectory(destinationId);

    try {
      await _paths.ensureProject(destinationId);
      await _copyProjectMedia(sourceId, destinationId);
      await _onFaultPoint?.call(ProjectFaultPoint.afterDuplicateMedia);
      final DateTime now = _now();
      await _database.transaction(() async {
        await _database
            .into(_database.projectRecords)
            .insert(
              ProjectRecordsCompanion.insert(
                id: destinationId,
                title: '${source.title} copy',
                aspectRatio: source.aspectRatio,
                resolution: source.resolution,
                framesPerSecond: source.framesPerSecond,
                backgroundColor: source.backgroundColor,
                createdAt: now,
                updatedAt: now,
                status: ProjectStatus.draft.name,
                currentRevision: Value<int>(source.currentRevision),
              ),
            );

        final List<FrameRecord> frames =
            await (_database.select(_database.frameRecords)..where(
                  (FrameRecords table) => table.projectId.equals(sourceId),
                ))
                .get();
        for (final FrameRecord frame in frames) {
          await _database
              .into(_database.frameRecords)
              .insert(
                FrameRecordsCompanion.insert(
                  id: _uuid.v4(),
                  projectId: destinationId,
                  relativeSourcePath: _replaceProjectInPath(
                    frame.relativeSourcePath,
                    sourceId,
                    destinationId,
                  ),
                  position: frame.position,
                  holdFrames: Value<int>(frame.holdFrames),
                  createdAt: now,
                  sourceWidth: frame.sourceWidth,
                  sourceHeight: frame.sourceHeight,
                  missing: Value<bool>(frame.missing),
                ),
              );
        }

        final List<AudioClipRecord> audioClips =
            await (_database.select(_database.audioClipRecords)..where(
                  (AudioClipRecords table) => table.projectId.equals(sourceId),
                ))
                .get();
        for (final AudioClipRecord clip in audioClips) {
          await _database
              .into(_database.audioClipRecords)
              .insert(
                AudioClipRecordsCompanion.insert(
                  id: _uuid.v4(),
                  projectId: destinationId,
                  relativeSourcePath: _replaceProjectInPath(
                    clip.relativeSourcePath,
                    sourceId,
                    destinationId,
                  ),
                  name: clip.name,
                  trackType: clip.trackType,
                  startMilliseconds: clip.startMilliseconds,
                  trimStartMilliseconds: clip.trimStartMilliseconds,
                  trimEndMilliseconds: clip.trimEndMilliseconds,
                  volume: Value<double>(clip.volume),
                  fadeInMilliseconds: Value<int>(clip.fadeInMilliseconds),
                  fadeOutMilliseconds: Value<int>(clip.fadeOutMilliseconds),
                  muted: Value<bool>(clip.muted),
                ),
              );
        }
      });
      await _journal.setState(journalId, OperationState.complete);
      return (await getProject(destinationId))!;
    } on Object catch (error) {
      if (await destination.exists()) {
        await destination.delete(recursive: true);
      }
      await _journal.setState(
        journalId,
        OperationState.failed,
        errorCode: error.runtimeType.toString(),
      );
      rethrow;
    }
  }

  Future<void> moveToTrash(String id) async {
    await (_database.update(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(id))).write(
      ProjectRecordsCompanion(
        deletedAt: Value<DateTime?>(_now()),
        updatedAt: Value<DateTime>(_now()),
      ),
    );
  }

  Future<void> restoreFromTrash(String id) async {
    await (_database.update(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(id))).write(
      ProjectRecordsCompanion(
        deletedAt: const Value<DateTime?>(null),
        updatedAt: Value<DateTime>(_now()),
      ),
    );
  }

  Future<void> permanentlyDelete(String id) async {
    final String journalId = await _journal.begin(
      type: OperationType.deleteProject,
      projectId: id,
    );
    await (_database.delete(
      _database.projectRecords,
    )..where((ProjectRecords table) => table.id.equals(id))).go();
    final Directory directory = _paths.projectDirectory(id);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    final Directory thumbnails = _paths.thumbnailDirectory(id);
    if (await thumbnails.exists()) {
      await thumbnails.delete(recursive: true);
    }
    await _journal.setState(journalId, OperationState.complete);
  }

  Future<int> projectSize(String id) async {
    final Directory directory = _paths.projectDirectory(id);
    if (!await directory.exists()) {
      return 0;
    }
    var bytes = 0;
    await for (final FileSystemEntity entity in directory.list(
      recursive: true,
    )) {
      if (entity is File) {
        bytes += await entity.length();
      }
    }
    return bytes;
  }

  Future<Project> _mapProject(ProjectRecord row) async {
    final Expression<int> count = _database.frameRecords.id.count();
    final Expression<int> duration = _database.frameRecords.holdFrames.sum();
    final JoinedSelectStatement<HasResultSet, dynamic> frameSummary =
        _database.selectOnly(_database.frameRecords)
          ..addColumns(<Expression<Object>>[count, duration])
          ..where(_database.frameRecords.projectId.equals(row.id));
    final TypedResult summary = await frameSummary.getSingle();
    return Project(
      id: row.id,
      title: row.title,
      aspectRatio: ProjectAspectRatio.values.byName(row.aspectRatio),
      resolution: ProjectResolution.values.byName(row.resolution),
      framesPerSecond: row.framesPerSecond,
      backgroundColorValue: row.backgroundColor,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      status: ProjectStatus.values.byName(row.status),
      frameCount: summary.read(count) ?? 0,
      durationFrames: summary.read(duration) ?? 0,
      currentRevision: row.currentRevision,
      lastExportedRevision: row.lastExportedRevision,
      deletedAt: row.deletedAt,
    );
  }

  Future<void> _copyProjectMedia(String sourceId, String destinationId) async {
    for (final Directory source in <Directory>[
      _paths.framesDirectory(sourceId),
      _paths.audioDirectory(sourceId),
    ]) {
      if (!await source.exists()) {
        continue;
      }
      await for (final FileSystemEntity entity in source.list(
        recursive: true,
      )) {
        if (entity is! File) {
          continue;
        }
        final String relative = p.relative(
          entity.path,
          from: _paths.projectDirectory(sourceId).path,
        );
        final File output = File(
          p.join(_paths.projectDirectory(destinationId).path, relative),
        );
        await output.parent.create(recursive: true);
        await entity.copy(output.path);
      }
    }
  }

  String _replaceProjectInPath(
    String relativePath,
    String sourceId,
    String destinationId,
  ) {
    final List<String> parts = p.split(relativePath).toList();
    final int index = parts.indexOf(sourceId);
    if (index >= 0) {
      parts[index] = destinationId;
    }
    return p.joinAll(parts);
  }
}
