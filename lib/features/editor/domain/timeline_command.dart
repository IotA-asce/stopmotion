import 'package:uuid/uuid.dart';

import 'frame.dart';
import 'frame_adjustments.dart';
import 'timeline.dart';

abstract interface class TimelineCommand {
  TimelineSnapshot apply(TimelineSnapshot timeline);
}

class InsertFramesCommand implements TimelineCommand {
  const InsertFramesCommand(this.frames, this.index);

  final List<ProjectFrame> frames;
  final int index;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) {
    final List<ProjectFrame> next = <ProjectFrame>[...timeline.frames];
    next.insertAll(index.clamp(0, next.length), frames);
    return timeline.copyWith(frames: next);
  }
}

class ReorderFramesCommand implements TimelineCommand {
  const ReorderFramesCommand(this.frameIds, this.targetIndex);

  final Set<String> frameIds;
  final int targetIndex;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) {
    if (frameIds.isEmpty) {
      return timeline;
    }
    final List<ProjectFrame> moving = timeline.frames
        .where((ProjectFrame frame) => frameIds.contains(frame.id))
        .toList();
    final List<ProjectFrame> remaining = timeline.frames
        .where((ProjectFrame frame) => !frameIds.contains(frame.id))
        .toList();
    final int removedBefore = timeline.frames
        .take(targetIndex.clamp(0, timeline.frames.length))
        .where((ProjectFrame frame) => frameIds.contains(frame.id))
        .length;
    final int insertion = (targetIndex - removedBefore).clamp(
      0,
      remaining.length,
    );
    remaining.insertAll(insertion, moving);
    return timeline.copyWith(frames: remaining);
  }
}

class DeleteFramesCommand implements TimelineCommand {
  const DeleteFramesCommand(this.frameIds);

  final Set<String> frameIds;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) => timeline.copyWith(
    frames: timeline.frames
        .where((ProjectFrame frame) => !frameIds.contains(frame.id))
        .toList(),
  );
}

class ReverseFramesCommand implements TimelineCommand {
  const ReverseFramesCommand(this.frameIds);

  final Set<String> frameIds;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) {
    final List<ProjectFrame> selected = timeline.frames
        .where((ProjectFrame frame) => frameIds.contains(frame.id))
        .toList()
        .reversed
        .toList();
    var cursor = 0;
    return timeline.copyWith(
      frames: <ProjectFrame>[
        for (final ProjectFrame frame in timeline.frames)
          if (frameIds.contains(frame.id)) selected[cursor++] else frame,
      ],
    );
  }
}

class DuplicateFramesCommand implements TimelineCommand {
  DuplicateFramesCommand(this.frameIds, {this.uuid = const Uuid()});

  final Set<String> frameIds;
  final Uuid uuid;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) {
    final List<ProjectFrame> next = <ProjectFrame>[];
    for (final ProjectFrame frame in timeline.frames) {
      next.add(frame);
      if (frameIds.contains(frame.id)) {
        next.add(frame.copyWith(id: uuid.v4()));
      }
    }
    return timeline.copyWith(frames: next);
  }
}

class PasteFramesCommand implements TimelineCommand {
  PasteFramesCommand(this.frames, this.index, {this.uuid = const Uuid()});

  final List<ProjectFrame> frames;
  final int index;
  final Uuid uuid;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) => InsertFramesCommand(
    frames.map((ProjectFrame frame) => frame.copyWith(id: uuid.v4())).toList(),
    index,
  ).apply(timeline);
}

class SetFrameHoldCommand implements TimelineCommand {
  const SetFrameHoldCommand(this.frameIds, this.holdFrames);

  final Set<String> frameIds;
  final int holdFrames;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) {
    if (holdFrames < 1 || holdFrames > 99) {
      throw RangeError.range(holdFrames, 1, 99, 'holdFrames');
    }
    return timeline.copyWith(
      frames: <ProjectFrame>[
        for (final ProjectFrame frame in timeline.frames)
          frameIds.contains(frame.id)
              ? frame.copyWith(holdFrames: holdFrames)
              : frame,
      ],
    );
  }
}

class SetFramesPerSecondCommand implements TimelineCommand {
  const SetFramesPerSecondCommand(this.fps);

  final int fps;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) =>
      timeline.copyWith(fps: fps);
}

class UpdateFrameAdjustmentsCommand implements TimelineCommand {
  const UpdateFrameAdjustmentsCommand({
    required this.targetFrameId,
    required this.selectionIds,
    required this.adjustments,
    required this.scope,
  });

  final String targetFrameId;
  final Set<String> selectionIds;
  final FrameAdjustments adjustments;
  final AdjustmentScope scope;

  @override
  TimelineSnapshot apply(TimelineSnapshot timeline) {
    final int target = timeline.frames.indexWhere(
      (ProjectFrame frame) => frame.id == targetFrameId,
    );
    if (target < 0) {
      return timeline;
    }
    bool applies(ProjectFrame frame, int index) => switch (scope) {
      AdjustmentScope.frame => frame.id == targetFrameId,
      AdjustmentScope.selection => selectionIds.contains(frame.id),
      AdjustmentScope.subsequent => index >= target,
    };
    return timeline.copyWith(
      frames: <ProjectFrame>[
        for (var index = 0; index < timeline.frames.length; index++)
          applies(timeline.frames[index], index)
              ? timeline.frames[index].copyWith(adjustments: adjustments)
              : timeline.frames[index],
      ],
    );
  }
}
