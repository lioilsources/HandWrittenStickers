// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get navTextEditor => 'Textový editor';

  @override
  String get navGridAlignment => 'Zarovnanie mriežky';

  @override
  String get editorTitle => 'Ručne písaný text';

  @override
  String get packs => 'Balíčky';

  @override
  String get emojiForMessage => 'Emoji k správe';

  @override
  String get saveToGallery => 'Uložiť do galérie';

  @override
  String get share => 'Zdieľať';

  @override
  String get previewEmpty => 'Napíš niečo do poľa nižšie…';

  @override
  String get textHint => 'Sem napíš svoj text…';

  @override
  String get advancedSettings => 'Pokročilé nastavenia';

  @override
  String get savedToGallery => 'Uložené do galérie!';

  @override
  String get saveFailed => 'Obrázok sa nepodarilo uložiť';

  @override
  String get shareFailed => 'Zdieľanie sa nepodarilo';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Písmo presetu „$preset“ nie je k dispozícii, použité je $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Preset';

  @override
  String get newPreset => 'Nový preset';

  @override
  String get renamePreset => 'Premenovať preset';

  @override
  String get restorePurchases => 'Obnoviť nákupy';

  @override
  String get purchasesRestored => 'Nákupy obnovené.';

  @override
  String get packsIntro =>
      'Všetky funkcie aplikácie sú zadarmo. Balíčky pridávajú ďalšie písma a presety.';

  @override
  String get owned => 'Vlastníš';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count písiem',
      many: '$count písma',
      few: '$count písma',
      one: '$count písmo',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presetov',
      many: '$count presetu',
      few: '$count presety',
      one: '$count preset',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => 'Nákup čaká na schválenie. Odomkne sa sám.';

  @override
  String get purchaseFailed => 'Nákup sa nepodaril. Skús to prosím znova.';

  @override
  String get purchasesRestoredUnlocked =>
      'Nákupy obnovené. Čo si kúpil(a), je odomknuté.';

  @override
  String paywallPresets(String names) {
    return 'Presety: $names';
  }

  @override
  String get unlimitedPresets => 'Neobmedzene vlastných presetov';

  @override
  String get buyOnce => 'Raz kúpiš, máš navždy, aj na ďalších zariadeniach';

  @override
  String get allFeaturesFree => 'Všetky funkcie aplikácie zostávajú zadarmo';

  @override
  String get storeUnavailable =>
      'Obchod teraz nie je dostupný. Skús to neskôr.';

  @override
  String buyFor(String price) {
    return 'Kúpiť za $price';
  }

  @override
  String get notForSale => 'Zatiaľ nie je v predaji';

  @override
  String get loadingPrice => 'Načítavam cenu…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: všetky balíčky za $price';
  }

  @override
  String get save => 'Uložiť';

  @override
  String get presetSaveTooltip => 'Uložiť aktuálne písmo a štýl ako preset';

  @override
  String get presetSaveAsNew => 'Uložiť aktuálne ako nový preset';

  @override
  String get presetOverwrite => 'Prepísať aktuálnym nastavením';

  @override
  String get rename => 'Premenovať';

  @override
  String get delete => 'Zmazať';

  @override
  String get presetName => 'Názov';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get deletePresetTitle => 'Zmazať preset?';

  @override
  String deletePresetBody(String name) {
    return '„$name“ sa zmaže. Text v editore zostane.';
  }

  @override
  String get joinLetters => 'Spájať písmená';

  @override
  String get letterSpacing => 'Medzery medzi písmenami';

  @override
  String get baselineWobble => 'Kolísanie riadka';

  @override
  String get sizeVariance => 'Kolísanie veľkosti';

  @override
  String get rotationVariance => 'Kolísanie sklonu';

  @override
  String get opacityVariance => 'Kolísanie sýtosti';

  @override
  String get categoryHandwriting => 'Rukopis';

  @override
  String get categoryCalligraphy => 'Kaligrafia';

  @override
  String get categoryTypography => 'Typografia';

  @override
  String get categoryKids => 'Pre deti';

  @override
  String get categoryMaterial => 'Materiály';

  @override
  String get noEmoji => 'Bez emoji';

  @override
  String get saveAlignedImage => 'Uložiť zarovnaný obrázok';

  @override
  String savedPath(String path) {
    return 'Uložené: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Chyba: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Zarovnanie mriežky — $file';
  }

  @override
  String get openAnotherImage => 'Otvoriť iný obrázok';

  @override
  String get hideGrid => 'Skryť mriežku';

  @override
  String get showGrid => 'Zobraziť mriežku';

  @override
  String get resetGrid => 'Obnoviť mriežku';

  @override
  String get exportAlignedImage => 'Exportovať zarovnaný obrázok';

  @override
  String get openTemplatePhoto => 'Otvor fotku svojej vyplnenej šablóny';

  @override
  String get openImage => 'Otvoriť obrázok';

  @override
  String get gridInstructions =>
      'Potiahni 4 rohy tak, aby mriežka sedela na fotke,\npotom exportuj obrázok s opravenou perspektívou.';
}
