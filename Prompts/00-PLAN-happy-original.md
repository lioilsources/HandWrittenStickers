# Plán: Handwritten Stickers

## Přehled projektu
Dva nástroje pro převod textu na ručně psané písmo:

1. **Glyph Extractor** (desktop) - extrakce písmenek ze skenované mřížky
2. **Handwritten Stickers** (mobile) - převod textu na ručně psaný obrázek

### Vstupní data
- 1-2× A4 papír s mřížkou (políčka 22.5 × 26.2 mm)
- Ručně napsané znaky: A-Ž, a-ž, 0-9, interpunkce
- Včetně české diakritiky

## Architektura

### Projekt 1: Glyph Extractor (Go CLI)
**Technologie**: Go script (jednoduchý, bez UI)
```
glyph_extractor/
├── main.go                    # CLI nástroj
├── grid.go                    # Rozřezání mřížky
├── charset.go                 # Definice pořadí znaků
├── template_generator.go      # Generování PDF šablony
├── go.mod
└── output/
    ├── glyphs/
    │   ├── A.png, a.png, č.png, ...   # Unicode názvy
    └── glyphs.json
```

**Použití:**
```bash
# Generování šablony
go run . template template.pdf

# Extrakce glyphů ze skenu
go run . --input page1.png,page2.png --output ./output --dpi 300
```

### Projekt 2: Handwritten Stickers (Mobile)
**Technologie**: Flutter (iOS/Android)
```
handwritten_stickers/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   └── canvas_editor_screen.dart # Canvas + parametry editor
│   ├── widgets/
│   │   ├── handwritten_canvas.dart   # Canvas vykreslování
│   │   ├── style_params_panel.dart   # Slidery pro StyleParams
│   │   └── preset_selector.dart      # Výběr presetů
│   ├── services/
│   │   ├── glyph_renderer.dart       # Vykreslování s transformacemi
│   │   ├── image_exporter.dart       # Export PNG/JPG
│   │   └── glyph_loader.dart         # Načítání glyphů
│   └── models/
│       ├── glyph.dart                # Glyph + GlyphParams
│       └── style_params.dart         # StyleParams + presets
├── assets/
│   └── glyphs/                       # Zkopírováno z extractoru
│       ├── A.png, a.png, ...
│       └── glyphs.json
└── test/
```

## Datové modely

### Glyph (jednotlivé písmeno)
```dart
class Glyph {
  final String char;           // Znak (rune)
  final ui.Image image;        // Načtený obrázek

  // Automaticky detekované při zpracování
  final Rect boundingBox;      // Skutečný obsah v políčku
  final int width;             // Šířka bounding boxu
  final int height;            // Výška bounding boxu

  // Typografické metriky (lze doladit ručně)
  final int leftBearing;       // Mezera vlevo před písmenem
  final int rightBearing;      // Mezera vpravo za písmenem
  final int baseline;          // Kde je účaří
}
```

### GlyphParams (parametry pro konkrétní instanci)
```dart
class GlyphParams {
  // Pozice
  double baselineOffset;       // Vertikální posun od účaří (-2 až +2 px)
  double kerningAdjust;        // Horizontální mezera k dalšímu písmenu

  // Transformace
  double rotation;             // Náhodná rotace (-3° až +3°)
  double scale;                // Velikost (0.95 - 1.05)

  // Variance
  int variantIndex;            // Která varianta z 1-3
}
```

### StyleParams (globální nastavení stylu)
```dart
class StyleParams {
  // Základní rozestupy
  double letterSpacing;        // Mezera mezi písmeny (default: 0)
  double wordSpacing;          // Mezera mezi slovy (default: glyph width)
  double lineHeight;           // Výška řádku (default: 1.2)

  // Variance pro přirozený vzhled
  double baselineWobble;       // Jak moc "skáče" účaří (0-1)
  double sizeVariance;         // Variance velikosti (0-1)
  double rotationVariance;     // Variance rotace (0-1)

  // Ink efekty
  double opacityVariance;      // Simulace různého přítlaku (0-1)

  // Presets
  static StyleParams neat();      // Úhledné písmo
  static StyleParams casual();    // Běžné písmo
  static StyleParams chaotic();   // Chaotické písmo
  static StyleParams fast();      // Rychlé psaní
}
```

## Klíčové komponenty

---

## ČÁST 1: Glyph Extractor (Go CLI)

### Vstup
- 1-2× PNG/JPG sken A4 s mřížkou
- Pevné pořadí znaků (definováno v `charset.go`)

### Konfigurace mřížky
- **Políčko**: 22.5 × 26.2 mm
- **Mřížka**: 8 sloupců × 10 řádků = 80 políček/stránka
- **Stránky**: 2× A4 = 160 políček celkem

