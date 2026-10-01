# Persistence audit implementation plan

> Execute in the isolated `codex/persistence-audit` worktree. Review the plan and final diff with Claude Opus in read-only mode before implementation and delivery.

**Goal:** Make durable user data survive restart on Android, iOS, macOS, Linux and Windows, without stale identity data after delete or restore.

**Architecture:** Retain application-support JSON for app preferences, per-identity JSON for training, and Tim2Tox savedata/history plus scoped preferences for chat. Serialize file operations; restore settings before exposing providers; explicitly clear identity-scoped external preferences during replacement/deletion. Keep microphone streams, current playback and unfinished exercises transient.

**Tech stack:** Flutter/Dart, path_provider, shared_preferences, flutter_secure_storage, Tim2Tox.

## Task 1: Crash safety and training recovery

Files: `apps/morsecq/lib/training/atomic_json_file.dart`, the typed training stores/controller/host and `apps/morsecq/lib/i18n/key_value_store.dart`; corresponding store and host tests.

1. Reproduce overlapping saves/deletes against real temporary files, restart restoration, backup fallback and same-identity restore invalidation with regression tests. Run them before fixing.
2. Serialize write/delete/read operations so a shared staging path cannot race and a reset cannot resurrect deleted progress. Preserve the previous valid document and recover backups for missing, corrupt or structurally invalid primaries.
3. Ensure cached training controllers reload when the same identity is restored, and verify late loads or writes cannot overwrite a replacement identity.
4. Run relevant Flutter tests and analyzer. Respect the 500-line gate.

## Task 2: Persist app preferences

Files: `apps/morsecq/lib/di/app_scope.dart`, app settings and a preference coordinator, notification/playback/reference/listen settings and their screens; new persistence tests.

1. Add restart tests using a reopened file store for theme, notifications, chat WPM/Farnsworth/tone/training mode, reference playback, and microphone decoder options.
2. Restore and save these choices through the existing app settings store. Keep isolated widgets functional with default settings when no provider exists. Validate malformed/unsupported values without dropping unrelated valid preferences.
3. Scope conversation mute choices by identity; restore them on identity changes and avoid saving during hydration. Surface/log asynchronous persistence failures.
4. Verify shared settings work on mobile and desktop and screen recreation retains selections.

## Task 3: Identity and chat durability

Files: `packages/morsecq_chat/lib/src/{identity,adapters,engine,chat}`, backend wiring, native platform configuration and corresponding tests.

1. Trace creation/open/unlock/password changes/profile changes/delete/import/export, including secure-store failure and malformed records. Verify actual Tim2Tox savedata, friends/groups, pending requests/invites, histories, unread/read state, offline queue, drafts/pins/hidden rows and group identity keys.
2. Add tests for stale scoped preferences after deletion/replacement (including full-ID draft keys), repeated profile edits, and restore/restart. Clear only relevant identity keys, preserving global network settings and unrelated accounts.
3. Check native plugin registrations, writable paths and Apple Keychain entitlements against installed plugin code. Fix only verified defects; never edit third_party in place.
4. Confirm background/close paths flush durable state where required. Use supplemental Opus plan review before any material additional design change.

## Validation and delivery

Additional confirmed lifecycle requirements: add optional `PersistentIdentityService` / `IdentityDataStore` contracts in `morsecq_chat_api` so the training host can register a flush/replacement barrier without introducing backend imports. Before export/background, flush the registered stores and native savedata/history; before delete/import, dispose and drain stores before touching identity files, then publish a null/new identity boundary. Flush compose drafts on background as well as dispose. For unprovisioned macOS distribution use the plugin-supported legacy Keychain (`MacOsOptions(usesDataProtectionKeychain: false)`); iOS retains the data-protection Keychain and declares Keychain Sharing. Verify group unread counters survive restart rather than relying on Tim2Tox's volatile group counter.

Run the app and backend test suites, all pure Dart package tests, analyzers, complexity/import/ARB gates, and available native smoke/relaunch tests. Document the storage inventory and results in English and Chinese, clearly identifying platforms without native execution. Run read-only Claude Opus review of the actual diff; verify and fix credible findings before reporting completion. Keep the worktree available for review.

## Change log

- 2026-10-01: Initial audit plan based on missing preference wiring, non-serialized staging files and external identity preference cleanup gaps.
- 2026-10-01: Add verified background flush, training replacement barriers, group unread audit and Apple secure-store configuration requirements.
- 2026-10-01: Add pending-friend-request cache and scoping for the verified unscoped dismissed-request key. Group unread already restores from persisted history; test that path before changing it. Opus plan review and its identical retry both failed due to the reviewer account session limit; proceed with reproduced tests and independent local review, without claiming external approval.

- 2026-10-01: Retain failed per-key preference snapshots, rollback failed desktop selections, flush independent stores despite another failure, and resume controllers/chat/drafts after aborted replacement. Add an isolated Secret Service/keyring session to Linux e2e CI. Supplemental read-only Opus plan review and its identical retry again failed due to the same session quota.
- 2026-10-01: Final local verification passed: 477 app tests, 401 package tests including the final 71 chat tests, 2 native Tox tests, 4 native storage tests on each of macOS/iOS/Android, zero analyzer issues and all project gates. Final actual-diff Opus review plus identical retry failed on the reviewer session limit; no external approval claimed.

- 2026-10-01: User requested commit and local merge. Reverified 477 app tests serially, 71 chat tests, analyzers and project gates; documented the unchanged account harness's parallel real-timer/I/O timing failures. Integrate all 82 audit files into ci/installers while preserving its existing installer edits.
