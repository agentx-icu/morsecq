import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'morse_pattern_text.dart';
import 'reference_catalog.dart';
import 'reference_entry_tile.dart';
import 'reference_mnemonics.dart';
import 'reference_playback_controller.dart';
import 'reference_strings.dart';

/// A–Z and 0–9 as tappable cards. Tap plays, long-press shows the mnemonic.
///
/// Cards are at least 48 px on each side (they are ~100 px), so the grid is
/// comfortable with a thumb as well as a mouse.
class AlphabetGrid extends StatelessWidget {
  const AlphabetGrid({super.key, required this.entries, this.hint});

  final List<ReferenceEntry> entries;

  /// Optional line shown above the grid.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return CustomScrollView(
      slivers: <Widget>[
        if (hint != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.05,
            ),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) =>
                AlphabetCard(entry: entries[index]),
          ),
        ),
      ],
    );
  }
}

/// One character card of the [AlphabetGrid].
class AlphabetCard extends StatelessWidget {
  const AlphabetCard({super.key, required this.entry});

  final ReferenceEntry entry;

  @override
  Widget build(BuildContext context) {
    final ReferencePlaybackController controller =
        context.watch<ReferencePlaybackController>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool playing = controller.isPlayingId(entry.id);
    final int? active = controller.activeMarkFor(entry.id);

    return Semantics(
      button: true,
      label: '${entry.label}, ${ReferenceMnemonics.spokenRhythm(entry.pattern)}',
      hint: ReferenceStrings.alphabetHint,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: playing ? scheme.primaryContainer : null,
        child: InkWell(
          onTap: () => controller.toggle(entry.id, entry.playText),
          onLongPress: () => showReferenceMnemonic(context, entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      entry.label,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: playing ? scheme.onPrimaryContainer : null,
                      ),
                    ),
                    if (playing)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(
                          Icons.volume_up,
                          size: 16,
                          color: scheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                MorsePatternText(
                  entry.pattern,
                  activeMark: active,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                  color: playing ? scheme.onPrimaryContainer : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
