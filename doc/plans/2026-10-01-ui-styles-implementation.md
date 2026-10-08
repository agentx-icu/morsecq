> Historical pre-split document. Current MorseCQ is the offline trainer described in [README](../../README.md); chat belongs to DitMesh.

[简体中文](./2026-10-01-ui-styles-implementation.zh-CN.md)

# UI styles implementation plan

**Goal:** Implement the four approved additional styles, retain Classic Brass, and provide a persistent appearance chooser on desktop and mobile.

**Architecture:** Extend the existing shared Material theme with style palettes and component geometry. Keep appearance preferences in the existing device settings store, separate from identity data; a preview changes only its local Theme until Apply succeeds. Existing navigation, training controllers, chat drafts, audio engines, and touch/keyboard input remain mounted during a theme change.

**Tech stack:** Flutter, Provider, generated English/Chinese ARB localization, existing KeyValueStore, flutter_test.

## 1. Establish baseline and preference behavior

- Run the existing app tests before implementation.
- Add failing tests in `apps/morsecq/test/appearance/` for the Me → Appearance entry, staged preview, persistence, defaults, invalid saved values, and write failure.
- Extend `lib/di/app_settings.dart` with a stable five-value style enum and atomic serialized appearance record; pass the existing settings store from `lib/di/app_scope.dart`.
- Serialize file-store flushes in `lib/i18n/key_value_store.dart` so simultaneous language and appearance writes cannot race on the shared temporary file. Verify reopening after concurrent writes.

## 2. Build five shared themes and the chooser

- Add style definition and ThemeExtension tokens under `lib/ui/appearance/`; extend `lib/ui/theme.dart`, retaining Classic Brass as an option. Modern Calm is the current default and Restore Defaults appearance; preserve explicit saved styles.
- Cover all five styles in both brightness modes. Use distinct shapes, contrast, display typography, and semantic pastel surfaces; keep Morse monospace.
- Add localized style names and appearance labels to both ARB files and regenerate `S`.
- Implement `AppearancePage`, selection thumbnails, independent System/Light/Dark selection, local preview, Apply, and staged Restore Defaults. Disable input during a save and show localized persistence failures.
- Wire themes into `lib/main.dart`; add Me entry and the desktop/learning shortcut without replacing the root or resetting navigation.

## 3. Match the approved interface hierarchy

- Adapt `lib/ui/learn/learn_home.dart` and `learn_home_widgets.dart`: compact character tiles with real Morse, Continue inside the new-style lesson panel, desktop goal sidebar, and pastel cartoon practice panels. Keep Classic Brass layout intact.
- Add a small code-native radio mascot for Fresh Cartoon; avoid decoration over text and avoid extra gamification.
- Apply shared bubble geometry to `lib/ui/chat/message_bubble.dart` and shared control geometry to keying widgets without changing pointer, keyboard, timing, or audio behavior.
- Test narrow phone, desktop, large text, full character sets, and navigation/draft state retention when applying a style.

## 4. Verify and deliver

- Run focused appearance tests, the full app suite, keying package tests, analyzer, complexity gate, import guard, and ARB synchronization check.
- Render real Flutter previews in Chinese for all four styles at desktop and phone sizes; inspect them and fix overflow or incorrect hierarchy.
- Request an independent Codex subagent review of the actual diff using the code-review skill; this session explicitly disables Claude review. Verify and fix credible findings.
- Update bilingual implementation notes, commit the implementation on `codex/ui-styles`, and retain the worktree for the user. Do not merge or publish.

## Execution result — 2026-10-01

- Completed in the managed worktree `/Users/bin.gao/.codex/worktrees/ui-styles/morsecq`, branch `codex/ui-styles`, starting from design commit `3972bc6`.
- Implemented all four approved additional styles and retained Classic Brass. Five styles support independent System / Light / Dark mode, local previews, explicit Apply, and persistent device settings.
- Full app suite: **456 passed**, with one opt-in visual export skipped in normal runs. Keying package: **71 passed**. The separately enabled export passed and produced twelve Chinese desktop/phone frames; all were visually inspected. These are Flutter widget renders, not physical-device qualification.
- `flutter analyze apps/morsecq packages/morse_io --no-pub`: no issues. Complexity gate, import guard (383 files), ARB synchronization and `git diff --check` passed.
- Independent Codex review found and verified fixes for failed-write contamination and actual-background contrast. It independently passed sixteen settings/theme tests, then nine narrow/full-course/large-text learning tests after the final layout adjustment. No unresolved Critical / Important findings.
- Original checkout's installer/CI work remains separate. Design images were committed first; implementation and generated previews are committed in this worktree.

## Revision log

- 2026-10-01: Created after the user approved all four visual concepts and requested a new development worktree.
- 2026-10-01: Implemented all five palettes, staged previews, independent brightness, serialized persistence, shared geometry and styled learning layouts; added actual desktop/phone frames and independent Codex review. Fixed failed-write contamination and contrast on the real pastel backgrounds. Large-text tiles reserve glyph space and wrap when needed.
- 2026-10-01: Completed final full-suite verification and recorded independent review, rendered previews, and delivery branch.
- 2026-10-01: At the user's request, changed the default and Restore Defaults style to Modern Calm without migrating saved choices. README concepts use the corresponding language and product screenshots are pinned to Modern Calm; delivery follows the user's subsequent PR/CI/merge instruction.
