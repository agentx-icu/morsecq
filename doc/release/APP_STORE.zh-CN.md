[English](./APP_STORE.md)

# App Store 上架（iOS / iPadOS）

**策略（2026-10-07）：** App Store 版本是**纯离线的莫尔斯电码训练器**——没有聊天、没有身份，
App 自身不发起任何网络连接。它在构建期选择（`MORSECQ_CHAT=false`，见
`apps/morsecq/lib/di/app_features.dart`），只能由 `tool/build_ios_store.sh` 生成。Android、
桌面和自行构建的版本保留 Tox 聊天。其他决定：许可证 **GPL-3.0**；**不上中国大陆区**；
任何地方都不提供邮件（技术支持走 GitHub issues）；签名另行配置。

## 1. 状态

| 事项 | 状态 |
|---|---|
| 离线构建开关、三个标签页（学习 / 参考 / 我）、本地学习档案 | 已在仓库 |
| `tool/build_ios_store.sh`：不含 Tim2Tox pod、派生 `Info-Store.plist`、校验归档 / IPA | 已在仓库；2026-10-07 已校验未签名归档 |
| Bundle id `icu.agentx.morsecq`、显示名 MorseCQ、版本 `1.0.0`（构建号 4） | 已在仓库 |
| 1024×1024 无 alpha 图标；麦克风 / 相机用途说明（10 种语言） | 已在仓库 |
| App 隐私清单（`ios/Runner/PrivacyInfo.xcprivacy`） | 已在仓库（§6） |
| 商店构建中 `ITSAppUsesNonExemptEncryption = NO` | 由商店脚本生成（§7） |
| 隐私政策 / 使用条款 / 技术支持页，App 内“我 → 关于”可达 | `site/` → GitHub Pages（2026-10-05 已启用，`site/` 合入 `master` 后上线） |
| 6.9 英寸 iPhone + 13 英寸 iPad 截图，中英文，离线版本，RGB | `doc/screenshots/{ios,ipad}/`（§10） |
| 分发证书、App Store 描述文件、`DEVELOPMENT_TEAM` | **负责人——待办** |
| App Store Connect 建 App 记录、预留名称 | **负责人——待办** |

## 2. App 信息

| 字段 | 值 |
|---|---|
| 名称 | MorseCQ |
| 副标题（≤ 30 字符） | 英文：Learn Morse code, offline；中文：离线学习莫尔斯电码 |
| 主类别 | 教育 |
| 次类别 | 参考 |
| 内容版权 | 不含第三方内容 |
| 价格 | 免费，无 App 内购买 |
| 供应地区 | 除**中国大陆**外的所有地区 |

**推广文本（≤ 170）**

> 用 Koch 课程、抄收与拍发练习和 QSO 模拟器学会莫尔斯电码——完全离线，无需账号，不收集任何数据。

**描述（zh-Hans）**

> MorseCQ 教你莫尔斯电码——全部在你的设备上完成，无需账号，不收集任何数据。
>
> 学习
> • Koch 法课程，支持 Farnsworth 间隔与每日目标
> • 抄收练习：字符、单词、缩语、Q 简语、呼号、数字、QSO 与比赛交换
> • 屏幕手键或双桨电键拍发练习，实时解码与节奏诊断
> • 今日计划、间隔重复、混淆矩阵与水平测试
> • QSO 模拟器、模拟电波条件和自己的练习材料
> • 中文电码练习
>
> 收听与查阅
> • 在设备上从麦克风解码莫尔斯电码
> • 字母表、Q 简语、缩语、翻译器和无线电工具（梅登黑德网格、频段、天线长度、RST）
>
> MorseCQ 是自由软件（GPL-3.0）。

英文描述、推广文本见英文版文档。

**关键词（≤ 100，zh-Hans）**：`莫尔斯,摩尔斯,电码,CW,业余无线电,火腿,电报,Koch,QSO,电键,训练,离线`

**关键词（英文）**：`morse,cw,ham,amateur radio,koch,telegraph,qso,code,trainer,keyer,paddle,offline`

| URL | 值 |
|---|---|
| 技术支持 URL | https://agentx-icu.github.io/morsecq/zh-CN/support/（英文：/support/） |
| 营销 URL | https://agentx-icu.github.io/morsecq/ |
| 隐私政策 URL | https://agentx-icu.github.io/morsecq/zh-CN/privacy/（英文：/privacy/） |
| 许可协议 | Apple 标准 EULA（条款页有链接；软件本身以 GPL 为准） |

**年龄分级**：所有内容问题都回答**否 / 无**（没有用户之间的消息或聊天、没有用户生成内容、
没有网页访问、没有广告、没有赌博、没有成人主题）。预计结果：**4+**。

## 3. 公开站点

`site/` 存放隐私政策、使用条款和技术支持页（中英文），区分离线的 App Store 版本和聊天版本。
`.github/workflows/pages.yml` 在推送到 `master` 时部署。支持渠道是 GitHub issues
（`site/_config.yml` 的 `support_url`）；不提供邮件（准则 1.5 要求有可用的联系方式，技术支持页提供了）。

