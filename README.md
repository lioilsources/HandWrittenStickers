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
go run . template     # generate template PDF
go run . extract      # extract glyphs from scan
```

## Documentation

- [CHANGELOG.md](CHANGELOG.md) — development history
- [GALLERY.md](GALLERY.md) — screenshots and videos
