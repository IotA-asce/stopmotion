import 'package:flutter/material.dart';

import '../domain/frame_adjustments.dart';

class CropEditor extends StatelessWidget {
  const CropEditor({required this.crop, required this.onChanged, super.key});

  final NormalizedCrop crop;
  final ValueChanged<NormalizedCrop> onChanged;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.crop),
      title: const Text('Crop'),
      children: <Widget>[
        _edge('Left', crop.left, 0, crop.right - 0.05, (double value) {
          onChanged(
            NormalizedCrop(
              left: value,
              top: crop.top,
              right: crop.right,
              bottom: crop.bottom,
            ),
          );
        }),
        _edge('Right', crop.right, crop.left + 0.05, 1, (double value) {
          onChanged(
            NormalizedCrop(
              left: crop.left,
              top: crop.top,
              right: value,
              bottom: crop.bottom,
            ),
          );
        }),
        _edge('Top', crop.top, 0, crop.bottom - 0.05, (double value) {
          onChanged(
            NormalizedCrop(
              left: crop.left,
              top: value,
              right: crop.right,
              bottom: crop.bottom,
            ),
          );
        }),
        _edge('Bottom', crop.bottom, crop.top + 0.05, 1, (double value) {
          onChanged(
            NormalizedCrop(
              left: crop.left,
              top: crop.top,
              right: crop.right,
              bottom: value,
            ),
          );
        }),
      ],
    );
  }

  Widget _edge(
    String label,
    double value,
    double minimum,
    double maximum,
    ValueChanged<double> changed,
  ) => Row(
    children: <Widget>[
      SizedBox(width: 64, child: Text(label)),
      Expanded(
        child: Slider(
          value: value.clamp(minimum, maximum),
          min: minimum,
          max: maximum,
          label: '${(value * 100).round()}%',
          onChanged: changed,
        ),
      ),
      SizedBox(width: 48, child: Text('${(value * 100).round()}%')),
    ],
  );
}
