[简体中文](./APP_STORE.zh-CN.md)

# App Store build

Set the verified owner `MORSECQ_APPLE_TEAM_ID`, then run `bash tool/build_ios_store.sh` with an Apple team, distribution certificate and provisioning profile configured for the application.

Provide current iPhone/iPad screenshots through the [capture pipeline](../../tool/screenshots/README.md), public privacy/support URLs and store metadata. Describe offline learning, local progress and user-triggered microphone decoding. Check learning-material file selection and persistence on a device. The app declares no non-exempt application cryptography (`ITSAppUsesNonExemptEncryption = false`; MorseCQ has no networking and no libsodium).

iPhone supports portrait and both landscape orientations; iPad supports all four and `UIRequiresFullScreen` is not set, so Split View, Slide Over and Stage Manager apply down to 320 pt. The learning-material export anchors its share popover to the tapped control (`sharePositionOrigin`; `test/platform/share_origin_guard_test.dart` fails on a share call without one).

See the [channel matrix and owner gates](STORE_READINESS.md) before choosing App Store, Developer ID, Play or a desktop store. The iOS script verifies the actual exported IPA identity/profile and writes a payload report; it does not upload.

## Android: SDK levels and 16 KB pages

`compileSdk` 36, `minSdk` 24 and `targetSdk` 36 are pinned in `apps/morsecq/android/app/build.gradle.kts` (not inherited from the Flutter Gradle plugin; `test/platform/mobile_platform_config_test.dart` checks them). Google Play requires API 36 for new apps and updates since 2026-08-31; review target/compile separately from the supported minimum OS and update the dated policy record.

MorseCQ ships no native library of its own, so Google Play's 16 KB page-size requirement (64-bit libraries of apps targeting Android 15+) concerns only the libraries the toolchains produce: `libflutter.so`, `libapp.so` and any plugin code built with Flutter's NDK (28.2 on Flutter 3.41.9, which aligns by default; never pin `ndkVersion` below r28). Check the final APK before a Play upload: `zipalign -c -P 16 -v 4 app-release.apk`, and `llvm-readelf -lW` on every `lib/arm64-v8a/*.so` and `lib/x86_64/*.so` (every `LOAD` `Align` at least `0x4000`).

Predictive back is enabled (`android:enableOnBackInvokedCallback="true"`); Android 16 applies it to targetSdk 36 anyway, the attribute makes Android 13–15 behave the same. `DrillLeaveGuard` handles the gesture through `PopScope`.

See the [build guide](../operations/BUILD_AND_DEPLOY.md) and [validation record](../VALIDATION.md).

## Submission answers and compatibility surfaces (2026-10-22)

These are source-based draft answers for the owner to enter and verify in the
store consoles, not evidence of an accepted submission.

| Question | Current product answer |
| --- | --- |
| App Store privacy / Play Data safety | No developer collection, sharing, tracking, advertising or analytics. Learning, recordings and redacted diagnostics remain on-device. User-requested exports and OS backup are explicit/system-owned paths. |
| Microphone | Optional live Morse decoding and local recording; no audio upload. |
| Accounts / purchases / UGC service | None. No account deletion or server moderation flow applies. |
| Age-rating content flags | No violence, sexual content, gambling, alcohol/drugs, advertising, unrestricted in-app web browsing or user-to-user communication. Complete each store's current questionnaire; do not infer a store age label from this list. |
| iOS binary on Apple silicon Mac | Do not offer the compatibility binary; ship the separately tested native macOS application. Owner must deselect compatibility availability in App Store Connect. |
| iOS binary on Apple Vision Pro / native visionOS | Not offered pending plugin, input and media validation. Owner must opt out of compatibility availability in App Store Connect. |

Apple's [privacy definitions](https://developer.apple.com/app-store/app-privacy-details/)
exclude processing confined to a device. Apple documents separate
[Mac compatibility availability](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-of-iphone-and-ipad-apps-on-macs-with-apple-silicon/)
and [Vision Pro compatibility availability](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-of-iphone-and-ipad-apps-on-apple-vision-pro/).
The API 36 deadline above was checked against
[Play's current requirement](https://support.google.com/googleplay/android-developer/answer/11926878)
on 2026-10-22. Actual console settings and signed release verification remain owner actions.

The final APK/AAB are now checked by `tool/ci/release_preflight.py`, including every native module, optional hardware, merged permissions and bundle delivery alignment. The owner upload fingerprint is required for tagged signature checks; Play delivery uses its separate app-signing key. Physical 16 KB execution and console validation remain open.

## Release budgets

Initial engineering limits, to be checked per architecture on every release:
Android APK/AAB ≤100 MiB each; iOS IPA ≤150 MiB; macOS app ≤100 MiB and PKG ≤100 MiB;
Windows MSI ≤150 MiB and installed app ≤250 MiB; Linux DEB/RPM ≤100 MiB each and
installed bundle ≤250 MiB. Cold start to usable Learn ≤5 s and warm reopen ≤2 s
on the release device matrix are targets, not measurements. The local universal
macOS release measured 57.1 MB on macOS 27.0.1 arm64; the other artifact sizes and
startup latency still require measurement. See the [cross-platform audit](../testing/CROSS_PLATFORM_AUDIT.md).
