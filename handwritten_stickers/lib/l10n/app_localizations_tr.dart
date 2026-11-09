// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get navTextEditor => 'Metin düzenleyici';

  @override
  String get navGridAlignment => 'Izgara hizalama';

  @override
  String get editorTitle => 'El yazısı metin';

  @override
  String get packs => 'Paketler';

  @override
  String get emojiForMessage => 'Mesaj için emoji';

  @override
  String get saveToGallery => 'Galeriye kaydet';

  @override
  String get share => 'Paylaş';

  @override
  String get previewEmpty => 'Aşağıya bir şey yaz…';

  @override
  String get textHint => 'Metnini buraya yaz…';

  @override
  String get advancedSettings => 'Gelişmiş ayarlar';

  @override
  String get savedToGallery => 'Galeriye kaydedildi!';

  @override
  String get saveFailed => 'Görsel kaydedilemedi';

  @override
  String get shareFailed => 'Paylaşım başarısız oldu';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return '“$preset” ön ayarının yazı tipi kullanılamıyor, $sheet kullanılıyor.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Ön ayar';

  @override
  String get newPreset => 'Yeni ön ayar';

  @override
  String get renamePreset => 'Ön ayarı yeniden adlandır';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get purchasesRestored => 'Satın alımlar geri yüklendi.';

  @override
  String get packsIntro =>
      'Uygulamanın tüm özellikleri ücretsizdir. Paketler yeni yazı tipleri ve ön ayarlar ekler.';

  @override
  String get owned => 'Satın alındı';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yazı tipi',
      one: '$count yazı tipi',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ön ayar',
      one: '$count ön ayar',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Satın alma onay bekliyor. Kilidi kendiliğinden açılacak.';

  @override
  String get purchaseFailed => 'Satın alma başarısız oldu. Lütfen tekrar dene.';

  @override
  String get purchasesRestoredUnlocked =>
      'Satın alımlar geri yüklendi. Aldığın her şeyin kilidi açık.';

  @override
  String paywallPresets(String names) {
    return 'Ön ayarlar: $names';
  }

  @override
  String get unlimitedPresets => 'Sınırsız kendi ön ayarın';

  @override
  String get buyOnce => 'Bir kez al, sonsuza dek senin, diğer cihazlarında da';

  @override
  String get allFeaturesFree => 'Uygulamanın tüm özellikleri ücretsiz kalır';

  @override
  String get storeUnavailable =>
      'Mağaza şu anda kullanılamıyor. Daha sonra tekrar dene.';

  @override
  String buyFor(String price) {
    return '$price karşılığında al';
  }

  @override
  String get notForSale => 'Henüz satışta değil';

  @override
  String get loadingPrice => 'Fiyat yükleniyor…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: tüm paketler $price';
  }

  @override
  String get save => 'Kaydet';

  @override
  String get presetSaveTooltip =>
      'Geçerli yazı tipini ve stili ön ayar olarak kaydet';

  @override
  String get presetSaveAsNew => 'Geçerli ayarı yeni ön ayar olarak kaydet';

  @override
  String get presetOverwrite => 'Geçerli ayarlarla üzerine yaz';

  @override
  String get rename => 'Yeniden adlandır';

  @override
  String get delete => 'Sil';

  @override
  String get presetName => 'Ad';

  @override
  String get cancel => 'İptal';

  @override
  String get deletePresetTitle => 'Ön ayar silinsin mi?';

  @override
  String deletePresetBody(String name) {
    return '“$name” silinecek. Düzenleyicideki metin kalır.';
  }

  @override
  String get joinLetters => 'Harfleri birleştir';

  @override
  String get letterSpacing => 'Harf aralığı';

  @override
  String get baselineWobble => 'Satır dalgalanması';

  @override
  String get sizeVariance => 'Boyut değişkenliği';

  @override
  String get rotationVariance => 'Eğim değişkenliği';

  @override
  String get opacityVariance => 'Opaklık değişkenliği';

  @override
  String get categoryHandwriting => 'El yazısı';

  @override
  String get categoryCalligraphy => 'Kaligrafi';

  @override
  String get categoryTypography => 'Tipografi';

  @override
  String get categoryKids => 'Çocuklar';

  @override
  String get categoryMaterial => 'Malzemeler';

  @override
  String get noEmoji => 'Emoji yok';

  @override
  String get saveAlignedImage => 'Hizalanmış görseli kaydet';

  @override
  String savedPath(String path) {
    return 'Kaydedildi: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Hata: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Izgara hizalama — $file';
  }

  @override
  String get openAnotherImage => 'Başka görsel aç';

  @override
  String get hideGrid => 'Izgarayı gizle';

  @override
  String get showGrid => 'Izgarayı göster';

  @override
  String get resetGrid => 'Izgarayı sıfırla';

  @override
  String get exportAlignedImage => 'Hizalanmış görseli dışa aktar';

  @override
  String get openTemplatePhoto => 'Doldurduğun şablonun fotoğrafını aç';

  @override
  String get openImage => 'Görsel aç';

  @override
  String get gridInstructions =>
      'Izgara fotoğrafa otursun diye 4 köşeyi sürükle,\nsonra perspektifi düzeltilmiş görseli dışa aktar.';
}
