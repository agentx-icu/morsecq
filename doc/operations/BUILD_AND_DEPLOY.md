[简体中文](./BUILD_AND_DEPLOY.zh-CN.md)

# Build and release

Use Flutter 3.41.9 and Dart 3.11.5 to build MorseCQ. Run `flutter doctor -v` after installing the target toolchain. Resolve the pinned Pub workspace from the repository root with `dart pub get --enforce-lockfile`.

## Build a local development package

Run both commands from the repository root. Replace `macos` in both commands for Android, Linux or Windows, using the appropriate host. Packaging requires Python 3.11+.

```sh
./build_all.sh --platform macos --mode release
bash tool/ci/package_artifacts.sh --target macos
```

| Target | Required host tools | Development assets in `dist/<target>/` |
| --- | --- | --- |
| `android` | JDK 17 and Android SDK | APK, AAB |
| `ios` | macOS with Xcode and CocoaPods | Unsigned IPA |
| `macos` | macOS with Xcode and CocoaPods | PKG, ZIP |
| `linux` | x86_64 Linux with Clang, CMake, Ninja, pkg-config, GTK 3, ALSA and Ayatana AppIndicator development packages. RPM packaging also requires `rpmbuild`. | DEB, RPM, tar.gz |
| `windows` | x64 Windows with Visual Studio C++ desktop tools. For packaging, install CMake with CPack, WiX v3 for MSI and 7-Zip for ZIP. Run the scripts in Bash with `python` (3.11+), `cmake`, `cpack` and `7z` on `PATH`. | MSI, ZIP |

The macOS packager requires a universal2 executable containing both `arm64` and
`x86_64`. For an Android development build without a release keystore, use
`MORSECQ_ALLOW_DEBUG_SIGNING=1 ./build_all.sh --platform android --mode release`
as the build command.

For an unsigned iOS release build with `build_all.sh`, use `--allow-unsigned-ios`. Use
`flutter run` for the simulator and the signed export procedure below for
TestFlight or App Store distribution.

```sh
./build_all.sh --platform ios --mode release --allow-unsigned-ios
bash tool/ci/package_artifacts.sh --target ios
```

## Build CI and published artifacts

`.github/workflows/builds.yml` runs Linux analysis and regression checks once on PRs and main/master changes. Full platform builds require a current `ci:build`/`ci:full` PR label, manual dispatch or a version tag. Analyzer, complexity, import/localization guards, screenshot-import boundaries and all package/application tests gate these builds. All five platforms must pass before a tagged draft Release can be created. Assets are APK/AAB, IPA, macOS PKG/ZIP, Linux DEB/RPM/tar.gz, Windows MSI/ZIP and SHA256SUMS. Published installers are immutable.

Apple CI caches the Flutter SDK but disables Pub-cache reuse. Before building or running macOS UI tests it removes only flutter_soloud's generated CMake output; the iOS build refreshes its corresponding output. Cached compiler paths cannot cross Xcode runner images. For a local Xcode change, run `bash tool/ci/clean_apple_plugin_cache.sh macos` or `ios` before rebuilding.

After publication, the [release manifest workflow](../../.github/workflows/release-manifest.yml)
writes `release-manifest.json` with asset URLs, sizes, SHA-256 values and signing
status. It runs when a GitHub Release is published or edited and supports a manual
refresh. See [distribution packaging](../release/DISTRIBUTION_PACKAGING.md) for the
final signing, checksum and metadata steps for third-party package managers.

## Platform signing and package checks

macOS release packages require a universal2 executable. The packager checks each
embedded Mach-O minimum OS against the application's `LSMinimumSystemVersion`.
Run `python3 tool/ci/macos_runtime.py` with the path to the built app to inspect it.
Trusted distribution uses Developer ID signing and notarization.

Tagged Android builds require the four Actions secrets `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD`.
For local owner signing, set `MORSECQ_ANDROID_KEYSTORE`,
`MORSECQ_ANDROID_KEYSTORE_PASSWORD`, `MORSECQ_ANDROID_KEY_ALIAS` and
`MORSECQ_ANDROID_KEY_PASSWORD`, or configure `storeFile`, `storePassword`,
`keyAlias` and `keyPassword` in `apps/morsecq/android/key.properties`. Branch and
PR test builds opt in to debug signing. The Google Play release owner needs Play
App Signing and upload/release-track access.

