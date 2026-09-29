import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/glyph.dart';

/// Service for loading and caching glyphs of one glyph sheet from assets.
///
/// A sheet directory contains `glyphs.json` (manifest) and one PNG per
/// character. Manifest version 2 additionally carries per-glyph metrics,
/// see [GlyphMetrics].
class GlyphLoader {
  static const String defaultSheetPath = 'assets/glyphs/laurinka/';
  static const String _manifestFile = 'glyphs.json';

  /// Default template geometry, used when a manifest does not specify it.
  static const double _defaultCellHeightMM = 26.2;
  static const int _defaultDpi = 300;
  static const double _defaultBaselineRatio = 0.75;

  /// Asset directory of this sheet, with trailing `/`.
  final String sheetPath;

  final Map<String, Glyph> _cache = {};
  Map<String, String>? _glyphsMap;
  Map<String, GlyphMetrics> _metrics = {};
  bool _initialized = false;

  double _cellHeightPx = _defaultCellHeightMM / 25.4 * _defaultDpi;
  double _baselineRatio = _defaultBaselineRatio;

  GlyphLoader({this.sheetPath = defaultSheetPath})
      : assert(sheetPath.endsWith('/'), 'sheetPath must end with /');

  /// Height of one template cell in source pixels. All glyphs of a sheet are
  /// scaled uniformly by `targetCellHeight / cellHeightPx`.
  double get cellHeightPx => _cellHeightPx;

  /// Where the baseline sits inside a cell (fraction from the top).
  double get baselineRatio => _baselineRatio;

  /// True when the sheet manifest carries per-glyph metrics.
  bool get hasMetrics => _metrics.isNotEmpty;

  bool get isInitialized => _initialized;

  /// Initialize the loader by reading the glyphs manifest
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final manifestPath = '$sheetPath$_manifestFile';
      final jsonString = await rootBundle.loadString(manifestPath);
      final Map<String, dynamic> manifest = json.decode(jsonString);

      _glyphsMap = Map<String, String>.from(manifest['glyphs'] as Map);

      final cellSize = manifest['cellSize'] as Map<String, dynamic>?;
      final cellHeightMM =
          (cellSize?['height'] as num?)?.toDouble() ?? _defaultCellHeightMM;
      final dpi = (manifest['dpi'] as num?)?.toInt() ?? _defaultDpi;
      _cellHeightPx = cellHeightMM / 25.4 * dpi;
      _baselineRatio = (manifest['baselineRatio'] as num?)?.toDouble() ??
          _defaultBaselineRatio;

