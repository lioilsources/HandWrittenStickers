# Zadání pro L40S: vlastní sada animovaných emoji

Zadavatel: session **Stickers** (Mac, repo `HandWrittenStickers`). Dotazy a hlášení posílej jí.
Celý plán: `docs/EMOJI_SET_PLAN.md`. Zdroj pravdy: `tools/emoji/emoji_set.json` a
`tools/emoji/styles.json` na větvi `emoji-own-set`.

## 1. Co a proč

Aplikace Handwritten Stickers přidává ke zprávě jedno animované emoji. Dnešních 40 nálepek je
převzatých z jiné aplikace. Nahrazuje je **vlastní sada 168 emoji + 12 rezervních** v deseti
kategoriích. Animaci dělá kód v aplikaci, takže od L40S je potřeba jen **jeden statický výřez na
emoji** (RGBA, průhledné pozadí). Jde do GIFu s paletou 256 barev a zobrazuje se i v 64 px.

Každý obrázek musí:
- ukazovat **jeden objekt celý**, uprostřed, s okrajem kolem,
- být **bez textu**, číslic, log a podpisu (nejčastější vada, každý výstup projít okem),
- být **SFW a vhodný pro hodnocení 4+** (žádný alkohol, zbraně, nahota),
- u rukou mít **pět prstů a správné gesto**.

## 2. Model a licence (blokující)

Aplikace je komerční. Použij **Qwen-Image fp8** (`qwen_image_fp8_e4m3fn`, text encoder
`qwen_2.5_vl_7b_fp8_scaled`, Apache-2.0), stejně jako u ikon BioDefense: 20 kroků, cfg 2,5,
shift 3,1, euler/simple. Výřez **BiRefNet** (ZhengPeng7, MIT) skriptem `uc28/icons.py`.
Jiný model jen po domluvě; FLUX.1 dev/Kontext/Fill a komunitní checkpointy ne.
Do `drafts/manifest.json` (`backend`) zapiš přesný checkpoint, verzi, licenci a odkud je ověřená.

## 3. Dávky

Seznam promptů generuje `python3 tools/emoji/make_jobs.py <dávka>` do
`tools/emoji/jobs/<dávka>.json`. Každá položka má `file`, `id`, `style`, `seed`, `size`,
`prompt` a `negative`. Prompt už je složený; neměň ho, a když něco nefunguje, napiš proč.
Posílej dávku najednou (jinak se model přenačítá).

| Dávka | Obsah | Obrázků | Pak |
|---|---|---|---|
| **I0** | 8 emoji × 3 styly × 2 seedy | 48 | **stop**, uživatel vybírá styl |
| **I1** | pilot, 2 emoji z každé kategorie, 4 seedy (ruce 8) | 88 | **stop**, čekej na pokyn |
| **I2** | zbytek sady | ~700 | hlášení |
| **I3** | opravy podle seznamu od Stickers | podle potřeby | hlášení |

Seed: `7000 + 20 × n + k` (`n` z `emoji_set.json`), už spočítaný v `jobs/*.json`.
Rozměr 1024 × 1024.

## 4. Výřez

`icons.py` s `--fill-all`: PNG RGBA, díry uvnitř objektu zaplněné, bez světlého ani tmavého lemu
(zkontrolovat na světlém i tmavém podkladu), ořez na objekt s okrajem asi 6 %, doplnit na čtverec.
Pozadí v promptu je světle šedé; když ho BiRefNet nechá v mezerách (mezi prsty, v uchu hrnku),
napiš to.

## 5. Co odevzdat

Podle tvých pravidel zůstávají výstupy na `/cold`; kopie mimo VM a push jen se souhlasem Olina
v tvém chatu. Po souhlasu:

Na větev **`emoji-drafts`** (nikdy se neslučuje):

```
tools/emoji/drafts/sheets/<dávka>_<kategorie>.jpg   # řádek = emoji, sloupec = seed (u I0 styl × seed),
                                                    # buňka 256 px na šachovnici, pod buňkou seed,
                                                    # JPEG do 1,5 MB; u I0 navíc pás 64 px
tools/emoji/drafts/manifest.json                    # backend; u každého id: seeds, pick, notes
```

`pick` je tvůj návrh nejlepšího seedu, `notes` co nesedí (text v obrázku, prsty, ořez).

Na větev **`emoji-own-set`** až po výběru (seznam pošle Stickers):

```
tools/emoji/masters/<id>.webp    # vybraný výřez, 768 px, bezztrátový WebP s alfou, do 150 kB
```

Zmenšení do aplikace, testy a zapojení dělá Stickers na Macu.

## 6. Komunikace

- Před I0: potvrzení modelu, licence a času.
- Po každé dávce: „hotovo, push <commit>“ a seznam `id` s problémem.
- Když zadání nedává smysl, zeptej se. Neodhaduj.
