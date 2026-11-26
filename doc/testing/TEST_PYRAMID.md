[简体中文](./TEST_PYRAMID.zh-CN.md)

# Test pyramid

Coverage and fixes for every current learning/training entry, flow and save boundary are in the [learning and training audit](LEARNING_TRAINING_AUDIT.md); storage locations and lifecycle guarantees are in the [persistence audit](PERSISTENCE_AUDIT.md).

Run the checks from the repository root after `dart pub get --enforce-lockfile`.

```sh
bash tool/test_pyramid.sh --level gates
bash tool/test_pyramid.sh --level unit
bash tool/test_pyramid.sh --level widget
bash tool/test_pyramid.sh --level e2e --device macos
```

`gates` runs analysis, complexity, import, shared-package pin and UI text checks. `unit` covers all six workspace packages and the repository tools (`dart test tool/test`). `widget` covers local learning, keying, reference, recordings, statistics and settings. `e2e` launches the real app, reopens local persistence, exercises native head-copy audio and advanced learning persistence, completes the first-day learning path and walks twelve screenshot scenes. `--level all` runs the four levels in order and needs an available device for the final level.

A fresh installation requires no account and exposes Learn, Reference and Me. An Android release build opens Learn after the user reviews and accepts the first-run privacy prompt. `privacy_walk_test.dart` exercises the Android startup widget with a separate consent store, opens the policy and terms from the prompt, accepts and reopens both stores from disk. A second test walks the in-app privacy, permissions and support pages in Me. Use an installed Android release to verify native storage, decline/exit and the system microphone permission flow. Confirmed clearing flushes pending writes, retires the active controller, deletes learning files and reloads empty learning state. Backgrounding and desktop quit flush local persistence.

Replace `macos` with an ID from `flutter devices`, or omit `--device` to use the host desktop. The local E2E command and CI use `tool/ci/run_integration_tests.sh` to discover every `integration_test/*_test.dart` file, launch the app once per file and retry a failed file once with a warning annotation. Manually dispatch [E2E CI](../../.github/workflows/e2e.yml) or add `ci:e2e` or `ci:full` to a PR that is ready for review to run on macOS, Linux and Windows, an iPhone simulator and an Android emulator (API 34). For screenshots on macOS, run `bash tool/screenshots/capture.sh --platforms macos --locales en,zh`.

The [Layout workflow](../../.github/workflows/layout.yml) runs `apps/morsecq/test/layout/` after manual dispatch or on a PR targeting `main` or `master` that is ready for review and labelled `ci:layout` or `ci:full`. `layout_sweep_test.dart` covers every screen, the app shell (each destination) and the pages opened from Me; `layout_overlays_test.dart` covers dialogs, sheets, menus, dropdowns, snackbars, error states and drill results. Each scene is resized live through device profiles with their safe areas (iPhone SE and notched phones in both orientations, a gesture-navigation Android phone, iPad portrait/landscape, the zero-inset desktop minimum window and full desktops, and a phone with the soft keyboard open when a field can take focus), at text scales 1.0, 1.3, 2.0 and 3.1 (iOS's largest accessibility size); screen scenes also get a nonlinear scaler, while whole-app scenes (the shell, Appearance, Keys and whole-app dialogs) take only the platform's linear scale, which is all the app's own MaterialApp reads. Screen scenes run again with iOS typography in the Brass Handbook style. A scene fails on any overflow, visible ellipsised text, text a layout shrank below 12 px, visible text under a status bar, notch, home indicator or keyboard (top inset with scroll views at their start, bottom inset at their end), text that stays under a floating action button at the end of scrolling, a FAB label outside its button, an app-bar title outside its bar, or when the scene's state is lost on a resize. The harness checks itself with fixtures (`harness checks`). It needs real fonts (the test font's square glyphs make Latin text far too wide): pass `--dart-define=MORSECQ_MATRIX_FONT=<NotoSansCJK-Regular.ttc>`, `MORSECQ_MATRIX_MONO_FONT=<NotoSansMono-Regular.ttf>` and `MORSECQ_MATRIX_SERIF_FONT=<NotoSerifCJK-Regular.ttc>`; without them the sweep is skipped. Rotation on a real platform is `integration_test/rotation_test.dart` (iOS/Android only; skipped on desktop): it rotates through the system and checks the selected tab, typed text, focus and an open drill survive.

The opt-in Visual matrix CI renders ten languages and four styles in light/dark on phone and desktop: 34 deduplicated profiles and 68 real PNGs. It uses the same `ci:e2e` or `ci:full` label and manual dispatch options; see the [screenshot guide](../../tool/screenshots/README.md). Custom capture profiles require a separate explicit output so canonical galleries stay intact.

`first_day_learning_test.dart` runs English and Simplified Chinese through the real playback factory and native key timing: fresh Start here, six assisted intro trials, one-character and three-character guided receive, then a correctly keyed K advancing guided sending to M. Each guided receive stage must leave Koch lesson 1 unchanged. This is a behavior check, not evidence of learner mastery. The local E2E command and each E2E platform include this test. The iOS simulator suite runs in shards.

`advanced_learning_test.dart` has two tests on an isolated local profile. The first uses test playback that records the real timeline: it checks that a complete playback precedes head-copy answers, an omitted word becomes a semantic mistake, and the selected goal, question snapshot and listening result survive reopening. The second uses the device's real audio and passes only when playback completes or, without a usable audio device, when answers and submission stay hidden and no comprehension record or mistake is written. Widget regressions additionally cover all four styles on phone/desktop, large text, exact retries across days, assistance, frozen plans and delayed QSO recovery.

## Shared packages

`morse_core`, `morse_dsp`, `morse_io`, `morse_trainer` and `radio_tools` also live in the DitMesh repository. `tool/shared_packages.lock.json` pins every Git-visible file of them with the SHA-256 of MorseCQ's copy and of DitMesh's copy, plus the DitMesh commit of the last comparison. A file whose copies differ needs a divergence rule with a reason: `product` (intentional, e.g. the app name or MorseCQ having no chat), `morsecq-ahead` or `ditmesh-ahead` (a change the other side has not taken yet).

`dart run tool/shared_sync.dart --check` (CI and the gates level; no DitMesh checkout needed) fails on any shared file that changed, appeared or disappeared since its pin, on an unexplained divergence and on a stale rule. Its own tests run with `dart test tool/test`.

To change a shared file or take a change from DitMesh:

1. `dart run tool/shared_sync.dart --compare <ditmesh-checkout>` lists the files that changed on each side since the pin.
2. Make the change, and port it to the other repository when both should have it. If the copies are meant to stay different, add or update a divergence rule in the manifest.
3. `dart run tool/shared_sync.dart --write --ditmesh <ditmesh-checkout>` re-pins both sides and the DitMesh commit (without `--ditmesh` only MorseCQ's hashes move), then validates the result. Commit the manifest with the code and say in the commit message what was synced or why it diverges.

`<ditmesh-checkout>` must be the root of a DitMesh checkout that holds every shared package; any other directory is refused before anything is compared or written. Hashes are taken byte for byte, so the root `.gitattributes` keeps `packages/**` LF in every checkout, whatever `core.autocrlf` says. A Windows checkout made before that file existed still holds CRLF copies: with no local changes, run `git rm -rq --cached packages` and `git reset -q --hard` once. `--compare` on Windows needs the same attribute in the DitMesh checkout.
