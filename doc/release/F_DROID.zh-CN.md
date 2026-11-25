[English](F_DROID.md)

# F-Droid 官方仓库准备

**2026-11-12 状态：**材料已写入当前工作区，尚未向 F-Droid 提交 issue/MR，应用未在官方仓库上架。所有者选择继续准备官方仓库材料，满足条件后再提交。

## 收录条件

[收录政策](https://f-droid.org/docs/Inclusion_Policy/#quality-control)通常要求应用已持续开发至少三个月；已有用户、作者已维护其他 F-Droid 应用或专为活动开发等情况可例外。

仓库中的首条应用提交为 2026-09-30。所有者表示尚无其他使用者，目前没有“已有用户”的例外证据。按此记录，**2026-12-30 只是最早满三个月的日期**，不代表届时必定通过或自动发布。正式提交前应重查维护情况、例外证据和最新政策。

## 已准备的材料

- `fastlane/metadata/android/en-US/`、`zh-CN/`：标题、简介、完整描述、更新说明、现有图标及每种语言六张真实 Android 截图。
- `tool/fdroid/icu.agentx.morsecq.yml`：fdroiddata 候选配方，构建通用 APK，保持上游 versionCode `2`，min SDK 24、target SDK 36，覆盖 armv7、arm64 和 x86_64。
- `tool/fdroid/icu.agentx.morsecq/remove-upstream-signing.patch`：在 F-Droid 清理签名配置前移除多行签名赋值，仅应用于其构建副本。
- `tool/fdroid/srclibs/ogg.yml`、`vorbis.yml`：新增源码库定义，配合 fdroiddata 已有的 Flutter、Opus 和 FLAC 定义。
- `tool/fdroid/MERGE_REQUEST.md`：提交草稿，未验证的项目保持未勾选。

配方中的 commit 是本次准备快照。正式申请前应先发布包含 Fastlane 文件的、经过验证的上游版本，再更新完整 commit、版本及更新说明；不要移动已有发布标签。F-Droid 维护者也可能要求把新增源码库改为上游 Git submodule。

## 音频依赖源码构建

`flutter_soloud` 4.1.7 自带预编译编解码库。配方在扫描前删除这些二进制，构建阶段使用其现有 Xiph 脚本，从固定的 Ogg、Vorbis、Opus、FLAC 源码重新编译。脚本中的 strip 工具目录改为 F-Droid 的 Linux 主机目录，保留音频功能，不使用 `NO_XIPH_LIBS`。

Flutter 固定为 3.41.9，NDK 固定为 `28.2.13676358`。完整源码 commit 见配方及[英文说明](F_DROID.md#source-built-audio-dependencies)。依赖升级时应同步更新 Pub 包路径和源码 pin。Pub cache 放在项目内部供扫描；官方 Flutter SDK 二进制按 F-Droid 的 SDK 例外规则处理。

## 验证记录与待办

fdroidserver 2.4.5 的 `readmeta`、`rewritemeta`、`lint -f` 已在官方分类配置下通过。签名补丁已通过 fdroidserver 的真实签名清理函数验证。

本机 macOS arm64 已从固定源码构建四个 ABI 共 24 个编解码共享库。ELF 架构、SONAME 与文件名、动态依赖可用性以及 64 位 16 KB 加载对齐均通过。详细本机记录在 `build/fdroid/source-codec-validation.json` 和 `build/fdroid/metadata-validation.json`。

**尚未验证**完整 F-Droid Linux 构建服务器流程、源码重建库与完整 APK 的集成，以及目标设备运行。提交前需在官方 Linux 环境执行完整构建和扫描，检查最终 APK，并测试安装、音频、拒绝麦克风授权及数据持久化。

候选配方采用 F-Droid 签名，不宣称能复现现有上游 APK；现有上游 APK 使用了预编译编解码库。首次收录前需确定并验证签名/可复现构建路径，不同渠道签名不能直接互相覆盖升级。私钥和密码不进入提交材料。

## 满足条件后的提交步骤

以[当前贡献指南](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md)及[快速指南](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)为准：

1. 发布上游元数据和经过验证的版本，更新配方固定版本，并重查重复收录及申请。
2. 在公开 fdroiddata fork 中，将配方复制到 `metadata/icu.agentx.morsecq.yml`，补丁放到 `metadata/icu.agentx.morsecq/`，两个新增库定义放到 `srclibs/`。
3. 在官方 Linux 构建环境执行 `fdroid readmeta`、`fdroid rewritemeta icu.agentx.morsecq`、`fdroid lint -f icu.agentx.morsecq`、`fdroid build -v -l icu.agentx.morsecq`，处理扫描发现并检查真实产物。
4. 据实补全提交草稿，创建 `New app: MorseCQ`。MR 提交或合并后，还需分别确认官方构建、签名及仓库发布结果。
