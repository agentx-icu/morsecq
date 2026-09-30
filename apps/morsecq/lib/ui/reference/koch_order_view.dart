import 'package:flutter/material.dart';

import 'reference_catalog.dart';
import 'reference_entry_tile.dart';
import 'reference_strings.dart';

/// The Koch teaching order as a numbered list.
class KochOrderView extends StatelessWidget {
  const KochOrderView({super.key, required this.entries});

  final List<ReferenceEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length + 1,
      separatorBuilder: (_, int index) =>
          index == 0 ? const SizedBox.shrink() : const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              ReferenceStrings.kochHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return ReferenceEntryTile(entry: entries[index - 1], showPosition: true);
      },
    );
  }
}
