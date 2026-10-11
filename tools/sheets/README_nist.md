# NIST SD19 → sady rukopisu (plán 02, sekce 3, D1–D6)

`nist.py` vybere z NIST Special Database 19 čitelné pisatele a pro každého
vyrobí `candidates.json`, ze kterého Go příkaz `assemble` postaví glyph sheet.
Potřebuje jen Python 3 + Pillow (`python3 -m pip install --user Pillow`).

## Stažení

- Stránka: https://www.nist.gov/srd/nist-special-database-19
- `by_class.zip` – https://s3.amazonaws.com/nist-srd/SD19/by_class.zip (1,03 GB, ~1,55 M souborů) – **stačí tento**
- `by_write.zip` – https://s3.amazonaws.com/nist-srd/SD19/by_write.zip (568 MB) – není potřeba, nemá štítky
- Uživatelská příručka 2. vydání: https://s3.amazonaws.com/nist-srd/SD19/sd19_users_guide_edition_2.pdf
- Seznamy souborů: `https://s3.amazonaws.com/nist-srd/SD19/by_class_md5.log`, `by_write_md5.log`

Licence: public domain (dílo vlády USA). Do `SOURCE.md` se zapisuje „NIST SD19, writer id“ (D6).

## Struktura dat (2. vydání, ověřeno z md5 logů a z reálného `.mit` souboru)

```
sd19/2ndEdition2016/data/
  by_write/hsf_0/f0000_14/{d,u,l,c}0000_14/d0000_14_00000.png   # bez štítků!
  by_class/<hex>/hsf_<N>/hsf_<N>_<i>.png                         # 128×128, RGB, černá 0 / bílá 255
  by_class/<hex>/hsf_<N>.mit                                     # původ každého PNG
  by_class/<hex>/train_<hex>/...                                 # duplikát hsf_{0,1,2,3,6,7}, ignoruje se
```

- `<hex>` = ASCII kód třídy malými písmeny: `30`–`39`, `41`–`5a`, `61`–`7a` (62 tříd).
- Oddíly: `hsf_0,1,2,3,4,6,7` (hsf_4 = studenti, ostatní úředníci Census Bureau; `hsf_5` neexistuje).
- Pisatel = adresář `f<čtyři číslice>_<číslo šablony formuláře>`, např. `f3600_46`
  (číslo pisatele je jedinečné, přípona je typ formuláře).
- Pole (první písmeno podsložky): `d` číslice, `u` verzálky, `l` minusky, `c` volný text (Preambule).
- `.mit` = počet řádků a pak `hsf_7_00000.png f3600_46/d3600_46/d3600_46_00007.png`
  (PNG v by_class → zdrojové PNG v `by_write/hsf_7/`). V 2. vydání `by_write` **nemá `.cls`**,
  takže třída znaku je jen v `by_class` a pisatel jen v `.mit`. Proto skript čte by_class.

Zdroje: příručka 2. vydání (sekce 1.2, 2.2, 2.4), příručka 1. vydání
https://s3.amazonaws.com/nist-srd/SD19/1stEditionUserGuide.pdf (sekce 6.3 „.cls“, 6.4 „.mit“),
a první řádky skutečného `by_class/37/hsf_7.mit` staženého range requestem ze zipu.

## Použití

```bash
# D2: index všech pisatelů (adresář nebo přímo zip; zip netřeba rozbalovat)
python3 tools/sheets/nist.py index ~/data/by_class.zip --out nist/index.json --jobs 8

# ruční kontrola: kontaktní arch (1 nejčistší vzorek na třídu) pro 40 nejlepších
python3 tools/sheets/nist.py contact nist/index.json --top 40 --out nist/contact/

# D4: export pisatele (3–5 variant na znak)
python3 tools/sheets/nist.py export nist/index.json --writer hsf_0/f0000 --variants 5 \
    --upscale 2 --out nist/hsf_0_f0000
glyph_extractor assemble nist/hsf_0_f0000/candidates.json -output SHEET \
    --id nist_hsf_0_f0000 --name "Rukopis č. 1"
```

`--writer` bere `hsf_0/f0000`, `hsf_0/f0000_14`, `f0000` nebo pořadí v žebříčku `#3`.

## Skóre

- **Čistota obrázku** (0–1): podíl inkoustu v rozumném pásmu (0,8–16 %), bbox inkoustu
  se nedotýká okraje 128 px (jinak ×0,2 = oříznutý tah), jedna dominantní souvislá složka
  (u `i`, `j` dvě; počítá se na 32×32, takže drobné mezery v tahu nevadí), prázdné/mini
  bboxy ≈ 0. Vzorky z volného textu (`c`) mají ×0,9.
- **Pisatel**: `1 + průměrná čistota`, pokud má všech 62 tříd; jinak `0,5 × pokrytí/62 + čistota`
  (neúplní jsou vždy pod úplnými). Index drží na třídu jen `--keep` (8) nejlepších vzorků.

## Export (formát candidates.json)

Každý vzorek: 128 px binární → RGBA, černý inkoust v alfě, průhledné pozadí, ořez na bbox
inkoustu + 2 px. `--upscale 2|3`: LANCZOS + lehké Gaussovo rozostření a zúžení přechodu
(potrace se nepoužívá, D3 porovnání cest zůstává otevřené). `bbox` = bbox inkoustu v 128 px
obrázku × upscale, `line` = 0, `order` = pořadí, `baseline` chybí (odhadne `assemble`).
Navíc je u kandidáta klíč `nist` (zdrojový soubor, origin, čistota) – Go ho ignoruje.
Do výstupu se zapisuje `SOURCE.md`. Interpunkce a diakritika v SD19 nejsou (D4 fallback, D5).
