// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get navTextEditor => 'ଟେକ୍ସଟ୍ ଏଡିଟର୍';

  @override
  String get navGridAlignment => 'ଗ୍ରିଡ୍ ସଜାଡ଼ିବା';

  @override
  String get editorTitle => 'ହସ୍ତଲିଖିତ ଟେକ୍ସଟ୍';

  @override
  String get packs => 'ପ୍ୟାକ୍';

  @override
  String get emojiForMessage => 'ମେସେଜ୍ ପାଇଁ ଇମୋଜି';

  @override
  String get saveToGallery => 'ଗ୍ୟାଲେରୀରେ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get share => 'ସେୟାର୍ କରନ୍ତୁ';

  @override
  String get previewEmpty => 'ତଳେ କିଛି ଲେଖନ୍ତୁ…';

  @override
  String get textHint => 'ଆପଣଙ୍କ ଟେକ୍ସଟ୍ ଏଠାରେ ଲେଖନ୍ତୁ…';

  @override
  String get advancedSettings => 'ଉନ୍ନତ ସେଟିଂସ୍';

  @override
  String get savedToGallery => 'ଗ୍ୟାଲେରୀରେ ସେଭ୍ ହେଲା!';

  @override
  String get saveFailed => 'ଛବି ସେଭ୍ ହୋଇପାରିଲା ନାହିଁ';

  @override
  String get shareFailed => 'ସେୟାର୍ ହୋଇପାରିଲା ନାହିଁ';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'ପ୍ରିସେଟ୍ “$preset”ର ଫଣ୍ଟ ଉପଲବ୍ଧ ନାହିଁ, $sheet ବ୍ୟବହାର ହେଲା।';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'ପ୍ରିସେଟ୍';

  @override
  String get newPreset => 'ନୂଆ ପ୍ରିସେଟ୍';

  @override
  String get renamePreset => 'ପ୍ରିସେଟ୍‌ର ନାମ ବଦଳାନ୍ତୁ';

  @override
  String get restorePurchases => 'କିଣାକିଣି ଫେରାଇ ଆଣନ୍ତୁ';

  @override
  String get purchasesRestored => 'କିଣାକିଣି ଫେରାଇ ଅଣାଗଲା।';

  @override
  String get packsIntro =>
      'ଆପ୍‌ର ସମସ୍ତ ସୁବିଧା ମାଗଣା। ପ୍ୟାକ୍ ଅଧିକ ଫଣ୍ଟ ଓ ପ୍ରିସେଟ୍ ଯୋଡ଼େ।';

  @override
  String get owned => 'ଆପଣଙ୍କର';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି ଫଣ୍ଟ',
      one: '$countଟି ଫଣ୍ଟ',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି ପ୍ରିସେଟ୍',
      one: '$countଟି ପ୍ରିସେଟ୍',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'କିଣାକିଣି ଅନୁମୋଦନ ଅପେକ୍ଷାରେ ଅଛି। ଏହା ନିଜେ ଅନଲକ୍ ହେବ।';

  @override
  String get purchaseFailed => 'କିଣାକିଣି ବିଫଳ ହେଲା। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get purchasesRestoredUnlocked =>
      'କିଣାକିଣି ଫେରାଇ ଅଣାଗଲା। ଆପଣ କିଣିଥିବା ସବୁ ଅନଲକ୍ ଅଛି।';

  @override
  String paywallPresets(String names) {
    return 'ପ୍ରିସେଟ୍: $names';
  }

  @override
  String get unlimitedPresets => 'ଅସୀମିତ ନିଜ ପ୍ରିସେଟ୍';

  @override
  String get buyOnce =>
      'ଥରେ କିଣନ୍ତୁ, ସବୁଦିନ ପାଇଁ ଆପଣଙ୍କର, ଅନ୍ୟ ଡିଭାଇସ୍‌ରେ ମଧ୍ୟ';

  @override
  String get allFeaturesFree => 'ଆପ୍‌ର ସମସ୍ତ ସୁବିଧା ମାଗଣା ରହିବ';

  @override
  String get storeUnavailable => 'ଷ୍ଟୋର୍ ଏବେ ଉପଲବ୍ଧ ନାହିଁ। ପରେ ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String buyFor(String price) {
    return '$priceରେ କିଣନ୍ତୁ';
  }

  @override
  String get notForSale => 'ଏପର୍ଯ୍ୟନ୍ତ ବିକ୍ରି ପାଇଁ ନାହିଁ';

  @override
  String get loadingPrice => 'ଦାମ୍ ଲୋଡ୍ ହେଉଛି…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: ସମସ୍ତ ପ୍ୟାକ୍ $priceରେ';
  }

  @override
  String get save => 'ସେଭ୍ କରନ୍ତୁ';

  @override
  String get presetSaveTooltip =>
      'ବର୍ତ୍ତମାନର ଫଣ୍ଟ ଓ ଶୈଳୀକୁ ପ୍ରିସେଟ୍ ଭାବେ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get presetSaveAsNew => 'ବର୍ତ୍ତମାନକୁ ନୂଆ ପ୍ରିସେଟ୍ ଭାବେ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get presetOverwrite => 'ବର୍ତ୍ତମାନର ସେଟିଂସ୍‌ରେ ବଦଳାନ୍ତୁ';

  @override
  String get rename => 'ନାମ ବଦଳାନ୍ତୁ';

  @override
  String get delete => 'ଡିଲିଟ୍ କରନ୍ତୁ';

  @override
  String get presetName => 'ନାମ';

  @override
  String get cancel => 'ବାତିଲ୍';

  @override
  String get deletePresetTitle => 'ପ୍ରିସେଟ୍ ଡିଲିଟ୍ କରିବେ?';

  @override
  String deletePresetBody(String name) {
    return '“$name” ଡିଲିଟ୍ ହେବ। ଏଡିଟର୍‌ର ଟେକ୍ସଟ୍ ରହିବ।';
  }

  @override
  String get joinLetters => 'ଅକ୍ଷର ଯୋଡ଼ନ୍ତୁ';

  @override
  String get letterSpacing => 'ଅକ୍ଷର ବ୍ୟବଧାନ';

  @override
  String get baselineWobble => 'ଧାଡ଼ିର ଲହରୀ';

  @override
  String get sizeVariance => 'ଆକାରର ଭିନ୍ନତା';

  @override
  String get rotationVariance => 'ଢଳାର ଭିନ୍ନତା';

  @override
  String get opacityVariance => 'ଗାଢ଼ତାର ଭିନ୍ନତା';

  @override
  String get categoryHandwriting => 'ହସ୍ତାକ୍ଷର';

  @override
  String get categoryCalligraphy => 'କ୍ୟାଲିଗ୍ରାଫି';

  @override
  String get categoryTypography => 'ଟାଇପୋଗ୍ରାଫି';

  @override
  String get categoryKids => 'ପିଲାଙ୍କ ପାଇଁ';

  @override
  String get categoryMaterial => 'ସାମଗ୍ରୀ';

  @override
  String get noEmoji => 'ଇମୋଜି ନାହିଁ';

  @override
  String get saveAlignedImage => 'ସଜାଡ଼ିଥିବା ଛବି ସେଭ୍ କରନ୍ତୁ';

  @override
  String savedPath(String path) {
    return 'ସେଭ୍ ହେଲା: $path';
  }

  @override
  String errorMessage(String error) {
    return 'ତ୍ରୁଟି: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ଗ୍ରିଡ୍ ସଜାଡ଼ିବା — $file';
  }

  @override
  String get openAnotherImage => 'ଅନ୍ୟ ଛବି ଖୋଲନ୍ତୁ';

  @override
  String get hideGrid => 'ଗ୍ରିଡ୍ ଲୁଚାନ୍ତୁ';

  @override
  String get showGrid => 'ଗ୍ରିଡ୍ ଦେଖାନ୍ତୁ';

  @override
  String get resetGrid => 'ଗ୍ରିଡ୍ ରିସେଟ୍ କରନ୍ତୁ';

  @override
  String get exportAlignedImage => 'ସଜାଡ଼ିଥିବା ଛବି ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get openTemplatePhoto => 'ଆପଣ ପୂରଣ କରିଥିବା ଟେମ୍ପଲେଟ୍‌ର ଫଟୋ ଖୋଲନ୍ତୁ';

  @override
  String get openImage => 'ଛବି ଖୋଲନ୍ତୁ';

  @override
  String get gridInstructions =>
      'ଚାରି କୋଣକୁ ଟାଣି ଗ୍ରିଡ୍‌କୁ ଫଟୋ ଉପରେ ମେଳ କରନ୍ତୁ,\nତା’ପରେ ଦୃଷ୍ଟିକୋଣ ସଂଶୋଧିତ ଛବି ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ।';
}
