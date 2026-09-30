[English](./HANDOVER-2026-09-30-screenshots-test-pyramid.md)

# 交接：截图流水线 + 测试金字塔（分支 `feat/screenshots-test-pyramid`）

> 给接手 2026-09-30 会话的 AI / 工程师。两个语言版本不一致时以本中文版为准。项目
> 通用的坑见 [HANDOVER.zh-CN.md](HANDOVER.zh-CN.md)；本文只讲这个分支。

## 1. 现状

| 项 | 值 |
|---|---|
| worktree（Mac） | `/Users/bin.gao/chat-uikit/morsecq-shots`，与 VM 的 `~/bin_gao_home/chat-uikit/morsecq-shots` 是同一份存储 |
| 主 checkout | `/Users/bin.gao/chat-uikit/morsecq` 在 `master`（已快进到 `origin/master` = `8eac300`） |
| 分支 | `feat/screenshots-test-pyramid`，已 rebase 到 `8eac300`，**尚未推送** |
| 分支提交（从旧到新） | `fix: desktop debug launch, add-friend sheet semantics, trend-chart labels` · `test: real-UI integration tests, screenshot pipeline, test pyramid runner, macOS screenshots` · `fix(contacts): scan action below the Tox ID field…` · `test: iOS, iPad and Android screenshots; UI-only Android e2e builds` · `fix: codex review round 1 — sheet scrolling, label thinning, capture script gates, docs` |
| 本会话用户指令 | 实现用单 agent；**codex 评审按要求用多 agent 并行**；评审发现先修完再整体跑一遍金字塔；只有明确要求才推送 |

所有构建/测试都在 Mac 上经 `ssh mac2` 跑（VM 没有 Flutter）。每条远程命令前加
`export PATH=/opt/homebrew/opt/openjdk@17/bin:/opt/homebrew/bin:$HOME/flutter/bin:$HOME/Library/Android/sdk/platform-tools:$PATH; export JAVA_HOME=/opt/homebrew/opt/openjdk@17`
（Android 的 Gradle 需要 arm64 JDK；非交互 shell 不会加载设置它的 profile）。

## 2. 已交付（除特别说明外均在 Mac 上验证过）

- `apps/morsecq/integration_test/`：`app_launch_test.dart`（真实 `main()`，引导 → 五个
  页签 → 练习 → 加好友并发送 → 翻译器 → 我）与 `screenshots_test.dart`（灌好数据的假实现上
  17 场景 × 中英文，Flutter 层截帧）；`support/{shot_harness,seed_data,scene_walk}.dart`；
  `test_driver/integration_test.dart` 写出 PNG。
- `tool/screenshots/capture.sh`（按平台编排、校验、发布）、`tool/test_pyramid.sh`（门禁 →
  单元 → 控件 → 端到端）、`.github/workflows/e2e.yml`（按需触发的 macOS runner；分支未推送，
  从未跑过）。
- 已提交的帧：`doc/screenshots/{macos,ios,ipad,android}/{en,zh}/`（各 34 张；macOS 1280×768
  @1x，移动端 @2x），逐张看过。
- 文档（双语）：`doc/testing/TEST_PYRAMID.md`、`doc/screenshots/README.md`、
  `tool/screenshots/README.md`；CLAUDE.md 命令与目录行；文档索引；根 README 状态；方案
  变更记录 `v0.3.9`。
- 顶层测试发现并在根因处修掉的产品 bug：桌面 debug 启动崩溃（`AppScope` provider 类型）、
  添加好友面板语义断言（后缀槽里的 Tooltip，macOS 与 iOS）、正确率趋势图刻度/标题、
  `FakeChatService.addFakeGroupMember` 钩子。
- 最近一次完整运行（评审第一轮修复之前）：`tool/test_pyramid.sh --level all` 在 macOS 上
  ALL PASSED。第一轮修复后只重跑了 `flutter analyze apps/morsecq`、
  `test/chat/add_friend_test.dart`、`test/stats`（全绿）。启动测试在 macOS、iOS 模拟器
  （`42498CC3-…`，iPhone 16 Plus）、Android `emulator-5554` 上通过。

## 3. Codex 评审状态（三路并行 `codex-mac`，`gpt-6-sol` xhigh）

| 评审 | 范围 | 结论 | 状态 |
|---|---|---|---|
| A | 产品修复 | NEEDS-CHANGES（4 条） | **已全部修完**（第一轮提交） |
| C | 脚本 / CI / 文档 | NEEDS-CHANGES（12 条） | **已全部修完**（第一轮提交） |
| B | 集成测试 harness | NEEDS-CHANGES（8 条） | **未修——先做这个** |

### 3.1 评审 B 的发现与预定修法

1. **高 — `shot_harness.dart` `settle()`** 把所有 `FlutterError` 都吞掉，真错误被藏起来，
   超时后照样继续。修法：只捕获 pumpAndSettle 的超时（消息以 `pumpAndSettle timed out`
   开头的 `FlutterError`），其它一律重抛；每个场景在 `capture()` 前必须断言就绪条件（见 2）。
