[简体中文](./TEST_PYRAMID.zh-CN.md)

# The test pyramid

Four levels, bottom up. Each level is cheap enough to run before every push at
its own tier; the top one needs a device and is run on macOS before a release
and from the opt-in `e2e.yml` workflow.

```bash
tool/test_pyramid.sh                     # all levels, host desktop as the device
tool/test_pyramid.sh --level unit
tool/test_pyramid.sh --level e2e --device macos
```

| level | what | where | runs on | count (2026-09-30) |
|---|---|---|---|---|
| **gates** | analyzer (zero issues), 500-LOC complexity, import guard, ARB sync | `tool/*.dart` | every push, CI `analyze.yml` | — |
| **unit** | pure-Dart engines (`morse_core`, `morse_trainer`, `morse_dsp`), the chat contract and its in-memory fakes (`morsecq_chat_api`), the Tim2Tox transport (`morsecq_chat`, `needs-native` smoke excluded), Flutter I/O sinks and keyers (`morse_io`) | `packages/*/test` | every push, CI `analyze.yml` | 347 |
| **widget** | every screen with the fake backend, at phone and desktop sizes; startup gate, onboarding, chat, learn, stats, reference, listen, notifications, desktop shell, i18n | `apps/morsecq/test` | every push, CI `analyze.yml` | 405 |
| **integration (in-process)** | services wired the way `main()` wires them: `AppScope` → `AppServices` → fakes; the headless Tox smoke when `libtim2tox_ffi` is present (`needs-native`, `native.yml`) | `apps/morsecq/test/di`, `packages/morsecq_chat/test/native_smoke_test.dart` | with the widget tier; native workflow | part of the counts above |
| **e2e (real UI)** | the app's own `main()` on the real platform, driven the way a first-time user clicks: onboarding → every tab → a drill → add a friend and send a line → translator → Me; plus the screenshot walk of 17 scenes × 2 locales | `apps/morsecq/integration_test` | macOS before release; `e2e.yml` on demand; other platforms as the screenshot pipeline covers them | 3 tests, 34 frames |

The e2e tier always runs with `--dart-define=MORSECQ_FAKE_BACKEND=true`: the
in-memory backend keeps nothing on disk, so every launch starts at onboarding
and nothing is created on the device.

## What each tier is for

- **Unit** proves the maths and the protocol: timing, decoding, scoring, SRS,
  the fake services' behaviour that the widget tier relies on.
- **Widget** proves each screen's behaviour hermetically and fast (about 40 s
  for the whole app), on both layouts. It is where a bug's regression test
  normally lands.
- **In-process integration** proves the wiring, not the screens: that
  `AppScope` provides what the tree reads, that teardown order is right.
- **e2e** proves the things nothing below can: plugin initialisation on the
  real platform (window manager, tray, notifications, audio), the real
  `main()`, real navigation and text input, and — through the screenshots —
  that every scene renders without overflow in both languages.

## Bugs only the top tier found (2026-09-30, first run)

1. **Every debug launch on desktop crashed at first frame**: `AppScope`
   exposed the `DesktopShellController` (a `ChangeNotifier`) through a plain
   `Provider`, which provider's debug check rejects. Hermetic tests pass
   `desktopShell: null` and release builds skip the assert, so nothing lower
   could see it. Regression test now at the integration tier
   (`test/di/app_scope_desktop_shell_test.dart`).
2. **Add-friend sheet** tripped a framework semantics assertion ("invisible
   SemanticsNodes") while sliding away, on macOS and again on iOS: a
   `Tooltip` inside the Tox-ID field's suffix slot, laid out with a negative
   height by the shrinking sheet. The scan action is now a labelled button
   below the field on mobile (desktop keeps its hint line); the field has no
   suffix icon on any platform.
3. **Accuracy-trend chart** labelled sessions `1 2 3 5 6 7` (rounded
   fractional stride) and painted the axis caption over the last tick. Seen in
   the screenshots; fixed with an integer stride and a caption row.

## Adding tests

Put a test at the lowest tier that can observe the behaviour. A screen's
behaviour → widget. A wiring or lifecycle fact → `test/di`. Anything that
needs a plugin or the real `main()` → `integration_test/`, and add it to the
existing walk rather than a new file when it is a scene (see
`tool/screenshots/README.md`).
