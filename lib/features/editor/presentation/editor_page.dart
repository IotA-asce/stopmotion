import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../projects/presentation/project_providers.dart';
import '../domain/frame.dart';
import '../domain/timeline.dart';
import 'editor_controller.dart';
import 'editor_providers.dart';
import 'frame_action_menu.dart';
import 'frame_timeline.dart';
import 'preview_canvas.dart';
import 'transport_controls.dart';

class EditorPage extends ConsumerWidget {
  const EditorPage({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EditorController controller = ref.watch(
      editorControllerProvider(projectId),
    );
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) =>
          _buildWorkspace(context, ref, controller),
    );
  }

  Widget _buildWorkspace(
    BuildContext context,
    WidgetRef ref,
    EditorController controller,
  ) {
    final EditorViewState state = controller.state;
    if (state.errorMessage != null && state.timeline == null) {
      return AppErrorView(
        title: 'Editor unavailable',
        message: state.errorMessage!,
        actionLabel: 'Back to Projects',
        onAction: () => context.go(AppRoutes.projects),
      );
    }
    if (state.timeline == null || state.project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    File resolveFrame(ProjectFrame frame) => ref
        .read(projectPathsProvider)
        .resolveRelativeFile(frame.relativeSourcePath);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
            controller.undo,
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            controller.undo,
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            controller.redo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): controller.redo,
        const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
            controller.selectAll,
        const SingleActivator(LogicalKeyboardKey.keyA, control: true):
            controller.selectAll,
        const SingleActivator(LogicalKeyboardKey.delete):
            controller.deleteSelection,
        const SingleActivator(LogicalKeyboardKey.space):
            controller.togglePlayback,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            controller.jumpTo(state.playheadIndex - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            controller.jumpTo(state.playheadIndex + 1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to Projects',
              onPressed: () => context.go(AppRoutes.projects),
              icon: const Icon(Icons.arrow_back),
            ),
            title: InkWell(
              onTap: () => _rename(context, controller, state.project!.title),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      state.project!.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_outlined, size: 18),
                ],
              ),
            ),
            actions: <Widget>[
              _AutosaveIndicator(state: state),
              IconButton(
                tooltip: 'Undo',
                onPressed: controller.canUndo ? controller.undo : null,
                icon: const Icon(Icons.undo),
              ),
              IconButton(
                tooltip: 'Redo',
                onPressed: controller.canRedo ? controller.redo : null,
                icon: const Icon(Icons.redo),
              ),
              FrameActionMenu(
                canPaste: controller.canPaste,
                onSelected: (FrameAction action) =>
                    _frameAction(context, controller, action),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              if (state.errorMessage != null)
                MaterialBanner(
                  content: Text(state.errorMessage!),
                  actions: <Widget>[
                    TextButton(
                      onPressed: controller.initialize,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool wide = constraints.maxWidth >= 900;
                    final Widget preview = _PreviewRegion(
                      controller: controller,
                      state: state,
                      resolveFrame: resolveFrame,
                    );
                    final Widget timeline = _TimelineRegion(
                      controller: controller,
                      state: state,
                      resolveFrame: resolveFrame,
                    );
                    return wide
                        ? Row(
                            children: <Widget>[
                              Expanded(child: preview),
                              SizedBox(width: 430, child: timeline),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              Expanded(child: preview),
                              SizedBox(height: 235, child: timeline),
                            ],
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    EditorController controller,
    String current,
  ) async {
    final TextEditingController text = TextEditingController(text: current);
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Rename project'),
        content: TextField(
          controller: text,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Project title'),
          onSubmitted: (String value) => Navigator.pop(context, value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, text.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    text.dispose();
    if (result != null && result.trim().isNotEmpty) {
      await controller.rename(result);
    }
  }

  Future<void> _frameAction(
    BuildContext context,
    EditorController controller,
    FrameAction action,
  ) async {
    switch (action) {
      case FrameAction.selectAll:
        controller.selectAll();
      case FrameAction.copy:
        controller.copySelection();
      case FrameAction.paste:
        await controller.paste();
      case FrameAction.duplicate:
        await controller.duplicateSelection();
      case FrameAction.reverse:
        await controller.reverseSelection();
      case FrameAction.hold:
        await _setHold(context, controller);
      case FrameAction.delete:
        await controller.deleteSelection();
    }
  }

  Future<void> _setHold(
    BuildContext context,
    EditorController controller,
  ) async {
    int value = controller.state.selectedFrames.isEmpty
        ? 1
        : controller.state.selectedFrames.first.holdFrames;
    final int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: const Text('Frame hold'),
          content: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Decrease hold',
                onPressed: value > 1 ? () => setState(() => value--) : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text('$value frame units', textAlign: TextAlign.center),
              ),
              IconButton(
                tooltip: 'Increase hold',
                onPressed: value < 99 ? () => setState(() => value++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      await controller.setHold(result);
    }
  }
}

class _PreviewRegion extends StatelessWidget {
  const _PreviewRegion({
    required this.controller,
    required this.state,
    required this.resolveFrame,
  });

  final EditorController controller;
  final EditorViewState state;
  final File Function(ProjectFrame frame) resolveFrame;

  @override
  Widget build(BuildContext context) {
    final TimelineSnapshot timeline = state.timeline!;
    final ProjectFrame? frame = timeline.frames.isEmpty
        ? null
        : timeline.frames[state.playheadIndex.clamp(
            0,
            timeline.frames.length - 1,
          )];
    return Column(
      children: <Widget>[
        Expanded(
          child: EditorPreviewCanvas(
            project: state.project!,
            frame: frame,
            resolveFrame: resolveFrame,
          ),
        ),
        TransportControls(controller: controller, state: state),
      ],
    );
  }
}

class _TimelineRegion extends StatelessWidget {
  const _TimelineRegion({
    required this.controller,
    required this.state,
    required this.resolveFrame,
  });

  final EditorController controller;
  final EditorViewState state;
  final File Function(ProjectFrame frame) resolveFrame;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${state.timeline!.frames.length} frames',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Frame rate: ${state.timeline!.fps} fps',
                  onPressed: () => _fps(context),
                  icon: const Icon(Icons.speed),
                ),
                IconButton(
                  tooltip: 'Capture frames',
                  onPressed: () =>
                      context.push(AppRoutes.capture(controller.projectId)),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                IconButton(
                  tooltip: 'Audio workspace',
                  onPressed: () =>
                      context.push(AppRoutes.audio(controller.projectId)),
                  icon: const Icon(Icons.graphic_eq),
                ),
                IconButton(
                  tooltip: 'Full-screen preview',
                  onPressed: state.timeline!.isEmpty
                      ? null
                      : () => context.push(
                          AppRoutes.preview(controller.projectId),
                        ),
                  icon: const Icon(Icons.fullscreen),
                ),
              ],
            ),
          ),
          Expanded(
            child: FrameTimeline(
              controller: controller,
              state: state,
              resolveFrame: resolveFrame,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fps(BuildContext context) async {
    int value = state.timeline!.fps;
    final int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: const Text('Project frame rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Slider(
                value: value.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: '$value fps',
                onChanged: (double next) =>
                    setState(() => value = next.round()),
              ),
              Text('$value frames per second'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      await controller.setFps(result);
    }
  }
}

class _AutosaveIndicator extends StatelessWidget {
  const _AutosaveIndicator({required this.state});

  final EditorViewState state;

  @override
  Widget build(BuildContext context) {
    final (IconData, String) presentation = switch (state.autosave) {
      AutosaveStatus.saving => (Icons.sync, 'Saving'),
      AutosaveStatus.saved => (Icons.cloud_done_outlined, 'Saved'),
      AutosaveStatus.failed => (Icons.error_outline, 'Save failed'),
      AutosaveStatus.idle => (Icons.cloud_outlined, 'Not saved yet'),
    };
    return Semantics(
      label: presentation.$2,
      child: Tooltip(
        message: presentation.$2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(presentation.$1, size: 20),
        ),
      ),
    );
  }
}
