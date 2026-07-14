import 'package:flutter/material.dart';

enum PreviewQuality { automatic, full, performance }

class PreviewQualityMenu extends StatelessWidget {
  const PreviewQualityMenu({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PreviewQuality value;
  final ValueChanged<PreviewQuality> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PreviewQuality>(
      tooltip: 'Preview quality',
      initialValue: value,
      onSelected: onChanged,
      icon: const Icon(Icons.high_quality_outlined),
      itemBuilder: (BuildContext context) =>
          const <PopupMenuEntry<PreviewQuality>>[
            PopupMenuItem(
              value: PreviewQuality.automatic,
              child: Text('Automatic quality'),
            ),
            PopupMenuItem(
              value: PreviewQuality.full,
              child: Text('Full quality'),
            ),
            PopupMenuItem(
              value: PreviewQuality.performance,
              child: Text('Performance quality'),
            ),
          ],
    );
  }
}
