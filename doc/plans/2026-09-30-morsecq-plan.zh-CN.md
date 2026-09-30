[English](./2026-09-30-morsecq-plan.md)

# morsecq — 跨平台莫斯电码 App 立项规划

> 状态：v0.3（2026-09-30）。本文是 morsecq 的立项规划，最初在 toxee 仓库起草（复用其代码事实），现随仓库 `agentx-icu/morsecq` 一起维护。toxee 文档惯例为 EN/zh-CN 成对，本稿先只出中文。
>
> 评审记录见文末「变更记录」。

## 0. 一句话

**morsecq**：一款「学莫斯、用莫斯聊天」的跨平台 App。首启创建一个 Tox 身份（无服务器、无手机号），之后训练学习与聊天共用这一身份：训练进度按身份保存，单聊与群聊走 Tox P2P 网络，复用 toxee 已经打磨过的 Tim2Tox 通信栈。消息在线路上就是普通文本，任何 Tim2Tox 客户端（含 toxee）都能读；morsecq 端把它按听者自选速度播成「滴答」。

## 1. 项目命名

### 1.1 定名：**morsecq**（2026-09-30 拍板）

- 仓库 `https://github.com/agentx-icu/morsecq`，GPL-3.0。
- Dart 包前缀 `morse_*`（纯引擎）/ `morsecq_*`（应用侧），Bundle ID `icu.agentx.morsecq`。
- 商店标题建议「morsecq: Morse Code Chat & Trainer」；中文副名「滴答」。
- 首个候选 Morsee 因 Google Play 已有同名 App（`com.wisteriastone.morsecode`）放弃。

### 1.2 当时的候选记录（2026-09-30 用网页搜索核对商店同名，非商标检索）

| 候选 | 由来 / 读法 | 商店同名 | 取舍 |
|---|---|---|---|
| **CQCQ**（首选） | 电台呼叫本身就是「CQ CQ CQ」，名字即节奏 dah-di-dah-dit dah-dah-di-dah；读 "see-queue see-queue" | 未见同名 App（仅有大量以 CQ 开头的无关 App：调音台、券商、政治新闻） | 品牌感最强、好记、包名 `icu.agentx.cqcq` 干净；缺点是名字里没有 morse，商店标题需写成「CQCQ: Morse Code Chat & Trainer」补搜索；CQ 是业余无线电杂志名，商标需查 |
| **MorseCQ** | Morse + CQ，一个词 | 未见同名 | 描述性最强、搜索友好；品牌感弱于 CQCQ |
| **CQ Morse** | 同上，两个词 | 未见同名 | 最直白，但通用词组合，商标保护弱，易被 Morse 类 App 淹没 |
| **CQ Dit** / **DitCQ** | CQ + 点（dit） | 未见同名 | 有点划趣味，短；「Dit」对非爱好者无意义 |
| **CQtox** | CQ + Tox，直指 P2P 底座，与 toxee 同族 | 未见同名，但与 Tox 客户端 qTox 近音 | 对 Tox 社区友好，对普通用户不解释 |
| **CQ Wave** | CQ + 电波 | 未见同名 | 意象好，中文「电波」顺口；偏泛 |

已确认被占用、不再考虑：Morsenger（Play）、CQ Key（App Store，券商双因子；另有同名硬件品牌）、CQNet（App Store，无人机管理）、Morse Chat（iOS + Android，且是直接竞品：服务器房间制莫斯聊天）。

中文副名建议不变：**「滴答」**；若选 CQCQ，也可用「呼叫呼叫」。

待办：定名后核对 GitHub `agentx-icu/<name>`、App Store / Play 精确名称、域名（`<name>.app`）、商标数据库。本会话的 GitHub 访问范围只有 toxee，未做核验。

### 1.3 竞品提示

Morse Chat（digital.dong.morsechat）已做「按速度分房间 + 私聊 + 七种电键」的莫斯聊天，走中心服务器。morsecq 的差异点必须讲清楚：**Tox P2P、无服务器、无手机号/邮箱注册、与 toxee 生态互通、训练与聊天一体**。

## 2. 产品定义

### 2.1 目标用户

1. 想系统学莫斯电码的人（业余无线电备考、兴趣、密码/应急爱好者）。
2. 学会后想「真的用起来」的人：和朋友用莫斯发消息、在群里练收发。
3. 隐私敏感用户：不要账号服务器、不要手机号，P2P 即可。

### 2.2 三大模块

所有模块都在同一个 Tox 身份下使用（产品决定，2026-09-30）：首启即创建身份，训练进度按身份持久化并随身份文件一起备份/迁移。

| 模块 | 核心能力 | 是否需要网络 |
|---|---|---|
| **训练学习** | Koch 法字符课程、Farnsworth 间距、听抄练习、发报练习（直键 / 双桨自动键）、实时解码反馈、错字混淆矩阵、间隔复习、每日目标 | 否，创建身份后可完全离线训练 |
| **C2C 单聊** | Tox ID / 二维码加好友、莫斯消息（明文上线路，接收端按自选速度播放为音频/震动/闪光）、「先听后揭晓」练习模式、历史记录、离线队列 | 是，Tox P2P，无账号服务器 |
| **群组聊天** | 创建 / 邀请 / 通过 chat_id 加入、群内莫斯消息、成员列表、重启后自动重入、CQ 呼叫式的「电台频道」玩法 | 是，Tox NGC 群 |

### 2.3 与 toxee 的互通

v1 的莫斯消息在线路上**就是纯文本**，不附带任何元数据（原因见 §3.1 第 5 条：Tim2Tox 的 `cloudCustomData` 只存本地，不上线路）。toxee 用户收到的是可读文本；morsecq 收到后按听者设置的速度重新生成节奏播放。这与莫斯训练界的惯例一致——听者用自己的速度听，本来就是 Farnsworth 练法的一部分。

「听到对方真实手感（键控实录）」是 v2 特性，依赖 Tim2Tox 上游新增「消息附注」线路承载（§5.2 第二层）。

### 2.4 明确不做（v1）

- 语音/视频通话（不引入 ToxAV）。
- 服务器推送。Tox 没有离线服务器，双方都在线才收得到，离线消息依赖 Tim2Tox Dart 侧队列在对方上线时补发。UI 上要把这一点讲清楚。
- 多账号同时在线（Tim2Tox 单例模型，与 toxee 一致）。
- 键控实录传输、实时键控（v2，见 §5.2 / §5.5）。

## 3. 技术选型与架构决策

