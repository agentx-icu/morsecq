# 构建与发布

MorseCQ 的所有平台构建均为离线学习版，无子模块、Tim2Tox 或 Tencent SDK 引导。固定工具链为 Flutter 3.41.9 / Dart 3.11.5。

在根目录执行 `dart pub get --enforce-lockfile`，然后使用 `./build_all.sh --platform <目标> --mode release`。目标为 android、ios、macos、linux、windows。每个桌面平台在对应主机构建；iOS 在安装 Xcode 的 Mac 上构建。Android 需要 Java 17 与 Android SDK；Linux 需要 GTK、ALSA 与 Ayatana appindicator 开发包；Windows 需要 Visual Studio C++ 和 WiX v3 安装包工具。

`.github/workflows/builds.yml` 在 PR、main/master 更新、v* 标签及手动执行时运行。分析、复杂度、分层、本地化、截图导入保护及所有包/应用测试是构建前置门禁。所有五个平台均必须成功，标签才可生成草稿 Release。流水线输出 APK/AAB、unsigned IPA、macOS PKG/ZIP、Linux DEB/RPM/tar.gz、Windows MSI/ZIP 和 SHA256SUMS。不会改写已经发布的 Release 资产。

Apple CI 保留 Flutter SDK 缓存，关闭 Pub 缓存复用；macOS 构建及界面测试前仅清理 flutter_soloud 的 CMake 生成文件，iOS 构建清理对应平台的生成文件，避免在不同 Xcode 主机镜像间复用绝对编译器路径。本地切换 Xcode 后，可在重新构建前执行 `bash tool/ci/clean_apple_plugin_cache.sh macos` 或 `ios`。

本地构建后运行 `bash tool/ci/package_artifacts.sh --target <目标>`，资产位于 `dist/<目标>/`。macOS 包名按可执行文件的实际架构标注为 arm64、x86_64 或 universal2。Linux/Windows ARM 暂不作为必需应用构建目标。

Android 正式签名使用 `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD` 仓库 secrets，或本地 `android/key.properties`。缺少签名时生成 debug-key 签名的测试包，不可上传商店。iOS Release 默认 unsigned，须由拥有者重新签名。App Store 可使用 `tool/build_ios_store.sh`，但需要拥有者的 Apple 签名配置。macOS 默认未进行 Developer ID 分发签名/公证。

真实设备麦克风、触觉、实体键和本地持久化仍需设备验收；Windows/Linux 的运行和截图由 E2E CI 验证。不要把构建成功等同于商店上架或签名完成。

发布标签匹配 pubspec 的数字 `X.Y.Z` 部分：`1.0.0+1` 对应 `v1.0.0`；打包流程拒绝元数据不匹配。生成草稿 Release 前，`bash tool/ci/verify_release_assets.sh <产物目录> v1.0.0` 要求全部十个原生产物、且 macOS 只有一组架构的 PKG/ZIP，并生成可跨主机验证的 SHA256SUMS。缺失、空文件、额外文件或符号链接均会阻断发布。

## 平台范围

必需安装包面向 Android API 24+（arm64-v8a、armeabi-v7a、x86_64）、iOS 14+（arm64）、macOS 13+ universal2、Linux x86_64 和 Windows x64。macOS Runner 和 Podfile 的最低版本与实际随包 objective_c 原生框架已验证的 13.0 要求一致。Linux 在 Ubuntu 24.04 与 GTK 3、ALSA、Ayatana appindicator 上验证运行；Windows CI 使用 Windows Server 2022，Windows 10/11 与真实移动设备仍需分发验收。
