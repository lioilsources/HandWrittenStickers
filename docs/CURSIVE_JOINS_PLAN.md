# Plán: navázané písmo (cursive joins)

> Stav: implementováno (větev `cursive-joins`, `jessie_1` přegenerována).
> Odchylky od plánu níže:
> - bod je `[x, y, směr°]` (směr tahu pera), ne jen `[x, y]`; spojnice díky
>   tomu vybíhá ve směru pera;
> - malá písmena bez volného konce tahu (`a c d g o q`, `s`) se navazují v
>   nejlevějším / nejpravějším bodě kostry v pásmu těla písmene;
> - navíc `-snap-baseline` (každé malé písmeno bez dotahu sedí na účaří) a
>   `inkColor` v manifestu (barva pera pro spojnice);
> - sklon se odhaduje a opravuje jen u `b d f h k l t`;
> - `PositionedGlyph.join` místo samostatného typu `Connector`;
> - zalamování zůstalo po znacích (zalomení navázání přeruší); `laurinka`
>   zatím nepřevedena.

Cíl: u ručně psaných sad (`source: handwriting`, dnes `jessie_1`, později
`laurinka`) spojit písmena ve slově tahem, jako při psaní vázaným písmem, a
sjednotit velikost a sklon písmen, která byla napsána každé zvlášť do buňky
šablony.

Vzor: `jessie_1` – psací písmo, kde skoro každé malé písmeno má náběhový tah
zleva od účaří a výběhový tah vpravo (viz fotky `jess-1.JPG`, `jess-2.JPG` v
`~/Library/Mobile Documents/com~apple~CloudDocs/Dev/HandWrite/`, extrahováno
`glyph_extractor extract -input p1.jpg,p2.jpg -grid auto -output … -id jessie_1
-name "Jessie 1" -fallback caveat`).

## Proč to dnes nenavazuje

- `SheetBuilder.Write` (`glyph_extractor/sheet_builder.go`) dá každému glyfu
  `bearing = advance − width = 4 % em` na obou stranách. Výběh jednoho a
  náběh druhého písmene tak od sebe dělí ~8 % em vzduchu, a `Letter Spacing`
  v záporu je jen přiblíží, ale konce tahů se nepotkají (různá výška konců).
- `GlyphRenderer.layoutText` (`handwritten_stickers/lib/services/glyph_renderer.dart`)
  zná jen `baseline / advance / bearing`; neví, kde tah vstupuje a vystupuje.
- Každá buňka byla psaná zvlášť: x-výška a sklon kolísají (na fotce viz `m`
  vs. `n`, `k` vs. `h`), takže i přiložená písmena vypadají nesourodě.
- Tenké pero: tah má ~3 px při 300 dpi, spojnice musí mít stejnou tloušťku,
  jinak je vidět.

## Co se uloží do manifestu (v3, nové klíče jsou volitelné)

Na úrovni sady:

```json
"xHeight": 86,        // px, medián výšky malých písmen bez dotahů
"slantDeg": 18.5,     // sklon písma (kladný = doprava), medián přes malá písmena
"strokeWidth": 3.2    // px, medián tloušťky tahu
```

Na úrovni glyfu v `metrics` (stejně jako dnes v px relativně k levému hornímu
rohu PNG; u variant seznam jako dosud):

```json
"a": {"w": 92, "h": 65, "baseline": 59, "advance": 106, "bearing": 7,
      "entry": [3, 44], "exit": [89, 41]}
```

`entry`/`exit` chybí, když písmeno na té straně nenavazuje (většina
verzálek vpravo, `o`/`v`/`w` mají `exit` nahoře u x-výšky – to je v pořádku,
spojnice to vyřeší). Staré čtečky klíče ignorují, `glyph_sheets_test.dart`
jen ověří, že body leží uvnitř obrázku.

## Fáze 1 – extraktor (Go)

Nový soubor `glyph_extractor/joins.go`, volaný ze `SheetBuilder` před
`Write` (po `FitRowBaselines` a `NormalizeCapHeight`, a až po normalizaci
sklonu/velikosti níže, aby body odpovídaly výsledným PNG).

