// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get navTextEditor => 'मजकूर संपादक';

  @override
  String get navGridAlignment => 'ग्रिड संरेखन';

  @override
  String get editorTitle => 'हस्तलिखित मजकूर';

  @override
  String get packs => 'पॅक';

  @override
  String get emojiForMessage => 'संदेशासाठी इमोजी';

  @override
  String get saveToGallery => 'गॅलरीत जतन करा';

  @override
  String get share => 'शेअर करा';

  @override
  String get previewEmpty => 'खाली काहीतरी लिहा…';

  @override
  String get textHint => 'तुमचा मजकूर इथे लिहा…';

  @override
  String get advancedSettings => 'प्रगत सेटिंग्ज';

  @override
  String get savedToGallery => 'गॅलरीत जतन झाले!';

  @override
  String get saveFailed => 'प्रतिमा जतन करता आली नाही';

  @override
  String get shareFailed => 'शेअर करता आले नाही';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'प्रीसेट “$preset” चा फॉन्ट उपलब्ध नाही, $sheet वापरला.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'प्रीसेट';

  @override
  String get newPreset => 'नवीन प्रीसेट';

  @override
  String get renamePreset => 'प्रीसेटचे नाव बदला';

  @override
  String get restorePurchases => 'खरेदी पुनर्संचयित करा';

  @override
  String get purchasesRestored => 'खरेदी पुनर्संचयित झाली.';

  @override
  String get packsIntro =>
      'अ‍ॅपची सर्व वैशिष्ट्ये मोफत आहेत. पॅक आणखी फॉन्ट आणि प्रीसेट जोडतात.';

  @override
  String get owned => 'तुमच्याकडे आहे';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फॉन्ट',
      one: '$count फॉन्ट',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रीसेट',
      one: '$count प्रीसेट',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'खरेदी मंजुरीच्या प्रतीक्षेत आहे. ती आपोआप अनलॉक होईल.';

  @override
  String get purchaseFailed => 'खरेदी झाली नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get purchasesRestoredUnlocked =>
      'खरेदी पुनर्संचयित झाली. तुम्ही जे खरेदी केले ते सर्व अनलॉक आहे.';

  @override
  String paywallPresets(String names) {
    return 'प्रीसेट: $names';
  }

  @override
  String get unlimitedPresets => 'अमर्याद स्वतःचे प्रीसेट';

  @override
  String get buyOnce => 'एकदा खरेदी करा, कायमचे तुमचे, इतर डिव्हाइसवरही';

  @override
  String get allFeaturesFree => 'अ‍ॅपची सर्व वैशिष्ट्ये मोफतच राहतील';

  @override
  String get storeUnavailable => 'स्टोअर सध्या उपलब्ध नाही. नंतर प्रयत्न करा.';

  @override
  String buyFor(String price) {
    return '$price ला खरेदी करा';
  }

  @override
  String get notForSale => 'अद्याप विक्रीसाठी नाही';

  @override
  String get loadingPrice => 'किंमत लोड होत आहे…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: सर्व पॅक $price ला';
  }

  @override
  String get save => 'जतन करा';

  @override
  String get presetSaveTooltip =>
      'सध्याचा फॉन्ट आणि शैली प्रीसेट म्हणून जतन करा';

  @override
  String get presetSaveAsNew => 'सध्याचे नवीन प्रीसेट म्हणून जतन करा';

  @override
  String get presetOverwrite => 'सध्याच्या सेटिंग्जने बदला';

  @override
  String get rename => 'नाव बदला';

  @override
  String get delete => 'हटवा';

  @override
  String get presetName => 'नाव';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get deletePresetTitle => 'प्रीसेट हटवायचा?';

  @override
  String deletePresetBody(String name) {
    return '“$name” हटवला जाईल. संपादकातील मजकूर राहील.';
  }

  @override
  String get joinLetters => 'अक्षरे जोडा';

  @override
  String get letterSpacing => 'अक्षरांमधील अंतर';

  @override
  String get baselineWobble => 'ओळीची लहर';

  @override
  String get sizeVariance => 'आकारातील फरक';

  @override
  String get rotationVariance => 'तिरकेपणातील फरक';

  @override
  String get opacityVariance => 'गडदपणातील फरक';

  @override
  String get categoryHandwriting => 'हस्ताक्षर';

  @override
  String get categoryCalligraphy => 'सुलेखन';

  @override
  String get categoryTypography => 'टायपोग्राफी';

  @override
  String get categoryKids => 'मुलांसाठी';

  @override
  String get categoryMaterial => 'साहित्य';

  @override
  String get noEmoji => 'इमोजी नाही';

  @override
  String get saveAlignedImage => 'संरेखित प्रतिमा जतन करा';

  @override
  String savedPath(String path) {
    return 'जतन केले: $path';
  }

  @override
  String errorMessage(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ग्रिड संरेखन — $file';
  }

  @override
  String get openAnotherImage => 'दुसरी प्रतिमा उघडा';

  @override
  String get hideGrid => 'ग्रिड लपवा';

  @override
  String get showGrid => 'ग्रिड दाखवा';

  @override
  String get resetGrid => 'ग्रिड रीसेट करा';

  @override
  String get exportAlignedImage => 'संरेखित प्रतिमा निर्यात करा';

  @override
  String get openTemplatePhoto => 'तुम्ही भरलेल्या टेम्पलेटचा फोटो उघडा';

  @override
  String get openImage => 'प्रतिमा उघडा';

  @override
  String get gridInstructions =>
      'चारही कोपरे ओढून ग्रिड फोटोवर बसवा,\nमग दृष्टिकोन दुरुस्त केलेली प्रतिमा निर्यात करा.';
}
