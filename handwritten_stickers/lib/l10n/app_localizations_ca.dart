// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get navTextEditor => 'Editor de text';

  @override
  String get navGridAlignment => 'Alinear la graella';

  @override
  String get editorTitle => 'Text manuscrit';

  @override
  String get packs => 'Paquets';

  @override
  String get emojiForMessage => 'Emoji del missatge';

  @override
  String get saveToGallery => 'Desa a la galeria';

  @override
  String get share => 'Comparteix';

  @override
  String get previewEmpty => 'Escriu alguna cosa a sota…';

  @override
  String get textHint => 'Escriu el teu text aquí…';

  @override
  String get advancedSettings => 'Configuració avançada';

  @override
  String get savedToGallery => 'Desat a la galeria!';

  @override
  String get saveFailed => 'No s’ha pogut desar la imatge';

  @override
  String get shareFailed => 'No s’ha pogut compartir';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'La lletra del predefinit «$preset» no està disponible; s’utilitza $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Predefinit';

  @override
  String get newPreset => 'Predefinit nou';

  @override
  String get renamePreset => 'Canvia el nom del predefinit';

  @override
  String get restorePurchases => 'Restaura les compres';

  @override
  String get purchasesRestored => 'Compres restaurades.';

  @override
  String get packsIntro =>
      'Totes les funcions de l’app són gratuïtes. Els paquets afegeixen més lletres i predefinits.';

  @override
  String get owned => 'Comprat';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lletres',
      one: '$count lletra',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinits',
      one: '$count predefinit',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'La compra està pendent d’aprovació. Es desbloquejarà sola.';

  @override
  String get purchaseFailed =>
      'La compra no s’ha pogut fer. Torna-ho a provar.';

  @override
  String get purchasesRestoredUnlocked =>
      'Compres restaurades. Tot el que has comprat està desbloquejat.';

  @override
  String paywallPresets(String names) {
    return 'Predefinits: $names';
  }

  @override
  String get unlimitedPresets => 'Predefinits propis il·limitats';

  @override
  String get buyOnce =>
      'Compra una vegada i és teu per sempre, també als altres dispositius';

  @override
  String get allFeaturesFree =>
      'Totes les funcions de l’app continuen sent gratuïtes';

  @override
  String get storeUnavailable =>
      'La botiga no està disponible ara mateix. Torna-ho a provar més tard.';

  @override
  String buyFor(String price) {
    return 'Compra per $price';
  }

  @override
  String get notForSale => 'Encara no està a la venda';

  @override
  String get loadingPrice => 'S’està carregant el preu…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: tots els paquets per $price';
  }

  @override
  String get save => 'Desa';

  @override
  String get presetSaveTooltip =>
      'Desa la lletra i l’estil actuals com a predefinit';

  @override
  String get presetSaveAsNew => 'Desa l’actual com a predefinit nou';

  @override
  String get presetOverwrite => 'Sobreescriu amb la configuració actual';

  @override
  String get rename => 'Canvia el nom';

  @override
  String get delete => 'Suprimeix';

  @override
  String get presetName => 'Nom';

  @override
  String get cancel => 'Cancel·la';

  @override
  String get deletePresetTitle => 'Vols suprimir el predefinit?';

  @override
  String deletePresetBody(String name) {
    return '«$name» se suprimirà. El text de l’editor es manté.';
  }

  @override
  String get joinLetters => 'Uneix les lletres';

  @override
  String get letterSpacing => 'Espai entre lletres';

  @override
  String get baselineWobble => 'Ondulació de la línia';

  @override
  String get sizeVariance => 'Variació de mida';

  @override
  String get rotationVariance => 'Variació d’inclinació';

  @override
  String get opacityVariance => 'Variació d’opacitat';

  @override
  String get categoryHandwriting => 'Manuscrita';

  @override
  String get categoryCalligraphy => 'Cal·ligrafia';

  @override
  String get categoryTypography => 'Tipografia';

  @override
  String get categoryKids => 'Infantil';

  @override
  String get categoryMaterial => 'Materials';

  @override
  String get noEmoji => 'Sense emoji';

  @override
  String get saveAlignedImage => 'Desa la imatge alineada';

  @override
  String savedPath(String path) {
    return 'Desat: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Alinear la graella — $file';
  }

  @override
  String get openAnotherImage => 'Obre una altra imatge';

  @override
  String get hideGrid => 'Amaga la graella';

  @override
  String get showGrid => 'Mostra la graella';

  @override
  String get resetGrid => 'Restableix la graella';

  @override
  String get exportAlignedImage => 'Exporta la imatge alineada';

  @override
  String get openTemplatePhoto =>
      'Obre una foto de la teva plantilla escrita a mà';

  @override
  String get openImage => 'Obre una imatge';

  @override
  String get gridInstructions =>
      'Arrossega les 4 cantonades perquè la graella encaixi a la foto\ni després exporta la imatge amb la perspectiva corregida.';
}