### 3.1 关键事实（来自 toxee 主干 `5a1cebe` 与 tim2tox 子模块 pin `9d4245a` 的勘查，2026-09-30）

1. `tim2tox_dart`（`third_party/tim2tox/dart`，GPL-3.0）在包级别依赖 `tencent_cloud_chat_sdk: any`（**未 pin**）与 `tencent_cloud_chat_common ^4.1.0+1`；`FfiChatService` 本身 import 的是 `tencent_cloud_chat_sdk` 的 `native_library_manager`、`tim_message_manager`、`tim_group_manager` 等。不能「只拿 Tim2Tox 不拿腾讯 SDK」，除非上游先做拆分；且必须原样复制 toxee 的 `pubspec_overrides` pin，否则 `any` 会漂。
2. `FfiChatService`（约 13k 行）已提供 morsecq 需要的通信能力：账号（`init/login`、同步的 `getSelfToxId()`、`updateSelfProfile`）、好友（`addFriend/acceptFriendRequest/getFriendList/removeFriend`）、单聊（`sendTextWithResult(peerId, text, {cloudCustomData, clientMessageID})`、`sendFile`）、群聊（`createGroup(name, {groupType: 'group'|'conference'})`、`joinGroup`、`acceptGroupInvite`、`sendGroupTextWithResult(groupId, text, {clientMessageID})`、`quitGroup`）、历史（`loadHistory/clearC2CHistory/clearGroupHistory`）、连接状态流、`startPolling()`、Dart 侧离线消息队列（对方上线时自动重放，返回 pending 行）。
3. 构造 `FfiChatService` 只需注入 `ExtendedPreferencesService`（含 Draft / GroupIdentity / AccountScoped 变体，合计约 60 个方法）、`LoggerService`、`BootstrapService`、`ScratchFileService`；`EventBusProvider` / `ConversationManagerProvider` 属于 FakeUIKit 侧，方案 B 不需要。接口定义在 `tim2tox/dart/lib/interfaces/`。
4. toxee 中**真正可搬运**的只有：`lib/models/`、`startup_outcome` / `startup_step` 类型、`logger` / `bootstrap` / `shared_prefs` 三个适配器（约 1.1k 行）。`StartupSessionUseCase`、`LoginUseCase`、`AccountService`、`StartupGate` 都经由 `SessionRuntimeCoordinator` / `FakeUIKit` / 腾讯 provider 耦合，**流程可以照抄，代码不能搬**。
5. **`cloudCustomData` 不上线路。** `FfiChatService.sendText` 文档明确「NOT sent over Tox — the peer never sees the quote」，它只落在本地 `ChatMessage` 与离线队列行上；`sendGroupTextWithResult` 连这个参数都没有。toxee 用它做回复引用，所以引用也不会传到对端——这是 toxee 自己的既有缺口。
6. 自定义包现状：`Tim2ToxSdkPlatform.createCustomMessage` 的发送路径是把数据包成 `__custom__:` **文本**，且拒绝超过单分片者；真正的 lossless 自定义包只有原生 `tim2tox_ffi_send_c2c_custom` → `tox_friend_send_lossless_packet`（包 ID 184，ID 已**提交**到 zoff99 注册表，未见确认），Dart 侧只在 `Tim2ToxFfi.sendC2CCustomNative / sendGroupCustomNative` 有原生绑定，`FfiChatService` 没有对应方法。群自定义包对旧 Conference 类型直接拒绝。**没有任何 lossy 包发送接口**（只注册接收回调）。
7. 长度：文本按 `TOX_MAX_MESSAGE_LENGTH − 50 = 1322` 字节分片，但分片在接收端是多条独立消息；lossless 自定义包超过 Tox 上限直接报 `ERR_SDK_MSG_BODY_SIZE_LIMIT`，**没有分片**。
8. Headless 可行性：`init / login / startPolling` 只走 `_ffi`，ToxAV 关闭时 `avIterate` 有空桩。但有两处硬走腾讯绑定：`quitGroup`（`NativeLibraryManager.registerPort` + `bindings.DartQuitGroup`）和离线群邀请重放（`TIMGroupManager.instance.inviteUserToGroup`），二者都要求 `setNativeLibraryName('tim2tox_ffi')` 且腾讯绑定能加载 `libtim2tox_ffi`。不装 `Tim2ToxSdkPlatform` 时，`clearHistoryMessage` / `groupQuitNotification` / `groupChatIdStored` 三个回调会被静默丢弃（toxee `HYBRID_ARCHITECTURE.md` §4.3），拉取式补偿是 `syncGroupIdentitiesFromNative()`。**现有测试没有一个走 headless 模式**：tim2tox `auto_tests` 用 `TIMManager.instance.initSDK` 并检查 `Tim2ToxSdkPlatform`；toxee 单测只裸构造 `FfiChatService`，不登录不收发。
9. 原生库：`tool/ci/build_tim2tox.sh` 覆盖 Linux x86_64 / Windows x64（arm64 实验性）/ macOS x86_64+arm64 / Android arm64-v8a / iOS arm64；已有 `--no-toxav` 开关，关掉即不需要 opus 1.5.2 与 libvpx 1.15.2。tim2tox 自带 `build.sh` 默认 `BUILD_FFI=ON`，也能出共享库。最低系统版本见 toxee `doc/reference/PLATFORM_SUPPORT.md`：macOS 10.15、Windows 10、Android API 21、iOS 13。
10. 音频：toxee 用的 `flutter_pcm_sound` 只支持 **Android / iOS / macOS**（toxee 自己也把它限定在移动端）；Windows / Linux 没有现成侧音方案。其他可复用包：`qr_flutter`、`mobile_scanner`、`flutter_secure_storage`、`provider`。没有触觉反馈包。
11. `tim2tox_dart` 依赖 `path_provider` / `shared_preferences`，所以 `morsecq_chat` 的测试要用 Flutter test binding 并 mock `path_provider` channel（toxee 的 `ffi_chat_service_group_invite_queue_test.dart` 就是这么做的），不是纯 `dart test`。

### 3.2 四个方案

