import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

/// One animated emoji sticker a message can be tagged with.
///
/// The artwork is a cut-out sticker (`assets/emoji/<codepoints>.webp`, same
/// style as SwypeKids); the animation is code ([EmojiMotion]), so preview and
/// GIF export move identically.
class EmojiTag {
  final String emoji;

  /// Czech display name (picker tooltip, semantics).
  final String name;

  /// Asset path of the sticker image.
  final String asset;

  const EmojiTag({required this.emoji, required this.name, required this.asset});

  @override
  bool operator ==(Object other) => other is EmojiTag && other.emoji == emoji;

  @override
  int get hashCode => emoji.hashCode;
}

/// Index of bundled emoji stickers, read from `assets/emoji/emoji.json`
/// (written by `tools/emoji/build.py`).
class EmojiIndex {
  static const String dir = 'assets/emoji/';
  static const String assetPath = '${dir}emoji.json';

  final List<EmojiTag> tags;

  const EmojiIndex(this.tags);

  static Future<EmojiIndex> load({AssetBundle? bundle}) async {
    final data =
        json.decode(await (bundle ?? rootBundle).loadString(assetPath))
            as Map<String, dynamic>;
    return EmojiIndex([
      for (final e in data['emoji'] as List)
        EmojiTag(
          emoji: e['emoji'] as String,
          name: e['name'] as String,
          asset: '$dir${e['file']}',
        ),
    ]);
  }
}

/// The sticker's idle animation as a pure function of loop phase, shared by
/// the on-screen widget and the animated export.
///
/// One loop: the sticker lifts and swells a little ("breathes") while it
/// rocks side to side. Phase 0 and 1 are identical, so the loop is seamless.
class EmojiMotion {
  EmojiMotion._();

  /// Length of one loop.
  static const Duration period = Duration(milliseconds: 2400);

  /// Frames per loop in the GIF export (100 ms each → 2.4 s).
  static const int gifFrames = 24;

  /// Transform at loop phase [t] (0..1): vertical offset as a fraction of
  /// the sticker size (negative = up), scale factor and rotation in radians.
  static ({double lift, double scale, double angle}) at(double t) {
    final p = 2 * math.pi * (t % 1.0);
    final breath = (1 - math.cos(p)) / 2; // 0 → 1 → 0
    return (
      lift: -0.05 * breath,
      scale: 1 + 0.07 * breath,
      angle: 0.08 * math.sin(p),
    );
  }
}
