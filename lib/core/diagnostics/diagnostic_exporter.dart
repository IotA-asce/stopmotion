import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import '../filesystem/project_paths.dart';
import 'app_logger.dart';

class DiagnosticEnvironment {
  const DiagnosticEnvironment({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.platformVersion,
    required this.capabilities,
  });

  factory DiagnosticEnvironment.current() => DiagnosticEnvironment(
    appVersion: '0.1.0',
    buildNumber: '1',
    platform: Platform.operatingSystem,
    platformVersion: Platform.operatingSystemVersion,
    capabilities: <String, Object?>{'filesystem': true, 'methodChannels': true},
  );

  final String appVersion;
  final String buildNumber;
  final String platform;
  final String platformVersion;
  final Map<String, Object?> capabilities;

  Map<String, Object?> toJson() => <String, Object?>{
    'appVersion': appVersion,
    'buildNumber': buildNumber,
    'platform': platform,
    'platformVersion': platformVersion,
    'capabilities': capabilities,
  };
}

class DiagnosticExporter {
  factory DiagnosticExporter({
    required AppDatabase database,
    required ProjectPaths paths,
    required AppLogger logger,
    DiagnosticEnvironment? environment,
    DateTime Function()? now,
  }) => DiagnosticExporter._(
    database,
    paths,
    logger,
    environment ?? DiagnosticEnvironment.current(),
    now ?? _utcNow,
  );

  DiagnosticExporter._(
    this._database,
    this._paths,
    this._logger,
    this._environment,
    this._now,
  );

  final AppDatabase _database;
  final ProjectPaths _paths;
  final AppLogger _logger;
  final DiagnosticEnvironment _environment;
  final DateTime Function() _now;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Future<File> create() async {
    await _paths.diagnosticsDirectory.create(recursive: true);
    final File output = File(
      p.join(
        _paths.diagnosticsDirectory.path,
        'stop-motion-diagnostics-${_now().millisecondsSinceEpoch}.zip',
      ),
    );
    final ZipFileEncoder encoder = ZipFileEncoder();
    var opened = false;
    try {
      encoder.create(output.path);
      opened = true;
      encoder.addArchiveFile(
        ArchiveFile.string(
          'diagnostics.json',
          const JsonEncoder.withIndent('  ').convert(<String, Object?>{
            'schemaVersion': 1,
            'databaseSchemaVersion': _database.schemaVersion,
            'environment': _environment.toJson(),
            'logs': await _logger.read(),
          }),
        ),
      );
      encoder.addArchiveFile(ArchiveFile.string('licenses.txt', _licenses));
      await encoder.close();
      opened = false;
      await _logger.log(
        category: 'diagnostics',
        action: 'exported',
        attributes: <String, Object?>{'schemaVersion': _database.schemaVersion},
      );
      return output;
    } on Object {
      if (opened) {
        try {
          await encoder.close();
        } on Object {
          // The partial archive is removed below.
        }
      }
      if (await output.exists()) await output.delete();
      rethrow;
    }
  }
}

const String _licenses = '''
Stop Motion dependency notice

Flutter framework: BSD 3-Clause License
Drift: MIT License
archive: BSD-style License
FFmpegKit minimal: LGPL 3.0-or-later components
Riverpod: MIT License
go_router: BSD 3-Clause License
camera, image_picker, path_provider, shared_preferences: BSD 3-Clause License
share_plus, wakelock_plus: BSD-style License
record, just_audio, audio_session, audio_waveforms: package-specific notices in the in-app license page

The in-app Open source licenses page contains the complete notices bundled by Flutter.
''';
