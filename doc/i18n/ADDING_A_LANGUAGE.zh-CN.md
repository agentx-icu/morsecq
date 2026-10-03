[English](./ADDING_A_LANGUAGE.md)

# 为 MorseCQ 添加一种界面语言

MorseCQ 通过 Flutter gen-l10n 提供英语（`en`，模板）、简体中文（`zh`）、繁体中文
（`zh_Hant`）、日语（`ja`）、韩语（`ko`）、德语（`de`）、法语（`fr`）、
西班牙语（`es`）、葡萄牙语（`pt`）和俄语（`ru`）。每份译文完整包含模板的
656 条消息（2026-10-03）。文档仍只维护英文和简体中文。

本页说明共享本地化流程与扩展方法。日常字符串工作和摩尔斯词汇请看
[`apps/morsecq/lib/l10n/README.zh-CN.md`](../../apps/morsecq/lib/l10n/README.zh-CN.md)。

## 1. 本地化是如何工作的

### 1.1 gen-l10n 与 `S` 类

| 组成 | 位置 | 说明 |
|---|---|---|
| gen-l10n 配置 | `apps/morsecq/l10n.yaml` | `arb-dir: lib/l10n`、`template-arb-file: app_en.arb`、`output-class: S`、`output-dir: lib/l10n/generated`、`output-localization-file: s.dart`、`nullable-getter: false`、`format: false`。不设 `synthetic-package`（Flutter 3.41 已移除；该键只会打印警告）。 |
| 自动生成 | `apps/morsecq/pubspec.yaml` → `flutter: generate: true` | `flutter run` / `flutter build` 会重新生成；`flutter gen-l10n` 显式执行。 |
| ARB 文件 | `apps/morsecq/lib/l10n/app_<tag>.arb` | 每个区域设置一个。`app_en.arb` 是模板，也是唯一需要 `@key` 元数据（description、placeholders）的文件。截至 2026-10-03 有 656 个消息键。 |
| 生成的代码 | `apps/morsecq/lib/l10n/generated/s.dart`、`s_<language>.dart` | 已提交，永不手改。通过 `**/l10n/**` 模式免于 500 行门禁。 |
| 访问方式 | `context.s`（`lib/i18n/l10n_extension.dart`）或 `S.of(context)` | 仅在 `MaterialApp` 之下可用；测试需要 pump `localizationsDelegates: S.localizationsDelegates`。 |
| 支持的集合 | `S.supportedLocales` | 由 ARB 文件推导。`LocaleController.supportedLocales` 和语言选择器都读它，因此**添加语言不需要编辑任何 Dart 列表**。 |

`main.dart` 中的接线：

```dart
MaterialApp(
  onGenerateTitle: (context) => S.of(context).appName,
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: context.watch<LocaleController>().locale,   // null = follow system
  localeResolutionCallback: LocaleController.resolve,
  ...
)
```

### 1.2 `LocaleController`：跟随系统或手动覆盖

`lib/i18n/locale_controller.dart` 是一个 `ChangeNotifier`，由 `AppScope` 在 `MaterialApp` 之上提供。

- `locale` 是**覆盖值**（`null` = 跟随系统）。"我"页面的 `LanguageSettingsTile`
  （`lib/i18n/language_settings_tile.dart`）负责设置它。
- `effectiveLocale` 是 UI 此刻真正渲染所用的区域设置：覆盖值，或设备区域设置按 `S.supportedLocales`
  解析后的结果。
- 持久化经由 `KeyValueStore` 接口（`lib/i18n/key_value_store.dart`）。生产环境使用
  `JsonFileKeyValueStore`，文件为 `<application support>/settings.json`（在 `main.dart` 中打开；
  桌面 shell 通过 `DesktopStoreAdapter` 共享同一个文件）；假后端和测试使用 `InMemoryKeyValueStore`。
  键：`i18n.locale`；值：`localeTag()` 生成的标签——`en`、`zh`、`zh_Hant`、`pt_BR`
  （脚本优先于地区）。`parseLocaleTag()` 接受 `-`/`_`、任意大小写以及旧式的 `zh_CN`，
  因此添加语言时已有的偏好设置永远不需要迁移。
- 若保存的标签在当前构建中已不再提供，则回退为"跟随系统"。

### 1.3 一条解析规则，用在三处

`lib/i18n/locale_resolution.dart::resolveSystemLocale(system, supported)` 是 toxee 解析器的泛化版本，
把支持的集合变成了数据：

1. 没有 ARB 的语言 → 英语（`fallback`）。
2. 中文：脚本为 `Hant`，**或**没有脚本但地区为 TW / HK / MO 时用繁体（Android 上报 `zh-TW` 不带脚本，
   iOS 上报 `zh-Hant-TW`）——*前提是*提供了 `zh_Hant` ARB；否则用简体文件（有 `zh_Hans` 用之，
   否则用普通的 `zh`）。
3. 其他语言：有脚本精确匹配的就用它，否则用仅含语言代码的文件。

