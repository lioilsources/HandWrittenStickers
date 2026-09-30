# Plán: zdroje znaků mimo fonty

Zadání pro Opuse. Navazuje na `RELEASE_PLAN.md` (formát sad, úkol T3) a
`EMOJI_PLAN.md` (klient ComfyUI, Cloudflare Access). Cíl: sady glyphů,
které nejdou získat z TTF fontů: materiálové písmo (hlína, neon, perník),
rukopis napodobený z jedné věty, reálný rukopis z datasetů a archivů,
„nalezené“ písmo z fotek a vlastní rukopis bez vyplňování šablony.

Formát sady je na to připravený: adresář PNG s alfou + `glyphs.json`
s metrikami (viz CLAUDE.md, „Glyph Sheets“). Renderer kreslí původní barvy
glyphů, takže barevné materiálové písmo funguje bez změny vykreslování.

## 0. Co je hotové a co chybí

Hotové: `fontset` (font → sada v2 s metrikami), extraktor z mřížky
(`--input`, sken šablony → sada v1 bez metrik), Grid Alignment nástroj
(fotka → zarovnaný A4 PNG), přepínač sad po kategoriích, testy assetů.

Chybí a je společné pro všechny zdroje níže (sprint A):

| # | Úkol | Proč |
|---|------|------|
| A1 | **Metriky i z mřížky** (`--input` zapisuje manifest v2): `baseline = 0,75·cellH − trimRect.Min.Y`, `advance = šířka ořezu + 2·padding`, `bearing = padding`, `emHeight = 0,62·cellH`; navíc normalizace velikosti podle buňky „H“ jako ve `fontset` (`-cap-ratio`). | Bez toho se každá skenovaná sada chová „monospace“ (dnešní Laurinka). Je to T3 z release plánu. |
| A2 | **Varianty znaku** (manifest v3): `glyphs: {"a": ["a.png", "a_1.png", …]}` nebo samostatné pole `variants`; loader načte všechny, renderer vybírá deterministicky z `Random(text.hashCode)` přes už existující `GlyphParams.variantIndex`. v1/v2 (řetězec místo pole) zůstává platné. Test: dvě „a“ ve slově dostanou různé varianty, stejný text dá stejný výsledek. | Reálný rukopis vypadá živě jen s více vzorky na písmeno. Datasety jich dávají desítky. |
| A3 | **Segmentační režim extraktoru** `glyph_extractor segment --input page.png --output DIR`: binarizace (Otsu), spojité komponenty + spojení diakritiky s písmenem pod ní (háček/čárka = malá komponenta nad větší v toleranci 0,6·výška), řádky projekčním profilem, výstup `candidates/NNNN.png` + `candidates.json` (bbox, řádek, pořadí). Označení znaků: (a) `--labels "text řádku 1\ntext řádku 2"` když je známý přepis, znaky se párují v pořadí; (b) `--ocr tesseract` (jazyk `ces`); (c) ruční: jednoduchá lokální HTML stránka `tools/sheets/label.html` (kandidát → klávesa). Výsledek `glyph_extractor assemble candidates.json labels.json → sada v3`. | Archivy, volný list vlastního rukopisu a výstupy rukopisných modelů nejsou v mřížce. |
| A4 | **Odstranění pozadí pro barevné glyphy**: `MakeTransparent` dnes klíčuje podle světlosti (tmavý inkoust na bílé). Přidat `--bg-mode lightness|chroma|alpha`: `chroma` klíčuje podle referenční barvy pozadí (vzorek z rohu buňky, tolerance v Lab), `alpha` bere hotovou alfu z PNG (když pozadí odstranil BiRefNet/RMBG v ComfyUI). Ořez (`TrimWhitespace`) musí u `chroma`/`alpha` hledat alfu, ne tmavé pixely. | Materiálové písmo a fotky mají barvu i stíny; světlostní práh je zničí. |
| A5 | **Kategorie `material`** v `sheets.json` + `SheetCategory.material` (popisek „Materiál“) a pole `colored: true` v manifestu (renderer u barevných sad ignoruje budoucí `inkColor`). | Nové sady nejsou ani rukopis, ani typografie. |
| A6 | **Skládání diakritiky**: manifest může místo glyphu „č“ deklarovat `compose: {"č": ["c", "caron"]}` s glyphy akcentů (`caron`, `acute`, `ring`); renderer akcent umístí nad základní glyph (střed na střed, mezera 0,08·em, u verzálek výš), metriky dědí ze základu. Řeší se přes NFD rozklad vstupu (i B7 z release plánu). | Datasety a rukopisné modely česká písmena neznají. |
| A7 | **Sdílený klient ComfyUI** `tools/comfy/client.py` (queue, wait, download, upload, hlavičky Cloudflare Access) používaný emoji i archy. | Aby se kód nepsal dvakrát. |

