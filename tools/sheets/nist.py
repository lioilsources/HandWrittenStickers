#!/usr/bin/env python3
"""NIST Special Database 19 -> per-writer handwriting glyph candidates.

Plan: Prompts/02-GLYPH_SOURCES_PLAN.md, section 3 (D1-D6). See README_nist.md.

Only the Python standard library and Pillow are required.

SD19 2nd edition layout (the part this script reads):

    by_class/<hex>/hsf_<N>.mit             label/origin list for that folder
    by_class/<hex>/hsf_<N>/hsf_<N>_<i>.png 128x128 binary image (black ink, white bg)

<hex> is the ASCII code of the class ("30".."39", "41".."5a", "61".."7a").
Each .mit file starts with a count line, followed by one line per PNG:

    hsf_7_00000.png f3600_46/d3600_46/d3600_46_00007.png

The second column points into by_write/hsf_<N>/, so its first path component
is the writer directory (f<writer>_<form template>) and the first letter of the
second component is the field it was cut from (d digit, u upper, l lower,
c constitution free text). by_write itself has no labels in the 2nd edition,
so the labels have to come from by_class.

SD19_ROOT may be the extracted directory (anything containing by_class/, or
by_class itself) or by_class.zip directly (no need to unpack 1.5 M files).

Subcommands:
    index   SD19_ROOT --out index.json
    contact index.json --top 40 --out contact/
    export  index.json --writer hsf_0/f0000 --variants 5 --out DIR [--upscale 2]
"""

from __future__ import annotations

import argparse
import io
import json
import os
import re
import sys
import time
import zipfile
from collections import defaultdict
from concurrent.futures import ProcessPoolExecutor

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError:  # pragma: no cover
    sys.exit("nist.py needs Pillow: python3 -m pip install --user Pillow")

CLASSES = [chr(c) for c in range(ord("0"), ord("9") + 1)] + \
          [chr(c) for c in range(ord("A"), ord("Z") + 1)] + \
          [chr(c) for c in range(ord("a"), ord("z") + 1)]
CLASS_SET = set(CLASSES)
SIZE = 128  # SD19 character images are 128x128

# Cleanliness tuning.
INK_MIN, INK_MAX = 0.008, 0.16      # sane share of ink pixels in the 128 px box
MIN_BOX = 6                          # ink bbox smaller than this in both axes = speck
TWO_PART = set("ij")                 # classes that legitimately have two parts
FIELD_PREF = {"d": 1.0, "u": 1.0, "l": 1.0, "c": 0.9}  # prefer form boxes over free text


# --------------------------------------------------------------------------
# Source access (directory or zip)
# --------------------------------------------------------------------------

class Source:
    """Read-only view of by_class, either a directory or by_class.zip."""

    def __init__(self, root: str):
        self.root = os.path.abspath(root)
        self.zip = None
        if os.path.isfile(root) and zipfile.is_zipfile(root):
            self.zip = zipfile.ZipFile(root)
            names = self.zip.namelist()
            self._names = set(names)
            self.prefix = self._find_zip_prefix(names)
        else:
            self.prefix = self._find_dir_prefix(root)

    @staticmethod
    def _find_zip_prefix(names):
        for n in names:
            m = re.match(r"^(.*?by_class/)", n)
            if m:
                return m.group(1)
        sys.exit("zip does not contain a by_class/ folder")

    @staticmethod
    def _find_dir_prefix(root):
        root = os.path.abspath(root)
        if os.path.basename(root.rstrip("/")) == "by_class":
            return root + "/"
        for cand in ("by_class", "data/by_class", "2ndEdition2016/data/by_class",
                     "sd19/2ndEdition2016/data/by_class"):
            p = os.path.join(root, cand)
            if os.path.isdir(p):
                return p + "/"
        for dirpath, dirnames, _ in os.walk(root):
            if "by_class" in dirnames:
                return os.path.join(dirpath, "by_class") + "/"
            if dirpath.count(os.sep) - root.count(os.sep) > 4:
                dirnames[:] = []
        sys.exit(f"no by_class/ folder under {root} (labels live only in by_class/*.mit)")

    def mit_files(self):
        """Yield (hex, partition, relpath_of_mit) excluding train_* duplicates."""
        if self.zip:
            items = [n[len(self.prefix):] for n in self._names if n.startswith(self.prefix)]
        else:
            items = []
            for hx in sorted(os.listdir(self.prefix)):
                d = os.path.join(self.prefix, hx)
                if os.path.isdir(d):
                    items += [f"{hx}/{f}" for f in os.listdir(d)]
        for rel in sorted(items):
            m = re.fullmatch(r"([0-9a-fA-F]{2})/(hsf_\d)\.mit", rel)
            if m:
                yield m.group(1).lower(), m.group(2), rel

    def read(self, rel: str) -> bytes:
        if self.zip:
            return self.zip.read(self.prefix + rel)
        with open(self.prefix + rel, "rb") as f:
            return f.read()

    def location(self, rel: str) -> str:
        return f"{self.root}!{self.prefix}{rel}" if self.zip else self.prefix + rel


