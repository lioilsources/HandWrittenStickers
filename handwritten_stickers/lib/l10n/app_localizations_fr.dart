// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navTextEditor => 'Éditeur de texte';

  @override
  String get navGridAlignment => 'Alignement de la grille';

  @override
  String get editorTitle => 'Texte manuscrit';

  @override
  String get packs => 'Packs';

  @override
  String get emojiForMessage => 'Emoji du message';

  @override
  String get saveToGallery => 'Enregistrer dans la galerie';

  @override
  String get share => 'Partager';

  @override
  String get previewEmpty => 'Écris quelque chose ci-dessous…';

  @override
  String get textHint => 'Écris ton texte ici…';

  @override
  String get advancedSettings => 'Réglages avancés';

  @override
  String get savedToGallery => 'Enregistré dans la galerie !';

  @override
  String get saveFailed => 'Impossible d’enregistrer l’image';

  @override
  String get shareFailed => 'Échec du partage';

  @override
  String presetSheetMissing(String preset, String sheet) {
    return 'La police du préréglage « $preset » n’est pas disponible, $sheet est utilisée.';
  }

  @override
  String presetDefaultName(String sheet, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$sheet – $dateString';
  }

  @override
  String get presetFallbackName => 'Préréglage';

  @override
  String get newPreset => 'Nouveau préréglage';

  @override
  String get renamePreset => 'Renommer le préréglage';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchasesRestored => 'Achats restaurés.';

  @override
  String get packsIntro =>
      'Toutes les fonctions de l’app sont gratuites. Les packs ajoutent des polices et des préréglages.';

  @override
  String get owned => 'Acheté';

  @override
  String fontCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count polices',
      many: '$count polices',
      one: '$count police',
    );
    return '$_temp0';
  }

  @override
  String presetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count préréglages',
      many: '$count préréglages',
      one: '$count préréglage',
    );
    return '$_temp0';
  }

  @override
  String get purchasePending =>
      'L’achat attend une validation. Il se débloquera tout seul.';

  @override
  String get purchaseFailed => 'L’achat a échoué. Réessaie, s’il te plaît.';

  @override
  String get purchasesRestoredUnlocked =>
      'Achats restaurés. Tout ce que tu as acheté est débloqué.';

  @override
  String paywallPresets(String names) {
    return 'Préréglages : $names';
  }

  @override
  String get unlimitedPresets => 'Préréglages personnels illimités';

  @override
  String get buyOnce =>
      'Achète une fois, garde-le pour toujours, aussi sur tes autres appareils';

  @override
  String get allFeaturesFree =>
      'Toutes les fonctions de l’app restent gratuites';

  @override
  String get storeUnavailable =>
      'La boutique n’est pas disponible pour le moment. Réessaie plus tard.';

  @override
  String buyFor(String price) {
    return 'Acheter pour $price';
  }

  @override
  String get notForSale => 'Pas encore en vente';

  @override
  String get loadingPrice => 'Chargement du prix…';

  @override
  String buyAllFor(String bundle, String price) {
    return '$bundle : tous les packs pour $price';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String get presetSaveTooltip =>
      'Enregistrer la police et le style actuels comme préréglage';

  @override
  String get presetSaveAsNew => 'Enregistrer comme nouveau préréglage';

  @override
  String get presetOverwrite => 'Remplacer par les réglages actuels';

  @override
  String get rename => 'Renommer';

  @override
  String get delete => 'Supprimer';

  @override
  String get presetName => 'Nom';

  @override
  String get cancel => 'Annuler';

  @override
  String get deletePresetTitle => 'Supprimer le préréglage ?';

  @override
  String deletePresetBody(String name) {
    return '« $name » sera supprimé. Le texte de l’éditeur reste.';
  }

  @override
  String get joinLetters => 'Lier les lettres';

  @override
  String get letterSpacing => 'Espacement des lettres';

  @override
  String get baselineWobble => 'Ondulation de la ligne';

  @override
  String get sizeVariance => 'Variation de taille';

  @override
  String get rotationVariance => 'Variation d’inclinaison';

  @override
  String get opacityVariance => 'Variation d’opacité';

  @override
  String get categoryHandwriting => 'Manuscrit';

  @override
  String get categoryCalligraphy => 'Calligraphie';

  @override
  String get categoryTypography => 'Typographie';

  @override
  String get categoryKids => 'Enfants';

  @override
  String get categoryMaterial => 'Matières';

  @override
  String get noEmoji => 'Sans emoji';

  @override
  String get saveAlignedImage => 'Enregistrer l’image alignée';

  @override
  String savedPath(String path) {
    return 'Enregistré : $path';
  }

  @override
  String errorMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String gridAlignmentFile(String file) {
    return 'Alignement de la grille — $file';
  }

  @override
  String get openAnotherImage => 'Ouvrir une autre image';

  @override
  String get hideGrid => 'Masquer la grille';

  @override
  String get showGrid => 'Afficher la grille';

  @override
  String get resetGrid => 'Réinitialiser la grille';

  @override
  String get exportAlignedImage => 'Exporter l’image alignée';

  @override
  String get openTemplatePhoto =>
      'Ouvre une photo de ton modèle rempli à la main';

  @override
  String get openImage => 'Ouvrir une image';

  @override
  String get gridInstructions =>
      'Fais glisser les 4 coins pour caler la grille sur la photo,\npuis exporte l’image à la perspective corrigée.';
}
