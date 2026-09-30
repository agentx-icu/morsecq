import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notifications_api.dart';
import 'notification_platform.dart';
import 'notification_strings.dart';

/// Production [LocalNotificationsApi] on `flutter_local_notifications`
/// (22.x). The only file in the app that imports the plugin.
///
/// Per platform (see README.md in this directory for the full table):
/// - Android: notification channels created up front; grouping via
///   `groupKey` + inbox style; `POST_NOTIFICATIONS` requested lazily.
/// - iOS / macOS: UNUserNotificationCenter; permission requested lazily
///   (the init settings turn the automatic prompt off); banners are shown in
///   the foreground too, because the center posts only for conversations the
///   user is *not* looking at.
/// - Linux: D-Bus `org.freedesktop.Notifications` via the endorsed
///   `flutter_local_notifications_linux`; no permission, no grouping.
/// - Windows: WinRT toasts via the endorsed FFI package
///   `flutter_local_notifications_windows`; no permission, no grouping;
///   `cancel` is a no-op unless the app is packaged as MSIX (plugin README).
final class FlutterLocalNotificationsApi implements LocalNotificationsApi {
  FlutterLocalNotificationsApi({
    FlutterLocalNotificationsPlugin? plugin,
    NotificationPlatform? platform,
    this.androidIcon = defaultAndroidIcon,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _platform = platform ?? NotificationPlatform.detect();

  /// The launcher icon. Android guidance prefers an alpha-only drawable; the
  /// launcher mipmap is a known-acceptable fallback until branding ships a
  /// status-bar glyph (keep it out of R8 resource shrinking if that changes).
  static const String defaultAndroidIcon = '@mipmap/ic_launcher';

  /// Windows registers the app with the toast platform under this
  /// AppUserModelID; unpackaged apps register it in the registry on first
  /// init. Must stay stable across versions or old toasts orphan.
  static const String windowsAppUserModelId = 'icu.agentx.morsecq';

  /// COM activator CLSID for Windows toast activation. Generated once
  /// (2026-09-30) and must never change for the same [windowsAppUserModelId].
  static const String windowsGuid = 'e98da184-450e-43c1-88ba-c2082fc8de1d';

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationPlatform _platform;
  final String androidIcon;
  bool _initialized = false;

  @override
  Future<bool> initialize({required ValueChanged<String> onTap}) async {
    if (_initialized) return true;
    if (!_platform.supportsOsNotifications) return false;
    try {
      const DarwinInitializationSettings darwin = DarwinInitializationSettings(
        // Permission is driven by requestPermission() so the prompt happens
        // when the app decides (not on first launch behind the splash).
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      final InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: darwin,
        macOS: darwin,
        linux: const LinuxInitializationSettings(
          defaultActionName: NotificationStrings.open,
        ),
        windows: const WindowsInitializationSettings(
          appName: NotificationStrings.appName,
          appUserModelId: windowsAppUserModelId,
          guid: windowsGuid,
        ),
      );
      final bool? ok = await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final String? payload = response.payload;
          if (payload != null && payload.isNotEmpty) onTap(payload);
        },
      );
      if (ok == false) return false;
      if (_platform == NotificationPlatform.android) {
        await _createAndroidChannels();
      }
      _initialized = true;
      return true;
    } catch (error, stack) {
      _report('initialize', error, stack);
      return false;
    }
  }

  @override
  Future<String?> takeLaunchPayload() async {
    if (!_initialized) return null;
    try {
      final NotificationAppLaunchDetails? details = await _plugin
          .getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      final String? payload = details.notificationResponse?.payload;
      return (payload == null || payload.isEmpty) ? null : payload;
    } catch (error, stack) {
      _report('takeLaunchPayload', error, stack);
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      switch (_platform) {
        case NotificationPlatform.android:
          final AndroidFlutterLocalNotificationsPlugin? impl = _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
          if (impl == null) return false;
          // No-op (null) below API 33, where notifications are on by default
          // unless the user turned them off in settings.
          final bool? granted = await impl.requestNotificationsPermission();
          return granted ?? (await impl.areNotificationsEnabled() ?? true);
        case NotificationPlatform.ios:
          final IOSFlutterLocalNotificationsPlugin? impl = _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
          return await impl?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;
        case NotificationPlatform.macos:
          final MacOSFlutterLocalNotificationsPlugin? impl = _plugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >();
          return await impl?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;
        case NotificationPlatform.linux:
        case NotificationPlatform.windows:
          return true;
        case NotificationPlatform.unsupported:
          return false;
      }
    } catch (error, stack) {
      _report('requestPermission', error, stack);
      return false;
    }
  }

