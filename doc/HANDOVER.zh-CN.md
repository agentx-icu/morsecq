[English](./HANDOVER.md)

# morsecq 交接文档

> 写给接手的下一位 AI / 工程师。日期 2026-09-30，`master` 最新提交 `3e98693`，共 18 个提交，工作树干净。原稿为中文，与英文版冲突时以本文为准。

## 1. 三句话说清项目

- **morsecq** 是一款跨平台（Android / iOS / macOS / Windows / Linux）Flutter 应用：学莫斯电码（Koch 法训练）+ 用莫斯电码聊天（单聊、群聊），聊天走 **Tox P2P** 网络，无服务器、无手机号，首启创建一个 Tox 身份，训练进度也按身份保存。
- 通信栈复用姊妹项目 **toxee**（`agentx-icu/toxee`）打磨过的 **Tim2Tox**（`third_party/tim2tox` 子模块，GPL-3.0）。morsecq 只用 Tim2Tox 的 `FfiChatService`，不装腾讯 UIKit 界面；消息在线路上是纯文本，因此与 toxee 用户互通。
- 全部功能代码已写完并推送，**analyzer / 复杂度 / 分层 / ARB 门禁全绿。2026-09-30（第二个会话）：首次跑了全量测试——7 个包/应用共 750 个测试，修掉 32 个失败（9 个产品 bug，其余是过期的测试；见方案变更日志 v0.3.6）后全绿。仍未做真机构建**；macOS arm64 原生库已在真实 Mac 上构建成功，其它平台只在 CI runner 上构建过。

## 2. 先读什么

| 顺序 | 文件 | 为什么 |
|---|---|---|
| 1 | `CLAUDE.md`（仓库根） | 目录职责、常用命令、硬性约束、工作约定。**所有约束都在这里。** |
| 2 | `doc/plans/2026-09-30-morsecq-plan.md`（英文默认）/ `.zh-CN.md`（原稿） | 立项规划：产品定义、架构决策、里程碑、风险；末尾「变更记录」逐条记录了实施期的所有偏差与决定。 |
| 3 | `doc/README.md` | 全部文档索引（英文默认，每篇都有 `.zh-CN.md`）。 |
| 4 | `packages/morsecq_chat/README.md` | 最关键、最容易踩坑的一层：Tim2Tox 接入、腾讯 SDK 供应链、原生库。 |
| 5 | `doc/operations/BUILD_AND_DEPLOY.md` | 五端原生库与打包。 |
| 6 | `doc/i18n/ADDING_A_LANGUAGE.md` | 多语言方案（toxee 同款）。 |
| 7 | `apps/morsecq/lib/{notifications,desktop,l10n}/README.md`、`packages/*/README.md` | 各模块细节。 |

toxee 仓库（本地 `/home/user/toxee`，或克隆 `agentx-icu/toxee`）是参考实现，其 `CLAUDE.md`、`doc/architecture/HYBRID_ARCHITECTURE.md`、`doc/reference/GROUP_CHAT_GUIDE.md`、`doc/architecture/MOBILE_BACKGROUND.md` 解释了 Tim2Tox 的行为。**不要修改 toxee**。

## 3. 环境与命令

```bash
# 工具链：Flutter 3.41.9 stable（与 toxee CI 一致；Dart 3.11.5）。容器里装在 /home/user/flutter
export PATH=/home/user/flutter/bin:$PATH

git clone --recursive https://github.com/agentx-icu/morsecq   # 子模块 third_party/tim2tox，pin 9d4245a（与 toxee 相同）
cd morsecq
dart run tool/bootstrap_deps.dart   # 必须先于 pub get：下载腾讯 Cloud Chat SDK、打 tim2tox 补丁、生成根 pubspec_overrides.yaml（已 gitignore）
dart pub get                        # pub workspace：根目录一次解析全部包

# 门禁（CI 的 analyze.yml 跑的就是这些）
for d in packages/* apps/*; do flutter analyze "$d"; done
dart run tool/check_complexity.dart     # 任何 .dart > 500 行即失败（生成文件、l10n 例外）
dart run tool/import_guard.dart         # 分层：只有 packages/morsecq_chat 可 import tim2tox_dart / tencent_*；纯 Dart 包不得 import Flutter
dart run tool/strings_to_arb.dart --check
(cd apps/morsecq && flutter gen-l10n)   # 改 ARB 后重新生成 lib/l10n/generated/

# 测试（尚未整体跑过！）
for d in packages/* apps/morsecq; do (cd "$d" && flutter test --exclude-tags=needs-native); done

# 原生库 + 打包
bash tool/ci/build_tim2tox.sh --target linux-x86_64 --mode release   # 本容器已验证成功；ToxAV 永久关闭，sqlite 默认关闭
./build_all.sh --platform macos --mode debug                          # 其它平台需相应工具链
# 无原生库时用假后端跑 UI：--dart-define=MORSECQ_FAKE_BACKEND=true（真实后端启动失败也会自动回落）
```

