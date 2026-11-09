// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get navTextEditor => 'Urejevalnik besedila';

  @override
  String get navGridAlignment => 'Poravnava mreže';

  @override
  String get editorTitle => 'Ročno pisano besedilo';

  @override
  String get packs => 'Paketi';

  @override
  String get emojiForMessage => 'Emoji k sporočilu';

  @override
  String get saveToGallery => 'Shrani v galerijo';

  @override
  String get share => 'Deli';

  @override
  String get previewEmpty => 'Spodaj nekaj napiši…';

  @override
  String get textHint => 'Sem napiši svoje besedilo…';

  @override
  String get advancedSettings => 'Napredne nastavitve';

  @override
  String get savedToGallery => 'Shranjeno v galerijo!';

  @override
  String get saveFailed => 'Slike ni bilo mogoče shraniti';

  @override
  String get shareFailed => 'Deljenje ni uspelo';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Pisava prednastavitve »$preset« ni na voljo, uporabljena je $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Prednastavitev';

  @override
  String get newPreset => 'Nova prednastavitev';

  @override
  String get renamePreset => 'Preimenuj prednastavitev';

  @override
  String get restorePurchases => 'Obnovi nakupe';

  @override
  String get purchasesRestored => 'Nakupi obnovljeni.';

  @override
  String get packsIntro =>
      'Vse funkcije aplikacije so brezplačne. Paketi dodajo nove pisave in prednastavitve.';

  @override
  String get owned => 'Kupljeno';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pisav',
      few: '$count pisave',
      two: '$count pisavi',
      one: '$count pisava',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prednastavitev',
      few: '$count prednastavitve',
      two: '$count prednastavitvi',
      one: '$count prednastavitev',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => 'Nakup čaka na odobritev. Odklenil se bo sam.';

  @override
  String get purchaseFailed => 'Nakup ni uspel. Poskusi znova.';

  @override
  String get purchasesRestoredUnlocked =>
      'Nakupi obnovljeni. Vse, kar si kupil(a), je odklenjeno.';

  @override
  String paywallPresets(String names) {
    return 'Prednastavitve: $names';
  }

  @override
  String get unlimitedPresets => 'Neomejeno lastnih prednastavitev';

  @override
  String get buyOnce => 'Kupiš enkrat, imaš za vedno, tudi na drugih napravah';

  @override
  String get allFeaturesFree => 'Vse funkcije aplikacije ostanejo brezplačne';

  @override
  String get storeUnavailable =>
      'Trgovina trenutno ni na voljo. Poskusi pozneje.';

  @override
  String buyFor(String price) {
    return 'Kupi za $price';
  }

  @override
  String get notForSale => 'Še ni naprodaj';

  @override
  String get loadingPrice => 'Nalagam ceno…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: vsi paketi za $price';
  }

  @override
  String get save => 'Shrani';

  @override
  String get presetSaveTooltip =>
      'Shrani trenutno pisavo in slog kot prednastavitev';

  @override
  String get presetSaveAsNew => 'Shrani trenutno kot novo prednastavitev';

  @override
  String get presetOverwrite => 'Prepiši s trenutnimi nastavitvami';

  @override
  String get rename => 'Preimenuj';

  @override
  String get delete => 'Izbriši';

  @override
  String get presetName => 'Ime';

  @override
  String get cancel => 'Prekliči';

  @override
  String get deletePresetTitle => 'Izbrišem prednastavitev?';

  @override
  String deletePresetBody(String name) {
    return '»$name« bo izbrisana. Besedilo v urejevalniku ostane.';
  }

  @override
  String get joinLetters => 'Poveži črke';

  @override
  String get letterSpacing => 'Razmik črk';

  @override
  String get baselineWobble => 'Valovanje vrstice';

  @override
  String get sizeVariance => 'Nihanje velikosti';

  @override
  String get rotationVariance => 'Nihanje nagiba';

  @override
  String get opacityVariance => 'Nihanje prekrivnosti';

  @override
  String get categoryHandwriting => 'Rokopis';

  @override
  String get categoryCalligraphy => 'Kaligrafija';

  @override
  String get categoryTypography => 'Tipografija';

  @override
  String get categoryKids => 'Za otroke';

  @override
  String get categoryMaterial => 'Materiali';

  @override
  String get noEmoji => 'Brez emojija';

  @override
  String get saveAlignedImage => 'Shrani poravnano sliko';

  @override
  String savedPath(String path) {
    return 'Shranjeno: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Napaka: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Poravnava mreže — $file';
  }

  @override
  String get openAnotherImage => 'Odpri drugo sliko';

  @override
  String get hideGrid => 'Skrij mrežo';

  @override
  String get showGrid => 'Pokaži mrežo';

  @override
  String get resetGrid => 'Ponastavi mrežo';

  @override
  String get exportAlignedImage => 'Izvozi poravnano sliko';

  @override
  String get openTemplatePhoto => 'Odpri fotografijo izpolnjene predloge';

  @override
  String get openImage => 'Odpri sliko';

  @override
  String get gridInstructions =>
      'Povleci 4 vogale, da se mreža prilega fotografiji,\nnato izvozi sliko s popravljeno perspektivo.';
}
