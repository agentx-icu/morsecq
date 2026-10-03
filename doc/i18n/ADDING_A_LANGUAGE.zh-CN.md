[English](./ADDING_A_LANGUAGE.md)

# 为 MorseCQ 添加一种界面语言

MorseCQ 通过 Flutter 的 `gen-l10n` 提供英语（`en`，模板）和简体中文（`zh`）。本页端到端地说明
本地化是如何接线的，并给出添加第三种语言的确切步骤；参照对象是姊妹项目 toxee 发布
`ar` / `en` / `ja` / `ko` / `zh_Hans` / `zh_Hant` 的方式（那边的 `/home/user/toxee/l10n.yaml`、
`lib/util/locale_controller.dart`、`test/l10n/arb_completeness_test.dart`）。

日常的字符串工作（添加一个键、业余无线电词汇）请看
[`apps/morsecq/lib/l10n/README.md`](../../apps/morsecq/lib/l10n/README.zh-CN.md)。

> **状态说明（2026-10-02）。** 下文描述的都是代码的现状：`*_strings.dart` 迁移已完成（界面上不再有
> 英语 `static const` 文本，一次性的迁移工具已删除），一致性测试覆盖每一个已发布的 ARB，
> 平台语言清单由漂移测试守护。

## 1. 本地化是如何工作的

### 1.1 gen-l10n 与 `S` 类

| 组成 | 位置 | 说明 |
|---|---|---|
| gen-l10n 配置 | `apps/morsecq/l10n.yaml` | `arb-dir: lib/l10n`、`template-arb-file: app_en.arb`、`output-class: S`、`output-dir: lib/l10n/generated`、`output-localization-file: s.dart`、`nullable-getter: false`、`format: false`。不设 `synthetic-package`（Flutter 3.41 已移除；该键只会打印警告）。 |
| 自动生成 | `apps/morsecq/pubspec.yaml` → `flutter: generate: true` | `flutter run` / `flutter build` 会重新生成；`flutter gen-l10n` 显式执行。 |
| ARB 文件 | `apps/morsecq/lib/l10n/app_<tag>.arb` | 每个区域设置一个。`app_en.arb` 是模板，也是唯一需要 `@key` 元数据（description、placeholders）的文件。截至 2026-10-02 约有 660 个消息键。 |
| 生成的代码 | `apps/morsecq/lib/l10n/generated/s.dart`、`s_en.dart`、`s_zh.dart` | 已提交，永不手改。通过 `**/l10n/**` 模式免于 500 行门禁。 |
| 访问方式 | `context.s`（`lib/i18n/l10n_extension.dart`）或 `S.of(context)` | 仅在 `MaterialApp` 之下可用；测试需要 pump `localizationsDelegates: S.localizationsDelegates`。 |
| 支持的集合 | `S.supportedLocales` | 由 ARB 文件推导。`LocaleController.supportedLocales` 和语言选择器都读它，因此**添加语言不需要编辑任何 Dart 列表**。 |

`main.dart` 中的接线：

```dart
MaterialApp(
  onGenerateTitle: (context) => S.of(context).appName,
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: context.watch<LocaleController>().locale,   // null = follow system
  localeListResolutionCallback: LocaleController.resolve,
  ...
)
```

### 1.2 `LocaleController`：跟随系统或手动覆盖

`lib/i18n/locale_controller.dart` 是一个 `ChangeNotifier`，由 `AppScope` 在 `MaterialApp` 之上提供。

- `locale` 是**覆盖值**（`null` = 跟随系统）。"我"页面的 `LanguageSettingsTile`
  （`lib/i18n/language_settings_tile.dart`）负责设置它。
- `effectiveLocale` 是 UI 此刻真正渲染所用的区域设置：覆盖值，或操作系统的首选区域设置**列表**按
  `S.supportedLocales` 解析后的结果（见 §1.3）。该列表每次实时读取 `PlatformDispatcher.instance.locales`
  （测试可通过构造参数 `systemLocales:` 注入）。
