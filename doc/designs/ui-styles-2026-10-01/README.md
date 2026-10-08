[简体中文](./README.zh-CN.md)

# MorseCQ visual styles

Style concepts and archived implementation previews from 2026-10-01. Current learning screens are in the [product concept](../product-2026-10-08/README.md) and [screenshot gallery](../../screenshots/README.md).

| Style | Visual direction | Experience |
|---|---|---|
| Classic Brass | Warm brass Material colors | Traditional radio feel |
| Modern Calm | White, teal and fine borders | Clear hierarchy; default style |
| Night Radio | Navy, mint and amber with monospace Morse | Focused practice and night use |
| Paper Handbook | Paper white, terracotta and fine rules | Reading and reference |
| Fresh Cartoon | Mint, cream, pale blue and soft corners | Relaxed learning |

## Concepts

![Modern Calm](./a-modern-en.png)
![Night Radio](./b-radio.png)
![Paper Handbook](./c-paper.png)
![Fresh Cartoon](./d-cartoon.png)
![Appearance settings](./appearance-switcher.png)

## Appearance controls

Open Me → Appearance, choose a style and System/Light/Dark brightness, then Apply Style. Restore Defaults previews Modern Calm with System brightness. Changing appearance preserves course progress and playback settings.

Keep Morse text readable, key feedback immediate and touch targets at least 44 logical pixels. Selection and playback states use cues beyond color. Decorative animations respect reduced motion.

## Archived widget previews

| Style | Desktop | Phone |
|---|---|---|
| Classic Brass | [Open](./implementation-previews/classic-desktop.png) | [Open](./implementation-previews/classic-phone.png) |
| Modern Calm | [Open](./implementation-previews/modern-desktop.png) | [Open](./implementation-previews/modern-phone.png) |
| Night Radio | [Open](./implementation-previews/radio-desktop.png) | [Open](./implementation-previews/radio-phone.png) |
| Paper Handbook | [Open](./implementation-previews/paper-desktop.png) | [Open](./implementation-previews/paper-phone.png) |
| Fresh Cartoon | [Open](./implementation-previews/cartoon-desktop.png) | [Open](./implementation-previews/cartoon-phone.png) |
| Appearance chooser | [Open](./implementation-previews/appearance-desktop.png) | [Open](./implementation-previews/appearance-phone.png) |

Generate current previews from `apps/morsecq` with `test/appearance/style_render_test.dart`. Pass `MORSECQ_RENDER_STYLES=true`, an absolute `MORSECQ_STYLE_RENDER_DIR`, and `MORSECQ_PREVIEW_FONT` pointing to a Chinese font file through `--dart-define`.
