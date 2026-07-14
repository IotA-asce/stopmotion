import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../data/export_handoff.dart';
import '../data/export_repository.dart';
import '../domain/export_job.dart';
import '../domain/export_record.dart';

enum ExportViewStatus { loading, ready, exporting, complete, cancelled, failed }

class ExportViewState {
  const ExportViewState({
    this.status = ExportViewStatus.loading,
    this.settings = const ExportSettings(),
    this.preflight,
    this.progress,
    this.output,
    this.errorMessage,
    this.handoffMessage,
  });

  final ExportViewStatus status;
  final ExportSettings settings;
  final ExportPreflight? preflight;
  final ExportProgress? progress;
  final File? output;
  final String? errorMessage;
  final String? handoffMessage;

  ExportViewState copyWith({
    ExportViewStatus? status,
    ExportSettings? settings,
    ExportPreflight? preflight,
    ExportProgress? progress,
    File? output,
    String? errorMessage,
    String? handoffMessage,
    bool clearProgress = false,
    bool clearOutput = false,
    bool clearError = false,
    bool clearHandoff = false,
  }) => ExportViewState(
    status: status ?? this.status,
    settings: settings ?? this.settings,
    preflight: preflight ?? this.preflight,
    progress: clearProgress ? null : progress ?? this.progress,
    output: clearOutput ? null : output ?? this.output,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    handoffMessage: clearHandoff ? null : handoffMessage ?? this.handoffMessage,
  );
}

class ExportController extends ChangeNotifier {
  ExportController({
    required String projectId,
    required ExportGateway repository,
    required ExportHandoff handoff,
    ExportSettings defaults = const ExportSettings(),
  }) : this._(projectId, repository, handoff, defaults);

  ExportController._(
    this.projectId,
    this._repository,
    this._handoff,
    this._defaults,
  );

  final String projectId;
  final ExportGateway _repository;
  final ExportHandoff _handoff;
  final ExportSettings _defaults;
  ExportCancellationToken? _cancellation;
  ExportViewState _state = const ExportViewState();
  bool _disposed = false;

  ExportViewState get state => _state;

  Future<void> initialize() async {
    try {
      final ExportSettings settings =
          await _repository.previousSuccessfulSettings(projectId) ?? _defaults;
      _update(_state.copyWith(settings: settings, clearError: true));
      await _refreshPreflight(status: ExportViewStatus.ready);
    } on Object catch (error) {
      _update(
        _state.copyWith(
          status: ExportViewStatus.failed,
          errorMessage: 'Export could not open: $error',
        ),
      );
    }
  }

  Future<void> setSettings(ExportSettings settings) async {
    if (_state.status == ExportViewStatus.exporting) return;
    _update(
      _state.copyWith(
        settings: settings,
        status: ExportViewStatus.loading,
        clearOutput: true,
        clearError: true,
        clearHandoff: true,
      ),
    );
    await _refreshPreflight(status: ExportViewStatus.ready);
  }

  Future<void> export() async {
    if (_state.preflight?.canExport != true ||
        _state.status == ExportViewStatus.exporting) {
      return;
    }
    final ExportCancellationToken cancellation = ExportCancellationToken();
    _cancellation = cancellation;
    _update(
      _state.copyWith(
        status: ExportViewStatus.exporting,
        progress: const ExportProgress(
          stage: ExportStage.preflight,
          fraction: 0,
          elapsed: Duration.zero,
        ),
        clearOutput: true,
        clearError: true,
        clearHandoff: true,
      ),
    );
    try {
      final request = await _repository.createRequest(
        projectId,
        _state.settings,
      );
      final ExportResult result = await _repository.run(
        request,
        cancellation: cancellation,
        onProgress: (ExportProgress progress) {
          _update(_state.copyWith(progress: progress));
        },
      );
      _update(
        _state.copyWith(
          status: ExportViewStatus.complete,
          output: result.output,
          progress: ExportProgress(
            stage: ExportStage.validating,
            fraction: 1,
            elapsed: _state.progress?.elapsed ?? Duration.zero,
          ),
        ),
      );
    } on ExportCancelled {
      _update(
        _state.copyWith(
          status: ExportViewStatus.cancelled,
          clearProgress: true,
        ),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          status: ExportViewStatus.failed,
          errorMessage: _friendlyError(error),
          clearProgress: true,
        ),
      );
    } finally {
      _cancellation = null;
    }
  }

  void cancel() => _cancellation?.cancel();

  Future<void> retry() async {
    await _refreshPreflight(status: ExportViewStatus.ready);
    await export();
  }

  Future<void> share({Rect? origin}) => _handoffAction(
    (File file) => _handoff.share(file, origin: origin),
    success: 'Share sheet opened.',
  );

  Future<void> save({Rect? origin}) => _handoffAction(
    (File file) => _handoff.save(file, _state.settings.format, origin: origin),
    success: _state.settings.format == ExportFormat.imageSequence
        ? 'Choose Save to Files in the system sheet.'
        : 'Saved to your media library.',
  );

  Future<void> open() =>
      _handoffAction(_handoff.open, success: 'Opened export.');

  Future<void> _handoffAction(
    Future<ExportHandoffResult> Function(File file) action, {
    required String success,
  }) async {
    final File? output = _state.output;
    if (output == null) return;
    final ExportHandoffResult result = await action(output);
    _update(
      _state.copyWith(
        handoffMessage: switch (result) {
          ExportHandoffResult.complete => success,
          ExportHandoffResult.dismissed => 'Export remains ready to share.',
          ExportHandoffResult.denied =>
            'Access was denied. You can still share the export.',
          ExportHandoffResult.unavailable =>
            'No compatible system destination is available.',
          ExportHandoffResult.failed => 'The system action could not complete.',
        },
      ),
    );
  }

  Future<void> _refreshPreflight({required ExportViewStatus status}) async {
    try {
      final ExportPreflight checked = await _repository.preflight(
        projectId,
        _state.settings,
      );
      _update(
        _state.copyWith(status: status, preflight: checked, clearError: true),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          status: ExportViewStatus.failed,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  String _friendlyError(Object error) => switch (error) {
    FormatException(:final message) => message.toString(),
    UnsupportedError(:final message) => message.toString(),
    FileSystemException() => 'Storage could not complete the export.',
    _ => 'Export failed. Change settings or try again.',
  };

  void _update(ExportViewState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancellation?.cancel();
    super.dispose();
  }
}
