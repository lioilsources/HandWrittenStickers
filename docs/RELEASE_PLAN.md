# Plán prvního releasu do App Store

Stav k 2026-09-29, větev `claude/typography-sheet-variants-7j2sfr`.
Tento dokument je zadání pro další iteraci (Opus). Položky jsou seřazené podle
priority; každá má odhad rozsahu a hotovo-kritérium, aby se dala odškrtnout.

## Co už je hotové v této větvi

- 113 sad glyphů generovaných z fontů (SIL OFL) ve třech kategoriích
  (rukopis 21, kaligrafie 70, typografie 22) + původní Laurinčina ručně
  psaná sada; přepínač sad v editoru seskupený po kategoriích. Jde o všechny
  rodiny z Google Fonts kategorií handwriting/display se skriptovým nebo
  dekorativním charakterem, které pokrývají celou českou sadu.
- `fontset` normalizuje výšku verzálek (H = 0,70 em), takže sady mají v
  aplikaci stejnou velikost.
- Manifest `glyphs.json` verze 2 s metrikami (baseline, advance, bearing);
  renderer zarovnává glyphy na účaří a používá proporcionální šířky.
- `glyph_extractor fontset` (Go) – vyrobí sadu z libovolného TTF/OTF fontu,
  `-check` vypíše, které znaky z 160znakové české sady font neumí.
- Testy: layout s metrikami, načtení všech sad z assetů, existence všech PNG.

Náhledy: [rukopis](glyph_sheets_handwriting.png), [kaligrafie](glyph_sheets_calligraphy.png), [typografie](glyph_sheets_typography.png).

## Nalezené chyby a slabá místa (audit kódu)

### Renderování a export (uživatel to vidí hned)

| # | Kde | Problém | Dopad |
|---|-----|---------|-------|
| B1 | `image_exporter.dart` `exportToPng(scale: 2.0)` | Export počítá z náhledu (výška písma 30 px) a jen 2× zvětší. Výstupní PNG má písmena ~60 px vysoká, zatímco zdrojové glyphy mají 200–250 px. | Rozmazané samolepky. Exportovat při `scale ≈ 8` nebo layout přepočítat pro cílovou výšku. |
| B2 | `handwritten_canvas.dart`, `image_exporter.dart` | `canvas.drawImage(..., Paint())` bez `filterQuality`. Zmenšení z 250 px na 30 px bez filtrování = aliasing v náhledu. | Nastavit `Paint()..filterQuality = FilterQuality.medium` (náhled) / `high` (export). |
| B3 | `image_exporter.dart` | Parametr `transparent` existuje, ale UI vždy volá bílé pozadí. Samolepka bez průhledného pozadí není samolepka. | Přidat přepínač „průhledné pozadí“, výchozí zapnuto. |
| B4 | `style_params.dart` / painter | `inkColor` a `opacity` se generují, ale painter je nikdy nepoužije. | Glyphy jsou černé s alfou, stačí `ColorFilter.mode(inkColor, BlendMode.srcIn)`; opacity přes `Paint.color`. |
| B5 | `canvas_editor_screen.dart` | `_canvasWidth = 800`, `_baseGlyphHeight = 30` natvrdo. Na telefonu se dlouhý text zalomí podle 800 px, ne podle šířky obrazovky; velikost písma nejde měnit. | Slider velikosti písma, zalamování podle skutečné šířky canvasu. |
| B6 | Laurinčina sada (`assets/glyphs/laurinka`) | Je to manifest v1: neořezané celé buňky 217×252 px, bez metrik. Renderer ji proto pokládá „monospace“ (každé písmeno má šířku celé buňky). | Rozšířit extrakci `--input` o výstup metrik (viz T3) a sadu přegenerovat ze zarovnaných skenů. |
| B7 | `glyph_renderer.dart` | Vstupní text se nenormalizuje (NFC). Diakritika napsaná jako rozložené znaky (např. z některých klávesnic nebo vložením) se nenajde v manifestu a vypadne. | Normalizovat NFC (`package:unorm_dart` nebo `characters`), neznámé znaky zobrazit jako zástupný symbol místo tichého vynechání. |
| B8 | `style_params_panel.dart` | Slidery nepokrývají `wordSpacing` a `lineHeight`, přitom jsou ve `StyleParams`. | Doplnit dva slidery. |

### Platforma a App Store

