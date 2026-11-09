// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get navTextEditor => 'ਟੈਕਸਟ ਐਡੀਟਰ';

  @override
  String get navGridAlignment => 'ਗ੍ਰਿਡ ਇਕਸਾਰਤਾ';

  @override
  String get editorTitle => 'ਹੱਥ ਨਾਲ ਲਿਖਿਆ ਟੈਕਸਟ';

  @override
  String get packs => 'ਪੈਕ';

  @override
  String get emojiForMessage => 'ਸੁਨੇਹੇ ਲਈ ਇਮੋਜੀ';

  @override
  String get saveToGallery => 'ਗੈਲਰੀ ਵਿੱਚ ਸੰਭਾਲੋ';

  @override
  String get share => 'ਸਾਂਝਾ ਕਰੋ';

  @override
  String get previewEmpty => 'ਹੇਠਾਂ ਕੁਝ ਲਿਖੋ…';

  @override
  String get textHint => 'ਆਪਣਾ ਟੈਕਸਟ ਇੱਥੇ ਲਿਖੋ…';

  @override
  String get advancedSettings => 'ਉੱਨਤ ਸੈਟਿੰਗਾਂ';

  @override
  String get savedToGallery => 'ਗੈਲਰੀ ਵਿੱਚ ਸੰਭਾਲਿਆ ਗਿਆ!';

  @override
  String get saveFailed => 'ਤਸਵੀਰ ਸੰਭਾਲੀ ਨਹੀਂ ਜਾ ਸਕੀ';

  @override
  String get shareFailed => 'ਸਾਂਝਾ ਨਹੀਂ ਹੋ ਸਕਿਆ';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'ਪ੍ਰੀਸੈੱਟ “$preset” ਦਾ ਫੌਂਟ ਉਪਲਬਧ ਨਹੀਂ, $sheet ਵਰਤਿਆ ਗਿਆ।';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'ਪ੍ਰੀਸੈੱਟ';

  @override
  String get newPreset => 'ਨਵਾਂ ਪ੍ਰੀਸੈੱਟ';

  @override
  String get renamePreset => 'ਪ੍ਰੀਸੈੱਟ ਦਾ ਨਾਂ ਬਦਲੋ';

  @override
  String get restorePurchases => 'ਖਰੀਦਾਂ ਬਹਾਲ ਕਰੋ';

  @override
  String get purchasesRestored => 'ਖਰੀਦਾਂ ਬਹਾਲ ਹੋ ਗਈਆਂ।';

  @override
  String get packsIntro =>
      'ਐਪ ਦੀਆਂ ਸਾਰੀਆਂ ਸਹੂਲਤਾਂ ਮੁਫ਼ਤ ਹਨ। ਪੈਕ ਹੋਰ ਫੌਂਟ ਅਤੇ ਪ੍ਰੀਸੈੱਟ ਜੋੜਦੇ ਹਨ।';

  @override
  String get owned => 'ਤੁਹਾਡੇ ਕੋਲ ਹੈ';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਫੌਂਟ',
      one: '$count ਫੌਂਟ',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਪ੍ਰੀਸੈੱਟ',
      one: '$count ਪ੍ਰੀਸੈੱਟ',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'ਖਰੀਦ ਮਨਜ਼ੂਰੀ ਦੀ ਉਡੀਕ ਵਿੱਚ ਹੈ। ਇਹ ਆਪਣੇ ਆਪ ਅਨਲੌਕ ਹੋ ਜਾਵੇਗੀ।';

  @override
  String get purchaseFailed =>
      'ਖਰੀਦ ਨਹੀਂ ਹੋ ਸਕੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get purchasesRestoredUnlocked =>
      'ਖਰੀਦਾਂ ਬਹਾਲ ਹੋ ਗਈਆਂ। ਤੁਸੀਂ ਜੋ ਖਰੀਦਿਆ ਉਹ ਸਭ ਅਨਲੌਕ ਹੈ।';

  @override
  String paywallPresets(String names) {
    return 'ਪ੍ਰੀਸੈੱਟ: $names';
  }

  @override
  String get unlimitedPresets => 'ਅਸੀਮਤ ਆਪਣੇ ਪ੍ਰੀਸੈੱਟ';

  @override
  String get buyOnce => 'ਇੱਕ ਵਾਰ ਖਰੀਦੋ, ਸਦਾ ਲਈ ਤੁਹਾਡਾ, ਹੋਰ ਡਿਵਾਈਸਾਂ ’ਤੇ ਵੀ';

  @override
  String get allFeaturesFree => 'ਐਪ ਦੀਆਂ ਸਾਰੀਆਂ ਸਹੂਲਤਾਂ ਮੁਫ਼ਤ ਰਹਿਣਗੀਆਂ';

  @override
  String get storeUnavailable => 'ਸਟੋਰ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ। ਬਾਅਦ ਵਿੱਚ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String buyFor(String price) {
    return '$price ਵਿੱਚ ਖਰੀਦੋ';
  }

  @override
  String get notForSale => 'ਅਜੇ ਵਿਕਰੀ ਲਈ ਨਹੀਂ';

  @override
  String get loadingPrice => 'ਕੀਮਤ ਲੋਡ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: ਸਾਰੇ ਪੈਕ $price ਵਿੱਚ';
  }

  @override
  String get save => 'ਸੰਭਾਲੋ';

  @override
  String get presetSaveTooltip =>
      'ਮੌਜੂਦਾ ਫੌਂਟ ਅਤੇ ਸਟਾਈਲ ਨੂੰ ਪ੍ਰੀਸੈੱਟ ਵਜੋਂ ਸੰਭਾਲੋ';

  @override
  String get presetSaveAsNew => 'ਮੌਜੂਦਾ ਨੂੰ ਨਵੇਂ ਪ੍ਰੀਸੈੱਟ ਵਜੋਂ ਸੰਭਾਲੋ';

  @override
  String get presetOverwrite => 'ਮੌਜੂਦਾ ਸੈਟਿੰਗਾਂ ਨਾਲ ਬਦਲੋ';

  @override
  String get rename => 'ਨਾਂ ਬਦਲੋ';

  @override
  String get delete => 'ਮਿਟਾਓ';

  @override
  String get presetName => 'ਨਾਂ';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get deletePresetTitle => 'ਪ੍ਰੀਸੈੱਟ ਮਿਟਾਉਣਾ ਹੈ?';

  @override
  String deletePresetBody(String name) {
    return '“$name” ਮਿਟਾ ਦਿੱਤਾ ਜਾਵੇਗਾ। ਐਡੀਟਰ ਵਿੱਚ ਟੈਕਸਟ ਰਹੇਗਾ।';
  }

  @override
  String get joinLetters => 'ਅੱਖਰ ਜੋੜੋ';

  @override
  String get letterSpacing => 'ਅੱਖਰਾਂ ਦੀ ਵਿੱਥ';

  @override
  String get baselineWobble => 'ਲਾਈਨ ਦੀ ਲਹਿਰ';

  @override
  String get sizeVariance => 'ਆਕਾਰ ਵਿੱਚ ਫ਼ਰਕ';

  @override
  String get rotationVariance => 'ਝੁਕਾਅ ਵਿੱਚ ਫ਼ਰਕ';

  @override
  String get opacityVariance => 'ਗੂੜ੍ਹੇਪਣ ਵਿੱਚ ਫ਼ਰਕ';

  @override
  String get categoryHandwriting => 'ਹੱਥ ਲਿਖਤ';

  @override
  String get categoryCalligraphy => 'ਖ਼ੁਸ਼ਨਵੀਸੀ';

  @override
  String get categoryTypography => 'ਟਾਈਪੋਗ੍ਰਾਫੀ';

  @override
  String get categoryKids => 'ਬੱਚਿਆਂ ਲਈ';

  @override
  String get categoryMaterial => 'ਸਮੱਗਰੀ';

  @override
  String get noEmoji => 'ਕੋਈ ਇਮੋਜੀ ਨਹੀਂ';

  @override
  String get saveAlignedImage => 'ਇਕਸਾਰ ਕੀਤੀ ਤਸਵੀਰ ਸੰਭਾਲੋ';

  @override
  String savedPath(String path) {
    return 'ਸੰਭਾਲਿਆ: $path';
  }

  @override
  String errorMessage(String error) {
    return 'ਗੜਬੜ: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ਗ੍ਰਿਡ ਇਕਸਾਰਤਾ — $file';
  }

  @override
  String get openAnotherImage => 'ਹੋਰ ਤਸਵੀਰ ਖੋਲ੍ਹੋ';

  @override
  String get hideGrid => 'ਗ੍ਰਿਡ ਲੁਕਾਓ';

  @override
  String get showGrid => 'ਗ੍ਰਿਡ ਦਿਖਾਓ';

  @override
  String get resetGrid => 'ਗ੍ਰਿਡ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get exportAlignedImage => 'ਇਕਸਾਰ ਕੀਤੀ ਤਸਵੀਰ ਐਕਸਪੋਰਟ ਕਰੋ';

  @override
  String get openTemplatePhoto => 'ਆਪਣੇ ਭਰੇ ਹੋਏ ਟੈਮਪਲੇਟ ਦੀ ਫ਼ੋਟੋ ਖੋਲ੍ਹੋ';

  @override
  String get openImage => 'ਤਸਵੀਰ ਖੋਲ੍ਹੋ';

  @override
  String get gridInstructions =>
      'ਚਾਰੇ ਕੋਨੇ ਖਿੱਚ ਕੇ ਗ੍ਰਿਡ ਨੂੰ ਫ਼ੋਟੋ ’ਤੇ ਬਿਠਾਓ,\nਫਿਰ ਸਹੀ ਕੀਤੇ ਦ੍ਰਿਸ਼ਟੀਕੋਣ ਵਾਲੀ ਤਸਵੀਰ ਐਕਸਪੋਰਟ ਕਰੋ।';
}
