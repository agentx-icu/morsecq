> Historical pre-split document. Current MorseCQ is the offline trainer described in [README](../../README.md); chat belongs to DitMesh.

[简体中文](./2026-10-03-functional-improvements.zh-CN.md)

# MorseCQ Functional Improvements: Specification and AI Implementation Handoff

> Date: 2026-10-03. Inspected code baseline: `bae1d5e`.
> Status: **implemented (M0–M8), 2026-10-03**, branch `agentx/functional-improvements`; see §17 Implementation record. The sections below remain the specification.
> The Chinese document is the original. Both versions must retain the same scope, default parameters, and acceptance criteria.
> For the implementing AI: deliver by milestone, inspect the current code first, and preserve existing behavior and user data.

## 1. Goal and scope

Connect MorseCQ's promise of learning Morse and chatting with Morse into a complete journey: try it → practice specific weaknesses → understand contacts → communicate with people → learn from those conversations.

This specification covers eight features. Product priority is below; development dependencies are in §13.

| ID | Feature | Priority | User outcome |
|---|---|---|---|
| F01 | Daily training plans and speed recommendations | High | Know what to practice today, why, and what to do next |
| F02 | Interactive QSO simulator | High | Practice turn-taking, information exchange, and repeat requests alone |
| F03 | Chat-to-learning integration | High | Turn received messages into scored exercises and review material |
| F04 | Sending rhythm replay and targeted practice | Medium | See and hear specific timing problems, then correct them |
| F05 | First-use guest experience and placement assessment | Medium | Try learning immediately; experienced users get a suggested starting point |
| F06 | Custom training materials and audio export | Medium | Practice personal texts, callsigns, and word lists; listen offline |
| F07 | Message search, bookmarks, retry, and pending-send cancellation | Medium | Manage history, important messages, and failed sends |
| F08 | Recorded-audio copying workbench | Later | Import recordings, loop selections, decode, and check personal copies |

Recommended implementation: local, offline, rule-based. Core features do not depend on generative AI, account servers, cloud sync, or subscriptions.

Thresholds below are initial product defaults, not research-validated learning conclusions. Centralize them and adjust after real use. A recommendation is not a proficiency certification.

## 2. Current implementation and capabilities to preserve

### 2.1 Existing capabilities: reuse them

- Koch lessons, Farnsworth spacing, ten receive-drill types, weakness weighting, spaced review, confusion matrices, daily symbol goals, and statistics.
- Sending through an on-screen straight key, paddles, or desktop keyboard; symbol alignment, measured speed, and written rhythm diagnostics.
- Current QSO drills generate templated copying text; they do not advance a conversation based on user responses.
- Chat training mode currently hides received plaintext but still displays dots/dashes. Manual reveal, playback, and autoplay exist.
- Direct/group chat, the local note-to-self conversation, paginated history, drafts, pinning, durable offline queues, and restored send status.
- Conversation-list search already exists. F07 adds searching historical message bodies.
- Live microphone decoding already provides levels, tone lock, tuning, and decoded text. The recorded-file workbench specified here is new.
- Identity backups already include the training directory. Training backup is not a new feature.
- Ten UI languages, five visual styles, light/dark modes, and responsive mobile/desktop layouts.

### 2.2 Product constraints to preserve

1. Outgoing chat remains Morse-keyed only. A training answer control does not restore a chat text composer.
2. Wire messages remain ordinary text compatible with other Tim2Tox clients. New learning metadata stays local.
3. Note-to-self never sends over the network and cannot be deleted. Existing clear-history rules remain.
4. Mobile and desktop support touch/mouse keying; environments with a hardware keyboard also retain keyboard keying.
5. Training and materials work offline. Chat remains subject to Tox P2P connectivity and mobile background limitations.
6. Simultaneously online accounts, server push, voice/video, and transmission of actual keying rhythm are out of scope.
7. F05 explicitly changes a product decision: only when that feature ships does “identity required before training” become “guest training uses an independent local profile.” Other milestones must not loosen the startup gate early.

### 2.3 Reading and code map

| Concern | Existing entry points |
|---|---|
| Product and scope | `README.md`; `doc/plans/2026-09-30-morsecq-plan.md` |
| Course, SRS, scoring | `packages/morse_trainer/lib/src/{koch_course,srs_scheduler,session_score,trainer_progress,session_summary,char_weights}.dart` |
| QSO templates | `packages/morse_trainer/lib/src/qso_drill.dart` |
| Training orchestration/storage | `apps/morsecq/lib/training/{training_controller,training_controller_host,file_trainer_store,training_settings_store}.dart` |
| Learning UI | `apps/morsecq/lib/ui/learn/`; `apps/morsecq/lib/ui/stats/` |
| Sending measurements/diagnostics | `apps/morsecq/lib/training/send_session.dart`; `packages/morse_trainer/lib/src/send_practice.dart` |
| Startup/identity | `apps/morsecq/lib/startup/`; `apps/morsecq/lib/ui/account/`; `packages/morsecq_chat/lib/src/identity/` |
| Chat contract | `packages/morsecq_chat_api/lib/src/{chat_service,models}.dart` |
| Chat transport/UI | `packages/morsecq_chat/lib/src/chat/`; `apps/morsecq/lib/ui/chat/` |
| Decoding/audio | `packages/morse_dsp/lib/src/audio_morse_decoder.dart`; `packages/morse_io/lib/src/player.dart`; `apps/morsecq/lib/ui/listen/` |
| Validation/data protection | `doc/testing/TEST_PYRAMID.md`; `doc/testing/PERSISTENCE_AUDIT.md`; `doc/plans/2026-10-03-learn-review.md` |

Braces indicate multiple existing files in the same directory. Paths and types labeled “new candidates” below do not exist yet. They may be split to match repository conventions, while preserving responsibilities and acceptance criteria.

## 3. Shared architecture, data, and statistics

### 3.1 Responsibilities

```text
Flutter UI → app controllers and storage
                 ├─ morse_trainer: Morse tokenization, plans, assessments, QSO states, materials, scoring
                 ├─ morse_core: alphabet, encoding, timing, key decoding
                 ├─ morse_io: playback, keying, audio-file output
                 ├─ morse_dsp: chunked PCM decoding and audio-time positioning
                 └─ morsecq_chat_api → morsecq_chat → Tim2Tox
```

