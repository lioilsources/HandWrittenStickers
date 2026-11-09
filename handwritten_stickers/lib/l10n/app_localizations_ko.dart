// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navTextEditor => '텍스트 편집기';

  @override
  String get navGridAlignment => '격자 맞추기';

  @override
  String get editorTitle => '손글씨 텍스트';

  @override
  String get packs => '팩';

  @override
  String get emojiForMessage => '메시지 이모지';

  @override
  String get saveToGallery => '갤러리에 저장';

  @override
  String get share => '공유';

  @override
  String get previewEmpty => '아래에 뭔가 써 보세요…';

  @override
  String get textHint => '여기에 텍스트를 입력하세요…';

  @override
  String get advancedSettings => '고급 설정';

  @override
  String get savedToGallery => '갤러리에 저장했어요!';

  @override
  String get saveFailed => '이미지를 저장하지 못했어요';

  @override
  String get shareFailed => '공유하지 못했어요';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return '프리셋 ‘$preset’의 글꼴을 사용할 수 없어 $sheet을(를) 사용합니다.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => '프리셋';

  @override
  String get newPreset => '새 프리셋';

  @override
  String get renamePreset => '프리셋 이름 변경';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get purchasesRestored => '구매를 복원했어요.';

  @override
  String get packsIntro => '앱의 모든 기능은 무료예요. 팩을 사면 글꼴과 프리셋이 더 늘어나요.';

  @override
  String get owned => '보유 중';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '글꼴 $count개',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '프리셋 $count개',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending => '구매 승인을 기다리는 중이에요. 승인되면 자동으로 잠금이 풀려요.';

  @override
  String get purchaseFailed => '구매하지 못했어요. 다시 시도해 주세요.';

  @override
  String get purchasesRestoredUnlocked => '구매를 복원했어요. 구매한 항목은 모두 잠금 해제됐어요.';

  @override
  String paywallPresets(String names) {
    return '프리셋: $names';
  }

  @override
  String get unlimitedPresets => '나만의 프리셋 무제한';

  @override
  String get buyOnce => '한 번 사면 평생, 다른 기기에서도 사용';

  @override
  String get allFeaturesFree => '앱의 모든 기능은 계속 무료';

  @override
  String get storeUnavailable => '지금은 스토어를 사용할 수 없어요. 나중에 다시 시도해 주세요.';

  @override
  String buyFor(String price) {
    return '$price에 구매';
  }

  @override
  String get notForSale => '아직 판매하지 않아요';

  @override
  String get loadingPrice => '가격 불러오는 중…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: 모든 팩 $price';
  }

  @override
  String get save => '저장';

  @override
  String get presetSaveTooltip => '현재 글꼴과 스타일을 프리셋으로 저장';

  @override
  String get presetSaveAsNew => '현재 설정을 새 프리셋으로 저장';

  @override
  String get presetOverwrite => '현재 설정으로 덮어쓰기';

  @override
  String get rename => '이름 변경';

  @override
  String get delete => '삭제';

  @override
  String get presetName => '이름';

  @override
  String get cancel => '취소';

  @override
  String get deletePresetTitle => '프리셋을 삭제할까요?';

  @override
  String deletePresetBody(String name) {
    return '‘$name’이(가) 삭제돼요. 편집기의 텍스트는 그대로예요.';
  }

  @override
  String get joinLetters => '글자 잇기';

  @override
  String get letterSpacing => '글자 간격';

  @override
  String get baselineWobble => '줄 흔들림';

  @override
  String get sizeVariance => '크기 변화';

  @override
  String get rotationVariance => '기울기 변화';

  @override
  String get opacityVariance => '진하기 변화';

  @override
  String get categoryHandwriting => '손글씨';

  @override
  String get categoryCalligraphy => '캘리그래피';

  @override
  String get categoryTypography => '타이포그래피';

  @override
  String get categoryKids => '어린이';

  @override
  String get categoryMaterial => '재료';

  @override
  String get noEmoji => '이모지 없음';

  @override
  String get saveAlignedImage => '맞춘 이미지 저장';

  @override
  String savedPath(String path) {
    return '저장됨: $path';
  }

  @override
  String errorMessage(String error) {
    return '오류: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return '격자 맞추기 — $file';
  }

  @override
  String get openAnotherImage => '다른 이미지 열기';

  @override
  String get hideGrid => '격자 숨기기';

  @override
  String get showGrid => '격자 보기';

  @override
  String get resetGrid => '격자 초기화';

  @override
  String get exportAlignedImage => '맞춘 이미지 내보내기';

  @override
  String get openTemplatePhoto => '손으로 채운 템플릿 사진을 열어 주세요';

  @override
  String get openImage => '이미지 열기';

  @override
  String get gridInstructions => '네 모서리를 끌어 격자를 사진에 맞춘 다음\n원근을 보정한 이미지를 내보내세요.';
}
