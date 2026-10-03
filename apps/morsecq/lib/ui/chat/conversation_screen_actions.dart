part of 'conversation_screen.dart';

/// The app-bar menu of a conversation: group members, leaving a group and
/// clearing the history.
extension _ConversationMenu on _ConversationScreenState {
  Group? _group() {
    if (!_isGroup) return null;
    for (final Group g in _service.groups) {
      if (g.id == widget.target.peerId) return g;
    }
    return null;
  }

  Future<void> _leaveGroup() async {
    final S s = context.s;
    final bool ok = await confirm(
      context,
      title: s.chatLeaveGroupTitle,
      body: s.chatLeaveGroupBody,
      confirmLabel: s.chatLeave,
    );
    if (!ok || !mounted) return;
    try {
      await _service.leaveGroup(widget.target.peerId);
    } on Object catch (e) {
      if (mounted) showSnack(context, describeChatError(s, e));
      return;
    }
    if (!mounted) return;
    if (widget.embedded) {
      widget.onClosed?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onMenu(String action) async {
    switch (action) {
      case 'members':
        final Group? group = _group();
        if (group != null) {
          await showGroupMembersSheet(context, service: _service, group: group);
        }
      case 'leave':
        await _leaveGroup();
      case 'clear':
        await _clearHistory();
    }
  }
}
