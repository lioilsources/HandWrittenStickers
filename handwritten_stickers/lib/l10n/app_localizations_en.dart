// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navEditor => 'Text Editor';

  @override
  String get navGrid => 'Grid Alignment';

  @override
  String get editorTitle => 'Handwritten Text';

  @override
  String get packs => 'Packs';

  @override
  String get aboutAndLicences => 'About and licences';

  @override
  String get emojiTag => 'Emoji tag';

  @override
  String get emojiRecent => 'Recent';

  @override
  String get noEmoji => 'No emoji';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get share => 'Share';

  @override
  String get savedToGallery => 'Saved to gallery!';

  @override
  String get saveFailed => 'Failed to save image';

  @override
  String get shareFailed => 'Sharing failed';

  @override
  String get emptyCanvasHint => 'Type something below...';

  @override
  String get textHint => 'Type your text here...';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get presetDefaultName => 'Preset';

  @override
  String get newPreset => 'New preset';

  @override
  String get renamePreset => 'Rename preset';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'The font of preset “$preset” is not available, using $sheet.';
  }

  @override
  String get save => 'Save';

  @override
  String get savePresetTooltip => 'Save the current font and style as a preset';

  @override
  String get saveAsNewPreset => 'Save current as a new preset';

  @override
  String get overwritePreset => 'Overwrite with the current settings';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get nameLabel => 'Name';

  @override
  String get deletePresetTitle => 'Delete preset?';

  @override
  String deletePresetBody(String name) {
    return '“$name” will be deleted. The text in the editor stays.';
  }

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchasesRestored => 'Purchases restored.';

  @override
  String get purchasesRestoredUnlocked =>
      'Purchases restored. What you bought is unlocked.';

  @override
  String get owned => 'Owned';

  @override
  String get packsIntro =>
      'Every feature of the app is free. Packs add more fonts and presets.';

  @override
  String get purchasePending =>
      'The purchase is waiting for approval. It will unlock by itself.';

  @override
  String get purchaseFailed => 'The purchase failed. Please try again.';

  @override
  String get storeUnavailable =>
      'The store is not available right now. Try again later.';

  @override
  String buyFor(String price) {
    return 'Buy for $price';
  }

  @override
  String get notForSaleYet => 'Not for sale yet';

  @override
  String allPacksFor(String name, String price) {
    return '$name: all packs for $price';
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
  String gridSaved(String path) {
    return 'Saved: $path';
  }

  @override
  String gridError(String error) {
    return 'Error: $error';
  }

  @override
  String get gridSaveDialogTitle => 'Save Aligned Image';

  @override
  String get gridOpenAnother => 'Open Another Image';

  @override
  String get gridHide => 'Hide Grid';

  @override
  String get gridShow => 'Show Grid';

  @override
  String get gridReset => 'Reset Grid';

  @override
  String get gridExport => 'Export Aligned Image';

  @override
  String get gridOpenImage => 'Open Image';

  @override
  String get gridOpenHint => 'Open a photo of your handwriting template';

  @override
  String get gridDragHint =>
      'Drag the 4 corners to align the grid on the photo,\nthen export the perspective-corrected image.';

  @override
  String sheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fonts',
      one: '1 font',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presets',
      one: '1 preset',
    );
    return '$_temp0';
  }

  @override
  String emojiCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count emoji',
      one: '1 emoji',
    );
    return '$_temp0';
  }

  @override
  String presetsList(String names) {
    return 'Presets: $names';
  }

  @override
  String get unlimitedPresets => 'Unlimited presets of your own';

  @override
  String get buyOnceKeepForever =>
      'Buy once, keep forever, on your other devices too';

  @override
  String get featuresStayFree => 'Every feature of the app stays free';

  @override
  String get loadingPrice => 'Loading price…';
}
