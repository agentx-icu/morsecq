[English](./README.md)

# morsecq App 的本地化（l10n）

通过 Flutter 的 gen-l10n 提供英语（`en`，模板）和简体中文（`zh`）。

| 路径 | 内容 |
|------|------|
| `apps/morsecq/l10n.yaml` | gen-l10n 配置：输出类 `S`、非空 getter、输出到 `lib/l10n/generated/` |
| `lib/l10n/app_en.arb` | **模板。** 每个键都先在这里出现，带 `@key` 元数据（description、placeholders） |
| `lib/l10n/app_zh.arb` | 简体中文。与模板相同的键集合（由 `test/i18n/arb_consistency_test.dart` 强制） |
| `lib/l10n/generated/s*.dart` | 生成物；永不手改。通过 `**/l10n/**` 模式免于 500 行门禁 |
| `lib/i18n/locale_controller.dart` | `LocaleController`（系统 / en / zh），通过 `KeyValueStore` 持久化 |
| `lib/i18n/key_value_store.dart` | `KeyValueStore` 接口 + `InMemoryKeyValueStore` + `JsonFileKeyValueStore` |
| `lib/i18n/l10n_extension.dart` | `context.s` → `S.of(context)`；重新导出 `S` |
| `lib/i18n/language_settings_tile.dart` | "我"页面的 `LanguageSettingsTile`（+ `showLanguageDialog`） |
| `lib/i18n/chat_error_messages.dart` | 针对 `ChatException` 代码的 `chatErrorMessage(s, code)` / `describeChatError(s, error)` |
| `tool/strings_to_arb.dart`（仓库根目录） | 迁移工具：`*_strings.dart` 常量 → ARB 键 |

## 接线（main.dart）

在 `MaterialApp` 之上提供一个 `LocaleController`（假后端用 `InMemoryKeyValueStore`，
真实后端用 `await JsonFileKeyValueStore.open(File(...))` 或一个 `shared_preferences` 适配器），然后：

```dart
MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: context.watch<LocaleController>().locale, // null = follow system
  ...
)
```

`locale: null` 让 Flutter 按 `supportedLocales` 解析设备语言（任何 `zh-*` → 简体中文，
其他一切 → 英语）。

## 使用字符串

```dart
import '../../i18n/l10n_extension.dart';

Text(context.s.chatSend)                      // plain
Text(context.s.learnLessonOf(lesson, total))  // placeholders
Text(context.s.statsSessions(count))          // ICU plural
```

在 widget 之外（控制器、后台代码）请把 `S` 实例传进去，而不是去找 context。`S.of(context)` 在
`MaterialApp` 之上会抛出异常，因此测试需要 pump `localizationsDelegates: S.localizationsDelegates`。

## 添加一个字符串

1. 把键同时加到 `app_en.arb` **和** `app_zh.arb`。按功能区域命名空间（`chatSendHint`、
   `learnLessonOf`、`statsTitle`、`accountBackupTitle`、`referenceSearchHint`；共享字符串用
   `action*`、`nav*`、`connection*`、`messageStatus*`、`error*`、`language*`）。
2. 给模板条目一个带 `description`（什么/在哪）的 `@key`，有占位符的话再加一个 `placeholders` 映射
   （`{"count": {"type": "int"}}`）。计数使用 ICU 复数：
   `{count, plural, =1{1 session} other{{count} sessions}}`；中文没有复数形式，
   所以其分支通常就是 `{count, plural, other{{count} 次练习}}`（保留任何 `=0` 特例）。
3. 在 `apps/morsecq` 下执行 `flutter gen-l10n`（因为 `pubspec.yaml` 有 `generate: true`，
   build/run 时也会自动运行）。提交重新生成的文件。
4. `flutter analyze apps/morsecq` 和 `flutter test test/i18n` 必须保持通过。

`app_zh.arb` 中使用的业余无线电 / 摩尔斯词汇——请保持一致：
点/划 (dit/dah), 字符速度 (character speed), Farnsworth 间距, 有效速度,
呼号 (callsign), 电键 (key), 直键 (straight key), 双桨 (paddles),
侧音 (sidetone), 音调 (tone), 通联 / QSO, 呼叫 CQ, 报务员 (operator),
听抄 / 抄收 (copy, receive), 发报 / 拍发 (send, key), 译码 (decoded),
规程符号 (prosign), Q 简语 (Q-codes), CW 缩写, Koch 课程/顺序.

## 从 `*_strings.dart` 文件迁移字符串

各功能区域把英语文本保存为 `<Area>Strings` 类的 `static const` 成员。要把它们提升到 ARB 文件，
在仓库根目录运行：

```bash
dart run tool/strings_to_arb.dart                       # all apps/morsecq/lib/ui/**/*_strings.dart
dart run tool/strings_to_arb.dart apps/morsecq/lib/ui/listen/listen_strings.dart
dart run tool/strings_to_arb.dart --check               # CI: exit 1 if anything is missing
dart run tool/strings_to_arb.dart --dry-run             # report only
```

