enum ExportFormat { movie, gif, imageSequence }

enum ExportStatus { pending, complete, failed, cancelled }

class ProjectExportRecord {
  const ProjectExportRecord({
    required this.id,
    required this.projectId,
    required this.format,
    required this.status,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    required this.settingsJson,
    this.relativeOutputPath,
    this.outputBytes,
    this.errorCode,
  });

  final String id;
  final String projectId;
  final ExportFormat format;
  final ExportStatus status;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String settingsJson;
  final String? relativeOutputPath;
  final int? outputBytes;
  final String? errorCode;
}