def parse_mit(text: str):
    """Return [(png_name, origin_path)] from a 2nd-edition .mit file."""
    lines = [l.split() for l in text.splitlines() if l.strip()]
    if lines and len(lines[0]) == 1 and lines[0][0].isdigit():
        lines = lines[1:]
    out = []
    for parts in lines:
        if len(parts) >= 2:
            out.append((parts[0], parts[1]))
    return out


# --------------------------------------------------------------------------
# Image metrics
# --------------------------------------------------------------------------

def ink_mask(img: Image.Image) -> Image.Image:
    """'L' image, 255 where ink, 0 background."""
    g = img.convert("L")
    return g.point(lambda v: 255 if v < 128 else 0)


def components(mask: Image.Image, factor: int = 4):
    """Sizes of 8-connected components on a downscaled mask (any ink per block).

    Downscaling by 4 closes hairline gaps of 1-3 px, keeps it fast in pure Python.
    """
    w, h = mask.size
    small = mask.reduce(factor) if factor > 1 else mask
    sw, sh = small.size
    px = small.tobytes()
    ink = {i for i, v in enumerate(px) if v}
    sizes = []
    while ink:
        start = ink.pop()
        stack = [start]
        n = 0
        while stack:
            i = stack.pop()
            n += 1
            x, y = i % sw, i // sw
            for dy in (-1, 0, 1):
                yy = y + dy
                if yy < 0 or yy >= sh:
                    continue
                for dx in (-1, 0, 1):
                    xx = x + dx
                    if 0 <= xx < sw:
                        j = yy * sw + xx
                        if j in ink:
                            ink.discard(j)
                            stack.append(j)
        sizes.append(n)
    sizes.sort(reverse=True)
    return sizes


def ramp(x, lo, hi):
    if x <= lo:
        return 0.0
    if x >= hi:
        return 1.0
    return (x - lo) / (hi - lo)


