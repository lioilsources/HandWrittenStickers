// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navTextEditor => 'Texteditor';

  @override
  String get navGridAlignment => 'Rasterausrichtung';

  @override
  String get editorTitle => 'Handschriftlicher Text';

  @override
  String get packs => 'Pakete';

  @override
  String get emojiForMessage => 'Emoji zur Nachricht';

  @override
  String get saveToGallery => 'In Galerie speichern';

  @override
  String get share => 'Teilen';

  @override
  String get previewEmpty => 'Schreib unten etwas…';

  @override
  String get textHint => 'Schreib hier deinen Text…';

  @override
  String get advancedSettings => 'Erweiterte Einstellungen';

  @override
  String get savedToGallery => 'In der Galerie gespeichert!';

  @override
  String get saveFailed => 'Bild konnte nicht gespeichert werden';

  @override
  String get shareFailed => 'Teilen fehlgeschlagen';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Die Schrift der Vorlage „$preset“ ist nicht verfügbar, verwendet wird $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Vorlage';

  @override
  String get newPreset => 'Neue Vorlage';

  @override
  String get renamePreset => 'Vorlage umbenennen';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get purchasesRestored => 'Käufe wiederhergestellt.';

  @override
  String get packsIntro =>
      'Alle Funktionen der App sind kostenlos. Pakete bringen weitere Schriften und Vorlagen.';

  @override
  String get owned => 'Gekauft';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schriften',
      one: '$count Schrift',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vorlagen',
      one: '$count Vorlage',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Der Kauf wartet auf Freigabe. Er wird automatisch freigeschaltet.';

  @override
  String get purchaseFailed =>
      'Der Kauf ist fehlgeschlagen. Bitte versuch es noch einmal.';

  @override
  String get purchasesRestoredUnlocked =>
      'Käufe wiederhergestellt. Alles, was du gekauft hast, ist freigeschaltet.';

  @override
  String paywallPresets(String names) {
    return 'Vorlagen: $names';
  }

  @override
  String get unlimitedPresets => 'Unbegrenzt eigene Vorlagen';

  @override
  String get buyOnce =>
      'Einmal kaufen, für immer behalten, auch auf deinen anderen Geräten';

  @override
  String get allFeaturesFree => 'Alle Funktionen der App bleiben kostenlos';

  @override
  String get storeUnavailable =>
      'Der Store ist gerade nicht erreichbar. Versuch es später.';

  @override
  String buyFor(String price) {
    return 'Für $price kaufen';
  }

  @override
  String get notForSale => 'Noch nicht im Verkauf';

  @override
  String get loadingPrice => 'Preis wird geladen…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: alle Pakete für $price';
  }

  @override
  String get save => 'Speichern';

  @override
  String get presetSaveTooltip =>
      'Aktuelle Schrift und Stil als Vorlage speichern';

  @override
  String get presetSaveAsNew => 'Aktuelles als neue Vorlage speichern';

  @override
  String get presetOverwrite => 'Mit aktuellen Einstellungen überschreiben';

  @override
  String get rename => 'Umbenennen';

  @override
  String get delete => 'Löschen';

  @override
  String get presetName => 'Name';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get deletePresetTitle => 'Vorlage löschen?';

  @override
  String deletePresetBody(String name) {
    return '„$name“ wird gelöscht. Der Text im Editor bleibt.';
  }

  @override
  String get joinLetters => 'Buchstaben verbinden';

  @override
  String get letterSpacing => 'Buchstabenabstand';

  @override
  String get baselineWobble => 'Zeilenschwankung';

  @override
  String get sizeVariance => 'Größenschwankung';

  @override
  String get rotationVariance => 'Neigungsschwankung';

  @override
  String get opacityVariance => 'Deckkraftschwankung';

  @override
  String get categoryHandwriting => 'Handschrift';

  @override
  String get categoryCalligraphy => 'Kalligrafie';

  @override
  String get categoryTypography => 'Typografie';

  @override
  String get categoryKids => 'Kinder';

  @override
  String get categoryMaterial => 'Materialien';

  @override
  String get noEmoji => 'Kein Emoji';

  @override
  String get saveAlignedImage => 'Ausgerichtetes Bild speichern';

  @override
  String savedPath(String path) {
    return 'Gespeichert: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Fehler: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Rasterausrichtung — $file';
  }

  @override
  String get openAnotherImage => 'Anderes Bild öffnen';

  @override
  String get hideGrid => 'Raster ausblenden';

  @override
  String get showGrid => 'Raster einblenden';

  @override
  String get resetGrid => 'Raster zurücksetzen';

  @override
  String get exportAlignedImage => 'Ausgerichtetes Bild exportieren';

  @override
  String get openTemplatePhoto => 'Öffne ein Foto deiner ausgefüllten Vorlage';

  @override
  String get openImage => 'Bild öffnen';

  @override
  String get gridInstructions =>
      'Zieh die 4 Ecken so, dass das Raster auf dem Foto sitzt,\nund exportiere dann das perspektivisch korrigierte Bild.';
}
