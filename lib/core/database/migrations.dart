import 'package:drift/drift.dart';

import 'app_database.dart';

Future<void> verifyDatabaseIntegrity(AppDatabase database) async {
  final List<QueryRow> foreignKeyErrors = await database
      .customSelect('PRAGMA foreign_key_check')
      .get();
  if (foreignKeyErrors.isNotEmpty) {
    throw StateError('Database foreign-key integrity check failed.');
  }

  final List<QueryRow> integrity = await database
      .customSelect('PRAGMA integrity_check')
      .get();
  final Object? result = integrity.isEmpty
      ? null
      : integrity.first.data.values.first;
  if (result != 'ok') {
    throw StateError('Database integrity check failed: $result');
  }
}
