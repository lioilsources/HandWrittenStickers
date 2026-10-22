import 'dart:convert';

import 'package:flutter/services.dart';

/// A paid content pack: a curated set of glyph sheets and presets, or a
/// feature (saving presets). One non-consumable store product each.
///
/// Read from `assets/packs/packs.json`; sheets and presets name their pack
/// in their own `pack` key.
class ContentPack {
  /// Pack id, e.g. `calligraphy`. [allId] is the bundle of every pack.
  final String id;

  /// Store product id, the same in App Store Connect and Play Console.
  final String productId;
  final String name;
  final String description;

  /// Short text the paywall renders in the pack's sheets.
  final String? sampleText;

  /// Feature the pack unlocks instead of (or besides) content, e.g.
  /// [savePresetsFeature].
  final String? feature;

  /// The pack contains every other pack ([allId]).
  final bool includesAll;
  final int order;

  static const String allId = 'all';
  static const String savePresetsFeature = 'savePresets';

  const ContentPack({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    this.sampleText,
    this.feature,
    this.includesAll = false,
    this.order = 0,
  });

  factory ContentPack.fromJson(
    Map<String, dynamic> json, {
    String language = 'cs',
  }) {
    String text(Object? v) {
      if (v is Map) {
        return (v[language] ?? v['en'] ?? v.values.first) as String;
      }
      return (v as String?) ?? '';
    }

    return ContentPack(
      id: json['id'] as String,
      productId: json['product'] as String,
      name: text(json['name']),
      description: text(json['description']),
      sampleText: json['sampleText'] as String?,
      feature: json['feature'] as String?,
      includesAll: json['includes'] == '*',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) => other is ContentPack && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Every pack from `assets/packs/packs.json`, in display order.
class PackIndex {
  static const String assetPath = 'assets/packs/packs.json';

  final List<ContentPack> packs;

  const PackIndex(this.packs);

  static const PackIndex empty = PackIndex([]);

  ContentPack? byId(String? id) {
    for (final p in packs) {
      if (p.id == id) return p;
    }
    return null;
  }

  ContentPack? byProduct(String productId) {
    for (final p in packs) {
      if (p.productId == productId) return p;
    }
    return null;
  }

  /// The pack that unlocks [feature], if any.
  ContentPack? forFeature(String feature) {
    for (final p in packs) {
      if (p.feature == feature) return p;
    }
    return null;
  }

  /// The "everything" bundle, if the index has one.
  ContentPack? get all {
    for (final p in packs) {
      if (p.includesAll) return p;
    }
    return null;
  }

  /// Every pack except the bundle.
  List<ContentPack> get single => [
    for (final p in packs)
      if (!p.includesAll) p,
  ];

  Set<String> get productIds => {for (final p in packs) p.productId};

  static Future<PackIndex> load({
    AssetBundle? bundle,
    String language = 'cs',
  }) async {
    final text = await (bundle ?? rootBundle).loadString(assetPath);
    final data = json.decode(text) as Map<String, dynamic>;
    final packs = [
      for (final e in data['packs'] as List)
        ContentPack.fromJson(
          (e as Map).cast<String, dynamic>(),
          language: language,
        ),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return PackIndex(packs);
  }
}
