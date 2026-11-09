// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get navTextEditor => 'టెక్స్ట్ ఎడిటర్';

  @override
  String get navGridAlignment => 'గ్రిడ్ అమరిక';

  @override
  String get editorTitle => 'చేతిరాత టెక్స్ట్';

  @override
  String get packs => 'ప్యాక్‌లు';

  @override
  String get emojiForMessage => 'సందేశానికి ఎమోజీ';

  @override
  String get saveToGallery => 'గ్యాలరీలో సేవ్ చేయండి';

  @override
  String get share => 'షేర్ చేయండి';

  @override
  String get previewEmpty => 'కింద ఏదైనా రాయండి…';

  @override
  String get textHint => 'మీ టెక్స్ట్‌ను ఇక్కడ రాయండి…';

  @override
  String get advancedSettings => 'అధునాతన సెట్టింగ్‌లు';

  @override
  String get savedToGallery => 'గ్యాలరీలో సేవ్ అయింది!';

  @override
  String get saveFailed => 'చిత్రాన్ని సేవ్ చేయలేకపోయాం';

  @override
  String get shareFailed => 'షేర్ చేయలేకపోయాం';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'ప్రీసెట్ “$preset” ఫాంట్ అందుబాటులో లేదు, $sheet ఉపయోగించాం.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'ప్రీసెట్';

  @override
  String get newPreset => 'కొత్త ప్రీసెట్';

  @override
  String get renamePreset => 'ప్రీసెట్ పేరు మార్చండి';

  @override
  String get restorePurchases => 'కొనుగోళ్లను పునరుద్ధరించండి';

  @override
  String get purchasesRestored => 'కొనుగోళ్లు పునరుద్ధరించబడ్డాయి.';

  @override
  String get packsIntro =>
      'యాప్‌లోని అన్ని ఫీచర్లు ఉచితం. ప్యాక్‌లు మరిన్ని ఫాంట్‌లు, ప్రీసెట్‌లను జోడిస్తాయి.';

  @override
  String get owned => 'మీ దగ్గర ఉంది';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫాంట్‌లు',
      one: '$count ఫాంట్',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రీసెట్‌లు',
      one: '$count ప్రీసెట్',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'కొనుగోలు ఆమోదం కోసం వేచి ఉంది. అది దానంతట అదే అన్‌లాక్ అవుతుంది.';

  @override
  String get purchaseFailed =>
      'కొనుగోలు విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get purchasesRestoredUnlocked =>
      'కొనుగోళ్లు పునరుద్ధరించబడ్డాయి. మీరు కొన్నవన్నీ అన్‌లాక్ అయ్యాయి.';

  @override
  String paywallPresets(String names) {
    return 'ప్రీసెట్‌లు: $names';
  }

  @override
  String get unlimitedPresets => 'అపరిమిత సొంత ప్రీసెట్‌లు';

  @override
  String get buyOnce => 'ఒక్కసారి కొనండి, ఎప్పటికీ మీదే, ఇతర పరికరాల్లోనూ';

  @override
  String get allFeaturesFree => 'యాప్‌లోని అన్ని ఫీచర్లు ఉచితంగానే ఉంటాయి';

  @override
  String get storeUnavailable =>
      'స్టోర్ ఇప్పుడు అందుబాటులో లేదు. తర్వాత ప్రయత్నించండి.';

  @override
  String buyFor(String price) {
    return '$priceకి కొనండి';
  }

  @override
  String get notForSale => 'ఇంకా అమ్మకానికి లేదు';

  @override
  String get loadingPrice => 'ధర లోడ్ అవుతోంది…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: అన్ని ప్యాక్‌లు $priceకి';
  }

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get presetSaveTooltip =>
      'ప్రస్తుత ఫాంట్, శైలిని ప్రీసెట్‌గా సేవ్ చేయండి';

  @override
  String get presetSaveAsNew => 'ప్రస్తుతాన్ని కొత్త ప్రీసెట్‌గా సేవ్ చేయండి';

  @override
  String get presetOverwrite => 'ప్రస్తుత సెట్టింగ్‌లతో మార్చండి';

  @override
  String get rename => 'పేరు మార్చండి';

  @override
  String get delete => 'తొలగించండి';

  @override
  String get presetName => 'పేరు';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get deletePresetTitle => 'ప్రీసెట్‌ను తొలగించాలా?';

  @override
  String deletePresetBody(String name) {
    return '“$name” తొలగించబడుతుంది. ఎడిటర్‌లోని టెక్స్ట్ అలాగే ఉంటుంది.';
  }

  @override
  String get joinLetters => 'అక్షరాలను కలపండి';

  @override
  String get letterSpacing => 'అక్షరాల మధ్య దూరం';

  @override
  String get baselineWobble => 'పంక్తి అల';

  @override
  String get sizeVariance => 'పరిమాణ వ్యత్యాసం';

  @override
  String get rotationVariance => 'వాలు వ్యత్యాసం';

  @override
  String get opacityVariance => 'గాఢత వ్యత్యాసం';

  @override
  String get categoryHandwriting => 'చేతిరాత';

  @override
  String get categoryCalligraphy => 'కాలిగ్రఫీ';

  @override
  String get categoryTypography => 'టైపోగ్రఫీ';

  @override
  String get categoryKids => 'పిల్లల కోసం';

  @override
  String get categoryMaterial => 'పదార్థాలు';

  @override
  String get noEmoji => 'ఎమోజీ లేదు';

  @override
  String get saveAlignedImage => 'అమర్చిన చిత్రాన్ని సేవ్ చేయండి';

  @override
  String savedPath(String path) {
    return 'సేవ్ అయింది: $path';
  }

  @override
  String errorMessage(String error) {
    return 'లోపం: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'గ్రిడ్ అమరిక — $file';
  }

  @override
  String get openAnotherImage => 'మరో చిత్రాన్ని తెరవండి';

  @override
  String get hideGrid => 'గ్రిడ్ దాచండి';

  @override
  String get showGrid => 'గ్రిడ్ చూపండి';

  @override
  String get resetGrid => 'గ్రిడ్ రీసెట్ చేయండి';

  @override
  String get exportAlignedImage => 'అమర్చిన చిత్రాన్ని ఎగుమతి చేయండి';

  @override
  String get openTemplatePhoto => 'మీరు నింపిన టెంప్లేట్ ఫోటోను తెరవండి';

  @override
  String get openImage => 'చిత్రాన్ని తెరవండి';

  @override
  String get gridInstructions =>
      'నాలుగు మూలలను లాగి గ్రిడ్‌ను ఫోటోకు సరిపెట్టండి,\nఆపై దృక్కోణం సరిచేసిన చిత్రాన్ని ఎగుమతి చేయండి.';
}
