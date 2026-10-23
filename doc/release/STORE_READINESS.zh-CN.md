[English](STORE_READINESS.md)

# 商店与发行准备度 — 2026-10-23

本次以更新后的跨平台商店清单复审 MorseCQ 1.0.1+2（`icu.agentx.morsecq`）。产品是无账号、广告、购买、UGC 服务和网络后端的离线教育应用，导入素材是私人本地文件。界面提供 en、zh-Hans、zh-Hant、ja、ko、de、fr、es、pt、ru；这不代表十种商店文案/截图已完成。开发者账号、地区、法律主体、商店记录和审核状态均未查阅，须由所有者提供，不能猜测。

[上次全部 65 项审计](../testing/CROSS_PLATFORM_AUDIT.zh-CN.md)保留其有界 UI/生命周期证据；以下更新上架相关缺项。R 为所选路径要求，C 为满足触发条件时要求，A 为可选计划；它们与“已验证/待办/需设备/不适用”的证据状态不同。“未选定”并非永久不适用，也不代表任何商店认证。

## 渠道矩阵

| 渠道 / 地区 / 包模型 | 当前路径与证据 | 所有者后续动作 |
| --- | --- | --- |
| GitHub 开发制品 / 地区待定 | 已有 Android APK/AAB、未签名 iOS IPA、Mac PKG/ZIP、Windows x64 MSI/ZIP、Linux x86_64 DEB/RPM/tar；十个制品和校验和，只生成 release 草稿 | 记录版本、tag、哈希、权利与地区，单独批准发布。默认 Apple/Windows 开发包不是商店包或可信分发包。 |
| Apple App Store / iOS+iPadOS / 地区待定 | 有 `tool/build_ios_store.sh` 签名导出入口；CI 未签名 IPA 只证明编译与产物检查 | R：核实 Team/应用记录、协议、发行 profile、处理后的 build、隐私标签/报告、出口问卷、分级及文案/支持/隐私 URL；C：地区/trader 材料。离线审查不需要测试登录。 |
| 原生 Mac App Store / universal2 / 地区待定 | 未选定提交路径；原生应用有 sandbox，但无 Store 签名导出包与后台证据 | 决定同一 app record 添加 macOS 还是独立记录；配置商店签名/更新路径，测试 sandbox 麦克风、导入/导出、历史数据升级。Developer ID PKG 是另一路径。 |
| Developer ID 直接下载 / macOS universal2 | 已有开发 PKG/ZIP；显式发行模式按内到外签名、核对 Team/证书类别、公证并 staple 最终制品 | 提供真实身份、Team、notary profile，运行所有者入口并保留下载隔离/Gatekeeper、安装与升级证据。本次未使用真实凭据或公证服务。 |
| iOS 兼容版运行于 Apple silicon Mac / Vision Pro | 上次决定为验证前关闭兼容上架；原生 Mac 是另一二进制，实际后台可用性未知 | 所有者分别留存 App Store Connect opt-out。若启用或在同记录替换，验证插件、硬件降级和进度/设置数据连续性，原生 Mac 构建不证明兼容 iOS 行为。 |
| Google Play / Android mobile armv7、arm64、x86_64 / 地区待定 | 有 AAB/配套 APK，target36/min24，最终 native/manifest/alignment 检查；tag 签名须匹配所有者 upload SHA-256 | R：账号、包名、upload 与 Play 分发证书、Data safety/隐私、访问说明、广告/受众/分级、设备目录与实际投递 APK；C：个人账号封闭测试/生产访问。需 16 KB 真机/镜像运行、签名升级及审核证据；TV/XR/Wear/Automotive 非当前选定产品。 |
| Windows 直接下载 / x64 MSI+ZIP | 已有开发路径；CI 与本地发行门禁检查全部 PE 架构及 Flutter 标准 `data/app.so` ELF AOT 的 CPU；CI 另检查最终 ZIP 内容和实际 MSI Template Summary；发行模式校验全部 PE/安装器签名 | 所有者提供指纹，测试普通用户安装/升级/卸载及运行时依赖；不能以签名推定 SmartScreen 信誉。 |
| Microsoft Store hosted MSI/EXE / PC 非游戏 / 地区待定 | 候选，尚无商店提交路径，现有 MSI 源码 | C：10.2.9 要求版本固定不可变 HTTPS URL、离线/静默安装器、安装器及所有 PE 的可信签名；保留身份、分级、隐私和从最终 URL 安装证据。 |
| Microsoft Store MSIX / x64 / 地区待定 | 未选定，无 MSIX identity/package | 与 MSI 分别选择；所有者提供 Partner Center identity 后实现 capabilities、更新和 WACK。Microsoft 会重签商店提交包，不要仅为 Store MSIX 提交购买 CA 证书。 |
| Linux 直接下载 / Ubuntu24.04 基线 / x86_64 | DEB/RPM/tar 已有；检查 ELF machine 与媒体/托盘依赖，无发行版仓库批准 | 选定支持发行版/桌面会话及签名/更新信任；干净系统安装、麦克风/托盘、升级/卸载。能生成 RPM 不等于兼容所有发行版。 |
| Flathub / Snap Store | 均未选定，未生成 manifest/snap/listing | 所有者决定 runtime、confinement、portal/interface、权利和更新测试。Flathub 当前 manifest、提交及评审交互需人类处理，已知 AI 材料需披露；本项目 PR 不是 Flathub 提交。Snap stable 需合格 confinement 与真实 interface 授权。 |
| 华为 AppGallery / 中国大陆 Android APK | 未选定，详细公开审核文档未读到 | 所有者核对当前账号、APK 专属指引、资质/备案适用性、隐私标签及后台要求；HarmonyOS/快应用不是同一目标。 |
| 小米 / 中国大陆 Android APK | 未选定，已读公开上架要求 | 当前指引包含首启隐私同意/拒绝，以及与主体一致的开发者/联系/隐私材料。本离线应用当前刻意无接受门槛；选定渠道并确认设计后才加入该流程。 |
| OPPO / 中国大陆 Android APK | 未选定，公共文档需 JavaScript | 所有者取得迁移后的指引，核对主体、资质、隐私、审核访问与地区；Play 通过不能替代。 |
| WinGet、Homebrew Cask、F-Droid、发行版仓库 | 未选定额外路径 | 各自核对源码/依赖许可、identity、签名、recipe/hash 和安装更新；本次不生成提交。 |

