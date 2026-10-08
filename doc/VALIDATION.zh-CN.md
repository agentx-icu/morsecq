# 验证记录 — 2026-10-08

范围：MorseCQ 首个无需账号的离线学习版本 **1.0.0+1**。安装后直接进入学习 / 参考 / 我的。已移除聊天、注册、账号及 Tim2Tox、Tencent SDK 集成。

## 代码与回归检查

- 应用测试 **701 项通过、1 项跳过**。跳过项是按需开启的视觉样式导出器，通过 `MORSECQ_RENDER_STYLES` 启用。
- 保留的五个包测试均通过；移除聊天练习元数据后，训练包当前 **212 项测试通过**。
- 首次启动导航、共享控制器重试、后台写入、确认清除的持久化及学习界面重载回归通过。
- 根目录 Flutter 分析零问题。分层、本地化、复杂度门禁及 actionlint、shellcheck、`git diff --check` 均通过。
- 截图流程 **12 项回归通过**；macOS 安装包组件选择 **3 项回归通过**。
- `dart pub get --enforce-lockfile` 通过；解析图共 155 个包，不含 Tim2Tox、Tencent 或 MorseCQ 聊天包。

初始实现提交 `396a7c1` 已通过[分析流水线](https://github.com/agentx-icu/morsecq/actions/runs/37721025673)、[全部五个平台 Release 构建](https://github.com/agentx-icu/morsecq/actions/runs/37721026135)和[三个桌面 E2E 作业](https://github.com/agentx-icu/morsecq/actions/runs/37721025982)。后续修改更新文档及不影响渲染的本地化描述、在本地构建中强制锁文件，并删除历史安装包改名脚本。最终提交 CI 见 [PR #27](https://github.com/agentx-icu/morsecq/pull/27)。

## 发布产物

| 平台 | 已验证产物 |
| --- | --- |
| macOS | 本地 Release、universal2 PKG 与 ZIP；CI Release 打包亦通过。 |
| iOS | 本地 unsigned Release IPA；CI Release 打包亦通过。 |
| Android | 本地 Release APK 与 AAB；CI Release 打包亦通过。 |
| Linux | CI Release DEB、RPM、tar.gz 打包通过。 |
| Windows | CI Release MSI 与 ZIP 打包通过。 |

本地产物位于 `dist/<平台>/`。应用标识均为 `icu.agentx.morsecq`，版本 1.0.0、构建号 1。macOS 深度签名验证及 ZIP 完整性通过。展开的 PKG 固定安装到 `/Applications/MorseCQ.app`，重定位条目为零、应用版本条目只有一个，且不含历史改名脚本。IPA/APK/AAB 完整性及 APK、AAB 签名验证通过。Android 使用本地 debug 测试签名；iOS 未签名；macOS 应用为 ad hoc 签名，安装包未签名。

Android Release 仅申请 `RECORD_AUDIO`、`VIBRATE` 和本包作用域的动态接收器权限，不含网络、相机或聊天通知权限。本地 macOS、iOS、Android 归档均不含 Tim2Tox、Tencent 或 toxcore 条目。

集成测试后使用标准 Flutter Release 构建命令。Flutter 3.41.9 的 `--no-pub` 会跳过原生插件注册文件重建，可能保留仅用于开发的 Android 集成测试注册器；仓库构建脚本及 CI 通过标准构建命令刷新这一状态。

## 截图与分发

六个平台图库共 **108 张真实截图**：macOS、iPhone、iPad、Android、Linux 和 Windows 均含九个场景及英文、简体中文。前四个平台使用本地捕获，Linux/Windows 使用成功的桌面 E2E 产物。[图库说明](screenshots/README.zh-CN.md)记录尺寸与来源；[产品设计概念图](designs/product-2026-10-08/README.zh-CN.md)单独标注。

版本标签通过必需门禁后才生成草稿 GitHub Release 与 SHA256SUMS；PR 不运行发布作业。商店分发仍需拥有者提供 Android/Apple 签名、按分发需要完成 macOS Developer ID 签名与公证，以及验收真实设备的麦克风、闪光灯、实体键、触觉反馈和持久化。本次工作未发布商店版本。
