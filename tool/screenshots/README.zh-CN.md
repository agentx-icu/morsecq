# 真实产品截图

运行 `bash tool/screenshots/capture.sh --platforms macos --locales en,zh`，或选择 ios、ipad、android、linux、windows。截图测试只写临时本地学习档案，使用真实 Flutter 界面与学习数据，不包含 Tox 或账号。

所有平台统一九个场景：learn_home、stats、training_settings、receive_drill、send_practice、reference、translator、listen、me。全部语言/场景通过完整性、尺寸、非空和重复帧检查后才更新图库。使用 `--from <CI 截图根目录>` 导入远端结果，源与目标不得重叠。

iOS/iPad 自动选择 App Store 尺寸模拟器。桌面默认 1280×800。支持 `--out`、`--keep`、`--device` 和 `MORSECQ_SHOT_THEME`。不要使用旧聊天截图代表当前离线产品。`doc/designs/product-2026-10-08/` 是概念图，不是真实截图。
