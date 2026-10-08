# Test pyramid

Run `tool/test_pyramid.sh --level gates|unit|widget|e2e|all` from the root. Gates cover zero-issue analysis, complexity, import and localization boundaries. Unit tests cover Morse core, trainer, DSP, audio I/O and radio tools. Widget tests cover local learning, keying, reference, recordings, statistics and settings. E2E launches the real app, reopens local persistence and walks nine screenshot scenes.

A default installation must open Learn immediately without an account and expose only Learn / Reference / Me. Confirmed clearing flushes pending writes, retires the active controller, deletes learning files and reloads empty learning state. Backgrounding and desktop quit flush local persistence.

E2E: `bash tool/test_pyramid.sh --level e2e --device macos`. Screenshots: `bash tool/screenshots/capture.sh --platforms macos --locales en,zh`. Enable E2E CI with manual dispatch or the `ci:e2e` PR label. No backend flags or native chat tests are needed.

The opt-in Visual matrix CI renders ten languages and five styles in light/dark on phone and desktop: 38 deduplicated profiles and 76 real PNGs. It runs with the same `ci:e2e` label or manual dispatch; see the [screenshot guide](../../tool/screenshots/README.md). Custom capture profiles require a separate explicit output so canonical galleries stay intact.