提交约定：只推 `master`（仓库默认分支）；提交信息用 Conventional Commits 前缀（feat / fix / docs / build / chore）。每个变更都要走过上面的门禁。

## 4. 仓库结构（pub workspace）

```
packages/morse_core        纯 Dart  字母表、PARIS/Farnsworth 时序、编码器、流式键控解码器（对数域两簇 dit 估计）
packages/morse_trainer     纯 Dart  Koch 课程、题库、对齐评分、混淆矩阵、SRS、发报诊断、进度模型
packages/morse_dsp         纯 Dart  Goertzel 音调检测、自动调谐、包络门限、AudioMorseDecoder（麦克风解码）
packages/morse_io          Flutter  MorsePlayer、SoLoud 侧音、触觉、闪光、直键/双桨状态机、键控控件
packages/morsecq_chat_api  纯 Dart  UI 与后端之间的契约：IdentityService、ChatService、模型 + 内存假实现（testing.dart）
packages/morsecq_chat      Flutter  契约的 Tim2Tox 实现（唯一允许 import Tim2Tox/腾讯 SDK 的包）
apps/morsecq               应用     lib/di（后端工厂、AppScope、AppServices）、lib/startup、lib/ui/{account,learn,chat,contacts,groups,reference,stats,listen,shell}、
                                    lib/training（按身份的进度存储、TrainingControllerHost）、lib/notifications、lib/lifecycle、lib/desktop、lib/i18n + lib/l10n
third_party/tim2tox        子模块   不要就地修改；third_party/stubs 是腾讯 UIKit common 包的空桩
tool/                      门禁与脚本：check_complexity、import_guard、strings_to_arb、bootstrap_deps、ci/build_tim2tox.sh、gen_tray_icons
doc/                       文档（英文默认 + zh-CN）
```

代码量约 4.7 万行 Dart（不含生成文件）。测试文件：包内 33 个、应用 43 个，`needs-native` 标签的原生 smoke 在无 `libtim2tox_ffi` 时自动跳过。

## 5. 必须知道的架构事实与坑

这些都写进了规划文档变更记录，这里按「不知道就会出错」排序：