- Pure Dart packages do not import Flutter, platform file pickers, or chat SDKs.
- Only `morsecq_chat` touches Tim2Tox/Tencent SDKs. UI uses contracts rather than editing queue files.
- Retain existing provider wiring, audio leases, profile isolation, and durability barriers.
- Inject parameters, clocks, and randomness. Fixed inputs must produce replayable plans and simulations.

### 3.2 Shared exercise records

Existing `SessionSummary` stores time, symbol/correct counts, lesson, kind, and elapsed time. It cannot reliably compare different speeds or retain assistance conditions. Add backwards-compatible exercise metadata, provisionally named `ExerciseRecord`:

| Field | Requirement |
|---|---|
| `id`, `schemaVersion` | Stable ID per attempt; persistence retry retains it; practicing again creates another ID |
| `profileKey`, `source` | Local profile identifier; course/review/plan/QSO/chat/material/placement/send/recording source |
| `kind`, `startedAt`, `finishedAt` | Exercise type and recoverable timestamps; daily goals use the user's local calendar |
| `characterWpm`, `effectiveWpm`, `toneHz` | Actual character speed, spacing-derived effective speed, and tone; unknown is null, not a fake measured zero |
| `expectedSymbols`, `correctSymbols`, `insertions` | Existing tokenizer/alignment semantics; one prosign is one symbol; whitespace is not a mastered symbol |
| `strictAccuracy` | Reuse strict scoring; extra typed symbols must not improve a result |
| `perCharStats`, `confusion` | Per-attempt summaries support recent windows; lifetime totals alone must not decide speed changes |
| `activeDurationMs` | Exclude pause/background/idle waiting; do not relabel legacy wall-clock elapsed time as active time |
| `completed`, `assistance` | Track completion, abandonment, replay, reveal, hints, and assisted decoding |
| `planStepId`, `sourceRef` | Optional origin references; do not duplicate complete chat bodies or recordings into statistics |
| `detailRef` | Optional rhythm/audio detail; missing detail must not prevent loading course progress |

This is a data contract, not a requirement to put everything into one class. Extend existing summaries and store details only when needed; avoid a second contradictory set of totals.

### 3.3 Credit and unlock policy

| Source/condition | Activity/daily goal | Weakness/SRS | Automatic Koch unlock | Speed recommendation sample |
|---|---|---|---|---|
| Unassisted course copying meeting current course rules | Yes | Yes | Existing rules | Yes |
| Unassisted review, focused drills, supported material/chat copying | Yes | Only learned symbols actually answered | No | Comparable kind/speed and sufficient samples |
| Revealed, hinted, or replayed practice | Yes, marked assisted | No by default; a new unassisted attempt may update it | No | No |
| Sending practice | Yes | Separate sending metrics, not receive statistics | No | Not part of receive-speed advice |
| QSO semantics, placement, assisted recording decoding | Separate record; meaningful completed answers can count toward activity | No by default | No | No |
| Playback only, no answer, or an empty unfinished session | Draft allowed | No | No | No |

This policy applies to new flows. Existing replay/reveal conditions become evaluable only after implementing assistance tracking; do not infer them from old history.

Unknown-to-the-course chat symbols may be freely practiced but do not enter learned-symbol SRS. Decoder output is not the user's copy. Replays do not add credit. Recording an exercise and completing a plan step must not each add a session.

### 3.4 Persistence and migration

- Continue reading old progress, settings, and backups. Default new fields and explicitly handle versions; do not invent old speed/active-time/assistance data.
- Save exercise records, one-time counters, and plan completion through one authoritative progress commit, or a recoverable commit log. Multiple file writes are not automatically atomic.
- Repeated submission of one `id` must not add credit, including after restart. History trimming preserves deduplication data for unfinished commits; new practice uses a new ID.
- Write details before committing references. Details may be deleted while summaries remain; clean orphan files only without in-flight writes.
- Reuse atomic JSON, serialized writes, valid `.bak` fallback, profile generation guards, and `flush`.
- A save failure still displays the result and a retry action. Retry persists that result rather than rescoring or adding credit.
- Suggested limit: recent 500 detailed exercise summaries per profile, matching existing history retention. Lifetime totals never fall with trimming. Additional detail cache defaults to 20 MiB; explicitly manage saved favorites.
- Put new learning data under the identity training directory so existing backups include it. F07 chat history/queues do not thereby become part of identity backups; do not promise full chat backups.

## 4. F01: Daily plans and speed recommendations

### 4.1 User flow

Add “Today's plan” to Learn: estimated duration, steps, reasons, completion state, and Start/Continue. Keep free practice and the current daily symbol goal.

Each completed step shows its result and next step. The complete plan reports progress, 1–3 symbols needing work, and a next-round/tomorrow recommendation.

Offer 5-, 10-, and 15-minute budgets. Budgets guide the plan; never stop in the middle of a symbol or held key.

### 4.2 Generation rules

1. Inputs: lesson, learned symbols, due SRS, recent weaknesses/confusions, settings, budget, local date, and completed steps.
2. Prioritize due review, then confusions with sufficient evidence, then course consolidation, then short sending practice.
3. Suggested 10-minute allocation: review 3, focused practice 2, course 3, sending 2 minutes.
4. Redistribute unavailable categories to available ones; do not create empty steps. Use existing drill fallbacks when fewer than two appropriate symbols exist.
5. Beginners practice the current lesson. Focused pools contain learned symbols only. Plan generation never skips lessons.
6. Freeze content, speeds, and seed when a plan starts. Completion does not regenerate it. Explicit rearrangement affects only unstarted steps.
7. A new local date creates a new plan. Yesterday's unfinished plan can be inspected or continued as free practice; it must not be credited as completing today's new plan.
8. Lesson/speed changes flag unstarted steps for update. An active step retains its snapshot; validate profile ownership before starting.

Course steps retain their original lesson. If an earlier step advanced the course, later steps targeting that old lesson become consolidation without advancing the new lesson; old questions cannot unlock a new lesson.

Course steps still need the course minimum (currently 50 symbols) for unlocking. For insufficient time, make the step consolidation without unlock eligibility, or extend its estimate with an explanation. Do not label an impossible-to-pass short drill as a course challenge.

