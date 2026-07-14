import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/rendered_frame_image.dart';
import '../../editor/domain/frame.dart';
import '../../editor/domain/timeline.dart';
import '../../editor/presentation/editor_providers.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_providers.dart';
import 'preview_controller.dart';
import 'preview_quality_menu.dart';

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({
    required this.projectId,
    this.initialFrame = 0,
    this.controller,
    super.key,
  });

  final String projectId;
  final int initialFrame;
  final PreviewController? controller;

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage>
    with WidgetsBindingObserver {
  late final PreviewController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        PreviewController(
          projectId: widget.projectId,
          initialFrame: widget.initialFrame,
          editor: ref.read(editorRepositoryProvider),
          projects: ref.read(projectRepositoryProvider),
        );
    if (_ownsController) {
      unawaited(_controller.initialize());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? child) {
        final PreviewViewState state = _controller.state;
        if (state.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.errorMessage!)),
          );
        }
        if (state.timeline == null || state.project == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final TimelineSnapshot timeline = state.timeline!;
        final ProjectFrame frame = timeline.frames[state.frameIndex];
        final bool accessible = MediaQuery.accessibleNavigationOf(context);
        final File source = ref
            .read(projectPathsProvider)
            .resolveRelativeFile(frame.relativeSourcePath);
        final (int, int) dimensions = switch (state.quality) {
          PreviewQuality.full =>
            state.project!.aspectRatio.value >= 1 ? (1920, 1080) : (1080, 1920),
          PreviewQuality.performance =>
            state.project!.aspectRatio.value >= 1 ? (480, 270) : (270, 480),
          PreviewQuality.automatic =>
            state.project!.aspectRatio.value >= 1 ? (640, 360) : (360, 640),
        };
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _controller.toggleControls(keepAccessible: accessible),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: AspectRatio(
                    aspectRatio: state.project!.aspectRatio.value,
                    child: RenderedFrameImage(
                      cache: ref.read(framePreviewCacheProvider),
                      source: source,
                      adjustments: frame.adjustments,
                      targetWidth: dimensions.$1,
                      targetHeight: dimensions.$2,
                      backgroundColor: state.project!.backgroundColorValue,
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: !state.controlsVisible && !accessible,
                  child: AnimatedOpacity(
                    opacity: state.controlsVisible || accessible ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: _controls(context, state, timeline),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _controls(
    BuildContext context,
    PreviewViewState state,
    TimelineSnapshot timeline,
  ) {
    final Duration current = timeline.elapsedAtFrame(state.frameIndex);
    final double fraction = timeline.duration.inMicroseconds == 0
        ? 0
        : current.inMicroseconds / timeline.duration.inMicroseconds;
    return Column(
      children: <Widget>[
        ColoredBox(
          color: Colors.black54,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Close preview',
                  onPressed: context.pop,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    state.project!.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                PreviewQualityMenu(
                  value: state.quality,
                  onChanged: _controller.setQuality,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        ColoredBox(
          color: Colors.black54,
          child: SafeArea(
            top: false,
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: state.playing ? 'Pause' : 'Play',
                  onPressed: _controller.togglePlayback,
                  icon: Icon(
                    state.playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: state.loop ? 'Disable loop' : 'Enable loop',
                  onPressed: _controller.toggleLoop,
                  isSelected: state.loop,
                  icon: const Icon(Icons.repeat, color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                    value: fraction.clamp(0, 1),
                    onChanged: _controller.seekFraction,
                  ),
                ),
                Text(
                  timeline.timecode(current),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }
}
