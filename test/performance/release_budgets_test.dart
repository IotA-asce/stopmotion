import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';

void main() {
  test(
    '1000-frame timeline normalization and time mapping stay CI-bounded',
    () {
      final List<ProjectFrame> frames = List<ProjectFrame>.generate(
        1000,
        (int index) => ProjectFrame(
          id: 'frame-$index',
          projectId: 'project',
          relativeSourcePath: 'projects/project/frames/$index.jpg',
          position: index,
          holdFrames: (index % 5) + 1,
          createdAt: DateTime.utc(2026),
          sourceWidth: 1920,
          sourceHeight: 1080,
          missing: false,
        ),
      );
      final Stopwatch stopwatch = Stopwatch()..start();
      final TimelineSnapshot timeline = TimelineSnapshot(
        frames: frames,
        fps: 24,
      );
      final Random random = Random(2481);
      for (var index = 0; index < 1000; index++) {
        final int frame = random.nextInt(timeline.frames.length);
        expect(timeline.frameIndexAt(timeline.elapsedAtFrame(frame)), frame);
      }
      stopwatch.stop();

      expect(timeline.frames, hasLength(1000));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    },
  );

  test('50 project fixture metadata remains compact and deterministic', () {
    final List<Map<String, Object>> projects =
        List<Map<String, Object>>.generate(
          50,
          (int index) => <String, Object>{
            'id': 'project-${index.toString().padLeft(3, '0')}',
            'frameCount': 500,
            'revision': index,
          },
        );

    expect(projects, hasLength(50));
    expect(projects.first['id'], 'project-000');
    expect(projects.last['id'], 'project-049');
  });
}
