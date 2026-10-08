# Validation — 2026-10-08

Scope: the first account-free, offline MorseCQ release, version **1.0.0+1**. Installation opens Learn / Reference / Me directly. Chat, registration, accounts, Tim2Tox and Tencent SDK integration have been removed.

## Code and regression checks

- Application suite: **701 passed, 1 skipped**. The skip is the opt-in visual-style exporter, enabled with `MORSECQ_RENDER_STYLES`.
- All five retained package suites passed. The current trainer suite passed **212 tests** after removal of chat exercise metadata.
- First-launch navigation, shared controller retry, background flush, confirmed clear durability and learning-UI reload regressions passed.
- Root Flutter analysis reports zero issues. Import, UI-literal and complexity guards passed; actionlint, shellcheck and `git diff --check` passed.
- Screenshot pipeline: **12 regression tests passed**. macOS installer component selection: **3 regression tests passed**. Complete release-asset validation: **7 regression tests passed**, including missing/empty/extra files, macOS architecture mixing, symlinks, tags and the checksum manifest.
- Apple plugin cache cleanup: **4 regression tests passed**. Real CMake configuration reproduced a removed Xcode compiler path for both Apple platform directories, then succeeded after deleting only generated output. Source files, unrelated packages and the other platform remained intact.
- `dart pub get --enforce-lockfile` passed. The resolved graph contains 155 packages and no Tim2Tox, Tencent or MorseCQ chat package.

Runtime/package implementation `8ff8dd4` passed [Analyze](https://github.com/agentx-icu/morsecq/actions/runs/37722463165), [all five required release builds](https://github.com/agentx-icu/morsecq/actions/runs/37722463344) and [all three desktop E2E jobs](https://github.com/agentx-icu/morsecq/actions/runs/37722463151). Final documentation and the release-completeness gate were then added without changing application code; latest CI is tracked in [PR #27](https://github.com/agentx-icu/morsecq/pull/27).

## Release artifacts

| Target | Verified output |
| --- | --- |
| macOS | Local release build, universal2 PKG and ZIP; CI release packaging also passed. |
| iOS | Local unsigned release IPA; CI release packaging also passed. |
| Android | Local release APK and AAB; CI release packaging also passed. |
| Linux | CI release DEB, RPM and tar.gz packaging passed. |
| Windows | CI release MSI and ZIP packaging passed. |

Local artifacts are under `dist/<platform>/`. Bundle/application metadata is `icu.agentx.morsecq`, version 1.0.0, build 1. macOS deep code-signature verification and ZIP integrity passed. Its expanded PKG installs at `/Applications/MorseCQ.app`, has zero relocation entries, contains one application bundle-version entry and has no historical rename scripts. IPA/APK/AAB integrity checks passed; APK and AAB signatures verified. Android uses the local debug test key; iOS is unsigned; macOS has an ad hoc application signature and an unsigned installer.

All **10 current CI assets** were downloaded from build run `37722463344` into ignored `dist/release-v1.0.0/`. `verify_release_assets.sh` produced SHA256SUMS and `shasum -a 256 -c SHA256SUMS` verified every file. ZIP/tar integrity and transport-entry absence passed. No version tag or GitHub Release was created.

The Android release manifest requests only `RECORD_AUDIO`, `VIBRATE` and its package-local dynamic receiver permission. No Internet, camera or chat-notification permission remains. Local macOS, iOS and Android archives contain no Tim2Tox, Tencent or toxcore entry.

Use normal Flutter release build commands after integration tests: Flutter 3.41.9 skips native plugin-registration regeneration with `--no-pub`, which can retain a development-only Android integration-test registrant. The repository build scripts and CI refresh this state through standard build commands.

## Screenshots and distribution

All six current galleries contain **108 real frames**: nine scenes in English and Simplified Chinese for macOS, iPhone, iPad, Android, Linux and Windows. Four device/host galleries came from local captures; Linux/Windows came from the successful desktop E2E run. The [gallery](screenshots/README.md) records dimensions and capture provenance. The [product concept](designs/product-2026-10-08/README.md) is labelled separately.

Version tags gate draft GitHub Releases and SHA256SUMS; the release job is intentionally skipped for PRs. Store distribution still needs owner Android/Apple signing, macOS Developer ID signing/notarization when required, and physical-device microphone, torch, keying, haptics and persistence acceptance. No store release has been published by this work.
