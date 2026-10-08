# MorseCQ application

The account-free offline Flutter app opens learning immediately. It wires the morse_core, morse_dsp, morse_io, morse_trainer and radio_tools packages into Learn / Reference / Me, with device-local preferences, learning data. No chat, account or transport package is required.

From the workspace root, run `dart pub get --enforce-lockfile`, `flutter analyze apps/morsecq` and `(cd apps/morsecq && flutter test --no-pub)`. Start with `(cd apps/morsecq && flutter run -d macos)` or a supported device.

See the root [README](../../README.md), [offline architecture](../../doc/architecture/OFFLINE_LEARNING.md) and [build guide](../../doc/operations/BUILD_AND_DEPLOY.md).
