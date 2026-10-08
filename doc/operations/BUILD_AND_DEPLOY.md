# Build and release

Every MorseCQ target builds the offline trainer, with no submodule, Tim2Tox or Tencent SDK bootstrap. The pinned toolchain is Flutter 3.41.9 / Dart 3.11.5.

Run `dart pub get --enforce-lockfile` at the root, then `./build_all.sh --platform <target> --mode release`. Targets are android, ios, macos, linux and windows. Desktop applications build on their host OS; iOS requires a Mac with Xcode. Android needs Java 17 and Android SDK; Linux needs GTK, ALSA and Ayatana appindicator development packages; Windows needs Visual Studio C++ and WiX v3 for the MSI.

`.github/workflows/builds.yml` runs on PRs, main/master changes, v* tags and manual dispatch. Analyzer, complexity, import/localization guards, screenshot-import boundaries and all package/application tests gate required builds. All five platforms must pass before a tagged draft Release can be created. Assets are APK/AAB, unsigned IPA, macOS PKG/ZIP, Linux DEB/RPM/tar.gz, Windows MSI/ZIP and SHA256SUMS. Published Release assets are never overwritten.

After a local build, run `bash tool/ci/package_artifacts.sh --target <target>`; packages appear in `dist/<target>/`. macOS package names use the built executable’s architecture: arm64, x86_64 or universal2. Linux/Windows ARM application targets remain outside required builds.

Android owner signing uses repository secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, or local `android/key.properties`. Without them CI produces debug-key signed testing packages, unsuitable for stores. iOS Release packages are unsigned and require owner re-signing. `tool/build_ios_store.sh` builds a store IPA with the owner's Apple signing setup. macOS packages are not Developer ID signed/notarized by default.

Physical-device microphone, haptics, keying and local persistence still require device acceptance. E2E CI verifies Windows/Linux execution and screenshots. Building a package does not publish to a store or complete signing.

Tags must be `v<pubspec version>`; packaging refuses mismatched tag/application version metadata.