### 4.3 Initial speed algorithm

- Compare completed, unassisted exercises from the past 14 days with identical kind, character speed, and effective speed; take the latest five.
- Require at least three attempts, each with at least 50 target symbols. Otherwise report insufficient evidence without proposing an increase.
- Weighted strict accuracy ≥95%, each attempt ≥90%: recommend +1 effective WPM.
- Latest three attempts all <80%: recommend −1 effective WPM or focused practice; never change settings automatically.
- Effective speed cannot exceed character speed. Once equal, recommend increasing both by 1 WPM.
- Respect current bounds: character 10–40 WPM, effective at least 5 WPM. Persist only after Apply recommendation.
- Recommend once per evidence batch. Do not combine new symbols and higher speed in one plan. A reduction is advice, not a penalty.
- Exclude sending, semantic QSO scores, placement, and legacy records with unknown assistance.

### 4.4 Data, files, acceptance

New candidates: `packages/morse_trainer/lib/src/daily_plan.dart`, `daily_plan_builder.dart`, `speed_recommendation.dart`; `apps/morsecq/lib/training/daily_plan_controller.dart`; `apps/morsecq/lib/ui/learn/plan/`.

Modify `training_controller.dart`, `learn_home.dart`, summary/progress serialization, and statistics. A pure Dart generator owns decisions; UI displays and executes them.

Plan: `id/date/profileKey/seed/settingsSnapshot/steps`. Step: stable ID, kind, symbol pool, budget, unlock eligibility, state, result reference, and localizable reason code.

Acceptance: deterministic inputs/results; every question answerable using the available keypad; no empty review; restart resumes the same plan; repeated completion adds no credit; local-day/DST correctness; sufficient high scores required for speed advice; settings unchanged before Apply; short budgets preserve unlock rules.

## 5. F02: Interactive QSO simulator

### 5.1 Initial scope

Provide “Respond to CQ” and “Call CQ.” Use a local state machine and controlled templates for callsigns, RST, name, QTH, repeat requests, and closing. Pileups, unrestricted conversation, and noisy channels are later work.

Use the current `qsoFromLesson` threshold (currently 30). Explain prerequisites earlier. Placement may suggest a starting point but cannot bypass the gate before the user selects a lesson.

### 5.2 Flow and state

```text
Configure → remote CQ / await user CQ → callsign confirmation → RST/name/QTH
          → information confirmation → 73/<SK> closing → summary
At relevant stages: pause, request repeat, view a hint, or leave.
```

- User sends via existing straight key/paddles and keyboard keying; decoded text is explicitly submitted. A pause in keying is not automatic sentence submission.
- Remote replies use complete text snapshots played with the user's settings. Pause/background stops playback; resume is user-driven.
- Callsigns, names, QTH, and RST remain consistent within a seeded session.
- `AGN`/`PSE AGN` repeat the current remote information without advancing. `QRS` lowers subsequent effective playback speed by 1 WPM, respecting the minimum.
- Process each submission ID once; double taps/rebuilds cannot create another remote turn.
- Invalid answers retain the stage and identify missing information. After three consecutive errors, offer more specific hints without answering automatically.

### 5.3 Semantic evaluation

Evaluate whether the stage's exchange succeeded, not whether text exactly matches one template.

- Reuse Morse tokenization, case/whitespace normalization, and target-specific prosign alias handling; preserve punctuation/prosign distinctions.
- Callsign confirmation requires configured callsigns and a sensible `DE` relationship. Missing/wrong remote callsigns fail.
- Accept ordinary RST and defined cut-number forms such as `5NN`; substitute only within the RST slot, not every N/T in ordinary words.
- Names/QTH use controlled vocabularies and listed variants such as `NAME IS`/`NAME`, `QTH IS`/`QTH`. Do not claim unrestricted language understanding.
- Closing accepts scenario-defined forms such as `73` and `<SK>`. Repeat/slow-down requests are separate intents recognized first.
- Ship valid/invalid examples and an allowed-variants table for each scenario rather than leaving protocol interpretation to guesswork.

Example: remote `K1ABC`, local `BD1XYZ`. Accept `K1ABC DE BD1XYZ K`; report the wrong remote callsign for `K1ABD DE BD1XYZ K`; `PSE AGN` repeats without leaving the stage.

Initial evaluation validates slots; extra courtesy abbreviations do not invalidate correct fields. Do not rely on substring presence. Minimum accepted forms:

| Stage/intent | Accepted form | Rejection/distinction |
|---|---|---|
| Call CQ | At least one `CQ`, `DE {LOCAL}`, optionally repeat local call, end in `K` | Missing DE/local call or wrong local call |
| Confirm calls | `{REMOTE} DE {LOCAL}`, ending `K` or `KN` | Reversed roles or substring-only matches |
| Send report | `UR RST {RST}` or `RST {RST}`, optional report repetition | Validate using current RST tool bounds; interpret cut numbers only in this slot |
| Name/QTH | `NAME [IS] {LOCAL_NAME}`, `QTH [IS] {LOCAL_QTH}` | Must match this session; remote name/QTH cannot stand in for local values |
| Repeat | `AGN` or `PSE AGN`, optional final `?` | Repeat previous information, not a field answer or closing |
| Slow down | `QRS` or `PSE QRS` | Adjust speed without advancing information exchange |
| Close | `73` plus `<SK>`, optionally callsigns, `TU`, `CUL` | `K` alone is not closing; prosign aliases follow target-context rules |

Summaries separate flow completion, field correctness, repeat count, hints, and sending rhythm. Semantic scores are not copying accuracy and do not unlock Koch lessons.

### 5.4 Data, files, acceptance

New candidates: `packages/morse_trainer/lib/src/qso/{qso_scenario,qso_session,qso_intent,qso_evaluator}.dart`; `apps/morsecq/lib/ui/learn/qso/`.

Retain templated copying in `qso_drill.dart`. Add `QsoSession` with `scenarioId/version/seed/roles/state/turns/assistance`. Restore incomplete text/state, never a held key or active playback.

