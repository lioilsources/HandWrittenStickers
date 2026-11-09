// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get navTextEditor => 'Teksteditor';

  @override
  String get navGridAlignment => 'Raster uitlijnen';

  @override
  String get editorTitle => 'Handgeschreven tekst';

  @override
  String get packs => 'Pakketten';

  @override
  String get emojiForMessage => 'Emoji bij het bericht';

  @override
  String get saveToGallery => 'Opslaan in galerij';

  @override
  String get share => 'Delen';

  @override
  String get previewEmpty => 'Typ hieronder iets…';

  @override
  String get textHint => 'Typ hier je tekst…';

  @override
  String get advancedSettings => 'Geavanceerde instellingen';

  @override
  String get savedToGallery => 'Opgeslagen in de galerij!';

  @override
  String get saveFailed => 'Afbeelding kon niet worden opgeslagen';

  @override
  String get shareFailed => 'Delen mislukt';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Het lettertype van voorinstelling ‘$preset’ is niet beschikbaar, $sheet wordt gebruikt.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Voorinstelling';

  @override
  String get newPreset => 'Nieuwe voorinstelling';

  @override
  String get renamePreset => 'Voorinstelling hernoemen';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get purchasesRestored => 'Aankopen hersteld.';

  @override
  String get packsIntro =>
      'Alle functies van de app zijn gratis. Pakketten voegen meer lettertypen en voorinstellingen toe.';

  @override
  String get owned => 'Gekocht';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lettertypen',
      one: '$count lettertype',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voorinstellingen',
      one: '$count voorinstelling',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'De aankoop wacht op goedkeuring. Hij wordt vanzelf ontgrendeld.';

  @override
  String get purchaseFailed => 'De aankoop is mislukt. Probeer het opnieuw.';

  @override
  String get purchasesRestoredUnlocked =>
      'Aankopen hersteld. Alles wat je hebt gekocht is ontgrendeld.';

  @override
  String paywallPresets(String names) {
    return 'Voorinstellingen: $names';
  }

  @override
  String get unlimitedPresets => 'Onbeperkt eigen voorinstellingen';

  @override
  String get buyOnce =>
      'Eén keer kopen, voor altijd van jou, ook op je andere apparaten';

  @override
  String get allFeaturesFree => 'Alle functies van de app blijven gratis';

  @override
  String get storeUnavailable =>
      'De winkel is nu niet beschikbaar. Probeer het later.';

  @override
  String buyFor(String price) {
    return 'Kopen voor $price';
  }

  @override
  String get notForSale => 'Nog niet te koop';

  @override
  String get loadingPrice => 'Prijs laden…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: alle pakketten voor $price';
  }

  @override
  String get save => 'Opslaan';

  @override
  String get presetSaveTooltip =>
      'Huidig lettertype en stijl opslaan als voorinstelling';

  @override
  String get presetSaveAsNew => 'Huidige opslaan als nieuwe voorinstelling';

  @override
  String get presetOverwrite => 'Overschrijven met huidige instellingen';

  @override
  String get rename => 'Hernoemen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get presetName => 'Naam';

  @override
  String get cancel => 'Annuleren';

  @override
  String get deletePresetTitle => 'Voorinstelling verwijderen?';

  @override
  String deletePresetBody(String name) {
    return '‘$name’ wordt verwijderd. De tekst in de editor blijft staan.';
  }

  @override
  String get joinLetters => 'Letters verbinden';

  @override
  String get letterSpacing => 'Letterafstand';

  @override
  String get baselineWobble => 'Golvende regel';

  @override
  String get sizeVariance => 'Variatie in grootte';

  @override
  String get rotationVariance => 'Variatie in helling';

  @override
  String get opacityVariance => 'Variatie in dekking';

  @override
  String get categoryHandwriting => 'Handschrift';

  @override
  String get categoryCalligraphy => 'Kalligrafie';

  @override
  String get categoryTypography => 'Typografie';

  @override
  String get categoryKids => 'Kinderen';

  @override
  String get categoryMaterial => 'Materialen';

  @override
  String get noEmoji => 'Geen emoji';

  @override
  String get saveAlignedImage => 'Uitgelijnde afbeelding opslaan';

  @override
  String savedPath(String path) {
    return 'Opgeslagen: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Fout: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Raster uitlijnen — $file';
  }

  @override
  String get openAnotherImage => 'Andere afbeelding openen';

  @override
  String get hideGrid => 'Raster verbergen';

  @override
  String get showGrid => 'Raster tonen';

  @override
  String get resetGrid => 'Raster resetten';

  @override
  String get exportAlignedImage => 'Uitgelijnde afbeelding exporteren';

  @override
  String get openTemplatePhoto => 'Open een foto van je ingevulde sjabloon';

  @override
  String get openImage => 'Afbeelding openen';

  @override
  String get gridInstructions =>
      'Sleep de 4 hoeken zodat het raster op de foto past\nen exporteer daarna de afbeelding met gecorrigeerd perspectief.';
}
