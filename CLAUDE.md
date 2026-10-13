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
./glyph_extractor template -guide F.ttf -out p1.png,p2.png -mask grid_mask.png  # Guide pages for img2img material letters
./glyph_extractor template -pangram pangram.pdf  # Lined sheet to trace + pangram.txt transcript
./glyph_extractor --input page1.png,page2.png --output DIR --dpi 300  # Extract aligned scan → v2 sheet with metrics
./glyph_extractor -input p1.jpg,p2.jpg -grid auto -bg-mode chroma -output DIR  # Extract from photos (grid detection, colour keying)
./glyph_extractor upgrade <v1_sheet_dir> [-output DIR]  # Trim a v1 cell sheet, add metrics
./glyph_extractor segment -input page.png -output DIR -labels-file pangram.txt  # Free-form writing → candidates.json
./glyph_extractor assemble DIR/candidates.json [-labels labels.json] -output SHEET  # → v3 sheet (variants, compose)
./glyph_extractor preview <sheet_dir> -out preview.png  # Contact sheet + sample text laid out with metrics (-marks shows join points)
go test ./...                               # Tests
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
- `main.go` - CLI dispatch: `template`, `extract` (also the bare `--input` form), `upgrade`, `segment`, `assemble`, `preview`, `fontset`, `reprocess`, `rename`
- `manifest.go` - `ManifestV2` (reads/writes v1–v3; `OneOrMany` = single value or variant list), `GlyphMetrics`
- `extract.go` - template-grid extraction and `upgrade`; `SheetMeta` flags shared by sheet-writing commands
- `sheet_builder.go` - `ProcessCell` (key, drop specks/grid lines, trim), `SheetBuilder` (variants, `FitRowBaselines`, `NormalizeCapHeight`, write)
- `keying.go` - background removal modes: `lightness` (`MakeTransparent`), `chroma` (Lab ΔE from sampled paper colour), `alpha`
- `autogrid.go` - `DetectGrid` finds the printed 8×10 grid in a photo (line projection profiles), `ExtractCellQuad` warps a cell
- `segment.go` / `assemble.go` - free-form writing: Otsu + connected components + diacritic grouping + lines → `candidates.json`; labelled candidates → v3 sheet with `compose` rules and dotless `ı`
- `joins.go` - joined handwriting (`SheetBuilder.PrepareJoins`, on by default for `-source handwriting`): snaps lowercase letters to the baseline, evens x-height and slant, thins each letter to its skeleton (Zhang–Suen) and stores stroke ends as `entry`/`exit` join points; flags `-joins`, `-fix-slant`, `-fix-xheight`, `-snap-baseline`
- `guide.go` - clean-font guide pages for material letters; `preview.go` - contact sheet renderer
- `grid.go` - `GridConfig` for cell extraction, `TrimWhitespace` (JPEG-noise-tolerant), `MakeTransparent` (3-zone alpha: opaque ink / gradient edge / transparent background)
- `charset.go` - `Charset` (160 runes), `CharToFilename` (ASCII names for special chars, `cap_` prefix for uppercase)
- `template_generator.go` - PDF generation with gofpdf
- `fontset.go` - `fontset` command: rasterises a TTF/OTF into a glyph sheet with manifest v2 metrics (`ManifestV2`, `GlyphMetrics`)