1. **`cloudCustomData` 不上线路。** Tim2Tox 的 `sendTextWithResult(..., cloudCustomData)` 只存本地，群消息接口根本没有这个参数。所以 v1 莫斯消息就是纯文本，接收端按听者自选速度播放。要传发送方键控实录需要上游 Tim2Tox 加「消息附注」（规划 §5.2 第二层，D 线）。
2. **B 变体运行模式。** 不装 `Tim2ToxSdkPlatform`、不启 FakeUIKit，但**必须调用 `setNativeLibraryName('tim2tox_ffi')`**（`NativeLibrarySetup.ensure()` 在 `MorsecqChatBackend.create` 里做），因为 `quitGroup`、`DartGetGroupMemberList`、`DartInviteUserToGroup` 仍走腾讯绑定。`TIMManager.initSDK` 绝不能调用（会装上第二条入站路径）。SDK 的进程级自定义回调钩子由 `engine/native_callbacks.dart`（`NativeCustomCallbacks`）接管：把 `friendAddResult`（没有它 `addFriend` 要等 30 s 超时才返回）和 `DartNotifyGroup*` 通知路由到当前 session；`groupChatIdStored`/`groupTypeStored` 退回拉取 `syncGroupIdentitiesFromNative()`。
3. **离线群邀请重放**由 `morsecq_chat` 自己的 `ConversationMetaStore` 维护，不用 Tim2Tox 的（它依赖 initSDK）。
4. **Tim2Tox 轮询路径分不出 `failed` 与 `sent`**，`MessageStatus.failed` 目前不会出现（上游问题）。
5. **腾讯 SDK 是隐性编译依赖。** `tim2tox_dart` 声明 `tencent_cloud_chat_sdk: any`，靠 `tool/bootstrap_deps.dart` 生成的 `pubspec_overrides.yaml` pin 到 8.9.7540+3 并打 22 个补丁；`tencent_cloud_chat_common` 用 `third_party/stubs` 空桩满足。`flutter_secure_storage` 必须 `^11`（9.x 的 `win32 ^5` 与 `share_plus` 冲突）。 自 2026-09-30 起 bootstrap 还会叠加 morsecq 的 overlay（`third_party/overlays/tencent_cloud_chat_sdk/`，`tool/vendor_overlay.dart`）：插件的平台半边换成空操作桩，不再链接或打包任何腾讯原生 SDK（`TXIMSDK_Plus_*`、`imsdk-plus` AAR、`libdart_native_imsdk.so`、`ImSDK.dll`）；vendor state 里的 `overlay_sha256` 由 `--offline-check-only` 校验。
6. **原生库**：`tool/ci/build_tim2tox.sh` 默认 `--no-toxav`（`--toxav` 直接报错）、`TIM2TOX_DISABLE_SQLITE=ON`、libsodium 1.0.20 静态链接。macOS 以裸 `libtim2tox_ffi.dylib` 放 `Contents/Frameworks`；iOS 为 xcframework 经 CocoaPods 嵌入；Android jniLibs 缺库时 Gradle 直接失败（`-PmorsecqAllowMissingFfi=true` 可放行 UI-only 构建）。已跑过的：macOS（真实 Mac 上 release 构建，应用可启动）、iOS（真实 Mac 上 XCFramework + `pod install`；未做设备构建）、Android / Windows / Linux 原生库在 CI runner 上、Linux / macOS / Windows 应用构建在 CI 上；Mac 上构建过 UI-only 的 Android debug APK（2026-09-30）；Android 与 iOS 应用尚未在设备上运行过。
7. **iOS 后台**只声明 `audio`（无 ToxAV 故不能声明 `voip`），后台约 30 秒后断连，产品上按「打开即收」预期；`AppLifecycleCoordinator` 在恢复时重连。
8. **插件版本 pin 的原因**：`flutter_soloud ^4.1.7`（5.x 需要 Flutter 3.41.9 没有的 `meta`）、`record ^6.2.1`（7.x 需 Dart 3.12）、`tray_manager ^0.5.3`（0.6+ 是无平台声明的 FFI 重写）、`torch_light ^1.1.0`、`flutter_local_notifications ^22.3.1`（Windows 原生 toast）。
9. **一个身份一个 `TrainingController`**：`TrainingControllerHost` 在 `AppScope` 里；Learn 页和 Me 页的训练设置路由共用同一实例，`LearnScope` 只 dispose 自己创建的控制器。两个实例会互相覆盖 `progress.json`。
10. **参考手册的 SoLoud 播放器懒创建**（首次播放/键控时），否则外壳 `IndexedStack` 一构建就碰音频引擎，测试与无声卡环境会崩。
11. **多语言**：`LocaleController.active` 由 `AppScope` 设置，`currentS()` 供无 `BuildContext` 代码使用；`AppServices.dispose()` 必须在任何 `await` 之前同步释放 `StringsResolver`（`AppScope` 随后就 dispose 控制器）。Android 通知渠道名会跟随语言切换（`LocalNotificationsApi.refreshStrings`，经 `AppServices` → `NotificationCenter` 接线，2026-09-30）；重要性与提示音仍按 Android 规则在首次创建时冻结。
12. **应用级偏好**（语言、窗口位置）存 `<application support>/settings.json`；**按身份的数据**（训练进度、聊天历史）在 `IdentityService.dataDirectory()` 下，随身份备份（`MCQB` 容器）一起迁移。
13. 许可证：Tim2Tox 与 morsecq 均 GPL-3.0，**与 App Store 条款存在已知冲突**，尚未拍板（规划 §3.4 / §9）。iOS 上架不能作为任何时间盒的验收门。

## 6. 现状：做完了什么

| 区域 | 状态 | 备注 |
|---|---|---|
| 引擎包 core / trainer / io / dsp | 代码完成；core 71、trainer 91、io 55、dsp 49 个测试通过 | dsp 阈值首跑即通过 |
| 聊天契约与 Tim2Tox 实现 | 代码完成；45 个单元测试 + `needs-native` smoke 测试通过（smoke 测试 2026-09-30 在 macOS 上真实跑过） | 见 §5 第 1–5 条 |
| 应用：身份/启动门/Me、聊天/好友/群组、训练/统计、参考手册/翻译器、收听、通知、桌面壳 | 代码完成，全部接线，analyzer 零问题；404 个应用测试通过 | |
| 多语言 en + zh | 完成；531 键零 TODO；全部界面走 `S` | 新增语言只需新 ARB |
| 文档 | 英文默认 + zh-CN 成对 | |
| CI | `analyze.yml`、`native.yml` 自 `8ddc265`（2026-09-30）起在 GitHub Actions 上全绿 | 8/8 原生目标与 Linux / macOS / Windows 应用打包全部通过；首轮全红（Tests 步骤、macOS sysroot、arm64 无 Flutter 包、Linux apt 依赖）——均已修复 |
| 原生库 | Linux x86_64（容器）、macOS arm64 与 iOS 设备 + 模拟器 XCFramework 均在真实 Mac 上构建成功（`build/native/`、`ios/Frameworks/tim2tox_ffi.xcframework`）；Android / Windows x64 在 CI runner 上构建过 | Windows arm64 / Linux aarch64 只验证到工具链安装 |