Odhad sprintu A: 3–4 dny. A1, A2, A5 jsou nutné pro všechno; A3, A4, A6
jen pro zdroje, které je vyžadují (viz tabulka na konci).

## 1. Materiálové písmo přes ComfyUI (priorita 1)

Idea: existující šablonu (mřížka 8×10, 2 strany) vyrenderovat s písmeny
v čistém fontu jako vodicí obrázek a nechat difuzní model písmena
„přematerializovat“. Výstup jde do stávajícího extraktoru jako sken.

- [ ] **M1 Vodicí arch**: `glyph_extractor template --guide FONT.ttf --out guide_p1.png,guide_p2.png` vyrenderuje obě strany do 2480×3508 px s písmeny ze zadaného fontu (tučný bezpatkový, např. Bebas Neue nebo Kalam pro rukopisný charakter), bez šedých popisků buněk, bez čar účaří. Mřížku vykreslit jen do samostatné masky `grid_mask.png` (pro ControlNet, ne do vodicího obrázku).
- [ ] **M2 Workflow** `tools/sheets/workflows/material.json` (export API formát):
  img2img z vodicího archu, `denoise` 0,55–0,75 (tvar písmen zůstane, materiál se změní), ControlNet Canny/Lineart z vodicího archu síla 0,6–0,9 (drží polohu v buňkách), prompt materiálu, negativ `text, letters merged, shadow, background texture, watermark`. Model: podle inventury (Flux dev + ControlNet Union, nebo SDXL + Canny ControlNet + 3D LoRA ze serveru). Rozlišení: arch po dlaždicích (`Tiled` sampler nebo generovat po 4 řádcích, 2480×1400 px), protože celý A4 v 300 DPI většina modelů neutáhne.
- [ ] **M3 Materiály** (každý = vlastní sada, id `mat_<x>`): modelína (`plasticine letters, fingerprints`), perník (`gingerbread cookie letters with white icing outline`), neon (`neon tube letters glowing, on white`), dřevo (`carved wooden letters`), balónky (`inflated foil balloon letters, gold`), sníh/led, mech, křída na tabuli (tmavé pozadí, `bg-mode chroma`), LEGO kostky, výšivka, kamínky, těstoviny. Začít třemi: modelína, perník, neon.
- [ ] **M4 Pozadí**: generovat na čistě bílé, bez stínu; při extrakci `--bg-mode chroma` (bílá) nebo do workflow přidat BiRefNet a exportovat PNG s alfou → `--bg-mode alpha`.
- [ ] **M5 Extrakce a metriky**: `glyph_extractor --input p1.png,p2.png --bg-mode … --output …` (po A1 dává v2 metriky) → `sheets.json` s kategorií `material`, `colored: true`.
- [ ] **M6 Kontrola**: kontaktní arch v 64 px, čitelnost ≥ 150/160 znaků (drobné symboly ¶ § ‰ smí být horší), stejná velikost napříč buňkami (odchylka výšky „H“ < 15 %), žádné slité dvojice. Nepovedené buňky přegenerovat samostatně (inpaint jedné buňky se stejným seedem).
- [ ] **M7 Licence**: zapsat model do `assets/glyphs/<id>/SOURCE.md` (model, LoRA, seed, prompt). Komerční použití výstupu ověřit stejně jako u emoji (Flux dev vs. Qwen-Image/SDXL).

Odhad: 2 dny na první tři materiály včetně ladění, pak ~1 h/materiál.

## 2. Rukopis napodobený z jedné věty (priorita 2)

Řeší původní problém: místo 160 políček stačí, aby člověk napsal pár řádků.