A signed iOS export requires the `icu.agentx.morsecq` App ID, an Apple Developer
team, an iOS Distribution certificate, an App Store provisioning profile and
App Store Connect upload permission. Open `apps/morsecq/ios/Runner.xcworkspace` in
Xcode, select the team and follow the [store build guide](../release/APP_STORE.md)
to run `bash tool/build_ios_store.sh` with the reviewed options and signing identity.
The helper exports locally, verifies the final IPA identity and profile, and
writes evidence under `build/ios/store-readiness/`. The release owner uploads to
TestFlight or the App Store with Xcode Organizer or Transporter. The GitHub iOS
package is for unsigned sideload validation.

Device checks cover microphone decoding, haptics, keying and local persistence. Opt-in E2E CI runs on macOS, Windows, Linux, an iPhone simulator and an Android emulator. The three desktop jobs also capture screenshots. See the [test guide](../testing/TEST_PYRAMID.md).

Tags must match the numeric `X.Y.Z` part of the app pubspec: for example `1.0.1+2` uses tag `v1.0.1`; a stale tag such as `v0.2.0` is rejected before builds/package steps. Run `bash tool/ci/check_version_tag.sh vX.Y.Z` to preflight locally. Packaging and the release workflow repeat this check. Before creating a draft release, `bash tool/ci/verify_release_assets.sh <dist-dir> vX.Y.Z` requires all ten platform assets, exactly one macOS architecture pair, and writes a portable SHA256SUMS manifest. Missing, empty, unexpected or symlinked assets fail the gate.

## Platform scope

Required packages target Android API 24+ (arm64-v8a, armeabi-v7a and x86_64), iOS 14+ (arm64), macOS 13+ universal2, Linux x86_64 and Windows x64. The macOS Runner and Podfile minimum match the bundled `objective_c` native framework's verified 13.0 floor. Linux execution is verified on Ubuntu 24.04 with GTK 3, ALSA and Ayatana AppIndicator. The installed DEB gate also requires the EGL/GL/GLES dispatch loaders before its test harness. Windows CI uses Windows Server 2022.

## Compatibility release checks (2026-10-22)

Linux Listen invokes `parecord` and `pactl`: install `pulseaudio-utils`, `libegl1`, `libgl1` and `libgles2` for bare
tar.gz deployments. DEB and RPM now declare it; `gdbus` is used to confirm a live
tray host (DEB `libglib2.0-bin`, RPM `glib2`). An absent tray host leaves close as
quit. The native macOS sandbox permits local client/server IPC for the
single-instance activation socket; no Internet service is contacted.

Tagged Android builds require all four owner-signing secrets. The built APK
and AAB must have matching non-debug certificates, checked by
`tool/ci/verify_android_signing.py`. Branch, PR and non-tag manual CI builds
use the debug key even when the repository has owner signing configured.
Pass `-PstoreRelease` to `flutter build apk --release` or
`flutter build appbundle --release` for a store build. Both require a configured
release keystore (env or `android/key.properties`). Gradle verifies the signed
AAB and every output APK and rejects Android Debug certificates.
Windows Authenticode signing and macOS
Developer ID signing / notarization require owner credentials and are not
claimed by an unsigned build.

Builds archive Dart split-debug-info and available dSYM/PDB files as separate
`symbols-*` CI artifacts. App-owned Dart diagnostics retain UTC time, an allowlisted error category, a fixed event name and
code coordinates / AOT PCs captured inside the recorder in
`<support>/logs/errors.log`, with one previous file (256 KiB each). Caller-supplied
stack text, function names, absolute paths, exception messages, learning content
and recordings are excluded. This is the recorder's capture-point stack, not the
original exception stack. Unrecognized frames are omitted. Legacy raw logs are
replaced before recording and excluded from copying. Logs stay on the device. Use **Me → About → Copy local diagnostics** to export them manually.
Custom error `runtimeType` and `toString` getters are never evaluated for these
records. Links at the logs directory/current/previous paths are refused by
initialization, recording and copying. Writes stage in a private temporary
directory and replace directory entries by rename; they never truncate or
append through an existing log entry. A changed/unsafe path disables diagnostics
instead of modifying its target. No learning file is migrated by this cleanup.

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
