// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get navTextEditor => 'Tekstieditori';

  @override
  String get navGridAlignment => 'Ruudukon kohdistus';

  @override
  String get editorTitle => 'Käsin kirjoitettu teksti';

  @override
  String get packs => 'Paketit';

  @override
  String get emojiForMessage => 'Emoji viestiin';

  @override
  String get saveToGallery => 'Tallenna galleriaan';

  @override
  String get share => 'Jaa';

  @override
  String get previewEmpty => 'Kirjoita jotain alle…';

  @override
  String get textHint => 'Kirjoita tekstisi tähän…';

  @override
  String get advancedSettings => 'Lisäasetukset';

  @override
  String get savedToGallery => 'Tallennettu galleriaan!';

  @override
  String get saveFailed => 'Kuvan tallennus epäonnistui';

  @override
  String get shareFailed => 'Jakaminen epäonnistui';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Esiasetuksen ”$preset” fontti ei ole saatavilla, käytetään fonttia $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Esiasetus';

  @override
  String get newPreset => 'Uusi esiasetus';

  @override
  String get renamePreset => 'Nimeä esiasetus uudelleen';

  @override
  String get restorePurchases => 'Palauta ostot';

  @override
  String get purchasesRestored => 'Ostot palautettu.';

  @override
  String get packsIntro =>
      'Kaikki sovelluksen toiminnot ovat ilmaisia. Paketit tuovat lisää fontteja ja esiasetuksia.';

  @override
  String get owned => 'Ostettu';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fonttia',
      one: '$count fontti',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esiasetusta',
      one: '$count esiasetus',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Osto odottaa hyväksyntää. Se avautuu itsestään.';

  @override
  String get purchaseFailed => 'Osto epäonnistui. Yritä uudelleen.';

  @override
  String get purchasesRestoredUnlocked =>
      'Ostot palautettu. Kaikki ostamasi on avattu.';

  @override
  String paywallPresets(String names) {
    return 'Esiasetukset: $names';
  }

  @override
  String get unlimitedPresets => 'Rajattomasti omia esiasetuksia';

  @override
  String get buyOnce => 'Osta kerran, pidä ikuisesti, myös muilla laitteillasi';

  @override
  String get allFeaturesFree =>
      'Kaikki sovelluksen toiminnot pysyvät ilmaisina';

  @override
  String get storeUnavailable =>
      'Kauppa ei ole juuri nyt käytettävissä. Yritä myöhemmin.';

  @override
  String buyFor(String price) {
    return 'Osta hintaan $price';
  }

  @override
  String get notForSale => 'Ei vielä myynnissä';

  @override
  String get loadingPrice => 'Ladataan hintaa…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: kaikki paketit hintaan $price';
  }

  @override
  String get save => 'Tallenna';

  @override
  String get presetSaveTooltip =>
      'Tallenna nykyinen fontti ja tyyli esiasetukseksi';

  @override
  String get presetSaveAsNew => 'Tallenna nykyinen uutena esiasetuksena';

  @override
  String get presetOverwrite => 'Korvaa nykyisillä asetuksilla';

  @override
  String get rename => 'Nimeä uudelleen';

  @override
  String get delete => 'Poista';

  @override
  String get presetName => 'Nimi';

  @override
  String get cancel => 'Peruuta';

  @override
  String get deletePresetTitle => 'Poistetaanko esiasetus?';

  @override
  String deletePresetBody(String name) {
    return '”$name” poistetaan. Editorin teksti säilyy.';
  }

  @override
  String get joinLetters => 'Yhdistä kirjaimet';

  @override
  String get letterSpacing => 'Kirjainväli';

  @override
  String get baselineWobble => 'Rivin aaltoilu';

  @override
  String get sizeVariance => 'Koon vaihtelu';

  @override
  String get rotationVariance => 'Kallistuksen vaihtelu';

  @override
  String get opacityVariance => 'Peittävyyden vaihtelu';

  @override
  String get categoryHandwriting => 'Käsiala';

  @override
  String get categoryCalligraphy => 'Kalligrafia';

  @override
  String get categoryTypography => 'Typografia';

  @override
  String get categoryKids => 'Lapset';

  @override
  String get categoryMaterial => 'Materiaalit';

  @override
  String get noEmoji => 'Ei emojia';

  @override
  String get saveAlignedImage => 'Tallenna kohdistettu kuva';

  @override
  String savedPath(String path) {
    return 'Tallennettu: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Virhe: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Ruudukon kohdistus — $file';
  }

  @override
  String get openAnotherImage => 'Avaa toinen kuva';

  @override
  String get hideGrid => 'Piilota ruudukko';

  @override
  String get showGrid => 'Näytä ruudukko';

  @override
  String get resetGrid => 'Palauta ruudukko';

  @override
  String get exportAlignedImage => 'Vie kohdistettu kuva';

  @override
  String get openTemplatePhoto => 'Avaa kuva täyttämästäsi pohjasta';

  @override
  String get openImage => 'Avaa kuva';

  @override
  String get gridInstructions =>
      'Vedä 4 kulmaa niin, että ruudukko osuu kuvaan,\nja vie sitten perspektiiviltään korjattu kuva.';
}