1. **Kostra a konce tahů.** Binarizovat alfa (> 128), Zhang–Suen thinning
   (~80 řádků, bez závislostí). Koncový bod = pixel kostry s jedním sousedem.
   Pracovat jen s největší souvislou komponentou (háčky a čárky jsou zvlášť
   a mají vlastní konce). Tloušťka tahu = 2× medián vzdálenostní
   transformace na kostře → `strokeWidth` jako medián přes sadu.
2. **`exit`** = koncový bod s největším x, jehož y je v pásu
   `[baseline − 1.2·xHeight, baseline + 0.15·xHeight]` a x ≥ 0.6·šířky.
   **`entry`** = koncový bod s nejmenším x ve stejném pásu a x ≤ 0.4·šířky.
   Nic nenalezeno → klíč se nevypíše. Písmena s křížením (`x`, `k`) mají
   víc konců; pravidlo největší/nejmenší x je vybere správně.
3. **Sklon.** Pro každé malé písmeno zkosit masku o θ ∈ ⟨−35°, 35°⟩ po 1° a
   vzít θ s nejmenší šířkou ink-projekce (standardní odhad sklonu z OCR).
   `slantDeg` = medián. Glyf, který se liší o více než 3°, zkosit kolem
   účaří zpět na medián (`xdraw` affine, Catmull-Rom). Nesrovnávat na
   svislici – sklon je součást rukopisu, jen se sjednocuje.
4. **x-výška.** Pro písmena bez dotahů (`aceimnorsuvwxz` + jejich diakritické
   varianty měřené bez horní komponenty) změřit vrch inku → `xHeight` =
   medián. Glyf mimo ±8 % škálovat rovnoměrně k mediánu, nejvýš o ±15 %
   (škálování zachová tloušťku tahu v poměru; větší odchylky nechat, jsou to
   chyby zápisu, které autor spíš přepíše). Písmena s dotahy neškálovat
   (nelze změřit jejich x-část spolehlivě).
5. **CLI.** `extract` a `upgrade` dostanou `-joins` (default zapnuto pro
   `-source handwriting`), `-fix-slant`, `-fix-xheight` (obě default zapnuto
   tamtéž, pro `fontset` vypnuto). `preview -marks` vykreslí body `entry`
   (zeleně) a `exit` (červeně) do kontaktního archu a ukázkovou větu
   vykreslí s navázáním (stejný algoritmus jako v appce, viz fáze 2) – díky
   tomu se dá výsledek ladit bez telefonu.
6. **Testy (`joins_test.go`).** Syntetický glyf tvaru „L“ s náběhem: očekávané
   `entry`/`exit`; zkosený obdélník → odhad sklonu ±1°; x-výška z tří masek
   dává medián; glyf bez konců v pásu nemá `exit`.

## Fáze 2 – renderer (Dart)

1. `GlyphMetrics` (`lib/models/glyph.dart`) + `GlyphLoader`: parsovat
   `entry`, `exit` (nullable), sadové `xHeight`, `slantDeg`, `strokeWidth`.
2. `StyleParams.joinLetters` (bool, default `true`); v `canvas_editor_screen`
   přepínač „Join letters“ v Advanced Settings, zobrazený jen když má sada
   `strokeWidth` (jinak nemá význam).
3. `layoutText`: držet `prevExit` (absolutní souřadnice po aplikaci
   `params.scale`, rotace kolem středu glyfu a posunu z baseline wobble –
   body transformovat stejnou maticí jako obrázek). Pro další glyf v tomtéž
   slově (mezi nimi nebyla mezera ani `\n`, oba mají body, žádný není
   `colored`, oba z téhož loaderu – fallback z Caveat nenavazuje):
   - `x` zvolit tak, aby `entry` přišel na `prevExit.x + style.letterSpacing`
     (`letterSpacing` tedy už neotvírá mezeru, ale prodlužuje spojnici;
     záporné hodnoty se ořežou na −0.3·strokeWidth, jinak se tahy překryjí).
   - Je-li `|entry − prevExit| > 0.5·strokeWidth·scale`, přidat
     `Connector` (nový typ vedle `PositionedGlyph`): kubická Bézierova křivka
     z `prevExit` do `entry`, tečny ve směru tahů (směr spočítat z posledních
     ~6 px kostry už v extraktoru a uložit jako úhel `exitDir`/`entryDir`,
     nebo jednodušeji: tečna vodorovná + sklon sady). Tloušťka
     `strokeWidth·scale`, kulaté konce, barva inkoustu, opacita jako
     předchozí glyf.
   - `kerningAdjust` se při navázání nepoužije.
   - Bez bodů (verzálky, interpunkce, fallback) zůstává dnešní chování.
