import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/editor/domain/timeline_command.dart';

import 'timeline_test.dart' show frame;

void main() {
  test('commands reorder, duplicate, delete, reverse, paste, and hold', () {
    TimelineSnapshot timeline = TimelineSnapshot(
      frames: <ProjectFrame>[frame('a'), frame('b'), frame('c'), frame('d')],
      fps: 12,
    );

    timeline = ReorderFramesCommand(<String>{'b', 'c'}, 4).apply(timeline);
    expect(ids(timeline), <String>['a', 'd', 'b', 'c']);
    timeline = ReverseFramesCommand(<String>{'d', 'b'}).apply(timeline);
    expect(ids(timeline), <String>['a', 'b', 'd', 'c']);
    timeline = SetFrameHoldCommand(<String>{'b', 'd'}, 8).apply(timeline);
    expect(
      timeline.frames
          .where((ProjectFrame value) => value.holdFrames == 8)
          .length,
      2,
    );
    timeline = DuplicateFramesCommand(<String>{'b'}).apply(timeline);
    expect(timeline.frames.length, 5);
    timeline = DeleteFramesCommand(<String>{'a'}).apply(timeline);
    expect(timeline.frames.length, 4);
    timeline = PasteFramesCommand(<ProjectFrame>[
      frame('copy'),
    ], 1).apply(timeline);
    expect(timeline.frames.length, 5);
    expect(
      timeline.frames.map((ProjectFrame value) => value.id).toSet().length,
      5,
    );
    expect(
      timeline.frames.map((ProjectFrame value) => value.position),
      orderedEquals(<int>[0, 1, 2, 3, 4]),
    );
  });

  test('fps and hold validation reject invalid values', () {
    final TimelineSnapshot timeline = TimelineSnapshot(
      frames: <ProjectFrame>[frame('a')],
      fps: 12,
    );
    expect(
      () => SetFramesPerSecondCommand(31).apply(timeline),
      throwsRangeError,
    );
    expect(
      () => SetFrameHoldCommand(<String>{'a'}, 0).apply(timeline),
      throwsRangeError,
    );
  });
}

List<String> ids(TimelineSnapshot value) =>
    value.frames.map((ProjectFrame frame) => frame.id).toList();
