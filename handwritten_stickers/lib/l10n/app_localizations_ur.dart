// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get navTextEditor => 'ٹیکسٹ ایڈیٹر';

  @override
  String get navGridAlignment => 'گرڈ کی سیدھ';

  @override
  String get editorTitle => 'ہاتھ سے لکھا متن';

  @override
  String get packs => 'پیکس';

  @override
  String get emojiForMessage => 'پیغام کے لیے ایموجی';

  @override
  String get saveToGallery => 'گیلری میں محفوظ کریں';

  @override
  String get share => 'شیئر کریں';

  @override
  String get previewEmpty => 'نیچے کچھ لکھیں…';

  @override
  String get textHint => 'اپنا متن یہاں لکھیں…';

  @override
  String get advancedSettings => 'اعلیٰ ترتیبات';

  @override
  String get savedToGallery => 'گیلری میں محفوظ ہو گیا!';

  @override
  String get saveFailed => 'تصویر محفوظ نہیں ہو سکی';

  @override
  String get shareFailed => 'شیئر نہیں ہو سکا';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'پری سیٹ “$preset” کا فونٹ دستیاب نہیں، $sheet استعمال کیا گیا۔';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'پری سیٹ';

  @override
  String get newPreset => 'نیا پری سیٹ';

  @override
  String get renamePreset => 'پری سیٹ کا نام بدلیں';

  @override
  String get restorePurchases => 'خریداریاں بحال کریں';

  @override
  String get purchasesRestored => 'خریداریاں بحال ہو گئیں۔';

  @override
  String get packsIntro =>
      'ایپ کی تمام خصوصیات مفت ہیں۔ پیکس مزید فونٹس اور پری سیٹس شامل کرتے ہیں۔';

  @override
  String get owned => 'خریدا ہوا';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فونٹس',
      one: '$count فونٹ',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پری سیٹس',
      one: '$count پری سیٹ',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'خریداری منظوری کی منتظر ہے۔ یہ خود کھل جائے گی۔';

  @override
  String get purchaseFailed =>
      'خریداری ناکام ہو گئی۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get purchasesRestoredUnlocked =>
      'خریداریاں بحال ہو گئیں۔ آپ نے جو کچھ خریدا وہ کھل گیا ہے۔';

  @override
  String paywallPresets(String names) {
    return 'پری سیٹس: $names';
  }

  @override
  String get unlimitedPresets => 'لامحدود اپنے پری سیٹس';

  @override
  String get buyOnce => 'ایک بار خریدیں، ہمیشہ کے لیے آپ کا، دوسرے آلات پر بھی';

  @override
  String get allFeaturesFree => 'ایپ کی تمام خصوصیات مفت رہتی ہیں';

  @override
  String get storeUnavailable => 'اسٹور ابھی دستیاب نہیں۔ بعد میں کوشش کریں۔';

  @override
  String buyFor(String price) {
    return '$price میں خریدیں';
  }

  @override
  String get notForSale => 'ابھی فروخت کے لیے نہیں';

  @override
  String get loadingPrice => 'قیمت لوڈ ہو رہی ہے…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: تمام پیکس $price میں';
  }

  @override
  String get save => 'محفوظ کریں';

  @override
  String get presetSaveTooltip =>
      'موجودہ فونٹ اور انداز کو پری سیٹ کے طور پر محفوظ کریں';

  @override
  String get presetSaveAsNew => 'موجودہ کو نئے پری سیٹ کے طور پر محفوظ کریں';

  @override
  String get presetOverwrite => 'موجودہ ترتیبات سے بدل دیں';

  @override
  String get rename => 'نام بدلیں';

  @override
  String get delete => 'حذف کریں';

  @override
  String get presetName => 'نام';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get deletePresetTitle => 'پری سیٹ حذف کریں؟';

  @override
  String deletePresetBody(String name) {
    return '“$name” حذف ہو جائے گا۔ ایڈیٹر میں متن باقی رہے گا۔';
  }

  @override
  String get joinLetters => 'حروف جوڑیں';

  @override
  String get letterSpacing => 'حروف کا فاصلہ';

  @override
  String get baselineWobble => 'سطر کی لہر';

  @override
  String get sizeVariance => 'سائز میں فرق';

  @override
  String get rotationVariance => 'جھکاؤ میں فرق';

  @override
  String get opacityVariance => 'گہرائی میں فرق';

  @override
  String get categoryHandwriting => 'ہینڈ رائٹنگ';

  @override
  String get categoryCalligraphy => 'خطاطی';

  @override
  String get categoryTypography => 'ٹائپوگرافی';

  @override
  String get categoryKids => 'بچوں کے لیے';

  @override
  String get categoryMaterial => 'مواد';

  @override
  String get noEmoji => 'کوئی ایموجی نہیں';

  @override
  String get saveAlignedImage => 'سیدھی کی گئی تصویر محفوظ کریں';

  @override
  String savedPath(String path) {
    return 'محفوظ ہو گیا: $path';
  }

  @override
  String errorMessage(String error) {
    return 'خرابی: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'گرڈ کی سیدھ — $file';
  }

  @override
  String get openAnotherImage => 'دوسری تصویر کھولیں';

  @override
  String get hideGrid => 'گرڈ چھپائیں';

  @override
  String get showGrid => 'گرڈ دکھائیں';

  @override
  String get resetGrid => 'گرڈ ری سیٹ کریں';

  @override
  String get exportAlignedImage => 'سیدھی کی گئی تصویر ایکسپورٹ کریں';

  @override
  String get openTemplatePhoto => 'اپنے بھرے ہوئے ٹیمپلیٹ کی تصویر کھولیں';

  @override
  String get openImage => 'تصویر کھولیں';

  @override
  String get gridInstructions =>
      'چاروں کونے گھسیٹیں تاکہ گرڈ تصویر پر بیٹھ جائے،\nپھر درست زاویے والی تصویر ایکسپورٹ کریں۔';
}
