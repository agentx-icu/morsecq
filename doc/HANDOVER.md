[简体中文](./HANDOVER.zh-CN.md)

# MorseCQ maintenance guide

Start with the [README](../README.md), [learning architecture](architecture/OFFLINE_LEARNING.md), [advanced learning](architecture/ADVANCED_LEARNING.md), [build guide](operations/BUILD_AND_DEPLOY.md) and [test pyramid](testing/TEST_PYRAMID.md). Executed checks are in the [validation record](VALIDATION.md); the [persistence audit](testing/PERSISTENCE_AUDIT.md) and [learning and training audit](testing/LEARNING_TRAINING_AUDIT.md) list what each learning entry saves and how it is tested. The [documentation index](README.md) lists every current page.

Preserve the first-lesson path from dit/dah and K/M to guided recognition, guided sending and independent challenges. Keep lesson advancement tied to independent per-character evidence. Cover progress reopening, background saves, retry behavior and confirmed learning-data removal when changing persistence.

Keep assisted practice, comprehension scores and simulated QSOs out of Koch unlocks and per-symbol mastery. New learning records belong in `TrainerProgress` or a validated `training/docs/` document so that reopening, clearing and the backup storage layer see them.

Five of the six `packages/` (all but `morse_session`) are shared with DitMesh. A change there needs `tool/shared_sync.dart` re-pinning and, when the copies differ, a divergence rule; see the [shared-package procedure](testing/TEST_PYRAMID.md#shared-packages).

Use phone and desktop layouts to check all ten languages and five styles; the Layout CI catches overflow, clipping and inset problems on pushes to and pull requests against `main`/`master`. Device checks cover microphone decoding, key timing, haptics, learning-material selection and local persistence.
