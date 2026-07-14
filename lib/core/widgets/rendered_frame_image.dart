import 'dart:io';

import 'package:flutter/material.dart';

import '../../features/editor/domain/frame_adjustments.dart';
import '../media/frame_renderer.dart';

class RenderedFrameImage extends StatefulWidget {
  const RenderedFrameImage({
    required this.cache,
    required this.source,
    required this.adjustments,
    required this.targetWidth,
    required this.targetHeight,
    required this.backgroundColor,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.medium,
    this.error,
    super.key,
  });

  final FramePreviewCache cache;
  final File source;
  final FrameAdjustments adjustments;
  final int targetWidth;
  final int targetHeight;
  final int backgroundColor;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final Widget? error;

  @override
  State<RenderedFrameImage> createState() => _RenderedFrameImageState();
}

class _RenderedFrameImageState extends State<RenderedFrameImage> {
  late Future<RenderedFrame> _rendered = _read();

  @override
  void didUpdateWidget(RenderedFrameImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cache != widget.cache ||
        oldWidget.source.path != widget.source.path ||
        oldWidget.adjustments.cacheKey != widget.adjustments.cacheKey ||
        oldWidget.targetWidth != widget.targetWidth ||
        oldWidget.targetHeight != widget.targetHeight ||
        oldWidget.backgroundColor != widget.backgroundColor) {
      _rendered = _read();
    }
  }

  Future<RenderedFrame> _read() => widget.cache.read(
    source: widget.source,
    adjustments: widget.adjustments,
    targetWidth: widget.targetWidth,
    targetHeight: widget.targetHeight,
    backgroundColor: widget.backgroundColor,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RenderedFrame>(
      future: _rendered,
      builder: (BuildContext context, AsyncSnapshot<RenderedFrame> snapshot) {
        if (snapshot.hasError) {
          return widget.error ??
              const Center(child: Icon(Icons.broken_image_outlined, size: 52));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Image.memory(
          snapshot.data!.bytes,
          fit: widget.fit,
          filterQuality: widget.filterQuality,
        );
      },
    );
  }
}
