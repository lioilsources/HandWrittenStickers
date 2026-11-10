// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get navEditor => 'Editor textu';

  @override
  String get navGrid => 'Zarovnání mřížky';

  @override
  String get editorTitle => 'Ručně psaný text';

  @override
  String get packs => 'Balíčky';

  @override
  String get aboutAndLicences => 'O aplikaci a licence';

  @override
  String get emojiTag => 'Emoji ke zprávě';

  @override
  String get noEmoji => 'Bez emoji';

  @override
  String get saveToGallery => 'Uložit do galerie';

  @override
  String get share => 'Sdílet';

  @override
  String get savedToGallery => 'Uloženo do galerie.';

  @override
  String get saveFailed => 'Obrázek se nepodařilo uložit';

  @override
  String get shareFailed => 'Sdílení se nepodařilo';

  @override
  String get emptyCanvasHint => 'Napiš něco níže…';

  @override
  String get textHint => 'Sem napiš text…';

  @override
  String get advancedSettings => 'Pokročilé nastavení';

  @override
  String get presetDefaultName => 'Preset';

  @override
  String get newPreset => 'Nový preset';

  @override
  String get renamePreset => 'Přejmenovat preset';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Písmo presetu „$preset“ není k dispozici, použito $sheet.';
  }

  @override
  String get save => 'Uložit';

  @override
  String get savePresetTooltip => 'Uložit aktuální písmo a styl jako preset';

  @override
  String get saveAsNewPreset => 'Uložit aktuální jako nový preset';

  @override
  String get overwritePreset => 'Přepsat aktuálním nastavením';

  @override
  String get rename => 'Přejmenovat';

  @override
  String get delete => 'Smazat';

  @override
  String get cancel => 'Zrušit';

  @override
  String get nameLabel => 'Název';

  @override
  String get deletePresetTitle => 'Smazat preset?';

  @override
  String deletePresetBody(String name) {
    return '„$name“ se smaže. Text v editoru zůstane.';
  }

  @override
  String get restorePurchases => 'Obnovit nákupy';

  @override
  String get purchasesRestored => 'Nákupy obnoveny.';

  @override
  String get purchasesRestoredUnlocked =>
      'Nákupy obnoveny. Co jsi koupil(a), je odemčené.';

  @override
  String get owned => 'Vlastníš';

  @override
  String get packsIntro =>
      'Všechny funkce aplikace jsou zdarma. Balíčky přidávají další písma a presety.';

  @override
  String get purchasePending => 'Nákup čeká na schválení. Odemkne se sám.';

  @override
  String get purchaseFailed => 'Nákup se nepodařil. Zkus to prosím znovu.';

  @override
  String get storeUnavailable => 'Obchod teď není dostupný. Zkus to později.';

  @override
  String buyFor(String price) {
    return 'Koupit za $price';
  }

  @override
  String get notForSaleYet => 'Zatím není v prodeji';

  @override
  String allPacksFor(String name, String price) {
    return '$name: všechny balíčky za $price';
  }

  @override
  String get joinLetters => 'Spojovat písmena';

  @override
  String get letterSpacing => 'Mezery mezi písmeny';

  @override
  String get baselineWobble => 'Kolísání účaří';

  @override
  String get sizeVariance => 'Kolísání velikosti';

  @override
  String get rotationVariance => 'Kolísání natočení';

  @override
  String get opacityVariance => 'Kolísání krytí';

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
  String gridSaved(String path) {
    return 'Uloženo: $path';
  }

  @override
  String gridError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get gridSaveDialogTitle => 'Uložit zarovnaný obrázek';

  @override
  String get gridOpenAnother => 'Otevřít jiný obrázek';

  @override
  String get gridHide => 'Skrýt mřížku';

  @override
  String get gridShow => 'Zobrazit mřížku';

  @override
  String get gridReset => 'Obnovit mřížku';

  @override
  String get gridExport => 'Exportovat zarovnaný obrázek';

  @override
  String get gridOpenImage => 'Otevřít obrázek';

  @override
  String get gridOpenHint => 'Otevři fotku šablony s ručně psanými znaky';

  @override
  String get gridDragHint =>
      'Přetáhni 4 rohy tak, aby mřížka seděla na fotku,\npak exportuj obrázek s opravenou perspektivou.';

  @override
  String sheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count písem',
      few: '$count písma',
      one: '1 písmo',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presetů',
      few: '$count presety',
      one: '1 preset',
    );
    return '$_temp0';
  }

  @override
  String presetsList(String names) {
    return 'Presety: $names';
  }

  @override
  String get unlimitedPresets => 'Neomezeně vlastních presetů';

  @override
  String get buyOnceKeepForever =>
      'Jednou koupíš, máš navždy, i na dalších zařízeních';

  @override
  String get featuresStayFree => 'Všechny funkce aplikace zůstávají zdarma';

  @override
  String get loadingPrice => 'Načítám cenu…';
}
