# Real product screenshots

Run `bash tool/screenshots/capture.sh --platforms macos --locales en,zh`, or select ios, ipad, android, linux or windows. The screenshot test writes only a temporary local learning profile and drives the real Flutter UI with learning fixtures. It needs no Tox or account.

All platforms have nine scenes: learn_home, stats, training_settings, receive_drill, send_practice, reference, translator, listen and me. A complete locale/scene set must pass dimensions, non-empty and duplicate-frame checks before replacing a gallery. Use `--from <CI screenshot root>` to import remote results; source/output directories must not overlap.

iOS/iPad auto-select App Store size simulators. Desktop defaults to 1280×800. Options include `--out`, `--keep`, `--device` and `MORSECQ_SHOT_THEME`. Never use former chat screenshots to represent the current offline product. `doc/designs/product-2026-10-08/` contains concepts, separate from real screenshots.
