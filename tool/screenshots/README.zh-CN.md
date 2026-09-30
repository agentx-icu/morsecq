[English](./README.md)

# 产品截图（跨平台）

一条命令在真实设备 / 桌面窗口里启动真实的应用，灌入演示数据，按中英文两种语言走完
所有产品场景，并把帧发布到仓库里的 `doc/screenshots/<platform>/<locale>/`。

```bash
tool/screenshots/capture.sh                          # 默认 macOS，en + zh
tool/screenshots/capture.sh --platforms macos,ios,ipad,android
tool/screenshots/capture.sh --platforms android --device emulator-5554
tool/screenshots/capture.sh --locales zh --keep      # 只截一种语言，保留暂存目录
```

平台：`macos`、`linux`、`windows`（本机桌面）、`ios`（iPhone 模拟器）、`ipad`
（iPad 模拟器）、`android`（模拟器或真机）。设备按平台从 `flutter devices` 里自动
选择，也可用 `--device` 指定；移动端模拟器需事先启动。

## 工作原理

整条流水线就是一个普通的 `integration_test`：

| 部件 | 文件 |
|---|---|
| 编排（选设备、`flutter drive`、校验、发布） | `tool/screenshots/capture.sh` |
| 场景 × 语言的真实 UI 走查 | `apps/morsecq/integration_test/screenshots_test.dart` |
| 演示数据（主角、好友、QSO、通联网、好友请求、一周训练） | `apps/morsecq/integration_test/support/seed_data.dart` |
| 导航与场景清单 `kScenes` | `apps/morsecq/integration_test/support/scene_walk.dart` |
| Flutter 层截帧、窗口尺寸、主题钉死 | `apps/morsecq/integration_test/support/shot_harness.dart` |
| 宿主侧：写出 PNG | `apps/morsecq/test_driver/integration_test.dart` |

- **后端**：`--dart-define=MORSECQ_FAKE_BACKEND=true`。不起 Tox 节点、不落盘；
  用 `package:morsecq_chat_api/testing.dart` 的测试钩子（`addFakeFriend`、
  `receiveMessage`、`addFakeGroupMember` 等）在进程内灌数据，并用 `FileTrainerStore`
  写一份 `progress.json`，让学习首页和统计页有内容。
- **截帧**：应用包在一个 `RepaintBoundary` 里，每个场景从 Flutter 层 `toImage`。
  五个平台做法完全一样，不需要系统权限，也不会截到别的窗口（Flutter 3.41.9 的
  `integration_test` 只在 Android / iOS 有原生 `takeScreenshot`）。PNG 以 base64
  装进 `binding.reportData`，由 `flutter drive` 宿主写成
  `<platform>/<locale>/<scene>.png`。
- **桌面窗口**：harness 通过 `window_manager` 把真实窗口调整到
  `MORSECQ_SHOT_WINDOW`（默认 `1280x800`）并居中，然后回读实际尺寸——macOS 会把
  窗口钳制到可见区域（14 寸 MacBook Pro 得到 1280×768），按实际尺寸截。
- **像素比**：桌面 1.0，移动端 `min(dpr, 2)`，可用 `MORSECQ_SHOT_PIXEL_RATIO` 覆盖。
- **主题**：钉死为浅色（`MORSECQ_SHOT_THEME=light|dark|system`），不跟随宿主外观。
- **语言**：每种语言单独一遍，用各自的一份演示文案（中文帧里是中文名字和中文群名；
  电码正文保持 CW 缩写，那才是空中实际拍发的内容）。
- **发布门禁**：只有当该平台的 `flutter drive` 退出码为 0、每种语言的每个场景都存在、
  不小于 8 KiB、且没有两帧字节相同时，才复制进 `doc/screenshots/`；失败的平台不动
  仓库里的帧，并打印暂存目录。

`flutter test integration_test/screenshots_test.dart -d <device>` 会把同一套走查当作
普通 UI 测试跑（每个场景都必须渲染成功，无溢出、无缺失控件），帧被丢弃；
`tool/test_pyramid.sh --level e2e` 就是这么用它的。

## 场景

`welcome`、`create_identity`、`backup_wizard`（首次启动），然后基于已有身份：
`learn_home`、`stats`、`training_settings`、`receive_drill`、`send_practice`、
`chat_list`、`conversation`、`contacts`、`groups`、`group_conversation`、
`reference`、`translator`、`listen`、`me`。

新增场景：在 `scene_walk.dart` 里导航并 `shots.capture(tester, locale, 'name')`，把名字
加进那里的 `kScenes` 和 `capture.sh` 的 `SCENES`，再在 `doc/screenshots/README.md`
加一行。

## 坑（都是搭建时踩过的）

- 两次 `pumpWidget` 的根控件类型相同时，框架会**原地更新**旧元素而不是替换，
  `AppScope` 会继续用第一个后端。走查里每个应用根都带不同的 `key`。
- `pumpAndSettle` 遇到无限动画（光标闪烁、转圈）会抛异常；harness 的 `settle()` 会
  接住并继续。
- SnackBar 会盖住输入区的发送按钮 4 秒；合成点击落在提示条上，而 `flutter test` 只
  打印一条警告。要么 `ScaffoldMessenger.clearSnackBars()`，要么断言结果，绝不能只
  断言输入过的文本。
- 从 ssh 会话启动 macOS 窗口照样能渲染和截帧（Flutter 层不依赖合成器），但运行中
  不要抢焦点。
