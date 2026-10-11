#!/usr/bin/env bash
# Rebuilds the CuteKidFonts glyph sheets of the app:
#   Flutter renders every glyph with the CuteKidFonts painter (test/render_sheets_test.dart),
#   glyph_extractor assemble adds metrics and normalises size, OFL licences are copied.
# Needs ../../../CuteKidFonts next to this repo. Sheet list + names: sheets.json here.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
KID="$(cd "$ROOT/../CuteKidFonts" && pwd)"
ASSETS="$ROOT/handwritten_stickers/assets/glyphs"
OUT="$HERE/build/candidates"

(cd "$ROOT/glyph_extractor" && go build)
rm -rf "$OUT"
(cd "$HERE" && flutter pub get >/dev/null && KID_SHEETS_OUT="$OUT" flutter test)

python3 - "$HERE/sheets.json" <<'PY' | while IFS=$'\t' read -r id name colored license cap; do
import json, sys
for s in json.load(open(sys.argv[1])):
    print(f"{s['id']}\t{s['name']}\t{'1' if s['colored'] else '0'}\t{s['license']}\t{s['capRatio']}")
PY
  dest="$ASSETS/$id"
  rm -rf "$dest"
  flags=(-output "$dest" -id "$id" -name "$name" -source font -license OFL-1.1
         -attribution "CuteKidFonts (github.com/lioilsources/CuteKidFonts)" -cap-ratio "$cap")
  [[ "$colored" == 1 ]] && flags+=(-colored)
  "$ROOT/glyph_extractor/glyph_extractor" assemble "$OUT/$id/candidates.json" "${flags[@]}" | tail -1
  cp "$KID/fonts/$license" "$dest/OFL.txt"
done
