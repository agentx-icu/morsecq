# MorseCQ

[English](README.md)

MorseCQ 是无需账号的离线莫尔斯电码学习软件，打开应用即可开始学习。电码聊天请使用 [DitMesh](https://github.com/agentx-icu/ditmesh)。

先从听辨点划与 K/M 开始，再练习引导识别、引导发报和独立抄报。科赫课程按逐字符证据通过挑战升级，练习总结明确区分辅助练习和课程掌握。提供水平测评、间隔复习、带准备度提示的模拟通联、学习素材、统计、参考手册、翻译器、中文电报码、麦克风解码、录音抄报工作台和业余无线电工具。手机、平板和桌面支持触摸与实体键盘操作，提供十种界面语言和五种视觉样式。

通过 **学习 / 参考 / 我的** 导航。启动实时音频解码时申请麦克风权限；文件选择与分享用于学习素材。

![MorseCQ 产品概念图](doc/designs/product-2026-10-08/product-concept.png)

查看[产品设计](doc/designs/product-2026-10-08/README.zh-CN.md)和[截图库](doc/screenshots/README.zh-CN.md)。

进阶学习提供跨次错题本、整词与整句听懂训练，以及首次通联、日常交谈和竞赛目标路线。模拟通联支持竞赛与 POTA 公园间交换、信息更正和部分重发。参考 CW Academy 进阶方向设计的原创练习全部离线运行，辅助成绩与独立掌握分开保存。见[进阶学习说明](doc/architecture/ADVANCED_LEARNING.zh-CN.md)。

## 构建与运行

使用 Flutter **3.41.9** / Dart **3.11.5** 及目标平台的 Flutter 构建工具。在仓库根目录解析 Pub workspace：

```sh
dart pub get --enforce-lockfile
cd apps/morsecq
flutter run -d macos
```

```sh
# 在仓库根目录执行
bash tool/test_pyramid.sh --level gates
bash tool/test_pyramid.sh --level unit
bash tool/test_pyramid.sh --level widget
./build_all.sh --platform macos --mode release
bash tool/ci/package_artifacts.sh --target macos
```

支持 Android 7.0+、iOS 14+、macOS 13+、Linux 和 Windows。平台工具及打包命令见[构建指南](doc/operations/BUILD_AND_DEPLOY.zh-CN.md)。

## 学习数据

学习进度、素材和录音保存在设备上。在「我的 → 清除学习数据」中确认后可删除这些内容，语言和外观设置会保留。卸载应用可能删除本地数据。

## 仓库结构

- `packages/morse_core`：字母表、时序、编码解码与中文电报码。
- `packages/morse_trainer`：课程、测评、间隔复习、评分与模拟通联。
- `packages/morse_dsp`：音频解码与 WAV 读取。
- `packages/radio_tools`：网格、距离、波段、CW 速度与 RST 工具。
- `packages/morse_io`：音频、键控与触觉反馈。
- `apps/morsecq`：应用、本地持久化与桌面窗口服务。

[学习架构](doc/architecture/OFFLINE_LEARNING.zh-CN.md) · [测试](doc/testing/TEST_PYRAMID.zh-CN.md) · [验证记录](doc/VALIDATION.zh-CN.md) · [隐私](site/zh-CN/privacy.md) · [支持](site/zh-CN/support.md) · [许可证](LICENSE)
