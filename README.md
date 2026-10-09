# MorseCQ

[简体中文](README.zh-CN.md)

MorseCQ is an account-free offline Morse code trainer. Open the app and start learning. For Morse chat, use [DitMesh](https://github.com/agentx-icu/ditmesh).

Start by hearing dit/dah and K/M, then practise guided recognition and sending before independent copying. Koch lessons advance through challenges using per-character evidence. Practice summaries distinguish assisted exercises from course mastery. Assessment, spaced review, simulated QSOs with readiness hints, learning materials, statistics, reference, translation, Chinese telegraph codes, microphone decoding, recorded-audio workbench and amateur-radio tools support continued practice. Touch and physical keyboards work across phone, tablet and desktop, with ten interface languages and five visual styles.

Use **Learn / Reference / Me** to navigate. Microphone access is requested when you start live audio decoding; file selection and sharing let you work with your learning materials.

![MorseCQ product concept](doc/designs/product-2026-10-08/product-concept.png)

See the [product design](doc/designs/product-2026-10-08/README.md) and [screenshot gallery](doc/screenshots/README.md).

Advanced learning adds a persistent mistake notebook, whole-word and sentence comprehension, and first-QSO, conversation and contest goal routes. The simulator includes contest and park-to-park POTA exchanges, corrections and targeted repetition. Original offline exercises follow CW Academy intermediate learning directions; assisted attempts remain separate from independent mastery. See [advanced learning](doc/architecture/ADVANCED_LEARNING.md).

## Build and run

Use Flutter **3.41.9** with Dart **3.11.5** and the host platform's Flutter build tools. Resolve the Pub workspace at the repository root:

```sh
dart pub get --enforce-lockfile
cd apps/morsecq
flutter run -d macos
```

```sh
# From the repository root
bash tool/test_pyramid.sh --level gates
bash tool/test_pyramid.sh --level unit
bash tool/test_pyramid.sh --level widget
./build_all.sh --platform macos --mode release
bash tool/ci/package_artifacts.sh --target macos
```

Supports Android 7.0+, iOS 14+, macOS 13+, Linux and Windows. See the [build guide](doc/operations/BUILD_AND_DEPLOY.md) for platform tools and packaging commands.

## Your learning data

Progress, learning materials and recordings stay on your device. Use Me → Clear learning data to remove them after confirmation; language and appearance settings are preserved. Uninstalling the app may delete local data.

## Project layout

- `packages/morse_core`: alphabet, timing, encoder/decoder and Chinese telegraph codes.
- `packages/morse_trainer`: lessons, assessment, spaced review, scoring and simulated QSO models.
- `packages/morse_dsp`: audio decoding and WAV reading.
- `packages/radio_tools`: locator, distance, bands, CW speed and RST utilities.
- `packages/morse_io`: audio, keying and haptics.
- `apps/morsecq`: application, local persistence and desktop shell.

[Learning architecture](doc/architecture/OFFLINE_LEARNING.md) · [Testing](doc/testing/TEST_PYRAMID.md) · [Validation](doc/VALIDATION.md) · [Privacy](site/privacy.md) · [Support](site/support.md) · [License](LICENSE)
