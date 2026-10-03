[简体中文](./README.zh-CN.md)

# Localisation (l10n) for the MorseCQ app

Flutter's gen-l10n ships English (`en`, template), Simplified Chinese (`zh`),
Traditional Chinese (`zh_Hant`), Japanese (`ja`), Korean (`ko`), German (`de`),
French (`fr`), Spanish (`es`), Portuguese (`pt`) and Russian (`ru`).
Documentation is maintained in English and Simplified Chinese only.

| Path | What |
|------|------|
| `apps/morsecq/l10n.yaml` | gen-l10n config: output class `S`, non-nullable getter, output in `lib/l10n/generated/` |
| `lib/l10n/app_en.arb` | **Template.** Every key lives here first, with `@key` metadata (description, placeholders) |
| `lib/l10n/app_<locale>.arb` | Complete translations. Every file has the template key set (enforced by `test/i18n/arb_consistency_test.dart`) |
| `lib/l10n/generated/s*.dart` | Generated; never edit. Exempt from the 500-LOC gate by the `**/l10n/**` pattern |
| `lib/i18n/locale_controller.dart` | `LocaleController` (system / every shipped locale) persisted through a `KeyValueStore` |
| `lib/i18n/key_value_store.dart` | `KeyValueStore` interface + `InMemoryKeyValueStore` + `JsonFileKeyValueStore` |
| `lib/i18n/l10n_extension.dart` | `context.s` → `S.of(context)`; re-exports `S` |
| `lib/i18n/language_settings_tile.dart` | `LanguageSettingsTile` for the Me page (+ `showLanguageDialog`) |
| `lib/i18n/chat_error_messages.dart` | `chatErrorMessage(s, code)` / `describeChatError(s, error)` for `ChatException` codes |
| `lib/i18n/current_strings.dart`, `lib/i18n/strings_resolver.dart` | `currentS()` / `StringsResolver` for code without a `BuildContext` (see below) |
| `lib/notifications/**` | `notification*` keys: OS notification titles/bodies, inbox summary plural, Android channel names, Linux action. Resolved via `S Function()` at post time |
| `lib/desktop/**` | `desktop*` keys: tray menu (Show/Hide/Sound/Quit), tooltip plural, unread window title. `DesktopShellController.updateStrings(S)` |
| `tool/strings_to_arb.dart` (repo root) | Migration tool: `*_strings.dart` consts → ARB keys |

## Wiring (main.dart)

Provide a `LocaleController` above `MaterialApp` (an `InMemoryKeyValueStore`
for the fake backend, `await JsonFileKeyValueStore.open(File(...))` or a
`shared_preferences` adapter for the real one), then:

```dart
MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: context.watch<LocaleController>().locale, // null = follow system
  localeResolutionCallback: LocaleController.resolve,
  ...
)
```

`locale: null` follows the device language using the shared resolver. Chinese
with an explicit `Hant` script or TW/HK/MO region without a script maps to
Traditional Chinese; other Chinese maps to Simplified Chinese. Other shipped
languages match their language code; unsupported languages fall back to English.

Reference meanings and mnemonics are separate data tables, currently in English
and Simplified Chinese. Traditional Chinese uses the Chinese table; other added
interface languages use the existing English fallback.

## Using a string

```dart
import '../../i18n/l10n_extension.dart';

Text(context.s.chatSend)                      // plain
Text(context.s.learnLessonOf(lesson, total))  // placeholders
Text(context.s.statsSessions(count))          // ICU plural
```

Outside a widget (controllers, background code) pass the `S` instance in
rather than reaching for a context. `S.of(context)` throws above the
`MaterialApp`, so tests pump `localizationsDelegates: S.localizationsDelegates`.

### Context-free strings (notifications, tray, lifecycle)

