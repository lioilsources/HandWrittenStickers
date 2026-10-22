import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Visual category of a sheet, used to group the sheet selector.
enum SheetCategory {
  handwriting('Handwriting'),
  calligraphy('Calligraphy'),
  typography('Typography'),
  kids('Kids'),
  material('Material');

  final String label;
  const SheetCategory(this.label);

  static SheetCategory parse(String? value) {
    for (final c in values) {
      if (c.name == value) return c;
    }
    return SheetCategory.handwriting;
  }
}

/// One glyph sheet (a complete character set in one "handwriting").
class GlyphSheet {
  final String id;
  final String name;

  /// Asset directory containing `glyphs.json` and the PNGs, with trailing `/`.
  final String path;

  /// `handwriting` (scanned template), `font` (rasterised TTF), `material`
  /// (AI or photographed material letters), `dataset`, `archive`.
  final String source;

  final SheetCategory category;

  /// False for sheets without a clear licence: they are hidden from release
  /// builds (see [GlyphSheetIndex.load]).
  final bool bundle;

  /// Content pack that unlocks the sheet (`assets/packs/packs.json`); null
  /// means free.
  final String? pack;

  const GlyphSheet({
    required this.id,
    required this.name,
    required this.path,
    required this.source,
    this.category = SheetCategory.handwriting,
    this.bundle = true,
    this.pack,
  });

  factory GlyphSheet.fromJson(Map<String, dynamic> json) {
    var path = json['path'] as String;
    if (!path.endsWith('/')) path = '$path/';
    return GlyphSheet(
      id: json['id'] as String,
      name: json['name'] as String,
      path: path,
      source: (json['source'] as String?) ?? 'handwriting',
      category: SheetCategory.parse(json['category'] as String?),
      bundle: (json['bundle'] as bool?) ?? true,
      pack: json['pack'] as String?,
    );
  }

  bool get isHandwriting => source == 'handwriting';

  bool get isMaterial => source == 'material';

  bool get isFree => pack == null;

  @override
  bool operator ==(Object other) => other is GlyphSheet && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Index of all bundled glyph sheets, read from `assets/glyphs/sheets.json`.
class GlyphSheetIndex {
  static const String assetPath = 'assets/glyphs/sheets.json';

  final List<GlyphSheet> sheets;
  final String defaultId;

  const GlyphSheetIndex({required this.sheets, required this.defaultId});

  GlyphSheet get defaultSheet =>
      sheets.firstWhere((s) => s.id == defaultId, orElse: () => sheets.first);

  GlyphSheet? byId(String id) {
    for (final s in sheets) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Reads the index. Sheets marked `"bundle": false` are only included when
  /// [includeUnbundled] is true, which defaults to debug/profile builds.
  static Future<GlyphSheetIndex> load({
    AssetBundle? bundle,
    bool includeUnbundled = !kReleaseMode,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final Map<String, dynamic> data = json.decode(jsonString);
    final sheets = (data['sheets'] as List)
        .map((e) => GlyphSheet.fromJson(e as Map<String, dynamic>))
        .where((s) => includeUnbundled || s.bundle)
        .toList();
    if (sheets.isEmpty) {
      throw StateError('$assetPath lists no sheets');
    }
    return GlyphSheetIndex(
      sheets: sheets,
      defaultId: (data['default'] as String?) ?? sheets.first.id,
    );
  }
}
