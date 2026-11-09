// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get navTextEditor => 'Szövegszerkesztő';

  @override
  String get navGridAlignment => 'Rács igazítása';

  @override
  String get editorTitle => 'Kézzel írt szöveg';

  @override
  String get packs => 'Csomagok';

  @override
  String get emojiForMessage => 'Emoji az üzenethez';

  @override
  String get saveToGallery => 'Mentés a galériába';

  @override
  String get share => 'Megosztás';

  @override
  String get previewEmpty => 'Írj valamit lent…';

  @override
  String get textHint => 'Ide írd a szöveged…';

  @override
  String get advancedSettings => 'Speciális beállítások';

  @override
  String get savedToGallery => 'Mentve a galériába!';

  @override
  String get saveFailed => 'Nem sikerült menteni a képet';

  @override
  String get shareFailed => 'A megosztás nem sikerült';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'A(z) „$preset” előbeállítás betűtípusa nem érhető el, helyette: $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Előbeállítás';

  @override
  String get newPreset => 'Új előbeállítás';

  @override
  String get renamePreset => 'Előbeállítás átnevezése';

  @override
  String get restorePurchases => 'Vásárlások visszaállítása';

  @override
  String get purchasesRestored => 'Vásárlások visszaállítva.';

  @override
  String get packsIntro =>
      'Az alkalmazás minden funkciója ingyenes. A csomagok további betűtípusokat és előbeállításokat adnak.';

  @override
  String get owned => 'Megvásárolva';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count betűtípus',
      one: '$count betűtípus',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count előbeállítás',
      one: '$count előbeállítás',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'A vásárlás jóváhagyásra vár. Magától feloldódik.';

  @override
  String get purchaseFailed => 'A vásárlás nem sikerült. Próbáld újra.';

  @override
  String get purchasesRestoredUnlocked =>
      'Vásárlások visszaállítva. Minden, amit megvettél, fel van oldva.';

  @override
  String paywallPresets(String names) {
    return 'Előbeállítások: $names';
  }

  @override
  String get unlimitedPresets => 'Korlátlan saját előbeállítás';

  @override
  String get buyOnce =>
      'Egyszer veszed meg, örökre a tiéd, a többi eszközödön is';

  @override
  String get allFeaturesFree => 'Az alkalmazás minden funkciója ingyenes marad';

  @override
  String get storeUnavailable =>
      'Az áruház most nem érhető el. Próbáld később.';

  @override
  String buyFor(String price) {
    return 'Megvásárlás: $price';
  }

  @override
  String get notForSale => 'Még nem kapható';

  @override
  String get loadingPrice => 'Ár betöltése…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: minden csomag $price áron';
  }

  @override
  String get save => 'Mentés';

  @override
  String get presetSaveTooltip =>
      'A jelenlegi betűtípus és stílus mentése előbeállításként';

  @override
  String get presetSaveAsNew => 'Jelenlegi mentése új előbeállításként';

  @override
  String get presetOverwrite => 'Felülírás a jelenlegi beállításokkal';

  @override
  String get rename => 'Átnevezés';

  @override
  String get delete => 'Törlés';

  @override
  String get presetName => 'Név';

  @override
  String get cancel => 'Mégse';

  @override
  String get deletePresetTitle => 'Törlöd az előbeállítást?';

  @override
  String deletePresetBody(String name) {
    return 'A(z) „$name” törlődik. A szerkesztőben lévő szöveg megmarad.';
  }

  @override
  String get joinLetters => 'Betűk összekötése';

  @override
  String get letterSpacing => 'Betűköz';

  @override
  String get baselineWobble => 'Sor hullámzása';

  @override
  String get sizeVariance => 'Méret ingadozása';

  @override
  String get rotationVariance => 'Dőlés ingadozása';

  @override
  String get opacityVariance => 'Fedettség ingadozása';

  @override
  String get categoryHandwriting => 'Kézírás';

  @override
  String get categoryCalligraphy => 'Kalligráfia';

  @override
  String get categoryTypography => 'Tipográfia';

  @override
  String get categoryKids => 'Gyerekeknek';

  @override
  String get categoryMaterial => 'Anyagok';

  @override
  String get noEmoji => 'Nincs emoji';

  @override
  String get saveAlignedImage => 'Igazított kép mentése';

  @override
  String savedPath(String path) {
    return 'Mentve: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Hiba: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Rács igazítása — $file';
  }

  @override
  String get openAnotherImage => 'Másik kép megnyitása';

  @override
  String get hideGrid => 'Rács elrejtése';

  @override
  String get showGrid => 'Rács megjelenítése';

  @override
  String get resetGrid => 'Rács visszaállítása';

  @override
  String get exportAlignedImage => 'Igazított kép exportálása';

  @override
  String get openTemplatePhoto => 'Nyisd meg a kitöltött sablonod fotóját';

  @override
  String get openImage => 'Kép megnyitása';

  @override
  String get gridInstructions =>
      'Húzd a 4 sarkot úgy, hogy a rács illeszkedjen a fotóra,\nmajd exportáld a perspektívában javított képet.';
}
