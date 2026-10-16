[简体中文](./README.zh-CN.md)

# Current documentation

Start with the [maintenance guide](HANDOVER.md). Every page below also has a Simplified Chinese version linked at its top.

## Product and architecture

- [Offline learning architecture](architecture/OFFLINE_LEARNING.md): storage, lifecycle, learning evidence and the backup storage layer
- [Advanced learning](architecture/ADVANCED_LEARNING.md): mistake notebook, comprehension, goal routes and simulated QSOs
- [Current product concept](designs/product-2026-10-08/README.md) and [visual styles](designs/ui-styles-2026-10-01/README.md)
- [Application layout](../apps/morsecq/README.md), [desktop shell](../apps/morsecq/lib/desktop/README.md) and [localization](../apps/morsecq/lib/l10n/README.md)
- Shared packages: [morse_core](../packages/morse_core/README.md), [morse_trainer](../packages/morse_trainer/README.md), [morse_dsp](../packages/morse_dsp/README.md), [morse_io](../packages/morse_io/README.md) and [radio_tools](../packages/radio_tools/README.md)

## Testing and validation

- [Test pyramid](testing/TEST_PYRAMID.md), including layout CI and shared-package sync
- [Persistence audit](testing/PERSISTENCE_AUDIT.md)
- [Learning and training audit](testing/LEARNING_TRAINING_AUDIT.md)
- [Validation record](VALIDATION.md)

## Build, release and assets

- [Build and release](operations/BUILD_AND_DEPLOY.md)
- [App Store and Google Play build](release/APP_STORE.md)
- [Adding a language](i18n/ADDING_A_LANGUAGE.md)
- [Screenshot gallery](screenshots/README.md) and [capture pipeline](../tool/screenshots/README.md)
- [Website](../site/README.md): product, privacy, terms and support pages
