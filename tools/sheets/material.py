#!/usr/bin/env python3
"""Material letter sheets via ComfyUI (plan 02, section 1, M1–M7).

Pipeline for one material (e.g. `plasticine`):

  1. guide     glyph_extractor renders both template pages with clean font
               letters (no labels, no grid) + grid_mask.png          (M1)
  2. generate  every page is cut into strips of 4/4/2 cell rows, each strip
               goes through tools/sheets/workflows/material.json
               (img2img + Canny ControlNet) and is pasted back       (M2, M3)
  3. extract   glyph_extractor extract -bg-mode chroma -colored → sheet
               with v2 metrics, plus SOURCE.md (model, seed, prompt) (M4, M5, M7)
  4. preview   contact sheet for the manual check                  (M6)
  5. register  adds the sheet to sheets.json (category material,
               bundle:false until the licence is cleared) and pubspec.yaml

Failed cells are regenerated alone with `generate --cells 1:r3c5,2:r0c1`
(new seed, only those cells are replaced).

Needs Pillow; ComfyUI access via tools/comfy/client.py (CF Access token).
`generate --dry-run` writes the filled workflows and strip images without a
server, for checking.

  python3 tools/sheets/material.py all --material plasticine
  python3 tools/sheets/material.py generate --material neon --cells 2:r5c3 --seed 7
"""
from __future__ import annotations

import argparse
import json
import random
import shutil
import subprocess
import sys
import urllib.request
from datetime import date
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "comfy"))
from client import ComfyClient, load_workflow, set_inputs  # noqa: E402

HERE = Path(__file__).resolve().parent
EXTRACTOR_DIR = ROOT / "glyph_extractor"
ASSETS = ROOT / "handwritten_stickers" / "assets" / "glyphs"
WORK = ROOT / "tools" / "sheets" / "work"
FONT_CACHE = HERE / ".fonts"

# Template geometry at 300 DPI (glyph_extractor GridConfig).
DPI = 300
CELL_W = int(22.5 / 25.4 * DPI)
CELL_H = int(26.2 / 25.4 * DPI)
MARGIN = int(15 / 25.4 * DPI)
COLS, ROWS = 8, 10
STRIPS = [(0, 4), (4, 8), (8, 10)]  # cell rows per generated strip
GEN_WIDTH = 1536                     # model resolution (multiple of 64)

GOOGLE_FONTS = "https://github.com/google/fonts/raw/main/ofl/{family}/{file}"


def load_materials() -> tuple[dict, dict[str, dict]]:
    data = json.loads((HERE / "materials.json").read_text())
    defaults = data["defaults"]
    mats = {}
    for m in data["materials"]:
        merged = dict(defaults)
        merged.update(m)
        mats[m["id"]] = merged
    return defaults, mats


def extractor() -> Path:
    exe = EXTRACTOR_DIR / "glyph_extractor"
    if not exe.exists():
        subprocess.run(["go", "build"], cwd=EXTRACTOR_DIR, check=True)
    return exe


def run_extractor(*args: str) -> None:
    # Run from glyph_extractor/ so relative font paths (fonts/DejaVuSans.ttf) resolve.
    cmd = [str(extractor()), *args]
    print("$", " ".join(cmd))
    subprocess.run(cmd, cwd=EXTRACTOR_DIR, check=True)


def font_path(name: str) -> Path:
    """Finds a guide font locally or downloads it from github.com/google/fonts."""
    for d in (EXTRACTOR_DIR / "fonts", FONT_CACHE):
        if (d / name).exists():
            return d / name
    family = name.split("-")[0].lower()
    url = GOOGLE_FONTS.format(family=family, file=name)
    FONT_CACHE.mkdir(exist_ok=True)
    dest = FONT_CACHE / name
    print(f"downloading {url}")
    with urllib.request.urlopen(url, timeout=60) as r:
        dest.write_bytes(r.read())
    return dest


def work_dir(mat: dict) -> Path:
    d = WORK / mat["id"]
    d.mkdir(parents=True, exist_ok=True)
    return d


# -- M1 --------------------------------------------------------------------