同一个函数支撑着 `MaterialApp.localeResolutionCallback`（`LocaleController.resolve`）、
`LocaleController.effectiveLocale` 和无需 context 的 `currentLocale()`，因此 widget 树、
设置项和通知永远一致。`supportedLocaleFor()` 是同一规则去掉英语回退的版本（用于校验用户的选择）。

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
  `ChangeNotifier` 视图，在用户更改设置时，或在跟随系统模式下操作系统区域设置变化时
  （`PlatformDispatcher.onLocaleChanged`）触发重新打标签。

通知在发送时通过 `S Function()` 解析文本，桌面外壳在语言变化时调用
`DesktopShellController.updateStrings(strings.s)`。新增 ARB 因此也会翻译系统通知
和托盘字符串。已显示的通知保留原文本；Android 通知渠道名保留首次创建时的语言。

参考手册的释义与记忆提示是独立数据表，目前提供英文和简体中文。繁体中文
使用中文数据表；其余新增界面语言沿用现有英文回退。翻译这些数据表与新增
界面消息属于不同工作。

### 1.6 CI 检查什么

| 检查 | 位置 | 守护的内容 |
|---|---|---|
| `dart run tool/strings_to_arb.dart --check` | `.github/workflows/analyze.yml`（"Localisation strings in sync"） | `apps/morsecq/lib/ui/**/*_strings.dart` 中的每个 `static const` 在模板**以及** ARB 目录里的每个其他 `app_*.arb` 中都有对应的键（工具自己枚举 `app_*.arb`，所以新文件会自动被覆盖）。缺任何一项即 exit 1。 |
| `test/i18n/arb_consistency_test.dart` | `flutter test apps/morsecq` | 键集合一致、声明了 `@@locale`、值非空、模板的每个占位符都出现在译文中、每个复数都有 `other{…}`、`appName` 不翻译、每个 `ChatException` 代码都有一个 `error*` 键。自动发现所有 `app_*.arb`。 |
| `test/i18n/locale_resolution_test.dart`、`locale_controller_test.dart`、`language_settings_tile_test.dart` | 同上 | 解析规则、持久化标签、选择器行为。 |
| `flutter analyze apps/morsecq` | CI 的 analyze 步骤 | 生成的代码能编译；严格 lint。 |

gen-l10n 本身**永远不会因缺少翻译而失败**：它会悄悄把英语模板值编译进任何缺少该键的区域设置。
toxee 吃过这个亏（ja/ko 在构建全绿的情况下发布了约 110 条英语字符串），这就是它的
`arb_completeness_test.dart` 存在的原因，也是这里的一致性测试必须覆盖每一个已发布 ARB 的原因。

## 2. 添加语言的逐步操作

示例：尚未发布的意大利语（`it`）。按需替换标签。

### 第 1 步——创建 ARB

```bash
cd apps/morsecq/lib/l10n
cp app_en.arb app_it.arb
```

文件名 = `app_` + gen-l10n 期望的区域设置标签：`app_<lang>.arb`、`app_<lang>_<Script>.arb`
（`app_zh_Hant.arb`）或 `app_<lang>_<REGION>.arb`（`app_pt_BR.arb`）。把文件头改成一致：

```json
{
  "@@locale": "it",
  "appName": "MorseCQ",
  ...
}
```

### 第 2 步——翻译

- 翻译每一个**值**。每个 `{placeholder}` 都要与模板完全一致（一致性测试会逐个检查）。
- ICU 复数必须保留 `other{…}` 分支：`{count, plural, =1{1 session} other{{count} sessions}}`。
  没有复数形式的语言（ja、zh、ko）通常折叠为 `{count, plural, other{{count} 回}}`——
  保留模板中已有的任何 `=0` 特例。
- 欧洲语言通常使用 `one` / `other`；俄语使用 `one` / `few` / `many` / `other`，
  只保留精确匹配的 `=1` 会遗漏 21、31 等数字的单数形式。
- `appName` 保持为 `MorseCQ`（产品名，测试要求两边相同）。
- `@key` 元数据块在模板之外是可选的；保留无害，删除则让文件更短。迁移工具会给它添加的未翻译条目
  打上 `"description": "@@TODO(l10n): …"`；`grep -n '@@TODO' apps/morsecq/lib/l10n/app_it.arb`
  可列出待办。
- 在同一语言内保持业余无线电/摩尔斯词汇一致（`lib/l10n/README.md` 中的中文词表是范本：
  点/划、字符速度、Farnsworth 间距、侧音、直键、双桨、呼号、听抄、发报）。

### 第 3 步——语言目录中的显示名称

打开 `apps/morsecq/lib/i18n/language_catalog.dart`。如果你的标签（或其语言代码）已在
`LanguageCatalog._names` 中，什么都不用做——`it` → `Italiano` 已经在里面。否则加一行**自称**
（该语言对自己的称呼，永不翻译）：

```dart
'cy': 'Cymraeg',
```

对从右到左书写的语言，把它的代码加进 `isRtl` 的集合。没有目录条目时选择器仍能工作，
只是会显示原始标签（`cy`）。