- [ ] **H1 Výběr modelu**: One-DM (one-shot, ICCV 2024), DiffusionPen, VATr++, HWT. Žádný není standardní ComfyUI uzel; počítat s během jako samostatný Python proces na stejném GPU (docker v `tools/hwgen/`). Kritéria: běží na dostupné VRAM, licence povoluje komerční použití výstupů (One-DM: MIT kód, ale trénováno na IAM → výstup ověřit; při pochybnostech použít jen pro rodinu/testování, ne do App Store).
- [ ] **H2 Vstup**: fotka 3–5 řádků rukopisu (Grid Alignment nástroj umí i volný obdélník) → segmentace řádků (A3) → referenční výřezy slov.
- [ ] **H3 Generování**: modely tvoří slova, ne znaky. Generovat seznam slov pokrývající celou sadu, každé písmeno v ≥ 5 slovech („banán“, „máma“, …), pak segmentace (A3) s `--labels` (přepis je známý), varianty (A2).
- [ ] **H4 Diakritika**: anglicky trénované modely české znaky neumí → základní písmeno z modelu + akcent z referenční fotky (uživatel napíše „č ř ů“ zvlášť) přes skládání (A6).
- [ ] **H5 Kvalita**: porovnat s ručně vyplněnou šablonou stejné osoby (Laurinka) na 20 slovech, hodnotí uživatel; cíl „poznám, čí to je“.

Odhad: 3–5 dní, z toho polovina zprovoznění modelu. Vysoké riziko, viz níže.

## 3. Datasety reálného rukopisu (priorita 3)

- [ ] **D1 Zdroj**: NIST Special Database 19 (public domain, 128×128 px, ~810 k znaků, čísla, verzálky, minusky, s identifikátorem pisatele `hsf_*/f####`). EMNIST je z něj odvozený a menší (28×28), nepoužívat. IAM, CVL, RIMES: jen nekomerční licence, vynechat.
- [ ] **D2 Stažení a index** `tools/sheets/nist.py`: rozbalit, seskupit podle pisatele, pro každého spočítat pokrytí (musí mít všech 62 tříd) a „čistotu“ (poměr inkoustu, žádné oříznuté tahy). Vybrat 20 pisatelů s nejčitelnějším písmem (skóre + ruční pohled na kontaktní arch).
- [ ] **D3 Kvalita obrázku**: 128 px binární → vektorizace (potrace) → render 300 DPI s mírným rozostřením hran, nebo `MakeTransparent` s přechodovou zónou. Porovnat obě cesty na 64 a 240 px.
- [ ] **D4 Sada na pisatele**: id `nist_<hsf>_<f>`, název „Rukopis č. N“, 3–5 variant na znak (A2), interpunkce a symboly v SD19 nejsou → doplnit z jedné neutrální rukopisné sady (Caveat) a označit v manifestu `fallback: "caveat"`; renderer u chybějícího znaku sáhne do fallback sady.
- [ ] **D5 Diakritika** skládáním (A6): akcenty nakreslit ručně jednou (3 tvary × 3 tloušťky pera) do `assets/glyphs/_accents/`.
- [ ] **D6 Licence**: public domain, do `SOURCE.md` zapsat „NIST SD19, writer id“.

Odhad: 2 dny. Nízké riziko, největší přínos pro „živý“ vzhled.

## 4. Archivní rukopisy a tisky (priorita 4, výzkum)

- [ ] **R1 Průzkum zdrojů** (½ dne, výstup tabulka do tohoto dokumentu): Manuscriptorium (API, licence per dokument), Kramerius NK ČR (IIIF, veřejná díla), Europeana API (filtr `REUSABILITY:open`), Wikimedia Commons (kategorie „Letters in Czech“, PD-old). Pro každý: formát skenu, rozlišení, licence, jestli jde stáhnout strojově.
- [ ] **R2 Kandidáti**: kurent (německá novogotická kurziva) z 19. století, školní krasopis z prvorepublikových sešitů, dopisy spisovatelů (ověřit, že autor zemřel před > 70 lety), tištěná fraktura a švabach (tisk je pro segmentaci nejjednodušší).
- [ ] **R3 Pipeline**: sken → Grid Alignment (jen narovnání) → `segment` (A3) → přepis (`--labels`, když je v archivu transkripce; jinak ruční označení v `label.html`) → varianty (A2) → sada, kategorie `calligraphy` (kurent) nebo `typography` (fraktura).
- [ ] **R4 Rozsah**: 2 sady (jedna psaná, jedna tištěná) jako důkaz, každá 2–4 h ručního označování.
- [ ] **R5 Právo**: dílo volné ≠ sken volný; u každého zdroje zapsat podmínky do `SOURCE.md`. Bez jasného „open“ nepoužívat v App Store.

