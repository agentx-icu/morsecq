[简体中文](./README.zh-CN.md)

# Product screenshots and visual matrix

The default command drives the real morsecq application and preserves the canonical English/Simplified Chinese, Modern Calm, light-theme gallery. Six targets are supported: macos, linux, windows, ios (iPhone), ipad and android. Desktop captures use the host OS; mobile captures use a device/emulator. iPhone/iPad captures validate App Store dimensions and opaque RGB PNGs.

```bash
tool/screenshots/capture.sh --platforms macos
tool/screenshots/capture.sh --platforms android --device emulator-5554
tool/screenshots/capture.sh --locales zh_Hant,ja,ko --style paper --theme dark --out build/visual-paper
tool/screenshots/capture.sh --locales en,zh,zh_Hant,ja,ko,de,fr,es,pt,ru --style all --out build/visual-all
```

Canonical language tags are `en,zh,zh_Hant,ja,ko,de,fr,es,pt,ru`. Styles are `classic,modern,radio,paper,cartoon`; `--style all` captures all five into `<out>/<style>/<platform>/<locale>/<scene>.png`. A single style uses `<out>/<platform>/<locale>/<scene>.png`. Theme accepts `light,dark,system`. `MORSECQ_SHOT_STYLE` and `MORSECQ_SHOT_THEME` provide environment defaults; explicit flags override them. The harness applies the requested style and parses Traditional Chinese as the Hant script.

Every custom locale set, style or theme requires an explicit `--out` outside `doc/screenshots`, including aliases and descendant paths. The default canonical gallery is preserved. For completed captures from another host, use `--from /path/to/screenshots` with the same locale/style/theme arguments and a separate output. For `--style all`, the source contains one folder per style. Selected source directories/PNGs cannot be symlinks. Failed completeness, size or distinct-frame checks preserve that profile's prior gallery; different platform/style profiles are published independently.

`--keep` retains staging. `MORSECQ_SHOT_STAGING` sets its location; all-style runs use a separate child staging folder per style. `MORSECQ_SHOT_WINDOW` sets desktop logical size (default 1280x800), and `MORSECQ_SHOT_PIXEL_RATIO` overrides capture scale. The application is wrapped in a RepaintBoundary; PNGs travel through integration-test report data to the host driver. Navigation uses localized labels and stable keys, and every scene is asserted before capture. Seeded learning-material text can remain English as user-authored content; navigation, learning instructions and scene assertions use the selected locale.

The opt-in **Visual matrix** workflow runs on manual dispatch or the PR `ci:e2e` label. It loads real Noto CJK, mono and serif fonts and renders **38 profiles / 76 PNGs**: ten languages on phone and desktop using Modern/light, plus five styles in light/dark on phone and desktop using English (shared profiles are deduplicated). Representative scenes are `learn_home / reference`. This checks each axis without multiplying every language, style, brightness and platform. The artifact includes `manifest.json`; the existing E2E workflow still captures all product scenes on three real desktop hosts.

Parser/apply regressions run as ordinary Flutter tests in `test/screenshots/shot_config_test.dart`. Import/publication regressions use private PNG fixtures: `python3 tool/screenshots/capture_import_test.py`. The actual matrix renderer is opt-in (`MORSECQ_RENDER_MATRIX=true`, `MORSECQ_MATRIX_DIR`, `MORSECQ_MATRIX_FONT`, optional mono/serif font paths), so normal application tests do not export visual assets.

Each canonical platform requires **12 scenes / 24 PNGs** in English and Simplified Chinese: `learn_home,stats,training_settings,receive_drill,send_practice,first_lesson,receive_summary,guided_send,reference,translator,listen,me`. The three teaching scenes are reached through actual screens; the receive summary follows completed native audio playback and answers.
