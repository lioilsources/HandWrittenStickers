import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/preset.dart';
import '../models/style_params.dart';

/// Built-in presets (from assets) and the user's own presets plus the last
/// editor state (JSON files in the app support directory).
///
/// Without a writable directory (tests, a platform without
/// `path_provider`) everything still works, it just lives in memory.
class PresetStore extends ChangeNotifier {
  static const String builtInAssetPath = 'assets/presets/presets.json';
  static const String presetsFile = 'presets.json';
  static const String editorStateFile = 'editor_state.json';

  final Future<Directory?> Function() _directory;
  final AssetBundle? _bundle;
  final String language;

  List<Preset> _builtIns = const [];
  List<Preset> _user = [];
  EditorState? _lastState;
  Directory? _dir;
  bool _loaded = false;

  PresetStore({
    Future<Directory?> Function()? directory,
    AssetBundle? bundle,
    this.language = 'cs',
  }) : _directory = directory ?? _defaultDirectory,
       _bundle = bundle;

  /// A store that never touches the disk (tests, previews).
  PresetStore.inMemory({AssetBundle? bundle, this.language = 'cs'})
    : _directory = _noDirectory,
      _bundle = bundle;

  static Future<Directory?> _noDirectory() async => null;

  static Future<Directory?> _defaultDirectory() async {
    try {
      return await getApplicationSupportDirectory();
    } catch (e) {
      debugPrint('PresetStore: no support directory ($e), memory only');
      return null;
    }
  }

  bool get isLoaded => _loaded;
  List<Preset> get builtIns => _builtIns;

  /// The user's presets, oldest first.
  List<Preset> get userPresets => List.unmodifiable(_user);

  /// Built-in presets first, then the user's.
  List<Preset> get all => [..._builtIns, ..._user];

  EditorState? get lastState => _lastState;

  Preset? byId(String? id) {
    if (id == null) return null;
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Reads built-in presets, the user's presets and the last editor state.
  /// A missing or corrupt file counts as empty; it never throws.
  Future<void> load() async {
    try {
      final text = await (_bundle ?? rootBundle).loadString(builtInAssetPath);
      final data = json.decode(text) as Map<String, dynamic>;
      _builtIns = [
        for (final e in data['presets'] as List)
          Preset.builtInFromJson(
            (e as Map).cast<String, dynamic>(),
            language: language,
          ),
      ];
    } catch (e) {
      debugPrint('PresetStore: no built-in presets ($e)');
      _builtIns = const [];
    }

    _dir = await _directory();
    final users = await _readJson(presetsFile);
    _user = [];
    if (users is Map && users['presets'] is List) {
      for (final e in users['presets'] as List) {
        final p = Preset.userFromJson(e);
        if (p != null) _user.add(p);
      }
    }
    _user.sort(
      (a, b) =>
          (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
    );
    _lastState = EditorState.fromJson(await _readJson(editorStateFile));
    _loaded = true;
    notifyListeners();
  }

  /// Saves the current look as a new user preset.
  Future<Preset> add({
    required String name,
    required String sheetId,
    required StyleParams style,
  }) async {
    final preset = Preset(
      id: _newId(),
      name: name.trim(),
      sheetId: sheetId,
      style: style,
      createdAt: DateTime.now(),
    );
    _user.add(preset);
    await _writeUser();
    notifyListeners();
    return preset;
  }

  /// Replaces name and/or look of a user preset. Built-ins cannot change.
  Future<Preset?> update(
    String id, {
    String? name,
    String? sheetId,
    StyleParams? style,
  }) async {
    final i = _user.indexWhere((p) => p.id == id);
    if (i < 0) return null;
    final updated = _user[i].copyWith(
      name: name?.trim(),
      sheetId: sheetId,
      style: style,
    );
    _user[i] = updated;
    await _writeUser();
    notifyListeners();
    return updated;
  }

  Future<void> delete(String id) async {
    final before = _user.length;
    _user.removeWhere((p) => p.id == id);
    if (_user.length == before) return;
    await _writeUser();
    notifyListeners();
  }

  /// Remembers what the editor shows, for the next start. Does not notify.
  Future<void> saveLastState(EditorState state) async {
    if (state == _lastState) return;
    _lastState = state;
    await _writeJson(editorStateFile, state.toJson());
  }

  static final math.Random _random = math.Random();

  static String _newId() =>
      'user:${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(1 << 20).toRadixString(36)}';

  Future<void> _writeUser() => _writeJson(presetsFile, {
    'version': 1,
    'presets': [for (final p in _user) p.toJson()],
  });

  Future<Object?> _readJson(String name) async {
    final dir = _dir;
    if (dir == null) return null;
    final file = File('${dir.path}/$name');
    try {
      if (!await file.exists()) return null;
      return json.decode(await file.readAsString());
    } catch (e) {
      debugPrint('PresetStore: ignoring unreadable $name ($e)');
      return null;
    }
  }

  /// Writes through a temp file and a rename, so a crash mid-write never
  /// leaves a half-written file behind.
  Future<void> _writeJson(String name, Object data) async {
    final dir = _dir;
    if (dir == null) return;
    try {
      await dir.create(recursive: true);
      final tmp = File('${dir.path}/$name.tmp');
      await tmp.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
        flush: true,
      );
      await tmp.rename('${dir.path}/$name');
    } catch (e) {
      debugPrint('PresetStore: could not write $name ($e)');
    }
  }
}
