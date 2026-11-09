import 'dart:ui';

/// Language tag used by the localized maps in bundled JSON (`presets.json`,
/// `packs.json`): `cs`, `en`, `pt-BR`, `zh-Hans`, … (BCP 47).
String contentLanguageOf(Locale locale) {
  final parts = [
    locale.languageCode,
    if (locale.scriptCode != null) locale.scriptCode!,
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty)
      locale.countryCode!,
  ];
  return parts.join('-');
}

/// Picks the text for [language] from a JSON value that is either a plain
/// string or a map of language tags. Tries the full tag (`pt-BR`), then
/// the language alone (`pt`), then any tag of that language, then English,
/// then whatever is there.
String pickLocalized(Object? value, String language) {
  if (value is! Map) return (value as String?) ?? '';
  final exact = value[language];
  if (exact is String) return exact;
  final base = language.split('-').first;
  final plain = value[base];
  if (plain is String) return plain;
  for (final entry in value.entries) {
    final key = entry.key as String;
    if (key.split('-').first == base && entry.value is String) {
      return entry.value as String;
    }
  }
  return (value['en'] ?? value.values.first) as String;
}
