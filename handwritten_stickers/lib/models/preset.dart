import 'style_params.dart';

/// A saved look: which glyph sheet and which [StyleParams]. The text and
/// the emoji tag are not part of a preset.
///
/// Built-in presets come from `assets/presets/presets.json`, the user's own
/// are stored by `PresetStore`.
class Preset {
  /// `builtin:<slug>` for built-in presets, `user:<…>` for the user's own.
  final String id;
  final String name;
  final String sheetId;
  final StyleParams style;

  /// Content pack the preset belongs to (`assets/packs/packs.json`); null
  /// means free. The user's own presets are always null.
  final String? pack;

  final bool builtIn;

  /// When the user saved it; null for built-in presets.
  final DateTime? createdAt;

  const Preset({
    required this.id,
    required this.name,
    required this.sheetId,
    required this.style,
    this.pack,
    this.builtIn = false,
    this.createdAt,
  });

  /// Whether [sheetId] and [style] are exactly what this preset stores.
  bool matches(String sheetId, StyleParams style) =>
      sheetId == this.sheetId && style == this.style;

  Preset copyWith({String? name, String? sheetId, StyleParams? style}) =>
      Preset(
        id: id,
        name: name ?? this.name,
        sheetId: sheetId ?? this.sheetId,
        style: style ?? this.style,
        pack: pack,
        builtIn: builtIn,
        createdAt: createdAt,
      );

  /// Built-in entry of `presets.json`. `name` is a map of language codes;
  /// [language] is preferred, then English, then any.
  factory Preset.builtInFromJson(
    Map<String, dynamic> json, {
    String language = 'cs',
  }) {
    final names = json['name'];
    String name;
    if (names is Map) {
      name = (names[language] ?? names['en'] ?? names.values.first) as String;
    } else {
      name = names as String;
    }
    return Preset(
      id: json['id'] as String,
      name: name,
      sheetId: json['sheet'] as String,
      style: StyleParams.fromJson(
        (json['style'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      pack: json['pack'] as String?,
      builtIn: true,
    );
  }

  /// The user's own preset as stored on disk.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sheet': sheetId,
    'style': style.toJson(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  /// Reads [toJson] output; null when the entry is unusable.
  static Preset? userFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    final sheet = json['sheet'];
    if (id is! String || name is! String || sheet is! String) return null;
    final style = json['style'];
    final created = json['createdAt'];
    return Preset(
      id: id,
      name: name,
      sheetId: sheet,
      style: StyleParams.fromJson(
        style is Map ? style.cast<String, dynamic>() : const {},
      ),
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  @override
  bool operator ==(Object other) => other is Preset && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// What the editor showed last: restored on the next start.
class EditorState {
  final String sheetId;
  final StyleParams style;

  /// Preset the look came from (it may have been changed since).
  final String? presetId;

  const EditorState({
    required this.sheetId,
    required this.style,
    this.presetId,
  });

  Map<String, dynamic> toJson() => {
    'sheet': sheetId,
    'style': style.toJson(),
    if (presetId != null) 'preset': presetId,
  };

  static EditorState? fromJson(Object? json) {
    if (json is! Map) return null;
    final sheet = json['sheet'];
    if (sheet is! String) return null;
    final style = json['style'];
    final preset = json['preset'];
    return EditorState(
      sheetId: sheet,
      style: StyleParams.fromJson(
        style is Map ? style.cast<String, dynamic>() : const {},
      ),
      presetId: preset is String ? preset : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EditorState &&
      other.sheetId == sheetId &&
      other.style == style &&
      other.presetId == presetId;

  @override
  int get hashCode => Object.hash(sheetId, style, presetId);
}
