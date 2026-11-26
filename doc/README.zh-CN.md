[English](./README.md)

# 当前文档

首次练习或从源码运行见[项目 README](../README.zh-CN.md)。参与维护时请读[维护指南](HANDOVER.zh-CN.md)。以下指南均有英文版链接。

## 使用 MorseCQ

- 从[截图库](screenshots/README.zh-CN.md)查看手机、平板和桌面端的界面。
- 麦克风、本地数据和问题反馈见[支持页面](../site/zh-CN/support.md)和[隐私政策](../site/zh-CN/privacy.md)。

## 产品与架构

- [本地学习架构](architecture/OFFLINE_LEARNING.zh-CN.md)：存储、生命周期、学习证据及备份存储层
- [进阶学习](architecture/ADVANCED_LEARNING.zh-CN.md)：跨次错题本、听懂训练、目标路线和模拟通联
- [产品概念设计](designs/product-2026-10-08/README.zh-CN.md)和[历史风格方案](designs/ui-styles-2026-10-01/README.zh-CN.md)
- [应用结构](../apps/morsecq/README.zh-CN.md)、[桌面外壳](../apps/morsecq/lib/desktop/README.zh-CN.md)和[本地化](../apps/morsecq/lib/l10n/README.zh-CN.md)
- 共享包：[morse_core](../packages/morse_core/README.zh-CN.md)、[morse_trainer](../packages/morse_trainer/README.zh-CN.md)、[morse_dsp](../packages/morse_dsp/README.zh-CN.md)、[morse_io](../packages/morse_io/README.zh-CN.md) 和 [radio_tools](../packages/radio_tools/README.zh-CN.md)
- 会话层：[morse_session](../packages/morse_session/README.zh-CN.md)（纯 Dart，仅 MorseCQ 使用）

## 测试与验证

- [测试金字塔](testing/TEST_PYRAMID.zh-CN.md)，含布局 CI 与共享包同步
- [持久化审计](testing/PERSISTENCE_AUDIT.zh-CN.md)
- [学习与训练审计](testing/LEARNING_TRAINING_AUDIT.zh-CN.md)
- [跨平台审计](testing/CROSS_PLATFORM_AUDIT.zh-CN.md)记录 2026-10-22 的修复、验证证据和设备验证缺口。
- [首次学习界面验证](testing/FIRST_SUCCESS_VALIDATION.zh-CN.md)和[新手试用方案](testing/BEGINNER_TRIAL.zh-CN.md)
- [验证记录](VALIDATION.zh-CN.md)

## 构建、发布与素材

- [构建与发布](operations/BUILD_AND_DEPLOY.zh-CN.md)
- [App Store 与 Google Play 构建](release/APP_STORE.zh-CN.md)
- [第三方分发与元数据](release/DISTRIBUTION_PACKAGING.zh-CN.md) · [中国大陆](release/CHINA_DISTRIBUTION.zh-CN.md) · [Windows](release/WINDOWS_DISTRIBUTION.zh-CN.md) · [Linux](release/LINUX_DISTRIBUTION.zh-CN.md)
- [F-Droid 官方仓库准备](release/F_DROID.zh-CN.md)：商店资料、音频依赖源码构建、候选配方及延期收录条件
- [商店准备度与渠道矩阵](release/STORE_READINESS.zh-CN.md)：产物门禁、政策来源和所有者动作
- [添加界面语言](i18n/ADDING_A_LANGUAGE.zh-CN.md)
- [截图采集流程](../tool/screenshots/README.zh-CN.md)
- [网站](../site/README.zh-CN.md)：产品、隐私、条款与支持页面
