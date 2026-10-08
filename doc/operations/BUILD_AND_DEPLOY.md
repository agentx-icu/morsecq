[简体中文](./BUILD_AND_DEPLOY.zh-CN.md) — the Chinese document is the authoritative, complete version; this is a condensed English summary.

# MorseCQ Build and Deploy (native library `libtim2tox_ffi`)

The Tox chat backend needs one native library per platform: **libtim2tox_ffi**
(Tim2Tox C++ FFI shim + c-toxcore + libsodium), built **without ToxAV** (MorseCQ
has no calls) and **without sqlite3** (no communities). Everything is a port of
toxee's pipeline; see the zh-CN doc §1.2 for the exact differences.

## Prerequisites

Common: Flutter **3.41.9** (also needed by the *native* build — Tim2Tox
compiles `dart_api_dl.c` from the Flutter-bundled Dart SDK), Git, CMake ≥ 3.16,
network on first run (libsodium 1.0.20 tarball, SHA-256 verified; same pin as toxee).
For the *native library alone* a standalone Dart SDK of the same version Flutter
bundles (3.11.5 for 3.41.9) is enough: when `flutter` is not on PATH but `dart`
is (or `MORSECQ_DART_SDK_DIR` points at an SDK), `build_tim2tox.sh` stages its
`include/` under a shim `FLUTTER_ROOT` (`build/native/.dart-sdk-shim`). That is
how the Linux aarch64 / Windows arm64 CI jobs run — Flutter ships no arm64
archive for either.

| Platform | Needs |
|---|---|
| Linux (x86_64 / aarch64, native host build) | `build-essential cmake ninja-build pkg-config`; `libgtk-3-dev` + `patchelf` for the Flutter bundle, plus `libsecret-1-dev` (`flutter_secure_storage`, a hard CMake error without it) , `libayatana-appindicator3-dev` (`tray_manager`; optional at build time but the tray silently degrades without it) and `libasound2-dev` (`flutter_soloud` compiles its ALSA backend; PulseAudio/JACK are dlopen-ed at runtime, no headers needed). No `libsodium-dev` (static pinned build; `--system-libsodium` opts back in). |
| macOS (x86_64 / arm64, cross-buildable) | Xcode CLT, `cmake` (`brew install cmake ninja pkg-config`), CocoaPods. No Homebrew libsodium needed. The script pins the SDK from `xcrun --sdk macosx --show-sdk-path` (`-isysroot` / `SDKROOT` / `CMAKE_OSX_SYSROOT`): the raw toolchain clang that `xcrun -f clang` returns does not infer one, and without it libsodium's configure dies with "C compiler cannot create executables" (first GitHub `macos-15` runs). |
| Windows (x64 / arm64) | VS 2022/18 C++ tools, CMake, Git Bash, vcpkg with `libsodium pthreads pkgconf` for the triplet, `VCPKG_ROOT`; run from Git Bash inside vcvars. |
| Android | Android SDK + NDK (`ANDROID_NDK_HOME` or `$ANDROID_HOME/ndk/*`), Java 17. |
| iOS | Xcode (iphoneos + iphonesimulator SDKs), CocoaPods. |

## Commands (repo root)

```bash
dart run tool/bootstrap_deps.dart && dart pub get

./build_all.sh --platform <macos|linux|windows|android|ios> --mode <debug|profile|release> [--clean]
#   builds the native lib, then `flutter build` in apps/morsecq with --dart-define=MORSECQ_FAKE_BACKEND=false

bash tool/ci/build_tim2tox.sh --target linux-x86_64|linux-aarch64|windows-x64|windows-arm64|macos-x86_64|macos-arm64|android|ios-device|ios-simulator
ABIS="arm64-v8a x86_64" tool/build_android_ffi.sh    # -> apps/morsecq/android/app/src/main/jniLibs/<abi>/
tool/build_ios_ffi.sh                                 # -> apps/morsecq/ios/Frameworks/tim2tox_ffi.xcframework
bash tool/ci/assert_no_test_hooks.sh <binary-or-dir>  # byte-level gate against Tim2Tox test-only hooks
```

Options: `--with-sqlite`, `--system-libsodium`, `--stage-only` (re-stage an
existing `build/native/<target>/` into the app), `--no-stage-app`,
`MORSECQ_NATIVE_BUILD_TYPE=RelWithDebInfo`. `--toxav` is rejected.

## Where the library lands

| Platform | Artifact | Bundled by | In the app |
|---|---|---|---|
| Linux | `build/native/linux-<arch>/libtim2tox_ffi.so` | `apps/morsecq/linux/CMakeLists.txt` | `bundle/lib/libtim2tox_ffi.so` (RUNPATH `$ORIGIN`) |
| Windows | `build/native/windows-<arch>/tim2tox_ffi.dll` + `libsodium.dll` + `pthreadVC3.dll` | `apps/morsecq/windows/CMakeLists.txt` | next to `morsecq.exe` |
| macOS | `build/native/macos-<arch>/libtim2tox_ffi.dylib` → copied to `apps/morsecq/macos/Frameworks/` | `macos/Podfile` + `Frameworks/Tim2ToxFFI.podspec` (`vendored_libraries`) | `Contents/Frameworks/libtim2tox_ffi.dylib` |
| Android | `build/native/android/jniLibs/<abi>/libtim2tox_ffi.so` → `apps/morsecq/android/app/src/main/jniLibs/` | `app/build.gradle.kts` (ABI filter, fail-fast, hook scan) | `lib/<abi>/libtim2tox_ffi.so` |
| iOS | `build/native/ios-{device,simulator}/tim2tox_ffi.framework` → `apps/morsecq/ios/Frameworks/tim2tox_ffi.xcframework` | `ios/Podfile` + `Frameworks/Tim2ToxFFI.podspec` (`vendored_frameworks`) | `Runner.app/Frameworks/tim2tox_ffi.framework` |

