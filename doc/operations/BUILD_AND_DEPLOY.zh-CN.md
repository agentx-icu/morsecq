# 构建与发布

使用 Flutter 3.41.9 / Dart 3.11.5 构建 MorseCQ。

在根目录执行 `dart pub get --enforce-lockfile`，然后使用 `./build_all.sh --platform <目标> --mode release`。目标为 android、ios、macos、linux、windows。每个桌面平台在对应主机构建；iOS 在安装 Xcode 的 Mac 上构建。Android 需要 Java 17 与 Android SDK；Linux 需要 GTK、ALSA 与 Ayatana appindicator 开发包；Windows 需要 Visual Studio C++ 和 WiX v3 安装包工具。

`.github/workflows/builds.yml` 在 PR、main/master 更新、v* 标签及手动执行时运行。分析、复杂度、分层、本地化、截图导入保护及所有包/应用测试是构建前置门禁。所有五个平台均必须成功，标签才可生成草稿 Release。流水线输出 APK/AAB、IPA、macOS PKG/ZIP、Linux DEB/RPM/tar.gz、Windows MSI/ZIP 和 SHA256SUMS。不会改写已经发布的 Release 资产。

Apple CI 保留 Flutter SDK 缓存，关闭 Pub 缓存复用；macOS 构建及界面测试前仅清理 flutter_soloud 的 CMake 生成文件，iOS 构建清理对应平台的生成文件，避免在不同 Xcode 主机镜像间复用绝对编译器路径。本地切换 Xcode 后，可在重新构建前执行 `bash tool/ci/clean_apple_plugin_cache.sh macos` 或 `ios`。

本地构建后运行 `bash tool/ci/package_artifacts.sh --target <目标>`，资产位于 `dist/<目标>/`。macOS 包名按可执行文件的实际架构标注为 arm64、x86_64 或 universal2。Linux/Windows ARM 暂不作为必需应用构建目标。

macOS 创建任一归档前，会核对所有内嵌 Mach-O 架构与应用的 `LSMinimumSystemVersion`。可运行 `python3 tool/ci/macos_runtime.py <应用.app>` 检查已构建应用；任何依赖要求更高系统版本都会阻断打包。

Android 签名使用 `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD` 仓库 secrets，或本地 `android/key.properties`。iOS 配置 Apple Team、证书和描述文件后运行 `tool/build_ios_store.sh`。macOS 分发配置 Developer ID 签名及公证。

设备检查覆盖麦克风解码、触觉、实体键和本地持久化。E2E CI 在 macOS、Windows 和 Linux 运行应用并捕获截图。

发布标签匹配 pubspec 的数字 `X.Y.Z` 部分：`1.0.0+1` 对应 `v1.0.0`；打包流程拒绝元数据不匹配。生成草稿 Release 前，`bash tool/ci/verify_release_assets.sh <产物目录> v1.0.0` 要求全部十个原生产物、且 macOS 只有一组架构的 PKG/ZIP，并生成可跨主机验证的 SHA256SUMS。缺失、空文件、额外文件或符号链接均会阻断发布。

## 平台范围

必需安装包面向 Android API 24+（arm64-v8a、armeabi-v7a、x86_64）、iOS 14+（arm64）、macOS 13+ universal2、Linux x86_64 和 Windows x64。macOS Runner 和 Podfile 的最低版本与实际随包 objective_c 原生框架已验证的 13.0 要求一致。Linux 在 Ubuntu 24.04 与 GTK 3、ALSA、Ayatana appindicator 上验证运行；Windows CI 使用 Windows Server 2022。
