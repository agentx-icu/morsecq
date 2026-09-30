# CLAUDE.md

Guidance for coding agents and contributors working in this repository.

## Project

**morsecq** is a Flutter Morse code trainer plus a serverless Morse chat over the
**Tox P2P network**. There is no server: peers key Morse to each other directly.
It is a sibling of **toxee** (same org, same Tim2Tox bridge) and interoperates
with it on the wire. Licence: GPL-3.0.

The authoritative plan (方案) is `doc/plans/2026-09-30-morsecq-plan.zh-CN.md`.
Read it before changing scope; keep it in sync when scope changes.

## Layout (pub workspace — one `dart pub get` at the root)

| Path | Role | Rules |
|------|------|-------|
| `packages/morse_core` | **Pure Dart** engine: alphabet, PARIS/Farnsworth timing, encoder, streaming key decoder | never imports Flutter |
| `packages/morse_trainer` | **Pure Dart** pedagogy: Koch/lesson progression, scoring, spaced practice | never imports Flutter |
| `packages/morse_io` | Flutter I/O: audio sidetone, haptics, keying input (touch + keyboard) | Flutter allowed |
| `packages/morsecq_chat_api` | **Pure Dart** contract between UI and backend: `IdentityService`, `ChatService`, models, plus in-memory fakes in `testing.dart` | the UI depends only on this |
| `packages/morsecq_chat` | Tox transport implementing the contract on Tim2Tox (`Tim2ToxIdentityService`, `Tim2ToxChatService`). **The ONLY package allowed to import Tim2Tox / Tencent SDK.** | everything else talks to the contract |
| `packages/morse_dsp` | **Pure Dart** audio decoding: Goertzel tone detection, auto-tune, envelope gate, `AudioMorseDecoder` | never imports Flutter |
| `apps/morsecq` | The app: Material 3 shell, responsive nav (Learn / Chat / Groups / Reference / Me), startup gate (identity is required before training too). Sub-areas: `lib/di` (backend factories, `AppScope`, `AppServices`), `lib/startup`, `lib/ui/{account,learn,chat,contacts,groups,reference,stats,listen}`, `lib/training` (per-identity progress store), `lib/notifications`, `lib/lifecycle`, `lib/desktop`, `lib/i18n` + `lib/l10n` (ARB, class `S`) | depends on packages, never on Tim2Tox; only `lib/di/real_backend_factory.dart` imports `morsecq_chat` |
| `third_party/tim2tox` | git submodule (upstream `agentx-icu/tim2tox`) — to be added with `morsecq_chat` | never edit in place |
| `tool/` | repo gates: `check_complexity.dart`, `import_guard.dart`; `test_pyramid.sh` (all test tiers in order); `screenshots/capture.sh` (product screenshots on every platform) | scanned by the complexity gate too |
| `apps/morsecq/integration_test` + `test_driver` | top of the test pyramid: the real `main()` click-through and the screenshot scene walk, on a real device / desktop window with the fake backend | always `--dart-define=MORSECQ_FAKE_BACKEND=true`; see `doc/testing/TEST_PYRAMID.md` |
| `doc/screenshots/` | committed frames per platform × locale, published only by `tool/screenshots/capture.sh` | never edit PNGs by hand; regenerate after UI changes |
| `doc/plans/` | 方案 / plan documents | every edit appends to the doc's change-log section |
| `.github/workflows/` | CI (`analyze.yml`; `e2e.yml` opt-in via `workflow_dispatch` or the `ci:e2e` label) | mirrors the local commands below exactly |

## Common commands

Toolchain: Flutter **3.41.9** stable / Dart 3.11 (same pin as CI). Run everything
from the repository root.

```bash
export PATH=/home/user/flutter/bin:$PATH

dart pub get                                   # workspace-wide resolution (root only)

# Analyze — zero issues is the bar. Root analysis_options.yaml applies everywhere.
flutter analyze packages/morse_core
flutter analyze apps/morsecq
for d in packages/* apps/*; do flutter analyze "$d"; done

# Tests — per package/app (any that has a test/ dir)
(cd packages/morse_core && dart test)
(cd apps/morsecq && flutter test)
(cd apps/morsecq && flutter test test/app_shell_test.dart)

# Test pyramid — gates, unit, widget, then e2e on a real device (doc/testing/TEST_PYRAMID.md)
tool/test_pyramid.sh                           # all tiers; host desktop is the e2e device
tool/test_pyramid.sh --level e2e --device macos
(cd apps/morsecq && flutter test integration_test -d macos --dart-define=MORSECQ_FAKE_BACKEND=true)

# Product screenshots (tool/screenshots/README.md) -> doc/screenshots/<platform>/<locale>/
tool/screenshots/capture.sh --platforms macos            # ios, ipad, android, linux, windows too

# Repo gates (both HARD: exit 1 on violation)
dart run tool/check_complexity.dart            # .dart files > 500 LOC vs tool/.complexity_baseline.txt
dart run tool/import_guard.dart                # layering: Tim2Tox/Tencent only in morsecq_chat; core/trainer stay pure Dart

# Run the app
(cd apps/morsecq && flutter run -d macos)      # or linux / windows / an attached device
```

