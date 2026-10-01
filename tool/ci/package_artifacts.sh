#!/usr/bin/env bash
# Turns one platform's release build into the files a GitHub release ships,
# under dist/<target>/ (modelled on toxee/tool/ci/package_artifacts.sh):
#
#   linux    morsecq-<v>-linux-x86_64.{deb,rpm,tar.gz}   (CPack, tool/ci/linux-installer)
#   windows  morsecq-<v>-windows-x64.{msi,zip}           (CPack + WiX v3, tool/ci/windows-installer)
#   macos    morsecq-<v>-macos-arm64.{pkg,zip}           (pkgbuild into /Applications; ditto zip)
#   android  morsecq-<v>-android.{apk,aab}
#   ios      morsecq-<v>-ios-unsigned.ipa                (no signing identity on CI)
#
# Run from anywhere after the matching `flutter build <target> --release`
# (the Native workflow does both). <v> is the tag without its "v" on a tag
# build, else the version in apps/morsecq/pubspec.yaml. Every package must
# carry the Tox backend (libtim2tox_ffi); a build without it is refused.
#
#   tool/ci/package_artifacts.sh --target <linux|windows|macos|android|ios>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tool/ci/common.sh
source "$SCRIPT_DIR/common.sh"

TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --help|-h) sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) ci_die "Unknown option: $1" ;;
  esac
done
[[ -n "$TARGET" ]] || ci_die "--target is required"

REPO_ROOT="$(ci_repo_root)"
APP_DIR="$REPO_ROOT/apps/morsecq"
BUILD_DIR="$APP_DIR/build"
DIST_DIR="$REPO_ROOT/dist/$TARGET"
ci_reset_dir "$DIST_DIR"

release_version() {
  if [[ "${GITHUB_REF_TYPE:-}" == "tag" && "${GITHUB_REF_NAME:-}" == v* ]]; then
    printf '%s\n' "${GITHUB_REF_NAME#v}"
    return
  fi
  sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' "$APP_DIR/pubspec.yaml" | head -n 1
}
VERSION="$(release_version)"
[[ -n "$VERSION" ]] || ci_die "could not determine the release version"
BASE="morsecq-$VERSION"

