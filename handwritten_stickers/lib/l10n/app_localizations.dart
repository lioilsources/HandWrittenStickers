import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nb'),
    Locale('nl'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @navTextEditor.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get navTextEditor;

  /// No description provided for @navGridAlignment.
  ///
  /// In en, this message translates to:
  /// **'Grid Alignment'**
  String get navGridAlignment;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'Handwritten Text'**
  String get editorTitle;

  /// Paid content packs (fonts and presets).
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get packs;

  /// No description provided for @emojiForMessage.
  ///
  /// In en, this message translates to:
  /// **'Emoji for the message'**
  String get emojiForMessage;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @previewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Type something below…'**
  String get previewEmpty;

  /// No description provided for @textHint.
  ///
  /// In en, this message translates to:
  /// **'Type your text here…'**
  String get textHint;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery!'**
  String get savedToGallery;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get saveFailed;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing failed'**
  String get shareFailed;

  /// No description provided for @presetSheetMissing.
  ///
  /// In en, this message translates to:
  /// **'The font of preset “{preset}” is not available, using {sheet}.'**
  String presetSheetMissing(String preset, String sheet);

  /// Default name of a new preset: font name and today's date.
  ///
  /// In en, this message translates to:
  /// **'{sheet} – {date}'**
  String presetDefaultName(String sheet, DateTime date);

  /// A preset = saved combination of font and style.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get presetFallbackName;

  /// No description provided for @newPreset.
  ///
  /// In en, this message translates to:
  /// **'New preset'**
  String get newPreset;

  /// No description provided for @renamePreset.
  ///
  /// In en, this message translates to:
  /// **'Rename preset'**
  String get renamePreset;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get purchasesRestored;

  /// No description provided for @packsIntro.
  ///
  /// In en, this message translates to:
  /// **'Every feature of the app is free. Packs add more fonts and presets.'**
  String get packsIntro;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @fontCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} font} other{{count} fonts}}'**
  String fontCount(int count);

  /// No description provided for @presetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} preset} other{{count} presets}}'**
  String presetCount(int count);

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'The purchase is waiting for approval. It unlocks by itself.'**
  String get purchasePending;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase failed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @purchasesRestoredUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored. Everything you bought is unlocked.'**
  String get purchasesRestoredUnlocked;

  /// No description provided for @paywallPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets: {names}'**
  String paywallPresets(String names);

  /// No description provided for @unlimitedPresets.
  ///
  /// In en, this message translates to:
  /// **'Unlimited presets of your own'**
  String get unlimitedPresets;

  /// No description provided for @buyOnce.
  ///
  /// In en, this message translates to:
  /// **'Buy once, keep forever, on your other devices too'**
  String get buyOnce;

  /// No description provided for @allFeaturesFree.
  ///
  /// In en, this message translates to:
  /// **'Every feature of the app stays free'**
  String get allFeaturesFree;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store is not available right now. Try again later.'**
  String get storeUnavailable;

  /// No description provided for @buyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy for {price}'**
  String buyFor(String price);

  /// No description provided for @notForSale.
  ///
  /// In en, this message translates to:
  /// **'Not on sale yet'**
  String get notForSale;

  /// No description provided for @loadingPrice.
  ///
  /// In en, this message translates to:
  /// **'Loading price…'**
  String get loadingPrice;

  /// Button offering the bundle of every pack; bundle = its name.
  ///
  /// In en, this message translates to:
  /// **'{bundle}: all packs for {price}'**
  String buyAllFor(String bundle, String price);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @presetSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save the current font and style as a preset'**
  String get presetSaveTooltip;

  /// No description provided for @presetSaveAsNew.
  ///
  /// In en, this message translates to:
  /// **'Save current as a new preset'**
  String get presetSaveAsNew;

  /// No description provided for @presetOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite with current settings'**
  String get presetOverwrite;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get presetName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete preset?'**
  String get deletePresetTitle;

  /// No description provided for @deletePresetBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be deleted. The text in the editor stays.'**
  String deletePresetBody(String name);

  /// No description provided for @joinLetters.
  ///
  /// In en, this message translates to:
  /// **'Join letters'**
  String get joinLetters;

  /// No description provided for @letterSpacing.
  ///
  /// In en, this message translates to:
  /// **'Letter Spacing'**
  String get letterSpacing;

  /// No description provided for @baselineWobble.
  ///
  /// In en, this message translates to:
  /// **'Baseline Wobble'**
  String get baselineWobble;

  /// No description provided for @sizeVariance.
  ///
  /// In en, this message translates to:
  /// **'Size Variance'**
  String get sizeVariance;

  /// No description provided for @rotationVariance.
  ///
  /// In en, this message translates to:
  /// **'Rotation Variance'**
  String get rotationVariance;

  /// No description provided for @opacityVariance.
  ///
  /// In en, this message translates to:
  /// **'Opacity Variance'**
  String get opacityVariance;

  /// No description provided for @categoryHandwriting.
  ///
  /// In en, this message translates to:
  /// **'Handwriting'**
  String get categoryHandwriting;

  /// No description provided for @categoryCalligraphy.
  ///
  /// In en, this message translates to:
  /// **'Calligraphy'**
  String get categoryCalligraphy;

  /// No description provided for @categoryTypography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get categoryTypography;

  /// No description provided for @categoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// Sheet category: letters made of materials (gingerbread, neon, plasticine).
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get categoryMaterial;

  /// No description provided for @noEmoji.
  ///
  /// In en, this message translates to:
  /// **'No emoji'**
  String get noEmoji;

  /// No description provided for @saveAlignedImage.
  ///
  /// In en, this message translates to:
  /// **'Save Aligned Image'**
  String get saveAlignedImage;

  /// No description provided for @savedPath.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String savedPath(String path);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// No description provided for @gridAlignmentFile.
  ///
  /// In en, this message translates to:
  /// **'Grid Alignment — {file}'**
  String gridAlignmentFile(String file);

  /// No description provided for @openAnotherImage.
  ///
  /// In en, this message translates to:
  /// **'Open Another Image'**
  String get openAnotherImage;

  /// No description provided for @hideGrid.
  ///
  /// In en, this message translates to:
  /// **'Hide Grid'**
  String get hideGrid;

  /// No description provided for @showGrid.
  ///
  /// In en, this message translates to:
  /// **'Show Grid'**
  String get showGrid;

  /// No description provided for @resetGrid.
  ///
  /// In en, this message translates to:
  /// **'Reset Grid'**
  String get resetGrid;

  /// No description provided for @exportAlignedImage.
  ///
  /// In en, this message translates to:
  /// **'Export Aligned Image'**
  String get exportAlignedImage;

  /// No description provided for @openTemplatePhoto.
  ///
  /// In en, this message translates to:
  /// **'Open a photo of your handwriting template'**
  String get openTemplatePhoto;

  /// No description provided for @openImage.
  ///
  /// In en, this message translates to:
  /// **'Open Image'**
  String get openImage;

  /// No description provided for @gridInstructions.
  ///
  /// In en, this message translates to:
  /// **'Drag the 4 corners to align the grid on the photo,\nthen export the perspective-corrected image.'**
  String get gridInstructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'gu',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'ms',
    'nb',
    'nl',
    'or',
    'pa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
