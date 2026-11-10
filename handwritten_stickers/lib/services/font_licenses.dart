import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/glyph_sheet.dart';

/// Lists the fonts behind the bundled glyph sheets in the licence page
/// (Settings → About → Licences), with each font's SIL OFL text.
///
/// Sheets without an `OFL.txt` (hand-written scans, material letters) have no
/// third-party licence to show and are skipped.
class FontLicenses {
  static bool _registered = false;

  static void register({AssetBundle? bundle}) {
    if (_registered) return;
    _registered = true;
    LicenseRegistry.addLicense(() => _entries(bundle ?? rootBundle));
  }

  static Stream<LicenseEntry> _entries(AssetBundle bundle) async* {
    final GlyphSheetIndex index;
    try {
      index = await GlyphSheetIndex.load(bundle: bundle);
    } catch (e) {
      debugPrint('FontLicenses: sheets.json unreadable: $e');
      return;
    }
    // Several sheets can share one family's licence text: group by text.
    final byText = <String, List<String>>{};
    for (final sheet in index.sheets) {
      try {
        final text = await bundle.loadString('${sheet.path}OFL.txt');
        final manifest =
            json.decode(await bundle.loadString('${sheet.path}glyphs.json'))
                as Map<String, dynamic>;
        final label = (manifest['attribution'] as String?) ?? sheet.name;
        byText.putIfAbsent(text.trim(), () => []).add(label);
      } catch (_) {
        // No OFL.txt: not a font sheet.
      }
    }
    for (final e in byText.entries) {
      yield LicenseEntryWithLineBreaks(e.value, e.key);
    }
  }
}
