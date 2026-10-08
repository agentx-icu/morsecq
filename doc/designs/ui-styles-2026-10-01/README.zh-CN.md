[English](./README.md)

# MorseCQ 页面风格

2026-10-01 的风格概念与归档界面预览。当前学习界面见[产品设计](../product-2026-10-08/README.zh-CN.md)和[截图库](../../screenshots/README.zh-CN.md)。

| 风格 | 视觉方向 | 体验 |
|---|---|---|
| 经典黄铜 | 暖黄铜 Material 配色 | 传统电台感 |
| 清爽现代 | 白色、青绿与细边框 | 层级清晰；默认风格 |
| 夜航电台 | 深蓝、薄荷青、琥珀与等宽电码 | 专注练习和夜间使用 |
| 纸感手册 | 纸白、陶土红与细分隔线 | 阅读和参考 |
| 清新卡通 | 薄荷绿、奶油黄、浅蓝与柔和圆角 | 轻松学习 |

## 概念图

![清爽现代](./a-modern.png)
![夜航电台](./b-radio.png)
![纸感手册](./c-paper.png)
![清新卡通](./d-cartoon.png)
![外观设置](./appearance-switcher.png)

## 外观操作

打开「我的 → 外观」，选择风格及跟随系统/浅色/深色，再点击「应用风格」。「恢复默认」预览清爽现代与跟随系统。切换外观保留课程进度和播放设置。

电码文字保持清晰，按键立即反馈，触摸区域至少 44 个逻辑像素。选中和播放状态使用颜色之外的提示，装饰动画遵循减少动态效果设置。

## 归档控件预览

| 风格 | 桌面 | 手机 |
|---|---|---|
| 经典黄铜 | [查看](./implementation-previews/classic-desktop.png) | [查看](./implementation-previews/classic-phone.png) |
| 清爽现代 | [查看](./implementation-previews/modern-desktop.png) | [查看](./implementation-previews/modern-phone.png) |
| 夜航电台 | [查看](./implementation-previews/radio-desktop.png) | [查看](./implementation-previews/radio-phone.png) |
| 纸感手册 | [查看](./implementation-previews/paper-desktop.png) | [查看](./implementation-previews/paper-phone.png) |
| 清新卡通 | [查看](./implementation-previews/cartoon-desktop.png) | [查看](./implementation-previews/cartoon-phone.png) |
| 外观选择 | [查看](./implementation-previews/appearance-desktop.png) | [查看](./implementation-previews/appearance-phone.png) |

在 `apps/morsecq` 下通过 `test/appearance/style_render_test.dart` 生成当前预览。使用 `--dart-define` 传入 `MORSECQ_RENDER_STYLES=true`、绝对路径 `MORSECQ_STYLE_RENDER_DIR`，以及指向中文字体文件的 `MORSECQ_PREVIEW_FONT`。
