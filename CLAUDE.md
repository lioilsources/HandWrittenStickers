# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HandWrittenStickers creates personalized stickers from handwritten characters. Two-part pipeline:
1. **Glyph Extractor** (Go) - generates template PDF, extracts glyphs from scans
2. **Flutter App** - composes text from glyphs, exports images

## Commands

### Glyph Extractor (Go)
```bash
cd glyph_extractor
go build                                    # Build
./glyph_extractor template ../template.pdf  # Generate template
./glyph_extractor --input page1.png,page2.png --output ./output --dpi 300  # Extract
```

### Flutter App
```bash
cd handwritten_stickers
flutter pub get           # Install dependencies
flutter run               # Run (debug)
flutter run -d macos      # Run on macOS
flutter build apk         # Build Android
flutter build ios         # Build iOS
flutter test              # Run tests
flutter test test/widget_test.dart  # Single test
```

## Architecture

### Glyph Extractor
- `main.go` - CLI: `template` command or `--input` extraction mode
- `grid.go` - `GridConfig` for cell extraction, `TrimWhitespace`, `MakeTransparent`
- `charset.go` - `Charset` (160 runes), `CharToFilename` for special chars
- `template_generator.go` - PDF generation with gofpdf

### Flutter App
- `GlyphLoader` reads `assets/glyphs/glyphs.json` manifest, caches `ui.Image`
- `GlyphRenderer` layouts text → `List<PositionedGlyph>`
- `StyleParams` controls spacing, rotation, scale variations
- `ImageExporter` renders to PNG for save/share

Data flow: `GlyphLoader` → `GlyphRenderer.layoutText()` → `HandwrittenCanvas` → `ImageExporter`

## Template Format

A4 PDF, 8×10 grid (80 chars/page), 2 pages = 160 characters total.
- Cell: 22.5 × 26.2 mm
- Margins: 15mm top/left
- Page 1: Uppercase + digits + punctuation
- Page 2: Lowercase + special chars
- Full Czech diacritics support (Á, Č, Ď, É, Ě, Í, Ň, Ó, Ř, Š, Ť, Ú, Ů, Ý, Ž)

Index formula: `(page × 80) + (row × 8) + col`
