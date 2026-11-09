// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get navTextEditor => 'ಪಠ್ಯ ಸಂಪಾದಕ';

  @override
  String get navGridAlignment => 'ಗ್ರಿಡ್ ಜೋಡಣೆ';

  @override
  String get editorTitle => 'ಕೈಬರಹದ ಪಠ್ಯ';

  @override
  String get packs => 'ಪ್ಯಾಕ್‌ಗಳು';

  @override
  String get emojiForMessage => 'ಸಂದೇಶಕ್ಕೆ ಎಮೋಜಿ';

  @override
  String get saveToGallery => 'ಗ್ಯಾಲರಿಗೆ ಉಳಿಸಿ';

  @override
  String get share => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get previewEmpty => 'ಕೆಳಗೆ ಏನಾದರೂ ಬರೆಯಿರಿ…';

  @override
  String get textHint => 'ನಿಮ್ಮ ಪಠ್ಯವನ್ನು ಇಲ್ಲಿ ಬರೆಯಿರಿ…';

  @override
  String get advancedSettings => 'ಸುಧಾರಿತ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get savedToGallery => 'ಗ್ಯಾಲರಿಗೆ ಉಳಿಸಲಾಗಿದೆ!';

  @override
  String get saveFailed => 'ಚಿತ್ರವನ್ನು ಉಳಿಸಲಾಗಲಿಲ್ಲ';

  @override
  String get shareFailed => 'ಹಂಚಿಕೊಳ್ಳಲಾಗಲಿಲ್ಲ';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'ಪ್ರೀಸೆಟ್ “$preset” ಫಾಂಟ್ ಲಭ್ಯವಿಲ್ಲ, $sheet ಬಳಸಲಾಗಿದೆ.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'ಪ್ರೀಸೆಟ್';

  @override
  String get newPreset => 'ಹೊಸ ಪ್ರೀಸೆಟ್';

  @override
  String get renamePreset => 'ಪ್ರೀಸೆಟ್ ಮರುಹೆಸರಿಸಿ';

  @override
  String get restorePurchases => 'ಖರೀದಿಗಳನ್ನು ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get purchasesRestored => 'ಖರೀದಿಗಳನ್ನು ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ.';

  @override
  String get packsIntro =>
      'ಆ್ಯಪ್‌ನ ಎಲ್ಲಾ ವೈಶಿಷ್ಟ್ಯಗಳು ಉಚಿತ. ಪ್ಯಾಕ್‌ಗಳು ಇನ್ನಷ್ಟು ಫಾಂಟ್ ಮತ್ತು ಪ್ರೀಸೆಟ್‌ಗಳನ್ನು ಸೇರಿಸುತ್ತವೆ.';

  @override
  String get owned => 'ನಿಮ್ಮದು';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಫಾಂಟ್‌ಗಳು',
      one: '$count ಫಾಂಟ್',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರೀಸೆಟ್‌ಗಳು',
      one: '$count ಪ್ರೀಸೆಟ್',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'ಖರೀದಿ ಅನುಮೋದನೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ. ಅದು ತಾನಾಗಿಯೇ ಅನ್‌ಲಾಕ್ ಆಗುತ್ತದೆ.';

  @override
  String get purchaseFailed => 'ಖರೀದಿ ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get purchasesRestoredUnlocked =>
      'ಖರೀದಿಗಳನ್ನು ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ. ನೀವು ಖರೀದಿಸಿದ್ದೆಲ್ಲ ಅನ್‌ಲಾಕ್ ಆಗಿದೆ.';

  @override
  String paywallPresets(String names) {
    return 'ಪ್ರೀಸೆಟ್‌ಗಳು: $names';
  }

  @override
  String get unlimitedPresets => 'ಅನಿಯಮಿತ ಸ್ವಂತ ಪ್ರೀಸೆಟ್‌ಗಳು';

  @override
  String get buyOnce => 'ಒಮ್ಮೆ ಖರೀದಿಸಿ, ಎಂದೆಂದಿಗೂ ನಿಮ್ಮದು, ಇತರ ಸಾಧನಗಳಲ್ಲೂ';

  @override
  String get allFeaturesFree =>
      'ಆ್ಯಪ್‌ನ ಎಲ್ಲಾ ವೈಶಿಷ್ಟ್ಯಗಳು ಉಚಿತವಾಗಿಯೇ ಇರುತ್ತವೆ';

  @override
  String get storeUnavailable => 'ಸ್ಟೋರ್ ಈಗ ಲಭ್ಯವಿಲ್ಲ. ನಂತರ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String buyFor(String price) {
    return '$priceಗೆ ಖರೀದಿಸಿ';
  }

  @override
  String get notForSale => 'ಇನ್ನೂ ಮಾರಾಟಕ್ಕಿಲ್ಲ';

  @override
  String get loadingPrice => 'ಬೆಲೆ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: ಎಲ್ಲಾ ಪ್ಯಾಕ್‌ಗಳು $priceಗೆ';
  }

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get presetSaveTooltip =>
      'ಪ್ರಸ್ತುತ ಫಾಂಟ್ ಮತ್ತು ಶೈಲಿಯನ್ನು ಪ್ರೀಸೆಟ್ ಆಗಿ ಉಳಿಸಿ';

  @override
  String get presetSaveAsNew => 'ಪ್ರಸ್ತುತವನ್ನು ಹೊಸ ಪ್ರೀಸೆಟ್ ಆಗಿ ಉಳಿಸಿ';

  @override
  String get presetOverwrite => 'ಪ್ರಸ್ತುತ ಸೆಟ್ಟಿಂಗ್‌ಗಳಿಂದ ಬದಲಿಸಿ';

  @override
  String get rename => 'ಮರುಹೆಸರಿಸಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get presetName => 'ಹೆಸರು';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get deletePresetTitle => 'ಪ್ರೀಸೆಟ್ ಅಳಿಸಬೇಕೇ?';

  @override
  String deletePresetBody(String name) {
    return '“$name” ಅಳಿಸಲಾಗುತ್ತದೆ. ಸಂಪಾದಕದಲ್ಲಿನ ಪಠ್ಯ ಉಳಿಯುತ್ತದೆ.';
  }

  @override
  String get joinLetters => 'ಅಕ್ಷರಗಳನ್ನು ಜೋಡಿಸಿ';

  @override
  String get letterSpacing => 'ಅಕ್ಷರಗಳ ಅಂತರ';

  @override
  String get baselineWobble => 'ಸಾಲಿನ ಅಲೆ';

  @override
  String get sizeVariance => 'ಗಾತ್ರದ ವ್ಯತ್ಯಾಸ';

  @override
  String get rotationVariance => 'ಓರೆಯ ವ್ಯತ್ಯಾಸ';

  @override
  String get opacityVariance => 'ಗಾಢತೆಯ ವ್ಯತ್ಯಾಸ';

  @override
  String get categoryHandwriting => 'ಕೈಬರಹ';

  @override
  String get categoryCalligraphy => 'ಕ್ಯಾಲಿಗ್ರಫಿ';

  @override
  String get categoryTypography => 'ಮುದ್ರಣಾಕ್ಷರ';

  @override
  String get categoryKids => 'ಮಕ್ಕಳಿಗೆ';

  @override
  String get categoryMaterial => 'ಸಾಮಗ್ರಿಗಳು';

  @override
  String get noEmoji => 'ಎಮೋಜಿ ಇಲ್ಲ';

  @override
  String get saveAlignedImage => 'ಜೋಡಿಸಿದ ಚಿತ್ರ ಉಳಿಸಿ';

  @override
  String savedPath(String path) {
    return 'ಉಳಿಸಲಾಗಿದೆ: $path';
  }

  @override
  String errorMessage(String error) {
    return 'ದೋಷ: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ಗ್ರಿಡ್ ಜೋಡಣೆ — $file';
  }

  @override
  String get openAnotherImage => 'ಬೇರೆ ಚಿತ್ರ ತೆರೆಯಿರಿ';

  @override
  String get hideGrid => 'ಗ್ರಿಡ್ ಮರೆಮಾಡಿ';

  @override
  String get showGrid => 'ಗ್ರಿಡ್ ತೋರಿಸಿ';

  @override
  String get resetGrid => 'ಗ್ರಿಡ್ ಮರುಹೊಂದಿಸಿ';

  @override
  String get exportAlignedImage => 'ಜೋಡಿಸಿದ ಚಿತ್ರ ರಫ್ತು ಮಾಡಿ';

  @override
  String get openTemplatePhoto => 'ನೀವು ತುಂಬಿದ ಟೆಂಪ್ಲೇಟ್‌ನ ಫೋಟೋ ತೆರೆಯಿರಿ';

  @override
  String get openImage => 'ಚಿತ್ರ ತೆರೆಯಿರಿ';

  @override
  String get gridInstructions =>
      'ನಾಲ್ಕು ಮೂಲೆಗಳನ್ನು ಎಳೆದು ಗ್ರಿಡ್ ಅನ್ನು ಫೋಟೋಗೆ ಹೊಂದಿಸಿ,\nನಂತರ ದೃಷ್ಟಿಕೋನ ಸರಿಪಡಿಸಿದ ಚಿತ್ರವನ್ನು ರಫ್ತು ಮಾಡಿ.';
}
