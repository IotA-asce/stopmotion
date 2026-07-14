import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/database/migrations.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() => database.close());

  Future<void> insertProject() async {
    await database
        .into(database.projectRecords)
        .insert(
          ProjectRecordsCompanion.insert(
            id: 'project',
            title: 'Film',
            aspectRatio: 'widescreen',
            resolution: 'fullHd1080',
            framesPerSecond: 12,
            backgroundColor: 0,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
            status: 'draft',
          ),
        );
  }

  test('foreign keys cascade project deletion to frames', () async {
    await insertProject();
    await database
        .into(database.frameRecords)
        .insert(
          FrameRecordsCompanion.insert(
            id: 'frame',
            projectId: 'project',
            relativeSourcePath: 'projects/project/frames/frame.jpg',
            position: 0,
            createdAt: DateTime.utc(2026),
            sourceWidth: 1920,
            sourceHeight: 1080,
          ),
        );

    await database.delete(database.projectRecords).go();

    expect(await database.select(database.frameRecords).get(), isEmpty);
    await verifyDatabaseIntegrity(database);
  });

  test('frame positions are unique inside a project', () async {
    await insertProject();
    Future<void> insertFrame(String id) => database
        .into(database.frameRecords)
        .insert(
          FrameRecordsCompanion.insert(
            id: id,
            projectId: 'project',
            relativeSourcePath: 'projects/project/frames/$id.jpg',
            position: 0,
            createdAt: DateTime.utc(2026),
            sourceWidth: 1920,
            sourceHeight: 1080,
          ),
        );

    await insertFrame('one');
    await expectLater(insertFrame('two'), throwsA(isA<Exception>()));
  });

  test('failed transaction rolls back every row', () async {
    await expectLater(
      database.transaction(() async {
        await insertProject();
        throw StateError('stop');
      }),
      throwsStateError,
    );

    expect(await database.select(database.projectRecords).get(), isEmpty);
  });

  test('file-backed opening retains a pre-open database snapshot', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'stop_motion_database_backup_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final File file = File('${directory.path}/stop_motion.sqlite');
    final AppDatabase first = AppDatabase.open(file);
    await first
        .into(first.projectRecords)
        .insert(
          ProjectRecordsCompanion.insert(
            id: 'project',
            title: 'Film',
            aspectRatio: 'widescreen',
            resolution: 'fullHd1080',
            framesPerSecond: 12,
            backgroundColor: 0,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
            status: 'draft',
          ),
        );
    await first.close();

    final AppDatabase reopened = AppDatabase.open(file);
    addTearDown(reopened.close);
    expect(await reopened.select(reopened.projectRecords).get(), hasLength(1));
    expect(await File('${file.path}.backup').exists(), isTrue);
  });
}
