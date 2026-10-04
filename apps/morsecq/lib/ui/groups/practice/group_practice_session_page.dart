import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/chat_copy_session.dart';
import '../../../training/group_practice.dart';
import '../../../training/training_controller.dart';
import '../../chat/chat_layout.dart';
import '../../chat/morse_playback_settings.dart';
import '../../learn/chat_copy/chat_copy_screen.dart';
import '../../learn/learn_playback.dart';
import 'group_practice_page.dart';

/// One local group practice session (F14): its rounds (references to
/// ordinary group messages), copying a round on the shared copy-practice
/// page at the learner's own speed, the instructor's turn checklist, and a
/// summary. Answers, scores and drafts stay on this device; the result to
/// share is only shown, for the learner to key in the chat if they choose.
class GroupPracticeSessionPage extends StatefulWidget {
  const GroupPracticeSessionPage({
    super.key,
    required this.controller,
    required this.sessionId,
  });

  final TrainingController controller;
  final String sessionId;

  @override
  State<GroupPracticeSessionPage> createState() =>
      _GroupPracticeSessionPageState();
}

class _GroupPracticeSessionPageState extends State<GroupPracticeSessionPage> {
  GroupPracticeSession? _session;

  /// Round messages read from history; a missing key means not found yet
  /// (or chat is not connected), never "deleted".
  final Map<String, ChatMessage> _messages = {};

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  ChatService get _chat => context.read<ChatService>();

  Future<void> _load() async {
    final book = await widget.controller.readGroupPractice();
    final session = book.byId(widget.sessionId);
    if (!mounted) return;
    setState(() => _session = session);
    if (session == null) return;
    for (final r in session.rounds) {
      await _resolve(session, r);
    }
  }

  /// Reads a round's message; a definite "not in history" marks the round
  /// unavailable. Without a session nothing is concluded.
  Future<void> _resolve(GroupPracticeSession s, GroupPracticeRound r) async {
    final List<ChatMessage> rows;
    try {
      rows = await _chat.loadAround(
        s.conversationId,
        r.messageId,
        before: 0,
        after: 0,
      );
    } on ChatException {
      return;
    }
    if (!mounted) return;
    final hit = rows.where((m) => m.id == r.messageId).firstOrNull;
    if (hit != null) {
      setState(() => _messages[r.messageId] = hit);
    } else if (r.state != GroupRoundState.unavailable) {
      await _update(
        (b) => b.setRoundState(s.id, r.id, GroupRoundState.unavailable),
      );
    }
  }

  Future<void> _update(GroupPracticeBook Function(GroupPracticeBook) f) async {
    final book = await widget.controller.updateGroupPractice(f);
    if (mounted) setState(() => _session = book.byId(widget.sessionId));
  }

