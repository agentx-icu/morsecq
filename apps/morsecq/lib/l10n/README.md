[简体中文](README.zh-CN.md)

# MorseCQ localization

The offline application ships ten complete ARB locales: en, zh, zh_Hant, ja, ko, de, fr, es, pt and ru. `app_en.arb` is the template. `apps/morsecq/l10n.yaml` generates class `S` into `lib/l10n/generated/`; generated files are committed and never edited directly.

`main.dart` opens local `settings.json` and provides `LocaleController` above MaterialApp. `S.supportedLocales` defines the supported set. An in-app language override wins; following the system uses the first supported locale in its preferred list. Hant or TW/HK/MO without an explicit script selects Traditional Chinese. Android locale_config and Apple CFBundleLocalizations/InfoPlist.strings declare the same set.

Use localized messages below MaterialApp:

```dart
Text(context.s.navLearn)
Text(context.s.learnLessonOf(lesson, total))
Text(context.s.statsSessions(count))
```

For context-free text, pass `S` or use `currentS()`. AppServices owns a StringsResolver and refreshes desktop tray text when the locale changes. Controllers expose state and errors; widgets choose the localized wording.

## Add a message

1. Add the key to the English template and every translated ARB. Use learning, statistics, reference, listen, materials, settings or shared action namespaces.
2. Add the template `@key` description and placeholder types. Preserve placeholder names and ICU plural branches in every translation; always include `other` and use grammatical categories appropriate to the language.
3. Run `flutter gen-l10n` from `apps/morsecq` and commit regenerated files.
4. Run `dart run tool/ui_literal_guard.dart` at the repository root, then application `test/i18n` and analysis. Hard-coded UI prose is rejected; model enums remain independent of Flutter strings.

Reference meanings and mnemonics live in `lib/ui/reference/text/reference_text_<tag>.dart`, registered in `kReferenceTexts`. Preserve English row keys/order; every shipped language must have complete translated reference content. See [adding a language](../../../../doc/i18n/ADDING_A_LANGUAGE.md) for platform declarations, variants and checks.