- 持久化经由 `KeyValueStore` 接口（`lib/i18n/key_value_store.dart`）。生产环境使用
  `JsonFileKeyValueStore`，文件为 `<application support>/settings.json`（由 `main.dart` 打开，与选用哪个
  聊天后端无关，所以假后端同样会持久化语言；桌面 shell 通过 `DesktopStoreAdapter` 共享同一个文件）。
  只有该文件无法打开时，`main.dart` 才回退到 `InMemoryKeyValueStore`；单元测试与控件测试也用它。
  键：`i18n.locale`；值：`localeTag()` 生成的标签——`en`、`zh`、`zh_Hant`、`pt_BR`
  （脚本优先于地区）。`parseLocaleTag()` 接受 `-`/`_`、任意大小写以及旧式的 `zh_CN`，
  因此添加语言时已有的偏好设置永远不需要迁移。
- 恢复时，保存的标签经 `supportedLocaleFor()` 映射到已发布的集合（同一语言内，考虑脚本/地区）。
  因此被移除的变体会落到同一语言中仍然发布的区域设置上——在没有 `app_zh_Hant.arb` 的构建里，
  保存的 `zh_Hant` 会变成手动选择的 `zh`。只有整个语言都不再发布时才回退为"跟随系统"。

### 1.3 一条解析规则，用在三处

`lib/i18n/locale_resolution.dart` 分两层。

**首选列表。** `resolveSystemLocales(preferred, supported)` 按优先级从高到低遍历操作系统的整个
首选区域设置列表。第一个能映射到已发布区域设置的条目（按下面的单区域设置规则，不做回退）胜出；
只有没有任何条目匹配——或列表为 null/空——时才用英语。因此操作系统列表为 `[fr-FR, zh-CN]` 的用户
得到的是中文而不是英语：法语没有发布，中文有。

**单个区域设置。** `resolveSystemLocale(system, supported)` / `supportedLocaleFor(candidate, supported)`
是 toxee 单区域设置解析器的泛化版本，把支持的集合变成了数据：

1. 没有 ARB 的语言 → 不匹配（最终回退为英语 `fallback`）。
2. 中文：脚本为 `Hant`，**或**没有脚本但地区为 TW / HK / MO 时用繁体（Android 上报 `zh-TW` 不带脚本，
   iOS 上报 `zh-Hant-TW`）——*前提是*提供了 `zh_Hant` ARB；否则用简体文件（有 `zh_Hans` 用之，
   否则用普通的 `zh`）。
3. 其他语言：有脚本精确匹配的就用它，否则用仅含语言代码的文件。
4. 作用于操作系统列表（`resolveSystemLocales`）：第一个能被规则 2–3 映射到已发布区域设置的首选项胜出；
   都不能则用英语。

`resolveSystemLocales` 支撑着 `MaterialApp.localeListResolutionCallback`（`LocaleController.resolve`）、
`LocaleController.effectiveLocale` 和无需 context 的 `currentLocale()`（读取 `PlatformDispatcher.locales`），
因此 widget 树、设置项和通知永远一致。`supportedLocaleFor()` 是去掉英语回退的单区域设置规则
（也用于校验用户的选择）。

**优先级。** App 内选择器中的显式选择永远优先。选"跟随系统"时，App 跟随操作系统的首选区域设置列表，
而该列表已经包含操作系统的按 App 语言设置（Android 13+ 的"应用语言"、iOS 的"设置 → MorseCQ → 语言"），
因此无需任何原生桥接，系统级的按 App 语言设置就能生效。

### 1.4 语言目录（母语名称）

