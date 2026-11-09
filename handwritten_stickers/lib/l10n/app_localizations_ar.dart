// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navTextEditor => 'محرر النص';

  @override
  String get navGridAlignment => 'محاذاة الشبكة';

  @override
  String get editorTitle => 'نص بخط اليد';

  @override
  String get packs => 'الحزم';

  @override
  String get emojiForMessage => 'إيموجي للرسالة';

  @override
  String get saveToGallery => 'حفظ في المعرض';

  @override
  String get share => 'مشاركة';

  @override
  String get previewEmpty => 'اكتب شيئًا في الأسفل…';

  @override
  String get textHint => 'اكتب نصك هنا…';

  @override
  String get advancedSettings => 'إعدادات متقدمة';

  @override
  String get savedToGallery => 'تم الحفظ في المعرض!';

  @override
  String get saveFailed => 'تعذّر حفظ الصورة';

  @override
  String get shareFailed => 'تعذّرت المشاركة';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'خط الإعداد المسبق «$preset» غير متاح، تم استخدام $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'إعداد مسبق';

  @override
  String get newPreset => 'إعداد مسبق جديد';

  @override
  String get renamePreset => 'إعادة تسمية الإعداد المسبق';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get purchasesRestored => 'تمت استعادة المشتريات.';

  @override
  String get packsIntro =>
      'كل ميزات التطبيق مجانية. تضيف الحزم مزيدًا من الخطوط والإعدادات المسبقة.';

  @override
  String get owned => 'تم الشراء';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خط',
      many: '$count خطًا',
      few: '$count خطوط',
      two: 'خطّان',
      one: 'خط واحد',
      zero: 'لا خطوط',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعداد مسبق',
      many: '$count إعدادًا مسبقًا',
      few: '$count إعدادات مسبقة',
      two: 'إعدادان مسبقان',
      one: 'إعداد مسبق واحد',
      zero: 'لا إعدادات مسبقة',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'عملية الشراء بانتظار الموافقة. سيُفتح المحتوى تلقائيًا.';

  @override
  String get purchaseFailed => 'فشلت عملية الشراء. حاول مرة أخرى.';

  @override
  String get purchasesRestoredUnlocked =>
      'تمت استعادة المشتريات. كل ما اشتريته أصبح مفتوحًا.';

  @override
  String paywallPresets(String names) {
    return 'الإعدادات المسبقة: $names';
  }

  @override
  String get unlimitedPresets => 'إعدادات مسبقة خاصة بك بلا حدود';

  @override
  String get buyOnce =>
      'اشترِ مرة واحدة واحتفظ به للأبد، وعلى أجهزتك الأخرى أيضًا';

  @override
  String get allFeaturesFree => 'تبقى كل ميزات التطبيق مجانية';

  @override
  String get storeUnavailable => 'المتجر غير متاح الآن. حاول لاحقًا.';

  @override
  String buyFor(String price) {
    return 'شراء مقابل $price';
  }

  @override
  String get notForSale => 'غير معروض للبيع بعد';

  @override
  String get loadingPrice => 'جارٍ تحميل السعر…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: كل الحزم مقابل $price';
  }

  @override
  String get save => 'حفظ';

  @override
  String get presetSaveTooltip => 'حفظ الخط والنمط الحاليين كإعداد مسبق';

  @override
  String get presetSaveAsNew => 'حفظ الحالي كإعداد مسبق جديد';

  @override
  String get presetOverwrite => 'استبدال بالإعدادات الحالية';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get delete => 'حذف';

  @override
  String get presetName => 'الاسم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deletePresetTitle => 'حذف الإعداد المسبق؟';

  @override
  String deletePresetBody(String name) {
    return 'سيُحذف «$name». يبقى النص في المحرر.';
  }

  @override
  String get joinLetters => 'وصل الحروف';

  @override
  String get letterSpacing => 'تباعد الحروف';

  @override
  String get baselineWobble => 'تموّج السطر';

  @override
  String get sizeVariance => 'تفاوت الحجم';

  @override
  String get rotationVariance => 'تفاوت الميل';

  @override
  String get opacityVariance => 'تفاوت الكثافة';

  @override
  String get categoryHandwriting => 'خط اليد';

  @override
  String get categoryCalligraphy => 'الخط الفني';

  @override
  String get categoryTypography => 'الطباعة';

  @override
  String get categoryKids => 'للأطفال';

  @override
  String get categoryMaterial => 'خامات';

  @override
  String get noEmoji => 'بدون إيموجي';

  @override
  String get saveAlignedImage => 'حفظ الصورة المحاذاة';

  @override
  String savedPath(String path) {
    return 'تم الحفظ: $path';
  }

  @override
  String errorMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'محاذاة الشبكة — $file';
  }

  @override
  String get openAnotherImage => 'فتح صورة أخرى';

  @override
  String get hideGrid => 'إخفاء الشبكة';

  @override
  String get showGrid => 'إظهار الشبكة';

  @override
  String get resetGrid => 'إعادة ضبط الشبكة';

  @override
  String get exportAlignedImage => 'تصدير الصورة المحاذاة';

  @override
  String get openTemplatePhoto => 'افتح صورة القالب الذي ملأته بخط يدك';

  @override
  String get openImage => 'فتح صورة';

  @override
  String get gridInstructions =>
      'اسحب الزوايا الأربع لتنطبق الشبكة على الصورة،\nثم صدّر الصورة بعد تصحيح المنظور.';
}
