import 'dart:async';

import 'package:flutter/material.dart';

import '../../i18n/l10n_extension.dart';
import 'chat_layout.dart';
import 'morse_playback_settings.dart';
import 'playback_settings_sheet.dart';

/// App-bar actions of a conversation: training mode, auto-play, playback
/// settings and the overflow menu (members / clear history / leave).
class ConversationActions extends StatelessWidget {
  const ConversationActions({
    super.key,
    required this.settings,
    required this.isGroup,
    required this.onMenu,
  });

  final MorsePlaybackSettings settings;
  final bool isGroup;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: s.chatTrainingMode,
          isSelected: settings.trainingMode,
          icon: const Icon(Icons.school_outlined),
          selectedIcon: const Icon(Icons.school),
          onPressed: () {
            settings.trainingMode = !settings.trainingMode;
            showSnack(
              context,
              settings.trainingMode
                  ? s.chatTrainingModeOn
                  : s.chatTrainingModeOff,
            );
          },
        ),
        IconButton(
          tooltip: s.chatAutoPlay,
          isSelected: settings.autoPlay,
          icon: const Icon(Icons.volume_off_outlined),
          selectedIcon: const Icon(Icons.volume_up),
          onPressed: () {
            settings.autoPlay = !settings.autoPlay;
            showSnack(
              context,
              settings.autoPlay ? s.chatAutoPlayOn : s.chatAutoPlayOff,
            );
          },
        ),
        IconButton(
          tooltip: s.chatPlaybackSettings,
          icon: const Icon(Icons.speed),
          onPressed: () =>
              unawaited(showPlaybackSettingsSheet(context, settings)),
        ),
        PopupMenuButton<String>(
          onSelected: onMenu,
          itemBuilder: (_) => [
            if (isGroup)
              PopupMenuItem(value: 'members', child: Text(s.chatMembers)),
            PopupMenuItem(value: 'clear', child: Text(s.chatClearHistory)),
            if (isGroup)
              PopupMenuItem(value: 'leave', child: Text(s.chatLeaveGroup)),
          ],
        ),
      ],
    );
  }
}
