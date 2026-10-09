#!/usr/bin/env bash
# Require all five platform packages before creating a draft release.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tool/ci/common.sh
source "$SCRIPT_DIR/common.sh"
[[ $# -eq 2 ]] || ci_die "Usage: verify_release_assets.sh <dist-dir> <vX.Y.Z>"
DIST_DIR="$1"
TAG="$2"
# Validate the tag against the current pubspec before reading or writing any
# release assets. In particular this rejects stale tags such as v0.2.0 when
# master now declares 1.0.0+1.
"$SCRIPT_DIR/check_version_tag.sh" "$TAG"
VERSION="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+[[:space:]]*$/\1/p' "$(ci_repo_root)/apps/morsecq/pubspec.yaml" | head -n 1)"
[[ -n "$VERSION" ]] || ci_die "Could not determine app version"
[[ -d "$DIST_DIR" ]] || ci_die "Missing release directory: $DIST_DIR"
BASE="morsecq-$VERSION"
MAC_ARCH=""
for arch in arm64 x86_64 universal2; do
  if [[ -e "$DIST_DIR/$BASE-macos-$arch.pkg" || -e "$DIST_DIR/$BASE-macos-$arch.zip" ]]; then
    [[ -z "$MAC_ARCH" ]] || ci_die "Expected exactly one macOS architecture pair"
    MAC_ARCH="$arch"
  fi
done
[[ -n "$MAC_ARCH" ]] || ci_die "Required release asset missing: macOS architecture pair"
ASSETS=(
  "$BASE-linux-x86_64.deb" "$BASE-linux-x86_64.rpm" "$BASE-linux-x86_64.tar.gz"
  "$BASE-windows-x64.msi" "$BASE-windows-x64.zip"
  "$BASE-macos-$MAC_ARCH.pkg" "$BASE-macos-$MAC_ARCH.zip"
  "$BASE-android.apk" "$BASE-android.aab" "$BASE-ios-unsigned.ipa"
)
for asset in "${ASSETS[@]}"; do
  [[ -f "$DIST_DIR/$asset" && ! -L "$DIST_DIR/$asset" && -s "$DIST_DIR/$asset" ]] ||
    ci_die "Required release asset missing, empty or not a regular file: $asset"
done
shopt -s nullglob dotglob
for path in "$DIST_DIR"/*; do
  name="$(basename "$path")"
  if [[ "$name" == SHA256SUMS ]]; then
    [[ -f "$path" && ! -L "$path" ]] || ci_die "Unexpected release asset: $name must be a regular manifest file"
    continue
  fi
  found=false
  for asset in "${ASSETS[@]}"; do
    if [[ "$asset" == "$name" ]]; then found=true; break; fi
  done
  [[ "$found" == true ]] || ci_die "Unexpected release asset: $name"
done
manifest="$(mktemp "$DIST_DIR/.SHA256SUMS.XXXXXX")"
trap 'rm -f "$manifest"' EXIT
for asset in "${ASSETS[@]}"; do
  if command -v sha256sum >/dev/null 2>&1; then
    digest="$(sha256sum "$DIST_DIR/$asset" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    digest="$(shasum -a 256 "$DIST_DIR/$asset" | awk '{print $1}')"
  else
    ci_die 'sha256sum or shasum is required'
  fi
  printf '%s  %s\n' "$digest" "$asset" >> "$manifest"
done
mv -f "$manifest" "$DIST_DIR/SHA256SUMS"
ci_log "Verified ${#ASSETS[@]} required release assets; wrote $DIST_DIR/SHA256SUMS"
