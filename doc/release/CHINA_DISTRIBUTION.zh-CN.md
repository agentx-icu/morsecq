# 中国区分发准备清单

本文档用于 MorseCQ 1.0.0+1 的中国区分发准备。当前应用包名为 `icu.agentx.morsecq`，应用名称为 MorseCQ，主功能为无需账号、无需联网的离线莫尔斯电码训练。

## 推荐顺序

1. Android：华为、小米、OPPO、vivo、腾讯应用宝。
2. Windows：Microsoft Store（MSIX）和官网/Gitee 直链。
3. Linux：deepin/UOS，再评估麒麟、openKylin 和 Flathub。
4. iOS：中国大陆 App Store，必须使用个人 Apple Developer 团队，不能使用现有公司团队。

## Android 提交资料

- 包名：`icu.agentx.morsecq`
- 版本：`1.0.0+1`，对应 Git 标签 `v1.0.0`
- 建议分类：教育；工具/参考可作为备选。不要填“通信”，应用本身不提供聊天或网络服务。
- 权限：仅 `RECORD_AUDIO`，且麦克风功能由用户主动启动；麦克风硬件标记为可选。
- 网络：正式 Android Manifest 不声明 INTERNET；学习数据、设置、素材和录音保存在本机。
- 数据安全说明：无账号、无广告、无分析 SDK；说明麦克风音频只用于实时解码，并按实际实现填写是否保存录音。
- 包体：使用正式签名 AAB/APK，禁止使用 debug key；固定并妥善保管发布签名。
- 素材：应用图标 `apps/morsecq/icon/app_icon_1024.png`；中文截图在 `doc/screenshots/android/zh/`。
- 隐私、支持和条款：`site/zh-CN/privacy.md`、`site/zh-CN/support.md`、`site/zh-CN/terms.md`。提交前必须确认这些页面已部署到公开 HTTPS 地址。

建议商店文案：

- 短描述：离线莫尔斯电码训练：从 K/M 听辨到 Koch 抄收、发报与复习。
- 长描述：MorseCQ 是无需账号、无需联网的莫尔斯电码学习工具。通过 Koch 课程、听抄、发报、间隔复习、模拟通联、参考手册、双向翻译器、中文电报码、麦克风实时解码和业余无线电工具，帮助初学者与爱好者系统练习。学习数据保存在设备上，不含广告、分析或聊天服务。

## 中国大陆合规检查

- 如果在中国大陆提供互联网信息服务或通过大陆分发平台上线，应先确认 APP 备案主体、接入服务商/分发平台和备案展示要求。
- 隐私/支持网站使用的域名和服务器是否需要 ICP 备案，应单独确认；ICP 备案不等于 APP 备案。
- 教育类应用可能触发主管部门的额外材料要求；提交前由实际运营主体和法律顾问确认。
- 中国区 iOS 还会在 App Store Connect 校验 ICP 备案信息；游戏、新闻、出版、宗教等类别有额外许可要求。MorseCQ 不应按游戏或通信服务申报，最终分类以商店审核为准。

## 签名与发布门禁

- Android 发布必须配置四个签名值：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`。
- 没有签名时只能做明确标注为测试用途的 debug 构建，不能上传商店。
- 不要把密钥、证书、Profile、密码或账号配置提交到 Git。
- 现有公司 Apple 团队下的 `icu.agentx.morsecq` 记录不用于本项目的个人发布；个人 iOS 发布需先准备独立个人团队。
