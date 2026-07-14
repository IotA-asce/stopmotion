import 'dart:collection';

import 'frame.dart';

class TimelineSnapshot {
  TimelineSnapshot({required List<ProjectFrame> frames, required this.fps})
    : frames = UnmodifiableListView<ProjectFrame>(_normalize(frames)) {
    if (fps < 1 || fps > 30) {
      throw RangeError.range(fps, 1, 30, 'fps');
    }
    if (this.frames.map((ProjectFrame frame) => frame.id).toSet().length !=
        this.frames.length) {
      throw const FormatException('Timeline frame identifiers must be unique.');
    }
    if (this.frames.any((ProjectFrame frame) => frame.holdFrames < 1)) {
      throw const FormatException('Frame holds must be positive.');
    }
  }

  final List<ProjectFrame> frames;
  final int fps;

  int get totalHoldFrames => frames.fold<int>(
    0,
    (int total, ProjectFrame frame) => total + frame.holdFrames,
  );

  Duration get duration => Duration(
    microseconds: (totalHoldFrames * Duration.microsecondsPerSecond) ~/ fps,
  );

  bool get isEmpty => frames.isEmpty;

  int frameIndexAt(Duration elapsed) {
    if (frames.isEmpty) {
      return 0;
    }
    final int target =
        ((elapsed.inMicroseconds * fps) ~/ Duration.microsecondsPerSecond)
            .clamp(0, totalHoldFrames - 1);
    var cursor = 0;
    for (var index = 0; index < frames.length; index++) {
      cursor += frames[index].holdFrames;
      if (target < cursor) {
        return index;
      }
    }
    return frames.length - 1;
  }

  Duration elapsedAtFrame(int index) {
    if (frames.isEmpty) {
      return Duration.zero;
    }
    final int bounded = index.clamp(0, frames.length);
    final int holds = frames
        .take(bounded)
        .fold<int>(
          0,
          (int total, ProjectFrame frame) => total + frame.holdFrames,
        );
    return Duration(
      microseconds: (holds * Duration.microsecondsPerSecond + fps - 1) ~/ fps,
    );
  }

  String timecode(Duration elapsed) {
    final int boundedMicros = elapsed.inMicroseconds.clamp(
      0,
      duration.inMicroseconds,
    );
    final int totalSeconds = boundedMicros ~/ Duration.microsecondsPerSecond;
    final int frame =
        ((boundedMicros % Duration.microsecondsPerSecond) * fps) ~/
        Duration.microsecondsPerSecond;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}:'
        '${frame.toString().padLeft(2, '0')}';
  }

  TimelineSnapshot copyWith({List<ProjectFrame>? frames, int? fps}) =>
      TimelineSnapshot(frames: frames ?? this.frames, fps: fps ?? this.fps);

  static List<ProjectFrame> _normalize(List<ProjectFrame> frames) =>
      <ProjectFrame>[
        for (var index = 0; index < frames.length; index++)
          frames[index].copyWith(position: index),
      ];
}

class TimelineSelection {
  TimelineSelection._(Set<String> ids, this.anchorId)
    : ids = UnmodifiableSetView<String>(ids);

  factory TimelineSelection.empty() => TimelineSelection._(<String>{}, null);

  final Set<String> ids;
  final String? anchorId;

  bool get isEmpty => ids.isEmpty;
  bool contains(String id) => ids.contains(id);

  TimelineSelection single(String id) => TimelineSelection._(<String>{id}, id);

  TimelineSelection toggle(String id) {
    final Set<String> next = <String>{...ids};
    next.contains(id) ? next.remove(id) : next.add(id);
    return TimelineSelection._(next, next.contains(id) ? id : anchorId);
  }

  TimelineSelection range(List<ProjectFrame> frames, String targetId) {
    final int anchor = frames.indexWhere(
      (ProjectFrame frame) => frame.id == (anchorId ?? targetId),
    );
    final int target = frames.indexWhere(
      (ProjectFrame frame) => frame.id == targetId,
    );
    if (anchor < 0 || target < 0) {
      return single(targetId);
    }
    final int start = anchor < target ? anchor : target;
    final int end = anchor > target ? anchor : target;
    return TimelineSelection._(
      frames
          .sublist(start, end + 1)
          .map((ProjectFrame frame) => frame.id)
          .toSet(),
      frames[anchor].id,
    );
  }

  TimelineSelection all(List<ProjectFrame> frames) => TimelineSelection._(
    frames.map((ProjectFrame frame) => frame.id).toSet(),
    frames.isEmpty ? null : frames.first.id,
  );

  TimelineSelection retain(List<ProjectFrame> frames) {
    final Set<String> available = frames
        .map((ProjectFrame frame) => frame.id)
        .toSet();
    return TimelineSelection._(ids.intersection(available), anchorId);
  }
}
