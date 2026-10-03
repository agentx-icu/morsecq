import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../lifecycle/app_lifecycle_coordinator.dart';
import '../../notifications/notification_center.dart';

/// Whether the user can actually see one open conversation, and the two
/// side effects that hang off that:
///
/// - **Active conversation.** While the screen is on screen (its route is not
///   covered and its tab is selected: [TickerMode] enabled) it is the
///   [NotificationCenter.setActiveConversation], so inbound messages for it
///   raise no OS banner while the app is in the foreground. It is cleared
///   when the screen is hidden or disposed, but only if it is still the
///   active one (another screen may have taken over meanwhile).
/// - **Mark read.** [requestRead] runs `onSeen` only when the screen is shown
///   *and* the app is in the foreground ([AppLifecycleCoordinator.isForeground]).
///   A request made while the app is backgrounded or the screen hidden is
///   kept and replayed as soon as the conversation is visible again, so the
///   unread count and the OS notification survive until the user looks.
///   iOS `inactive` (control centre, a call banner) and a desktop window
///   losing focus count as foreground: the coordinator ignores `inactive`.
///
/// Both dependencies are optional: widget tests that pump a bare screen
/// provide neither, and then the screen counts as foreground and visible.
class ConversationPresence {
  ConversationPresence({required this.conversationId, required this.onSeen});

  final String conversationId;
  final VoidCallback onSeen;

  NotificationCenter? _center;
  ValueListenable<bool>? _foreground;
  bool _shown = false;
  bool _readPending = false;
  bool _disposed = false;

  /// Shown on screen and the app is in the foreground.
  bool get visible => _shown && (_foreground?.value ?? true);

  /// Call from `initState` (reads providers without depending on them).
  void attach(BuildContext context) {
    _center = context.read<NotificationCenter?>();
    try {
      _foreground = context.read<AppLifecycleCoordinator>().isForeground;
    } on ProviderNotFoundException {
      _foreground = null;
    }
    _foreground?.addListener(_sync);
  }

  /// Call from `didChangeDependencies`: picks up tab / route visibility.
  void update(BuildContext context) {
    _shown = TickerMode.valuesOf(context).enabled;
    _sync();
  }

  /// Mark the conversation read now if the user can see it, else as soon as
  /// they can.
  void requestRead() {
    if (visible) {
      onSeen();
    } else {
      _readPending = true;
    }
  }

  void dispose() {
    _disposed = true;
    _foreground?.removeListener(_sync);
    _release();
  }

  void _sync() {
    if (_disposed) return;
    final NotificationCenter? center = _center;
    if (_shown) {
      if (center != null && center.activeConversation != conversationId) {
        center.setActiveConversation(conversationId);
      }
    } else {
      _release();
    }
    if (visible && _readPending) {
      _readPending = false;
      onSeen();
    }
  }

  void _release() {
    final NotificationCenter? center = _center;
    if (center != null && center.activeConversation == conversationId) {
      center.setActiveConversation(null);
    }
  }
}
