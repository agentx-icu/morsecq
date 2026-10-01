[English](./BUILD_AND_DEPLOY.md)

# morsecq 构建与部署（原生库 libtim2tox_ffi）

本文档说明 morsecq 五端（macOS / Linux / Windows / Android / iOS）如何构建并打包
Tox 聊天后端所依赖的原生库 **libtim2tox_ffi**（Tim2Tox C++ FFI 层 + c-toxcore +
libsodium），以及 GitHub Actions 中对应的流水线。UI 与纯 Dart 的部分只需
`dart pub get` + `flutter run`，本文不重复。

流水线整体照搬 toxee（同组织、同一个 Tim2Tox 子模块），差异集中在
[§1.2 与 toxee 的差异](#12-与-toxee-的差异)。

## 目录

- [1. 概览](#1-概览)
- [2. 各平台前置条件](#2-各平台前置条件)
- [3. 命令](#3-命令)
- [4. 产物位置与运行时查找路径](#4-产物位置与运行时查找路径)
- [5. 最低系统版本](#5-最低系统版本)
- [6. GitHub Actions：native.yml](#6-github-actionsnativeyml)
- [7. 本地 / 容器 CI 无法验证的部分](#7-本地--容器-ci-无法验证的部分)
- [8. 排障](#8-排障)

## 1. 概览

### 1.1 组件

| 文件 | 作用 |
|---|---|
| `tool/ci/build_tim2tox.sh` | **唯一的原生构建入口**。一个 `--target` 对应一个产物目录 `build/native/<target>/`。负责初始化 c-toxcore 嵌套子模块、下载并校验 libsodium 1.0.20、配置/编译 tim2tox_ffi、三项字节级校验（无 ToxAV、Dart* 入口存在、无测试钩子）、并把产物放到应用工程能取到的位置。 |
| `tool/ci/assert_no_test_hooks.sh` | 字节级门禁：拒绝任何带 Tim2Tox `auto_tests` 专用钩子（`tim2tox_ffi_mm6_*`）的二进制进入打包。Gradle 脚本从此文件解析符号名，**只维护这一份清单**。 |
| `tool/ci/common.sh` | 日志/路径/平台辅助函数（全部日志走 stderr，便于 `$(...)` 捕获）。 |
| `tool/build_android_ffi.sh` | 薄封装：`ABIS="arm64-v8a x86_64" tool/build_android_ffi.sh` → 每个 ABI 一份 `.so` 落到 `apps/morsecq/android/app/src/main/jniLibs/<abi>/`。 |
| `tool/build_ios_ffi.sh` | 薄封装：构建 iOS 真机 (arm64) + 模拟器 (arm64+x86_64 通用) 两个切片，`xcodebuild -create-xcframework` 合成 `apps/morsecq/ios/Frameworks/tim2tox_ffi.xcframework`。 |
| `build_all.sh` | `--platform <macos\|linux\|windows\|android\|ios> --mode <debug\|profile\|release> [--clean]`：先原生库，再 `flutter build`（默认 `--dart-define=MORSECQ_FAKE_BACKEND=false`）。 |
| `apps/morsecq/linux/CMakeLists.txt`、`windows/CMakeLists.txt` | 末尾 `# morsecq: bundle libtim2tox_ffi` 段：把库（Windows 还有 `libsodium.dll` / `pthreadVC3.dll`）`install` 到可执行文件旁。 |
| `apps/morsecq/android/app/build.gradle.kts` | 只打包有 `.so` 的 ABI；没有任何 `.so` 时直接失败（`-PmorsecqAllowMissingFfi=true` 放行纯 UI 构建）；打包前字节扫描测试钩子。 |
| `apps/morsecq/ios/Podfile` + `ios/Frameworks/Tim2ToxFFI.podspec` | 本地二进制 pod，`vendored_frameworks = tim2tox_ffi.xcframework`；CocoaPods 把匹配的切片嵌入 `Runner.app/Frameworks/`。 |
| `apps/morsecq/macos/Podfile` + `macos/Frameworks/Tim2ToxFFI.podspec` | 本地二进制 pod，`vendored_libraries = libtim2tox_ffi.dylib`；CocoaPods 链接并嵌入 `Contents/Frameworks/`。 |
| `.github/workflows/native.yml` | 8 个原生目标 + 3 个桌面端 release 构建（见 §6）。 |

### 1.2 与 toxee 的差异

| 项 | toxee | morsecq | 原因 |
|---|---|---|---|
| ToxAV | 默认 ON，`--no-toxav` 关闭 | **永远 OFF**；`--toxav` 直接报错 | morsecq 无通话；opus / libvpx 完全不下载、不链接 |
| sqlite3 | 桌面端链接系统 sqlite3 | 默认 `TIM2TOX_DISABLE_SQLITE=ON`（`--with-sqlite` 恢复） | Tim2Tox 只用它做 Community 持久化，morsecq 不用；桌面库因此零系统依赖 |
| libsodium（Linux / macOS） | apt / Homebrew 动态库，随包捕获 | **从 pinned tarball 静态编译**（版本、SHA-256 与 toxee 完全一致：1.0.20 / `ebb65ef6…0ce19`）；`--system-libsodium` 恢复 toxee 行为 | 每平台只需捆绑一个文件，无需 `install_name_tool -change` / RUNPATH 依赖；本机没有 libsodium-dev 也能构建 |
| libsodium（Android / iOS / Windows） | 同 toxee | 同 toxee（Android/iOS 静态；Windows vcpkg 动态 + `pthreadVC3.dll`） | — |
| 目标命名 | `--target linux` 等 | 架构显式：`linux-x86_64`、`windows-arm64`、`macos-arm64`…（`linux`/`macos`/`windows` 别名 = 宿主架构，`ios` = `ios-device`） | CMake 端按 `CMAKE_SYSTEM_PROCESSOR` 选目录 |
| 产物目录 | `build/native-artifacts/<target>/`，构建树在 `third_party/tim2tox/build/` | `build/native/<target>/`，构建树 `build/native/.work/`，依赖 `build/native/.deps/` | 本仓库禁止写入 `third_party/` |
| iOS 嵌入 | 手改 `project.pbxproj` 的脚本阶段，按 `PLATFORM_NAME` 选 framework | XCFramework + 本地 podspec | 一个产物同时含真机与模拟器切片，无需改 pbxproj |
| macOS 嵌入 | `flutter build macos` 不嵌入；由 run 脚本 / 打包脚本拷贝到 `Contents/MacOS` | 本地 podspec `vendored_libraries`，`flutter build macos` 直接嵌入 `Contents/Frameworks` | morsecq 没有 run 脚本 |

## 2. 各平台前置条件

通用：**Flutter 3.41.9**（与 `.github/workflows/analyze.yml` 一致；原生构建也需要它——
`tim2tox/ffi/CMakeLists.txt` 会编译 Flutter 自带 Dart SDK 里的 `dart_api_dl.c`，
缺了它所有原生→Dart 回调都是死的）、Git（子模块）、CMake ≥ 3.16、网络（首次会下载
libsodium tarball ~1.9 MB 并校验 SHA-256）。**只构建原生库**时，一份与 Flutter 自带
版本相同的独立 Dart SDK（3.41.9 对应 3.11.5）就够了：PATH 上没有 `flutter` 但有 `dart`
（或设置 `MORSECQ_DART_SDK_DIR`）时，`build_tim2tox.sh` 会把它的 `include/` 摆成 tim2tox
CMake 探测的 `<FLUTTER_ROOT>/bin/cache/dart-sdk/include` 布局（`build/native/.dart-sdk-shim`）。
CI 的 Linux aarch64 / Windows arm64 job 就是这样跑的——Flutter 不发布这两个平台的 arm64 归档。

| 平台 | 需要 |
|---|---|
| **Linux**（x86_64 / aarch64，本机架构构建） | `build-essential cmake ninja-build pkg-config`；打 Flutter 包还需 `libgtk-3-dev`、`patchelf`（推荐），以及 `libsecret-1-dev`（`flutter_secure_storage`，缺了 CMake 直接报错）、`libayatana-appindicator3-dev`（`tray_manager`；构建时可选，但缺了托盘会静默降级）和 `libasound2-dev`（`flutter_soloud` 编译其 ALSA 后端；PulseAudio/JACK 在运行时 dlopen，不需要头文件）。**不需要** `libsodium-dev`（默认静态编译；`--system-libsodium` 时需要）。 |
| **macOS**（x86_64 / arm64，任一 Mac 可交叉构建另一架构） | Xcode Command Line Tools、`cmake`（`brew install cmake ninja pkg-config`）、CocoaPods。**不需要** Homebrew libsodium。脚本用 `xcrun --sdk macosx --show-sdk-path` 显式钉住 SDK（`-isysroot` / `SDKROOT` / `CMAKE_OSX_SYSROOT`）：`xcrun -f clang` 给出的是 toolchain 里的原始 clang，它不会自己推断 SDK，缺了这一步 libsodium 的 configure 会报 "C compiler cannot create executables"（GitHub `macos-15` 首轮就是这样挂的）。 |
| **Windows**（x64 / arm64） | Visual Studio 2022 或 18 的 C++ 工具集、CMake、Git Bash、`vcpkg`：`vcpkg install libsodium:<triplet> pthreads:<triplet> pkgconf:<triplet>`，设置 `VCPKG_ROOT`；在 vcvars 环境里从 Git Bash 运行脚本。 |
| **Android** | Android SDK + **NDK**（`ANDROID_NDK_HOME` / `ANDROID_NDK_ROOT` / `$ANDROID_HOME/ndk/<ver>`），Java 17。 |
| **iOS** | Xcode（iphoneos + iphonesimulator SDK）、CocoaPods。分发 IPA 另需证书与 provisioning profile（不在本流水线内）。 |

## 3. 命令

都在仓库根目录执行。

```bash
export PATH=/home/user/flutter/bin:$PATH        # 或你的 Flutter 路径
dart run tool/bootstrap_deps.dart                # 子模块 + 腾讯 SDK vendor + pubspec_overrides
dart pub get                                     # workspace 一次解析

# ---- 一键：原生库 + Flutter 构建 ----
./build_all.sh --platform linux   --mode release
./build_all.sh --platform macos   --mode debug
./build_all.sh --platform windows --mode release          # Windows 上的 Git Bash
./build_all.sh --platform android --mode release --android-abis arm64-v8a,x86_64
./build_all.sh --platform ios     --mode release          # 产出未签名 .app
#   --clean 先 flutter clean；--skip-native 复用已构建的库；--fake-backend 纯 UI 构建

# ---- 只构建原生库 ----
bash tool/ci/build_tim2tox.sh --target linux-x86_64
bash tool/ci/build_tim2tox.sh --target macos-arm64            # 会同时拷到 apps/morsecq/macos/Frameworks/
bash tool/ci/build_tim2tox.sh --target windows-x64
ABIS="arm64-v8a x86_64" tool/build_android_ffi.sh             # 模拟器需要 x86_64
tool/build_ios_ffi.sh                                         # 真机 + 模拟器 → xcframework
tool/build_ios_ffi.sh --simulator-only

# 可选开关（build_tim2tox.sh）
#   --with-sqlite         链接 sqlite3（Community 持久化，morsecq 不用）
#   --system-libsodium    Linux/macOS 用系统 / Homebrew libsodium（动态，随包捕获）
#   --stage-only          不编译，仅把 build/native/<target>/ 重新放入应用工程（CI 缓存命中后用）
#   --no-stage-app        只编译捕获，不碰 apps/morsecq/
#   MORSECQ_NATIVE_BUILD_TYPE=RelWithDebInfo   带符号的原生库

# ---- 门禁：打包前的字节级检查（脚本内部已自动执行，可手动复核）----
bash tool/ci/assert_no_test_hooks.sh build/native/linux-x86_64
bash tool/ci/assert_no_test_hooks.sh apps/morsecq/android/app/src/main/jniLibs
```

`--mode` 只是 Flutter 的模式标签；原生库始终以 `Release`（或
`MORSECQ_NATIVE_BUILD_TYPE`）编译，与 toxee 一致。

## 4. 产物位置与运行时查找路径

Dart 侧有两个加载器，都以 **`tim2tox_ffi`** 为名：

- `Tim2ToxFfi.open()`（`third_party/tim2tox/dart/lib/ffi/tim2tox_ffi.dart`）：按平台依次探测
  可执行文件目录、`../lib/`（Linux/Windows）、`../Frameworks/libtim2tox_ffi.dylib`（macOS）、
  `Frameworks/tim2tox_ffi.framework/tim2tox_ffi`（iOS），最后回退到裸名 dlopen。
- 打过补丁的腾讯 SDK `NativeLibraryManager`（`packages/morsecq_chat` 的 `NativeLibrarySetup.ensure()`
  调 `setNativeLibraryName('tim2tox_ffi')`）：Linux/Android `libtim2tox_ffi.so`，Windows
  `tim2tox_ffi.dll`，iOS 同上绝对路径，macOS 裸名 `libtim2tox_ffi.dylib`（命中进程内已由
  `Tim2ToxFfi` 加载的同名镜像）。

`libtim2tox_ffi` 是包里**唯一**的原生聊天库：自 2026-09-30 起 `bootstrap_deps` 会给 vendored 的
`tencent_cloud_chat_sdk` 插件叠加空操作的平台桩（`third_party/overlays/tencent_cloud_chat_sdk/`），
因此不再链接或打包任何 `TXIMSDK_Plus_*` pod、`imsdk-plus` AAR、`libdart_native_imsdk.so` 或
`ImSDK.dll`。`pod install` / `flutter build` 之前先跑 bootstrap；如果 `Podfile.lock` 里还列着
`TXIMSDK_Plus_*`，说明 overlay 没有生效。

因此每端的落点如下（全部被 `.gitignore` 忽略，**不要提交**）：

| 平台 | `build_tim2tox.sh` 产物 | 进入应用工程 | 最终在包里 |
|---|---|---|---|
| Linux | `build/native/linux-<arch>/libtim2tox_ffi.so`（`--system-libsodium` 时另有 `libsodium.so*`） | 不拷贝；`linux/CMakeLists.txt` 直接从该目录 `install` | `bundle/lib/libtim2tox_ffi.so`（RUNPATH=`$ORIGIN`，需 patchelf） |
| Windows | `build/native/windows-<x64\|arm64>/tim2tox_ffi.dll` + `libsodium.dll` + `pthreadVC3.dll`（+ `.pdb`） | 不拷贝；`windows/CMakeLists.txt` 直接 `install` | `runner/Release/` 与 `morsecq.exe` 同目录 |
| macOS | `build/native/macos-<x86_64\|arm64>/libtim2tox_ffi.dylib`（install name `@rpath/libtim2tox_ffi.dylib`，ad-hoc 签名） | 拷到 `apps/morsecq/macos/Frameworks/libtim2tox_ffi.dylib`，并 `touch Podfile` 触发 `pod install` | `morsecq.app/Contents/Frameworks/libtim2tox_ffi.dylib` |
| Android | `build/native/android/jniLibs/<abi>/libtim2tox_ffi.so`（已 strip） | 整目录替换 `apps/morsecq/android/app/src/main/jniLibs/` | APK `lib/<abi>/libtim2tox_ffi.so`；Gradle `abiFilters` = 有 `.so` 的 ABI |
| iOS | `build/native/ios-device/tim2tox_ffi.framework`、`build/native/ios-simulator/tim2tox_ffi.framework`（+ 各自 `libtim2tox_ffi.dylib`） | `tool/build_ios_ffi.sh` 合成 `apps/morsecq/ios/Frameworks/tim2tox_ffi.xcframework`，并 `touch Podfile` | `Runner.app/Frameworks/tim2tox_ffi.framework` |

`MORSECQ_NATIVE_DIR`（CMake 缓存变量或环境变量）可以让 Linux/Windows 工程从别的目录取库。

## 5. 最低系统版本

与 toxee `doc/reference/PLATFORM_SUPPORT.md` 一致，并在构建参数里落实：

| 平台 | 最低版本 | 落实处 |
|---|---|---|
| macOS | **10.15** | `-mmacosx-version-min=10.15` / `CMAKE_OSX_DEPLOYMENT_TARGET`；`macos/Podfile` `platform :osx, '10.15'`；Runner.xcodeproj `MACOSX_DEPLOYMENT_TARGET = 10.15` |
| Windows | **10** | MSVC 默认目标 |
| Android | **API 21**（Android 5.0） | `ANDROID_PLATFORM=android-21`，libsodium 以 API 21 clang 编译；`minSdk = flutter.minSdkVersion`（Flutter 3.41 默认 ≥ 21） |
| iOS | **14.0**（`file_picker_darwin` 要求 14；2026-09-30 从 13.0 提高） | `-target arm64-apple-ios14.0[-simulator]`、framework `MinimumOSVersion=14.0`；`ios/Podfile` `platform :ios, '14.0'`；Runner.xcodeproj `IPHONEOS_DEPLOYMENT_TARGET = 14.0` |

## 6. GitHub Actions：native.yml

`.github/workflows/native.yml`，触发：push 到 main/master、`v*` tag、PR，且仅当原生/平台相关路径变更；
或手动 `workflow_dispatch`。

**Job `native`（矩阵）**

| target | runner | 备注 |
|---|---|---|
| `linux-x86_64` | ubuntu-24.04 | |
| `linux-aarch64` | ubuntu-24.04-arm | **experimental**（`continue-on-error`），同 toxee；不装 Flutter（无 arm64 归档），用 `dart-lang/setup-dart` 装独立 Dart SDK `DART_VERSION` |
| `windows-x64` | windows-2022 | vcpkg libsodium/pthreads/pkgconf；`ilammy/msvc-dev-cmd` |
| `windows-arm64` | windows-11-arm | **experimental**；同上，只装独立 Dart SDK |
| `macos-x86_64` | macos-15-intel | |
| `macos-arm64` | macos-15 | |
| `android` | ubuntu-24.04 | arm64-v8a + armeabi-v7a + x86_64 |
| `ios` | macos-15 | 真机 + 模拟器切片 + xcframework |

每个 job：checkout（含子模块）→ Dart 头文件来源（x64 / macOS / Android / iOS 行装 Flutter 3.41.9，
`subosito/flutter-action@v2` 带缓存；`linux-aarch64` / `windows-arm64` 两行改装独立 Dart SDK
`DART_VERSION`，`dart-lang/setup-dart@v1`）→ 按 `tim2tox` 子模块 SHA + Flutter/Dart 版本 +
脚本哈希缓存整个 `build/native/<target>/`（命中即跳过编译；libsodium
前缀另行缓存）→ 构建（`--no-stage-app`）→ `assert_no_test_hooks.sh` 校验**上传的字节**→
上传 artifact `tim2tox-ffi-<target>`。

**Job `app-linux` / `app-windows` / `app-macos`**（`needs: native`）：下载对应 artifact 到
`build/native/<target>/`，`bootstrap_deps` + `dart pub get`，（macOS 先 `--stage-only`），然后在
`apps/morsecq` 内 `flutter build <platform> --release --dart-define=MORSECQ_FAKE_BACKEND=false`，
并**断言包里确实含库**（Linux 查 `bundle/lib/`，Windows 查 `tim2tox_ffi.dll` + `libsodium.dll`，
macOS 查 `Contents/Frameworks/` 并 `codesign --verify`）。

**Job `app-android` / `app-ios`**（`needs: native`）：Android 用 `--stage-only` 把 `jniLibs`
放入工程后 `flutter build apk` + `flutter build appbundle`；iOS 把 XCFramework 复制到
`apps/morsecq/ios/Frameworks/` 后 `flutter build ios --no-codesign`。

**安装包**：每个应用 job 随后运行 `tool/ci/package_artifacts.sh --target <平台>`（不含
`libtim2tox_ffi` 的构建一律拒绝打包），产物写到 `dist/<平台>/`：

| 平台 | 安装包 |
|---|---|
| Linux x86_64 | `.deb`、`.rpm`（CPack，`tool/ci/linux-installer`：程序在 `/opt/morsecq`，`/usr/bin/morsecq`、桌面入口、hicolor 图标），`.tar.gz` |
| Windows x64 | `.msi`（CPack + WiX v3，`tool/ci/windows-installer`；开始菜单快捷方式，固定升级 GUID），`.zip` |
| macOS arm64 | `.pkg`（pkgbuild 装到 `/Applications`，不可重定位），`.zip`（ditto） |
| Android | `.apk`（arm64-v8a、armeabi-v7a、x86_64），`.aab` |
| iOS | 未签名 `.ipa` |

每次运行都以 `release-<平台>` 上传，所以 PR 就能证明安装包可以构建；推送 `v*` tag 时，
`release` job 把它们连同 `SHA256SUMS` 挂到该 tag 的 GitHub Release（不存在则建草稿）。
Android 正式签名读仓库 secrets `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、
`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`（以 `MORSECQ_ANDROID_*` 环境变量原样交给 Gradle；
本地构建也可用被 gitignore 的 `apps/morsecq/android/key.properties`），没有时用 debug 密钥签名。
Android 原生库以 `ANDROID_STL=c++_shared` 构建，随包带上 NDK 的 `libc++_shared.so`。macOS / Windows 目前都未做代码签名或公证。

复用 toxee 的 pinned actions：`actions/checkout@v6`、`subosito/flutter-action@v2`、`actions/cache@v4`、
`actions/upload-artifact@v4`、`actions/download-artifact@v5`、`ilammy/msvc-dev-cmd@v1`、`actions/setup-java@v5`。

## 7. 本地 / 容器 CI 无法验证的部分

本流水线在 Linux 容器（cmake 3.28 / ninja / gcc+clang / Flutter 3.41.9，**无** GTK、libsodium-dev、
Android SDK、Xcode、MSVC）里完成了如下真实验证：

- `tool/ci/build_tim2tox.sh --target linux-x86_64`：子模块初始化 → libsodium 1.0.20 下载、SHA-256 校验、
  静态编译 → tim2tox_ffi 配置 + 编译（144 个目标）→ 产物 `libtim2tox_ffi.so`（5.4 MB，运行时依赖仅
  libc / libstdc++ / libm / libgcc_s；`DartInitSDK`、`tim2tox_ffi_init`、`Dart_InitializeApiDL`
  已导出；`sodium_init` 已静态链入；ToxAV 标记符号不存在；测试钩子门禁通过）。
- `--stage-only`、`--toxav` 拒绝、非法 target、在 Linux 上请求 macOS 目标的拒绝路径。
- `linux/CMakeLists.txt` 与 `windows/CMakeLists.txt` 的 `# morsecq: bundle libtim2tox_ffi` 段：
  用 mock 工程 `include` 后 `cmake --install`，确认库（Windows 含 `libsodium.dll`、`pthreadVC3.dll`）
  被安装，缺库时只告警。
- `native.yml` YAML 结构；Podfile / podspec 的 Ruby 语法。

**未在此环境验证、需要在对应平台首次运行确认**：

1. **macOS / iOS / Windows / Android 的实际编译**（脚本逐行移植自 toxee 已在 CI 跑通的版本，但
   morsecq 改为静态 libsodium、`CMAKE_OSX_DEPLOYMENT_TARGET`、`-DCMAKE_TRY_COMPILE_TARGET_TYPE` 等
   组合未实跑）。
2. **CocoaPods 嵌入**：iOS `vendored_frameworks` 的 xcframework、macOS `vendored_libraries` 的 dylib
   是否被 `[CP] Embed Pods Frameworks` 正确复制并签名；`Tim2ToxFfi._openMacOS()` 期望的
   `<exe>/../Frameworks/libtim2tox_ffi.dylib` 路径是否成立。首次 `flutter build macos/ios` 后请
   `ls <App>/Contents/Frameworks` / `Runner.app/Frameworks` 核对（`native.yml` 的 `app-macos` 已内置该断言）。
3. **Gradle 脚本**（`build.gradle.kts` 的 Kotlin 段落照抄 toxee 已运行的代码，仅改路径/属性名）。
4. **`flutter build linux` 的完整链路**（缺 GTK）；CMake 段落已用 mock 验证。
5. Windows arm64 / Linux aarch64 runner 的可用性（与 toxee 一样标为 experimental）。

## 8. 排障

- **`pod install` 没有带上 Tim2ToxFFI**：Podfile 只在产物存在时声明该 pod。构建原生库的脚本会
  `touch Podfile` 迫使 flutter 重新 `pod install`；若仍未生效：`rm -rf apps/morsecq/{ios,macos}/Pods
  apps/morsecq/{ios,macos}/Podfile.lock` 后重建。
- **Android：`libtim2tox_ffi.so not found under .../jniLibs`**：先 `tool/build_android_ffi.sh`；纯 UI
  构建加 `-PmorsecqAllowMissingFfi=true`（或 `MORSECQ_ALLOW_MISSING_FFI=1`）并配合
  `--dart-define=MORSECQ_FAKE_BACKEND=true`。
- **Windows 启动时 `error 126`**：`libsodium.dll` / `pthreadVC3.dll` 不在 exe 旁。确认
  `build/native/windows-<arch>/` 里有它们（脚本从 `$VCPKG_ROOT/installed/<triplet>/bin` 捕获）。
- **`dart_api_dl.h not found`**：`flutter --version` 一次让 Flutter 下载 Dart SDK，或设置 `FLUTTER_ROOT`；
  没有 Flutter 的机器把同版本独立 Dart SDK 的 `bin` 放上 PATH（或设 `MORSECQ_DART_SDK_DIR`）即可。
- **libsodium `configure: error: C compiler cannot create executables`（macOS）**：失败时脚本会把
  `config.log` 里真正的编译错误和 `CC/CFLAGS/LDFLAGS` 打到日志；常见原因是 SDK 没被选中
  （`xcrun --sdk macosx --show-sdk-path` 为空 → `xcode-select --install` 或 `sudo xcode-select -s /Applications/Xcode.app`）。
- **`FORBIDDEN test hook ... found`**：该二进制以 `TIM2TOX_ENABLE_TEST_HOOKS=ON` 编出（Tim2Tox 自带的
  `build_ffi.sh` 默认如此）。删掉产物，用本仓库脚本重建。
- **`exports tim2tox_ffi_av_backend_toxav`**：混入了 toxee 的 ToxAV 版库。删除 `build/native/<target>` 重建。
- **换了 tim2tox 子模块版本**：`build/native/.work/<target>` 会增量重配；如遇诡异错误，删除该目录。
  libsodium 前缀 `build/native/.deps/` 与子模块无关，可保留。
