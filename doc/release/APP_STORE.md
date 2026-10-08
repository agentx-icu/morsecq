[简体中文](./APP_STORE.zh-CN.md)

# App Store build

Run `bash tool/build_ios_store.sh` with an Apple team, distribution certificate and provisioning profile configured for the application.

Provide current iPhone/iPad screenshots through the [capture pipeline](../../tool/screenshots/README.md), public privacy/support URLs and store metadata. Describe offline learning, local progress and user-triggered microphone decoding. Check learning-material file selection and persistence on a device. The app declares no non-exempt application cryptography (`ITSAppUsesNonExemptEncryption = false`; MorseCQ has no networking and no libsodium).

iPhone supports portrait and both landscape orientations; iPad supports all four and `UIRequiresFullScreen` is not set, so Split View, Slide Over and Stage Manager apply down to 320 pt. The learning-material export anchors its share popover to the tapped control (`sharePositionOrigin`; `test/platform/share_origin_guard_test.dart` fails on a share call without one).

## Android: SDK levels and 16 KB pages

`compileSdk` 36, `minSdk` 24 and `targetSdk` 36 are pinned in `apps/morsecq/android/app/build.gradle.kts` (not inherited from the Flutter Gradle plugin; `test/platform/mobile_platform_config_test.dart` checks them). Google Play requires API 36 for new apps and updates since 2026-08-31; raise the three together and update this line.

MorseCQ ships no native library of its own, so Google Play's 16 KB page-size requirement (64-bit libraries of apps targeting Android 15+) concerns only the libraries the toolchains produce: `libflutter.so`, `libapp.so` and any plugin code built with Flutter's NDK (28.2 on Flutter 3.41.9, which aligns by default; never pin `ndkVersion` below r28). Check the final APK before a Play upload: `zipalign -c -P 16 -v 4 app-release.apk`, and `llvm-readelf -lW` on every `lib/arm64-v8a/*.so` and `lib/x86_64/*.so` (every `LOAD` `Align` at least `0x4000`).

Predictive back is enabled (`android:enableOnBackInvokedCallback="true"`); Android 16 applies it to targetSdk 36 anyway, the attribute makes Android 13–15 behave the same. `DrillLeaveGuard` handles the gesture through `PopScope`.

See the [build guide](../operations/BUILD_AND_DEPLOY.md) and [validation record](../VALIDATION.md).
