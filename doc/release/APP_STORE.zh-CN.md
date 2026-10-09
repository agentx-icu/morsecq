[English](./APP_STORE.md)

# App Store 构建

## 账号、签名与上传

MorseCQ 在两个平台的商店标识都是 `icu.agentx.morsecq`。商店权限应只授予发布负责人或同等的最小权限；不要把证书、描述文件、keystore 或密码提交到仓库。

### iOS / TestFlight

1. Apple Developer 团队需要 `icu.agentx.morsecq` App ID、iOS Distribution 证书和 App Store 描述文件；同一 Team ID 在 App Store Connect 中还需要有可上传构建的 App Manager 或 Developer 角色。
2. 在 Mac 上用该账号登录 Xcode，打开 `apps/morsecq/ios/Runner.xcworkspace`，在 Runner target 选择 Team，并核对 Bundle ID 与签名配置。
3. 运行 `bash tool/build_ios_store.sh`。这是明确的商店签名路径：固定 `--export-method app-store`、拒绝 `--no-codesign` 和其他导出方式、验证归档签名，并在 `apps/morsecq/build/ios/ipa/` 生成一个 IPA。
4. 用 Xcode Organizer 或 Apple Transporter 上传该 IPA，再在 App Store Connect 完成 TestFlight 处理和商店资料。GitHub 工作流的 `ios-unsigned.ipa` 仅用于侧载/测试，不能上传 TestFlight。

### Android / Google Play

1. Google Play Console Owner 或 Release Manager 用包名 `icu.agentx.morsecq` 创建应用，启用 Play App Signing，并给发布人员上传和发布轨道权限。
2. 在仓库 Settings → Secrets and variables → Actions 中配置四个 Actions secret：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`。用 `base64 -w 0 morsecq-upload.jks` 生成不带换行的单行值填入 `ANDROID_KEYSTORE_BASE64`。
3. `vX.Y.Z` 标签构建必须提供四个 secret，缺失或不完整会失败，不会静默使用 debug key。分支/PR 测试构建只有在显式设置 `MORSECQ_ALLOW_DEBUG_SIGNING=1` 时才可使用 debug 签名；本地商店构建使用（已忽略的）`android/key.properties`。

通过[截图流程](../../tool/screenshots/README.zh-CN.md)提供当前 iPhone/iPad 截图，填写公开的隐私与支持网址及商店信息。产品介绍说明离线学习、本地进度及用户主动启动的麦克风解码。在设备上检查学习素材文件选择和持久化。应用声明不使用非豁免加密（`ITSAppUsesNonExemptEncryption = false`；MorseCQ 无联网、无 libsodium）。

iPhone 支持竖屏和两个横屏方向；iPad 支持全部四个方向且未设置 `UIRequiresFullScreen`，因此 Split View、Slide Over 和 Stage Manager 都适用，最窄到 320 pt。学习素材导出通过 `sharePositionOrigin` 把分享弹出框锚定到被点击的控件（`test/platform/share_origin_guard_test.dart` 会让没有锚点的分享调用失败）。

## Android：SDK 级别与 16 KB 页

`compileSdk` 36、`minSdk` 24 和 `targetSdk` 36 在 `apps/morsecq/android/app/build.gradle.kts` 中显式固定（不从 Flutter Gradle 插件继承；`test/platform/mobile_platform_config_test.dart` 检查它们）。Google Play 自 2026-08-31 起要求新应用和更新使用 API 36；三个级别要一起提高并同步更新这一行。

MorseCQ 不自带原生库，所以 Google Play 的 16 KB 页要求（面向 Android 15+ 应用的 64 位库）只涉及工具链产出的库：`libflutter.so`、`libapp.so` 以及用 Flutter 的 NDK（Flutter 3.41.9 为 28.2，默认对齐；不要把 `ndkVersion` 固定到 r28 以下）编译的插件代码。上传 Play 前检查最终 APK：`zipalign -c -P 16 -v 4 app-release.apk`，并对每个 `lib/arm64-v8a/*.so` 和 `lib/x86_64/*.so` 运行 `llvm-readelf -lW`（每个 `LOAD` 的 `Align` 至少为 `0x4000`）。

预测性返回已启用（`android:enableOnBackInvokedCallback="true"`）；Android 16 对 targetSdk 36 本来就默认启用，该属性让 Android 13–15 行为一致。`DrillLeaveGuard` 通过 `PopScope` 处理该手势。

当前应用版本是 `1.0.0+1`，唯一有效的发布标签是 `v1.0.0`；`v0.2.0` 等旧标签会在打包前被拒绝。

详见[构建指南](../operations/BUILD_AND_DEPLOY.zh-CN.md)和[验证记录](../VALIDATION.zh-CN.md)。