Acceptance: complete both scenarios; valid variants pass and wrong callsigns fail; AGN preserves state and QRS respects limits; duplicate submit produces one reply; mobile/desktop input works; complete offline; no added wire messages or protocol changes.

## 6. F03: Chat-to-learning integration

### 6.1 Entry points and modes

Keep existing Hide plaintext. Add an independent Listen-only training option that hides both plaintext and dots/dashes until explicit reveal.

Received messages offer Practice this message and Save as training material. Open a separate training page; answers must not overwrite drafts or reach the peer.

### 6.2 Copying flow

1. Freeze the selected message, playback settings, and source reference. Stop conversation autoplay and remember its user setting.
2. Answer with existing learning answer controls. Initial sequence: listen → answer → submit → view alignment.
3. Allow replay, per-symbol hints, and full reveal, tracking assistance. Revealing cannot later make the same attempt unassisted.
4. Show strict accuracy, insertions/omissions/confusions; Practice errors generates focused drills for learned symbols.
5. Release the audio lease on exit. Restore autoplay settings only if the original conversation is visible, profile matches, and the user has not changed the toggle. Do not replay the backlog accumulated during practice.

Ordinary chat never forces an answer. Notifications/previews retain current privacy settings. If training-answer privacy is added, hide answers from previews and accessibility as well as visual text.

### 6.3 Content and data boundaries

- Validate through `MorseText`/`MorseAlphabet`. Explain unsupported characters; first generate user-confirmed trainable text rather than silently removing content.
- Unlearned symbols remain answerable but do not unlock or enter learned SRS. Keypads cover every supported symbol in the question.
- Viewing, playback, and reveal alone do not complete an exercise. Apply §3 credit rules after answers.
- Reference source locally with `profileKey/conversationId/messageId`. Do not change `ChatService.sendText` or wire data.
- Saving material creates an independent local text snapshot using F06's material contract. Clearing history must explain any deliberately saved copies and provide deletion access.
- Initial scope is selected-message practice. Automatic bulk harvesting of chat content is excluded.

### 6.4 Files and acceptance

New candidates: `apps/morsecq/lib/training/chat_copy_session.dart`; `apps/morsecq/lib/ui/learn/chat_copy/`. Modify `message_bubble.dart`, `conversation_actions.dart`, `conversation_screen.dart`; reuse answer/alignment components.

Acceptance: no visual/accessibility answer leak in listen-only mode; no outbound answer or overwritten draft; assisted attempts do not unlock/recommend speed; unknown-to-course symbols remain answerable; save retry is idempotent; exit/profile switch releases playback correctly; saved materials remain manageable after original-message deletion.

## 7. F04: Sending rhythm replay and focused practice

### 7.1 User flow

Add My rhythm and Standard rhythm timelines to sending results. Position/length show marks; whitespace shows gaps; problematic elements have text and color indicators.

Select a symbol/region to replay actual timing, hear the standard, and Practice this part. Mobile defaults to symbol cards; desktop may show a word. Offer zoom/scroll instead of shrinking everything to fit.

### 7.2 Diagnostic rules

- Reuse measured `SendSession.marks/gaps`. Local replay stores key timing, not microphone recordings.
- Generate standards with `MorseTiming`. Distinguish target-speed comparison from diagnosis normalized to estimated dit length; label this clearly.
- Keep current diagnostics and add overly long dahs. Centralize thresholds and adjust through tests/use.
- Character/word gaps respect target Farnsworth timing; do not flag valid extended gaps using ordinary 3/7-dit rules.
- Actual replay retains measured durations. Optional speed changes are labeled and never replace raw data.
- If alignment is uncertain, report that localization to one symbol failed and permit segment practice rather than forcing all subsequent marks onto wrong symbols.
- Prioritize this attempt's problematic symbols. Offer a standard example and three new attempts. Playback does not count as another attempt.

### 7.3 Data, files, acceptance

New candidates: `packages/morse_trainer/lib/src/send_timeline.dart`; `apps/morsecq/lib/ui/learn/send/send_timeline_view.dart`; `apps/morsecq/lib/training/send_detail_store.dart`.

Modify `send_session.dart`, `send_practice.dart`, `send_result_view.dart`, `send_tips.dart`. Store target, target speed, monotonic relative times, mark/gap arrays, alignment, and diagnostic version. Follow §3 summary/detail persistence.

Acceptance: exact ordering/durations on repeated replay; clean sending not misdiagnosed; deliberately long dah identified; valid Farnsworth gaps accepted; cancelled held keys/focus/background add no phantom marks; existing prosign aliases preserved; 20 MiB detail trimming does not delete summaries or saved favorites.

## 8. F05: Guest experience and placement

### 8.1 Guest profile

Add Try learning first to Welcome. Enable Learn, Reference, Translator, and local tools; Chat/Groups offer identity create/restore. Guest use creates no Tox identity, makes no connection calls, and never disguises the in-memory fake as real chat.

Store guest data separately, provisionally `<support>/morsecq/guest/training/`. Keep it across restart; allow clearing it.

Guest use with an existing encrypted identity must not read, decrypt, or overwrite that identity. Guest access is not an unlock bypass.

### 8.2 Profile abstraction and migration

Introduce local `LearningProfile`: at least `guest` or `identity(publicKey)`. Share controllers per learning profile; chat still requires a real identity.

When creating a new identity from guest use, transfer progress, settings, materials, and detailed records by default: freeze/flush the old controller → stage target data → validate → commit → switch controllers → mark migration completed. Failure preserves usable guest data; retry does not add credit twice.

Restoring an existing backup must not silently combine guest scores. Default to the restored profile and retain guest data separately. Users may choose guest progress instead; initial scope does not automatically merge SRS, lessons, or lifetime totals. If identity creation succeeds but migration fails, clearly distinguish the created identity from unmigrated learning data and offer retry.

### 8.3 Placement assessment

