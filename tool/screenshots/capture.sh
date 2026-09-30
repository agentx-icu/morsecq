#!/usr/bin/env bash
# Product-screenshot pipeline — one command, every platform this host can drive.
#
#   tool/screenshots/capture.sh [--platforms macos,ios,ipad,android,linux,windows]
#                               [--locales en,zh] [--device <flutter device id>]
#                               [--out <dir>] [--keep] [--help]
#
# For each platform it runs apps/morsecq/integration_test/screenshots_test.dart
# through `flutter drive` on a real device/simulator/desktop window with the
# in-memory backend (--dart-define=MORSECQ_FAKE_BACKEND=true), seeded with
# demo data, in every locale. The app captures its own Flutter layer (no OS
# permission, no window grab) and the driver writes the PNGs to a staging
# directory. A platform is published into doc/screenshots/<platform>/<locale>/
# only when every scene of every locale is present, non-trivial and distinct;
# otherwise the committed frames stay untouched and the staging dir is kept.
#
#   --platforms  comma list (default: macos). ios = iPhone simulator,
#                ipad = iPad simulator, android = emulator/device.
#   --locales    comma list of en, zh (default: both)
#   --device     use this Flutter device id instead of auto-picking one
#                (only meaningful with a single platform)
#   --out        publish root (default: doc/screenshots)
#   --keep       keep the staging directory even on success
#
# Env: MORSECQ_SHOT_WINDOW (desktop window, default 1280x800),
#      MORSECQ_SHOT_PIXEL_RATIO (capture scale; default 1 on desktop, ≤2 mobile).
#
# Do not steal focus from the desktop window while it runs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="$REPO_ROOT/apps/morsecq"
PLATFORMS="macos"
LOCALES="en,zh"
DEVICE=""
OUT="$REPO_ROOT/doc/screenshots"
KEEP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --platforms) PLATFORMS="${2:-}"; shift 2 ;;
    --platforms=*) PLATFORMS="${1#*=}"; shift ;;
    --locales) LOCALES="${2:-}"; shift 2 ;;
    --locales=*) LOCALES="${1#*=}"; shift ;;
    --device) DEVICE="${2:-}"; shift 2 ;;
    --device=*) DEVICE="${1#*=}"; shift ;;
    --out) OUT="${2:-}"; shift 2 ;;
    --out=*) OUT="${1#*=}"; shift ;;
    --keep) KEEP=1; shift ;;
    --help|-h) sed -n '2,29p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 64 ;;
  esac
done

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info() { echo -e "${GREEN}[capture]${NC} $*"; }
warn() { echo -e "${YELLOW}[capture]${NC} $*"; }
err()  { echo -e "${RED}[capture]${NC} $*" >&2; }
step() { echo -e "${CYAN}==>${NC} $*"; }

# Must match kScenes in apps/morsecq/integration_test/support/scene_walk.dart.
SCENES=(welcome create_identity backup_wizard learn_home stats training_settings
        receive_drill send_practice chat_list conversation contacts groups
        group_conversation reference translator listen me)
MIN_BYTES=8192

STAGING="$(mktemp -d -t morsecq_shots.XXXXXX)"
cleanup() { [[ "$KEEP" == "1" ]] || rm -rf "$STAGING"; }
trap cleanup EXIT

# Flutter device id for a platform: `flutter devices --machine` filtered by
# targetPlatform (and iPhone/iPad by name). Prints nothing when none matches.
pick_device() {  # <platform>
  local platform="$1"
  (cd "$APP_DIR" && flutter devices --machine 2>/dev/null) | python3 -c '
import json, sys
want = sys.argv[1]
prefix = {"macos": "darwin", "linux": "linux", "windows": "windows",
          "ios": "ios", "ipad": "ios", "android": "android"}[want]
rows = json.load(sys.stdin)
for d in rows:
    tp = d.get("targetPlatform", "")
    name = d.get("name", "")
    if not tp.startswith(prefix):
        continue
    if want == "ios" and "iPad" in name:
        continue
    if want == "ipad" and "iPad" not in name:
        continue
    print(d["id"]); break
' "$platform"
}

