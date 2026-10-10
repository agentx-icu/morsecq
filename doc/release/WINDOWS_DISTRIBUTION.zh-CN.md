# Windows 中国区分发准备

## 目标渠道

1. Microsoft Store：首选正式商店渠道，使用 MSIX 和 Partner Center。
2. 官网与 Gitee：作为不依赖商店审核的官方下载入口，提供 Windows ZIP/MSI、SHA256SUMS、版本说明和隐私/支持页面。
3. WinGet：等正式 GitHub Release 和 SHA256 校验完成后提交清单。
4. Chocolatey：作为社区包管理器补充渠道，使用稳定 MSI 下载地址和校验值。
5. 腾讯软件中心、360 软件管家等：以收录/合作为主，不把它们当作唯一官方下载源。

## 当前仓库产物

- CI 目标：Windows x64。
- 构建：Flutter Windows release。
- 打包：WiX v3 生成 `morsecq-1.0.0-windows-x64.msi`，同时生成 ZIP。
- 模板：`packaging/templates/winget/` 和 `packaging/templates/chocolatey/`。
- 元数据：必须从同一版本的 `SHA256SUMS` 渲染，不能提交占位符或 `latest` 可变链接。

## 上架前阻塞

- 当前 Windows MSI 没有 Authenticode 签名；Microsoft Store 更适合改为 MSIX 并完成 Partner Center 验证。
- 需要在 Windows 机器上做安装、升级、卸载和数据保留测试。
- 需要确认应用图标、发布者名称、隐私政策、支持网址和中文截图。
- 需要为官方下载页选择稳定域名，并确保隐私/支持页面可通过公开 HTTPS 访问。

## 安全要求

- 不把证书、私钥、签名密码或商店凭据提交到仓库。
- 不用未签名 MSI 作为正式推荐安装包；未签名包只能用于内部测试。
- 每个版本只发布不可变 URL 和对应 SHA256；不覆盖已发布资产。
