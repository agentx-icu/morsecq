import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import '../groups/group_members_sheet.dart';
import 'chat_layout.dart';
import 'conversation_actions.dart';
import 'conversation_auto_play.dart';
import 'conversation_target.dart';
import 'conversation_header.dart';
import 'conversation_presence.dart';
import 'conversation_history.dart';
import 'conversation_bubble.dart';
import 'conversation_learning.dart';
import 'conversation_menu.dart';
import 'search/message_bookmarks.dart';
import 'conversation_timeline.dart';
import 'message_input.dart';
import 'local_message_sends.dart';
import 'morse_playback_controller.dart';
import 'morse_playback_settings.dart';

part 'conversation_screen_menu.dart';

/// One conversation (c2c or group): history + live events, Morse bubbles,
/// training mode, auto-play, playback settings and the keyed input.
///
/// [embedded] hides the back button for the master-detail right pane; the
/// owner passes [onClosed] to clear its selection when the user leaves a
/// group from here.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.target,
    this.embedded = false,
    this.onClosed,
  });

  final ConversationTarget target;
  final bool embedded;
  final VoidCallback? onClosed;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with _ConversationMenuActions {
  @override
  late final ChatService _service;
  late final MorsePlaybackController _playback;
  bool _ownsPlayback = false;
  late final ConversationAutoPlay _autoPlay = ConversationAutoPlay(_playback);
  late final StreamSubscription<ChatMessage> _events;
  @override
  late final LocalMessageSends _localSends;
  late final ConversationPresence _presence = ConversationPresence(
    conversationId: _id,
    onSeen: () => unawaited(_markReadNow()),
  );
  @override
  final ScrollController _scroll = ScrollController();
  final GlobalKey _timelineOrigin = GlobalKey();
  @override
  final List<ChatMessage> _older = <ChatMessage>[];
  @override
  final List<ChatMessage> _messages = <ChatMessage>[];
  @override
  final Set<String> _revealed = <String>{};
  @override
  final Map<String, ChatMessage> _pendingStatuses = {};
  @override
  bool _loading = true;
  @override
  bool _loadingOlder = false;
  @override
  bool _hasMore = false;
  @override
  bool _clearing = false;
  bool _following = false;
  @override
  int _historyLimit = 50;
  @override
  int _generation = 0;
  @override
  int _newMessages = 0;

  @override
  Object? _error;
  @override
  Object? _olderError;

  @override
  String get _id => widget.target.id;

  @override
  bool get _isGroup => widget.target.kind == ConversationKind.group;

  @override
  void initState() {
    super.initState();
    _service = context.read<ChatService>();
    try {
      _playback = context.read<MorsePlaybackController>();
    } on ProviderNotFoundException {
      _playback = MorsePlaybackController();
      _ownsPlayback = true;
    }
    _events = _service.messageEvents.listen(_onEvent);
    _localSends = LocalMessageSends.forService(_service)
      ..addListener(_onLocalSend);
    _scroll.addListener(_onScroll);
    _presence.attach(context);
    unawaited(_load());
    unawaited(_initBookmarks());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoPlay.update(context);
    _presence.update(context);
  }

  @override
  void dispose() {
    _bookmarkStore?.removeListener(_onBookmarks);
    _autoPlay.dispose();
    _presence.dispose();
    unawaited(_events.cancel());
    _localSends.removeListener(_onLocalSend);
    _scroll.dispose();
    if (_ownsPlayback) {
      _playback.dispose();
    } else {
      // Also drops queued or held clips. Unmounting locks the tree; the stop
      // notifies listeners after it.
      final MorsePlaybackController playback = _playback;
      WidgetsBinding.instance.addPostFrameCallback((_) => playback.stop());
    }
    super.dispose();
  }

  @override
  Future<void> _load() async {
    final int generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<ChatMessage> history = await _service.loadHistory(_id);
      if (!mounted || generation != _generation) return;
      setState(() {
        final events = {for (final m in _messages) m.id: m};
        _messages
          ..clear()
          ..addAll(
            history.map(
              (m) => events.remove(m.id) ?? _pendingStatuses.remove(m.id) ?? m,
            ),
          )
          ..addAll(events.values);
        _loading = false;
        _hasMore = history.length == _historyLimit;
      });
      _scrollToEnd();
      _markRead();
    } on Object catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadOlder() async {
    if (_loading ||
        _loadingOlder ||
        _clearing ||
        !_hasMore ||
        _messages.isEmpty) {
      return;
    }
    if (_jumpedAway) return _loadOlderAround();
    final int generation = _generation;
    final String origin = _messages.first.id;
    final int loaded = _older.length + _messages.length;
    final int limit = (_historyLimit > loaded ? _historyLimit : loaded) + 50;
    setState(() {
      _loadingOlder = true;
      _olderError = null;
    });
    try {
      final window = await readHistoryWindow(
        _service,
        _id,
        origin: origin,
        limit: limit,
        loadedCount: () => _older.length + _messages.length,
        isCurrent: () => mounted && generation == _generation,
      );
      if (window == null) return;
      setState(() {
        final live = {
          for (final m in [..._older, ..._messages]) m.id: m,
        };
        final merged = mergeEarlierHistory(
          _older,
          window.messages.take(window.boundary).toList(),
        );
        _older
          ..clear()
          ..addAll(
            merged.map((m) => live[m.id] ?? _pendingStatuses.remove(m.id) ?? m),
          );
        _historyLimit = window.limit;
        _hasMore = window.messages.length == window.limit;
        _loadingOlder = false;
      });
    } on Object catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _olderError = e;
          _loadingOlder = false;
        });
      }
    }
  }

  /// Only once the user can see it: see [ConversationPresence].
  @override
  void _markRead() => _presence.requestRead();

  Future<void> _markReadNow() async {
    try {
      await _service.markRead(_id);
    } on Object {
      // A conversation with no row yet has nothing to mark.
    }
  }

  void _onEvent(ChatMessage message, {bool ownSend = false}) {
    if (!mounted || message.conversationId != _id) return;
    final int index = _messages.indexWhere((m) => m.id == message.id);
    final int olderIndex = _older.indexWhere((m) => m.id == message.id);
    final bool added = index < 0 && olderIndex < 0;
    // The stream includes old outgoing status updates outside our window.
    // A new local send is explicitly accepted through the composer's onSent.
    if (added && message.isMine && !ownSend) {
      _pendingStatuses[message.id] = message;
      return;
    }
    if (added && _jumpedAway && !ownSend) {
      // Live rows are not appended to an older window; offer the latest.
      setState(() => _newMessages++);
      return;
    }
    if (added && _jumpedAway) {
      _showLatest();
      return;
    }
    final bool follow = _loading || _following || _nearBottom;
    setState(() {
      if (index >= 0) {
        _messages[index] = message;
      } else if (olderIndex >= 0) {
        _older[olderIndex] = message;
      } else {
        _messages.add(message);
        if (!follow) _newMessages++;
      }
    });
    if (added && !message.isMine) _autoPlay.incoming(message);
    if (added && follow) {
      _scrollToEnd();
      if (!message.isMine) _markRead();
    }
  }

  bool get _nearBottom =>
      !_scroll.hasClients || _scroll.position.extentAfter <= 80;

  void _onScroll() {
    // The bottom of a jumped (historical) window is not the live end: it
    // must not clear the arrival count or mark the conversation read.
    if (_newMessages > 0 && _nearBottom && !_jumpedAway) {
      setState(() => _newMessages = 0);
      _markRead();
    }
    if (_jumpedAway && _nearBottom) unawaited(_loadNewerAround());
    if (!_following &&
        _scroll.hasClients &&
        _olderError == null &&
        _scroll.position.pixels - _scroll.position.minScrollExtent <= 80) {
      unawaited(_loadOlder());
    }
  }

  @override
  void _scrollToEnd() => _scrollToEndIn(8);

  void _scrollToEndIn(int remainingPasses) {
    final int generation = _generation;
    _following = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation || !_scroll.hasClients) {
        _following = false;
        return;
      }
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _generation) return;
        if (remainingPasses > 1 &&
            _scroll.hasClients &&
            _scroll.position.extentAfter > 1) {
          _scrollToEndIn(remainingPasses - 1);
        } else {
          _following = false;
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _onLocalSend() {
    final message = _localSends.latest!;
    if (message.conversationId != _id) return;
    _onEvent(_pendingStatuses.remove(message.id) ?? message, ownSend: true);
  }

  @override
  Widget build(BuildContext context) {
    final MorsePlaybackSettings settings = MorsePlaybackSettings.of(context);
    final Group? group = _group();
    final bool conference = group?.kind == GroupKind.conference;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: ConversationTitle(service: _service, target: widget.target),
        actions: [
          IconButton(
            tooltip: context.s.chatSearchMessages,
            icon: const Icon(Icons.search),
            onPressed: () => unawaited(_search()),
          ),
          ConversationActions(
            settings: settings,
            isGroup: _isGroup,
            onMenu: (a) => unawaited(_onMenu(a)),
          ),
        ],
      ),
      // Landscape phones (~320-430 px tall) and large text make the keyed
      // composer taller than the body; cap it and let it scroll instead.
      body: LayoutBuilder(
        builder: (context, box) => Column(
          children: [
            if (conference) const ConferenceNote(),
            Expanded(child: _buildList(settings)),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: box.maxHeight * 0.75),
              child: SingleChildScrollView(
                child: MessageInput(
                  key: ValueKey<String>('input_$_id'),
                  service: _service,
                  conversationId: _id,
                  playback: _playback,
                  initialDraft: _draft(),
                  onSent: (_) => _showLatest(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _draft() {
    for (final Conversation c in _service.conversations) {
      if (c.id == _id) return c.draft;
    }
    return '';
  }

  Widget _buildList(MorsePlaybackSettings settings) {
    final Object? error = _error;
    if (error != null) {
      return ConversationPlaceholder(
        text: describeChatError(context.s, error),
        onRetry: () => unawaited(_load()),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_messages.isEmpty) {
      return ConversationPlaceholder(text: context.s.chatNoMessages);
    }
    return ListenableBuilder(
      listenable: _playback,
      builder: (context, _) => ConversationTimeline(
        controller: _scroll,
        origin: _timelineOrigin,
        older: _older,
        messages: _messages,
        bubbleBuilder: (m) => _bubble(m, settings),
        hasMore: _hasMore,
        loadingOlder: _loadingOlder,
        historyFailed: _olderError != null,
        onLoadOlder: _clearing ? null : () => unawaited(_loadOlder()),
        newCount: _newMessages,
        onLatest: _showLatest,
        showLatest: _jumpedAway,
      ),
    );
  }

  Widget _bubble(ChatMessage m, MorsePlaybackSettings settings) =>
      conversationBubble(
        context,
        message: m,
        settings: settings,
        playback: _playback,
        isGroup: _isGroup,
        revealed: _revealed.contains(m.id),
        onReveal: () => setState(() => _revealed.add(m.id)),
        fallbackTitle: widget.target.title,
        service: _service,
        isSelf: widget.target.isSelf,
        bookmarked: _bookmarkStore?.contains(_id, m.id) ?? false,
      );
}