```go
type GridConfig struct {
    CellWidth  float64  // 22.5 mm
    CellHeight float64  // 26.2 mm
    Columns    int      // 8
    Rows       int      // 10
    DPI        int      // rozlišení skenu (default 300)
    MarginTop  float64  // okraj nahoře (mm)
    MarginLeft float64  // okraj vlevo (mm)
}
```

### Charset (160 znaků, pevné pořadí)

**Stránka 1 (80 znaků) - Velká písmena + čísla:**
```
Řádek 1:  A  Á  B  C  Č  D  Ď  E
Řádek 2:  É  Ě  F  G  H  I  Í  J
Řádek 3:  K  L  M  N  Ň  O  Ó  P
Řádek 4:  Q  R  Ř  S  Š  T  Ť  U
Řádek 5:  Ú  Ů  V  W  X  Y  Ý  Z
Řádek 6:  Ž  0  1  2  3  4  5  6
Řádek 7:  7  8  9  .  ,  !  ?  :
Řádek 8:  ;  -  (  )  "  '  /  @
Řádek 9:  #  &  +  =  %  *  €  $
Řádek 10: [  ]  {  }  <  >  \  _
```

**Stránka 2 (80 znaků) - Malá písmena + extra:**
```
Řádek 1:  a  á  b  c  č  d  ď  e
Řádek 2:  é  ě  f  g  h  i  í  j
Řádek 3:  k  l  m  n  ň  o  ó  p
Řádek 4:  q  r  ř  s  š  t  ť  u
Řádek 5:  ú  ů  v  w  x  y  ý  z
Řádek 6:  ž  ~  `  ^  |  ©  ®  ™
Řádek 7:  °  §  ¶  •  …  –  —  „
Řádek 8:  "  ‚  '  «  »  ×  ÷  ±
Řádek 9:  ¼  ½  ¾  ¹  ²  ³  µ  ¿
Řádek 10: ¡  ñ  Ñ  ß  æ  Æ  ø  Ø
```

### Algoritmus
1. Načti obrázek(y)
2. Spočítej pozice políček z DPI a rozměrů
3. Pro každé políčko:
   - Ořízni oblast
   - Detekuj bounding box (trim whitespace)
   - Ulož jako `{znak}.png` (unicode název)
4. Vygeneruj `glyphs.json`

### Výstup (glyphs.json)
```json
{
  "version": 1,
  "cellSize": { "width": 22.5, "height": 26.2 },
  "glyphs": {
    "A": "A.png",
    "á": "á.png",
    "č": "č.png"
  }
}
```

---

## ČÁST 2: Handwritten Stickers (Mobile)

### 1. GlyphLoader
- Načítání PNG obrázků z assets
- Automatická detekce bounding boxu (trim whitespace)
- Cache načtených obrázků
- Fallback pro chybějící znaky (placeholder box)
- Mapování z `glyphs.json`

### 2. GlyphRenderer
- Aplikace transformací (rotace, scale, offset)
- Výpočet pozice s kerningem
- Generování náhodných GlyphParams dle StyleParams
- Multi-line layout s word wrap

### 3. HandwrittenCanvas (Widget)
- CustomPainter pro vykreslování
- Real-time preview při změně textu/parametrů
- Zoom a pan gesta
- Transparentní nebo barevné pozadí

### 4. StyleParamsPanel (Widget)
- Slidery pro každý parametr
- Preset selector (neat, casual, chaotic, fast)
- Live preview změn
- Reset to default

### 5. ImageExporter
- Export do PNG (transparentní pozadí)
- Export do JPG (bílé pozadí)
- Volba rozlišení
- Share sheet integrace

## Implementační kroky

### FÁZE A: Glyph Extractor (Go CLI)

#### A1: Projekt setup
1. `go mod init glyph_extractor`
2. Dependencies: `gofpdf` (pro PDF šablonu)

#### A2: Implementace
1. `charset.go` - definice pořadí znaků
2. `grid.go` - výpočet pozic políček, ořez
3. `template_generator.go` - generování PDF šablony
4. `main.go` - CLI, načtení obrázků, export

#### A3: Spuštění
```bash
# Generování šablony
go run . template ../template.pdf

# Extrakce glyphů
go run . --input scan_page1.png,scan_page2.png --output ./output --dpi 300
```

---

### FÁZE B: Handwritten Stickers (Mobile)

#### B1: Projekt setup
1. `flutter create handwritten_stickers`
2. Dependencies: `provider`, `path_provider`, `share_plus`, `image_gallery_saver`
3. Přidání glyph assets (výstup z Extractoru)

#### B2: Datové modely
1. `lib/models/glyph.dart` - Glyph + GlyphParams
2. `lib/models/style_params.dart` - StyleParams + presets

#### B3: Glyph loading
1. `lib/services/glyph_loader.dart` - načítání z assets
2. Parsování glyphs.json
3. Cache management

#### B4: Rendering engine
1. `lib/services/glyph_renderer.dart` - transformace a layout
2. `lib/widgets/handwritten_canvas.dart` - CustomPainter

#### B5: UI - Editor screen
1. `lib/screens/canvas_editor_screen.dart`
2. `lib/widgets/style_params_panel.dart` - slidery
3. `lib/widgets/preset_selector.dart`

#### B6: Export
1. PNG/JPG export
2. Share sheet + save to gallery

## Technické detaily

### Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0           # State management
  path_provider: ^2.0.0      # File paths
  share_plus: ^7.0.0         # Sharing
  image_gallery_saver: ^2.0.0 # Save to gallery
```

