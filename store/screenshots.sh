#!/usr/bin/env bash
# Renders the store screenshots (test/screenshots_test.dart) for every
# language and device size the stores ask for:
#   store/screenshots/<cs|en>/<iphone69|play|ipad13|play_tablet>/stickers_*.png
# iphone69 = 1320×2868 (App Store 6.9"), play = 1242×2208 (Google Play 9:16,
# App Store 5.5"), ipad13 = 2064×2752 (App Store iPad 13"),
# play_tablet = 1800×3200 (Google Play 7" and 10" tablets).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/store/screenshots"
cd "$ROOT/handwritten_stickers"
for locale in cs en; do
  for device in ${SCREENSHOT_DEVICES:-iphone69 play ipad13 play_tablet}; do
    echo "== $locale $device"
    rm -rf "${OUT:?}/$locale/$device"
    SCREENSHOT_DIR="$OUT/$locale/$device" SCREENSHOT_LOCALE="$locale" \
      SCREENSHOT_DEVICE="$device" flutter test test/screenshots_test.dart \
      | tail -1
  done
done
