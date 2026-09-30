[简体中文](./README.zh-CN.md)

# Product screenshots (cross-platform)

One command boots the real app on a real device or desktop window, seeds demo
data, walks every product scene in English and Chinese, and publishes the
frames into the committed `doc/screenshots/<platform>/<locale>/`.

```bash
tool/screenshots/capture.sh                          # macOS (default), en + zh
tool/screenshots/capture.sh --platforms macos,ios,ipad,android
tool/screenshots/capture.sh --platforms android --device emulator-5554
tool/screenshots/capture.sh --locales zh --keep      # one language, keep staging
MORSECQ_SHOT_THEME=dark tool/screenshots/capture.sh  # env → --dart-define (see knobs)
```

Platforms: `macos`, `linux`, `windows` (the host desktop), `ios` (an iPhone
simulator), `ipad` (an iPad simulator), `android` (emulator or device). The
device is picked from `flutter devices` by platform, or given with `--device`.
Mobile simulators/emulators must already be running.

## How it works

The pipeline is a normal `integration_test`:

| piece | file |
|---|---|
| orchestrator (device pick, `flutter drive`, verify, publish) | `tool/screenshots/capture.sh` |
| the walk: scenes × locales on the real UI | `apps/morsecq/integration_test/screenshots_test.dart` |
| seed data (hero, friends, QSO, net, request, a week of training) | `apps/morsecq/integration_test/support/seed_data.dart` |
| navigation + the scene list `kScenes` | `apps/morsecq/integration_test/support/scene_walk.dart` |
| Flutter-layer capture, window sizing, theme pin | `apps/morsecq/integration_test/support/shot_harness.dart` |
| host side: writes the PNGs | `apps/morsecq/test_driver/integration_test.dart` |

- **Backend**: `--dart-define=MORSECQ_FAKE_BACKEND=true`. No Tox node, no
  disk; the fake services are seeded in-process through the test hooks of
  `package:morsecq_chat_api/testing.dart` (`addFakeFriend`, `receiveMessage`,
  `addFakeGroupMember`, …) and a `progress.json` written with
  `FileTrainerStore`, so the Learn home and Statistics have content.
- **Capture**: the app is wrapped in a `RepaintBoundary` and each scene is
  `toImage`d from the Flutter layer. This is the same on all five platforms,
  needs no OS permission and never grabs another window. (Flutter 3.41.9's
  `integration_test` has a native `takeScreenshot` only for Android and iOS.)
  The PNG bytes ride in `binding.reportData` (base64) to the `flutter drive`
  host, which writes `<platform>/<locale>/<scene>.png`.
- **Desktop window**: the harness resizes and centres the real window to
  `MORSECQ_SHOT_WINDOW` (default `1280x800`) through `window_manager`, then
  reads the achieved size back — macOS clamps to the visible frame (a 14"
  MacBook Pro gives 1280×768) and the frame is captured as-is.
- **Pixel ratio**: 1.0 on desktop, `min(dpr, 2)` on mobile, override with
  `MORSECQ_SHOT_PIXEL_RATIO`.
- **Theme**: pinned to light (`MORSECQ_SHOT_THEME=light|dark|system`) so the
  frames do not follow the host's appearance.
- **Locales**: each locale is a separate pass with its own seed copy (Chinese
  frames show Chinese names and a Chinese group; the Morse text stays in CW
  abbreviations, which is what is keyed on the air).
- **Publish gate**: a platform is copied into `doc/screenshots/` only when its
  `flutter drive` exited 0, every scene of every locale exists, is at least
  8 KiB, and no two frames are byte-identical (`cmp`, not just a checksum).
  The replacement set is assembled next to the target and swapped in whole;
  a failed platform leaves the committed frames untouched. Staging
  (`MORSECQ_SHOT_STAGING`, else a temp dir) is kept on any failure. A
  `--locales` subset is verified but not published into the gallery, which
  must always hold every locale; use `--out` for a partial set. `--device`
  ids are checked against the requested platform.

`flutter test integration_test/screenshots_test.dart -d <device>` runs the
same walk as a plain UI test (every scene must render without an overflow or a
missing widget) and discards the frames; `tool/test_pyramid.sh --level e2e`
uses it that way.

## Scenes

`welcome`, `create_identity`, `backup_wizard` (first run), then from a seeded
identity: `learn_home`, `stats`, `training_settings`, `receive_drill`,
`send_practice`, `chat_list`, `conversation`, `contacts`, `groups`,
`group_conversation`, `reference`, `translator`, `listen`, `me`.

Adding a scene: navigate + `shots.capture(tester, locale, 'name')` in
`scene_walk.dart`, add the name to `kScenes` there and to `SCENES` in
`capture.sh`, and add a row to `doc/screenshots/README.md`.

## Traps (all hit while building this)

- Two `pumpWidget` calls with a same-typed root **update** the existing element
  instead of replacing it, and `AppScope` keeps its first backend. Every app
  root in the walk carries a distinct `key`.
- `pumpAndSettle` throws on an endless animation (blinking caret, spinner);
  `settle()` in the harness catches that and moves on.
- A SnackBar sits over the composer's send button for 4 s; a synthetic tap
  lands on the toast and `flutter test` only prints a warning. Clear it
  (`ScaffoldMessenger.clearSnackBars()`) or assert on the result, never on the
  typed text.
- Android needs `morsecqAllowMissingFfi` for a UI-only build (no
  `libtim2tox_ffi.so` staged); `capture.sh` exports it as
  `ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true`. It also needs an arm64
  JDK on `JAVA_HOME` — a non-interactive ssh shell does not source the
  profile that sets it.
- From an ssh session the macOS window still renders and captures (the
  Flutter layer does not depend on the compositor), but do not steal focus
  while a run is in progress.
