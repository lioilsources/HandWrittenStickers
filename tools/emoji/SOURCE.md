# Původ emoji

Plán: `docs/EMOJI_SET_PLAN.md`. Zadání pro GPU: `BRIEF.md`.

## Generování (L40S)

Odpovědi session L40S z 2026-11-12:

- ComfyUI běží na vyžádání (profil D), mezi úlohami jede výplňová práce, kterou běžná úloha
  přeruší. Fronta je volná.
- Model: Qwen-Image fp8 (`qwen_image_fp8_e4m3fn`, text encoder `qwen_2.5_vl_7b_fp8_scaled`,
  VAE `qwen_image_vae`), Apache-2.0. 20 kroků, cfg 2,5, shift 3,1. Měřeno 7. 11.: 20,4–20,7 s
  na obrázek 1024², studený start ~85 s. Prompty posílat v jedné dávce, jinak se model
  přenačítá (~120 s na obrázek).
- Qwen-Image ignoruje negativní prompt; popisovat kladně.
- Výřez: BiRefNet (ZhengPeng7, MIT) skriptem `tmobile-sandbox/uc28/icons.py`, volby
  `--fill-all` a `--drop-dark 40`.
- Pravidla GPU: jen SFW, výstupy na `/cold`, kopie mimo VM a push jen se souhlasem Olina
  v chatu L40S.
- Konec sandboxu neznámý, počítat nejvýš s několika dny bez potvrzení.

## Přechodné obrázky

`legacy/<codepointy>.webp`: 40 nálepek z první verze aplikace (25 ze SwypeKids, 15 z
flux-schnell na SPARKu). `build.py` je použije pro emoji bez masteru. Smažou se ve fázi F7.

## Mastery

Zatím žádné. Po výběru: `id`, styl, seed, checkpoint a datum u každého obrázku.
