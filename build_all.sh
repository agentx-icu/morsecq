#!/usr/bin/env bash
# Build MorseCQ's offline Flutter app, with no native chat bootstrap.
# ./build_all.sh --platform macos --mode release [--clean]
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
platform=""; mode=release; clean=0
while [[ $# -gt 0 ]]; do
 case "$1" in
  --platform) platform="${2:-}"; shift 2 ;;
  --mode) mode="${2:-}"; shift 2 ;;
  --clean) clean=1; shift ;;
  --help|-h) echo 'build_all.sh --platform macos|linux|windows|android|ios --mode debug|profile|release [--clean]'; exit 0 ;;
  *) echo "Unknown option: $1" >&2; exit 64 ;;
 esac
done
case "$mode" in debug|profile|release) ;; *) echo 'Invalid build mode' >&2; exit 64 ;; esac
if [[ -z "$platform" ]]; then
 case "$(uname -s)" in Darwin) platform=macos ;; Linux) platform=linux ;; MINGW*|MSYS*|CYGWIN*) platform=windows ;; *) exit 64 ;; esac
fi
case "$platform" in macos|linux|windows|android|ios) ;; *) echo 'Invalid platform' >&2; exit 64 ;; esac
cd "$repo"
dart pub get
cd apps/morsecq
if [[ "$clean" == 1 ]]; then flutter clean; fi
case "$platform" in
 android) flutter build apk --"$mode"; if [[ "$mode" == release ]]; then flutter build appbundle --release; fi ;;
 ios) flutter build ios --"$mode" --no-codesign ;;
 *) flutter build "$platform" --"$mode" ;;
esac