`lib/i18n/language_catalog.dart::LanguageCatalog.nativeName(locale)` 返回一种语言的自称——
`English`、`简体中文`、`繁體中文`、`日本語`、`العربية`……这些**不是** ARB 键：语言的自称在任何界面语言下
都相同（toxee 出于同样的原因把 `english` 列入"与英语相同属合理"的白名单）。选择器列出
`S.supportedLocales`，用目录为每一项加标签；只有"跟随系统"（`languageSystemDefault`）是需要翻译的
ARB 字符串。查找顺序：完整标签 → `language_Script` → 语言 → BCP-47 标签本身，因此未列出的语言
也总能得到*一个*标签。`LanguageCatalog.isRtl` 是 `ar` / `he` / `fa` / `ur` 的布局方向提示。

目录预先填充的条目远多于实际发布的语言（约 35 条），所以大多数新增语言根本不需要改目录。

### 1.5 没有 `BuildContext` 的字符串（通知、托盘）

`lib/i18n/current_strings.dart`：

- `currentS()`——当前界面语言的 `S` 实例，每次调用时从 `LocaleController.active` 解析
  （由 `AppScope` 在本次运行中设置，单元测试中为 `null` → 使用平台区域设置）。
  与 toxee 的 `currentAppL10n()` 契约相同。
- `lookupSFor(locale)`——能容忍"持久化的区域设置在本构建中已不再提供"的 `lookupS`
  （在通知路径上回退到英语而不是抛出异常）。
- `StringsResolver`（`strings_resolver.dart`）——面向长生命周期服务（托盘菜单、常驻通知）的
  `ChangeNotifier` 视图，在用户更改设置时，或在跟随系统模式下操作系统区域设置变化时触发重新打标签。
  它是一个 `WidgetsBindingObserver`（`didChangeLocales`），不会接管 `PlatformDispatcher.onLocaleChanged`。

通知文本（Android 频道名与频道说明、"新消息"、好友请求与群邀请通知）、桌面托盘菜单与提示、
以及桌面窗口标题都读取 `currentS()` / `StringsResolver`（或由其传入的 `S`），所以新语言无需额外工作就能覆盖这些面向操作系统的字符串。

### 1.6 参考内容（Q 简语、缩略语、助记）

参考*内容*是数据而不是界面外壳，所以不在 ARB 文件里。参考表的每一行按语言携带文本
（`lib/ui/reference/reference_localized_text.dart`）。某个界面区域设置的查找顺序，从最具体开始：

`lang_Script_REGION` → `lang_Script` → `lang_REGION` → `lang` → `en`

因此 `zh-Hant-TW` 界面在有 `zh_Hant` 行时读它，在那之前读 `zh`（简体）文本，而不是掉回英语。
`kReferenceLanguages` 列出表格携带的语言（目前是 `en`、`zh`）；
`test/reference/reference_catalog_test.dart` 要求每一行都有列出的每种语言。标签分隔符在 `zh` / `ja`
下使用全角冒号。

### 1.7 CI 检查什么

