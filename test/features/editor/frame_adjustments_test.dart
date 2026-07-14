import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/editor/domain/frame_adjustments.dart';

void main() {
  test('adjustments serialize deterministically and clamp unsafe values', () {
    final FrameAdjustments value = FrameAdjustments.decode(
      FrameAdjustments(
        crop: const NormalizedCrop(
          left: 0.1,
          top: 0.2,
          right: 0.8,
          bottom: 0.9,
        ),
        straighten: 12.5,
        quarterTurns: 3,
        flipHorizontal: true,
        fit: FrameFit.fill,
        exposure: 1.2,
        contrast: -0.4,
        highlights: 0.2,
        shadows: -0.3,
        temperature: 0.5,
        tint: -0.2,
        saturation: 0.8,
        sharpening: 0.6,
      ).encode(),
    );

    expect(value.crop.left, 0.1);
    expect(value.straighten, 12.5);
    expect(value.quarterTurns, 3);
    expect(value.flipHorizontal, isTrue);
    expect(value.fit, FrameFit.fill);
    expect(value.sharpening, 0.6);
    expect(FrameAdjustments.decode(value.encode()).encode(), value.encode());
    expect(value.copyWith(exposure: 99).exposure, 2);
  });

  test('per-control and reset-all restore identity', () {
    final FrameAdjustments value = const FrameAdjustments()
        .copyWith(exposure: 1, saturation: 0.5)
        .reset(AdjustmentControl.exposure)
        .reset(AdjustmentControl.saturation);
    expect(value.isIdentity, isTrue);
    expect(const FrameAdjustments().isIdentity, isTrue);
  });

  test('invalid serialized state falls back without crashing', () {
    expect(FrameAdjustments.decode('not-json').isIdentity, isTrue);
  });
}
