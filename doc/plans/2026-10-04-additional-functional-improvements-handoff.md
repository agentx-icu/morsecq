> Historical pre-split document. Current MorseCQ is the offline trainer described in [README](../../README.md); chat belongs to DitMesh.

[简体中文](./2026-10-04-additional-functional-improvements-handoff.zh-CN.md)

# MorseCQ Additional Functional Improvements: Implementation Handoff

> Date: 2026-10-04. Inspected application-code baseline: `bae1d5e`.
> Status: implemented (F09–F14) on branch `agentx/additional-improvements`; see §13 for decisions, verification and what remains unverified on real devices.
> English is the authoritative version of this handoff; the Chinese counterpart retains the same scope and acceptance criteria.
> Read this alongside [the existing F01–F08 specification](./2026-10-03-functional-improvements.md). This supplement does not replace it or authorize application-code changes by itself.

## 1. Objective and priorities

Extend MorseCQ with reliable everyday communication, complete device migration, and more practical Morse training. Preserve the product's local-first, serverless Tox architecture and Morse-keyed chat.

The existing roadmap already covers daily plans, interactive QSO, chat-based exercises, rhythm replay, guest/placement, custom materials, message management, and an audio workbench. Do not reimplement those features here.

| ID | Additional feature | Priority | User outcome |
|---|---|---|---|
| F09 | Connection diagnostics and recovery | High | Understand why communication is waiting and what action is available |
| F10 | Complete encrypted backup and device migration | High | Move an identity and selected personal data to another device with a verifiable result |
| F11 | Realistic radio-condition training | Medium | Practice copying beyond a clean, uniform tone |
| F12 | External key support and configurable key bindings | Medium | Practice with an existing physical key or paddle and retain a preferred setup |
| F13 | Chinese telegraph-code learning and chat interpretation | Medium | Learn four-digit character codes and deliberately interpret keyed numeric messages |
| F14 | Group practice sessions | Later | Give groups a repeatable instructor-led practice workflow |

If only three additions are funded, select F09, F10, and F11. Continue prioritizing the existing daily-plan and interactive-QSO work. These priorities express product value, not an instruction to implement everything in one change.

All defaults below are proposed first-release choices. Recheck the current code before implementation and record any material adjustment in this document's change log.

## 2. Verified baseline and constraints

| Area | Present behavior | Gap addressed here |
|---|---|---|
| Connection | `offline`, `connecting`, and `online` states; an in-app banner after two minutes continuously not online, with a reconnect action | A detailed explanation, pending-message overview, and observed connection history |
| Backup | MCQB v1 includes identity metadata, the Tox profile, and the training directory; the profile is encrypted only when an identity password is set | Native chat history, explicit preference export, selectable content, and encryption of the complete archive |
| Storage | Native history and the offline queue live under the identity's `data/`; learning data lives under `training/`; some conversation metadata lives in an identity-scoped key/value store | A consistent snapshot across these separate owners |
| Audio | Existing playback uses a sine-wave sidetone with managed audio-engine leases | Seeded noise, fading, interference, and bounded timing variations for receive practice |
| Keyboard | `KeyboardKeyBinding` already accepts custom action sets and provides `swapped()`; default keys are Space / left Ctrl / right Ctrl | User-facing configuration, persistence, and tested adapter configurations |
| Chinese codes | `ChineseTelegraphCode` and the translator already support mainland and Taiwan codebooks, leading zeros, and reverse candidates | Dedicated exercises and explicit chat interpretation |
| Groups | Group creation/join/invites, messages, member lists, and restored membership exist | Practice workflow, local attempts, and session summaries |

Preserve these rules:

- Outgoing chat remains Morse-keyed. Training answer controls and diagnostics do not introduce a text chat composer or silently send answers.
- Ordinary messages remain plain text on the wire and readable by other Tim2Tox clients. `cloudCustomData` is not a reliable wire channel; the existing group interface does not expose it.
- Only `morsecq_chat` accesses Tim2Tox/Tencent SDKs. UI uses `morsecq_chat_api`; pure Dart packages retain their existing boundaries.
- Training works offline. Do not add a cloud account, directory service, subscription, server push, or background-delivery promise.
- Transmitting the sender's actual rhythm and synchronized live keying remain dependent on upstream work and outside this supplement's first release.
- The note-to-self conversation remains local and cannot be deleted. Existing progress, old backups, and identity isolation remain compatible.
- Preserve touch/mouse and keyboard keying. Mobile compatibility is required; hardware-device compatibility must be reported by tested platform and device.
- Follow the current user review policy: Claude-based reviews are disabled. Complete appropriate local inspection and validation.