verify() {  # <platform>
  local platform="$1" locale scene f size ok=1
  local -a sums=()
  IFS=',' read -r -a locales <<< "$LOCALES"
  for locale in "${locales[@]}"; do
    for scene in "${SCENES[@]}"; do
      f="$STAGING/$platform/$locale/$scene.png"
      if [[ ! -s "$f" ]]; then err "$platform/$locale/$scene.png missing"; ok=0; continue; fi
      size=$(wc -c < "$f" | tr -d ' ')
      if [[ "$size" -lt "$MIN_BYTES" ]]; then err "$platform/$locale/$scene.png is only $size bytes"; ok=0; fi
      sums+=("$(cksum < "$f" | cut -d' ' -f1) $locale/$scene")
    done
  done
  # Two byte-identical frames mean the walk did not move between scenes.
  local dup
  dup="$(printf '%s\n' "${sums[@]}" | sort | awk '{ if ($1 == prev) print prevname " == " $2; prev = $1; prevname = $2 }')"
  if [[ -n "$dup" ]]; then err "identical frames:"; echo "$dup" >&2; ok=0; fi
  [[ "$ok" == "1" ]]
}

publish() {  # <platform>
  local platform="$1" locale
  IFS=',' read -r -a locales <<< "$LOCALES"
  for locale in "${locales[@]}"; do
    rm -rf "${OUT:?}/$platform/$locale"
    mkdir -p "$OUT/$platform/$locale"
    cp "$STAGING/$platform/$locale/"*.png "$OUT/$platform/$locale/"
  done
  info "published $platform → $OUT/$platform/{${LOCALES}}/"
}

capture_platform() {  # <platform>
  local platform="$1" device="$DEVICE"
  [[ -z "$device" ]] && device="$(pick_device "$platform" || true)"
  [[ -z "$device" ]] && { err "$platform: no matching device (see: flutter devices)"; return 1; }
  step "$platform on device $device"
  (cd "$APP_DIR" && MORSECQ_SHOT_OUT="$STAGING" flutter drive \
      --driver=test_driver/integration_test.dart \
      --target=integration_test/screenshots_test.dart \
      -d "$device" \
      --dart-define=MORSECQ_FAKE_BACKEND=true \
      --dart-define=MORSECQ_SHOT_PLATFORM="$platform" \
      --dart-define=MORSECQ_SHOT_LOCALES="$LOCALES" \
      ${MORSECQ_SHOT_WINDOW:+--dart-define=MORSECQ_SHOT_WINDOW="$MORSECQ_SHOT_WINDOW"} \
      ${MORSECQ_SHOT_PIXEL_RATIO:+--dart-define=MORSECQ_SHOT_PIXEL_RATIO="$MORSECQ_SHOT_PIXEL_RATIO"}) \
    || { err "$platform: flutter drive failed"; return 1; }
  verify "$platform" || return 1
  publish "$platform"
}

declare -a OK=() FAIL=()
IFS=',' read -r -a SELECTED <<< "${PLATFORMS// /}"
for platform in "${SELECTED[@]}"; do
  [[ -z "$platform" ]] && continue
  case "$platform" in macos|ios|ipad|android|linux|windows) ;;
    *) err "unknown platform: $platform"; exit 64 ;; esac
  echo ""; info "════════ $platform ════════"
  if capture_platform "$platform"; then OK+=("$platform"); else FAIL+=("$platform"); fi
done

echo ""; info "════════ done ════════"
[[ ${#OK[@]} -gt 0 ]] && info "published: ${OK[*]}"
if [[ ${#FAIL[@]} -gt 0 ]]; then
  err "failed (committed frames untouched): ${FAIL[*]} — staging kept at $STAGING"
  KEEP=1
  exit 1
fi
