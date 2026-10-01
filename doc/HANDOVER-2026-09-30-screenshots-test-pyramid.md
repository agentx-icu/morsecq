[简体中文](./HANDOVER-2026-09-30-screenshots-test-pyramid.zh-CN.md)

# Handover: screenshot pipeline + test pyramid (branch `feat/screenshots-test-pyramid`)

> For the AI or engineer taking over from the 2026-09-30 session. The Chinese
> file is the original where the two disagree. General project traps are in
> [HANDOVER.md](HANDOVER.md); this file covers only this branch.

## 1. Where things are

| item | value |
|---|---|
| worktree (Mac) | `/Users/bin.gao/chat-uikit/morsecq-shots` — same storage as VM `~/bin_gao_home/chat-uikit/morsecq-shots` |
| main checkout | `/Users/bin.gao/chat-uikit/morsecq` on `master` (fast-forwarded to `origin/master` = `8eac300`) |
| branch | `feat/screenshots-test-pyramid`, rebased onto `8eac300`, **not pushed** |
| commits on the branch, oldest first | `fix: desktop debug launch, add-friend sheet semantics, trend-chart labels` · `test: real-UI integration tests, screenshot pipeline, test pyramid runner, macOS screenshots` · `fix(contacts): scan action below the Tox ID field…` · `test: iOS, iPad and Android screenshots; UI-only Android e2e builds` · `fix: codex review round 1 — sheet scrolling, label thinning, capture script gates, docs` |
| user directives this session | single-agent implementation; **codex review fanned out over parallel agents when asked**; fix review findings first, then rerun the whole pyramid; push only when told |

Everything runs on the Mac over `ssh mac2` (VM has no Flutter). Prefix every
remote command with
`export PATH=/opt/homebrew/opt/openjdk@17/bin:/opt/homebrew/bin:$HOME/flutter/bin:$HOME/Library/Android/sdk/platform-tools:$PATH; export JAVA_HOME=/opt/homebrew/opt/openjdk@17`
(Android's Gradle needs the arm64 JDK; the non-interactive shell does not
source the profile that sets it).

## 2. What was delivered (all verified on the Mac unless noted)

- `apps/morsecq/integration_test/` — `app_launch_test.dart` (real `main()`,
  onboarding → five tabs → drill → add friend + send → translator → Me) and
  `screenshots_test.dart` (17 scenes × en/zh on seeded fakes, Flutter-layer
  capture); `support/{shot_harness,seed_data,scene_walk}.dart`;
  `test_driver/integration_test.dart` writes the PNGs.
- `tool/screenshots/capture.sh` (per-platform orchestration, verify, publish),
  `tool/test_pyramid.sh` (gates → unit → widget → e2e), `.github/workflows/e2e.yml`
  (opt-in macOS runner; never triggered yet because the branch is not pushed).
- Committed frames: `doc/screenshots/{macos,ios,ipad,android}/{en,zh}/` (34
  each; macOS 1280×768 @1x, mobile @2x), reviewed frame by frame.
- Docs (bilingual): `doc/testing/TEST_PYRAMID.md`, `doc/screenshots/README.md`,
  `tool/screenshots/README.md`; CLAUDE.md commands + layout rows; doc index;
  root README status; plan change-log `v0.3.9`.
- Product bugs found by the top tier and fixed at the cause: desktop debug
  launch crash (`AppScope` provider type), add-friend sheet semantics assertion
  (Tooltip in the suffix slot, macOS and iOS), accuracy-trend labels/caption,
  `FakeChatService.addFakeGroupMember` hook.
- Test status at the last full run (before review round 1 fixes):
  `tool/test_pyramid.sh --level all` → ALL PASSED on macOS. After round 1
  fixes only `flutter analyze apps/morsecq`, `test/chat/add_friend_test.dart`
  and `test/stats` were rerun (green). Launch test passed on macOS, iOS
  simulator (`42498CC3-…`, iPhone 16 Plus) and Android `emulator-5554`.

## 3. Codex review status (three parallel `codex-mac` runs, `gpt-6-sol` xhigh)

| review | scope | verdict | state |
|---|---|---|---|
| A | product fixes | NEEDS-CHANGES (4) | **all fixed** in the round-1 commit |
| C | scripts / CI / docs | NEEDS-CHANGES (12) | **all fixed** in the round-1 commit |
| B | integration harness | NEEDS-CHANGES (8) | **open — do these first** |

### 3.1 Review B findings, verbatim scope, with the intended fix

1. **High — `shot_harness.dart` `settle()`** catches every `FlutterError`,
   hiding real errors, and proceeds after a timeout. Fix: catch only the
   pumpAndSettle timeout (`FlutterError` whose message starts with
   `pumpAndSettle timed out`), rethrow anything else; each scene must assert a
   ready condition before `capture()` (see 2).
2. **High — `scene_walk.dart` walkShell**: conversation, group conversation,
   translator and listen captures have no destination/content assertion, and
   `screenshots_test.dart` only counts captures. Fix: before each capture
   `expect(find.byType(<Screen>), findsOneWidget)` plus a content check
   (e.g. a seeded message text in a `MessageBubble`, the translator output
   pattern, `ListenScreen`), and tap only hit-testable targets
   (`tester.tap(..., warnIfMissed: false)` is NOT the answer — assert instead).