These match the paths Tim2Tox's Dart loader (`Tim2ToxFfi.open()`) and the
patched Tencent SDK `NativeLibraryManager` (`setNativeLibraryName('tim2tox_ffi')`)
probe. All staged artifacts are gitignored.

`libtim2tox_ffi` is the **only** native chat library in the bundles: since
2026-09-30 `bootstrap_deps` overlays the vendored `tencent_cloud_chat_sdk`
plugin with no-op platform stubs (`third_party/overlays/tencent_cloud_chat_sdk/`),
so no `TXIMSDK_Plus_*` pod, `imsdk-plus` AAR, `libdart_native_imsdk.so` or
`ImSDK.dll` is linked or shipped. Run the bootstrap before `pod install` /
`flutter build`; a stale `Podfile.lock` still listing `TXIMSDK_Plus_*` means
the overlay was not applied.

## Minimum OS versions

The application targets Windows **10/11**, Android **API 24** (Android 7.0,
`flutter.minSdkVersion` with the pinned Flutter 3.41.9), and iOS **14.0**
(`file_picker_darwin` needs 14). macOS has an Intel source deployment target
of **10.15**; Apple Silicon requires **11.0+**. These deployment targets are
not evidence of testing on every older OS; see the main README's availability
matrix for actual verification.

The native chat library is built with `-mmacosx-version-min=10.15`,
`ANDROID_PLATFORM=android-21` and `-target *-apple-ios14.0`. Its Android API 21
target does not lower the application's API 24 minimum.

## CI: `.github/workflows/native.yml`

Matrix job `native` builds the 8 targets on ubuntu-24.04 / ubuntu-24.04-arm
(experimental) / windows-2022 / windows-11-arm (experimental) / macos-15-intel /
macos-15 (the two arm64 runners install the standalone Dart SDK `DART_VERSION`
via `dart-lang/setup-dart` instead of Flutter, see Prerequisites), caches
`build/native/<target>` by tim2tox submodule SHA + Flutter/Dart pins + script hash,
gates the uploaded bytes with `assert_no_test_hooks.sh`, and uploads
`tim2tox-ffi-<target>`. Jobs `app-linux`, `app-windows`, `app-macos` consume the
artifact, run `flutter build <platform> --release --dart-define=MORSECQ_FAKE_BACKEND=false`
in `apps/morsecq`, and assert the library is inside the produced bundle. Jobs
`app-android` (stages `jniLibs` with `--stage-only`; `flutter build apk` +
`appbundle`) and `app-ios` (copies the XCFramework into `apps/morsecq/ios/Frameworks`;
`flutter build ios --no-codesign`) do the same for mobile.

### Release packages

Every app job then runs `tool/ci/package_artifacts.sh --target <platform>`, which
refuses a build without `libtim2tox_ffi` and writes `dist/<platform>/`:

| platform | packages |
|---|---|
| Linux x86_64 | `.deb`, `.rpm` (CPack, `tool/ci/linux-installer`: bundle in `/opt/morsecq`, `/usr/bin/morsecq`, desktop entry, hicolor icons), `.tar.gz` |
| Windows x64 | `.msi` (CPack + WiX v3, `tool/ci/windows-installer`; Start-menu shortcut, fixed upgrade GUID), `.zip` |
| macOS arm64 | `.pkg` (pkgbuild into `/Applications`, not relocatable), `.zip` (ditto) |
| Android | `.apk` (arm64-v8a, armeabi-v7a, x86_64), `.aab` |
| iOS | unsigned `.ipa` |

They are uploaded as `release-<platform>` on every run, so a PR already proves the
installers build. On a `v*` tag, job `release` attaches all of them plus `SHA256SUMS`
to that tag's GitHub release (creating a draft when none exists). Android release
signing uses the repository secrets `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` (handed to
Gradle as `MORSECQ_ANDROID_*` environment variables; a local build may use the
gitignored `apps/morsecq/android/key.properties` instead); without them the APK/AAB
are signed with the debug key. The Android FFI ships with the NDK's `libc++_shared.so`
(it is built with `ANDROID_STL=c++_shared`). Nothing is code-signed or notarized for macOS/Windows yet.

## What CI cannot verify here

Verified for real in the Linux container that produced this pipeline: the full
`linux-x86_64` build (submodule init, pinned libsodium, 144-step tim2tox build,
exported `DartInitSDK`/`tim2tox_ffi_init`, static `sodium_init`, no ToxAV marker,
hook gate), the error paths, the Linux/Windows CMake install fragments (mock
install), YAML and Ruby syntax.

**Not verified here** (no Xcode / MSVC / NDK / GTK in the container): the actual
macOS, iOS, Windows and Android compiles; CocoaPods embedding of the vendored
xcframework / dylib; the Gradle script; a full `flutter build linux`. The
`app-*` jobs in `native.yml` assert the embedding on the first CI run.
