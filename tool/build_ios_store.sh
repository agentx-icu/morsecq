#!/usr/bin/env bash
# Build the offline trainer for App Store distribution (owner signing required).
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${MORSECQ_APPLE_TEAM_ID:?App Store export requires the verified owner Team ID}"
cd "$repo"
dart pub get --enforce-lockfile
cd apps/morsecq
flutter build ipa --release "$@"

# Inspect the signed exported IPA, not the development-signed archive.
ipa=""
count=0
while IFS= read -r candidate; do ipa="$candidate"; count=$((count + 1)); done < <(find build/ios/ipa -maxdepth 1 -type f -name '*.ipa')
[[ "$count" == 1 ]] || { echo 'Expected exactly one exported IPA' >&2; exit 1; }
mkdir -p "$repo/build"
verify_dir="$(mktemp -d "$repo/build/ios-export.XXXXXX")"
trap 'rm -rf "$verify_dir"' EXIT
ditto -x -k "$ipa" "$verify_dir"
app="$(find "$verify_dir/Payload" -maxdepth 1 -type d -name '*.app')"
python3 "$repo/tool/ci/release_preflight.py" --output "$repo/build/evidence/ios-store.json" apple "$app" --platform ios
python3 "$repo/tool/ci/distribution_signing.py" "$app" --team "$MORSECQ_APPLE_TEAM_ID" --platform ios
