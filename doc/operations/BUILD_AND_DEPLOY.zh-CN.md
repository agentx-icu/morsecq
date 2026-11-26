[English](./BUILD_AND_DEPLOY.md)

# 构建与发布

使用 Flutter 3.41.9 和 Dart 3.11.5 构建 MorseCQ。安装目标工具链后，用 `flutter doctor -v` 检查环境。从仓库根目录运行 `dart pub get --enforce-lockfile`，按锁文件解析 Pub 工作区依赖。

## 在本机构建开发包

在仓库根目录执行以下两个命令。切换到 Android、Linux 或 Windows 时，请在对应主机上把两条命令中的 `macos` 一并替换。打包需要 Python 3.11 或更高版本。

```sh
./build_all.sh --platform macos --mode release
bash tool/ci/package_artifacts.sh --target macos
```

| 目标 | 主机工具 | `dist/<目标>/` 中的开发制品 |
| --- | --- | --- |
| `android` | JDK 17 和 Android SDK | APK、AAB |
| `ios` | 安装了 Xcode 和 CocoaPods 的 macOS | 未签名 IPA |
| `macos` | 安装了 Xcode 和 CocoaPods 的 macOS | PKG、ZIP |
| `linux` | 安装了 Clang、CMake、Ninja、pkg-config、GTK 3、ALSA 和 Ayatana AppIndicator 开发包的 x86_64 Linux。打 RPM 还需 `rpmbuild`。 | DEB、RPM、tar.gz |
| `windows` | 安装了 Visual Studio C++ 桌面开发工具的 x64 Windows。打包需安装带 CPack 的 CMake、生成 MSI 的 WiX v3 和生成 ZIP 的 7-Zip。在 Bash 中运行脚本，并确认 `PATH` 中可找到 `python`（3.11+）、`cmake`、`cpack` 和 `7z`。 | MSI、ZIP |

macOS 打包要求同时包含 `arm64` 和 `x86_64` 的 universal2 可执行文件。
Android 本地测试如未配置发布密钥，可将构建命令改为
`MORSECQ_ALLOW_DEBUG_SIGNING=1 ./build_all.sh --platform android --mode release`。

使用 `build_all.sh` 生成未签名的 iOS 发布构建时，需传入 `--allow-unsigned-ios`。可用 `flutter run` 在模拟器运行应用。
TestFlight 或 App Store 签名导出使用下文的商店流程。

```sh
./build_all.sh --platform ios --mode release --allow-unsigned-ios
bash tool/ci/package_artifacts.sh --target ios
```

## 构建流水线与发布产物

`.github/workflows/builds.yml` 在 PR 和 main/master 更新时只运行一次 Linux 分析与回归检查。完整平台构建需要当前 `ci:build`/`ci:full` PR 标签、手动执行或版本标签。分析、复杂度、分层、本地化、截图导入保护及所有包/应用测试是这些构建的前置门禁。所有五个平台均必须成功，标签才可生成草稿 Release。流水线输出 APK/AAB、IPA、macOS PKG/ZIP、Linux DEB/RPM/tar.gz、Windows MSI/ZIP 和 SHA256SUMS。已发布的安装包保持原样。

Apple CI 保留 Flutter SDK 缓存，关闭 Pub 缓存复用；macOS 构建及界面测试前仅清理 flutter_soloud 的 CMake 生成文件，iOS 构建清理对应平台的生成文件，避免在不同 Xcode 主机镜像间复用绝对编译器路径。本地切换 Xcode 后，可在重新构建前执行 `bash tool/ci/clean_apple_plugin_cache.sh macos` 或 `ios`。

发布后，[发布清单工作流](../../.github/workflows/release-manifest.yml)生成
`release-manifest.json`，列出产物下载地址、大小、SHA-256 和签名状态。GitHub
Release 发布或编辑时会运行，也可手动刷新。第三方分发所需的最终签名、校验和与元数据
准备流程见[分发打包指南](../release/DISTRIBUTION_PACKAGING.zh-CN.md)。

## 平台签名与包验证

macOS 发布包要求 universal2 可执行文件。打包前会核对所有内嵌 Mach-O 的最低系统
版本与应用的 `LSMinimumSystemVersion`。用 `python3 tool/ci/macos_runtime.py`
加应用包路径检查已构建的应用。正式分发时配置 Developer ID 签名及公证。