| # | Kde | Problém | Dopad |
|---|-----|---------|-------|
| P1 | `home_screen.dart` | Záložka „Grid Alignment“ (vývojářský nástroj pro macOS s `file_picker.saveFile`) se zobrazuje i na iPhonu. | Na iOS/Android skrýt (`Platform.isMacOS` nebo `kDebugMode`), případně vyčlenit do samostatného desktop targetu. |
| P2 | `ios/Runner/Assets.xcassets/AppIcon` | Výchozí Flutter ikona. Apple takové buildy vrací (Guideline 2.3.8). | Vlastní ikona 1024×1024, vygenerovat sady přes `flutter_launcher_icons`. |
| P3 | `ios/Runner.xcodeproj` | Bundle ID `com.handwritten.handwrittenStickers` je placeholder; `MARKETING_VERSION = 1.0`. | Zaregistrovat finální bundle ID v App Store Connect, verze řídit z `pubspec.yaml` (`1.0.0+1`). |
| P4 | `ios/Runner/` | Chybí `PrivacyInfo.xcprivacy` (Apple od 05/2024 vyžaduje pro app i pluginy používající „required reason API“ – `path_provider`, `share_plus`). | Přidat privacy manifest (Flutter template ho má) a aktualizovat pluginy na verze s vlastním manifestem. |
| P5 | `pubspec.yaml` | `share_plus ^7` (aktuální 13.x), `file_picker ^8` (13.x), `image ^4.0` (4.10). Staré verze nemají privacy manifesty a mají známé iOS chyby. | Upgrade + `flutter pub outdated`, otestovat sdílení na reálném iPhonu. |
| P6 | `ios/Runner/Info.plist` | Je jen `NSPhotoLibraryAddUsageDescription`. Pro `gal` stačí, ale text musí být lokalizovaný (`InfoPlist.strings` cs/en). Chybí `LaunchScreen` s vlastní grafikou. | Doplnit. |
| P7 | `android/app/build.gradle.kts` | Release build podepsán debug klíčem (`signingConfig = debug`). | Netýká se App Storu, ale před Play releasem vytvořit keystore (`key.properties`, nedávat do gitu). |
| P8 | Lokalizace | UI je anglicky, cílová skupina česká. | `flutter_localizations` + `intl`, cs jako výchozí, en. Názvy presetů, tooltips, chybové hlášky. |
| P9 | `image_exporter.dart` `saveToGallery` | `catch (_) { return false; }` spolkne důvod (typicky odmítnuté oprávnění). | Rozlišit „odmítnuto“ (nabídnout Nastavení) a „chyba“. |

### Právní a obsah

| # | Problém | Dopad |
|---|---------|-------|
| L1 | Laurinčina sada je rukopis dítěte kamaráda, v aplikaci pod jménem. Před veřejným vydáním je potřeba souhlas rodičů (a rozhodnout, zda sadu pojmenovat neutrálně, např. „Ruční písmo 1“). Fotky předloh `glyph_extractor/matrix/*.jpg` jsou v repu. | Bez souhlasu vydat jen fontové sady (přepnout `default` v `sheets.json`). |
| L2 | Fontové sady jsou z fontů pod SIL OFL 1.1. Rasterizované PNG nejsou „Font Software“, ale attribution je slušnost a licence je u každé sady v `OFL.txt` (bundlují se do appky). | Přidat obrazovku „O aplikaci / Licence“ se seznamem fontů. |
| L3 | App Store vyžaduje URL na Privacy Policy (i když appka nesbírá nic). | Statická stránka (GitHub Pages) – „aplikace neposílá žádná data“. |
| L4 | Název „Handwritten Stickers“ je generický, v App Store pravděpodobně obsazený. | Ověřit v App Store Connect, připravit alternativu. |

### Hygiena repozitáře

| # | Problém | Náprava |
|---|---------|---------|
| R0 | Assety glyphů mají 42 MB (114 sad × ~370 KB, PNG se v IPA téměř nekomprimuje). Pro první release únosné, ale rozhodnout: (a) menší DPI pro fontové sady (`fontset -dpi 200` ≈ −55 %), (b) iOS On-Demand Resources po kategoriích, (c) kurátorský výběr ~30 sad v appce a zbytek ke stažení. |
| R1 | `app-release.apk` (51 MB) je v gitu. | `git rm --cached`, do `.gitignore`, do budoucna GitHub Releases. |
| R2 | `glyph_extractor/output/` (160 PNG s ne-ASCII názvy jako `!.png`) a `glyph_extractor/glyph_extractor` (binárka, v této větvi už odstraněna z gitu). | `git rm -r --cached glyph_extractor/output`, ignorovat. |
| R3 | `glyph_extractor/grid.go` není `gofmt`. `go vet` je čistý. | `gofmt -w`. |
| R4 | Žádné CI. | GitHub Actions: `flutter analyze`, `flutter test`, `go vet`, `go build`. |
| R5 | `web/`, `linux/`, `windows/` targety se neudržují. | Buď smazat, nebo nechat a v README označit jako nepodporované. |

## Plán práce

### Sprint 1 – kvalita výstupu (nutné pro TestFlight)

- [ ] **T1 Export ve vysokém rozlišení** (B1, B2). `exportToPng` přijme cílovou
  výšku písma v px (výchozí 240 px, tj. `scale = 8` proti náhledu) a používá
  `FilterQuality.high`. Hotovo: exportované PNG má písmena ≥ 200 px vysoká,
  test porovná rozměry výstupu.
