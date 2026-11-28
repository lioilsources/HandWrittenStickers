import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

/// How an emoji sticker moves in its loop ([EmojiMotion.pose]).
enum EmojiMotionKind {
  breathe,
  pulse,
  bounce,
  wave,
  shake,
  nod,
  float,
  twinkle;

  static EmojiMotionKind parse(Object? name) => values.firstWhere(
    (m) => m.name == name,
    orElse: () => EmojiMotionKind.breathe,
  );
}

/// One animated emoji sticker a message can be tagged with, in one style.
///
/// The artwork is one cut-out image (`assets/emoji/<style>/<id>.webp`); the
/// animation is code ([EmojiMotion]), so preview and GIF export move
/// identically.
class EmojiTag {
  /// Stable key, e.g. `hand_thumbs_up`; the same in every style.
  final String id;
  final String category;

  /// Id of the [EmojiStyle] this artwork is drawn in ('' = the only one).
  final String style;

  /// Unicode emoji the sticker stands for (fallback text, semantics).
  final String emoji;

  /// Display name in the content language.
  final String name;

  /// Asset path of the sticker image.
  final String asset;
  final EmojiMotionKind motion;

  const EmojiTag({
    required this.id,
    required this.emoji,
    required this.name,
    required this.asset,
    this.category = '',
    this.style = '',
    this.motion = EmojiMotionKind.breathe,
  });

  @override
  bool operator ==(Object other) =>
      other is EmojiTag && other.id == id && other.style == style;

  @override
  int get hashCode => Object.hash(id, style);
}

/// A group of emoji in the picker.
class EmojiCategory {
  final String id;
  final String name;

  const EmojiCategory(this.id, this.name);
}

/// One art style the whole set is drawn in (paper, marker, clay). A style
/// with a [pack] needs that content pack for export, like a paid sheet.
class EmojiStyle {
  final String id;
  final String name;

  /// Content pack (`packs.json`) the style belongs to; null = free.
  final String? pack;

  const EmojiStyle(this.id, this.name, {this.pack});

  @override
  bool operator ==(Object other) => other is EmojiStyle && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Index of bundled emoji stickers, read from `assets/emoji/emoji.json`
/// (written by `tools/emoji/build.py`). Version 3 lists [styles] and a file
/// per style for each emoji; version 2 (one `file`) is a single unnamed
/// style.
class EmojiIndex {
  static const String dir = 'assets/emoji/';
  static const String assetPath = '${dir}emoji.json';

  final List<EmojiCategory> categories;

  /// Styles in display order; the first is the default (free) one.
  final List<EmojiStyle> styles;

  /// Every emoji in every style it is drawn in.
  final List<EmojiTag> all;

  EmojiIndex(
    this.all, {
    this.categories = const [],
    List<EmojiStyle> styles = const [],
  }) : styles = styles.isEmpty ? const [EmojiStyle('', '')] : styles;

  static Future<EmojiIndex> load({
    AssetBundle? bundle,
    String language = 'cs',
  }) async {
    final data =
        json.decode(await (bundle ?? rootBundle).loadString(assetPath))
            as Map<String, dynamic>;
    String text(Object? v) {
      if (v is Map) return (v[language] ?? v['en'] ?? v.values.first) as String;
      return v as String;
    }

    final styles = [
      for (final s in data['styles'] as List? ?? const [])
        EmojiStyle(
          s['id'] as String,
          text(s['name']),
          pack: s['pack'] as String?,
        ),
    ];
    final order = {for (final (i, s) in styles.indexed) s.id: i};
    final all = <EmojiTag>[];
    for (final e in data['emoji'] as List) {
      final files = e['files'] is Map
          ? (e['files'] as Map).cast<String, String>()
          : {'': e['file'] as String};
      for (final MapEntry(key: style, value: file) in files.entries) {
        if (styles.isNotEmpty && !order.containsKey(style)) continue;
        all.add(
          EmojiTag(
            id: e['id'] as String,
            category: e['category'] as String? ?? '',
            style: style,
            emoji: e['emoji'] as String,
            name: text(e['name']),
            asset: '$dir$file',
            motion: EmojiMotionKind.parse(e['motion']),
          ),
        );
      }
    }
    return EmojiIndex(
      all,
      styles: styles,
      categories: [
        for (final c in data['categories'] as List? ?? const [])
          EmojiCategory(c['id'] as String, text(c['name'])),
      ],
    );
  }

  /// The default style, shown first and free.
  EmojiStyle get defaultStyle => styles.first;