| 方案 | 做法 | 优点 | 代价 |
|---|---|---|---|
| A. Fork toxee | 复制整个 toxee（腾讯 UIKit + FakeUIKit + 双路径混合架构），在上面加莫斯功能 | 聊天第一天就能跑 | 继承约 10 万行、patch 流程、`BinaryReplacementHistoryHook` 等双路径不变量；莫斯 UX 被 UIKit 气泡框住；复杂度守卫下很难再瘦身 |
| **B. Tim2Tox 引擎 + 自绘 UI（推荐，以「B 变体」为基线）** | 依赖 `tim2tox_dart`，只用 `FfiChatService`；**仍调用 `setNativeLibraryName('tim2tox_ffi')`**（第 8 条的两处硬依赖需要它），但不装 `Tim2ToxSdkPlatform`、不启 FakeUIKit、不引 UIKit 组件包；聊天 UI 全部按莫斯场景自绘 | 只有一条数据路径；UI 完全为莫斯设计；无 UIKit patch | 腾讯 SDK 仍是编译依赖（复用 toxee `bootstrap_deps` 与补丁流程）；`quitGroup` 与离线群邀请重放两处要改走 `Tim2ToxFfi` 或上游补 API；被静默丢弃的三个回调要用 `syncGroupIdentitiesFromNative()` 兜底；要自建 headless 双实例测试 |
| C. 直接绑定 C 层 `tim2tox_ffi.h` | 另写一层薄 Dart 绑定 | 零腾讯依赖 | 重写 13k 行 Dart（离线队列、历史、群重入、文件传输），得不偿失 |
| D. 上游拆分 `tim2tox_core` | 在 Tim2Tox 仓库把 UIKit 无关的部分拆成独立包，并补「消息附注上线路」「Dart 侧自定义包 API」「lossy 包 API」 | 长期最干净，toxee 也受益（回复引用终于能传到对端） | 是独立的上游工程；其中「消息附注」是 morsecq v2 键控实录的前置，但**不阻塞 v1** |

**决策：B 变体为基线，D 线并行。** v1 聊天只依赖 Tim2Tox 现有能力（纯文本消息 + 现有群/好友/离线队列），因此 D 线的进度不卡 M1–M3；D 线产出（消息附注、Dart 侧自定义包 API、lossy API）落地后再开 v2 的键控实录与实时键控。若 M0 spike 证明 headless 路线连 B 变体也跑不通，退回方案 A。

### 3.3 目标架构（方案 B 变体）

```
┌──────────────────────── apps/morsecq (Flutter) ───────────────────────┐
│  ui/learn        ui/chat (c2c + group)       ui/account   ui/settings  │
│  ─────────────── 状态层：provider（与 toxee 一致）─────────────────────  │
├──────────────┬──────────────────┬──────────────────┬──────────────────┤
│ morse_core   │ morse_trainer    │ morse_io         │ morsecq_chat      │
│ 纯 Dart      │ 纯 Dart          │ 平台音频/触觉/闪光 │ Tim2Tox 门面      │
│ 字母表/编解码 │ Koch/Farnsworth  │ flutter_soloud   │ FfiChatService   │
│ 时序/解码器  │ SRS/进度/统计     │ HapticFeedback   │ + 账号/启动/登录  │
│ 中文电码(P4) │                  │ torch/屏幕闪光    │ + adapters 实现   │
├──────────────┴──────────────────┴──────────────────┴──────────────────┤
│ third_party/tim2tox (submodule) → libtim2tox_ffi (c-toxcore, --no-toxav)│
└─────────────────────────────────────────────────────────────────────────┘
```

- `morse_core` / `morse_trainer` 不依赖 Flutter，可单独 `dart test`，也是未来 Web/CLI 复用的基础。
- `morsecq_chat` 是**唯一**接触 `tim2tox_dart` 与腾讯 SDK 的包：账号创建/恢复、启动用例、登录用例、好友、会话、消息流全部在里面，对上只暴露 `MorseChatService`。用 import 白名单脚本在 CI 里禁止 `apps/` 与其他包出现 `tencent_cloud_chat*` / `tim2tox_dart` import。
- **单一构建目标**：训练也要求身份，所以 App 始终带 `morsecq_chat` 与原生库；启动门（身份存在/创建/解锁）位于 shell 之前，训练与聊天页面都在门后。M1 内测时聊天入口可先隐藏，但身份流程必须已可用。
- 仓库为单仓多包（`melos` 可选，不强制），CI 沿用 toxee 的 `flutter analyze` 严格 lint、`check_complexity.dart`（500 行硬门）、五端原生库构建脚本。

### 3.4 许可证（需要拍板）

Tim2Tox 与 toxee 均为 GPL-3.0，morsecq 只要链接 Tim2Tox 就必须 GPL-3.0 兼容。**GPLv3 与 App Store 条款存在已知冲突**（FSF 立场、VLC 曾因此下架），「关于页放源码链接」并不解决问题。可选路径：① 接受风险照发（业界不少 GPL App 在架但无保障）；② morsecq 自有代码双许可（GPL-3.0 + 允许商店分发的附加许可），但 Tim2Tox 部分仍是 GPL；③ 向 Tim2Tox（同组织）加 App Store 分发例外条款。建议 ③ + ②，在 M0 定下来。iOS 商店上架不能作为任何时间盒里程碑的验收门（见 §6）。

## 4. 训练学习模块设计

### 4.1 莫斯引擎（`morse_core`）

- 字母表：ITU 国际莫斯（A–Z、0–9、标点）、常用 prosign（AR、SK、BT、SOS 等）。中文电码（4 位数字表，约 7000 常用字）放到 P4，数据表体积与检索要单独评估。
- 时序标准（PARIS 法）：`dit = 1200 / WPM` 毫秒；dah = 3 dit；字符内间隔 1 dit；字符间 3 dit；词间 7 dit。Farnsworth：字符速度与有效速度分离，只拉长字符间/词间间隔。
- 编码器输出 `List<MorseElement>`（on/off 与时长），供音频、震动、闪光三种渲染器共用同一份时间轴。
- 解码器：输入按键的 down/up 时间戳序列。**dit 长度用两簇聚类估计**（按键时长分成短/长两簇，取短簇均值；不用整体中位数——O、0、T 多的文本里中位数会落到 dah 上）。判决阈值放在名义值的中点：**点/划阈值 2×dit；字符内/字符间间隔阈值 2×dit；字符间/词间阈值 5×dit**；这样 ±30% 抖动仍能正确判决。Farnsworth 模式下字符间/词间间隔被人为拉长，间隔阈值改为按观测到的间隔分布自适应，而不是固定倍数。附带「置信度」，UI 用来做实时纠错提示。
- 全部逻辑有黄金用例测试：标准句子在 5/12/20/25 WPM 下的精确毫秒序列；解码器对加入 ±20%/±35% 抖动的合成序列的准确率下限；Farnsworth 与非 Farnsworth 各一组。

### 4.2 训练法

