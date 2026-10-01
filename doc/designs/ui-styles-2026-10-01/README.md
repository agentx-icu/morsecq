[简体中文](./README.zh-CN.md)

# morsecq UI style proposals

Date: 2026-10-01. Status: the user approved all four additional styles. Commit the design artifacts separately and implement the application changes in a new worktree.

Based on the actual interfaces in `doc/screenshots/`, retain the five destinations: Learn, Chat, Groups, Reference, and Me. Add four styles and retain Classic Brass. Images were generated with the built-in image_gen tool; exact prompts are stored in `prompts.json`. These are visual concepts rather than screenshots of a running implementation.

| Option | Visual direction | Intended experience |
| --- | --- | --- |
| Classic Brass | Existing warm Material appearance | Default for existing users |
| A Modern Calm | White, teal, fine borders, distinct card hierarchy | Everyday learning and chat; recommended modern direction |
| B Night Radio | Navy charcoal, mint cyan, amber accents, instrument panels, monospace Morse | Focused practice and night use |
| C Paper Handbook | Paper white, terracotta, fine rules, rectangular editorial layout | Quiet reading, review, and reference |
| D Fresh Cartoon | Mint, cream yellow, pale blue and blush, soft corners, a small friendly radio character | A welcoming and relaxed learning experience |

## Visual concepts

![A Modern Calm: desktop learning and mobile chat](./a-modern.png)

![B Night Radio: desktop learning and mobile keying](./b-radio.png)

![C Paper Handbook: desktop and mobile learning](./c-paper.png)

![D Fresh Cartoon: desktop and mobile learning](./d-cartoon.png)

![Appearance settings with five styles](./appearance-switcher.png)

## Switching experience

- Main entry: Me → Appearance. An optional desktop header shortcut opens the same page.
- Five style cards show miniature interfaces. Selection uses both an outline and a checkmark.
- Brightness is independent: System, Light, or Dark. Night Radio is illustrated in dark mode and the other concepts in light mode; both modes are planned for every style.
- Selecting a card updates the preview. Apply Style updates the application and saves the settings. Leaving without applying retains existing settings.
- Restore Defaults previews Classic Brass with System brightness; Apply Style confirms the reset.
- Preferences belong to the device and remain independent of training identity. Applying preserves the current destination, chat draft, course progress, playback, and keying state.
- Mobile uses a full appearance page, with style cards before brightness and preview; the apply action stays easy to reach.

## Shared interface constraints

- New styles arrange K, M, R, S, and U in one row so character lists do not fill the initial mobile viewport. Continue Course and practice entries take priority.
- 27 / 30 and 90% represent completion of the daily goal, not accuracy. Lesson 4 / 42 uses course progress.
- Morse uses readable monospace characters. Content, audio playback, and dot/dash controls take priority over decoration.
- Cartoon illustration is a small supporting element; no points, medals, levels, or other additional features are introduced.
- All styles share the five destinations, existing functionality, and input methods: touch keying on mobile and keyboard keying on desktop.
- Touch targets are at least 44 logical pixels. Chinese body text remains readable. Selection, online, playback, and pressed states use cues beyond color alone.
- Appearance transitions never delay key feedback or alter audio timing. Decorative animations stop when reduced motion is enabled.

## Confirmation

The user approved Modern Calm, Night Radio, Paper Handbook, and Fresh Cartoon, and requested a design-artifact commit followed by development in a new worktree. Keep Classic Brass as the default; select the additional styles from Appearance. This proposal does not replace the existing product plan.

## Revision log

- 2026-10-01: Designed three additional styles and appearance settings from existing screenshots.
- 2026-10-01: Added Fresh Cartoon at the user's request and expanded the chooser to five styles.
- 2026-10-01: The user approved all four styles and requested development in an isolated worktree.