      final metrics = manifest['metrics'] as Map<String, dynamic>?;
      if (metrics != null) {
        _metrics = metrics.map(
          (k, v) =>
              MapEntry(k, GlyphMetrics.fromJson(v as Map<String, dynamic>)),
        );
      }
      _initialized = true;
      debugPrint('GlyphLoader: $sheetPath loaded ${_glyphsMap!.length} '
          'glyphs, metrics: ${_metrics.length}');
    } catch (e) {
      // If manifest doesn't exist, we'll try direct filename mapping
      debugPrint('GlyphLoader: error loading manifest from $sheetPath: $e');
      _glyphsMap = {};
      _initialized = true;
    }
  }

  /// Get a glyph for the given character
  Future<Glyph?> getGlyph(String char) async {
    if (!_initialized) {
      await initialize();
    }

    // Check cache first
    if (_cache.containsKey(char)) {
      return _cache[char];
    }

    // Determine filename
    String filename;
    if (_glyphsMap != null && _glyphsMap!.containsKey(char)) {
      filename = _glyphsMap![char]!;
    } else {
      // Fallback: use character as filename (with safe conversion)
      filename = '${_charToFilename(char)}.png';
    }

    // Load image
    try {
      final image = await _loadImage('$sheetPath$filename');
      if (image == null) return null;

      final glyph = Glyph(
        char: char,
        image: image,
        width: image.width,
        height: image.height,
        metrics: _metrics[char],
      );

      _cache[char] = glyph;
      return glyph;
    } catch (e) {
      return null;
    }
  }

  /// Preload all glyphs for faster rendering
  Future<void> preloadAll() async {
    if (!_initialized) {
      await initialize();
    }

    if (_glyphsMap == null) return;

    for (final char in _glyphsMap!.keys) {
      await getGlyph(char);
    }
  }

  /// Get all available characters
  Set<String> get availableCharacters {
    if (_glyphsMap != null) {
      return _glyphsMap!.keys.toSet();
    }
    return {};
  }

  /// Check if a character is available
  bool hasGlyph(String char) {
    if (_cache.containsKey(char)) return true;
    if (_glyphsMap != null) return _glyphsMap!.containsKey(char);
    return false;
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }

  /// Load a ui.Image from assets
  Future<ui.Image?> _loadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      return null;
    }
  }

  /// Convert character to safe ASCII filename
  /// Must match CharToFilename in glyph_extractor/charset.go
  String _charToFilename(String char) {
    switch (char) {
      // Basic punctuation
      case '.': return 'dot';
      case ',': return 'comma';
      case '!': return 'exclaim';
      case '?': return 'question';
      case ':': return 'colon';
      case ';': return 'semicolon';
      case '-': return 'hyphen';
      case '_': return 'underscore';
      case "'": return 'apostrophe';
      case '"': return 'doublequote';
      case '/': return 'slash';
      case '\\': return 'backslash';
      case '@': return 'at';
      case '#': return 'hash';
      case '&': return 'ampersand';
      case '+': return 'plus';
      case '=': return 'equals';
      case '%': return 'percent';
      case '*': return 'asterisk';
      case r'$': return 'dollar';
      case ' ': return 'space';

      // Brackets
      case '(': return 'lparen';
      case ')': return 'rparen';
      case '[': return 'lbracket';
      case ']': return 'rbracket';
      case '{': return 'lbrace';
      case '}': return 'rbrace';
      case '<': return 'less';
      case '>': return 'greater';

      // Special ASCII
      case '~': return 'tilde';
      case '`': return 'backtick';
      case '^': return 'caret';
      case '|': return 'pipe';

      // Czech uppercase with diacritics
      case 'Á': return 'A_acute';
      case 'Č': return 'C_caron';
      case 'Ď': return 'D_caron';
      case 'É': return 'E_acute';
      case 'Ě': return 'E_caron';
      case 'Í': return 'I_acute';
      case 'Ň': return 'N_caron';
      case 'Ó': return 'O_acute';
      case 'Ř': return 'R_caron';
      case 'Š': return 'S_caron';
      case 'Ť': return 'T_caron';
      case 'Ú': return 'U_acute';
      case 'Ů': return 'U_ring';
      case 'Ý': return 'Y_acute';
      case 'Ž': return 'Z_caron';

      // Czech lowercase with diacritics
      case 'á': return 'a_acute';
      case 'č': return 'c_caron';
      case 'ď': return 'd_caron';
      case 'é': return 'e_acute';
      case 'ě': return 'e_caron';
      case 'í': return 'i_acute';
      case 'ň': return 'n_caron';
      case 'ó': return 'o_acute';
      case 'ř': return 'r_caron';
      case 'š': return 's_caron';
      case 'ť': return 't_caron';
      case 'ú': return 'u_acute';
      case 'ů': return 'u_ring';
      case 'ý': return 'y_acute';
      case 'ž': return 'z_caron';

      // Currency and symbols
      case '€': return 'euro';
      case '©': return 'copyright';
      case '®': return 'registered';
      case '™': return 'trademark';
      case '°': return 'degree';
      case '§': return 'section';
      case '¶': return 'pilcrow';
      case '•': return 'bullet';
      case '…': return 'ellipsis';

      // Dashes and quotes
      case '–': return 'endash';
      case '—': return 'emdash';
      case '„': return 'quotelowdbl';
      case '\u201D': return 'quoterightdbl'; // "
      case '‚': return 'quotelowsgl';
      case '\u2019': return 'quoteright'; // '
      case '«': return 'guillemotleft';
      case '»': return 'guillemotright';

      // Math symbols
      case '×': return 'multiply';
      case '÷': return 'divide';
      case '±': return 'plusminus';

      // Fractions and superscripts
      case '¼': return 'onequarter';
      case '½': return 'onehalf';
      case '¾': return 'threequarters';
      case '¹': return 'onesuperior';
      case '²': return 'twosuperior';
      case '³': return 'threesuperior';
      case 'µ': return 'micro';
      case '¿': return 'questiondown';
      case '¡': return 'exclamdown';

      // Foreign characters
      case 'ñ': return 'n_tilde';
      case 'Ñ': return 'N_tilde';
      case 'ß': return 'eszett';
      case 'æ': return 'ae';
      case 'Æ': return 'AE';
      case 'ø': return 'o_stroke';
      case 'Ø': return 'O_stroke';

      // Default: return as-is (for A-Z, a-z, 0-9)
      default: return char;
    }
  }
}