## 3. F09: Connection diagnostics and recovery

### 3.1 User flow and scope

The existing connection banner opens a diagnostics page. Also provide a persistent entry from Chat or Me so users can inspect the state before the banner appears.

Show:

1. Local connection state and when that state was last observed to change.
2. Last observed successful local connection, or “No connection observed yet.” This is not the time a message was received by its destination.
3. Selected peer's observed online state, when available; otherwise “Unknown.” Local connectivity and peer availability are separate facts.
4. Pending-message count and oldest pending time, scoped to the current identity and conversation. Use the durable queue as the authority, rather than counting only the loaded history page.
5. Available recovery actions and a short explanation of the P2P/mobile-background behavior.

Reconnect uses the existing lifecycle/identity coordinator and has an in-progress state. Coalesce repeated taps. A completed reconnect call does not mean the network is online: keep observing connection events and show the result honestly.

Retain the existing two-minute banner policy and its no-OS-notification behavior. Detailed inspection is on demand; do not generate repeated notifications for routine connection changes.

### 3.2 Data and implementation

Add a typed diagnostics snapshot through the app controller and, where needed, `morsecq_chat_api`. Suggested fields: identity key, observation time, local status, last observed online time, optional peer status, pending count, oldest pending time, operation state, and typed error code.

- Unsupported observations are null/unknown. Do not infer NAT failures, firewall blocks, a recipient crash, delivery, or read receipts from an offline state.
- Tim2Tox currently cannot reliably distinguish all failed and sent states in its polling path. Do not promise failure diagnosis that the backend cannot provide; reuse F07 if retry/cancellation has shipped.
- Reset identity-specific observations on identity replacement. Late events from an old session cannot update the new one.
- Diagnostics are read-only except for explicit recovery actions. They never discard queued messages or automatically retry uncertain sends.
- Keep technical details in an optional detail view; the main page explains the user's situation in ordinary language.

### 3.3 Acceptance criteria

- Local online / peer offline and local offline / unknown peer render distinct explanations.
- Pending counts include durable queued rows outside the currently loaded history page, without duplicates.
- Repeated reconnect taps start one operation; errors leave the page usable and queued data unchanged.
- A return from mobile background reflects newly observed state without claiming continuous background connectivity.
- A new identity cannot display the previous identity's observations or queue counts.

## 4. F10: Complete encrypted backup and device migration

### 4.1 User flow and content

Export: select content → preview included/excluded categories and size → set a backup passphrase → create a consistent encrypted archive → save/share → show the platform's actual outcome.

Restore: choose file → enter passphrase → validate and preview → explicitly confirm identity replacement → stage and commit → display a restoration report. A share-sheet dismissal is not verified storage; preserve the current platform-specific saved/cancelled/failed semantics.

| Category | Proposed default | Rule |
|---|---|---|
| Identity and Tox profile | Required | Validate that profile and identity metadata describe the same public key |
| Training progress/settings and saved learning materials | Included | Include existing training files; future F04/F06 details are included only if present |
| Chat history, including note-to-self | Included, selectable | Preserve message IDs, ordering, and supported status data |
| Drafts, pins, bookmarks, conversation metadata | Included, selectable | Inventory actual owners; future F07 bookmarks are optional, not assumed to exist |
| Portable app preferences | Included, selectable | Export explicit keys, not the complete operating-system preference store |
| Saved recordings and other large media | Excluded, opt-in | List missing-media consequences and estimated size; align with F08 |
| Pending messages and queued invitations | Excluded from automatic resumption | Report their presence; see the policy below |

Window coordinates, active audio/key-down state, transient diagnostics, OS permissions, tokens, caches, and scratch files are not portable settings. Do not restore them as active state.

### 4.2 Pending-send policy

Moving an identity while the old device retains its outbox can cause both devices to send the same message. First-release default: restored pending rows do not transmit automatically.

