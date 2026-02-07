# Plán: Personalizované samolepky s ručním písmem

> Rekonstruováno z implementace - původní konverzace nejsou k dispozici.

## Kontext

**5. února 2026** - Kamarád měl nápad: ukázat ručně psané poznámky své dcery jako digitální samolepky.

**6. února 2026** - Dva kola "vibe coding":
1. Claude mobile - pochopení rozsahu a obtížnosti
2. Happy - implementace

---

## Problém k vyřešení

Jak převést jedinečné ručně psané písmo (např. dětské) na digitální samolepky, které lze použít v messaging aplikacích?

### Požadavky
- Zachovat autentický vzhled ručního písma
- Umožnit psaní libovolného textu
- Podpora českých znaků včetně diakritiky
- Export jako obrázek s průhledným pozadím
- Multiplatformní použití

---

## Navržené řešení

### Dvoustupňová pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│  FÁZE 1: Příprava glyphů                                        │
│                                                                 │
│  Šablona PDF → Ruční vyplnění → Sken → Extrakce → PNG glyphy   │
│       ↑              ↑           ↑         ↑          ↑        │
│    (Go)         (člověk)     (skener)   (Go)      (output)     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  FÁZE 2: Tvorba samolepek                                       │
│                                                                 │
│  PNG glyphy + Text → Kompozice → Stylizace → Export obrázku    │
│       ↑        ↑          ↑          ↑            ↑            │
│   (input)  (uživatel)  (Flutter)  (Flutter)    (output)        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technická architektura

### 1. Glyph Extractor (Go)

**Proč Go:**
- Rychlé zpracování obrazu
- Jednoduchý deployment (single binary)
- Dobrá podpora pro práci s obrázky

**Komponenty:**
- `template_generator.go` - generování PDF šablony
- `grid.go` - extrakce buněk z mřížky
- `charset.go` - definice znakové sady
- `main.go` - CLI rozhraní

**Šablona:**
- Formát A4, 2 strany
- Mřížka 8×10 políček (80 znaků/strana)
- Celkem 160 znaků (velká, malá písmena, čísla, interpunkce, speciální znaky)
- Políčko: 22.5 × 26.2 mm

### 2. Flutter aplikace

**Proč Flutter:**
- Jeden kód pro všechny platformy (iOS, Android, macOS, Linux, Windows, Web)
- Kvalitní rendering
- Rychlý vývoj UI

**Struktura:**
```
lib/
├── main.dart
├── models/
│   ├── glyph.dart          # Model znaku
│   └── style_params.dart   # Parametry stylizace
├── screens/
│   └── canvas_editor_screen.dart  # Hlavní obrazovka
├── services/
│   ├── glyph_loader.dart   # Načítání glyphů
│   ├── glyph_renderer.dart # Renderování textu
│   └── image_exporter.dart # Export obrázku
└── widgets/
    ├── handwritten_canvas.dart  # Plátno pro text
    ├── preset_selector.dart     # Výběr předvoleb
    └── style_params_panel.dart  # Panel stylizace
```

---

## Znaková sada

### Strana 1 (index 0-79): Velká písmena, čísla, interpunkce
```
A Á B C Č D Ď E | É Ě F G H I Í J | K L M N Ň O Ó P | Q R Ř S Š T Ť U
Ú Ů V W X Y Ý Z | Ž 0 1 2 3 4 5 6 | 7 8 9 . , ! ? : | ; - ( ) " ' / @
# & + = % * € $ | [ ] { } < > \ _
```

### Strana 2 (index 80-159): Malá písmena, speciální znaky
```
a á b c č d ď e | é ě f g h i í j | k l m n ň o ó p | q r ř s š t ť u
ú ů v w x y ý z | ž ~ ` ^ | © ® ™ | ° § ¶ • … – — „ | " ‚ ' « » × ÷ ±
¼ ½ ¾ ¹ ² ³ µ ¿ | ¡ ñ Ñ ß æ Æ ø Ø
```

---

## Workflow použití

### 1. Vytvoření glyphů (jednorázově)
```bash
# Vygenerovat šablonu
cd glyph_extractor
go build
./glyph_extractor template ../template.pdf

# Vytisknout, ručně vyplnit, naskenovat

# Extrahovat glyphy
./glyph_extractor --input page1.png,page2.png --output ./output
```

### 2. Tvorba samolepek (opakovaně)
```bash
cd handwritten_stickers
flutter run
```

Uživatel:
1. Načte glyphy z adresáře
2. Napíše text
3. Upraví styl (velikost, mezery, barva...)
4. Exportuje jako PNG

---

## Klíčová rozhodnutí

| Rozhodnutí | Volba | Důvod |
|------------|-------|-------|
| Formát šablony | PDF | Snadný tisk, přesné rozměry |
| Extrakční nástroj | Go | Rychlost, single binary |
| UI framework | Flutter | Multiplatformní |
| Formát glyphů | PNG s průhledností | Snadná kompozice |
| Mapování znaků | JSON manifest | Flexibilita, čitelnost |

---

## Možná budoucí rozšíření

- [ ] Více variant stejného znaku (přirozenější vzhled)
- [ ] Automatická detekce baseline a kerning
- [ ] Předvolby stylů (barvy, efekty)
- [ ] Přímé sdílení do messaging aplikací
- [ ] Cloud úložiště glyphů
