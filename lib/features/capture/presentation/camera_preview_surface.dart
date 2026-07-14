import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/media/camera_service.dart';
import '../../editor/domain/frame.dart';
import '../domain/capture_frame.dart';
import 'capture_controller.dart';

class CameraPreviewSurface extends StatelessWidget {
  const CameraPreviewSurface({
    required this.controller,
    required this.state,
    required this.onOpenSettings,
    required this.onImport,
    super.key,
  });

  final CaptureController controller;
  final CaptureViewState state;
  final VoidCallback onOpenSettings;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: switch (state.camera.availability) {
        CameraAvailability.ready => _readyPreview(),
        CameraAvailability.initializing || CameraAvailability.idle =>
          const Center(child: CircularProgressIndicator()),
        CameraAvailability.denied ||
        CameraAvailability.restricted => _CameraUnavailable(
          icon: Icons.no_photography_outlined,
          title: 'Camera access is off',
          message:
              state.camera.message ??
              'Allow access in Settings, or import images to continue.',
          onPrimary: onOpenSettings,
          primaryLabel: 'Open settings',
          onImport: onImport,
        ),
        CameraAvailability.unavailable ||
        CameraAvailability.failed => _CameraUnavailable(
          icon: Icons.videocam_off_outlined,
          title: 'Camera is unavailable',
          message:
              state.camera.message ??
              'Retry the camera or import images to continue.',
          onPrimary: controller.resume,
          primaryLabel: 'Retry camera',
          onImport: onImport,
        ),
        CameraAvailability.paused => const Center(
          child: Text('Camera paused', style: TextStyle(color: Colors.white)),
        ),
      },
    );
  }

  Widget _readyPreview() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _PreviewGesture(
          controller: controller,
          state: state,
          constraints: constraints,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              controller.camera.buildPreview(),
              ..._onionLayers(),
              if (state.grid != CaptureGrid.off)
                IgnorePointer(
                  child: CustomPaint(painter: CaptureGridPainter(state.grid)),
                ),
              Positioned(
                right: 12,
                bottom: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '${state.zoom.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (state.countdown case final int seconds)
                ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$seconds',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: controller.cancelCountdown,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _onionLayers() {
    if (state.frames.isEmpty || state.onionMode == OnionMode.off) {
      return const <Widget>[];
    }
    final List<ProjectFrame> frames = state.onionMode == OnionMode.previousTwo
        ? state.frames.reversed.take(2).toList(growable: false)
        : <ProjectFrame>[state.frames.last];
    return frames.indexed
        .map(((int, ProjectFrame) entry) {
          final File file = controller.resolveFrame(entry.$2);
          final double opacity = state.onionOpacity / (entry.$1 + 1);
          Widget image = Image.file(
            file,
            fit: BoxFit.contain,
            opacity: AlwaysStoppedAnimation<double>(opacity),
          );
          if (state.onionMode == OnionMode.difference) {
            image = ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.difference,
              ),
              child: image,
            );
          }
          return IgnorePointer(child: Center(child: image));
        })
        .toList(growable: false);
  }
}

class _PreviewGesture extends StatefulWidget {
  const _PreviewGesture({
    required this.controller,
    required this.state,
    required this.constraints,
    required this.child,
  });

  final CaptureController controller;
  final CaptureViewState state;
  final BoxConstraints constraints;
  final Widget child;

  @override
  State<_PreviewGesture> createState() => _PreviewGestureState();
}

class _PreviewGestureState extends State<_PreviewGesture> {
  double _baseZoom = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (TapDownDetails details) {
        unawaited(
          widget.controller.focus(
            Offset(
              details.localPosition.dx / widget.constraints.maxWidth,
              details.localPosition.dy / widget.constraints.maxHeight,
            ),
          ),
        );
      },
      onScaleStart: (_) => _baseZoom = widget.state.zoom,
      onScaleUpdate: (ScaleUpdateDetails details) {
        final capabilities = widget.state.camera.capabilities;
        if (capabilities == null) {
          return;
        }
        final double zoom = (_baseZoom * details.scale).clamp(
          capabilities.minimumZoom,
          capabilities.maximumZoom,
        );
        unawaited(widget.controller.setZoom(zoom));
      },
      child: widget.child,
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({
    required this.icon,
    required this.title,
    required this.message,
    required this.onPrimary,
    required this.primaryLabel,
    required this.onImport,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                OutlinedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Import images'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CaptureGridPainter extends CustomPainter {
  const CaptureGridPainter(this.mode);

  final CaptureGrid mode;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;
    switch (mode) {
      case CaptureGrid.off:
        return;
      case CaptureGrid.thirds:
        for (final double fraction in <double>[1 / 3, 2 / 3]) {
          canvas.drawLine(
            Offset(size.width * fraction, 0),
            Offset(size.width * fraction, size.height),
            paint,
          );
          canvas.drawLine(
            Offset(0, size.height * fraction),
            Offset(size.width, size.height * fraction),
            paint,
          );
        }
      case CaptureGrid.square:
        final double edge = size.shortestSide;
        final Rect square = Rect.fromCenter(
          center: size.center(Offset.zero),
          width: edge,
          height: edge,
        );
        canvas.drawRect(square, paint..style = PaintingStyle.stroke);
      case CaptureGrid.crosshair:
        canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(CaptureGridPainter oldDelegate) =>
      oldDelegate.mode != mode;
}
