import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../l10n/generated/s.dart';
import 'badge_api.dart';
import 'local_notifications_api.dart';
import 'notification_composer.dart';
import 'notification_payload.dart';
import 'notification_platform.dart';
import 'notification_prefs.dart';

/// Posts OS notifications for chat events and keeps the unread badge in step
/// with the conversation list.
///
/// Rules for an inbound message (`!isMine`, status `received`):
/// - never while the app is in the foreground **and** the conversation is the
///   one set by [setActiveConversation] (the user is looking at it);
/// - never for a conversation muted in [NotificationPrefs], or when
///   notifications are disabled there;
/// - otherwise one notification per conversation, replaced in place, with
///   the last [NotificationComposer.maxInboxLines] messages as inbox lines
///   on Android and a `threadIdentifier` stack on iOS/macOS.
///
/// Friend requests and group invites notify on their own channels; the sets
/// present when [start] runs are treated as already seen (they are visible in
/// the app the user just opened), only additions notify afterwards.
///
/// Connection state deliberately never produces an OS notification — see
/// `ConnectionBannerPolicy` for the in-app banner.
///
/// Wiring: the orchestrator constructs this once per session, calls [start]
/// after the identity is ready, routes [openConversationRequests] into the
/// chat UI, and calls [setActiveConversation] from the conversation screen's
/// `initState` / `dispose`. All plugin access goes through the injected
/// [LocalNotificationsApi] and [BadgeApi].
///
/// Text is resolved through [strings] at post time (default `currentS()`, or
/// the `StringsResolver` the orchestrator owns), so a language change shows
/// up in the next notification; banners already posted are not relabelled.
class NotificationCenter {
  NotificationCenter({
    required ChatService chat,
    required LocalNotificationsApi notifications,
    required BadgeApi badge,
    required NotificationPrefs prefs,
    required ValueListenable<bool> isForeground,
    NotificationPlatform? platform,
    String Function(String text)? patternOf,
    S Function()? strings,
  }) : _chat = chat,
       _notifications = notifications,
       _badge = badge,
       _prefs = prefs,
       _isForeground = isForeground,
       _platform = platform ?? NotificationPlatform.detect(),
       _composer = NotificationComposer(
         prefs: prefs,
         platform: platform ?? NotificationPlatform.detect(),
         patternOf: patternOf,
         strings: strings,
       );

  final ChatService _chat;
  final LocalNotificationsApi _notifications;
  final BadgeApi _badge;
  final NotificationPrefs _prefs;
  final ValueListenable<bool> _isForeground;
  final NotificationPlatform _platform;
  final NotificationComposer _composer;

  final StreamController<String> _openRequests =
      StreamController<String>.broadcast();
  final StreamController<NotificationTapTarget> _taps =
      StreamController<NotificationTapTarget>.broadcast();

  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<List<FriendRequest>>? _friendRequestSub;
  StreamSubscription<List<GroupInvite>>? _inviteSub;
  StreamSubscription<List<Conversation>>? _conversationSub;

  /// Inbox lines per conversation id for the currently visible notification.
  final Map<String, List<String>> _inbox = <String, List<String>>{};
  final Set<String> _knownFriendRequests = <String>{};
  final Set<String> _knownInvites = <String>{};

  String? _activeConversation;
  bool _started = false;
  bool _ready = false;
  bool _disposed = false;

  bool _permissionGranted = false;
  Future<bool>? _permissionRequest;

  bool? _badgeSupported;
  int? _lastBadge;
  Future<void> _badgeChain = Future<void>.value();

  /// Conversation ids the user asked to open by tapping a notification
  /// (including the one that cold-started the app).
  Stream<String> get openConversationRequests => _openRequests.stream;

  /// Every parsed tap, including friend-request and group-invite targets.
  Stream<NotificationTapTarget> get tapTargets => _taps.stream;

  String? get activeConversation => _activeConversation;

  /// Whether the OS backend initialised; false on unsupported platforms or
  /// after a plugin failure (the badge and the streams keep working).
  bool get isReady => _ready;

