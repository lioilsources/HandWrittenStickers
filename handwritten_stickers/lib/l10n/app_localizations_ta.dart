// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get navTextEditor => 'உரை திருத்தி';

  @override
  String get navGridAlignment => 'கட்ட சீரமைப்பு';

  @override
  String get editorTitle => 'கையெழுத்து உரை';

  @override
  String get packs => 'தொகுப்புகள்';

  @override
  String get emojiForMessage => 'செய்திக்கு எமோஜி';

  @override
  String get saveToGallery => 'கேலரியில் சேமி';

  @override
  String get share => 'பகிர்';

  @override
  String get previewEmpty => 'கீழே ஏதாவது எழுதுங்கள்…';

  @override
  String get textHint => 'உங்கள் உரையை இங்கே எழுதுங்கள்…';

  @override
  String get advancedSettings => 'மேம்பட்ட அமைப்புகள்';

  @override
  String get savedToGallery => 'கேலரியில் சேமிக்கப்பட்டது!';

  @override
  String get saveFailed => 'படத்தைச் சேமிக்க முடியவில்லை';

  @override
  String get shareFailed => 'பகிர முடியவில்லை';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'முன்னமைவு “$preset” இன் எழுத்துரு கிடைக்கவில்லை, $sheet பயன்படுத்தப்பட்டது.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'முன்னமைவு';

  @override
  String get newPreset => 'புதிய முன்னமைவு';

  @override
  String get renamePreset => 'முன்னமைவின் பெயரை மாற்று';

  @override
  String get restorePurchases => 'வாங்கியவற்றை மீட்டமை';

  @override
  String get purchasesRestored => 'வாங்கியவை மீட்டமைக்கப்பட்டன.';

  @override
  String get packsIntro =>
      'ஆப்பின் எல்லா அம்சங்களும் இலவசம். தொகுப்புகள் கூடுதல் எழுத்துருக்களையும் முன்னமைவுகளையும் சேர்க்கின்றன.';

  @override
  String get owned => 'உங்களுடையது';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count எழுத்துருக்கள்',
      one: '$count எழுத்துரு',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count முன்னமைவுகள்',
      one: '$count முன்னமைவு',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'வாங்குதல் ஒப்புதலுக்காகக் காத்திருக்கிறது. அது தானாகத் திறக்கப்படும்.';

  @override
  String get purchaseFailed => 'வாங்குதல் தோல்வியடைந்தது. மீண்டும் முயலவும்.';

  @override
  String get purchasesRestoredUnlocked =>
      'வாங்கியவை மீட்டமைக்கப்பட்டன. நீங்கள் வாங்கியவை அனைத்தும் திறக்கப்பட்டுள்ளன.';

  @override
  String paywallPresets(String names) {
    return 'முன்னமைவுகள்: $names';
  }

  @override
  String get unlimitedPresets => 'வரம்பற்ற சொந்த முன்னமைவுகள்';

  @override
  String get buyOnce =>
      'ஒருமுறை வாங்குங்கள், என்றும் உங்களுடையது, மற்ற சாதனங்களிலும்';

  @override
  String get allFeaturesFree => 'ஆப்பின் எல்லா அம்சங்களும் இலவசமாகவே இருக்கும்';

  @override
  String get storeUnavailable =>
      'ஸ்டோர் இப்போது கிடைக்கவில்லை. பிறகு முயலவும்.';

  @override
  String buyFor(String price) {
    return '$priceக்கு வாங்கு';
  }

  @override
  String get notForSale => 'இன்னும் விற்பனைக்கு இல்லை';

  @override
  String get loadingPrice => 'விலை ஏற்றப்படுகிறது…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: எல்லாத் தொகுப்புகளும் $priceக்கு';
  }

  @override
  String get save => 'சேமி';

  @override
  String get presetSaveTooltip =>
      'தற்போதைய எழுத்துருவையும் பாணியையும் முன்னமைவாகச் சேமி';

  @override
  String get presetSaveAsNew => 'தற்போதையதைப் புதிய முன்னமைவாகச் சேமி';

  @override
  String get presetOverwrite => 'தற்போதைய அமைப்புகளால் மாற்றி எழுது';

  @override
  String get rename => 'பெயர் மாற்று';

  @override
  String get delete => 'நீக்கு';

  @override
  String get presetName => 'பெயர்';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get deletePresetTitle => 'முன்னமைவை நீக்கவா?';

  @override
  String deletePresetBody(String name) {
    return '“$name” நீக்கப்படும். திருத்தியில் உள்ள உரை அப்படியே இருக்கும்.';
  }

  @override
  String get joinLetters => 'எழுத்துகளை இணை';

  @override
  String get letterSpacing => 'எழுத்து இடைவெளி';

  @override
  String get baselineWobble => 'வரி அலைவு';

  @override
  String get sizeVariance => 'அளவு மாறுபாடு';

  @override
  String get rotationVariance => 'சாய்வு மாறுபாடு';

  @override
  String get opacityVariance => 'அடர்த்தி மாறுபாடு';

  @override
  String get categoryHandwriting => 'கையெழுத்து';

  @override
  String get categoryCalligraphy => 'எழுத்தோவியம்';

  @override
  String get categoryTypography => 'அச்சுக்கலை';

  @override
  String get categoryKids => 'குழந்தைகளுக்கு';

  @override
  String get categoryMaterial => 'பொருட்கள்';

  @override
  String get noEmoji => 'எமோஜி இல்லை';

  @override
  String get saveAlignedImage => 'சீரமைத்த படத்தைச் சேமி';

  @override
  String savedPath(String path) {
    return 'சேமிக்கப்பட்டது: $path';
  }

  @override
  String errorMessage(String error) {
    return 'பிழை: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'கட்ட சீரமைப்பு — $file';
  }

  @override
  String get openAnotherImage => 'வேறு படத்தைத் திற';

  @override
  String get hideGrid => 'கட்டத்தை மறை';

  @override
  String get showGrid => 'கட்டத்தைக் காட்டு';

  @override
  String get resetGrid => 'கட்டத்தை மீட்டமை';

  @override
  String get exportAlignedImage => 'சீரமைத்த படத்தை ஏற்றுமதி செய்';

  @override
  String get openTemplatePhoto =>
      'நீங்கள் நிரப்பிய வார்ப்புருவின் புகைப்படத்தைத் திறக்கவும்';

  @override
  String get openImage => 'படத்தைத் திற';

  @override
  String get gridInstructions =>
      'நான்கு மூலைகளையும் இழுத்து கட்டத்தைப் புகைப்படத்தில் பொருத்துங்கள்,\nபின்னர் கோணம் சரிசெய்த படத்தை ஏற்றுமதி செய்யுங்கள்.';
}
