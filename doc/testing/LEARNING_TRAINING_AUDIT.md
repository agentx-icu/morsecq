[简体中文](./LEARNING_TRAINING_AUDIT.zh-CN.md)

# Learning and training audit — 2026-10-09

The audit covered every learning, training and recording-practice entry in the app: reachability, finishing and leaving, score attribution, assistance marking, retry after a failed save, reopening and clearing learning data. Each problem was first reproduced by a failing test, then fixed and kept as a regression.

## Coverage by item

| Learning / training item | Flow and credit | Persistence and interruption |
| --- | --- | --- |
| First / repeated introduction | Worked example, 6 K/M multiple-choice recognition trials, result and next step; choice trials are assisted and neither unlock lessons nor create independent SRS evidence | Introduction completion time and result are saved; a failed preview does not reveal "heard"; the lesson can be repeated |
| Koch lesson challenge | Full budget and new-symbol coverage; only a pass advances; only passing the last lesson marks the course complete | Lesson position, result, per-symbol stats, confusions and SRS are saved together; replays and blank answers cannot unlock |
| Guided recognition / copying | 10 characters one at a time, 15 characters in groups of three and 20 in groups of five; guidance advances on recent same-speed new-symbol evidence and never advances Koch | The exact guided level is saved; a started exercise does not change with the default speed |
| All 10 receive drills | Groups, characters, words, abbreviations, numbers, callsigns, confusable pairs, QSO lines, contest exchanges and review; the menu offers what the learned symbols allow | Completion, results, same-ID retry de-duplication and JSON reopening have widget regressions for each kind |
| SRS review / targeted practice | Fills from the learned set when too few cards are due; weak-item practice is available from results; only that practice is credited | SRS cards, confusions and history are restored; the leave confirmation keeps the current screen or discards the unfinished exercise |
| Simulated channel | Clear, Light, Radio; non-clear channels save the full seed, speed, pitch and channel parameters | Activity credit only; never pollutes clear-copy stats, SRS or the course; missing audio or failed playback blocks submission; leaving and backgrounding stop playback |
| Placement assessment | Koch-tiered test, early finish, recommendation and explicit adoption; never changes the lesson automatically or provides SRS or speed-up evidence | Only rounds actually answered are saved; blanks earn nothing; phone backgrounding stops audio; failed saves retry idempotently |
| Sending / guided sending / targeted rhythm practice | Straight key, double key, iambic A/B and physical keys; K→M→KM→KMKMK guidance; listening to the model is unscored; only keyed sending is submitted | Target, speed, raw marks/gaps, diagnostic details and history are saved; an interrupted key press does not create an unfinished mark; result retries do not double count |
| Simulated QSO / protocol | Short exchange, answering CQ, calling CQ, contest and POTA; corrections, field repeats, AGN, QRS and semantic scores | Station, state, pending text, submission ID, typed assistance and completion date are saved; trailing characters survive leaving, backgrounding and switching input; a finished result is parked before submission, recoverable and de-duplicated |
| Chinese telegraph code | Mainland / Taiwan codebooks; four-digit copying, character→code and code→character recall; full 10-card recall flow | Copying saves the codebook; recall statistics are stored separately; repeated retry taps after a failure count once and never change Koch |
| Custom materials | Text, word lists, callsigns; preview, TXT/JSON import, duplicate-ID handling, learned/all modes, JSON/TXT/WAV export | Original text and normalized entries are saved; editing does not change a started drill or old mistake snapshots; cancel stores nothing; JSON limits are symmetric and never produce a file that cannot be imported again |
| Recording workbench / recording library | Decode, blind copy, answer reveal, tuning, segment playback and saving; decoded answers hidden by default | Segment, title, note and safe relative media path are saved; answer exposure does not become independent again after retuning; a new recording does not inherit old answers; quitting closes a late reader; missing media can be relinked |
| Whole-word / sentence comprehension | Words, phrases, QSO details, POTA details and stories; semantic fields answered after full audio | Original exercise, questions, answers, speed, assistance and plan binding are saved; replay/reveal/unlearned previews exclude independent evidence; character-copy stats are not written |
| Mistake notebook | Retries at the original content, speed and channel; blank answers are recorded too; repeated failure, assistance and duplicate-submission rules are tested | Target, original answer, latest answer, failure count and semantic snapshot are saved; recovery needs independent correct retries on two different days |
| Goal routes / daily plan | First QSO, conversation, contest; next step from recent independent accuracy, speed and sample size; direct entry into the matching practice | Goal and frozen plan are saved; switching keeps finished and active steps; expired and future evidence is excluded; a failed goal save retries when the goal is chosen again |
| Statistics / settings / lifecycle | Comprehension activity shows counts, active days and streaks; guided sending feeds the sending curve; semantic scores stay out of character accuracy | Training settings, progress and documents save serially; a healthy store survives another store's read failure; backgrounding and quitting await the flush; clearing retires the controller before deleting training and media |

## Fixes in this audit

