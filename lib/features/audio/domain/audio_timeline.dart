import 'audio_clip.dart';

class AudioTimeline {
  AudioTimeline({
    required this.projectId,
    required this.projectDurationMilliseconds,
    required List<AudioClip> clips,
    this.masterVolume = 1,
    this.muted = false,
  }) : clips = List<AudioClip>.unmodifiable(clips) {
    if (projectDurationMilliseconds < 0 ||
        masterVolume < 0 ||
        masterVolume > 2) {
      throw const FormatException('Audio timeline values are invalid.');
    }
    if (clips.any((AudioClip clip) => clip.projectId != projectId)) {
      throw const FormatException('Audio clip belongs to another project.');
    }
    _validateTrackLimits(clips);
  }

  static const int maximumNarrationTracks = 1;
  static const int maximumImportedTracks = 3;

  final String projectId;
  final int projectDurationMilliseconds;
  final List<AudioClip> clips;
  final double masterVolume;
  final bool muted;

  bool get hasAudibleAudio =>
      !muted && masterVolume > 0 && clips.any((AudioClip clip) => clip.audible);

  AudioTimeline copyWith({
    List<AudioClip>? clips,
    double? masterVolume,
    bool? muted,
  }) => AudioTimeline(
    projectId: projectId,
    projectDurationMilliseconds: projectDurationMilliseconds,
    clips: clips ?? this.clips,
    masterVolume: masterVolume ?? this.masterVolume,
    muted: muted ?? this.muted,
  );

  AudioTimeline add(AudioClip clip) =>
      copyWith(clips: <AudioClip>[...clips, clip]);

  AudioTimeline replace(AudioClip clip) {
    if (!clips.any((AudioClip value) => value.id == clip.id)) {
      throw StateError('Audio clip does not exist.');
    }
    return copyWith(
      clips: clips
          .map((AudioClip value) => value.id == clip.id ? clip : value)
          .toList(growable: false),
    );
  }

  AudioTimeline remove(String id) => copyWith(
    clips: clips
        .where((AudioClip clip) => clip.id != id)
        .toList(growable: false),
  );

  AudioTimeline split({
    required String id,
    required int playheadMilliseconds,
    required String newId,
  }) {
    final AudioClip source = clips.firstWhere(
      (AudioClip clip) => clip.id == id,
    );
    final int local = playheadMilliseconds - source.startMilliseconds;
    if (local <= 0 || local >= source.durationMilliseconds) {
      throw const FormatException('Split must be inside the audio clip.');
    }
    final int sourceSplit = source.trimStartMilliseconds + local;
    final AudioClip left = source.copyWith(
      trimEndMilliseconds: sourceSplit,
      fadeInMilliseconds: source.fadeInMilliseconds.clamp(0, local),
      fadeOutMilliseconds: 0,
    );
    final AudioClip right = source.copyWith(
      id: newId,
      name: '${source.name} split',
      startMilliseconds: playheadMilliseconds,
      trimStartMilliseconds: sourceSplit,
      fadeInMilliseconds: 0,
      fadeOutMilliseconds: source.fadeOutMilliseconds.clamp(
        0,
        source.durationMilliseconds - local,
      ),
    );
    return copyWith(
      clips: clips
          .expand(
            (AudioClip clip) =>
                clip.id == id ? <AudioClip>[left, right] : <AudioClip>[clip],
          )
          .toList(growable: false),
    );
  }

  List<AudioClip> activeAt(int milliseconds) => clips
      .where(
        (AudioClip clip) =>
            clip.audible &&
            milliseconds >= clip.startMilliseconds &&
            milliseconds < clip.endMilliseconds,
      )
      .toList(growable: false);

  double gainAt(AudioClip clip, int timelineMilliseconds) {
    if (muted || !clip.audible) {
      return 0;
    }
    final int local = timelineMilliseconds - clip.startMilliseconds;
    if (local < 0 || local >= clip.durationMilliseconds) {
      return 0;
    }
    var fade = 1.0;
    if (clip.fadeInMilliseconds > 0 && local < clip.fadeInMilliseconds) {
      fade = local / clip.fadeInMilliseconds;
    }
    final int remaining = clip.durationMilliseconds - local;
    if (clip.fadeOutMilliseconds > 0 && remaining < clip.fadeOutMilliseconds) {
      fade = (remaining / clip.fadeOutMilliseconds).clamp(0, fade);
    }
    return clip.volume * masterVolume * fade;
  }

  static void _validateTrackLimits(List<AudioClip> clips) {
    final int narrations = clips
        .where((AudioClip clip) => clip.trackType == AudioTrackType.narration)
        .length;
    final int imported = clips.length - narrations;
    if (narrations > maximumNarrationTracks ||
        imported > maximumImportedTracks) {
      throw const FormatException('Audio track limit exceeded.');
    }
  }
}
