enum AudioTrackType { narration, music, effect }

class AudioClip {
  AudioClip({
    required this.id,
    required this.projectId,
    required this.relativeSourcePath,
    required String name,
    required this.trackType,
    required this.startMilliseconds,
    required this.trimStartMilliseconds,
    required this.trimEndMilliseconds,
    required this.volume,
    required this.fadeInMilliseconds,
    required this.fadeOutMilliseconds,
    required this.muted,
    this.missing = false,
  }) : name = name.trim() {
    if (this.name.isEmpty) {
      throw const FormatException('Audio clip name cannot be empty.');
    }
    if (startMilliseconds < 0 ||
        trimStartMilliseconds < 0 ||
        trimEndMilliseconds <= trimStartMilliseconds) {
      throw const FormatException('Audio clip timing is invalid.');
    }
    if (volume < 0 || volume > 2) {
      throw const FormatException('Audio volume must be between 0 and 2.');
    }
    if (fadeInMilliseconds < 0 ||
        fadeOutMilliseconds < 0 ||
        fadeInMilliseconds + fadeOutMilliseconds > durationMilliseconds) {
      throw const FormatException('Audio fades exceed the clip duration.');
    }
  }

  final String id;
  final String projectId;
  final String relativeSourcePath;
  final String name;
  final AudioTrackType trackType;
  final int startMilliseconds;
  final int trimStartMilliseconds;
  final int trimEndMilliseconds;
  final double volume;
  final int fadeInMilliseconds;
  final int fadeOutMilliseconds;
  final bool muted;
  final bool missing;

  int get durationMilliseconds => trimEndMilliseconds - trimStartMilliseconds;
  int get endMilliseconds => startMilliseconds + durationMilliseconds;
  bool get audible => !muted && !missing && volume > 0;

  AudioClip copyWith({
    String? id,
    String? relativeSourcePath,
    String? name,
    AudioTrackType? trackType,
    int? startMilliseconds,
    int? trimStartMilliseconds,
    int? trimEndMilliseconds,
    double? volume,
    int? fadeInMilliseconds,
    int? fadeOutMilliseconds,
    bool? muted,
    bool? missing,
  }) => AudioClip(
    id: id ?? this.id,
    projectId: projectId,
    relativeSourcePath: relativeSourcePath ?? this.relativeSourcePath,
    name: name ?? this.name,
    trackType: trackType ?? this.trackType,
    startMilliseconds: startMilliseconds ?? this.startMilliseconds,
    trimStartMilliseconds: trimStartMilliseconds ?? this.trimStartMilliseconds,
    trimEndMilliseconds: trimEndMilliseconds ?? this.trimEndMilliseconds,
    volume: volume ?? this.volume,
    fadeInMilliseconds: fadeInMilliseconds ?? this.fadeInMilliseconds,
    fadeOutMilliseconds: fadeOutMilliseconds ?? this.fadeOutMilliseconds,
    muted: muted ?? this.muted,
    missing: missing ?? this.missing,
  );
}
