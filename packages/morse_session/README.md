[简体中文](./README.zh-CN.md)

# morse_session

The learning-session layer of MorseCQ as **pure Dart** (no Flutter, no
`dart:io`): the training controller core, receive and send sessions, the one
commit path for scored exercises, verdicts, the drill catalog, training
settings, store interfaces, document codecs and the atomic document writer.
It sits between `morse_trainer` (pedagogy models) and the hosts: the Flutter
app and the mini-program bridge both drive the same controller.

This package is specific to MorseCQ and is **not** shared with DitMesh
(`tool/shared_packages.lock.json` pins the other five).

## What lives here

| Area | Types |
| --- | --- |
| Controller core | `TrainingCore`: loads progress and settings, exposes the Koch position, SRS due list and streak, serializes writes, keeps a failed save's result in memory for `retryProgressSave`, `flush`, `close`. `notifyListeners()` is abstract; `dispose()` runs the idempotent `retireCore()`. |
| Session starters | Extensions on `TrainingCore`: `ReceiveSessionStart` (lesson challenge, guided levels, onboarding, practice kinds, review, focus), `SendPracticeStart`, `TrainingPlan`, `QsoPractice`, `MistakePractice`, `MaterialPractice`, `TelegraphSessions`, `AdvancedLearning`. |
| Sessions | `ReceiveSession` / `ReceiveRound`, `SendSession` (implements `SendKeyTarget`), `recordReceiveSession`, `applyExercise` (credit, dedupe, unlock), `ReceiveVerdict` / `verdictOf`, `DrillCatalog`. |
| Settings and documents | `TrainingSettings`, `TrainingSettingsStore` + `TrainingSettingsCodec`, `TrainingDocStore`, `TrainerProgressCodec`, `MaterialStore`, `AudioMaterialStore`, `SendDetailStore`. |
| Storage algorithm | `AtomicDocument` over a host-supplied `DocumentFs`: temp file, validate the previous document, rotate it to `.bak` or set a corrupt one aside, rename into place; defensive reads with backup fallback. |

## Hosts

- The app (`apps/morsecq/lib/training/`) declares
  `TrainingController extends TrainingCore with ChangeNotifier`, implements
  `DocumentFs` over `dart:io` (`AtomicJsonFile`) and keeps the file stores, the
  backup layer and the host that shares one controller between screens.
- The mini-program bridge (planned) subclasses `TrainingCore` with a JavaScript
  callback and implements `DocumentFs` over the mini program's file system.

The import gate (`tool/import_guard.dart`, rule `pure-dart-session`) forbids
Flutter, `dart:io`, `package:path` and the `morse_io` barrel here, so the
package stays compilable with dart2js.

## Tests

`dart test` from this directory (or `flutter test`, as CI runs for every
package). Tests use `TestTrainingCore` from `test/helpers/test_core.dart`, the
in-memory stores, a fixed clock and a seeded `Random`.