- Offer Start from zero and Check my current level. Skippable; sending is not a prerequisite.
- Receive tiers cover the current Koch order in groups (letters, numbers/punctuation), then short words. Each tier has at least 20 symbols; each symbol being verified appears at least twice. Character speed defaults to 20 WPM; effective tiers are 5, 8, 12, 16, 20 WPM.
- First three tiers use Koch symbols 1–10, 11–20, and 21–30 twice each. Tier four tests the remaining symbols twice (26 with the current 43-symbol order). Tier five uses at least 20 symbols of short words. Pools are fixed, shuffled by seed; future course-order changes derive pools from the actual list rather than hard-coded symbols.
- Advance at strict accuracy ≥90%; otherwise stop. Unknown symbols diagnose coverage rather than count as course failure.
- Suggest the earliest unmastered lesson using the continuously verified Koch prefix. Verification requires at least two unassisted correct copies and no incorrect copy of that symbol. Isolated advanced successes cannot skip untested/weak prerequisites. Map through `KochCourse.charsForLesson`, not symbol index as lesson number.
- Untested symbols stay unknown. Suggest a start rather than awarding unlocks or SRS mastery.
- Apply the starting lesson only after explicit Adopt starting point using existing lesson selection; retain the option to start at lesson one. Placement results are excluded from speed advice.
- This is approximately 3–5 minutes of rough placement; communicate sample limitations. Optional sending introduces controls and rhythm feedback only.

### 8.4 Files and acceptance

New candidates: `packages/morse_trainer/lib/src/placement_assessment.dart`; `apps/morsecq/lib/training/learning_profile.dart`, `learning_profile_host.dart`, `guest_migration.dart`; `apps/morsecq/lib/ui/learn/placement/`.

Change `startup_gate.dart`, `startup_controller.dart`, `welcome_page.dart`, `training_controller_host.dart`, `learn_scope.dart`, DI, and backup barriers. Update the main plan and `CLAUDE.md` identity requirement at this milestone, not just the welcome UI.

Acceptance: fresh guest practice persists after restart without an identity; no accidental chat connections; encrypted identity protection remains; failed migration recovers and retries idempotently; restored backups do not silently add guest scores; no lesson change before adoption; late guest/identity writes cannot overwrite each other.

## 9. F06: Custom materials and audio export

### 9.1 Materials and entry points

Add My materials to Learn: create/edit text, import UTF-8 `.txt`, import/export versioned JSON. Include title, tags, text/word-list/callsign kind, favorites, search, and origin description.

Text trains in segments. Word lists contain line-based entries and can sample randomly. Callsign material validates supported symbols without claiming callsign existence.

Defaults: import ≤1 MiB, ≤1000 entries, ≤200 Morse symbols per entry. Segment long text and preview it. Reject limits explicitly; never report complete success after partial import.

### 9.2 Content, training, export

- Preview counts, segmentation, unsupported characters, prosigns, and duplicate entries; commit after confirmation.
- Keep original and normalized text separately. Follow engine normalization; never silently drop Chinese characters or replace accented letters with other letters.
- Offer learned-symbol-only or all-supported-symbol practice. Mark incompatible entries unavailable with reasons in learned-only mode.
- Reuse receive/send sessions and scoring. No course unlock by default; unassisted learned-symbol copying updates weaknesses/SRS under §3.
- Initial audio export: PCM WAV, 16-bit mono, 48 kHz, chosen character/effective speed and tone. Cross-platform MP3 encoding is not required first.
- Export complete selected text, ≤10 minutes per output; split longer materials into explicit segments. Sanitize filenames; failures must not leave zero-byte files reported as successful.
- Optionally include answer text/settings; choose answer inclusion before sharing. Material JSON contains neither chat sender identity nor Tox private keys.
- Initial scope does not scrape, bundle, or redistribute third-party copyrighted material. Users import their own; public resources are links.

### 9.3 Data, files, acceptance

Suggested `TrainingMaterial`: `id/version/title/kind/originalText/normalizedItems/tags/favorite/source/createdAt/updatedAt`. `source` is an optional description/local reference. Shared exports remove private references by default.

New candidates: `packages/morse_trainer/lib/src/material/{training_material,material_drill,material_import}.dart`; `packages/morse_io/lib/src/wav_export.dart`; `apps/morsecq/lib/training/material_store.dart`; `apps/morsecq/lib/ui/learn/materials/`.

Acceptance: TXT/JSON round trips preserve entries; invalid import leaves the library intact; preview explains unsupported symbols; duplicate IDs offer overwrite/keep-copy rules; backups restore materials; exported WAV plays in an independent player with correct timing and no clicks; cancelled sharing preserves materials; all five platforms have save/share paths.

## 10. F07: Message management

### 10.1 Body search and bookmarks

- Search historical bodies within a conversation, with case-insensitive matching and sender/date filters. Include time, context, and jump-to-message; search is not limited to the loaded 50 rows.
- Define ordering: latest first by default, with time and message ID as tie-breakers. Stable pagination cannot lose same-timestamp messages.
- Expose through `ChatService`; transport reads persisted history in pages. Scanning/caching is acceptable initially without a mandatory full-text database. Run in background/chunks and support cancellation.
- Local bookmarks reference profile+conversation+message ID. Distinguish them from independent F06 material snapshots: history clearing invalidates/removes bookmarks, while materials remain independently managed.
- Deep jumps load surrounding history while preserving reading continuity. Opening search does not mark all messages read or start autoplay.
- Listen-only training also hides search-result answers until explicit plaintext viewing; accessibility follows the same rule.

### 10.2 Status and operations

| State | Operations | Behavior |
|---|---|---|
| `pending` | Cancel pending send | Only while still locally queued and not handed to transport |
| `failed` | Retry | Reuse the stable local message ID, not another local bubble |
| `sending` | Inspect status | No promise of cancelling content already handed to transport |
| `sent` | Search/bookmark | No recall; local deletion does not delete the peer's copy |
| `received` | Search/bookmark/practice | No send retry |
| New `cancelled` | Inspect cancellation | Keep the local row; never requeue after restart |

Proposed contract extensions: `searchMessages(query, cursor, limit)`, `retryMessage(conversationId, messageId)`, `cancelPendingMessage(conversationId, messageId)`. Return success/state-changed/unavailable/failure explicitly rather than making UI infer queue changes.

### 10.3 Transport consistency and capability investigation