## 7. 接手后的待办（按优先级）

1. ~~跑全量测试并修红。~~ 2026-09-30（第二个会话）已完成；此后每次推送前逐包跑 `flutter test --exclude-tags=needs-native`。
2. **每次推送后继续看 GitHub Actions**；arm64 原生行仍是 `continue-on-error`。
3. **真机验证清单**：侧音延迟 < 30 ms 与爆音、iOS 静音开关下播放（可能需要 `audio_session` 设类别）、Android 触觉精度、托盘图标三平台、通知点击路由、相机扫码、麦克风解码、备份文件保存/分享、身份重装恢复后训练进度完整。
4. **许可证决策**（GPL-3.0 与 App Store）。
5. 上游 D 线（Tim2Tox）：消息附注上线路、Dart 侧自定义包 API、lossy 包 API、`failed` 状态区分。v2 的键控实录与实时键控依赖它。 消息注解 RFC 已起草于 `doc/rfcs/2026-09-30-tim2tox-message-annotation.zh-CN.md` 并提交上游 https://github.com/agentx-icu/tim2tox/issues/20（2026-09-30）；实现属于上游工作。
6. 小修：`MorsecqChatBackend.dispose`、`learn_playback.dart`、`reference_player.dart` 仍是有意的顺序 await（chat → identity → engine；player 先于其 sink），其余销毁链已于 2026-09-30 改为先同步释放；~~`SendIssue.describe()`~~（已标注为仅日志用）、~~Android 通知渠道语言~~、~~`Podfile.lock`~~（iOS + macOS，2026-09-30）已完成；~~应用图标~~（`tool/gen_app_icons.dart` 用莫斯码 "CQ" 渲染 iOS / macOS / Android 传统图标 / Windows 图标及 1024 商店母图 `apps/morsecq/icon/app_icon_1024.png`；自适应图标图层已于 2026-09-30 加入；商店截图仍待做）；~~中文电码（P4）~~（`morse_core` 的 `ChineseTelegraphCode`，表由 `tool/gen_telegraph_table.dart` 从 Unihan 生成，已接入翻译器：汉字按四位数字组键发，可切换大陆 / 台湾电码本；手册页与聊天侧解码未做）；~~Apple / Android / Windows 包链接了腾讯原生 IM SDK~~——2026-09-30 已由 bootstrap overlay 去掉（§5.5）；验证：`pod install` 后两份 `Podfile.lock` 均无 `TXIMSDK_Plus_*` / `HydraAsync`，macOS release 包带桩插件可启动；Mac 上构建的 UI-only Android debug APK（`-PmorsecqAllowMissingFfi=true`，因此也没有 `libtim2tox_ffi.so`）内无任何 `com.tencent.imsdk` 类或库、含桩插件类；Windows 由携带 overlay 的那次推送的 CI 应用构建检查。
7. codex 审核：第一个会话明确跳过；第二个会话对自己的 diff 跑了 `codex-mac`（见方案变更日志 v0.3.6）。此后每个变更都应过审。

## 8. 这些代码是怎么写出来的（如果你要继续用多代理）

- 编排者先手写**契约骨架**（`morse_core` 公共 API、`morsecq_chat_api`），再按**目录边界**并行派代理，每个代理只碰自己的目录；共享文件（根 `pubspec.yaml` 的 `workspace:` 列表、ARB）只允许追加自己的行/键并在编辑前重读。
- 代理不提交；编排者按波次跑全部门禁后提交推送。
- 每个代理的简报都包含：环境、所有权、硬规则（500 行、analyzer 零问题、移动端兼容）、交付物、回报格式。规划文档 §11 有波次表。
- 用户的两条工作指令要记住：「不实际进行构建和测试」（上一轮）、「当前会话不做 codex 审核」（上一轮）。新会话请重新确认这两条是否仍然有效。

## 9. 各代理留下的已知问题（原样汇总）

- `arb_consistency_test` 现遍历所有 `app_*.arb` 并拒绝残留 `@@TODO`。
- iOS / macOS `Info.plist` 的 `CFBundleLocalizations` 只有 `en`、`zh-Hans`，加语言时同步。
- `record_linux` 依赖 PATH 上的 `parecord`（PulseAudio / PipeWire-pulse）。
- Linux 托盘需要 `libayatana-appindicator3-dev`，AppIndicator 无左键与 tooltip。
- Windows 通知的 `cancel()` 与冷启动载荷只在 MSIX 打包时可用。
- Tim2Tox `auto_tests` 依赖 `TIMManager.initSDK`，不能直接复用；`morsecq_chat/test/native_smoke_test.dart` 是自建的 headless 冒烟，需要原生库。
