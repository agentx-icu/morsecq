#!/usr/bin/env bash
# Owner-invoked Developer ID path. This does not submit an App Store build.
set -euo pipefail
app="${1:?application required}"
: "${MORSECQ_MACOS_APPLICATION_IDENTITY:?distribution requires application identity}"
repo="$(cd "$(dirname "$0")/../.." && pwd)"
while IFS= read -r -d '' image; do
  if file -b "$image" | grep -q 'Mach-O'; then
    codesign --force --sign "$MORSECQ_MACOS_APPLICATION_IDENTITY" --options runtime --timestamp "$image"
  fi
done < <(find "$app/Contents" -type f -print0)
while IFS= read -r -d '' bundle; do
  codesign --force --sign "$MORSECQ_MACOS_APPLICATION_IDENTITY" --options runtime --timestamp "$bundle"
done < <(find "$app/Contents" -depth -type d \( -name '*.framework' -o -name '*.app' -o -name '*.xpc' -o -name '*.appex' \) -print0)
codesign --force --sign "$MORSECQ_MACOS_APPLICATION_IDENTITY" --options runtime --timestamp \
  --entitlements "$repo/apps/morsecq/macos/Runner/Release.entitlements" "$app"
python3 "$repo/tool/ci/distribution_signing.py" "$app" --team "$MORSECQ_APPLE_TEAM_ID" --platform macos
