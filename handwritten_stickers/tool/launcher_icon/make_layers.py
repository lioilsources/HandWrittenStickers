#!/usr/bin/env python3
"""Android adaptive-icon layers from the existing square app icon.

The icon is the "Aa" lettering on a flat cream (#FFF3E0) background, so:
  * background  = the flat colour (set in pubspec, adaptive_icon_background)
  * foreground  = the lettering cut out of the cream, scaled so its diagonal
                  fits the 66/108 safe-zone circle of the 108 dp canvas
  * monochrome  = the light letter fill (keeps the counters), for Android 13
                  themed icons

Usage (from handwritten_stickers/):
  python3 tool/launcher_icon/make_layers.py
  dart run flutter_launcher_icons
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).parent
SRC = HERE.parents[1] / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
SIZE = 1024
SAFE = 0.61  # diagonal of the art / canvas; safe zone is 66/108 = 0.611


def main():
    a = np.asarray(Image.open(SRC).convert("RGB")).astype(float)
    bg = a[4, 4]
    dist = np.sqrt(((a - bg) ** 2).sum(-1))

    # Exterior = cream region connected to the corner (the dark outline seals
    # the letters, so the light fill inside them stays opaque).
    cand = Image.fromarray(((dist < 200) * 255).astype(np.uint8)).copy()
    ImageDraw.floodfill(cand, (0, 0), 128)
    ext = np.asarray(cand) == 128
    outline = np.median(a[~ext & (dist > 150)], 0)
    d_outline = np.sqrt(((outline - bg) ** 2).sum())
    alpha = np.where(ext, np.clip(dist / d_outline, 0, 1), 1.0)
    alpha[alpha < 0.04] = 0
    # Un-blend anti-aliased edge pixels from the cream.
    rgb = bg + (a - bg) / np.maximum(alpha[..., None], 1e-6)
    rgb = np.where(alpha[..., None] > 0, np.clip(rgb, 0, 255), 0)
    art = Image.fromarray(np.dstack([rgb, alpha * 255]).astype(np.uint8), "RGBA")
    art = art.crop(art.getbbox())

    scale = SAFE * SIZE / (art.width ** 2 + art.height ** 2) ** 0.5
    art = art.resize((round(art.width * scale), round(art.height * scale)), Image.LANCZOS)
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fg.paste(art, ((SIZE - art.width) // 2, (SIZE - art.height) // 2), art)
    fg.save(HERE / "foreground.png")

    c = np.asarray(fg).astype(float)
    lum = c[..., :3].mean(-1)
    m = np.clip((lum - 150) / 40, 0, 1) * (c[..., 3] / 255)
    mono = np.dstack([np.full((SIZE, SIZE, 3), 255), m * 255]).astype(np.uint8)
    Image.fromarray(mono, "RGBA").save(HERE / "monochrome.png")
    print("background", "#%02X%02X%02X" % tuple(int(x) for x in bg))


if __name__ == "__main__":
    main()
