[English](./README.md)

# 通知、角标与后台处理

`lib/notifications/` 为聊天事件发送操作系统通知，并让未读角标与会话列表保持同步；
`lib/lifecycle/` 跟踪前台/后台并驱动移动端后台策略。两者都只通过 `morsecq_chat_api` 契约与后端对话，
只通过两个接口（`LocalNotificationsApi`、`BadgeApi`）与插件对话，`testing/` 下有记录式假实现。

方案引用：`doc/plans/2026-09-30-morsecq-plan.zh-CN.md` §5.6（移动端后台）和 §7
（风险：没有 `voip` 模式，iOS 窗口比 toxee 更短）。

## 插件

| 包 | 版本 | 为什么选它 |
|---|---|---|
| `flutter_local_notifications` | `^22.3.1`（Flutter ≥ 3.38.1，Dart ≥ 3.10） | **全部五个**目标平台都有官方背书的联合实现：Android/iOS/macOS 在主包内，`flutter_local_notifications_linux` 8.0.1（D-Bus），`flutter_local_notifications_windows` 3.1.1（通过 FFI 的 WinRT toast）。toxee 仍固定在 17.2.4，早于 Windows 包出现；选 22.x 是为了让 Windows 得到真正的系统 toast 而不是应用内回退。 |
| `app_badge_plus` | `^1.3.5`（Flutter ≥ 3.32） | Android / iOS / macOS 角标。没有 Linux 或 Windows 实现；`AppBadgePlusApi.isSupported()` 在那里返回 false，不触碰任何 channel。 |

依据：2026-09-30 读取的 pub.dev 包元数据（`flutter.plugin.platforms` 列出
`windows: {default_package: flutter_local_notifications_windows}` 和
`linux: {default_package: flutter_local_notifications_linux}`；`app_badge_plus` 只列出
android/ios/macos）。插件 README 在 pub 缓存中。

## 各平台行为

| | Android | iOS | macOS | Windows | Linux |
|---|---|---|---|---|---|
| 系统通知后端 | NotificationCompat，3 个频道（`morsecq_messages`、`morsecq_friend_requests`、`morsecq_group_invites`） | UNUserNotificationCenter | UNUserNotificationCenter | WinRT toast（`flutter_local_notifications_windows`，AUMID `icu.agentx.morsecq`，固定 CLSID） | 通过 D-Bus 的 `org.freedesktop.Notifications` |
| 运行时权限 | 13+ 上的 `POST_NOTIFICATIONS`（`ensurePermission()`，首次发送前懒请求） | 提醒 + 角标 + 声音授权（懒请求，同一调用） | 与 iOS 相同 | 无 | 无 |
| App 在前台时是否显示 | 是（仅对不在屏幕上的会话） | 是——`presentBanner/List` 开启 | 是 | 是 | 是 |
| 按会话分组 | `groupKey` + `InboxStyle`（最近 5 行，"N 条新消息"摘要） | `threadIdentifier` 堆叠 | `threadIdentifier` 堆叠 | 无（每个会话一条 toast，按 id 替换） | 无（按 id 替换） |
| 点击 → `openConversationRequests` | 是，包括冷启动（`getNotificationAppLaunchDetails`） | 是，包括冷启动 | 是 | 运行中可以；**冷启动载荷仅在打包为 MSIX 时可用** | 运行中可以 |
| 打开 / 已读时取消 | 是 | 是 | 是 | **除非打包为 MSIX，否则为空操作**（插件限制，见 README） | 是 |
| 未读角标 | 取决于启动器（三星、小米/HyperOS、华为、OPPO、vivo、索尼、HTC……；原生 Pixel 只显示圆点） | 精确 | 精确（Dock） | 不支持 → 空操作 | 不支持 → 空操作 |
| 声音 | 频道默认，按偏好设置 `playSound` | 按偏好设置 `presentSound` | 相同 | 默认 toast 声音；关闭时 `WindowsNotificationAudio.silent()` | 关闭时 `suppressSound` |
| 后台预算（`AppLifecycleCoordinator`） | 60 s 提示（依 OEM 而异；Doze / 厂商省电会更早或更晚冻结） | 30 s（没有 `voip`；`audio` 仅在播放期间有效） | 无——从不挂起 | 无 | 无 |
| 恢复时重连 | 任何后台时段之后 `IdentityService.connect()` | 相同 | 相同（在 `hidden` 之后，例如最小化） | 相同 | 相同 |

