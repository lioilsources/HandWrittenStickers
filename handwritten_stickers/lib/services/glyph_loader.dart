import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models/glyph.dart';

/// Service for loading and caching glyphs from assets
class GlyphLoader {
  static const String _assetsPath = 'assets/glyphs/';
  static const String _manifestFile = 'glyphs.json';

  final Map<String, Glyph> _cache = {};
  Map<String, String>? _glyphsMap;
  bool _initialized = false;

  /// Initialize the loader by reading the glyphs manifest
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final manifestPath = '$_assetsPath$_manifestFile';
      final jsonString = await rootBundle.loadString(manifestPath);
      final Map<String, dynamic> manifest = json.decode(jsonString);

      _glyphsMap = Map<String, String>.from(manifest['glyphs'] as Map);
      _initialized = true;
    } catch (e) {
      // If manifest doesn't exist, we'll try direct filename mapping
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
      final image = await _loadImage('$_assetsPath$filename');
      if (image == null) return null;

      final glyph = Glyph(
        char: char,
        image: image,
        width: image.width,
        height: image.height,
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

  /// Convert character to safe filename
  String _charToFilename(String char) {
    switch (char) {
      case '/':
        return 'slash';
      case '\\':
        return 'backslash';
      case ':':
        return 'colon';
      case '*':
        return 'asterisk';
      case '?':
        return 'question';
      case '"':
        return 'doublequote';
      case '<':
        return 'less';
      case '>':
        return 'greater';
      case '|':
        return 'pipe';
      case '.':
        return 'dot';
      case ',':
        return 'comma';
      case '\'':
        return 'apostrophe';
      case ' ':
        return 'space';
      default:
        return char;
    }
  }
}

/// Singleton instance for easy access
final glyphLoader = GlyphLoader();
