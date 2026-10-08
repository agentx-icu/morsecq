[简体中文](./PERSISTENCE_AUDIT.zh-CN.md)

# Offline persistence audit — 2026-10-08

MorseCQ stores learning and preferences locally and opens directly into Learn. `<support>` is the application's platform support directory returned by path_provider; `<learning>` is `<support>/morsecq/guest`. Data is independent of the process working directory and the installed application bundle.

| Durable content | Location | Save/reopen behavior |
| --- | --- | --- |
| Course completion, first-lesson timestamp, recognition pace, guided-send stage, SRS cards, plan steps and completed session history | `<learning>/training/progress.json` | Validated atomic JSON replacement with a previous-save backup; a fresh controller reloads committed data. |
| Training speed, playback and pedagogy defaults | `<learning>/training/settings.json` | Validated and serialized local settings. |
| Materials, workbench documents and recording metadata | `<learning>/training/docs/` | Named JSON documents with atomic replacement and previous-save recovery. |
| Recorded audio | `<learning>/media/recordings/` | Metadata permits only safe relative recording filenames. |
| Language, appearance, reference playback, decoder and physical-key preferences | `<support>/settings.json` | One file-backed key/value store. Style and brightness share `appearance.preferences`; defaults are Modern/system. Successful writes precede visible appearance changes; failed writes preserve the committed state. |
| Desktop window bounds/maximized and tray preferences | `<support>/settings.json` | Bounds are checked against current displays; close-to-tray and quit follow persisted choices. |

Live audio, microphone buffers, pressed keys, selected pages, translator scratch text and unfinished exercise input remain session state. Completed sessions and chosen defaults are durable. Materials and media can be shared using their dedicated tools; those operations are distinct from a whole-application backup.

`AppScope` flushes preferences, locale, key profiles and the shared training controller together. Preference failures remain dirty for retry; another setting cannot erase the failure. Backgrounding uses the platform background-task bridge where available. Desktop quit waits for persistence and propagates unresolved errors. Confirmed Clear learning first flushes and retires the active controller, deletes local training/media, then reloads an empty controller so a delayed writer cannot resurrect cleared data. App-wide language/appearance/window choices remain available.

Regression coverage includes concurrent file writes, malformed JSON recovery, preference error/retry and appearance restart behavior; first launch, background flushing, clear durability and learning-UI reload; plus real-platform learning/preference reopening in `integration_test/persistence_test.dart`. The desktop E2E workflow executes that integration test and the actual UI walk on macOS, Linux and Windows. Fresh counts, CI links, device evidence and artifact verification are maintained in [the validation record](../VALIDATION.md), with [Chinese details](../VALIDATION.zh-CN.md). Reproduce gates and suites through `tool/test_pyramid.sh`; the screenshot and visual-matrix workflows are documented in [the screenshot guide](../../tool/screenshots/README.md).

If application-support storage cannot open, preferences fall back to memory and log the error; they then cannot survive restart. Learning-store failures surface a retryable state. Atomic JSON replacement and previous-save files reduce incomplete-file failures; they do not prove power-loss or force-kill durability.