### Flutter App
- **Navigation**: `HomeScreen` with tabs → `CanvasEditorScreen` + `GridAlignmentScreen` on desktop; phones get the editor alone
- `GlyphSheetIndex` reads `assets/glyphs/sheets.json` (list of bundled sheets, default sheet)
- `GlyphLoader(sheetPath)` reads one sheet's `glyphs.json` manifest (v1–v3), caches `ui.Image` per variant, exposes `cellHeightPx`/`baselineRatio`/`emHeightPx`/metrics, `variantCount`, `composeParts`, `fallbackId` (+ `fallbackLoader` wired by the editor)
- `GlyphRenderer` layouts text → `List<PositionedGlyph>`; with metrics it aligns glyphs on the baseline and uses proportional advances, without metrics it falls back to per-cell scaling. Input is recomposed (`TextNormalizer.nfc`); missing letters are composed from base + accent glyph, else taken from the fallback sheet; variants never repeat back to back (deterministic per text)
- Joined sheets (manifest `strokeWidth`): inside a word the entry point of a letter is placed `GlyphRenderer.joinGap` right of the previous exit point and `PositionedGlyph.join` (`GlyphJoin`, a pen-wide cubic curve) bridges them; `StyleParams.joinLetters` switches it off. `paintGlyphs` (`glyph_painter.dart`) is the one place glyphs and joins are drawn, for preview and export alike
- `SheetSelector` chip row in `CanvasEditorScreen` switches sheets (one loader per sheet)
- `StyleParams` controls spacing, rotation, scale variations
- `ImageExporter` renders to PNG for save/share, scaled so the longest side reaches `pngMaxSide`/`gifMaxSide` px (`scaleFor`); with an emoji tag it exports a looping GIF (`exportToGif`, frames from `renderFrame`, encoded off the UI isolate)
- Emoji tag: one animated sticker per message. `EmojiIndex` reads `assets/emoji/emoji.json` (built by `tools/emoji/build.py`; SwypeKids-style WebP stickers), `EmojiMotion.at(phase)` is the shared loop (preview widget `AnimatedEmojiSticker` and GIF export), `showEmojiPicker` is the bottom sheet

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
- v2 (font sheets, `extract`): adds `id, name, source, license, attribution, dpi, emHeight, baselineRatio, metrics: {char: {w, h, baseline, advance, bearing}}` in source pixels. `baseline` = px from PNG top to the baseline, `advance` = pen advance, `bearing` = origin → PNG left edge.
- v3 (`assemble`, or any sheet using these keys): `glyphs`/`metrics` values may be lists (variants, `a.png`, `a_1.png`, …), `compose: {"č": ["c", "caron"]}` (accent glyph keys `caron`/`acute`/`ring`, dotless `ı` stored as `dotlessi.png`), `fallback: "<sheet id>"`, `colored: true` (material letters, never tinted). A single variant is still written as a plain string, so v2 readers keep working. Joined handwriting adds sheet keys `xHeight`, `slantDeg`, `strokeWidth` (px), `inkColor` (`#rrggbb`) and per-glyph `entry`/`exit` = `[x, y, direction°]` in PNG pixels (direction of pen travel, 0 = right, 90 = up); capitals only have `exit`, digits and punctuation neither.

Sheets carry a `category` in `sheets.json` (`handwriting`, `calligraphy`, `typography`, `kids`, `material`) that groups the selector rows. `"bundle": false` hides a sheet from release builds (unclear licence, e.g. AI material sheets until the model licence is checked). 124 sheets are bundled: two template scans (Laurinka, and Jessie 1 in `calligraphy`, extracted from phone photos with `-grid auto`), 113 Google Fonts sheets (21 handwriting, 70 calligraphy, 22 typography) and 9 CuteKidFonts sheets (`kids`: 6 coloured bubble sheets + 3 plain, built by `tools/kid_sheets/build.sh`), all SIL OFL 1.1. The authoritative list is `sheets.json`; previews per category are in `docs/glyph_sheets_<category>.png`. Release plan: `docs/RELEASE_PLAN.md`.

`fontset`, `extract` and `assemble` normalise every sheet so the capital H is 0.70 em (`-cap-ratio`), which keeps sheets visually interchangeable; `emHeight` in the manifest is the em in px. The renderer scales by `cellHeightPx` (from `cellSize`/`dpi`), not by `emHeight`.

Sources beyond fonts (material letters via ComfyUI, free-form handwriting, NIST SD19, archives, found type): `tools/sheets/README.md`, shared ComfyUI client `tools/comfy/client.py`. Uppercase letters are stored as `cap_A.png` so file names stay unique on case-insensitive volumes (macOS checkouts, hence every iOS build); `CharToFilename` adds the prefix and a test in `glyph_sheets_test.dart` guards it.

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
