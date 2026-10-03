# 移动设备特性评审

**目标：** 找出手机与平板的特性（系统生命周期、音频会话、触控与屏幕尺寸、平台政策）在 iOS/Android 上让 MorseCQ 出错的地方，并在根因处修掉真实缺陷。

**方法：** 按文件归属互不重叠拆成四路并行评审（生命周期/通知、音频/触觉/麦克风、触控/布局、平台配置/存储），再由第二波处理跨区域的修复。每个修复都先用失败的单元或 widget 测试复现（模拟手机尺寸、字体缩放、软键盘 inset 与生命周期状态）。全部未在真机上运行，见「仍欠的真机验证」。

## 已修复

### 生命周期与通知

| 发现 | 移动端场景 | 修复 |
|---|---|---|
| 冷启动点通知丢失 | 点击在 `NotificationCenter.start()` 期间触发，早于启动门（密码解锁）让 `AppShell` 订阅 | 保留最近一次未被接收的点击，交给第一个订阅者 |
| 后台弹权限、反复弹 | Android 13+ 在第一次后台通知时从已停止的 Activity 申请 `POST_NOTIFICATIONS`；拒绝未缓存 | 先静默检查；只在前台、每次会话至多弹一次；并发通知共享同一个待定请求 |
| iOS 进入后台约 5 秒即冻结，落盘被截断 | 没有 `beginBackgroundTask` | 原生通道 `icu.agentx.morsecq/background_task` 在后台到恢复/到期之间持有任务 |
| 打开的会话仍弹通知；后台时被标为已读 | 无人调用 `setActiveConversation`；标记已读不看前后台 | `ConversationPresence` 按路由与页签可见性设置/清除活动会话；标记已读等到前台（iOS `inactive` 算前台） |
| 点通知重复推入同一页面 | 点击当前已打开会话的通知 | `_openConversation` 跳过重复推入；好友请求 / 群邀请通知打开 Chat / Groups 页签 |

### 音频、触觉、麦克风

| 发现 | 移动端场景 | 修复 |
|---|---|---|
| 静音开关打开时侧音无声，锁屏即静音 | flutter_soloud 让 iOS 会话停在 SoloAmbient | `morse_io` 在启动引擎前设置 `playback` + `mixWithOthers` 并激活（`audio_session`） |
| 来电 / Siri 打断后侧音不再响 | `SidetoneSink.on()` 只改循环 voice 的音量，不会重启已停的设备 | 每次按键都恢复设备并替换丢失的 voice；输出被拒时下次按键重试 |
| 应用在后台被一直保活 | `playback` 加上 `UIBackgroundModes=audio`，静音循环 voice 让 iOS 无法挂起 | Android/iOS 进入后台时侧音停掉 voice；移除 `audio` 后台模式 |
| 用过 Listen 后蓝牙耳机卡在通话音质 | `record` 把会话留在 `playAndRecord` | `RecordPcmSource.stop()` 恢复播放会话；新的采集等待恢复完成 |
| 自动锁屏中断 Listen / 练习 | 没有屏幕常亮 | Listen、抄收练习、发报练习只在进行中保持常亮（`wakelock_plus`） |

### 触控与布局

| 发现 | 移动端场景 | 修复 |
|---|---|---|
| 旋转屏幕重置所有页签 | 600 px 断点处页面区在 `Scaffold.body` 与侧栏 `Row` 之间移动 | 用 `GlobalKey` 跨移动保留页面状态 |
| iPad 横屏转竖屏丢失打开的会话 | Chat 与 Groups 的双栏折叠 | 选中的会话在帧后以全屏路由重新打开（草稿经共享写入器保留） |
| 键控输入区比横屏手机还高 | 667×375 溢出，2 倍字体溢出 85–148 px | 高度不足 500 px 时用紧凑键（88 dp）；输入区最多占 75 % 并可滚动 |
| 翻译器溢出 / 输入框被软键盘挡住 | 竖屏弹键盘、横屏、2 倍字体 | `ReferenceMinHeight` 给出随字体缩放的最小高度并可滚动 |
| 320 px、2 倍字体下溢出 | 导航侧栏、会话标题、剩余字节、发报练习顶栏、身份卡 | 侧栏可滚动、`Flexible` + 省略号、开关改图标并带语义标签 |
| 练习中途退出静默丢失本次进度 | Android 返回 / 预测性返回 / iOS 边缘右滑 | `DrillLeaveGuard`（`PopScope`）有进度时先确认；iOS 上受保护期间边缘右滑被禁用（Flutter 行为），由返回按钮询问 |

触控键控本身无需改动：双桨与直键使用原始 `Listener`（无手势竞技场、无点击延迟），能处理双指捏键、系统手势导致的指针取消以及外层滚动视图；新增测试固定了这些行为。

### 平台配置与存储

| 发现 | 移动端场景 | 修复 |
|---|---|---|
| Tox 身份被 Android 云备份 / 设备迁移复制 | 默认 `allowBackup` | `allowBackup="false"`、`fullBackupContent="false"`、`data_extraction_rules.xml`（同 toxee） |
| Tox 身份进入 iCloud/iTunes 备份 | Application Support 默认被备份 | 每次建目录以及恢复前，经通道把 `<appSupport>/morsecq` 标为 `isExcludedFromBackup` |
| Play 过滤掉无自动对焦相机或无麦克风的设备 | CAMERA / RECORD_AUDIO 隐含必需特性 | `uses-feature … required="false"` |
| 权限弹窗只有英文 | Info.plist 文案未本地化 | `InfoPlist.xcstrings` 覆盖全部十种语言 |
| `UIBackgroundModes=audio` 无正当理由（App Review 2.5.4） | 后台不播放任何声音 | 移除该键，不声明任何后台模式 |
| iPad 分享弹窗与按钮脱节 | 从向导和 Me 页导出备份 | 用被点击控件计算 `sharePositionOrigin` |
| 拒绝相机权限显示英文错误码 | mobile_scanner 默认错误视图 | 本地化 `errorBuilder`（`chatScanQrPermissionDenied` / `chatScanQrCameraUnavailable`） |

## 未修复（及原因）

- **读屏用户无法在屏幕键上键控：** 摩尔斯键控没有有意义的语义点击等价物。
- **iPad/Android 接硬件键盘时不显示键位说明：** 外观问题，键盘键控可用。
- **麦克风/相机被永久拒绝时的「打开设置」按钮：** 需要新依赖（`permission_handler`）；提示文案已指向系统设置。
- **引擎运行中恢复前台时不重新引导 Tox：** toxcore 解冻后会重新 ping 已知 DHT 节点；需真机证据再改。
- **运行中带密码的身份在磁盘上为明文：** 属于 tim2tox 原生 savedata 加密（上游）。
- **`ITSAppUsesNonExemptEncryption`：** 出口合规决定，由所有者决定。
- **蓝牙 A2DP 侧音延迟（150–250 ms）：** 传输本身固有。

## 仍欠的真机验证

iPhone：静音开关打开时的侧音；来电、Siri、其他应用播放音乐之后的侧音；后台挂起；后台落盘完成；Listen 与练习保持常亮；有进度时边缘右滑被禁用、返回按钮询问。Android 13+：通知权限只在前台申请；练习中的预测性返回；数据提取规则（`adb shell bmgr`）。iPad：分享弹窗锚点；打开会话时旋转。

## 变更记录

- **2026-10-03** — 首次评审与修复（四个评审 agent、三个修复 agent；analyzer 零问题，导入守卫与复杂度门禁通过，全部包与应用测试通过）。
