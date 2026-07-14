import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    ProjectRecords,
    FrameRecords,
    AudioClipRecords,
    ExportRecords,
    OperationJournals,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open(File databaseFile)
    : super(
        LazyDatabase(() async {
          await databaseFile.parent.create(recursive: true);
          return NativeDatabase.createInBackground(databaseFile);
        }),
      );

  AppDatabase.memory()
    : super(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      await transaction(() async {
        if (from > to) {
          throw StateError('Database downgrades are not supported.');
        }
        if (from < 2) {
          await migrator.addColumn(frameRecords, frameRecords.adjustmentsJson);
        }
        if (from < 3) {
          await migrator.addColumn(projectRecords, projectRecords.masterVolume);
          await migrator.addColumn(projectRecords, projectRecords.audioMuted);
          await migrator.addColumn(audioClipRecords, audioClipRecords.missing);
        }
        if (from < 4) {
          await migrator.addColumn(exportRecords, exportRecords.updatedAt);
          await migrator.addColumn(exportRecords, exportRecords.settingsJson);
          await migrator.addColumn(exportRecords, exportRecords.outputBytes);
        }
      });
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS frame_project_position '
        'ON frame_records (project_id, position)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS project_updated_at '
        'ON project_records (updated_at DESC)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS journal_state '
        'ON operation_journals (state)',
      );
    },
  );
}