## 4. 版本与构建

- `apps/morsecq/pubspec.yaml` 的 `version: 1.0.0+4` → 1.0.0（构建号 4）。每次上传构建号都必须递增。
- 构建（签名配置好之后）：在仓库根目录运行 `tool/build_ios_store.sh`。脚本会生成被忽略的
  `ios/Runner/Info-Store.plist` 和 `ios/Flutter/Store.xcconfig`，在不含 Tim2ToxFFI 的情况下
  `pod install`，执行 `flutter build ipa --release --dart-define=MORSECQ_CHAT=false`，然后校验：
  归档里的 App（以及导出的 IPA）必须没有 `tim2tox_ffi.framework`、没有 libsodium / toxcore
  符号、包含隐私清单、且 `ITSAppUsesNonExemptEncryption = false`，否则失败。退出时恢复聊天
  版本的 pods。这个构建**不需要** `tool/build_ios_ffi.sh`。`--no-codesign` 产出经过校验的未签名归档。
- 用 Transporter 或 `xcrun altool` 上传 `apps/morsecq/build/ios/ipa/*.ipa`，然后查看上传后的
  邮件里有没有 ITMS 警告。
- 不要上传不经脚本构建的 iOS 包：直接 `flutter build ipa` 得到的是聊天版本。

## 5. App 隐私（"营养标签"）

**不收集数据。** 商店版本没有服务器、账号、统计、广告、崩溃上报或跟踪 SDK，也没有自己的
网络代码；学习数据和麦克风音频只在设备上处理。跟踪：**否**。

## 6. 隐私清单

`apps/morsecq/ios/Runner/PrivacyInfo.xcprivacy`（Runner target 资源）：不跟踪、不收集数据；
UserDefaults `CA92.1`、文件时间戳 `C617.1`。Flutter 与各插件自带隐私清单。Tim2Tox 框架
（及其清单 `tool/ci/ios/tim2tox_ffi.PrivacyInfo.xcprivacy`）不在商店版本中。

## 7. 出口合规

商店版本不含非豁免加密：Podfile 去掉了 Tox 协议栈（c-toxcore、libsodium），其余代码只使用
Apple 系统自带的加密（系统发起的 HTTPS、钥匙串）。商店脚本以 `Info-Store.plist` 构建，其中
`ITSAppUsesNonExemptEncryption = NO`，因此 App Store Connect 不会问加密问题，这个版本也不需要
法国申报或美国自我分类报告。（聊天版本的 `Info.plist` 仍为 `YES`，它们不通过 App Store 分发。）

## 8. App 审核信息

- 需要登录：**否**（没有账号）。
- 联系人：负责人姓名、电话、邮箱（只给 Apple，不公开）。
- 备注：原样粘贴英文版 §8 的 Notes（审核团队使用英文）。

## 9. 准则对照

| 准则 | 商店版本如何满足 |
|---|---|
| 1.2 用户生成内容 | 不适用：没有聊天，没有用户内容 |
| 1.5 开发者信息 | 技术支持 URL 提供可用的联系方式（GitHub issues） |
| 2.1 完整性 | 没有占位内容；所有可见功能都能离线使用 |
| 5.1.1 隐私 | App Store Connect 和 App 内（我 → 关于）都链接隐私政策；不收集数据；没有需要删除的账号 |
| 5.1.2 数据使用 | App 不发送任何数据（用户自己的设备备份可能包含其数据） |

## 10. 截图

`tool/screenshots/capture.sh --platforms ios,ipad` 会启动 iPhone 17 Pro Max（6.9 英寸，
1320×2868）和 iPad Pro 13-inch（2064×2752）模拟器，截取**离线版本**
（`MORSECQ_SHOT_VARIANT=offline`：学习、统计、训练设置、听抄练习、拍发练习、参考、翻译器、
收听、我）为 RGB PNG；尺寸不符或带 alpha 的帧会被拒绝。从 `doc/screenshots/ios/<locale>/` 和
`doc/screenshots/ipad/<locale>/` 上传（`en` → 英文，`zh` → 简体中文）。建议顺序：`learn_home`、
`receive_drill`、`send_practice`、`stats`、`reference`、`translator`、`listen`、`training_settings`、`me`。

## 11. 许可证

MorseCQ 为 GPL-3.0。负责人在知悉 GPL 与 App Store 条款长期存在争议的前提下选择以 GPL-3.0
发布；源代码公开，并在 App（我 → 关于）和条款页提供链接。商店版本不包含 Tim2Tox 和 c-toxcore。

## 12. 聊天版本

Android、macOS、Linux 和 Windows（以及自行构建的版本）保留 Tox 聊天、屏蔽、带版本号的社区
准则同意页（`kTermsVersion` 2，没有举报流程）以及 `ITSAppUsesNonExemptEncryption = YES`。
如果将来要通过 App Store Connect 分发 iOS 聊天版本，需要改用聊天版本的答案（加密：标准算法、
ECCN 5D992.c、美国 BIS 年度自我分类报告、法国申报；以及准则 1.2——届时需要重新提供举报机制）。
