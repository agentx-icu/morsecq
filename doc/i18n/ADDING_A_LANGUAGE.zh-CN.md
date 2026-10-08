[English](ADDING_A_LANGUAGE.md)

# 添加界面语言

MorseCQ 提供英语（`en`，模板）、简体中文（`zh`）、繁体中文（`zh_Hant`）、日语（`ja`）、韩语（`ko`）、德语（`de`）、法语（`fr`）、西班牙语（`es`）、葡萄牙语（`pt`）和俄语（`ru`）。文档维护英语与简体中文。

Flutter gen-l10n 从完整 ARB 文件生成 `S.supportedLocales`；LocaleController 将其用于语言选择器及系统语言解析。应用内手动选择优先，否则采用操作系统首选列表中的第一个支持语言，没有匹配时使用英语。中文 Hant 或无脚本的 TW/HK/MO 地区采用繁体中文。偏好保存在 main.dart 打开的本地 `settings.json`。

## 添加翻译

1. 将 `apps/morsecq/lib/l10n/app_en.arb` 复制为 `app_<tag>.arb`，设置 `@@locale`。保留全部模板消息并翻译文案；保持占位符名称与类型、ICU 复数分支及产品名。新增消息须在英文中提供 `@key` 描述，并翻译到所有语言。
2. 若 `lib/i18n/language_catalog.dart` 尚无该语言的自称，添加对应名称。Flutter 负责界面方向；必要时更新原生界面的 RTL 提示。
3. 将 `lib/ui/reference/text/reference_text_en.dart` 复制为 `reference_text_<小写标签>.dart`。翻译 Q 简语、缩写、勤务符号、标点和 `digitPhrases` 的值，保持全部键及行顺序。翻译 `phraseNote`；仅在已有确立的电码节奏读法时设置 rhythm。
4. 在 `lib/ui/reference/text/reference_texts.dart` 的 `kReferenceTexts` 中导入并注册文件。参考内容测试要求每个 ARB 语言都有完整且实际翻译的参考资料。
5. 在 iOS/macOS 的 `CFBundleLocalizations`、两个 Xcode 工程的 `knownRegions` 和本地化 `InfoPlist.strings` variant group 中添加标签。创建两套 `<tag>.lproj/InfoPlist.strings`，翻译实际声明的麦克风用途；英文用途须与 Info.plist 完全一致。
6. 在 Android `res/xml/locale_config.xml` 添加对应 BCP-47 标签，`zh` 映射为 `zh-Hans`，`zh_Hant` 映射为 `zh-Hant`。Linux/Windows 使用操作系统语言设置。
7. 扩展 `shipped_locales_test.dart` 及语言选择器用例，运行 gen-l10n 并提交生成文件。

脚本或地区变体需要对应的纯语言 ARB 父文件。繁体中文是现有脚本示例，gen-l10n 将 `SZhHant` 放在 `s_zh.dart`。新增非中文地区变体时，应在 `locale_resolution.dart` 添加明确的地区偏好及测试；当前解析器主要匹配语言与脚本。

## 验证

在仓库根目录运行：

```sh
dart pub get --enforce-lockfile
dart run tool/ui_literal_guard.dart
flutter analyze apps/morsecq
cd apps/morsecq
flutter gen-l10n
flutter test --no-pub test/i18n test/reference
flutter run -d macos
```

在 **我的 → 语言** 选择新语言，再改为跟随系统。检查学习/参考/我的标签、原生托盘、参考资料、小屏布局、重启后的偏好及 Android/iOS 按应用语言设置。`arb_consistency_test`、`platform_locales_test` 与 `reference_texts_test` 分别保护消息键、平台声明及参考资料。

日常文案规范见 [l10n README](../../apps/morsecq/lib/l10n/README.zh-CN.md)。
