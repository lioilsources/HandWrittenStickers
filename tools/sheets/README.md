# Nástroje pro sady glyphů mimo fonty

Plán: [Prompts/02-GLYPH_SOURCES_PLAN.md](../../Prompts/02-GLYPH_SOURCES_PLAN.md).
Všechny cesty vedou do stejného formátu sady (`glyphs.json` v2/v3 + PNG s alfou,
viz CLAUDE.md „Glyph Sheets“). Go příkazy spouštějte z `glyph_extractor/`
(`go build` jednou předem).

| Zdroj | Nástroje | Výstup |
|-------|----------|--------|
| Vyplněná šablona (fotka) | `extract -grid auto` | v2 s metrikami |
| Materiálové písmo (AI) | `material.py` → `extract -bg-mode chroma -colored` | v2, `colored` |
| Volný list rukopisu | `template -pangram` → `segment` → `label.html` → `assemble` | v3 s variantami |
| Dataset NIST SD19 | `nist.py` → `assemble` | v3 s variantami, skládaná diakritika |
| Archivy | viz [docs/ARCHIVE_SOURCES.md](../../docs/ARCHIVE_SOURCES.md), pak `segment` | v3 |
| CuteKidFonts (bublinky) | `tools/kid_sheets/build.sh` | v2, bublinkové sady `colored` |
| Nalezené písmo (fotky) | viz [docs/found_type.md](../../docs/found_type.md) | v2, `colored` |

Kontrola každé sady: `./glyph_extractor preview <sada> -out náhled.png`
(kontaktní arch se všemi variantami na účaří + ukázkový text, vykreslený
stejně jako v aplikaci).

## Vyplněná šablona

```bash
./glyph_extractor -input str1.jpg,str2.jpg -grid auto -bg-mode chroma -bg-tolerance 22 \
    -output ../handwritten_stickers/assets/glyphs/<id> -id <id> -name "Jméno" -fallback caveat
```

- `-grid auto` najde vytištěnou mřížku 8×10 ve fotce (i mírně šikmé) a každou
  buňku narovná; `-grid template` (výchozí) čeká zarovnaný sken 300 DPI
  z nástroje Grid Alignment.
- `-bg-mode chroma` klíčuje podle barvy papíru (vzorek z rohů buňky) – nutné
  pro barevný inkoust (fialová fixa) a materiály. `lightness` (výchozí) je
  původní klíčování tmavého inkoustu, `alpha` bere hotovou alfu z PNG.
- `-fit-baseline` (výchozí zapnuto) najde skutečné účaří v každém řádku
  (medián spodků písmen), takže nevadí, že pisatel nepsal přesně na čáru.
- `-cap-ratio 0.70` sjednotí velikost s fontovými sadami (výška H = 0,70 em).
- Znaky, které pisatel nevyplnil, doplní aplikace z `-fallback` sady.

Stará v1 sada z neořezaných buněk se dá převést bez fotek:
`./glyph_extractor upgrade <sada>` (ořízne, dopočítá metriky; buňky ale musí
být vyříznuté ze správně zarovnaného skenu).

## Materiálové písmo (ComfyUI)

```bash
echo COMFY_URL=http://192.168.88.66:8188 > tools/comfy/.env   # SPARK v LAN, okno 07–13, dávku ohlásit Directorovi
python3 tools/comfy/client.py inventory --out tools/comfy/inventory.json
python3 tools/sheets/material.py list
python3 tools/sheets/material.py all --material plasticine
python3 tools/sheets/material.py generate --material plasticine --cells 1:r3c5 --seed 9   # oprava buňky
python3 tools/sheets/material.py register --material plasticine   # sheets.json (bundle:false) + pubspec
```

- `materials.json`: prompt, vodicí font, pozadí a síla denoise/ControlNetu
  pro každý materiál; `defaults` obsahuje část názvu checkpointu
  (`sd_xl_base_1.0`) a ControlNetu (`controlnet-union-sdxl-promax-xinsir`,
  režim canny přes `SetUnionControlNetType`). Přesný soubor se dohledá
  na serveru přes `/models`. SDXL base má licenci OpenRAIL++ (komerční
  výstup povolen); Juggernaut a spol. mají vlastní licence, ověřit.
