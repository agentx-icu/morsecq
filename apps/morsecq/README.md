[简体中文](./README.zh-CN.md)

# MorseCQ application

This offline Flutter app combines `morse_core`, `morse_dsp`, `morse_io`, `morse_trainer`, `radio_tools` and `morse_session` into Learn, Reference and Me. Preferences and learning data are local. Android release builds prompt for first-run consent before Learn opens. The app keeps policy, permissions and help available offline in **Me → Privacy and permissions** on every platform.

## Run and test

Run these from the workspace root with Flutter 3.41.9 and Dart 3.11.5.

```sh
dart pub get --enforce-lockfile
(cd apps/morsecq && flutter run -d macos)
```

Replace `macos` with an ID from `flutter devices`. Run app analysis and hermetic widget checks from the workspace root.

```sh
flutter analyze apps/morsecq
bash tool/test_pyramid.sh --level widget
```

Run all native integration tests on the host desktop with `bash tool/test_pyramid.sh --level e2e` or add `--device <id>`. To run only the privacy and offline support flow on macOS, use `(cd apps/morsecq && flutter test integration_test/privacy_walk_test.dart -d macos)`. See the [test pyramid](../../doc/testing/TEST_PYRAMID.md) for coverage and required device checks.

## Keyboard shortcut

With Reference selected, Command+K on macOS/iOS or Ctrl+K on Windows/Linux/Android focuses its search field. The command applies to the current route, leaves focused editors and IME composition to the text input system and ignores held-key repeats. The sidetone intent has no shell binding yet. Native menus and physical iPad keyboard validation remain pending.

## Application layout

| Path | Owns |
| --- | --- |
| `lib/main.dart`, `lib/di/` | Startup, `AppScope` services, `settings.json` preferences and Android release consent in `privacy.json` |
| `lib/i18n/`, `lib/l10n/` | Language selection and resolution; ARB resources and generated localizations ([localization](lib/l10n/README.md)) |
| `lib/training/` | `TrainingController` (`morse_session`'s `TrainingCore` with `ChangeNotifier`), `TrainingControllerHost`, `dart:io` document stores and the backup storage layer |
| `lib/keying/`, `lib/lifecycle/` | Physical-key profiles; the native background-task bridge |
| `lib/ui/` | The Learn / Reference / Me shell, learning, reference, statistics, recording workbench, appearance and radio-tool screens |
| `lib/ui/legal/`, `lib/diagnostics/` | In-app privacy, permissions and support pages, and local diagnostic capture and copy |
| `lib/desktop/` | Window, tray and quit handling ([desktop shell](lib/desktop/README.md)) |

See the [offline architecture](../../doc/architecture/OFFLINE_LEARNING.md), [build guide](../../doc/operations/BUILD_AND_DEPLOY.md) and [documentation index](../../doc/README.md).
