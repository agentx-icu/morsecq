#!/usr/bin/env bash
# Turns one platform's release build into the files a GitHub release ships,
# under dist/<target>/ (modelled on toxee/tool/ci/package_artifacts.sh):
#
#   linux    morsecq-<v>-linux-x86_64.{deb,rpm,tar.gz}   (CPack, tool/ci/linux-installer)
#   windows  morsecq-<v>-windows-x64.{msi,zip}           (CPack + WiX v3, tool/ci/windows-installer)
#   macos    morsecq-<v>-macos-<arch>.{pkg,zip}           (pkgbuild into /Applications; ditto zip)
#   android  morsecq-<v>-android.{apk,aab}
#   ios      morsecq-<v>-ios-unsigned.ipa                (no signing identity on CI)
#
# Run from anywhere after the matching `flutter build <target> --release`
# (the Builds and release workflow does both). <v> is the tag without its "v" on a tag
# build, else the version in apps/morsecq/pubspec.yaml. Every package contains only offline learning functionality.
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
# Development artifacts remain available without inventing owner identities.
# This opt-in path fails before staging when owner material is absent.
if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
  case "$TARGET" in
    macos)
      for key in MORSECQ_MACOS_APPLICATION_IDENTITY MORSECQ_MACOS_INSTALLER_IDENTITY MORSECQ_APPLE_TEAM_ID MORSECQ_NOTARY_PROFILE; do
        [[ -n "${!key:-}" ]] || ci_die "distribution requires $key"
      done ;;
    windows) [[ -n "${MORSECQ_WINDOWS_CERT_SHA1:-}" ]] || ci_die 'distribution requires MORSECQ_WINDOWS_CERT_SHA1' ;;
    android) [[ -n "${MORSECQ_ANDROID_UPLOAD_CERT_SHA256:-}" ]] || ci_die 'distribution requires MORSECQ_ANDROID_UPLOAD_CERT_SHA256' ;;
    ios) ci_die 'distribution: use tool/build_ios_store.sh for a signed App Store export; this packager only creates unsigned IPA' ;;
    linux) ci_die 'distribution: Linux repository signing/update trust is an owner release action; only development packages are automated' ;;
  esac
fi
ci_reset_dir "$DIST_DIR"

