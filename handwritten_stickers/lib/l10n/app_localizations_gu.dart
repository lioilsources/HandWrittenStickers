// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get navTextEditor => 'ટેક્સ્ટ એડિટર';

  @override
  String get navGridAlignment => 'ગ્રીડ ગોઠવણી';

  @override
  String get editorTitle => 'હસ્તલિખિત ટેક્સ્ટ';

  @override
  String get packs => 'પૅક';

  @override
  String get emojiForMessage => 'સંદેશ માટે ઇમોજી';

  @override
  String get saveToGallery => 'ગૅલેરીમાં સાચવો';

  @override
  String get share => 'શેર કરો';

  @override
  String get previewEmpty => 'નીચે કંઈક લખો…';

  @override
  String get textHint => 'તમારો ટેક્સ્ટ અહીં લખો…';

  @override
  String get advancedSettings => 'અદ્યતન સેટિંગ્સ';

  @override
  String get savedToGallery => 'ગૅલેરીમાં સાચવ્યું!';

  @override
  String get saveFailed => 'છબી સાચવી શકાઈ નહીં';

  @override
  String get shareFailed => 'શેર કરી શકાયું નહીં';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'પ્રીસેટ “$preset”નો ફૉન્ટ ઉપલબ્ધ નથી, $sheet વાપર્યો.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'પ્રીસેટ';

  @override
  String get newPreset => 'નવો પ્રીસેટ';

  @override
  String get renamePreset => 'પ્રીસેટનું નામ બદલો';

  @override
  String get restorePurchases => 'ખરીદી પુનઃસ્થાપિત કરો';

  @override
  String get purchasesRestored => 'ખરીદી પુનઃસ્થાપિત થઈ.';

  @override
  String get packsIntro =>
      'ઍપની બધી સુવિધાઓ મફત છે. પૅક વધુ ફૉન્ટ અને પ્રીસેટ ઉમેરે છે.';

  @override
  String get owned => 'તમારી પાસે છે';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફૉન્ટ',
      one: '$count ફૉન્ટ',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પ્રીસેટ',
      one: '$count પ્રીસેટ',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'ખરીદી મંજૂરીની રાહ જુએ છે. તે આપમેળે અનલૉક થશે.';

  @override
  String get purchaseFailed => 'ખરીદી થઈ શકી નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get purchasesRestoredUnlocked =>
      'ખરીદી પુનઃસ્થાપિત થઈ. તમે જે ખરીદ્યું તે બધું અનલૉક છે.';

  @override
  String paywallPresets(String names) {
    return 'પ્રીસેટ: $names';
  }

  @override
  String get unlimitedPresets => 'અમર્યાદિત પોતાના પ્રીસેટ';

  @override
  String get buyOnce => 'એકવાર ખરીદો, હંમેશ માટે તમારું, બીજાં ઉપકરણો પર પણ';

  @override
  String get allFeaturesFree => 'ઍપની બધી સુવિધાઓ મફત રહે છે';

  @override
  String get storeUnavailable => 'સ્ટોર અત્યારે ઉપલબ્ધ નથી. પછીથી પ્રયાસ કરો.';

  @override
  String buyFor(String price) {
    return '$priceમાં ખરીદો';
  }

  @override
  String get notForSale => 'હજી વેચાણમાં નથી';

  @override
  String get loadingPrice => 'કિંમત લોડ થઈ રહી છે…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: બધા પૅક $priceમાં';
  }

  @override
  String get save => 'સાચવો';

  @override
  String get presetSaveTooltip =>
      'વર્તમાન ફૉન્ટ અને શૈલીને પ્રીસેટ તરીકે સાચવો';

  @override
  String get presetSaveAsNew => 'વર્તમાનને નવા પ્રીસેટ તરીકે સાચવો';

  @override
  String get presetOverwrite => 'વર્તમાન સેટિંગ્સથી બદલો';

  @override
  String get rename => 'નામ બદલો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get presetName => 'નામ';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get deletePresetTitle => 'પ્રીસેટ કાઢી નાખીએ?';

  @override
  String deletePresetBody(String name) {
    return '“$name” કાઢી નખાશે. એડિટરનો ટેક્સ્ટ રહેશે.';
  }

  @override
  String get joinLetters => 'અક્ષરો જોડો';

  @override
  String get letterSpacing => 'અક્ષરો વચ્ચે અંતર';

  @override
  String get baselineWobble => 'લીટીની લહેર';

  @override
  String get sizeVariance => 'કદમાં ફેરફાર';

  @override
  String get rotationVariance => 'ઝુકાવમાં ફેરફાર';

  @override
  String get opacityVariance => 'ઘેરાશમાં ફેરફાર';

  @override
  String get categoryHandwriting => 'હસ્તાક્ષર';

  @override
  String get categoryCalligraphy => 'સુલેખન';

  @override
  String get categoryTypography => 'ટાઇપોગ્રાફી';

  @override
  String get categoryKids => 'બાળકો માટે';

  @override
  String get categoryMaterial => 'સામગ્રી';

  @override
  String get noEmoji => 'ઇમોજી વિના';

  @override
  String get saveAlignedImage => 'ગોઠવેલી છબી સાચવો';

  @override
  String savedPath(String path) {
    return 'સાચવ્યું: $path';
  }

  @override
  String errorMessage(String error) {
    return 'ભૂલ: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ગ્રીડ ગોઠવણી — $file';
  }

  @override
  String get openAnotherImage => 'બીજી છબી ખોલો';

  @override
  String get hideGrid => 'ગ્રીડ છુપાવો';

  @override
  String get showGrid => 'ગ્રીડ બતાવો';

  @override
  String get resetGrid => 'ગ્રીડ રીસેટ કરો';

  @override
  String get exportAlignedImage => 'ગોઠવેલી છબી નિકાસ કરો';

  @override
  String get openTemplatePhoto => 'તમારા ભરેલા ટેમ્પ્લેટનો ફોટો ખોલો';

  @override
  String get openImage => 'છબી ખોલો';

  @override
  String get gridInstructions =>
      'ચારેય ખૂણા ખેંચીને ગ્રીડને ફોટા પર બેસાડો,\nપછી સુધારેલા પરિપ્રેક્ષ્યવાળી છબી નિકાસ કરો.';
}