def measure(data: bytes, label: str):
    """Return dict(clean, ink, bbox, clipped, parts, dom) for one PNG."""
    img = Image.open(io.BytesIO(data))
    if img.size != (SIZE, SIZE):
        img = img.resize((SIZE, SIZE))
    mask = ink_mask(img)
    bbox = mask.getbbox()
    if not bbox:
        return {"clean": 0.0, "ink": 0.0, "bbox": None, "clipped": False, "parts": 0, "dom": 0.0}
    hist = mask.histogram()
    ink = hist[255] / float(SIZE * SIZE)
    x0, y0, x1, y1 = bbox
    clipped = x0 == 0 or y0 == 0 or x1 == SIZE or y1 == SIZE
    sizes = components(mask)
    total = sum(sizes) or 1
    keep = 2 if label in TWO_PART else 1
    dom = sum(sizes[:keep]) / total

    # ink ratio: 1 inside the sane band, falls off to 0 at half/double the band
    if ink < INK_MIN:
        t_ink = ramp(ink, INK_MIN * 0.4, INK_MIN)
    elif ink > INK_MAX:
        t_ink = 1.0 - ramp(ink, INK_MAX, INK_MAX * 1.6)
    else:
        t_ink = 1.0
    t_dom = ramp(dom, 0.6, 0.95)          # stray specks / broken strokes
    t_parts = 1.0 if len(sizes) <= keep + 1 else 0.85 ** (len(sizes) - keep - 1)
    t_box = 1.0 if max(x1 - x0, y1 - y0) >= MIN_BOX else 0.1
    t_clip = 0.2 if clipped else 1.0
    clean = t_ink * (0.5 + 0.5 * t_dom) * t_parts * t_box * t_clip
    return {"clean": round(clean, 4), "ink": round(ink, 4), "bbox": list(bbox),
            "clipped": clipped, "parts": len(sizes), "dom": round(dom, 3)}


# --------------------------------------------------------------------------
# index
# --------------------------------------------------------------------------

_WORKER_SRC = None


def _worker_init(root):
    global _WORKER_SRC
    _WORKER_SRC = Source(root)


def _index_mit(job):
    hx, part, rel = job
    src = _WORKER_SRC
    label = chr(int(hx, 16))
    out = []
    try:
        entries = parse_mit(src.read(rel).decode("ascii", "replace"))
    except (KeyError, OSError) as e:
        return [("__error__", f"{rel}: {e}")]
    for png, origin in entries:
        prel = f"{hx}/{part}/{png}"
        try:
            m = measure(src.read(prel), label)
        except (KeyError, OSError) as e:
            out.append(("__error__", f"{prel}: {e}"))
            continue
        comps = origin.split("/")
        writer_dir = comps[0]                      # f3600_46
        field = comps[1][:1] if len(comps) > 1 else "?"
        m["clean"] = round(m["clean"] * FIELD_PREF.get(field, 1.0), 4)
        out.append((f"{part}/{writer_dir}", label, prel, origin, field, m))
    return out


def cmd_index(a):
    t0 = time.time()
    src = Source(a.root)
    jobs = [j for j in src.mit_files() if chr(int(j[0], 16)) in CLASS_SET]
    if a.partitions:
        want = set(a.partitions.split(","))
        jobs = [j for j in jobs if j[1] in want]
    if not jobs:
        sys.exit("no by_class/<hex>/hsf_N.mit files found")
    print(f"{len(jobs)} .mit files in {src.location('')}", file=sys.stderr)

    writers = defaultdict(lambda: defaultdict(list))  # key -> label -> [sample]
    errors = []
    n = 0
    if a.jobs > 1:
        with ProcessPoolExecutor(a.jobs, initializer=_worker_init, initargs=(a.root,)) as ex:
            results = ex.map(_index_mit, jobs)
            for k, res in enumerate(results):
                n += _collect(res, writers, errors)
                _progress(k + 1, len(jobs), n, t0)
    else:
        _worker_init(a.root)
        for k, job in enumerate(jobs):
            n += _collect(_index_mit(job), writers, errors)
            _progress(k + 1, len(jobs), n, t0)
    print(file=sys.stderr)

    out_writers = {}
    for key, per in writers.items():
        classes = {}
        all_clean = []
        best = []
        for label, samples in per.items():
            samples.sort(key=lambda s: -s["clean"])
            all_clean += [s["clean"] for s in samples]
            best.append(samples[0]["clean"])
            classes[label] = {"count": len(samples), "samples": samples[:a.keep]}
        cov = sum(1 for c in CLASSES if c in classes)
        complete = cov == len(CLASSES)
        mean_clean = sum(all_clean) / len(all_clean)
        # coverage complete counts 1.0; incomplete writers get a partial,
        # always lower, credit so they sort below every complete one.
        score = (1.0 if complete else 0.5 * cov / len(CLASSES)) + mean_clean
        hsf, fdir = key.split("/")
        out_writers[key] = {
            "partition": hsf,
            "writer": fdir.split("_")[0],
            "writer_dir": fdir,
            "coverage": cov,
            "complete": complete,
            "missing": [c for c in CLASSES if c not in classes],
            "images": len(all_clean),
            "mean_clean": round(mean_clean, 4),
            "best_clean": round(sum(best) / len(CLASSES), 4),
            "score": round(score, 4),
            "classes": {c: classes[c] for c in CLASSES if c in classes},
        }
    ranked = sorted(out_writers, key=lambda k: -out_writers[k]["score"])
    index = {
        "version": 1,
        "source": "NIST Special Database 19, 2nd edition (by_class + .mit)",
        "root": src.root,
        "prefix": src.prefix,
        "zip": bool(src.zip),
        "classes": "".join(CLASSES),
        "images": n,
        "ranking": ranked,
        "writers": out_writers,
        "errors": errors[:200],
    }
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    with open(a.out, "w") as f:
        json.dump(index, f, ensure_ascii=False, separators=(",", ":"))
    complete = sum(1 for w in out_writers.values() if w["complete"])
    print(f"indexed {n} images, {len(out_writers)} writers ({complete} with all 62 classes), "
          f"{len(errors)} errors, {time.time() - t0:.0f}s -> {a.out}", file=sys.stderr)
    for k in ranked[:10]:
        w = out_writers[k]
        print(f"  {k:22s} score {w['score']:.3f} coverage {w['coverage']}/62 "
              f"clean {w['mean_clean']:.3f}", file=sys.stderr)


