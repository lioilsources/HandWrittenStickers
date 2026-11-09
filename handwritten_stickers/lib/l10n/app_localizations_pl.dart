// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get navTextEditor => 'Edytor tekstu';

  @override
  String get navGridAlignment => 'Wyrównanie siatki';

  @override
  String get editorTitle => 'Tekst pisany odręcznie';

  @override
  String get packs => 'Pakiety';

  @override
  String get emojiForMessage => 'Emoji do wiadomości';

  @override
  String get saveToGallery => 'Zapisz w galerii';

  @override
  String get share => 'Udostępnij';

  @override
  String get previewEmpty => 'Napisz coś poniżej…';

  @override
  String get textHint => 'Wpisz tutaj swój tekst…';

  @override
  String get advancedSettings => 'Ustawienia zaawansowane';

  @override
  String get savedToGallery => 'Zapisano w galerii!';

  @override
  String get saveFailed => 'Nie udało się zapisać obrazu';

  @override
  String get shareFailed => 'Nie udało się udostępnić';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Czcionka presetu „$preset” jest niedostępna, użyto $sheet.';
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
  String get newPreset => 'Nowy preset';

  @override
  String get renamePreset => 'Zmień nazwę presetu';

  @override
  String get restorePurchases => 'Przywróć zakupy';

  @override
  String get purchasesRestored => 'Zakupy przywrócone.';

  @override
  String get packsIntro =>
      'Wszystkie funkcje aplikacji są bezpłatne. Pakiety dodają kolejne czcionki i presety.';

  @override
  String get owned => 'Kupione';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count czcionki',
      many: '$count czcionek',
      few: '$count czcionki',
      one: '$count czcionka',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presetu',
      many: '$count presetów',
      few: '$count presety',
      one: '$count preset',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Zakup czeka na zatwierdzenie. Odblokuje się sam.';

  @override
  String get purchaseFailed => 'Zakup się nie powiódł. Spróbuj ponownie.';

  @override
  String get purchasesRestoredUnlocked =>
      'Zakupy przywrócone. Wszystko, co kupiłeś(-aś), jest odblokowane.';

  @override
  String paywallPresets(String names) {
    return 'Presety: $names';
  }

  @override
  String get unlimitedPresets => 'Nieograniczona liczba własnych presetów';

  @override
  String get buyOnce =>
      'Kupujesz raz, masz na zawsze, także na innych urządzeniach';

  @override
  String get allFeaturesFree =>
      'Wszystkie funkcje aplikacji pozostają bezpłatne';

  @override
  String get storeUnavailable =>
      'Sklep jest teraz niedostępny. Spróbuj później.';

  @override
  String buyFor(String price) {
    return 'Kup za $price';
  }

  @override
  String get notForSale => 'Jeszcze niedostępne w sprzedaży';

  @override
  String get loadingPrice => 'Wczytywanie ceny…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: wszystkie pakiety za $price';
  }

  @override
  String get save => 'Zapisz';

  @override
  String get presetSaveTooltip => 'Zapisz bieżącą czcionkę i styl jako preset';

  @override
  String get presetSaveAsNew => 'Zapisz bieżące jako nowy preset';

  @override
  String get presetOverwrite => 'Nadpisz bieżącymi ustawieniami';

  @override
  String get rename => 'Zmień nazwę';

  @override
  String get delete => 'Usuń';

  @override
  String get presetName => 'Nazwa';

  @override
  String get cancel => 'Anuluj';

  @override
  String get deletePresetTitle => 'Usunąć preset?';

  @override
  String deletePresetBody(String name) {
    return '„$name” zostanie usunięty. Tekst w edytorze zostaje.';
  }

  @override
  String get joinLetters => 'Łącz litery';

  @override
  String get letterSpacing => 'Odstęp między literami';

  @override
  String get baselineWobble => 'Falowanie linii';

  @override
  String get sizeVariance => 'Zmienność rozmiaru';

  @override
  String get rotationVariance => 'Zmienność nachylenia';

  @override
  String get opacityVariance => 'Zmienność krycia';

  @override
  String get categoryHandwriting => 'Pismo odręczne';

  @override
  String get categoryCalligraphy => 'Kaligrafia';

  @override
  String get categoryTypography => 'Typografia';

  @override
  String get categoryKids => 'Dla dzieci';

  @override
  String get categoryMaterial => 'Materiały';

  @override
  String get noEmoji => 'Bez emoji';

  @override
  String get saveAlignedImage => 'Zapisz wyrównany obraz';

  @override
  String savedPath(String path) {
    return 'Zapisano: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Błąd: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Wyrównanie siatki — $file';
  }

  @override
  String get openAnotherImage => 'Otwórz inny obraz';

  @override
  String get hideGrid => 'Ukryj siatkę';

  @override
  String get showGrid => 'Pokaż siatkę';

  @override
  String get resetGrid => 'Resetuj siatkę';

  @override
  String get exportAlignedImage => 'Eksportuj wyrównany obraz';

  @override
  String get openTemplatePhoto => 'Otwórz zdjęcie wypełnionego szablonu';

  @override
  String get openImage => 'Otwórz obraz';

  @override
  String get gridInstructions =>
      'Przeciągnij 4 rogi, aby siatka pasowała do zdjęcia,\na potem wyeksportuj obraz z poprawioną perspektywą.';
}
