[简体中文](./README.zh-CN.md)

# MorseCQ Documentation

## Convention: bilingual, English by default

Every document in this repository exists as a pair:

- `X.md` — **English, the default.** Links, READMEs and CI point here.
- `X.zh-CN.md` — Simplified Chinese.

The first line of each file is a language link to its counterpart
(`[简体中文](./X.zh-CN.md)` in the English file, `[English](./X.md)` in the
Chinese one). When adding a document, add both files. Where a pair disagrees,
the file that was written first is authoritative and says so in a note at the
top (today that is the Chinese original of the plan document and the English
`BUILD_AND_DEPLOY.md`, which is a condensed summary of the Chinese one).

## Recommended reading path

- **Taking over the project** — [HANDOVER.md](HANDOVER.md): state as of the
  last session, traps, backlog, how the multi-agent work was run.
- **Just want to run it** — [Main README](../README.md) "Build prerequisites"
  → [operations/BUILD_AND_DEPLOY.md](operations/BUILD_AND_DEPLOY.md) for the
  native library on your platform.
- **Contributing code** — [CLAUDE.md](../CLAUDE.md) (layout, gates, working
  agreement) → [plans/2026-09-30-morsecq-plan.md](plans/2026-09-30-morsecq-plan.md)
  §3 "Technology choices and architecture decisions" → the README of the
  package or sub-area you are touching (below).
- **Changing scope or product decisions** — the plan document is the source of
  truth; every edit appends to its change log.

## Plans (方案)

- [plans/2026-10-03-functional-improvements.md](plans/2026-10-03-functional-improvements.md) /
  [zh-CN](plans/2026-10-03-functional-improvements.zh-CN.md) — Detailed specifications and AI
  handoff for eight proposed features: daily plans, interactive QSO, chat practice,
  rhythm replay, guest/placement, materials, message management, and audio workbench.
  Includes data compatibility, acceptance criteria, and phased tasks; documentation
  only, with no current product behavior changed.
- [plans/2026-10-03-interface-languages.md](plans/2026-10-03-interface-languages.md) /
  [zh-CN](plans/2026-10-03-interface-languages.zh-CN.md) — Eight additional interface
  languages, complete ARB translations and mobile/desktop verification.
- [plans/2026-09-30-morsecq-plan.md](plans/2026-09-30-morsecq-plan.md) /
  [zh-CN](plans/2026-09-30-morsecq-plan.zh-CN.md) — Founding product and
  architecture plan: naming, product definition, Tim2Tox facts, the four
  options and the "variant B" decision, training and communication design,
  milestones, risks, multi-agent orchestration, change log. **The Chinese file
  is the original.**

## Operations and build

- [rfcs/2026-09-30-tim2tox-message-annotation.md](rfcs/2026-09-30-tim2tox-message-annotation.md) /
  [zh-CN](rfcs/2026-09-30-tim2tox-message-annotation.zh-CN.md) — Draft
  proposal for Tim2Tox (track D): a per-message annotation that travels with
  the text, the prerequisite of v2 recorded keying. Not yet filed upstream.
- [operations/BUILD_AND_DEPLOY.md](operations/BUILD_AND_DEPLOY.md) /
  [zh-CN](operations/BUILD_AND_DEPLOY.zh-CN.md) — Building the
  `libtim2tox_ffi` native library (`--no-toxav` by default) on Linux, macOS,
  Windows, Android and iOS; where the library lands in each bundle; minimum OS
  versions; the `native.yml` CI workflow and what it cannot verify.

## Testing and screenshots

- [testing/TEST_PYRAMID.md](testing/TEST_PYRAMID.md) /
  [zh-CN](testing/TEST_PYRAMID.zh-CN.md) — The four tiers (gates, unit,
  widget, e2e on a real device), what each proves, `tool/test_pyramid.sh`,
  and the bugs only the top tier found.
- [screenshots/README.md](screenshots/README.md) /
  [zh-CN](screenshots/README.zh-CN.md) — Gallery of the committed product
  screenshots per platform and locale; produced by
  [tool/screenshots](../tool/screenshots/README.md).

## Packages (`packages/*`)

Each package carries its own README (English default; the `.zh-CN.md`
counterpart sits next to it).

- [morse_core](../packages/morse_core/README.md) — Pure-Dart Morse engine:
  alphabet and prosigns, PARIS / Farnsworth timing, text → timeline encoder,
  streaming decoder for hand-keyed input.
- [morse_trainer](../packages/morse_trainer/README.md) — Pure-Dart pedagogy:
  Koch course, drill generators, alignment-based scoring, spaced repetition,
  send-practice diagnostics, learner progress.
- [morse_dsp](../packages/morse_dsp/README.md) — Pure-Dart audio decoding:
  Goertzel tone detection, auto-tune, envelope gate, `AudioMorseDecoder`.
- [morse_io](../packages/morse_io/README.md) — Flutter I/O: `flutter_soloud`
  sidetone, haptics, flash, straight-key / paddle state machines and key
  widgets for touch and keyboard.
- [morsecq_chat_api](../packages/morsecq_chat_api/README.md) — Pure-Dart
  contract between the UI and the chat backend (`IdentityService`,
  `ChatService`, models, in-memory fakes in `testing.dart`).
- [morsecq_chat](../packages/morsecq_chat/README.md) — Tim2Tox-backed
  implementation of the contract; the only package allowed to import Tim2Tox
  or the Tencent SDK.

## App sub-areas (`apps/morsecq`)

- [apps/morsecq](../apps/morsecq/README.md) — The Flutter app shell.
- [lib/notifications](../apps/morsecq/lib/notifications/README.md) — Local
  notifications, unread badge, foreground/background handling and the mobile
  background policy (`lib/lifecycle`).
- [lib/desktop](../apps/morsecq/lib/desktop/README.md) — Window management,
  system tray and shortcuts on macOS / Windows / Linux (no-ops on mobile).
- [lib/l10n](../apps/morsecq/lib/l10n/README.md) — gen-l10n setup, ARB
  files (`app_en.arb` template, `app_zh.arb`), the `S` class, the
  translator glossary and the UI literal guard.
- [doc/i18n/ADDING_A_LANGUAGE.md](./i18n/ADDING_A_LANGUAGE.md) — how UI
  localisation works and the steps to add a language (ARB, catalog,
  reference rows, platform locale manifests).

## Cross-project references

- [Main README](../README.md) / [zh-CN](../README.zh-CN.md)
- [CLAUDE.md](../CLAUDE.md) — conventions, hard gates, working agreement
- **Tim2Tox** (upstream [agentx-icu/tim2tox](https://github.com/agentx-icu/tim2tox),
  vendored as the `third_party/tim2tox` submodule): [documentation index](../third_party/tim2tox/doc/README.md)
- **toxee** (sibling project, same Tim2Tox wire protocol):
  [github.com/agentx-icu/toxee](https://github.com/agentx-icu/toxee)
