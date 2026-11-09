// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navTextEditor => 'Editor di testo';

  @override
  String get navGridAlignment => 'Allineamento griglia';

  @override
  String get editorTitle => 'Testo scritto a mano';

  @override
  String get packs => 'Pacchetti';

  @override
  String get emojiForMessage => 'Emoji del messaggio';

  @override
  String get saveToGallery => 'Salva nella galleria';

  @override
  String get share => 'Condividi';

  @override
  String get previewEmpty => 'Scrivi qualcosa qui sotto…';

  @override
  String get textHint => 'Scrivi qui il tuo testo…';

  @override
  String get advancedSettings => 'Impostazioni avanzate';

  @override
  String get savedToGallery => 'Salvato nella galleria!';

  @override
  String get saveFailed => 'Impossibile salvare l’immagine';

  @override
  String get shareFailed => 'Condivisione non riuscita';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Il carattere del preset «$preset» non è disponibile, uso $sheet.';
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
  String get newPreset => 'Nuovo preset';

  @override
  String get renamePreset => 'Rinomina preset';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get purchasesRestored => 'Acquisti ripristinati.';

  @override
  String get packsIntro =>
      'Tutte le funzioni dell’app sono gratuite. I pacchetti aggiungono altri caratteri e preset.';

  @override
  String get owned => 'Acquistato';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caratteri',
      many: '$count caratteri',
      one: '$count carattere',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preset',
      many: '$count preset',
      one: '$count preset',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'L’acquisto è in attesa di approvazione. Si sbloccherà da solo.';

  @override
  String get purchaseFailed => 'L’acquisto non è riuscito. Riprova.';

  @override
  String get purchasesRestoredUnlocked =>
      'Acquisti ripristinati. Tutto ciò che hai comprato è sbloccato.';

  @override
  String paywallPresets(String names) {
    return 'Preset: $names';
  }

  @override
  String get unlimitedPresets => 'Preset personali illimitati';

  @override
  String get buyOnce =>
      'Compri una volta, è tuo per sempre, anche sugli altri dispositivi';

  @override
  String get allFeaturesFree => 'Tutte le funzioni dell’app restano gratuite';

  @override
  String get storeUnavailable =>
      'Lo store non è disponibile al momento. Riprova più tardi.';

  @override
  String buyFor(String price) {
    return 'Acquista a $price';
  }

  @override
  String get notForSale => 'Non ancora in vendita';

  @override
  String get loadingPrice => 'Caricamento prezzo…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: tutti i pacchetti a $price';
  }

  @override
  String get save => 'Salva';

  @override
  String get presetSaveTooltip => 'Salva carattere e stile attuali come preset';

  @override
  String get presetSaveAsNew => 'Salva l’attuale come nuovo preset';

  @override
  String get presetOverwrite => 'Sovrascrivi con le impostazioni attuali';

  @override
  String get rename => 'Rinomina';

  @override
  String get delete => 'Elimina';

  @override
  String get presetName => 'Nome';

  @override
  String get cancel => 'Annulla';

  @override
  String get deletePresetTitle => 'Eliminare il preset?';

  @override
  String deletePresetBody(String name) {
    return '«$name» verrà eliminato. Il testo nell’editor resta.';
  }

  @override
  String get joinLetters => 'Unisci le lettere';

  @override
  String get letterSpacing => 'Spaziatura lettere';

  @override
  String get baselineWobble => 'Ondulazione della riga';

  @override
  String get sizeVariance => 'Variazione dimensione';

  @override
  String get rotationVariance => 'Variazione inclinazione';

  @override
  String get opacityVariance => 'Variazione opacità';

  @override
  String get categoryHandwriting => 'Scrittura a mano';

  @override
  String get categoryCalligraphy => 'Calligrafia';

  @override
  String get categoryTypography => 'Tipografia';

  @override
  String get categoryKids => 'Bambini';

  @override
  String get categoryMaterial => 'Materiali';

  @override
  String get noEmoji => 'Nessuna emoji';

  @override
  String get saveAlignedImage => 'Salva immagine allineata';

  @override
  String savedPath(String path) {
    return 'Salvato: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Errore: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Allineamento griglia — $file';
  }

  @override
  String get openAnotherImage => 'Apri un’altra immagine';

  @override
  String get hideGrid => 'Nascondi griglia';

  @override
  String get showGrid => 'Mostra griglia';

  @override
  String get resetGrid => 'Reimposta griglia';

  @override
  String get exportAlignedImage => 'Esporta immagine allineata';

  @override
  String get openTemplatePhoto =>
      'Apri una foto del tuo modello scritto a mano';

  @override
  String get openImage => 'Apri immagine';

  @override
  String get gridInstructions =>
      'Trascina i 4 angoli per allineare la griglia alla foto,\npoi esporta l’immagine con la prospettiva corretta.';
}