连接状态从不产生系统通知。`ConnectionBannerPolicy` 暴露一个 `ValueListenable<bool>`：
连续两分钟不在线（`connecting` 也算）后置为 true，节点上线的那一刻置为 false；
shell 把它渲染为应用内横幅。

### Windows：系统 toast 与应用内回退

`flutter_local_notifications` ≥ 18 通过官方背书的 FFI 包原生支持 Windows，因此*显示*通知不需要
应用内回退。对未打包（`flutter build windows` 生成的 .exe）的 App，仍有两个限制，直接来自插件 README：

- `cancel()` / `getActiveNotifications()` 什么都不做——toast 会留在操作中心，直到用户关闭
  （打开会话不会清除它们）；
- 冷启动载荷不可用。

一旦 App 以 MSIX（`package:msix`）发布，这两个限制都会消失。在此之前的行为是"通知出现；
App 运行中点击它会打开会话"。`AppBadgePlusApi` 在 Windows 上是空操作（插件不支持任务栏覆盖角标）。

## Manifest / plist 变更

### `android/app/src/main/AndroidManifest.xml`

在 `<manifest>` 层级添加：

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

`flutter_local_notifications` ≥ 16 已经从自己的 manifest 合并了这两项；这里重复声明是为了让 App
请求的运行时权限在 App 自己的 manifest 中可见。**没有** `ScheduledNotificationReceiver` /
`ScheduledNotificationBootReceiver`（它们是为*定时*通知准备的；morsecq 只从 Tox 轮询循环发送即时通知），
也**没有** `ActionBroadcastReceiver`（没有通知操作按钮）。没有前台服务：morsecq 不附带 toxee 的
`ToxPollingService`；如果产品以后想要 Android 后台轮询，那是一个独立的原生服务加上
`FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_DATA_SYNC` 权限。

### `ios/Runner/Info.plist`

添加了 `UIBackgroundModes = [audio]`。

- **不是 `voip`**：morsecq 没有 ToxAV；没有 VoIP 功能却声明 `voip` 并不诚实，App Review 会拒绝
  （方案 §5.6/§7）。
- **`audio`**：由摩尔斯播放（消息播放、训练会话）在用户切换 App 后继续进行来证明其正当性。
  副作用：音频实际播放期间 Tox 循环会继续运行。除此之外它**不会**延长后台窗口——没有活跃的音频会话时，
  iOS 在约 30 s 后挂起 App，这正是协调器的 iOS 预算。如果在提交 App Store 之前 `morse_io` 的音频会话
  没有配置为后台播放（`AVAudioSession` 类别 `.playback`），请移除该条目，而不是发布一个未使用的模式。
- **刻意不声明 `fetch`**：`BGAppRefreshTask` 需要原生处理器和 `BGTaskSchedulerPermittedIdentifiers`；
  toxee 有，morsecq 还没有。要么两者一起添加，要么都不加。

### macOS

`UNUserNotificationCenter` 不需要 plist 或 entitlement 变更；插件会安装自己的 delegate。
通知需要签名过的 bundle（`flutter run -d macos` 的 ad-hoc 签名足以本地测试）。

## 本模块所有权之外的必要后续工作

