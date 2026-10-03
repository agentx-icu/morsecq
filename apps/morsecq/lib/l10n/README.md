[简体中文](./README.zh-CN.md)

# Localisation (l10n) for the MorseCQ app

English (`en`, template) and Simplified Chinese (`zh`) via Flutter's gen-l10n.

| Path | What |
|------|------|
| `apps/morsecq/l10n.yaml` | gen-l10n config: output class `S`, non-nullable getter, output in `lib/l10n/generated/` |
| `lib/l10n/app_en.arb` | **Template.** Every key lives here first, with `@key` metadata (description, placeholders) |
| `lib/l10n/app_zh.arb` | Simplified Chinese. Same key set as the template (enforced by `test/i18n/arb_consistency_test.dart`) |
| `lib/l10n/generated/s*.dart` | Generated; never edit. Exempt from the 500-LOC gate by the `**/l10n/**` pattern |
| `lib/i18n/locale_controller.dart` | `LocaleController` (system / en / zh) persisted through a `KeyValueStore` |
| `lib/i18n/key_value_store.dart` | `KeyValueStore` interface + `InMemoryKeyValueStore` + `JsonFileKeyValueStore` |
| `lib/i18n/l10n_extension.dart` | `context.s` → `S.of(context)`; re-exports `S` |
| `lib/i18n/language_settings_tile.dart` | `LanguageSettingsTile` for the Me page (+ `showLanguageDialog`) |
| `lib/i18n/chat_error_messages.dart` | `chatErrorMessage(s, code)` / `describeChatError(s, error)` for `ChatException` codes |
| `lib/i18n/current_strings.dart`, `lib/i18n/strings_resolver.dart` | `currentS()` / `StringsResolver` for code without a `BuildContext` (see below) |
| `lib/notifications/**` | `notification*` keys: OS notification titles/bodies, inbox summary plural, Android channel names, Linux action. Resolved via `S Function()` at post time |
| `lib/desktop/**` | `desktop*` keys: tray menu (Show/Hide/Sound/Quit), tooltip plural, unread window title. `DesktopShellController.updateStrings(S)` |
| `lib/i18n/locale_resolution.dart` | `resolveSystemLocales(preferred, supported)`: walks the OS preferred-locale **list** in order, first shipped match wins, else English |
| `tool/ui_literal_guard.dart` (repo root) | CI gate: no hard-coded user-visible prose in `apps/morsecq/lib` (see below) |

## Wiring (main.dart)

`main()` opens one settings store, `JsonFileKeyValueStore` on
`<application support>/settings.json`, for every backend (fake or Tox); only
if that file cannot be opened does it fall back to an `InMemoryKeyValueStore`.
It is passed to `AppScope` (`localeStore`), which builds the
`LocaleController` on it above `MaterialApp` (an `AppScope` without a store,
as in widget tests, uses memory). Then:

```dart
MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: context.watch<LocaleController>().locale, // null = follow system
  localeListResolutionCallback: LocaleController.resolve,
  ...
)
```

Precedence: an explicit in-app choice (English / 简体中文) wins. With
"System default" (`locale: null`) `LocaleController.resolve` →
`resolveSystemLocales` walks the OS preferred-locale **list** in order and
picks the first language the app ships, so `[fr-FR, zh-CN]` gives Chinese
and a list with no shipped language falls back to English. The OS list
already contains the per-app language on Android 13+ and iOS (declared in
`android/app/src/main/res/xml/locale_config.xml` and the Runner
`*.lproj/InfoPlist.strings`; `test/i18n/platform_locales_test.dart` keeps
those in step with the ARB files). `currentS()` uses the same resolution for
code without a context.

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
placeholders, never translated. Android notification channel names and
descriptions are refreshed on a language change too
(`LocalNotificationsApi.refreshStrings()` re-creates the channels; see
`lib/notifications/README.md`); only notifications already on screen keep
their old language. Tests pin the language with
`lookupS(const Locale('en'))` / `lookupS(const Locale('zh'))` instead of
relying on the host locale.

## Adding a string

1. Add the key to `app_en.arb` **and** `app_zh.arb`. Namespace it by area
   (`chatSendHint`, `learnLessonOf`, `statsTitle`, `accountBackupTitle`,
   `referenceSearchHint`; `action*`, `nav*`, `connection*`,
   `messageStatus*`, `error*`, `language*` for shared strings).