- **Koch 法**：从 K、M 两字符起步，字符速度固定 18–20 WPM（Farnsworth 有效速度 5–10 WPM 可调），单课准确率 ≥ 90% 解锁下一字符；顺序采用 LCWO 常用序列。
- **听抄**：随机字符组 → 常用词 → 呼号 → 简短 QSO 对话；答题方式键盘输入或点选；统计每字符准确率与「混淆矩阵」（如 S/H、B/6）。
- **发报**：屏幕直键（单键）与双桨（左点右划，Iambic B）；桌面端用空格/左右 Ctrl 或外接键盘；解码结果实时显示，并给出「点太长 / 字符间隔不足」这类节奏诊断。
- **间隔复习（SRS）**：对准确率低的字符加权抽样；每日目标与连续打卡。
- **进度存储**：本地 SQLite 或 JSON（`path_provider`），不上云；支持导出 JSON。

### 4.3 声音与体感（`morse_io`）

- 侧音：600–800 Hz 可调正弦，5 ms 起止包络防爆音。**首选 `flutter_soloud`**（Android / iOS / macOS / Windows / Linux 全覆盖，低延迟）；`flutter_pcm_sound` 只覆盖三端，仅作移动端备选。按键→出声延迟目标 < 30 ms，M0 五端实测。
- 震动：iOS/Android 用 `HapticFeedback` / `vibration`（时长精度差，仅作辅助），桌面无震动改用屏幕闪光。
- 闪光：全平台屏幕闪光；移动端可选手电筒（`torch_light`）。
- 音频会话：iOS 需 `AVAudioSession` 播放类别以在静音开关下仍出侧音；Android 用 `USAGE_GAME` 低延迟属性。

## 5. 通信模块设计

### 5.1 账号与好友

- 在 `morsecq_chat` 内**重写**（流程照抄 toxee 的 `StartupSessionUseCase` / `LoginUseCase` / `AccountService`，代码不搬）：首启生成 Tox 身份 → 可选密码加密 `.tox` → 自动登录 → 等连接。
- 加好友：手输 Tox ID、扫码（`mobile_scanner`）、展示二维码（`qr_flutter`）。
- 首启必须提示备份 Tox 身份文件（toxee 的 TODOS 已把「丢身份 = 丧失信任」列为头号风险，morsecq 直接吸取）。

### 5.2 莫斯消息：两层设计

**第一层（v1，M2/M3 交付，不依赖上游）：纯文本。**

- C2C 用 `sendTextWithResult(peerId, text)`，群用 `sendGroupTextWithResult(groupId, text)`；`text` 是解码后的明文。任何 Tim2Tox 客户端可读。
- 接收端按**听者**设置的字符速度 / Farnsworth 速度 / 音调生成播放序列。发送方的速度不传——这是刻意的产品选择，与训练惯例一致。
- 单条明文控制在 1322 字节以内以避免分片（分片在接收端是多条消息）；UI 在输入区显示剩余字节。

**第二层（v2，依赖 D 线「消息附注上线路」）：键控实录。**

- 上游改动：在 Tim2Tox 控制帧（T2TC，ID 184）新增「消息附注」类型，以 `clientMessageID` 关联，接收端把它合并进对应 `ChatMessage.cloudCustomData` 而**不是**渲染成独立气泡。这同时修复 toxee 回复引用不上线路的既有缺口，所以对上游是双赢。
- morsecq 在附注里放 `{"morsee":{"v":1,"wpm":15,"fw":8,"keyed":true,"t":"<base64 varint 时序>"}}`，时序以 dit 单位量化后 varint 编码，总载荷 ≤ 1.2 KB（自定义包没有分片，超限直接报错）。
- 旧客户端忽略未知附注键；Conference 类型群无法承载自定义包，附注只在 C2C 与 NGC 群可用。

### 5.3 聊天 UI 的莫斯特性

- 气泡显示三层：点划符号 / 明文 / 播放按钮；「训练模式」默认遮住明文，听完再揭晓并记分。
- 输入区三种模式：键盘文本（自动编码）、直键、双桨；发送前可预听。
- 会话列表：未读、置顶、草稿由 `morsecq_chat` 自己维护（不经 FakeUIKit）；草稿可复用 Tim2Tox 的 `DraftPreferencesService`。

### 5.4 群组

- 默认 `groupType: 'group'`（NGC），保留 chat_id 持久化与重启重入（toxee `doc/reference/GROUP_CHAT_GUIDE` 里的映射恢复机制原样受益）。
- Conference 仅为兼容旧客户端保留开关，不做 UI 主入口；v2 附注在 Conference 上不可用要在 UI 里提示。
- `quitGroup` 与离线群邀请重放要在 M0 spike 确认走腾讯绑定的路径在 B 变体下可用（已调用 `setNativeLibraryName`），否则改走 `Tim2ToxFfi` 或上游补 API。
- 玩法：群 = 「频道」，支持「CQ」快捷呼叫与「网络练习」（轮流发报、群内自动评分，P4）。

### 5.5 实时键控（v2，可选）

- 目标：对方能近实时听到你敲键。
- lossless 自定义包是有序可靠传输，一个包延迟就会阻塞后面所有键控事件（队头阻塞），走 TCP 中继时 RTT 本身就可能超过 200 ms 抖动缓冲。**因此很可能需要 lossy 包接口**，这是 D 线要新增的 FFI/Dart API，必须遵守 Tim2Tox 的 ABI 字节级匹配约束。先用 lossless + 抖动缓冲做原型量化延迟，再决定是否上 lossy。

### 5.6 移动端注意事项（移动端兼容为硬性要求）

- 后台：toxee 靠 `voip` + `audio` 后台模式把 iOS 连接保温约几分钟（`MOBILE_BACKGROUND.md`），而 morsecq 不带 ToxAV，**不能诚实地声明 `voip` 后台模式**，iOS 后台窗口会更短；Android 各厂商省电策略不一。沿用前台服务 / 本地通知策略，产品上明确「在线才收」。
- 双桨键在触屏上需要 ≥ 48 dp 的大热区与多点触控；桌面端键盘快捷键是另一套输入实现，两端都要有对应测试。

## 6. 里程碑与工期

工期采用 toxee `TODOS.md` 的 **CC 日**（Claude Code 协作下的一个工作日，约合 8–15 个人力日）口径。

