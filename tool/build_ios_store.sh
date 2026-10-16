#!/usr/bin/env bash
# Build a signed iOS App Store archive for TestFlight/App Store distribution.
# This path intentionally requires an Apple signing identity and provisioning
# profile. CI's unsigned IPA is a separate artifact and cannot be uploaded.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
app_dir="$repo/apps/morsecq"
cd "$repo"

# Do not let a caller accidentally turn this into an ad-hoc, development, or
# unsigned build. Extra Flutter/Xcode flags remain supported, but the export
# method and signing mode are owned by this store script.
for arg in "$@"; do
  case "$arg" in
    --no-codesign|--no-codesign=*)
      echo "[ios-store][error] --no-codesign is not valid for TestFlight/App Store output" >&2
      exit 64
      ;;
    --export-method|--export-method=*|--export-options-plist|--export-options-plist=*|--debug|--profile)
      echo "[ios-store][error] release/App Store export is fixed; do not override its build mode or export options" >&2
      exit 64
      ;;
  esac
done

bash "$repo/tool/ci/check_version_tag.sh"
dart pub get --enforce-lockfile
cd "$app_dir"
# Remove a previous IPA so a failed export cannot leave a stale file that looks
# uploadable. flutter build ipa performs archive signing and export with the
# selected Apple Team/provisioning settings.
rm -rf build/ios/ipa
flutter build ipa --release --export-method app-store "$@"

shopt -s nullglob
ipas=(build/ios/ipa/*.ipa)
if [[ "${#ipas[@]}" -ne 1 || ! -s "${ipas[0]}" ]]; then
  echo '[ios-store][error] expected exactly one non-empty App Store IPA in build/ios/ipa/' >&2
  exit 1
fi

# Flutter derives archive and application names from the Xcode product, which
# can differ from the Runner scheme. Do not assume either name is Runner.
archive_apps=(build/ios/archive/*.xcarchive/Products/Applications/*.app)
if [[ "${#archive_apps[@]}" -ne 1 || ! -d "${archive_apps[0]}" ]]; then
  echo '[ios-store][error] expected exactly one archived application under build/ios/archive/' >&2
  exit 1
fi
archive_app="${archive_apps[0]}"
if command -v codesign >/dev/null 2>&1; then
  codesign --verify --deep --strict --verbose=2 "$archive_app" >/dev/null
else
  echo '[ios-store][error] codesign is required to verify the signed archive' >&2
  exit 1
fi
printf '[ios-store] signed App Store IPA: %s\n' "${ipas[0]}"
