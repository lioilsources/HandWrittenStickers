import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

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
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @navEditor.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get navEditor;

  /// No description provided for @navGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid Alignment'**
  String get navGrid;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'Handwritten Text'**
  String get editorTitle;

  /// No description provided for @packs.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get packs;

  /// No description provided for @aboutAndLicences.
  ///
  /// In en, this message translates to:
  /// **'About and licences'**
  String get aboutAndLicences;

  /// No description provided for @emojiTag.
  ///
  /// In en, this message translates to:
  /// **'Emoji tag'**
  String get emojiTag;

  /// No description provided for @noEmoji.
  ///
  /// In en, this message translates to:
  /// **'No emoji'**
  String get noEmoji;

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

  /// No description provided for @emptyCanvasHint.
  ///
  /// In en, this message translates to:
  /// **'Type something below...'**
  String get emptyCanvasHint;

  /// No description provided for @textHint.
  ///
  /// In en, this message translates to:
  /// **'Type your text here...'**
  String get textHint;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @presetDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get presetDefaultName;

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

  /// No description provided for @presetSheetMissing.
  ///
  /// In en, this message translates to:
  /// **'The font of preset “{preset}” is not available, using {sheet}.'**
  String presetSheetMissing(String preset, String sheet);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savePresetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save the current font and style as a preset'**
  String get savePresetTooltip;

  /// No description provided for @saveAsNewPreset.
  ///
  /// In en, this message translates to:
  /// **'Save current as a new preset'**
  String get saveAsNewPreset;

  /// No description provided for @overwritePreset.
  ///
  /// In en, this message translates to:
  /// **'Overwrite with the current settings'**
  String get overwritePreset;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

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

  /// No description provided for @purchasesRestoredUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored. What you bought is unlocked.'**
  String get purchasesRestoredUnlocked;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @packsIntro.
  ///
  /// In en, this message translates to:
  /// **'Every feature of the app is free. Packs add more fonts and presets.'**
  String get packsIntro;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'The purchase is waiting for approval. It will unlock by itself.'**
  String get purchasePending;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase failed. Please try again.'**
  String get purchaseFailed;

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

  /// No description provided for @notForSaleYet.
  ///
  /// In en, this message translates to:
  /// **'Not for sale yet'**
  String get notForSaleYet;

  /// No description provided for @allPacksFor.
  ///
  /// In en, this message translates to:
  /// **'{name}: all packs for {price}'**
  String allPacksFor(String name, String price);

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

  /// No description provided for @categoryMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get categoryMaterial;

  /// No description provided for @gridSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String gridSaved(String path);

  /// No description provided for @gridError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String gridError(String error);

  /// No description provided for @gridSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Aligned Image'**
  String get gridSaveDialogTitle;

  /// No description provided for @gridOpenAnother.
  ///
  /// In en, this message translates to:
  /// **'Open Another Image'**
  String get gridOpenAnother;

  /// No description provided for @gridHide.
  ///
  /// In en, this message translates to:
  /// **'Hide Grid'**
  String get gridHide;

  /// No description provided for @gridShow.
  ///
  /// In en, this message translates to:
  /// **'Show Grid'**
  String get gridShow;

  /// No description provided for @gridReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Grid'**
  String get gridReset;

  /// No description provided for @gridExport.
  ///
  /// In en, this message translates to:
  /// **'Export Aligned Image'**
  String get gridExport;

  /// No description provided for @gridOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Open Image'**
  String get gridOpenImage;

  /// No description provided for @gridOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Open a photo of your handwriting template'**
  String get gridOpenHint;

  /// No description provided for @gridDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the 4 corners to align the grid on the photo,\nthen export the perspective-corrected image.'**
  String get gridDragHint;

  /// No description provided for @sheetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 font} other{{count} fonts}}'**
  String sheetCount(int count);

  /// No description provided for @presetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 preset} other{{count} presets}}'**
  String presetCount(int count);

  /// No description provided for @presetsList.
  ///
  /// In en, this message translates to:
  /// **'Presets: {names}'**
  String presetsList(String names);

  /// No description provided for @unlimitedPresets.
  ///
  /// In en, this message translates to:
  /// **'Unlimited presets of your own'**
  String get unlimitedPresets;

  /// No description provided for @buyOnceKeepForever.
  ///
  /// In en, this message translates to:
  /// **'Buy once, keep forever, on your other devices too'**
  String get buyOnceKeepForever;

  /// No description provided for @featuresStayFree.
  ///
  /// In en, this message translates to:
  /// **'Every feature of the app stays free'**
  String get featuresStayFree;

  /// No description provided for @loadingPrice.
  ///
  /// In en, this message translates to:
  /// **'Loading price…'**
  String get loadingPrice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
