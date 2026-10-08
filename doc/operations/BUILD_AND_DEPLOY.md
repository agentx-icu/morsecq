# Build and release

Use Flutter 3.41.9 / Dart 3.11.5 to build MorseCQ.

Run `dart pub get --enforce-lockfile` at the root, then `./build_all.sh --platform <target> --mode release`. Targets are android, ios, macos, linux and windows. Desktop applications build on their host OS; iOS requires a Mac with Xcode. Android needs Java 17 and Android SDK; Linux needs GTK, ALSA and Ayatana appindicator development packages; Windows needs Visual Studio C++ and WiX v3 for the MSI.

`.github/workflows/builds.yml` runs on PRs, main/master changes, v* tags and manual dispatch. Analyzer, complexity, import/localization guards, screenshot-import boundaries and all package/application tests gate required builds. All five platforms must pass before a tagged draft Release can be created. Assets are APK/AAB, IPA, macOS PKG/ZIP, Linux DEB/RPM/tar.gz, Windows MSI/ZIP and SHA256SUMS. Published Release assets are never overwritten.

Apple CI caches the Flutter SDK but disables Pub-cache reuse. Before building or running macOS UI tests it removes only flutter_soloud's generated CMake output; the iOS build refreshes its corresponding output. Cached compiler paths cannot cross Xcode runner images. For a local Xcode change, run `bash tool/ci/clean_apple_plugin_cache.sh macos` or `ios` before rebuilding.

After a local build, run `bash tool/ci/package_artifacts.sh --target <target>`; packages appear in `dist/<target>/`. macOS package names use the built executable’s architecture: arm64, x86_64 or universal2. Linux/Windows ARM application targets remain outside required builds.

macOS packaging checks every embedded Mach-O architecture against the application's `LSMinimumSystemVersion` before creating either archive. Run `python3 tool/ci/macos_runtime.py <application.app>` to inspect a built bundle; a dependency requiring a newer OS fails packaging.

Configure Android signing with repository secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, or local `android/key.properties`. For iOS, configure an Apple team, certificate and provisioning profile and run `tool/build_ios_store.sh`. For macOS distribution, configure Developer ID signing and notarization.

Device checks cover microphone decoding, haptics, keying and local persistence. E2E CI runs the application and captures screenshots on macOS, Windows and Linux.

Tags must match the numeric `X.Y.Z` part of the app pubspec: `1.0.0+1` uses tag `v1.0.0`. Packaging refuses mismatched metadata. Before creating a draft release, `bash tool/ci/verify_release_assets.sh <dist-dir> v1.0.0` requires all ten platform assets, exactly one macOS architecture pair, and writes a portable SHA256SUMS manifest. Missing, empty, unexpected or symlinked assets fail the gate.

## Platform scope

Required packages target Android API 24+ (arm64-v8a, armeabi-v7a and x86_64), iOS 14+ (arm64), macOS 13+ universal2, Linux x86_64 and Windows x64. The macOS Runner and Podfile minimum match the bundled objective_c native framework’s verified 13.0 floor. Linux execution is verified on Ubuntu 24.04 with GTK 3, ALSA and Ayatana appindicator. Windows CI uses Windows Server 2022.
