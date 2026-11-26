[English](./README.md)

# MorseCQ 应用

本离线 Flutter 应用使用 `morse_core`、`morse_dsp`、`morse_io`、`morse_trainer`、`radio_tools` 和 `morse_session`，提供学习、参考和我三个入口。偏好与学习数据保存在本机。首次启动 Android 正式版时，需同意隐私政策和使用条款后进入学习。各平台均可在 **我 → 隐私与权限** 离线查看政策、权限说明和帮助。

## 运行与测试

使用 Flutter 3.41.9 和 Dart 3.11.5，在工作区根目录执行以下命令。

```sh
dart pub get --enforce-lockfile
(cd apps/morsecq && flutter run -d macos)
```

可用 `flutter devices` 列出的设备 ID 替换 `macos`。从工作区根目录运行应用静态分析和隔离的组件测试。

```sh
flutter analyze apps/morsecq
bash tool/test_pyramid.sh --level widget
```

用 `bash tool/test_pyramid.sh --level e2e` 在本机桌面运行全部原生集成测试，或加上 `--device <id>` 指定设备。只在 macOS 验证隐私与离线支持流程时，运行 `(cd apps/morsecq && flutter test integration_test/privacy_walk_test.dart -d macos)`。覆盖范围与设备检查见[测试金字塔](../../doc/testing/TEST_PYRAMID.zh-CN.md)。

## 键盘快捷键

选中“参考”时，macOS/iOS 的 Command+K 或 Windows/Linux/Android 的 Ctrl+K 可聚焦搜索框。命令作用于当前路由，已有焦点的编辑器和输入法组合输入仍由文本系统处理，忽略长按产生的重复事件。侧音 intent 尚未绑定到应用外壳。原生菜单和 iPad 实体键盘验证仍待完成。

## 应用结构

| 路径 | 负责 |
| --- | --- |
| `lib/main.dart`、`lib/di/` | 启动、`AppScope` 服务、`settings.json` 本机偏好及 Android 正式版 `privacy.json` 同意记录 |
| `lib/i18n/`、`lib/l10n/` | 语言选择与解析；ARB 资源及生成的本地化代码（[本地化](lib/l10n/README.zh-CN.md)） |
| `lib/training/` | `TrainingController`（`morse_session` 的 `TrainingCore` 加 `ChangeNotifier`）、`TrainingControllerHost`、`dart:io` 文档存储及备份存储层 |
| `lib/keying/`、`lib/lifecycle/` | 实体键配置；原生后台任务桥接 |
| `lib/ui/` | 「学习／参考／我」应用外壳，以及练习、统计、录音工作台、外观和无线电工具界面 |
| `lib/ui/legal/`、`lib/diagnostics/` | 应用内隐私、权限和支持页面，以及本地诊断记录与复制 |
| `lib/desktop/` | 窗口、托盘与退出处理（[桌面外壳](lib/desktop/README.zh-CN.md)） |

另见[本地学习架构](../../doc/architecture/OFFLINE_LEARNING.zh-CN.md)、[构建指南](../../doc/operations/BUILD_AND_DEPLOY.zh-CN.md)和[文档索引](../../doc/README.zh-CN.md)。
