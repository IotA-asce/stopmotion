enum ProjectAspectRatio { widescreen, portrait, square, classic }

enum ProjectResolution { hd720, fullHd1080 }

enum ProjectStatus { draft, exported, needsRepair }

enum ProjectSort { lastEdited, dateCreated, title, duration }

enum ProjectFilter { all, draft, exported }

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.aspectRatio,
    required this.resolution,
    required this.framesPerSecond,
    required this.backgroundColorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.frameCount,
    required this.durationFrames,
    required this.currentRevision,
    this.masterVolume = 1,
    this.audioMuted = false,
    this.lastExportedRevision,
    this.deletedAt,
  });

  final String id;
  final String title;
  final ProjectAspectRatio aspectRatio;
  final ProjectResolution resolution;
  final int framesPerSecond;
  final int backgroundColorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectStatus status;
  final int frameCount;
  final int durationFrames;
  final int currentRevision;
  final double masterVolume;
  final bool audioMuted;
  final int? lastExportedRevision;
  final DateTime? deletedAt;

  Duration get duration => Duration(
    microseconds:
        (Duration.microsecondsPerSecond * durationFrames) ~/ framesPerSecond,
  );

  bool get isCurrentRevisionExported => lastExportedRevision == currentRevision;

  Project copyWith({
    String? title,
    DateTime? updatedAt,
    ProjectStatus? status,
    int? frameCount,
    int? durationFrames,
    int? currentRevision,
    double? masterVolume,
    bool? audioMuted,
    int? lastExportedRevision,
    DateTime? deletedAt,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      aspectRatio: aspectRatio,
      resolution: resolution,
      framesPerSecond: framesPerSecond,
      backgroundColorValue: backgroundColorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      frameCount: frameCount ?? this.frameCount,
      durationFrames: durationFrames ?? this.durationFrames,
      currentRevision: currentRevision ?? this.currentRevision,
      masterVolume: masterVolume ?? this.masterVolume,
      audioMuted: audioMuted ?? this.audioMuted,
      lastExportedRevision: lastExportedRevision ?? this.lastExportedRevision,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class ProjectDraft {
  ProjectDraft({
    required String title,
    required this.aspectRatio,
    required this.resolution,
    required this.framesPerSecond,
    required this.backgroundColorValue,
  }) : title = title.trim() {
    if (this.title.isEmpty) {
      throw const FormatException('Project title cannot be empty.');
    }
    if (framesPerSecond < 1 || framesPerSecond > 30) {
      throw const FormatException('Frame rate must be between 1 and 30.');
    }
  }

  final String title;
  final ProjectAspectRatio aspectRatio;
  final ProjectResolution resolution;
  final int framesPerSecond;
  final int backgroundColorValue;
}

extension ProjectAspectRatioPersistence on ProjectAspectRatio {
  String get storedValue => name;

  double get value => switch (this) {
    ProjectAspectRatio.widescreen => 16 / 9,
    ProjectAspectRatio.portrait => 9 / 16,
    ProjectAspectRatio.square => 1,
    ProjectAspectRatio.classic => 4 / 3,
  };

  String get label => switch (this) {
    ProjectAspectRatio.widescreen => '16:9',
    ProjectAspectRatio.portrait => '9:16',
    ProjectAspectRatio.square => '1:1',
    ProjectAspectRatio.classic => '4:3',
  };
}

extension ProjectResolutionPersistence on ProjectResolution {
  String get storedValue => name;

  int get longEdge => switch (this) {
    ProjectResolution.hd720 => 1280,
    ProjectResolution.fullHd1080 => 1920,
  };

  String get label => switch (this) {
    ProjectResolution.hd720 => '720p',
    ProjectResolution.fullHd1080 => '1080p',
  };
}