| 里程碑 | 交付 | 验收门 | 工期 |
|---|---|---|---|
| **M0a 仓库与 CI** | 新仓库骨架（两个构建目标）、复制 toxee 的 `bootstrap_deps` / `check_complexity` / `analysis_options` / `build_tim2tox.sh --no-toxav`、五端 CI（含 macOS/Windows runner 与 iOS 签名）、`morse_core` 编解码 + 黄金测试、许可证决策 | 五端 CI 绿；`morse_core` 测试通过 | 3–4 CC 日 |
| **M0b 通信 spike** | ① B 变体 headless：`setNativeLibraryName` + 裸 `FfiChatService` 双实例登录、加好友、互发文本、建 NGC 群互发、`quitGroup`、离线队列重放，全程不装 Platform/FakeUIKit，用 Flutter test binding + mock path_provider 落成可重复测试；② `flutter_soloud` 五端侧音延迟 < 30 ms；③ `--no-toxav` 库被 Dart 绑定正常加载；④ 向 Tim2Tox 提「消息附注上线路」RFC 草案 | ①③ 全过则 B 变体成立；否则回退方案 A 并重估 | 3–4 CC 日 |
| **M1 身份 + 训练学习 MVP** | 身份创建/密码/备份/恢复（`morsecq_chat` 的账号部分，依赖 M0b 结论）、Koch 课程、听抄、发报（直键/双桨）、解码器、按身份保存的进度与 SRS、设置；聊天入口隐藏发内测 | 五端可跑；解码器抖动与 Farnsworth 测试达标；身份重装恢复后训练进度完整 | 9–11 CC 日 |
| **M2 单聊** | 身份创建/备份/恢复、加好友、纯文本莫斯消息、聊天 UI、历史、离线队列、基础本地通知 | 与 toxee 互发互通；离线补发；移动端后台策略落地 | 8–10 CC 日 |
| **M3 群聊** | 建群/邀请/chat_id 加入、群莫斯消息、成员列表、重启重入 | 三端三实例互通；杀进程重启后群恢复 | 5–6 CC 日 |
| **M4 打磨与发布** | 中文电码、i18n（zh/en）、无障碍、打包（Play / msix / dmg / AppImage；iOS 视 §3.4 决议） | 打包产物可安装；崩溃率与延迟指标达标（**不含**商店审核结果） | 6–8 CC 日 |
| **D 线（并行上游）** | `tim2tox_core` 拆分 RFC、消息附注上线路、Dart 侧自定义包 API、lossy 包 API | 不阻塞 M1–M4；是 v2 的前置 | 另计 |
| **v2** | 键控实录（§5.2 第二层）、实时键控（§5.5）、群网络练习 | 依赖 D 线落地 | 另计 |

v1 合计约 **33–42 CC 日**，按本仓 8–15× 口径约合 **260–630 人力日**。M1 先于 M2 是刻意的：学习模块无网络依赖、风险最低、可最早验证用户价值；通信部分的所有不确定性在 M0b 里消化。

## 7. 风险与对策

| 风险 | 影响 | 对策 |
|---|---|---|
| B 变体 headless 跑不通（腾讯绑定加载、`quitGroup`、邀请重放、静默丢弃的三个回调） | 方案基线失效 | M0b 首项 spike；`syncGroupIdentitiesFromNative()` 兜底；两处硬依赖改走 `Tim2ToxFfi`；再退是方案 A |
| 腾讯 SDK 作为隐性编译依赖（`tencent_cloud_chat_sdk: any` 未 pin） | 版本漂移、补丁维护 | 原样复制 toxee 的 `pubspec_overrides` pin 与 `PATCH_MAINTENANCE` 流程；D 线拆分后彻底移除 |
| 五端原生库构建（NDK / iOS framework / vcpkg） | 构建链是 toxee 最重的运维负担 | 原样复用 `tool/ci/build_tim2tox.sh --no-toxav`、`build_android_ffi.sh`、`build_ios_sim_ffi.sh` |
| GPL-3.0 与 App Store 冲突 | iOS 上架受阻 | §3.4 三选一，M0a 定案；iOS 上架不进任何时间盒验收 |
| Windows/Linux 侧音无现成方案；`flutter_soloud` 延迟或爆音 | 训练体验核心 | M0b 五端实测；备选自写 miniaudio FFI 薄层 |
| 用户对 P2P「离线收不到」不理解 | 差评与流失 | 首启教育、在线状态醒目、离线消息「待送达」标记（Tim2Tox 已返回 pending 行） |
| iOS 后台窗口比 toxee 更短（无 `voip` 模式） | 移动端在线率低 | 产品上以「打开即收」为预期；探索 `audio` 后台模式配合侧音是否合规 |
| 身份文件丢失 | 不可恢复 | 首启强制备份向导（导出加密 `.tox` + 二维码/文件） |
| 解码器对新手节奏容错不足 | 挫败感 | 中点阈值 + 两簇 dit 估计 + 置信度分级；训练模式允许「宽松档」 |
| 上游 D 线进度不受控 | v2 特性延期 | v1 完全不依赖 D 线；同组织维护，可自己提 PR |
| 复杂度失控 | 重蹈 toxee 大文件问题 | 从第一天启用 500 行硬门与 baseline ratchet；import 白名单脚本把腾讯/Tim2Tox 类型锁在 `morsecq_chat` 内 |

## 8. 质量与流程

- 静态：`flutter analyze` 严格 lint（沿用 toxee `analysis_options.yaml`）、`check_complexity.dart`、import 白名单脚本。
- 单测：`morse_core` / `morse_trainer` 纯 Dart 测试，覆盖时序黄金值、解码抖动、Farnsworth 自适应阈值、Koch 解锁逻辑、SRS 抽样分布。
- 集成：**自建** headless 双实例测试（Flutter test binding + mock `path_provider`，M0b 产出），tim2tox `auto_tests` 因依赖 `TIMManager.initSDK` 与 `Tim2ToxSdkPlatform` 不能直接复用；UI 层借鉴 toxee 的 MCP 真实控件驱动思路（`MORSECQ_L3_TEST` 开关）。
- 评审：每个变更走「草稿 → codex 二次意见 → 应用 → 推进」；codex 不可用时显式声明跳过并记欠账（本文即如此，见变更记录）。
- 移动端兼容：每个 PR 的默认评审问题「移动端也会命中吗？」，桌面专属实现必须点名对应的移动实现或说明缺口。

## 9. 需要你拍板的事

