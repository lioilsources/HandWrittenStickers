// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get navTextEditor => 'Trình soạn văn bản';

  @override
  String get navGridAlignment => 'Căn lưới';

  @override
  String get editorTitle => 'Chữ viết tay';

  @override
  String get packs => 'Gói';

  @override
  String get emojiForMessage => 'Emoji cho tin nhắn';

  @override
  String get saveToGallery => 'Lưu vào thư viện';

  @override
  String get share => 'Chia sẻ';

  @override
  String get previewEmpty => 'Hãy viết gì đó bên dưới…';

  @override
  String get textHint => 'Nhập văn bản của bạn tại đây…';

  @override
  String get advancedSettings => 'Cài đặt nâng cao';

  @override
  String get savedToGallery => 'Đã lưu vào thư viện!';

  @override
  String get saveFailed => 'Không lưu được ảnh';

  @override
  String get shareFailed => 'Chia sẻ thất bại';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'Phông chữ của mẫu “$preset” không có sẵn, đang dùng $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Mẫu';

  @override
  String get newPreset => 'Mẫu mới';

  @override
  String get renamePreset => 'Đổi tên mẫu';

  @override
  String get restorePurchases => 'Khôi phục giao dịch mua';

  @override
  String get purchasesRestored => 'Đã khôi phục giao dịch mua.';

  @override
  String get packsIntro =>
      'Mọi tính năng của ứng dụng đều miễn phí. Các gói thêm phông chữ và mẫu mới.';

  @override
  String get owned => 'Đã sở hữu';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phông chữ',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mẫu',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'Giao dịch đang chờ phê duyệt. Nội dung sẽ tự mở khóa.';

  @override
  String get purchaseFailed => 'Mua không thành công. Vui lòng thử lại.';

  @override
  String get purchasesRestoredUnlocked =>
      'Đã khôi phục giao dịch mua. Mọi thứ bạn đã mua đều được mở khóa.';

  @override
  String paywallPresets(String names) {
    return 'Mẫu: $names';
  }

  @override
  String get unlimitedPresets => 'Không giới hạn mẫu của riêng bạn';

  @override
  String get buyOnce => 'Mua một lần, dùng mãi mãi, cả trên các thiết bị khác';

  @override
  String get allFeaturesFree => 'Mọi tính năng của ứng dụng vẫn miễn phí';

  @override
  String get storeUnavailable =>
      'Cửa hàng hiện không khả dụng. Hãy thử lại sau.';

  @override
  String buyFor(String price) {
    return 'Mua với giá $price';
  }

  @override
  String get notForSale => 'Chưa được bán';

  @override
  String get loadingPrice => 'Đang tải giá…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: tất cả các gói với giá $price';
  }

  @override
  String get save => 'Lưu';

  @override
  String get presetSaveTooltip => 'Lưu phông chữ và kiểu hiện tại thành mẫu';

  @override
  String get presetSaveAsNew => 'Lưu hiện tại thành mẫu mới';

  @override
  String get presetOverwrite => 'Ghi đè bằng cài đặt hiện tại';

  @override
  String get rename => 'Đổi tên';

  @override
  String get delete => 'Xóa';

  @override
  String get presetName => 'Tên';

  @override
  String get cancel => 'Hủy';

  @override
  String get deletePresetTitle => 'Xóa mẫu?';

  @override
  String deletePresetBody(String name) {
    return '“$name” sẽ bị xóa. Văn bản trong trình soạn vẫn giữ nguyên.';
  }

  @override
  String get joinLetters => 'Nối chữ';

  @override
  String get letterSpacing => 'Khoảng cách chữ';

  @override
  String get baselineWobble => 'Độ gợn dòng';

  @override
  String get sizeVariance => 'Dao động kích thước';

  @override
  String get rotationVariance => 'Dao động độ nghiêng';

  @override
  String get opacityVariance => 'Dao động độ đậm';

  @override
  String get categoryHandwriting => 'Chữ viết tay';

  @override
  String get categoryCalligraphy => 'Thư pháp';

  @override
  String get categoryTypography => 'Kiểu chữ in';

  @override
  String get categoryKids => 'Trẻ em';

  @override
  String get categoryMaterial => 'Chất liệu';

  @override
  String get noEmoji => 'Không emoji';

  @override
  String get saveAlignedImage => 'Lưu ảnh đã căn';

  @override
  String savedPath(String path) {
    return 'Đã lưu: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Lỗi: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Căn lưới — $file';
  }

  @override
  String get openAnotherImage => 'Mở ảnh khác';

  @override
  String get hideGrid => 'Ẩn lưới';

  @override
  String get showGrid => 'Hiện lưới';

  @override
  String get resetGrid => 'Đặt lại lưới';

  @override
  String get exportAlignedImage => 'Xuất ảnh đã căn';

  @override
  String get openTemplatePhoto => 'Mở ảnh chụp mẫu bạn đã viết tay';

  @override
  String get openImage => 'Mở ảnh';

  @override
  String get gridInstructions =>
      'Kéo 4 góc để lưới khớp với ảnh,\nrồi xuất ảnh đã chỉnh phối cảnh.';
}