| 检查 | 位置 | 守护的内容 |
|---|---|---|
| `dart run tool/ui_literal_guard.dart` | `.github/workflows/analyze.yml`（"UI literal guard (localisation)"）、`tool/test_pyramid.sh` 的 gates 层 | 硬门禁。解析 `apps/morsecq/lib/**` 下的每个文件（跳过生成代码），凡是含字母的字符串字面量被直接传给用户可见的位置（`Text`、`TextSpan.text`、`Tooltip.message`、具名参数 `label` / `hintText` / `title` / `tooltip` / ……）即失败。豁免：在该行末尾或其上一行单独写 `// ui-literal-ok: <reason>`；理由必填，失效的标记本身也算违规。经由数据表或辅助函数传递的文案它看不到——代码审查仍然必要。 |
| `test/i18n/arb_consistency_test.dart` | `flutter test apps/morsecq` | 枚举 `lib/l10n/` 下**每一个** `app_*.arb`：`@@locale` 与文件名一致、键集合一致、值非空、模板的每个占位符都出现在译文中、每个复数都有 `other{…}`、`appName` 不翻译、不残留 `@@TODO` 标记、模板中存在一组固定的 `error*` 键（即 `lib/i18n/chat_error_messages.dart` 所映射的错误码；其他 `ChatException` 代码一律显示 `errorUnknown`）。模板中的每个键还必须带非空的 `@key` `description`，且不得指向已删除的 `*_strings.dart` / `*Strings.` 类。 |
| `test/i18n/platform_locales_test.dart` | 同上 | 原生语言声明与 ARB 集合严格相等：Android `res/xml/locale_config.xml`（以及清单中的 `android:localeConfig`）、iOS/macOS 的 `CFBundleLocalizations`、iOS/macOS 的 `*.lproj/InfoPlist.strings` 集合及其在 Xcode 工程中的注册；每个 `NS*UsageDescription` 在每种语言下都有翻译。ARB 的 `zh` 映射为 `zh-Hans`，`zh_Hant` 为 `zh-Hant`，`pt_BR` 为 `pt-BR`。 |
| `test/i18n/locale_resolution_test.dart`、`locale_list_resolution_test.dart`、`locale_controller_test.dart`、`language_settings_tile_test.dart`、`language_dialog_save_test.dart`、`strings_resolver_test.dart` | 同上 | 解析规则（单个区域设置与首选列表）、持久化标签、选择器行为、操作系统语言变化时重新打标签。 |
| `flutter analyze apps/morsecq` | CI 的 analyze 步骤 | 生成的代码能编译；严格 lint。 |

gen-l10n 本身**永远不会因缺少翻译而失败**，而是悄悄回退。基础语言文件（`app_ja.arb`）缺的键会编译成
英语模板值。脚本/地区变体（`app_zh_Hant.arb`）缺的键则根本不会生成：变体类只覆盖其文件里有的键，
于是该键继承基础语言（`zh`，简体）——繁体用户会看到简体文本。toxee 吃过这个亏（ja/ko 在构建全绿的
情况下发布了约 110 条英语字符串），这就是它的 `arb_completeness_test.dart` 存在的原因，也是这里的
一致性测试枚举每一个已发布 ARB 并要求键集合完全一致的原因。

## 2. 添加语言的逐步操作

示例：日语（`ja`）。按需替换标签。

### 第 1 步——创建 ARB

```bash
cd apps/morsecq/lib/l10n
cp app_en.arb app_ja.arb
```

文件名 = `app_` + gen-l10n 期望的区域设置标签：`app_<lang>.arb`、`app_<lang>_<Script>.arb`
（`app_zh_Hant.arb`）或 `app_<lang>_<REGION>.arb`（`app_pt_BR.arb`）。把文件头改成一致：

```json
{
  "@@locale": "ja",
  "appName": "MorseCQ",
  ...
}
```

### 第 2 步——翻译

- 翻译每一个**值**。每个 `{placeholder}` 都要与模板完全一致（一致性测试会逐个检查）。
- ICU 复数必须保留 `other{…}` 分支：`{count, plural, =1{1 session} other{{count} sessions}}`。
  没有复数形式的语言（ja、zh、ko）通常折叠为 `{count, plural, other{{count} 回}}`——
  保留模板中已有的任何 `=0` 特例。
- `appName` 保持为 `MorseCQ`（产品名，测试要求两边相同）。
- `@key` 元数据块在模板之外是可选的；保留无害，删除则让文件更短。翻译过程中可以给条目打上
  `"description": "@@TODO(l10n): …"`；`grep -n '@@TODO' apps/morsecq/lib/l10n/app_ja.arb`
  可列出待办，只要还有残留，一致性测试就会失败。
- 在同一语言内保持业余无线电/摩尔斯词汇一致（`lib/l10n/README.md` 中的中文词表是范本：
  点/划、字符速度、Farnsworth 间距、侧音、直键、双桨、呼号、听抄、发报）。

### 第 3 步——语言目录中的显示名称