def cmd_guide(mat: dict, font: str | None) -> None:
    wd = work_dir(mat)
    f = Path(font) if font else font_path(mat["guide_font"])
    run_extractor("template", "-guide", str(f.resolve()),
                  "-out", f"{wd / 'guide_p1.png'},{wd / 'guide_p2.png'}",
                  "-mask", str(wd / "grid_mask.png"))


# -- M2/M3 -----------------------------------------------------------------

def strip_box(r0: int, r1: int) -> tuple[int, int, int, int]:
    return (MARGIN, MARGIN + r0 * CELL_H, MARGIN + COLS * CELL_W, MARGIN + r1 * CELL_H)


def cell_box(row: int, col: int) -> tuple[int, int, int, int]:
    x, y = MARGIN + col * CELL_W, MARGIN + row * CELL_H
    return (x, y, x + CELL_W, y + CELL_H)


def parse_cells(spec: str | None) -> dict[int, set[tuple[int, int]]]:
    """'1:r3c5,2:r0c1' → {1: {(3, 5)}, 2: {(0, 1)}}"""
    out: dict[int, set[tuple[int, int]]] = {}
    if not spec:
        return out
    for item in spec.split(","):
        page, rc = item.strip().split(":")
        r, c = rc.lower().lstrip("r").split("c")
        out.setdefault(int(page), set()).add((int(r), int(c)))
    return out


def gen_size(w: int, h: int) -> tuple[int, int]:
    gh = max(64, round(GEN_WIDTH * h / w / 64) * 64)
    return GEN_WIDTH, gh


def resolve_model(client: ComfyClient | None, folder: str, name: str) -> str:
    """Exact file name on the server for a configured name or name fragment
    (e.g. 'sd_xl_base_1.0' → 'sd_xl_base_1.0.safetensors')."""
    if client is None:
        return name if name.endswith((".safetensors", ".ckpt", ".pth")) else name + ".safetensors"
    available = client.models(folder)
    if name in available:
        return name
    hits = [m for m in available if name.lower() in m.lower()]
    if not hits:
        sys.exit(f"no {folder} model matching {name!r} on {client.url}; available: {', '.join(available)}")
    return sorted(hits, key=len)[0]


def cmd_generate(mat: dict, seed: int | None, cells: str | None, dry_run: bool) -> None:
    wd = work_dir(mat)
    seed = seed if seed is not None else random.randint(1, 2**31 - 1)
    workflow = load_workflow(HERE / "workflows" / "material.json")
    redo = parse_cells(cells)
    client = None if dry_run else ComfyClient()
    ckpt = resolve_model(client, "checkpoints", mat["checkpoint"])
    cnet = resolve_model(client, "controlnet", mat["controlnet"])
    print(f"checkpoint {ckpt}, controlnet {cnet}")
    log = []

    for page in (1, 2):
        if redo and page not in redo:
            continue
        guide = Image.open(wd / f"guide_p{page}.png").convert("RGB")
        out_path = wd / f"page_p{page}.png"
        if redo:
            if not out_path.exists():
                sys.exit(f"{out_path} missing: run generate without --cells first")
            page_img = Image.open(out_path).convert("RGB")
        else:
            page_img = Image.new("RGB", guide.size, mat["background"])
        for r0, r1 in STRIPS:
            wanted = {rc for rc in redo.get(page, set()) if r0 <= rc[0] < r1}
            if redo and not wanted:
                continue
            box = strip_box(r0, r1)
            strip = guide.crop(box)
            name = f"guide_p{page}_r{r0}-{r1}.png"
            strip.save(wd / name)
            gw, gh = gen_size(strip.width, strip.height)
            filled = set_inputs(workflow, {
                "Checkpoint": {"ckpt_name": ckpt},
                "ControlNet Model": {"control_net_name": cnet},
                "Guide": {"image": name},
                "Scale": {"width": gw, "height": gh},
                "Positive": {"text": mat["prompt"] + mat["prompt_suffix"]},
                "Negative": {"text": mat["negative"] + (", " + mat["negative_extra"] if mat.get("negative_extra") else "")},
                "ControlNet": {"strength": mat["controlnet_strength"]},
                "Sampler": {"seed": seed, "denoise": mat["denoise"],
                            "steps": mat["steps"], "cfg": mat["cfg"]},
                "Save": {"filename_prefix": f"sheets/{mat['id']}_p{page}_r{r0}"},
            })
            log.append({"page": page, "rows": [r0, r1], "seed": seed, "size": [gw, gh]})
            if dry_run:
                (wd / f"workflow_p{page}_r{r0}.json").write_text(json.dumps(filled, indent=2))
                result = strip  # stand-in so the paste logic is exercised
            else:
                filled["2"]["inputs"]["image"] = client.upload(wd / name, subfolder="sheets")
                outs = client.run(filled, wd / "raw", prefix=f"p{page}_r{r0}_")
                result = Image.open(outs[0]).convert("RGB")
            result = result.resize(strip.size, Image.LANCZOS)
            if wanted:
                for row, col in wanted:
                    cb = cell_box(row, col)
                    local = (cb[0] - box[0], cb[1] - box[1], cb[2] - box[0], cb[3] - box[1])
                    page_img.paste(result.crop(local), cb[:2])
            else:
                page_img.paste(result, box[:2])
            print(f"page {page} rows {r0}-{r1}: {'dry run' if dry_run else 'generated'} (seed {seed})")
        page_img.save(out_path)

    meta_path = wd / "generation.json"
    history = json.loads(meta_path.read_text()) if meta_path.exists() else []
    history.append({"date": date.today().isoformat(), "cells": cells, "dry_run": dry_run,
                    "material": {k: mat[k] for k in ("id", "prompt", "prompt_suffix", "negative",
                                                     "checkpoint", "controlnet", "denoise",
                                                     "controlnet_strength", "steps", "cfg")},
                    "strips": log})
    meta_path.write_text(json.dumps(history, indent=2, ensure_ascii=False))


