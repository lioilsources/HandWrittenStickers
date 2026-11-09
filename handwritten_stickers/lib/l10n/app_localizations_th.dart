// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get navTextEditor => 'ตัวแก้ไขข้อความ';

  @override
  String get navGridAlignment => 'จัดตาราง';

  @override
  String get editorTitle => 'ข้อความลายมือ';

  @override
  String get packs => 'แพ็ก';

  @override
  String get emojiForMessage => 'อีโมจิสำหรับข้อความ';

  @override
  String get saveToGallery => 'บันทึกลงคลังภาพ';

  @override
  String get share => 'แชร์';

  @override
  String get previewEmpty => 'ลองเขียนอะไรสักอย่างด้านล่าง…';

  @override
  String get textHint => 'พิมพ์ข้อความของคุณที่นี่…';

  @override
  String get advancedSettings => 'การตั้งค่าขั้นสูง';

  @override
  String get savedToGallery => 'บันทึกลงคลังภาพแล้ว!';

  @override
  String get saveFailed => 'บันทึกรูปภาพไม่สำเร็จ';

  @override
  String get shareFailed => 'แชร์ไม่สำเร็จ';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'ฟอนต์ของพรีเซ็ต “$preset” ใช้ไม่ได้ จึงใช้ $sheet แทน';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'พรีเซ็ต';

  @override
  String get newPreset => 'พรีเซ็ตใหม่';

  @override
  String get renamePreset => 'เปลี่ยนชื่อพรีเซ็ต';

  @override
  String get restorePurchases => 'กู้คืนการซื้อ';

  @override
  String get purchasesRestored => 'กู้คืนการซื้อแล้ว';

  @override
  String get packsIntro =>
      'ทุกฟีเจอร์ของแอปใช้ฟรี แพ็กจะเพิ่มฟอนต์และพรีเซ็ตให้มากขึ้น';

  @override
  String get owned => 'เป็นเจ้าของแล้ว';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ฟอนต์',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count พรีเซ็ต',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => 'การซื้อกำลังรออนุมัติ แล้วจะปลดล็อกเอง';

  @override
  String get purchaseFailed => 'ซื้อไม่สำเร็จ โปรดลองอีกครั้ง';

  @override
  String get purchasesRestoredUnlocked =>
      'กู้คืนการซื้อแล้ว ทุกอย่างที่คุณซื้อปลดล็อกแล้ว';

  @override
  String paywallPresets(String names) {
    return 'พรีเซ็ต: $names';
  }

  @override
  String get unlimitedPresets => 'พรีเซ็ตของคุณเองไม่จำกัด';

  @override
  String get buyOnce => 'ซื้อครั้งเดียว ใช้ได้ตลอดไป บนอุปกรณ์อื่นด้วย';

  @override
  String get allFeaturesFree => 'ทุกฟีเจอร์ของแอปยังคงฟรี';

  @override
  String get storeUnavailable =>
      'ร้านค้าไม่พร้อมใช้งานในตอนนี้ โปรดลองใหม่ภายหลัง';

  @override
  String buyFor(String price) {
    return 'ซื้อในราคา $price';
  }

  @override
  String get notForSale => 'ยังไม่เปิดขาย';

  @override
  String get loadingPrice => 'กำลังโหลดราคา…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: ทุกแพ็กในราคา $price';
  }

  @override
  String get save => 'บันทึก';

  @override
  String get presetSaveTooltip => 'บันทึกฟอนต์และสไตล์ปัจจุบันเป็นพรีเซ็ต';

  @override
  String get presetSaveAsNew => 'บันทึกค่าปัจจุบันเป็นพรีเซ็ตใหม่';

  @override
  String get presetOverwrite => 'เขียนทับด้วยการตั้งค่าปัจจุบัน';

  @override
  String get rename => 'เปลี่ยนชื่อ';

  @override
  String get delete => 'ลบ';

  @override
  String get presetName => 'ชื่อ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get deletePresetTitle => 'ลบพรีเซ็ตไหม';

  @override
  String deletePresetBody(String name) {
    return '“$name” จะถูกลบ ข้อความในตัวแก้ไขยังอยู่';
  }

  @override
  String get joinLetters => 'เชื่อมตัวอักษร';

  @override
  String get letterSpacing => 'ระยะห่างตัวอักษร';

  @override
  String get baselineWobble => 'ความโยกของบรรทัด';

  @override
  String get sizeVariance => 'ความต่างของขนาด';

  @override
  String get rotationVariance => 'ความต่างของความเอียง';

  @override
  String get opacityVariance => 'ความต่างของความเข้ม';

  @override
  String get categoryHandwriting => 'ลายมือ';

  @override
  String get categoryCalligraphy => 'อักษรวิจิตร';

  @override
  String get categoryTypography => 'ตัวพิมพ์';

  @override
  String get categoryKids => 'เด็ก';

  @override
  String get categoryMaterial => 'วัสดุ';

  @override
  String get noEmoji => 'ไม่มีอีโมจิ';

  @override
  String get saveAlignedImage => 'บันทึกรูปที่จัดแล้ว';

  @override
  String savedPath(String path) {
    return 'บันทึกแล้ว: $path';
  }

  @override
  String errorMessage(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'จัดตาราง — $file';
  }

  @override
  String get openAnotherImage => 'เปิดรูปอื่น';

  @override
  String get hideGrid => 'ซ่อนตาราง';

  @override
  String get showGrid => 'แสดงตาราง';

  @override
  String get resetGrid => 'รีเซ็ตตาราง';

  @override
  String get exportAlignedImage => 'ส่งออกรูปที่จัดแล้ว';

  @override
  String get openTemplatePhoto => 'เปิดรูปถ่ายแม่แบบที่คุณเขียนด้วยลายมือ';

  @override
  String get openImage => 'เปิดรูป';

  @override
  String get gridInstructions =>
      'ลากมุมทั้ง 4 ให้ตารางพอดีกับรูป\nแล้วส่งออกรูปที่แก้มุมมองแล้ว';
}
