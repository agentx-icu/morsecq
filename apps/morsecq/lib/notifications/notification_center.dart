import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../l10n/generated/s.dart';
import 'badge_api.dart';
import 'local_notifications_api.dart';
import 'message_banner_ledger.dart';
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

  // A tap that lands with nobody listening (the cold-start payload is read
  // in start(), while the startup gate - unlock, open - still hides the
  // shell that subscribes) is parked and handed to the first subscriber.
  late final StreamController<String> _openRequests =
      StreamController<String>.broadcast(onListen: _replayOpenRequest);
  late final StreamController<NotificationTapTarget> _taps =
      StreamController<NotificationTapTarget>.broadcast(onListen: _replayTap);
  String? _parkedOpenRequest;
  NotificationTapTarget? _parkedTap;

  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<List<FriendRequest>>? _friendRequestSub;
  StreamSubscription<List<GroupInvite>>? _inviteSub;
  StreamSubscription<List<Conversation>>? _conversationSub;

  /// Inbox lines per conversation id for the currently visible notification.
  final Map<String, List<String>> _inbox = <String, List<String>>{};
  final MessageBannerLedger _ledger = MessageBannerLedger();
  final Set<String> _knownFriendRequests = <String>{};
  final Set<String> _knownInvites = <String>{};

  String? _activeConversation;
  bool _started = false;
  bool _ready = false;
  bool _disposed = false;

  bool _permissionGranted = false;
  Future<bool>? _permissionRequest;

  /// The one unsolicited prompt per session has been shown.
  bool _autoPrompted = false;

  /// A post was dropped in the background for want of a permission nobody
  /// has asked for yet: prompt when the user is back.
  bool _promptOnForeground = false;

  bool? _badgeSupported;
  int? _lastBadge;
  Future<void> _badgeChain = Future<void>.value();

  /// Conversation ids the user asked to open by tapping a notification
  /// (including the one that cold-started the app). A request made while
  /// nobody listens (cold start behind the startup gate) is kept - the
  /// latest one only - and delivered to the next subscriber.
  Stream<String> get openConversationRequests => _openRequests.stream;

  /// Every parsed tap, including friend-request and group-invite targets.
  /// Same parking rule as [openConversationRequests].
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

  /// Language changed: let the OS-facing metadata follow (Android channel
  /// names). Forwarded whenever this platform has OS notifications, ready or
  /// not: the API remembers a change that arrives while it initialises.
  Future<void> refreshStrings() async {
    if (_disposed || !_platform.supportsOsNotifications) return;
    await _notifications.refreshStrings();
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
  ///
  /// This may show a system dialog: call it from a user action (a settings
  /// tile). Posting never prompts from the background and prompts on its
  /// own at most once per session - see [_mayPost].
  Future<bool> ensurePermission() {
    if (!_platform.needsRuntimePermission) {
      return Future<bool>.value(_platform.supportsOsNotifications);
    }
    if (_permissionGranted) return Future<bool>.value(true);
    return _permissionRequest ??= _requestPermission();
  }

  /// Every release happens SYNCHRONOUSLY before the first `await`: the
  /// owning scope's `dispose()` cannot wait, and a cancelled broadcast
  /// subscription may hand back a root-zone completed future that FakeAsync
  /// never resumes, which would leave the later subscriptions and the
  /// controllers open. The futures are only awaited afterwards.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (_started) _isForeground.removeListener(_onForegroundChanged);
    final pending = <Future<void>>[
      ?_messageSub?.cancel(),
      ?_friendRequestSub?.cancel(),
      ?_inviteSub?.cancel(),
      ?_conversationSub?.cancel(),
      _openRequests.close(),
      _taps.close(),
    ];
    _messageSub = null;
    _friendRequestSub = null;
    _inviteSub = null;
    _conversationSub = null;
    await Future.wait(pending);
  }

  // ---- Inbound events --------------------------------------------------------

  void _onMessage(ChatMessage message) {
    if (message.isMine || message.status != MessageStatus.received) return;
    final String id = message.conversationId;
    if (_isForeground.value && _activeConversation == id) return;
    if (!_prefs.enabled || _prefs.isMuted(id)) return;

    final Conversation? conversation = _conversationFor(id);
    final bool isGroup =
        (conversation?.kind ?? NotificationComposer.kindFromId(id)) ==
        ConversationKind.group;
    final String title =
        conversation?.title ??
        (isGroup
            ? NotificationComposer.shortKey(NotificationComposer.peerFromId(id))
            : NotificationComposer.senderLabel(message));

    final List<String> lines = _inbox.putIfAbsent(id, () => <String>[]);
    lines.add(_composer.inboxLine(message, isGroup: isGroup));
    if (lines.length > NotificationComposer.maxInboxLines) {
      lines.removeRange(0, lines.length - NotificationComposer.maxInboxLines);
    }
    final int generation = _ledger.posted(id, message);
    unawaited(
      _post(
        _composer.message(
          message: message,
          title: title,
          isGroup: isGroup,
          lines: lines,
        ),
        stillWanted: () => _ledger.isCurrent(id, generation),
      ),
    );
  }

  void _onFriendRequests(List<FriendRequest> requests) {
    final Set<String> current = <String>{};
    for (final FriendRequest request in requests) {
      current.add(request.publicKey);
      if (_knownFriendRequests.add(request.publicKey) && _prefs.enabled) {
        final String key = request.publicKey;
        unawaited(
          _post(
            _composer.friendRequest(request),
            stillWanted: () => _knownFriendRequests.contains(key),
          ),
        );
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
        final String inviteId = invite.inviteId;
        unawaited(
          _post(
            _composer.groupInvite(
              invite,
              fromName: _friendName(invite.fromPublicKey),
            ),
            stillWanted: () => _knownInvites.contains(inviteId),
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
      if (_inbox.containsKey(conversation.id) &&
          _ledger.showsRead(conversation)) {
        unawaited(_clearConversation(conversation.id));
      }
    }
    // Deleted conversations: drop their banners (a materialised list:
    // _clearConversation mutates _inbox synchronously).
    for (final String id in _ledger.deleted(_inbox.keys, live)) {
      unawaited(_clearConversation(id));
    }
    _updateBadge(total);
  }

  void _onForegroundChanged() {
    if (!_isForeground.value) return;
    final String? id = _activeConversation;
    if (id != null) unawaited(_clearConversation(id));
    if (_promptOnForeground) {
      _promptOnForeground = false;
      unawaited(_autoPrompt());
    }
  }

  void _onTap(String payload) {
    final NotificationTapTarget? target = NotificationTapTarget.parse(payload);
    if (target == null || _disposed) return;
    if (_taps.hasListener) {
      _taps.add(target);
    } else {
      _parkedTap = target;
    }
    // Only the latest tap is replayed, across both streams: an earlier
    // conversation tap must not reopen behind a later invite / request.
    if (!_openRequests.hasListener) _parkedOpenRequest = null;
    if (target is OpenConversationTarget) {
      if (_openRequests.hasListener) {
        _openRequests.add(target.conversationId);
      } else {
        _parkedOpenRequest = target.conversationId;
      }
    }
  }

  void _replayOpenRequest() {
    final String? parked = _parkedOpenRequest;
    _parkedOpenRequest = null;
    if (parked != null && !_openRequests.isClosed) _openRequests.add(parked);
  }

  void _replayTap() {
    final NotificationTapTarget? parked = _parkedTap;
    _parkedTap = null;
    if (parked != null && !_taps.isClosed) _taps.add(parked);
  }

  // ---- Posting -----------------------------------------------------------------

  /// Posts [request] once the permission gate allows it. The gate awaits a
  /// platform call; [stillWanted] is re-checked afterwards so a banner the
  /// user made moot meanwhile (opened, read, answered) is not shown stale.
  Future<void> _post(
    NotificationRequest request, {
    required bool Function() stillWanted,
  }) async {
    if (!_ready || _disposed) return;
    if (!await _mayPost()) return;
    if (_disposed || !stillWanted()) return;
    try {
      await _notifications.show(request);
    } catch (error, stack) {
      _report('show(${request.payload})', error, stack);
    }
  }

  /// Permission gate for posting. A system prompt is a dialog: shown from
  /// the background it is lost or refused (Android cannot start the
  /// permission activity from a stopped one; a cancelled request reads as
  /// "denied"), and shown on every inbound message it nags. So: check
  /// silently first (a grant from an earlier run or from Settings), prompt
  /// only while the app is visible and only once per session, and from the
  /// background defer that one prompt to the next foreground.
  Future<bool> _mayPost() async {
    if (!_platform.needsRuntimePermission || _permissionGranted) return true;
    if (await _checkPermission()) return true;
    if (_disposed) return false;
    // Join a prompt already on screen rather than dropping this post.
    final Future<bool>? pending = _permissionRequest;
    if (pending != null) return pending;
    if (_autoPrompted) return false;
    if (_isForeground.value) return _autoPrompt();
    _promptOnForeground = true;
    return false;
  }

  Future<bool> _autoPrompt() {
    if (_disposed || _permissionGranted) {
      return Future<bool>.value(_permissionGranted);
    }
    if (_autoPrompted) return _permissionRequest ?? Future<bool>.value(false);
    _autoPrompted = true;
    return ensurePermission();
  }

  Future<bool> _checkPermission() async {
    try {
      final bool granted = await _notifications.isPermissionGranted();
      if (granted) _permissionGranted = true;
      return granted;
    } catch (error, stack) {
      _report('isPermissionGranted', error, stack);
      return false;
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
    _ledger.cleared(conversationId);
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

  static void _report(String what, Object error, StackTrace stack) {
    debugPrint('[NotificationCenter] $what failed: $error\n$stack');
  }
}
