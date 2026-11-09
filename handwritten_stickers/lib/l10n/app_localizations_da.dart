// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get navTextEditor => 'Teksteditor';

  @override
  String get navGridAlignment => 'Justér gitter';

  @override
  String get editorTitle => 'Håndskrevet tekst';

  @override
  String get packs => 'Pakker';

  @override
  String get emojiForMessage => 'Emoji til beskeden';

  @override
  String get saveToGallery => 'Gem i galleri';

  @override
  String get share => 'Del';

  @override
  String get previewEmpty => 'Skriv noget nedenfor…';

  @override
  String get textHint => 'Skriv din tekst her…';

  @override
  String get advancedSettings => 'Avancerede indstillinger';

  @override
  String get savedToGallery => 'Gemt i galleriet!';

  @override
  String get saveFailed => 'Billedet kunne ikke gemmes';

  @override
  String get shareFailed => 'Deling mislykkedes';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Skrifttypen i forudindstillingen “$preset” er ikke tilgængelig, $sheet bruges.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Forudindstilling';

  @override
  String get newPreset => 'Ny forudindstilling';

  @override
  String get renamePreset => 'Omdøb forudindstilling';

  @override
  String get restorePurchases => 'Gendan køb';

  @override
  String get purchasesRestored => 'Køb gendannet.';

  @override
  String get packsIntro =>
      'Alle appens funktioner er gratis. Pakker giver flere skrifttyper og forudindstillinger.';

  @override
  String get owned => 'Købt';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skrifttyper',
      one: '$count skrifttype',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count forudindstillinger',
      one: '$count forudindstilling',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Købet venter på godkendelse. Det låses op af sig selv.';

  @override
  String get purchaseFailed => 'Købet mislykkedes. Prøv igen.';

  @override
  String get purchasesRestoredUnlocked =>
      'Køb gendannet. Alt, hvad du har købt, er låst op.';

  @override
  String paywallPresets(String names) {
    return 'Forudindstillinger: $names';
  }

  @override
  String get unlimitedPresets => 'Ubegrænset med egne forudindstillinger';

  @override
  String get buyOnce =>
      'Køb én gang, behold det for altid, også på dine andre enheder';

  @override
  String get allFeaturesFree => 'Alle appens funktioner forbliver gratis';

  @override
  String get storeUnavailable =>
      'Butikken er ikke tilgængelig lige nu. Prøv igen senere.';

  @override
  String buyFor(String price) {
    return 'Køb for $price';
  }

  @override
  String get notForSale => 'Endnu ikke til salg';

  @override
  String get loadingPrice => 'Henter pris…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: alle pakker for $price';
  }

  @override
  String get save => 'Gem';

  @override
  String get presetSaveTooltip =>
      'Gem den aktuelle skrifttype og stil som forudindstilling';

  @override
  String get presetSaveAsNew => 'Gem aktuelle som ny forudindstilling';

  @override
  String get presetOverwrite => 'Overskriv med aktuelle indstillinger';

  @override
  String get rename => 'Omdøb';

  @override
  String get delete => 'Slet';

  @override
  String get presetName => 'Navn';

  @override
  String get cancel => 'Annuller';

  @override
  String get deletePresetTitle => 'Slet forudindstilling?';

  @override
  String deletePresetBody(String name) {
    return '“$name” slettes. Teksten i editoren bliver.';
  }

  @override
  String get joinLetters => 'Forbind bogstaver';

  @override
  String get letterSpacing => 'Bogstavafstand';

  @override
  String get baselineWobble => 'Bølgende linje';

  @override
  String get sizeVariance => 'Variation i størrelse';

  @override
  String get rotationVariance => 'Variation i hældning';

  @override
  String get opacityVariance => 'Variation i dækkeevne';

  @override
  String get categoryHandwriting => 'Håndskrift';

  @override
  String get categoryCalligraphy => 'Kalligrafi';

  @override
  String get categoryTypography => 'Typografi';

  @override
  String get categoryKids => 'Børn';

  @override
  String get categoryMaterial => 'Materialer';

  @override
  String get noEmoji => 'Ingen emoji';

  @override
  String get saveAlignedImage => 'Gem justeret billede';

  @override
  String savedPath(String path) {
    return 'Gemt: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Fejl: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Justér gitter — $file';
  }

  @override
  String get openAnotherImage => 'Åbn et andet billede';

  @override
  String get hideGrid => 'Skjul gitter';

  @override
  String get showGrid => 'Vis gitter';

  @override
  String get resetGrid => 'Nulstil gitter';

  @override
  String get exportAlignedImage => 'Eksportér justeret billede';

  @override
  String get openTemplatePhoto => 'Åbn et foto af din udfyldte skabelon';

  @override
  String get openImage => 'Åbn billede';

  @override
  String get gridInstructions =>
      'Træk de 4 hjørner, så gitteret passer på fotoet,\nog eksportér derefter billedet med rettet perspektiv.';
}
