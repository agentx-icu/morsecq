# Layout and interaction review fixes

**Goal:** Resolve all eight findings from the 2026-10-01 layout audit while retaining the five styles and Modern Calm default.

**Architecture:** Keep changes in the shared Flutter UI, with a reference-counted editor shared per service/conversation and the current master's identity flush/replacement barriers. Draft clearing follows the sent editing revision; history expands the existing local-history window and merges live events by message ID. A centered two-sliver timeline grows older records above its stable origin and new records below it, preserving reading position without estimating bubble heights.

**Stack:** Flutter, existing ChatService contract/fake backend, widget tests, ARB localization and the native screenshot pipeline.

The user's request to fix the review findings approves the recommendations already presented in the audit. Implementation proceeds in this session; no Claude review or RTK.

## Tasks and verification

1. **Protect drafts** — modify `apps/morsecq/lib/ui/chat/message_input.dart`; add `test/chat/message_input_draft_test.dart`. First reproduce delayed-send draft loss, edits returning to the same text, failure and disposal. Record actual text edit revisions, clear only the unchanged sent revision, serialize draft writes across editors for the same service/conversation and avoid controller access after disposal.
2. **History and reading continuity** — modify `ui/chat/conversation_screen.dart`, extracting title/banner widgets to `conversation_header.dart` to remain below 500 lines. Add `test/chat/conversation_history_test.dart`. Initially request 50 records, then increase the requested local window by 50, accounting for live messages. This uses the existing API without timestamp-only cursors that skip tied timestamps. Merge by ID, retain status events during loads, reject stale results after clear/disposal, and expose loading/retry controls. Use centered chronological slivers to keep existing message positions stable as either end grows. Follow the bottom only near it or after an explicit send; otherwise provide a localized new-message entry.
3. **Confirm clearing history** — reuse `chat_layout.dart`'s destructive confirmation for c2c and groups. Explain that only this device's conversation history is removed, peers' copies are unaffected and deletion cannot be undone. Add cancel/confirm/failure and pending-load regression cases.
4. **Group forms** — modify `ui/groups/create_group_sheet.dart` and `join_group_sheet.dart`; add restricted-height tests in `test/chat/group_sheet_layout_test.dart`. Use sheet-local keyboard insets, safe areas and scrollable content. Verify create advanced options and join validation errors at 320×640 with a 280-pixel keyboard and 1.8 text scale; submission stays reachable.
5. **Alphabet grid** — modify `ui/reference/alphabet_grid.dart`; add `test/reference/alphabet_grid_layout_test.dart`. Measure text at the current scaler, derive safe card height and column width, preserve full Morse patterns and tap/long-press behavior. Test 320/390/900 widths, both languages and enlarged fonts.
6. **Classic lesson home** — modify `ui/learn/learn_home.dart` and `learn_home_widgets.dart`; add `test/learn/learn_home_layout_test.dart`. Give all style chips bounded widths. Move the Classic primary action before the potentially long character set and let that set expand; preserve all learned characters and newest-character visibility.
7. **Appearance preview** — modify `ui/appearance/appearance_page.dart`; extend `test/appearance/appearance_page_test.dart`. Put the complete preview before choices at stacked widths; keep the existing side-by-side layout from an inner width of 900, thumbnails, selection state, staged settings and fixed Apply area. Check 320/390/900 widths and 1.8 scale.
8. **Integration and delivery** — keep ARB strings bilingual, generate localization output, update product-plan changelogs. Run focused regressions from RED to GREEN, then all app tests, analyzer and repository gates. Independently review scope and actual diff. Regenerate 17 scenes × two locales × six targets with `tool/screenshots/capture.sh`, importing Linux/Windows only from successful CI at the same UI revision. Open PR, wait for final-head CI, fix any errors and merge.

## Commands

Run Flutter commands from `apps/morsecq`, gates and capture commands from the repository root:

```bash
flutter test test/chat/message_input_draft_test.dart
flutter test test/chat/conversation_history_test.dart
flutter test test/chat/group_sheet_layout_test.dart
flutter test test/reference/alphabet_grid_layout_test.dart
flutter test test/learn/learn_home_layout_test.dart test/appearance/appearance_page_test.dart
flutter test
flutter analyze
dart run tool/check_complexity.dart
dart run tool/import_guard.dart
dart run tool/strings_to_arb.dart --check
tool/screenshots/capture.sh --platforms macos,ios,ipad,android
```

Expected: Each new regression fails against the audited implementation, then passes after its root-cause fix. Final checks have zero analyzer/gate violations; all platform sets contain 34 distinct PNGs and remain Modern Calm.

## Change log

- 2026-10-01: Recorded all eight user-authorized audit fixes, async/scroll edge cases, mobile parity and PR/CI/screenshot delivery checks.

- 2026-10-01: Independent Codex plan review passed; shared draft queues and reopening regressions address write ordering across editor instances. Preserve the actual 900-pixel inner-width appearance breakpoint; extract timeline/header and goal-ring widgets for the 500-line gate.

- 2026-10-01: Actual-diff review reproduced and resolved cross-route draft clearing, unloaded outgoing-status duplication, and shrinking asynchronous history windows. Share the editor, announce successful local sends to all open conversation routes, retain earlier records and expand displaced origins. Add navigation-return, 175 tied-timestamp records, burst, initial-clear-failure and group-confirmation regressions.

- 2026-10-01: Confirmed-clear IDs suppress late send completions that would recreate deleted rows, while post-clear creations remain visible. Added the gated row-creation/clear/completion regression.

- 2026-10-01: Final independent diff review passed, including a clear operation that finishes after its route is disposed. At UI revision `1a4b9db471827b067abd267c50aa6a8b9b1c2bd6`, Analyze CI passed with 533 app tests and one existing conditional skip; macOS/Linux/Windows E2E run [36836332406](https://github.com/agentx-icu/morsecq/actions/runs/36836332406) passed. Regenerated all 204 Modern Calm frames: four local targets and two CI artifact imports through the official capture pipeline. PR #6 awaits final-head CI after the asset/documentation commit.

- 2026-10-01: Integrate master persistence changes (`fdee8e1`) after it advances during delivery. Resolve the compose conflict by combining shared draft ordering/edit revisions with background durability, retry and identity replacement guards. A same-key restore creates a fresh shared editor even while an old route remains mounted; the regression fails without writer invalidation and passes with it. The 40 combined chat regressions, analyzer and gates pass; independently review the integration, rerun all app tests and refresh gallery provenance at the resulting UI revision before final CI/merge.

- 2026-10-01: Merge review reproduced premature flush completion and hidden write failures when reopening an unchanged pending draft. Move durable snapshot/error state into the shared writer, await its complete queue, retain failed drafts for retry and observe identity boundaries while pending/failed. Remove idle clean writers and invalidate old writers on replacement. Added waiting, failed retry, disposed-failure recovery/isolation and saved-text reversal regressions.

- 2026-10-01: Integrated-source verification passed: 594 app tests with one existing skip, zero analyzer issues, complexity/import/ARB gates, and independent merge review. The two pending-reopen durability regressions first failed, then passed; five further integration edge cases are covered in the complete suite. Refresh the gallery from this integrated UI and await final-head CI before merging PR #6.
