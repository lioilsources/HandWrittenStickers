# Plán: animované 3D emoji postavičky (tag poznámky)

Zadání pro Opuse. Každou odeslanou poznámku (samolepku) jde otagovat jednou
emoji. Emoji není Unicode, ale vlastní 3D animovaná postavička s jasným
gestem, vygenerovaná přes ComfyUI na `comfyui.ol1n.com`.

Stav k 2026-09-29: server je za Cloudflare Access (bez tokenu vrací
přihlašovací stránku), takže inventura modelů zatím neproběhla. Plán je
proto napsaný jako rozhodovací strom: fáze 0 zjistí, co na serveru je, a
podle tabulky v každé fázi se vybere konkrétní model.

Strojově čitelný seznam gest: [`emoji/gestures.json`](emoji/gestures.json)
(50 core + 11 rezervních, každé s `motion_prompt` pro video model).

## 1. Produktové rozhodnutí

- **Co je „poznámka“:** samolepka vyexportovaná nebo nasdílená z editoru.
  Tag se vybírá před sdílením a stává se součástí samolepky.
- **Kde se emoji objeví:**
  1. *Statický export (PNG):* první snímek animace jako odznak v pravém
     dolním rohu, výška ≈ 22 % výšky samolepky, min. 96 px.
  2. *Animovaný export:* text jako statická vrstva + smyčka postavičky;
     formát APNG (iMessage) a GIF (fallback). Animovaný WebP Dart balík
     `image` neumí zapisovat, jen číst.
  3. *V aplikaci:* výběr v mřížce s živými náhledy (animovaný WebP přes
     `Image.asset`, Flutter ho přehrává nativně).
- **Jedna postavička pro všech 50 gest** (konzistence je hlavní technický
  problém, viz fáze 1). Později lze přidat druhou „rodinu“.
- **Rozpočet velikosti:** 50 × (WebP ≤ 300 KB + PNG ≤ 40 KB) ≈ 17 MB.
  Spolu s 42 MB sad glyphů to tlačí aplikaci k 60 MB; viz R0 v
  RELEASE_PLAN.md (řešení stejné: nižší rozlišení nebo On-Demand Resources).

## 2. Postavička {#postavicka}

Cíl: čitelná na 64 px, gesto poznatelné ze siluety, žádné detaily, které by
video model rozbíjel (vzorky na oblečení, brýle, dlouhé vlasy).

- **Tvar:** malá kulatá postavička, poměr hlava : tělo ≈ 1 : 1 (chibi),
  krátké ruce s třemi prsty a palcem (gesta rukou musí být čitelná: palec,
  V, OK, ukazování), nohy krátké, bez obuvi nebo jednoduché boty.
- **Obličej:** velké oči s odleskem, obočí (nutné pro emoce), jednoduchá
  ústa, tváře, které umí zčervenat.
- **Materiál:** matný vinyl/clay, „Pixar-style 3D render“, jedna akcentová
  barva (návrh: teplá žlutá tělo + modrá kombinéza/šála), bez textur.
- **Kamera:** 3/4 pohled zepředu, výška očí, ekvivalent 85 mm, postavička
  vyplní 80 % výšky rámu, stejné nastavení pro všech 50 klipů.
