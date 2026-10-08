[简体中文](./VALIDATION.zh-CN.md)

# Verification record — 2026-10-08

Verified source revision: `1eb4784140bc11b106912482f6485c6b5dd13164`. Toolchain: Flutter 3.41.9 / Dart 3.11.5.

## Automated checks

| Check | Result |
|---|---|
| [Analyze](https://github.com/agentx-icu/morsecq/actions/runs/37737215089) | Strict analysis, source guards and package/application tests passed. |
| Application suite | 780 passed; 2 opt-in image exporters skipped. |
| Package suites | Core 92, DSP 107, audio I/O 124, trainer 270 and radio tools 18 passed. DSP has 2 existing skipped first-block noise-floor cases. |
| Learning behavior | Guided pace persistence, receive verdicts, independent per-character evidence, lesson advancement, course completion, daily plans and QSO readiness passed. |
| Persistence | First launch, progress save/reopen, malformed data recovery, background saves, preferences and confirmed data removal passed. |
| Tool regressions | Screenshot import 19, Apple plugin cache 4, macOS installer 3, macOS runtime 9 and complete release assets 7 checks passed. |
| [Platform builds](https://github.com/agentx-icu/morsecq/actions/runs/37737215290) | All five required platform builds passed. |
| [Desktop E2E](https://github.com/agentx-icu/morsecq/actions/runs/37737214821) | macOS, Linux and Windows startup, persistence, English/Chinese first-lesson journeys and all 12 screenshot scenes passed. |
| [Visual matrix](https://github.com/agentx-icu/morsecq/actions/runs/37737214831) | 38 profiles / 76 PNGs covering ten languages, five styles, light/dark and phone/desktop layouts. |

The first-lesson journey covers six assisted intro trials, one-character then three-character guided receive, and correctly keyed K advancing guided sending to M. Guided practice leaves Koch lesson 1 unchanged. The journey also passed locally on iPhone and Android.

The DSP skips concern unusually quiet first noise blocks that can produce a spurious leading symbol. The opt-in application exporters are exercised by the screenshot and visual workflows.

## Screenshots and packages

The [gallery](screenshots/README.md) contains **144 frames**: 12 scenes × English/Chinese × macOS/iPhone/iPad/Android/Linux/Windows.

| Target | Verified packages |
|---|---|
| Android | APK and AAB |
| iOS | IPA |
| macOS | Universal2 PKG and ZIP |
| Linux | x86_64 DEB, RPM and tar.gz |
| Windows | x64 MSI and ZIP |

All **10 packages** from the platform build were downloaded and checked for complete asset coverage, SHA-256 and archive integrity. Every embedded macOS Mach-O architecture passed the **13.0** minimum-runtime gate. The universal2 application passed deep code-signature verification; the PKG contains one root application bundle and no relocation entries. Android packages contain all three required ABIs and request no Internet permission.

Commands for reproducing these checks are in the [test guide](testing/TEST_PYRAMID.md), [build guide](operations/BUILD_AND_DEPLOY.md) and [capture guide](../tool/screenshots/README.md).
