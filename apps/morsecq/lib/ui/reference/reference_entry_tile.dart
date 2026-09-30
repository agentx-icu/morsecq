import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'morse_pattern_text.dart';
import 'reference_catalog.dart';
import 'reference_playback_controller.dart';
import 'reference_strings.dart';

/// One list row of the reference: label, pattern (with playback highlight),
/// meaning and a play / stop button. Tap plays, long-press shows the
/// mnemonic when the entry has one.
class ReferenceEntryTile extends StatelessWidget {
  const ReferenceEntryTile({super.key, required this.entry, this.showPosition = false});

  final ReferenceEntry entry;

  /// Prefix the row with the entry's Koch position.
  final bool showPosition;

  @override
  Widget build(BuildContext context) {
    final ReferencePlaybackController controller =
        context.watch<ReferencePlaybackController>();
    final ThemeData theme = Theme.of(context);
    final bool playing = controller.isPlayingId(entry.id);
    final int? active = controller.activeMarkFor(entry.id);
    final String? meaning = entry.meaning;
    final int? position = entry.position;

    return ListTile(
      selected: playing,
      leading: SizedBox(
        width: showPosition ? 88 : 56,
        child: Row(
          children: <Widget>[
            if (showPosition && position != null)
              SizedBox(
                width: 32,
                child: Text(
                  '$position',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (showPosition) const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontFamilyFallback: const <String>['Menlo', 'Consolas'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      title: MorsePatternText(entry.pattern, activeMark: active),
      subtitle: meaning == null || meaning.isEmpty ? null : Text(meaning),
      trailing: IconButton(
        tooltip: playing ? ReferenceStrings.stop : ReferenceStrings.play,
        icon: Icon(playing ? Icons.stop_circle_outlined : Icons.play_circle_outline),
        onPressed: () => controller.toggle(entry.id, entry.playText),
      ),
      onTap: () => controller.toggle(entry.id, entry.playText),
      onLongPress: entry.mnemonic == null
          ? null
          : () => showReferenceMnemonic(context, entry),
    );
  }
}

/// Shows the mnemonic for [entry] in a dialog, with a play button.
Future<void> showReferenceMnemonic(BuildContext context, ReferenceEntry entry) {
  final ReferencePlaybackController controller =
      context.read<ReferencePlaybackController>();
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);
      final String? meaning = entry.meaning;
      final int? position = entry.position;
      return AlertDialog(
        title: Text(entry.label, style: theme.textTheme.displaySmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ChangeNotifierProvider<ReferencePlaybackController>.value(
              value: controller,
              child: Consumer<ReferencePlaybackController>(
                builder: (_, ReferencePlaybackController c, _) => MorsePatternText(
                  entry.pattern,
                  activeMark: c.activeMarkFor(entry.id),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(ReferenceStrings.mnemonicTitle, style: theme.textTheme.labelLarge),
            Text(entry.mnemonic ?? '', style: theme.textTheme.bodyLarge),
            if (meaning != null && meaning.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(ReferenceStrings.meaningLabel, style: theme.textTheme.labelLarge),
              Text(meaning),
            ],
            if (position != null) ...<Widget>[
              const SizedBox(height: 12),
              Text('${ReferenceStrings.kochPosition}: $position'),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => controller.play(entry.id, entry.playText),
            icon: const Icon(Icons.play_arrow),
            label: const Text(ReferenceStrings.play),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(ReferenceStrings.close),
          ),
        ],
      );
    },
  );
}
