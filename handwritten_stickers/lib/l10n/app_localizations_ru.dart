// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navTextEditor => 'Текстовый редактор';

  @override
  String get navGridAlignment => 'Выравнивание сетки';

  @override
  String get editorTitle => 'Рукописный текст';

  @override
  String get packs => 'Наборы';

  @override
  String get emojiForMessage => 'Эмодзи к сообщению';

  @override
  String get saveToGallery => 'Сохранить в галерею';

  @override
  String get share => 'Поделиться';

  @override
  String get previewEmpty => 'Напиши что-нибудь ниже…';

  @override
  String get textHint => 'Напиши здесь свой текст…';

  @override
  String get advancedSettings => 'Дополнительные настройки';

  @override
  String get savedToGallery => 'Сохранено в галерею!';

  @override
  String get saveFailed => 'Не удалось сохранить изображение';

  @override
  String get shareFailed => 'Не удалось поделиться';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Шрифт пресета «$preset» недоступен, используется $sheet.';
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
  String get newPreset => 'Новый пресет';

  @override
  String get renamePreset => 'Переименовать пресет';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get purchasesRestored => 'Покупки восстановлены.';

  @override
  String get packsIntro =>
      'Все функции приложения бесплатны. Наборы добавляют новые шрифты и пресеты.';

  @override
  String get owned => 'Куплено';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шрифта',
      many: '$count шрифтов',
      few: '$count шрифта',
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
      many: '$count пресетов',
      few: '$count пресета',
      one: '$count пресет',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Покупка ожидает подтверждения. Она разблокируется сама.';

  @override
  String get purchaseFailed => 'Покупка не удалась. Попробуй ещё раз.';

  @override
  String get purchasesRestoredUnlocked =>
      'Покупки восстановлены. Всё, что ты купил(а), разблокировано.';

  @override
  String paywallPresets(String names) {
    return 'Пресеты: $names';
  }

  @override
  String get unlimitedPresets => 'Неограниченное число своих пресетов';

  @override
  String get buyOnce =>
      'Покупаешь один раз — твоё навсегда, и на других устройствах тоже';

  @override
  String get allFeaturesFree => 'Все функции приложения остаются бесплатными';

  @override
  String get storeUnavailable => 'Магазин сейчас недоступен. Попробуй позже.';

  @override
  String buyFor(String price) {
    return 'Купить за $price';
  }

  @override
  String get notForSale => 'Пока не продаётся';

  @override
  String get loadingPrice => 'Загрузка цены…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: все наборы за $price';
  }

  @override
  String get save => 'Сохранить';

  @override
  String get presetSaveTooltip => 'Сохранить текущий шрифт и стиль как пресет';

  @override
  String get presetSaveAsNew => 'Сохранить текущее как новый пресет';

  @override
  String get presetOverwrite => 'Перезаписать текущими настройками';

  @override
  String get rename => 'Переименовать';

  @override
  String get delete => 'Удалить';

  @override
  String get presetName => 'Название';

  @override
  String get cancel => 'Отмена';

  @override
  String get deletePresetTitle => 'Удалить пресет?';

  @override
  String deletePresetBody(String name) {
    return '«$name» будет удалён. Текст в редакторе останется.';
  }

  @override
  String get joinLetters => 'Соединять буквы';

  @override
  String get letterSpacing => 'Межбуквенный интервал';

  @override
  String get baselineWobble => 'Волнистость строки';

  @override
  String get sizeVariance => 'Разброс размера';

  @override
  String get rotationVariance => 'Разброс наклона';

  @override
  String get opacityVariance => 'Разброс насыщенности';

  @override
  String get categoryHandwriting => 'Рукописные';

  @override
  String get categoryCalligraphy => 'Каллиграфия';

  @override
  String get categoryTypography => 'Типографика';

  @override
  String get categoryKids => 'Детские';

  @override
  String get categoryMaterial => 'Материалы';

  @override
  String get noEmoji => 'Без эмодзи';

  @override
  String get saveAlignedImage => 'Сохранить выровненное изображение';

  @override
  String savedPath(String path) {
    return 'Сохранено: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Ошибка: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Выравнивание сетки — $file';
  }

  @override
  String get openAnotherImage => 'Открыть другое изображение';

  @override
  String get hideGrid => 'Скрыть сетку';

  @override
  String get showGrid => 'Показать сетку';

  @override
  String get resetGrid => 'Сбросить сетку';

  @override
  String get exportAlignedImage => 'Экспортировать выровненное изображение';

  @override
  String get openTemplatePhoto => 'Открой фото своего заполненного шаблона';

  @override
  String get openImage => 'Открыть изображение';

  @override
  String get gridInstructions =>
      'Перетащи 4 угла, чтобы сетка легла на фото,\nзатем экспортируй изображение с исправленной перспективой.';
}
