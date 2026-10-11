# Perník (mat_gingerbread)

Materiálové písmo vygenerované přes ComfyUI (plán 02, sekce 1).

- Vodicí font: Kalam-Bold.ttf (SIL OFL 1.1)
- Checkpoint: sd_xl_base_1.0
- ControlNet: controlnet-union-sdxl-promax-xinsir (síla 0.85)
- Denoise: 0.95, kroky 30, CFG 6.5
- Prompt: letters shaped from gingerbread dough, each letter is itself a cut-out gingerbread cookie in the shape of the letter, baked golden brown, thin white royal icing line along the letter, each letter isolated in its own square, centered, on plain pure white background, studio lighting, high detail, product photo
- Negativní prompt: text, words, letters merged, touching letters, extra letters, shadow, drop shadow, background texture, table, watermark, signature, frame, border
- Workflow: tools/sheets/workflows/material.json

## Generování

- 2026-10-05: buňky vše, seed 1234
- 2026-10-05: buňky 1:r6c3,1:r6c4,1:r6c7,1:r7c0,1:r7c1,1:r7c4,1:r7c5,1:r8c5,2:r5c1,2:r5c2,2:r5c3,2:r6c3,2:r6c4,2:r6c5,2:r6c7,2:r7c0,2:r7c1,2:r7c2, seed 777

## Licence

Komerční použití výstupu ověřit podle licence checkpointu (Flux dev ≠ SDXL/Qwen-Image).
Do ověření je sada v `sheets.json` s `"bundle": false`.

Vyřazené znaky (nepovedené, berou se z `caveat`): * ` • … – „
