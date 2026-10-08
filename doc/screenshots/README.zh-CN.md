[English](./README.md)

# 截图

由 `tool/screenshots/capture.sh`（见
[tool/screenshots/README.zh-CN.md](../../tool/screenshots/README.zh-CN.md)）从真实
应用截取：灌入演示数据、清爽现代风格、浅色主题、英文与简体中文。只有整个平台一次跑通才会发布，
所以这里的帧永远是完整、一致的一套。UI 改动后重新生成，不要手工修改 PNG。

| 平台 | 状态 | 尺寸 |
|---|---|---|
| macOS | 2026-10-08 已截（教学流程） | 1280×800 @1x |
| iOS（iPhone） | 2026-10-08 已截（教学流程，App Store 6.9 英寸） | 440×956 @3x（1320×2868 像素，RGB） |
| iPad | 2026-10-08 已截（教学流程） | 1032×1376 @2x（2064×2752 像素，RGB） |
| Android | 2026-10-08 已截（教学流程） | ≈412×915 @2x（823×1829 px） |
| Linux | 2026-10-01 已截（CI，ubuntu-24.04 + Xvfb） | 1280×800 @1x |
| Windows | 2026-10-01 已截（CI，windows-2022） | 1280×800 @1x |

Linux、Windows 截图来自成功的 [E2E 运行 36839181762](https://github.com/agentx-icu/morsecq/actions/runs/36839181762)，
UI 版本为 `0a83b325f8d9533340b851cf40672d129d4991fd`，通过 `capture.sh --from`
执行相同发布校验后导入；本机目标已为教学 worktree 重新生成，实际日期见上表。

## macOS

| 场景 | English | 简体中文 |
|---|---|---|
| 欢迎（首次启动） | ![](macos/en/welcome.png) | ![](macos/zh/welcome.png) |
| 创建身份 | ![](macos/en/create_identity.png) | ![](macos/zh/create_identity.png) |
| 备份向导 | ![](macos/en/backup_wizard.png) | ![](macos/zh/backup_wizard.png) |
| 学习首页 | ![](macos/en/learn_home.png) | ![](macos/zh/learn_home.png) |
| 统计 | ![](macos/en/stats.png) | ![](macos/zh/stats.png) |
| 训练设置 | ![](macos/en/training_settings.png) | ![](macos/zh/training_settings.png) |
| 听抄练习 | ![](macos/en/receive_drill.png) | ![](macos/zh/receive_drill.png) |
| 发报练习 | ![](macos/en/send_practice.png) | ![](macos/zh/send_practice.png) |
| 入门试听 | ![](macos/en/first_lesson.png) | ![](macos/zh/first_lesson.png) |
| 听抄小结 | ![](macos/en/receive_summary.png) | ![](macos/zh/receive_summary.png) |
| 发报带练 | ![](macos/en/guided_send.png) | ![](macos/zh/guided_send.png) |
| 会话列表 | ![](macos/en/chat_list.png) | ![](macos/zh/chat_list.png) |
| 会话 | ![](macos/en/conversation.png) | ![](macos/zh/conversation.png) |
| 联系人 | ![](macos/en/contacts.png) | ![](macos/zh/contacts.png) |
| 群组 | ![](macos/en/groups.png) | ![](macos/zh/groups.png) |
| 群会话 | ![](macos/en/group_conversation.png) | ![](macos/zh/group_conversation.png) |
| 手册 | ![](macos/en/reference.png) | ![](macos/zh/reference.png) |
| 翻译器 | ![](macos/en/translator.png) | ![](macos/zh/translator.png) |
| 收听 | ![](macos/en/listen.png) | ![](macos/zh/listen.png) |
| 我 | ![](macos/en/me.png) | ![](macos/zh/me.png) |

## iOS（iPhone 17 Pro Max 模拟器）

离线的 App Store 版本（`MORSECQ_SHOT_VARIANT=offline`）：没有聊天场景。

| 场景 | English | 简体中文 |
|---|---|---|
| 学习首页 | ![](ios/en/learn_home.png) | ![](ios/zh/learn_home.png) |
| 统计 | ![](ios/en/stats.png) | ![](ios/zh/stats.png) |
| 训练设置 | ![](ios/en/training_settings.png) | ![](ios/zh/training_settings.png) |
| 听抄练习 | ![](ios/en/receive_drill.png) | ![](ios/zh/receive_drill.png) |
| 发报练习 | ![](ios/en/send_practice.png) | ![](ios/zh/send_practice.png) |
| 入门试听 | ![](ios/en/first_lesson.png) | ![](ios/zh/first_lesson.png) |
| 听抄小结 | ![](ios/en/receive_summary.png) | ![](ios/zh/receive_summary.png) |
| 发报带练 | ![](ios/en/guided_send.png) | ![](ios/zh/guided_send.png) |
| 手册 | ![](ios/en/reference.png) | ![](ios/zh/reference.png) |
| 翻译器 | ![](ios/en/translator.png) | ![](ios/zh/translator.png) |
| 收听 | ![](ios/en/listen.png) | ![](ios/zh/listen.png) |
| 我 | ![](ios/en/me.png) | ![](ios/zh/me.png) |

## iPad（iPad Pro 13 英寸模拟器）

离线的 App Store 版本（`MORSECQ_SHOT_VARIANT=offline`）：没有聊天场景。

| 场景 | English | 简体中文 |
|---|---|---|
| 学习首页 | ![](ipad/en/learn_home.png) | ![](ipad/zh/learn_home.png) |
| 统计 | ![](ipad/en/stats.png) | ![](ipad/zh/stats.png) |
| 训练设置 | ![](ipad/en/training_settings.png) | ![](ipad/zh/training_settings.png) |
| 听抄练习 | ![](ipad/en/receive_drill.png) | ![](ipad/zh/receive_drill.png) |
| 发报练习 | ![](ipad/en/send_practice.png) | ![](ipad/zh/send_practice.png) |
| 入门试听 | ![](ipad/en/first_lesson.png) | ![](ipad/zh/first_lesson.png) |
| 听抄小结 | ![](ipad/en/receive_summary.png) | ![](ipad/zh/receive_summary.png) |
| 发报带练 | ![](ipad/en/guided_send.png) | ![](ipad/zh/guided_send.png) |
| 手册 | ![](ipad/en/reference.png) | ![](ipad/zh/reference.png) |
| 翻译器 | ![](ipad/en/translator.png) | ![](ipad/zh/translator.png) |
| 收听 | ![](ipad/en/listen.png) | ![](ipad/zh/listen.png) |
| 我 | ![](ipad/en/me.png) | ![](ipad/zh/me.png) |

## Android（模拟器，API 36）

| 场景 | English | 简体中文 |
|---|---|---|
| 欢迎（首次启动） | ![](android/en/welcome.png) | ![](android/zh/welcome.png) |
| 创建身份 | ![](android/en/create_identity.png) | ![](android/zh/create_identity.png) |
| 备份向导 | ![](android/en/backup_wizard.png) | ![](android/zh/backup_wizard.png) |
| 学习首页 | ![](android/en/learn_home.png) | ![](android/zh/learn_home.png) |
| 统计 | ![](android/en/stats.png) | ![](android/zh/stats.png) |
| 训练设置 | ![](android/en/training_settings.png) | ![](android/zh/training_settings.png) |
| 听抄练习 | ![](android/en/receive_drill.png) | ![](android/zh/receive_drill.png) |
| 发报练习 | ![](android/en/send_practice.png) | ![](android/zh/send_practice.png) |
| 入门试听 | ![](android/en/first_lesson.png) | ![](android/zh/first_lesson.png) |
| 听抄小结 | ![](android/en/receive_summary.png) | ![](android/zh/receive_summary.png) |
| 发报带练 | ![](android/en/guided_send.png) | ![](android/zh/guided_send.png) |
| 会话列表 | ![](android/en/chat_list.png) | ![](android/zh/chat_list.png) |
| 会话 | ![](android/en/conversation.png) | ![](android/zh/conversation.png) |
| 联系人 | ![](android/en/contacts.png) | ![](android/zh/contacts.png) |
| 群组 | ![](android/en/groups.png) | ![](android/zh/groups.png) |
| 群会话 | ![](android/en/group_conversation.png) | ![](android/zh/group_conversation.png) |
| 手册 | ![](android/en/reference.png) | ![](android/zh/reference.png) |
| 翻译器 | ![](android/en/translator.png) | ![](android/zh/translator.png) |
| 收听 | ![](android/en/listen.png) | ![](android/zh/listen.png) |
| 我 | ![](android/en/me.png) | ![](android/zh/me.png) |

## Linux（CI：ubuntu-24.04，Xvfb）

| 场景 | English | 简体中文 |
|---|---|---|
| 欢迎（首次启动） | ![](linux/en/welcome.png) | ![](linux/zh/welcome.png) |
| 创建身份 | ![](linux/en/create_identity.png) | ![](linux/zh/create_identity.png) |
| 备份向导 | ![](linux/en/backup_wizard.png) | ![](linux/zh/backup_wizard.png) |
| 学习首页 | ![](linux/en/learn_home.png) | ![](linux/zh/learn_home.png) |
| 统计 | ![](linux/en/stats.png) | ![](linux/zh/stats.png) |
| 训练设置 | ![](linux/en/training_settings.png) | ![](linux/zh/training_settings.png) |
| 听抄练习 | ![](linux/en/receive_drill.png) | ![](linux/zh/receive_drill.png) |
| 发报练习 | ![](linux/en/send_practice.png) | ![](linux/zh/send_practice.png) |
| 会话列表 | ![](linux/en/chat_list.png) | ![](linux/zh/chat_list.png) |
| 会话 | ![](linux/en/conversation.png) | ![](linux/zh/conversation.png) |
| 联系人 | ![](linux/en/contacts.png) | ![](linux/zh/contacts.png) |
| 群组 | ![](linux/en/groups.png) | ![](linux/zh/groups.png) |
| 群会话 | ![](linux/en/group_conversation.png) | ![](linux/zh/group_conversation.png) |
| 手册 | ![](linux/en/reference.png) | ![](linux/zh/reference.png) |
| 翻译器 | ![](linux/en/translator.png) | ![](linux/zh/translator.png) |
| 收听 | ![](linux/en/listen.png) | ![](linux/zh/listen.png) |
| 我 | ![](linux/en/me.png) | ![](linux/zh/me.png) |

## Windows（CI：windows-2022）

| 场景 | English | 简体中文 |
|---|---|---|
| 欢迎（首次启动） | ![](windows/en/welcome.png) | ![](windows/zh/welcome.png) |
| 创建身份 | ![](windows/en/create_identity.png) | ![](windows/zh/create_identity.png) |
| 备份向导 | ![](windows/en/backup_wizard.png) | ![](windows/zh/backup_wizard.png) |
| 学习首页 | ![](windows/en/learn_home.png) | ![](windows/zh/learn_home.png) |
| 统计 | ![](windows/en/stats.png) | ![](windows/zh/stats.png) |
| 训练设置 | ![](windows/en/training_settings.png) | ![](windows/zh/training_settings.png) |
| 听抄练习 | ![](windows/en/receive_drill.png) | ![](windows/zh/receive_drill.png) |
| 发报练习 | ![](windows/en/send_practice.png) | ![](windows/zh/send_practice.png) |
| 会话列表 | ![](windows/en/chat_list.png) | ![](windows/zh/chat_list.png) |
| 会话 | ![](windows/en/conversation.png) | ![](windows/zh/conversation.png) |
| 联系人 | ![](windows/en/contacts.png) | ![](windows/zh/contacts.png) |
| 群组 | ![](windows/en/groups.png) | ![](windows/zh/groups.png) |
| 群会话 | ![](windows/en/group_conversation.png) | ![](windows/zh/group_conversation.png) |
| 手册 | ![](windows/en/reference.png) | ![](windows/zh/reference.png) |
| 翻译器 | ![](windows/en/translator.png) | ![](windows/zh/translator.png) |
| 收听 | ![](windows/en/listen.png) | ![](windows/zh/listen.png) |
| 我 | ![](windows/en/me.png) | ![](windows/zh/me.png) |
