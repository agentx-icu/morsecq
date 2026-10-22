[English](./README.md)

# morse_session

MorseCQ 的学习会话层，**纯 Dart**（不依赖 Flutter，也不用 `dart:io`）：训练控制器核心、
收发练习会话、计分练习的唯一提交路径、结论判定、练习目录、训练设置、存储接口、文档编解码
与原子文档写入器。它位于 `morse_trainer`（教学模型）与宿主之间：Flutter 应用和小程序桥接
驱动的是同一个控制器。

本包只属于 MorseCQ，**不**与 DitMesh 共享（`tool/shared_packages.lock.json` 只锁定另外
五个包）。

## 内容

| 领域 | 类型 |
| --- | --- |
| 控制器核心 | `TrainingCore`：加载进度与设置，提供 Koch 进度、SRS 待复习列表和连续天数，串行化写入，保存失败时把结果留在内存供 `retryProgressSave` 重试，`flush`、`close`。`notifyListeners()` 为抽象方法；`dispose()` 执行幂等的 `retireCore()`。 |
| 会话入口 | `TrainingCore` 上的扩展：`ReceiveSessionStart`（课程挑战、引导级别、首课、练习类型、复习、专项）、`SendPracticeStart`、`TrainingPlan`、`QsoPractice`、`MistakePractice`、`MaterialPractice`、`TelegraphSessions`、`AdvancedLearning`。 |
| 会话 | `ReceiveSession` / `ReceiveRound`、`SendSession`（实现 `SendKeyTarget`）、`recordReceiveSession`、`applyExercise`（记分、去重、解锁）、`ReceiveVerdict` / `verdictOf`、`DrillCatalog`。 |
| 设置与文档 | `TrainingSettings`、`TrainingSettingsStore` + `TrainingSettingsCodec`、`TrainingDocStore`、`TrainerProgressCodec`、`MaterialStore`、`AudioMaterialStore`、`SendDetailStore`。 |
| 存储算法 | 基于宿主提供的 `DocumentFs` 的 `AtomicDocument`：先写临时文件，校验旧文档后轮转为 `.bak`（损坏的旧文档移到一旁），再重命名就位；读取时失败回退到备份。 |

## 宿主

- 应用（`apps/morsecq/lib/training/`）声明
  `TrainingController extends TrainingCore with ChangeNotifier`，用 `dart:io` 实现
  `DocumentFs`（`AtomicJsonFile`），并保留文件存储、备份层和在各页面间共享控制器的宿主。
- 小程序桥接（规划中）用 JavaScript 回调子类化 `TrainingCore`，并基于小程序文件系统实现
  `DocumentFs`。

导入门禁（`tool/import_guard.dart` 的 `pure-dart-session` 规则）禁止这里引入 Flutter、
`dart:io`、`package:path` 和 `morse_io` 总入口，以保证本包始终能用 dart2js 编译。

## 测试

在本目录运行 `dart test`（CI 对每个包运行 `flutter test`）。测试使用
`test/helpers/test_core.dart` 里的 `TestTrainingCore`、内存存储、固定时钟和带种子的
`Random`。
