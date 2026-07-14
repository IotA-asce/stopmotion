import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';

void main() {
  test('duration and playhead mapping honor holds and fps', () {
    final TimelineSnapshot timeline = TimelineSnapshot(
      frames: <ProjectFrame>[
        frame('a', hold: 1),
        frame('b', hold: 3),
        frame('c', hold: 2),
      ],
      fps: 2,
    );

    expect(timeline.totalHoldFrames, 6);
    expect(timeline.duration, const Duration(seconds: 3));
    expect(timeline.frameIndexAt(const Duration(milliseconds: 499)), 0);
    expect(timeline.frameIndexAt(const Duration(milliseconds: 500)), 1);
    expect(timeline.frameIndexAt(const Duration(milliseconds: 2100)), 2);
    expect(timeline.timecode(const Duration(milliseconds: 1250)), '00:01:00');
  });

  test('selection supports single, toggle, range, and select all', () {
    final List<ProjectFrame> frames = List<ProjectFrame>.generate(
      6,
      (int index) => frame('$index'),
    );
    TimelineSelection selection = TimelineSelection.empty().single('1');
    selection = selection.range(frames, '4');
    expect(selection.ids, <String>{'1', '2', '3', '4'});
    selection = selection.toggle('3');
    expect(selection.contains('3'), isFalse);
    expect(selection.all(frames).ids.length, 6);
  });

  test('randomized 1000-frame timelines retain deterministic invariants', () {
    final Random random = Random(2481);
    final List<ProjectFrame> frames = List<ProjectFrame>.generate(
      1000,
      (int index) => frame('$index', hold: random.nextInt(99) + 1),
    );
    final TimelineSnapshot timeline = TimelineSnapshot(frames: frames, fps: 24);

    expect(timeline.frames.length, 1000);
    expect(
      timeline.frames.map((ProjectFrame value) => value.position),
      orderedEquals(List<int>.generate(1000, (int index) => index)),
    );
    for (var index = 0; index < timeline.frames.length; index += 17) {
      expect(timeline.frameIndexAt(timeline.elapsedAtFrame(index)), index);
    }
  });
}

ProjectFrame frame(String id, {int hold = 1}) => ProjectFrame(
  id: id,
  projectId: 'project',
  relativeSourcePath: 'projects/project/frames/$id.jpg',
  position: 99,
  holdFrames: hold,
  createdAt: DateTime.utc(2026),
  sourceWidth: 1920,
  sourceHeight: 1080,
  missing: false,
);