If the user explicitly includes pending payloads, restore them as inert drafts/review items outside the live native queue. Show their previous pending state and let the user decide whether to key and send again. Do not claim exactly-once delivery or silently downgrade an uncertain send into a guaranteed failure.

Exclude queued invitations from automatic replay as well. Explain what was not resumed in the restoration report. The migration flow tells the user to stop using the source identity before connecting it on the destination; it does not add simultaneous-account support.

### 4.3 Archive and restore requirements

- Current MCQB v1 is a length-prefixed archive, not whole-file encryption. Retain its reader and legacy import behavior.
- Introduce a versioned authenticated encrypted envelope for new complete backups. Encrypt identity metadata, chat text, learning content, and the private manifest together. Public metadata should contain only what decryption requires.
- Use a maintained encryption library and its supported passphrase derivation. Store bounded derivation parameters and format identifiers; do not invent cryptographic primitives. Libsodium's [file-encryption API](https://doc.libsodium.org/secret-key_cryptography/secretstream) and [password hashing documentation](https://doc.libsodium.org/password_hashing) are reference options, not evidence of an existing callable Dart API in this repository.
- Verify an available binding on all target platforms before choosing it. Define format/version, authenticated metadata, resource limits, final-record validation, and error handling before writing the encoder.
- A backup passphrase is separate from the identity unlock password. Export must not silently alter the identity password. If the contained Tox profile remains encrypted with another password, the restore preview must explain the additional unlock requirement.
- Inventory `data/`, `training/`, and identity-scoped key/value entries. Do not copy arbitrary directories or assume all preferences are files beneath the identity root.
- Coordinate existing `persist`/`flush` barriers with native history/queue writers and preference owners to obtain one consistent snapshot. Flushing alone does not prevent writes during copying; quiesce writers or use a verified snapshot mechanism.
- Validate authentication, identity, supported versions, allowed paths, duplicate entries, entry counts, sizes, and required data before replacement. Do not follow symlinks or extract outside staging. Unknown future formats must fail clearly.
- Reuse staging, replacement-generation guards, and rollback. File replacement and external preference updates require a recoverable transaction; renaming one directory does not make both atomic.
- Preserve the existing installation on failure. Keep a recoverable prior snapshot until commit succeeds; clean sensitive staging files after success or cancellation without destroying the only recoverable copy.

### 4.4 Acceptance criteria

- MCQB v1 fixtures still import. New archives conceal sample identity names, chat bodies, and training text from a raw-byte inspection.
- Correct passphrase restores selected categories and the same identity; omitted categories are explicitly reported.
- Wrong passphrase, altered/truncated data, unsafe paths, duplicate entries, and oversized inputs cannot replace the current account or preferences.
- A new message or training save during export is either consistently included or consistently excluded; it does not create mismatched history/outbox state.
- Restored pending payloads and invitations never send automatically, including after restart.
- Cross-platform restoration preserves supported logical data and does not apply invalid window bounds or source-device hardware bindings.
- Simulated failure between file and preference commits is recoverable; repeated restore does not double-count training or duplicate history.

## 5. F11: Realistic radio-condition training

### 5.1 Scope and user flow

Add optional receive-practice presets: **Clear**, **Light interference**, and **Radio practice**. Clear stays the default. Preview each preset before starting, show the active conditions in the exercise, and retain a clean-reference replay after the answer.

First increment: reproducible background noise and signal fading. Second increment: one adjacent tone/interfering Morse source and bounded timing variation. Open-ended pileups, transmitter integration, and propagation prediction remain later work.

Keep speed controls independent of channel conditions. A harder environment must not silently change character/effective WPM, increase output loudness, or expose the answer through an unaffected flash/haptic track.

### 5.2 Data, audio, and scoring

Suggested immutable scenario fields: scenario version, seed, character/effective WPM, tone, noise level, fade parameters, optional interference parameters, timing-variation parameters, and assistance state.

