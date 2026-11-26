[简体中文](./README.zh-CN.md)

# Current documentation

For a first lesson or a local run, start with the [project README](../README.md). For maintenance, use the [maintenance guide](HANDOVER.md). Each guide below links to its Simplified Chinese edition.

## Using MorseCQ

- See the application on phones, tablets and desktop in the [screenshot gallery](screenshots/README.md).
- Find help with microphones, local data and bug reports on the [support page](../site/support.md) and in the [privacy policy](../site/privacy.md).

## Product and architecture

- [Offline learning architecture](architecture/OFFLINE_LEARNING.md): storage, lifecycle, learning evidence and the backup storage layer
- [Advanced learning](architecture/ADVANCED_LEARNING.md): mistake notebook, comprehension, goal routes and simulated QSOs
- [Product concept](designs/product-2026-10-08/README.md) and [archived visual styles](designs/ui-styles-2026-10-01/README.md)
- [Application layout](../apps/morsecq/README.md), [desktop shell](../apps/morsecq/lib/desktop/README.md) and [localization](../apps/morsecq/lib/l10n/README.md)
- Shared packages: [morse_core](../packages/morse_core/README.md), [morse_trainer](../packages/morse_trainer/README.md), [morse_dsp](../packages/morse_dsp/README.md), [morse_io](../packages/morse_io/README.md) and [radio_tools](../packages/radio_tools/README.md)
- Session layer: [morse_session](../packages/morse_session/README.md) (pure Dart, MorseCQ only)

## Testing and validation

- [Test pyramid](testing/TEST_PYRAMID.md), including layout CI and shared-package sync
- [Persistence audit](testing/PERSISTENCE_AUDIT.md)
- [Learning and training audit](testing/LEARNING_TRAINING_AUDIT.md)
- [Cross-platform audit](testing/CROSS_PLATFORM_AUDIT.md) records the 2026-10-22 fixes, evidence and device gaps.
- [First-success UI validation](testing/FIRST_SUCCESS_VALIDATION.md) and [beginner trial protocol](testing/BEGINNER_TRIAL.md)
- [Validation record](VALIDATION.md)

## Build, release and assets

- [Build and release](operations/BUILD_AND_DEPLOY.md)
- [App Store and Google Play build](release/APP_STORE.md)
- [Third-party distribution metadata](release/DISTRIBUTION_PACKAGING.md) · [Mainland China](release/CHINA_DISTRIBUTION.md) · [Windows](release/WINDOWS_DISTRIBUTION.md) · [Linux](release/LINUX_DISTRIBUTION.md)
- [F-Droid main-repository preparation](release/F_DROID.md): listing, source-built audio dependencies, candidate recipe and deferred inclusion
- [Store readiness and channel matrix](release/STORE_READINESS.md): artifact gates, policy sources and owner actions
- [Adding a language](i18n/ADDING_A_LANGUAGE.md)
- [Screenshot capture pipeline](../tool/screenshots/README.md)
- [Website](../site/README.md): product, privacy, terms and support pages
