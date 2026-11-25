# First-success UI validation — 2026-11-25

[简体中文](FIRST_SUCCESS_VALIDATION.zh-CN.md)

The compact daily plan on Learn home now shows the next required practice and its existing reason before Continue. The complete-plan summary only says “No weak symbols” when that plan has actual per-symbol copying results; an introduction or sending-only plan instead says no copying results were recorded. Completing a plan and passing a course lesson remain explicitly separate. No lesson-unlock, practice-credit, schedule or persistence rules changed.

## Executed checks

- Before implementation, the two new behavior regressions failed for the intended reasons: no visible next-practice preview, and an introduction-only plan claiming “No weak symbols today”. The eight existing plan-card tests passed.
- `flutter test --no-pub test/learn/today_plan_card_test.dart test/learn/learn_home_layout_test.dart test/learn/daily_plan_flow_test.dart test/learn/first_lesson_endings_test.dart test/i18n/arb_consistency_test.dart --reporter expanded` (from `apps/morsecq`): **50 passed**. This includes 320 px width, 2× German text, next-step rationale, no-result completion, recorded weak-symbol results, midnight rollover, existing first-lesson progression and all-ten-locale ARB consistency.
- `flutter analyze --no-pub apps/morsecq`: zero issues.
- `dart run tool/check_complexity.dart` and `dart run tool/ui_literal_guard.dart`: passed.
- The first full widget sweep exposed two 320×640/1.8× regressions: an extra preview heading pushed Continue below the fold. Removing that redundant heading retained the actual next-practice title and rationale. All seven existing home-layout tests then passed without weakening their visibility assertions.
- Localization regenerated with `flutter gen-l10n`; all ten canonical locales contain the evidence distinction.

## Device and participant boundaries

Layout checks use Flutter widget rendering, not physical phone displays or screen readers. Touch/keyboard/assistive technology behavior in installed packages remains a device check. This change adds no audio, microphone, notification, camera or lifecycle code to the app. Physical Bluetooth switching and formal-channel upgrade evidence remain the separate work described by the release readiness records.

The [beginner trial](BEGINNER_TRIAL.md) and its [empty observation CSV](fixtures/beginner-observations.csv) are ready for 5–10 volunteers on their actual first and seventh days. No participants were recruited, no contacts were messaged, no Day-7 return was observed, and no trial outcomes are implied by these automated checks.

Cross-platform checklist dispositions: L3/L8/L10 narrow and large-text layout **verified by widget test**; D2 ten-language resources **verified**; I5 actual screen-reader traversal **needs device**; A/B/V hardware audio, lifecycle and camera changes **not applicable to this UI-only change**; X6 installed candidate and signed upgrade **needs package/device evidence**.
