#!/usr/bin/env bash
# Build the offline trainer for App Store distribution (owner signing required).
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"
dart pub get
cd apps/morsecq
flutter build ipa --release "$@"
