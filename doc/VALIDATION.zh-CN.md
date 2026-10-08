# 验证记录 — 2026-10-08

范围：MorseCQ 首个无需账号的离线学习版本 **1.0.0+1**，通过正常合并 `7cffd42` 完整保留上游教学更新 `5631376`。安装后直接进入学习 / 参考 / 我的；不包含聊天、注册、Tox 身份、Tim2Tox/Tencent 集成或历史导入功能。

## 代码与教学检查

- 应用 **780 项通过、2 项跳过**；两项为按需开启的样式预览与视觉矩阵导出器，矩阵另行开启并验证通过。
- 保留包通过数：核心 **92**、DSP **107**、音频 I/O **124**、训练 **270**、无线电工具 **18**。DSP **2 项已有噪声底限制用例跳过**：异常安静的首个噪声块（包括 44.1 kHz 录音）可能产生多余前导字符。这是已有算法限制，不是原生平台测试跳过。
- 首次安装直接提供第一课。测试覆盖引导节奏保存、真实抄报结论、逐字符近期独立证据、课程挑战升级、最终课程完成、每日计划重点、模拟通联准备度，以及两个新增进度字段的保存、重开与损坏回退。
- 所有包 / 应用 / 工具分析零问题；复杂度、分层、本地化门禁通过（486 个源码文件 / 213 个 UI 文件），actionlint、shellcheck、`git diff --check` 通过。固定依赖图含 155 个包，不含 Tim2Tox、Tencent 或 MorseCQ 聊天包。
- 截图导入 / 发布 **19**、Apple 插件缓存 **4**、macOS 安装包组件 **3**、发布资产完整性 **7** 项回归通过；语言 / 样式截图配置 **4** 项回归包含在应用测试中。

整合后的运行时 `7cffd42` 通过[分析](https://github.com/agentx-icu/morsecq/actions/runs/37733546824)、[全部五个平台 Release 构建](https://github.com/agentx-icu/morsecq/actions/runs/37733547331)、[三个桌面 E2E 作业](https://github.com/agentx-icu/morsecq/actions/runs/37733546823)及[视觉矩阵](https://github.com/agentx-icu/morsecq/actions/runs/37733547328)。最终图库 / 文档提交的 CI 见 [PR #27](https://github.com/agentx-icu/morsecq/pull/27)。

## 真实界面与截图

macOS、Linux、Windows E2E 运行真实启动、本地持久化重开、英文 / 简体中文完整首日学习路径及十二个截图场景。iPhone 和 Android 的本地首日测试亦通过：六次辅助入门识别、单字符与三字符引导抄报，以及正确发出 K 后推进到 M。引导练习必须保持科赫第 1 课不变。自动答案验证软件行为，不证明学习者掌握或真实听觉效果。

六个平台图库共 **144 张真实截图**：十二个场景 × 英文 / 简体中文 × macOS/iPhone/iPad/Android/Linux/Windows。前四个平台重新本地捕获，Linux/Windows 从成功的教学整合 E2E 产物导入；导入后另以独立目录复验六平台完整发布合同通过。[图库](screenshots/README.zh-CN.md)记录尺寸与来源；没有复制原学习与聊天合并应用的截图。

真实字体矩阵本地与 CI 都生成 **38 个配置 / 76 张 PNG**，覆盖全部十种语言、五种样式、手机 / 桌面及浅色 / 深色。矩阵选择学习和参考作为代表页面，原生 E2E 覆盖全部产品场景。更新后的[产品设计](designs/product-2026-10-08/README.zh-CN.md)体现入门与引导练习，明确标注为概念而非真实截图。

## 真实发布产物

| 平台 | 教学整合源码的 CI 产物 |
| --- | --- |
| Android | APK 与 AAB |
| iOS | unsigned IPA |
| macOS | universal2 PKG 与 ZIP |
| Linux | x86_64 DEB、RPM、tar.gz |
| Windows | x64 MSI 与 ZIP |

已下载构建流水线 `37733547331` 的全部 **10 个真实教学整合产物**，通过 `verify_release_assets.sh v1.0.0`、SHA256SUMS 与 ZIP/tar 完整性验证；归档不含 Tim2Tox/Tencent/toxcore 条目。最终 HEAD 产物替换被 Git 忽略的 `dist/release-v1.0.0/` 工作集；源码流水线证明保存在同样忽略的 `dist/release-proof-37733547331-v1.0.0/`。应用标识为 `icu.agentx.morsecq`，版本 1.0.0、构建号 1。实际 Mach-O 检查确认 objective_c 的 macOS 13.0 要求，最终打包已统一 Runner/Podfile 部署最低版本。源码 PKG 无重定位条目且只有一个主应用版本条目，universal2 应用深度签名验证通过。

全部五平台构建、版本 / 标签匹配、十资产完整性和 SHA256SUMS 是草稿 GitHub Release 前置门禁；PR 正常跳过发布作业。未创建标签、公开 Release 或商店提交。缺少拥有者签名配置时 Android 使用 debug 测试签名，iOS IPA 未签名，macOS 未进行 Developer ID 分发签名 / 公证；拥有者分发签名及真实设备麦克风、实体键、触觉反馈和持久化验收仍需完成。

集成测试后使用标准 Flutter Release 构建命令；Flutter 3.41.9 的 `--no-pub` 可能保留开发用 Android 集成测试注册器，仓库构建与 CI 通过标准命令刷新。
