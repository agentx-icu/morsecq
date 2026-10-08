import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asks the OS for extra running time after the app leaves the foreground.
///
/// iOS grants a brief background window for local learning/preference writes.
/// Other platforms use [NoopBackgroundTaskApi]. No network task runs here.
abstract interface class BackgroundTaskApi {
  /// Starts a background task; returns an opaque token, or null when the OS
  /// refused (or the platform has no such concept).
  Future<int?> begin();

  /// Ends the task [token] identifies. Ending one that already expired is a
  /// no-op on the native side.
  Future<void> end(int token);

  /// The implementation for the running platform.
  static BackgroundTaskApi forPlatform() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
      ? MethodChannelBackgroundTaskApi()
      : const NoopBackgroundTaskApi();
}

/// Platforms without a suspension grace period: nothing to ask for.
final class NoopBackgroundTaskApi implements BackgroundTaskApi {
  const NoopBackgroundTaskApi();

  @override
  Future<int?> begin() async => null;

  @override
  Future<void> end(int token) async {}
}

/// iOS: `ios/Runner/AppDelegate.swift` answers on [channelName].
final class MethodChannelBackgroundTaskApi implements BackgroundTaskApi {
  MethodChannelBackgroundTaskApi({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'icu.agentx.morsecq/background_task';

  final MethodChannel _channel;

  @override
  Future<int?> begin() async {
    try {
      return await _channel.invokeMethod<int>('begin');
    } on Object catch (error) {
      // MissingPluginException (tests, an older native build) or the OS
      // refusing: the app still works, it just gets the default grace time.
      debugPrint('[BackgroundTaskApi] begin failed: $error');
      return null;
    }
  }

  @override
  Future<void> end(int token) async {
    try {
      await _channel.invokeMethod<void>('end', token);
    } on Object catch (error) {
      debugPrint('[BackgroundTaskApi] end failed: $error');
    }
  }
}
