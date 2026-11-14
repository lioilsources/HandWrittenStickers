import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';

import '../l10n/l10n.dart';
import '../models/content_pack.dart';
import '../models/emoji_tag.dart';
import '../models/glyph.dart';
import '../models/glyph_sheet.dart';
import '../models/preset.dart';
import '../models/style_params.dart';
import '../services/entitlement_service.dart';
import '../services/glyph_loader.dart';
import '../services/glyph_renderer.dart';
import '../services/image_exporter.dart';
import '../services/preset_store.dart';
import '../telemetry/telemetry_dictionary.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/emoji_sticker.dart';
import 'packs_screen.dart';
import '../widgets/handwritten_canvas.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/preset_selector.dart';
import '../widgets/sheet_selector.dart';
import '../widgets/style_params_panel.dart';

/// Main editor screen for creating handwritten text
class CanvasEditorScreen extends StatefulWidget {
  /// Whether sheets marked `"bundle": false` are offered. Release builds
  /// hide them; screenshots pass false to show what a release shows.
  final bool includeUnbundledSheets;

  /// Built-in and saved presets plus the last editor state. Null creates a
  /// store backed by the app support directory.
  final PresetStore? presetStore;

  /// Owned content packs. Null uses [EntitlementService.forPlatform].
  final EntitlementService? entitlements;

  const CanvasEditorScreen({
    super.key,
    this.includeUnbundledSheets = !kReleaseMode,
    this.presetStore,
    this.entitlements,
  });

  @override
  State<CanvasEditorScreen> createState() => _CanvasEditorScreenState();
}

class _CanvasEditorScreenState extends State<CanvasEditorScreen> {
  final TextEditingController _textController = TextEditingController();

  /// One loader (with its own image cache) per sheet, created lazily.
  final Map<String, GlyphLoader> _loaders = {};
  GlyphSheetIndex? _sheetIndex;
  GlyphSheet? _sheet;
  late GlyphRenderer _renderer;

  /// Language of pack and built-in preset names, from the first locale.
  String _language = 'en';
  bool _started = false;

  late final PresetStore _presets =
      widget.presetStore ?? PresetStore(language: _language);
  late final EntitlementService _entitlements =
      widget.entitlements ?? EntitlementService.forPlatform();

  /// Preset the current look came from; the look may have changed since.
  Preset? _appliedPreset;
  StyleParams _styleParams = StyleParams.casual();
  Timer? _saveStateTimer;
  List<PositionedGlyph> _glyphs = [];
  bool _isLoading = true;
  bool _showAdvanced = false;
  bool _exporting = false;

  /// Animated emoji the message is tagged with (one per sticker).
  EmojiIndex? _emojiIndex;
  EmojiTag? _emoji;

