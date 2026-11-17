#!/usr/bin/env bash
# Runs every apps/morsecq/integration_test/*_test.dart on one device, one app
# launch per file, and retries a failed file once so a single slow emulator
# frame does not fail the job. A file that fails twice fails the run; the
# summary lists every file with its outcome.
#
#   tool/ci/run_integration_tests.sh -d <device-id> [--shard <index>/<count>] [--skip <file>]...
set -euo pipefail

DEVICE=""
SHARD_INDEX=1
SHARD_COUNT=1
declare -a SKIP=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--device) DEVICE="${2:-}"; shift 2 ;;
    --shard)
      if [[ ! ${2:-} =~ ^([1-9][0-9]{0,8})/([1-9][0-9]{0,8})$ ]]; then
        echo 'expected --shard <index>/<count> with positive integers' >&2
        exit 64
      fi
      SHARD_INDEX=${BASH_REMATCH[1]}
      SHARD_COUNT=${BASH_REMATCH[2]}
      shift 2 ;;
    --skip) SKIP+=("${2:-}"); shift 2 ;;
    *) echo "unknown flag: $1" >&2; exit 64 ;;
  esac
done
[[ -n "$DEVICE" ]] || { echo 'usage: run_integration_tests.sh -d <device-id> [--shard <index>/<count>]' >&2; exit 64; }
(( SHARD_INDEX <= SHARD_COUNT )) || { echo 'shard index exceeds shard count' >&2; exit 64; }

cd "$(dirname "${BASH_SOURCE[0]}")/../../apps/morsecq"
declare -a RESULTS=()
FAILED=0
POSITION=0
shopt -s nullglob
for f in integration_test/*_test.dart; do
  POSITION=$((POSITION + 1))
  (( (POSITION - 1) % SHARD_COUNT == SHARD_INDEX - 1 )) || continue
  name="$(basename "$f")"
  if [[ ${#SKIP[@]} -gt 0 ]] && printf '%s\n' "${SKIP[@]}" | grep -qx "$name"; then
    RESULTS+=("SKIP $name"); continue
  fi
  outcome=FAIL
  for attempt in 1 2; do
    echo "::group::$name on $DEVICE (attempt $attempt)"
    if flutter test "$f" -d "$DEVICE"; then
      echo "::endgroup::"
      if [[ $attempt -eq 1 ]]; then
        outcome=PASS
      else
        outcome="PASS (retried)"
        echo "::warning::$name passed on $DEVICE only after a retry"
      fi
      break
    fi
    echo "::endgroup::"
  done
  RESULTS+=("$outcome $name")
  [[ $outcome == FAIL ]] && FAILED=1
done
(( POSITION >= SHARD_INDEX )) || { echo 'no integration test files for this shard' >&2; exit 64; }
printf '%s\n' "${RESULTS[@]}"
exit "$FAILED"
