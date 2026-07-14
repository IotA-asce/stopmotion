enum RecoveryIssueKind {
  migration,
  orphanedMedia,
  missingMedia,
  interruptedDuplicate,
  interruptedDelete,
  missingProjectDirectory,
}

class RecoveryItem {
  const RecoveryItem({
    required this.id,
    required this.kind,
    required this.message,
    this.projectId,
    this.operationId,
    this.missingFrameCount = 0,
    this.missingAudioCount = 0,
  });

  final String id;
  final RecoveryIssueKind kind;
  final String message;
  final String? projectId;
  final String? operationId;
  final int missingFrameCount;
  final int missingAudioCount;

  bool get canRemoveMissing => missingFrameCount > 0 || missingAudioCount > 0;

  bool get canRepair => switch (kind) {
    RecoveryIssueKind.interruptedDuplicate ||
    RecoveryIssueKind.interruptedDelete ||
    RecoveryIssueKind.missingMedia ||
    RecoveryIssueKind.missingProjectDirectory => true,
    RecoveryIssueKind.migration || RecoveryIssueKind.orphanedMedia => false,
  };
}

class RecoveryReport {
  const RecoveryReport({required this.items, this.databaseHealthy = true});

  final List<RecoveryItem> items;
  final bool databaseHealthy;

  bool get requiresAttention => items.isNotEmpty;
  bool get hasMissingItems =>
      items.any((RecoveryItem item) => item.canRemoveMissing);
}
