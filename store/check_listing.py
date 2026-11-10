#!/usr/bin/env python3
"""Checks the length limits in store/listing.md.

A heading ending in `(≤N)` limits the code block that follows it; a table
header cell ending in `(≤N)` limits every cell of its column. Keywords
(comma separated) are also checked for repeats.
"""
import re
import sys
from pathlib import Path

LIMIT = re.compile(r"\(≤(\d+)\)\s*$")


def main() -> int:
    lines = Path(__file__).with_name("listing.md").read_text("utf-8").splitlines()
    errors = 0
    section = ""
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("## "):
            section = line[3:]
        heading = LIMIT.search(line) if line.startswith("### ") else None
        if heading:
            limit = int(heading.group(1))
            start = next(j for j in range(i + 1, len(lines)) if lines[j] == "```")
            end = next(j for j in range(start + 1, len(lines)) if lines[j] == "```")
            text = "\n".join(lines[start + 1 : end])
            name = f"{section}: {line[4:]}"
            ok = len(text) <= limit
            errors += not ok
            print(f"{'ok  ' if ok else 'LONG'} {len(text):5}/{limit:<5} {name}")
            if "keywords" in line:
                words = text.split(",")
                repeats = {w for w in words if words.count(w) > 1}
                if repeats:
                    errors += 1
                    print(f"     repeated keywords: {sorted(repeats)}")
            i = end
        elif line.startswith("|") and LIMIT.search(line.split("|")[-2]):
            limits = [LIMIT.search(c) for c in line.split("|")[1:-1]]
            i += 2  # separator row
            while i < len(lines) and lines[i].startswith("|"):
                cells = [c.strip() for c in lines[i].split("|")[1:-1]]
                for cell, m in zip(cells, limits):
                    if m and len(cell) > int(m.group(1)):
                        errors += 1
                        print(f"LONG {len(cell):5}/{m.group(1):<5} {cell}")
                i += 1
            print("ok   table of in-app purchases" if not errors else "")
            continue
        i += 1
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