- **Pozadí:** jednolité světle šedé (#DDDDDD). Ne zelené: video modely
  zelenou „prokrvují“ do okrajů; odstranění pozadí se dělá až v postprodukci
  (fáze 4).
- **Rekvizity** jen tam, kde nesou význam (hrnek, půllitr, dort, deštník,
  telefon, sluchátka, pohár, hokejka, košík, kytice, dárek). Každou rekvizitu
  drží stejná ruka a je ve stejné akcentové barvě.
- **Pojmenování:** id v `gestures.json`, jméno postavičky rozhodne uživatel
  (blokující rozhodnutí ve fázi 1).

## 3. Padesát gest

Kritéria výběru: poznatelné ze siluety, dá se zahrát do 2 s, nepotřebuje
druhou postavu, kulturně čitelné v ČR. Typ smyčky: *seamless* (klip se
opakuje bez švu), *hold* (dojde do pózy a drží, opakuje se od začátku),
*one_shot* (přehraje se jednou, poslední snímek zůstane).

**Pozdravy a kontakt**

| # | id | Název | Gesto | Smyčka |
|---|----|-------|-------|--------|
| 1 | `wave` | Mávání | Zvedne pravou ruku a zamává dlaní ze strany na stranu, široký úsměv. | klid → 3 zamávání → klid (seamless) |
| 2 | `wink` | Mrknutí | Nakloní hlavu, mrkne levým okem, koutek úst nahoru. | klid → mrk + naklonění → klid (seamless) |
| 3 | `bow` | Úklona | Ruce u těla, hluboká úklona a zpět. | stoj → úklona → stoj (seamless) |
| 4 | `salute` | Salutování | Pravá ruka k čelu, krátké salutování, vážný výraz. | klid → ruka k čelu (hold) → klid (seamless) |
| 5 | `hug` | Objetí | Rozpřáhne obě ruce dokořán směrem k divákovi, zavřené oči. | klid → náruč dokořán (hold) → klid (hold) |
| 6 | `high_five` | Plácnutí | Zvedne dlaň nahoru k divákovi, čeká na plácnutí, pak plácne. | dlaň nahoru → plácnutí dopředu → zpět (seamless) |
| 7 | `fist_bump` | Ťuknutí pěstí | Natáhne pěst k divákovi, ťukne, pěst se rozevře s 'explozí' prstů. | pěst dopředu → ťuk → rozevření → zpět (seamless) |
| 8 | `blow_kiss` | Posílá pusu | Políbí dlaň a foukne směrem k divákovi, letí srdíčko. | ruka k puse → fouknutí → srdíčko odletí (one_shot) |
| 9 | `heart_hands` | Srdce z rukou | Spojí obě ruce do tvaru srdce před hrudí, srdce zapulzuje. | ruce k sobě → srdce → puls (seamless) |
| 10 | `point_you` | Ty! | Ukáže ukazováčkem přímo do kamery a kývne. | klid → ukázání + kývnutí (hold) → klid (hold) |

**Souhlas a nesouhlas**

| # | id | Název | Gesto | Smyčka |
|---|----|-------|-------|--------|
| 11 | `thumbs_up` | Palec nahoru | Zvedne pěst s palcem nahoru, palec 'pruží'. | klid → palec nahoru + poskok → klid (seamless) |
| 12 | `thumbs_down` | Palec dolů | Palec dolů, zamračený výraz. | klid → palec dolů + zamračení → klid (seamless) |
| 13 | `clap` | Tleskání | Zatleská třikrát, nadšený výraz. | klid → 3 tlesknutí → klid (seamless) |
| 14 | `ok_sign` | OK | Ukáže kolečko z palce a ukazováčku, mrkne. | klid → OK gesto (hold) + mrk → klid (hold) |
| 15 | `peace` | Vé | Dva prsty V u tváře, nakloněná hlava, úsměv. | klid → V u tváře (hold) → klid (hold) |
| 16 | `nod_yes` | Ano | Přikývne dvakrát hlavou, úsměv. | klid → 2 kývnutí → klid (seamless) |
| 17 | `shake_no` | Ne | Zavrtí hlavou ze strany na stranu, ruce v bok. | klid → zavrtění → klid (seamless) |
| 18 | `shrug` | Nevím | Pokrčí rameny, dlaně nahoru, obočí nahoru. | klid → pokrčení (hold) → klid (hold) |
| 19 | `crossed_fingers` | Držím palce | Zkříží prsty obou rukou u tváře, nadějný výraz. | klid → zkřížené prsty (hold) + zavření očí → klid (hold) |
| 20 | `pray_please` | Prosím | Sepne dlaně před sebe, lehce se nakloní, prosebné oči. | klid → sepnuté dlaně (hold) → klid (hold) |

**Emoce**

| # | id | Název | Gesto | Smyčka |
|---|----|-------|-------|--------|
| 21 | `laugh` | Smích | Zakloní hlavu a směje se, drží se za břicho. | klid → záklon + smích (opakuje) → klid (seamless) |
| 22 | `cry` | Pláč | Sedne si, slzy tečou proudem, ústa do oblouku. | stoj → sed + slzy (opakují se) → stoj (seamless) |
| 23 | `angry` | Vztek | Dupne nohou, ruce v pěst, z hlavy jde pára. | klid → dupnutí + pára → klid (seamless) |
| 24 | `surprised` | Překvapení | Ruce na tváře, ústa O, oči dokořán. | klid → ruce na tváře (hold) → klid (hold) |
| 25 | `thinking` | Přemýšlím | Ruka na bradě, pohled nahoru, nad hlavou otazník. | klid → ruka na bradě + otazník (hold) → klid (hold) |
| 26 | `mind_blown` | Mind blown | Ruce k hlavě a od ní, nad hlavou malý 'výbuch'. | ruce k hlavě → rozhození + výbuch → klid (one_shot) |
| 27 | `eye_roll` | Protočení očí | Založí ruce, protočí oči, nadechne se. | klid → založené ruce + protočení očí → klid (seamless) |
| 28 | `facepalm` | Facepalm | Plácne si dlaní na čelo a zůstane. | klid → dlaň na čelo (hold) → klid (hold) |
| 29 | `shush` | Pšt | Prst na rty, druhá ruka 'klidně'. | klid → prst na rty (hold) → klid (hold) |
| 30 | `shy` | Stydím se | Zakryje si tvář dlaněmi, kouká mezi prsty, červené tváře. | klid → dlaně na tvář → kouknutí mezi prsty → klid (seamless) |
| 31 | `love_eyes` | Zamilovaně | Ruce sepnuté u tváře, v očích srdíčka, houpe se. | klid → sepnuté ruce + srdíčka (houpání) → klid (seamless) |
| 32 | `dizzy` | Mimo | Motá se, nad hlavou kroužící hvězdičky. | klid → motání + hvězdičky → klid (seamless) |

**Zábava a tanec**

| # | id | Název | Gesto | Smyčka |
|---|----|-------|-------|--------|
| 33 | `chicken_dance` | Kuřecí tanec | Lokty jako křídla, mává, podřepy, hlava dopředu-dozadu. | 4 doby: zobák → křídla → zadek → tlesknutí (seamless) |
| 34 | `dab` | Dab | Skloní hlavu do lokte, druhá ruka nahoru šikmo. | klid → dab (hold) → klid (hold) |
| 35 | `moonwalk` | Moonwalk | Klouže pozadu moonwalk, klobouk nakloněný. | klouzání pozadu přes záběr, smyčka (seamless) |
| 36 | `disco` | Disco | Ukazuje střídavě nahoru a dolů šikmo, houpe boky. | 4 doby: nahoru → dolů → nahoru → dolů (seamless) |
| 37 | `twirl` | Piruetka | Otočí se o 360° na špičce, ruce nahoře. | klid → otočka → klid (seamless) |
| 38 | `star_jump` | Hvězda | Vyskočí s rukama i nohama do hvězdy. | klid → výskok hvězda → dopad (seamless) |
| 39 | `celebrate` | Sláva! | Skáče s rukama nahoře, kolem padají konfety. | skoky s konfetami, smyčka (seamless) |
| 40 | `flex` | Síla | Napne oba bicepsy, zatne zuby. | klid → flex (hold) → klid (hold) |
| 41 | `finger_guns` | Prstové pistolky | Vystřelí prstovými pistolkami do kamery a mrkne. | klid → pistolky + mrk → klid (seamless) |
| 42 | `headphones` | Vibe | Sluchátka na uších, kývá hlavou do rytmu, oči zavřené. | kývání do rytmu, smyčka (seamless) |
| 43 | `deal_with_it` | Deal with it | Shora spadnou sluneční brýle na oči, založí ruce. | brýle padají → nasazení → založení rukou (hold) (one_shot) |

**Všední den a české**

| # | id | Název | Gesto | Smyčka |
|---|----|-------|-------|--------|
| 44 | `coffee` | Kafe | Drží hrnek oběma rukama, usrkne, spokojený výdech s párou. | zvednutí hrnku → usrknutí → výdech (seamless) |
| 45 | `cheers` | Na zdraví | Zvedne půllitr k divákovi a přiťukne. | zvednutí → ťuknutí → napití (seamless) |
| 46 | `birthday` | Všechno nejlepší | Drží dort se svíčkou, nadechne se a sfoukne. | dort → nádech → sfouknutí → kouř (one_shot) |
| 47 | `sleep` | Spím | Schoulený spí, nad hlavou stoupají Zzz. | dýchání + Zzz, smyčka (seamless) |
| 48 | `running_late` | Spěchám | Běží na místě, kouká na hodinky, panika. | běh na místě + pohled na hodinky, smyčka (seamless) |
| 49 | `sick` | Marod | Teploměr v puse, deka, zelený obličej, kýchne. | klid → kýchnutí → klid (seamless) |
| 50 | `cold` | Zima | Třese se, objímá se, z pusy jde pára. | třes + pára, smyčka (seamless) |


**Rezerva (výměna za cokoli z padesátky):**

- `hot` Vedro: Ovívá se rukou, pot na čele, jazyk venku.
- `popcorn` Popcorn: Sedí s kyblíkem popcornu, jí a zírá dopředu.
- `phone` Píšu: Kouká do telefonu, palce píšou, občas se zasměje.
- `selfie` Selfie: Natáhne ruku s telefonem, pusa 'kachna', blesk.
- `meditate` Klid: Sedí v lotosu, levituje, kolem plují lístky.
- `gift` Dárek: Podává divákovi krabičku s mašlí, natěšený výraz.
- `flowers` Kytka: Podává kytici, plachý úsměv.
- `umbrella` Prší: Stojí pod deštníkem, kolem prší, otráveně.
- `trophy` Vítěz: Zvedne pohár nad hlavu, poskakuje.
- `hockey` Gól!: Hokejka nad hlavou, skok, dres.
- `mushrooms` Houby: Nese košík hub, jednu zvedne a ukáže hrdě.

## 4. Pipeline generování

Všechny fáze běží ze skriptů v `tools/emoji/` (Python 3, jen `requests` a
`websocket-client`), ComfyUI se volá přes jeho HTTP API:

```
POST /prompt            {"prompt": <workflow v API formátu>, "client_id": ...} → prompt_id
WS   /ws?clientId=...   průběh
GET  /history/{prompt_id}                      výstupní soubory
GET  /view?filename=&subfolder=&type=output    stažení
POST /upload/image                             nahrání referencí
GET  /system_stats, /object_info, /models/{folder}   inventura
```

Cloudflare Access: každý request nese hlavičky `CF-Access-Client-Id` a
`CF-Access-Client-Secret` ze servisního tokenu (env `CF_ACCESS_CLIENT_ID`,
`CF_ACCESS_CLIENT_SECRET`). Token vytvoří uživatel v Cloudflare Zero Trust →
Access → Service Auth a přidá policy „Service Auth“ na aplikaci ComfyUI.
Nikdy ho necommitovat; `tools/emoji/.env.example` bez hodnot.

Workflow se do skriptů ukládají jako JSON exportovaný z UI volbou
*Save (API Format)*; skript jen dosazuje prompt, seed, název vstupního
souboru a rozměry do pojmenovaných uzlů (`_meta.title`).

### Fáze 0: přístup a inventura (½ dne)

- [ ] `tools/emoji/comfy_client.py`: `queue(workflow) → prompt_id`,
  `wait(prompt_id)`, `download(prompt_id, out_dir)`, `upload(path)`,
  s CF hlavičkami a retry.
- [ ] `tools/emoji/inventory.py` uloží `tools/emoji/inventory.json`:
  GPU + VRAM (`/system_stats`), seznam checkpointů, `diffusion_models`,
  `loras`, `controlnet`, `clip_vision`, `ipadapter`, `upscale_models` a
  nainstalované custom nody (`/object_info`, jen klíče).
- [ ] Podle inventury vyplnit tabulku výběru níže a zapsat ji do
  `tools/emoji/README.md`. **Blokující bod: výsledek ukázat uživateli.**

Tabulka výběru (co hledat, v pořadí preference):

| Úloha | Hledat v inventuře | Poznámka |
|-------|--------------------|----------|
| Koncept postavičky (text→obrázek) | Flux.1 dev / Flux.1 Krea, Qwen-Image, SDXL + „3D render“ LoRA | Flux drží ruce a prsty nejlépe; SDXL jen s LoRA na 3D/chibi. |
| Konzistence postavičky | Flux Kontext dev, Qwen-Image-Edit, OmniGen2, IP-Adapter (FaceID nebo Plus) pro SDXL | Editační modely (Kontext/Qwen-Edit) berou referenci a mění pózu; nejjednodušší cesta bez tréninku. |
| Trénink LoRA postavičky | uzly `LoraTraining`/`FluxTrainer`, nebo ai-toolkit/kohya mimo ComfyUI | Jen pokud editační modely nedrží identitu. 30–40 obrázků z fáze 1. |
| Řízení pózy | ControlNet OpenPose (SDXL) / Flux ControlNet Union / DWPose preprocessor | Pro gesta rukou stačí prompt + reference; OpenPose až u tanců. |
| Obrázek→video | Wan 2.2 I2V (14B, nebo 5B na malé VRAM), Wan 2.1 I2V, LTX-Video 2, HunyuanVideo I2V | Wan 2.2 má nejlepší chování rukou. 480p stačí (výstup je 512 px). |
| Bezešvá smyčka | Wan FLF2V (first+last frame) se stejným snímkem na obou koncích; Wan VACE s referencí | Pro `seamless` gesta; `hold`/`one_shot` používají prosté I2V. |
| Přenos pohybu z nahrávky | Wan Animate / Wan VACE + DWPose z videa | Volitelně: uživatel natočí gesta na telefon, model je přenese na postavičku. Nejpřesnější řízení gesta. |
| Odstranění pozadí | BiRefNet, RMBG-2.0, InSPyReNet (uzly `Image Remove Background`) | Po snímcích, s konzistentní maskou (temporal smoothing volitelně). |
| Interpolace / zpomalení | RIFE (`VFI` uzly) | Když video model dá jen 16 fps. |
| Upscale | 4x-UltraSharp, RealESRGAN | Jen pokud generujeme < 512 px. |

### Fáze 1: postavička (1 den + rozhodnutí uživatele)

- [ ] `tools/emoji/workflows/concept.json`: text→obrázek, 8 kandidátů
  (2 seedy × 4 varianty promptu: barva, tvar hlavy, kombinéza/šála).
  Prompt kostra:
  ```
  cute small round 3D character, chibi proportions, big glossy eyes,
  simple three-finger hands, matte vinyl toy material, single accent color,
  Pixar style render, soft studio lighting, 3/4 front view, eye level,
  plain light grey background, full body, standing neutral pose
  ```
  Negativ: `text, watermark, extra fingers, realistic human, multiple
  characters, cropped, blurry, dark background`.
- [ ] Kontaktní arch `docs/emoji/concepts.png`. **Blokující bod: uživatel
  vybere jednu postavičku a jméno.**
- [ ] Sada referencí vybrané postavičky: otočka (zepředu, 3/4 vlevo a vpravo,
  z boku, zezadu) + 6 výrazů + 4 základní pózy rukou (dlaň, pěst, palec,
  ukazování). Nástroj: editační model z tabulky (reference + prompt „same
  character, turn to the right side view“). Výstup `docs/emoji/reference/`.
- [ ] Test konzistence: 5 náhodných gest z padesátky, každé 2 seedy.
  Pokud se identita rozpadá (jiné oči, barva, proporce) → trénovat LoRA
  z referencí (30–40 obrázků, 1500–2500 kroků, trigger slovo = jméno).

### Fáze 2: klíčové snímky 50 gest (1–2 dny strojového času)

- [ ] `tools/emoji/run.py --phase keyframes [--ids wave,wink]`: pro každé
  gesto 4 kandidáti (4 seedy) z `gestures.json` (`gesture` + kostra
  promptu + reference/LoRA). Rekvizity se do promptu přidávají z gesta.
- [ ] Pro `difficulty: 3` (chicken_dance, moonwalk, twirl, hockey) přidat
  OpenPose z pózové knihovny `tools/emoji/poses/*.png` (ručně nakreslené
  kostry nebo DWPose z fotky uživatele).
- [ ] Kontaktní arch po 8 gestech → `docs/emoji/keyframes_XX.png`. Výběr
  vítězů: automaticky VLM skórování (pokud je v ComfyUI Florence-2 nebo
  Qwen-VL uzel: „Is the character doing <gesture>? Are hands correct?“) a
  finálně ručně. Vybrané id seedů do `tools/emoji/picks.json`.

### Fáze 3: animace (2–3 dny strojového času)

- [ ] `run.py --phase animate`: pro každé gesto I2V z vybraného klíčového
  snímku, `motion_prompt` z `gestures.json`, 2 s, 24 fps (nebo 16 fps +
  RIFE ×1,5), 512×512 nebo 480×480, 2 seedy.
  - `seamless`: FLF2V se stejným snímkem jako první i poslední, nebo I2V
    a v postprodukci najít nejbližší dvojici snímků (SSIM) a oříznout.
  - `hold`: I2V, posledních 12 snímků zmrazit.
  - `one_shot`: I2V, bez smyčky, poslední snímek se drží.
- [ ] Pro tance (`difficulty: 3`) preferovat přenos pohybu (Wan Animate /
  VACE) z 2s nahrávky uživatele: `tools/emoji/driving/<id>.mp4` → DWPose →
  video. Jedna nahrávka na gesto, stejné rámování jako postavička.
- [ ] Kontaktní arch z 6 snímků každého klipu → `docs/emoji/anim_XX.png`,
  výběr do `picks.json`.

### Fáze 4: postprodukce (½ dne, `tools/emoji/post.py`)

- [ ] Rozklad na snímky → odstranění pozadí (BiRefNet/RMBG přes ComfyUI,
  nebo lokálně `rembg`) → ořez na čtverec se společným rámem pro všechny
  snímky (žádné poskakování) → 512×512.
- [ ] Smyčka: pro `seamless` ořezat na nejlepší šev, pro `hold` doplnit
  zmrazené snímky, snížit na 16–20 fps, pokud je klip nad rozpočtem.
- [ ] Výstupy do `handwritten_stickers/assets/emoji/<id>/`:
  `anim.webp` (animovaný WebP, ≤ 300 KB, `cwebp`/`img2webp`),
  `anim.apng` (pro export do iMessage, ≤ 500 KB), `still.png` (první snímek
  512 px s alfou), `meta.json` (id, názvy, loop_type, fps, frames, licence).
- [ ] `assets/emoji/emoji.json` index (stejný vzor jako `sheets.json`).
- [ ] Kontrolní arch všech 50 na 64 px: `docs/emoji/final_64px.png`.
  Kritérium: gesto poznatelné bez popisku u ≥ 45 z 50.

### Fáze 5: integrace do aplikace (1–2 dny)

- [ ] Model `EmojiTag {id, nameCs, nameEn, loopType}` a
  `EmojiIndex.load()` z `assets/emoji/emoji.json`.
- [ ] `EmojiPicker`: bottom sheet s mřížkou 4 sloupce, animované náhledy
  (`Image.asset` na `anim.webp`), vyhledávání podle názvu, poslední použité.
- [ ] Stav editoru: `EmojiTag? _tag`; zobrazení v rohu náhledu.
- [ ] `ImageExporter`: parametr `tag`; PNG export kreslí `still.png` jako
  odznak (velikost 22 % výšky, 12 px odsazení); nová metoda
  `exportAnimated()` skládá snímky APNG přes balík `image`
  (`PngEncoder` s `isAnimated`) a GIF fallback; sdílení nabídne obě volby.
- [ ] Testy: index se načte, každé emoji má všechny čtyři soubory, odznak
  se v exportu vykreslí (golden test 1 gesto), APNG export má správný počet
  snímků.
- [ ] Assety `assets/emoji/` do `pubspec.yaml` (každý adresář zvlášť).

### Fáze 6: kontrola kvality a licence

- [ ] Každé gesto: čitelnost na 64 px, šev smyčky, okraje alfa bez zeleného
  nebo šedého lemu, žádné extra prsty, stejná velikost postavičky napříč.
- [ ] Zapsat použité modely a jejich licence do
  `handwritten_stickers/assets/emoji/LICENSES.md` (Flux dev = nekomerční
  licence pro *model*, výstupy jsou dle FAL/BFL podmínek použitelné;
  Wan 2.x = Apache 2.0; SDXL = CreativeML OpenRAIL). Před App Store ověřit,
  že výstupy z vybraného obrázkového modelu lze použít komerčně; pokud ne,
  koncept a reference přegenerovat Qwen-Image nebo SDXL.

## 5. Doporučené pořadí pro Opuse

1. Fáze 0 celá, výsledek inventury uživateli (blokující).
2. Fáze 1 do výběru postavičky (blokující), pak reference + test konzistence.
3. Fáze 2 na 10 gestech (`wave, wink, thumbs_up, clap, chicken_dance,
   laugh, shrug, coffee, cheers, sleep`) → fáze 3 a 4 na těch samých 10 →
   fáze 5 na 10 emoji. Tím se ověří celý řetězec a formáty v aplikaci.
4. Zbylých 40 gest hromadně, rezervy nahradí, co se nepovede.

## 6. Rizika

- **Identita postavičky** se ve videu rozpadá: mírní se LoRA + referenční
  snímek + krátké klipy (2 s) + nízké `guidance`. Nejhorší případ: gesta
  s rekvizitou generovat editačním modelem po snímcích (méně plynulé).
- **Ruce a prsty** jsou slabina všech modelů: tři prsty + palec v designu
  a gesta zvolena tak, aby se počet prstů nemusel číst (kromě `peace`,
  `ok_sign`, `finger_guns`, ty jsou kandidáti na rezervu).
- **Odstranění pozadí** u animace bliká: společná maska přes snímky
  (dilatace + časové vyhlazení), nebo generovat rovnou s šedým pozadím a
  chroma-key na šedou.
- **Velikost aplikace:** 17 MB emoji + 42 MB glyphů. Rozhodnout spolu.
- **Práva:** licence modelu vs. výstupu, viz fáze 6; zápis do plánu releasu.