If `dart pub get` fails with a lock/contention error, another process is resolving
the workspace — wait and retry rather than running pub inside a sub-package.

## Constraints (hard gates)

- **500-LOC gate with a baseline ratchet.** `tool/check_complexity.dart` scans
  `packages/*/lib`, `packages/*/tool`, `apps/*/lib` and `tool/`. Any `.dart` file
  over 500 lines that is not pinned in `tool/.complexity_baseline.txt` fails CI.
  A pinned file may shrink but never grow past its pin. `--write-baseline` is for
  deliberate, explained splits — never for silencing a new offender. Generated
  files (`*.g.dart`, `*.freezed.dart`, `**/l10n/**`, `app_localizations*.dart`)
  are exempt by pattern. The baseline is currently empty; keep it that way.
- **Import guard.** `tool/import_guard.dart` fails if anything outside
  `packages/morsecq_chat/` imports `package:tim2tox_dart`,
  `package:tencent_cloud_chat*` or `package:tencent_im`, or if `morse_core` /
  `morse_trainer` import `package:flutter/`. The rule table is at the top of the
  file; extend it there, not in the scanner.
- **Strict lints.** Root `analysis_options.yaml` (`avoid_print`, `unawaited_futures`,
  `use_build_context_synchronously`, `cancel_subscriptions`, `close_sinks`,
  `always_declare_return_types`, `prefer_final_locals`, …) applies to every
  package. Packages must not ship their own `analysis_options.yaml` that weakens it.
  Zero analyzer issues — infos included.
- **Pure-Dart packages stay pure.** `morse_core` and `morse_trainer` must be
  testable with `dart test` and usable from a CLI or server; no `dart:ui`, no Flutter.
- **Mobile parity is mandatory.** morsecq targets iOS/Android as well as
  macOS/Linux/Windows. Every design must work on a phone; every bugfix must
  explicitly check whether the same bug exists on the mobile counterpart and fix
  it there too (or state why it cannot apply). Default review question: "does
  mobile hit this too?"
- **Both keying modalities must exist.** Any keying UI ships for touch (on-screen
  paddle/straight key) **and** keyboard (desktop key-down/key-up) at the same
  time; one modality alone is not done.
- **Accounts are required before training too** (product decision). The startup
  gate wraps the whole shell, not just Chat/Groups. See the `TODO(startup-gate)`
  in `apps/morsecq/lib/ui/shell/app_shell.dart`.
- **No Tencent Cloud IM.** The backend is Tox P2P via Tim2Tox. Anything assuming
  an IM server is wrong for this repo.

## Working agreement

- **Deep root-cause fixes only.** Fix the real cause at the correct layer
  (native/FFI, package, or app) — never a surface patch that hides the symptom.
  If the real fix is large, scope it and say so.
- **Tests accompany behaviour.** New behaviour lands with tests in the same
  change; a bugfix lands with the regression test that would have caught it.
- **Plan docs carry a change-log.** Every edit to a `doc/plans/*.md` file
  appends an entry (date, what changed, why) to that doc's change-log section.
- **Docs are bilingual:** `X.md` (English, default) + `X.zh-CN.md`; add both
  when adding a doc.
- **Independent review on every change.** Draft → second opinion → apply
  findings → proceed. Bundle the diff and have the reviewer check correctness,
  layering (import guard), memory/ownership for anything FFI-adjacent, and
  mobile parity. If the reviewer is unavailable, say so explicitly, self-validate
  with analyzer + tests, and record that a review is still owed.
- **Resolve uncertainty before asking the user.** Reserve user questions for
  genuine product/scope forks; technical choices get decided and stated.
- **Never edit `third_party/` in place.** Upstream changes go to the submodule's
  own repo; patches are documented, not applied by hand.
- **Do not commit build outputs.** Platform folders under `apps/morsecq/` keep
  the `.gitignore` files `flutter create` wrote; the root `.gitignore` is the
  safety net for ephemeral dirs, Pods, `.gradle`, `local.properties`,
  `key.properties` and generated plugin registrants.
