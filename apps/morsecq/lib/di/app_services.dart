import 'dart:async';

import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../desktop/desktop_shell_controller.dart';
import '../lifecycle/app_lifecycle_coordinator.dart';
import '../notifications/badge_api.dart';
import '../notifications/connection_banner_policy.dart';
import '../notifications/local_notifications_api.dart';
import '../notifications/notification_center.dart';
import '../notifications/notification_prefs.dart';

/// The two plugin-backed APIs the notification centre needs. `main()` passes
/// the real ones; widget tests pass nothing, so no notification code that
/// touches platform channels runs under `flutter test`.
final class NotificationApis {
  const NotificationApis({required this.notifications, required this.badge});

  final LocalNotificationsApi notifications;
  final BadgeApi badge;
}

/// Cross-cutting services that live for the whole app session and hang off
/// the identity / chat services: lifecycle tracking, the offline banner,
/// OS notifications and the desktop shell's unread count.
///
/// Built by `AppScope`; everything here is plugin-free unless
/// [NotificationApis] or a [DesktopShellController] is supplied.
final class AppServices {
  AppServices({
    required IdentityService identity,
    required ChatService chat,
    NotificationApis? notificationApis,
    NotificationPrefs? notificationPrefs,
    this.desktopShell,
  })  : lifecycle = AppLifecycleCoordinator(identity: identity),
        banner = ConnectionBannerPolicy(identity: identity),
        notificationPrefs = notificationPrefs ?? NotificationPrefs(),
        _chat = chat {
    final apis = notificationApis;
    notifications = apis == null
        ? null
        : NotificationCenter(
            chat: chat,
            notifications: apis.notifications,
            badge: apis.badge,
            prefs: this.notificationPrefs,
            isForeground: lifecycle.isForeground,
          );
  }

  final ChatService _chat;
  final AppLifecycleCoordinator lifecycle;
  final ConnectionBannerPolicy banner;
  final NotificationPrefs notificationPrefs;
  final DesktopShellController? desktopShell;
  late final NotificationCenter? notifications;

  StreamSubscription<List<Conversation>>? _unreadSub;
  bool _started = false;

  /// Idempotent. Safe to call before the identity exists: every piece reacts
  /// to streams, nothing here blocks on the network.
  void start() {
    if (_started) return;
    _started = true;
    lifecycle.attach();
    banner.start();
    final center = notifications;
    if (center != null) unawaited(center.start());
    final shell = desktopShell;
    if (shell != null) {
      shell.setUnreadCount(_totalUnread(_chat.conversations));
      _unreadSub = _chat.conversationChanges.listen(
        (list) => shell.setUnreadCount(_totalUnread(list)),
      );
    }
  }

  static int _totalUnread(List<Conversation> list) =>
      list.fold<int>(0, (sum, c) => sum + c.unreadCount);

  Future<void> dispose() async {
    await _unreadSub?.cancel();
    await notifications?.dispose();
    await banner.dispose();
    await lifecycle.dispose();
    notificationPrefs.dispose();
  }
}
