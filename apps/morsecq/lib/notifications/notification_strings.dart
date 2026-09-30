/// User-facing strings for notifications and the connection banner.
///
/// English only, mirroring `ChatStrings`: a later l10n pass replaces this
/// class without touching the notification logic. Android channel names are
/// visible in system settings, so keep them short and stable.
abstract final class NotificationStrings {
  static const String appName = 'Morsecq';

  /// Linux default action label (required by the D-Bus backend).
  static const String open = 'Open';

  static const String channelMessages = 'Messages';
  static const String channelMessagesDescription =
      'New Morse messages from friends and groups';
  static const String channelFriendRequests = 'Friend requests';
  static const String channelFriendRequestsDescription =
      'Someone wants to add you as a friend';
  static const String channelGroupInvites = 'Group invites';
  static const String channelGroupInvitesDescription =
      'A friend invited you to a group';

  static const String newMessage = 'New message';
  static String newMessages(int count) => '$count new messages';

  static const String friendRequestTitle = 'New friend request';
  static String friendRequestBody(String who, String message) =>
      message.trim().isEmpty ? who : '$who: ${message.trim()}';

  static String groupInviteTitle(String groupName) => 'Invite to $groupName';
  static String groupInviteBody(String who) => '$who invited you';

  static const String offlineBanner =
      'Offline for a while. Messages only arrive while you are connected.';
  static const String offlineBannerAction = 'Reconnect';
}
