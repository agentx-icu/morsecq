[English](./HANDOVER.md)

# MorseCQ 维护指南

从 [README](../README.zh-CN.md)、[学习架构](architecture/OFFLINE_LEARNING.zh-CN.md)、[进阶学习](architecture/ADVANCED_LEARNING.zh-CN.md)、[构建指南](operations/BUILD_AND_DEPLOY.zh-CN.md)和[测试金字塔](testing/TEST_PYRAMID.zh-CN.md)开始。已执行的检查见[验证记录](VALIDATION.zh-CN.md)；[持久化审计](testing/PERSISTENCE_AUDIT.zh-CN.md)和[学习与训练审计](testing/LEARNING_TRAINING_AUDIT.zh-CN.md)列出每个学习入口保存什么以及如何测试。全部当前文档见[文档索引](README.zh-CN.md)。

保持点划与 K/M、引导识别、引导发报和独立挑战的入门路径。课程升级依赖逐字符的独立练习证据。修改持久化时，覆盖进度重载、后台保存、失败重试及确认后清除学习数据。

辅助练习、听懂成绩和模拟通联不得进入科赫解锁或逐字符掌握度。新的学习记录应写入 `TrainerProgress` 或经过校验的 `training/docs/` 文档，这样重开、清除和备份存储层才能看到它们。

五个 `packages/` 与 DitMesh 共享。修改它们需要用 `tool/shared_sync.dart` 重新固定哈希；两边副本不同时还需要分歧规则，见[共享包流程](testing/TEST_PYRAMID.zh-CN.md#共享包)。

使用手机和桌面布局检查十种语言和五种风格；Layout CI 在推送到 `main`/`master` 及以其为目标的 PR 上检查溢出、截断和安全区问题。设备检查覆盖麦克风解码、键控时序、触觉反馈、学习素材选择和本地持久化。