## 5. Nalezené písmo z fotek (priorita 5, skoro bez kódu)

- [ ] **F1 Návod** `docs/found_type.md`: vytisknout šablonu, do políček položit nebo napsat znaky (křída, LEGO, těstoviny, výšivka), vyfotit shora při rozptýleném světle, Grid Alignment → extraktor s `--bg-mode chroma` (barva pozadí vzorkem) a `-cap-ratio`.
- [ ] **F2 Test** na jedné sadě (např. LEGO nebo nůžkami vystříhaný papír), kategorie `material`.

## 6. Vlastní rukopis z volného listu (spojuje A3 + A6)

- [ ] **S1** V aplikaci (macOS) „Import z fotky textu“: fotka popsaného listu + přepis textu → `segment --labels` → sada. Přepis lze získat i OCR (Tesseract `ces`) s ruční opravou.
- [ ] **S2** Pangram k napsání, který pokryje sadu: „Příliš žluťoučký kůň úpěl ďábelské ódy“ + verzálky + číslice + interpunkce ≈ 4 řádky. Vytisknout jako linkovaný list s předtištěným textem šedě k obtažení (pomáhá segmentaci: známé pořadí znaků).

## 7. Pořadí pro Opuse

1. Sprint A: A1, A2, A5, A7 (2 dny). Přegenerovat Laurinčinu sadu s
   metrikami ze zarovnaných skenů (fotky v `glyph_extractor/matrix/` projít
   Grid Alignment nástrojem). Testy: metriky u všech sad, varianty.
2. Materiály M1–M7 na třech materiálech (2 dny). První viditelný výsledek.
3. Datasety D1–D6 (2 dny) a s nimi A6 (skládání diakritiky).
4. A3 segmentace + S1/S2 vlastní rukopis z listu (2 dny). To přímo řeší
   „nemám lidi na vyplnění archu“.
5. H1–H5 rukopis z jedné věty (3–5 dní, jen pokud 4 nestačí).
6. R1 průzkum archivů (½ dne), zbytek podle výsledku.

| Zdroj | Potřebuje z A |
|-------|---------------|
| Materiály | A1, A4, A5, A7 |
| Rukopis z věty | A1, A2, A3, A6, A7 |
| Datasety | A1, A2, A6 |
| Archivy | A1, A2, A3 |
| Fotky | A1, A4, A5 |
| Vlastní list | A1, A2, A3, A6 |

## 8. Rizika

- **Difuzní modely slévají písmena v mřížce** nebo mění tvar znaku (ď → d):
  držet nízké `denoise`, silný ControlNet, generovat po dlaždicích, sporné
  buňky inpaintovat samostatně; diakritiku kontrolovat zvlášť (háček vs.
  čárka je pro model detail).
- **Rukopisné modely** jsou výzkumný kód: závislosti, VRAM, anglický trénink.
  Proto priorita až po datasetech a segmentaci.
- **Segmentace** slitého psacího písma (kurent, kurzíva) spojité komponenty
  nerozdělí; pro tyto zdroje počítat s ručním dořezáním v `label.html`
  (posuvníky hranic) nebo se omezit na tištěné a nespojované písmo.
- **Velikost aplikace**: každá nová sada ≈ 0,4 MB (barevné materiálové až
  1,5 MB). Rozhodnutí z release plánu R0 (nižší DPI / On-Demand Resources)
  udělat před sprintem 2.
- **Právo**: u každé sady `SOURCE.md` se zdrojem, licencí a (u AI) modelem
  a promptem; sady bez jasné licence zůstávají mimo release build (flag
  `bundle: false` v `sheets.json`, test ho respektuje).
