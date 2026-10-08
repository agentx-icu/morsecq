[简体中文](ADDING_A_LANGUAGE.zh-CN.md)

# Add a UI language

MorseCQ ships English (`en`, template), Simplified Chinese (`zh`), Traditional Chinese (`zh_Hant`), Japanese (`ja`), Korean (`ko`), German (`de`), French (`fr`), Spanish (`es`), Portuguese (`pt`) and Russian (`ru`). Documentation is maintained in English and Simplified Chinese.

Flutter gen-l10n derives `S.supportedLocales` from the complete ARB files. `LocaleController` uses this set for the language picker and system-locale resolution. An in-app override wins; otherwise the first supported language in the operating system's preferred list wins, with English as fallback. Chinese Hant or TW/HK/MO without a script selects Traditional Chinese. Preferences use the local `settings.json` store opened by `main.dart`.

## Add the translation

1. Copy `apps/morsecq/lib/l10n/app_en.arb` to `app_<tag>.arb` and set `@@locale` to the tag. Keep every template message; translate all prose, preserve placeholder names/types, ICU plural branches and product names. New strings require an English `@key` description and translations in every shipped ARB.
2. Add the language's native name to `lib/i18n/language_catalog.dart` if absent. Flutter handles widget direction; update the native-interface RTL hint when appropriate.
3. Copy `lib/ui/reference/text/reference_text_en.dart` to `reference_text_<lowercase-tag>.dart`. Translate values while preserving every key and row order for Q codes, abbreviations, prosigns, punctuation and `digitPhrases`. Translate `phraseNote`; select a rhythm only when the language has an established Morse rhythm convention.
4. Import/register the new reference text in `kReferenceTexts`, in `lib/ui/reference/text/reference_texts.dart`. The reference tests require complete translated content for every shipped ARB locale.
5. Add the locale to iOS/macOS `CFBundleLocalizations`, both Xcode projects' `knownRegions` and their localized `InfoPlist.strings` variant groups. Create both `<tag>.lproj/InfoPlist.strings` files and translate the declared microphone usage text. The English usage text must match Info.plist exactly.
6. Add the corresponding BCP-47 tag to Android `res/xml/locale_config.xml`. Map `zh` to `zh-Hans` and `zh_Hant` to `zh-Hant`. Linux/Windows read operating-system locale settings.
7. Update `shipped_locales_test.dart` and the language-picker test cases for the expanded supported set; run gen-l10n and commit generated files.

A script/region variant needs its language-only ARB parent. Traditional Chinese is the existing script example; gen-l10n puts `SZhHant` in `s_zh.dart`. For a new non-Chinese region variant, add explicit region-preference behavior and tests to `locale_resolution.dart`; the current resolver primarily matches language and script.

## Verify

From the repository root:

```sh
dart pub get --enforce-lockfile
dart run tool/ui_literal_guard.dart
flutter analyze apps/morsecq
cd apps/morsecq
flutter gen-l10n
flutter test --no-pub test/i18n test/reference
flutter run -d macos
```

Use **Me → Language** to select the new language and then follow the system. Check Learn / Reference / Me labels, native tray strings, reference rows, small-screen layout, persistence after reopening, and Android/iOS per-app language selection. `arb_consistency_test`, `platform_locales_test` and `reference_texts_test` guard the key set, platform declarations and reference data.

Daily string conventions are in the [l10n README](../../apps/morsecq/lib/l10n/README.md).
