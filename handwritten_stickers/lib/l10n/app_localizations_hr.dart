// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get navTextEditor => 'Uređivač teksta';

  @override
  String get navGridAlignment => 'Poravnanje mreže';

  @override
  String get editorTitle => 'Rukom pisani tekst';

  @override
  String get packs => 'Paketi';

  @override
  String get emojiForMessage => 'Emoji uz poruku';

  @override
  String get saveToGallery => 'Spremi u galeriju';

  @override
  String get share => 'Podijeli';

  @override
  String get previewEmpty => 'Napiši nešto ispod…';

  @override
  String get textHint => 'Ovdje napiši svoj tekst…';

  @override
  String get advancedSettings => 'Napredne postavke';

  @override
  String get savedToGallery => 'Spremljeno u galeriju!';

  @override
  String get saveFailed => 'Slika se nije mogla spremiti';

  @override
  String get shareFailed => 'Dijeljenje nije uspjelo';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Font predloška „$preset” nije dostupan, koristi se $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Predložak';

  @override
  String get newPreset => 'Novi predložak';

  @override
  String get renamePreset => 'Preimenuj predložak';

  @override
  String get restorePurchases => 'Vrati kupnje';

  @override
  String get purchasesRestored => 'Kupnje vraćene.';

  @override
  String get packsIntro =>
      'Sve funkcije aplikacije su besplatne. Paketi donose dodatne fontove i predloške.';

  @override
  String get owned => 'Kupljeno';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fontova',
      few: '$count fonta',
      one: '$count font',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predložaka',
      few: '$count predloška',
      one: '$count predložak',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => 'Kupnja čeka odobrenje. Otključat će se sama.';

  @override
  String get purchaseFailed => 'Kupnja nije uspjela. Pokušaj ponovno.';

  @override
  String get purchasesRestoredUnlocked =>
      'Kupnje vraćene. Sve što si kupio/la je otključano.';

  @override
  String paywallPresets(String names) {
    return 'Predlošci: $names';
  }

  @override
  String get unlimitedPresets => 'Neograničeno vlastitih predložaka';

  @override
  String get buyOnce => 'Kupiš jednom, imaš zauvijek, i na drugim uređajima';

  @override
  String get allFeaturesFree => 'Sve funkcije aplikacije ostaju besplatne';

  @override
  String get storeUnavailable =>
      'Trgovina trenutačno nije dostupna. Pokušaj kasnije.';

  @override
  String buyFor(String price) {
    return 'Kupi za $price';
  }

  @override
  String get notForSale => 'Još nije u prodaji';

  @override
  String get loadingPrice => 'Učitavam cijenu…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: svi paketi za $price';
  }

  @override
  String get save => 'Spremi';

  @override
  String get presetSaveTooltip => 'Spremi trenutačni font i stil kao predložak';

  @override
  String get presetSaveAsNew => 'Spremi trenutačno kao novi predložak';

  @override
  String get presetOverwrite => 'Prepiši trenutačnim postavkama';

  @override
  String get rename => 'Preimenuj';

  @override
  String get delete => 'Izbriši';

  @override
  String get presetName => 'Naziv';

  @override
  String get cancel => 'Odustani';

  @override
  String get deletePresetTitle => 'Izbrisati predložak?';

  @override
  String deletePresetBody(String name) {
    return '„$name” bit će izbrisan. Tekst u uređivaču ostaje.';
  }

  @override
  String get joinLetters => 'Spajaj slova';

  @override
  String get letterSpacing => 'Razmak slova';

  @override
  String get baselineWobble => 'Valovitost retka';

  @override
  String get sizeVariance => 'Varijacija veličine';

  @override
  String get rotationVariance => 'Varijacija nagiba';

  @override
  String get opacityVariance => 'Varijacija prozirnosti';

  @override
  String get categoryHandwriting => 'Rukopis';

  @override
  String get categoryCalligraphy => 'Kaligrafija';

  @override
  String get categoryTypography => 'Tipografija';

  @override
  String get categoryKids => 'Za djecu';

  @override
  String get categoryMaterial => 'Materijali';

  @override
  String get noEmoji => 'Bez emojija';

  @override
  String get saveAlignedImage => 'Spremi poravnatu sliku';

  @override
  String savedPath(String path) {
    return 'Spremljeno: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Pogreška: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Poravnanje mreže — $file';
  }

  @override
  String get openAnotherImage => 'Otvori drugu sliku';

  @override
  String get hideGrid => 'Sakrij mrežu';

  @override
  String get showGrid => 'Prikaži mrežu';

  @override
  String get resetGrid => 'Vrati mrežu';

  @override
  String get exportAlignedImage => 'Izvezi poravnatu sliku';

  @override
  String get openTemplatePhoto =>
      'Otvori fotografiju svog ispunjenog predloška';

  @override
  String get openImage => 'Otvori sliku';

  @override
  String get gridInstructions =>
      'Povuci 4 kuta tako da mreža sjedne na fotografiju,\nzatim izvezi sliku s ispravljenom perspektivom.';
}
