import 'frame_adjustments.dart';

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
    this.adjustments = const FrameAdjustments(),
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
  final FrameAdjustments adjustments;

  ProjectFrame copyWith({
    String? id,
    int? position,
    int? holdFrames,
    String? relativeSourcePath,
    bool? missing,
    FrameAdjustments? adjustments,
  }) {
    return ProjectFrame(
      id: id ?? this.id,
      projectId: projectId,
      relativeSourcePath: relativeSourcePath ?? this.relativeSourcePath,
      position: position ?? this.position,
      holdFrames: holdFrames ?? this.holdFrames,
      createdAt: createdAt,
      sourceWidth: sourceWidth,
      sourceHeight: sourceHeight,
      missing: missing ?? this.missing,
      adjustments: adjustments ?? this.adjustments,
    );
  }
}
