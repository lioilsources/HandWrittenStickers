import 'package:flutter/widgets.dart';

import '../models/glyph_sheet.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's strings in the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Language of content names (packs, built-in presets): `cs` or `en`.
  String get contentLanguage =>
      contentLanguageFor(Localizations.localeOf(this));
}

/// Pack and preset names exist in Czech and English.
String contentLanguageFor(Locale locale) =>
    locale.languageCode == 'cs' ? 'cs' : 'en';

/// Czech for Czech and Slovak devices, English for everyone else.
Locale resolveAppLocale(Locale? device, Iterable<Locale> supported) {
  final code = device?.languageCode;
  return Locale(code == 'cs' || code == 'sk' ? 'cs' : 'en');
}

extension SheetCategoryL10n on SheetCategory {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SheetCategory.handwriting => l10n.categoryHandwriting,
    SheetCategory.calligraphy => l10n.categoryCalligraphy,
    SheetCategory.typography => l10n.categoryTypography,
    SheetCategory.kids => l10n.categoryKids,
    SheetCategory.material => l10n.categoryMaterial,
  };
}
