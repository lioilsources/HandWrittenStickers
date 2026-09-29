# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HandWrittenStickers creates personalized stickers from handwritten characters. Two-part pipeline:
1. **Glyph Extractor** (Go) - generates template PDF, extracts glyphs from scans
2. **Flutter App** - composes text from glyphs, exports images; includes grid alignment tool for photo correction

## Commands

### Glyph Extractor (Go)
```bash
cd glyph_extractor
go build                                    # Build
./glyph_extractor template ../template.pdf  # Generate template
./glyph_extractor --input page1.png,page2.png --output ./output --dpi 300  # Extract
./glyph_extractor reprocess <glyphs_dir> [threshold]  # Re-apply transparency to existing PNGs
./glyph_extractor rename <glyphs_dir>       # Rename to ASCII-safe filenames
./glyph_extractor fontset -font F.ttf -check                       # Which charset runes a font lacks
./glyph_extractor fontset -font F.ttf -output DIR -id ID -name NAME  # Rasterise a font into a glyph sheet
```

### Flutter App
```bash
cd handwritten_stickers
flutter pub get           # Install dependencies
flutter run               # Run (debug)
flutter run -d macos      # Run on macOS (includes Grid Alignment tool)
flutter build apk         # Build Android
flutter build ios         # Build iOS
flutter test              # Run tests
flutter test test/widget_test.dart  # Single test
```

## Architecture

### Glyph Extractor
- `main.go` - CLI: `template`, `reprocess`, `rename` commands or `--input` extraction mode
- `grid.go` - `GridConfig` for cell extraction, `TrimWhitespace` (JPEG-noise-tolerant), `MakeTransparent` (3-zone alpha: opaque ink / gradient edge / transparent background)
- `charset.go` - `Charset` (160 runes), `CharToFilename` for special chars
- `template_generator.go` - PDF generation with gofpdf
- `fontset.go` - `fontset` command: rasterises a TTF/OTF into a glyph sheet with manifest v2 metrics (`ManifestV2`, `GlyphMetrics`)

### Flutter App
- **Navigation**: `HomeScreen` with tabs → `CanvasEditorScreen` + `GridAlignmentScreen`
- `GlyphSheetIndex` reads `assets/glyphs/sheets.json` (list of bundled sheets, default sheet)
- `GlyphLoader(sheetPath)` reads one sheet's `glyphs.json` manifest, caches `ui.Image`, exposes `cellHeightPx`/`baselineRatio`/metrics
- `GlyphRenderer` layouts text → `List<PositionedGlyph>`; with metrics it aligns glyphs on the baseline and uses proportional advances, without metrics it falls back to per-cell scaling
- `SheetSelector` chip row in `CanvasEditorScreen` switches sheets (one loader per sheet)
- `StyleParams` controls spacing, rotation, scale variations
- `ImageExporter` renders to PNG for save/share

#### Grid Alignment Tool (macOS)
- `GridAlignmentScreen` - interactive photo alignment with 4-corner perspective mapping
- `GridPainter` - `CustomPainter` drawing 8×10 grid interpolated between 4 draggable corners
- `PerspectiveTransformer` - uses `image` package `copyRectify` to warp photo → A4 at 300 DPI (2480×3508 px)
- Workflow: open iPhone photo → drag corners to match template grid → export aligned PNG → feed to Go extractor

Data flow: `GlyphSheetIndex` → `GlyphLoader` → `GlyphRenderer.layoutText()` → `HandwrittenCanvas` → `ImageExporter`

## Glyph Sheets

`assets/glyphs/<id>/` holds one sheet: `glyphs.json` + one PNG per character (+ `OFL.txt` for font sheets). Every directory must be listed in `pubspec.yaml` (`assets:`) and in `assets/glyphs/sheets.json`.

Manifest versions:
- v1 (`laurinka`): `{version, cellSize, glyphs: {char: file}}`, untrimmed cell scans, laid out cell by cell.
- v2 (font sheets): adds `id, name, source, license, attribution, dpi, emHeight, baselineRatio, metrics: {char: {w, h, baseline, advance, bearing}}` in source pixels. `baseline` = px from PNG top to the baseline, `advance` = pen advance, `bearing` = origin → PNG left edge.

Sheets carry a `category` in `sheets.json` (`handwriting`, `calligraphy`, `typography`) that groups the selector rows. Bundled font sheets (all SIL OFL 1.1 from Google Fonts):
- handwriting: Caveat, Patrick Hand, Kalam, Indie Flower, Playpen Sans, Reenie Beanie
- calligraphy: Dancing Script, Sacramento, Pacifico, Great Vibes, Alex Brush, Parisienne, Pinyon Script, Kaushan Script
- typography: Amatic SC, Playfair Display, Cinzel, Bebas Neue, Abril Fatface, Courier Prime, MedievalSharp Preview: `docs/glyph_sheets_preview.png`. Release plan: `docs/RELEASE_PLAN.md`.

## Template Format

A4 PDF, 8×10 grid (80 chars/page), 2 pages = 160 characters total.
- Cell: 22.5 × 26.2 mm
- Margins: 15mm top/left
- Grid area: 180 × 262 mm (starts at margin offset)
- Page 1: Uppercase + digits + punctuation
- Page 2: Lowercase + special chars
- Full Czech diacritics support (Á, Č, Ď, É, Ě, Í, Ň, Ó, Ř, Š, Ť, Ú, Ů, Ý, Ž)

Index formula: `(page × 80) + (row × 8) + col`

## Glyph Transparency

Glyphs are stored as RGBA PNGs with transparent backgrounds. `MakeTransparent` uses 3-zone algorithm:
- Dark pixels (maxRGB < threshold×¾) → fully opaque (alpha=255)
- Transition zone → smooth gradient alpha for anti-aliased edges
- Light pixels (maxRGB ≥ threshold) → fully transparent (alpha=0)

Default threshold: 160 (tuned for iPhone photos of printed templates).
