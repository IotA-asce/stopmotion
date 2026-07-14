import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/recovery/operation.dart';
import 'package:stop_motion/core/recovery/operation_journal.dart';

void main() {
  late AppDatabase database;
  late OperationJournalRepository journal;

  setUp(() {
    database = AppDatabase.memory();
    journal = OperationJournalRepository(database);
  });

  tearDown(() => database.close());

  test('tracks incomplete work until it is completed', () async {
    final String id = await journal.begin(
      type: OperationType.import,
      projectId: 'project',
      temporaryPath: 'temporary',
      finalPath: 'final',
    );

    final Operation pending = (await journal.watchIncomplete().first).single;
    expect(pending.id, id);
    expect(pending.state, OperationState.pending);

    await journal.setState(id, OperationState.databaseCommitted);
    expect(
      (await journal.watchIncomplete().first).single.state,
      OperationState.databaseCommitted,
    );

    await journal.setState(id, OperationState.complete);
    expect(await journal.watchIncomplete().first, isEmpty);
  });
}
