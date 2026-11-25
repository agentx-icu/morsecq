# 首次学习界面验证 — 2026-11-25

[English](FIRST_SUCCESS_VALIDATION.md)

学习首页精简的今日计划现在在“继续”前显示下一个必需练习及其既有依据。完成计划的小结仅在该计划确有逐字符抄收结果时显示“没有薄弱字符”；仅完成入门或发报的计划会说明没有记录抄收结果。完成计划与通过课程继续明确区分，没有修改课程解锁、练习计分、计划安排或持久化规则。

## 已执行检查

- 实现前，两项新增行为回归按预期失败：没有可见的下一步预览，以及仅完成入门的计划显示“没有薄弱字符”。原八项计划卡片用例通过。
- 在 `apps/morsecq` 执行 `flutter test --no-pub test/learn/today_plan_card_test.dart test/learn/learn_home_layout_test.dart test/learn/daily_plan_flow_test.dart test/learn/first_lesson_endings_test.dart test/i18n/arb_consistency_test.dart --reporter expanded`：**50 项通过**。包含 320 px 宽、德语两倍文字、下一步依据、无成绩时的小结、真实薄弱字符结果、午夜换日、既有第一课推进及十语言 ARB 一致性。
- `flutter analyze --no-pub apps/morsecq`：零问题。
- `dart run tool/check_complexity.dart` 与 `dart run tool/ui_literal_guard.dart`：通过。
- 首轮完整 widget 扫描发现两项 320×640/1.8 倍文字回归：新增预览标题把“继续”推到首屏以下。移除这行冗余标题，保留下一个练习及依据后，既有七项首页布局检查通过，没有放宽可见性断言。
- 布局修正后的完整 hermetic 应用扫描：**1,306 项通过、753 项跳过、零失败**，日志位于 `/tmp/morsecq-first-success-all-widget-final.log`。753 项字体相关布局用例需要 `MORSECQ_MATRIX_FONT`，仍由独立 Layout 任务验证，本轮不冒称通过。最后将十语言“没有薄弱字符”的范围明确为已记录的抄收结果，并说明缺少逐字符结果，其计划卡片与 ARB 检查共 20 项通过。
- 已执行 `flutter gen-l10n`，十种规范语言均补充练习与课程证据的区分文案。

## 设备与参与者边界

布局证据来自 Flutter widget 渲染，不是实体手机显示或读屏器验收。安装包上的触摸、键盘和辅助技术操作仍需设备验证。本次没有为应用增加音频、麦克风、通知、相机或生命周期代码。实体蓝牙切换及正式渠道升级仍按发行准备记录单独验收。

[新手试用流程](BEGINNER_TRIAL.zh-CN.md)及[空白观察 CSV](fixtures/beginner-observations.csv)已可供 5–10 位自愿参与者在其实际首日、第七日使用。尚未招募参与者、发送联系消息或观察第七日回访，自动化检查不代表真人试用结果。

跨平台清单：L3/L8/L10 窄屏及大字布局为 **widget 已验证**；D2 十语言资源 **已验证**；I5 实际读屏遍历 **需设备**；A/B/V 硬件音频、生命周期及相机改动 **不适用于此次纯界面调整**；X6 已安装候选包与签名升级 **需安装包及设备证据**。
