#!/usr/bin/env python3
"""Builds handwritten_stickers/assets/emoji/ from tools/emoji/emoji_set.json
and styles.json `ship` (docs/EMOJI_SET_PLAN.md §8):

  masters/<style>/<id>.webp  (768 px cut-outs from L40S)
      →  assets/emoji/<style>/<id>.webp, 384 px
  emoji.json  version 3: styles [{id, name {cs, en}, pack}], categories, and
              emoji with id, category, emoji, name {cs, en}, motion and
              files {style: path}

Until the masters exist, the first (free) style falls back to
legacy/<codepoints>.webp (the 40 stickers the app shipped first) so the app
keeps working; --no-legacy leaves those out. Reserve emoji are built only from
a master. A style without any emoji is left out of the index. Stray *.webp
files and style folders are removed, and the style folders are written into
pubspec.yaml (Flutter does not bundle sub-folders on its own).

Usage: python3 build.py [--no-legacy] [--reject id,id | style/id,...]
Needs Pillow with WebP."""
import json
import os
import re
import shutil
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
APP = os.path.join(ROOT, 'handwritten_stickers')
OUT = os.path.join(APP, 'assets', 'emoji')
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


def write_pubspec(style_ids):
    path = os.path.join(APP, 'pubspec.yaml')
    with open(path) as f:
        text = f.read()
    lines = ''.join(f'    - assets/emoji/{s}/\n' for s in style_ids)
    text = re.sub(r'(    - assets/emoji/\n)(    - assets/emoji/[^\n]+/\n)*', lambda m: m.group(1) + lines, text)
    with open(path, 'w') as f:
        f.write(text)


def main():
    use_legacy = '--no-legacy' not in sys.argv
    reject = set()
    if '--reject' in sys.argv:
        reject = set(sys.argv[sys.argv.index('--reject') + 1].split(','))
    with open(os.path.join(HERE, 'emoji_set.json')) as f:
        data = json.load(f)
    with open(os.path.join(HERE, 'styles.json')) as f:
        ship = json.load(f)['ship']
    os.makedirs(OUT, exist_ok=True)

    files = {item['id']: {} for item in data['emoji']}
    report = []
    for i, style in enumerate(ship):
        sid = style['id']
        out_dir = os.path.join(OUT, sid)
        os.makedirs(out_dir, exist_ok=True)
        used_legacy, missing, built = set(), [], set()
        for item in data['emoji']:
            id_ = item['id']
            if id_ in reject or f'{sid}/{id_}' in reject:
                continue
            dst = os.path.join(out_dir, id_ + '.webp')
            master = os.path.join(MASTERS, sid, id_ + '.webp')
            old = os.path.join(LEGACY, legacy_key(item['emoji']) + '.webp')
            if os.path.exists(master):
                render(master, dst)
            elif (i == 0 and use_legacy and not item.get('reserve')
                  and os.path.exists(old) and old not in used_legacy):
                used_legacy.add(old)
                render(old, dst)
            else:
                if not item.get('reserve'):
                    missing.append(id_)
                continue
            built.add(id_ + '.webp')
            files[id_][sid] = f'{sid}/{id_}.webp'
        for f in os.listdir(out_dir):
            if f.endswith('.webp') and f not in built:
                os.remove(os.path.join(out_dir, f))
        if not built:
            os.rmdir(out_dir) if not os.listdir(out_dir) else None
        report.append(f'{sid}: {len(built)} ({len(used_legacy)} legacy, {len(missing)} core missing)')

    styles = [s for s in ship if any(s['id'] in f for f in files.values())]
    ids = {s['id'] for s in styles}
    # Leftovers from older layouts: flat webp files and dropped styles.
    for f in os.listdir(OUT):
        p = os.path.join(OUT, f)
        if f.endswith('.webp') or (os.path.isdir(p) and f not in ids):
            shutil.rmtree(p) if os.path.isdir(p) else os.remove(p)

    index = [{'id': item['id'], 'category': item['category'], 'emoji': item['emoji'],
              'name': item['name'], 'motion': item['motion'], 'files': files[item['id']]}
             for item in data['emoji'] if files[item['id']]]
    cats = {e['category'] for e in index}
    with open(os.path.join(OUT, 'emoji.json'), 'w') as f:
        json.dump({'version': 3,
                   'styles': [{k: s[k] for k in ('id', 'name', 'pack') if k in s} for s in styles],
                   'categories': [c for c in data['categories'] if c['id'] in cats],
                   'emoji': index}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    write_pubspec([s['id'] for s in styles])
    print(f'{len(index)} emoji → {OUT}; ' + '; '.join(report))


if __name__ == '__main__':
    main()
