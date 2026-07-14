import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/core/media/export_engine.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';
import 'package:stop_motion/features/audio/data/audio_repository.dart';
import 'package:stop_motion/features/editor/data/editor_repository.dart';
import 'package:stop_motion/features/export/data/export_repository.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';
import 'package:stop_motion/features/projects/data/project_repository.dart';

class _WritingEngine implements ExportEngine {
  @override
  Future<ExportResult> export(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  }) async {
    await request.output.parent.create(recursive: true);
    await request.output.writeAsBytes(<int>[1, 2, 3, 4]);
    onProgress(
      const ExportProgress(
        stage: ExportStage.validating,
        fraction: 1,
        elapsed: Duration(milliseconds: 1),
      ),
    );
    return ExportResult(
      output: request.output,
      bytes: 4,
      duration: request.timeline.duration,
    );
  }

  @override
  Future<bool> isAvailable() async => true;
}

void main() {
  late AppDatabase database;
  late Directory root;
  late ProjectPaths paths;
  late ExportRepository repository;

  setUp(() async {
    database = AppDatabase.memory();
    root = await Directory.systemTemp.createTemp('export_repository_');
    paths = ProjectPaths(
      root: root,
      cacheRoot: Directory('${root.path}_cache'),
    );
    final OperationJournalRepository journal = OperationJournalRepository(
      database,
    );
    final ProjectRepository projects = ProjectRepository(
      database: database,
      paths: paths,
      journal: journal,
    );
    final File source = File(
      p.join(root.path, 'projects/project-1/frames/frame-1.jpg'),
    );
    await source.parent.create(recursive: true);
    await source.writeAsBytes(<int>[1]);
    final DateTime now = DateTime.utc(2026, 7, 15);
    await database
        .into(database.projectRecords)
        .insert(
          ProjectRecordsCompanion.insert(
            id: 'project-1',
            title: 'Paper planets',
            aspectRatio: 'widescreen',
            resolution: 'hd720',
            framesPerSecond: 12,
            backgroundColor: 0xff202020,
            createdAt: now,
            updatedAt: now,
            status: 'draft',
            currentRevision: const Value<int>(4),
          ),
        );
    await database
        .into(database.frameRecords)
        .insert(
          FrameRecordsCompanion.insert(
            id: 'frame-1',
            projectId: 'project-1',
            relativeSourcePath: 'projects/project-1/frames/frame-1.jpg',
            position: 0,
            holdFrames: const Value<int>(3),
            createdAt: now,
            sourceWidth: 24,
            sourceHeight: 16,
          ),
        );
    final _WritingEngine engine = _WritingEngine();
    repository = ExportRepository(
      database: database,
      paths: paths,
      projects: projects,
      editor: EditorRepository(database: database),
      audio: AudioRepository(
        database: database,
        paths: paths,
        journal: journal,
      ),
      journal: journal,
      preflight: const ExportPreflightService(),
      engines: <ExportFormat, ExportEngine>{
        for (final ExportFormat format in ExportFormat.values) format: engine,
      },
    );
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) await root.delete(recursive: true);
    if (await paths.cacheRoot.exists()) {
      await paths.cacheRoot.delete(recursive: true);
    }
  });

  test(
    'successful job records settings, output, history, and revision',
    () async {
      final ExportRequest request = await repository.createRequest(
        'project-1',
        const ExportSettings(format: ExportFormat.movie),
        id: 'export-1',
      );

      await repository.run(
        request,
        cancellation: ExportCancellationToken(),
        onProgress: (_) {},
      );
      final ProjectExportRecord record =
          (await repository.watchHistory('project-1').first).single;
      final ProjectRecord project = await database
          .select(database.projectRecords)
          .getSingle();

      expect(record.status, ExportStatus.complete);
      expect(record.outputBytes, 4);
      expect(record.revision, 4);
      expect(
        ExportSettings.decode(record.settingsJson).format,
        ExportFormat.movie,
      );
      expect(project.lastExportedRevision, 4);
      expect(project.status, 'exported');
      expect(await request.output.exists(), isTrue);
    },
  );

  test('latest successful settings are reused', () async {
    final ExportRequest request = await repository.createRequest(
      'project-1',
      const ExportSettings(format: ExportFormat.gif, gifMaximumDimension: 320),
      id: 'export-2',
    );
    await repository.run(
      request,
      cancellation: ExportCancellationToken(),
      onProgress: (_) {},
    );

    final ExportSettings? previous = await repository
        .previousSuccessfulSettings('project-1');

    expect(previous?.format, ExportFormat.gif);
    expect(previous?.gifMaximumDimension, 320);
  });
}