1. **`android/app/build.gradle.kts`——核心库脱糖（core library desugaring）**
   （`flutter_local_notifications` ≥ 10 的硬性构建要求）：
   ```kotlin
   android {
       compileOptions {
           isCoreLibraryDesugaringEnabled = true
           sourceCompatibility = JavaVersion.VERSION_17
           targetCompatibility = JavaVersion.VERSION_17
       }
   }
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
   }
   ```
   AGP 已经是 8.11.1（满足插件的最低要求）。
2. **`ios/Runner/AppDelegate.swift`**——iOS 插件依赖 App delegate 转发通知中心回调
   （macOS 插件不需要）。在 `didFinishLaunchingWithOptions` 内、`super` 之前添加：
   ```swift
   UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
   ```
   没有这一行，iOS 上的点击回调和前台展示都不工作。
3. **在 `main.dart` / `AppScope` 中接线**（见下文）。
4. **偏好设置持久化**：`NotificationPrefs.toJson()` / `fromJson()` 已就绪；App 设置的所有者
   应负责加载/保存它们。

## 接线片段（编排器）

```dart
// In AppScope (once per session, after the identity is ready):
final lifecycle = AppLifecycleCoordinator(identity: identity)..attach();
final prefs = NotificationPrefs.fromJson(settings.notificationsJson);
final center = NotificationCenter(
  chat: chat,
  notifications: FlutterLocalNotificationsApi(),
  badge: AppBadgePlusApi(),
  prefs: prefs,
  isForeground: lifecycle.isForeground,
);
final banner = ConnectionBannerPolicy(identity: identity)..start();
unawaited(center.start());

// Route taps into the chat UI (ChatPage._open / GroupsPage equivalent):
final tapSub = center.openConversationRequests.listen((conversationId) {
  final c = chat.conversations.where((c) => c.id == conversationId).firstOrNull;
  if (c != null) openConversation(ConversationTarget.fromConversation(c));
});

// ConversationScreen.initState / dispose:
center.setActiveConversation(widget.target.id);   // initState
center.setActiveConversation(null);               // dispose

// Banner: ValueListenableBuilder(valueListenable: banner.offlineBannerVisible, ...)
// with NotificationStrings.offlineBanner and a Reconnect action calling
// StartupController.reconnect().

// Settings page: a "Notifications" tile calling center.ensurePermission()
// and toggles bound to prefs.enabled / showText / showPattern / sound;
// per-conversation "Mute" in the conversation menu via prefs.setMuted(id, v).

// Dispose order: tapSub.cancel(); center.dispose(); banner.dispose();
// lifecycle.dispose(); then the services.
```

## 需要真机验证的内容

- Android 13+：权限对话框只出现一次；拒绝后不再发送；收件箱分组正确渲染；三星 / 小米启动器上的
  角标计数；Pixel 上只有圆点。Android 8–12：频道出现在设置中，没有对话框。
- iOS：授权提示；前台对未打开的会话显示横幅；锁屏上的线程堆叠；角标；点击冷启动通知打开会话
  （需要上面的 AppDelegate 那一行）；无播放时进入后台约 30 s 后 App 被挂起、`mayBeDisconnected`
  提示以及恢复时重连；活跃的摩尔斯播放在 `audio` 模式下是否能维持套接字存活。
- macOS：授权提示（签名 bundle）、Dock 角标、最小化时 `hidden` → 最小化期间的通知。
- Windows：未打包构建能出现 toast；运行中点击打开会话；确认上述 MSIX 限制；声音开关。
- Linux（GNOME / KDE）：D-Bus 通知、`Open` 操作、声音抑制。

## 测试（文件已编写，本轮未运行）

`test/notifications/`：`notification_center_test.dart`（后台发送文本 + 点划模式；活跃会话打开 → 不发送；
已静音 → 不发送；角标跟随未读；好友请求 / 群组邀请；点击；权限；收件箱分组；Linux/不支持平台的门控），
`app_lifecycle_coordinator_test.dart`（假时钟预算、恢复重连、桌面端无倒计时、钩子），
`connection_banner_policy_test.dart`、`notification_payload_test.dart`、
`notification_prefs_test.dart`。
