import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';

/// The send screen's "copy from memory" switch for the app bar.
///
/// A 320 px phone (or large text) has no room for the written label next
/// to the title; it falls back to an icon there. The tooltip and merged
/// semantics keep the switch named for screen readers either way.
class CopyFromMemorySwitch extends StatelessWidget {
  const CopyFromMemorySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final media = MediaQuery.of(context);
    final textScale = media.textScaler.scale(14) / 14;
    // Room for the title, the "hear the standard" button and the label.
    final roomForLabel = media.size.width / textScale >= 470;
    return MergeSemantics(
      child: Tooltip(
        message: s.learnCopyFromMemory,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (roomForLabel)
              Text(s.learnCopyFromMemory, maxLines: 1)
            else
              Semantics(
                label: s.learnCopyFromMemory,
                child: const Icon(Icons.visibility_off_outlined),
              ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
