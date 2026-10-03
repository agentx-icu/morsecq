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
| ~~`AccountStrings`~~ (deleted 2026-09-30) | `account*` (+ shared `action*`, `connection*`, `error*`, `appName`) | **Done.** `main.dart`, `startup/**`, `ui/account/**`, `ui/pages/me_page.dart` read `context.s`. Routes/URLs live in `ui/account/account_routes.dart` (`kTrainingSettingsRoute`, `kAboutSourceUrl`). `StartupController` holds no text: `error` / `connectionError` are the thrown objects and widgets call `describeChatError(s, e)`; `PasswordStrength.label(S s)`; the backup gateway's native dialog titles use `currentS()` (no context). `invalid_backup` is mapped in `restore_backup_page.dart` only (not part of `chat_error_messages.dart`) |
| ~~`ChatStrings`~~ (deleted 2026-09-30) | `chat*` (+ shared `action*`, `connection*`, `messageStatus*`, `error*`, `nav*`; placeholder keys `chatBytesLeftCount`, `chatMemberCount`, `chatFriendsCount`, `chatFriendRequestsCount`, `chatGroupInvitesCount`, `chatMembersTitleCount`, `chatInvitedByName`, `chatMemberSelf`, `chatSliderValue` added) | **Done.** `ui/chat/**`, `ui/contacts/**`, `ui/groups/**` and the bodies of `ui/pages/{chat,groups}_page.dart` read `context.s`. The duplicates below were collapsed on the way (`chatCancel`→`actionCancel`, `chatCopy`→`actionCopy`, `chatOnline/Offline`→`connection*`, `chatStatus*`→`messageStatus*`; the old `chat*` twins stay in the ARB unused). Errors: widgets keep the thrown object / `ChatException.code` and call `describeChatError(s, e)` in `build`; the add-friend sheet maps `invalid_tox_id`/`own_id`/`already_friend` to the short field texts `chatToxId*`. Validators: `ui/contacts/tox_id.dart` exposes locale-free `validateToxId(...) → ToxIdError?` / `isValidChatIdInput` plus `validateToxIdInput(S, …)` / `validateChatIdInput(S, …)` wrappers. Timestamps: `formatMessageTime(context, time)` in `chat_layout.dart` uses `MaterialLocalizations` (`formatTimeOfDay` / `formatShortMonthDay` / `formatShortDate`), no format string. Count strings are ICU (`chatBytesLeftCount` accepts a negative count for over-budget drafts). `ConversationList.emptyText` / `MasterDetail.emptyDetailText` are nullable and fall back to `chatNoConversations` / `chatSelectConversation`. Tests: `test/chat/test_support.dart` pins `Locale('en')` and exports `final S s = lookupS(const Locale('en'))` |
| ~~`LearnStrings`~~ (deleted 2026-09-30) | `learn*` | **Done.** `ui/learn/**` reads `context.s`; helpers that need an `S` take it as a parameter (`send/send_tips.dart`: `tipFor/titleFor/severityLabel/detailFor/formatWpm(S, …)`, `receive/receive_widgets.dart`: `formatAccuracy/confusedAs(S, …)`). `LearnScope.title` is nullable and falls back to `navLearn`. Tests pump `l10nApp(...)` from `test/learn/helpers/l10n.dart` and compare against `en.learn*` |
| ~~`StatsStrings`~~ (deleted 2026-09-30) | `stats*` | **Done.** `ui/stats/**` reads `context.s`; `formatPercent/formatPercentOrNoData/formatPracticeDuration(S, …)` live in `stats_widgets.dart`; painters receive pre-localised labels (`TrendPainter.axisLabel/percentLabel`, `CalendarPainter.locale`); dates via `DateFormat.yMd(locale)`, weekday/month labels via `weekdayInitial/monthAbbreviation(…, locale:)` in `stats_math.dart` |
| ~~`ReferenceStrings`~~ (deleted 2026-09-30) | `reference*` (`referenceKochPositionValue` added) | **Done.** `ui/reference/**` reads `context.s` / `S s`; `ReferenceSection.label(S)` and `TranslatorMode.label(S)` replace the enum const labels. Reference *content* (Q-code / CW-abbreviation / prosign / punctuation meanings, mnemonics) is data, not ARB: each row is a `Map<String, String>` keyed by language code (`'en'`, `'zh'`), read through `ReferenceEntry.meaning(Locale)` / `mnemonic(Locale)` with English fallback (`ui/reference/reference_localized_text.dart`, `kReferenceLanguages`). A new language adds one entry per row there (plus a `ReferenceMnemonics.spokenRhythm` reading if it voices dit/dah differently); search matches every language's text |
| ~~`ListenStrings`~~ (deleted 2026-09-30) | `listen*` (`listenWpmValue`, `listenHzValue`, `listenMsValue`, `listenBlockSamples`, `listenStateOn/Off` added) | **Done.** `ui/listen/**` reads `context.s`; `ListenController` holds no text (it exposes `ListenStatus` + the raw platform `errorMessage`; `ListenStatusBanner._failureText(S, detail)` maps them). Units are ICU placeholders; tests pin `Locale('en')` and compare against `lookupS(...)` |
| ~~Hard-coded page titles~~ | `nav*` (`navReference` added) | **Done.** Every `ui/pages/*_page.dart` exposes `static String title(S s)`; `ShellDestination.label` is a `String Function(S s)` resolved in `AppShell.build`, so a language switch relabels the bar/rail. Tests: `LearnPage.title(lookupS(const Locale('en')))` |
| ~~Hard-coded page descriptions~~ | `nav*Description`, `shellOfflineBanner` | **Done.** `static String description(S s)` on the same pages (`navLearnDescription`, `navChatDescription`, `navGroupsDescription`, `navReferenceDescription`, `navMeDescription`); the offline strip in `ui/shell/app_shell.dart` reads `shellOfflineBanner` |

Duplicates worth collapsing during the swap: `accountCancel`/`chatCancel` →
`actionCancel`; `accountCopy`/`chatCopy` → `actionCopy`; `accountRetry`/
`statsRetry` → `actionRetry`; `accountConnection*`/`chatOnline`/`chatOffline`
→ `connection*`; `chatStatus*` → `messageStatus*`; `accountWrongPassword` →
`errorWrongPassword`; `chatError`/`accountGenericError` → `errorUnknown`;
`learnLearnTitle`/`chatChatTitle`/`chatGroupsTitle`/`accountMeTitle` → `nav*`.
Once a const class has no remaining references, delete it and the ARB keeps
the keys (nothing depends on the const file any more).

The Listen screen (`listen*`) was migrated on 2026-09-30 together with the
reference; its const file is gone (see the table above).
