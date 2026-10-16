[English](./README.md)

# MorseCQ 网站

Jekyll 站点包含当前无需账号的离线产品页、隐私声明、使用条款和支持页面，提供英文（`site/*.md`）与简体中文（`site/zh-CN/*.md`）两个版本。两个语言版本都要与应用保持一致。开始学习不需要账号，也不需要同意任何协议；外部支持链接只在用户操作后打开。

Pages 工作流（`.github/workflows/pages.yml`）使用 `actions/jekyll-build-pages` 构建 `site/`，在每次修改 `site/**` 的 `master` 推送或手动触发时部署。本地预览请使用与 GitHub Pages 兼容的 Jekyll 运行 `jekyll serve --source site`。产品截图来自 `tool/screenshots/capture.sh`；设计概念图单独标注。