def _collect(res, writers, errors):
    n = 0
    for item in res:
        if item[0] == "__error__":
            errors.append(item[1])
            continue
        key, label, prel, origin, field, m = item
        m = dict(m, file=prel, origin=origin, field=field)
        writers[key][label].append(m)
        n += 1
    return n


def _progress(k, total, n, t0):
    if sys.stderr.isatty():
        print(f"\r  {k}/{total} files, {n} images, {time.time() - t0:.0f}s",
              end="", file=sys.stderr, flush=True)


# --------------------------------------------------------------------------
# helpers shared by contact/export
# --------------------------------------------------------------------------

def load_index(path):
    with open(path) as f:
        return json.load(f)


def open_source(index):
    return Source(index["root"])


def find_writer(index, spec):
    """Accept 'hsf_0/f0000', 'hsf_0/f0000_14', 'f0000' or a ranking number '#3'."""
    ws = index["writers"]
    if spec.startswith("#"):
        return index["ranking"][int(spec[1:]) - 1]
    if spec in ws:
        return spec
    spec = spec.strip("/")
    hits = [k for k in ws if k.startswith(spec + "_") or k.split("/")[1].startswith(spec + "_")
            or k.split("/")[1] == spec]
    if len(hits) == 1:
        return hits[0]
    if not hits:
        sys.exit(f"writer {spec!r} not in index")
    sys.exit(f"writer {spec!r} is ambiguous: {', '.join(sorted(hits))}")


def sheet_id(key):
    hsf, fdir = key.split("/")
    return f"nist_{hsf}_{fdir.split('_')[0]}"


def rgba_glyph(data: bytes, pad: int = 2, upscale: int = 1):
    """128 px binary PNG -> (RGBA image cropped to ink bbox + pad, bbox in 128 px coords)."""
    img = Image.open(io.BytesIO(data))
    mask = ink_mask(img)
    bbox = mask.getbbox()
    if not bbox:
        return None, None
    x0, y0, x1, y1 = bbox
    box = (max(0, x0 - pad), max(0, y0 - pad), min(SIZE, x1 + pad), min(SIZE, y1 + pad))
    alpha = mask.crop(box)
    # keep the padding even if the ink touches the edge of the 128 box
    w, h = (x1 - x0) + 2 * pad, (y1 - y0) + 2 * pad
    canvas = Image.new("L", (w, h), 0)
    canvas.paste(alpha, (box[0] - (x0 - pad), box[1] - (y0 - pad)))
    alpha = canvas
    if upscale > 1:
        alpha = alpha.resize((w * upscale, h * upscale), Image.LANCZOS)
        # soften the staircase of the binary source, then re-sharpen the edge a bit
        alpha = alpha.filter(ImageFilter.GaussianBlur(radius=0.45 * upscale))
        alpha = alpha.point(lambda v: 0 if v < 24 else (255 if v > 200 else int((v - 24) * 255 / 176)))
    black = Image.new("RGBA", alpha.size, (0, 0, 0, 255))
    black.putalpha(alpha)
    return black, bbox


