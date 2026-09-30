# Localisation (l10n) for the morsecq app

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
  ...
)
```

`locale: null` lets Flutter resolve the device language against
`supportedLocales` (any `zh-*` → Simplified Chinese, everything else → English).

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

## Adding a string

1. Add the key to `app_en.arb` **and** `app_zh.arb`. Namespace it by area
   (`chatSendHint`, `learnLessonOf`, `statsTitle`, `accountBackupTitle`,
   `referenceSearchHint`; `action*`, `nav*`, `connection*`,
   `messageStatus*`, `error*`, `language*` for shared strings).
2. Give the template entry an `@key` with a `description` (what/where) and,
   for placeholders, a `placeholders` map (`{"count": {"type": "int"}}`).
   Counts use ICU plurals: `{count, plural, =1{1 session} other{{count} sessions}}`;
   Chinese has no plural forms, so its branch is usually just
   `{count, plural, other{{count} 次练习}}` (keep any `=0` special cases).
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
* Adds every template key missing from `app_zh.arb` with the **English text**
  and `"description": "@@TODO(l10n): translate from en — …"`. Translate the
  value, then delete the `@key` entry (or replace the description).
  `grep -n '@@TODO' apps/morsecq/lib/l10n/app_zh.arb` lists open work.
* Skips functions (`static String foo(int n) => …`) — write those by hand as
  ICU messages, see the `learn*`/`stats*`/`reference*` placeholder keys — and
  skips routes/URLs (`/settings/…`, `https://…`).
* Idempotent; the tests in `test/i18n/strings_to_arb_test.dart` cover this.

Then `flutter gen-l10n` and replace the const references with `S` calls.

## Follow-up: consts still to replace with `S` calls

All 389 consts (plus the 32 function strings) present on 2026-09-30 are in
both ARB files and translated. The widgets still read the const classes; the
owning agents replace them file by file (`AccountStrings.x` → `context.s.accountX`,
`LearnStrings.lessonOf(a, b)` → `context.s.learnLessonOf(a, b)`, …):

| Const class | ARB prefix | Files that reference it |
|-------------|-----------|-------------------------|
| `AccountStrings` (`ui/account/account_strings.dart`) | `account*` | `main.dart` (title, placeholder route), `startup/startup_controller.dart`, `startup/startup_screens.dart`, `ui/account/{account_widgets,backup_actions,backup_wizard_page,change_password_page,connection_chip,create_identity_page,delete_identity_dialog,edit_profile_page,identity_card,password_strength,restore_backup_page,tox_id_qr_dialog,unlock_page,welcome_page}.dart`, `ui/pages/me_page.dart` |
| `ChatStrings` (`ui/chat/chat_strings.dart`) | `chat*` | `ui/chat/{chat_layout,conversation_list,conversation_screen,conversation_tile,keying_input,message_bubble,message_input,message_status_icon,playback_settings_sheet}.dart`, `ui/contacts/{add_friend_sheet,contacts_page,friend_request_inbox,my_tox_id_sheet,qr_scan_page}.dart`, `ui/groups/{create_group_sheet,group_invites_inbox,group_list,group_members_sheet,join_group_sheet}.dart`, `ui/pages/{chat_page,groups_page}.dart` |
| `LearnStrings` (`ui/learn/learn_strings.dart`) | `learn*` | `ui/learn/{learn_home,learn_home_widgets}.dart`, `ui/learn/receive/{answer_keypad,receive_drill_screen,receive_summary_view,round_result_view}.dart`, `ui/learn/review/review_screen.dart`, `ui/learn/send/{keyer_legend,send_live_view,send_practice_screen,send_result_view,send_tips}.dart`, `ui/learn/settings/training_settings_screen.dart` |
| `StatsStrings` (`ui/stats/stats_strings.dart`) | `stats*` | `ui/stats/**` (dashboard, tiles, trend chart, character grid, heatmap, calendar) |
| `ReferenceStrings` (`ui/reference/reference_strings.dart`) | `reference*` | `ui/reference/**` (reference screen, translator, keypad) |
| Hard-coded page titles | `nav*` | `ui/pages/learn_page.dart` (`'Learn'`), `ui/pages/me_page.dart` (`'Me'`), `ui/shell/app_shell.dart` (`kShellDestinations` labels — make them a function of `S` or resolve in `build`) |
| Hard-coded page descriptions | — (not yet in ARB) | `ui/pages/{learn,chat,groups,me}_page.dart` `description` consts |

Duplicates worth collapsing during the swap: `accountCancel`/`chatCancel` →
`actionCancel`; `accountCopy`/`chatCopy` → `actionCopy`; `accountRetry`/
`statsRetry` → `actionRetry`; `accountConnection*`/`chatOnline`/`chatOffline`
→ `connection*`; `chatStatus*` → `messageStatus*`; `accountWrongPassword` →
`errorWrongPassword`; `chatError`/`accountGenericError` → `errorUnknown`;
`learnLearnTitle`/`chatChatTitle`/`chatGroupsTitle`/`accountMeTitle` → `nav*`.
Once a const class has no remaining references, delete it and the ARB keeps
the keys (nothing depends on the const file any more).

Also still to do: a `listen_strings.dart` (audio decoder UI) did not exist
when this pass ran — run the migration tool when it lands.
