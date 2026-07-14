import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/audio/domain/audio_clip.dart';
import 'package:stop_motion/features/audio/domain/audio_timeline.dart';

void main() {
  test('enforces narration and imported track limits', () {
    expect(
      () => AudioTimeline(
        projectId: 'project',
        projectDurationMilliseconds: 10000,
        clips: <AudioClip>[
          _clip('n1', AudioTrackType.narration),
          _clip('n2', AudioTrackType.narration),
        ],
      ),
      throwsFormatException,
    );
    expect(
      () => AudioTimeline(
        projectId: 'project',
        projectDurationMilliseconds: 10000,
        clips: <AudioClip>[
          _clip('m1', AudioTrackType.music),
          _clip('m2', AudioTrackType.music),
          _clip('m3', AudioTrackType.effect),
          _clip('m4', AudioTrackType.effect),
        ],
      ),
      throwsFormatException,
    );
  });

  test('split retains source timing and creates reversible clip regions', () {
    final AudioTimeline timeline = AudioTimeline(
      projectId: 'project',
      projectDurationMilliseconds: 10000,
      clips: <AudioClip>[
        _clip('music', AudioTrackType.music).copyWith(
          startMilliseconds: 1000,
          trimStartMilliseconds: 200,
          trimEndMilliseconds: 4200,
          fadeInMilliseconds: 500,
          fadeOutMilliseconds: 500,
        ),
      ],
    );

    final AudioTimeline split = timeline.split(
      id: 'music',
      playheadMilliseconds: 2500,
      newId: 'right',
    );

    expect(split.clips, hasLength(2));
    expect(split.clips.first.trimEndMilliseconds, 1700);
    expect(split.clips.last.trimStartMilliseconds, 1700);
    expect(split.clips.last.startMilliseconds, 2500);
    expect(
      split.clips.fold<int>(
        0,
        (int total, AudioClip clip) => total + clip.durationMilliseconds,
      ),
      4000,
    );
  });

  test('gain honors fades, clip volume, master volume, mute, and position', () {
    final AudioClip clip = _clip('fx', AudioTrackType.effect).copyWith(
      startMilliseconds: 1000,
      volume: 1.5,
      fadeInMilliseconds: 500,
      fadeOutMilliseconds: 500,
    );
    final AudioTimeline timeline = AudioTimeline(
      projectId: 'project',
      projectDurationMilliseconds: 10000,
      clips: <AudioClip>[clip],
      masterVolume: 0.5,
    );

    expect(timeline.gainAt(clip, 1000), 0);
    expect(timeline.gainAt(clip, 1250), closeTo(0.375, 0.0001));
    expect(timeline.gainAt(clip, 2000), closeTo(0.75, 0.0001));
    expect(timeline.gainAt(clip, 5000), 0);
    expect(timeline.copyWith(muted: true).gainAt(clip, 2000), 0);
  });
}

AudioClip _clip(String id, AudioTrackType type) => AudioClip(
  id: id,
  projectId: 'project',
  relativeSourcePath: 'projects/project/audio/$id.m4a',
  name: id,
  trackType: type,
  startMilliseconds: 0,
  trimStartMilliseconds: 0,
  trimEndMilliseconds: 4000,
  volume: 1,
  fadeInMilliseconds: 0,
  fadeOutMilliseconds: 0,
  muted: false,
);
