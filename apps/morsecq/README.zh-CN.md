[English](./README.md)

# MorseCQ 应用

无需账号的离线 Flutter 应用，启动后直接进入学习。它把 morse_core、morse_dsp、morse_io、morse_trainer、radio_tools 和 morse_session 组装成学习 / 参考 / 我的三个导航目标，偏好与学习数据都保存在本机，不需要任何聊天、账号或传输包。

在 workspace 根目录运行 `dart pub get --enforce-lockfile`、`flutter analyze apps/morsecq` 和 `(cd apps/morsecq && flutter test --no-pub)`。用 `(cd apps/morsecq && flutter run -d macos)` 或其他受支持设备启动。原生测试位于 `integration_test/`，通过 `bash tool/test_pyramid.sh --level e2e --device <id>` 或 `tool/ci/run_integration_tests.sh -d <id>` 运行。

| 路径 | 负责 |
| --- | --- |
| `lib/main.dart`、`lib/di/` | 启动、`settings.json`、`AppScope` 服务与本机偏好 |
| `lib/i18n/`、`lib/l10n/` | 语言选择与解析；ARB 资源及生成的本地化代码（[本地化](lib/l10n/README.zh-CN.md)） |
| `lib/training/` | `TrainingController`（`morse_session` 的 `TrainingCore` 加 `ChangeNotifier`）、`TrainingControllerHost`、`dart:io` 文档存储及备份存储层 |
| `lib/keying/`、`lib/lifecycle/` | 实体键配置；原生后台任务桥接 |
| `lib/ui/` | 学习 / 参考 / 我的外壳，以及学习、参考、统计、录音工作台、外观和无线电工具界面 |
| `lib/desktop/` | 窗口、托盘与退出处理（[桌面外壳](lib/desktop/README.zh-CN.md)） |

另见根目录 [README](../../README.zh-CN.md)、[本地学习架构](../../doc/architecture/OFFLINE_LEARNING.zh-CN.md)、[测试金字塔](../../doc/testing/TEST_PYRAMID.zh-CN.md)和[构建指南](../../doc/operations/BUILD_AND_DEPLOY.zh-CN.md)。
