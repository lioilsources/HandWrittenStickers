#!/usr/bin/env python3
"""Checks tools/emoji/emoji_set.json (docs/EMOJI_SET_PLAN.md §8, §11).

  python3 check_set.py            # the set itself
  python3 check_set.py --assets   # also the built app assets (after build.py)

Exits 1 when anything fails. --assets needs Pillow."""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
ASSETS = os.path.join(ROOT, 'handwritten_stickers', 'assets', 'emoji')
MOTIONS = {'breathe', 'pulse', 'bounce', 'wave', 'shake', 'nod', 'float', 'twinkle'}
ID = re.compile(r'^[a-z][a-z0-9_]*$')
# Words that must not reach a prompt: other apps' sticker style, brands,
# content that breaks the 4+ rating.
BANNED = re.compile(
    r'\b(sticker|chibi|apple|google|samsung|microsoft|whatsapp|facebook|meta|'
    r'beer|wine|alcohol|cigarette|tobacco|gun|weapon|knife|blood|nude|naked|'
    r'casino|gambling)\b', re.I)
MIN_TOTAL = 150
MIN_SHARE = 0.8


def load(name):
    with open(os.path.join(HERE, name)) as f:
        return json.load(f)


def check_set(data, errors):
    cats = [c['id'] for c in data['categories']]
    if len(set(cats)) != len(cats):
        errors.append('duplicate category id')
    for c in data['categories']:
        if not c['name'].get('cs') or not c['name'].get('en'):
            errors.append(f'category {c["id"]}: name missing')
    ids, ns = set(), set()
    for e in data['emoji']:
        where = e.get('id', '?')
        if not ID.match(e['id']):
            errors.append(f'{where}: bad id')
        if e['id'] in ids:
            errors.append(f'{where}: duplicate id')
        if e['n'] in ns:
            errors.append(f'{where}: duplicate n {e["n"]}')
        ids.add(e['id'])
        ns.add(e['n'])
        if e['category'] not in cats:
            errors.append(f'{where}: unknown category {e["category"]}')
        if e['motion'] not in MOTIONS:
            errors.append(f'{where}: unknown motion {e["motion"]}')
        for lang in ('cs', 'en'):
            name = e['name'].get(lang, '')
            if not name or len(name) > 24:
                errors.append(f'{where}: name.{lang} empty or over 24 chars')
        if not e.get('emoji'):
            errors.append(f'{where}: fallback character missing')
        m = BANNED.search(e.get('subject', ''))
        if not e.get('subject') or m:
            errors.append(f'{where}: subject empty or contains "{m.group(0) if m else ""}"')
    core = [e for e in data['emoji'] if not e.get('reserve')]
    if len(core) < MIN_TOTAL:
        errors.append(f'only {len(core)} core emoji, need {MIN_TOTAL}')


def check_styles(styles, errors):
    for name, block in styles['styles'].items():
        m = BANNED.search(block)
        if m:
            errors.append(f'style {name} contains "{m.group(0)}"')
    if styles['selected'] not in (None, *styles['styles']):
        errors.append(f'selected style {styles["selected"]} does not exist')


def check_assets(data, errors):
    from PIL import Image

    with open(os.path.join(ASSETS, 'emoji.json')) as f:
        index = json.load(f)
    if index.get('version') != 2:
        errors.append('assets/emoji/emoji.json is not version 2')
        return
    files = {e['file'] for e in index['emoji']}
    on_disk = {f for f in os.listdir(ASSETS) if f.endswith('.webp')}
    for f in sorted(files - on_disk):
        errors.append(f'index names missing file {f}')
    for f in sorted(on_disk - files):
        errors.append(f'file not in index: {f}')
    total = 0
    for f in sorted(files & on_disk):
        path = os.path.join(ASSETS, f)
        size = os.path.getsize(path)
        total += size
        if size > 40_000:
            errors.append(f'{f}: {size} B over 40 kB')
        im = Image.open(path).convert('RGBA')
        if im.size != (384, 384):
            errors.append(f'{f}: {im.size} is not 384×384')
            continue
        a = im.getchannel('A')
        w, h = im.size
        edge = [a.getpixel((x, 0)) for x in range(w)] + [a.getpixel((x, h - 1)) for x in range(w)] \
            + [a.getpixel((0, y)) for y in range(h)] + [a.getpixel((w - 1, y)) for y in range(h)]
        if max(edge) > 16:
            errors.append(f'{f}: opaque pixels on the edge (cut failed or subject cropped)')
        bb = a.point(lambda v: 255 if v > 16 else 0).getbbox()
        if bb is None:
            errors.append(f'{f}: empty image')
            continue
        fill = max(bb[2] - bb[0], bb[3] - bb[1]) / w
        if not 0.55 <= fill <= 0.95:
            errors.append(f'{f}: subject fills {fill:.0%} of the side (want 55–95 %)')
    if total > 6_000_000:
        errors.append(f'emoji assets {total} B over 6 MB')
    by_cat = {}
    for e in index['emoji']:
        by_cat.setdefault(e['category'], set()).add(e['id'])
    for c in data['categories']:
        core = {e['id'] for e in data['emoji'] if e['category'] == c['id'] and not e.get('reserve')}
        have = by_cat.get(c['id'], set())
        if len(have) < MIN_SHARE * len(core):
            errors.append(f'category {c["id"]}: {len(have)} of {len(core)} built')
    if len(index['emoji']) < MIN_TOTAL:
        errors.append(f'only {len(index["emoji"])} emoji built, need {MIN_TOTAL}')


def main():
    errors = []
    data = load('emoji_set.json')
    check_set(data, errors)
    check_styles(load('styles.json'), errors)
    if '--assets' in sys.argv:
        check_assets(data, errors)
    for e in errors:
        print('FAIL', e)
    core = sum(1 for e in data['emoji'] if not e.get('reserve'))
    print(f'{len(data["emoji"])} emoji ({core} core), {len(errors)} problems')
    sys.exit(1 if errors else 0)


if __name__ == '__main__':
    main()
