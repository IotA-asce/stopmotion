enum OperationType {
  capture,
  import,
  importAudio,
  recordAudio,
  duplicateProject,
  deleteProject,
  export,
}

enum OperationState {
  pending,
  mediaReady,
  databaseCommitted,
  complete,
  failed,
  recovered,
}

extension OperationStateX on OperationState {
  bool get isTerminal =>
      this == OperationState.complete || this == OperationState.recovered;
}

class Operation {
  const Operation({
    required this.id,
    required this.type,
    required this.state,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
    this.destinationProjectId,
    this.temporaryPath,
    this.finalPath,
    this.errorCode,
  });

  final String id;
  final OperationType type;
  final OperationState state;
  final String projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? destinationProjectId;
  final String? temporaryPath;
  final String? finalPath;
  final String? errorCode;
}