## 清单记录

| ID | 状态 | 证据 |
| --- | --- | --- |
| P4 / Apple | 产物检查已验证；后台待办 | Mac 补入应用 privacy manifest，检查全部内嵌 manifest、十语言麦克风用途及签名功能权限，JSON 保留 SDK required-reason 清单。Archive privacy report、required-SDK 签名、标签及真实签名导出仍需所有者；不收集草稿不是表单已完成。 |
| P4 / Play | gate 已验证；需设备/所有者 | 最终 APK/AAB 的 manifest、SDK/权限/feature、每个 ELF ABI/PT_LOAD、stored APK ZIP 和 bundle 投递对齐；签名核对 upload 指纹及 AAB 内容。Play 分发证书、后台表单和 16 KB 执行另测。 |
| P8 | 不适用 | 无购买、付费解锁、billing SDK、订阅或权益服务；增加商业化时按渠道/地区重审。 |
| P9 / 账号、登录、UGC | 不适用 | 无自动/访客账号、第三方登录、用户通信和服务器发帖。清除本地学习不是服务器账号删除承诺。 |
| P9 / 受众、文案、权利 | 所有者待办 | 完成 Apple/Play/Microsoft 当前问卷、listing 语言、内容/截图权利、发布者/trader 与国家。教育应用不自动等于 Kids/Families；无障碍标签需完整流程验证。 |
| W4 / 直接制品 | 部分 | 开发/发行政策分离；无凭据、错误 Team/debug 证书和错误架构 fixture 拒绝。可信签名/公证、最终安装升级需要凭据/目标系统。 |
| W4 / 商店 | 所有者待办 | 区分 Mac Store/Developer ID、MSIX/hosted MSI、直接 Linux/Flathub/Snap 与国内渠道；未操作账号、买证书、生成 listing 或提交商店。 |
| X6 | 本机 Mac 产物已验证；CI gate；安装需目标系统 | 每平台 release CI 保留 `evidence-*`，包含模块哈希、identity、声明和架构。头部检查不证明目标机实际加载。干净安装、上一版本升级及受保护功能按渠道实测。 |

## 官方政策日期与来源

均于 **2026-10-23** 核对，真正发布时重查；时间阈值不硬写进检测器。

