// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get navTextEditor => 'Editor de text';

  @override
  String get navGridAlignment => 'Aliniere grilă';

  @override
  String get editorTitle => 'Text scris de mână';

  @override
  String get packs => 'Pachete';

  @override
  String get emojiForMessage => 'Emoji pentru mesaj';

  @override
  String get saveToGallery => 'Salvează în galerie';

  @override
  String get share => 'Distribuie';

  @override
  String get previewEmpty => 'Scrie ceva mai jos…';

  @override
  String get textHint => 'Scrie textul aici…';

  @override
  String get advancedSettings => 'Setări avansate';

  @override
  String get savedToGallery => 'Salvat în galerie!';

  @override
  String get saveFailed => 'Imaginea nu a putut fi salvată';

  @override
  String get shareFailed => 'Distribuirea a eșuat';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Fontul presetării „$preset” nu este disponibil, se folosește $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Presetare';

  @override
  String get newPreset => 'Presetare nouă';

  @override
  String get renamePreset => 'Redenumește presetarea';

  @override
  String get restorePurchases => 'Restabilește achizițiile';

  @override
  String get purchasesRestored => 'Achiziții restabilite.';

  @override
  String get packsIntro =>
      'Toate funcțiile aplicației sunt gratuite. Pachetele adaugă fonturi și presetări noi.';

  @override
  String get owned => 'Cumpărat';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de fonturi',
      few: '$count fonturi',
      one: '$count font',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de presetări',
      few: '$count presetări',
      one: '$count presetare',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Achiziția așteaptă aprobarea. Se va debloca singură.';

  @override
  String get purchaseFailed => 'Achiziția nu a reușit. Încearcă din nou.';

  @override
  String get purchasesRestoredUnlocked =>
      'Achiziții restabilite. Tot ce ai cumpărat este deblocat.';

  @override
  String paywallPresets(String names) {
    return 'Presetări: $names';
  }

  @override
  String get unlimitedPresets => 'Presetări proprii nelimitate';

  @override
  String get buyOnce =>
      'Cumperi o dată, ai pentru totdeauna, și pe celelalte dispozitive';

  @override
  String get allFeaturesFree => 'Toate funcțiile aplicației rămân gratuite';

  @override
  String get storeUnavailable =>
      'Magazinul nu este disponibil acum. Încearcă mai târziu.';

  @override
  String buyFor(String price) {
    return 'Cumpără cu $price';
  }

  @override
  String get notForSale => 'Încă nu este de vânzare';

  @override
  String get loadingPrice => 'Se încarcă prețul…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: toate pachetele cu $price';
  }

  @override
  String get save => 'Salvează';

  @override
  String get presetSaveTooltip =>
      'Salvează fontul și stilul actual ca presetare';

  @override
  String get presetSaveAsNew => 'Salvează actualul ca presetare nouă';

  @override
  String get presetOverwrite => 'Suprascrie cu setările actuale';

  @override
  String get rename => 'Redenumește';

  @override
  String get delete => 'Șterge';

  @override
  String get presetName => 'Nume';

  @override
  String get cancel => 'Anulează';

  @override
  String get deletePresetTitle => 'Ștergi presetarea?';

  @override
  String deletePresetBody(String name) {
    return '„$name” va fi ștearsă. Textul din editor rămâne.';
  }

  @override
  String get joinLetters => 'Leagă literele';

  @override
  String get letterSpacing => 'Spațiere litere';

  @override
  String get baselineWobble => 'Ondulare rând';

  @override
  String get sizeVariance => 'Variație dimensiune';

  @override
  String get rotationVariance => 'Variație înclinare';

  @override
  String get opacityVariance => 'Variație opacitate';

  @override
  String get categoryHandwriting => 'Scris de mână';

  @override
  String get categoryCalligraphy => 'Caligrafie';

  @override
  String get categoryTypography => 'Tipografie';

  @override
  String get categoryKids => 'Copii';

  @override
  String get categoryMaterial => 'Materiale';

  @override
  String get noEmoji => 'Fără emoji';

  @override
  String get saveAlignedImage => 'Salvează imaginea aliniată';

  @override
  String savedPath(String path) {
    return 'Salvat: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Eroare: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Aliniere grilă — $file';
  }

  @override
  String get openAnotherImage => 'Deschide altă imagine';

  @override
  String get hideGrid => 'Ascunde grila';

  @override
  String get showGrid => 'Arată grila';

  @override
  String get resetGrid => 'Resetează grila';

  @override
  String get exportAlignedImage => 'Exportă imaginea aliniată';

  @override
  String get openTemplatePhoto =>
      'Deschide o fotografie a șablonului completat de mână';

  @override
  String get openImage => 'Deschide imaginea';

  @override
  String get gridInstructions =>
      'Trage cele 4 colțuri ca grila să se potrivească pe fotografie,\napoi exportă imaginea cu perspectiva corectată.';
}