它做的事：

* `ChatStrings.sendHint = 'Type a message'` → `app_en.arb` 中的 `"chatSendHint": "Type a message"`，
  外加 `"@chatSendHint": {"description": "From ChatStrings.sendHint (…/chat_strings.dart)"}`。
* 只添加；从不覆盖或删除已有的键或其元数据。
* 把 `app_zh.arb` 中缺少的每个模板键以**英语文本**加入，并附上
  `"description": "@@TODO(l10n): translate from en — …"`。翻译该值，然后删除 `@key` 条目
  （或替换 description）。`grep -n '@@TODO' apps/morsecq/lib/l10n/app_zh.arb` 可列出待办。
* 跳过函数（`static String foo(int n) => …`）——请手写为 ICU 消息，参见 `learn*`/`stats*`/`reference*`
  这些占位符键——也跳过路由/URL（`/settings/…`、`https://…`）。
* 幂等；`test/i18n/strings_to_arb_test.dart` 中的测试覆盖了这一点。

然后执行 `flutter gen-l10n`，并把常量引用替换为 `S` 调用。

## 后续工作：仍待替换为 `S` 调用的常量

2026-09-30 时存在的全部 389 个常量（加上 32 个函数字符串）都已在两个 ARB 文件中并已翻译。
widget 仍在读取常量类；由各自的负责 agent 逐文件替换（`AccountStrings.x` → `context.s.accountX`，
`LearnStrings.lessonOf(a, b)` → `context.s.learnLessonOf(a, b)`，……）：

| 常量类 | ARB 前缀 | 引用它的文件 |
|-------------|-----------|-------------------------|
| `AccountStrings`（`ui/account/account_strings.dart`） | `account*` | `main.dart`（标题、占位路由）、`startup/startup_controller.dart`、`startup/startup_screens.dart`、`ui/account/{account_widgets,backup_actions,backup_wizard_page,change_password_page,connection_chip,create_identity_page,delete_identity_dialog,edit_profile_page,identity_card,password_strength,restore_backup_page,tox_id_qr_dialog,unlock_page,welcome_page}.dart`、`ui/pages/me_page.dart` |
| `ChatStrings`（`ui/chat/chat_strings.dart`） | `chat*` | `ui/chat/{chat_layout,conversation_list,conversation_screen,conversation_tile,keying_input,message_bubble,message_input,message_status_icon,playback_settings_sheet}.dart`、`ui/contacts/{add_friend_sheet,contacts_page,friend_request_inbox,my_tox_id_sheet,qr_scan_page}.dart`、`ui/groups/{create_group_sheet,group_invites_inbox,group_list,group_members_sheet,join_group_sheet}.dart`、`ui/pages/{chat_page,groups_page}.dart` |
| `LearnStrings`（`ui/learn/learn_strings.dart`） | `learn*` | `ui/learn/{learn_home,learn_home_widgets}.dart`、`ui/learn/receive/{answer_keypad,receive_drill_screen,receive_summary_view,round_result_view}.dart`、`ui/learn/review/review_screen.dart`、`ui/learn/send/{keyer_legend,send_live_view,send_practice_screen,send_result_view,send_tips}.dart`、`ui/learn/settings/training_settings_screen.dart` |
| `StatsStrings`（`ui/stats/stats_strings.dart`） | `stats*` | `ui/stats/**`（仪表盘、磁贴、趋势图、字符网格、热力图、日历） |
| `ReferenceStrings`（`ui/reference/reference_strings.dart`） | `reference*` | `ui/reference/**`（参考页、翻译器、键盘） |
| 硬编码的页面标题 | `nav*` | `ui/pages/learn_page.dart`（`'Learn'`）、`ui/pages/me_page.dart`（`'Me'`）、`ui/shell/app_shell.dart`（`kShellDestinations` 标签——把它们改成 `S` 的函数，或在 `build` 中解析） |
| 硬编码的页面描述 | —（尚未进入 ARB） | `ui/pages/{learn,chat,groups,me}_page.dart` 的 `description` 常量 |

替换过程中值得合并的重复项：`accountCancel`/`chatCancel` → `actionCancel`；
`accountCopy`/`chatCopy` → `actionCopy`；`accountRetry`/`statsRetry` → `actionRetry`；
`accountConnection*`/`chatOnline`/`chatOffline` → `connection*`；`chatStatus*` → `messageStatus*`；
`accountWrongPassword` → `errorWrongPassword`；`chatError`/`accountGenericError` → `errorUnknown`；
`learnLearnTitle`/`chatChatTitle`/`chatGroupsTitle`/`accountMeTitle` → `nav*`。
一旦某个常量类不再有任何引用，就删除它，ARB 保留这些键（再没有东西依赖那个常量文件了）。

另外仍待处理：本轮运行时 `listen_strings.dart`（音频译码器 UI）尚不存在——它落地后请运行迁移工具。