- Current `ChatService` lacks these operations. Tim2Tox has conversation-wide pending replay and persisted item removal; that does not establish safe single-message retry/cancellation.
- Inspect `FfiChatService` send paths, drain, history updates, client ID semantics, and C2C/group paths; write a minimal integration demonstration before exposing operations.
- Cancellation must share serialization/arbitration with autoplay of the queue: cancellation wins while queued; return changed state if transport already claimed it. Removing a persisted item or changing a bubble alone is insufficient.
- If cancellation persistence fails, retain pending and allow retry. Retry failure remains failed. Events, history, and restored queues agree.
- Retry only confirmed failed messages. Unknown delivery outcomes cannot guarantee one receipt on the peer. Stable local IDs are not end-to-end exactly-once delivery.
- If safe arbitration requires upstream capabilities, implement in the separate Tim2Tox repository and update the submodule pin; never edit `third_party/` in place. Search/bookmarks may ship first; cancellation cannot ship as a fake button before transport acceptance.
- Respect C2C/group/self capabilities. Self messages bypass queues and do not show meaningless retry/cancel actions.

### 10.4 Files and acceptance

Change `morsecq_chat_api` contract/models/fakes; chat transport mapping/history/queue adapters; bubbles, history, menus. New candidates: `message_search.dart`, `message_bookmarks.dart`, `apps/morsecq/lib/ui/chat/search/`.

Acceptance: find unloaded history; same-timestamp pages neither lose nor duplicate results; preserve jump position; profile isolation; repeated retry keeps one local row; cancellation/drain races are correct; restart never sends cancelled rows; integrate-test both C2C and groups; distinguish bookmark cleanup from material deletion.

## 11. F08: Recorded-audio copying workbench

### 11.1 Initial formats and limits

Keep live microphone decoding and add Import recording. Initially support RIFF/WAVE PCM16, mono/stereo, 8/16/44.1/48 kHz, parsed from actual headers rather than extension.

Limit both size to 50 MiB and duration to 20 minutes; reject either excess explicitly. MP3/AAC/float WAV are not supported initially. Do not advertise all-audio support; codec adapters can follow separately.

### 11.2 Flow

1. Import and show filename, format, duration, and simplified waveform.
2. Play/pause, select start/end, loop a selection. Mobile has accessible time entry and handles rather than precise dragging alone.
3. Choose automatic/manual tuning, decode selection, show tone, estimated speed, text, and unknown patterns.
4. Switch to Copy it myself, hiding decoder text by default; optionally import/type accompanying answer text and score with existing alignment.
5. Save selections/notes as local audio materials. Never automatically transmit recordings through chat or the network.

### 11.3 Decoding, playback, resources

- Reuse `AudioMorseDecoder`; correctly downmix stereo, supply the actual sample rate, and process time chunks rather than duplicating a whole recording into large arrays.
- Waveforms use downsampled min/max envelopes. Decode in a worker/isolate or controlled chunks while the UI remains responsive; cancellation stops subsequent result updates.
- Validate sizes, chunk boundaries, channels, rates, bit depth, truncation, and overflow. Rejecting an unsupported format leaves existing sessions intact.
- Selection boundaries may cut marks: flag incomplete edge symbols. Decoding may read up to one second of context, but only display in-selection events with the boundary caveat.
- Position events on the original recording's sample clock, never decoding wall-clock time. Changing selection/tuning invalidates old results.
- Tone lock/gating are not statistical confidence probabilities. Keep unknown patterns unknown and allow user correction.
- Retain audio leases between playback and microphone capture. Import requires no microphone permission. Stop on background; resume by user action.
- Copy selected external files into managed storage or obtain explicit durable platform access; a transient URL is not a restart-safe file reference.
- User-saved recordings are not automatically included in identity backup by default. Explain metadata-only backup and offer explicit media inclusion. Missing media offers relink/delete without breaking progress loading.

### 11.4 Files and acceptance

New candidates: `packages/morse_dsp/lib/src/wav_pcm_reader.dart` (pure parser, no picker), `audio_decode_segment.dart`; `apps/morsecq/lib/ui/listen/workbench/`; `apps/morsecq/lib/training/audio_material_store.dart`.

Acceptance: all four rates and mono/stereo decode; feed chunking preserves text/time; known CW fixtures recognized; damaged/truncated/oversized input rejected; cancellation stops updates; no other-segment contamination; imports work without microphone permission; background/audio ownership remains correct; saved selections restore; missing media does not corrupt the entire progress file.

## 12. Global interaction and quality

- Support 320 dp phones, landscape, tablets, and desktop. Large text does not overflow results/buttons/timelines. Touch targets ≥48 dp.
- Put new prose in all ten ARBs using `S`; no English placeholders. User materials, callsigns, and CW protocol text need not be translated.
- VoiceOver/TalkBack can operate new flows; errors are not color-only. Listen-only answers must not leak through semantics.
- Retain permission, focus, calls, background, and device-loss release/recovery policies. Preserve existing flash/other fallbacks when audio output is unavailable.
- Long operations show progress/cancellation. Cancelling sharing/import/practice does not hang or add false credit.
- Data belongs to the active profile. Suspend writes during delete/restore/switch; stale jobs cannot write to the next profile.
- Do not add mandatory leaderboards, streak penalties, public matchmaking, cloud analytics, or another account system.

## 13. Milestones and task breakdown

### 13.1 Recommended delivery sequence

```text
M0: shared records, assistance policy, migrations, minimal material contract
  ├─ M1: F01 daily plans
  ├─ M2: F02 interactive QSO
  └─ M3: F03 chat practice (M0 material contract; full management may follow)
M4: F04 rhythm replay
M5: F05 guest/placement (startup/profile refactor)
M6: F06 material management and WAV export
M7: F07 search/bookmarks → retry/cancel after transport validation
M8: F08 audio workbench (reuse M6 materials)
```

Ship each milestone as a usable feature with regression evidence; do not refactor all training/chat at once. With limited resources, complete M0–M3 first and keep later scope explicitly unimplemented.

### 13.2 Implementing AI task list

