[简体中文](./PERSISTENCE_AUDIT.zh-CN.md)

# Offline persistence audit — 2026-10-08

MorseCQ stores learning and preferences locally and opens directly into Learn. `<support>` is the application's platform support directory returned by path_provider; `<learning>` is `<support>/morsecq/guest`. Data is independent of the process working directory and the installed application bundle.

| Durable content | Location | Save/reopen behavior |
| --- | --- | --- |
| Course completion, first-lesson timestamp, recognition pace, guided-send stage, SRS cards, plan steps, completed session history, mistake notebook, comprehension records and the chosen learning goal | `<learning>/training/progress.json` | Validated atomic JSON replacement with a previous-save backup; a fresh controller reloads committed data. |
| Training speed, playback and pedagogy defaults | `<learning>/training/settings.json` | Validated and serialized local settings. |
| Materials, workbench documents, recording metadata, send-rhythm details, telegraph-code sessions, QSO drafts and parked QSO results | `<learning>/training/docs/` | Named JSON documents with atomic replacement and previous-save recovery. |
| Recorded audio | `<learning>/media/recordings/` | Metadata permits only safe relative recording filenames. `<learning>/media/recordings_kept.json` lists recordings a backup restore must keep. |
| Language, appearance, reference playback, decoder and physical-key preferences | `<support>/settings.json` | One file-backed key/value store. Style and brightness share `appearance.preferences`; defaults are Modern/system. Successful writes precede visible appearance changes; failed writes preserve the committed state. |
| Desktop window bounds/maximized and tray preferences | `<support>/settings.json` | Bounds are checked against current displays; close-to-tray and quit follow persisted choices. |

Live audio, microphone buffers, pressed keys, selected pages, translator scratch text and unfinished exercise input remain session state. Completed sessions and chosen defaults are durable. Materials and media can be shared using their dedicated tools; those operations are distinct from a whole-application backup. The storage layer for a portable learning backup exists (see the [learning architecture](../architecture/OFFLINE_LEARNING.md#backup-storage-layer)) but has no user-facing action yet.

Unsent QSO replies are resumable drafts: visible typed text and released keyed
patterns enqueue a checkpoint 400 ms after the first dirty edit, coalescing
subsequent edits into the latest snapshot. Continuous input does not postpone
that checkpoint; completion still depends on successful file IO. Clear, submit,
mode changes, backgrounding and disposal share the same snapshot path; completed
or disposed screens cannot leave a timer that recreates an old draft. Held keys
and playback stay transient. `qso_visible_draft_test.dart` reopens the real file
store with a new controller while the original screen is still visible, and
covers failed writes, retry and completion/replacement races. This verifies the
local B2/X7 checkpoint, not Windows session-end or Linux SIGTERM delivery;
termination before a checkpoint or during unsuccessful IO can still lose edits.

`AppScope` flushes preferences, locale, key profiles and the shared training controller together. Preference failures remain dirty for retry; another setting cannot erase the failure. Backgrounding uses the platform background-task bridge where available. Desktop quit waits for persistence and propagates unresolved errors. Confirmed Clear learning first flushes and retires the active controller, deletes local training/media, then reloads an empty controller so a delayed writer cannot resurrect cleared data. App-wide language/appearance/window choices remain available.

Regression coverage includes concurrent file writes, malformed JSON recovery, preference error/retry and appearance restart behavior; first launch, background flushing, clear durability and learning-UI reload; plus real-platform learning/preference reopening in `integration_test/persistence_test.dart`. On the device file system, `integration_test/storage_contract_test.dart` covers the lifecycle barrier before a kill, clearing racing a late write, corrupt-progress recovery and rapid unawaited writes; `integration_test/app_storage_lifecycle_test.dart` drives the real app through backgrounding with the native background task, the desktop quit hook and the Me page's confirmed clear, each followed by a relaunch. The desktop E2E workflow executes every integration test and the actual UI walk on macOS, Linux and Windows. Fresh counts, CI links, device evidence and artifact verification are maintained in [the validation record](../VALIDATION.md), with [Chinese details](../VALIDATION.zh-CN.md). Reproduce gates and suites through `tool/test_pyramid.sh`; the screenshot and visual-matrix workflows are documented in [the screenshot guide](../../tool/screenshots/README.md).

If application-support storage cannot open, preferences fall back to memory and log the error; they then cannot survive restart. Learning-store failures surface a retryable state. Atomic JSON replacement and previous-save files reduce incomplete-file failures; they do not prove power-loss or force-kill durability.

## Cross-platform update — 2026-10-22

Desktop acquires a process-wide support-directory lock before any settings or
learning store opens, and keeps it until process exit. Later launches request
activation over authenticated loopback IPC. Future progress/settings schemas
raise `UnsupportedDataVersion` through the atomic loader and controller, show an
update-required state, and are not renamed, recovered over or overwritten.
Repeated corrupt files keep distinct recovery copies. Telegraph recall already
had a write guard; its codec now also rejects newer schemas explicitly.
Android now opts the local learning directory and settings into OS backup and
device transfer, subject to system settings and the 25 MB cloud quota. Actual
restore/transfer still needs a device. Window close defaults to quit; Me offers
a persisted tray option, usable only with a live tray host. Native cancelable
exit requests wait for saves. Forced termination and Windows session-end
callbacks remain outside this verified guarantee.