4. `HandwrittenPainter` a `ImageExporter.renderFrame` musí kreslit spojnice
   stejně – vytáhnout kreslení do jedné funkce (`paintLayout`), aby se náhled
   a export nerozešly. GIF s emoji používá tutéž cestu.
5. Zalamování (`balanceLines`, `layoutText` při `x + advance > maxWidth`):
   šířku slova počítat z pozic po navázání; nejjednodušší je nejdřív
   rozložit slovo do bufferu a až celé slovo umístit/zalomit.
6. Testy (`glyph_renderer_test.dart`): falešné glyfy s `entry`/`exit` →
   origin druhého = `prevExit − entry·scale`; spojnice vzniká jen při
   rozdílu výšek; přes mezeru se nespojuje; `letterSpacing` prodlužuje
   spojnici; při `sizeVariance`/`rotationVariance` sedí body na
   transformovaný obrázek (ověřit přes stejnou matici); `joinLetters: false`
   vrací dnešní layout beze změny (regresní test na existující očekávání).

## Fáze 3 – data a ověření

1. Přegenerovat `jessie_1` z fotek příkazem výše (přidat flagy z fáze 1),
   `preview -marks`, prohlédnout body na všech 160 znacích; špatně
   detekované konce opravit pravidly, ne ručně v JSON.
2. `laurinka` je manifest v1 (neořezané buňky): `upgrade` ji převede na v3
   a může přidat body; dělat až po `jessie_1`, je to méně vhodný rukopis
   (tiskací).
3. Ověřit v appce přes screenshot harness
   (`SCREENSHOT_DIR=… flutter test test/screenshots_test.dart`) větu
   „Příliš žluťoučký kůň úpěl ďábelské ódy“ a „Jess chce písmo vázaný“,
   s presetem Neat i Chaotic (rotace glyfů nesmí spojnice roztrhat).
4. Aktualizovat `CLAUDE.md` (klíče manifestu v3, `joins.go`, `Connector`) a
   `docs/RELEASE_PLAN.md`.
5. Merge do `main` přes PR, tag `v1.0.3`, znovu nasadit olin.now.

## Mimo rozsah (zmínit, neřešit)

- Posuvník tloušťky pera (dilatace masky) – snadné doplnění nad
  `strokeWidth`, ale samostatný krok.
- Kontextové varianty (jiné `s` na konci slova) – manifest v3 varianty umí,
  chybí jen výběr podle pozice ve slově.
- Fallback glyfy z fontu (Caveat) nikdy nenavazují; ať zůstane vidět, že
  jde o jiný rukopis.

## Rizika

- Detekce konců u písmen s okem na výstupu (`s`, `š`, `b`) – konec tahu je
  uvnitř smyčky; pás a podmínka x ≥ 0.6·šířky to většinou vyřeší, jinak
  vzít místo koncového bodu nejpravější bod kostry v pásu.
- Diakritika spojená s tělem (nízko napsaný háček) – komponenta není
  oddělená; omezit pás shora `baseline − 1.2·xHeight`, nad ním konce ignorovat.
- Rotace glyfů (`rotationVariance`) s navázáním: body se otáčejí s glyfem,
  spojnice to vstřebá, ale při vysoké hodnotě to vypadá nepřirozeně – preset
  Chaotic může při `joinLetters` rotaci zmenšit na polovinu.
