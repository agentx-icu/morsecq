package com.tencent.chat.tencent_cloud_chat_sdk;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * morsecq overlay: the generated plugin registrant instantiates this class;
 * morsecq never uses the method channel (everything goes through
 * libtim2tox_ffi via dart:ffi), so attaching is a no-op.
 */
public class TencentCloudChatSdkPlugin implements FlutterPlugin {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {}

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
