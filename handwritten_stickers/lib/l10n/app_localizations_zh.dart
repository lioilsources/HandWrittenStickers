// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navTextEditor => '文本编辑器';

  @override
  String get navGridAlignment => '网格对齐';

  @override
  String get editorTitle => '手写文字';

  @override
  String get packs => '扩展包';

  @override
  String get emojiForMessage => '消息表情';

  @override
  String get saveToGallery => '保存到相册';

  @override
  String get share => '分享';

  @override
  String get previewEmpty => '在下方写点什么…';

  @override
  String get textHint => '在此输入文字…';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get savedToGallery => '已保存到相册！';

  @override
  String get saveFailed => '无法保存图片';

  @override
  String get shareFailed => '分享失败';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return '预设“$preset”的字体不可用，已改用 $sheet。';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => '预设';

  @override
  String get newPreset => '新建预设';

  @override
  String get renamePreset => '重命名预设';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get purchasesRestored => '已恢复购买。';

  @override
  String get packsIntro => '应用的所有功能都免费。扩展包会增加更多字体和预设。';

  @override
  String get owned => '已拥有';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 款字体',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个预设',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => '购买正在等待批准，批准后会自动解锁。';

  @override
  String get purchaseFailed => '购买失败，请重试。';

  @override
  String get purchasesRestoredUnlocked => '已恢复购买。你买过的内容都已解锁。';

  @override
  String paywallPresets(String names) {
    return '预设：$names';
  }

  @override
  String get unlimitedPresets => '无限量自定义预设';

  @override
  String get buyOnce => '一次购买，永久拥有，其他设备也能用';

  @override
  String get allFeaturesFree => '应用的所有功能依然免费';

  @override
  String get storeUnavailable => '商店暂时不可用，请稍后再试。';

  @override
  String buyFor(String price) {
    return '以 $price 购买';
  }

  @override
  String get notForSale => '尚未开售';

  @override
  String get loadingPrice => '正在加载价格…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle：全部扩展包 $price';
  }

  @override
  String get save => '保存';

  @override
  String get presetSaveTooltip => '将当前字体和样式保存为预设';

  @override
  String get presetSaveAsNew => '将当前设置保存为新预设';

  @override
  String get presetOverwrite => '用当前设置覆盖';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get presetName => '名称';

  @override
  String get cancel => '取消';

  @override
  String get deletePresetTitle => '删除预设？';

  @override
  String deletePresetBody(String name) {
    return '“$name”将被删除。编辑器中的文字会保留。';
  }

  @override
  String get joinLetters => '连笔';

  @override
  String get letterSpacing => '字距';

  @override
  String get baselineWobble => '行抖动';

  @override
  String get sizeVariance => '大小变化';

  @override
  String get rotationVariance => '倾斜变化';

  @override
  String get opacityVariance => '浓淡变化';

  @override
  String get categoryHandwriting => '手写';

  @override
  String get categoryCalligraphy => '书法';

  @override
  String get categoryTypography => '印刷体';

  @override
  String get categoryKids => '儿童';

  @override
  String get categoryMaterial => '材质';

  @override
  String get noEmoji => '不加表情';

  @override
  String get saveAlignedImage => '保存对齐后的图片';

  @override
  String savedPath(String path) {
    return '已保存：$path';
  }

  @override
  String errorMessage(String error) {
    return '错误：$error';
  }

  @override
  String gridAlignmentFile(String file) {
    return '网格对齐 — $file';
  }

  @override
  String get openAnotherImage => '打开其他图片';

  @override
  String get hideGrid => '隐藏网格';

  @override
  String get showGrid => '显示网格';

  @override
  String get resetGrid => '重置网格';

  @override
  String get exportAlignedImage => '导出对齐后的图片';

  @override
  String get openTemplatePhoto => '打开你手写填好的模板照片';

  @override
  String get openImage => '打开图片';

  @override
  String get gridInstructions => '拖动 4 个角让网格贴合照片，\n然后导出校正透视后的图片。';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get navTextEditor => '文本编辑器';

  @override
  String get navGridAlignment => '网格对齐';

  @override
  String get editorTitle => '手写文字';

  @override
  String get packs => '扩展包';

  @override
  String get emojiForMessage => '消息表情';

  @override
  String get saveToGallery => '保存到相册';

  @override
  String get share => '分享';

  @override
  String get previewEmpty => '在下方写点什么…';

  @override
  String get textHint => '在此输入文字…';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get savedToGallery => '已保存到相册！';

  @override
  String get saveFailed => '无法保存图片';

  @override
  String get shareFailed => '分享失败';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return '预设“$preset”的字体不可用，已改用 $sheet。';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => '预设';

  @override
  String get newPreset => '新建预设';

  @override
  String get renamePreset => '重命名预设';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get purchasesRestored => '已恢复购买。';

  @override
  String get packsIntro => '应用的所有功能都免费。扩展包会增加更多字体和预设。';

  @override
  String get owned => '已拥有';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 款字体',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个预设',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => '购买正在等待批准，批准后会自动解锁。';

  @override
  String get purchaseFailed => '购买失败，请重试。';

  @override
  String get purchasesRestoredUnlocked => '已恢复购买。你买过的内容都已解锁。';

  @override
  String paywallPresets(String names) {
    return '预设：$names';
  }

  @override
  String get unlimitedPresets => '无限量自定义预设';

  @override
  String get buyOnce => '一次购买，永久拥有，其他设备也能用';

  @override
  String get allFeaturesFree => '应用的所有功能依然免费';

  @override
  String get storeUnavailable => '商店暂时不可用，请稍后再试。';

  @override
  String buyFor(String price) {
    return '以 $price 购买';
  }

  @override
  String get notForSale => '尚未开售';

  @override
  String get loadingPrice => '正在加载价格…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle：全部扩展包 $price';
  }

  @override
  String get save => '保存';

  @override
  String get presetSaveTooltip => '将当前字体和样式保存为预设';

  @override
  String get presetSaveAsNew => '将当前设置保存为新预设';

  @override
  String get presetOverwrite => '用当前设置覆盖';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get presetName => '名称';

  @override
  String get cancel => '取消';

  @override
  String get deletePresetTitle => '删除预设？';

  @override
  String deletePresetBody(String name) {
    return '“$name”将被删除。编辑器中的文字会保留。';
  }

  @override
  String get joinLetters => '连笔';

  @override
  String get letterSpacing => '字距';

  @override
  String get baselineWobble => '行抖动';

  @override
  String get sizeVariance => '大小变化';

  @override
  String get rotationVariance => '倾斜变化';

  @override
  String get opacityVariance => '浓淡变化';

  @override
  String get categoryHandwriting => '手写';

  @override
  String get categoryCalligraphy => '书法';

  @override
  String get categoryTypography => '印刷体';

  @override
  String get categoryKids => '儿童';

  @override
  String get categoryMaterial => '材质';

  @override
  String get noEmoji => '不加表情';

  @override
  String get saveAlignedImage => '保存对齐后的图片';

  @override
  String savedPath(String path) {
    return '已保存：$path';
  }

  @override
  String errorMessage(String error) {
    return '错误：$error';
  }

  @override
  String gridAlignmentFile(String file) {
    return '网格对齐 — $file';
  }

  @override
  String get openAnotherImage => '打开其他图片';

  @override
  String get hideGrid => '隐藏网格';

  @override
  String get showGrid => '显示网格';

  @override
  String get resetGrid => '重置网格';

  @override
  String get exportAlignedImage => '导出对齐后的图片';

  @override
  String get openTemplatePhoto => '打开你手写填好的模板照片';

  @override
  String get openImage => '打开图片';

  @override
  String get gridInstructions => '拖动 4 个角让网格贴合照片，\n然后导出校正透视后的图片。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get navTextEditor => '文字編輯器';

  @override
  String get navGridAlignment => '格線對齊';

  @override
  String get editorTitle => '手寫文字';

  @override
  String get packs => '擴充包';

  @override
  String get emojiForMessage => '訊息表情符號';

  @override
  String get saveToGallery => '儲存到相簿';

  @override
  String get share => '分享';

  @override
  String get previewEmpty => '在下方寫點什麼…';

  @override
  String get textHint => '在此輸入文字…';

  @override
  String get advancedSettings => '進階設定';

  @override
  String get savedToGallery => '已儲存到相簿！';

  @override
  String get saveFailed => '無法儲存圖片';

  @override
  String get shareFailed => '分享失敗';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return '預設組合「$preset」的字型無法使用，已改用 $sheet。';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => '預設組合';

  @override
  String get newPreset => '新增預設組合';

  @override
  String get renamePreset => '重新命名預設組合';

  @override
  String get restorePurchases => '恢復購買';

  @override
  String get purchasesRestored => '已恢復購買。';

  @override
  String get packsIntro => 'App 的所有功能都免費。擴充包會增加更多字型和預設組合。';

  @override
  String get owned => '已擁有';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 款字型',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個預設組合',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => '購買正在等待核准，核准後會自動解鎖。';

  @override
  String get purchaseFailed => '購買失敗，請再試一次。';

  @override
  String get purchasesRestoredUnlocked => '已恢復購買。你買過的內容都已解鎖。';

  @override
  String paywallPresets(String names) {
    return '預設組合：$names';
  }

  @override
  String get unlimitedPresets => '無限量自訂預設組合';

  @override
  String get buyOnce => '一次購買，永久擁有，其他裝置也能用';

  @override
  String get allFeaturesFree => 'App 的所有功能依然免費';

  @override
  String get storeUnavailable => '商店目前無法使用，請稍後再試。';

  @override
  String buyFor(String price) {
    return '以 $price 購買';
  }

  @override
  String get notForSale => '尚未開賣';

  @override
  String get loadingPrice => '正在載入價格…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle：全部擴充包 $price';
  }

  @override
  String get save => '儲存';

  @override
  String get presetSaveTooltip => '將目前的字型和樣式儲存為預設組合';

  @override
  String get presetSaveAsNew => '將目前設定儲存為新的預設組合';

  @override
  String get presetOverwrite => '以目前設定覆寫';

  @override
  String get rename => '重新命名';

  @override
  String get delete => '刪除';

  @override
  String get presetName => '名稱';

  @override
  String get cancel => '取消';

  @override
  String get deletePresetTitle => '刪除預設組合？';

  @override
  String deletePresetBody(String name) {
    return '「$name」將被刪除。編輯器中的文字會保留。';
  }

  @override
  String get joinLetters => '連筆';

  @override
  String get letterSpacing => '字距';

  @override
  String get baselineWobble => '行抖動';

  @override
  String get sizeVariance => '大小變化';

  @override
  String get rotationVariance => '傾斜變化';

  @override
  String get opacityVariance => '濃淡變化';

  @override
  String get categoryHandwriting => '手寫';

  @override
  String get categoryCalligraphy => '書法';

  @override
  String get categoryTypography => '印刷體';

  @override
  String get categoryKids => '兒童';

  @override
  String get categoryMaterial => '材質';

  @override
  String get noEmoji => '不加表情符號';

  @override
  String get saveAlignedImage => '儲存對齊後的圖片';

  @override
  String savedPath(String path) {
    return '已儲存：$path';
  }

  @override
  String errorMessage(String error) {
    return '錯誤：$error';
  }

  @override
  String gridAlignmentFile(String file) {
    return '格線對齊 — $file';
  }

  @override
  String get openAnotherImage => '開啟其他圖片';

  @override
  String get hideGrid => '隱藏格線';

  @override
  String get showGrid => '顯示格線';

  @override
  String get resetGrid => '重設格線';

  @override
  String get exportAlignedImage => '匯出對齊後的圖片';

  @override
  String get openTemplatePhoto => '開啟你手寫填好的範本照片';

  @override
  String get openImage => '開啟圖片';

  @override
  String get gridInstructions => '拖曳 4 個角讓格線貼合照片，\n然後匯出校正透視後的圖片。';
}
