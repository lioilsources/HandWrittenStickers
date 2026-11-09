// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get navTextEditor => 'ടെക്സ്റ്റ് എഡിറ്റർ';

  @override
  String get navGridAlignment => 'ഗ്രിഡ് വിന്യാസം';

  @override
  String get editorTitle => 'കൈയെഴുത്ത് ടെക്സ്റ്റ്';

  @override
  String get packs => 'പായ്ക്കുകൾ';

  @override
  String get emojiForMessage => 'സന്ദേശത്തിന് ഇമോജി';

  @override
  String get saveToGallery => 'ഗാലറിയിൽ സംരക്ഷിക്കുക';

  @override
  String get share => 'പങ്കിടുക';

  @override
  String get previewEmpty => 'താഴെ എന്തെങ്കിലും എഴുതൂ…';

  @override
  String get textHint => 'നിങ്ങളുടെ ടെക്സ്റ്റ് ഇവിടെ എഴുതുക…';

  @override
  String get advancedSettings => 'വിപുലമായ ക്രമീകരണങ്ങൾ';

  @override
  String get savedToGallery => 'ഗാലറിയിൽ സംരക്ഷിച്ചു!';

  @override
  String get saveFailed => 'ചിത്രം സംരക്ഷിക്കാനായില്ല';

  @override
  String get shareFailed => 'പങ്കിടാനായില്ല';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'പ്രീസെറ്റ് “$preset”-ന്റെ ഫോണ്ട് ലഭ്യമല്ല, $sheet ഉപയോഗിച്ചു.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'പ്രീസെറ്റ്';

  @override
  String get newPreset => 'പുതിയ പ്രീസെറ്റ്';

  @override
  String get renamePreset => 'പ്രീസെറ്റിന്റെ പേര് മാറ്റുക';

  @override
  String get restorePurchases => 'വാങ്ങലുകൾ പുനഃസ്ഥാപിക്കുക';

  @override
  String get purchasesRestored => 'വാങ്ങലുകൾ പുനഃസ്ഥാപിച്ചു.';

  @override
  String get packsIntro =>
      'ആപ്പിന്റെ എല്ലാ ഫീച്ചറുകളും സൗജന്യമാണ്. പായ്ക്കുകൾ കൂടുതൽ ഫോണ്ടുകളും പ്രീസെറ്റുകളും ചേർക്കുന്നു.';

  @override
  String get owned => 'നിങ്ങളുടേത്';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഫോണ്ടുകൾ',
      one: '$count ഫോണ്ട്',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പ്രീസെറ്റുകൾ',
      one: '$count പ്രീസെറ്റ്',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'വാങ്ങൽ അംഗീകാരത്തിനായി കാത്തിരിക്കുന്നു. അത് സ്വയം അൺലോക്ക് ആകും.';

  @override
  String get purchaseFailed =>
      'വാങ്ങൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get purchasesRestoredUnlocked =>
      'വാങ്ങലുകൾ പുനഃസ്ഥാപിച്ചു. നിങ്ങൾ വാങ്ങിയതെല്ലാം അൺലോക്ക് ആണ്.';

  @override
  String paywallPresets(String names) {
    return 'പ്രീസെറ്റുകൾ: $names';
  }

  @override
  String get unlimitedPresets => 'പരിധിയില്ലാത്ത സ്വന്തം പ്രീസെറ്റുകൾ';

  @override
  String get buyOnce =>
      'ഒരിക്കൽ വാങ്ങൂ, എന്നേക്കും നിങ്ങളുടേത്, മറ്റ് ഉപകരണങ്ങളിലും';

  @override
  String get allFeaturesFree => 'ആപ്പിന്റെ എല്ലാ ഫീച്ചറുകളും സൗജന്യമായി തുടരും';

  @override
  String get storeUnavailable =>
      'സ്റ്റോർ ഇപ്പോൾ ലഭ്യമല്ല. പിന്നീട് ശ്രമിക്കുക.';

  @override
  String buyFor(String price) {
    return '$price-ന് വാങ്ങുക';
  }

  @override
  String get notForSale => 'ഇതുവരെ വിൽപ്പനയ്ക്കില്ല';

  @override
  String get loadingPrice => 'വില ലോഡ് ചെയ്യുന്നു…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: എല്ലാ പായ്ക്കുകളും $price-ന്';
  }

  @override
  String get save => 'സംരക്ഷിക്കുക';

  @override
  String get presetSaveTooltip =>
      'നിലവിലെ ഫോണ്ടും ശൈലിയും പ്രീസെറ്റായി സംരക്ഷിക്കുക';

  @override
  String get presetSaveAsNew => 'നിലവിലുള്ളത് പുതിയ പ്രീസെറ്റായി സംരക്ഷിക്കുക';

  @override
  String get presetOverwrite => 'നിലവിലെ ക്രമീകരണങ്ങൾ കൊണ്ട് മാറ്റിയെഴുതുക';

  @override
  String get rename => 'പേര് മാറ്റുക';

  @override
  String get delete => 'ഇല്ലാതാക്കുക';

  @override
  String get presetName => 'പേര്';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get deletePresetTitle => 'പ്രീസെറ്റ് ഇല്ലാതാക്കണോ?';

  @override
  String deletePresetBody(String name) {
    return '“$name” ഇല്ലാതാക്കും. എഡിറ്ററിലെ ടെക്സ്റ്റ് നിലനിൽക്കും.';
  }

  @override
  String get joinLetters => 'അക്ഷരങ്ങൾ ചേർക്കുക';

  @override
  String get letterSpacing => 'അക്ഷര അകലം';

  @override
  String get baselineWobble => 'വരിയുടെ ഇളക്കം';

  @override
  String get sizeVariance => 'വലുപ്പ വ്യതിയാനം';

  @override
  String get rotationVariance => 'ചരിവ് വ്യതിയാനം';

  @override
  String get opacityVariance => 'കടുപ്പ വ്യതിയാനം';

  @override
  String get categoryHandwriting => 'കൈയെഴുത്ത്';

  @override
  String get categoryCalligraphy => 'കാലിഗ്രഫി';

  @override
  String get categoryTypography => 'ടൈപ്പോഗ്രഫി';

  @override
  String get categoryKids => 'കുട്ടികൾക്ക്';

  @override
  String get categoryMaterial => 'വസ്തുക്കൾ';

  @override
  String get noEmoji => 'ഇമോജി ഇല്ല';

  @override
  String get saveAlignedImage => 'വിന്യസിച്ച ചിത്രം സംരക്ഷിക്കുക';

  @override
  String savedPath(String path) {
    return 'സംരക്ഷിച്ചു: $path';
  }

  @override
  String errorMessage(String error) {
    return 'പിശക്: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'ഗ്രിഡ് വിന്യാസം — $file';
  }

  @override
  String get openAnotherImage => 'മറ്റൊരു ചിത്രം തുറക്കുക';

  @override
  String get hideGrid => 'ഗ്രിഡ് മറയ്ക്കുക';

  @override
  String get showGrid => 'ഗ്രിഡ് കാണിക്കുക';

  @override
  String get resetGrid => 'ഗ്രിഡ് പുനഃസജ്ജമാക്കുക';

  @override
  String get exportAlignedImage => 'വിന്യസിച്ച ചിത്രം എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get openTemplatePhoto =>
      'നിങ്ങൾ പൂരിപ്പിച്ച ടെംപ്ലേറ്റിന്റെ ഫോട്ടോ തുറക്കുക';

  @override
  String get openImage => 'ചിത്രം തുറക്കുക';

  @override
  String get gridInstructions =>
      'നാല് മൂലകളും വലിച്ച് ഗ്രിഡ് ഫോട്ടോയിൽ ഒപ്പിക്കുക,\nതുടർന്ന് കാഴ്ചക്കോൺ ശരിയാക്കിയ ചിത്രം എക്സ്പോർട്ട് ചെയ്യുക.';
}
