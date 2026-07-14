enum AudioTrackType { narration, music, effect }

class AudioClip {
  const AudioClip({
    required this.id,
    required this.projectId,
    required this.relativeSourcePath,
    required this.name,
    required this.trackType,
    required this.startMilliseconds,
    required this.trimStartMilliseconds,
    required this.trimEndMilliseconds,
    required this.volume,
    required this.fadeInMilliseconds,
    required this.fadeOutMilliseconds,
    required this.muted,
  });

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
}
