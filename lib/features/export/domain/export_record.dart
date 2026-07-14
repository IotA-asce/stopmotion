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
    this.relativeOutputPath,
    this.errorCode,
  });

  final String id;
  final String projectId;
  final ExportFormat format;
  final ExportStatus status;
  final int revision;
  final DateTime createdAt;
  final String? relativeOutputPath;
  final String? errorCode;
}
