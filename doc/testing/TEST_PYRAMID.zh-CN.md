# 测试金字塔

当前全学习／训练入口、流程及保存边界的覆盖与修复见[学习与训练审计](LEARNING_TRAINING_AUDIT.zh-CN.md)。

`tool/test_pyramid.sh --level gates|unit|widget|e2e|all` 从根目录运行。gates 包含所有包/应用与工具的零问题分析、复杂度、分层及本地化检查；unit 验证 Morse 核心、训练、DSP、音频 I/O 与无线电工具；widget 验证本地学习、键控、参考、录音、统计和设置；e2e 在真实桌面或设备上启动应用、验证本地持久化、完整首日学习路径并遍历十二个截图场景。

默认安装必须无需账号立即打开学习，只有学习/参考/我的三个目标。确认清除学习数据时，先保存待写入内容并释放当前控制器，再删除学习文件并重建空白学习状态。生命周期暂停和桌面退出必须等待本地持久化。

E2E：`bash tool/test_pyramid.sh --level e2e --device macos`。截图：`bash tool/screenshots/capture.sh --platforms macos --locales en,zh`。CI 的 E2E 工作流通过手动运行或 PR 标签 `ci:e2e` 启用。没有后端开关或原生聊天测试。

Layout CI 在每次 push 和 pull request 时运行 `apps/morsecq/test/layout/layout_sweep_test.dart`：所有界面、应用外壳以及从“我”打开的页面，在十种语言下，以 1.0、1.3、2.0 三档字号，实时调整窗口经过手机竖屏 / 横屏、平板竖屏 / 横屏、桌面最小窗口和完整桌面尺寸。任何溢出或被省略号截断的文字都会失败。它需要真实的多语言字体（测试字体的方块字形会让拉丁文字宽得多），本地运行时请传入 `--dart-define=MORSECQ_MATRIX_FONT=<NotoSansCJK-Regular.ttc>` 和 `--dart-define=MORSECQ_MATRIX_MONO_FONT=<NotoSansMono-Regular.ttf>`；未传入时该测试会跳过。

按需运行的 Visual matrix CI 渲染十种语言及五种样式的手机 / 桌面浅色 / 深色界面，共38个合并去重配置、76张真实 PNG。通过同一 `ci:e2e` 标签或手动启用，详见[截图指南](../../tool/screenshots/README.zh-CN.md)。自定义截图配置必须显式指定独立输出目录，以保护标准图库。

`first_day_learning_test.dart` 以英文与简体中文使用真实播放与原生按键时序，完成首次“从这里开始”、六次辅助入门识别、单字符与三字符引导抄报，再正确发出 K 推进到 M。每次引导抄报都必须保持科赫课程第 1 课不变。这验证软件行为，不证明学习者已掌握。本地 E2E 命令与所有桌面 CI 都运行此测试。
