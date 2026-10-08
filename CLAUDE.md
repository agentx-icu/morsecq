# Contributor guidance

MorseCQ is an account-free, offline Morse trainer. All five platforms open
Learn / Reference / Me immediately. Chat belongs to the independent DitMesh
repository. No account, registration, messaging package, transport library,
network bootstrap or historical-data import belongs in this workspace.

## Workspace

Run Pub resolution once from the repository root with Flutter 3.41.9 / Dart
3.11.5: `dart pub get --enforce-lockfile`. The root lockfile is committed.

- `morse_core`, `morse_trainer`, `morse_dsp` and `radio_tools` stay pure Dart.
- `morse_io` supplies Flutter audio, screen flash, haptics and touch/keyboard keys.
- `apps/morsecq` owns the three-destination shell, local learning controller,
  JSON stores, localization, reference/radio tools and desktop lifecycle.
- `tool/` owns architecture/localization/complexity gates, packaging and captures.

`LocalLearningStore` opens the device-local learning directory.
`TrainingControllerHost` shares and retires the controller. Backgrounding and
quitting await local writes; confirmed clearing retires the controller before
removing active learning files. Appearance/language and device preferences stay
available. Read `doc/architecture/OFFLINE_LEARNING.md` for the storage contract.

## Teaching invariants

The first lesson teaches hearing dit/dah and K/M before independent copying.
Guided receive and send sessions supply practice and honest feedback.
Only `startLessonSession()` and an unlock-eligible course-plan step advance the
course. `LessonChallengeDrill` covers the lesson's new symbols; passing requires
50 symbols at 90% overall and each new symbol copied at least ten times at 90%.
Assisted/free practice does not unlock lessons. `ReceiveVerdict` drives summary
wording, and `courseCompleted` records the final pass rather than just reaching
lesson 42. Readiness, available drills, daily plans and speed advice follow the
learned symbols and recent independent evidence. Simulated radio QSOs are local.

## Verification and documentation

```sh
flutter analyze --no-pub
dart analyze --fatal-infos tool
dart run tool/check_complexity.dart
dart run tool/import_guard.dart
dart run tool/ui_literal_guard.dart
bash tool/test_pyramid.sh --level unit
bash tool/test_pyramid.sh --level widget
python3 tool/screenshots/capture_import_test.py
```

The complexity gate caps production files at 500 lines with its recorded
baseline; do not suppress failures. The import gate forbids chat/transport SDKs
and protects pure-Dart packages. User-facing strings come from ARB resources.
Regenerate localization after changing keys. Keep all ten canonical locales
and five styles, light/dark/system themes, narrow layouts and physical keys.

Use real native integration tests and the capture pipeline for product images.
The default gallery has twelve offline scenes; custom language/style/theme
profiles require a separate explicit output. The bounded actual-font visual
matrix checks language, style and phone/desktop coverage. Never copy product
screenshots from a build with accounts or chat, or edit them manually.

Documentation is bilingual. Keep current product/runtime facts in READMEs,
architecture, testing, store/policy pages and build guides. `doc/plans/` is local
working material, ignored by Git; published docs must not link into it.
Do not commit generated build outputs or recordings. Release tags require all
five platform jobs and the complete ten-asset checksum verifier. Release jobs
create drafts; distribution needs the owner's signing/notarization setup.

Use meaningful regressions and appropriate local/CI checks. User instructions
prohibit RTK and Claude-based reviews; do not load or invoke those workflows.
