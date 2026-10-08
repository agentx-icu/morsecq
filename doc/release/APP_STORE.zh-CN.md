# 离线 App Store 构建

MorseCQ 安装后直接进入离线学习，无需注册，也不包含聊天网络服务。使用标准 iOS Release 配置；麦克风权限用于用户主动启动的实时解码。应用标识为 `icu.agentx.morsecq`，首个版本为 1.0.0、构建号 1。

通过拥有者的 Apple 签名配置运行 `bash tool/build_ios_store.sh`。使用[截图流程](../../tool/screenshots/README.zh-CN.md)提供当前 iPhone/iPad 截图，填写公开隐私与支持网址及完整商店信息，并在真实设备验收本地学习与学习素材文件选择。应用声明不使用非豁免加密。

CI unsigned IPA 在安装到设备前需要拥有者签名；App Store 提交使用已签名的商店构建。详见[构建指南](../operations/BUILD_AND_DEPLOY.zh-CN.md)及[验证记录](../VALIDATION.zh-CN.md)。