| Task | Change/deliverable | First important tests |
|---|---|---|
| T01 | Check baseline, legacy fixtures/gates, available devices | Existing progress/settings/backups load |
| T02 | Exercise metadata, assistance, idempotent credit, recent windows | Repeat/restart saves, trim-safe totals, unknown legacy fields |
| T03 | Minimal material contract and validation for chat saving | Prosigns, unsupported symbols, private export references |
| T04 | Pure Dart plan generation/speed recommendations | Seed, unavailable-category fallback, sample/speed boundaries |
| T05 | Plan controller/home/summary/persistence | Resume, new local day, settings changes, duplicate completion |
| T06 | Two QSO scenarios, intents, evaluation/state | Complete scenarios, variants, wrong calls, AGN/QRS, idempotent submit |
| T07 | QSO keying/playback UI and restoration | Touch/keyboard, background/focus, pause/resume |
| T08 | Listen-only messages and separate copying page | No answer leak/send/draft change, assistance, audio ownership |
| T09 | Save messages/materials and practice errors | Unknown-to-course symbols, duplicates, deleted source, switching |
| T10 | Sending timelines/details/replay/practice | Timing, prosign aliases, Farnsworth, cache trimming |
| T11 | Profile abstraction, guest storage, startup gate | Locked identity, offline guest, stale-write isolation |
| T12 | Migration transaction and placement | Failure recovery at each stage, repeated migration, no prerequisite skips |
| T13 | Materials, TXT/JSON, WAV output | Import rollback, versions, limits, independently playable WAV |
| T14 | Historical body search/bookmarks/deep jump | Unloaded rows, equal timestamps, deletion/clear, accessibility privacy |
| T15 | Single-message send investigation/contract/transport | C2C/group cancellation races, repeated retries, history/queue restart |
| T16 | WAV parsing, chunks, sample-clock events | Channels/rates, malformed input, feed chunk invariance |
| T17 | Workbench/loop selection/audio storage | Cancellation/background, no mic permission, missing files |
| T18 | Stage documentation/screenshots/main-plan/acceptance log | Ten languages, five-platform capability table, links/compatibility |

Suggested new tests: `packages/morse_trainer/test/{daily_plan,qso_session,placement_assessment,material_drill}_test.dart`; `packages/morse_dsp/test/{wav_pcm_reader,audio_decode_segment}_test.dart`; `packages/morse_io/test/wav_export_test.dart`; matching App `test/learn/`, `test/chat/`, `test/training/`, `test/account/`, `test/listen/` tests.

Extend existing tests instead of building a separate fake application, including `training_controller_host_test.dart`, `training_persistence_test.dart`, `startup_gate_test.dart`, `pending_message_status_test.dart`, and chat-history tests.

## 14. Validation and completion

### 14.1 Run checks for the change

Run from the repository root using its pinned toolchain (currently Flutter 3.41.9/Dart 3.11). First establish meaningful failing behavior tests, implement, then run module regressions.

```bash
# Pure Dart pedagogy and DSP
(cd packages/morse_trainer && dart test)
(cd packages/morse_dsp && dart test)

# Flutter I/O, contract fakes, actual transport adapters
(cd packages/morse_io && flutter test)
(cd packages/morsecq_chat_api && dart test)
(cd packages/morsecq_chat && flutter test --exclude-tags=needs-native)

# App regression and gates
(cd apps/morsecq && flutter test --exclude-tags=needs-native)
flutter analyze apps/morsecq
dart run tool/check_complexity.dart
dart run tool/import_guard.dart
dart run tool/ui_literal_guard.dart
git diff --check

# Also analyze changed packages; stage deliveries can run full pyramid tiers
tool/test_pyramid.sh --level gates
tool/test_pyramid.sh --level unit
tool/test_pyramid.sh --level widget

# Actual available device/desktop verification
tool/test_pyramid.sh --level e2e --device macos
```

Check current test directories and script usage first. Update these commands if the repository changes. Retry/cancellation additionally require real Tox integration; fakes prove UI/contracts only. Configure `TIM2TOX_FFI_LIB` using the native-build documentation, run `flutter test --tags=needs-native` inside `packages/morsecq_chat`, and add real cancellation/retry scenarios.

### 14.2 Required scenarios

- Data: legacy progress/settings/backups, failed save, restore, restart, trimming, local-day/DST, profile replacement/stale writes.
- Input: straight key/paddles, keyboard, losing focus while held, backgrounding, mode changes, repeated submits.
- Playback: manual/autoplay, keying interruption, microphone/file switching, no output device.
- Layout/accessibility: 320 dp, large text, landscape, iPad/desktop, VoiceOver/TalkBack, long strings in ten languages.
- Chat: C2C/group/self, offline peer, failed sends, reconnect/drain competition, historical search, bookmark/material behavior after clearing.
- Audio files: rates/channels, unknown chunks, truncation, limits, cancellation, missing source.

List verified/unverified capabilities on all five platforms. Unrun device/OS checks remain explicit; widget tests and screenshots do not prove native behavior.

### 14.3 Milestone completion criteria

1. Primary flows and relevant failure paths work.
2. Necessary unit/widget/storage/transport checks pass with actual commands/results recorded.
3. No regressions to courses, wire protocol, data restoration, or mobile keying.
4. New UI includes all ten languages/accessibility; screenshots use the official pipeline.
5. Both document languages, main-plan change log, and data-format notes are synchronized.
6. Remaining work is explicit; expose genuinely available operations rather than placeholder controls.

This document delivery checks structure, file references, bilingual scope, and diffs only. No features were implemented, so it does not claim their functional tests have passed.

## 15. Ready-to-send implementing AI prompt

```text
Implement doc/plans/2026-10-03-functional-improvements.zh-CN.md in MorseCQ.

Read repository instructions, the main plan, this specification, and relevant code.
Check the current baseline and existing user data. Default to M0–M3, delivering by
milestone rather than refactoring everything at once. Use the documented defaults
without repeatedly asking about routine technical decisions. If I specify another
feature/milestone, follow that scope and include its necessary dependencies.

Preserve Morse-only chat composition, ordinary-text interoperability, local-only
self chat, mobile/desktop input, existing identities/training backups, serialized
persistence, old-data recovery, and ten languages. Change identity requirements only
when shipping F05; keep the current startup gate before then.
Never edit third_party in place. Implement needed Tim2Tox capabilities separately
upstream and update the pin. Do not use Claude tools to review plans, code, or results;
perform appropriate local self-checks and validation. Use standard Git/Dart/Flutter
workflows rather than additional command wrappers.

Add meaningful behavior tests and run relevant analyzers/gates/available devices.
Report implemented IDs, code changes, migrations, actual validation, unrun platform
checks, and remaining work. Never present unimplemented features as complete.
Fake-only tests do not establish correct real P2P sending or cancellation.
```

