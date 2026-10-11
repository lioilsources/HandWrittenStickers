import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/glyph.dart';
import 'text_normalizer.dart';

/// Service for loading and caching glyphs of one glyph sheet from assets.
///
/// A sheet directory contains `glyphs.json` (manifest) and one PNG per
/// character. Manifest version 2 adds per-glyph metrics ([GlyphMetrics]);
/// version 3 allows several variants per character (`"a": ["a.png",
/// "a_1.png"]`, metrics likewise as a list), `compose` rules for accented
/// letters, a `fallback` sheet and `colored` glyphs.
class GlyphLoader {
  static const String defaultSheetPath = 'assets/glyphs/laurinka/';
  static const String _manifestFile = 'glyphs.json';

  /// Default template geometry, used when a manifest does not specify it.
  static const double _defaultCellHeightMM = 26.2;
  static const int _defaultDpi = 300;
  static const double _defaultBaselineRatio = 0.75;
  static const double _defaultEmRatio = 0.62;

  /// Asset directory of this sheet, with trailing `/`.
  final String sheetPath;

  final Map<String, Glyph> _cache = {};
  Map<String, List<String>>? _files;
  Map<String, List<GlyphMetrics>> _metrics = {};
  Map<String, List<String>> _compose = {};
  bool _colored = false;
  String? _fallbackId;
  bool _initialized = false;

  double _cellHeightPx = _defaultCellHeightMM / 25.4 * _defaultDpi;
  double _baselineRatio = _defaultBaselineRatio;
  double? _emHeightPx;

  /// Sheet used for characters this sheet lacks (manifest `fallback`),
  /// wired up by whoever owns the loaders once both are initialised.
  GlyphLoader? fallbackLoader;

  /// Asset bundle to read from; [rootBundle] unless injected (tests).
  final AssetBundle? _bundle;

  GlyphLoader({this.sheetPath = defaultSheetPath, AssetBundle? bundle})
    : _bundle = bundle,
      assert(sheetPath.endsWith('/'), 'sheetPath must end with /');

  AssetBundle get _assets => _bundle ?? rootBundle;

  /// Height of one template cell in source pixels. All glyphs of a sheet are
  /// scaled uniformly by `targetCellHeight / cellHeightPx`.
  double get cellHeightPx => _cellHeightPx;

  /// Where the baseline sits inside a cell (fraction from the top).
  double get baselineRatio => _baselineRatio;

  /// Nominal em size in source pixels (manifest `emHeight`).
  double get emHeightPx => _emHeightPx ?? _cellHeightPx * _defaultEmRatio;

  /// True when the sheet manifest carries per-glyph metrics.
  bool get hasMetrics => _metrics.isNotEmpty;

  /// Glyphs carry their own colours and must not be tinted.
  bool get isColored => _colored;

  /// Id of the sheet to use for missing characters, if any.
  String? get fallbackId => _fallbackId;

  bool get isInitialized => _initialized;

  /// Manifest values may be a single item (v1/v2) or a list (v3 variants).
  static List<T> _oneOrMany<T>(Object? value, T Function(Object?) convert) {
    if (value is List) return value.map(convert).toList();
    if (value == null) return const [];
    return [convert(value)];
  }

  /// Initialize the loader by reading the glyphs manifest
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final manifestPath = '$sheetPath$_manifestFile';
      final jsonString = await _assets.loadString(manifestPath);
      final Map<String, dynamic> manifest = json.decode(jsonString);

      _files = (manifest['glyphs'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, _oneOrMany(v, (e) => e as String)),
      );

      final cellSize = manifest['cellSize'] as Map<String, dynamic>?;
      final cellHeightMM =
          (cellSize?['height'] as num?)?.toDouble() ?? _defaultCellHeightMM;
      final dpi = (manifest['dpi'] as num?)?.toInt() ?? _defaultDpi;
      _cellHeightPx = cellHeightMM / 25.4 * dpi;
      _baselineRatio =
          (manifest['baselineRatio'] as num?)?.toDouble() ??
          _defaultBaselineRatio;
      _emHeightPx = (manifest['emHeight'] as num?)?.toDouble();
      _colored = (manifest['colored'] as bool?) ?? false;
      _fallbackId = manifest['fallback'] as String?;