2. Give the template entry an `@key` with a `description` and, for
   placeholders, a `placeholders` map (`{"count": {"type": "int"}}`).
   Counts use ICU plurals: `{count, plural, =1{1 session} other{{count} sessions}}`;
   Chinese has no plural forms, so its branch is usually just
   `{count, plural, other{{count} 次练习}}` (keep any `=0` special cases).
   The description is for the translator: say **where** the string is shown
   and **what** it means (`"Receive drill: button that plays the round again"`),
   what each placeholder holds and whether it is pre-formatted, and any
   length limit or term to keep (callsigns, Q-codes, `CQ`). Do not point at
   source files or classes. `test/i18n/arb_consistency_test.dart` fails on a
   missing or empty description. Translation ARBs need no `@key` metadata.
3. From `apps/morsecq`: `flutter gen-l10n` (also runs on build/run because
   `pubspec.yaml` has `generate: true`). Commit the regenerated files.
4. `flutter analyze apps/morsecq`, `flutter test test/i18n` and
   `dart run tool/ui_literal_guard.dart` (repo root) must stay green.

Ham / Morse vocabulary used in `app_zh.arb` — keep it consistent:
点/划 (dit/dah), 字符速度 (character speed), Farnsworth 间距, 有效速度,
呼号 (callsign), 电键 (key), 直键 (straight key), 双桨 (paddles),
侧音 (sidetone), 音调 (tone), 通联 / QSO, 呼叫 CQ, 报务员 (operator),
听抄 / 抄收 (copy, receive), 发报 / 拍发 (send, key), 译码 (decoded),
规程符号 (prosign), Q 简语 (Q-codes), CW 缩写, Koch 课程/顺序.

Terminology rules (both languages):

* **Morse** is 莫尔斯 (莫尔斯电码), never 摩尔斯 — in the ARB files and in the
  platform strings (`ios/macos/Runner/zh-Hans.lproj/InfoPlist.strings`).
* **好友 vs 联系人.** A Tox friend (someone added by Tox ID, who can come
  online, receive a request, be removed) is 好友 — "friend", and also the
  English "contact" when it means a friend (`errorPeerOffline`,
  `accountEditProfileBody`). 联系人 is only the broader **Contacts** screen
  (`chatContacts`), which lists friends plus the note-to-self entry.
* **Speed unit.** Words per minute is written `WPM` (`{wpm} WPM`, `chatWpm`)
  in both languages. An unknown speed is `-- WPM` (`learnWpmUnknown`,
  `listenSpeedUnknown`).

## UI literal guard

`dart run tool/ui_literal_guard.dart` (repo root; CI step "UI literal guard
(localisation)") parses every file under `apps/morsecq/lib` (generated code
skipped) and fails when a string literal containing a letter, after
interpolations are removed, is passed straight to a user-visible sink:
`Text` / `SelectableText`, `TextSpan.text`, `Tooltip.message`,
`Semantics.value`, and named arguments such as `tooltip`, `label`,
`labelText`, `hintText`, `helperText`, `errorText`, `semanticLabel`,
`title`, `subtitle`, `content`. `Text('$n')` or `'—'` pass; `Text('Send')`
fails. The sink table is at the top of the tool.

For content that is genuinely not translatable (callsigns, Q-codes,
prosigns, locator examples) add `// ui-literal-ok: <reason>` at the end of
the line or alone on the line above. The reason is mandatory, and a marker
that no longer covers a flagged literal fails the gate, so exemptions cannot
go stale. The guard does not follow prose routed through data maps,
constants or helpers — review those by hand. Tests:
`test/i18n/ui_literal_guard_test.dart`.

## Migration status

The migration from the old `*_strings.dart` const classes is complete; the
classes and `tool/strings_to_arb.dart` are gone. Notification titles and
bodies, the desktop tray and the window title are resolved through
`currentS()` / `StringsResolver` (see "Context-free strings" under
"Using a string"), and
reference *content* (Q-code / abbreviation / prosign meanings, mnemonics) is
data keyed by language code inside the reference tables
(`ui/reference/reference_qcodes.dart`, `reference_abbreviations.dart`,
`reference_catalog.dart`, `reference_mnemonics.dart`), not ARB;
`reference_localized_text.dart` only holds the lookup helpers
(`referenceLanguageFor`, `localizedReferenceText`, label separator); `ReferenceEntry.meaning` / `mnemonic` in `reference_catalog.dart` call them.