- [Apple 提交要求](https://developer.apple.com/news/upcoming-requirements/)当前移动提交需 Xcode26/SDK26；项目最低运行版本为 iOS14，与提交 SDK26 是独立数值；所有者须在发布时重查提交要求。[2.4.5](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility)是 Mac Store 路径；[出口](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/)与[无障碍披露](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/)还须核对后台，不猜资格或分级。
- [Play target API](https://support.google.com/googleplay/android-developer/answer/11926878)规定移动新应用/更新自 2026-08-31 使用 API36，延期取决于账号；[16 KB 指引](https://developer.android.com/guide/practices/page-sizes)当前写 2027-02-01 阻止不兼容更新，仍须实际二进制/运行验证。[App content](https://support.google.com/googleplay/android-developer/answer/9859455)及[个人账号测试](https://support.google.com/googleplay/android-developer/answer/14151465)为后台工作。
- [Microsoft 7.20](https://learn.microsoft.com/en-us/windows/apps/publish/store-policies#102-security)自 2026-10-22 生效，是 hosted MSI/EXE 签名依据；[MSIX 要求](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements)是另一包路径。
- [Flathub](https://docs.flathub.org/docs/for-app-authors/requirements#generative-ai-policy)人类边界如上；[Snap confinement](https://snapcraft.io/docs/explanation/security/snap-confinement/)与[发布](https://ubuntu.com/docs/snapcraft/9/how-to/publishing/publish-a-snap/)仅在选定后适用。
- 国内：[华为索引](https://developer.huawei.com/consumer/cn/doc/doccenter-submission/50000)、[小米当前要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)（2025-09-02 更新）、[OPPO 入口](https://open.oppomobile.com/new/developmentDoc/info?id=10035)；华为/OPPO 详细规则待所有者后台核验。[工信部通知](https://www.miit.gov.cn/jgsj/xgj/wjfb/art/2023/art_dd783a581c9644a4aee10afa582811db.html)适用于 APP 互联网信息服务提供者，本离线产品的具体渠道适用性由所有者核实，不编造备案号。

## 所有者证据与发行流程

在私有发布记录保存：账号/角色和已接受协议；下载价格；渠道/地区/受众；bundle/package/store ID；版本/build/上一版本；预期 upload 与投递证书指纹；确切制品哈希和报告；无需登录可访问的公开支持/隐私 URL；文案/截图/权利；审核操作；真实授权/安装更新；后台声明；审核与发布各自状态；操作人/track/分阶段发布和停止条件。凭据、审核密码及私有后台截图不入 Git。

已有站点路径来自 `site/_config.yml` 与应用链接配置，所有者在填表前须实际核对线上 URL、主体/联系信息和正文，本次不编造隐私网址/法律联系人。审核路线：全新启动 → 首课 → 参考 → Listen 授权/拒绝 → 导入/导出 → 我的清除，无需账号、付费功能或审核后端。

CI 报告与十个发布下载分开保留，符号亦独立。用上一签名版本创建进度，按所选渠道升级，再检查进度、拒绝麦克风、文件访问及卸载无残留进程。保留旧包和备份用于调查；停止 rollout 不会撤销已安装数据迁移。以向前修复为主，二进制降级需既有 B7 测试及单独签名更新路径。

## 所有者材料及获取位置

公开 ID、证书指纹及脱敏证据可进入发布记录。下表请所有者将既有材料配置到指定安全位置；不要在聊天、issue 或 Git 中发送私钥、keystore、密码、token 或未脱敏后台截图。本清单不授权创建账号、扩大权限或提交商店。

| 平台 / 材料 | 用途与所有者获取位置 | 安全配置位置 / 阻塞步骤 |
| --- | --- | --- |
| 所有选定渠道：发布主体、地区、受众、权利、上一版本 | 所有者开发者账号资料及应用记录；自有主体/联系、截图/内容权利记录 | 公开 ID 与脱敏决定保存在私有发布记录。阻塞提交路径、listing 和签名升级矩阵选择；未选渠道仍是条件项。 |
| Apple：Team ID、bundle/应用记录 ID、协议 | [Apple Developer 账号](https://developer.apple.com/account/)的 membership 与 Certificates, Identifiers & Profiles；App Store Connect 应用信息及 Agreements | `MORSECQ_APPLE_TEAM_ID` 是公开标识。所有者核对协议及身份一致性；阻塞 iOS 签名导出及 Apple 提交。 |
| iOS/iPadOS：既有分发身份及 App Store provisioning profile | Apple Developer 的 Certificates, Identifiers & Profiles，以及所有者 Xcode 的 `icu.agentx.morsecq` 签名/导出配置 | 私钥保存在所有者 keychain，profile 由 Xcode 管理；本机带 export 参数运行 `tool/build_ios_store.sh`。`.p12` 与密码不入 Git。阻塞最终签名 IPA 检查及设备安装。 |
| macOS 直接下载：既有 Developer ID Application / Installer 身份、公证 profile | Apple Developer 证书、签名 Mac 的 Keychain Access 以及所有者既有 `notarytool` keychain profile | 在签名机配置 `MORSECQ_MACOS_APPLICATION_IDENTITY`、`MORSECQ_MACOS_INSTALLER_IDENTITY`、`MORSECQ_APPLE_TEAM_ID`、`MORSECQ_NOTARY_PROFILE`。名称只是引用，不是密钥材料。阻塞可信 PKG/ZIP、公证和 Gatekeeper 资格验证；本次不调用公证服务。 |
| Google Play：既有 upload key、上传与投递证书 SHA-256 | 所有者既有上传 keystore；Play Console 该应用 App integrity / App signing 的证书页面。上传与 Play 投递证书可不同 | 所有者在仓库 Settings → Secrets and variables → Actions 配置已有四个签名 secret；非秘密上传指纹填 Actions variable `ANDROID_UPLOAD_CERT_SHA256`。本地 strict 使用 `MORSECQ_ANDROID_UPLOAD_CERT_SHA256`。阻塞 tag 签名/身份校验与签名升级；不要将 key 上传仓库。 |
| Windows 直接下载 / hosted MSI：既有可信签名证书 | 所有者证书提供方和签名机证书存储；用本机证书管理工具读取指纹 | `MORSECQ_WINDOWS_CERT_SHA1` 引用可访问的既有密钥，并使用 Windows SDK `signtool.exe`。阻塞最终 PE/MSI 可信签名；CI 开发 MSI 的安装不证明信任或 SmartScreen 信誉，本次不购买证书。 |
| Windows 随包 MSVC CRT：许可依据与维护负责人 | 实际 Visual Studio 安装的 About → License Terms，以及[官方许可目录](https://visualstudio.microsoft.com/license-terms/)；保留准确工具链 edition/version 的条款 | 所有者确认适用条款下的再分发权利，并随组件 NOTICE/hash 归档证据。阻塞公开再分发批准；app-local CRT 安全更新由应用发行维护，不能假设全局 updater 代劳。本次不购买或接受许可。 |
| Microsoft Store：产品/包 identity 与包模型选择 | 所有者 Partner Center 产品记录 / Product identity | 选择 hosted MSI 或 MSIX 后记录公开 identity；MSIX 仍需单独实现。Hosted MSI 另需所有者可控的版本固定不可变 HTTPS URL 与最终 hash。阻塞 Store 包与资料；不应仅为 Store MSIX 提交购买 CA 证书。 |
| Apple / Play / Microsoft：隐私、评级、商店素材、审核说明 | 所有者 App Store Connect App Privacy / App Review、Play Console App content、Partner Center 提交表单；以项目 app/SDK 清单和当前政策为依据 | 所有者在后台完成问卷，提供有权使用的本地化文案/截图，并未登录验证公开支持/隐私 URL。本离线无账号应用不需要审核登录。阻塞提交；十语言 UI 不证明十语言 listing 已完成。 |
| Linux / 额外商店及国内 Android，选定后适用 | 所有者选择支持发行版/会话、签名/更新信任和实际渠道；该渠道发布者后台提供 identity、备案适用性与必要权限 | 密钥留在所选所有者 secret store；包/沙盒/更新证据齐全前阻塞对应渠道。Flathub manifest 作者与提交仍是人工步骤，本次不生成新提交包。 |
| 各选定发行：上一签名包与设备访问 | 所有者发布归档 / 商店测试轨道及真机或干净系统实验室 | 记录版本/build、SHA-256、签名者与安装结果；阻塞旧版升级、受保护硬件/runtime 及普通用户验证。同版本 MSI repair 是另一测试。 |

## Windows MSI 安装后证据

进一步核对发现实际运行库遗漏：#49 最终 Windows ZIP（Builds run `39886425706`）没有 MSVC runtime DLL，但 `llvm-objdump -p` 检查真实 `morsecq.exe` 可见 `MSVCP140.dll`、`VCRUNTIME140.dll`、`VCRUNTIME140_1.dll` 导入。自带 Visual Studio 的 runner 会掩盖这一问题。现按 [Flutter Windows ZIP 分发指引](https://docs.flutter.dev/platform-integration/windows/building#building-your-own-zip-file-for-windows)，由 Windows CMake 的 `InstallRequiredSystemLibraries` 按目标工具链发现 release CRT，缺任一必需 DLL 即失败，并将其随 ZIP/MSI 放到 exe 旁。Native inventory 校 CPU/hash；安装冒烟校验 Microsoft 可信签名，并确认这些 CRT 与引擎实际从安装 payload 加载，不依赖 runner 全局运行库。所有者本地 strict 签名入口也会在查找签名工具前拒绝损坏/未签/非 Microsoft CRT，不会改用所有者签名覆盖原厂身份。Windows CI 对真实已签 CRT 的副本修改代码字节执行拒绝回归，原组件不变。

包内保留 `licenses/MSVC-runtime.txt`，记录工具链/目标与组件及官方许可入口。[Microsoft 再分发条件](https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files)仍需所有者确认适用的 Visual Studio 许可，并在发布记录归档该工具链的确切许可条款；代码实现不等于权利已批准。App-local CRT 的安全更新需随应用更新提供。本次不安装全局 redistributable、不创建凭据、不公开发布。


`tool/ci/test_windows_installer.ps1` 是已有 Windows release-build job 的必跑步骤：将最终 MSI 安装到含空格目录，按最终 ZIP 比对**每一个文件**（含资源），检查 PE/AOT 架构，要求实际窗口与 fresh-profile 优雅关闭；删除引擎 DLL 后执行 repair、重新检查并启动/关闭，再卸载，拒绝遗留 exe/进程。MSI 操作有超时；即使失败，也在 `evidence-windows/windows-installed` 保留 MSI 日志、安装/repair 清单及 `result.json`，报告绑定 MSI/ZIP SHA-256。[Microsoft 命令行文档](https://learn.microsoft.com/en-us/windows/win32/msi/standard-installer-command-line-options)定义静默、不重启与日志语义。

脚本拒绝非 GitHub-hosted runner、已有 MorseCQ 进程及按 Windows KnownFolder 与已装 exe 版本资源推导的已有 support/cache 目录。不靠改 `APPDATA` 重定向数据、不删除既有 profile、不修改应用持久化。CI runner 一次性且可能提权，不证明普通用户、纯净 OS、真实所有者签名、最低 OS 或旧版本升级。Windows 执行结果以精确 head 的 PR job 为准；其余平台仍按设备矩阵验证安装。

| ID | 状态 | 证据 / 剩余边界 |
| --- | --- | --- |
| W4、X6 / Windows MSI | 已加入安装后自动门禁；精确 head 结果见 PR | 实际安装 → 文件/CPU 校验 → 可见启动/优雅退出 → DLL 缺失 repair/重启 → 卸载，保留日志与制品 hash。可信签名、普通用户与旧版升级仍需所有者/设备。 |
| X5 | 已记录 parity | 本次测试 Windows MSI 与 Ubuntu 24.04 DEB；macOS 安装器、Linux RPM/Wayland 与移动商店投递升级仍需对应安装矩阵。五平台原有 payload gate 均保留。 |
| B2、W2 | 行为未改；冒烟执行默认关闭 | Fresh-profile close-to-tray 默认 false，不退出即失败。强杀只清理失败测试，不能当作优雅退出证据；未修改训练/session 层。 |

## Linux DEB 安装后证据

Linux release-build job 现将最终 DEB 安装进官方 Ubuntu 24.04 容器，记录 image digest、包 SHA-256 与 OS/CPU。先只安装 DEB 声明的依赖，在引入 X11 测试工具前逐个 installed ELF 执行 `ldd`，避免测试工具补装的库掩盖 Depends 遗漏。真实 GUI 使用镜像既有 `nobody` 用户与私有 XDG 目录，不挂载宿主桌面/数据/服务 socket。检查最终包与已装程序/launcher/desktop/icon 文件完全匹配、ELF CPU，要求可见可关闭窗口属于已装 executable 的同一 PID，并加载随包 Flutter engine；发送 `WM_DELETE_WINDOW` 后要求 exit0、启动进程组无残留，再检查卸载后程序文件消失且包不再是 installed 状态（apt remove 可保留配置状态）。强杀只清理失败，不算通过。

`evidence-linux/linux-installed` 保留测试工具安装前后的依赖闭包、模块 maps、窗口/进程、程序文件 hash 和失败日志。范围只是全新 Ubuntu 24.04 DEB/X11 软件渲染启动/关闭，不证明 RPM、Wayland、音频/托盘硬件、旧版升级或其他发行版/最低 OS。发行签名/更新信任及设备路径仍是独立所有者/工程项。65 项审计中的 X9 原生崩溃诊断、应用菜单/平板输入与折叠屏适配仍明确未完成，安装门禁不会让这些工程项变成已验证。

| ID | 状态 | 证据 / 边界 |
| --- | --- | --- |
| W4、X6 / Linux DEB | 已加入安装后自动门禁；精确 head 结果见 PR | 干净容器最终 DEB 安装、普通用户 GUI/PID/engine、优雅关闭、卸载，保留 image/package hash；其他包/会话/硬件/升级路径未验证。 |
| X5 | 已记录 parity | Windows MSI 和 Ubuntu DEB 已有安装后门禁；Mac/mobile/RPM 等矩阵项仍需各自证据。 |

## 本机验证记录

以下测量、hash 及原测试数量为 CRT/安装后门禁补充前的 #49 历史基线。本轮变更和精确 head CI 证据见 [PR #50](https://github.com/agentx-icu/morsecq/pull/50)，不要把旧数量当作本轮最终结果。

macOS27.0.1 arm64、Flutter3.41.9、Xcode SDK26.4：release57.0MB，15个 Mach-O 全含 arm64+x86_64，九个隐私 manifest 和十语言用途检查通过。首轮产物检查抓到 Xcode 注入 `get-task-allow=true`，Release 关闭 base-entitlement 注入后签名权限检查通过。实际 PKG/ZIP 打包和最终 ZIP 解包检查通过。Android APK74.6MB/AAB55.1MB，三个 ABI 的30个模块、最终 manifest、16KB ELF/ZIP/AAB config 通过；本地 Android 为 debug 证书，不能用作分发。

Python 新产物/发行/签名/站点与既有资产/runtime/component 回归共47项通过（含已有 cache 回归为51项），JDK17.0.17 与 Temurin17.0.20+8 均通过；平台/用途本地化 Widget18项通过；根/tool 分析和复杂度/导入/shared/UI 门禁通过。真实所有者签名导出、Windows/Linux/iOS 目标系统及安装升级仍待测，CI 结果单列于 PR。精确本机制品哈希见[英文记录](STORE_READINESS.md#local-validation-record)，重建会改变哈希。

2026-10-23，现有 `/morsecq/privacy/`、`/morsecq/support/` 实测 HTTP404，而 `/morsecq/privacy.html` 为200，Pages 最近部署成功；原因是 Jekyll 页面未设置显式 permalink。现补英/中文 slash permalink 匹配应用 URL，PR Pages 构建在部署前核对六个真实渲染输出路径。该历史路由阻塞已由 #49 合并触发的既有 Pages 工作流解决。2026-10-23 再次未登录只读 GET，英/中文 privacy、terms、support 六个 slash 路由均为 HTTP200 且包含预期应用内容；本次复核未触发部署。法律/联系正文及后台声明仍需所有者确认，可达性不等于内容审批；未编造新隐私 URL/联系人/商店记录。

独立复查补充：本地 strict Windows/Android 入口现于签名/复制前运行相同 payload gate；Android 显式要求 bundletool/apkanalyzer 路径。三个入口负例通过。真实 Mac release 副本仅修改一个签名资源后被递归 codesign 检查拒绝，原包通过；真实 strict Android 尝试先通过 payload 检查，再拒绝 Debug 证书。

AAB 完整性改用 JDK17 `JarFile`：每条 payload 读至 EOF、要求唯一且一致的有效叶证书，拒绝未签名/篡改/重复条目与缺失 bundle 结构，发行模式另绑定所有者证书。PR Android 构建保留真实 AAB 签名报告；开发验证允许测试密钥，tag/本地发行拒绝 Debug。真实本地 AAB 及 manifest-last 副本在 JDK17.0.17/17.0.20+8 下均通过旧文字 gate 和新验证（175 个签名条目），没有观察到这些 MorseCQ 制品的 JDK 特定故障。五项真实签名 JAR 回归覆盖 manifest-last 正例及 unsigned/tamper/duplicate/结构缺失负例；旧 gate 会接受结构缺失 fixture。
