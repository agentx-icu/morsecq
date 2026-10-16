[简体中文](./README.zh-CN.md)

# MorseCQ application

The account-free offline Flutter app opens learning immediately. It wires the morse_core, morse_dsp, morse_io, morse_trainer and radio_tools packages into Learn / Reference / Me, with device-local preferences and learning data. No chat, account or transport package is required.

From the workspace root, run `dart pub get --enforce-lockfile`, `flutter analyze apps/morsecq` and `(cd apps/morsecq && flutter test --no-pub)`. Start with `(cd apps/morsecq && flutter run -d macos)` or a supported device. Native tests live in `integration_test/`; run them through `bash tool/test_pyramid.sh --level e2e --device <id>` or `tool/ci/run_integration_tests.sh -d <id>`.

| Path | Owns |
| --- | --- |
| `lib/main.dart`, `lib/di/` | Startup, `settings.json`, `AppScope` services and device preferences |
| `lib/i18n/`, `lib/l10n/` | Language selection and resolution; ARB resources and generated localizations ([localization](lib/l10n/README.md)) |
| `lib/training/` | `TrainingController`, `TrainingControllerHost`, local JSON stores and the backup storage layer |
| `lib/keying/`, `lib/lifecycle/` | Physical-key profiles; the native background-task bridge |
| `lib/ui/` | The Learn / Reference / Me shell, learning, reference, statistics, recording workbench, appearance and radio-tool screens |
| `lib/desktop/` | Window, tray and quit handling ([desktop shell](lib/desktop/README.md)) |

See the root [README](../../README.md), [offline architecture](../../doc/architecture/OFFLINE_LEARNING.md), [test pyramid](../../doc/testing/TEST_PYRAMID.md) and [build guide](../../doc/operations/BUILD_AND_DEPLOY.md).
