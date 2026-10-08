[English](README.md)

# MorseCQ 本地化

离线应用提供十套完整 ARB：en、zh、zh_Hant、ja、ko、de、fr、es、pt、ru。`app_en.arb` 是模板；`apps/morsecq/l10n.yaml` 在 `lib/l10n/generated/` 生成 S 类。生成文件须提交，不直接编辑。

main.dart 打开本地 `settings.json`，在 MaterialApp 之上提供 LocaleController。`S.supportedLocales` 定义支持语言集合。应用内手动选择优先；跟随系统时采用首选列表中的第一个支持语言。Hant 或无显式脚本的 TW/HK/MO 使用繁体中文。Android locale_config 与 Apple CFBundleLocalizations/InfoPlist.strings 声明同一集合。

在 MaterialApp 下使用本地化消息：

```dart
Text(context.s.navLearn)
Text(context.s.learnLessonOf(lesson, total))
Text(context.s.statsSessions(count))
```

不依赖 context 的代码传入 S 或使用 `currentS()`。AppServices 持有 StringsResolver，在语言变化时刷新桌面托盘文案。控制器提供状态和错误，由界面选择对应翻译。

## 添加消息

1. 在英文模板及每个翻译 ARB 添加键，按学习、统计、参考、听音、素材、设置或通用操作命名。
2. 在模板提供 `@key` 描述及占位符类型。所有翻译保持占位符名称及 ICU 复数分支，始终包含 `other`，采用对应语言的语法类别。
3. 在 `apps/morsecq` 运行 `flutter gen-l10n` 并提交生成文件。
4. 在根目录运行 `dart run tool/ui_literal_guard.dart`，再执行应用 `test/i18n` 与分析。门禁拒绝硬编码界面文案；模型枚举保持与 Flutter 字符串独立。

参考释义及助记位于 `lib/ui/reference/text/reference_text_<tag>.dart`，在 kReferenceTexts 注册。保留英文的行键与顺序，每种语言均须完整翻译。平台声明、变体及检查见[添加语言](../../../../doc/i18n/ADDING_A_LANGUAGE.zh-CN.md)。
