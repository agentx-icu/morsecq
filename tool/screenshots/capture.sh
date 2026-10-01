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
#   --locales    comma list of en, zh (default: both). A subset is captured
#                and verified but NOT published into the committed gallery
#                (that must always hold every locale); pass --out to publish
#                a partial set somewhere else.
#   --device     use this Flutter device id instead of auto-picking one
#                (single platform only; the id must belong to that platform)
#   --out        publish root (default: doc/screenshots)
#   --keep       keep the staging directory even on success
#
# Env: MORSECQ_SHOT_STAGING (staging dir; default a fresh temp dir, always
#      kept when the run fails), MORSECQ_SHOT_WINDOW (desktop window, default
#      1280x800), MORSECQ_SHOT_PIXEL_RATIO (capture scale), MORSECQ_SHOT_THEME
#      (light|dark|system, default light) — each forwarded as a --dart-define.
#
# Do not steal focus from the desktop window while it runs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="$REPO_ROOT/apps/morsecq"
ALL_LOCALES="en,zh"
PLATFORMS="macos"
LOCALES="$ALL_LOCALES"
DEVICE=""
OUT="$REPO_ROOT/doc/screenshots"
OUT_SET=0
KEEP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --platforms) PLATFORMS="${2:-}"; shift 2 ;;
    --platforms=*) PLATFORMS="${1#*=}"; shift ;;
    --locales) LOCALES="${2:-}"; shift 2 ;;
    --locales=*) LOCALES="${1#*=}"; shift ;;
    --device) DEVICE="${2:-}"; shift 2 ;;
    --device=*) DEVICE="${1#*=}"; shift ;;
    --out) OUT="${2:-}"; OUT_SET=1; shift 2 ;;
    --out=*) OUT="${1#*=}"; OUT_SET=1; shift ;;
    --keep) KEEP=1; shift ;;
    --help|-h) sed -n '2,34p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

# ── argument validation (bash 3.2: an empty array is unbound under set -u) ──
declare -a SELECTED=() SELECTED_LOCALES=()
IFS=',' read -r -a SELECTED <<< "${PLATFORMS// /}" || true
IFS=',' read -r -a SELECTED_LOCALES <<< "${LOCALES// /}" || true
[[ ${#SELECTED[@]} -gt 0 && ${#SELECTED_LOCALES[@]} -gt 0 ]] \
  || { err "--platforms and --locales must not be empty"; exit 64; }
for p in "${SELECTED[@]}"; do
  case "$p" in macos|ios|ipad|android|linux|windows) ;;
    *) err "unknown platform: '$p' (macos|ios|ipad|android|linux|windows)"; exit 64 ;; esac
done
for l in "${SELECTED_LOCALES[@]}"; do
  case "$l" in en|zh) ;; *) err "unknown locale: '$l' (en|zh)"; exit 64 ;; esac
