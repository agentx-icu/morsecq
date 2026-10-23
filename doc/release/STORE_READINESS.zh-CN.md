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
| Windows 直接下载 / x64 MSI+ZIP | 已有开发路径；CI 检查全部 PE 架构及实际 MSI Template Summary，发行模式校验全部 PE/安装器签名 | 所有者提供指纹，测试普通用户安装/升级/卸载及运行时依赖；不能以签名推定 SmartScreen 信誉。 |
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

- [Apple 提交要求](https://developer.apple.com/news/upcoming-requirements/)当前移动提交需 Xcode26/SDK26；部署最低 OS 是独立值，现有 iOS14 高于当前提交下限。[2.4.5](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility)是 Mac Store 路径；[出口](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/)与[无障碍披露](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/)还须核对后台，不猜资格或分级。
- [Play target API](https://support.google.com/googleplay/android-developer/answer/11926878)规定移动新应用/更新自 2026-08-31 使用 API36，延期取决于账号；[16 KB 指引](https://developer.android.com/guide/practices/page-sizes)当前写 2027-02-01 阻止不兼容更新，仍须实际二进制/运行验证。[App content](https://support.google.com/googleplay/android-developer/answer/9859455)及[个人账号测试](https://support.google.com/googleplay/android-developer/answer/14151465)为后台工作。
- [Microsoft 7.20](https://learn.microsoft.com/en-us/windows/apps/publish/store-policies#102-security)自 2026-10-22 生效，是 hosted MSI/EXE 签名依据；[MSIX 要求](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements)是另一包路径。
- [Flathub](https://docs.flathub.org/docs/for-app-authors/requirements#generative-ai-policy)人类边界如上；[Snap confinement](https://snapcraft.io/docs/explanation/security/snap-confinement/)与[发布](https://ubuntu.com/docs/snapcraft/9/how-to/publishing/publish-a-snap/)仅在选定后适用。
- 国内：[华为索引](https://developer.huawei.com/consumer/cn/doc/doccenter-submission/50000)、[小米当前要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)（2025-09-02 更新）、[OPPO 入口](https://open.oppomobile.com/new/developmentDoc/info?id=10035)；华为/OPPO 详细规则待所有者后台核验。[工信部通知](https://www.miit.gov.cn/jgsj/xgj/wjfb/art/2023/art_dd783a581c9644a4aee10afa582811db.html)适用于 APP 互联网信息服务提供者，本离线产品的具体渠道适用性由所有者核实，不编造备案号。

## 所有者证据与发行流程

在私有发布记录保存：账号/角色和已接受协议；下载价格；渠道/地区/受众；bundle/package/store ID；版本/build/上一版本；预期 upload 与投递证书指纹；确切制品哈希和报告；无需登录可访问的公开支持/隐私 URL；文案/截图/权利；审核操作；真实授权/安装更新；后台声明；审核与发布各自状态；操作人/track/分阶段发布和停止条件。凭据、审核密码及私有后台截图不入 Git。

已有站点路径来自 `site/_config.yml` 与应用链接配置，所有者在填表前须实际核对线上 URL、主体/联系信息和正文，本次不编造隐私网址/法律联系人。审核路线：全新启动 → 首课 → 参考 → Listen 授权/拒绝 → 导入/导出 → 我的清除，无需账号、付费功能或审核后端。

CI 报告与十个发布下载分开保留，符号亦独立。用上一签名版本创建进度，按所选渠道升级，再检查进度、拒绝麦克风、文件访问及卸载无残留进程。保留旧包和备份用于调查；停止 rollout 不会撤销已安装数据迁移。以向前修复为主，二进制降级需既有 B7 测试及单独签名更新路径。

## 本机验证记录

macOS27.0.1 arm64、Flutter3.41.9、Xcode SDK26.4：release57.0MB，15个 Mach-O 全含 arm64+x86_64，九个隐私 manifest 和十语言用途检查通过。首轮产物检查抓到 Xcode 注入 `get-task-allow=true`，Release 关闭 base-entitlement 注入后签名权限检查通过。实际 PKG/ZIP 打包和最终 ZIP 解包检查通过。Android APK74.6MB/AAB55.1MB，三个 ABI 的30个模块、最终 manifest、16KB ELF/ZIP/AAB config 通过；本地 Android 为 debug 证书，不能用作分发。

Python 新产物/发行/签名/站点与既有资产/runtime/component 回归共40项通过，平台/用途本地化 Widget18项通过；根/tool 分析和复杂度/导入/shared/UI 门禁通过。真实所有者签名导出、Windows/Linux/iOS 目标系统及安装升级仍待测，CI 结果单列于 PR。精确本机制品哈希见[英文记录](STORE_READINESS.md#local-validation-record)，重建会改变哈希。

2026-10-23，现有 `/morsecq/privacy/`、`/morsecq/support/` 实测 HTTP404，而 `/morsecq/privacy.html` 为200，Pages 最近部署成功；原因是 Jekyll 页面未设置显式 permalink。现补英/中文 slash permalink 匹配应用 URL，PR Pages 构建在部署前核对六个真实渲染输出路径。现网404在合并触发现有 Pages 部署并 GET 验证前仍阻塞提交，不编造新隐私 URL/联系人/商店记录。
