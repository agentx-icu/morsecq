[English](./APP_STORE.md)

# App Store 构建

配置应用的 Apple Team、分发证书和描述文件及真实 `MORSECQ_APPLE_TEAM_ID`，运行 `bash tool/build_ios_store.sh`。

通过[截图流程](../../tool/screenshots/README.zh-CN.md)提供当前 iPhone/iPad 截图，填写公开的隐私与支持网址及商店信息。产品介绍说明离线学习、本地进度及用户主动启动的麦克风解码。在设备上检查学习素材文件选择和持久化。应用声明不使用非豁免加密（`ITSAppUsesNonExemptEncryption = false`；MorseCQ 无联网、无 libsodium）。

iPhone 支持竖屏和两个横屏方向；iPad 支持全部四个方向且未设置 `UIRequiresFullScreen`，因此 Split View、Slide Over 和 Stage Manager 都适用，最窄到 320 pt。学习素材导出通过 `sharePositionOrigin` 把分享弹出框锚定到被点击的控件（`test/platform/share_origin_guard_test.dart` 会让没有锚点的分享调用失败）。

先看[渠道矩阵与所有者门禁](STORE_READINESS.zh-CN.md)，再选择 App Store、Developer ID、Play 或桌面商店。iOS 脚本检查实际导出 IPA 的身份/profile 并生成产物报告，不上传。

## Android：SDK 级别与 16 KB 页

`compileSdk` 36、`minSdk` 24 和 `targetSdk` 36 在 `apps/morsecq/android/app/build.gradle.kts` 中显式固定（不从 Flutter Gradle 插件继承；`test/platform/mobile_platform_config_test.dart` 检查它们）。Google Play 自 2026-08-31 起要求新应用和更新使用 API 36；target/compile 与支持的最低系统分别审核，并更新有日期的政策记录。

MorseCQ 不自带原生库，所以 Google Play 的 16 KB 页要求（面向 Android 15+ 应用的 64 位库）只涉及工具链产出的库：`libflutter.so`、`libapp.so` 以及用 Flutter 的 NDK（Flutter 3.41.9 为 28.2，默认对齐；不要把 `ndkVersion` 固定到 r28 以下）编译的插件代码。上传 Play 前检查最终 APK：`zipalign -c -P 16 -v 4 app-release.apk`，并对每个 `lib/arm64-v8a/*.so` 和 `lib/x86_64/*.so` 运行 `llvm-readelf -lW`（每个 `LOAD` 的 `Align` 至少为 `0x4000`）。

预测性返回已启用（`android:enableOnBackInvokedCallback="true"`）；Android 16 对 targetSdk 36 本来就默认启用，该属性让 Android 13–15 行为一致。`DrillLeaveGuard` 通过 `PopScope` 处理该手势。

详见[构建指南](../operations/BUILD_AND_DEPLOY.zh-CN.md)和[验证记录](../VALIDATION.zh-CN.md)。

## 提交答案与兼容平台（2026-10-22）

以下为根据当前源码准备的草稿，供所有者在商店后台逐项核对填写，不代表商店已接受提交。

| 问题 | 当前产品答案 |
| --- | --- |
| App Store 隐私 / Play 数据安全 | 开发者不收集、分享或跟踪数据；无广告与分析 SDK。学习、录音与脱敏诊断留在设备上。主动导出和系统备份是用户/系统控制的路径。 |
| 麦克风 | 可选的实时电码解码和本地录音，不上传音频。 |
| 账号 / 购买 / 用户内容服务 | 均无，因此不涉及账号删除或服务器内容管理流程。 |
| 年龄分级内容项 | 无暴力、色情、赌博、酒精/药物、广告、不受限的应用内浏览或用户间通信。按当前问卷填写，不能由本表推定商店最终年龄标签。 |
| Apple silicon Mac 上的 iOS 兼容版 | 不提供；发布单独测试的原生 macOS 应用。所有者需在 App Store Connect 取消兼容版可用性。 |
| Vision Pro 上的 iOS 兼容版 / 原生 visionOS | 插件、输入与媒体验证完成前不提供。所有者需在 App Store Connect 取消兼容版可用性。 |

Apple 的[隐私定义](https://developer.apple.com/app-store/app-privacy-details/)将仅在设备上处理的数据排除在收集之外。
[Mac 兼容版](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-of-iphone-and-ipad-apps-on-macs-with-apple-silicon/)与
[Vision Pro 兼容版](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-of-iphone-and-ipad-apps-on-apple-vision-pro/)可用性需要单独设置。
API 36 截止日期已于 2026-10-22 对照 [Play 当前要求](https://support.google.com/googleplay/android-developer/answer/11926878)核对。
后台实际状态与签名分发验证仍需所有者执行。

最终 APK/AAB 现由 `tool/ci/release_preflight.py` 检查全部 native 模块、可选硬件、合并权限及 bundle 投递对齐。tag 签名检查需真实 upload 指纹，Play 使用另一个 app-signing 分发密钥；16 KB 实际运行与后台验证仍待完成。

## 发布预算

初始工程限制，发布时按架构检查：Android APK/AAB 各 ≤100 MiB；iOS IPA ≤150 MiB；macOS 应用与 PKG 各 ≤100 MiB；Windows MSI ≤150 MiB、安装后应用 ≤250 MiB；Linux DEB/RPM 各 ≤100 MiB、安装后目录 ≤250 MiB。
发布设备矩阵上的冷启动至可用 Learn ≤5 秒、热重开 ≤2 秒是目标，尚未测量。
本机 macOS 27.0.1 arm64 上 universal release 构建为 57.1 MB；其余包体与启动延迟待测。
详见[跨平台审计](../testing/CROSS_PLATFORM_AUDIT.zh-CN.md)。