1. **项目名**：接受 morsecq（中文副名「滴答」）？还是从备选/其他里选。
2. **许可证与 iOS 上架**（§3.4）：接受风险 / 自有代码双许可 / 向 Tim2Tox 加商店例外。
3. ~~训练模块是否强制无账号~~ **已拍板（2026-09-30）：训练也需要身份**。影响：去掉 learn 构建目标；M1 前置身份流程；训练进度按身份持久化并随 `.tox` 备份一起迁移。
4. **v1 是否接受「不传发送方速度」**（§5.2 第一层）。若必须传，v1 就要等 D 线的消息附注，M2 会被上游进度卡住。
5. **中文电码**优先级：本稿放 P4；若目标用户以中文圈为主，可提到 M1 之后紧接着做。
6. 新仓库位置：建议 `agentx-icu/morsecq`，与 toxee 同组织。

## 10. 下一步（拍板后立刻执行）

1. 建仓 `agentx-icu/morsecq`，初始化 `apps/morsecq`（两个入口）+ 四个包骨架 + `third_party/tim2tox` 子模块（pin 与 toxee 一致）。
2. 搬运 toxee 的 `tool/bootstrap_deps.dart`、`pubspec_overrides` pin、`tool/check_complexity.dart`、`tool/ci/build_tim2tox.sh`（默认 `--no-toxav`）、`analysis_options.yaml`、`tool/install_git_hooks.sh`。
3. 落地 `morse_core` 编解码与黄金测试（不依赖任何 Tim2Tox 结论，可与 spike 并行）。
4. 跑 M0b 四项 spike，把结论写回本文 §3.2，并决定 B 变体或方案 A。
5. 向 Tim2Tox 提「消息附注上线路」RFC（同时修 toxee 回复引用不上线路的缺口）。

## 11. 多代理并行开发编排（2026-09-30 起执行）

用户指定采用多代理并行开发。原则：**按包边界切分，代理之间只通过已提交的公共 API 契约耦合**；编排者先手写契约骨架（`throw UnimplementedError()`），再并行派发；共享文件（根 `pubspec.yaml` 的 `workspace:` 列表）只允许追加自己的一行；代理不提交，编排者按波次集成、跑全量门禁后提交。

| 波次 | 代理 | 产出目录 | 依赖 |
|---|---|---|---|
| 0（编排者） | — | 根 workspace、共享 lint、`morse_core` 公共 API 骨架 | — |
| 1 | core | `packages/morse_core` 实现 + 黄金测试 | 骨架 |
| 1 | trainer | `packages/morse_trainer`（Koch/Farnsworth/题库/评分/SRS/进度，纯 Dart） | 骨架类型；测试注入显式数据，不依赖 core 实现 |
| 1 | io | `packages/morse_io`（`flutter_soloud` 侧音、触觉、闪光、直键/双桨状态机、按键控件） | 骨架类型；插件调用全部藏在可注入接口后 |
| 1 | scaffold | `tool/check_complexity.dart`、`tool/import_guard.dart`、CI、`apps/morsecq` 外壳、`CLAUDE.md`、README | — |
| 1.5（编排者） | — | `packages/morsecq_chat_api`：纯 Dart 契约（`IdentityService`、`ChatService`、模型），UI 与实现两侧共同依赖 | — |
| 2 | chat | `packages/morsecq_chat`：tim2tox 子模块、`bootstrap_deps` 移植、`Tim2ToxIdentityService` / `Tim2ToxChatService` 实现契约、headless 双实例测试脚手架 | 契约包 |
| 2 | learn-ui | `apps/morsecq/lib/ui/learn`：课程/听抄/发报页面，接 trainer + io | 波次 1 |
| 2 | account-ui | 启动门、身份创建/解锁/备份页面、Me 页、Provider 装配（`lib/di`），对着契约 + `FakeIdentityService` 开发 | 契约包 |
| 2 | chat-ui | 会话列表、单聊、好友、群组页面，莫斯气泡与三模式输入，`FakeChatService` | 契约包；播放/键控等 morse_io 就绪 |
| 3 | native-ci | `tool/ci/build_tim2tox.sh`（默认 `--no-toxav`）、五端打包脚本、`.github/workflows/native.yml`、平台捆绑、`doc/operations/BUILD_AND_DEPLOY` | 需要有工具链的 runner；本容器无法验证 |
| 3 | reference-ui | `ui/reference`：字母表/标点/prosign/Q 简语/CW 缩写手册、双向翻译器、`MorsePatternText` | core、io |
| 3 | stats-ui | `ui/stats`：课程/准确率/连续天数概览、趋势图、字符格、混淆热图、练习日历（CustomPainter，无图表库） | trainer |
| 3 | dsp + listen-ui | `packages/morse_dsp`（Goertzel、自动调谐、包络门限、`AudioMorseDecoder`，纯 Dart）+ `ui/listen`（`record` 麦克风流） | core |
| 3 | desktop-shell | `lib/desktop`：窗口尺寸持久化、关闭到托盘、托盘菜单、快捷键 intent（移动端全 no-op） | — |
| 3 | notifications | `lib/notifications` + `lib/lifecycle`：本地通知（含莫斯图样）、角标、前后台协调、无 `voip` 的 iOS 后台策略 | 契约包 |
| 3 | l10n | `l10n.yaml`、`app_en.arb` / `app_zh.arb`、`LocaleController`、`tool/strings_to_arb.dart` 迁移工具 | 读各 `*_strings.dart` |

波次 3 起按用户指示「只编码、不构建不测试」：代理只跑 analyzer 做静态检查，测试以文件形式落盘，留待后续统一执行。

每一波结束由编排者执行：`dart pub get`、`flutter analyze` 全包、`dart run tool/check_complexity.dart`、`dart run tool/import_guard.dart`、`flutter test` 全包，然后提交推送到 `master`（仓库默认分支）。

## 变更记录

