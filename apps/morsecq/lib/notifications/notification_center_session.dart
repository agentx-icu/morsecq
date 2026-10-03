part of 'notification_center.dart';

/// What follows the identity and the OS: the foreground-only permission
/// request and withdrawing notifications that belong to another identity.
extension _NotificationSession on NotificationCenter {
  /// The one automatic permission request: in the foreground only (a prompt
  /// cannot show from the background), once the plugin is ready. When the
  /// app was in the background then, the next resume asks instead. An OS
  /// that already decided answers without prompting.
  void _askPermissionIfForeground() {
    if (!_ready ||
        _disposed ||
        _permissionAsked ||
        !_platform.needsRuntimePermission ||
        !_isForeground.value) {
      return;
    }
    unawaited(ensurePermission());
  }

  /// Another identity (or none): everything posted belongs to the old one.
  /// The first identity to open after start is not a change (a cold-start
  /// tap waiting for it must survive).
  void _onIdentity(Identity? identity) {
    final String? account = NotificationCenter.accountOf(identity);
    final String? previous = _account;
    if (account == previous) return;
    _account = account;
    if (previous == null) {
      // The first identity of this run: banners an earlier run posted for a
      // different identity (it was deleted or replaced, e.g. a restore from
      // the unlock screen) are withdrawn; its own stay.
      if (account != null) unawaited(_withdrawForeign(account));
      return;
    }
    _pendingTap = null;
    _inbox.clear();
    _knownFriendRequests.clear();
    _knownInvites.clear();
    _activeConversation = null;
    _activeOwner = null;
    if (_ready && !_disposed) {
      unawaited(
        _notifications.cancelAll().catchError(
          (Object error, StackTrace stack) => NotificationCenter._report('cancelAll', error, stack),
        ),
      );
    }
  }

  Future<void> _withdrawForeign(String account) async {
    if (!_ready || _disposed) return;
    try {
      final List<String> active = await _notifications.activePayloads();
      for (final String payload in active) {
        // The identity may have changed while the list was read: a cleanup
        // for an identity that is no longer current must not touch the
        // banners of the one that is.
        if (_disposed || _account != account) return;
        final String? owner = NotificationTapTarget.parse(payload)?.account;
        if (owner != null && owner != account) await _cancel(payload);
      }
    } catch (error, stack) {
      NotificationCenter._report('withdraw foreign notifications', error, stack);
    }
  }


  Future<bool> _requestPermission() async {
    try {
      final bool granted = await _notifications.requestPermission();
      if (granted) _permissionGranted = true;
      return granted;
    } catch (error, stack) {
      NotificationCenter._report('requestPermission', error, stack);
      return false;
    } finally {
      _permissionRequest = null;
    }
  }
}
