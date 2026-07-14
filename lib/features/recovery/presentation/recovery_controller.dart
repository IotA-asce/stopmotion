import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/diagnostic_exporter.dart';
import '../../export/data/export_handoff.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/recovery_repository.dart';
import '../domain/recovery_report.dart';
import 'recovery_providers.dart';

class RecoveryViewState {
  const RecoveryViewState({
    this.loading = true,
    this.report = const RecoveryReport(items: <RecoveryItem>[]),
    this.message,
  });

  final bool loading;
  final RecoveryReport report;
  final String? message;

  RecoveryViewState copyWith({
    bool? loading,
    RecoveryReport? report,
    String? message,
    bool clearMessage = false,
  }) => RecoveryViewState(
    loading: loading ?? this.loading,
    report: report ?? this.report,
    message: clearMessage ? null : message ?? this.message,
  );
}

class RecoveryController extends Notifier<RecoveryViewState> {
  late final RecoveryRepository _repository;
  late final DiagnosticExporter _diagnostics;
  late final ExportHandoff _handoff;
  bool _disposed = false;

  @override
  RecoveryViewState build() {
    _repository = ref.watch(recoveryRepositoryProvider);
    _diagnostics = ref.watch(diagnosticExporterProvider);
    _handoff = const SystemExportHandoff();
    ref.onDispose(() => _disposed = true);
    return const RecoveryViewState();
  }

  Future<void> refresh() => _run(_repository.scan);
  Future<void> repair() => _run(_repository.repair);
  Future<void> removeMissingItems() => _run(_repository.removeMissingItems);

  Future<void> exportDiagnostics() async {
    _update(state.copyWith(loading: true, clearMessage: true));
    try {
      final result = await _handoff.share(await _diagnostics.create());
      _update(
        state.copyWith(
          loading: false,
          message: switch (result) {
            ExportHandoffResult.complete => 'Diagnostic archive shared.',
            ExportHandoffResult.dismissed =>
              'Diagnostic archive is ready to share.',
            ExportHandoffResult.denied =>
              'Sharing was denied. The archive remains on this device.',
            ExportHandoffResult.unavailable =>
              'No compatible sharing destination is available.',
            ExportHandoffResult.failed =>
              'The diagnostic archive could not be shared.',
          },
        ),
      );
    } on Object {
      _update(
        state.copyWith(
          loading: false,
          message: 'The diagnostic archive could not be created.',
        ),
      );
    }
  }

  Future<void> _run(Future<RecoveryReport> Function() action) async {
    _update(state.copyWith(loading: true, clearMessage: true));
    try {
      _update(state.copyWith(loading: false, report: await action()));
    } on Object {
      _update(
        state.copyWith(
          loading: false,
          message:
              'Recovery could not finish. Your source files were retained.',
        ),
      );
    }
  }

  void _update(RecoveryViewState value) {
    if (_disposed) return;
    state = value;
  }
}