打开 `apps/morsecq/lib/i18n/language_catalog.dart`。如果你的标签（或其语言代码）已在
`LanguageCatalog._names` 中，什么都不用做——`ja` → `日本語` 已经在里面。否则加一行**自称**
（该语言对自己的称呼，永不翻译）：

```dart
'cy': 'Cymraeg',
```

对从右到左书写的语言，把它的代码加进 `isRtl` 的集合。没有目录条目时选择器仍能工作，
只是会显示原始标签（`cy`）。

### 第 4 步——生成

```bash
cd apps/morsecq
flutter gen-l10n          # writes lib/l10n/generated/s_ja.dart, updates s.dart
```

`S.supportedLocales` 现在包含 `Locale('ja')`；delegate 的 `isSupported`、选择器和解析器无需进一步编辑
就能识别它。提交重新生成的文件。

### 第 5 步——验证

```bash
# repo root
dart run tool/ui_literal_guard.dart           # no hard-coded UI prose
flutter analyze apps/morsecq
cd apps/morsecq && flutter test test/i18n test/reference
```

然后运行 App（假后端就够了：`flutter run --dart-define=MORSECQ_FAKE_BACKEND=true`），打开 **我 → 语言**，选择 日本語，
确认 shell 立刻重新打标签。再切回"跟随系统"，把设备语言设为日语，以走一遍解析器路径。

### 第 6 步——参考内容行

在 `apps/morsecq/lib/ui/reference/reference_localized_text.dart` 的 `kReferenceLanguages` 中加入该语言，
并为参考表（Q 简语释义、缩略语、勤务符号、助记）的每一行提供该语言的文本；
`test/reference/reference_catalog_test.dart` 会对缺少任一列出语言的行报错。在此之前，§1.6 的查找会显示
英语（脚本/地区变体则显示父语言的文本）。

### 第 7 步——平台语言清单

在以下各处都与 ARB 集合完全一致之前，`test/i18n/platform_locales_test.dart` 会失败
（BCP-47 形式：`ja`、`zh-Hans`、`zh-Hant`、`pt-BR`）：

- **iOS / macOS —— `CFBundleLocalizations`**，位于 `apps/morsecq/ios/Runner/Info.plist` 与
  `macos/Runner/Info.plist`（目前为 `en`、`zh-Hans`）。只有列在这里的语言，iOS 才会在"设置"中提供
  按 App 切换。
- **iOS / macOS —— `InfoPlist.strings`。** 添加 `ios/Runner/<tag>.lproj/InfoPlist.strings` 与
  `macos/Runner/<tag>.lproj/InfoPlist.strings`，翻译对应 `Info.plist` 中的每个 `NS*UsageDescription`
  键（相机、麦克风），译文须与英语文本不同且出现 MorseCQ，`en.lproj` 则须与 `Info.plist` 逐字一致。在 `Runner.xcodeproj/project.pbxproj` 中把该文件注册为
  现有 `InfoPlist.strings` variant group 的一个新本地化（Xcode：选中文件 → File inspector →
  Localization → 勾选该语言），并确认该标签在 `knownRegions` 中；测试两者都检查。
- **Android —— `res/xml/locale_config.xml`。** 在
  `apps/morsecq/android/app/src/main/res/xml/locale_config.xml` 中添加 `<locale android:name="<tag>"/>`，
  `AndroidManifest.xml` 里的 `android:localeConfig` 指向它；它决定 Android 13+ 的"应用语言"列表。
  这个文件是刻意手写的：AGP 的 `generateLocaleConfig` 依据 Android `res/` 与依赖库资源推导语言列表，
  而不是 Flutter 的 ARB 文件，会宣告 App 根本没有文案的语言。如果以后用
  `resourceConfigurations` / `resConfigs` 缩小 APK，也要把新语言保留在那个列表中。
- **Windows / Linux**：无需改动；区域设置来自操作系统的用户配置。

