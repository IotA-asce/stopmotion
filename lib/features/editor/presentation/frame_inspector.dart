import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/media/frame_renderer.dart';
import '../../../core/widgets/rendered_frame_image.dart';
import '../domain/frame.dart';
import '../domain/frame_adjustments.dart';
import 'crop_editor.dart';

class FrameInspector extends StatefulWidget {
  const FrameInspector({
    required this.frame,
    required this.source,
    required this.cache,
    required this.backgroundColor,
    required this.onApply,
    super.key,
  });

  final ProjectFrame frame;
  final File source;
  final FramePreviewCache cache;
  final int backgroundColor;
  final Future<void> Function(FrameAdjustments, AdjustmentScope) onApply;

  @override
  State<FrameInspector> createState() => _FrameInspectorState();
}

class _FrameInspectorState extends State<FrameInspector> {
  late FrameAdjustments _value = widget.frame.adjustments;
  AdjustmentScope _scope = AdjustmentScope.frame;
  bool _before = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Adjust frame ${widget.frame.position + 1}'),
              subtitle: const Text('Hold preview to compare original'),
              trailing: IconButton(
                tooltip: 'Reset all adjustments',
                onPressed: () =>
                    setState(() => _value = const FrameAdjustments()),
                icon: const Icon(Icons.restart_alt),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  Listener(
                    onPointerDown: (_) => setState(() => _before = true),
                    onPointerUp: (_) => setState(() => _before = false),
                    onPointerCancel: (_) => setState(() => _before = false),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _before
                          ? Image.file(widget.source, fit: BoxFit.contain)
                          : RenderedFrameImage(
                              cache: widget.cache,
                              source: widget.source,
                              adjustments: _value,
                              targetWidth: 640,
                              targetHeight: 360,
                              backgroundColor: widget.backgroundColor,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<FrameFit>(
                    segments: const <ButtonSegment<FrameFit>>[
                      ButtonSegment(
                        value: FrameFit.fit,
                        label: Text('Fit'),
                        icon: Icon(Icons.fit_screen),
                      ),
                      ButtonSegment(
                        value: FrameFit.fill,
                        label: Text('Fill'),
                        icon: Icon(Icons.crop_free),
                      ),
                    ],
                    selected: <FrameFit>{_value.fit},
                    onSelectionChanged: (Set<FrameFit> value) => setState(
                      () => _value = _value.copyWith(fit: value.single),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Rotate left',
                        onPressed: () => setState(
                          () => _value = _value.copyWith(
                            quarterTurns: _value.quarterTurns + 3,
                          ),
                        ),
                        icon: const Icon(Icons.rotate_left),
                      ),
                      IconButton(
                        tooltip: 'Rotate right',
                        onPressed: () => setState(
                          () => _value = _value.copyWith(
                            quarterTurns: _value.quarterTurns + 1,
                          ),
                        ),
                        icon: const Icon(Icons.rotate_right),
                      ),
                      IconButton(
                        tooltip: 'Flip horizontally',
                        onPressed: () => setState(
                          () => _value = _value.copyWith(
                            flipHorizontal: !_value.flipHorizontal,
                          ),
                        ),
                        icon: const Icon(Icons.flip),
                      ),
                      IconButton(
                        tooltip: 'Flip vertically',
                        onPressed: () => setState(
                          () => _value = _value.copyWith(
                            flipVertical: !_value.flipVertical,
                          ),
                        ),
                        icon: const RotatedBox(
                          quarterTurns: 1,
                          child: Icon(Icons.flip),
                        ),
                      ),
                    ],
                  ),
                  CropEditor(
                    crop: _value.crop,
                    onChanged: (NormalizedCrop crop) =>
                        setState(() => _value = _value.copyWith(crop: crop)),
                  ),
                  _slider(
                    'Straighten',
                    _value.straighten,
                    -45,
                    45,
                    AdjustmentControl.straighten,
                    (double value) => _value.copyWith(straighten: value),
                  ),
                  _slider(
                    'Exposure',
                    _value.exposure,
                    -2,
                    2,
                    AdjustmentControl.exposure,
                    (double value) => _value.copyWith(exposure: value),
                  ),
                  _slider(
                    'Contrast',
                    _value.contrast,
                    -1,
                    1,
                    AdjustmentControl.contrast,
                    (double value) => _value.copyWith(contrast: value),
                  ),
                  _slider(
                    'Highlights',
                    _value.highlights,
                    -1,
                    1,
                    AdjustmentControl.highlights,
                    (double value) => _value.copyWith(highlights: value),
                  ),
                  _slider(
                    'Shadows',
                    _value.shadows,
                    -1,
                    1,
                    AdjustmentControl.shadows,
                    (double value) => _value.copyWith(shadows: value),
                  ),
                  _slider(
                    'Temperature',
                    _value.temperature,
                    -1,
                    1,
                    AdjustmentControl.temperature,
                    (double value) => _value.copyWith(temperature: value),
                  ),
                  _slider(
                    'Tint',
                    _value.tint,
                    -1,
                    1,
                    AdjustmentControl.tint,
                    (double value) => _value.copyWith(tint: value),
                  ),
                  _slider(
                    'Saturation',
                    _value.saturation,
                    -1,
                    1,
                    AdjustmentControl.saturation,
                    (double value) => _value.copyWith(saturation: value),
                  ),
                  _slider(
                    'Sharpening',
                    _value.sharpening,
                    0,
                    1,
                    AdjustmentControl.sharpening,
                    (double value) => _value.copyWith(sharpening: value),
                  ),
                  DropdownButtonFormField<AdjustmentScope>(
                    initialValue: _scope,
                    decoration: const InputDecoration(labelText: 'Apply to'),
                    items: const <DropdownMenuItem<AdjustmentScope>>[
                      DropdownMenuItem(
                        value: AdjustmentScope.frame,
                        child: Text('This frame'),
                      ),
                      DropdownMenuItem(
                        value: AdjustmentScope.selection,
                        child: Text('Selection'),
                      ),
                      DropdownMenuItem(
                        value: AdjustmentScope.subsequent,
                        child: Text('This and subsequent frames'),
                      ),
                    ],
                    onChanged: (AdjustmentScope? value) =>
                        setState(() => _scope = value!),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await widget.onApply(_value, _scope);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Apply'),
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

  Widget _slider(
    String label,
    double value,
    double minimum,
    double maximum,
    AdjustmentControl control,
    FrameAdjustments Function(double) update,
  ) => Row(
    children: <Widget>[
      SizedBox(width: 88, child: Text(label)),
      Expanded(
        child: Slider(
          value: value,
          min: minimum,
          max: maximum,
          divisions: 100,
          label: value.toStringAsFixed(2),
          onChanged: (double next) => setState(() => _value = update(next)),
        ),
      ),
      SizedBox(width: 42, child: Text(value.toStringAsFixed(1))),
      IconButton(
        tooltip: 'Reset $label',
        onPressed: () => setState(() => _value = _value.reset(control)),
        icon: const Icon(Icons.refresh, size: 18),
      ),
    ],
  );
}
