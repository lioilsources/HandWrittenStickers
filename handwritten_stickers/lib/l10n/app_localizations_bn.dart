// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get navTextEditor => 'টেক্সট এডিটর';

  @override
  String get navGridAlignment => 'গ্রিড সারিবদ্ধকরণ';

  @override
  String get editorTitle => 'হাতে লেখা টেক্সট';

  @override
  String get packs => 'প্যাক';

  @override
  String get emojiForMessage => 'বার্তার জন্য ইমোজি';

  @override
  String get saveToGallery => 'গ্যালারিতে সংরক্ষণ করুন';

  @override
  String get share => 'শেয়ার করুন';

  @override
  String get previewEmpty => 'নিচে কিছু লিখুন…';

  @override
  String get textHint => 'আপনার টেক্সট এখানে লিখুন…';

  @override
  String get advancedSettings => 'উন্নত সেটিংস';

  @override
  String get savedToGallery => 'গ্যালারিতে সংরক্ষিত হয়েছে!';

  @override
  String get saveFailed => 'ছবি সংরক্ষণ করা যায়নি';

  @override
  String get shareFailed => 'শেয়ার করা যায়নি';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'প্রিসেট “$preset”-এর ফন্ট পাওয়া যাচ্ছে না, $sheet ব্যবহার করা হয়েছে।';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'প্রিসেট';

  @override
  String get newPreset => 'নতুন প্রিসেট';

  @override
  String get renamePreset => 'প্রিসেটের নাম বদলান';

  @override
  String get restorePurchases => 'কেনাকাটা পুনরুদ্ধার করুন';

  @override
  String get purchasesRestored => 'কেনাকাটা পুনরুদ্ধার হয়েছে।';

  @override
  String get packsIntro =>
      'অ্যাপের সব ফিচার বিনামূল্যে। প্যাক আরও ফন্ট ও প্রিসেট যোগ করে।';

  @override
  String get owned => 'কেনা আছে';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ফন্ট',
      one: '$countটি ফন্ট',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রিসেট',
      one: '$countটি প্রিসেট',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'কেনাকাটা অনুমোদনের অপেক্ষায়। এটি নিজে থেকেই আনলক হবে।';

  @override
  String get purchaseFailed => 'কেনাকাটা হয়নি। আবার চেষ্টা করুন।';

  @override
  String get purchasesRestoredUnlocked =>
      'কেনাকাটা পুনরুদ্ধার হয়েছে। আপনি যা কিনেছেন সব আনলক।';

  @override
  String paywallPresets(String names) {
    return 'প্রিসেট: $names';
  }

  @override
  String get unlimitedPresets => 'সীমাহীন নিজস্ব প্রিসেট';

  @override
  String get buyOnce => 'একবার কিনুন, চিরকাল আপনার, অন্য ডিভাইসেও';

  @override
  String get allFeaturesFree => 'অ্যাপের সব ফিচার বিনামূল্যেই থাকবে';

  @override
  String get storeUnavailable => 'স্টোর এখন পাওয়া যাচ্ছে না। পরে চেষ্টা করুন।';

  @override
  String buyFor(String price) {
    return '$price-এ কিনুন';
  }

  @override
  String get notForSale => 'এখনও বিক্রি হচ্ছে না';

  @override
  String get loadingPrice => 'দাম লোড হচ্ছে…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: সব প্যাক $price-এ';
  }

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get presetSaveTooltip =>
      'বর্তমান ফন্ট ও স্টাইল প্রিসেট হিসেবে সংরক্ষণ করুন';

  @override
  String get presetSaveAsNew => 'বর্তমানটি নতুন প্রিসেট হিসেবে সংরক্ষণ করুন';

  @override
  String get presetOverwrite => 'বর্তমান সেটিংস দিয়ে ওভাররাইট করুন';

  @override
  String get rename => 'নাম বদলান';

  @override
  String get delete => 'মুছুন';

  @override
  String get presetName => 'নাম';

  @override
  String get cancel => 'বাতিল';

  @override
  String get deletePresetTitle => 'প্রিসেট মুছবেন?';

  @override
  String deletePresetBody(String name) {
    return '“$name” মুছে যাবে। এডিটরের টেক্সট থেকে যাবে।';
  }

  @override
  String get joinLetters => 'অক্ষর জুড়ুন';

  @override
  String get letterSpacing => 'অক্ষরের ব্যবধান';

  @override
  String get baselineWobble => 'লাইনের ঢেউ';

  @override
  String get sizeVariance => 'আকারের তারতম্য';

  @override
  String get rotationVariance => 'হেলানোর তারতম্য';

  @override
  String get opacityVariance => 'গাঢ়ত্বের তারতম্য';

  @override
  String get categoryHandwriting => 'হাতের লেখা';

  @override
  String get categoryCalligraphy => 'ক্যালিগ্রাফি';

  @override
  String get categoryTypography => 'টাইপোগ্রাফি';

  @override
  String get categoryKids => 'শিশুদের';

  @override
  String get categoryMaterial => 'উপকরণ';

  @override
  String get noEmoji => 'ইমোজি ছাড়া';

  @override
  String get saveAlignedImage => 'সারিবদ্ধ ছবি সংরক্ষণ করুন';

  @override
  String savedPath(String path) {
    return 'সংরক্ষিত: $path';
  }

  @override
  String errorMessage(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'গ্রিড সারিবদ্ধকরণ — $file';
  }

  @override
  String get openAnotherImage => 'অন্য ছবি খুলুন';

  @override
  String get hideGrid => 'গ্রিড লুকান';

  @override
  String get showGrid => 'গ্রিড দেখান';

  @override
  String get resetGrid => 'গ্রিড রিসেট করুন';

  @override
  String get exportAlignedImage => 'সারিবদ্ধ ছবি এক্সপোর্ট করুন';

  @override
  String get openTemplatePhoto => 'আপনার পূরণ করা টেমপ্লেটের ছবি খুলুন';

  @override
  String get openImage => 'ছবি খুলুন';

  @override
  String get gridInstructions =>
      'চারটি কোণ টেনে গ্রিড ছবির সাথে মেলান,\nতারপর পরিপ্রেক্ষিত ঠিক করা ছবি এক্সপোর্ট করুন।';
}