## 16. References and reasoning

- [LCWO](https://lcwo.net/) offers Koch lessons, speed exercises, and downloadable practice audio. MorseCQ already has varied training; this specification prioritizes planning and chat integration rather than duplicating basics.
- [Morse Code World QSO Trainer](https://morsecode.world/international/trainer/qso.html) is an experience reference. This specification's interactive states and evaluation boundaries are project recommendations.
- [ARRL Code Practice Files](https://www.arrl.org/code-practice-files) provides recordings and accompanying text as links for user imports. This document does not authorize automatic redistribution.
- Repository main plan, persistence audit, Learn review, and test pyramid supply the compatibility/delivery constraints.

## 17. Implementation record (2026-10-03)

All eight features shipped in one branch, milestone by milestone. Where the code chose among options the spec left open:

| ID | Where | Notes / decisions |
|---|---|---|
| M0 | `morse_trainer` `exercise.dart`, `session_summary.dart`, `trainer_progress.dart`; app `training_controller.dart`, `exercise_outcome.dart` | `SessionSummary` is the exercise record (optional fields, legacy = unknown). `CreditPolicy` is the single credit table. `recordExercise` commits record, plan step and unlock in one write; ids remembered for the last 10 000 commits. Blank answers earn nothing. Training documents (`training/docs/*.json`) go through the same write queue; read-modify-write uses `docTransaction`. |
| F01 | `daily_plan*.dart`, `speed_recommendation.dart`; `training_plan.dart`; `ui/learn/plan/` | Steps carry their own seed and, once started, frozen speeds. Course steps shorter than 50 symbols are consolidation (5 min) or extended (≥10 min). Speed advice per evidence batch, Apply-only. |
| F02 | `morse_trainer/qso/`; `qso_practice.dart`; `ui/learn/qso/`, `ui/learn/keying/keyer_panel.dart` | Stages: (call CQ \| confirm calls) → exchange → confirm their info → close. Slot evaluator; AGN/QRS; hints get specific after 3 errors. Drafts keep unsent keyed text; a finished QSO is kept until its result is saved. Activity credit only; excluded from accuracy charts. |
| F03 | `chat_copy_session.dart`; `ui/learn/chat_copy/`; `ui/chat/conversation_learning.dart` | Separate copy page; listen-only hides text, pattern, list previews and semantics. Saving to materials confirms unsupported characters. |
| F04 | `send_timeline.dart`; `send_detail_store.dart`; `ui/learn/send/send_timeline_view.dart` | Alignment requires matching mark classes and character boundaries, otherwise "not located". New `dahTooLong`. Details under a 20 MiB index-trimmed budget; favourites kept. |
| F05 | `guest_profile.dart`, `startup_controller.dart`, `training_controller_host.dart`; `ui/account/guest_widgets.dart`; `placement_assessment.dart`, `ui/learn/placement/` | Guest data in `<support>/morsecq/guest/`. Migration: suspend all learning controllers → stage → validate → journal → commit → marker (per guest generation) → cleanup; resumed at launch. Restore/unlock from guest offers keep/use-guest, never merges. |
| F06 | `material/*.dart`; `material_store.dart`, `material_practice.dart`; `ui/learn/materials/`; `morse_io` `wav_export.dart` | TXT/JSON import (every JSON import previewed and confirmed), JSON/TXT/WAV export (PCM16 mono 48 kHz, ≤10 min parts). |
| F07 | `morsecq_chat_api` `message_search.dart`; `morsecq_chat` `chat_service_messages.dart`; `ui/chat/search/`; Tim2Tox PR agentx-icu/tim2tox#27 | Cursor paging by (timestamp, id) with cancellation; jump pages both ways; bookmarks per profile, removed with cleared history. Cancel/retry backed by Tim2Tox send control (drain re-checks queue membership). |
| F08 | `morse_dsp` `wav_pcm_reader.dart`, `audio_decode_segment.dart`; `morse_io` `clip_player.dart`; `ui/listen/workbench/`; `audio_material_store.dart` | Envelope gate unchanged by default (an opt-in noise warm-up exists; a spurious first symbol on noisy 44.1 kHz recordings remains a known limitation). Recordings live in `<profile>/media/recordings/` and stay out of identity backups by default. When saved recordings exist, backup export asks whether to include them (count and size shown; offered only up to 100 MiB), and restore writes them back; missing media offers relink/delete. |

Validation: package and app test suites, analyzer and the three repo gates pass (counts in the PR). Independent review by Codex in four scopes; findings fixed and re-reviewed.

Not done / unverified: product screenshots were not regenerated (macOS test runs share the installed app's sandbox); no two-node native Tox test of cancel/retry (covered by Tim2Tox's own tests); `SoloudClipPlayer` and real audio output not exercised on devices; selections longer than five minutes play only their first five minutes.

## 18. Change log

- **2026-10-03** — Converted the discussion into eight feature specifications, shared data/credit policies, milestones, tests, and AI handoff instructions. Documentation only; application behavior is unchanged. Purpose: enable another AI to implement a defined scope.
- **2026-10-03** — Self-check clarified QSO accepted forms, placement coverage, plan lesson-boundary eligibility, and native-test commands; corrected tokenizer ownership and kept both languages synchronized to reduce implementation ambiguity.

- **2026-10-03** — Implemented M0–M8 (all eight features) and added §17 Implementation record; Codex review findings fixed. The status line now reflects shipped scope.
- **2026-10-04** — Corrected §17: recordings can be included in an identity backup. Export asks when saved recordings exist (up to 100 MiB) and restore writes them back, as §11.3 requires. The record had said this was not offered.
- **2026-10-04** — F10 of the [additional improvements](./2026-10-04-additional-functional-improvements-handoff.md) supersedes the backup statements in §11.3 and §17 for new exports: recordings are now an opt-in category of the complete, passphrase-sealed backup (same 100 MiB limit, same referenced-recordings rule), restored with the rest. Legacy archives keep restoring as described here. Radio-condition sessions (F11) use a new `conditions` exercise source with activity-only credit.