Services that outlive any widget take an `S Function()` (default `currentS()`,
which follows `LocaleController.active` — toxee's `currentAppL10n()` scheme)
and call it when they need text, so the *next* notification or tray rebuild is
in the new language with no re-wiring. `AppServices` owns one `StringsResolver`
(a `ChangeNotifier` over the scope's `LocaleController`; fires on the setting
and, while following the system, on OS locale changes), hands notifications
`() => strings.s` and calls `DesktopShellController.updateStrings(strings.s)`
on start and on every change. Product names (`appName`, `MorseCQ`) are
placeholders, never translated. Limits: notifications already on screen keep
their language, and Android channel names are frozen at first creation (see
`lib/notifications/README.md`). Tests pin the language with
`lookupS(const Locale('en'))` / `lookupS(const Locale('zh'))` instead of
relying on the host locale.

## Adding a string

1. Add the key to `app_en.arb` **and every translation ARB**. Namespace it by area
   (`chatSendHint`, `learnLessonOf`, `statsTitle`, `accountBackupTitle`,
   `referenceSearchHint`; `action*`, `nav*`, `connection*`,
   `messageStatus*`, `error*`, `language*` for shared strings).
2. Give the template entry an `@key` with a `description` (what/where) and,
   for placeholders, a `placeholders` map (`{"count": {"type": "int"}}`).
   Counts use ICU plurals: `{count, plural, =1{1 session} other{{count} sessions}}`;
   Chinese has no plural forms, so its branch is usually just
   `{count, plural, other{{count} 次练习}}` (keep any `=0` special cases).
   Use grammatical categories such as `one` / `other` for European languages
   and `one` / `few` / `many` / `other` for Russian; an exact `=1` alone would
   miss Russian numbers such as 21.
3. From `apps/morsecq`: `flutter gen-l10n` (also runs on build/run because
   `pubspec.yaml` has `generate: true`). Commit the regenerated files.
4. `flutter analyze apps/morsecq` and `flutter test test/i18n` must stay green.

Ham / Morse vocabulary used in `app_zh.arb` — keep it consistent:
点/划 (dit/dah), 字符速度 (character speed), Farnsworth 间距, 有效速度,
呼号 (callsign), 电键 (key), 直键 (straight key), 双桨 (paddles),
侧音 (sidetone), 音调 (tone), 通联 / QSO, 呼叫 CQ, 报务员 (operator),
听抄 / 抄收 (copy, receive), 发报 / 拍发 (send, key), 译码 (decoded),
规程符号 (prosign), Q 简语 (Q-codes), CW 缩写, Koch 课程/顺序.

## Migrating strings from a `*_strings.dart` file

The feature areas keep their English text as `static const` members of a
`<Area>Strings` class. To lift them into the ARB files, run from the repo root:

```bash
dart run tool/strings_to_arb.dart                       # all apps/morsecq/lib/ui/**/*_strings.dart
dart run tool/strings_to_arb.dart apps/morsecq/lib/ui/listen/listen_strings.dart
dart run tool/strings_to_arb.dart --check               # CI: exit 1 if anything is missing
dart run tool/strings_to_arb.dart --dry-run             # report only
```

What it does:

* `ChatStrings.sendHint = 'Type a message'` → `"chatSendHint": "Type a message"`
  in `app_en.arb` plus `"@chatSendHint": {"description": "From ChatStrings.sendHint (…/chat_strings.dart)"}`.
* Adds only; never overwrites or removes an existing key or its metadata.
* Adds every template key missing from any translation ARB with the **English text**
  and `"description": "@@TODO(l10n): translate from en — …"`. Translate the
  value, then delete the `@key` entry (or replace the description).
  `grep -n '@@TODO' apps/morsecq/lib/l10n/app_zh.arb` lists open work.
* Skips functions (`static String foo(int n) => …`) — write those by hand as
  ICU messages, see the `learn*`/`stats*`/`reference*` placeholder keys — and
  skips routes/URLs (`/settings/…`, `https://…`).
* Idempotent; the tests in `test/i18n/strings_to_arb_test.dart` cover this.

Then `flutter gen-l10n` and replace the const references with `S` calls.

## Completed UI migration

The old UI string constant classes were removed on 2026-09-30. All interface
areas now use `context.s` or receive an `S` instance explicitly. New translations
cover these same callers automatically:

| Area | ARB prefix | Callers |
|------|------------|---------|
| Account and startup | `account*`, `action*`, `connection*`, `error*` | `startup/**`, `ui/account/**`, `ui/pages/me_page.dart`; backup dialogs use `currentS()` |
| Chat, contacts and groups | `chat*`, `messageStatus*` | `ui/chat/**`, `ui/contacts/**`, `ui/groups/**`; timestamp formatting uses `MaterialLocalizations` |
| Learning | `learn*` | `ui/learn/**`; send-feedback helpers take `S` explicitly |
| Statistics | `stats*` | `ui/stats/**`; date formatting uses the current locale |
| Reference and translator | `reference*` | `ui/reference/**`; meanings and mnemonics remain separate data tables |
| Microphone decoding | `listen*` | `ui/listen/**`; controllers expose state/errors, widgets resolve text |
| Navigation and shell | `nav*`, `shellOfflineBanner` | `ui/pages/**`, `ui/shell/app_shell.dart` |
| Notifications and desktop | `notification*`, `desktop*` | Services resolve strings at event time or on language changes |

`dart run tool/strings_to_arb.dart --check` is a no-op when no old string files
remain. The ARB consistency tests continue to enforce completeness in all locales.