- **2026-09-30 v0.1** 初稿。代码事实来自对 toxee 主干（`5a1cebe`）与 tim2tox 子模块 pin `9d4245a` 的勘查（子模块在本容器未初始化，tim2tox 文件通过其 GitHub raw 内容读取）。**codex 评审未执行**：本容器没有 codex 可执行文件，按工作约定显式跳过并记欠账。
- **2026-09-30 v0.2** 应用独立 reviewer 代理的 15 条发现（替代 codex 的自校，codex 评审仍欠）。阻塞级两条：`cloudCustomData` 不上线路、群消息不接受该参数 → 重写 §2.3/§5.2 为「v1 纯文本 + v2 上游消息附注」两层设计。主要级：`flutter_pcm_sound` 仅三端 → 侧音首选 `flutter_soloud`；headless 有两处硬走腾讯绑定且无现成测试 → 决策改为「B 变体为基线」并自建 headless 测试；toxee 可搬运层缩减为约 1.1k 行；Platform 自定义消息实为 `__custom__:` 文本、包 ID 仅「已提交」注册；自定义包无分片、载荷 ≤ 1.2 KB；解码阈值改为中点值 + 两簇 dit 估计 + Farnsworth 自适应；GPL-3.0 与 App Store 冲突升级为拍板项并从验收门移除；`morsecq_chat` 收纳账号/启动层、增加 learn 构建目标、M0 拆为 M0a/M0b、补人力日换算。次要级：`build.sh` 可出共享库、`--no-toxav` 已存在、iOS 后台窗口因无 `voip` 模式更短、实时键控大概率需要 lossy 接口、`loadHistory` 命名、构造函数实际所需接口、`tencent_cloud_chat_sdk: any` 未 pin、`morsecq_chat` 测试需 Flutter binding。
- **2026-09-30 v0.3** 定名 morsecq（仓库 `agentx-icu/morsecq`）；产品决定「训练也需要身份」→ 去掉 learn 构建目标，M1 改为「身份 + 训练」，训练进度按身份持久化；新增 §11 多代理并行开发编排。文档从 toxee 仓库迁至本仓库。本会话按用户指示不做 codex 审核。
- **2026-09-30 v0.3.1** 波次 2 chat 代理实现结论回写：§3.1 第 8 条需补充——Tim2Tox 的离线群邀请重放走 `TIMGroupManager.inviteUserToGroup`，它要求 `TIMManager.initSDK`（会装上第二条入站路径），morsecq 不调用；改为在 `morsecq_chat` 自己的 `ConversationMetaStore` 维护离线邀请队列，好友在线时直接调 `DartInviteUserToGroup`。另：`tim2tox_dart` 包级依赖的 `tencent_cloud_chat_common` 以空 stub（`third_party/stubs/`）满足 pub，不引入 UIKit 组件；Tim2Tox 轮询路径无法区分 `failed` 与 `sent`（`MessageStatus.failed` 目前不会出现）→ 列入 D 线；`flutter_secure_storage` 需 `^11`（9.x 的 `win32 ^5` 与 `share_plus` 冲突）。
- **2026-09-30 v0.3.2** 集成期决策：① `BackendFactory` 增加异步 `prepare()`，`main()` 先 await 真实后端；原生库缺失或 Tox 节点启动失败时自动回落到内存假后端并在「关于」显示后端标签。② 外壳改为五个目的地（Learn / Chat / Groups / Reference / Me），翻译器从手册顶栏进入并共享播放设置。③ 通知：Windows 由 `flutter_local_notifications` 22.x 原生 toast 覆盖，无需应用内兜底；iOS 后台模式只声明 `audio`（toxee 实际声明的是 `audio`+`fetch`，非本文 §5.6 所写的 `voip`，已更正认知）。④ 原生构建默认关闭 sqlite（`--with-sqlite` 可恢复 toxee 桌面行为），macOS 以裸 `libtim2tox_ffi.dylib` 放入 `Contents/Frameworks`。⑤ 应用级偏好（语言、窗口位置）存 `<application support>/settings.json`，按身份的数据（训练进度）存 `IdentityService.dataDirectory()`。
- **2026-09-30 v0.3.3** 波次 2/3 全部集成完毕并推送 `master`。新增 `TrainingControllerHost`：每个身份只有一个 `TrainingController`，Learn 页与 Me 页的训练设置路由共用同一实例（避免两处写同一 `progress.json`）；`LearnScope` 只 dispose 自己创建的控制器。参考手册的 SoLoud 播放器改为首次播放时懒创建（外壳 `IndexedStack` 里构建时不再触碰音频引擎）。CI 新增 `strings_to_arb --check`。全仓 analyzer、复杂度、import guard、ARB 同步检查均通过；按用户指示本轮未执行测试与构建（测试文件已落盘：core 71、trainer 91、io 55、chat 33、chat_api 36、app 约 300 个用例待运行）。
- **2026-09-30 v0.3.4** 仅文档：按与 toxee 共用的双语惯例（`X.md` + `X.zh-CN.md`）新增英文译本 `2026-09-30-morsecq-plan.md`（链接默认指向的文件），两文件第一行加语言链接。本文为原稿，两版不一致时以中文为准。规划内容本身无改动。
- **2026-09-30 v0.3.5** UI 多语言按 toxee 方案完成：gen-l10n + 每语言一个 ARB（`S` 类）、系统语言解析带脚本/地区判断且以 ARB 集合为数据源、语言目录表驱动选择列表、无 `BuildContext` 代码用 `currentS()`/`StringsResolver`；全部界面（含通知、托盘）已迁到 `S`，`*_strings.dart` 常量文件全部删除；参考手册内容（Q 简语、CW 缩写、口诀）以按语言字段的数据表承载。文档双语化（英文默认 + zh-CN），新增 `doc/i18n/ADDING_A_LANGUAGE`。后续新增语言 = 新增 ARB（+ 可选目录条目、plist 声明）。
- **2026-09-30 v0.3.6** 首次全量测试（第二个会话，编排者 + 按目录归属拆分的 7 个 agent）。基线：7 个包/应用共 739 个测试，32 个红（`morsecq_chat` 1、应用 31）；修完全绿，门禁不变。测试暴露并在根因处修掉的产品 bug：① `Tim2ToxChatService` 的过期 session 竞态——解绑后仍在飞行的刷新把 `_bindSession(null)` 刚清空的列表重新填回（friends/groups 各部分与 tick 在每个 await 之后加 `_isCurrent` 守卫）；② 围绕 `await StreamSubscription.cancel()` 的销毁顺序：它返回的根 zone future 在 `flutter_test` 的 FakeAsync 里永不恢复，其后的代码（`ConnectionBannerPolicy` 取消定时器、`TrainingControllerHost` 释放控制器、`ListenController` 释放麦克风）在 widget 测试中根本不执行、生产环境也会被推迟——现在定时器与同步销毁都放在第一个 await 之前，`AppServices.dispose()` 并行启动所有子对象的销毁；③ `ListenController.stop()` 可重入（框架连续投递 `hidden`、`paused`，此前会让麦克风源停两次）；④ `niceAxis` 的边界与刻度用同一种吸附（二进制漂移 `3 × 0.2`）；⑤ `StatsScreen._reload` 的箭头式 `setState` 返回 Future 触发调试断言（手机下拉刷新同样会撞）；⑥ `strings_to_arb.findKeyCollision` 对同一 key 在两个文件里重复声明不报错。测试侧修正：finder 限定到图表 painter / `ReferenceEntryTile`，生命周期按 `inactive → hidden → paused` 走，`learn_home` 改为编码 v0.3.3 的共享控制器规则，`me_page` 断言真实的训练设置页，`strings_to_arb_test` 解析 SDK 的 `dart` 而非 `Platform.resolvedExecutable`（`flutter test` 下是 `flutter_tester`，即 4 × 30 s 超时的来源），纯 Dart 测试里给 `DateFormat` 加 `initializeDateFormatting`。CI：GitHub Actions 首轮全红——`analyze.yml` 只红在 Tests 步骤（同一批失败）；`native.yml` 8 个目标过 4 个，macOS 死在 libsodium configure，原因是 `build_macos()` 导出了裸的 `xcrun -f clang` 却没给 `SDKROOT`/`-isysroot`（已修，并加了 configure 失败诊断），linux-aarch64 / windows-arm64 失败是 Flutter 3.41.9 没有这两个系统的 arm64 包（这两行改为经 `setup-dart` 只装 Dart 3.11.5，脚本把其头文件摆成 `FLUTTER_ROOT` 形状的 shim）。首次在真实 Mac 上构建出 macOS arm64 `libtim2tox_ffi.dylib`（4.1 MB，静态 libsodium，只链接 libc++/libSystem）。§3.3 架构图与 §10 改为 `apps/morsecq`。codex 审核（`codex-mac`，gpt-6-sol xhigh）覆盖全部 diff：第一轮 NEEDS-CHANGES（测试修复部分 5 major + 1 minor，native CI 部分 1 major + 4 minor），全部采纳——bool `_polling` 改为按 session 的进行中标记（此前重绑后的首次刷新会被饿死）、聊天变更操作每个 await 之后加 `_ensureCurrent`、排队邀请冲刷逐次校验 session、竞态回归测试、`NotificationCenter`/`AppServices`/fake backend 在第一个 await 之前释放全部资源、`TrainingControllerHost` 加代际令牌（dispose 或切换身份后才完成的加载会销毁控制器而非缓存，+5 测试）、native 缓存 key 带上 Flutter/Dart 版本、`MORSECQ_DART_SDK_DIR` 覆盖优先、同时校验 `.h`+`.c` 头文件、Apple sysroot 空白检查。第二轮又发现 `forget()` 的三次写入之间仍无守卫、`setPinned`/`setDraft` 在 await 之后重新发布（已修：`_forgetMeta` 在每次写入之间校验、捕获发起时的 session；回归测试把 pinned 写入停在半路），以及一条靠定时的竞态测试（改为等待 hold 信号）。最终 750 个测试全绿；第三轮 APPROVE（`morsecq_chat` 中不再有 await 之后未经守卫的元数据写入或发布）。 推送后的 CI：`analyze.yml` 首次全绿；`native.yml` 8/8 原生目标全绿，Windows 与 macOS 的 `flutter build` 通过，Linux 应用构建因缺 `libsecret-1-dev` 失败（已连同 `libayatana-appindicator3-dev` 补进作业与文档），再倒在 `flutter_soloud` 的 `alsa/asoundlib.h`（`libasound2-dev`）。
- **2026-09-30 v0.3.7** 原生 smoke 测试真实跑通（macOS arm64，单进程，接入 DHT），并在根因处修了两个缺陷。① B 变体丢掉了所有自定义原生回调：补丁版 SDK 的 `NativeLibraryManager.customCallbackHandler` 只由 `Tim2ToxSdkPlatform` 设置，于是 `friendAddResult` 永远到不了 `FfiChatService.addFriend` 的 completer，每次好友请求都要等 30 s 后报"timed out waiting for native result"，成功失败皆然。新增 `engine/native_callbacks.dart`（`NativeCustomCallbacks`）接管该钩子：`friendAddResult` → completer，`DartNotifyGroup*` 系列 → 当前 session（与 toxee 一样按 session 归属过滤），`groupChatIdStored`/`groupTypeStored` → `syncGroupIdentitiesFromNative()`，`clearHistoryMessage` 忽略；`Tim2ToxEngine.start` 安装、`stop` 解绑、`dispose` 卸载。§3.1 第 8 条"三个被静默丢弃的回调"的理解并不完整——丢的是全部自定义回调，包括 `friendAddResult`。② 测试用的对端地址 `kPeerToxId` 校验和错误（`tox_friend_add` 以 `TOX_ERR_FRIEND_ADD_BAD_CHECKSUM` 拒绝），fake FFI 从不校验所以一直没暴露。另外：`morsecq_chat` 里剩余的串行 await 销毁链（身份服务、聊天服务及其各部分、引擎 `stop`/`dispose`）与 `FakeIdentityService` 现在都先同步释放再 await（HANDOVER §7.6）。smoke 测试约 10 s 通过；45 个单元测试、410 个应用测试、门禁全绿。 iOS：最低版本提到 14.0（`file_picker_darwin` 2.1.2 要求），`tool/build_ios_ffi.sh` 在 Mac 上构建出设备 + 模拟器 XCFramework，iOS 与 macOS 的 `pod install` 均成功（两份 `Podfile.lock` 已提交）。发现：vendored 的 `tencent_cloud_chat_sdk` podspec 依赖 `TXIMSDK_Plus_iOS_XCFramework` / `TXIMSDK_Plus_Mac`，且插件的 Swift 源码 import 它，因此 Apple 包会链接腾讯原生 IM SDK，尽管 morsecq 从不调用它（toxee 同样如此）；去掉它需要在 tim2tox 补丁系列里改插件的 Swift 侧，已记入 HANDOVER §7。 应用图标：`tool/gen_app_icons.dart`（与托盘图标同一套绘制）写出全部平台图标集与 1024 商店母图。 D 线：「消息注解上线」RFC 已起草（双语）于 `doc/rfcs/2026-09-30-tim2tox-message-annotation.md`，尚未提交上游。 中文电码（P4，§9 第 5 项）：`morse_core` 新增 `ChineseTelegraphCode`（编码 / 解码 / 转写，大陆 1983 与台湾两套电码本，表由 `tool/gen_telegraph_table.dart` 从 Unicode Unihan 18.0 的 `kMainlandTelegraph` / `kTaiwanTelegraph` 生成，Unicode 许可证），翻译器把汉字按四位数字组键发并可切换电码本；手册页与聊天侧收码解码仍待做。
