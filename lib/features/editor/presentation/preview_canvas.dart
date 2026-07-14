import 'dart:io';

import 'package:flutter/material.dart';

import '../../projects/domain/project.dart';
import '../domain/frame.dart';

class EditorPreviewCanvas extends StatelessWidget {
  const EditorPreviewCanvas({
    required this.project,
    required this.frame,
    required this.resolveFrame,
    super.key,
  });

  final Project project;
  final ProjectFrame? frame;
  final File Function(ProjectFrame frame) resolveFrame;

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
    return Image.file(
      resolveFrame(current),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Center(child: Icon(Icons.broken_image_outlined, size: 52)),
      filterQuality: FilterQuality.medium,
    );
  }
}
