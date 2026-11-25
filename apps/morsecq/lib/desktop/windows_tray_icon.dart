import 'package:flutter/services.dart';

const _channel = MethodChannel('morsecq/windows_tray_icon');

/// Whether Explorer still holds the app's notification icon registration.
Future<bool> windowsTrayIconAvailable() async =>
    await _channel.invokeMethod<bool>('isAvailable') ?? false;
