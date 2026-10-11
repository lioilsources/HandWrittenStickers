# Nalezené písmo z fotek (plán 02, sekce 5)

Písmena z věcí – křída, LEGO, těstoviny, výšivka, vystřižený papír – se
fotí ve stejné mřížce jako ručně psaná šablona a zpracují se stejným
extraktorem, jen s klíčováním podle barvy pozadí.

## 1. Příprava

- Vytisknout šablonu: `cd glyph_extractor && ./glyph_extractor template sablona.pdf`
  (A4, 8×10 políček, 2 strany = 160 znaků; pořadí znaků je vytištěné šedě).
- Políčko má 22,5 × 26,2 mm. Znak by měl zabrat asi ⅔ výšky a nesmí přesahovat
  čáry. Modrá čárkovaná čára je účaří – na ni pokládat spodek písmen
  (ocásky g, j, p, y pod ni).
- Pozadí musí být jednobarevné a jiné než materiál. Bílý papír šablony se
  hodí pro tmavé a barevné věci; pro bílé materiály (těstoviny, křída)
  šablonu vytisknout na barevný papír nebo pod věci dát tmavou podložku a
  mřížku jen přiložit při focení.

## 2. Focení

- Shora, kolmo, celý list v záběru; mobil v režimu bez širokoúhlého objektivu.
- Rozptýlené světlo (u okna, bez přímého slunce, bez blesku) – stíny pod
  předměty se jinak vyklíčují jako součást znaku.
- Dvě fotky na stranu šablony stačí; menší rozlišení než 12 Mpx nevadí.

## 3. Zpracování

```bash
cd glyph_extractor
./glyph_extractor -input str1.jpg,str2.jpg -grid auto \
    -bg-mode chroma -bg-tolerance 16 -colored -source material \
    -output ../handwritten_stickers/assets/glyphs/found_lego -id found_lego -name "LEGO" \
    -fallback caveat
./glyph_extractor preview ../handwritten_stickers/assets/glyphs/found_lego -out lego.png
```

- `-grid auto` najde mřížku sama; když selže (silně šikmá fotka), fotku
  nejdřív narovnat v aplikaci (macOS, záložka Grid Alignment) a použít
  `-grid template`.
- `-bg-mode chroma` vezme barvu pozadí z rohů každého políčka; pevnou barvu
  lze zadat `-bg-color '#23402f'` (tabule). `-bg-tolerance` zvětšit, když
  v náhledu zůstává šum papíru, zmenšit, když mizí světlé části předmětů.
- `-cap-ratio 0.70` (výchozí) srovná velikost podle písmene H.
- `-colored` říká aplikaci, že glyphy mají vlastní barvy.

## 4. Do aplikace

Adresář sady přidat do `handwritten_stickers/pubspec.yaml` (`assets:`) a do
`assets/glyphs/sheets.json`:

```json
{ "id": "found_lego", "name": "LEGO", "path": "assets/glyphs/found_lego/",
  "source": "material", "category": "material" }
```

Fotky vlastních věcí jsou vlastní dílo; u fotek cizích nápisů (výlohy,
cedule) řešit práva k podobě písma před vydáním – do té doby `"bundle": false`.
