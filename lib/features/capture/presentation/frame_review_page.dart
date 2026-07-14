import 'package:flutter/material.dart';

import '../../editor/domain/frame.dart';
import '../domain/capture_frame.dart';
import 'capture_controller.dart';

class FrameReviewPage extends StatefulWidget {
  const FrameReviewPage({
    required this.controller,
    required this.initialFrame,
    super.key,
  });

  final CaptureController controller;
  final ProjectFrame initialFrame;

  @override
  State<FrameReviewPage> createState() => _FrameReviewPageState();
}

class _FrameReviewPageState extends State<FrameReviewPage> {
  late ProjectFrame _frame = widget.initialFrame;
  bool _busy = false;

  void _move(int delta) {
    final List<ProjectFrame> frames = widget.controller.state.frames;
    final int current = frames.indexWhere(
      (ProjectFrame value) => value.id == _frame.id,
    );
    final int next = current + delta;
    if (current >= 0 && next >= 0 && next < frames.length) {
      setState(() => _frame = frames[next]);
    }
  }

  Future<void> _retake() async {
    setState(() => _busy = true);
    await widget.controller.retakeFrame(_frame);
    if (mounted) {
      final List<ProjectFrame> frames = widget.controller.state.frames;
      final ProjectFrame? updated = frames
          .where((ProjectFrame value) => value.id == _frame.id)
          .firstOrNull;
      setState(() {
        _frame = updated ?? _frame;
        _busy = false;
      });
    }
  }

  Future<void> _duplicate() async {
    setState(() => _busy = true);
    await widget.controller.duplicateFrame(_frame);
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    final DeletedFrame deleted = await widget.controller.deleteFrame(_frame);
    if (mounted) {
      Navigator.pop(context, deleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          tooltip: 'Close frame review',
          icon: const Icon(Icons.close),
        ),
        title: Text('Frame ${_frame.position + 1}'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Image.file(
                    widget.controller.resolveFrame(_frame),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: _frame.position > 0 ? () => _move(-1) : null,
                  tooltip: 'Previous frame',
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed:
                      _frame.position <
                          widget.controller.state.frames.length - 1
                      ? () => _move(1)
                      : null,
                  tooltip: 'Next frame',
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            if (_busy) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: _busy ? null : _retake,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Retake'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _duplicate,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Duplicate'),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete frame'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
