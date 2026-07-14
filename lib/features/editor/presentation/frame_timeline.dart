import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/settings_providers.dart';
import '../domain/frame.dart';
import '../domain/timeline.dart';
import 'editor_controller.dart';

class FrameTimeline extends ConsumerStatefulWidget {
  const FrameTimeline({
    required this.controller,
    required this.state,
    required this.resolveFrame,
    super.key,
  });

  final EditorController controller;
  final EditorViewState state;
  final File Function(ProjectFrame frame) resolveFrame;

  @override
  ConsumerState<FrameTimeline> createState() => _FrameTimelineState();
}

class _FrameTimelineState extends ConsumerState<FrameTimeline> {
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(FrameTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.playheadIndex != widget.state.playheadIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealPlayhead());
    }
  }

  void _revealPlayhead() {
    if (!_scroll.hasClients) {
      return;
    }
    final double tileWidth = 72 * widget.state.zoom;
    final double target = widget.state.playheadIndex * tileWidth;
    final double viewport = _scroll.position.viewportDimension;
    final double current = _scroll.offset;
    if (target < current || target + tileWidth > current + viewport) {
      _scroll.animateTo(
        (target - viewport / 2).clamp(0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TimelineSnapshot timeline = widget.state.timeline!;
    final bool highContrast = ref
        .watch(appSettingsProvider)
        .highContrastTimeline;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 40,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 12),
              const Icon(Icons.zoom_out, size: 18),
              Expanded(
                child: Slider(
                  value: widget.state.zoom,
                  min: 0.75,
                  max: 2.5,
                  divisions: 7,
                  label: '${widget.state.zoom.toStringAsFixed(2)}x',
                  onChanged: widget.controller.setZoom,
                ),
              ),
              const Icon(Icons.zoom_in, size: 18),
              const SizedBox(width: 12),
            ],
          ),
        ),
        Expanded(
          child: timeline.isEmpty
              ? const Center(child: Text('Capture or import frames to begin.'))
              : ReorderableListView.builder(
                  scrollController: _scroll,
                  scrollDirection: Axis.horizontal,
                  scrollCacheExtent: const ScrollCacheExtent.pixels(900),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  buildDefaultDragHandles: false,
                  itemCount: timeline.frames.length,
                  onReorderItem: widget.controller.reorder,
                  proxyDecorator:
                      (Widget child, int index, Animation<double> animation) =>
                          Material(
                            elevation: 6,
                            color: Colors.transparent,
                            child: child,
                          ),
                  itemBuilder: (BuildContext context, int index) {
                    final ProjectFrame frame = timeline.frames[index];
                    return _FrameTile(
                      key: ValueKey<String>(frame.id),
                      frame: frame,
                      index: index,
                      width: 72 * widget.state.zoom,
                      selected:
                          widget.state.selection?.contains(frame.id) == true,
                      playhead: widget.state.playheadIndex == index,
                      file: widget.resolveFrame(frame),
                      onTap: () => widget.controller.select(frame.id),
                      onLongPress: () =>
                          widget.controller.select(frame.id, toggle: true),
                      highContrast: highContrast,
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
}

class _FrameTile extends StatelessWidget {
  const _FrameTile({
    required this.frame,
    required this.index,
    required this.width,
    required this.selected,
    required this.playhead,
    required this.file,
    required this.onTap,
    required this.onLongPress,
    required this.highContrast,
    super.key,
  });

  final ProjectFrame frame;
  final int index;
  final double width;
  final bool selected;
  final bool playhead;
  final File file;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ReorderableDragStartListener(
      index: index,
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Frame ${index + 1}, hold ${frame.holdFrames}',
        value: playhead ? 'Playhead' : null,
        hint:
            'Double tap to select. Long press to add or remove from selection.',
        child: SizedBox(
          width: width,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: playhead
                      ? highContrast
                            ? colors.error
                            : colors.tertiary
                      : selected
                      ? highContrast
                            ? colors.onSurface
                            : colors.primary
                      : colors.outlineVariant,
                  width: playhead
                      ? highContrast
                            ? 4
                            : 3
                      : selected
                      ? highContrast
                            ? 3
                            : 2
                      : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: frame.missing
                        ? const Center(child: Icon(Icons.broken_image_outlined))
                        : Image.file(
                            file,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            cacheWidth: width.round().clamp(48, 180),
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 25,
                    child: Center(
                      child: Text(
                        '${index + 1}${frame.holdFrames > 1 ? '  x${frame.holdFrames}' : ''}',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