- `workflows/material.json` je ve formátu *Save (API Format)*; skript plní uzly
  podle titulků (`Guide`, `Positive`, `Negative`, `Sampler`, `ControlNet`,
  `Scale`, `Checkpoint`, `ControlNet Model`, `Save`). Workflow lze nahradit
  vlastním (Flux + ControlNet Union, BiRefNet…), pokud titulky zůstanou.
- Arch se generuje po pásech 4 + 4 + 2 řádky buněk, výsledek se vrací
  do přesné geometrie šablony, takže `extract` funguje beze změny.
- `--dry-run` vyplní workflow a nařeže pásy bez serveru (kontrola).
- Do sady se zapisuje `SOURCE.md` (model, prompt, seedy). Licence modelu
  rozhoduje o komerčním použití; do ověření `bundle: false`.

## Vlastní rukopis z volného listu (S1, S2)

```bash
./glyph_extractor template -pangram pangram.pdf      # + pangram.txt s přepisem řádků
# vytisknout, obtáhnout perem, vyfotit shora (Grid Alignment jen narovná)
./glyph_extractor segment -input foto.png -output list/ -labels-file pangram.txt
open ../tools/sheets/label.html                       # vybrat složku list/, opravit, stáhnout labels.json
./glyph_extractor assemble list/candidates.json -labels list/labels.json \
    -output ../handwritten_stickers/assets/glyphs/<id> -id <id> -name "Jméno" -fallback caveat
```

- `segment`: binarizace (Otsu), spojité komponenty, připojení diakritiky,
  teček a dvojteček k písmenu, řádky, odhad účaří. Když počet kandidátů
  na řádku sedí s přepisem, jsou rovnou označené; jinak se řádek nechá
  k ručnímu označení (typicky `"`, `%` nebo slité písmeno).
- `-labels "řádek 1\nřádek 2"` pro známý text, `-ocr tesseract` (jazyk `ces`,
  `brew install tesseract tesseract-lang`) pro neznámý.
- `label.html`: klávesa = znak, Backspace zpět, mezera = přeskočit, pole pro
  vložení celého řádku, tlačítka `caron`/`acute`/`ring` pro samostatné akcenty.
  Chybějící id v `labels.json` = použije se štítek z `candidates.json`.
- `assemble`: každé písmeno až 5 variant (`-variants`), velikost podle H
  (nebo x-výšky), chybějící česká písmena se složí ze základu a akcentu
  (`compose` v manifestu), z `i` se vyrobí `ı` bez tečky pro `í`.

## Akcenty pro skládání (D5)

Napsat na papír několikrát ˇ ´ ˚ (různé tloušťky pera), `segment`, v
`label.html` označit tlačítky, pak
`assemble … -output ../handwritten_stickers/assets/glyphs/_accents -id _accents -cap-ratio 0`.
Sady bez vlastních akcentů je převezmou přes `assemble -accents <cesta k _accents>`.

## NIST SD19

Viz [README_nist.md](README_nist.md): `nist.py index/contact/export`, pak
`assemble … -source dataset -fallback caveat -accents …/_accents`.

## CuteKidFonts

`tools/kid_sheets/build.sh` vykreslí znaky přímo malířem knihovny
CuteKidFonts (`KidBubblePainter`, tedy stejný bublinkový efekt jako v jejich
appkách) přes `flutter test` a pak je složí `assemble`. Seznam sad, názvy,
licence a `capRatio` jsou v `tools/kid_sheets/sheets.json`. Bublinky mají
`capRatio` 0,88, protože obrys a 3D vysunutí se počítají do výšky H.
Potřebuje repo `CuteKidFonts` vedle tohoto repa (path závislost jen
v nástroji, aplikace na balíčku nezávisí).