# Copies the single top-level file in <dir> matching <glob> to <dest>
# (CPack leaves its staging trees in subdirectories; only the root holds
# the finished package).
copy_one() {  # <dir> <glob> <dest>
  local -a hits=()
  while IFS= read -r f; do hits+=("$f"); done < <(find "$1" -maxdepth 1 -type f -name "$2")
  [[ ${#hits[@]} -eq 1 ]] || ci_die "expected exactly one $2 in $1, found ${#hits[@]}"
  cp "${hits[0]}" "$3"
}

# The Tox backend must be inside what ships, and must not carry the Tim2Tox
# auto_tests-only hooks.
require_ffi() {  # <path> <label>
  [[ -e "$1" ]] || ci_die "$2: libtim2tox_ffi missing at $1 -- refusing to package a build without the Tox backend"
  bash "$SCRIPT_DIR/assert_no_test_hooks.sh" "$1"
}

package_linux() {
  local bundle="$BUILD_DIR/linux/x64/release/bundle" stage installer
  [[ -x "$bundle/morsecq" ]] || ci_die "Linux bundle not found: $bundle"
  require_ffi "$bundle/lib/libtim2tox_ffi.so" linux

  stage="$DIST_DIR/.stage/morsecq"
  mkdir -p "$stage"
  cp -a "$bundle/." "$stage/"
  tar -C "$DIST_DIR/.stage" -czf "$DIST_DIR/$BASE-linux-x86_64.tar.gz" morsecq

  ci_require_cmd cpack
  installer="$REPO_ROOT/build/linux-installer"
  rm -rf "$installer"
  cmake -S "$SCRIPT_DIR/linux-installer" -B "$installer" \
    -DMORSECQ_INSTALLER_SOURCE_DIR="$stage" \
    -DMORSECQ_RELEASE_VERSION="$VERSION" \
    -DMORSECQ_PACKAGE_ARCH=x86_64 \
    -DMORSECQ_DEB_ARCH=amd64 \
    -DMORSECQ_RPM_ARCH=x86_64 >/dev/null
  (cd "$installer" && cpack -G "DEB;RPM")
  copy_one "$installer" '*.deb' "$DIST_DIR/$BASE-linux-x86_64.deb"
  copy_one "$installer" '*.rpm' "$DIST_DIR/$BASE-linux-x86_64.rpm"
  rm -rf "$DIST_DIR/.stage"
}

package_windows() {
  local runner="$BUILD_DIR/windows/x64/runner/Release" stage installer
  [[ -f "$runner/morsecq.exe" ]] || ci_die "Windows runner not found: $runner"
  require_ffi "$runner/tim2tox_ffi.dll" windows

  stage="$DIST_DIR/.stage/morsecq"
  mkdir -p "$stage"
  cp -R "$runner/." "$stage/"
  (cd "$DIST_DIR/.stage" && 7z a -tzip -bd -bso0 "$(ci_windows_path "$DIST_DIR")/$BASE-windows-x64.zip" morsecq)

  ci_require_cmd cpack
  installer="$REPO_ROOT/build/windows-installer"
  rm -rf "$installer"
  cmake -S "$SCRIPT_DIR/windows-installer" -B "$installer" \
    -DMORSECQ_INSTALLER_SOURCE_DIR="$(ci_windows_path "$stage")" \
    -DMORSECQ_RELEASE_VERSION="$VERSION" \
    -DMORSECQ_PACKAGE_ARCH=x64 >/dev/null
  (cd "$installer" && cpack -C Release -G WIX)
  copy_one "$installer" '*.msi' "$DIST_DIR/$BASE-windows-x64.msi"
  rm -rf "$DIST_DIR/.stage"
}

package_macos() {
  local app="$BUILD_DIR/macos/Build/Products/Release/morsecq.app" root plist
  [[ -d "$app" ]] || ci_die "macOS app not found: $app"
  require_ffi "$app/Contents/Frameworks/libtim2tox_ffi.dylib" macos

  # ditto keeps the bundle's symlinks, modes and signature intact.
  ditto -c -k --sequesterRsrc --keepParent "$app" "$DIST_DIR/$BASE-macos-arm64.zip"

  # Installer package into /Applications. Not relocatable: without this,
  # Installer "upgrades" any other copy of the bundle id it finds on disk
  # (e.g. a debug build) instead of installing to /Applications.
  root="$DIST_DIR/.root"
  plist="$DIST_DIR/.component.plist"
  mkdir -p "$root"
  ditto "$app" "$root/morsecq.app"
  pkgbuild --analyze --root "$root" "$plist" >/dev/null
  # Newer pkgbuild omits the key (so Installer uses its relocatable default).
  /usr/libexec/PlistBuddy -c "Delete :0:BundleIsRelocatable" "$plist" >/dev/null 2>&1 || true
  /usr/libexec/PlistBuddy -c "Add :0:BundleIsRelocatable bool false" "$plist"
  pkgbuild --root "$root" --component-plist "$plist" \
    --identifier icu.agentx.morsecq --version "$VERSION" \
    --install-location /Applications "$DIST_DIR/$BASE-macos-arm64.pkg"
  rm -rf "$root" "$plist"
}

package_android() {
  local apk="$BUILD_DIR/app/outputs/flutter-apk/app-release.apk"
  local aab="$BUILD_DIR/app/outputs/bundle/release/app-release.aab"
  [[ -f "$apk" ]] || ci_die "Android APK not found: $apk"
  [[ -f "$aab" ]] || ci_die "Android App Bundle not found: $aab"
  # Listing captured first: `unzip | grep -q` under pipefail can SIGPIPE unzip.
  local listing lib
  listing="$(unzip -l "$apk")"
  for lib in libtim2tox_ffi.so libc++_shared.so; do
    grep -F "lib/arm64-v8a/$lib" <<<"$listing" >/dev/null ||
      ci_die "android: the APK carries no arm64-v8a $lib -- refusing to package"
  done
  cp "$apk" "$DIST_DIR/$BASE-android.apk"
  cp "$aab" "$DIST_DIR/$BASE-android.aab"
}

package_ios() {
  local app="$BUILD_DIR/ios/iphoneos/Runner.app" payload
  [[ -d "$app" ]] || ci_die "iOS app not found: $app"
  require_ffi "$app/Frameworks/tim2tox_ffi.framework/tim2tox_ffi" ios
  # Unsigned: sideload tools (AltStore, Sideloadly) or a re-sign step sign it.
  payload="$DIST_DIR/.ipa/Payload"
  mkdir -p "$payload"
  ditto "$app" "$payload/Runner.app"
  (cd "$DIST_DIR/.ipa" && zip -qry "$DIST_DIR/$BASE-ios-unsigned.ipa" Payload)
  rm -rf "$DIST_DIR/.ipa"
}

case "$TARGET" in
  linux) package_linux ;;
  windows) package_windows ;;
  macos) package_macos ;;
  android) package_android ;;
  ios) package_ios ;;
  *) ci_die "Unsupported target: $TARGET" ;;
esac

ci_log "[$TARGET] packages in $DIST_DIR:"
ls -l "$DIST_DIR"
