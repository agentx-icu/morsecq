# 构建与发布

MorseCQ 的所有平台构建均为离线学习版，无子模块、Tim2Tox 或 Tencent SDK 引导。固定工具链为 Flutter 3.41.9 / Dart 3.11.5。

在根目录执行 `dart pub get --enforce-lockfile`，然后使用 `./build_all.sh --platform <目标> --mode release`。目标为 android、ios、macos、linux、windows。每个桌面平台在对应主机构建；iOS 在安装 Xcode 的 Mac 上构建。Android 需要 Java 17 与 Android SDK；Linux 需要 GTK、ALSA 与 Ayatana appindicator 开发包；Windows 需要 Visual Studio C++ 和 WiX v3 安装包工具。

`.github/workflows/builds.yml` 在 PR、main/master 更新、v* 标签及手动执行时运行。分析、复杂度、分层、本地化、截图导入保护及所有包/应用测试是构建前置门禁。所有五个平台均必须成功，标签才可生成草稿 Release。流水线输出 APK/AAB、unsigned IPA、macOS PKG/ZIP、Linux DEB/RPM/tar.gz、Windows MSI/ZIP 和 SHA256SUMS。不会改写已经发布的 Release 资产。

本地构建后运行 `bash tool/ci/package_artifacts.sh --target <目标>`，资产位于 `dist/<目标>/`。macOS 默认包名按 arm64 标注，使用此流程须在 arm64 主机构建。Linux/Windows ARM 暂不作为必需应用构建目标。

Android 正式签名使用 `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD` 仓库 secrets，或本地 `android/key.properties`。缺少签名时生成 debug-key 签名的测试包，不可上传商店。iOS Release 默认 unsigned，须由拥有者重新签名。App Store 可使用 `tool/build_ios_store.sh`，但需要拥有者的 Apple 签名配置。macOS 默认未进行 Developer ID 分发签名/公证。

真实设备麦克风、触觉、实体键和本地持久化仍需设备验收；Windows/Linux 的运行和截图由 E2E CI 验证。不要把构建成功等同于商店上架或签名完成。

Tags must be `v<pubspec version>`; packaging refuses mismatched tag/application version metadata. / 发布标签须为 `v<pubspec 版本>`，打包流程拒绝版本不匹配。
