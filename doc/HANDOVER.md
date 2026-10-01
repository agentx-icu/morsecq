[简体中文](./HANDOVER.zh-CN.md)

# morsecq handover

> For the next AI / engineer taking over. Dated 2026-09-30; `master` at `3e98693`, 18 commits, clean tree. The Chinese file is the original where the two disagree.

## 1. The project in three sentences

- **morsecq** is a cross-platform (Android / iOS / macOS / Windows / Linux) Flutter app: learn Morse code (Koch-method training) and chat in Morse (C2C and groups) over the **Tox P2P** network — no server, no phone number. The first launch creates a Tox identity; training progress is stored per identity too.
- The chat stack reuses **Tim2Tox** (`third_party/tim2tox` submodule, GPL-3.0), hardened by the sibling project **toxee** (`agentx-icu/toxee`). morsecq uses only Tim2Tox's `FfiChatService`, not the Tencent UIKit widgets; messages are plain text on the wire, so they interoperate with toxee users.
- All feature code is written and pushed and **every gate is green (analyzer, complexity, layering, ARB). 2026-09-30 (second session): the full test suite was run for the first time — 750 tests across the 7 packages/app, all green after fixing 32 failures (9 product bugs, the rest stale tests; see plan change log v0.3.6). Still no device build**; the macOS arm64 native library was built on a real Mac, the other platforms only on CI runners.

## 2. Read this first

| # | File | Why |
|---|---|---|
| 1 | `CLAUDE.md` (repo root) | Layout, commands, hard constraints, working agreement. **Every rule lives here.** |
| 2 | `doc/plans/2026-09-30-morsecq-plan.md` (English default) / `.zh-CN.md` (original) | Kickoff plan: product, architecture decisions, milestones, risks; the change log at the end records every deviation and decision made during implementation. |
| 3 | `doc/README.md` | Index of all docs (English default, each with a `.zh-CN.md`). |
| 4 | `packages/morsecq_chat/README.md` | The layer with the most traps: Tim2Tox integration, Tencent SDK vendoring, native library. |
| 5 | `doc/operations/BUILD_AND_DEPLOY.md` | Native library and packaging on five platforms. |
| 6 | `doc/i18n/ADDING_A_LANGUAGE.md` | Localisation scheme (same as toxee). |
| 7 | `apps/morsecq/lib/{notifications,desktop,l10n}/README.md`, `packages/*/README.md` | Per-module details. |

toxee (local `/home/user/toxee`, or clone `agentx-icu/toxee`) is the reference implementation; its `CLAUDE.md`, `doc/architecture/HYBRID_ARCHITECTURE.md`, `doc/reference/GROUP_CHAT_GUIDE.md` and `doc/architecture/MOBILE_BACKGROUND.md` explain Tim2Tox's behaviour. **Never modify toxee.**

## 3. Environment and commands

```bash
# Toolchain: Flutter 3.41.9 stable (same as toxee CI; Dart 3.11.5). In the container it lives at /home/user/flutter
export PATH=/home/user/flutter/bin:$PATH

git clone --recursive https://github.com/agentx-icu/morsecq   # submodule third_party/tim2tox pinned to 9d4245a (same as toxee)
cd morsecq
dart run tool/bootstrap_deps.dart   # MUST run before pub get: vendors the Tencent Cloud Chat SDK, applies tim2tox's patches, writes the root pubspec_overrides.yaml (gitignored)
dart pub get                        # pub workspace: one resolution at the root covers every package

# Gates (exactly what CI's analyze.yml runs)
for d in packages/* apps/*; do flutter analyze "$d"; done
dart run tool/check_complexity.dart     # any .dart file > 500 lines fails (generated files and l10n exempt)
dart run tool/import_guard.dart         # layering: only packages/morsecq_chat may import tim2tox_dart / tencent_*; pure-Dart packages must not import Flutter
dart run tool/strings_to_arb.dart --check
(cd apps/morsecq && flutter gen-l10n)   # after editing ARBs, regenerate lib/l10n/generated/

# Tests (never run as a whole yet!)
for d in packages/* apps/morsecq; do (cd "$d" && flutter test --exclude-tags=needs-native); done

# Native library + packaging
bash tool/ci/build_tim2tox.sh --target linux-x86_64 --mode release   # verified in this container; ToxAV permanently off, sqlite off by default
./build_all.sh --platform macos --mode debug                          # other platforms need their toolchains
# UI without the native library: --dart-define=MORSECQ_FAKE_BACKEND=true (the app also falls back automatically when the real backend fails to start)
```

