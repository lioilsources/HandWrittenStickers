/// Minimal Unicode normalisation for the characters the glyph sheets cover.
///
/// Dart has no built-in NFC/NFD. Text pasted from some sources (or typed on
/// some keyboards) arrives decomposed – `c` + U+030C instead of `č` – and
/// would miss the manifest. [nfc] recomposes the accented letters of the
/// sheet charset; [decompose] tells the renderer how to build an accented
/// letter from a base glyph and an accent glyph (manifest v3 `compose`).
class TextNormalizer {
  TextNormalizer._();

  /// Accent glyph keys used in manifests, keyed by combining mark.
  static const Map<int, String> _accentKeys = {
    0x0301: 'acute',
    0x030C: 'caron',
    0x030A: 'ring',
    0x0303: 'tilde',
  };

  /// Precomposed letter → [base letter, accent glyph key].
  static const Map<String, List<String>> decompositions = {
    'Á': ['A', 'acute'],
    'Č': ['C', 'caron'],
    'Ď': ['D', 'caron'],
    'É': ['E', 'acute'],
    'Ě': ['E', 'caron'],
    'Í': ['I', 'acute'],
    'Ň': ['N', 'caron'],
    'Ó': ['O', 'acute'],
    'Ř': ['R', 'caron'],
    'Š': ['S', 'caron'],
    'Ť': ['T', 'caron'],
    'Ú': ['U', 'acute'],
    'Ů': ['U', 'ring'],
    'Ý': ['Y', 'acute'],
    'Ž': ['Z', 'caron'],
    'á': ['a', 'acute'],
    'č': ['c', 'caron'],
    'ď': ['d', 'caron'],
    'é': ['e', 'acute'],
    'ě': ['e', 'caron'],
    'í': ['ı', 'acute'],
    'ň': ['n', 'caron'],
    'ó': ['o', 'acute'],
    'ř': ['r', 'caron'],
    'š': ['s', 'caron'],
    'ť': ['t', 'caron'],
    'ú': ['u', 'acute'],
    'ů': ['u', 'ring'],
    'ý': ['y', 'acute'],
    'ž': ['z', 'caron'],
    'ñ': ['n', 'tilde'],
    'Ñ': ['N', 'tilde'],
  };

  static final Map<String, String> _composeMap = {
    for (final e in decompositions.entries)
      _composeKey(e.value[0] == 'ı' ? 'i' : e.value[0], e.value[1]): e.key,
  };

  static String _composeKey(String base, String accent) => '$base+$accent';

  /// Recomposes base letter + combining accent into the precomposed letter
  /// for every pair in [decompositions]; other text is returned unchanged.
  static String nfc(String text) {
    final runes = text.runes.toList();
    if (!runes.any(_accentKeys.containsKey)) return text;
    final out = StringBuffer();
    for (var i = 0; i < runes.length; i++) {
      final base = String.fromCharCode(runes[i]);
      if (i + 1 < runes.length) {
        final accent = _accentKeys[runes[i + 1]];
        final composed = accent == null
            ? null
            : _composeMap[_composeKey(base, accent)];
        if (composed != null) {
          out.write(composed);
          i++;
          continue;
        }
      }
      out.write(base);
    }
    return out.toString();
  }

  /// `[base, accentKey]` for an accented letter, or null.
  static List<String>? decompose(String char) => decompositions[char];

  /// Accents that sit to the right of a tall base letter (ď, ť) instead of
  /// above it.
  static bool isSideAccent(String char) => char == 'ď' || char == 'ť';
}
