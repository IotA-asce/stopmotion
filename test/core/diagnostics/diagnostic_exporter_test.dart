import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/diagnostics/app_logger.dart';
import 'package:stop_motion/core/diagnostics/diagnostic_exporter.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';

void main() {
  late Directory root;
  late ProjectPaths paths;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('stop_motion_diagnostics_');
    paths = ProjectPaths(
      root: Directory('${root.path}/data'),
      cacheRoot: Directory('${root.path}/cache'),
    );
  });

  tearDown(() => root.delete(recursive: true));

  test('logger redacts user content and keeps a bounded rolling log', () async {
    final AppLogger logger = AppLogger(paths: paths, maxEntries: 2);
    await logger.log(
      category: 'capture',
      action: 'accepted',
      operationId: 'operation-1',
      attributes: <String, Object?>{
        'projectTitle': 'Private Puppet Film',
        'sourcePath': '/Users/example/Private Puppet Film/frame.jpg',
        'count': 1,
      },
    );
    await logger.log(category: 'export', action: 'started');
    await logger.log(category: 'export', action: 'completed');

    final String source = await File(
      '${paths.diagnosticsDirectory.path}/events.jsonl',
    ).readAsString();
    expect(source, isNot(contains('Private Puppet Film')));
    expect(source, isNot(contains('/Users/example')));
    expect((await logger.read()).length, 2);
  });

  test(
    'diagnostic archive excludes project media, titles, and private paths',
    () async {
      final AppDatabase database = AppDatabase.memory();
      addTearDown(database.close);
      final AppLogger logger = AppLogger(paths: paths);
      await logger.log(
        category: 'recovery',
        action: 'scan',
        attributes: <String, Object?>{
          'title': 'Secret Animation',
          'path': '/private/var/mobile/frames/frame.jpg',
          'status': 'complete',
        },
      );
      final DiagnosticExporter exporter = DiagnosticExporter(
        database: database,
        paths: paths,
        logger: logger,
        environment: const DiagnosticEnvironment(
          appVersion: '0.1.0',
          buildNumber: '1',
          platform: 'test',
          platformVersion: 'test-platform',
          capabilities: <String, Object?>{'camera': false},
        ),
        now: () => DateTime.utc(2026, 7, 15),
      );

      final File archiveFile = await exporter.create();
      final Archive archive = ZipDecoder().decodeBytes(
        await archiveFile.readAsBytes(),
      );
      final ArchiveFile diagnostics = archive.files.singleWhere(
        (ArchiveFile file) => file.name == 'diagnostics.json',
      );
      final String diagnosticsText = utf8.decode(
        diagnostics.content as List<int>,
      );

      expect(
        archive.files.map((ArchiveFile file) => file.name),
        containsAll(<String>['diagnostics.json', 'licenses.txt']),
      );
      expect(diagnosticsText, contains('databaseSchemaVersion'));
      expect(diagnosticsText, isNot(contains('Secret Animation')));
      expect(diagnosticsText, isNot(contains('/private/var')));
      expect(diagnosticsText, isNot(contains('frame.jpg')));
    },
  );
}
