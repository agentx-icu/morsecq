[简体中文](./BUILD_AND_DEPLOY.zh-CN.md)

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

Required packages target Android API 24+ (arm64-v8a, armeabi-v7a and x86_64), iOS 14+ (arm64), macOS 13+ universal2, Linux x86_64 and Windows x64. The macOS Runner and Podfile minimum match the bundled objective_c native framework’s verified 13.0 floor. Linux execution is verified on Ubuntu 24.04 with GTK 3, ALSA and Ayatana appindicator. The installed DEB gate also requires the EGL/GL/GLES dispatch loaders before its test harness. Windows CI uses Windows Server 2022.

## Compatibility release checks (2026-10-22)

Linux Listen invokes `parecord` and `pactl`: install `pulseaudio-utils`, `libegl1`, `libgl1` and `libgles2` for bare
tar.gz deployments. DEB and RPM now declare it; `gdbus` is used to confirm a live
tray host (DEB `libglib2.0-bin`, RPM `glib2`). An absent tray host leaves close as
quit. The native macOS sandbox permits local client/server IPC for the
single-instance activation socket; no Internet service is contacted.

Tagged Android builds require all four owner-signing secrets. The built APK
and AAB must have matching non-debug certificates, checked by
`tool/ci/verify_android_signing.py`; non-tag debug-signed artifacts remain for
local/CI testing. Windows Authenticode signing and macOS Developer ID signing /
notarization require owner credentials and are not claimed by an unsigned build.

Builds archive Dart split-debug-info and available dSYM/PDB files as separate
`symbols-*` CI artifacts. App-owned Dart diagnostics retain UTC time, error type, a fixed event name and
code coordinates / AOT PCs captured inside the recorder in
`<support>/logs/errors.log`, with one previous file (256 KiB each). Caller-supplied
stack text, function names, absolute paths, exception messages, learning content
and recordings are excluded. This is the recorder's capture-point stack, not the
original exception stack. Unrecognized frames are omitted. Legacy raw logs are
replaced before recording and excluded from copying. Nothing is uploaded;
Me → Copy local diagnostics is the explicit export path.

Error hooks install before startup work without opening storage. On desktop,
only the exclusive instance owner enables the file sink. Until storage is ready
(or if it is unavailable), hooks still prevent raw release console fallback but
cannot retain an early report. Release hooks do not forward raw Flutter details
or request PlatformDispatcher's stderr fallback. App/plugin catch logs and the
opt-in shell sink are verbose only in debug builds. Product-policy CI checks
these branches; it does not replace installed release testing. Native crashes,
worker-isolate forwarding and per-platform symbolication from the matching
shipped artifact remain unverified; use OS crash reports and archived symbols.
Installed package and upgrade smoke checks on each OS remain required: install
the preceding release, create learning progress, upgrade, launch, confirm saved
progress, close/tray/reopen/quit, and inspect actual packaged declarations. They
have not been established by widget tests or a bundle launch alone.

## Channel preflight and owner signing

Read the [store/channel matrix](../release/STORE_READINESS.md) before choosing a distribution route. Python 3.11+ is required by payload tooling; CI pins 3.12. All five native jobs build release payloads and retain `evidence-*` separately from release/symbol artifacts. Reports inventory native hashes/architectures, actual Apple privacy/localizations/entitlements or Android merged permissions/SDK/ABIs/16 KB ELF/ZIP/bundle alignment; Windows also checks MSI Template Summary against x64. These checks do not replace installation or store review. The bundletool 1.18.3 download is SHA-256 pinned.

Default `package_artifacts.sh` creates development downloads; iOS remains explicitly unsigned. Do not publish them as approved store or trusted distribution artifacts. The optional `MORSECQ_DISTRIBUTION=1` path refuses missing owner material before staging:

| Target | Owner inputs / behavior |
| --- | --- |
| macOS Developer ID | `MORSECQ_MACOS_APPLICATION_IDENTITY`, `MORSECQ_MACOS_INSTALLER_IDENTITY`, verified `MORSECQ_APPLE_TEAM_ID`, existing `MORSECQ_NOTARY_PROFILE`. Signs nested images/containers then app, checks actual Team/authority/runtime, notarizes app ZIP and PKG, staples and checks final ZIP/installer. This is owner-invoked and uploads only to notarization, not App Store submission. |
| Windows direct/hosted MSI | `MORSECQ_WINDOWS_CERT_SHA1` in the accessible certificate store, `signtool.exe`, trusted signing material. Checks every staged PE architecture before signing, signs unsigned PE, preserves valid vendor signatures, requires the app/installer to match the expected owner, and verifies all PE plus MSI. Not used for an unimplemented Store MSIX path. |
| Android | `MORSECQ_ANDROID_UPLOAD_CERT_SHA256`, explicit `MORSECQ_BUNDLETOOL_JAR` and executable `MORSECQ_APKANALYZER` paths; missing inspection tools fail closed. Before copying, rechecks final manifest/ABI/16 KB using those tools; actual APK and AAB must match the expected upload certificate and reject debug. JDK17 `JarFile` reads every AAB payload to EOF and checks its signer, independently of manifest ZIP order; unsigned/tampered/duplicate entries fail. PR builds also retain a development AAB signature report. Tagged CI uses repository variable `ANDROID_UPLOAD_CERT_SHA256` plus the existing four signing secrets; record Play App Signing's delivery fingerprint separately. |
| iOS / Linux | Refuses this generic distribution flag: iOS uses the separate signed App Store export; Linux repository trust/signing and update policy are owner release work. Development packaging remains available. |

For iOS, set the verified `MORSECQ_APPLE_TEAM_ID` and run `bash tool/build_ios_store.sh` with the owner's Xcode signing/export options. After export it extracts the actual IPA, checks device payload/privacy, distribution signature/team and App Store provisioning identity (no development/ad-hoc device list). It writes `build/evidence/ios-store.json` and never submits to a store. An unsigned CI IPA is not this export.

Before publishing, record hashes and the prior signed artifact; test clean install, update with existing learning data, denial/revocation and uninstall as a standard user on each selected channel. Owner credentials, identity/territory/metadata/rights and store-console answers remain blockers until evidenced.

Both CI and local strict packaging use the same payload inspector. Final Mac ZIP inspection also runs actual `codesign --verify --deep --strict`; reading entitlement metadata alone cannot verify resources/signatures.

Desktop CMake intentionally disables optional JNI host discovery: JNI is transitive through Android-only platform code and is unused by MorseCQ on Linux/Windows. This prevents a runner JDK from adding a desktop JVM requirement. Android JNI remains enabled; adding desktop Java later requires explicit runtime/dependency and installed-package verification.