      final metrics = manifest['metrics'] as Map<String, dynamic>?;
      if (metrics != null) {
        _metrics = metrics.map(
          (k, v) => MapEntry(
            k,
            _oneOrMany(
              v,
              (e) => GlyphMetrics.fromJson(e as Map<String, dynamic>),
            ),
          ),
        );
      }
      final compose = manifest['compose'] as Map<String, dynamic>?;
      if (compose != null) {
        _compose = compose.map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        );
      }
      _initialized = true;
      debugPrint(
        'GlyphLoader: $sheetPath loaded ${_files!.length} '
        'glyphs, metrics: ${_metrics.length}',
      );
    } catch (e) {
      // If manifest doesn't exist, we'll try direct filename mapping
      debugPrint('GlyphLoader: error loading manifest from $sheetPath: $e');
      _files = {};
      _initialized = true;
    }
  }

  /// Number of variants of [char] (0 when the sheet lacks it).
  int variantCount(String char) => _files?[char]?.length ?? 0;

  /// Get variant [variant] of the glyph for [char].
  Future<Glyph?> getGlyph(String char, {int variant = 0}) async {
    if (!_initialized) {
      await initialize();
    }

    final files = _files?[char];
    if (files != null && files.isNotEmpty) {
      variant %= files.length;
    } else {
      variant = 0;
    }
    final cacheKey = variant == 0 ? char : '$char#$variant';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    // Determine filename
    final String filename;
    if (files != null && files.isNotEmpty) {
      filename = files[variant];
    } else {
      // Fallback: use character as filename (with safe conversion)
      filename = '${_charToFilename(char)}.png';
    }

    // Load image
    try {
      final image = await _loadImage('$sheetPath$filename');
      if (image == null) return null;

      final metrics = _metrics[char];
      final glyph = Glyph(
        char: char,
        image: image,
        width: image.width,
        height: image.height,
        metrics: metrics != null && variant < metrics.length
            ? metrics[variant]
            : null,
        colored: _colored,
      );

      _cache[cacheKey] = glyph;
      return glyph;
    } catch (e) {
      return null;
    }
  }

  /// How to build [char] from other glyphs of this sheet: `[base, accent]`.
  ///
  /// Uses the manifest `compose` rule, else the standard decomposition when
  /// the sheet has an accent glyph (`caron`, `acute`, `ring`, `tilde`) and
  /// the base letter. Only sheets with metrics can place accents.
  List<String>? composeParts(String char) {
    if (!hasMetrics) return null;
    final rule = _compose[char];
    if (rule != null && rule.length == 2) return rule;
    final parts = TextNormalizer.decompose(char);
    if (parts == null || !hasGlyph(parts[1])) return null;
    var base = parts[0];
    if (!hasGlyph(base) && base == 'ı') base = 'i';
    return hasGlyph(base) ? [base, parts[1]] : null;
  }

  /// Preload all glyphs (every variant) for faster rendering
  Future<void> preloadAll() async {
    if (!_initialized) {
      await initialize();
    }

    for (final entry in (_files ?? const <String, List<String>>{}).entries) {
      for (var v = 0; v < entry.value.length; v++) {
        await getGlyph(entry.key, variant: v);
      }
    }
  }

  /// Get all available characters
  Set<String> get availableCharacters => _files?.keys.toSet() ?? {};

  /// Check if a character is available
  bool hasGlyph(String char) {
    if (_cache.containsKey(char)) return true;
    return _files?.containsKey(char) ?? false;
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }

  /// Load a ui.Image from assets
  Future<ui.Image?> _loadImage(String path) async {
    try {
      final data = await _assets.load(path);
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