- [ ] **T2 Průhledné pozadí + barva inkoustu** (B3, B4). Přepínač v UI, výběr
  barvy (6 přednastavených), `ColorFilter` v painteru i exportu. Hotovo:
  PNG s alfou, barva se propíše do exportu.
- [ ] **T3 Metriky i pro ručně psané sady** (B6). V `main.go` (režim
  `--input`) zapisovat manifest v2: `baseline = 0.75·cellH − trimRect.Min.Y`,
  `advance = trimmed width + 2·padding`, `bearing = padding`, `emHeight =
  0.62·cellH`. Přegenerovat Laurinčinu sadu ze zarovnaných PNG (Grid
  Alignment tool → `--input`). Hotovo: `glyph_sheets_test` kontroluje metriky
  u všech sad, ne jen fontových.
- [ ] **T4 Velikost písma a zalamování** (B5, B8). Se 114 sadami je přepínač
  tři dlouhé řádky chipů; zvážit místo nich sheet s náhledem (render
  „Ahoj“ v každé sadě) a oblíbené.
- [ ] **T4a Velikost písma a zalamování** (B5, B8). Slider velikosti,
  `maxWidth` z `LayoutBuilder`. Hotovo: dlouhý text na iPhonu SE se zalomí
  uvnitř canvasu.
- [ ] **T5 Normalizace vstupu** (B7). NFC + zástupný znak.

### Sprint 2 – App Store připravenost

- [ ] **T6 Skrýt Grid Alignment na mobilu** (P1).
- [ ] **T7 Ikona, launch screen, název, bundle ID** (P2, P3, P6, L4).
- [ ] **T8 Upgrade pluginů + privacy manifest** (P4, P5). Po upgradu
  `share_plus` zkontrolovat API změny (`SharePlus.instance.share`).
- [ ] **T9 Lokalizace cs/en** (P8).
- [ ] **T10 Obrazovka O aplikaci s licencemi fontů** (L2) a rozhodnutí o
  Laurinčině sadě (L1) – bez souhlasu nastavit `default` na `caveat`.
- [ ] **T11 Ošetření chyb při ukládání** (P9).
- [ ] **T12 Privacy policy URL** (L3), texty do App Store Connect
  (popis, klíčová slova, kategorie *Photo & Video* nebo *Utilities*,
  věkové hodnocení 4+, export compliance: bez šifrování).

### Navazující funkce (mimo první release)

- Animované 3D emoji jako tag samolepky: samostatný plán
  [EMOJI_PLAN.md](EMOJI_PLAN.md). Přidává ~17 MB assetů a export APNG.
- Zdroje znaků mimo fonty (materiálové písmo z ComfyUI, datasety rukopisu,
  archivy, fotky, vlastní list): [GLYPH_SOURCES_PLAN.md](GLYPH_SOURCES_PLAN.md).
  Jeho sprint A obsahuje T3 (metriky z mřížky) a B7 (NFD normalizace).

### Sprint 3 – hygiena a proces

- [ ] **T13 Repo cleanup** (R1–R3, R5).
- [ ] **T14 CI** (R4) + `flutter build ipa --release` ručně na Macu,
  nahrání přes Transporter/Xcode, TestFlight interní test.
- [ ] **T15 Screenshoty** pro 6,7" a 6,1" iPhone (App Store je vyžaduje),
  volitelně iPad – pokud se iPad nepodporuje, nastavit `TARGETED_DEVICE_FAMILY = 1`.

### Doporučené pořadí pro Opus

1. T1, T2, T3 (jeden PR – „kvalita výstupu“; T3 mění Go i Dart).
2. T4, T5, T6, T11 (jeden PR – „UX na telefonu“).
3. T7, T8, T9, T10 (jeden PR – „App Store“).
4. T12–T15 mimo kód.

## Poznámky k formátu sad (pro implementaci T3)

```
assets/glyphs/sheets.json          index: { default, sheets: [{id, name, path, source, category}] }
assets/glyphs/<id>/glyphs.json     manifest v2 (viz glyph_extractor/fontset.go: ManifestV2)
assets/glyphs/<id>/*.png           černý inkoust + alfa, oříznuté na inkoust + 2 px
assets/glyphs/<id>/OFL.txt         licence fontu (jen fontové sady)
```

Renderer (`glyph_renderer.dart`): `scale = baseGlyphHeight / cellHeightPx`,
`y = lineTop + baseGlyphHeight·baselineRatio − baseline·scale`,
`x += advance·scale + letterSpacing`. Sady bez `metrics` se kreslí postaru
(celá buňka škálovaná na `baseGlyphHeight`).

Nová sada z fontu:

```bash
cd glyph_extractor && go build
./glyph_extractor fontset -font Foo.ttf -check                      # pokrytí sady
./glyph_extractor fontset -font Foo.ttf -output ../handwritten_stickers/assets/glyphs/foo \
    -id foo -name "Foo" -license OFL-1.1 -attribution "Foo by ... (SIL OFL 1.1)"
# pak přidat do assets/glyphs/sheets.json a do pubspec.yaml (assets:)
```