  EmojiStyle? styleById(String? id) {
    for (final s in styles) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Emoji of the default style.
  List<EmojiTag> get tags => inStyle(defaultStyle.id);

  List<EmojiTag> inStyle(String style) => [
    for (final t in all)
      if (t.style == style) t,
  ];

  /// [id] drawn in [style] (default: the default style).
  EmojiTag? byId(String? id, {String? style}) {
    style ??= defaultStyle.id;
    for (final t in all) {
      if (t.id == id && t.style == style) return t;
    }
    return null;
  }

  List<EmojiTag> inCategory(String category, {String? style}) {
    style ??= defaultStyle.id;
    return [
      for (final t in all)
        if (t.category == category && t.style == style) t,
    ];
  }
}

/// The sticker's transform at one moment of its loop. Offsets are fractions
/// of the sticker side; [pivotY] is where it rotates and squashes around
/// (0 = centre, 0.5 = bottom edge).
class EmojiPose {
  final double dx;
  final double dy;
  final double scaleX;
  final double scaleY;
  final double angle;
  final double pivotY;

  const EmojiPose({
    this.dx = 0,
    this.dy = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.angle = 0,
    this.pivotY = 0,
  });

  static const EmojiPose rest = EmojiPose();

  /// The transform for a sticker of [size], about the sticker's centre.
  Matrix4 matrix(double size) {
    final py = pivotY * size;
    return Matrix4.translationValues(dx * size, dy * size + py, 0)
      ..multiply(Matrix4.rotationZ(angle))
      ..multiply(Matrix4.diagonal3Values(scaleX, scaleY, 1))
      ..multiply(Matrix4.translationValues(0, -py, 0));
  }
}

/// The emoji animations as pure functions of loop phase, shared by the
/// on-screen widget and the animated export. Every motion rests at phase 0
/// and 1, so the loop is seamless and a still export shows the sticker
/// upright.
class EmojiMotion {
  EmojiMotion._();

  /// Length of one loop.
  static const Duration period = Duration(milliseconds: 2400);

  /// Frames per loop in the GIF export (100 ms each → 2.4 s).
  static const int gifFrames = 24;

  /// Progress 0..1 inside the window [a, b] of the loop, or null outside.
  static double? _window(double t, double a, double b) =>
      t < a || t > b ? null : (t - a) / (b - a);

  static double _hump(double u) =>
      math.pow(math.sin(math.pi * u), 2).toDouble();

  /// Pose of [kind] at loop phase [t] (0..1).
  static EmojiPose pose(EmojiMotionKind kind, double t) {
    t = t % 1.0;
    final p = 2 * math.pi * t;
    switch (kind) {
      case EmojiMotionKind.breathe:
        final breath = (1 - math.cos(p)) / 2; // 0 → 1 → 0
        return EmojiPose(
          dy: -0.05 * breath,
          scaleX: 1 + 0.07 * breath,
          scaleY: 1 + 0.07 * breath,
          angle: 0.08 * math.sin(p),
        );
      case EmojiMotionKind.pulse:
        final u1 = _window(t, 0, 0.18), u2 = _window(t, 0.22, 0.42);
        final double s =
            1 +
            (u1 != null ? 0.12 * _hump(u1) : 0.0) +
            (u2 != null ? 0.10 * _hump(u2) : 0.0);
        return EmojiPose(scaleX: s, scaleY: s);
      case EmojiMotionKind.bounce:
        final hop = _window(t, 0, 0.3) ?? _window(t, 0.3, 0.6);
        final land = _window(t, 0.6, 0.76);
        final h = hop == null ? 0.0 : math.sin(math.pi * hop);
        final sq = land == null ? 0.0 : math.sin(math.pi * land);
        return EmojiPose(
          dy: -0.08 * h,
          scaleX: 1 - 0.02 * h + 0.05 * sq,
          scaleY: 1 + 0.04 * h - 0.06 * sq,
          pivotY: 0.5,
        );
      case EmojiMotionKind.wave:
        final u = _window(t, 0, 0.6);
        final a = u == null
            ? 0.0
            : 0.14 * math.sin(3 * 2 * math.pi * u) * math.sin(math.pi * u);
        return EmojiPose(angle: a, pivotY: 0.5);
      case EmojiMotionKind.shake:
        final u = _window(t, 0, 0.6);
        return EmojiPose(
          dx: u == null ? 0 : 0.03 * math.sin(3 * 2 * math.pi * u) * (1 - u),
        );
      case EmojiMotionKind.nod:
        final u = _window(t, 0, 0.5);
        final e = u == null ? 0.0 : _hump(u);
        return EmojiPose(angle: 0.06 * e, dy: 0.03 * e, pivotY: 0.5);
      case EmojiMotionKind.float:
        return EmojiPose(
          dy: -0.04 * math.sin(p),
          angle: 0.04 * math.sin(2 * p),
        );
      case EmojiMotionKind.twinkle:
        final u = _window(t, 0, 0.25) ?? _window(t, 0.35, 0.6);
        if (u == null) return EmojiPose.rest;
        final s = 1 + 0.10 * _hump(u);
        return EmojiPose(
          angle: 0.12 * math.sin(2 * math.pi * u),
          scaleX: s,
          scaleY: s,
        );
    }
  }
}