3. **Medium — receive drill audio**: the drill starts real SoLoud audio; the
   walk pops it while disposal is unawaited, then opens send practice. Fix:
   seed training settings with sound off / flash on for the screenshot run
   (write `settings.json` via `FileTrainingSettingsStore` next to the seeded
   progress), or await teardown before the next drill.
4. **Medium — `app_launch_test.dart`** `find.textContaining('ABAB')` can
   match the typed ID if the sheet is still visible. Fix: assert
   `find.byType(AddFriendForm)` is gone, then tap the friend tile by its
   stable key (check `contacts_page.dart` / friend list for `ValueKey`; add one
   if missing).
5. **Medium — `shot_harness.dart`** forced pixel ratio accepts `Infinity` /
   huge values; malformed defines silently default. Fix: validate
   (`isFinite`, 0.25–4 range, window ≤ 8192 px, theme in the allowed set) and
   `throw ArgumentError`.
6. **Medium — window size**: on Linux/Windows a size mismatch only logs. Fix:
   fail unless the platform is macOS (documented clamping); or compare
   against the achieved size with a tolerance and fail on Linux/Windows.
7. **Low — `app_launch_test.dart`**: the fake identity's default data dir is
   the stable `systemTemp/morsecq_fake/<pk>`; another run's training data can
   leak in. Fix: isolate — e.g. delete that directory in `setUp`, or add a
   `--dart-define` the fake backend factory honours for its data dir.
8. **Low — `seed_data.dart`**: messages at today 09:12 are future-dated in
   early-morning runs; progress "one hour ago" can cross midnight. Fix: one
   controlled clock, e.g. `now - 3h` clamped to today, and derive every
   timestamp from it.

After fixing: rerun `flutter analyze apps/morsecq`, then
`tool/test_pyramid.sh --level all` (macOS), then the launch test on iOS
(`-d 42498CC3-9565-4BC8-A6DE-817F480B7887`) and Android (`-d emulator-5554`,
with `ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true`), then
`tool/screenshots/capture.sh --platforms macos,ios,ipad,android` to refresh
the committed frames if any scene changed (seeded settings → the drill frames
will change), inspect the PNGs, commit. Then a short `codex-mac` re-review
confirming only the fixed items (global policy §2.5).

## 4. Remaining work, in order

1. Fix review B (above), rerun the pyramid, commit, re-review.
2. Linux and Windows screenshots + launch test: no such machines here.
   Options: extend `e2e.yml` with `ubuntu-latest` (`xvfb-run` around
   `flutter test integration_test -d linux`, apt `libgtk-3-dev ninja-build
   libasound2-dev`) and `windows-latest` jobs, push the branch, trigger with
   `workflow_dispatch`, download the artifact, commit the frames. Update the
   status table in `doc/screenshots/README.md` (both languages).
3. Push the branch and open the MR against `master` (Conventional Commits,
   **no AI attribution lines**, per the global policy). Nothing has been
   pushed yet.
4. Global policy request that could not be honoured: the user asked to
   switch codex reviews to `gpt-6.1-sol` xhigh. Verified twice on 2026-09-30
   with a real call (`codex exec -m gpt-6.1-sol …`): the server answers
   `The 'gpt-6.1-sol' model is not supported when using Codex with a ChatGPT
   account`. The wrapper `~/.local/bin/codex-mac` still defaults to
   `gpt-6-sol`; the user was told and must decide (wait, or change the
   account/login on the Mac). Do not switch blindly.
5. Delete this handover once merged; fold anything durable into
   `HANDOVER.md`.

## 5. Traps specific to this branch

- Two `pumpWidget` roots of the same type are updated in place, not
  replaced: keep distinct `key`s on each `MorsecqApp` in the walk.
- A SnackBar covers the composer's send button for 4 s; `flutter test` only
  warns on a missed tap. Clear it or assert on the outcome.
- `flutter drive`/`flutter test` on iOS regenerates `apps/morsecq/ios/Podfile.lock`;
  the worktree must have `ios/Frameworks/tim2tox_ffi.xcframework` and
  `macos/Frameworks/libtim2tox_ffi.dylib` copied from the main checkout
  (gitignored), or the lock loses the `Tim2ToxFFI` pod.
- Android needs `ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true` (both
  scripts export it) and the arm64 JDK on `JAVA_HOME`.
- The Mac's sshd may refuse connections for ~60 s after a long build; wait,
  do not restart tunnels.

## 6. Progress on 2026-10-01 (takeover session)

- All 8 findings of review B fixed (`b8112fd`), plus two defects fixed at the cause: the shared
  SoLoud engine shut down under live sinks (`EngineLeases` in `morse_io`) and the relative staging
  path in `capture.sh`; codex (gpt-6-sol xhigh) APPROVE after follow-up rounds. macOS pyramid ALL
  PASSED, iOS / Android launch tests pass.
- Frames refreshed: macOS is now a true 1280×800 (the old 768 was the title bar's 32 px); mobile
  frames are byte-identical to the old ones (deterministic seed) except `android/en/translator.png`
  (caret blink). The root READMEs gained a screenshots section, each with its own language's frames.
- `e2e.yml` has Linux / Windows jobs, **not run yet**: items 2 (trigger after push, fetch frames)
  and 3 (push, MR) of section 4 remain. Item 4 is resolved: `gpt-6.1-sol` works since 2026-10-01
  and is the wrapper default.
