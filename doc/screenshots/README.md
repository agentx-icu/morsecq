[简体中文](./README.zh-CN.md)

# Screenshots

Captured by `tool/screenshots/capture.sh` (see
[tool/screenshots/README.md](../../tool/screenshots/README.md)) from the real
app with seeded demo data, Modern Calm style, light theme, English and
Simplified Chinese. Frames
are published only when a whole platform run succeeds, so what is committed
here is always a complete, consistent set. Regenerate after a UI change; do
not edit the PNGs by hand.

| platform | status | size |
|---|---|---|
| macOS | captured 2026-10-08 (pedagogy flow) | 1280×800 @1x |
| iOS (iPhone) | captured 2026-10-08 (pedagogy flow, App Store 6.9") | 440×956 @3x (1320×2868 px, RGB) |
| iPad | captured 2026-10-08 (pedagogy flow) | 1032×1376 @2x (2064×2752 px, RGB) |
| Android | captured 2026-10-08 (pedagogy flow) | ≈412×915 @2x (823×1829 px) |
| Linux | captured 2026-10-01 (CI, ubuntu-24.04 + Xvfb) | 1280×800 @1x |
| Windows | captured 2026-10-01 (CI, windows-2022) | 1280×800 @1x |

Linux and Windows frames come from the successful [E2E run 36839181762](https://github.com/agentx-icu/morsecq/actions/runs/36839181762)
at UI revision `0a83b325f8d9533340b851cf40672d129d4991fd`, imported through
`capture.sh --from` with the same publish checks. Local targets are regenerated
for the pedagogy worktree; their capture dates are listed above.

## macOS

| scene | English | 简体中文 |
|---|---|---|
| Welcome (first run) | ![](macos/en/welcome.png) | ![](macos/zh/welcome.png) |
| Create identity | ![](macos/en/create_identity.png) | ![](macos/zh/create_identity.png) |
| Backup wizard | ![](macos/en/backup_wizard.png) | ![](macos/zh/backup_wizard.png) |
| Learn home | ![](macos/en/learn_home.png) | ![](macos/zh/learn_home.png) |
| Statistics | ![](macos/en/stats.png) | ![](macos/zh/stats.png) |
| Training settings | ![](macos/en/training_settings.png) | ![](macos/zh/training_settings.png) |
| Receive drill | ![](macos/en/receive_drill.png) | ![](macos/zh/receive_drill.png) |
| Send practice | ![](macos/en/send_practice.png) | ![](macos/zh/send_practice.png) |
| First lesson | ![](macos/en/first_lesson.png) | ![](macos/zh/first_lesson.png) |
| Receive summary | ![](macos/en/receive_summary.png) | ![](macos/zh/receive_summary.png) |
| Guided sending | ![](macos/en/guided_send.png) | ![](macos/zh/guided_send.png) |
| Chat list | ![](macos/en/chat_list.png) | ![](macos/zh/chat_list.png) |
| Conversation | ![](macos/en/conversation.png) | ![](macos/zh/conversation.png) |
| Contacts | ![](macos/en/contacts.png) | ![](macos/zh/contacts.png) |
| Groups | ![](macos/en/groups.png) | ![](macos/zh/groups.png) |
| Group conversation | ![](macos/en/group_conversation.png) | ![](macos/zh/group_conversation.png) |
| Reference | ![](macos/en/reference.png) | ![](macos/zh/reference.png) |
| Translator | ![](macos/en/translator.png) | ![](macos/zh/translator.png) |
| Listen | ![](macos/en/listen.png) | ![](macos/zh/listen.png) |
| Me | ![](macos/en/me.png) | ![](macos/zh/me.png) |

## iOS (iPhone 17 Pro Max simulator)

The offline App Store build (`MORSECQ_SHOT_VARIANT=offline`): no chat scenes.

| scene | English | 简体中文 |
|---|---|---|
| Learn home | ![](ios/en/learn_home.png) | ![](ios/zh/learn_home.png) |
| Statistics | ![](ios/en/stats.png) | ![](ios/zh/stats.png) |
| Training settings | ![](ios/en/training_settings.png) | ![](ios/zh/training_settings.png) |
| Receive drill | ![](ios/en/receive_drill.png) | ![](ios/zh/receive_drill.png) |
| Send practice | ![](ios/en/send_practice.png) | ![](ios/zh/send_practice.png) |
| First lesson | ![](ios/en/first_lesson.png) | ![](ios/zh/first_lesson.png) |
| Receive summary | ![](ios/en/receive_summary.png) | ![](ios/zh/receive_summary.png) |
| Guided sending | ![](ios/en/guided_send.png) | ![](ios/zh/guided_send.png) |
| Reference | ![](ios/en/reference.png) | ![](ios/zh/reference.png) |
| Translator | ![](ios/en/translator.png) | ![](ios/zh/translator.png) |
| Listen | ![](ios/en/listen.png) | ![](ios/zh/listen.png) |
| Me | ![](ios/en/me.png) | ![](ios/zh/me.png) |

## iPad (iPad Pro 13-inch simulator)

The offline App Store build (`MORSECQ_SHOT_VARIANT=offline`): no chat scenes.

| scene | English | 简体中文 |
|---|---|---|
| Learn home | ![](ipad/en/learn_home.png) | ![](ipad/zh/learn_home.png) |
| Statistics | ![](ipad/en/stats.png) | ![](ipad/zh/stats.png) |
| Training settings | ![](ipad/en/training_settings.png) | ![](ipad/zh/training_settings.png) |
| Receive drill | ![](ipad/en/receive_drill.png) | ![](ipad/zh/receive_drill.png) |
| Send practice | ![](ipad/en/send_practice.png) | ![](ipad/zh/send_practice.png) |
| First lesson | ![](ipad/en/first_lesson.png) | ![](ipad/zh/first_lesson.png) |
| Receive summary | ![](ipad/en/receive_summary.png) | ![](ipad/zh/receive_summary.png) |
| Guided sending | ![](ipad/en/guided_send.png) | ![](ipad/zh/guided_send.png) |
| Reference | ![](ipad/en/reference.png) | ![](ipad/zh/reference.png) |
| Translator | ![](ipad/en/translator.png) | ![](ipad/zh/translator.png) |
| Listen | ![](ipad/en/listen.png) | ![](ipad/zh/listen.png) |
| Me | ![](ipad/en/me.png) | ![](ipad/zh/me.png) |

## Android (emulator, API 36)

| scene | English | 简体中文 |
|---|---|---|
| Welcome (first run) | ![](android/en/welcome.png) | ![](android/zh/welcome.png) |
| Create identity | ![](android/en/create_identity.png) | ![](android/zh/create_identity.png) |
| Backup wizard | ![](android/en/backup_wizard.png) | ![](android/zh/backup_wizard.png) |
| Learn home | ![](android/en/learn_home.png) | ![](android/zh/learn_home.png) |
| Statistics | ![](android/en/stats.png) | ![](android/zh/stats.png) |
| Training settings | ![](android/en/training_settings.png) | ![](android/zh/training_settings.png) |
| Receive drill | ![](android/en/receive_drill.png) | ![](android/zh/receive_drill.png) |
| Send practice | ![](android/en/send_practice.png) | ![](android/zh/send_practice.png) |
| First lesson | ![](android/en/first_lesson.png) | ![](android/zh/first_lesson.png) |
| Receive summary | ![](android/en/receive_summary.png) | ![](android/zh/receive_summary.png) |
| Guided sending | ![](android/en/guided_send.png) | ![](android/zh/guided_send.png) |
| Chat list | ![](android/en/chat_list.png) | ![](android/zh/chat_list.png) |
| Conversation | ![](android/en/conversation.png) | ![](android/zh/conversation.png) |
| Contacts | ![](android/en/contacts.png) | ![](android/zh/contacts.png) |
| Groups | ![](android/en/groups.png) | ![](android/zh/groups.png) |
| Group conversation | ![](android/en/group_conversation.png) | ![](android/zh/group_conversation.png) |
| Reference | ![](android/en/reference.png) | ![](android/zh/reference.png) |
| Translator | ![](android/en/translator.png) | ![](android/zh/translator.png) |
| Listen | ![](android/en/listen.png) | ![](android/zh/listen.png) |
| Me | ![](android/en/me.png) | ![](android/zh/me.png) |

## Linux (CI: ubuntu-24.04, Xvfb)

| scene | English | 简体中文 |
|---|---|---|
| Welcome (first run) | ![](linux/en/welcome.png) | ![](linux/zh/welcome.png) |
| Create identity | ![](linux/en/create_identity.png) | ![](linux/zh/create_identity.png) |
| Backup wizard | ![](linux/en/backup_wizard.png) | ![](linux/zh/backup_wizard.png) |
| Learn home | ![](linux/en/learn_home.png) | ![](linux/zh/learn_home.png) |
| Statistics | ![](linux/en/stats.png) | ![](linux/zh/stats.png) |
| Training settings | ![](linux/en/training_settings.png) | ![](linux/zh/training_settings.png) |
| Receive drill | ![](linux/en/receive_drill.png) | ![](linux/zh/receive_drill.png) |
| Send practice | ![](linux/en/send_practice.png) | ![](linux/zh/send_practice.png) |
| Chat list | ![](linux/en/chat_list.png) | ![](linux/zh/chat_list.png) |
| Conversation | ![](linux/en/conversation.png) | ![](linux/zh/conversation.png) |
| Contacts | ![](linux/en/contacts.png) | ![](linux/zh/contacts.png) |
| Groups | ![](linux/en/groups.png) | ![](linux/zh/groups.png) |
| Group conversation | ![](linux/en/group_conversation.png) | ![](linux/zh/group_conversation.png) |
| Reference | ![](linux/en/reference.png) | ![](linux/zh/reference.png) |
| Translator | ![](linux/en/translator.png) | ![](linux/zh/translator.png) |
| Listen | ![](linux/en/listen.png) | ![](linux/zh/listen.png) |
| Me | ![](linux/en/me.png) | ![](linux/zh/me.png) |

## Windows (CI: windows-2022)

| scene | English | 简体中文 |
|---|---|---|
| Welcome (first run) | ![](windows/en/welcome.png) | ![](windows/zh/welcome.png) |
| Create identity | ![](windows/en/create_identity.png) | ![](windows/zh/create_identity.png) |
| Backup wizard | ![](windows/en/backup_wizard.png) | ![](windows/zh/backup_wizard.png) |
| Learn home | ![](windows/en/learn_home.png) | ![](windows/zh/learn_home.png) |
| Statistics | ![](windows/en/stats.png) | ![](windows/zh/stats.png) |
| Training settings | ![](windows/en/training_settings.png) | ![](windows/zh/training_settings.png) |
| Receive drill | ![](windows/en/receive_drill.png) | ![](windows/zh/receive_drill.png) |
| Send practice | ![](windows/en/send_practice.png) | ![](windows/zh/send_practice.png) |
| Chat list | ![](windows/en/chat_list.png) | ![](windows/zh/chat_list.png) |
| Conversation | ![](windows/en/conversation.png) | ![](windows/zh/conversation.png) |
| Contacts | ![](windows/en/contacts.png) | ![](windows/zh/contacts.png) |
| Groups | ![](windows/en/groups.png) | ![](windows/zh/groups.png) |
| Group conversation | ![](windows/en/group_conversation.png) | ![](windows/zh/group_conversation.png) |
| Reference | ![](windows/en/reference.png) | ![](windows/zh/reference.png) |
| Translator | ![](windows/en/translator.png) | ![](windows/zh/translator.png) |
| Listen | ![](windows/en/listen.png) | ![](windows/zh/listen.png) |
| Me | ![](windows/en/me.png) | ![](windows/zh/me.png) |
