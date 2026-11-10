"""Play feature graphic (1024x500) and icon (512x512) from the app's own glyphs.

    python3 store/play_graphics.py . store/graphics
"""
import json
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(sys.argv[1])
OUT = Path(sys.argv[2])
GLYPHS = ROOT / "handwritten_stickers/assets/glyphs"
ICON = ROOT / "handwritten_stickers/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
BG = (255, 241, 222)


def first(v):
    return v[0] if isinstance(v, list) else v


def render(sheet, text, scale, tint=None):
    m = json.loads((GLYPHS / sheet / "glyphs.json").read_text())
    space = first(m["metrics"].get("n", {"advance": 80}))["advance"] * 0.6
    pieces, x, top, bottom = [], 0.0, 0, 0
    for ch in text:
        if ch == " ":
            x += space
            continue
        met = first(m["metrics"][ch])
        img = Image.open(GLYPHS / sheet / first(m["glyphs"][ch])).convert("RGBA")
        pieces.append((img, x + met["bearing"], -met["baseline"]))
        top = min(top, -met["baseline"])
        bottom = max(bottom, met["h"] - met["baseline"])
        x += met["advance"]
    w = int(max(px + im.width for im, px, _ in pieces)) + 4
    canvas = Image.new("RGBA", (w, bottom - top + 4), (0, 0, 0, 0))
    for im, px, py in pieces:
        if tint:
            solid = Image.new("RGBA", im.size, tint + (255,))
            solid.putalpha(im.getchannel("A"))
            im = solid
        canvas.alpha_composite(im, (int(px), int(py - top)))
    return canvas.resize((int(canvas.width * scale), int(canvas.height * scale)), Image.LANCZOS)


icon = Image.open(ICON).convert("RGB")
icon.resize((512, 512), Image.LANCZOS).save(OUT / "play_icon_512.png")

BG = icon.getpixel((4, 4))
fg = Image.new("RGBA", (1024, 500), BG + (255,))
# Icon art (no frame) on the left.
art = icon.resize((330, 330), Image.LANCZOS)
fg.paste(art, (40, 85))

x0 = 400
avail = 1024 - x0 - 36
raw = render("kid_bubble_peach", "Handwritten", 1)
k = avail / raw.width
title1 = render("kid_bubble_peach", "Handwritten", k)
title2 = render("kid_bubble_peach", "Stickers", k)
rawtag = render("caveat", "Type it. Send it handwritten.", 1)
tag = render("caveat", "Type it. Send it handwritten.", min(0.6, (avail - 10) / rawtag.width), tint=(160, 64, 36))
for t in (title1, title2, tag):
    if t.width > avail:
        raise SystemExit(f"too wide: {t.width} > {avail}")
y = (500 - (title1.height * 2 + 6 + 14 + tag.height)) // 2
fg.alpha_composite(title1, (x0, y)); y += title1.height + 6
fg.alpha_composite(title2, (x0, y)); y += title2.height + 14
fg.alpha_composite(tag, (x0 + 6, y))
fg.convert("RGB").save(OUT / "play_feature_1024x500.png")
print("ok", title1.size, title2.size, tag.size, y + tag.height)
