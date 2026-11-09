// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTextEditor => 'Text Editor';

  @override
  String get navGridAlignment => 'Grid Alignment';

  @override
  String get editorTitle => 'Handwritten Text';

  @override
  String get packs => 'Packs';

  @override
  String get emojiForMessage => 'Emoji for the message';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get share => 'Share';

  @override
  String get previewEmpty => 'Type something below…';

  @override
  String get textHint => 'Type your text here…';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get savedToGallery => 'Saved to gallery!';

  @override
  String get saveFailed => 'Failed to save image';

  @override
  String get shareFailed => 'Sharing failed';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'The font of preset “$preset” is not available, using $sheet.';
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
  String get newPreset => 'New preset';

  @override
  String get renamePreset => 'Rename preset';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchasesRestored => 'Purchases restored.';

  @override
  String get packsIntro =>
      'Every feature of the app is free. Packs add more fonts and presets.';

  @override
  String get owned => 'Owned';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fonts',
      one: '$count font',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presets',
      one: '$count preset',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'The purchase is waiting for approval. It unlocks by itself.';

  @override
  String get purchaseFailed => 'The purchase failed. Please try again.';

  @override
  String get purchasesRestoredUnlocked =>
      'Purchases restored. Everything you bought is unlocked.';

  @override
  String paywallPresets(String names) {
    return 'Presets: $names';
  }

  @override
  String get unlimitedPresets => 'Unlimited presets of your own';

  @override
  String get buyOnce => 'Buy once, keep forever, on your other devices too';

  @override
  String get allFeaturesFree => 'Every feature of the app stays free';

  @override
  String get storeUnavailable =>
      'The store is not available right now. Try again later.';

  @override
  String buyFor(String price) {
    return 'Buy for $price';
  }

  @override
  String get notForSale => 'Not on sale yet';

  @override
  String get loadingPrice => 'Loading price…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: all packs for $price';
  }

  @override
  String get save => 'Save';

  @override
  String get presetSaveTooltip => 'Save the current font and style as a preset';

  @override
  String get presetSaveAsNew => 'Save current as a new preset';

  @override
  String get presetOverwrite => 'Overwrite with current settings';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get presetName => 'Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get deletePresetTitle => 'Delete preset?';

  @override
  String deletePresetBody(String name) {
    return '“$name” will be deleted. The text in the editor stays.';
  }

  @override
  String get joinLetters => 'Join letters';

  @override
  String get letterSpacing => 'Letter Spacing';

  @override
  String get baselineWobble => 'Baseline Wobble';

  @override
  String get sizeVariance => 'Size Variance';

  @override
  String get rotationVariance => 'Rotation Variance';

  @override
  String get opacityVariance => 'Opacity Variance';

  @override
  String get categoryHandwriting => 'Handwriting';

  @override
  String get categoryCalligraphy => 'Calligraphy';

  @override
  String get categoryTypography => 'Typography';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryMaterial => 'Material';

  @override
  String get noEmoji => 'No emoji';

  @override
  String get saveAlignedImage => 'Save Aligned Image';

  @override
  String savedPath(String path) {
    return 'Saved: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Grid Alignment — $file';
  }

  @override
  String get openAnotherImage => 'Open Another Image';

  @override
  String get hideGrid => 'Hide Grid';

  @override
  String get showGrid => 'Show Grid';

  @override
  String get resetGrid => 'Reset Grid';

  @override
  String get exportAlignedImage => 'Export Aligned Image';

  @override
  String get openTemplatePhoto => 'Open a photo of your handwriting template';

  @override
  String get openImage => 'Open Image';

  @override
  String get gridInstructions =>
      'Drag the 4 corners to align the grid on the photo,\nthen export the perspective-corrected image.';
}
