# 测试金字塔

`tool/test_pyramid.sh --level gates|unit|widget|e2e|all` 从根目录运行。gates 包含所有包/应用与工具的零问题分析、复杂度、分层及本地化检查；unit 验证 Morse 核心、训练、DSP、音频 I/O 与无线电工具；widget 验证本地学习、键控、参考、录音、统计和设置；e2e 在真实桌面或设备上启动应用、验证本地持久化并遍历九个截图场景。

默认安装必须无需账号立即打开学习，只有学习/参考/我的三个目标。旧数据导入必须保留源与现有本地备份、拒绝损坏或不安全文件，并且不会复制账号档案。生命周期暂停和桌面退出必须等待本地持久化。

E2E：`bash tool/test_pyramid.sh --level e2e --device macos`。截图：`bash tool/screenshots/capture.sh --platforms macos --locales en,zh`。CI 的 E2E 工作流通过手动运行或 PR 标签 `ci:e2e` 启用。没有后端开关或原生聊天测试。
