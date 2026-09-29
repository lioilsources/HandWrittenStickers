# HandWritenStickers

Two-part app that converts handwritten notes into digital stickers. A Go CLI extracts individual glyphs from scanned template pages; the Flutter app composes text from those glyphs with styling variations and exports as PNG.

## Platforms

| Platform | Status |
|----------|--------|
| iOS | Supported |
| Android | Supported |
| macOS | Supported |
| Web | Supported |

## Features

- Interactive grid alignment tool for photo perspective correction
- Glyph extraction from A4 template pages (160 characters, Czech diacritics)
- 3-zone transparency algorithm with JPEG noise tolerance
- 114 bundled glyph sheets in three categories (handwriting, calligraphy, typography), switchable in the editor: Laurinka's scanned handwriting plus 113 font sheets rasterised from Google Fonts with full Czech coverage
- Baseline-aligned, proportionally spaced layout driven by per-glyph metrics
- Text composition with styling variations
- Export as PNG / save to gallery

## Tech Stack

- Flutter / Dart 3.10.7
- Provider (state management)
- Go (glyph_extractor CLI)
- path_provider, share_plus, gal, image, file_picker

## Build

```bash
# Flutter app
cd handwritten_stickers
flutter run -d ios

# Glyph extractor CLI
cd glyph_extractor
go run . template                                   # generate template PDF
go run . --input page1.png,page2.png --output out    # extract glyphs from scan
go run . fontset -font Foo.ttf -output ../handwritten_stickers/assets/glyphs/foo -id foo -name Foo
                                                    # rasterise a TTF font into a glyph sheet
```

## Fonts

The font-based glyph sheets are rasterised from Google Fonts families licensed under the SIL Open Font License 1.1; each sheet directory ships its `OFL.txt`. Previews: [handwriting](docs/glyph_sheets_handwriting.png), [calligraphy](docs/glyph_sheets_calligraphy.png), [typography](docs/glyph_sheets_typography.png).

## Documentation

- [CHANGELOG.md](CHANGELOG.md) — development history
- [docs/RELEASE_PLAN.md](docs/RELEASE_PLAN.md) — audit findings and plan for the first App Store release
- [GALLERY.md](GALLERY.md) — screenshots and videos
