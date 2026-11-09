// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get navTextEditor => 'Textový editor';

  @override
  String get navGridAlignment => 'Zarovnání mřížky';

  @override
  String get editorTitle => 'Ručně psaný text';

  @override
  String get packs => 'Balíčky';

  @override
  String get emojiForMessage => 'Emoji ke zprávě';

  @override
  String get saveToGallery => 'Uložit do galerie';

  @override
  String get share => 'Sdílet';

  @override
  String get previewEmpty => 'Napiš něco do pole níže…';

  @override
  String get textHint => 'Sem napiš svůj text…';

  @override
  String get advancedSettings => 'Pokročilé nastavení';

  @override
  String get savedToGallery => 'Uloženo do galerie!';

  @override
  String get saveFailed => 'Obrázek se nepodařilo uložit';

  @override
  String get shareFailed => 'Sdílení se nepodařilo';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Písmo presetu „$preset“ není k dispozici, použito $sheet.';
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
  String get renamePreset => 'Přejmenovat preset';

  @override
  String get restorePurchases => 'Obnovit nákupy';

  @override
  String get purchasesRestored => 'Nákupy obnoveny.';

  @override
  String get packsIntro =>
      'Všechny funkce aplikace jsou zdarma. Balíčky přidávají další písma a presety.';

  @override
  String get owned => 'Vlastníš';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count písem',
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
      other: '$count presetů',
      many: '$count presetu',
      few: '$count presety',
      one: '$count preset',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => 'Nákup čeká na schválení. Odemkne se sám.';

  @override
  String get purchaseFailed => 'Nákup se nepodařil. Zkus to prosím znovu.';

  @override
  String get purchasesRestoredUnlocked =>
      'Nákupy obnoveny. Co jsi koupil(a), je odemčené.';

  @override
  String paywallPresets(String names) {
    return 'Presety: $names';
  }

  @override
  String get unlimitedPresets => 'Neomezeně vlastních presetů';

  @override
  String get buyOnce => 'Jednou koupíš, máš navždy, i na dalších zařízeních';

  @override
  String get allFeaturesFree => 'Všechny funkce aplikace zůstávají zdarma';

  @override
  String get storeUnavailable => 'Obchod teď není dostupný. Zkus to později.';

  @override
  String buyFor(String price) {
    return 'Koupit za $price';
  }

  @override
  String get notForSale => 'Zatím není v prodeji';

  @override
  String get loadingPrice => 'Načítám cenu…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: všechny balíčky za $price';
  }

  @override
  String get save => 'Uložit';

  @override
  String get presetSaveTooltip => 'Uložit aktuální písmo a styl jako preset';

  @override
  String get presetSaveAsNew => 'Uložit aktuální jako nový preset';

  @override
  String get presetOverwrite => 'Přepsat aktuálním nastavením';

  @override
  String get rename => 'Přejmenovat';

  @override
  String get delete => 'Smazat';

  @override
  String get presetName => 'Název';

  @override
  String get cancel => 'Zrušit';

  @override
  String get deletePresetTitle => 'Smazat preset?';

  @override
  String deletePresetBody(String name) {
    return '„$name“ se smaže. Text v editoru zůstane.';
  }

  @override
  String get joinLetters => 'Spojovat písmena';

  @override
  String get letterSpacing => 'Mezery mezi písmeny';

  @override
  String get baselineWobble => 'Kolísání řádku';

  @override
  String get sizeVariance => 'Kolísání velikosti';

  @override
  String get rotationVariance => 'Kolísání sklonu';

  @override
  String get opacityVariance => 'Kolísání sytosti';

  @override
  String get categoryHandwriting => 'Rukopis';

  @override
  String get categoryCalligraphy => 'Kaligrafie';

  @override
  String get categoryTypography => 'Typografie';

  @override
  String get categoryKids => 'Pro děti';

  @override
  String get categoryMaterial => 'Materiály';

  @override
  String get noEmoji => 'Bez emoji';

  @override
  String get saveAlignedImage => 'Uložit zarovnaný obrázek';

  @override
  String savedPath(String path) {
    return 'Uloženo: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Chyba: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Zarovnání mřížky — $file';
  }

  @override
  String get openAnotherImage => 'Otevřít jiný obrázek';

  @override
  String get hideGrid => 'Skrýt mřížku';

  @override
  String get showGrid => 'Zobrazit mřížku';

  @override
  String get resetGrid => 'Obnovit mřížku';

  @override
  String get exportAlignedImage => 'Exportovat zarovnaný obrázek';

  @override
  String get openTemplatePhoto => 'Otevři fotku své vyplněné šablony';

  @override
  String get openImage => 'Otevřít obrázek';

  @override
  String get gridInstructions =>
      'Přetáhni 4 rohy tak, aby mřížka seděla na fotce,\npak exportuj obrázek s opravenou perspektivou.';
}