### Rendering algoritmus
```dart
void renderText(Canvas canvas, String text, StyleParams style) {
  double x = 0, y = 0;
  final random = Random(text.hashCode); // Deterministic randomness

  for (final char in text.characters) {
    if (char == ' ') {
      x += style.wordSpacing;
      continue;
    }
    if (char == '\n') {
      x = 0;
      y += style.lineHeight;
      continue;
    }

    final glyph = glyphLoader.get(char);
    final params = generateParams(style, random);

    canvas.save();
    canvas.translate(x, y + params.baselineOffset);
    canvas.rotate(params.rotation * pi / 180);
    canvas.scale(params.scale);

    final paint = Paint()..color = Colors.black.withOpacity(
      1.0 - style.opacityVariance * random.nextDouble()
    );
    canvas.drawImage(glyph.image, Offset.zero, paint);

    canvas.restore();

    x += glyph.width + style.letterSpacing + params.kerningAdjust;

    // Word wrap
    if (x > canvasWidth) {
      x = 0;
      y += style.lineHeight;
    }
  }
}

GlyphParams generateParams(StyleParams style, Random random) {
  return GlyphParams(
    baselineOffset: (random.nextDouble() - 0.5) * 4 * style.baselineWobble,
    rotation: (random.nextDouble() - 0.5) * 6 * style.rotationVariance,
    scale: 1.0 + (random.nextDouble() - 0.5) * 0.1 * style.sizeVariance,
    kerningAdjust: (random.nextDouble() - 0.5) * 2 * style.baselineWobble,
  );
}
```

### StyleParams presets
```dart
static StyleParams neat() => StyleParams(
  letterSpacing: 2,
  baselineWobble: 0.1,
  sizeVariance: 0.05,
  rotationVariance: 0.1,
  opacityVariance: 0.05,
);

static StyleParams casual() => StyleParams(
  letterSpacing: 0,
  baselineWobble: 0.3,
  sizeVariance: 0.15,
  rotationVariance: 0.3,
  opacityVariance: 0.1,
);

static StyleParams chaotic() => StyleParams(
  letterSpacing: -2,
  baselineWobble: 0.7,
  sizeVariance: 0.3,
  rotationVariance: 0.6,
  opacityVariance: 0.2,
);

static StyleParams fast() => StyleParams(
  letterSpacing: 4,
  baselineWobble: 0.5,
  sizeVariance: 0.2,
  rotationVariance: 0.4,
  opacityVariance: 0.15,
);
```

## UI Layout - Canvas Editor Screen

```
┌─────────────────────────────────┐
│  [←] Handwritten Text    [💾][↗]│  <- AppBar s export/share
├─────────────────────────────────┤
│                                 │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │   Canvas Preview        │   │  <- Hlavní preview area
│   │   (pinch to zoom)       │   │     s gesty pro zoom/pan
│   │                         │   │
│   └─────────────────────────┘   │
│                                 │
├─────────────────────────────────┤
│  [Neat] [Casual] [Chaotic] [Fast]│  <- Preset selector
├─────────────────────────────────┤
│  Letter Spacing    ──●────────  │
│  Baseline Wobble   ────●──────  │  <- Expandable panel
│  Size Variance     ──────●────  │     se slidery
│  Rotation Variance ────●──────  │
│  Opacity Variance  ─●─────────  │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ Type your text here...  │   │  <- Multi-line text input
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

## Verifikace

### Glyph Extractor (Go)
1. `go run . --input test_scan.png --output ./test_output --dpi 300`
2. Zkontrolovat výstupní složku - 160 PNG souborů
3. Zkontrolovat `glyphs.json` - všechny znaky namapované

### Handwritten Stickers (Flutter)
1. `flutter run` na iOS/Android simulátoru
2. Zadat text "Příliš žluťoučký kůň úpěl ďábelské ódy."
3. Přepnout mezi presety (Neat → Chaotic)
4. Upravit slider a ověřit live preview
5. Export PNG → ověřit transparentní pozadí
6. Share → ověřit funkčnost sdílení

## Budoucí rozšíření

- [ ] Více variant glyphů (A_1.png, A_2.png, A_3.png)
- [ ] Vlastní barva inkoustu
- [ ] Více fontů/stylů
- [ ] PDF export
- [ ] Animované psaní (postupné vykreslování)
