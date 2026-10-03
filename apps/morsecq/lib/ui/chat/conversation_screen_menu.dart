part of 'conversation_screen.dart';

/// Search / jump, clear history, leave group and the overflow menu of
/// [ConversationScreen]; the state's fields are declared here abstractly
/// and provided by `_ConversationScreenState`.
mixin _ConversationMenuActions on State<ConversationScreen> {
  ChatService get _service;
  LocalMessageSends get _localSends;
  ScrollController get _scroll;
  List<ChatMessage> get _older;
  List<ChatMessage> get _messages;
  Set<String> get _revealed;
  Map<String, ChatMessage> get _pendingStatuses;
  bool get _loading;
  set _loading(bool value);
  set _loadingOlder(bool value);
  set _hasMore(bool value);
  bool get _clearing;
  set _clearing(bool value);
  set _historyLimit(int value);
  int get _generation;
  set _generation(int value);
  set _newMessages(int value);
  set _error(Object? value);
  set _olderError(Object? value);
  String get _id;
  bool get _isGroup;
  Future<void> _load();
  void _markRead();
  void _scrollToEnd();

  /// Showing a search result's surroundings, detached from the live end.
  bool _jumpedAway = false;

  /// The profile's bookmarks, once resolved.
  MessageBookmarks? _bookmarkStore;

  Future<void> _initBookmarks() async {
    final store = await MessageBookmarks.of(context);
    if (!mounted) return;
    setState(() => _bookmarkStore = store..addListener(_onBookmarks));
  }

  void _onBookmarks() {
    if (mounted) setState(() {});
  }

  void _showLatest() {
    if (_jumpedAway) {
      _jumpedAway = false;
      _generation++;
      _older.clear();
      unawaited(_load());
      return;
    }
    setState(() => _newMessages = 0);
    _scrollToEnd();
    _markRead();
  }

  /// Opens history search; a picked result is shown at the top of the
  /// timeline with its surrounding history. Neither marks anything read.
  Future<void> _search() async {
    final bookmarks = await MessageBookmarks.of(context);
    if (!mounted) return;
    final ChatMessage? hit = await ConversationMenu.openSearch(
      context,
      service: _service,
      target: widget.target,
      bookmarks: bookmarks,
    );
    if (hit == null || !mounted) return;
    final int generation = ++_generation;
    try {
      final rows = await _service.loadAround(_id, hit.id);
      if (!mounted || generation != _generation || rows.isEmpty) return;
      final at = rows.indexWhere((m) => m.id == hit.id);
      setState(() {
        _jumpedAway = true;
        _older
          ..clear()
          ..addAll(rows.take(at));
        _messages
          ..clear()
          ..addAll(rows.skip(at));
        _hasMore = at > 0;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    } on Object catch (e) {
      if (mounted) showSnack(context, describeChatError(context.s, e));
    }
  }

  Group? _group() {
    if (!_isGroup) return null;
    for (final Group g in _service.groups) {
      if (g.id == widget.target.peerId) return g;
    }
    return null;
  }

  Future<void> _leaveGroup() async {
    final bool left = await ConversationMenu.leaveGroup(
      context,
      _service,
      widget.target.peerId,
    );
    if (!left || !mounted) return;
    if (widget.embedded) {
      widget.onClosed?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _clearHistory() async {
    final S s = context.s;
    final String body = await ConversationLearning.clearHistoryBody(
      context,
      _id,
    );
    if (!mounted) return;
    final bool ok = await confirm(
      context,
      title: s.chatClearHistory,
      body: body,
      confirmLabel: s.chatClearHistory,
    );
    if (!ok || !mounted || _clearing) return;
    final bool wasLoading = _loading;
    final ids = {
      for (final m in [..._older, ..._messages]) m.id,
      ..._pendingStatuses.keys,
    };
    // Invalidate outstanding loads before deletion. New arrivals remain live.
    _generation++;
    setState(() {
      _clearing = true;
      _loading = false;
      _loadingOlder = false;
    });
    try {
      await _service.clearHistory(_id);
      _localSends.recordClear(_id, ids);
      if (!mounted) return;
      unawaited(_bookmarkStore?.removeConversation(_id));
      setState(() {
        _messages.removeWhere((m) => ids.contains(m.id));
        _older.clear();
        _revealed.clear();
        _pendingStatuses.clear();
        _historyLimit = 50;
        _hasMore = false;
        _newMessages = 0;
        _error = _olderError = null;
      });
      _scrollToEnd();
    } on Object catch (e) {
      if (mounted) {
        showSnack(context, describeChatError(s, e));
        if (wasLoading) unawaited(_load());
      }
    } finally {
      if (mounted) setState(() => _clearing = false);
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
      case 'listenOnly':
        final settings = MorsePlaybackSettings.of(context, listen: false);
        settings.listenOnly = !settings.listenOnly;
    }
  }
}