done
[[ -n "$DEVICE" && ${#SELECTED[@]} -gt 1 ]] && { err "--device applies to a single platform"; exit 64; }
PARTIAL_LOCALES=0
[[ "$LOCALES" != "$ALL_LOCALES" ]] && PARTIAL_LOCALES=1
if [[ "$PARTIAL_LOCALES" == "1" && "$OUT_SET" == "0" ]]; then
  warn "locales '$LOCALES' is a subset: frames are verified but NOT published into $OUT (pass --out to publish a partial set elsewhere)"
fi

# ── staging: a fresh temp dir unless MORSECQ_SHOT_STAGING names one; kept on
# any unsuccessful exit (Ctrl-C included) so the frames can be inspected ──
if [[ -n "${MORSECQ_SHOT_STAGING:-}" ]]; then
  STAGING="$MORSECQ_SHOT_STAGING"; mkdir -p "$STAGING"
else
  STAGING="$(mktemp -d "${TMPDIR:-/tmp}/morsecq_shots.XXXXXX")"
fi
# Absolute, because flutter drive runs from $APP_DIR while verify/publish run
# from here; and in native form on Windows (`pwd -W` gives C:/..., which the
# Dart driver understands and Git Bash accepts too).
STAGING="$(cd "$STAGING" && { pwd -W 2>/dev/null || pwd; })"
on_exit() {
  local rc="$1"
  if [[ "$rc" != "0" || "$KEEP" == "1" ]]; then
    err "staging kept at $STAGING"
  else
    rm -rf "$STAGING"
  fi
}
trap 'on_exit $?' EXIT

# ── device selection ─────────────────────────────────────────────────────────
# Prints the Flutter device id for a platform (auto-pick), or checks that an
# explicit id belongs to that platform. Exit 0 with an id, 1 when nothing
# matches, 2 when the listing itself failed (missing python3, flutter error).
pick_device() {  # <platform> [<explicit id>]
  local platform="$1" want_id="${2:-}" listing
  command -v python3 >/dev/null 2>&1 || { err "python3 is required to read 'flutter devices --machine' (or pass --device)"; return 2; }
  listing="$(cd "$APP_DIR" && flutter devices --machine 2>/dev/null)" || { err "flutter devices failed"; return 2; }
  printf '%s' "$listing" | python3 -c '
import json, sys
want, want_id = sys.argv[1], sys.argv[2]
prefix = {"macos": "darwin", "linux": "linux", "windows": "windows",
          "ios": "ios", "ipad": "ios", "android": "android"}[want]
try:
    rows = json.load(sys.stdin)
except ValueError:
    sys.exit(2)
for d in rows:
    tp, name, dev_id = d.get("targetPlatform", ""), d.get("name", ""), d.get("id", "")
    if not tp.startswith(prefix):
        continue
    if want == "ios" and "iPad" in name:
        continue
    if want == "ipad" and "iPad" not in name:
        continue
    if want_id and dev_id != want_id:
        continue
    print(dev_id); sys.exit(0)
sys.exit(1)
' "$platform" "$want_id"
}

# ── verification: every scene of every locale present, non-trivial, distinct ─
verify() {  # <platform>
  local platform="$1" locale scene f size sum ok=1
  local -a sums=()
  for locale in "${SELECTED_LOCALES[@]}"; do
    for scene in "${SCENES[@]}"; do
      f="$STAGING/$platform/$locale/$scene.png"
      if [[ ! -s "$f" ]]; then err "$platform/$locale/$scene.png missing"; ok=0; continue; fi
      size="$(wc -c < "$f")" || { err "cannot size $f"; return 1; }
      size="${size// /}"
      if [[ "$size" -lt "$MIN_BYTES" ]]; then err "$platform/$locale/$scene.png is only $size bytes"; ok=0; fi
      sum="$(cksum < "$f")" || { err "cksum failed on $f"; return 1; }
      sums+=("${sum%% *} $locale/$scene")
    done
  done
  [[ "$ok" == "1" ]] || return 1
  # Equal checksums are only a hint; two frames are "identical" when cmp says
  # so. Identical frames mean the walk did not move between scenes.
  local sorted prev="" prevname="" line csum name
  sorted="$(printf '%s\n' "${sums[@]}" | sort)" || { err "sort failed"; return 1; }
  while IFS= read -r line; do
    csum="${line%% *}"; name="${line#* }"
    if [[ "$csum" == "$prev" ]] && cmp -s "$STAGING/$platform/$prevname.png" "$STAGING/$platform/$name.png"; then
      err "identical frames: $prevname == $name"; ok=0
    fi
    prev="$csum"; prevname="$name"
  done <<< "$sorted"
  [[ "$ok" == "1" ]]
}

# ── publish: assemble the complete replacement next to the target, then swap ─
publish() {  # <platform>
  local platform="$1" locale tmp dst scene
  for locale in "${SELECTED_LOCALES[@]}"; do
    dst="$OUT/$platform/$locale"
    tmp="$OUT/$platform/.$locale.new.$$"
    rm -rf "$tmp" || return 1
    mkdir -p "$tmp" || return 1
    for scene in "${SCENES[@]}"; do
      cp "$STAGING/$platform/$locale/$scene.png" "$tmp/$scene.png" || { err "publish: copy of $locale/$scene failed"; rm -rf "$tmp"; return 1; }
    done
    rm -rf "$dst" || return 1
    mv "$tmp" "$dst" || { err "publish: could not move $tmp into place"; return 1; }
    # Post-condition on the result, not on the exit codes above.
    local n; n="$(ls "$dst"/*.png 2>/dev/null | wc -l)"; n="${n// /}"
    [[ "$n" == "${#SCENES[@]}" ]] || { err "publish: $dst holds $n frames, expected ${#SCENES[@]}"; return 1; }
  done
  info "published $platform → $OUT/$platform/{${LOCALES}}/"
}

# Android: the Gradle build refuses to package without libtim2tox_ffi.so
# unless morsecqAllowMissingFfi is set; the screenshots run the in-memory
# backend and never load the library, so allow the UI-only build here
# (Gradle reads ORG_GRADLE_PROJECT_<name> as a project property).
export ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true

capture_platform() {  # <platform>
  local platform="$1" device rc=0
  device="$(pick_device "$platform" "$DEVICE")" || rc=$?
  if [[ $rc -eq 2 ]]; then return 1; fi
  if [[ $rc -ne 0 || -z "$device" ]]; then
    if [[ -n "$DEVICE" ]]; then err "$platform: device '$DEVICE' is not a $platform device (see: flutter devices)"
    else err "$platform: no matching device (see: flutter devices, or pass --device)"; fi
    return 1
  fi
  step "$platform on device $device"
  (cd "$APP_DIR" && MORSECQ_SHOT_OUT="$STAGING" flutter drive \
      --driver=test_driver/integration_test.dart \
      --target=integration_test/screenshots_test.dart \
      -d "$device" \
      --dart-define=MORSECQ_FAKE_BACKEND=true \
      --dart-define=MORSECQ_SHOT_PLATFORM="$platform" \
      --dart-define=MORSECQ_SHOT_LOCALES="$LOCALES" \
      ${MORSECQ_SHOT_WINDOW:+--dart-define=MORSECQ_SHOT_WINDOW="$MORSECQ_SHOT_WINDOW"} \
      ${MORSECQ_SHOT_PIXEL_RATIO:+--dart-define=MORSECQ_SHOT_PIXEL_RATIO="$MORSECQ_SHOT_PIXEL_RATIO"} \
      ${MORSECQ_SHOT_THEME:+--dart-define=MORSECQ_SHOT_THEME="$MORSECQ_SHOT_THEME"}) \
    || { err "$platform: flutter drive failed"; return 1; }
  verify "$platform" || return 1
  if [[ "$PARTIAL_LOCALES" == "1" && "$OUT_SET" == "0" ]]; then
    info "$platform: verified $LOCALES; not published (partial locale set) — frames in $STAGING/$platform"
    KEEP=1
    return 0
  fi
  publish "$platform"
}

declare -a OK=() FAIL=()
for platform in "${SELECTED[@]}"; do
  echo ""; info "════════ $platform ════════"
  if capture_platform "$platform"; then OK+=("$platform"); else FAIL+=("$platform"); fi
done

echo ""; info "════════ done ════════"
[[ ${#OK[@]} -gt 0 ]] && info "succeeded: ${OK[*]}"
if [[ ${#FAIL[@]} -gt 0 ]]; then
  err "failed (committed frames untouched): ${FAIL[*]}"
  exit 1
fi
