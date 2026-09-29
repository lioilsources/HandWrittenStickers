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
- 22 bundled glyph sheets in three categories, switchable in the editor: handwriting (Laurinka's scan + Caveat, Patrick Hand, Kalam, Indie Flower, Playpen Sans, Reenie Beanie), calligraphy (Dancing Script, Sacramento, Pacifico, Great Vibes, Alex Brush, Parisienne, Pinyon Script, Kaushan Script) and typography (Amatic SC, Playfair Display, Cinzel, Bebas Neue, Abril Fatface, Courier Prime, MedievalSharp)
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

The font-based glyph sheets are rasterised from Google Fonts families licensed under the SIL Open Font License 1.1; each sheet directory ships its `OFL.txt`. Preview of all sheets: [docs/glyph_sheets_preview.png](docs/glyph_sheets_preview.png).

## Documentation

- [CHANGELOG.md](CHANGELOG.md) — development history
- [docs/RELEASE_PLAN.md](docs/RELEASE_PLAN.md) — audit findings and plan for the first App Store release
- [GALLERY.md](GALLERY.md) — screenshots and videos
