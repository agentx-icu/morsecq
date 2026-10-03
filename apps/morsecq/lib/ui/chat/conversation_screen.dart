import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import '../../notifications/notification_center.dart';
import '../groups/group_members_sheet.dart';
import 'chat_layout.dart';
import 'conversation_actions.dart';
import 'conversation_attention.dart';
import 'conversation_auto_play.dart';
import 'conversation_target.dart';
import 'conversation_header.dart';
import 'conversation_history.dart';
import 'conversation_timeline.dart';
import 'message_bubble.dart';
import 'message_input.dart';
import 'local_message_sends.dart';
import 'morse_playback_controller.dart';
import 'morse_playback_settings.dart';

part 'conversation_screen_actions.dart';

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

class _ConversationScreenState extends State<ConversationScreen> {
  late final ChatService _service;
  late final MorsePlaybackController _playback;
  bool _ownsPlayback = false;
  late final ConversationAutoPlay _autoPlay = ConversationAutoPlay(_playback);
  late final ConversationAttention _attention;
  bool _sessionStartedWhileLoading = false;
  late final StreamSubscription<ChatMessage> _events;
  late final LocalMessageSends _localSends;
  final ScrollController _scroll = ScrollController();
  final GlobalKey _timelineOrigin = GlobalKey();
  final List<ChatMessage> _older = <ChatMessage>[];
  final List<ChatMessage> _messages = <ChatMessage>[];
  final Set<String> _revealed = <String>{};
  final Map<String, ChatMessage> _pendingStatuses = {};
  bool _loading = true;
  bool _loadingOlder = false;
  bool _hasMore = false;
  bool _clearing = false;
  bool _following = false;
  int _historyLimit = 50;
  int _generation = 0;
  int _newMessages = 0;
  Object? _error;
  Object? _olderError;

  String get _id => widget.target.id;

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
    _attention = ConversationAttention(
      service: _service,
      conversationId: _id,
      center: context.read<NotificationCenter?>(),
      onSessionStarted: _onSessionStarted,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _attention.start();
    });
    _events = _service.messageEvents.listen(_onEvent);
    _localSends = LocalMessageSends.forService(_service)
      ..addListener(_onLocalSend);
    _scroll.addListener(_onScroll);
    unawaited(_load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoPlay.update(context);
    _attention.update(context);
  }

  @override
  void dispose() {
    _autoPlay.dispose();
    _attention.dispose();
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

  /// Opening a chat before its session exists fails with not_connected;
  /// the session starting (seen even mid-load) retries a failed load.
  void _onSessionStarted() {
    if (_loading) {
      _sessionStartedWhileLoading = true;
    } else if (_error != null) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final int generation = _generation;
    _sessionStartedWhileLoading = false;
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
      _attention.markRead();
    } on Object catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = e;
          _loading = false;
        });
        if (_sessionStartedWhileLoading) unawaited(_load());
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
      if (!message.isMine) _attention.markRead();
    }
  }

  bool get _nearBottom =>
      !_scroll.hasClients || _scroll.position.extentAfter <= 80;

  void _onScroll() {
    if (_newMessages > 0 && _nearBottom) {
      setState(() => _newMessages = 0);
      _attention.markRead();
    }
    if (!_following &&
        _scroll.hasClients &&
        _olderError == null &&
        _scroll.position.pixels - _scroll.position.minScrollExtent <= 80) {
      unawaited(_loadOlder());
    }
  }

  void _scrollToEnd([int remainingPasses = 8]) {
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
          _scrollToEnd(remainingPasses - 1);
        } else {
          _following = false;
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _showLatest() {
    setState(() => _newMessages = 0);
    _scrollToEnd();
    _attention.markRead();
  }

  void _onLocalSend() {
    final message = _localSends.latest!;
    if (message.conversationId != _id) return;
    _onEvent(_pendingStatuses.remove(message.id) ?? message, ownSend: true);
  }

  Future<void> _clearHistory() async {
    final S s = context.s;
    final bool ok = await confirm(
      context,
      title: s.chatClearHistory,
      body: s.chatClearHistoryBody,
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
    // A message being deleted must not keep sounding or wait in the queue.
    _playback.cancelMessages(ids);
    try {
      await _service.clearHistory(_id);
      _localSends.recordClear(_id, ids);
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final MorsePlaybackSettings settings = MorsePlaybackSettings.of(context);
    final Group? group = _group();
    final bool conference = group?.kind == GroupKind.conference;

    return Scaffold(
      appBar: ConversationAppBar(
        service: _service,
        target: widget.target,
        settings: settings,
        embedded: widget.embedded,
        onMenu: (a) => unawaited(_onMenu(a)),
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
      ),
    );
  }

  Widget _bubble(ChatMessage m, MorsePlaybackSettings settings) =>
      MessageBubble(
        key: ValueKey<String>(m.id),
        message: m,
        trainingMode: settings.trainingMode,
        revealed: _revealed.contains(m.id),
        playing: _playback.playingId == m.id,
        activeMark: _playback.activeMarkFor(m.id),
        showSender: _isGroup,
        onReveal: () => setState(() => _revealed.add(m.id)),
        onPlay: () => unawaited(
          _playback.toggle(
            m.id,
            m.text,
            settings.timing,
            toneHz: settings.toneHz,
          ),
        ),
      );
}
