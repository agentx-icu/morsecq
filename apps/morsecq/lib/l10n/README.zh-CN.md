[English](./README.md)

# MorseCQ App 的本地化（l10n）

通过 Flutter 的 gen-l10n 提供英语（`en`，模板）、简体中文（`zh`）、繁体中文
（`zh_Hant`）、日语（`ja`）、韩语（`ko`）、德语（`de`）、法语（`fr`）、
西班牙语（`es`）、葡萄牙语（`pt`）和俄语（`ru`）。文档只维护英文和简体中文。

| 路径 | 内容 |
|------|------|
| `apps/morsecq/l10n.yaml` | gen-l10n 配置：输出类 `S`、非空 getter、输出到 `lib/l10n/generated/` |
| `lib/l10n/app_en.arb` | **模板。** 每个键都先在这里出现，带 `@key` 元数据（description、placeholders） |
| `lib/l10n/app_<locale>.arb` | 完整译文。每份文件的键集合均与模板相同（由 `test/i18n/arb_consistency_test.dart` 强制） |
| `lib/l10n/generated/s*.dart` | 生成物；永不手改。通过 `**/l10n/**` 模式免于 500 行门禁 |
| `lib/i18n/locale_controller.dart` | `LocaleController`（系统 / 所有支持的语言），通过 `KeyValueStore` 持久化 |
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
  localeResolutionCallback: LocaleController.resolve,
  ...
)
```

`locale: null` 通过共享解析器跟随设备语言。中文显式指定 `Hant` 脚本，或没有
脚本且地区为 TW/HK/MO 时使用繁体中文；其他中文使用简体中文。其他受支持的
语言按语言代码匹配，不受支持的语言回退到英文。

参考手册的释义与记忆提示是独立数据表，目前提供英文和简体中文。繁体中文
使用中文数据表；其余新增界面语言沿用现有的英文回退。

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

1. 把键同时加到 `app_en.arb` **和每份翻译 ARB**。按功能区域命名空间（`chatSendHint`、
   `learnLessonOf`、`statsTitle`、`accountBackupTitle`、`referenceSearchHint`；共享字符串用
   `action*`、`nav*`、`connection*`、`messageStatus*`、`error*`、`language*`）。
2. 给模板条目一个带 `description`（什么/在哪）的 `@key`，有占位符的话再加一个 `placeholders` 映射
   （`{"count": {"type": "int"}}`）。计数使用 ICU 复数：
   `{count, plural, =1{1 session} other{{count} sessions}}`；中文没有复数形式，
   所以其分支通常就是 `{count, plural, other{{count} 次练习}}`（保留任何 `=0` 特例）。
   欧洲语言使用 `one` / `other` 等语法类别；俄语使用 `one` / `few` / `many` /
   `other`，仅保留精确匹配的 `=1` 会遗漏 21 等数字的单数形式。
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

## 界面迁移已完成

旧界面字符串常量类已于 2026-09-30 删除。所有界面区域均使用 `context.s`，或显式
接收 `S` 实例。新增语言会自动覆盖这些相同的调用方：

| 区域 | ARB 前缀 | 调用方 |
|------|----------|--------|
| 账号与启动 | `account*`、`action*`、`connection*`、`error*` | `startup/**`、`ui/account/**`、`ui/pages/me_page.dart`；备份对话框使用 `currentS()` |
| 聊天、联系人与群组 | `chat*`、`messageStatus*` | `ui/chat/**`、`ui/contacts/**`、`ui/groups/**`；时间戳通过 `MaterialLocalizations` 格式化 |
| 学习 | `learn*` | `ui/learn/**`；发报反馈辅助函数显式接收 `S` |
| 统计 | `stats*` | `ui/stats/**`；日期按当前语言格式化 |
| 手册与翻译器 | `reference*` | `ui/reference/**`；释义与记忆提示仍是独立数据表 |
| 麦克风译码 | `listen*` | `ui/listen/**`；控制器暴露状态/错误，由界面解析文本 |
| 导航与外壳 | `nav*`、`shellOfflineBanner` | `ui/pages/**`、`ui/shell/app_shell.dart` |
| 通知与桌面 | `notification*`、`desktop*` | 服务在事件发生或语言变化时解析字符串 |

没有旧字符串文件时，`dart run tool/strings_to_arb.dart --check` 不执行迁移。
ARB 一致性测试仍持续约束所有语言的完整性。