# --------------------------------------------------------------------------
# contact
# --------------------------------------------------------------------------

def _font(size):
    for p in ("/System/Library/Fonts/Supplemental/Arial.ttf",
              "/System/Library/Fonts/Helvetica.ttc",
              "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"):
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except OSError:
                pass
    return ImageFont.load_default()


def cmd_contact(a):
    index = load_index(a.index)
    src = open_source(index)
    os.makedirs(a.out, exist_ok=True)
    keys = [find_writer(index, a.writer)] if a.writer else index["ranking"][:a.top]
    cell, cols, head = 80, 16, 36
    lab_font, head_font = _font(11), _font(15)
    rows = (len(CLASSES) + cols - 1) // cols
    listing = []
    for rank, key in enumerate(keys, 1):
        w = index["writers"][key]
        sheet = Image.new("RGB", (cols * cell, head + rows * cell), "white")
        d = ImageDraw.Draw(sheet)
        d.text((8, 9), f"#{rank}  {key}  score {w['score']:.3f}  coverage {w['coverage']}/62  "
               f"clean {w['mean_clean']:.3f}  images {w['images']}", fill="black", font=head_font)
        for i, c in enumerate(CLASSES):
            cx, cy = (i % cols) * cell, head + (i // cols) * cell
            d.rectangle([cx, cy, cx + cell - 1, cy + cell - 1], outline=(220, 220, 220))
            d.text((cx + 3, cy + 2), c, fill=(200, 0, 0), font=lab_font)
            info = w["classes"].get(c)
            if not info:
                d.line([cx + 10, cy + 10, cx + cell - 10, cy + cell - 10], fill=(255, 160, 160), width=2)
                continue
            s = info["samples"][0]
            g = Image.open(io.BytesIO(src.read(s["file"]))).convert("L")
            g = g.resize((cell - 16, cell - 16), Image.LANCZOS)
            sheet.paste(g, (cx + 8, cy + 8))
            col = (0, 140, 0) if s["clean"] >= 0.8 else (200, 120, 0) if s["clean"] >= 0.4 else (220, 0, 0)
            d.text((cx + cell - 28, cy + cell - 14), f"{s['clean']:.2f}", fill=col, font=lab_font)
        name = f"{rank:03d}_{key.replace('/', '_')}.png"
        sheet.save(os.path.join(a.out, name))
        listing.append(f"{rank:3d}  {key:22s}  {w['score']:.3f}  {name}")
    with open(os.path.join(a.out, "ranking.txt"), "w") as f:
        f.write("\n".join(listing) + "\n")
    print(f"{len(keys)} contact sheets -> {a.out}", file=sys.stderr)


# --------------------------------------------------------------------------
# export
# --------------------------------------------------------------------------

def cmd_export(a):
    index = load_index(a.index)
    src = open_source(index)
    key = find_writer(index, a.writer)
    w = index["writers"][key]
    out_dir = os.path.abspath(a.out)
    cand_dir = os.path.join(out_dir, "candidates")
    os.makedirs(cand_dir, exist_ok=True)
    up = max(1, a.upscale)
    cands = []
    for c in CLASSES:
        info = w["classes"].get(c)
        if not info:
            continue
        samples = [s for s in info["samples"] if s["clean"] >= a.min_clean] or info["samples"][:1]
        for s in samples[:a.variants]:
            img, bbox = rgba_glyph(src.read(s["file"]), pad=2, upscale=up)
            if img is None:
                continue
            i = len(cands)
            rel = f"candidates/{i:04d}.png"
            img.save(os.path.join(out_dir, rel))
            cands.append({
                "id": i,
                "file": rel,
                "line": 0,
                "order": i,
                "bbox": [v * up for v in bbox],
                "label": c,
                "nist": {"file": s["file"], "origin": s["origin"], "clean": s["clean"]},
            })
    doc = {
        "version": 1,
        "source": f"nist-sd19 {key}",
        "dpi": 300,
        "candidates": cands,
    }
    with open(os.path.join(out_dir, "candidates.json"), "w") as f:
        json.dump(doc, f, ensure_ascii=False, indent=1)
    sid = a.id or sheet_id(key)
    labels = sorted({c["label"] for c in cands}, key=CLASSES.index)
    with open(os.path.join(out_dir, "SOURCE.md"), "w") as f:
        f.write(
            "# Zdroj\n\n"
            "NIST Special Database 19 (2nd edition), public domain "
            "(U.S. Government work, not subject to copyright in the USA).\n\n"
            f"- writer id: `{key}` (partition `{w['partition']}`, writer `{w['writer']}`, "
            f"form directory `{w['writer_dir']}`)\n"
            f"- sheet id: `{sid}`\n"
            f"- classes: {len(labels)}/62, variants per class: up to {a.variants}, "
            f"upscale: {up}x\n"
            f"- missing classes: {''.join(w['missing']) or 'none'}\n"
            "- origin: https://www.nist.gov/srd/nist-special-database-19\n"
            "- punctuation, symbols and Czech diacritics are not in SD19 "
            "(fallback sheet / composed accents, see plan D4, D5)\n"
        )
    name = a.name or "Rukopis č. N"
    print(f"{len(cands)} candidates for {len(labels)} classes -> {out_dir}", file=sys.stderr)
    print(f'next: glyph_extractor assemble {os.path.join(out_dir, "candidates.json")} '
          f'-output SHEET --id {sid} --name "{name}"', file=sys.stderr)


# --------------------------------------------------------------------------

def main(argv=None):
    p = argparse.ArgumentParser(description="NIST SD19 -> handwriting glyph candidates")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("index", help="score every writer in SD19 by_class")
    s.add_argument("root", help="SD19 directory (containing by_class/) or by_class.zip")
    s.add_argument("--out", default="index.json")
    s.add_argument("--keep", type=int, default=8, help="samples kept per writer and class")
    s.add_argument("--jobs", type=int, default=os.cpu_count() or 1)
    s.add_argument("--partitions", help="comma list, e.g. hsf_0,hsf_1 (default all)")
    s.set_defaults(fn=cmd_index)

    s = sub.add_parser("contact", help="contact sheet PNG per top writer")
    s.add_argument("index")
    s.add_argument("--top", type=int, default=40)
    s.add_argument("--writer", help="only this writer instead of the top N")
    s.add_argument("--out", default="contact")
    s.set_defaults(fn=cmd_contact)

    s = sub.add_parser("export", help="write candidates.json for glyph_extractor assemble")
    s.add_argument("index")
    s.add_argument("--writer", required=True, help="hsf_0/f0000, hsf_0/f0000_14 or #rank")
    s.add_argument("--variants", type=int, default=5)
    s.add_argument("--min-clean", type=float, default=0.4,
                   help="skip samples below this cleanliness (best one is always kept)")
    s.add_argument("--upscale", type=int, default=1, help="2 or 3: LANCZOS + slight blur")
    s.add_argument("--id", help="sheet id for the printed assemble command")
    s.add_argument("--name", help="sheet name for the printed assemble command")
    s.add_argument("--out", required=True)
    s.set_defaults(fn=cmd_export)

    a = p.parse_args(argv)
    a.fn(a)


if __name__ == "__main__":
    main()
