[English](./BUILD_AND_DEPLOY.md)

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

## 跨平台发布检查（2026-10-22）

Linux Listen 调用 `parecord` 和 `pactl`；tar.gz 部署需要安装 `pulseaudio-utils`，DEB/RPM 已声明依赖。
使用 `gdbus` 检测真实托盘宿主（DEB 的 `libglib2.0-bin`、RPM 的 `glib2`）；没有宿主时关闭窗口仍退出。
macOS 沙盒允许单实例激活套接字所需的本机客户端/服务器 IPC，不连接互联网服务。

Android 标签构建必须提供四项所有者签名 secret；`tool/ci/verify_android_signing.py` 检查产物 APK/AAB 使用同一非调试证书。
非标签调试签名产物仅用于本机/CI 测试。Windows Authenticode、macOS Developer ID 与公证仍需所有者凭据，不能由未签名构建推定完成。

CI 以独立 `symbols-*` artifact 保存 Dart split-debug-info 及可用 dSYM/PDB。
应用自身的 Dart 诊断仅保存 UTC 时间、白名单错误类别、固定事件名，以及记录器内部捕获的代码坐标 / AOT PC，
位置为 `<support>/logs/errors.log`，最多两份、每份 256 KiB。忽略调用方传入的堆栈文本、函数名、绝对路径、
异常消息、学习内容与录音。这是记录器捕获点的代码栈，并非原始异常堆栈；无法识别的帧直接丢弃。
旧版原始日志在继续记录前替换，复制时也不导出。不上传；“我的 → 复制本地诊断信息”是主动导出入口。
记录时不求值自定义错误的 `runtimeType` 或 `toString`。初始化、记录与复制均拒绝 logs 目录、当前/轮转文件处的链接。
写入先在私有临时目录暂存，再以 rename 替换目录项，不通过既有日志项截断或追加；路径变化或不安全时停用诊断，
不修改链接目标。此清理不迁移任何学习文件。

错误钩子在启动工作前安装，此时不打开存储；桌面文件 sink 仅在独占实例取得目录所有权后启用。
存储尚未就绪或不可用时仍阻止 release 原始控制台回退，但无法保留此前的报告。
Release 不转发原始 Flutter details，PlatformDispatcher 不再请求 stderr 回退；应用/共享插件 catch 日志
和显式桌面日志 sink 仅在 debug 输出原文。Product-policy CI 验证这些分支，不代替安装后的 release 测试。
原生崩溃、工作 isolate 错误转发、与已发产物匹配的逐平台符号化仍未验证，仍需系统崩溃报告和归档符号。
各系统还需要安装包和升级冒烟：安装上一版、创建学习记录、升级、启动并确认记录、检查关闭/托盘/重开/退出及最终包声明。
Widget 测试或直接启动 app bundle 不证明安装升级已验证。

## 渠道预检与所有者签名

先读[商店/渠道矩阵](../release/STORE_READINESS.zh-CN.md)。产物工具需 Python3.11+，CI 固定3.12。五个平台构建 release 并把 `evidence-*` 与下载/符号分开保留：原生哈希/架构、Apple 最终隐私/用途本地化/权限、Android 最终 manifest/SDK/ABI/16 KB ELF/ZIP/bundle 对齐；Windows 另核对 MSI Template Summary 为 x64。检查不能替代安装和审核。bundletool1.18.3 下载有 SHA-256 pin。

`package_artifacts.sh` 默认是开发下载，iOS 明确未签名，不可宣称已上架/可信分发。可选 `MORSECQ_DISTRIBUTION=1` 在 staging 前拒绝缺少所有者材料：

| 目标 | 所有者输入 / 行为 |
| --- | --- |
| macOS Developer ID | `MORSECQ_MACOS_APPLICATION_IDENTITY`、`MORSECQ_MACOS_INSTALLER_IDENTITY`、真实 `MORSECQ_APPLE_TEAM_ID` 和已有 `MORSECQ_NOTARY_PROFILE`。从内到外签名，核对真实 Team/证书类别/runtime，公证并 staple app ZIP/PKG，再核对最终 ZIP/安装器；仅由所有者调用，上传至公证服务而非 App Store 提交。 |
| Windows 直接/hosted MSI | 可用证书存储中的 `MORSECQ_WINDOWS_CERT_SHA1`、`signtool.exe` 与可信签名材料。签名前先查所有 staged PE 架构，再签未签名 PE，保留有效供应商签名；app/安装器须匹配所有者，所有 PE/MSI 校验。不是尚未实现的 Store MSIX 路径。 |
| Android | `MORSECQ_ANDROID_UPLOAD_CERT_SHA256`、显式 `MORSECQ_BUNDLETOOL_JAR` 和可执行 `MORSECQ_APKANALYZER` 路径；缺检查工具直接拒绝。复制前重查最终 manifest/ABI/16 KB；APK/AAB 须匹配预期 upload 证书，拒绝 debug。JDK17 `JarFile` 逐条读至 EOF 验证签名者，不依赖 manifest 的 ZIP 顺序；未签名/篡改/重复条目拒绝。PR 构建亦保留开发 AAB 签名报告。tag CI 需 repository variable `ANDROID_UPLOAD_CERT_SHA256` 及已有四个签名 secrets；Play 分发指纹另记。 |
| iOS / Linux | 拒绝通用发行标志：iOS 用独立 App Store 签名导出，Linux 仓库信任/签名与更新为所有者发布工作，仍可生成开发包。 |

配置真实 `MORSECQ_APPLE_TEAM_ID` 后用所有者 Xcode signing/export 参数运行 `bash tool/build_ios_store.sh`。导出后解包实际 IPA，检查设备 payload/隐私、distribution 签名/Team 和 App Store provisioning（无开发/ad-hoc 设备列表），生成 `build/evidence/ios-store.json`，不提交商店。CI 未签名 IPA 不是此导出包。

发布前记录最终哈希和上一签名版本，按选定渠道以普通用户测试干净安装、带学习数据升级、授权拒绝/撤销和卸载。凭据、身份/地区/文案/权利与后台声明没有证据前仍是所有者阻塞项。

CI 与本地 strict 打包共用 payload 检查器。最终 Mac ZIP 检查同时执行真实 `codesign --verify --deep --strict`，仅读权限元数据不能验证资源/签名。

桌面 CMake 显式关闭可选 JNI 宿主发现：JNI 来自仅 Android 使用的间接平台依赖，MorseCQ 的 Linux/Windows 没有 Java 功能，不能因 runner 安装了 JDK 而额外要求 JVM。Android JNI 不变；未来增加桌面 Java 必须重新声明完整 runtime/依赖并验证已装产物。DEB 在引入测试 harness 前检查 EGL/GL/GLES loader 与闭包；tar 部署亦须安装 `libegl1`、`libgl1`、`libgles2` 及已有音频依赖。