  /// The conversation currently on screen, or null when none is. While the
  /// app is in the foreground its notification is dismissed immediately.
  void setActiveConversation(String? conversationId) {
    _activeConversation = conversationId;
    if (conversationId != null && _isForeground.value) {
      unawaited(_clearConversation(conversationId));
    }
  }

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    _isForeground.addListener(_onForegroundChanged);
    if (_platform.supportsOsNotifications) {
      _ready = await _notifications.initialize(onTap: _onTap);
    }
    if (_disposed) return;
    _knownFriendRequests.addAll(
      _chat.friendRequests.map((FriendRequest r) => r.publicKey),
    );
    _knownInvites.addAll(_chat.groupInvites.map((GroupInvite i) => i.inviteId));
    _messageSub = _chat.messageEvents.listen(_onMessage);
    _friendRequestSub = _chat.friendRequestChanges.listen(_onFriendRequests);
    _inviteSub = _chat.groupInviteChanges.listen(_onGroupInvites);
    _conversationSub = _chat.conversationChanges.listen(_onConversations);
    if (_ready) {
      final String? launch = await _notifications.takeLaunchPayload();
      if (launch != null && !_disposed) _onTap(launch);
    }
  }

  /// Requests the OS permission if this platform has one. Safe to call
  /// repeatedly and before [start]; a grant is remembered, a denial is not
  /// (the OS returns a remembered denial instantly without re-prompting).
  Future<bool> ensurePermission() {
    if (!_platform.needsRuntimePermission) {
      return Future<bool>.value(_platform.supportsOsNotifications);
    }
    if (_permissionGranted) return Future<bool>.value(true);
    return _permissionRequest ??= _requestPermission();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (_started) _isForeground.removeListener(_onForegroundChanged);
    await _messageSub?.cancel();
    await _friendRequestSub?.cancel();
    await _inviteSub?.cancel();
    await _conversationSub?.cancel();
    await _openRequests.close();
    await _taps.close();
  }

  // ---- Inbound events --------------------------------------------------------

  void _onMessage(ChatMessage message) {
    if (message.isMine || message.status != MessageStatus.received) return;
    final String id = message.conversationId;
    if (_isForeground.value && _activeConversation == id) return;
    if (!_prefs.enabled || _prefs.isMuted(id)) return;

    final Conversation? conversation = _conversationFor(id);
    final bool isGroup =
        (conversation?.kind ?? _kindFromId(id)) == ConversationKind.group;
    final String title =
        conversation?.title ??
        (isGroup
            ? NotificationComposer.shortKey(_peerFromId(id))
            : NotificationComposer.senderLabel(message));

    final List<String> lines = _inbox.putIfAbsent(id, () => <String>[]);
    lines.add(_composer.inboxLine(message, isGroup: isGroup));
    if (lines.length > NotificationComposer.maxInboxLines) {
      lines.removeRange(0, lines.length - NotificationComposer.maxInboxLines);
    }
    unawaited(
      _post(
        _composer.message(
          message: message,
          title: title,
          isGroup: isGroup,
          lines: lines,
        ),
      ),
    );
  }

  void _onFriendRequests(List<FriendRequest> requests) {
    final Set<String> current = <String>{};
    for (final FriendRequest request in requests) {
      current.add(request.publicKey);
      if (_knownFriendRequests.add(request.publicKey) && _prefs.enabled) {
        unawaited(_post(_composer.friendRequest(request)));
      }
    }
    // Answered (or withdrawn) requests: forget them so a repeat notifies
    // again, and take their banner down.
    for (final String gone in _knownFriendRequests.difference(current)) {
      unawaited(_cancel(FriendRequestTarget(gone).encode()));
    }
    _knownFriendRequests
      ..clear()
      ..addAll(current);
  }

  void _onGroupInvites(List<GroupInvite> invites) {
    final Set<String> current = <String>{};
    for (final GroupInvite invite in invites) {
      current.add(invite.inviteId);
      if (_knownInvites.add(invite.inviteId) && _prefs.enabled) {
        unawaited(
          _post(
            _composer.groupInvite(
              invite,
              fromName: _friendName(invite.fromPublicKey),
            ),
          ),
        );
      }
    }
    for (final String gone in _knownInvites.difference(current)) {
      unawaited(_cancel(GroupInviteTarget(gone).encode()));
    }
    _knownInvites
      ..clear()
      ..addAll(current);
  }

  void _onConversations(List<Conversation> conversations) {
    var total = 0;
    final Set<String> live = <String>{};
    for (final Conversation conversation in conversations) {
      live.add(conversation.id);
      total += conversation.unreadCount;
      // Read in-app (markRead) or from another surface: drop the banner.
      if (conversation.unreadCount == 0 && _inbox.containsKey(conversation.id)) {
        unawaited(_clearConversation(conversation.id));
      }
    }
    // Deleted conversations: drop their banners. Materialise first —
    // _clearConversation mutates _inbox synchronously.
    final List<String> stale = _inbox.keys
        .where((String k) => !live.contains(k))
        .toList();
    for (final String id in stale) {
      unawaited(_clearConversation(id));
    }
    _updateBadge(total);
  }

  void _onForegroundChanged() {
    final String? id = _activeConversation;
    if (_isForeground.value && id != null) unawaited(_clearConversation(id));
  }

  void _onTap(String payload) {
    final NotificationTapTarget? target = NotificationTapTarget.parse(payload);
    if (target == null || _disposed) return;
    _taps.add(target);
    if (target is OpenConversationTarget) {
      _openRequests.add(target.conversationId);
    }
  }

  // ---- Posting -----------------------------------------------------------------

  Future<void> _post(NotificationRequest request) async {
    if (!_ready || _disposed) return;
    if (_platform.needsRuntimePermission && !await ensurePermission()) return;
    if (_disposed) return;
    try {
      await _notifications.show(request);
    } catch (error, stack) {
      _report('show(${request.payload})', error, stack);
    }
  }

  Future<bool> _requestPermission() async {
    try {
      final bool granted = await _notifications.requestPermission();
      if (granted) _permissionGranted = true;
      return granted;
    } catch (error, stack) {
      _report('requestPermission', error, stack);
      return false;
    } finally {
      _permissionRequest = null;
    }
  }

  Future<void> _clearConversation(String conversationId) async {
    _inbox.remove(conversationId);
    await _cancel(OpenConversationTarget(conversationId).encode());
  }

  Future<void> _cancel(String payload) async {
    if (!_ready || _disposed) return;
    try {
      await _notifications.cancel(stableNotificationId(payload));
    } catch (error, stack) {
      _report('cancel($payload)', error, stack);
    }
  }

  // ---- Badge -------------------------------------------------------------------

  /// Writes are serialised (latest value last) and deduplicated against the
  /// last value that reached the OS, so a burst of conversation updates ends
  /// with the badge showing the final total exactly once per change.
  void _updateBadge(int total) {
    if (!_platform.supportsBadge || _disposed) return;
    _badgeChain = _badgeChain
        .then((_) => _writeBadge(total))
        .catchError(
          (Object error, StackTrace stack) => _report('badge', error, stack),
        );
  }

  Future<void> _writeBadge(int total) async {
    if (_disposed) return;
    _badgeSupported ??= await _badge.isSupported();
    if (_badgeSupported != true || _lastBadge == total) return;
    await _badge.update(total);
    _lastBadge = total;
  }

  // ---- Lookups -----------------------------------------------------------------

  Conversation? _conversationFor(String id) {
    for (final Conversation c in _chat.conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  String? _friendName(String publicKey) {
    for (final Friend f in _chat.friends) {
      if (f.publicKey == publicKey && f.displayName.trim().isNotEmpty) {
        return f.displayName.trim();
      }
    }
    return null;
  }

  static ConversationKind _kindFromId(String id) =>
      id.startsWith('group_') ? ConversationKind.group : ConversationKind.c2c;

  static String _peerFromId(String id) {
    final int separator = id.indexOf('_');
    return separator < 0 ? id : id.substring(separator + 1);
  }

  static void _report(String what, Object error, StackTrace stack) {
    debugPrint('[NotificationCenter] $what failed: $error\n$stack');
  }
}
