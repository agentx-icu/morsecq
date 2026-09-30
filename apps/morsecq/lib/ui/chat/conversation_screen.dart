import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../groups/group_members_sheet.dart';
import 'chat_layout.dart';
import 'chat_scope.dart';
import 'chat_strings.dart';
import 'conversation_target.dart';
import 'message_bubble.dart';
import 'message_input.dart';
import 'morse_playback_controller.dart';
import 'morse_playback_settings.dart';
import 'playback_settings_sheet.dart';

/// One conversation (c2c or group): history + live events, Morse bubbles,
/// training mode, playback settings and the three-mode input.
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
  late final StreamSubscription<ChatMessage> _events;
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final Set<String> _revealed = <String>{};
  bool _loading = true;
  Object? _error;

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
    _events = _service.messageEvents.listen(_onEvent);
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_events.cancel());
    _scroll.dispose();
    if (_ownsPlayback) {
      _playback.dispose();
    } else if (_playback.playingId != null) {
      _playback.stop();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final List<ChatMessage> history = await _service.loadHistory(_id);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
        _loading = false;
      });
      _scrollToEnd();
      await _markRead();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _markRead() async {
    try {
      await _service.markRead(_id);
    } on Object {
      // A conversation with no row yet has nothing to mark.
    }
  }

  void _onEvent(ChatMessage message) {
    if (message.conversationId != _id) return;
    final int index = _messages.indexWhere((m) => m.id == message.id);
    setState(() {
      if (index >= 0) {
        _messages[index] = message;
      } else {
        _messages.add(message);
      }
    });
    if (index < 0) {
      _scrollToEnd();
      if (!message.isMine) unawaited(_markRead());
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Group? _group() {
    if (!_isGroup) return null;
    for (final Group g in _service.groups) {
      if (g.id == widget.target.peerId) return g;
    }
    return null;
  }

  Future<void> _leaveGroup() async {
    final bool ok = await confirm(
      context,
      title: ChatStrings.leaveGroupTitle,
      body: ChatStrings.leaveGroupBody,
      confirmLabel: ChatStrings.leave,
    );
    if (!ok || !mounted) return;
    try {
      await _service.leaveGroup(widget.target.peerId);
    } on Object catch (e) {
      if (mounted) showSnack(context, describeError(e));
      return;
    }
    if (!mounted) return;
    if (widget.embedded) {
      widget.onClosed?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _clearHistory() async {
    try {
      await _service.clearHistory(_id);
      if (mounted) setState(_messages.clear);
    } on Object catch (e) {
      if (mounted) showSnack(context, describeError(e));
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

  @override
  Widget build(BuildContext context) {
    final MorsePlaybackSettings settings = MorsePlaybackSettings.of(context);
    final Group? group = _group();
    final bool conference = group?.kind == GroupKind.conference;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: _TitleBlock(service: _service, target: widget.target),
        actions: [
          IconButton(
            tooltip: ChatStrings.trainingMode,
            isSelected: settings.trainingMode,
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            onPressed: () {
              settings.trainingMode = !settings.trainingMode;
              showSnack(
                context,
                settings.trainingMode
                    ? ChatStrings.trainingModeOn
                    : ChatStrings.trainingModeOff,
              );
            },
          ),
          IconButton(
            tooltip: ChatStrings.playbackSettings,
            icon: const Icon(Icons.speed),
            onPressed: () =>
                unawaited(showPlaybackSettingsSheet(context, settings)),
          ),
          PopupMenuButton<String>(
            onSelected: (a) => unawaited(_onMenu(a)),
            itemBuilder: (_) => [
              if (_isGroup)
                const PopupMenuItem(
                  value: 'members',
                  child: Text(ChatStrings.members),
                ),
              const PopupMenuItem(
                value: 'clear',
                child: Text(ChatStrings.clearHistory),
              ),
              if (_isGroup)
                const PopupMenuItem(
                  value: 'leave',
                  child: Text(ChatStrings.leaveGroup),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (conference) const _ConferenceNote(),
          Expanded(child: _buildList(settings)),
          MessageInput(
            key: ValueKey<String>('input_$_id'),
            service: _service,
            conversationId: _id,
            playback: _playback,
            initialDraft: _draft(),
          ),
        ],
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
    if (error != null) return Center(child: Text(describeError(error)));
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          ChatStrings.noMessages,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: _playback,
      builder: (context, _) => ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final ChatMessage m = _messages[index];
          return MessageBubble(
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
        },
      ),
    );
  }
}

/// Title plus a live subtitle: online/offline for a friend, member count for
/// a group.
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.service, required this.target});

  final ChatService service;
  final ConversationTarget target;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget subtitle = target.kind == ConversationKind.c2c
        ? StreamBuilder<List<Friend>>(
            stream: service.friendChanges,
            initialData: service.friends,
            builder: (context, snapshot) {
              Friend? friend;
              for (final Friend f in snapshot.data ?? const <Friend>[]) {
                if (f.publicKey == target.peerId) friend = f;
              }
              final bool online = friend?.online ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: online
                        ? Colors.green
                        : scheme.outlineVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    online ? ChatStrings.online : ChatStrings.offline,
                    style: text.labelSmall,
                  ),
                ],
              );
            },
          )
        : StreamBuilder<List<Group>>(
            stream: service.groupChanges,
            initialData: service.groups,
            builder: (context, snapshot) {
              Group? group;
              for (final Group g in snapshot.data ?? const <Group>[]) {
                if (g.id == target.peerId) group = g;
              }
              if (group == null) return const SizedBox.shrink();
              final String kind = group.kind == GroupKind.conference
                  ? ' · ${ChatStrings.conferenceBadge}'
                  : '';
              return Text(
                '${group.memberCount} ${ChatStrings.membersCount}$kind',
                style: text.labelSmall,
              );
            },
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(target.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle,
      ],
    );
  }
}

class _ConferenceNote extends StatelessWidget {
  const _ConferenceNote();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: scheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ChatStrings.conferenceNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
