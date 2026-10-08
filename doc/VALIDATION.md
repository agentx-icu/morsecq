# Validation — 2026-10-08

Scope: the first account-free offline MorseCQ release, **1.0.0+1**, including the complete upstream teaching update `5631376` through normal merge `7cffd42`. Installation opens Learn / Reference / Me directly. Chat, registration, Tox identities, Tim2Tox/Tencent integration and historical import features are absent.

## Code and learning checks

- Application: **780 passed, 2 skipped**. The two skips are opt-in style-preview and visual-matrix exporters. The matrix exporter was separately enabled and passed.
- Retained packages: core **92**, DSP **107**, audio I/O **124**, trainer **270**, radio tools **18** passed. DSP has **2 existing skipped noise-floor cases**: an unusually quiet first noise block, including a 44.1 kHz recording, can add a spurious leading symbol. These are documented algorithm limitations, not native-platform skips.
- First installation opens the first lesson directly. Tests cover guided pace persistence, honest receive verdicts, per-symbol recent independent evidence, lesson-challenge advancement, final course completion, daily-plan focus, QSO readiness and the two new progress fields' save/reopen/corruption fallback.
- All package/application/tool analyzers reported zero issues. Complexity, import and UI-literal guards passed (486 source files / 213 UI files); actionlint, shellcheck and `git diff --check` passed. The pinned 155-package dependency graph contains no Tim2Tox, Tencent or MorseCQ chat package.
- Screenshot import/publication **19**, Apple plugin-cache **4**, macOS installer component **3**, complete release-asset **7** regression tests passed. Screenshot locale/style configuration **4** regressions run within the application suite.

The integrated runtime `7cffd42` passed [Analyze](https://github.com/agentx-icu/morsecq/actions/runs/37733546824), [all five required release builds](https://github.com/agentx-icu/morsecq/actions/runs/37733547331), [all three desktop E2E jobs](https://github.com/agentx-icu/morsecq/actions/runs/37733546823) and [Visual matrix](https://github.com/agentx-icu/morsecq/actions/runs/37733547328). Final gallery/documentation CI is tracked in [PR #27](https://github.com/agentx-icu/morsecq/pull/27).

## Real UI and screenshots

macOS, Linux and Windows E2E run actual startup, local persistence reopening, the English/Chinese first-day journey and all twelve screenshot scenes. The first-day journey also passed locally on iPhone and Android: six assisted intro trials, one-character then three-character guided receive, and a correctly keyed K advancing guided sending to M. Guided practice must leave Koch lesson 1 unchanged. Automated answers verify application behavior, not learner mastery or physical hearing.

All six current galleries contain **144 real frames**: twelve scenes × English/Simplified Chinese × macOS/iPhone/iPad/Android/Linux/Windows. Four galleries were recaptured locally; Linux/Windows were imported from the successful integrated-source E2E artifacts. A separate-output six-platform publication check passed after import. The [gallery](screenshots/README.md) records dimensions and provenance. No screenshot from the former combined chat application was copied into the new galleries.

Real-font rendering generated **38 profiles / 76 PNGs** locally and in CI, covering all ten languages and five styles, light/dark, phone/desktop. The bounded matrix captures learning and reference; native E2E covers all product scenes. The updated [product concept](designs/product-2026-10-08/README.md) illustrates the first-lesson/guided-practice path and is labelled separately from real screenshots.

## Actual release assets

| Target | Integrated-source CI output |
| --- | --- |
| Android | APK and AAB |
| iOS | Unsigned IPA |
| macOS | universal2 PKG and ZIP |
| Linux | x86_64 DEB, RPM and tar.gz |
| Windows | x64 MSI and ZIP |

All **10 actual integrated-source assets** were downloaded from build run `37733547331` and checked through `verify_release_assets.sh v1.0.0`, SHA256SUMS and ZIP/tar integrity. They contain no Tim2Tox/Tencent/toxcore archive entry. Final-head assets replace the working set under ignored `dist/release-v1.0.0/`; source-run proof is retained under ignored `dist/release-proof-37733547331-v1.0.0/`. Bundle/application metadata is `icu.agentx.morsecq`, version 1.0.0, build 1. Actual Mach-O inspection established objective_c’s macOS 13.0 floor; the Runner/Podfile deployment minimum is aligned for final packaging. The source PKG has no relocation entries and one root bundle-version entry, and the universal2 app passed deep code-signature verification.

Required five-platform builds, metadata/tag matching, complete ten-asset validation and SHA256SUMS gate a draft GitHub Release. The release job is intentionally skipped for PRs. No tag, published GitHub Release or store submission was created. CI Android packages use the debug testing key unless owner signing is configured; the iOS IPA is unsigned; macOS packages are not Developer ID signed/notarized. Owner distribution signing and physical-device microphone, keying, haptics and persistence acceptance remain.

After integration tests, use standard Flutter release build commands: Flutter 3.41.9 can retain a development-only Android integration-test registrant with `--no-pub`. Repository builds and CI refresh registration through the standard commands.