Android 标签构建要求四个 Actions 密钥 `ANDROID_KEYSTORE_BASE64`、
`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS` 和 `ANDROID_KEY_PASSWORD`。
本地构建可设置 `MORSECQ_ANDROID_KEYSTORE`、`MORSECQ_ANDROID_KEYSTORE_PASSWORD`、
`MORSECQ_ANDROID_KEY_ALIAS` 和 `MORSECQ_ANDROID_KEY_PASSWORD`，或配置
`apps/morsecq/android/key.properties` 中的 `storeFile`、`storePassword`、
`keyAlias` 和 `keyPassword`。分支和 PR 测试包显式启用调试签名。Google Play
发布负责人需要启用 Play App Signing 并获得上传及发布轨道权限。

iOS 签名导出需要 `icu.agentx.morsecq` App ID、Apple Developer Team、iOS
Distribution 证书、App Store 描述文件和 App Store Connect 上传权限。用 Xcode
打开 `apps/morsecq/ios/Runner.xcworkspace` 选择 Team，再按[商店构建指南](../release/APP_STORE.zh-CN.md)
执行 `bash tool/build_ios_store.sh`，并提供该指南要求的参数和签名身份。脚本在本地
导出并核验 IPA 身份和描述文件，将证据写入 `build/ios/store-readiness/`。上传
TestFlight 或 App Store 由发布负责人通过 Xcode Organizer 或 Transporter 完成。
GitHub 的 iOS 构建产物用于未签名侧载验证。

设备检查覆盖麦克风解码、触觉反馈、实体键和本地持久化。按需启用的 E2E CI 在 macOS、Windows、Linux、iPhone 模拟器及 Android 模拟器上运行，三个桌面任务还会捕获截图。见[测试指南](../testing/TEST_PYRAMID.zh-CN.md)。

发布标签匹配 pubspec 的数字 `X.Y.Z` 部分：例如 `1.0.1+2` 对应 `v1.0.1`，`v0.2.0` 等旧标签会在构建/打包前被拒绝。可先运行 `bash tool/ci/check_version_tag.sh vX.Y.Z`；工作流和打包流程会重复检查。生成草稿 Release 前，`bash tool/ci/verify_release_assets.sh <产物目录> vX.Y.Z` 要求全部十个原生产物、且 macOS 只有一组架构的 PKG/ZIP，并生成可跨主机验证的 SHA256SUMS。缺失、空文件、额外文件或符号链接均会阻断发布。

## 平台范围

必需安装包面向 Android API 24+（arm64-v8a、armeabi-v7a、x86_64）、iOS 14+（arm64）、macOS 13+ universal2、Linux x86_64 和 Windows x64。macOS Runner 和 Podfile 的最低版本与随包 `objective_c` 原生框架已验证的 13.0 要求一致。Linux 在带有 GTK 3、ALSA 和 Ayatana AppIndicator 的 Ubuntu 24.04 上验证运行，DEB 安装检查会先核对 EGL/GL/GLES 加载器，再引入测试工具。Windows CI 使用 Windows Server 2022。

## 跨平台发布检查（2026-10-22）

Linux Listen 调用 `parecord` 和 `pactl`；tar.gz 部署需要安装 `pulseaudio-utils`，DEB/RPM 已声明依赖。
使用 `gdbus` 检测真实托盘宿主（DEB 的 `libglib2.0-bin`、RPM 的 `glib2`）；没有宿主时关闭窗口仍退出。
macOS 沙盒允许单实例激活套接字所需的本机客户端/服务器 IPC，不连接互联网服务。

Android 标签构建必须提供四项所有者签名 secret；`tool/ci/verify_android_signing.py` 检查产物 APK/AAB 使用同一非调试证书。
即使仓库已配置所有者签名，分支、PR 和非标签的手动 CI 构建也使用调试密钥。构建商店产物时，给 `flutter build apk --release` 或 `flutter build appbundle --release` 加 `-PstoreRelease`。构建要求配置 release keystore（环境变量或 `android/key.properties`），验证 AAB 和每个 APK 的签名，并拒绝 Android Debug 证书。Windows Authenticode、macOS Developer ID 与公证仍需所有者凭据，不能由未签名构建推定完成。

CI 以独立 `symbols-*` artifact 保存 Dart split-debug-info 及可用 dSYM/PDB。
应用自身的 Dart 诊断仅保存 UTC 时间、白名单错误类别、固定事件名，以及记录器内部捕获的代码坐标 / AOT PC，
位置为 `<support>/logs/errors.log`，最多两份、每份 256 KiB。忽略调用方传入的堆栈文本、函数名、绝对路径、
异常消息、学习内容与录音。这是记录器捕获点的代码栈，并非原始异常堆栈；无法识别的帧直接丢弃。
旧版原始日志在继续记录前替换，复制时也不导出。日志保存在本机，可用 **我 → 关于 → 复制本地诊断信息** 手动导出。
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
