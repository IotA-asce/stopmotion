class ProjectFrame {
  const ProjectFrame({
    required this.id,
    required this.projectId,
    required this.relativeSourcePath,
    required this.position,
    required this.holdFrames,
    required this.createdAt,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.missing,
  });

  final String id;
  final String projectId;
  final String relativeSourcePath;
  final int position;
  final int holdFrames;
  final DateTime createdAt;
  final int sourceWidth;
  final int sourceHeight;
  final bool missing;
}
