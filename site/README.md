[简体中文](./README.zh-CN.md)

# MorseCQ website

The Jekyll site contains the current account-free offline product page, privacy statement, terms and support pages in English (`site/*.md`) and Simplified Chinese (`site/zh-CN/*.md`). Keep both language variants in sync with the application. Release builds on Android ask for privacy consent before opening the learning screen for the first time. The app provides technical support guidance locally.

The Pages workflow (`.github/workflows/pages.yml`) builds `site/` with `actions/jekyll-build-pages` and deploys it on every `master` push that touches `site/**`, or on manual dispatch. To preview locally, run a GitHub Pages–compatible Jekyll with `jekyll serve --source site`. Product screenshots come from `tool/screenshots/capture.sh`; design concepts are labeled separately.
