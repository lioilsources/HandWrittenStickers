import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/emoji_tag.dart';
import '../models/glyph.dart';
import '../models/glyph_sheet.dart';
import '../models/style_params.dart';
import '../services/glyph_loader.dart';
import '../services/glyph_renderer.dart';
import '../services/image_exporter.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/emoji_sticker.dart';
import '../widgets/handwritten_canvas.dart';
import '../widgets/preset_selector.dart';
import '../widgets/sheet_selector.dart';
import '../widgets/style_params_panel.dart';

/// Main editor screen for creating handwritten text
class CanvasEditorScreen extends StatefulWidget {
  /// Whether sheets marked `"bundle": false` are offered. Release builds
  /// hide them; screenshots pass false to show what a release shows.
  final bool includeUnbundledSheets;

  const CanvasEditorScreen({
    super.key,
    this.includeUnbundledSheets = !kReleaseMode,
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

  StylePreset _selectedPreset = StylePreset.casual;
  StyleParams _styleParams = StyleParams.casual();
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
    _initializeSheets();
    _loadEmoji();
    _textController.addListener(_onTextChanged);
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
    if (mounted) setState(() => _emoji = tag);
  }

  Future<void> _initializeSheets() async {
    GlyphSheetIndex index;
    try {
      index = await GlyphSheetIndex.load(
        includeUnbundled: widget.includeUnbundledSheets,
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
    final sheet = index.defaultSheet;
    final loader = await _prepareLoader(sheet, index);
    if (!mounted) return;
    setState(() {
      _sheetIndex = index;
      _sheet = sheet;
      _renderer = GlyphRenderer(loader);
      _isLoading = false;
    });
    // Text typed while the sheet was loading has not been laid out yet.
    _updateGlyphs();
  }

  Future<void> _onSheetChanged(GlyphSheet sheet) async {
    if (sheet == _sheet) return;
    final loader = await _prepareLoader(sheet, _sheetIndex);
    if (!mounted) return;
    setState(() {
      _sheet = sheet;
      _renderer = GlyphRenderer(loader);
    });
    _updateGlyphs();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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

  void _onPresetChanged(StylePreset preset) {
    setState(() {
      _selectedPreset = preset;
      _styleParams = preset.toStyleParams();
    });
    _updateGlyphs();
  }

  void _onStyleParamsChanged(StyleParams params) {
    setState(() {
      _styleParams = params;
      _selectedPreset = StylePreset.custom;
    });
    _updateGlyphs();
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

  Future<void> _exportImage() async {
    final success = await _withExport(
      () => ImageExporter.saveToGallery(
        glyphs: _glyphs,
        style: _styleParams,
        emoji: _emoji,
      ),
    );

    if (!mounted || success == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Saved to gallery!' : 'Failed to save image'),
      ),
    );
  }

  final GlobalKey _shareButtonKey = GlobalKey();

  Future<void> _shareImage() async {
    // The share sheet is anchored to the button (required on iOS).
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await _withExport(
        () => ImageExporter.shareImage(
          glyphs: _glyphs,
          style: _styleParams,
          emoji: _emoji,
          origin: origin,
        ),
      );
    } catch (e) {
      debugPrint('CanvasEditor: share failed ($e)');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sharing failed')));
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwritten Text'),
        actions: [
          if (_emojiIndex != null)
            IconButton(
              icon: Icon(
                _emoji == null
                    ? Icons.add_reaction_outlined
                    : Icons.add_reaction,
              ),
              onPressed: _pickEmoji,
              tooltip: 'Emoji ke zprávě',
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
            tooltip: 'Save to Gallery',
          ),
          IconButton(
            key: _shareButtonKey,
            icon: const Icon(Icons.share),
            onPressed: _glyphs.isNotEmpty && !_exporting ? _shareImage : null,
            tooltip: 'Share',
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
                                  ? const Center(
                                      child: Text(
                                        'Type something below...',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : _buildPreview(),
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
                          hintText: 'Type your text here...',
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
                              ),

                            // Preset selector
                            PresetSelector(
                              selected: _selectedPreset,
                              onSelected: _onPresetChanged,
                            ),

                            // Advanced settings toggle
                            ListTile(
                              dense: true,
                              title: const Text('Advanced Settings'),
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
