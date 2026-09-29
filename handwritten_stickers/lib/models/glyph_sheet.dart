import 'dart:convert';

import 'package:flutter/services.dart';

/// Visual category of a sheet, used to group the sheet selector.
enum SheetCategory {
  handwriting('Handwriting'),
  calligraphy('Calligraphy'),
  typography('Typography');

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

  /// `handwriting` (scanned template) or `font` (rasterised TTF).
  final String source;

  final SheetCategory category;

  const GlyphSheet({
    required this.id,
    required this.name,
    required this.path,
    required this.source,
    this.category = SheetCategory.handwriting,
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
    );
  }

  bool get isHandwriting => source == 'handwriting';

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

  static Future<GlyphSheetIndex> load({AssetBundle? bundle}) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final Map<String, dynamic> data = json.decode(jsonString);
    final sheets = (data['sheets'] as List)
        .map((e) => GlyphSheet.fromJson(e as Map<String, dynamic>))
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
