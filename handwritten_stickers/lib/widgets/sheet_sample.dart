import 'package:flutter/material.dart';

import '../models/glyph.dart';
import '../models/glyph_sheet.dart';
import '../models/style_params.dart';
import '../services/glyph_loader.dart';
import '../services/glyph_renderer.dart';
import '../services/image_exporter.dart';
import 'handwritten_canvas.dart';

/// One line of [text] in [sheet], scaled to [height]: a sample of a sheet
/// the user does not own yet (paywall, pack list).
class SheetSample extends StatefulWidget {
  final GlyphSheet sheet;
  final String text;
  final double height;

  /// Shares the editor's loaders (and their decoded images) when given.
  final Future<GlyphLoader> Function(GlyphSheet sheet)? loaderFor;

  const SheetSample({
    super.key,
    required this.sheet,
    required this.text,
    this.height = 40,
    this.loaderFor,
  });

  @override
  State<SheetSample> createState() => _SheetSampleState();
}

class _SheetSampleState extends State<SheetSample> {
  static const _style = StyleParams(
    baselineWobble: 0.1,
    sizeVariance: 0.05,
    rotationVariance: 0.05,
    opacityVariance: 0,
  );

  List<PositionedGlyph>? _glyphs;

  @override
  void initState() {
    super.initState();
    _layout();
  }

  @override
  void didUpdateWidget(SheetSample old) {
    super.didUpdateWidget(old);
    if (old.sheet != widget.sheet || old.text != widget.text) _layout();
  }

  Future<void> _layout() async {
    try {
      final loader = widget.loaderFor != null
          ? await widget.loaderFor!(widget.sheet)
          : (GlyphLoader(sheetPath: widget.sheet.path));
      await loader.initialize();
      final glyphs = await GlyphRenderer(loader).layoutText(
        text: widget.text,
        style: _style,
        maxWidth: 100000,
        baseGlyphHeight: 30,
      );
      if (mounted) setState(() => _glyphs = glyphs);
    } catch (e) {
      debugPrint('SheetSample: ${widget.sheet.id} failed ($e)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final glyphs = _glyphs;
    if (glyphs == null || glyphs.isEmpty) {
      return SizedBox(height: widget.height);
    }
    final size = StickerLayout.of(glyphs).text;
    return SizedBox(
      height: widget.height,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: HandwrittenCanvas(glyphs: glyphs, style: _style),
        ),
      ),
    );
  }
}
