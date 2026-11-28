# HandWrittenStickers

<!-- Max 80 lines. Details go to docs/architecture.md. Public repo: no LAN IPs, home paths, IDs. -->

## Purpose
Personalised stickers from handwritten characters. Two-part pipeline:
1. **Glyph Extractor** (Go, `glyph_extractor/`) - generates the template PDF, extracts glyph sheets from scans, photos, fonts and free-form writing
2. **Flutter App** (`handwritten_stickers/`) - composes text from glyphs, exports PNG/GIF; on desktop also a grid alignment tool for photo correction

## Build and test
Gate (same as `.github/workflows/ci.yml` and `ci-tools.yml`):
```bash
cd glyph_extractor && gofmt -l . && go vet ./... && go test ./...
cd handwritten_stickers && flutter pub get && flutter analyze --no-fatal-infos && flutter test
```
Everyday:
```bash
cd glyph_extractor && go build      # full CLI reference: docs/architecture.md
cd handwritten_stickers
flutter run -d macos                # includes the Grid Alignment tool
flutter gen-l10n                    # after editing lib/l10n/*.arb
../store/screenshots.sh             # store screenshots, cs/en × iPhone 6.9" / Play / iPad 13"
python3 ../store/check_listing.py   # length limits of store/listing.md
```

## Map
- `glyph_extractor/` - Go CLI: `template`, `extract`, `upgrade`, `segment`, `assemble`, `preview`, `fontset`, `reprocess`, `rename`
- `handwritten_stickers/` - Flutter app; glyph sheets in `assets/glyphs/`, presets, packs and emoji in `assets/`
- `tools/` - sheet sources (`tools/sheets/README.md`), ComfyUI client (`tools/comfy/`), emoji set (`tools/emoji/`), kid sheets
- `store/` - store texts and IAP table (`listing.md`), privacy answers, screenshots
- `site/` - support page and privacy policy, published by `.github/workflows/pages.yml`
- `docs/` - plans (`RELEASE_PLAN.md`, `EMOJI_SET_PLAN.md`, …), sheet previews, `architecture.md`
- `Prompts/` - Czech work plans

Data flow: `GlyphSheetIndex` → `GlyphLoader` → `GlyphRenderer.layoutText()` → `HandwrittenCanvas` → `ImageExporter`

## Invariants
- Every sheet directory `assets/glyphs/<id>/` must be listed in `pubspec.yaml` (`assets:`) and in `assets/glyphs/sheets.json` (the authoritative list). `"bundle": false` hides a sheet from release builds (unclear licence).
- Uppercase glyphs are stored as `cap_A.png` so names stay unique on case-insensitive volumes (every iOS build); `CharToFilename` adds the prefix, `glyph_sheets_test.dart` guards it.
- `fontset`, `extract` and `assemble` normalise the capital H to 0.70 em (`-cap-ratio`); the renderer scales by `cellHeightPx`, not by `emHeight`.
- Manifest v3 writes a single variant as a plain string, so v2 readers keep working.
- `paintGlyphs` (`glyph_painter.dart`) is the one place glyphs and joins are drawn, for preview and export alike.
- Content packs: all features free except saving presets; everything else paid is content. No `pack` = free (`packs_test.dart` pins the free sheet list).
- Anonymous statistics (`ol1n_telemetry`): the event dictionary is `lib/telemetry/telemetry_dictionary.dart` = `docs/telemetry.md`, kept in step by `test/telemetry_test.dart`; details in `docs/architecture.md`.
- Privacy manifests (`ios/` and `macos/Runner/PrivacyInfo.xcprivacy`), `store/privacy-answers.md` and the policy in `site/` change together with any new telemetry event or property.
- Localisation: English ARB is the template; `l10n_test.dart` keeps `app_en.arb` and `app_cs.arb` in step.
- Widget tests that open the editor more than once per file need `addTearDown(rootBundle.clear)`.
- The own emoji set is generated on L40S, never SPARK (`docs/EMOJI_SET_PLAN.md`).

## Where next
- `docs/architecture.md` - full CLI reference, Go and Flutter architecture, store, manifest versions v1–v3, template format, transparency
- `tools/sheets/README.md` - sheet sources beyond fonts
- `docs/RELEASE_PLAN.md`, `store/listing.md`, `README.md`
