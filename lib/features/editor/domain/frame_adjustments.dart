import 'dart:convert';

enum FrameFit { fit, fill }

enum AdjustmentScope { frame, selection, subsequent }

enum AdjustmentControl {
  crop,
  straighten,
  rotation,
  flip,
  fit,
  exposure,
  contrast,
  highlights,
  shadows,
  temperature,
  tint,
  saturation,
  sharpening,
}

class NormalizedCrop {
  const NormalizedCrop({
    this.left = 0,
    this.top = 0,
    this.right = 1,
    this.bottom = 1,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  bool get isFull => left == 0 && top == 0 && right == 1 && bottom == 1;

  Map<String, Object> toJson() => <String, Object>{
    'l': left,
    't': top,
    'r': right,
    'b': bottom,
  };

  // Kept near serialization for readability.
  // ignore: sort_constructors_first
  factory NormalizedCrop.fromJson(Object? value) {
    final Map<String, Object?> map = value is Map<String, Object?>
        ? value
        : const <String, Object?>{};
    final double left = (map['l'] as num? ?? 0).toDouble().clamp(0, 0.98);
    final double top = (map['t'] as num? ?? 0).toDouble().clamp(0, 0.98);
    final double right = (map['r'] as num? ?? 1).toDouble().clamp(
      left + 0.01,
      1,
    );
    final double bottom = (map['b'] as num? ?? 1).toDouble().clamp(
      top + 0.01,
      1,
    );
    return NormalizedCrop(left: left, top: top, right: right, bottom: bottom);
  }
}

class FrameAdjustments {
  const FrameAdjustments({
    this.crop = const NormalizedCrop(),
    this.straighten = 0,
    this.quarterTurns = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.fit = FrameFit.fit,
    this.exposure = 0,
    this.contrast = 0,
    this.highlights = 0,
    this.shadows = 0,
    this.temperature = 0,
    this.tint = 0,
    this.saturation = 0,
    this.sharpening = 0,
  });

  final NormalizedCrop crop;
  final double straighten;
  final int quarterTurns;
  final bool flipHorizontal;
  final bool flipVertical;
  final FrameFit fit;
  final double exposure;
  final double contrast;
  final double highlights;
  final double shadows;
  final double temperature;
  final double tint;
  final double saturation;
  final double sharpening;

  bool get isIdentity =>
      crop.isFull &&
      straighten == 0 &&
      quarterTurns % 4 == 0 &&
      !flipHorizontal &&
      !flipVertical &&
      fit == FrameFit.fit &&
      exposure == 0 &&
      contrast == 0 &&
      highlights == 0 &&
      shadows == 0 &&
      temperature == 0 &&
      tint == 0 &&
      saturation == 0 &&
      sharpening == 0;

  FrameAdjustments copyWith({
    NormalizedCrop? crop,
    double? straighten,
    int? quarterTurns,
    bool? flipHorizontal,
    bool? flipVertical,
    FrameFit? fit,
    double? exposure,
    double? contrast,
    double? highlights,
    double? shadows,
    double? temperature,
    double? tint,
    double? saturation,
    double? sharpening,
  }) => FrameAdjustments(
    crop: crop ?? this.crop,
    straighten: (straighten ?? this.straighten).clamp(-45, 45),
    quarterTurns: (quarterTurns ?? this.quarterTurns) % 4,
    flipHorizontal: flipHorizontal ?? this.flipHorizontal,
    flipVertical: flipVertical ?? this.flipVertical,
    fit: fit ?? this.fit,
    exposure: (exposure ?? this.exposure).clamp(-2, 2),
    contrast: (contrast ?? this.contrast).clamp(-1, 1),
    highlights: (highlights ?? this.highlights).clamp(-1, 1),
    shadows: (shadows ?? this.shadows).clamp(-1, 1),
    temperature: (temperature ?? this.temperature).clamp(-1, 1),
    tint: (tint ?? this.tint).clamp(-1, 1),
    saturation: (saturation ?? this.saturation).clamp(-1, 1),
    sharpening: (sharpening ?? this.sharpening).clamp(0, 1),
  );

  FrameAdjustments reset(AdjustmentControl control) => switch (control) {
    AdjustmentControl.crop => copyWith(crop: const NormalizedCrop()),
    AdjustmentControl.straighten => copyWith(straighten: 0),
    AdjustmentControl.rotation => copyWith(quarterTurns: 0),
    AdjustmentControl.flip => copyWith(
      flipHorizontal: false,
      flipVertical: false,
    ),
    AdjustmentControl.fit => copyWith(fit: FrameFit.fit),
    AdjustmentControl.exposure => copyWith(exposure: 0),
    AdjustmentControl.contrast => copyWith(contrast: 0),
    AdjustmentControl.highlights => copyWith(highlights: 0),
    AdjustmentControl.shadows => copyWith(shadows: 0),
    AdjustmentControl.temperature => copyWith(temperature: 0),
    AdjustmentControl.tint => copyWith(tint: 0),
    AdjustmentControl.saturation => copyWith(saturation: 0),
    AdjustmentControl.sharpening => copyWith(sharpening: 0),
  };

  String encode() => jsonEncode(<String, Object>{
    'crop': crop.toJson(),
    'straighten': straighten,
    'quarterTurns': quarterTurns,
    'flipH': flipHorizontal,
    'flipV': flipVertical,
    'fit': fit.name,
    'exposure': exposure,
    'contrast': contrast,
    'highlights': highlights,
    'shadows': shadows,
    'temperature': temperature,
    'tint': tint,
    'saturation': saturation,
    'sharpening': sharpening,
  });

  // Kept near serialization for readability.
  // ignore: sort_constructors_first
  factory FrameAdjustments.decode(String value) {
    if (value.isEmpty || value == '{}') {
      return const FrameAdjustments();
    }
    try {
      final Map<String, Object?> map =
          jsonDecode(value) as Map<String, Object?>;
      double number(String key) => (map[key] as num? ?? 0).toDouble();
      return FrameAdjustments(
        crop: NormalizedCrop.fromJson(map['crop']),
        straighten: number('straighten').clamp(-45, 45),
        quarterTurns: (map['quarterTurns'] as int? ?? 0) % 4,
        flipHorizontal: map['flipH'] as bool? ?? false,
        flipVertical: map['flipV'] as bool? ?? false,
        fit: FrameFit.values.firstWhere(
          (FrameFit value) => value.name == map['fit'],
          orElse: () => FrameFit.fit,
        ),
        exposure: number('exposure').clamp(-2, 2),
        contrast: number('contrast').clamp(-1, 1),
        highlights: number('highlights').clamp(-1, 1),
        shadows: number('shadows').clamp(-1, 1),
        temperature: number('temperature').clamp(-1, 1),
        tint: number('tint').clamp(-1, 1),
        saturation: number('saturation').clamp(-1, 1),
        sharpening: number('sharpening').clamp(0, 1),
      );
    } on Object {
      return const FrameAdjustments();
    }
  }

  String get cacheKey => encode();
}
