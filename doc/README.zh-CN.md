[English](./README.md)

# morsecq 文档

## 惯例：双语，英文为默认

本仓库的每份文档都成对存在：

- `X.md` —— **英文，默认版本。** 链接、README 与 CI 均指向它。
- `X.zh-CN.md` —— 简体中文。

每个文件的第一行是指向对应语言版本的链接（英文文件中为 `[简体中文](./X.zh-CN.md)`，
中文文件中为 `[English](./X.md)`）。新增文档时两份都要添加。两版不一致时，以先写成的
那一份为准，并在文件顶部注明（目前是：规划文档以中文原稿为准；`BUILD_AND_DEPLOY.md`
英文版是中文版的精简摘要，以中文为准）。

## 推荐阅读路径

- **接手项目** —— [HANDOVER.zh-CN.md](HANDOVER.zh-CN.md)：上一会话结束时的状态、坑、待办、多代理开发方式。
- **只想跑起来** —— [主 README](../README.zh-CN.md)「构建前提」→
  [operations/BUILD_AND_DEPLOY.zh-CN.md](operations/BUILD_AND_DEPLOY.zh-CN.md)
  了解本平台的原生库构建。
- **贡献代码** —— [CLAUDE.md](../CLAUDE.md)（目录结构、门禁、工作约定）→
  [plans/2026-09-30-morsecq-plan.zh-CN.md](plans/2026-09-30-morsecq-plan.zh-CN.md)
  §3「技术选型与架构决策」→ 所改动的包或子区域的 README（见下）。
- **改动范围或产品决策** —— 规划文档是唯一事实来源；每次编辑都要在其变更记录中追加一条。

## 规划（方案）

- [plans/2026-09-30-morsecq-plan.zh-CN.md](plans/2026-09-30-morsecq-plan.zh-CN.md) /
  [English](plans/2026-09-30-morsecq-plan.md) —— 立项产品与架构规划：命名、产品定义、
  Tim2Tox 关键事实、四个方案与「B 变体」决策、训练与通信设计、里程碑、风险、多代理
  编排、变更记录。**中文为原稿。**

## 操作与构建

- [operations/BUILD_AND_DEPLOY.zh-CN.md](operations/BUILD_AND_DEPLOY.zh-CN.md) /
  [English](operations/BUILD_AND_DEPLOY.md) —— 在 Linux、macOS、Windows、Android、
  iOS 上构建 `libtim2tox_ffi` 原生库（默认 `--no-toxav`）；库在各平台包中的落点；
  最低系统版本；`native.yml` CI 流程及其无法验证的部分。

## 包（`packages/*`）

每个包都有自己的 README（英文为默认；`.zh-CN.md` 对应版本在同一目录）。

- [morse_core](../packages/morse_core/README.md) —— 纯 Dart 莫斯引擎：字母表与
  prosign、PARIS / Farnsworth 时序、文本 → 时间轴编码器、手键输入的流式解码器。
- [morse_trainer](../packages/morse_trainer/README.md) —— 纯 Dart 教学法：Koch 课程、
  题目生成器、基于对齐的评分、间隔复习、发报练习诊断、学习进度。
- [morse_dsp](../packages/morse_dsp/README.md) —— 纯 Dart 音频解码：Goertzel 音调检测、
  自动调谐、包络门限、`AudioMorseDecoder`。
- [morse_io](../packages/morse_io/README.md) —— Flutter I/O：`flutter_soloud` 侧音、
  触觉、闪光、直键 / 双桨状态机，以及触屏与键盘的按键控件。
- [morsecq_chat_api](../packages/morsecq_chat_api/README.md) —— UI 与聊天后端之间的
  纯 Dart 契约（`IdentityService`、`ChatService`、模型、`testing.dart` 中的内存假实现）。
- [morsecq_chat](../packages/morsecq_chat/README.md) —— 基于 Tim2Tox 的契约实现；
  唯一允许 import Tim2Tox 或腾讯 SDK 的包。

## App 子区域（`apps/morsecq`）

- [apps/morsecq](../apps/morsecq/README.md) —— Flutter App 外壳。
- [lib/notifications](../apps/morsecq/lib/notifications/README.md) —— 本地通知、
  未读角标、前后台处理与移动端后台策略（`lib/lifecycle`）。
- [lib/desktop](../apps/morsecq/lib/desktop/README.md) —— macOS / Windows / Linux 的
  窗口管理、系统托盘与快捷键（移动端为 no-op）。
- [lib/l10n](../apps/morsecq/lib/l10n/README.md) —— gen-l10n 配置、ARB 文件
  （`app_en.arb` 模板、`app_zh.arb`）、`S` 类与 `strings_to_arb` 迁移工具。
- [doc/i18n/ADDING_A_LANGUAGE.zh-CN.md](./i18n/ADDING_A_LANGUAGE.zh-CN.md) —— UI 多语言方案说明与新增语言步骤（ARB、语言目录、plist）。

## 跨项目联动

- [主 README](../README.zh-CN.md) / [English](../README.md)
- [CLAUDE.md](../CLAUDE.md) —— 约定、硬门禁、工作约定
- **Tim2Tox**（上游 [agentx-icu/tim2tox](https://github.com/agentx-icu/tim2tox)，
  以 `third_party/tim2tox` 子模块引入）：[文档索引](../third_party/tim2tox/doc/README.md)
- **toxee**（姊妹项目，共用 Tim2Tox 线路协议）：
  [github.com/agentx-icu/toxee](https://github.com/agentx-icu/toxee)