Conventions: push to `master` only (the repo's default branch); Conventional Commits prefixes (feat / fix / docs / build / chore); every change passes the gates above.

## 4. Repository layout (pub workspace)

```
packages/morse_core        pure Dart  alphabet, PARIS/Farnsworth timing, encoder, streaming key decoder (log-domain two-cluster dit estimate)
packages/morse_trainer     pure Dart  Koch course, drills, alignment scoring, confusion matrix, SRS, send diagnostics, progress model
packages/morse_dsp         pure Dart  Goertzel tone detection, auto-tune, envelope gate, AudioMorseDecoder (microphone decoding)
packages/morse_io          Flutter    MorsePlayer, SoLoud sidetone, haptics, flash, straight/iambic keyer state machines, keying widgets
packages/morsecq_chat_api  pure Dart  UI<->backend contract: IdentityService, ChatService, models + in-memory fakes (testing.dart)
packages/morsecq_chat      Flutter    Tim2Tox implementation of the contract (the ONLY package allowed to import Tim2Tox / Tencent SDK)
apps/morsecq               app        lib/di (backend factories, AppScope, AppServices), lib/startup, lib/ui/{account,learn,chat,contacts,groups,reference,stats,listen,shell},
                                      lib/training (per-identity stores, TrainingControllerHost), lib/notifications, lib/lifecycle, lib/desktop, lib/i18n + lib/l10n
third_party/tim2tox        submodule  never edit in place; third_party/stubs holds an empty stub for the Tencent UIKit common package
tool/                      gates and scripts: check_complexity, import_guard, strings_to_arb, bootstrap_deps, ci/build_tim2tox.sh, gen_tray_icons
doc/                       documentation (English default + zh-CN)
```

About 47k lines of Dart excluding generated code. Test files: 33 in packages, 43 in the app; the `needs-native` smoke self-skips without `libtim2tox_ffi`.

## 5. Architecture facts and traps you must know

All recorded in the plan's change log; ordered by "you will break something if you do not know this":

1. **`cloudCustomData` never reaches the wire.** Tim2Tox's `sendTextWithResult(..., cloudCustomData)` stores it locally only, and the group send has no such parameter. Hence v1 Morse messages are plain text played back at the listener's own speed. Transporting the sender's keyed timing needs an upstream Tim2Tox "message annotation" (plan §5.2 layer 2, the D line).
2. **The "B variant" runtime.** No `Tim2ToxSdkPlatform`, no FakeUIKit, but **`setNativeLibraryName('tim2tox_ffi')` must still be called** (`NativeLibrarySetup.ensure()` inside `MorsecqChatBackend.create`) because `quitGroup`, `DartGetGroupMemberList` and `DartInviteUserToGroup` go through the Tencent bindings. Never call `TIMManager.initSDK` (it installs a second inbound path). The SDK's process-global custom-callback hook is owned by `engine/native_callbacks.dart` (`NativeCustomCallbacks`): it routes `friendAddResult` (without it `addFriend` only returns after a 30 s timeout) and the `DartNotifyGroup*` notifications to the live session; `groupChatIdStored`/`groupTypeStored` fall back to pulling `syncGroupIdentitiesFromNative()`.
3. **Offline group-invite replay** is morsecq_chat's own `ConversationMetaStore`, not Tim2Tox's (which needs initSDK).
4. **Tim2Tox's poll path cannot distinguish `failed` from `sent`**; `MessageStatus.failed` is never produced today (upstream issue).
5. **The Tencent SDK is an implicit compile dependency.** `tim2tox_dart` declares `tencent_cloud_chat_sdk: any`; `tool/bootstrap_deps.dart` pins 8.9.7540+3 through the generated `pubspec_overrides.yaml` and applies 22 patches; `tencent_cloud_chat_common` is satisfied by the empty stub in `third_party/stubs`. `flutter_secure_storage` must be `^11` (9.x pins `win32 ^5`, conflicting with `share_plus`). Since 2026-09-30 the bootstrap also applies morsecq's overlay (`third_party/overlays/tencent_cloud_chat_sdk/`, `tool/vendor_overlay.dart`): the plugin's platform halves become no-op stubs and no Tencent native SDK (`TXIMSDK_Plus_*`, `imsdk-plus` AAR, `libdart_native_imsdk.so`, `ImSDK.dll`) is linked or shipped; `overlay_sha256` in the vendor state, checked by `--offline-check-only`.
6. **Native library**: `tool/ci/build_tim2tox.sh` defaults to `--no-toxav` (`--toxav` is a hard error), `TIM2TOX_DISABLE_SQLITE=ON`, libsodium 1.0.20 linked statically. macOS ships a bare `libtim2tox_ffi.dylib` in `Contents/Frameworks`; iOS embeds an xcframework via CocoaPods; Android fails the Gradle build when jniLibs lack the library (`-PmorsecqAllowMissingFfi=true` allows a UI-only build). Exercised so far: macOS (release build on a real Mac, app launches), iOS (XCFramework + `pod install` on a real Mac; no device build), Android / Windows / Linux natives on CI runners and the Linux / macOS / Windows app builds on CI; a UI-only Android debug APK was built on the Mac (2026-09-30); no Android or iOS app has run on a device yet.
7. **iOS background** declares only `audio` (no ToxAV, so no `voip`); the app disconnects after ~30 s in the background, product expectation is "open to receive"; `AppLifecycleCoordinator` reconnects on resume.
8. **Why the plugin pins**: `flutter_soloud ^4.1.7` (5.x needs a `meta` Flutter 3.41.9 lacks), `record ^6.2.1` (7.x needs Dart 3.12), `tray_manager ^0.5.3` (0.6+ is an FFI rewrite without platform declarations), `torch_light ^1.1.0`, `flutter_local_notifications ^22.3.1` (native Windows toasts).
9. **One `TrainingController` per identity**: `TrainingControllerHost` lives in `AppScope`; the Learn tab and the Me page's training-settings route share the instance, and `LearnScope` only disposes controllers it created. Two instances would overwrite each other's `progress.json`.
10. **The reference handbook creates its SoLoud player lazily** (first play/keying); otherwise the shell's `IndexedStack` touches the audio engine at build time and crashes tests and sound-card-less machines.
11. **Localisation**: `AppScope` sets `LocaleController.active`; `currentS()` serves code without a `BuildContext`; `AppServices.dispose()` must release the `StringsResolver` synchronously before any `await` (AppScope disposes the controller right after). Android notification channel names follow a language change (`LocalNotificationsApi.refreshStrings`, wired through `AppServices` → `NotificationCenter`, 2026-09-30); importance and sound stay frozen at first creation (Android rule).
12. **App-wide preferences** (language, window bounds) live in `<application support>/settings.json`; **per-identity data** (training progress, chat history) lives under `IdentityService.dataDirectory()` and travels with the identity backup (`MCQB` container).
13. Licensing: Tim2Tox and morsecq are GPL-3.0, which **conflicts with App Store terms**; undecided (plan §3.4 / §9). iOS store release must never be a time-boxed acceptance gate.
14. **The SoLoud engine is a process-wide singleton, shared by lease.** Each `SidetoneSink` holds one `EngineLeases` lease through `FlutterSoloudApi`; only the last release stops an engine we started. The engine is resolved on the first `init()` (a native library that fails to load surfaces in `prepare()`, and the Learn screens fall back to the flash). Never call `SoLoud.instance.init/deinit` elsewhere. The Linux / Windows CMake sets `NO_XIPH_LIBS` (flutter_soloud's bundled libopus needs glibc 2.43 and fails to load on Ubuntu 24.04; morsecq only plays a sine).
15. **Integration test / screenshot traps**: two `pumpWidget`s with the same root type update in place, so every `MorsecqApp` needs its own `key`; a SnackBar covers the send button, so taps go through `tapHittable`; on desktop run one integration file per `flutter test` (the second launch of a multi-file run never attaches); `window_manager.setSize` sizes the outer frame and the harness adds the title bar back; on CI the Windows runner needs its display raised to 1920×1080 and the Linux runner needs `fonts-noto-cjk`; flutter_soloud builds its macOS library with CMake inside the pub cache, so drop the cached `cmake_build` after an Xcode change. In a worktree, copy the gitignored `ios/Frameworks/tim2tox_ffi.xcframework` and `macos/Frameworks/libtim2tox_ffi.dylib` from the main checkout before iOS/macOS runs; Android UI-only builds need `ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true`. Screenshot usage: `tool/screenshots/README.md`.

## 6. Status: what is done

| Area | State | Notes |
|---|---|---|
| Engine packages core / trainer / io / dsp | Code complete; core 71, trainer 91, io 55, dsp 49 tests pass | dsp thresholds held on the first run |
| Chat contract and Tim2Tox implementation | Code complete; 45 unit tests + the `needs-native` smoke test pass (the smoke test ran for real on macOS on 2026-09-30) | see §5 items 1–5 |
| App: identity/startup/Me, chat/contacts/groups, learn/stats, reference/translator, listen, notifications, desktop shell | Code complete, fully wired, analyzer clean; 404 app tests pass | |
| Localisation en + zh | Done; 531 keys, zero TODO; every surface reads `S` | a new language = a new ARB |
| Documentation | English default + zh-CN pairs | |
| CI | `analyze.yml`, `native.yml` green on GitHub Actions since `8ddc265` (2026-09-30) | 8/8 native targets and the Linux / macOS / Windows app builds pass; first runs were red (Tests step; macOS sysroot; arm64 Flutter archives; Linux apt packages) — all fixed |
| Native library | Linux x86_64 (container), macOS arm64 and the iOS device + simulator XCFramework built on a real Mac (`build/native/`, `ios/Frameworks/tim2tox_ffi.xcframework`); Android / Windows x64 built on CI runners | Windows arm64 / Linux aarch64 unverified past the toolchain setup |

## 7. Backlog for the next owner (priority order)

1. ~~Run the whole test suite and fix red.~~ Done 2026-09-30 (second session); keep running `flutter test --exclude-tags=needs-native` per package before every push.
2. **Keep watching GitHub Actions on every push**; the arm64 native rows stay `continue-on-error`.
3. **Device checklist**: sidetone latency < 30 ms and click-free, iOS playback with the silent switch on (may need `audio_session`), Android haptic precision, tray icons on three desktops, notification tap routing, QR scanning, microphone decoding, backup save/share, training progress intact after restore.
4. **License decision** (GPL-3.0 vs App Store).
5. Upstream D line (Tim2Tox): message annotation on the wire, Dart-side custom packet API, lossy packet API, `failed` status. v2 keyed-timing transport and live keying depend on it. The message-annotation RFC is drafted at `doc/rfcs/2026-09-30-tim2tox-message-annotation.md` and filed upstream as https://github.com/agentx-icu/tim2tox/issues/20 (2026-09-30); the implementation is upstream work.
6. Small items: `MorsecqChatBackend.dispose`, `learn_playback.dart` and `reference_player.dart` still await in sequence on purpose (chat before identity before engine; player before its sink), the other teardown chains were converted on 2026-09-30; ~~`SendIssue.describe()`~~ (documented as log-only), ~~Android channel language~~, ~~`Podfile.lock`~~ (iOS + macOS, 2026-09-30) done; ~~app icons~~ (`tool/gen_app_icons.dart` renders "CQ" in Morse for iOS / macOS / Android legacy / Windows plus the 1024 store master `apps/morsecq/icon/app_icon_1024.png`; adaptive icon layers included since 2026-09-30; store screenshots still to do); ~~Chinese telegraph code (P4)~~ (`morse_core` `ChineseTelegraphCode`, tables generated from Unihan by `tool/gen_telegraph_table.dart`, surfaced in the translator: Chinese characters key as four-digit groups with a mainland / Taiwan codebook toggle; a handbook page and chat-side decoding are not done); ~~Apple / Android / Windows bundles linked Tencent's native IM SDK~~ — removed on 2026-09-30 by the bootstrap overlay (§5.5); verified by `pod install` (no `TXIMSDK_Plus_*` / `HydraAsync` in either `Podfile.lock`) and a macOS release build that launches with the stubbed plugin; a UI-only Android debug APK built on the Mac (`-PmorsecqAllowMissingFfi=true`, so no `libtim2tox_ffi.so` either; no `com.tencent.imsdk` class or library inside, the stub plugin class present); the Windows (and Linux / macOS) CI app builds passed with the overlay on `5101913`.
7. Codex review: waived in the first session; the second session ran `codex-mac` on its own diff (see plan change log v0.3.6). Every later change is expected to be reviewed.

## 8. How this code was produced (if you continue with multiple agents)

- The orchestrator wrote **contract skeletons** first (`morse_core` public API, `morsecq_chat_api`), then fanned out agents by **directory ownership**; each agent touched only its own tree. Shared files (the root `pubspec.yaml` `workspace:` list, the ARBs) were append-only with a re-read before every edit.
- Agents never committed; the orchestrator ran all gates per wave, then committed and pushed.
- Every brief carried: environment, ownership, hard rules (500 lines, zero analyzer issues, mobile parity), deliverables, report format. Plan §11 has the wave table.
- Two user directives to remember: "no builds or tests, code only" (last round) and "no codex review this session" (last round). Re-confirm both in a new session.

## 9. Known issues left by the agents (collected as reported)

- `arb_consistency_test` iterates every `app_*.arb` and rejects leftover `@@TODO`.
- iOS / macOS `Info.plist` `CFBundleLocalizations` lists only `en`, `zh-Hans`; update when adding a language.
- `record_linux` needs `parecord` (PulseAudio / PipeWire-pulse) on PATH.
- Linux tray needs `libayatana-appindicator3-dev`; AppIndicator has no left-click or tooltip.
- Windows notification `cancel()` and cold-start payloads only work when MSIX-packaged.
- Tim2Tox `auto_tests` depend on `TIMManager.initSDK` and cannot be reused; `morsecq_chat/test/native_smoke_test.dart` is the self-built headless smoke and needs the native library.