  Future<void> _addRounds() async {
    final s = context.s;
    final session = _session!;
    List<ChatMessage> history;
    try {
      history = await _chat.loadHistory(session.conversationId, limit: 50);
    } on ChatException {
      if (mounted) showSnack(context, s.groupPracticeNotConnected);
      return;
    }
    if (!mounted) return;
    final instructor = session.role == GroupPracticeRole.instructor;
    final taken = session.rounds.map((r) => r.messageId).toSet();
    final candidates = history.reversed
        .where((m) => m.isMine == instructor && !taken.contains(m.id))
        .toList();
    final picked = await showModalBottomSheet<ChatMessage>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: candidates.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.groupPracticeNoMessages),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final m in candidates)
                    ListTile(
                      key: Key('gp-pick-${m.id}'),
                      title: Text(
                        // Participants pick by sender and time: the text is
                        // the exercise, not to be read before copying.
                        instructor ? m.text : (m.senderName ?? m.senderId),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(formatMessageTime(sheet, m.timestamp)),
                      onTap: () => Navigator.of(sheet).pop(m),
                    ),
                ],
              ),
      ),
    );
    if (picked == null || !mounted) return;
    _messages[picked.id] = picked;
    await _update(
      (b) => b.addRound(
        session.id,
        roundId: GroupPracticeBook.newId('gpr'),
        messageId: picked.id,
        messageAt: picked.timestamp,
      ),
    );
  }

  Future<void> _copy(GroupPracticeRound round) async {
    final message = _messages[round.messageId];
    if (message == null) return;
    final settings = MorsePlaybackSettings.of(context, listen: false);
    final c = widget.controller;
    // Each member copies at their own chosen speed and tone.
    final copy = ChatCopySession(
      text: message.text,
      conversationId: message.conversationId,
      messageId: message.id,
      profileKey: c.profileKey,
      timing: settings.timing,
      toneHz: settings.toneHz,
    );
    LearnPlaybackFactory factory;
    try {
      factory = context.read<LearnPlaybackFactory>();
    } on ProviderNotFoundException {
      factory = const DevicePlaybackFactory();
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatCopyScreen(
          controller: c,
          playback: factory,
          session: copy,
        ),
      ),
    );
    final attempt = GroupPracticeStore.attemptOf(
      copy.id,
      copy.score,
      copy.assistance,
    );
    if (attempt == null) return;
    await _update((b) => b.recordAttempt(widget.sessionId, round.id, attempt));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = _session;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final instructor = session.role == GroupPracticeRole.instructor;
    final sum = session.summary;
    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        actions: [
          IconButton(
            tooltip: s.actionDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await widget.controller.updateGroupPractice(
                (b) => b.remove(session.id),
              );
              navigator.pop();
            },
          ),
        ],
      ),
      floatingActionButton: session.completed
          ? null
          : FloatingActionButton.extended(
              key: const Key('gp-add-round'),
              onPressed: _addRounds,
              icon: const Icon(Icons.playlist_add),
              label: Text(s.groupPracticeAddRound),
            ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            Text(
              '${groupRoleLabel(s, session.role)} · '
              '${instructor ? s.groupPracticeInstructorHint : s.groupPracticeParticipantHint}',
            ),
            const SizedBox(height: 8),
            Text(
              s.groupPracticeLocalNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final (i, r) in session.rounds.indexed) _round(i, r, instructor),
            const Divider(height: 32),
            Card(
              key: const Key('gp-summary'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.groupPracticeSummary, style: Theme.of(context).textTheme.titleSmall),
                    Text(s.groupPracticeRoundsDone(sum.done, sum.rounds)),
                    if (sum.unavailable > 0)
                      Text(s.groupPracticeUnavailableCount(sum.unavailable)),
                    if (sum.attempts > 0) ...[
                      Text(s.groupPracticeAccuracy((sum.accuracy * 100).round())),
                      if (sum.assisted > 0) Text(s.groupPracticeAssisted(sum.assisted)),
                      const SizedBox(height: 8),
                      Text(
                        s.groupPracticeShareHint(
                          sum.done,
                          sum.rounds,
                          (sum.accuracy * 100).round(),
                        ),
                        key: const Key('gp-share'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!session.completed)
              OutlinedButton(
                key: const Key('gp-complete'),
                onPressed: () => _update((b) => b.complete(session.id)),
                child: Text(s.groupPracticeComplete),
              ),
          ],
        ),
      ),
    );
  }

  Widget _round(int i, GroupPracticeRound r, bool instructor) {
    final s = context.s;
    final message = _messages[r.messageId];
    final unavailable = r.state == GroupRoundState.unavailable;
    final last = r.attempts.isEmpty ? null : r.attempts.last;
    final subtitle = unavailable
        ? s.groupPracticeSourceGone
        : message == null
        ? s.groupPracticeSourceLoading
        : [
            if (instructor || last != null) message.text,
            formatMessageTime(context, r.messageAt),
            if (last != null)
              s.groupPracticeAttemptResult(
                (last.accuracy * 100).round(),
                r.attempts.length,
              ),
          ].join('\n');
    return Card(
      child: ListTile(
        key: Key('gp-round-$i'),
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text(
          r.state == GroupRoundState.done
              ? s.groupPracticeRoundDone
              : unavailable
              ? s.groupPracticeRoundUnavailable
              : s.groupPracticeRoundOpen,
        ),
        subtitle: Text(subtitle),
        trailing: Wrap(
          children: [
            if (!instructor && message != null && !unavailable)
              IconButton(
                key: Key('gp-copy-$i'),
                tooltip: s.groupPracticeCopy,
                icon: const Icon(Icons.hearing),
                onPressed: () => _copy(r),
              ),
            if (instructor && !unavailable)
              Checkbox(
                key: Key('gp-done-$i'),
                value: r.state == GroupRoundState.done,
                onChanged: (v) => _update(
                  (b) => b.setRoundState(
                    widget.sessionId,
                    r.id,
                    v == true ? GroupRoundState.done : GroupRoundState.open,
                  ),
                ),
              ),
            IconButton(
              tooltip: s.groupPracticeRemoveRound,
              icon: const Icon(Icons.close),
              onPressed: () => _update((b) => b.removeRound(widget.sessionId, r.id)),
            ),
          ],
        ),
      ),
    );
  }
}
