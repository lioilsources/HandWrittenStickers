// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navTextEditor => 'टेक्स्ट एडिटर';

  @override
  String get navGridAlignment => 'ग्रिड संरेखण';

  @override
  String get editorTitle => 'हाथ से लिखा टेक्स्ट';

  @override
  String get packs => 'पैक';

  @override
  String get emojiForMessage => 'संदेश के लिए इमोजी';

  @override
  String get saveToGallery => 'गैलरी में सहेजें';

  @override
  String get share => 'शेयर करें';

  @override
  String get previewEmpty => 'नीचे कुछ लिखें…';

  @override
  String get textHint => 'अपना टेक्स्ट यहाँ लिखें…';

  @override
  String get advancedSettings => 'उन्नत सेटिंग्स';

  @override
  String get savedToGallery => 'गैलरी में सहेजा गया!';

  @override
  String get saveFailed => 'इमेज सहेजी नहीं जा सकी';

  @override
  String get shareFailed => 'शेयर नहीं हो सका';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'प्रीसेट “$preset” का फ़ॉन्ट उपलब्ध नहीं है, $sheet इस्तेमाल किया गया।';
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
  String get newPreset => 'नया प्रीसेट';

  @override
  String get renamePreset => 'प्रीसेट का नाम बदलें';

  @override
  String get restorePurchases => 'खरीदारी बहाल करें';

  @override
  String get purchasesRestored => 'खरीदारी बहाल हो गई।';

  @override
  String get packsIntro =>
      'ऐप की सभी सुविधाएँ मुफ़्त हैं। पैक और फ़ॉन्ट व प्रीसेट जोड़ते हैं।';

  @override
  String get owned => 'आपके पास है';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ॉन्ट',
      one: '$count फ़ॉन्ट',
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
      'खरीदारी मंज़ूरी का इंतज़ार कर रही है। यह अपने आप अनलॉक हो जाएगी।';

  @override
  String get purchaseFailed => 'खरीदारी नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String get purchasesRestoredUnlocked =>
      'खरीदारी बहाल हो गई। आपने जो कुछ खरीदा, वह अनलॉक है।';

  @override
  String paywallPresets(String names) {
    return 'प्रीसेट: $names';
  }

  @override
  String get unlimitedPresets => 'असीमित अपने प्रीसेट';

  @override
  String get buyOnce => 'एक बार खरीदें, हमेशा के लिए आपका, दूसरे डिवाइस पर भी';

  @override
  String get allFeaturesFree => 'ऐप की सभी सुविधाएँ मुफ़्त रहेंगी';

  @override
  String get storeUnavailable =>
      'स्टोर अभी उपलब्ध नहीं है। बाद में कोशिश करें।';

  @override
  String buyFor(String price) {
    return '$price में खरीदें';
  }

  @override
  String get notForSale => 'अभी बिक्री के लिए नहीं';

  @override
  String get loadingPrice => 'कीमत लोड हो रही है…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: सभी पैक $price में';
  }

  @override
  String get save => 'सहेजें';

  @override
  String get presetSaveTooltip =>
      'मौजूदा फ़ॉन्ट और स्टाइल को प्रीसेट के रूप में सहेजें';

  @override
  String get presetSaveAsNew => 'मौजूदा को नए प्रीसेट के रूप में सहेजें';

  @override
  String get presetOverwrite => 'मौजूदा सेटिंग्स से बदलें';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get presetName => 'नाम';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get deletePresetTitle => 'प्रीसेट हटाएँ?';

  @override
  String deletePresetBody(String name) {
    return '“$name” हटा दिया जाएगा। एडिटर का टेक्स्ट बना रहेगा।';
  }

  @override
  String get joinLetters => 'अक्षर जोड़ें';

  @override
  String get letterSpacing => 'अक्षरों की दूरी';

  @override
  String get baselineWobble => 'पंक्ति की लहर';

  @override
  String get sizeVariance => 'आकार में बदलाव';

  @override
  String get rotationVariance => 'झुकाव में बदलाव';

  @override
  String get opacityVariance => 'गहराई में बदलाव';

  @override
  String get categoryHandwriting => 'हस्तलेख';

  @override
  String get categoryCalligraphy => 'सुलेख';

  @override
  String get categoryTypography => 'टाइपोग्राफ़ी';

  @override
  String get categoryKids => 'बच्चों के लिए';

  @override
  String get categoryMaterial => 'सामग्री';

  @override
  String get noEmoji => 'कोई इमोजी नहीं';

  @override
  String get saveAlignedImage => 'संरेखित इमेज सहेजें';

  @override
  String savedPath(String path) {
    return 'सहेजा गया: $path';
  }

  @override
  String errorMessage(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ग्रिड संरेखण — $file';
  }

  @override
  String get openAnotherImage => 'दूसरी इमेज खोलें';

  @override
  String get hideGrid => 'ग्रिड छिपाएँ';

  @override
  String get showGrid => 'ग्रिड दिखाएँ';

  @override
  String get resetGrid => 'ग्रिड रीसेट करें';

  @override
  String get exportAlignedImage => 'संरेखित इमेज एक्सपोर्ट करें';

  @override
  String get openTemplatePhoto => 'अपने भरे हुए टेम्पलेट की फ़ोटो खोलें';

  @override
  String get openImage => 'इमेज खोलें';

  @override
  String get gridInstructions =>
      'चारों कोनों को खींचकर ग्रिड को फ़ोटो पर बैठाएँ,\nफिर ठीक किए गए परिप्रेक्ष्य वाली इमेज एक्सपोर्ट करें।';
}
