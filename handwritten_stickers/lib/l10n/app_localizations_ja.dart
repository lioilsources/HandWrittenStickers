// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get navTextEditor => 'テキストエディタ';

  @override
  String get navGridAlignment => 'グリッド調整';

  @override
  String get editorTitle => '手書きテキスト';

  @override
  String get packs => 'パック';

  @override
  String get emojiForMessage => 'メッセージに絵文字';

  @override
  String get saveToGallery => 'ギャラリーに保存';

  @override
  String get share => '共有';

  @override
  String get previewEmpty => '下に何か書いてみよう…';

  @override
  String get textHint => 'ここにテキストを入力…';

  @override
  String get advancedSettings => '詳細設定';

  @override
  String get savedToGallery => 'ギャラリーに保存しました！';

  @override
  String get saveFailed => '画像を保存できませんでした';

  @override
  String get shareFailed => '共有できませんでした';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'プリセット「$preset」のフォントは使用できないため、$sheet を使用します。';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'プリセット';

  @override
  String get newPreset => '新しいプリセット';

  @override
  String get renamePreset => 'プリセット名を変更';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get purchasesRestored => '購入を復元しました。';

  @override
  String get packsIntro => 'アプリの機能はすべて無料です。パックでフォントとプリセットが増えます。';

  @override
  String get owned => '購入済み';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 書体',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count プリセット',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => '購入は承認待ちです。承認されると自動でロックが解除されます。';

  @override
  String get purchaseFailed => '購入できませんでした。もう一度お試しください。';

  @override
  String get purchasesRestoredUnlocked => '購入を復元しました。購入済みのものはすべて使えます。';

  @override
  String paywallPresets(String names) {
    return 'プリセット：$names';
  }

  @override
  String get unlimitedPresets => '自分のプリセットを無制限に';

  @override
  String get buyOnce => '一度買えばずっと使えて、ほかのデバイスでも使えます';

  @override
  String get allFeaturesFree => 'アプリの機能はすべて無料のまま';

  @override
  String get storeUnavailable => '現在ストアを利用できません。後でもう一度お試しください。';

  @override
  String buyFor(String price) {
    return '$price で購入';
  }

  @override
  String get notForSale => 'まだ販売されていません';

  @override
  String get loadingPrice => '価格を読み込み中…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle：全パックを $price で';
  }

  @override
  String get save => '保存';

  @override
  String get presetSaveTooltip => '現在のフォントとスタイルをプリセットとして保存';

  @override
  String get presetSaveAsNew => '現在の設定を新しいプリセットとして保存';

  @override
  String get presetOverwrite => '現在の設定で上書き';

  @override
  String get rename => '名前を変更';

  @override
  String get delete => '削除';

  @override
  String get presetName => '名前';

  @override
  String get cancel => 'キャンセル';

  @override
  String get deletePresetTitle => 'プリセットを削除しますか？';

  @override
  String deletePresetBody(String name) {
    return '「$name」を削除します。エディタのテキストは残ります。';
  }

  @override
  String get joinLetters => '文字をつなげる';

  @override
  String get letterSpacing => '文字間隔';

  @override
  String get baselineWobble => '行の揺れ';

  @override
  String get sizeVariance => 'サイズの揺れ';

  @override
  String get rotationVariance => '傾きの揺れ';

  @override
  String get opacityVariance => '濃さの揺れ';

  @override
  String get categoryHandwriting => '手書き';

  @override
  String get categoryCalligraphy => 'カリグラフィー';

  @override
  String get categoryTypography => 'タイポグラフィ';

  @override
  String get categoryKids => 'キッズ';

  @override
  String get categoryMaterial => '素材';

  @override
  String get noEmoji => '絵文字なし';

  @override
  String get saveAlignedImage => '調整した画像を保存';

  @override
  String savedPath(String path) {
    return '保存しました：$path';
  }

  @override
  String errorMessage(String error) {
    return 'エラー：$error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'グリッド調整 — $file';
  }

  @override
  String get openAnotherImage => '別の画像を開く';

  @override
  String get hideGrid => 'グリッドを隠す';

  @override
  String get showGrid => 'グリッドを表示';

  @override
  String get resetGrid => 'グリッドをリセット';

  @override
  String get exportAlignedImage => '調整した画像を書き出す';

  @override
  String get openTemplatePhoto => '記入したテンプレートの写真を開いてください';

  @override
  String get openImage => '画像を開く';

  @override
  String get gridInstructions => '4つの角をドラッグしてグリッドを写真に合わせ、\n遠近を補正した画像を書き出します。';
}
