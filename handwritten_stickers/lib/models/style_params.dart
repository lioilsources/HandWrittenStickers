import 'package:flutter/material.dart';

/// Global style parameters for handwriting appearance
class StyleParams {
  /// Base spacing between letters (in pixels)
  final double letterSpacing;

  /// Space width as multiplier of average glyph width
  final double wordSpacing;

  /// Line height as multiplier of glyph height
  final double lineHeight;

  /// How much the baseline wobbles (0-1)
  final double baselineWobble;

  /// Size variance (0-1)
  final double sizeVariance;

  /// Rotation variance (0-1)
  final double rotationVariance;

  /// Opacity variance for ink pressure simulation (0-1)
  final double opacityVariance;

  /// Ink color
  final Color inkColor;

  const StyleParams({
    this.letterSpacing = 0,
    this.wordSpacing = 1.0,
    this.lineHeight = 1.2,
    this.baselineWobble = 0.3,
    this.sizeVariance = 0.1,
    this.rotationVariance = 0.2,
    this.opacityVariance = 0.1,
    this.inkColor = Colors.black,
  });

  /// Neat, careful handwriting
  static StyleParams neat() => const StyleParams(
        letterSpacing: 2,
        wordSpacing: 1.2,
        lineHeight: 1.3,
        baselineWobble: 0.1,
        sizeVariance: 0.05,
        rotationVariance: 0.1,
        opacityVariance: 0.05,
      );

  /// Casual, everyday handwriting
  static StyleParams casual() => const StyleParams(
        letterSpacing: 0,
        wordSpacing: 1.0,
        lineHeight: 1.2,
        baselineWobble: 0.3,
        sizeVariance: 0.15,
        rotationVariance: 0.3,
        opacityVariance: 0.1,
      );

  /// Chaotic, rushed handwriting
  static StyleParams chaotic() => const StyleParams(
        letterSpacing: -2,
        wordSpacing: 0.8,
        lineHeight: 1.1,
        baselineWobble: 0.7,
        sizeVariance: 0.3,
        rotationVariance: 0.6,
        opacityVariance: 0.2,
      );

  /// Fast, quick notes style
  static StyleParams fast() => const StyleParams(
        letterSpacing: 4,
        wordSpacing: 1.1,
        lineHeight: 1.15,
        baselineWobble: 0.5,
        sizeVariance: 0.2,
        rotationVariance: 0.4,
        opacityVariance: 0.15,
      );

  StyleParams copyWith({
    double? letterSpacing,
    double? wordSpacing,
    double? lineHeight,
    double? baselineWobble,
    double? sizeVariance,
    double? rotationVariance,
    double? opacityVariance,
    Color? inkColor,
  }) {
    return StyleParams(
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      baselineWobble: baselineWobble ?? this.baselineWobble,
      sizeVariance: sizeVariance ?? this.sizeVariance,
      rotationVariance: rotationVariance ?? this.rotationVariance,
      opacityVariance: opacityVariance ?? this.opacityVariance,
      inkColor: inkColor ?? this.inkColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StyleParams &&
        other.letterSpacing == letterSpacing &&
        other.wordSpacing == wordSpacing &&
        other.lineHeight == lineHeight &&
        other.baselineWobble == baselineWobble &&
        other.sizeVariance == sizeVariance &&
        other.rotationVariance == rotationVariance &&
        other.opacityVariance == opacityVariance &&
        other.inkColor == inkColor;
  }

  @override
  int get hashCode => Object.hash(
        letterSpacing,
        wordSpacing,
        lineHeight,
        baselineWobble,
        sizeVariance,
        rotationVariance,
        opacityVariance,
        inkColor,
      );
}

/// Preset style enumeration
enum StylePreset {
  neat('Neat'),
  casual('Casual'),
  chaotic('Chaotic'),
  fast('Fast'),
  custom('Custom');

  final String label;
  const StylePreset(this.label);

  StyleParams toStyleParams() {
    switch (this) {
      case StylePreset.neat:
        return StyleParams.neat();
      case StylePreset.casual:
        return StyleParams.casual();
      case StylePreset.chaotic:
        return StyleParams.chaotic();
      case StylePreset.fast:
        return StyleParams.fast();
      case StylePreset.custom:
        return StyleParams.casual();
    }
  }
}
