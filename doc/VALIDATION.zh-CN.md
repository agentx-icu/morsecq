[English](./VALIDATION.md)

# 验证记录 — 2026-10-08

已验证源码：`1eb4784140bc11b106912482f6485c6b5dd13164`。工具链：Flutter 3.41.9 / Dart 3.11.5。

## 自动化检查

| 检查 | 结果 |
|---|---|
| [Analyze](https://github.com/agentx-icu/morsecq/actions/runs/37737215089) | 严格分析、源码守卫、包和应用测试通过。 |
| 应用测试 | 780 通过；跳过 2 个按需图片导出测试。 |
| 包测试 | 核心 92、DSP 107、音频 I/O 124、训练 270、无线电工具 18 通过；DSP 跳过 2 个已有的首块噪声底测试。 |
| 学习行为 | 引导节奏保存、抄收结果、逐字符独立证据、课程升级、课程完成、每日计划和模拟通联准备度通过。 |
| 持久化 | 首次启动、进度保存与重载、损坏数据恢复、后台保存、偏好及确认后清除数据通过。 |
| 工具回归 | 截图导入 19、Apple 插件缓存 4、macOS 安装器 3、macOS 运行时 9、发布产物完整性 7 项检查通过。 |
| [平台构建](https://github.com/agentx-icu/morsecq/actions/runs/37737215290) | 五个平台的必需构建全部通过。 |
| [桌面 E2E](https://github.com/agentx-icu/morsecq/actions/runs/37737214821) | macOS、Linux、Windows 启动、持久化、中英文入门路径及全部 12 个截图场景通过。 |
| [视觉矩阵](https://github.com/agentx-icu/morsecq/actions/runs/37737214831) | 38 个配置、76 张 PNG，覆盖十种语言、五种风格、浅深色及手机/桌面布局。 |

入门路径覆盖六次辅助听辨、单字符及三字符引导抄收、正确键控 K 后从引导发报 K 进入 M。引导练习保持科赫第一课不变。本地 iPhone 和 Android 也通过了该路径。

DSP 跳过项涉及极低音量首块噪声可能产生多余起始符号的问题。应用中的按需图片导出测试由截图及视觉工作流执行。

## 截图与安装包

[图库](screenshots/README.zh-CN.md)包含 **144 张截图**：12 个场景 × 中英文 × macOS/iPhone/iPad/Android/Linux/Windows。

| 目标 | 已验证安装包 |
|---|---|
| Android | APK、AAB |
| iOS | IPA |
| macOS | Universal2 PKG、ZIP |
| Linux | x86_64 DEB、RPM、tar.gz |
| Windows | x64 MSI、ZIP |

平台构建输出的 **10 个安装包**均已下载并检查产物完整性、SHA-256 及归档完整性。macOS 中全部 Mach-O 架构符合 **13.0** 最低运行时要求，universal2 应用通过深层代码签名校验；PKG 包含一个根应用且没有 relocation 项。Android 安装包包含三种必需 ABI，不申请 Internet 权限。

复现命令见[测试指南](testing/TEST_PYRAMID.zh-CN.md)、[构建指南](operations/BUILD_AND_DEPLOY.zh-CN.md)和[截图指南](../tool/screenshots/README.zh-CN.md)。