release_version() {
  if [[ "${GITHUB_REF_TYPE:-}" == "tag" && "${GITHUB_REF_NAME:-}" == v* ]]; then
    local declared tagged
    declared="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' "$APP_DIR/pubspec.yaml" | head -n 1)"
    tagged="${GITHUB_REF_NAME#v}"
    [[ "$tagged" == "$declared" ]] || ci_die "tag $GITHUB_REF_NAME must match pubspec version $declared"
    printf '%s\n' "$tagged"
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

package_linux() {
  local bundle="$BUILD_DIR/linux/x64/release/bundle" stage installer
  [[ -x "$bundle/morsecq" ]] || ci_die "Linux bundle not found: $bundle"

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

  stage="$DIST_DIR/.stage/morsecq"
  mkdir -p "$stage"
  cp -R "$runner/." "$stage/"
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(ci_windows_path "$SCRIPT_DIR/sign_windows.ps1")" -InputPath "$(ci_windows_path "$stage")"
  fi
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
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(ci_windows_path "$SCRIPT_DIR/sign_windows.ps1")" -InputPath "$(ci_windows_path "$DIST_DIR/$BASE-windows-x64.msi")"
  fi
  rm -rf "$DIST_DIR/.stage"
}

package_macos() {
  local app="$BUILD_DIR/macos/Build/Products/Release/MorseCQ.app" root plist arch arches
  [[ -d "$app" ]] || ci_die "macOS app not found: $app"

  arches="$(lipo -archs "$app/Contents/MacOS/MorseCQ")"
  case "$arches" in
    'arm64') arch=arm64 ;;
    'x86_64') arch=x86_64 ;;
    'x86_64 arm64'|'arm64 x86_64') arch=universal2 ;;
    *) ci_die "Unexpected macOS executable architectures: $arches" ;;
  esac
  # Every embedded framework and architecture must fit the app's declared OS.
  ci_require_cmd python3
  python3 "$SCRIPT_DIR/macos_runtime.py" "$app"
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    bash "$SCRIPT_DIR/sign_macos.sh" "$app"
    ditto -c -k --sequesterRsrc --keepParent "$app" "$DIST_DIR/.notarize.zip"
    xcrun notarytool submit "$DIST_DIR/.notarize.zip" --keychain-profile "$MORSECQ_NOTARY_PROFILE" --wait
    rm "$DIST_DIR/.notarize.zip"
    xcrun stapler staple "$app"
    xcrun stapler validate "$app"
  fi
  # ditto keeps the bundle's symlinks, modes and signature intact.
  ditto -c -k --sequesterRsrc --keepParent "$app" "$DIST_DIR/$BASE-macos-$arch.zip"

  # Installer package into /Applications. Not relocatable: without this,
  # Installer "upgrades" any other copy of the bundle id it finds on disk
  # (e.g. a debug build) instead of installing to /Applications.
  root="$DIST_DIR/.root"
  plist="$DIST_DIR/.component.plist"
  mkdir -p "$root"
  ditto "$app" "$root/MorseCQ.app"
  pkgbuild --analyze --root "$root" "$plist" >/dev/null
  # Framework privacy bundles may precede the root application in pkgbuild's
  # inventory. Select the application by path and pin every child bundle.
  ci_require_cmd python3
  python3 "$SCRIPT_DIR/macos_components.py" "$plist"
  local -a signing=()
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    signing=(--sign "$MORSECQ_MACOS_INSTALLER_IDENTITY")
  fi
  pkgbuild ${signing[@]+"${signing[@]}"} --root "$root" --component-plist "$plist" \
    --identifier icu.agentx.morsecq --version "$VERSION" \
    --install-location /Applications "$DIST_DIR/$BASE-macos-$arch.pkg"
  rm -rf "$root" "$plist"
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    xcrun notarytool submit "$DIST_DIR/$BASE-macos-$arch.pkg" --keychain-profile "$MORSECQ_NOTARY_PROFILE" --wait
    xcrun stapler staple "$DIST_DIR/$BASE-macos-$arch.pkg"
    xcrun stapler validate "$DIST_DIR/$BASE-macos-$arch.pkg"
    pkgutil --check-signature "$DIST_DIR/$BASE-macos-$arch.pkg" > "$DIST_DIR/.installer-signature.txt"
    grep -F 'Developer ID Installer:' "$DIST_DIR/.installer-signature.txt" >/dev/null
    grep -F "($MORSECQ_APPLE_TEAM_ID)" "$DIST_DIR/.installer-signature.txt" >/dev/null
    rm "$DIST_DIR/.installer-signature.txt"
    spctl --assess --type install "$DIST_DIR/$BASE-macos-$arch.pkg"
  fi
  # Re-extract the final ZIP after the final mutation and inspect its app.
  ditto -x -k "$DIST_DIR/$BASE-macos-$arch.zip" "$DIST_DIR/.verify"
  python3 "$SCRIPT_DIR/release_preflight.py" --output "$REPO_ROOT/build/evidence/macos-final.json" apple "$DIST_DIR/.verify/MorseCQ.app" --platform macos
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    python3 "$SCRIPT_DIR/distribution_signing.py" "$DIST_DIR/.verify/MorseCQ.app" --team "$MORSECQ_APPLE_TEAM_ID" --platform macos
    xcrun stapler validate "$DIST_DIR/.verify/MorseCQ.app"
  fi
  rm -rf "$DIST_DIR/.verify"
}

package_android() {
  local apk="$BUILD_DIR/app/outputs/flutter-apk/app-release.apk"
  local aab="$BUILD_DIR/app/outputs/bundle/release/app-release.aab"
  [[ -f "$apk" ]] || ci_die "Android APK not found: $apk"
  [[ -f "$aab" ]] || ci_die "Android App Bundle not found: $aab"
  if [[ "${MORSECQ_DISTRIBUTION:-0}" == 1 ]]; then
    python3 "$SCRIPT_DIR/verify_android_signing.py" "$apk" "$aab" --expected-sha256 "$MORSECQ_ANDROID_UPLOAD_CERT_SHA256"
  fi
  cp "$apk" "$DIST_DIR/$BASE-android.apk"
  cp "$aab" "$DIST_DIR/$BASE-android.aab"
}

package_ios() {
  local app="$BUILD_DIR/ios/iphoneos/Runner.app" payload
  [[ -d "$app" ]] || ci_die "iOS app not found: $app"
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