2. **高 — `scene_walk.dart` walkShell**：会话、群会话、翻译器、收听四个场景截帧前没有目标
   页面/内容断言，`screenshots_test.dart` 只数截帧次数。修法：每次截帧前
   `expect(find.byType(<Screen>), findsOneWidget)` 再加内容检查（如 `MessageBubble` 里的
   灌入文本、翻译器输出图样、`ListenScreen`），只点击可命中的目标（不要用
   `warnIfMissed: false` 糊过去，要断言）。
3. **中 — 听抄练习音频**：练习页真实启动 SoLoud 音频，走查弹出它时销毁未等待，随即打开发报
   练习。修法：截图运行时灌入"关声音、开闪屏"的训练设置（用 `FileTrainingSettingsStore`
   在灌入进度旁写 `settings.json`），或在打开下一个练习前等待销毁完成。
4. **中 — `app_launch_test.dart`** `find.textContaining('ABAB')` 在面板还在时可能命中输入的
   ID。修法：先断言 `find.byType(AddFriendForm)` 已消失，再按好友条目的稳定 key 点击
   （查 `contacts_page.dart` / 好友列表有没有 `ValueKey`，没有就加一个）。
5. **中 — `shot_harness.dart`** 强制像素比接受 `Infinity` / 巨大值；错误的 define 静默
   退回默认。修法：校验（`isFinite`、0.25–4 范围、窗口 ≤ 8192 px、主题在允许集合内），
   否则 `throw ArgumentError`。
6. **中 — 窗口尺寸**：Linux/Windows 上尺寸不符只打日志。修法：除 macOS（文档已说明会被
   钳制）外不符即失败，或按容差比较、Linux/Windows 上失败。
7. **低 — `app_launch_test.dart`**：假身份默认数据目录是固定的
   `systemTemp/morsecq_fake/<pk>`，别的运行留下的训练数据会串进来。修法：隔离——例如在
   `setUp` 删掉该目录，或给假后端工厂加一个 `--dart-define` 指定数据目录。
8. **低 — `seed_data.dart`**：消息时间是今天 09:12，凌晨跑时是未来时间；"一小时前"的进度
   可能跨到昨天。修法：一个受控时钟（如 `now - 3h` 且不早于今天零点），所有时间戳从它派生。

修完后：`flutter analyze apps/morsecq` → `tool/test_pyramid.sh --level all`（macOS）→
iOS（`-d 42498CC3-9565-4BC8-A6DE-817F480B7887`）与 Android（`-d emulator-5554`，带
`ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true`）上的启动测试 →
`tool/screenshots/capture.sh --platforms macos,ios,ipad,android` 刷新有变化的帧（灌入设置
会改变练习页的帧）→ 逐张检查 PNG → 提交 → 简短的 `codex-mac` 复核，只确认修复项
（全局策略 §2.5）。

## 4. 剩余工作（按顺序）

1. 修评审 B（上文），重跑金字塔，提交，复核。
2. Linux 与 Windows 的截图 + 启动测试：这里没有这两种机器。可选方案：给 `e2e.yml` 加
   `ubuntu-latest`（`xvfb-run` 包住 `flutter test integration_test -d linux`，apt 装
   `libgtk-3-dev ninja-build libasound2-dev`）和 `windows-latest` 两个 job，推送分支，
   `workflow_dispatch` 触发，下载 artifact，把帧提交进来，并更新
   `doc/screenshots/README.md` 的状态表（两种语言）。
3. 推送分支并向 `master` 提 MR（Conventional Commits，**不加任何 AI attribution**，
   见全局策略）。目前什么都没推送。
4. 一条没能执行的全局策略请求：用户要求 codex 评审改用 `gpt-6.1-sol` xhigh。2026-09-30
   两次真实调用（`codex exec -m gpt-6.1-sol …`）服务端都回
   `The 'gpt-6.1-sol' model is not supported when using Codex with a ChatGPT account`。
   wrapper `~/.local/bin/codex-mac` 仍默认 `gpt-6-sol`；已告知用户，由用户决定（等开放，
   或换 Mac 上的账号/登录方式）。不要盲目切换。
5. 合并后删除本交接文档，持久性的内容并入 `HANDOVER.zh-CN.md`。

## 5. 本分支特有的坑

- 两次 `pumpWidget` 的根类型相同会被原地更新而非替换：走查里每个 `MorsecqApp` 都要有
  不同的 `key`。
- SnackBar 会盖住输入区的发送按钮 4 秒；`flutter test` 对没点中的 tap 只打警告。要清掉它
  或断言结果。
- iOS 上的 `flutter drive`/`flutter test` 会重新生成 `apps/morsecq/ios/Podfile.lock`；
  worktree 里必须从主 checkout 复制 `ios/Frameworks/tim2tox_ffi.xcframework` 与
  `macos/Frameworks/libtim2tox_ffi.dylib`（都被 gitignore），否则 lock 会丢掉
  `Tim2ToxFFI` pod。
- Android 需要 `ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true`（两个脚本都已导出）和
  `JAVA_HOME` 指向 arm64 JDK。
- Mac 的 sshd 在长构建后可能拒绝连接约 60 秒；等待即可，不要重启隧道。
