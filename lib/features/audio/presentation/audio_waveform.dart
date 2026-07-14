import 'dart:math' as math;

import 'package:flutter/material.dart';

class AudioWaveform extends StatelessWidget {
  const AudioWaveform({required this.samples, required this.color, super.key});

  final List<double> samples;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveformPainter(samples, color),
      size: const Size(double.infinity, 44),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter(this.samples, this.color);

  final List<double> samples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    if (samples.isEmpty) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }
    final double step = size.width / samples.length;
    for (var index = 0; index < samples.length; index++) {
      final double height = math.max(2, samples[index] * size.height);
      final double x = (index + 0.5) * step;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.color != color;
}
