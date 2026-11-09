// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navTextEditor => 'Editor teks';

  @override
  String get navGridAlignment => 'Penyelarasan kisi';

  @override
  String get editorTitle => 'Teks tulisan tangan';

  @override
  String get packs => 'Paket';

  @override
  String get emojiForMessage => 'Emoji untuk pesan';

  @override
  String get saveToGallery => 'Simpan ke galeri';

  @override
  String get share => 'Bagikan';

  @override
  String get previewEmpty => 'Tulis sesuatu di bawah…';

  @override
  String get textHint => 'Tulis teksmu di sini…';

  @override
  String get advancedSettings => 'Pengaturan lanjutan';

  @override
  String get savedToGallery => 'Tersimpan di galeri!';

  @override
  String get saveFailed => 'Gagal menyimpan gambar';

  @override
  String get shareFailed => 'Gagal membagikan';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Font preset “$preset” tidak tersedia, menggunakan $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Preset';

  @override
  String get newPreset => 'Preset baru';

  @override
  String get renamePreset => 'Ganti nama preset';

  @override
  String get restorePurchases => 'Pulihkan pembelian';

  @override
  String get purchasesRestored => 'Pembelian dipulihkan.';

  @override
  String get packsIntro =>
      'Semua fitur aplikasi gratis. Paket menambahkan font dan preset baru.';

  @override
  String get owned => 'Dimiliki';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count font',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preset',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Pembelian menunggu persetujuan. Akan terbuka dengan sendirinya.';

  @override
  String get purchaseFailed => 'Pembelian gagal. Silakan coba lagi.';

  @override
  String get purchasesRestoredUnlocked =>
      'Pembelian dipulihkan. Semua yang kamu beli sudah terbuka.';

  @override
  String paywallPresets(String names) {
    return 'Preset: $names';
  }

  @override
  String get unlimitedPresets => 'Preset sendiri tanpa batas';

  @override
  String get buyOnce =>
      'Beli sekali, milikmu selamanya, juga di perangkat lain';

  @override
  String get allFeaturesFree => 'Semua fitur aplikasi tetap gratis';

  @override
  String get storeUnavailable => 'Toko sedang tidak tersedia. Coba lagi nanti.';

  @override
  String buyFor(String price) {
    return 'Beli seharga $price';
  }

  @override
  String get notForSale => 'Belum dijual';

  @override
  String get loadingPrice => 'Memuat harga…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: semua paket seharga $price';
  }

  @override
  String get save => 'Simpan';

  @override
  String get presetSaveTooltip =>
      'Simpan font dan gaya saat ini sebagai preset';

  @override
  String get presetSaveAsNew => 'Simpan yang sekarang sebagai preset baru';

  @override
  String get presetOverwrite => 'Timpa dengan pengaturan saat ini';

  @override
  String get rename => 'Ganti nama';

  @override
  String get delete => 'Hapus';

  @override
  String get presetName => 'Nama';

  @override
  String get cancel => 'Batal';

  @override
  String get deletePresetTitle => 'Hapus preset?';

  @override
  String deletePresetBody(String name) {
    return '“$name” akan dihapus. Teks di editor tetap ada.';
  }

  @override
  String get joinLetters => 'Sambung huruf';

  @override
  String get letterSpacing => 'Jarak huruf';

  @override
  String get baselineWobble => 'Gelombang baris';

  @override
  String get sizeVariance => 'Variasi ukuran';

  @override
  String get rotationVariance => 'Variasi kemiringan';

  @override
  String get opacityVariance => 'Variasi opasitas';

  @override
  String get categoryHandwriting => 'Tulisan tangan';

  @override
  String get categoryCalligraphy => 'Kaligrafi';

  @override
  String get categoryTypography => 'Tipografi';

  @override
  String get categoryKids => 'Anak-anak';

  @override
  String get categoryMaterial => 'Bahan';

  @override
  String get noEmoji => 'Tanpa emoji';

  @override
  String get saveAlignedImage => 'Simpan gambar yang diselaraskan';

  @override
  String savedPath(String path) {
    return 'Tersimpan: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Penyelarasan kisi — $file';
  }

  @override
  String get openAnotherImage => 'Buka gambar lain';

  @override
  String get hideGrid => 'Sembunyikan kisi';

  @override
  String get showGrid => 'Tampilkan kisi';

  @override
  String get resetGrid => 'Atur ulang kisi';

  @override
  String get exportAlignedImage => 'Ekspor gambar yang diselaraskan';

  @override
  String get openTemplatePhoto => 'Buka foto templat yang sudah kamu isi';

  @override
  String get openImage => 'Buka gambar';

  @override
  String get gridInstructions =>
      'Seret 4 sudut agar kisi pas dengan foto,\nlalu ekspor gambar dengan perspektif yang sudah dikoreksi.';
}