# -- M4/M5/M7 --------------------------------------------------------------

def sheet_id(mat: dict) -> str:
    return f"mat_{mat['id']}"


def cmd_extract(mat: dict, out: Path | None) -> Path:
    wd = work_dir(mat)
    out = (out or ASSETS / sheet_id(mat)).resolve()
    run_extractor("extract",
                  "-input", f"{wd / 'page_p1.png'},{wd / 'page_p2.png'}",
                  "-output", str(out), "-id", sheet_id(mat), "-name", mat["name"],
                  "-source", "material", "-colored",
                  "-bg-mode", "chroma", "-bg-color", mat["background"],
                  "-bg-tolerance", str(mat["bg_tolerance"]),
                  "-fallback", "caveat")
    history = json.loads((wd / "generation.json").read_text()) if (wd / "generation.json").exists() else []
    lines = [
        f"# {mat['name']} ({sheet_id(mat)})", "",
        "Materiálové písmo vygenerované přes ComfyUI (plán 02, sekce 1).", "",
        f"- Vodicí font: {mat['guide_font']} (SIL OFL 1.1)",
        f"- Checkpoint: {mat['checkpoint']}",
        f"- ControlNet: {mat['controlnet']} (síla {mat['controlnet_strength']})",
        f"- Denoise: {mat['denoise']}, kroky {mat['steps']}, CFG {mat['cfg']}",
        f"- Prompt: {mat['prompt']}{mat['prompt_suffix']}",
        f"- Negativní prompt: {mat['negative']}",
        f"- Workflow: tools/sheets/workflows/material.json",
        "", "## Generování", "",
    ]
    for h in history:
        seeds = sorted({s["seed"] for s in h["strips"]})
        lines.append(f"- {h['date']}: buňky {h['cells'] or 'vše'}, seed {', '.join(map(str, seeds))}"
                     + (" (dry run)" if h.get("dry_run") else ""))
    lines += ["", "## Licence", "",
              "Komerční použití výstupu ověřit podle licence checkpointu (Flux dev ≠ SDXL/Qwen-Image).",
              "Do ověření je sada v `sheets.json` s `\"bundle\": false`.", ""]
    (out / "SOURCE.md").write_text("\n".join(lines))
    return out


def cmd_preview(mat: dict, sheet: Path | None) -> None:
    sheet = (sheet or ASSETS / sheet_id(mat)).resolve()
    run_extractor("preview", str(sheet), "-out", str(work_dir(mat) / "contact.png"), "-cell", "64")


