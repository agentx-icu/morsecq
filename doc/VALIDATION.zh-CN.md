# 验证记录 — 2026-10-08

范围：MorseCQ 首个无需账号的离线学习版本 **1.0.0+1**。安装后直接进入学习 / 参考 / 我的。已移除聊天、注册、账号及 Tim2Tox、Tencent SDK 集成。

## 代码与回归检查

- 应用测试 **703 项通过、2 项跳过**。跳过项为按需开启的样式预览和视觉矩阵导出器，分别通过 `MORSECQ_RENDER_STYLES` 与 `MORSECQ_RENDER_MATRIX` 启用。
- 保留的五个包测试均通过；移除聊天练习元数据后，训练包当前 **212 项测试通过**。
- 首次启动导航、共享控制器重试、后台写入、确认清除的持久化及学习界面重载回归通过。
- 根目录 Flutter 分析零问题。分层、本地化、复杂度门禁及 actionlint、shellcheck、`git diff --check` 均通过。
- 截图流程 **18 项回归通过**；macOS 安装包组件选择 **3 项回归通过**；发布完整性 **7 项回归通过**，覆盖缺失、空文件、额外文件、macOS 架构混用、符号链接、标签及校验清单。
- Apple 插件缓存清理 **4 项回归通过**。真实 CMake 在两个 Apple 平台目录中复现已移除的 Xcode 编译器路径，清理生成文件后重新配置成功；源码、其他包及另一平台保持完整。
- 新增截图配置 **4 项回归通过**，覆盖十种语言（含繁体中文脚本）、五种样式、参数拒绝及实际外观保存。真实字体的视觉矩阵本地生成 **38 个配置 / 76 张 PNG**，覆盖学习和参考页面；独立 Visual matrix CI 通过手动运行或 `ci:e2e` 标签启用。
- `dart pub get --enforce-lockfile` 通过；解析图共 155 个包，不含 Tim2Tox、Tencent 或 MorseCQ 聊天包。

运行时及打包实现 `8ff8dd4` 已通过[分析流水线](https://github.com/agentx-icu/morsecq/actions/runs/37722463165)、[全部五个平台 Release 构建](https://github.com/agentx-icu/morsecq/actions/runs/37722463344)和[三个桌面 E2E 作业](https://github.com/agentx-icu/morsecq/actions/runs/37722463151)。随后 `5ba1a57` 亦通过全部五平台构建、分析和三桌面 E2E；当前增加语言 / 样式视觉门禁，并移除发布前旧主题回退。最新 CI 见 [PR #27](https://github.com/agentx-icu/morsecq/pull/27)。

## 发布产物

| 平台 | 已验证产物 |
| --- | --- |
| macOS | 本地 Release、universal2 PKG 与 ZIP；CI Release 打包亦通过。 |
| iOS | 本地 unsigned Release IPA；CI Release 打包亦通过。 |
| Android | 本地 Release APK 与 AAB；CI Release 打包亦通过。 |
| Linux | CI Release DEB、RPM、tar.gz 打包通过。 |
| Windows | CI Release MSI 与 ZIP 打包通过。 |

本地产物位于 `dist/<平台>/`。应用标识均为 `icu.agentx.morsecq`，版本 1.0.0、构建号 1。macOS 深度签名验证及 ZIP 完整性通过。展开的 PKG 固定安装到 `/Applications/MorseCQ.app`，重定位条目为零、应用版本条目只有一个，且不含历史改名脚本。IPA/APK/AAB 完整性及 APK、AAB 签名验证通过。Android 使用本地 debug 测试签名；iOS 未签名；macOS 应用为 ad hoc 签名，安装包未签名。

已从构建流水线 `37722463344` 下载全部 **10 个当前 CI 产物** 到被 Git 忽略的 `dist/release-v1.0.0/`。`verify_release_assets.sh` 生成 SHA256SUMS，`shasum -a 256 -c SHA256SUMS` 对全部文件验证通过；ZIP/tar 完整性及无聊天传输组件检查亦通过。未创建版本标签或 GitHub Release。

Android Release 仅申请 `RECORD_AUDIO`、`VIBRATE` 和本包作用域的动态接收器权限，不含网络、相机或聊天通知权限。本地 macOS、iOS、Android 归档均不含 Tim2Tox、Tencent 或 toxcore 条目。

集成测试后使用标准 Flutter Release 构建命令。Flutter 3.41.9 的 `--no-pub` 会跳过原生插件注册文件重建，可能保留仅用于开发的 Android 集成测试注册器；仓库构建脚本及 CI 通过标准构建命令刷新这一状态。

## 截图与分发

六个平台图库共 **108 张真实截图**：macOS、iPhone、iPad、Android、Linux 和 Windows 均含九个场景及英文、简体中文。前四个平台使用本地捕获，Linux/Windows 使用成功的桌面 E2E 产物。[图库说明](screenshots/README.zh-CN.md)记录尺寸与来源；[产品设计概念图](designs/product-2026-10-08/README.zh-CN.md)单独标注。

版本标签通过必需门禁后才生成草稿 GitHub Release 与 SHA256SUMS；PR 不运行发布作业。商店分发仍需拥有者提供 Android/Apple 签名、按分发需要完成 macOS Developer ID 签名与公证，以及验收真实设备的麦克风、闪光灯、实体键、触觉反馈和持久化。本次工作未发布商店版本。
