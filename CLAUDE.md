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

### Flutter App
- **Navigation**: `HomeScreen` with tabs → `CanvasEditorScreen` + `GridAlignmentScreen`
- `GlyphLoader` reads `assets/glyphs/glyphs.json` manifest, caches `ui.Image`
- `GlyphRenderer` layouts text → `List<PositionedGlyph>`
- `StyleParams` controls spacing, rotation, scale variations
- `ImageExporter` renders to PNG for save/share

#### Grid Alignment Tool (macOS)
- `GridAlignmentScreen` - interactive photo alignment with 4-corner perspective mapping
- `GridPainter` - `CustomPainter` drawing 8×10 grid interpolated between 4 draggable corners
- `PerspectiveTransformer` - uses `image` package `copyRectify` to warp photo → A4 at 300 DPI (2480×3508 px)
- Workflow: open iPhone photo → drag corners to match template grid → export aligned PNG → feed to Go extractor

Data flow: `GlyphLoader` → `GlyphRenderer.layoutText()` → `HandwrittenCanvas` → `ImageExporter`

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
