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

  /// Join neighbouring letters with a pen stroke where the sheet knows how
  /// (handwriting sheets with entry/exit points).
  final bool joinLetters;

  /// Text size relative to the editor's base glyph height (1.0 = default).
  /// Stored in presets; the editor does not offer it yet.
  final double fontScale;

  /// Export without the white background. Stored in presets; the editor
  /// does not offer it yet.
  final bool transparentBackground;

  const StyleParams({
    this.letterSpacing = 0,
    this.wordSpacing = 1.0,
    this.lineHeight = 1.2,
    this.baselineWobble = 0.3,
    this.sizeVariance = 0.1,
    this.rotationVariance = 0.2,
    this.opacityVariance = 0.1,
    this.inkColor = Colors.black,
    this.joinLetters = true,
    this.fontScale = 1.0,
    this.transparentBackground = true,
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
    bool? joinLetters,
    double? fontScale,
    bool? transparentBackground,
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
      joinLetters: joinLetters ?? this.joinLetters,
      fontScale: fontScale ?? this.fontScale,
      transparentBackground:
          transparentBackground ?? this.transparentBackground,
    );
  }

  /// JSON form used by presets (`assets/presets/presets.json` and the
  /// user's saved presets). Colours are `#rrggbb`.
  Map<String, dynamic> toJson() => {
    'letterSpacing': letterSpacing,
    'wordSpacing': wordSpacing,
    'lineHeight': lineHeight,
    'baselineWobble': baselineWobble,
    'sizeVariance': sizeVariance,
    'rotationVariance': rotationVariance,
    'opacityVariance': opacityVariance,
    'inkColor': colorToHex(inkColor),
    'joinLetters': joinLetters,
    'fontScale': fontScale,
    'transparentBackground': transparentBackground,
  };

  /// Reads [toJson] output. Missing or malformed keys take the defaults of
  /// `StyleParams()`, unknown keys are ignored, so presets saved by older
  /// or newer app versions still load.
  factory StyleParams.fromJson(Map<String, dynamic> json) {
    const d = StyleParams();
    double num_(String key, double fallback) {
      final v = json[key];
      return v is num ? v.toDouble() : fallback;
    }

    bool bool_(String key, bool fallback) {
      final v = json[key];
      return v is bool ? v : fallback;
    }

    final ink = json['inkColor'];
    return StyleParams(
      letterSpacing: num_('letterSpacing', d.letterSpacing),
      wordSpacing: num_('wordSpacing', d.wordSpacing),
      lineHeight: num_('lineHeight', d.lineHeight),
      baselineWobble: num_('baselineWobble', d.baselineWobble),
      sizeVariance: num_('sizeVariance', d.sizeVariance),
      rotationVariance: num_('rotationVariance', d.rotationVariance),
      opacityVariance: num_('opacityVariance', d.opacityVariance),
      inkColor: (ink is String ? colorFromHex(ink) : null) ?? d.inkColor,
      joinLetters: bool_('joinLetters', d.joinLetters),
      fontScale: num_('fontScale', d.fontScale),
      transparentBackground: bool_(
        'transparentBackground',
        d.transparentBackground,
      ),
    );
  }

  static String colorToHex(Color c) {
    final rgb = c.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  /// Parses `#rrggbb` (alpha is always opaque); null when malformed.
  static Color? colorFromHex(String s) {
    final hex = s.startsWith('#') ? s.substring(1) : s;
    if (hex.length != 6) return null;
    final v = int.tryParse(hex, radix: 16);
    return v == null ? null : Color(0xFF000000 | v);
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
        other.inkColor == inkColor &&
        other.joinLetters == joinLetters &&
        other.fontScale == fontScale &&
        other.transparentBackground == transparentBackground;
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
    joinLetters,
    fontScale,
    transparentBackground,
  );
}