def cmd_register(mat: dict) -> None:
    sid = sheet_id(mat)
    index_path = ASSETS / "sheets.json"
    index = json.loads(index_path.read_text())
    if not any(s["id"] == sid for s in index["sheets"]):
        index["sheets"].append({"id": sid, "name": mat["name"], "path": f"assets/glyphs/{sid}/",
                                "source": "material", "category": "material", "bundle": False})
        index_path.write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n")
        print(f"sheets.json: added {sid} (bundle: false)")
    pubspec = ROOT / "handwritten_stickers" / "pubspec.yaml"
    text = pubspec.read_text()
    line = f"    - assets/glyphs/{sid}/\n"
    if line not in text:
        # Append after the last glyph sheet directory.
        anchor = text.rfind("    - assets/glyphs/")
        if anchor < 0:
            sys.exit(f"no assets/glyphs entries in pubspec.yaml; add {line.strip()} by hand")
        end = text.index("\n", anchor) + 1
        pubspec.write_text(text[:end] + line + text[end:])
        print(f"pubspec.yaml: added {line.strip()}")


def cmd_drop(mat: dict, chars: str, out: Path | None) -> None:
    """Removes failed glyphs from the sheet; the app falls back to the
    manifest `fallback` sheet for them. Recorded in SOURCE.md."""
    sheet = (out or ASSETS / sheet_id(mat)).resolve()
    manifest = json.loads((sheet / "glyphs.json").read_text())
    dropped = []
    for ch in chars:
        files = manifest["glyphs"].pop(ch, None)
        manifest.get("metrics", {}).pop(ch, None)
        if files is None:
            continue
        for f in files if isinstance(files, list) else [files]:
            (sheet / f).unlink(missing_ok=True)
        dropped.append(ch)
    (sheet / "glyphs.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    with (sheet / "SOURCE.md").open("a") as f:
        f.write(f"\nVyřazené znaky (nepovedené, berou se z `{manifest.get('fallback')}`): {' '.join(dropped)}\n")
    print(f"{sheet_id(mat)}: dropped {len(dropped)}: {' '.join(dropped)}")


def main(argv=None) -> int:
    _, mats = load_materials()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("command", choices=["guide", "generate", "extract", "preview", "register", "drop", "all", "list"])
    ap.add_argument("--material", help="material id from materials.json")
    ap.add_argument("--font", help="guide font file (default: materials.json guide_font)")
    ap.add_argument("--seed", type=int)
    ap.add_argument("--cells", help="regenerate only these cells, e.g. 1:r3c5,2:r0c1")
    ap.add_argument("--dry-run", action="store_true", help="fill workflows without calling ComfyUI")
    ap.add_argument("--chars", help="drop: characters to remove from the sheet")
    ap.add_argument("--denoise", type=float, help="override materials.json denoise")
    ap.add_argument("--strength", type=float, help="override ControlNet strength")
    ap.add_argument("--out", type=Path, help="sheet directory (default assets/glyphs/mat_<id>)")
    args = ap.parse_args(argv)

    if args.command == "list":
        for m in mats.values():
            print(f"{m['id']:12} {m['name']:10} {m['prompt']}")
        return 0
    if args.material not in mats:
        ap.error(f"--material must be one of: {', '.join(mats)}")
    mat = mats[args.material]
    if args.denoise is not None:
        mat["denoise"] = args.denoise
    if args.strength is not None:
        mat["controlnet_strength"] = args.strength

    if args.command in ("guide", "all"):
        cmd_guide(mat, args.font)
    if args.command in ("generate", "all"):
        cmd_generate(mat, args.seed, args.cells, args.dry_run)
    if args.command in ("extract", "all"):
        sheet = cmd_extract(mat, args.out)
        cmd_preview(mat, sheet)
    if args.command == "preview":
        cmd_preview(mat, args.out)
    if args.command == "register":
        cmd_register(mat)
    if args.command == "drop":
        if not args.chars:
            ap.error("drop needs --chars")
        cmd_drop(mat, args.chars, args.out)
        cmd_preview(mat, args.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
