// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get navTextEditor => 'Текстовий редактор';

  @override
  String get navGridAlignment => 'Вирівнювання сітки';

  @override
  String get editorTitle => 'Рукописний текст';

  @override
  String get packs => 'Набори';

  @override
  String get emojiForMessage => 'Емодзі до повідомлення';

  @override
  String get saveToGallery => 'Зберегти в галерею';

  @override
  String get share => 'Поділитися';

  @override
  String get previewEmpty => 'Напиши щось нижче…';

  @override
  String get textHint => 'Напиши тут свій текст…';

  @override
  String get advancedSettings => 'Додаткові налаштування';

  @override
  String get savedToGallery => 'Збережено в галерею!';

  @override
  String get saveFailed => 'Не вдалося зберегти зображення';

  @override
  String get shareFailed => 'Не вдалося поділитися';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Шрифт пресета «$preset» недоступний, використано $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Пресет';

  @override
  String get newPreset => 'Новий пресет';

  @override
  String get renamePreset => 'Перейменувати пресет';

  @override
  String get restorePurchases => 'Відновити покупки';

  @override
  String get purchasesRestored => 'Покупки відновлено.';

  @override
  String get packsIntro =>
      'Усі функції застосунку безкоштовні. Набори додають нові шрифти й пресети.';

  @override
  String get owned => 'Куплено';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шрифту',
      many: '$count шрифтів',
      few: '$count шрифти',
      one: '$count шрифт',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пресета',
      many: '$count пресетів',
      few: '$count пресети',
      one: '$count пресет',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Покупка чекає на схвалення. Вона розблокується сама.';

  @override
  String get purchaseFailed => 'Покупка не вдалася. Спробуй ще раз.';

  @override
  String get purchasesRestoredUnlocked =>
      'Покупки відновлено. Усе, що ти купив(-ла), розблоковано.';

  @override
  String paywallPresets(String names) {
    return 'Пресети: $names';
  }

  @override
  String get unlimitedPresets => 'Необмежено власних пресетів';

  @override
  String get buyOnce =>
      'Купуєш один раз — твоє назавжди, і на інших пристроях теж';

  @override
  String get allFeaturesFree =>
      'Усі функції застосунку залишаються безкоштовними';

  @override
  String get storeUnavailable => 'Магазин зараз недоступний. Спробуй пізніше.';

  @override
  String buyFor(String price) {
    return 'Купити за $price';
  }

  @override
  String get notForSale => 'Поки що не продається';

  @override
  String get loadingPrice => 'Завантаження ціни…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: усі набори за $price';
  }

  @override
  String get save => 'Зберегти';

  @override
  String get presetSaveTooltip => 'Зберегти поточний шрифт і стиль як пресет';

  @override
  String get presetSaveAsNew => 'Зберегти поточне як новий пресет';

  @override
  String get presetOverwrite => 'Перезаписати поточними налаштуваннями';

  @override
  String get rename => 'Перейменувати';

  @override
  String get delete => 'Видалити';

  @override
  String get presetName => 'Назва';

  @override
  String get cancel => 'Скасувати';

  @override
  String get deletePresetTitle => 'Видалити пресет?';

  @override
  String deletePresetBody(String name) {
    return '«$name» буде видалено. Текст у редакторі залишиться.';
  }

  @override
  String get joinLetters => 'Поєднувати літери';

  @override
  String get letterSpacing => 'Відстань між літерами';

  @override
  String get baselineWobble => 'Хвилястість рядка';

  @override
  String get sizeVariance => 'Розкид розміру';

  @override
  String get rotationVariance => 'Розкид нахилу';

  @override
  String get opacityVariance => 'Розкид насиченості';

  @override
  String get categoryHandwriting => 'Рукописні';

  @override
  String get categoryCalligraphy => 'Каліграфія';

  @override
  String get categoryTypography => 'Типографіка';

  @override
  String get categoryKids => 'Дитячі';

  @override
  String get categoryMaterial => 'Матеріали';

  @override
  String get noEmoji => 'Без емодзі';

  @override
  String get saveAlignedImage => 'Зберегти вирівняне зображення';

  @override
  String savedPath(String path) {
    return 'Збережено: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Помилка: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Вирівнювання сітки — $file';
  }

  @override
  String get openAnotherImage => 'Відкрити інше зображення';

  @override
  String get hideGrid => 'Сховати сітку';

  @override
  String get showGrid => 'Показати сітку';

  @override
  String get resetGrid => 'Скинути сітку';

  @override
  String get exportAlignedImage => 'Експортувати вирівняне зображення';

  @override
  String get openTemplatePhoto => 'Відкрий фото свого заповненого шаблону';

  @override
  String get openImage => 'Відкрити зображення';

  @override
  String get gridInstructions =>
      'Перетягни 4 кути, щоб сітка лягла на фото,\nпотім експортуй зображення з виправленою перспективою.';
}
