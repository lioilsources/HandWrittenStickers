// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navTextEditor => 'Editor de texto';

  @override
  String get navGridAlignment => 'Alinhar grade';

  @override
  String get editorTitle => 'Texto manuscrito';

  @override
  String get packs => 'Pacotes';

  @override
  String get emojiForMessage => 'Emoji da mensagem';

  @override
  String get saveToGallery => 'Salvar na galeria';

  @override
  String get share => 'Compartilhar';

  @override
  String get previewEmpty => 'Escreva algo abaixo…';

  @override
  String get textHint => 'Escreva seu texto aqui…';

  @override
  String get advancedSettings => 'Configurações avançadas';

  @override
  String get savedToGallery => 'Salvo na galeria!';

  @override
  String get saveFailed => 'Não foi possível salvar a imagem';

  @override
  String get shareFailed => 'Falha ao compartilhar';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'A fonte da predefinição “$preset” não está disponível; usando $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Predefinição';

  @override
  String get newPreset => 'Nova predefinição';

  @override
  String get renamePreset => 'Renomear predefinição';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get packsIntro =>
      'Todos os recursos do app são gratuitos. Os pacotes adicionam mais fontes e predefinições.';

  @override
  String get owned => 'Comprado';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fontes',
      many: '$count fontes',
      one: '$count fonte',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições',
      many: '$count predefinições',
      one: '$count predefinição',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'A compra está aguardando aprovação. Ela será liberada sozinha.';

  @override
  String get purchaseFailed => 'A compra não deu certo. Tente de novo.';

  @override
  String get purchasesRestoredUnlocked =>
      'Compras restauradas. Tudo o que você comprou está liberado.';

  @override
  String paywallPresets(String names) {
    return 'Predefinições: $names';
  }

  @override
  String get unlimitedPresets => 'Predefinições próprias ilimitadas';

  @override
  String get buyOnce =>
      'Compre uma vez e é seu para sempre, também nos seus outros aparelhos';

  @override
  String get allFeaturesFree => 'Todos os recursos do app continuam gratuitos';

  @override
  String get storeUnavailable =>
      'A loja não está disponível agora. Tente mais tarde.';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get notForSale => 'Ainda não está à venda';

  @override
  String get loadingPrice => 'Carregando preço…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: todos os pacotes por $price';
  }

  @override
  String get save => 'Salvar';

  @override
  String get presetSaveTooltip =>
      'Salvar a fonte e o estilo atuais como predefinição';

  @override
  String get presetSaveAsNew => 'Salvar o atual como nova predefinição';

  @override
  String get presetOverwrite => 'Substituir pelas configurações atuais';

  @override
  String get rename => 'Renomear';

  @override
  String get delete => 'Excluir';

  @override
  String get presetName => 'Nome';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePresetTitle => 'Excluir predefinição?';

  @override
  String deletePresetBody(String name) {
    return '“$name” será excluída. O texto no editor continua.';
  }

  @override
  String get joinLetters => 'Ligar as letras';

  @override
  String get letterSpacing => 'Espaço entre letras';

  @override
  String get baselineWobble => 'Ondulação da linha';

  @override
  String get sizeVariance => 'Variação de tamanho';

  @override
  String get rotationVariance => 'Variação de inclinação';

  @override
  String get opacityVariance => 'Variação de opacidade';

  @override
  String get categoryHandwriting => 'Manuscrita';

  @override
  String get categoryCalligraphy => 'Caligrafia';

  @override
  String get categoryTypography => 'Tipografia';

  @override
  String get categoryKids => 'Infantil';

  @override
  String get categoryMaterial => 'Materiais';

  @override
  String get noEmoji => 'Sem emoji';

  @override
  String get saveAlignedImage => 'Salvar imagem alinhada';

  @override
  String savedPath(String path) {
    return 'Salvo: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Erro: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Alinhar grade — $file';
  }

  @override
  String get openAnotherImage => 'Abrir outra imagem';

  @override
  String get hideGrid => 'Ocultar grade';

  @override
  String get showGrid => 'Mostrar grade';

  @override
  String get resetGrid => 'Redefinir grade';

  @override
  String get exportAlignedImage => 'Exportar imagem alinhada';

  @override
  String get openTemplatePhoto =>
      'Abra uma foto do seu modelo preenchido à mão';

  @override
  String get openImage => 'Abrir imagem';

  @override
  String get gridInstructions =>
      'Arraste os 4 cantos para encaixar a grade na foto\ne depois exporte a imagem com a perspectiva corrigida.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get navTextEditor => 'Editor de texto';

  @override
  String get navGridAlignment => 'Alinhar grade';

  @override
  String get editorTitle => 'Texto manuscrito';

  @override
  String get packs => 'Pacotes';

  @override
  String get emojiForMessage => 'Emoji da mensagem';

  @override
  String get saveToGallery => 'Salvar na galeria';

  @override
  String get share => 'Compartilhar';

  @override
  String get previewEmpty => 'Escreva algo abaixo…';

  @override
  String get textHint => 'Escreva seu texto aqui…';

  @override
  String get advancedSettings => 'Configurações avançadas';

  @override
  String get savedToGallery => 'Salvo na galeria!';

  @override
  String get saveFailed => 'Não foi possível salvar a imagem';

  @override
  String get shareFailed => 'Falha ao compartilhar';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'A fonte da predefinição “$preset” não está disponível; usando $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Predefinição';

  @override
  String get newPreset => 'Nova predefinição';

  @override
  String get renamePreset => 'Renomear predefinição';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get packsIntro =>
      'Todos os recursos do app são gratuitos. Os pacotes adicionam mais fontes e predefinições.';

  @override
  String get owned => 'Comprado';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fontes',
      many: '$count fontes',
      one: '$count fonte',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições',
      many: '$count predefinições',
      one: '$count predefinição',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'A compra está aguardando aprovação. Ela será liberada sozinha.';

  @override
  String get purchaseFailed => 'A compra não deu certo. Tente de novo.';

  @override
  String get purchasesRestoredUnlocked =>
      'Compras restauradas. Tudo o que você comprou está liberado.';

  @override
  String paywallPresets(String names) {
    return 'Predefinições: $names';
  }

  @override
  String get unlimitedPresets => 'Predefinições próprias ilimitadas';

  @override
  String get buyOnce =>
      'Compre uma vez e é seu para sempre, também nos seus outros aparelhos';

  @override
  String get allFeaturesFree => 'Todos os recursos do app continuam gratuitos';

  @override
  String get storeUnavailable =>
      'A loja não está disponível agora. Tente mais tarde.';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get notForSale => 'Ainda não está à venda';

  @override
  String get loadingPrice => 'Carregando preço…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: todos os pacotes por $price';
  }

  @override
  String get save => 'Salvar';

  @override
  String get presetSaveTooltip =>
      'Salvar a fonte e o estilo atuais como predefinição';

  @override
  String get presetSaveAsNew => 'Salvar o atual como nova predefinição';

  @override
  String get presetOverwrite => 'Substituir pelas configurações atuais';

  @override
  String get rename => 'Renomear';

  @override
  String get delete => 'Excluir';

  @override
  String get presetName => 'Nome';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePresetTitle => 'Excluir predefinição?';

  @override
  String deletePresetBody(String name) {
    return '“$name” será excluída. O texto no editor continua.';
  }

  @override
  String get joinLetters => 'Ligar as letras';

  @override
  String get letterSpacing => 'Espaço entre letras';

  @override
  String get baselineWobble => 'Ondulação da linha';

  @override
  String get sizeVariance => 'Variação de tamanho';

  @override
  String get rotationVariance => 'Variação de inclinação';

  @override
  String get opacityVariance => 'Variação de opacidade';

  @override
  String get categoryHandwriting => 'Manuscrita';

  @override
  String get categoryCalligraphy => 'Caligrafia';

  @override
  String get categoryTypography => 'Tipografia';

  @override
  String get categoryKids => 'Infantil';

  @override
  String get categoryMaterial => 'Materiais';

  @override
  String get noEmoji => 'Sem emoji';

  @override
  String get saveAlignedImage => 'Salvar imagem alinhada';

  @override
  String savedPath(String path) {
    return 'Salvo: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Erro: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Alinhar grade — $file';
  }

  @override
  String get openAnotherImage => 'Abrir outra imagem';

  @override
  String get hideGrid => 'Ocultar grade';

  @override
  String get showGrid => 'Mostrar grade';

  @override
  String get resetGrid => 'Redefinir grade';

  @override
  String get exportAlignedImage => 'Exportar imagem alinhada';

  @override
  String get openTemplatePhoto =>
      'Abra uma foto do seu modelo preenchido à mão';

  @override
  String get openImage => 'Abrir imagem';

  @override
  String get gridInstructions =>
      'Arraste os 4 cantos para encaixar a grade na foto\ne depois exporte a imagem com a perspectiva corrigida.';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get navTextEditor => 'Editor de texto';

  @override
  String get navGridAlignment => 'Alinhar grelha';

  @override
  String get editorTitle => 'Texto manuscrito';

  @override
  String get packs => 'Pacotes';

  @override
  String get emojiForMessage => 'Emoji da mensagem';

  @override
  String get saveToGallery => 'Guardar na galeria';

  @override
  String get share => 'Partilhar';

  @override
  String get previewEmpty => 'Escreve algo em baixo…';

  @override
  String get textHint => 'Escreve aqui o teu texto…';

  @override
  String get advancedSettings => 'Definições avançadas';

  @override
  String get savedToGallery => 'Guardado na galeria!';

  @override
  String get saveFailed => 'Não foi possível guardar a imagem';

  @override
  String get shareFailed => 'Falha ao partilhar';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'O tipo de letra da predefinição «$preset» não está disponível; a usar $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Predefinição';

  @override
  String get newPreset => 'Nova predefinição';

  @override
  String get renamePreset => 'Mudar o nome da predefinição';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get packsIntro =>
      'Todas as funções da app são gratuitas. Os pacotes acrescentam mais tipos de letra e predefinições.';

  @override
  String get owned => 'Comprado';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tipos de letra',
      many: '$count tipos de letra',
      one: '$count tipo de letra',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predefinições',
      many: '$count predefinições',
      one: '$count predefinição',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'A compra aguarda aprovação. Será desbloqueada automaticamente.';

  @override
  String get purchaseFailed => 'A compra falhou. Tenta novamente.';

  @override
  String get purchasesRestoredUnlocked =>
      'Compras restauradas. Tudo o que compraste está desbloqueado.';

  @override
  String paywallPresets(String names) {
    return 'Predefinições: $names';
  }

  @override
  String get unlimitedPresets => 'Predefinições próprias ilimitadas';

  @override
  String get buyOnce =>
      'Compras uma vez e fica teu para sempre, também nos teus outros dispositivos';

  @override
  String get allFeaturesFree => 'Todas as funções da app continuam gratuitas';

  @override
  String get storeUnavailable =>
      'A loja não está disponível neste momento. Tenta mais tarde.';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get notForSale => 'Ainda não está à venda';

  @override
  String get loadingPrice => 'A carregar o preço…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: todos os pacotes por $price';
  }

  @override
  String get save => 'Guardar';

  @override
  String get presetSaveTooltip =>
      'Guardar o tipo de letra e o estilo atuais como predefinição';

  @override
  String get presetSaveAsNew => 'Guardar o atual como nova predefinição';

  @override
  String get presetOverwrite => 'Substituir pelas definições atuais';

  @override
  String get rename => 'Mudar o nome';

  @override
  String get delete => 'Eliminar';

  @override
  String get presetName => 'Nome';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePresetTitle => 'Eliminar a predefinição?';

  @override
  String deletePresetBody(String name) {
    return '«$name» será eliminada. O texto no editor mantém-se.';
  }

  @override
  String get joinLetters => 'Ligar as letras';

  @override
  String get letterSpacing => 'Espaçamento entre letras';

  @override
  String get baselineWobble => 'Ondulação da linha';

  @override
  String get sizeVariance => 'Variação do tamanho';

  @override
  String get rotationVariance => 'Variação da inclinação';

  @override
  String get opacityVariance => 'Variação da opacidade';

  @override
  String get categoryHandwriting => 'Manuscrito';

  @override
  String get categoryCalligraphy => 'Caligrafia';

  @override
  String get categoryTypography => 'Tipografia';

  @override
  String get categoryKids => 'Crianças';

  @override
  String get categoryMaterial => 'Materiais';

  @override
  String get noEmoji => 'Sem emoji';

  @override
  String get saveAlignedImage => 'Guardar imagem alinhada';

  @override
  String savedPath(String path) {
    return 'Guardado: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Erro: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Alinhar grelha — $file';
  }

  @override
  String get openAnotherImage => 'Abrir outra imagem';

  @override
  String get hideGrid => 'Ocultar grelha';

  @override
  String get showGrid => 'Mostrar grelha';

  @override
  String get resetGrid => 'Repor grelha';

  @override
  String get exportAlignedImage => 'Exportar imagem alinhada';

  @override
  String get openTemplatePhoto =>
      'Abre uma fotografia do teu modelo preenchido à mão';

  @override
  String get openImage => 'Abrir imagem';

  @override
  String get gridInstructions =>
      'Arrasta os 4 cantos para ajustar a grelha à fotografia\ne depois exporta a imagem com a perspetiva corrigida.';
}
