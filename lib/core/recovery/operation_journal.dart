import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import 'operation.dart' as domain;

class OperationJournalRepository {
  OperationJournalRepository(this._database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final Uuid _uuid;

  Future<String> begin({
    required domain.OperationType type,
    required String projectId,
    String? destinationProjectId,
    String? temporaryPath,
    String? finalPath,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    await _database
        .into(_database.operationJournals)
        .insert(
          OperationJournalsCompanion.insert(
            id: id,
            type: type.name,
            state: domain.OperationState.pending.name,
            projectId: projectId,
            destinationProjectId: Value<String?>(destinationProjectId),
            temporaryPath: Value<String?>(temporaryPath),
            finalPath: Value<String?>(finalPath),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> setState(
    String id,
    domain.OperationState state, {
    String? errorCode,
  }) async {
    await (_database.update(
      _database.operationJournals,
    )..where((OperationJournals table) => table.id.equals(id))).write(
      OperationJournalsCompanion(
        state: Value<String>(state.name),
        errorCode: Value<String?>(errorCode),
        updatedAt: Value<DateTime>(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<domain.Operation>> watchIncomplete() {
    final SimpleSelectStatement<OperationJournals, OperationJournal> query =
        _database.select(_database.operationJournals)
          ..where(
            (OperationJournals table) => table.state.isNotIn(<String>[
              domain.OperationState.complete.name,
              domain.OperationState.recovered.name,
            ]),
          )
          ..orderBy(<OrderingTerm Function(OperationJournals)>[
            (OperationJournals table) => OrderingTerm.asc(table.createdAt),
          ]);
    return query.watch().map(
      (List<OperationJournal> rows) => rows.map(_map).toList(growable: false),
    );
  }

  Future<List<domain.Operation>> listIncomplete() async {
    final SimpleSelectStatement<OperationJournals, OperationJournal> query =
        _database.select(_database.operationJournals)
          ..where(
            (OperationJournals table) => table.state.isNotIn(<String>[
              domain.OperationState.complete.name,
              domain.OperationState.recovered.name,
            ]),
          )
          ..orderBy(<OrderingTerm Function(OperationJournals)>[
            (OperationJournals table) => OrderingTerm.asc(table.createdAt),
          ]);
    final List<OperationJournal> rows = await query.get();
    return rows.map(_map).toList(growable: false);
  }

  Future<void> markRecovered(String id, {String? errorCode}) =>
      setState(id, domain.OperationState.recovered, errorCode: errorCode);

  domain.Operation _map(OperationJournal row) => domain.Operation(
    id: row.id,
    type: domain.OperationType.values.byName(row.type),
    state: domain.OperationState.values.byName(row.state),
    projectId: row.projectId,
    destinationProjectId: row.destinationProjectId,
    temporaryPath: row.temporaryPath,
    finalPath: row.finalPath,
    errorCode: row.errorCode,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
