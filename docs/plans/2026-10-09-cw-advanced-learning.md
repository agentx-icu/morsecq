# CW Academy inspired advanced learning implementation plan

**Goal:** Deliver persistent mistake review, whole-word and sentence comprehension, goal-driven progression, and richer offline QSO simulation.

**Architecture:** Keep pedagogy in pure Dart `morse_trainer`, persist new evidence in `TrainerProgress`, and expose practice screens through the existing shared `TrainingController`. Exact receive mistakes retain text, original timing and channel conditions; assisted listening never counts as independent mastery or unlocks Koch lessons. Goal routes use comparable evidence, preserve the beginner path, and include practice actions in the daily plan.

**Tech stack:** Flutter/Dart workspace, atomic local JSON stores, existing Morse playback and keyer, ARB localization, unit and widget tests.

## Source and interpretation

Reference: [CW Academy Intermediate Curriculum v2.1](https://cwops.org/wp-content/uploads/2025/06/Practice-Instructions-Intermediate-ver.2.1.htm), accessed 2026-10-09. The curriculum develops whole-word recognition, common word parts, information extraction from QSO/POTA exchanges, short-story head copy, readable sending and contest operation. Its speed stages inform optional milestones at 10, 13, 15, 18, 20 and 25 WPM. These are practice goals, not certificates or automatic Koch unlocks. All bundled examples are original; this project neither redistributes course recordings nor claims CW Academy endorsement.

## Checklist

- [x] Explore existing progress, daily-plan, receive and QSO architecture.
- [x] Adopt the four feature directions explicitly selected by the user.
- [x] Create a managed worktree and feature branch.
- [x] Verify the baseline and resolve workspace dependencies.
- [x] Mistake notebook: bounded immutable entries, source/timing/channel context, exercise de-duplication, cross-day independent recovery, filtering and exact retry UI. Unit tests first; controller restart and widget coverage.
- [x] Comprehension: original word, phrase, QSO/POTA information and short-story exercises; hide answers during playback; field-based grading; replay/reveal mark assistance; persist attempts independently of Koch evidence. Unit tests first and widget coverage.
- [x] Goal routes: persist first-QSO/conversation/contest selection, explain staged evidence and missing skills, provide direct practice actions, adapt future daily-plan allocations without deleting finished steps. Verify old JSON defaults and reloading.
- [x] QSO: extend deterministic scripts and validation with contest/POTA exchanges, partial repeats and correction requests. Preserve AGN/QRS, draft recovery and existing scenarios. Unit tests first and UI coverage.
- [x] Integrate learn-home entry points for all layouts, localization in ten languages, docs, and clear-data behavior through the existing profile store.
- [x] Review specification and implementation; fix findings without Claude tooling.
- [x] Run gates, package tests, widget tests and native build/interaction checks appropriate to these changes.

## Work ownership

Independent module tasks may be delegated using the parallel-agent skill. The primary agent owns shared progress/controller/plan integration, exports, localization merging and final verification. Module agents own separate mistake, comprehension and QSO files and their tests, preventing simultaneous edits of shared integration files.

## Acceptance

After reopening the app, mistakes, recovered status, comprehension evidence and chosen goal remain. An incorrect attempt remains pending; assistance cannot clear it. Correct retries across separate days recover a mistake. Listening answers are hidden until playback finishes and results identify assistance. Route milestones require actual recent evidence at the chosen speed. Contest and POTA QSO scenarios accept equivalent courteous exchanges and permit targeted repetition without advancing a stage. Existing course gates, local persistence and account-free navigation remain functional.

## Final verification (2026-10-09)

- Gates: all package/app/tool analyzers, 500-line complexity limit, import guard and UI literal guard passed.
- Unit pyramid: 686 tests across Morse core (92), DSP (107), I/O (147), trainer (322) and radio tools (18).
- Application pyramid: 851 tests passed; two opt-in visual rendering tests were skipped by the repository defaults.
- macOS debug build succeeded. Native advanced listening/persistence (one test) and first-day learning in English and Chinese (two tests) passed with real device playback.
- Independent local reviews closed frozen QSO seed, semantic plan accuracy, delayed result dates, old plan completion and unavailable audio grading findings. Legacy QSO envelopes without a completion date remain assisted activity and cannot demonstrate recent independent skill.
- The managed worktree and branch remain available for review after local verification and independent reviews.