### 第 4 步——生成

```bash
cd apps/morsecq
flutter gen-l10n          # writes lib/l10n/generated/s_it.dart, updates s.dart
```

`S.supportedLocales` 现在包含 `Locale('it')`；delegate 的 `isSupported`、选择器和解析器无需进一步编辑
就能识别它。提交重新生成的文件。

### 第 5 步——验证

```bash
# repo root
dart run tool/strings_to_arb.dart --check     # every *_strings.dart const present in app_it.arb
flutter analyze apps/morsecq
cd apps/morsecq && flutter test test/i18n
```

然后运行 App（使用 `--dart-define=MORSECQ_FAKE_BACKEND=true`），打开 **我 → 语言**，选择 Italiano，
确认 shell 立刻重新打标签。再切回"跟随系统"，把设备语言设为意大利语，以走一遍解析器路径。

### 第 6 步——测试完整性与语言选择

`test/i18n/arb_consistency_test.dart` 自动发现所有 `app_*.arb`，检查与英文模板相同
的键集合、占位符和复数分支。发布语言集合变化时更新 `shipped_locales_test.dart`，
并在 `language_settings_tile_test.dart` 的小屏幕用例中增加新的语言自称。
验证持久化、后台字符串、系统解析和不同数量的语法形式。

### 第 7 步——平台清单

- **iOS / macOS**：同步 `apps/morsecq/ios/Runner/Info.plist` 与
  `macos/Runner/Info.plist` 中的 `CFBundleLocalizations`，列出全部受支持语言。
  使用 BCP-47 标签（`it`、`zh-Hans`、`zh-Hant`），简体 `zh` ARB 对应 `zh-Hans`。
  发布语言测试会检查两份声明；Apple 系统设置也可以据此提供应用语言选项。
- **Android**：无需改动。如果以后用 `resourceConfigurations` / `resConfigs` 缩小 APK，
  记得把新语言保留在列表中。
- **Windows / Linux**：无需改动；区域设置来自操作系统的用户配置。

## 3. 脚本与地区变体（zh_Hant、pt_BR……）

遵循 toxee 的先例，但保持最小化：

- **繁体中文。** 添加 `app_zh_Hant.arb`（`"@@locale": "zh_Hant"`），且必须是*完整*文件——
  不要依赖 gen-l10n 回退到 `zh`，那样任何漏掉的键都会显示简体文本。保留 `app_zh.arb` 作为简体文件；
  不需要单独的 `app_zh_Hans.arb`（toxee 有一个只是作为覆盖层，而且它的完备性测试刻意排除它，
  因为 gen-l10n 通过 `zh` 解析它）。之后解析器会把 `zh-Hant-*`、`zh-TW`、`zh-HK`、`zh-MO` 路由到
  `zh_Hant`，其他中文都路由到 `zh`——无需改代码。`LanguageCatalog` 已把 `zh_Hant` 标为 `繁體中文`。
  gen-l10n 把该变体生成为子类（`s_zh.dart` 内的 `SZhHant`），所以脚本文件理论上可以只含有差异的键——
  但基于上面的原因，还是请完整发布。用台湾国语书写，不要用粤语口语（toxee 的测试会拒绝
  `咗嘅唔喺哋嚟冇揀`）。
- **地区变体**（`app_pt_BR.arb`、`app_en_GB.arb`）：gen-l10n 要求纯语言文件（`app_pt.arb`）
  作为父级存在。解析器先选脚本精确匹配，再选仅含语言的文件；对于只有地区的变体，规则 3 会落到父级，
  除非你像中文那样给 `resolveSystemLocale` 加上地区偏好。地区变体的持久化标签是 `pt_BR`
  （`localeTag`：只有在没有脚本时才用地区）。
- **RTL**（`ar`、`he`）：Flutter 会根据区域设置自动翻转 `Directionality`；只在 widget 树之外需要提示时
  （托盘菜单、通知布局）才用 `LanguageCatalog.isRtl`。

## 4. 检查清单

- [ ] `apps/morsecq/lib/l10n/app_<tag>.arb` 带 `@@locale`、完整、占位符与 `other{}` 完好、`appName` 未改
- [ ] `LanguageCatalog._names` 中有该语言的自称（适用时也加入 `isRtl`）
- [ ] 已运行 `flutter gen-l10n`；`lib/l10n/generated/` 已提交
- [ ] `dart run tool/strings_to_arb.dart --check` 通过
- [ ] `test/i18n/arb_consistency_test.dart` 自动发现新文件；已更新发布语言与选择器测试
- [ ] `flutter analyze apps/morsecq` 与 `flutter test apps/morsecq` 通过
- [ ] iOS 与 macOS 的 `Info.plist` 中已更新 `CFBundleLocalizations`
- [ ] 手动检查：我 → 语言 切换，以及设备设为新语言时的跟随系统
- [ ] 移动端兼容：以上全部是共享 Dart；唯一平台专有的步骤是 plist 条目
