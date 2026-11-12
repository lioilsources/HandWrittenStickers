#!/usr/bin/env python3
"""Builds handwritten_stickers/assets/emoji/ from tools/emoji/emoji_set.json
(docs/EMOJI_SET_PLAN.md §8):

  masters/<id>.webp  (768 px cut-outs from L40S)  →  assets/emoji/<id>.webp, 384 px
  emoji.json         version 2: categories + emoji with id, category, emoji,
                     name {cs, en}, file, motion

Until the masters exist, an emoji falls back to legacy/<codepoints>.webp (the
40 stickers the app shipped first) so the app keeps working; --no-legacy
leaves those out. Reserve emoji are built only from a master. Every other
*.webp in assets/emoji/ is removed.

Usage: python3 build.py [--no-legacy] [--reject id,id]    Needs Pillow with WebP."""
import json
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, 'handwritten_stickers', 'assets', 'emoji')
MASTERS = os.path.join(HERE, 'masters')
LEGACY = os.path.join(HERE, 'legacy')
SIZE = 384


def legacy_key(emoji):
    return '-'.join(format(ord(c), 'x') for c in emoji if ord(c) not in (0xFE0F, 0x200D))


def render(src, dst):
    im = Image.open(src).convert('RGBA')
    if im.size != (SIZE, SIZE):
        im = im.resize((SIZE, SIZE), Image.LANCZOS)
    im.save(dst, 'WEBP', quality=88, method=6)


def main():
    use_legacy = '--no-legacy' not in sys.argv
    reject = set()
    if '--reject' in sys.argv:
        reject = set(sys.argv[sys.argv.index('--reject') + 1].split(','))
    with open(os.path.join(HERE, 'emoji_set.json')) as f:
        data = json.load(f)
    os.makedirs(OUT, exist_ok=True)

    index, used_legacy, missing = [], set(), []
    for item in data['emoji']:
        if item['id'] in reject:
            continue
        dst = os.path.join(OUT, item['id'] + '.webp')
        master = os.path.join(MASTERS, item['id'] + '.webp')
        old = os.path.join(LEGACY, legacy_key(item['emoji']) + '.webp')
        if os.path.exists(master):
            render(master, dst)
        elif use_legacy and not item.get('reserve') and os.path.exists(old) and old not in used_legacy:
            used_legacy.add(old)
            render(old, dst)
        else:
            if not item.get('reserve'):
                missing.append(item['id'])
            continue
        index.append({'id': item['id'], 'category': item['category'], 'emoji': item['emoji'],
                      'name': item['name'], 'file': item['id'] + '.webp', 'motion': item['motion']})

    keep = {e['file'] for e in index}
    for f in os.listdir(OUT):
        if f.endswith('.webp') and f not in keep:
            os.remove(os.path.join(OUT, f))

    cats = {e['category'] for e in index}
    with open(os.path.join(OUT, 'emoji.json'), 'w') as f:
        json.dump({'version': 2,
                   'categories': [c for c in data['categories'] if c['id'] in cats],
                   'emoji': index}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{len(index)} emoji → {OUT} ({len(used_legacy)} from legacy, {len(missing)} core still missing)')


if __name__ == '__main__':
    main()
