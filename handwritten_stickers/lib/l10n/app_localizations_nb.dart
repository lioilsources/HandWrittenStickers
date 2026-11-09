// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get navTextEditor => 'Tekstredigering';

  @override
  String get navGridAlignment => 'Juster rutenett';

  @override
  String get editorTitle => 'Håndskrevet tekst';

  @override
  String get packs => 'Pakker';

  @override
  String get emojiForMessage => 'Emoji til meldingen';

  @override
  String get saveToGallery => 'Lagre i galleriet';

  @override
  String get share => 'Del';

  @override
  String get previewEmpty => 'Skriv noe nedenfor…';

  @override
  String get textHint => 'Skriv teksten din her…';

  @override
  String get advancedSettings => 'Avanserte innstillinger';

  @override
  String get savedToGallery => 'Lagret i galleriet!';

  @override
  String get saveFailed => 'Kunne ikke lagre bildet';

  @override
  String get shareFailed => 'Deling mislyktes';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Skrifttypen i forhåndsinnstillingen «$preset» er ikke tilgjengelig, $sheet brukes.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Forhåndsinnstilling';

  @override
  String get newPreset => 'Ny forhåndsinnstilling';

  @override
  String get renamePreset => 'Gi nytt navn til forhåndsinnstilling';

  @override
  String get restorePurchases => 'Gjenopprett kjøp';

  @override
  String get purchasesRestored => 'Kjøp gjenopprettet.';

  @override
  String get packsIntro =>
      'Alle funksjonene i appen er gratis. Pakker gir flere skrifttyper og forhåndsinnstillinger.';

  @override
  String get owned => 'Kjøpt';

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
      other: '$count forhåndsinnstillinger',
      one: '$count forhåndsinnstilling',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Kjøpet venter på godkjenning. Det låses opp av seg selv.';

  @override
  String get purchaseFailed => 'Kjøpet mislyktes. Prøv igjen.';

  @override
  String get purchasesRestoredUnlocked =>
      'Kjøp gjenopprettet. Alt du har kjøpt, er låst opp.';

  @override
  String paywallPresets(String names) {
    return 'Forhåndsinnstillinger: $names';
  }

  @override
  String get unlimitedPresets => 'Ubegrenset med egne forhåndsinnstillinger';

  @override
  String get buyOnce =>
      'Kjøp én gang, behold for alltid, også på de andre enhetene dine';

  @override
  String get allFeaturesFree => 'Alle funksjonene i appen forblir gratis';

  @override
  String get storeUnavailable =>
      'Butikken er ikke tilgjengelig akkurat nå. Prøv igjen senere.';

  @override
  String buyFor(String price) {
    return 'Kjøp for $price';
  }

  @override
  String get notForSale => 'Ikke til salgs ennå';

  @override
  String get loadingPrice => 'Henter pris…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: alle pakker for $price';
  }

  @override
  String get save => 'Lagre';

  @override
  String get presetSaveTooltip =>
      'Lagre gjeldende skrifttype og stil som forhåndsinnstilling';

  @override
  String get presetSaveAsNew => 'Lagre gjeldende som ny forhåndsinnstilling';

  @override
  String get presetOverwrite => 'Overskriv med gjeldende innstillinger';

  @override
  String get rename => 'Gi nytt navn';

  @override
  String get delete => 'Slett';

  @override
  String get presetName => 'Navn';

  @override
  String get cancel => 'Avbryt';

  @override
  String get deletePresetTitle => 'Slette forhåndsinnstillingen?';

  @override
  String deletePresetBody(String name) {
    return '«$name» slettes. Teksten i redigeringen blir værende.';
  }

  @override
  String get joinLetters => 'Bind sammen bokstaver';

  @override
  String get letterSpacing => 'Bokstavavstand';

  @override
  String get baselineWobble => 'Bølgete linje';

  @override
  String get sizeVariance => 'Variasjon i størrelse';

  @override
  String get rotationVariance => 'Variasjon i helning';

  @override
  String get opacityVariance => 'Variasjon i dekkevne';

  @override
  String get categoryHandwriting => 'Håndskrift';

  @override
  String get categoryCalligraphy => 'Kalligrafi';

  @override
  String get categoryTypography => 'Typografi';

  @override
  String get categoryKids => 'Barn';

  @override
  String get categoryMaterial => 'Materialer';

  @override
  String get noEmoji => 'Ingen emoji';

  @override
  String get saveAlignedImage => 'Lagre justert bilde';

  @override
  String savedPath(String path) {
    return 'Lagret: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Feil: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Juster rutenett — $file';
  }

  @override
  String get openAnotherImage => 'Åpne et annet bilde';

  @override
  String get hideGrid => 'Skjul rutenett';

  @override
  String get showGrid => 'Vis rutenett';

  @override
  String get resetGrid => 'Tilbakestill rutenett';

  @override
  String get exportAlignedImage => 'Eksporter justert bilde';

  @override
  String get openTemplatePhoto => 'Åpne et bilde av den utfylte malen din';

  @override
  String get openImage => 'Åpne bilde';

  @override
  String get gridInstructions =>
      'Dra de 4 hjørnene slik at rutenettet passer på bildet,\nog eksporter deretter bildet med rettet perspektiv.';
}
