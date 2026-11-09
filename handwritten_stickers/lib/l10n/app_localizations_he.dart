// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get navTextEditor => 'עורך טקסט';

  @override
  String get navGridAlignment => 'יישור רשת';

  @override
  String get editorTitle => 'טקסט בכתב יד';

  @override
  String get packs => 'חבילות';

  @override
  String get emojiForMessage => 'אימוג׳י להודעה';

  @override
  String get saveToGallery => 'שמירה בגלריה';

  @override
  String get share => 'שיתוף';

  @override
  String get previewEmpty => 'כתבו משהו למטה…';

  @override
  String get textHint => 'כתבו כאן את הטקסט…';

  @override
  String get advancedSettings => 'הגדרות מתקדמות';

  @override
  String get savedToGallery => 'נשמר בגלריה!';

  @override
  String get saveFailed => 'לא ניתן היה לשמור את התמונה';

  @override
  String get shareFailed => 'השיתוף נכשל';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'הגופן של ההגדרה השמורה „$preset” אינו זמין, נעשה שימוש ב־$sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'הגדרה שמורה';

  @override
  String get newPreset => 'הגדרה שמורה חדשה';

  @override
  String get renamePreset => 'שינוי שם ההגדרה';

  @override
  String get restorePurchases => 'שחזור רכישות';

  @override
  String get purchasesRestored => 'הרכישות שוחזרו.';

  @override
  String get packsIntro =>
      'כל התכונות של האפליקציה חינמיות. חבילות מוסיפות גופנים והגדרות שמורות.';

  @override
  String get owned => 'נרכש';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count גופנים',
      two: '$count גופנים',
      one: 'גופן אחד',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count הגדרות שמורות',
      two: '$count הגדרות שמורות',
      one: 'הגדרה שמורה אחת',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => 'הרכישה ממתינה לאישור. היא תיפתח מעצמה.';

  @override
  String get purchaseFailed => 'הרכישה נכשלה. נסו שוב.';

  @override
  String get purchasesRestoredUnlocked => 'הרכישות שוחזרו. כל מה שקניתם פתוח.';

  @override
  String paywallPresets(String names) {
    return 'הגדרות שמורות: $names';
  }

  @override
  String get unlimitedPresets => 'הגדרות שמורות משלכם ללא הגבלה';

  @override
  String get buyOnce => 'קונים פעם אחת, שלכם לתמיד, גם במכשירים האחרים';

  @override
  String get allFeaturesFree => 'כל התכונות של האפליקציה נשארות חינמיות';

  @override
  String get storeUnavailable => 'החנות אינה זמינה כרגע. נסו מאוחר יותר.';

  @override
  String buyFor(String price) {
    return 'קנייה ב־$price';
  }

  @override
  String get notForSale => 'עדיין לא במכירה';

  @override
  String get loadingPrice => 'טוען מחיר…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: כל החבילות ב־$price';
  }

  @override
  String get save => 'שמירה';

  @override
  String get presetSaveTooltip => 'שמירת הגופן והסגנון הנוכחיים כהגדרה שמורה';

  @override
  String get presetSaveAsNew => 'שמירת הנוכחי כהגדרה חדשה';

  @override
  String get presetOverwrite => 'החלפה בהגדרות הנוכחיות';

  @override
  String get rename => 'שינוי שם';

  @override
  String get delete => 'מחיקה';

  @override
  String get presetName => 'שם';

  @override
  String get cancel => 'ביטול';

  @override
  String get deletePresetTitle => 'למחוק את ההגדרה?';

  @override
  String deletePresetBody(String name) {
    return '„$name” תימחק. הטקסט בעורך נשאר.';
  }

  @override
  String get joinLetters => 'חיבור אותיות';

  @override
  String get letterSpacing => 'ריווח אותיות';

  @override
  String get baselineWobble => 'גליות השורה';

  @override
  String get sizeVariance => 'שונות בגודל';

  @override
  String get rotationVariance => 'שונות בנטייה';

  @override
  String get opacityVariance => 'שונות באטימות';

  @override
  String get categoryHandwriting => 'כתב יד';

  @override
  String get categoryCalligraphy => 'קליגרפיה';

  @override
  String get categoryTypography => 'טיפוגרפיה';

  @override
  String get categoryKids => 'ילדים';

  @override
  String get categoryMaterial => 'חומרים';

  @override
  String get noEmoji => 'ללא אימוג׳י';

  @override
  String get saveAlignedImage => 'שמירת התמונה המיושרת';

  @override
  String savedPath(String path) {
    return 'נשמר: $path';
  }

  @override
  String errorMessage(String error) {
    return 'שגיאה: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'יישור רשת — $file';
  }

  @override
  String get openAnotherImage => 'פתיחת תמונה אחרת';

  @override
  String get hideGrid => 'הסתרת הרשת';

  @override
  String get showGrid => 'הצגת הרשת';

  @override
  String get resetGrid => 'איפוס הרשת';

  @override
  String get exportAlignedImage => 'ייצוא התמונה המיושרת';

  @override
  String get openTemplatePhoto => 'פתחו תמונה של התבנית שמילאתם בכתב יד';

  @override
  String get openImage => 'פתיחת תמונה';

  @override
  String get gridInstructions =>
      'גררו את 4 הפינות כך שהרשת תתאים לתמונה,\nואז ייצאו את התמונה עם הפרספקטיבה המתוקנת.';
}
