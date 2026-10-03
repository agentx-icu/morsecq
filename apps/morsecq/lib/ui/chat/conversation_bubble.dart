import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'conversation_learning.dart';
import 'message_bubble.dart';
import 'morse_playback_controller.dart';
import 'morse_playback_settings.dart';

/// One timeline bubble of a conversation, with its playback, reveal and
/// learning actions wired.
Widget conversationBubble(
  BuildContext context, {
  required ChatMessage message,
  required MorsePlaybackSettings settings,
  required MorsePlaybackController playback,
  required bool isGroup,
  required bool revealed,
  required VoidCallback onReveal,
  required String fallbackTitle,
}) {
  final m = message;
  final title = m.senderName ?? fallbackTitle;
  return MessageBubble(
    key: ValueKey<String>(m.id),
    message: m,
    trainingMode: settings.trainingMode,
    listenOnly: settings.listenOnly,
    revealed: revealed,
    playing: playback.playingId == m.id,
    activeMark: playback.activeMarkFor(m.id),
    showSender: isGroup,
    onReveal: onReveal,
    onPlay: () => unawaited(
      playback.toggle(m.id, m.text, settings.timing, toneHz: settings.toneHz),
    ),
    onPractice: () => unawaited(
      ConversationLearning.practise(
        context,
        message: m,
        settings: settings,
        playback: playback,
        title: title,
      ),
    ),
    onSaveMaterial: () => unawaited(
      ConversationLearning.saveAsMaterial(context, message: m, title: title),
    ),
  );
}