- Separate the target signal from added effects; the clean transcript remains the scoring source. Decoder output is not the learner's answer.
- Use seeded generators and bounded, nonnegative timing. The same version/settings/seed must reproduce the same scenario within documented rendering tolerances.
- Keep scenario generation testable without Flutter; route actual audio through `morse_io` and existing engine leases. Do not replace the low-latency sending sidetone with the training mixer.
- Bound combined audio amplitude, prevent clipping, and stop on pause, navigation, background, and disposal. Returning to the foreground requires an explicit resume.
- If an unaffected visual/haptic track or clean replay is used, mark the attempt assisted. Explain the audio requirement when realistic effects cannot be perceived; retain ordinary accessible practice modes.
- Store condition metadata with the shared exercise record defined in F01–F08. Show performance by comparable scenario and speed. Do not mix noisy results into clean-speed recommendations.
- First release does not use realistic-condition sessions for automatic Koch unlocking. Record activity and separate condition-specific results; do not mix those results into clean-receive SRS/weakness totals until a defined policy exists.

### 5.3 Acceptance criteria

- Clear reproduces existing normal playback behavior; enabling conditions is explicit.
- Fixed seed/settings/version replay the same exercise; timing variation cannot reorder symbols or produce invalid durations.
- Different noise/fading settings do not change the target text or selected nominal speed.
- Mixed audio is bounded and interrupted playback leaves no audible or silent-running leaked voice.
- Results retain conditions and assistance and do not affect clean-speed advice, clean SRS, or automatic course unlocks.
- Mobile tests cover interruptions, speaker/headphone changes, and return from background.

## 6. F12: External keys and configurable bindings

### 6.1 Scope and user flow

First release supports keyboard-emulating USB adapters through the existing event path. Add a configuration page that captures bindings for straight key / dit / dah, swaps paddles, selects existing straight/iambic A/iambic B modes, tests input with a live indicator and sidetone, and saves named configurations.

Reuse `KeyboardKeyBinding` and its swap operation. Touch/mouse keying remains available when no external device is present. USB MIDI, serial, Bluetooth, adapter firmware control, and transmitter control are later extensions requiring separate platform work.