| Reproduced problem | Fix and regression evidence |
| --- | --- |
| A receive drill could build independent evidence without audible audio; a later mark error escaped the timer | One timeline output check and error event; failure blocks grading and can be retried. `audit_receive_paths_test.dart`, `listening_audio_failure_test.dart` |
| Assessment kept playing in the background; a failed save gave no feedback | Stop on backgrounding and return to manual replay; uses the existing save-failure message and retry. `audit_receive_paths_test.dart`, `audit_placement_recovery_test.dart` |
| A QSO's last released character was lost if saved before its character gap elapsed | The snapshot includes the decoded character of the pending pattern while the live decoder keeps accepting input. `audit_send_telegraph_qso_flow_test.dart` |
| A duplicate QSO submission in the same frame appended an empty reply to the next stage | Submission checks remote playback, completion state and non-empty input, blocking stale button callbacks. `audit_send_telegraph_qso_flow_test.dart` |
| Rapid retries after a failed Chinese recall save double counted; tapping Next twice skipped an unanswered card | A saving/saved single-run guard; Next checks the answered and finished state. `audit_send_telegraph_qso_flow_test.dart` |
| Retuning or trimming lost the answer-exposure mark; a new recording of the same length inherited old answers | The mark is bound to the recording identity and exposure range, and showing answers is separated from overlapping-range assistance; the working slot gets a new identity on each successful import. A target revealed on the first result page affects later attempts. `workbench_audit_regression_test.dart`, `audit_workbench_selection_review_test.dart` |
| Quitting while a recording was imported or opened installed and leaked a late reader | Disposal is checked after each asynchronous return and before the final install, and the reader is closed. `workbench_audit_regression_test.dart` |
| Material JSON could bypass entry / empty-item limits; an oversized library export could not be imported again | Import validates inner entries; export reuses the format limits, fails clearly when over them and keeps the original library. `material_audit_regression_test.dart`, `materials_audit_regression_test.dart` |
| A quick edit could be saved before the preview of the new content updated | Saving waits for the latest preview. `materials_audit_regression_test.dart` |
| Choosing the same goal again after a failed goal save did not retry | The goal is submitted again and unstarted plan steps are refreshed. `learning_persistence_audit_test.dart` |
| A finished QSO left only as `.json.bak` after an interrupted file replacement could not be found | Document listing includes backups and de-duplicates; recovery removes all companion files. `learning_persistence_audit_test.dart` |
| A settings read failure discarded healthy progress, and a progress failure discarded healthy settings | Each is read separately and usable state is kept. `learning_persistence_audit_test.dart` |
| A successful save of another document masked an unresolved save failure | Write errors are kept per document name and cleared only by a successful save or explicit delete of the same document; flush no longer under-reports. `learning_persistence_audit_test.dart` |
| Comprehension-only practice left statistics empty and missed active days; guided sending was counted on the copying curve | Activity statistics include comprehension records while semantic and character scores stay separate; sending is identified by source. `learning_stats_audit_test.dart` |

## Verification

A new [real-file reopen and clear test for every record type](../../apps/morsecq/test/training/learning_records_reopen_test.dart) drives the public controller through every receive kind, simulated channels, each guided level, the course, materials, copying and recall for both codebooks, and sending. It saves details, stations, QSO drafts, five kinds of comprehension records, mistakes, goals, plans, settings and recording materials, compares each item after reopening the files, and confirms that clearing removes training, documents and media.

One command runs everything:

```sh
bash tool/test_pyramid.sh --level all --device macos
```

On 2026-10-09 the full pyramid ran on a local Mac: all seven analyzer checks plus the complexity, import (layering) and UI-literal (localization) guards passed; 690 package tests passed; 5 native macOS test files with 7 tests passed, including complete English and Chinese first-day learning and all 12 scenes in each language (24 screenshots). After the final fixes, all gates and the complete application regression ran again: 908 passed and 2 opt-in visual renders were skipped; the native macOS advanced-learning test was rebuilt and passed, confirming real audio, the mistake notebook and goal recovery after reopening.

The PR native regression splits the advanced flow in two: test audio that records the real timeline verifies the full UI and file reopening, and a real device separately verifies either complete playback or an explicit audio failure. Audio initialization and playback both wait for observable state; an animation ending is never taken as device readiness. Without a device, answers and submission must stay hidden with zero comprehension records and zero mistakes; visual feedback never substitutes for comprehension evidence. Both passed locally; CI can verify the blocked-grading path on hosts without an audio device.

## Current boundaries

- Unfinished ordinary copy/send input and material edit drafts are session state, discarded after the leave confirmation; QSO drafts resume across sessions.
- Chinese telegraph code offers digit copying and two-way code recall; there is no dedicated Chinese telegraph sending drill.
- Sending rhythm details are persisted and visible on the current result page; there is no screen yet to reopen or bookmark details across sessions, although the underlying detail and bookmark APIs are tested.
- Material `version=1` is the file-format version; there is no revision history or undo. Started drills and mistakes keep snapshots of the original content.
- A recording segment is saved as audio material and does not generate text training material. A shared JSON library is limited to 1 MiB; an oversized export fails clearly.
- Native verification in this audit ran on macOS; other platforms rely on existing cross-platform code and tests and were not re-tested on Android, iOS, Windows or Linux hardware. USB/BLE keys, microphone capture and real device unplugging were not hardware-tested; their screens use test doubles, while real files and DSP are verified separately. Atomic writes and backup recovery tests do not prove power-loss durability.
