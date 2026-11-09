// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navTextEditor => 'Editor de texto';

  @override
  String get navGridAlignment => 'Alinear cuadrícula';

  @override
  String get editorTitle => 'Texto manuscrito';

  @override
  String get packs => 'Paquetes';

  @override
  String get emojiForMessage => 'Emoji del mensaje';

  @override
  String get saveToGallery => 'Guardar en la galería';

  @override
  String get share => 'Compartir';

  @override
  String get previewEmpty => 'Escribe algo abajo…';

  @override
  String get textHint => 'Escribe tu texto aquí…';

  @override
  String get advancedSettings => 'Ajustes avanzados';

  @override
  String get savedToGallery => '¡Guardado en la galería!';

  @override
  String get saveFailed => 'No se pudo guardar la imagen';

  @override
  String get shareFailed => 'No se pudo compartir';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'La letra del ajuste «$preset» no está disponible; se usa $sheet.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Ajuste';

  @override
  String get newPreset => 'Nuevo ajuste';

  @override
  String get renamePreset => 'Renombrar ajuste';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas.';

  @override
  String get packsIntro =>
      'Todas las funciones de la app son gratis. Los paquetes añaden más letras y ajustes.';

  @override
  String get owned => 'Comprado';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letras',
      many: '$count letras',
      one: '$count letra',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ajustes',
      many: '$count ajustes',
      one: '$count ajuste',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'La compra está pendiente de aprobación. Se desbloqueará sola.';

  @override
  String get purchaseFailed =>
      'La compra no se ha podido completar. Inténtalo de nuevo.';

  @override
  String get purchasesRestoredUnlocked =>
      'Compras restauradas. Todo lo que compraste está desbloqueado.';

  @override
  String paywallPresets(String names) {
    return 'Ajustes: $names';
  }

  @override
  String get unlimitedPresets => 'Ajustes propios ilimitados';

  @override
  String get buyOnce =>
      'Compra una vez y es tuyo para siempre, también en tus otros dispositivos';

  @override
  String get allFeaturesFree =>
      'Todas las funciones de la app siguen siendo gratis';

  @override
  String get storeUnavailable =>
      'La tienda no está disponible ahora. Inténtalo más tarde.';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get notForSale => 'Aún no está a la venta';

  @override
  String get loadingPrice => 'Cargando precio…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle: todos los paquetes por $price';
  }

  @override
  String get save => 'Guardar';

  @override
  String get presetSaveTooltip =>
      'Guardar la letra y el estilo actuales como ajuste';

  @override
  String get presetSaveAsNew => 'Guardar el actual como nuevo ajuste';

  @override
  String get presetOverwrite => 'Sobrescribir con la configuración actual';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get presetName => 'Nombre';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePresetTitle => '¿Eliminar el ajuste?';

  @override
  String deletePresetBody(String name) {
    return '«$name» se eliminará. El texto del editor se queda.';
  }

  @override
  String get joinLetters => 'Unir letras';

  @override
  String get letterSpacing => 'Espaciado de letras';

  @override
  String get baselineWobble => 'Ondulación de la línea';

  @override
  String get sizeVariance => 'Variación de tamaño';

  @override
  String get rotationVariance => 'Variación de inclinación';

  @override
  String get opacityVariance => 'Variación de opacidad';

  @override
  String get categoryHandwriting => 'Manuscrita';

  @override
  String get categoryCalligraphy => 'Caligrafía';

  @override
  String get categoryTypography => 'Tipografía';

  @override
  String get categoryKids => 'Infantil';

  @override
  String get categoryMaterial => 'Materiales';

  @override
  String get noEmoji => 'Sin emoji';

  @override
  String get saveAlignedImage => 'Guardar imagen alineada';

  @override
  String savedPath(String path) {
    return 'Guardado: $path';
  }

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Alinear cuadrícula — $file';
  }

  @override
  String get openAnotherImage => 'Abrir otra imagen';

  @override
  String get hideGrid => 'Ocultar cuadrícula';

  @override
  String get showGrid => 'Mostrar cuadrícula';

  @override
  String get resetGrid => 'Restablecer cuadrícula';

  @override
  String get exportAlignedImage => 'Exportar imagen alineada';

  @override
  String get openTemplatePhoto =>
      'Abre una foto de tu plantilla escrita a mano';

  @override
  String get openImage => 'Abrir imagen';

  @override
  String get gridInstructions =>
      'Arrastra las 4 esquinas para encajar la cuadrícula en la foto\ny luego exporta la imagen con la perspectiva corregida.';
}
