# MorseCQ

[简体中文](README.zh-CN.md)

MorseCQ is an account-free, offline Morse code trainer. Install it and start learning immediately. Chat has moved to the independent [DitMesh](https://github.com/agentx-icu/ditmesh) app.

MorseCQ keeps Koch lessons, placement assessment, spaced review, receive drills, straight-key and iambic sending practice, simulated radio QSOs, saved materials, progress statistics, the Morse reference and translator, Chinese telegraph codes, microphone decoding, recorded-audio copying and amateur-radio tools. Touch and physical keyboard keying work on phones, tablets and desktops. The interface supports ten locales and five visual styles.

Navigation is **Learn / Reference / Me**. No registration, Tox identity, messaging SDK, contacts, groups, chat notifications or chat network service is included. Microphone permission is requested only for live audio decoding. File selection and sharing serve local learning materials.

![MorseCQ offline product concept](doc/designs/product-2026-10-08/product-concept.png)

The [current product concept](doc/designs/product-2026-10-08/README.md) describes the offline split. Product screenshots come from real builds through the [capture pipeline](tool/screenshots/README.md); see the [screenshot gallery](doc/screenshots/README.md). Concepts are labelled separately from screenshots.

## Run and verify

Use Flutter **3.41.9** with Dart **3.11.5**, plus the host platform's normal Flutter build tools. Resolve this Pub workspace once at the repository root:

```sh
dart pub get
cd apps/morsecq
flutter run -d macos
```

No submodule checkout, chat bootstrap, Tox native library, backend flag or account setup is required.

```sh
# From the repository root
bash tool/test_pyramid.sh --level gates
bash tool/test_pyramid.sh --level unit
bash tool/test_pyramid.sh --level widget
./build_all.sh --platform macos --mode release
bash tool/ci/package_artifacts.sh --target macos
```

Android, iOS, macOS, Linux and Windows are required release targets. [Build and release instructions](doc/operations/BUILD_AND_DEPLOY.md) describe the CI jobs, output packages, signing and draft GitHub Releases.

## Local learning data

Learning data is stored locally under `<application support>/morsecq/guest/`: `training/` contains progress, settings and learning documents; `media/recordings/` contains managed audio. App-wide preferences are stored in `settings.json`. Me’s clear action flushes pending writes and removes current learning data after confirmation. Android platform backup is disabled; uninstalling can remove local data.

## Project layout

- `packages/morse_core`: pure Dart alphabet, timing, encoder/decoder and Chinese telegraph codes.
- `packages/morse_trainer`: pure Dart lessons, assessment, spaced review, scoring and simulated QSO models.
- `packages/morse_dsp`: pure Dart audio decoding and WAV reading.
- `packages/radio_tools`: pure Dart locator, distance, bands, CW speed and RST utilities.
- `packages/morse_io`: Flutter audio, keying and haptics.
- `apps/morsecq`: offline application, local persistence and desktop shell.

[Local learning architecture](doc/architecture/OFFLINE_LEARNING.md) · [Testing](doc/testing/TEST_PYRAMID.md) · [Validation record](doc/VALIDATION.md) · [Privacy](site/privacy.md) · [Support](site/support.md) · [License](LICENSE)
