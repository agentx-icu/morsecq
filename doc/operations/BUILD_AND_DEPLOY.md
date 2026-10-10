# Build and release

Use Flutter 3.41.9 / Dart 3.11.5 to build MorseCQ.

Run `dart pub get --enforce-lockfile` at the root, then `./build_all.sh --platform <target> --mode release` for Android and desktop targets. Targets are android, ios, macos, linux and windows. Desktop applications build on their host OS; iOS requires a Mac with Xcode. For a signed iOS TestFlight/App Store IPA use `bash tool/build_ios_store.sh`; `build_all.sh --platform ios --mode release` fails closed unless you explicitly add `--allow-unsigned-ios` for CI/sideload testing. Android needs Java 17 and Android SDK; Linux needs GTK, ALSA and Ayatana appindicator development packages; Windows needs Visual Studio C++ and WiX v3 for the MSI.

`.github/workflows/builds.yml` runs on PRs, main/master changes, v* tags and manual dispatch. Analyzer, complexity, import/localization guards, screenshot-import boundaries and all package/application tests gate required builds. All five platforms must pass before a tagged draft Release can be created. Assets are APK/AAB, IPA, macOS PKG/ZIP, Linux DEB/RPM/tar.gz, Windows MSI/ZIP and SHA256SUMS. Published Release assets are never overwritten.

Apple CI caches the Flutter SDK but disables Pub-cache reuse. Before building or running macOS UI tests it removes only flutter_soloud's generated CMake output; the iOS build refreshes its corresponding output. Cached compiler paths cannot cross Xcode runner images. For a local Xcode change, run `bash tool/ci/clean_apple_plugin_cache.sh macos` or `ios` before rebuilding.

After a local build, run `bash tool/ci/package_artifacts.sh --target <target>`; packages appear in `dist/<target>/`. macOS release packaging requires a universal2 executable (arm64 + x86_64). Linux/Windows ARM application targets remain outside required builds.

macOS packaging checks every embedded Mach-O architecture against the application's `LSMinimumSystemVersion` before creating either archive. Run `python3 tool/ci/macos_runtime.py <application.app>` to inspect a built bundle; a dependency requiring a newer OS fails packaging.

Configure Android signing with repository Actions secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD`, or local `apps/morsecq/android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). Tagged `vX.Y.Z` builds fail if those four secrets are absent or partial; they never silently use the debug key. Branch/PR test artifacts opt in explicitly with `MORSECQ_ALLOW_DEBUG_SIGNING=1`. The Play Console release owner should enable Play App Signing and grant the release operator upload/release-track access. For iOS, the Apple Developer team needs the `icu.agentx.morsecq` App ID, an iOS Distribution certificate, an App Store provisioning profile, and an App Store Connect app with upload permission. Open `apps/morsecq/ios/Runner.xcworkspace` in Xcode, select that Team, then run `bash tool/build_ios_store.sh`; the script fixes `--export-method app-store`, rejects `--no-codesign`, verifies the signed archive and writes one IPA to `apps/morsecq/build/ios/ipa/`. Upload it with Xcode Organizer or Transporter for TestFlight/App Store review. The GitHub iOS job intentionally publishes only an unsigned sideload artifact. For macOS distribution, configure Developer ID signing and notarization.

Device checks cover microphone decoding, haptics, keying and local persistence. E2E CI runs the application and captures screenshots on macOS, Windows and Linux.

Tags must match the numeric `X.Y.Z` part of the app pubspec: the current `1.0.0+1` uses tag `v1.0.0`; the stale `v0.2.0` tag is rejected before builds/package steps. Run `bash tool/ci/check_version_tag.sh v1.0.0` to preflight locally. Packaging and the release workflow repeat this check. Before creating a draft release, `bash tool/ci/verify_release_assets.sh <dist-dir> v1.0.0` requires all ten platform assets, exactly one macOS architecture pair, and writes a portable SHA256SUMS manifest. Missing, empty, unexpected or symlinked assets fail the gate.

## Platform scope

Required packages target Android API 24+ (arm64-v8a, armeabi-v7a and x86_64), iOS 14+ (arm64), macOS 13+ universal2, Linux x86_64 and Windows x64. The macOS Runner and Podfile minimum match the bundled objective_c native framework’s verified 13.0 floor. Linux execution is verified on Ubuntu 24.04 with GTK 3, ALSA and Ayatana appindicator. Windows CI uses Windows Server 2022.