  @override
  Future<void> show(NotificationRequest request) async {
    if (!_initialized) return;
    await _plugin.show(
      id: request.id,
      title: request.title,
      body: request.body,
      payload: request.payload,
      notificationDetails: _details(request),
    );
  }

  @override
  Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  NotificationDetails _details(NotificationRequest request) {
    final bool grouped = request.lines.length > 1;
    final NotificationChannelKind channel = request.channel;
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      channel.androidId,
      channel.displayName,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      category: channel.androidCategory,
      groupKey: request.groupKey,
      playSound: request.sound,
      enableVibration: request.sound,
      number: grouped ? request.lines.length : null,
      styleInformation: grouped
          ? InboxStyleInformation(
              request.lines,
              contentTitle: request.title,
              summaryText: request.summary,
            )
          : null,
    );
    final DarwinNotificationDetails darwin = DarwinNotificationDetails(
      threadIdentifier: request.groupKey,
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: request.sound,
    );
    final LinuxNotificationDetails linux = LinuxNotificationDetails(
      category: channel == NotificationChannelKind.messages
          ? LinuxNotificationCategory.imReceived
          : LinuxNotificationCategory.im,
      suppressSound: !request.sound,
      defaultActionName: NotificationStrings.open,
    );
    final WindowsNotificationDetails windows = WindowsNotificationDetails(
      audio: request.sound ? null : WindowsNotificationAudio.silent(),
    );
    return NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
      windows: windows,
    );
  }

  Future<void> _createAndroidChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl == null) return;
    for (final NotificationChannelKind kind in NotificationChannelKind.values) {
      // Re-creating an existing channel only updates name/description;
      // importance and sound are frozen by Android once the channel exists.
      await impl.createNotificationChannel(
        AndroidNotificationChannel(
          kind.androidId,
          kind.displayName,
          description: kind.description,
          importance: Importance.high,
        ),
      );
    }
  }

  static void _report(String what, Object error, StackTrace stack) {
    debugPrint('[FlutterLocalNotificationsApi] $what failed: $error\n$stack');
  }
}

/// Android channel metadata for each [NotificationChannelKind].
extension NotificationChannelKindAndroid on NotificationChannelKind {
  String get androidId => switch (this) {
    NotificationChannelKind.messages => 'morsecq_messages',
    NotificationChannelKind.friendRequests => 'morsecq_friend_requests',
    NotificationChannelKind.groupInvites => 'morsecq_group_invites',
  };

  String get displayName => switch (this) {
    NotificationChannelKind.messages => NotificationStrings.channelMessages,
    NotificationChannelKind.friendRequests =>
      NotificationStrings.channelFriendRequests,
    NotificationChannelKind.groupInvites =>
      NotificationStrings.channelGroupInvites,
  };

  String get description => switch (this) {
    NotificationChannelKind.messages =>
      NotificationStrings.channelMessagesDescription,
    NotificationChannelKind.friendRequests =>
      NotificationStrings.channelFriendRequestsDescription,
    NotificationChannelKind.groupInvites =>
      NotificationStrings.channelGroupInvitesDescription,
  };

  AndroidNotificationCategory get androidCategory => switch (this) {
    NotificationChannelKind.messages => AndroidNotificationCategory.message,
    NotificationChannelKind.friendRequests ||
    NotificationChannelKind.groupInvites => AndroidNotificationCategory.social,
  };
}
