import 'package:flutter/material.dart';

import '../models/glyph.dart';
import '../models/glyph_sheet.dart';
import '../models/style_params.dart';
import '../services/glyph_loader.dart';
import '../services/glyph_renderer.dart';
import '../services/image_exporter.dart';
import '../widgets/handwritten_canvas.dart';
import '../widgets/preset_selector.dart';
import '../widgets/sheet_selector.dart';
import '../widgets/style_params_panel.dart';

/// Main editor screen for creating handwritten text
class CanvasEditorScreen extends StatefulWidget {
  const CanvasEditorScreen({super.key});

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

  static const double _canvasWidth = 800;
  static const double _baseGlyphHeight = 30;

  @override
  void initState() {
    super.initState();
    _initializeSheets();
    _textController.addListener(_onTextChanged);
  }

  GlyphLoader _loaderFor(GlyphSheet sheet) {
    return _loaders.putIfAbsent(
      sheet.id,
      () => GlyphLoader(sheetPath: sheet.path),
    );
  }

  Future<void> _initializeSheets() async {
    GlyphSheetIndex index;
    try {
      index = await GlyphSheetIndex.load();
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
    final loader = _loaderFor(sheet);
    await loader.initialize();
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
    final loader = _loaderFor(sheet);
    await loader.initialize();
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
    final glyphs = await renderer.layoutText(
      text: text,
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

  Future<void> _exportImage() async {
    final success = await ImageExporter.saveToGallery(
      glyphs: _glyphs,
      style: _styleParams,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Saved to gallery!' : 'Failed to save image'),
      ),
    );
  }

  Future<void> _shareImage() async {
    await ImageExporter.shareImage(glyphs: _glyphs, style: _styleParams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwritten Text'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _glyphs.isNotEmpty ? _exportImage : null,
            tooltip: 'Save to Gallery',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _glyphs.isNotEmpty ? _shareImage : null,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Canvas preview
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                            : InteractiveHandwrittenCanvas(
                                glyphs: _glyphs,
                                style: _styleParams,
                                backgroundColor: Colors.white,
                              ),
                      ),
                    ),
                  ),

                  // Bottom controls in scrollable area
                  Flexible(
                    flex: 0,
                    child: SingleChildScrollView(
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

                          // Text input
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _textController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Type your text here...',
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
