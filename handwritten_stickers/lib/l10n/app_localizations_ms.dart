// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get navTextEditor => 'Editor teks';

  @override
  String get navGridAlignment => 'Penjajaran grid';

  @override
  String get editorTitle => 'Teks tulisan tangan';

  @override
  String get packs => 'Pek';

  @override
  String get emojiForMessage => 'Emoji untuk mesej';

  @override
  String get saveToGallery => 'Simpan ke galeri';

  @override
  String get share => 'Kongsi';

  @override
  String get previewEmpty => 'Tulis sesuatu di bawah…';

  @override
  String get textHint => 'Tulis teks anda di sini…';

  @override
  String get advancedSettings => 'Tetapan lanjutan';

  @override
  String get savedToGallery => 'Disimpan ke galeri!';

  @override
  String get saveFailed => 'Gagal menyimpan imej';

  @override
  String get shareFailed => 'Gagal berkongsi';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Fon pratetap “$preset” tidak tersedia, $sheet digunakan.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Pratetap';

  @override
  String get newPreset => 'Pratetap baharu';

  @override
  String get renamePreset => 'Namakan semula pratetap';

  @override
  String get restorePurchases => 'Pulihkan pembelian';

  @override
  String get purchasesRestored => 'Pembelian dipulihkan.';

  @override
  String get packsIntro =>
      'Semua ciri apl adalah percuma. Pek menambah lebih banyak fon dan pratetap.';

  @override
  String get owned => 'Dimiliki';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fon',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pratetap',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Pembelian menunggu kelulusan. Ia akan dibuka dengan sendirinya.';

  @override
  String get purchaseFailed => 'Pembelian gagal. Sila cuba lagi.';

  @override
  String get purchasesRestoredUnlocked =>
      'Pembelian dipulihkan. Semua yang anda beli telah dibuka.';

  @override
  String paywallPresets(String names) {
    return 'Pratetap: $names';
  }

  @override
  String get unlimitedPresets => 'Pratetap sendiri tanpa had';

  @override
  String get buyOnce =>
      'Beli sekali, milik anda selamanya, juga pada peranti lain';

  @override
  String get allFeaturesFree => 'Semua ciri apl kekal percuma';

  @override
  String get storeUnavailable =>
      'Kedai tidak tersedia sekarang. Cuba lagi nanti.';

  @override
  String buyFor(String price) {
    return 'Beli pada harga $price';
  }

  @override
  String get notForSale => 'Belum dijual';

  @override
  String get loadingPrice => 'Memuatkan harga…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: semua pek pada harga $price';
  }

  @override
  String get save => 'Simpan';

  @override
  String get presetSaveTooltip => 'Simpan fon dan gaya semasa sebagai pratetap';

  @override
  String get presetSaveAsNew => 'Simpan semasa sebagai pratetap baharu';

  @override
  String get presetOverwrite => 'Tulis ganti dengan tetapan semasa';

  @override
  String get rename => 'Namakan semula';

  @override
  String get delete => 'Padam';

  @override
  String get presetName => 'Nama';

  @override
  String get cancel => 'Batal';

  @override
  String get deletePresetTitle => 'Padam pratetap?';

  @override
  String deletePresetBody(String name) {
    return '“$name” akan dipadam. Teks dalam editor kekal.';
  }

  @override
  String get joinLetters => 'Sambung huruf';

  @override
  String get letterSpacing => 'Jarak huruf';

  @override
  String get baselineWobble => 'Gelombang baris';

  @override
  String get sizeVariance => 'Variasi saiz';

  @override
  String get rotationVariance => 'Variasi kecondongan';

  @override
  String get opacityVariance => 'Variasi kelegapan';

  @override
  String get categoryHandwriting => 'Tulisan tangan';

  @override
  String get categoryCalligraphy => 'Kaligrafi';

  @override
  String get categoryTypography => 'Tipografi';

  @override
  String get categoryKids => 'Kanak-kanak';

  @override
  String get categoryMaterial => 'Bahan';

  @override
  String get noEmoji => 'Tiada emoji';

  @override
  String get saveAlignedImage => 'Simpan imej yang dijajarkan';

  @override
  String savedPath(String path) {
    return 'Disimpan: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Ralat: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Penjajaran grid — $file';
  }

  @override
  String get openAnotherImage => 'Buka imej lain';

  @override
  String get hideGrid => 'Sembunyikan grid';

  @override
  String get showGrid => 'Tunjukkan grid';

  @override
  String get resetGrid => 'Tetapkan semula grid';

  @override
  String get exportAlignedImage => 'Eksport imej yang dijajarkan';

  @override
  String get openTemplatePhoto => 'Buka foto templat yang telah anda isi';

  @override
  String get openImage => 'Buka imej';

  @override
  String get gridInstructions =>
      'Seret 4 penjuru supaya grid sepadan dengan foto,\nkemudian eksport imej dengan perspektif yang dibetulkan.';
}