The [Vail Adapter](https://github.com/Vail-CW/vail-adapter) exposes keyboard and MIDI interfaces. This is evidence for the integration approach, not a compatibility claim for MorseCQ or every adapter mode.

### 6.2 Behavior and persistence

- First-release profiles are keyboard-binding presets; the app may not know which physical keyboard generated an event. Do not claim automatic device detection from generic keyboard events.
- Persist the three actions, paddle orientation, and keyer mode with a versioned device-local configuration. Apply the same selected configuration to Learn, Chat, and Reference keying.
- Reject conflicting bindings instead of relying on the current action-precedence fallback. Explain OS-reserved or unavailable keys and provide a reset to defaults.
- Ignore key-repeat events. Two paddles may be held simultaneously; release actions on lost focus, background, navigation, or configuration replacement.
- Where an adapter has its own keyer and sidetone, distinguish straight timed input from paddle input. Avoid generating a second iambic sequence from already timed key-down/key-up marks, and provide a way to disable app sidetone.
- Lost key-up recovery must leave no stuck tone. Keyboard-emulation disconnect is not always observable: retain the focus-reset path and an explicit stop/reset control; report any residual platform limitation.
- Mark input testing as testing; it cannot submit a chat message or add training credit.
- Imported configurations are inactive until reviewed on the destination. Report compatibility only for combinations actually exercised.

### 6.3 Acceptance criteria

- Defaults match current behavior; custom mapping/swap persists and is consistent across all keying surfaces.
- Duplicate bindings, repeat events, held dual paddles, lost focus, and configuration changes do not produce duplicate or stuck marks.
- Adapter-generated timed marks are interpreted without double keying in the documented configuration.
- Touch/mouse and ordinary keyboard practice continue to work without an adapter.
- Validate at least one real keyboard-emulating adapter and record platform, adapter/firmware mode, focus behavior, sidetone choice, and measured latency. Fake events alone do not prove hardware support.

## 7. F13: Chinese telegraph-code practice and chat interpretation

### 7.1 Scope and user flow

Add two distinct practice tasks:

1. **Digit copying:** listen to four-digit groups and enter the digits.
2. **Codebook recall:** given a character or group, identify its corresponding code or character using the selected codebook.

Provide a curated introductory character list and user-saved characters once F06 exists. Keep codebook selection visible and save it with the attempt. Listening to digits and memorizing character mappings are different skills; report them separately.

In Chat, add “Interpret as Chinese telegraph code” to a selected message or digit sequence. Show original groups, candidate characters, unresolved groups, and mainland/Taiwan selection. Interpretation is local and explicit; ordinary numbers are never converted automatically.

### 7.2 Parsing, ambiguity, and statistics

- Reuse `ChineseTelegraphCode`, generated tables, and `charsOf()`; do not build a second mapping table.
- Preserve four digits and leading zeros. For first-release chat interpretation, accept whitespace-separated four-digit groups; leave other text untouched and flag incomplete or malformed groups.
- Do not use the existing permissive `decode()` as the entire chat parser: it extracts digit runs, drops other text, splits runs into groups, and picks a first candidate. Chat interpretation needs conservative parsing and visible ambiguity.
- Offer all reverse candidates where a code maps to multiple characters. Do not silently choose the first Unicode code point or treat equivalent forms as learner errors.
- Unknown groups stay visible with an unresolved label. Reinterpretation never overwrites the stored message or sends a translated message.
- Outgoing chat still uses keyed numeric groups. A character lookup may help the user find a code, but cannot become an automatic text-to-chat send path.
- Digit-copy accuracy uses the existing Morse digit scoring rules; a four-digit group is not one mastered Morse symbol. Assisted attempts are labeled, and only eligible learned digits may update receive SRS under the existing policy.
- Codebook recall uses separate mapping statistics and never unlocks Koch lessons or changes Morse speed recommendations. Record codebook and mapping-table version so saved results remain interpretable after table updates.

### 7.3 Acceptance criteria

- Leading-zero codes survive playback, answers, storage, and interpretation unchanged.
- Mainland/Taiwan differences and multiple reverse candidates are visible and correctly scored.
- Ordinary numeric messages retain their default display; interpretation requires an explicit action.
- Mixed text, long numeric runs, incomplete groups, and unknown codes are preserved or flagged rather than silently discarded.
- Revealing a lookup marks assistance; mapping scores remain separate from digit-copy and Koch progress.
- All UI languages can display codebook names, explanations, and Chinese glyphs; functionality is not tied to the selected UI locale.

## 8. F14: Group practice sessions

### 8.1 First release: manual coordination, local evaluation

Add a practice entry inside an existing group. A local session contains a title, instructor/participant role, source message IDs, round order, playback preferences, attempts, and a summary.

The instructor sends exercise content using the existing Morse-keyed group composer. Participants explicitly select an exercise message, copy it in a local training page, and review their own result. Turn order is a suggested local checklist; the instructor announces turns through ordinary group messages.

Each participant plays at their own selected speed. Answers, scores, and drafts remain local. Sharing a result requires a separate deliberate user action and must preserve the Morse-keyed outgoing-chat rule; first release has no automatic score broadcast.

This delivers a useful group practice workflow without assuming that existing group metadata provides synchronized sessions, remote role enforcement, or authenticated automated reports.

### 8.2 State and future boundary

- Persist session/round IDs, source references, attempts, assistance, and completion. Reuse F03 copying/scoring and the common exercise record when available.
- Same message and attempt ID cannot add credit twice. Repeating practice creates a new attempt; a summary does not add another completed exercise.
- Source-message deletion marks the source unavailable. Saving a practice copy is explicit and follows F03/F06 storage and deletion policy.
- Exiting or backgrounding stops audio and releases keys. Reopening restores metadata, not an active key-down, playback, or automatically sent message.
- Offline participants may practice available local messages; do not claim that group history or missed rounds will always be delivered to every member.
- New session metadata stays local. Restoring a session does not rejoin, invite, or publish automatically; existing group behavior remains in control.
- Shared room IDs, synchronized rounds, distributed roles, remote score collection, and timers require a separately specified protocol and capability negotiation. Inspect the upstream message-annotation RFC first; do not put control data in non-transmitted `cloudCustomData` or assume arbitrary ordinary group messages are trusted commands.

### 8.3 Acceptance criteria

- An instructor and two participants can complete a manually coordinated exercise using ordinary group messages and local scoring.
- Participant playback speeds differ without affecting shared message content.
- Submitting an answer neither changes the chat draft nor sends anything to the group.
- Restart preserves local session progress; repeated submissions do not add credit twice.
- Ordinary Tim2Tox clients continue to see readable exercise text without requiring session support.
- Offline/missing-source states are explicit; the UI does not invent a completed round or synchronized state.

## 9. Code map and dependencies

All paths below exist at the inspected baseline. New types named above are suggested responsibilities, not already available APIs.

| Feature | Existing code to inspect first |
|---|---|
| F09 | `apps/morsecq/lib/notifications/connection_banner_policy.dart`; `apps/morsecq/lib/lifecycle/app_lifecycle_coordinator.dart`; `packages/morsecq_chat_api/lib/src/identity_service.dart`; `packages/morsecq_chat/lib/src/chat/pending_message_status.dart` |
| F10 | `packages/morsecq_chat/lib/src/identity/{identity_paths,identity_backup,backup_container,tim2tox_identity_service}.dart`; `packages/morsecq_chat/lib/src/chat/conversation_meta_store.dart`; `apps/morsecq/lib/ui/account/{backup_actions,backup_wizard_page,restore_backup_page}.dart`; `apps/morsecq/lib/training/training_controller_host.dart`; `apps/morsecq/lib/di/app_preferences.dart` |
| F11 | `packages/morse_core/lib/src/encoder.dart`; `packages/morse_io/lib/src/{player,sidetone_sink,soloud_api}.dart`; `packages/morse_trainer/lib/src/session_summary.dart`; `apps/morsecq/lib/ui/learn/receive/`; `apps/morsecq/lib/ui/learn/learn_playback.dart` |
| F12 | `packages/morse_io/lib/src/keyboard_binding.dart`; `packages/morse_io/lib/src/widgets/{straight_key_button,paddle_buttons}.dart`; `packages/morse_io/lib/src/iambic_keyer.dart`; `apps/morsecq/lib/training/training_settings.dart`; `apps/morsecq/lib/ui/chat/keying_input.dart` |
| F13 | `packages/morse_core/lib/src/telegraph/chinese_telegraph_code.dart`; `tool/gen_telegraph_table.dart`; `apps/morsecq/lib/ui/reference/text_to_morse_view.dart`; `apps/morsecq/lib/ui/chat/message_bubble.dart`; `packages/morse_trainer/lib/src/number_groups_drill.dart` |
| F14 | `apps/morsecq/lib/ui/groups/`; `apps/morsecq/lib/ui/chat/conversation_screen.dart`; `packages/morsecq_chat_api/lib/src/chat_service.dart`; `packages/morsecq_chat/lib/src/chat/chat_service_groups.dart` |

Dependency rules:

- F09 can ship independently. Queue visibility must be implemented through the backend contract; retry/cancel controls depend on F07.
- F10 can ship before new training features. Its manifest must represent absent optional categories honestly and admit later categories without breaking old archives.
- F11 depends on comparable exercise/assistance metadata for meaningful statistics. Deliver a minimal compatible record extension if F01's shared records have not shipped.
- F12 reuses present input primitives and can ship independently; portable backups must not activate imported device bindings automatically.
- F13 basic interpretation and curated drills can ship independently. Personal character collections depend on F06.
- F14 should follow F03/common exercise records. Coordinated online rooms are a separate later milestone, not an assumed property of the local first release.

## 10. Suggested delivery milestones

| Milestone | Tasks | Required reviewable output |
|---|---|---|
| M0: baseline audit | Recheck current implementation, data owners, fixture compatibility, SDK observations, crypto bindings, available devices | Updated code/data map; explicit unsupported capabilities; decisions for backup format and snapshot/restore transactions |
| M1: reliable communication and migration | F09; F10 inventory/manifest, encrypted export, legacy-compatible staged restore | Working diagnostics and cross-device restoration with failure recovery and no automatic resend |
| M2: practical receive/send tools | F11 clear/noise/fading first; F12 configuration and a real adapter; F13 conservative interpretation and curated drills | Reproducible scenarios, verified input configurations, and separate codebook learning statistics |
| M3: group practice | F14 manual rounds with F03 scoring | Instructor/participant walkthrough, restored local progress, and compatibility with ordinary clients |

Do not let unresolved later-room protocol work block F09–F13. Build small complete increments, with appropriate tests and documentation for each.

## 11. Verification and handoff requirements

Use [the test pyramid](../testing/TEST_PYRAMID.md) and [the persistence audit](../testing/PERSISTENCE_AUDIT.md). Run checks appropriate to changed packages: analyzer, complexity/import/UI-literal guards, focused unit/widget tests, and affected real-device flows. Update all ten ARB languages and regenerate localization when adding UI strings.

Minimum behavioral evidence:

- F09: fake-clock/status tests plus network-change/background UI checks.
- F10: legacy fixtures, encrypted round trips, malformed-input and failure-injection tests; verify two-way logical migration across available target platforms and record any untested pair.
- F11: seeded signal/timing tests, clipping/resource-lifetime checks, and real audio interruption tests.
- F12: event-sequence regression tests plus physical-adapter evidence; log real latency rather than asserting an unmeasured target.
- F13: codebook ambiguity/leading-zero/parser tests and a chat-to-practice walkthrough.
- F14: no-network-send assertions for answer submission, restart/deduplication tests, and a three-user walkthrough.

For every delivered milestone, report changed behavior, files/contracts, data migration, verification commands and actual results, physical devices tested, unresolved limitations, and the next task. Distinguish implementation, automated validation, and real-device validation.

When features actually ship, update the main README, relevant package docs, and the existing F01–F08/founding plan where prior backup, statistics, or group statements change. Preserve their change logs. Do not mark proposed features complete merely because a document or fake-backend screenshot exists.

## 12. Copy-ready implementation brief

> Implement the selected milestone from `doc/plans/2026-10-04-additional-functional-improvements-handoff.md`, alongside the existing F01–F08 specification. Inspect the current code and data owners before changing APIs. Preserve Morse-keyed chat, ordinary-text interoperability, local training, old profiles/backups, existing input modalities, and mobile parity. Reuse keyboard bindings, codebooks, audio leases, and persistence barriers. Unsupported diagnostics must remain unknown; new backups must encrypt the complete payload and restore transactionally; restored pending items must never send automatically. Keep radio-condition and codebook statistics separate from clean Morse proficiency. First-release group practice is manually coordinated with local scoring. Validate the selected work, document actual device evidence and remaining limitations, and follow the user's prohibition on Claude-based reviews. Do not implement every later feature as part of one milestone.

## 13. Implementation record (2026-10-04)

All six features were implemented in one branch, one commit per feature, followed by review fixes. Where the code chose among options this document left open:

| ID | Where | Decisions |
|---|---|---|
| F09 | `morsecq_chat_api` `outbox.dart` (`OutboxInspector`, `PendingOutboxSummary`); `morsecq_chat` `pending_message_status.dart`; app `diagnostics/connection_diagnostics.dart`, `ui/diagnostics/` | Queue visibility is an optional capability: services without it report *unknown*. The Tim2Tox queue is read directly (deduplicated per durable id), null while detached. Observations are per identity and dropped on replacement; reconnect goes through the startup controller, is coalesced and keeps a typed error code. After a mobile suspension observation restarts at the return; the last connection is never dated after the app left the foreground. Entry points: offline banner "Details", Me, conversation menu. |
| F10 | `morsecq_chat_api` `encrypted_backup.dart`; `morsecq_chat` `identity/backup_{envelope,archive,snapshot}.dart`, `identity_backup_v2.dart`, `adapters/kv_snapshot.dart`; app `ui/account/{encrypted_backup_page,restore_backup_page,restore_report_page}.dart`, `di/portable_preferences.dart`, `ui/chat/restored_pending.dart` | **Cipher:** the already bound, all-platform `toxencryptsave` (`tox_pass_encrypt`: libsodium scrypt + XSalsa20-Poly1305, random salt, library-fixed KDF parameters) through `ProfileCrypto`; no new native dependency. Envelope `MCQE` v1, suite 1, 8-byte public header that is also sealed and compared. Inner archive is MCQB layout v2 with a private manifest whose categories, counts and sizes must match the entries exactly. **Snapshot:** persist data stores, stop the node (history and outbox at one moment), stamp every file before and after reading, re-check the selection, retry up to three times (`backup_busy`). Rows still in the outbox are removed from exported history (they would otherwise restore as "sent"). **Restore:** decrypt once (cached from the preview), validate, stage, then rename the tree and rewrite conversation metadata inside one rollback-protected step under the password verifier; app preferences are applied afterwards through validating setters with their own rollback. Unsent messages come back only as review items in `training/chat/restored_pending.json`; the queue file is never written; queued group invitations are reported, never replayed. MCQB v1 import is unchanged except duplicate entries are now refused; the file limit is 192 MiB for both formats. |
| F11 | `morse_trainer` `radio_conditions.dart`; app `ui/learn/conditions/`, `receive_drill_screen.dart`, `drill_picker_sheet.dart` | Presets Clear / Light interference / Radio practice; Clear is the old path. A versioned `RadioScenario` (seed, speeds, tone, noise, fade, one interferer, timing variation ≤ 25 %) renders in pure Dart on a background isolate and plays through `morse_io`'s `ClipPlayer` (shared engine lease); the keying sidetone is untouched. Peak never exceeds a clean rendering. Audio only (no flash/haptic track). Records use a new `conditions` source: activity only, never lesson, SRS, clean trend or speed advice; results grouped by channel and speeds. |
| F12 | `morse_io` `keyboard_binding.dart` (`conflicts`, `straightOnly`), `sink.dart` (`GatedSink`); app `keying/`, `ui/keying/` | Device-local, versioned key profiles (not in backups). Duplicate and reserved keys refused. "Adapter keys its own elements" routes every bound key through the straight path. The sidetone switch gates only the sound. Applied to Learn send, QSO, chat and Reference keying; Learn's keyer mode follows the active profile. |
| F13 | `morse_core` `telegraph_groups.dart`; `morse_trainer` `telegraph_practice.dart`; app `training/telegraph_sessions.dart`, `ui/learn/telegraph/`, `ui/telegraph/` | Conservative whitespace-token parser on the existing tables. Digit copying records `telegraph:<codebook>:<Unihan version>` as its source reference and uses ordinary digit scoring. Recall statistics are a separate document keyed by codebook, table version and character. The Unihan 18 tables contain no code shared by two characters, so ambiguity handling is tested by returning the complete candidate list. |
| F14 | app `training/group_practice.dart`, `ui/groups/practice/` | Local sessions in a training document; rounds reference message ids only. Participants copy on the F03 copy page (shared credit and dedupe); instructors keep a checklist. A source not found is shown, never stored. Nothing is sent; the summary only suggests a result to key by hand. |

**Verification (automated, macOS host):** analyzer clean on every package and the app; app suite 1234 tests, package suites (morse_core 92, morse_trainer 212, morse_dsp 107, radio_tools 18, morse_io 124, morsecq_chat 216, morsecq_chat_api 73) pass; complexity, import and UI-literal gates pass; the native F10 test (real cipher) shows that identity name, chat and training text do not appear in the file and that altered, truncated or wrong-passphrase files are refused before anything changes.

**Review:** at the user's request in this session, reviews ran as independent Claude (Fable) agents instead of Codex, superseding the review note in §2 for this delivery: four parallel reviews, all findings fixed (one high in F10 — recordings were never exported — and one high in F14 — a still-loading history was stored as "source deleted"), then a confirmation review of the fixes, whose remaining findings (a stop during rendering left a round "listening", a retry after leaving the recall screen, queue-file stamping, a kept preview archive) were fixed too.

**Not verified on real devices:** no physical keyboard-emulating adapter was available, so F12 adapter compatibility and latency are unmeasured; no two-way migration between two physical platforms (round trips ran in tests on one host); F11 real audio interruption, speaker/headphone changes and isolate rendering time on phones; F09 network changes on a phone; no three-person F14 walkthrough; product screenshots were not regenerated.

## 14. Change log

- 2026-10-04: Created the English handoff and Chinese counterpart for six additional functional recommendations (F09–F14), with baseline facts, first-release boundaries, dependencies, and acceptance criteria. Application behavior is unchanged.
- 2026-10-04: Implemented F09–F14 and added §13 Implementation record (decisions, verification, unverified items); status line updated. Reviews ran as Claude (Fable) agents at the user's request for this session.
