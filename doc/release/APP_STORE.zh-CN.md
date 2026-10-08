[English](./APP_STORE.md)

# App Store 构建

配置应用的 Apple Team、分发证书和描述文件，运行 `bash tool/build_ios_store.sh`。

通过[截图流程](../../tool/screenshots/README.zh-CN.md)提供当前 iPhone/iPad 截图，填写公开的隐私与支持网址及商店信息。产品介绍说明离线学习、本地进度及用户主动启动的麦克风解码。在设备上检查学习素材文件选择和持久化。应用声明不使用非豁免加密（`ITSAppUsesNonExemptEncryption = false`；MorseCQ 无联网、无 libsodium）。

iPhone 支持竖屏和两个横屏方向；iPad 支持全部四个方向且未设置 `UIRequiresFullScreen`，因此 Split View、Slide Over 和 Stage Manager 都适用，最窄到 320 pt。学习素材导出通过 `sharePositionOrigin` 把分享弹出框锚定到被点击的控件（`test/platform/share_origin_guard_test.dart` 会让没有锚点的分享调用失败）。

## Android：SDK 级别与 16 KB 页

`compileSdk` 36、`minSdk` 24 和 `targetSdk` 36 在 `apps/morsecq/android/app/build.gradle.kts` 中显式固定（不从 Flutter Gradle 插件继承；`test/platform/mobile_platform_config_test.dart` 检查它们）。Google Play 自 2026-08-31 起要求新应用和更新使用 API 36；三个级别要一起提高并同步更新这一行。

MorseCQ 不自带原生库，所以 Google Play 的 16 KB 页要求（面向 Android 15+ 应用的 64 位库）只涉及工具链产出的库：`libflutter.so`、`libapp.so` 以及用 Flutter 的 NDK（Flutter 3.41.9 为 28.2，默认对齐；不要把 `ndkVersion` 固定到 r28 以下）编译的插件代码。上传 Play 前检查最终 APK：`zipalign -c -P 16 -v 4 app-release.apk`，并对每个 `lib/arm64-v8a/*.so` 和 `lib/x86_64/*.so` 运行 `llvm-readelf -lW`（每个 `LOAD` 的 `Align` 至少为 `0x4000`）。

预测性返回已启用（`android:enableOnBackInvokedCallback="true"`）；Android 16 对 targetSdk 36 本来就默认启用，该属性让 Android 13–15 行为一致。`DrillLeaveGuard` 通过 `PopScope` 处理该手势。

详见[构建指南](../operations/BUILD_AND_DEPLOY.zh-CN.md)和[验证记录](../VALIDATION.zh-CN.md)。
