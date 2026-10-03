[简体中文](./2026-10-03-interface-languages.zh-CN.md)

# Interface language expansion

**Goal:** Add Traditional Chinese, Japanese, Korean, German, French, Spanish,
Portuguese and Russian to the existing English and Simplified Chinese UI.
Documentation continues to be maintained only in English and Simplified Chinese.

**Design:** Use the existing Flutter gen-l10n pipeline. Each new
`apps/morsecq/lib/l10n/app_<locale>.arb` translates all 562 template messages.
Generated `S.supportedLocales` supplies the language picker, locale controller,
notifications and desktop shell. Keep product names, placeholder types and
technical protocol identifiers intact. Russian plurals use one/few/many/other;
Traditional Chinese uses `zh_Hant`, preserving existing `zh` preferences.
Reference table meanings and mnemonics remain English/Simplified Chinese data.
Traditional Chinese uses the Chinese table; other added interface languages use
the existing English fallback.

Adding partial translations would leave English throughout the new interfaces.
Refactoring locale selection would duplicate mechanisms already in place.
Complete ARBs fit the existing architecture without either cost.

## Implementation and verification

1. Establish the existing i18n test baseline. Add regression tests in
   `test/i18n/shipped_locales_test.dart` for all ten locales, Traditional
   Chinese resolution, persistence, service strings and Russian plurals.
   Extend `language_settings_tile_test.dart` for every new choice on a
   320 × 568 phone, including scrolling and returning to the system language.
   Run the new tests before translations and confirm the missing-locale failures.
2. Add eight complete ARBs, retaining all declared ICU placeholders and
   intentional zero-count messages. Generate Dart with `flutter gen-l10n`
   inside `apps/morsecq`; do not edit generated files manually.
3. Update tests that assumed French was unsupported. Update the two root
   READMEs, the two l10n READMEs and l10n config comments to describe the
   shipped locales and documentation policy.
4. Run the i18n suite, app tests excluding `needs-native`, app analyzer,
   complexity/import guards and the string migration check. Review translated
   messages for unintended English copies and inspect ICU behavior.

## Change log

- 2026-10-03: User approved eight additional interface languages and Chinese/
  English documentation only; recorded the implementation and verification plan.
- 2026-10-03: Small-phone tests exposed an unbounded review-status trailing label in German/Russian. Wrap the title and status together so long translations and large text remain visible on mobile and desktop; add four narrow-screen regression cases.
- 2026-10-03: Final validation: 667 app tests passed with one existing skip (needs-native excluded); app analysis, formatting, complexity/import guards, ARB migration check, all-locale message validation and both Apple plist checks passed. Independent Codex reviews completed; corrected character-count labels in Spanish/Portuguese/Russian and the Portuguese zero-session subtitle.
