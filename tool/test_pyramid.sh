#!/usr/bin/env bash
# The test pyramid, bottom up, in one command.
#
#   tool/test_pyramid.sh [--level gates|unit|widget|e2e|all] [--device <id>] [--help]
#
#   gates   analyzer (zero issues), complexity, import guard, UI literal guard
#   unit    packages/*  — pure-Dart Morse engines
#   widget  apps/morsecq/test — hermetic widget tests (local learning, no host)
#   e2e     apps/morsecq/integration_test on a real device/desktop window:
#           the real main() click-through + the screenshot scene walk
#   all     every level in that order (default)
#
# E2E needs a device: --device, otherwise the host desktop.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEVEL="all"
DEVICE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --level) LEVEL="${2:-}"; shift 2 ;;
    --level=*) LEVEL="${1#*=}"; shift ;;
    --device) DEVICE="${2:-}"; shift 2 ;;
    --device=*) DEVICE="${1#*=}"; shift ;;
    --help|-h) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 64 ;;
  esac
done
case "$LEVEL" in gates|unit|widget|e2e|all) ;; *) echo "bad --level $LEVEL" >&2; exit 64 ;; esac

GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "${CYAN}==>${NC} $*"; }
cd "$REPO_ROOT"

declare -a RESULTS=()
FAILED=0
run_step() {  # <label> <command...>
  local label="$1"; shift
  local start=$SECONDS rc=0
  step "$label"
  "$@" || rc=$?
  local secs=$((SECONDS - start))
  if [[ $rc -eq 0 ]]; then RESULTS+=("$(printf '%-34s %s %4ss' "$label" "PASS" "$secs")")
  else RESULTS+=("$(printf '%-34s %s %4ss' "$label" "FAIL" "$secs")"); FAILED=1; fi
}

level_gates() {
  for dir in packages/* apps/*; do
    [[ -f "$dir/pubspec.yaml" ]] || continue
    run_step "analyze $dir" flutter analyze "$dir"
  done
  run_step "analyze tool" dart analyze --fatal-infos tool
  run_step "complexity gate" dart run tool/check_complexity.dart
  run_step "import guard" dart run tool/import_guard.dart
  run_step "UI literal guard" dart run tool/ui_literal_guard.dart
}

level_unit() {
  for dir in packages/*; do
    [[ -f "$dir/pubspec.yaml" && -d "$dir/test" ]] || continue
    run_step "unit $dir" bash -c "cd '$dir' && flutter test --exclude-tags=needs-native"
  done
}

level_widget() {
  run_step "widget apps/morsecq" bash -c "cd apps/morsecq && flutter test --exclude-tags=needs-native"
}

host_device() {
  case "$(uname -s)" in
    Darwin) echo macos ;; Linux) echo linux ;; MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *) echo "" ;;
  esac
}

level_e2e() {
  local device="$DEVICE"
  [[ -z "$device" ]] && device="$(host_device)"
  [[ -z "$device" ]] && { echo "e2e: no device (use --device)" >&2; return 1; }
  run_step "e2e launch [$device]" bash -c "cd apps/morsecq && flutter test integration_test/app_launch_test.dart -d '$device'"
  run_step "e2e persistence [$device]" bash -c "cd apps/morsecq && flutter test integration_test/persistence_test.dart -d '$device'"
  run_step "e2e first day [$device]" bash -c "cd apps/morsecq && flutter test integration_test/first_day_learning_test.dart -d '$device'"
  run_step "e2e scenes [$device]" bash -c "cd apps/morsecq && flutter test integration_test/screenshots_test.dart -d '$device'"
}

case "$LEVEL" in
  gates) level_gates ;;
  unit) level_unit ;;
  widget) level_widget ;;
  e2e) level_e2e ;;
  all) level_gates; level_unit; level_widget; level_e2e ;;
esac

echo ""
echo "──────── test pyramid ($LEVEL) ────────"
printf '%s\n' "${RESULTS[@]}"
if [[ $FAILED -ne 0 ]]; then echo -e "${RED}FAILED${NC}"; exit 1; fi
echo -e "${GREEN}ALL PASSED${NC}"
