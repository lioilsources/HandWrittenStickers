#!/usr/bin/env python3
"""Builds handwritten_stickers/assets/emoji/ from emoji_set.json:

  source "swypekids" → copied from ../SwypeKids/assets/emoji/<key>.webp
                       (same sticker style, already cut out, 320 px)
  source "generated" → cut out of out/emoji-<key>.png (run_batch.py drafts)
                       with the SwypeKids cutout (flood fill from the edges,
                       the white sticker outline separates the subject)

Writes assets/emoji/<key>.webp and assets/emoji/emoji.json (index for the
app; only emoji whose WebP exists). Usage: python3 build.py [--reject key,key]
Needs Pillow with WebP."""
import json, os, shutil, sys
from PIL import Image, ImageChops, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, 'handwritten_stickers', 'assets', 'emoji')
SWYPE = os.path.join(os.path.dirname(ROOT), 'SwypeKids', 'assets', 'emoji')
DRAFTS = os.path.join(HERE, 'out')
SIZE = 320
SENT = (1, 254, 3)


def key_for(emoji):
    return '-'.join(format(ord(c), 'x') for c in emoji if ord(c) != 0xFE0F)


def cutout(path):
    im = Image.open(path).convert('RGB')
    w, h = im.size
    work = im.copy()
    for c in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1),
              (w // 2, 0), (0, h // 2), (w - 1, h // 2), (w // 2, h - 1)]:
        if work.getpixel(c) != SENT:
            ImageDraw.floodfill(work, c, SENT, thresh=40)
    diff = ImageChops.difference(work, Image.new('RGB', (w, h), SENT)).convert('L')
    alpha = (diff.point(lambda v: 255 if v > 0 else 0)
             .filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2)))
    out = im.convert('RGBA')
    out.putalpha(alpha)
    bb = alpha.getbbox()
    if bb is None:
        return None
    out = out.crop(bb)
    s = max(out.size)
    sq = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    sq.paste(out, ((s - out.size[0]) // 2, (s - out.size[1]) // 2))
    return sq.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    reject = set()
    if '--reject' in sys.argv:
        reject = set(sys.argv[sys.argv.index('--reject') + 1].split(','))
    os.makedirs(OUT, exist_ok=True)
    index = []
    for item in json.load(open(os.path.join(HERE, 'emoji_set.json'))):
        key = key_for(item['emoji'])
        dst = os.path.join(OUT, key + '.webp')
        if key in reject:
            if os.path.exists(dst):
                os.remove(dst)
            continue
        if item['source'] == 'swypekids':
            src = os.path.join(SWYPE, key + '.webp')
            if os.path.exists(src):
                shutil.copyfile(src, dst)
        else:
            src = os.path.join(DRAFTS, f'emoji-{key}.png')
            if os.path.exists(src):
                img = cutout(src)
                if img is not None:
                    img.save(dst, 'WEBP', quality=88, method=6)
        if os.path.exists(dst):
            index.append({'emoji': item['emoji'], 'name': item['name'], 'file': key + '.webp'})
        else:
            print(f'missing {item["emoji"]} ({key})')
    with open(os.path.join(OUT, 'emoji.json'), 'w') as f:
        json.dump({'version': 1, 'emoji': index}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{len(index)} emoji → {OUT}')


if __name__ == '__main__':
    main()
