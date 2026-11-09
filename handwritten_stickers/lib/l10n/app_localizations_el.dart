// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get navTextEditor => 'Επεξεργαστής κειμένου';

  @override
  String get navGridAlignment => 'Ευθυγράμμιση πλέγματος';

  @override
  String get editorTitle => 'Χειρόγραφο κείμενο';

  @override
  String get packs => 'Πακέτα';

  @override
  String get emojiForMessage => 'Emoji για το μήνυμα';

  @override
  String get saveToGallery => 'Αποθήκευση στη συλλογή';

  @override
  String get share => 'Κοινοποίηση';

  @override
  String get previewEmpty => 'Γράψε κάτι παρακάτω…';

  @override
  String get textHint => 'Γράψε εδώ το κείμενό σου…';

  @override
  String get advancedSettings => 'Ρυθμίσεις για προχωρημένους';

  @override
  String get savedToGallery => 'Αποθηκεύτηκε στη συλλογή!';

  @override
  String get saveFailed => 'Η εικόνα δεν αποθηκεύτηκε';

  @override
  String get shareFailed => 'Η κοινοποίηση απέτυχε';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Η γραμματοσειρά της προρύθμισης «$preset» δεν είναι διαθέσιμη, χρησιμοποιείται η $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Προρύθμιση';

  @override
  String get newPreset => 'Νέα προρύθμιση';

  @override
  String get renamePreset => 'Μετονομασία προρύθμισης';

  @override
  String get restorePurchases => 'Επαναφορά αγορών';

  @override
  String get purchasesRestored => 'Οι αγορές επανήλθαν.';

  @override
  String get packsIntro =>
      'Όλες οι λειτουργίες της εφαρμογής είναι δωρεάν. Τα πακέτα προσθέτουν γραμματοσειρές και προρυθμίσεις.';

  @override
  String get owned => 'Αγοράστηκε';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count γραμματοσειρές',
      one: '$count γραμματοσειρά',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count προρυθμίσεις',
      one: '$count προρύθμιση',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Η αγορά περιμένει έγκριση. Θα ξεκλειδωθεί μόνη της.';

  @override
  String get purchaseFailed => 'Η αγορά απέτυχε. Δοκίμασε ξανά.';

  @override
  String get purchasesRestoredUnlocked =>
      'Οι αγορές επανήλθαν. Ό,τι αγόρασες είναι ξεκλείδωτο.';

  @override
  String paywallPresets(String names) {
    return 'Προρυθμίσεις: $names';
  }

  @override
  String get unlimitedPresets => 'Απεριόριστες δικές σου προρυθμίσεις';

  @override
  String get buyOnce =>
      'Αγοράζεις μία φορά, το έχεις για πάντα, και στις άλλες συσκευές σου';

  @override
  String get allFeaturesFree =>
      'Όλες οι λειτουργίες της εφαρμογής μένουν δωρεάν';

  @override
  String get storeUnavailable =>
      'Το κατάστημα δεν είναι διαθέσιμο τώρα. Δοκίμασε αργότερα.';

  @override
  String buyFor(String price) {
    return 'Αγορά για $price';
  }

  @override
  String get notForSale => 'Δεν πωλείται ακόμη';

  @override
  String get loadingPrice => 'Φόρτωση τιμής…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: όλα τα πακέτα για $price';
  }

  @override
  String get save => 'Αποθήκευση';

  @override
  String get presetSaveTooltip =>
      'Αποθήκευση της τρέχουσας γραμματοσειράς και στυλ ως προρύθμιση';

  @override
  String get presetSaveAsNew => 'Αποθήκευση του τρέχοντος ως νέα προρύθμιση';

  @override
  String get presetOverwrite => 'Αντικατάσταση με τις τρέχουσες ρυθμίσεις';

  @override
  String get rename => 'Μετονομασία';

  @override
  String get delete => 'Διαγραφή';

  @override
  String get presetName => 'Όνομα';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get deletePresetTitle => 'Διαγραφή προρύθμισης;';

  @override
  String deletePresetBody(String name) {
    return 'Η «$name» θα διαγραφεί. Το κείμενο στον επεξεργαστή μένει.';
  }

  @override
  String get joinLetters => 'Ένωση γραμμάτων';

  @override
  String get letterSpacing => 'Απόσταση γραμμάτων';

  @override
  String get baselineWobble => 'Κυμάτισμα γραμμής';

  @override
  String get sizeVariance => 'Διακύμανση μεγέθους';

  @override
  String get rotationVariance => 'Διακύμανση κλίσης';

  @override
  String get opacityVariance => 'Διακύμανση αδιαφάνειας';

  @override
  String get categoryHandwriting => 'Χειρόγραφα';

  @override
  String get categoryCalligraphy => 'Καλλιγραφία';

  @override
  String get categoryTypography => 'Τυπογραφία';

  @override
  String get categoryKids => 'Παιδικά';

  @override
  String get categoryMaterial => 'Υλικά';

  @override
  String get noEmoji => 'Χωρίς emoji';

  @override
  String get saveAlignedImage => 'Αποθήκευση ευθυγραμμισμένης εικόνας';

  @override
  String savedPath(String path) {
    return 'Αποθηκεύτηκε: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Ευθυγράμμιση πλέγματος — $file';
  }

  @override
  String get openAnotherImage => 'Άνοιγμα άλλης εικόνας';

  @override
  String get hideGrid => 'Απόκρυψη πλέγματος';

  @override
  String get showGrid => 'Εμφάνιση πλέγματος';

  @override
  String get resetGrid => 'Επαναφορά πλέγματος';

  @override
  String get exportAlignedImage => 'Εξαγωγή ευθυγραμμισμένης εικόνας';

  @override
  String get openTemplatePhoto =>
      'Άνοιξε μια φωτογραφία του συμπληρωμένου προτύπου σου';

  @override
  String get openImage => 'Άνοιγμα εικόνας';

  @override
  String get gridInstructions =>
      'Σύρε τις 4 γωνίες ώστε το πλέγμα να ταιριάξει στη φωτογραφία\nκαι μετά κάνε εξαγωγή της εικόνας με διορθωμένη προοπτική.';
}
