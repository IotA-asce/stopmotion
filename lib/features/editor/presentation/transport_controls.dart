import 'package:flutter/material.dart';

import '../domain/timeline.dart';
import 'editor_controller.dart';

class TransportControls extends StatelessWidget {
  const TransportControls({
    required this.controller,
    required this.state,
    super.key,
  });

  final EditorController controller;
  final EditorViewState state;

  @override
  Widget build(BuildContext context) {
    final TimelineSnapshot timeline = state.timeline!;
    final Duration current = timeline.elapsedAtFrame(state.playheadIndex);
    final double fraction = timeline.duration.inMicroseconds == 0
        ? 0
        : current.inMicroseconds / timeline.duration.inMicroseconds;
    return Semantics(
      container: true,
      label: 'Playback controls',
      child: SizedBox(
        height: 64,
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: 'Jump to start',
              onPressed: timeline.isEmpty ? null : () => controller.jumpTo(0),
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              tooltip: 'Previous frame',
              onPressed: timeline.isEmpty
                  ? null
                  : () => controller.jumpTo(state.playheadIndex - 1),
              icon: const Icon(Icons.navigate_before),
            ),
            IconButton.filled(
              tooltip: state.playing ? 'Pause' : 'Play',
              onPressed: timeline.isEmpty ? null : controller.togglePlayback,
              icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              tooltip: 'Next frame',
              onPressed: timeline.isEmpty
                  ? null
                  : () => controller.jumpTo(state.playheadIndex + 1),
              icon: const Icon(Icons.navigate_next),
            ),
            IconButton(
              tooltip: state.loop ? 'Disable loop' : 'Enable loop',
              onPressed: controller.toggleLoop,
              isSelected: state.loop,
              icon: const Icon(Icons.repeat),
            ),
            Expanded(
              child: Slider(
                value: fraction.clamp(0, 1),
                onChanged: timeline.isEmpty ? null : controller.seekFraction,
              ),
            ),
            SizedBox(
              width: 104,
              child: Text(
                '${timeline.timecode(current)} / ${timeline.timecode(timeline.duration)}',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
