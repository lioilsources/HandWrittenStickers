// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get navTextEditor => 'Textredigerare';

  @override
  String get navGridAlignment => 'Justera rutnät';

  @override
  String get editorTitle => 'Handskriven text';

  @override
  String get packs => 'Paket';

  @override
  String get emojiForMessage => 'Emoji till meddelandet';

  @override
  String get saveToGallery => 'Spara i galleriet';

  @override
  String get share => 'Dela';

  @override
  String get previewEmpty => 'Skriv något nedan…';

  @override
  String get textHint => 'Skriv din text här…';

  @override
  String get advancedSettings => 'Avancerade inställningar';

  @override
  String get savedToGallery => 'Sparat i galleriet!';

  @override
  String get saveFailed => 'Det gick inte att spara bilden';

  @override
  String get shareFailed => 'Delningen misslyckades';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Typsnittet i förinställningen ”$preset” är inte tillgängligt, $sheet används.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Förinställning';

  @override
  String get newPreset => 'Ny förinställning';

  @override
  String get renamePreset => 'Byt namn på förinställning';

  @override
  String get restorePurchases => 'Återställ köp';

  @override
  String get purchasesRestored => 'Köpen har återställts.';

  @override
  String get packsIntro =>
      'Alla appens funktioner är gratis. Paket ger fler typsnitt och förinställningar.';

  @override
  String get owned => 'Köpt';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count typsnitt',
      one: '$count typsnitt',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count förinställningar',
      one: '$count förinställning',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Köpet väntar på godkännande. Det låses upp av sig självt.';

  @override
  String get purchaseFailed => 'Köpet misslyckades. Försök igen.';

  @override
  String get purchasesRestoredUnlocked =>
      'Köpen har återställts. Allt du har köpt är upplåst.';

  @override
  String paywallPresets(String names) {
    return 'Förinställningar: $names';
  }

  @override
  String get unlimitedPresets => 'Obegränsat med egna förinställningar';

  @override
  String get buyOnce =>
      'Köp en gång, behåll för alltid, även på dina andra enheter';

  @override
  String get allFeaturesFree => 'Alla appens funktioner förblir gratis';

  @override
  String get storeUnavailable =>
      'Butiken är inte tillgänglig just nu. Försök senare.';

  @override
  String buyFor(String price) {
    return 'Köp för $price';
  }

  @override
  String get notForSale => 'Inte till salu än';

  @override
  String get loadingPrice => 'Hämtar pris…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: alla paket för $price';
  }

  @override
  String get save => 'Spara';

  @override
  String get presetSaveTooltip =>
      'Spara aktuellt typsnitt och stil som förinställning';

  @override
  String get presetSaveAsNew => 'Spara aktuell som ny förinställning';

  @override
  String get presetOverwrite => 'Skriv över med aktuella inställningar';

  @override
  String get rename => 'Byt namn';

  @override
  String get delete => 'Radera';

  @override
  String get presetName => 'Namn';

  @override
  String get cancel => 'Avbryt';

  @override
  String get deletePresetTitle => 'Radera förinställningen?';

  @override
  String deletePresetBody(String name) {
    return '”$name” raderas. Texten i redigeraren finns kvar.';
  }

  @override
  String get joinLetters => 'Sammanbind bokstäver';

  @override
  String get letterSpacing => 'Bokstavsavstånd';

  @override
  String get baselineWobble => 'Vågig rad';

  @override
  String get sizeVariance => 'Variation i storlek';

  @override
  String get rotationVariance => 'Variation i lutning';

  @override
  String get opacityVariance => 'Variation i täckning';

  @override
  String get categoryHandwriting => 'Handstil';

  @override
  String get categoryCalligraphy => 'Kalligrafi';

  @override
  String get categoryTypography => 'Typografi';

  @override
  String get categoryKids => 'Barn';

  @override
  String get categoryMaterial => 'Material';

  @override
  String get noEmoji => 'Ingen emoji';

  @override
  String get saveAlignedImage => 'Spara justerad bild';

  @override
  String savedPath(String path) {
    return 'Sparad: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Fel: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Justera rutnät — $file';
  }

  @override
  String get openAnotherImage => 'Öppna en annan bild';

  @override
  String get hideGrid => 'Dölj rutnät';

  @override
  String get showGrid => 'Visa rutnät';

  @override
  String get resetGrid => 'Återställ rutnät';

  @override
  String get exportAlignedImage => 'Exportera justerad bild';

  @override
  String get openTemplatePhoto => 'Öppna ett foto av din ifyllda mall';

  @override
  String get openImage => 'Öppna bild';

  @override
  String get gridInstructions =>
      'Dra de 4 hörnen så att rutnätet passar på fotot\noch exportera sedan bilden med korrigerat perspektiv.';
}
