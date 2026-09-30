import 'package:flutter/foundation.dart';

import '../local_notifications_api.dart';
import '../notification_payload.dart';

/// Recording [LocalNotificationsApi] for tests. Never touches a platform
/// channel; exposes everything the production plugin would have been told.
final class FakeLocalNotificationsApi implements LocalNotificationsApi {
  FakeLocalNotificationsApi({
    this.permissionGranted = true,
    this.initializeResult = true,
    this.launchPayload,
  });

  /// What [requestPermission] answers.
  bool permissionGranted;

  /// What [initialize] answers (false simulates a plugin failure).
  bool initializeResult;

  /// Returned once by [takeLaunchPayload] (cold-start tap).
  String? launchPayload;

  /// Every [show] call, in order (including replacements of the same id).
  final List<NotificationRequest> shown = <NotificationRequest>[];
  final List<int> cancelled = <int>[];
  int cancelAllCalls = 0;
  int refreshStringsCalls = 0;
  int permissionRequests = 0;
  bool initialized = false;

  final Map<int, NotificationRequest> _active = <int, NotificationRequest>{};
  ValueChanged<String>? _onTap;

  /// Notifications currently on screen (shown and not cancelled), by id.
  List<NotificationRequest> get active =>
      List<NotificationRequest>.unmodifiable(_active.values);

  NotificationRequest? get last => shown.isEmpty ? null : shown.last;

  /// Simulates the user tapping a notification with this payload.
  void tap(String payload) => _onTap?.call(payload);

  void tapTarget(NotificationTapTarget target) => tap(target.encode());

  @override
  Future<bool> initialize({required ValueChanged<String> onTap}) async {
    _onTap = onTap;
    initialized = initializeResult;
    return initializeResult;
  }

  @override
  Future<String?> takeLaunchPayload() async {
    final String? payload = launchPayload;
    launchPayload = null;
    return payload;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> show(NotificationRequest request) async {
    shown.add(request);
    _active[request.id] = request;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    _active.remove(id);
  }

  @override
  Future<void> refreshStrings() async {
    refreshStringsCalls++;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    _active.clear();
  }
}
