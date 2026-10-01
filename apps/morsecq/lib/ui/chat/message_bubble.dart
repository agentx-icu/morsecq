import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../../i18n/l10n_extension.dart';
import 'chat_layout.dart';
import 'message_status_icon.dart';
import 'morse_pattern_text.dart';
import '../appearance/style_tokens.dart';

/// A chat bubble with the three layers from plan §5.3: Morse pattern, plain
/// text (hidden in training mode until revealed) and a play button.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.trainingMode,
    required this.revealed,
    required this.playing,
    required this.onPlay,
    required this.onReveal,
    this.activeMark,
    this.showSender = false,
  });

  final ChatMessage message;
  final bool trainingMode;
  final bool revealed;
  final bool playing;
  final int? activeMark;
  final VoidCallback onPlay;
  final VoidCallback onReveal;

  /// Group chats show who keyed the message.
  final bool showSender;

  bool get _textHidden => trainingMode && !revealed && !message.isMine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final radius = StyleTokens.of(context)?.bubbleRadius ?? 16;
    final S s = context.s;
    final bool mine = message.isMine;
    final Color background = mine
        ? scheme.primaryContainer
        : scheme.surfaceContainerHigh;
    final Color foreground = mine
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final String pattern = MorseEncoder.toPattern(message.text);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.fromLTRB(mine ? 48 : 12, 4, mine ? 12 : 48, 4),
          child: Material(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
              bottomLeft: Radius.circular(mine ? radius : radius.clamp(0, 4)),
              bottomRight: Radius.circular(mine ? radius.clamp(0, 4) : radius),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSender && !mine)
                    Text(
                      message.senderName ?? _shortKey(message.senderId),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.tertiary,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MorsePatternText(
                          pattern,
                          activeMark: activeMark,
                          style: theme.textTheme.bodyLarge,
                          color: foreground.withValues(alpha: 0.75),
                          highlightColor: scheme.primary,
                        ),
                      ),
                      IconButton(
                        tooltip: playing ? s.chatStop : s.chatPlay,
                        onPressed: pattern.isEmpty ? null : onPlay,
                        icon: Icon(
                          playing ? Icons.stop_circle : Icons.play_circle,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_textHidden)
                    _HiddenText(onReveal: onReveal)
                  else
                    SelectableText(
                      message.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: foreground,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatMessageTime(context, message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: foreground.withValues(alpha: 0.7),
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        MessageStatusIcon(message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _shortKey(String key) =>
      key.length > 8 ? key.substring(0, 8) : key;
}

class _HiddenText extends StatelessWidget {
  const _HiddenText({required this.onReveal});

  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Wrap, not Row: on a phone the bubble is ~330 px wide and the hint plus
    // the button do not always fit on one line.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Icon(
          Icons.visibility_off_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        Text(
          context.s.chatHiddenText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onReveal, child: Text(context.s.chatReveal)),
      ],
    );
  }
}