## 3. 脚本与地区变体（zh_Hant、pt_BR……）

遵循 toxee 的先例，但保持最小化：

- **繁体中文。** 添加 `app_zh_Hant.arb`（`"@@locale": "zh_Hant"`），且必须是*完整*文件——
  gen-l10n 会让它缺的任何键悄悄继承简体 `zh` 文本（§1.7），而且一致性测试本来就会拒绝不完整的文件。保留 `app_zh.arb` 作为简体文件；
  不需要单独的 `app_zh_Hans.arb`（toxee 有一个只是作为覆盖层，而且它的完备性测试刻意排除它，
  因为 gen-l10n 通过 `zh` 解析它）。之后解析器会把 `zh-Hant-*`、`zh-TW`、`zh-HK`、`zh-MO` 路由到
  `zh_Hant`，其他中文都路由到 `zh`——无需改代码。`LanguageCatalog` 已把 `zh_Hant` 标为 `繁體中文`。
  它的原生标签是 `zh-Hant`（Info.plist、
  `InfoPlist.strings`、`locale_config.xml`）；在添加 `zh_Hant` 行之前，参考内容显示 `zh` 文本（§1.6）。
  gen-l10n 把该变体生成为子类（`s_zh.dart` 内的 `SZhHant`），只覆盖其文件中含有的键；
  这正是不完整文件会漏出简体文本的原因。用台湾国语书写，不要用粤语口语（toxee 的测试会拒绝
  `咗嘅唔喺哋嚟冇揀`）。
- **地区变体**（`app_pt_BR.arb`、`app_en_GB.arb`）：gen-l10n 要求纯语言文件（`app_pt.arb`）
  作为父级存在。解析器遍历首选列表，对每个条目规则 3 只匹配脚本、不看地区，
  所以 `pt-BR` 设备并不保证拿到 `pt_BR` 文件（它取 `S.supportedLocales` 中第一个无脚本的 `pt*`）。
  请在添加第一个地区变体的同一次改动中，像中文那样给 `resolveSystemLocale` 加上地区偏好。地区变体的持久化标签是 `pt_BR`
  （`localeTag`：只有在没有脚本时才用地区）。
- **RTL**（`ar`、`he`）：Flutter 会根据区域设置自动翻转 `Directionality`；只在 widget 树之外需要提示时
  （托盘菜单、通知布局）才用 `LanguageCatalog.isRtl`。

## 4. 检查清单

- [ ] `apps/morsecq/lib/l10n/app_<tag>.arb` 带 `@@locale`、完整、占位符与 `other{}` 完好、`appName` 未改、无残留 `@@TODO`
- [ ] `LanguageCatalog._names` 中有该语言的自称（适用时也加入 `isRtl`）
- [ ] 已运行 `flutter gen-l10n`；`lib/l10n/generated/` 已提交
- [ ] 参考内容：该语言已加入 `kReferenceLanguages`，且每个参考行都已翻译
- [ ] iOS 与 macOS 的 `Info.plist` 中已更新 `CFBundleLocalizations`
- [ ] iOS 与 macOS 都已添加 `<tag>.lproj/InfoPlist.strings`（覆盖每个 `NS*UsageDescription`）并在两个 Xcode 工程中注册
- [ ] `android/app/src/main/res/xml/locale_config.xml` 中已添加 `<locale android:name="<tag>"/>`
- [ ] `dart run tool/ui_literal_guard.dart`、`flutter analyze apps/morsecq` 与 `flutter test apps/morsecq` 通过（含 `arb_consistency_test` 与 `platform_locales_test`）
- [ ] 手动检查：我 → 语言 切换；设备设为新语言时的跟随系统；在 Android 13+ / iOS 上，App 内选"跟随系统"时操作系统的按 App 语言设置
- [ ] 移动端兼容：Dart 部分是共享的；平台专有的步骤是上面的 plist / `InfoPlist.strings` / `locale_config.xml` 条目