  static const double _canvasWidth = 800;
  static const double _baseGlyphHeight = 30;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  /// Loading starts here, not in [initState]: content names need the
  /// locale.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _language = context.contentLanguage;
    _initializeSheets();
    _initializeEntitlements();
    _loadEmoji();
  }

  GlyphLoader _loaderFor(GlyphSheet sheet) {
    return _loaders.putIfAbsent(
      sheet.id,
      () => GlyphLoader(sheetPath: sheet.path),
    );
  }

  /// Initialises the loader of [sheet] and the loader of its fallback sheet
  /// (manifest `fallback`), if the index has it.
  Future<GlyphLoader> _prepareLoader(
    GlyphSheet sheet,
    GlyphSheetIndex? index,
  ) async {
    final loader = _loaderFor(sheet);
    await loader.initialize();
    final fallbackId = loader.fallbackId;
    final fallbackSheet = fallbackId == null ? null : index?.byId(fallbackId);
    if (fallbackSheet != null && fallbackSheet != sheet) {
      final fallback = _loaderFor(fallbackSheet);
      await fallback.initialize();
      loader.fallbackLoader = fallback;
    }
    return loader;
  }

  Future<void> _initializeEntitlements() async {
    _entitlements.addListener(_onEntitlementsChanged);
    if (_entitlements.isInitialized) return;
    PackIndex packs;
    try {
      packs = await PackIndex.load(language: _language);
    } catch (e) {
      debugPrint('CanvasEditor: no packs.json ($e)');
      packs = PackIndex.empty;
    }
    await _entitlements.initialize(packs);
  }

  /// Locks come and go with purchases.
  void _onEntitlementsChanged() {
    if (mounted) setState(() {});
  }

  /// Pack the current look needs and the user does not own: the sheet's,
  /// else that of the applied (unchanged) preset.
  ContentPack? get _lockedPack {
    final sheet = _sheet;
    if (sheet != null && !_entitlements.canUseSheet(sheet)) {
      return _entitlements.packs.byId(sheet.pack);
    }
    final preset = _appliedPreset;
    if (preset != null && !_modified && !_entitlements.canUsePreset(preset)) {
      return _entitlements.packs.byId(preset.pack);
    }
    return null;
  }

  Future<GlyphLoader> _sampleLoader(GlyphSheet sheet) async =>
      _loaderFor(sheet);

  /// Offers [pack]; true once the user owns it. [source] says what opened
  /// the offer (anonymous statistics).
  Future<bool> _offerPack(ContentPack pack, {required String source}) async {
    final owned = await showPaywall(
      context,
      entitlements: _entitlements,
      pack: pack,
      source: source,
      contents: PackContents.of(
        pack,
        sheets: _sheetIndex?.sheets ?? const [],
        presets: _presets.builtIns,
      ),
      loaderFor: _sampleLoader,
    );
    return owned ?? false;
  }

  /// Export and share need the content the look uses. Unknown packs (not
  /// in packs.json) never block.
  Future<bool> _ensureOwned() async {
    final pack = _lockedPack;
    if (pack == null) return true;
    return _offerPack(pack, source: 'export');
  }

  /// Saving the user's own presets is the `presets` pack.
  Future<bool> _ensureCanSavePresets() async {
    if (_entitlements.canSavePresets) return true;
    final pack = _entitlements.packs.forFeature(ContentPack.savePresetsFeature);
    if (pack == null) return true;
    return _offerPack(pack, source: 'preset_save');
  }

  /// A tap on a sheet or preset from a pack the user does not own.
  void _reportLocked(String? packId) {
    if (kPackIds.contains(packId)) Telemetry.lockedTap(packId!);
  }

  void _openPacks() {
    Telemetry.feature('packs_open');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/packs'),
        builder: (_) => PacksScreen(
          entitlements: _entitlements,
          sheets: _sheetIndex?.sheets ?? const [],
          presets: _presets.builtIns,
          loaderFor: _sampleLoader,
        ),
      ),
    );
  }

  Future<void> _loadEmoji() async {
    try {
      final index = await EmojiIndex.load();
      if (mounted) setState(() => _emojiIndex = index);
    } catch (e) {
      debugPrint('CanvasEditor: no emoji stickers ($e)');
    }
  }

  Future<void> _pickEmoji() async {
    final index = _emojiIndex;
    if (index == null) return;
    final tag = await showEmojiPicker(context, index: index, selected: _emoji);
    if (tag != null && tag != _emoji) Telemetry.feature('emoji');
    if (mounted) setState(() => _emoji = tag);
  }

  Future<void> _initializeSheets() async {
    GlyphSheetIndex index;
    try {
      index = await GlyphSheetIndex.load(
        includeUnbundled: widget.includeUnbundledSheets,
        language: _language,
      );
    } catch (e) {
      debugPrint(
        'CanvasEditor: sheets.json missing or invalid ($e), '
        'falling back to the default sheet',
      );
      index = const GlyphSheetIndex(
        sheets: [
          GlyphSheet(
            id: 'default',
            name: 'Default',
            path: GlyphLoader.defaultSheetPath,
            source: 'handwriting',
          ),
        ],
        defaultId: 'default',
      );
    }
    if (!_presets.isLoaded) await _presets.load();
    // Continue where the user left off, if that sheet still exists.
    final last = _presets.lastState;
    final sheet = index.byId(last?.sheetId ?? '') ?? index.defaultSheet;
    final style = last != null && last.sheetId == sheet.id
        ? last.style
        : _styleParams;
    final applied = last != null && last.sheetId == sheet.id
        ? _presets.byId(last.presetId)
        : null;
    final loader = await _prepareLoader(sheet, index);
    if (!mounted) return;
    setState(() {
      _sheetIndex = index;
      _sheet = sheet;
      _styleParams = style;
      _appliedPreset = applied;
      _renderer = GlyphRenderer(loader);
      _isLoading = false;
    });
    // Text typed while the sheet was loading has not been laid out yet.
    _updateGlyphs();
  }

  Future<void> _onSheetChanged(GlyphSheet sheet) async {
    if (sheet == _sheet) return;
    Telemetry.feature('sheet_change');
    if (!_entitlements.canUseSheet(sheet)) _reportLocked(sheet.pack);
    final loader = await _prepareLoader(sheet, _sheetIndex);
    if (!mounted) return;
    setState(() {
      _sheet = sheet;
      _renderer = GlyphRenderer(loader);
    });
    _updateGlyphs();
    _scheduleSaveState();
  }

  @override
  void dispose() {
    if (_saveStateTimer?.isActive ?? false) {
      _saveStateTimer!.cancel();
      _saveState();
    }
    _textController.dispose();
    // Services the editor created itself are the editor's to dispose.
    if (widget.presetStore == null) _presets.dispose();
    _entitlements.removeListener(_onEntitlementsChanged);
    if (widget.entitlements == null) _entitlements.dispose();
    super.dispose();
  }

  /// The look differs from the preset it came from.
  bool get _modified {
    final applied = _appliedPreset;
    final sheet = _sheet;
    return applied != null &&
        sheet != null &&
        !applied.matches(sheet.id, _styleParams);
  }

  /// Remembers the look for the next start, at most every 500 ms.
  void _scheduleSaveState() {
    _saveStateTimer?.cancel();
    _saveStateTimer = Timer(const Duration(milliseconds: 500), _saveState);
  }

  void _saveState() {
    final sheet = _sheet;
    if (sheet == null) return;
    _presets.saveLastState(
      EditorState(
        sheetId: sheet.id,
        style: _styleParams,
        presetId: _appliedPreset?.id,
      ),
    );
  }

  /// Switches sheet and style to [preset]; the text stays. A sheet that is
  /// not available (removed, or hidden in release builds) is replaced by
  /// the default sheet.
  Future<void> _applyPreset(Preset preset) async {
    final index = _sheetIndex;
    if (index == null) return;
    Telemetry.feature('preset_apply');
    if (!_entitlements.canUsePreset(preset)) _reportLocked(preset.pack);
    var sheet = index.byId(preset.sheetId);
    if (sheet == null) {
      sheet = index.defaultSheet;
      Telemetry.errorShown('preset_sheet');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.presetSheetMissing(preset.name, sheet.name),
          ),
        ),
      );
    }
    final loader = await _prepareLoader(sheet, index);
    if (!mounted) return;
    setState(() {
      _appliedPreset = preset;
      _sheet = sheet;
      _renderer = GlyphRenderer(loader);
      _styleParams = preset.style;
    });
    _updateGlyphs();
    _scheduleSaveState();
  }

  String _defaultPresetName() {
    final now = DateTime.now();
    final name = _sheet?.name ?? context.l10n.presetDefaultName;
    return '$name – ${now.day}. ${now.month}.';
  }

  Future<void> _saveAsNewPreset() async {
    if (_sheet == null || !await _ensureCanSavePresets()) return;
    if (!mounted) return;
    final sheet = _sheet!;
    final name = await showPresetNameDialog(
      context,
      title: context.l10n.newPreset,
      initial: _defaultPresetName(),
    );
    if (name == null || !mounted) return;
    final preset = await _presets.add(
      name: name,
      sheetId: sheet.id,
      style: _styleParams,
    );
    Telemetry.feature('preset_save');
    if (!mounted) return;
    setState(() => _appliedPreset = preset);
    _scheduleSaveState();
  }

  Future<void> _onPresetLongPress(Preset preset) async {
    final action = await showPresetActions(
      context,
      preset: preset,
      modified: _appliedPreset == preset ? _modified : true,
    );
    if (action == null || !mounted) return;
    switch (action) {
      case PresetAction.saveAsNew:
        await _saveAsNewPreset();
      case PresetAction.overwrite:
        final sheet = _sheet;
        if (sheet == null || !await _ensureCanSavePresets()) return;
        final updated = await _presets.update(
          preset.id,
          sheetId: sheet.id,
          style: _styleParams,
        );
        if (updated != null && mounted) {
          setState(() => _appliedPreset = updated);
          _scheduleSaveState();
        }
      case PresetAction.rename:
        if (!await _ensureCanSavePresets() || !mounted) return;
        final name = await showPresetNameDialog(
          context,
          title: context.l10n.renamePreset,
          initial: preset.name,
        );
        if (name == null) return;
        final updated = await _presets.update(preset.id, name: name);
        if (updated != null && mounted && _appliedPreset == preset) {
          setState(() => _appliedPreset = updated);
        }
      case PresetAction.delete:
        if (!await confirmPresetDelete(context, preset)) return;
        await _presets.delete(preset.id);
        if (!mounted) return;
        if (_appliedPreset == preset) {
          setState(() => _appliedPreset = null);
          _scheduleSaveState();
        }
    }
  }

  void _onTextChanged() {
    _updateGlyphs();
  }

  int _layoutGeneration = 0;

  Future<void> _updateGlyphs() async {
    if (_isLoading) return;
    final text = _textController.text;
    final generation = ++_layoutGeneration;
    if (text.isEmpty) {
      setState(() {
        _glyphs = [];
      });
      return;
    }

    final renderer = _renderer;
    final lines = await renderer.balanceLines(
      text: text,
      style: _styleParams,
      baseGlyphHeight: _baseGlyphHeight,
    );
    final glyphs = await renderer.layoutText(
      text: lines,
      style: _styleParams,
      maxWidth: _canvasWidth,
      baseGlyphHeight: _baseGlyphHeight,
    );

    // Drop results of an older layout that finished after a newer one.
    if (!mounted || generation != _layoutGeneration) return;
    setState(() {
      _glyphs = glyphs;
    });
  }

  void _onStyleParamsChanged(StyleParams params) {
    Telemetry.feature('style_adjust');
    setState(() {
      _styleParams = params;
    });
    _updateGlyphs();
    _scheduleSaveState();
  }

  /// Runs an export, showing progress (the animated GIF takes a moment).
  Future<T?> _withExport<T>(Future<T> Function() run) async {
    if (_exporting) return null;
    setState(() => _exporting = true);
    try {
      return await run();
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// An export flow with what the sticker is made of: catalogue ids and
  /// counts only, never the text itself.
  TelemetryFlow _exportFlow(String target) {
    final sheet = _sheet;
    final preset = _appliedPreset;
    final end = {'target': target, 'animated': _emoji != null};
    return Telemetry.flow('export', {
      ...end,
      'sheet': telemetrySheet(sheet?.id),
      'category': sheet?.category.name ?? 'handwriting',
      'pack': telemetryPack(sheet?.pack),
      'preset': telemetryPreset(
        id: preset?.id,
        builtIn: preset?.builtIn ?? false,
      ),
      'modified': _modified,
      'chars': _textController.text.characters.length.clamp(0, 10000),
    }, () => end);
  }

  Future<void> _exportImage() async {
    if (!await _ensureOwned() || !mounted) return;
    Telemetry.feature('save_gallery');
    final flow = _exportFlow('gallery');
    final success = await _withExport(
      () => ImageExporter.saveToGallery(
        glyphs: _glyphs,
        style: _styleParams,
        emoji: _emoji,
      ),
    );

    final end = {'target': 'gallery', 'animated': _emoji != null};
    if (success == null) {
      flow.end('cancel', end); // another export was running
    } else if (success) {
      flow.end('ok', end);
      Telemetry.activation();
    } else {
      flow.end('error', end);
      Telemetry.errorShown('save');
    }
    if (!mounted || success == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? context.l10n.savedToGallery : context.l10n.saveFailed,
        ),
      ),
    );
  }

  final GlobalKey _shareButtonKey = GlobalKey();

  Future<void> _shareImage() async {
    if (!await _ensureOwned() || !mounted) return;
    // The share sheet is anchored to the button (required on iOS).
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    Telemetry.feature('share');
    final flow = _exportFlow('share');
    final end = {'target': 'share', 'animated': _emoji != null};
    try {
      final done = await _withExport(() async {
        await ImageExporter.shareImage(
          glyphs: _glyphs,
          style: _styleParams,
          emoji: _emoji,
          origin: origin,
        );
        return true;
      });
      if (done == null) {
        flow.end('cancel', end); // another export was running
      } else {
        flow.end('ok', end);
        Telemetry.activation();
      }
    } catch (e) {
      debugPrint('CanvasEditor: share failed ($e)');
      flow.end('error', end);
      Telemetry.errorShown('share');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));
    }
  }

  void _openLicences() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/licences'),
        builder: (_) =>
            const LicensePage(applicationName: 'Handwritten Stickers'),
      ),
    );
  }

  /// Licences, plus the statistics switch when the build can send any.
  void _openAbout() {
    if (!Telemetry.isConfigured) {
      _openLicences();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final l10n = context.l10n;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  key: const ValueKey('about-licences'),
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.aboutAndLicences),
                  onTap: () {
                    Navigator.pop(context);
                    _openLicences();
                  },
                ),
                SwitchListTile(
                  key: const ValueKey('about-stats'),
                  secondary: const Icon(Icons.insights_outlined),
                  title: Text(l10n.statsToggle),
                  subtitle: Text(l10n.statsToggleSubtitle),
                  value: Telemetry.isEnabled,
                  onChanged: (on) async {
                    await Telemetry.setEnabled(on);
                    setSheetState(() {});
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The sticker scaled to fit the preview box, never past [_maxPreviewZoom]
  /// times the layout size.
  static const double _maxPreviewZoom = 4;

  Widget _buildPreview() {
    return LayoutBuilder(
      builder: (context, box) {
        // Same geometry as the export, so the emoji sits where it will.
        final layout = StickerLayout.of(_glyphs, withEmoji: _emoji != null);
        const inset = 8.0;
        final zoom = [
          _maxPreviewZoom,
          (box.maxWidth - inset * 2) / layout.width,
          (box.maxHeight - inset * 2) / layout.height,
        ].reduce((a, b) => a < b ? a : b);
        return Center(
          child: SizedBox(
            width: layout.width * zoom,
            height: layout.height * zoom,
            child: FittedBox(
              child: SizedBox(
                width: layout.width,
                height: layout.height,
                child: Stack(
                  children: [
                    Positioned(
                      left: StickerLayout.padding,
                      top: StickerLayout.padding,
                      width: layout.text.width,
                      height: layout.text.height,
                      child: HandwrittenCanvas(
                        glyphs: _glyphs,
                        style: _styleParams,
                      ),
                    ),
                    // The tag rides along beside the text; tap to change.
                    if (_emoji != null)
                      Positioned(
                        left: layout.badgeOrigin.dx,
                        top: layout.badgeOrigin.dy,
                        child: GestureDetector(
                          onTap: _pickEmoji,
                          child: AnimatedEmojiSticker(
                            key: const ValueKey('emoji-badge'),
                            tag: _emoji!,
                            size: layout.badge,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        // Five actions leave little room on a narrow phone: shrink the
        // title rather than cut it off.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(l10n.editorTitle),
        ),
        actions: [
          IconButton(
            key: const ValueKey('open-packs'),
            icon: const Icon(Icons.storefront_outlined),
            onPressed: _openPacks,
            tooltip: l10n.packs,
          ),
          IconButton(
            key: const ValueKey('open-about'),
            icon: const Icon(Icons.info_outline),
            onPressed: _openAbout,
            tooltip: l10n.aboutAndLicences,
          ),
          if (_emojiIndex != null)
            IconButton(
              icon: Icon(
                _emoji == null
                    ? Icons.add_reaction_outlined
                    : Icons.add_reaction,
              ),
              onPressed: _pickEmoji,
              tooltip: l10n.emojiTag,
            ),
          if (_exporting)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _glyphs.isNotEmpty && !_exporting ? _exportImage : null,
            tooltip: l10n.saveToGallery,
          ),
          IconButton(
            key: _shareButtonKey,
            icon: const Icon(Icons.share),
            onPressed: _glyphs.isNotEmpty && !_exporting ? _shareImage : null,
            tooltip: l10n.share,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, box) => Column(
                  children: [
                    // Preview and text field keep their place above the
                    // keyboard; only the settings below them scroll.
                    SizedBox(
                      height: (box.maxHeight * 0.36).clamp(96.0, 320.0),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _glyphs.isEmpty
                                  ? Center(
                                      child: Text(
                                        l10n.emptyCanvasHint,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : _buildPreview(),
                            ),
                            if (_lockedPack != null && _glyphs.isNotEmpty)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: _LockedBadge(
                                  pack: _lockedPack!,
                                  onTap: () {
                                    _reportLocked(_lockedPack!.id);
                                    _offerPack(_lockedPack!, source: 'badge');
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Text input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: l10n.textHint,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: _textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _textController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sheet (handwriting) selector
                            if (_sheetIndex != null &&
                                _sheetIndex!.sheets.length > 1)
                              SheetSelector(
                                sheets: _sheetIndex!.sheets,
                                selected: _sheet!,
                                onSelected: _onSheetChanged,
                                isLocked: (s) => !_entitlements.canUseSheet(s),
                              ),

                            // Presets: sheet + style, built-in and saved
                            ListenableBuilder(
                              listenable: _presets,
                              builder: (context, _) => PresetSelector(
                                builtIns: _presets.builtIns,
                                userPresets: _presets.userPresets,
                                applied: _appliedPreset,
                                modified: _modified,
                                sheetById: (id) => _sheetIndex?.byId(id),
                                onApply: _applyPreset,
                                onLongPress: _onPresetLongPress,
                                onSave: _saveAsNewPreset,
                                isLocked: (p) => !_entitlements.canUsePreset(p),
                              ),
                            ),

                            // Advanced settings toggle
                            ListTile(
                              dense: true,
                              title: Text(l10n.advancedSettings),
                              trailing: Icon(
                                _showAdvanced
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onTap: () {
                                setState(() {
                                  _showAdvanced = !_showAdvanced;
                                });
                              },
                            ),

                            // Style params panel
                            if (_showAdvanced)
                              StyleParamsPanel(
                                params: _styleParams,
                                onChanged: _onStyleParamsChanged,
                                expanded: true,
                                canJoinLetters:
                                    _renderer.loader.strokeWidthPx != null,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// "Part of pack X" label on the preview of content the user does not own
/// yet; tapping it offers the pack.
class _LockedBadge extends StatelessWidget {
  final ContentPack pack;
  final VoidCallback onTap;

  const _LockedBadge({required this.pack, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      key: const ValueKey('locked-badge'),
      color: scheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 14,
                color: scheme.onTertiaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                pack.name,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
