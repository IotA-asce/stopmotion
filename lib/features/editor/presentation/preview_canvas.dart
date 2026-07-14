import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/media/frame_renderer.dart';
import '../../../core/widgets/rendered_frame_image.dart';
import '../../projects/domain/project.dart';
import '../domain/frame.dart';

class EditorPreviewCanvas extends StatelessWidget {
  const EditorPreviewCanvas({
    required this.project,
    required this.frame,
    required this.resolveFrame,
    required this.cache,
    super.key,
  });

  final Project project;
  final ProjectFrame? frame;
  final File Function(ProjectFrame frame) resolveFrame;
  final FramePreviewCache cache;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(project.backgroundColorValue),
      child: Center(
        child: AspectRatio(
          aspectRatio: project.aspectRatio.value,
          child: Semantics(
            label: frame == null
                ? 'Empty project preview'
                : 'Preview frame ${frame!.position + 1}',
            image: frame != null,
            child: _content(context),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final ProjectFrame? current = frame;
    if (current == null) {
      return const Center(child: Icon(Icons.movie_creation_outlined, size: 52));
    }
    if (current.missing) {
      return const Center(child: Icon(Icons.broken_image_outlined, size: 52));
    }
    return RenderedFrameImage(
      cache: cache,
      source: resolveFrame(current),
      adjustments: current.adjustments,
      targetWidth: project.aspectRatio.value >= 1 ? 640 : 360,
      targetHeight: project.aspectRatio.value >= 1 ? 360 : 640,
      backgroundColor: project.backgroundColorValue,
    );
  }
}
