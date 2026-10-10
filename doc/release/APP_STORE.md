[简体中文](./APP_STORE.zh-CN.md)

# App Store build

## Accounts, signing and upload

MorseCQ's store identifiers are `icu.agentx.morsecq` on both platforms. Keep
store access with the release owner (or the least-privileged equivalent) and
never commit certificates, provisioning profiles, keystores or passwords.

### iOS / TestFlight

1. The Apple Developer Program team must have the `icu.agentx.morsecq` App ID,
   an iOS Distribution certificate and an App Store provisioning profile. The
   same Team ID must have an App Store Connect app record with a role that can
   upload builds (App Manager or Developer).
2. On a Mac, sign in to Xcode with that Apple Developer account, open
   `apps/morsecq/ios/Runner.xcworkspace`, select the Runner target, and choose
   the team. Verify the bundle identifier and automatic/manual signing profile
   before building.
3. Run `bash tool/build_ios_store.sh`. This is the signed store path: it fixes
   `--export-method app-store`, rejects `--no-codesign` and other export
   methods, verifies the archive signature, and leaves one IPA under
   `apps/morsecq/build/ios/ipa/`.
4. Upload that IPA with Xcode Organizer or Apple's Transporter, then complete
   TestFlight processing and App Store metadata in App Store Connect. The
   GitHub workflow's `ios-unsigned.ipa` is intentionally for sideload/testing
   and must not be uploaded to TestFlight.

### Android / Google Play

1. A Google Play Console owner or release manager creates the app with package
   name `icu.agentx.morsecq`, registers the Play App Signing account, and
   grants the release operator permission to create/manage production releases.
2. Keep the upload keystore and its four values in the repository's Actions
   secrets (Settings → Secrets and variables → Actions):
   `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD`. Encode the keystore without
   a trailing newline, for example `base64 -w 0 morsecq-upload.jks`, and paste
   that single-line value into `ANDROID_KEYSTORE_BASE64`.
3. Tagged release builds require all four secrets and fail closed if any is
   missing. Branch/PR CI may set `MORSECQ_ALLOW_DEBUG_SIGNING=1` explicitly for
   a non-distributable test APK/AAB; that opt-in is never accepted for a `vX.Y.Z`
   release. Local store builds should use `android/key.properties` (gitignored)
   with `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` instead.
4. Before a Play upload, inspect the signed AAB/APK, run the 16 KB page checks
   below, and upload the AAB through Play Console's release track. Do not reuse
   a debug-signed artifact because it cannot be upgraded to the Play key.

Provide current iPhone/iPad screenshots through the [capture pipeline](../../tool/screenshots/README.md), public privacy/support URLs and store metadata. Describe offline learning, local progress and user-triggered microphone decoding. Check learning-material file selection and persistence on a device. The app declares no non-exempt application cryptography (`ITSAppUsesNonExemptEncryption = false`; MorseCQ has no networking and no libsodium).

iPhone supports portrait and both landscape orientations; iPad supports all four and `UIRequiresFullScreen` is not set, so Split View, Slide Over and Stage Manager apply down to 320 pt. The learning-material export anchors its share popover to the tapped control (`sharePositionOrigin`; `test/platform/share_origin_guard_test.dart` fails on a share call without one).

## Android: SDK levels and 16 KB pages

`compileSdk` 36, `minSdk` 24 and `targetSdk` 36 are pinned in `apps/morsecq/android/app/build.gradle.kts` (not inherited from the Flutter Gradle plugin; `test/platform/mobile_platform_config_test.dart` checks them). Google Play requires API 36 for new apps and updates since 2026-08-31; raise the three together and update this line.

MorseCQ ships no native library of its own, so Google Play's 16 KB page-size requirement (64-bit libraries of apps targeting Android 15+) concerns only the libraries the toolchains produce: `libflutter.so`, `libapp.so` and any plugin code built with Flutter's NDK (28.2 on Flutter 3.41.9, which aligns by default; never pin `ndkVersion` below r28). Check the final APK before a Play upload: `zipalign -c -P 16 -v 4 app-release.apk`, and `llvm-readelf -lW` on every `lib/arm64-v8a/*.so` and `lib/x86_64/*.so` (every `LOAD` `Align` at least `0x4000`).

Predictive back is enabled (`android:enableOnBackInvokedCallback="true"`); Android 16 applies it to targetSdk 36 anyway, the attribute makes Android 13–15 behave the same. `DrillLeaveGuard` handles the gesture through `PopScope`.

The current app version is `1.0.0+1`, so the only valid release tag is
`v1.0.0`; a stale tag such as `v0.2.0` is rejected before packaging.

See the [build guide](../operations/BUILD_AND_DEPLOY.md) and [validation record](../VALIDATION.md).
