import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/media/camera_capabilities.dart';
import '../../../core/media/camera_service.dart';
import '../../editor/domain/frame.dart';
import '../domain/capture_frame.dart';
import '../domain/interval_capture.dart';
import 'camera_preview_surface.dart';
import 'capture_controller.dart';
import 'capture_providers.dart';
import 'capture_tools.dart';
import 'frame_review_page.dart';

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage>
    with WidgetsBindingObserver {
  late final CaptureController _controller;
  final FocusNode _volumeFocus = FocusNode(debugLabel: 'volume-shutter');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ref.read(captureControllerProvider(widget.projectId));
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _volumeFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller.pause());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_controller.resume());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(captureControllerProvider(widget.projectId));
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? child) {
        final CaptureViewState state = _controller.state;
        return KeyboardListener(
          focusNode: _volumeFocus,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.audioVolumeUp ||
                    event.logicalKey == LogicalKeyboardKey.audioVolumeDown)) {
              unawaited(_controller.capture());
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: _appBar(state),
            body: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool landscape =
                      constraints.maxWidth > constraints.maxHeight;
                  return landscape
                      ? _landscapeBody(state)
                      : _portraitBody(state);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar(CaptureViewState state) {
    final CameraCapabilities? capabilities = state.camera.capabilities;
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: _back,
        tooltip: 'Back to Projects',
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        '${state.project?.title ?? 'Capture'}  ${state.frames.length}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        if ((capabilities?.flashModes.length ?? 0) > 1)
          PopupMenuButton<CameraFlash>(
            tooltip: 'Flash mode',
            initialValue: state.flash,
            onSelected: (CameraFlash value) => _controller.setFlash(value),
            icon: Icon(_flashIcon(state.flash)),
            itemBuilder: (BuildContext context) => capabilities!.flashModes
                .map(
                  (CameraFlash value) => PopupMenuItem<CameraFlash>(
                    value: value,
                    child: Text(value.name),
                  ),
                )
                .toList(growable: false),
          ),
        if (capabilities?.canSwitchCamera ?? false)
          IconButton(
            onPressed: _controller.switchCamera,
            tooltip: 'Switch camera',
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
      ],
    );
  }

  Widget _portraitBody(CaptureViewState state) {
    return Column(
      children: <Widget>[
        _status(state),
        Expanded(child: _preview(state)),
        CaptureTools(
          controller: _controller,
          state: state,
          vertical: false,
          onInterval: () => _interval(state),
        ),
        _filmstrip(state, height: 74),
        _captureControls(state),
      ],
    );
  }

  Widget _landscapeBody(CaptureViewState state) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CaptureTools(
                  controller: _controller,
                  state: state,
                  vertical: true,
                  onInterval: () => _interval(state),
                ),
              ),
              Expanded(child: _filmstrip(state, height: double.infinity)),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: _preview(state)),
              Positioned(left: 12, right: 12, top: 4, child: _status(state)),
              if (state.camera.availability == CameraAvailability.ready)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _captureControls(state),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _preview(CaptureViewState state) => CameraPreviewSurface(
    controller: _controller,
    state: state,
    onOpenSettings: () =>
        ref.read(systemSettingsServiceProvider).openAppSettings(),
    onImport: _import,
  );

  Widget _status(CaptureViewState state) {
    if (state.importing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LinearProgressIndicator(
            value: state.importTotal == 0
                ? null
                : state.importProgress / state.importTotal,
          ),
          Text(
            'Importing ${state.importProgress} of ${state.importTotal}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    }
    if (state.errorMessage case final String error) {
      return MaterialBanner(
        content: Text(error),
        actions: <Widget>[
          IconButton(
            onPressed: _controller.clearError,
            tooltip: 'Dismiss error',
            icon: const Icon(Icons.close),
          ),
        ],
      );
    }
    if (state.intervalActive) {
      return Text(
        'Interval active - ${state.intervalFrameCount} captured',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _filmstrip(CaptureViewState state, {required double height}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: height.isFinite ? Axis.horizontal : Axis.vertical,
        padding: const EdgeInsets.all(6),
        itemCount: state.frames.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == state.frames.length) {
            return SizedBox.square(
              dimension: 62,
              child: IconButton(
                onPressed: state.importing ? null : _import,
                tooltip: 'Import images',
                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.white,
                ),
              ),
            );
          }
          final ProjectFrame frame = state.frames[index];
          return Padding(
            padding: const EdgeInsets.all(3),
            child: Semantics(
              button: true,
              label: 'Review frame ${index + 1}',
              child: InkWell(
                onTap: () => _reviewFrame(frame),
                child: SizedBox.square(
                  dimension: 62,
                  child: Image.file(
                    _controller.resolveFrame(frame),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Colors.black26,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _captureControls(CaptureViewState state) {
    final bool ready = state.camera.availability == CameraAvailability.ready;
    return ColoredBox(
      color: Colors.black87,
      child: SizedBox(
        height: 104,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: state.importing ? null : _import,
              tooltip: 'Import images',
              icon: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
              ),
            ),
            if (state.intervalActive)
              FilledButton.icon(
                onPressed: _controller.stopInterval,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              )
            else
              Semantics(
                button: true,
                label: state.capturing ? 'Saving frame' : 'Capture frame',
                child: SizedBox.square(
                  dimension: 72,
                  child: IconButton.filled(
                    onPressed: ready && !state.capturing
                        ? _controller.capture
                        : null,
                    tooltip: 'Capture frame',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: state.capturing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.camera_alt, size: 34),
                  ),
                ),
              ),
            IconButton(
              onPressed: state.frames.isEmpty
                  ? null
                  : () => context.push(AppRoutes.edit(widget.projectId)),
              tooltip: 'Open editor',
              icon: const Icon(Icons.movie_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _interval(CaptureViewState state) async {
    if (state.intervalActive) {
      await _controller.stopInterval();
      return;
    }
    var seconds = 3;
    final int? selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Interval capture',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Slider(
                  min: 1,
                  max: 60,
                  divisions: 59,
                  value: seconds.toDouble(),
                  label: '$seconds seconds',
                  onChanged: (double value) =>
                      setState(() => seconds = value.round()),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, seconds),
                  child: Text('Start every $seconds seconds'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected != null) {
      await _controller.startInterval(
        IntervalCaptureSettings(seconds: selected),
      );
    }
  }

  Future<void> _import() async {
    try {
      final List<CaptureSource> selected = await _controller.pickSources();
      if (selected.isEmpty || !mounted) {
        return;
      }
      final List<CaptureSource>? ordered = selected.length == 1
          ? selected
          : await _confirmImportOrder(selected);
      if (ordered != null) {
        await _controller.importSources(ordered);
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
      }
    }
  }

  Future<List<CaptureSource>?> _confirmImportOrder(
    List<CaptureSource> sources,
  ) async {
    final List<CaptureSource> ordered = List<CaptureSource>.of(sources);
    return showModalBottomSheet<List<CaptureSource>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Import order',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Drag images into timeline order.'),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: ordered.length,
                    onReorderItem: (int oldIndex, int newIndex) {
                      setState(() {
                        final CaptureSource item = ordered.removeAt(oldIndex);
                        ordered.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final CaptureSource source = ordered[index];
                      return ListTile(
                        key: ValueKey<String>(source.file.path),
                        leading: Text('${index + 1}'),
                        title: Text(source.file.uri.pathSegments.last),
                        trailing: const Icon(Icons.drag_handle),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, ordered),
                        child: Text('Import ${ordered.length} images'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reviewFrame(ProjectFrame frame) async {
    final DeletedFrame? deleted = await showModalBottomSheet<DeletedFrame>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => FractionallySizedBox(
        heightFactor: 0.96,
        child: FrameReviewPage(controller: _controller, initialFrame: frame),
      ),
    );
    if (deleted != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Frame deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _controller.undoDelete(deleted),
          ),
        ),
      );
    }
  }

  Future<void> _back() async {
    if (_controller.state.capturing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for the active frame to save.')),
      );
      await _controller.waitForActiveCapture();
    }
    await _controller.stopInterval();
    if (mounted) {
      context.go(AppRoutes.projects);
    }
  }
}

IconData _flashIcon(CameraFlash flash) => switch (flash) {
  CameraFlash.off => Icons.flash_off,
  CameraFlash.auto => Icons.flash_auto,
  CameraFlash.on => Icons.flash_on,
  CameraFlash.torch => Icons.highlight,
};
