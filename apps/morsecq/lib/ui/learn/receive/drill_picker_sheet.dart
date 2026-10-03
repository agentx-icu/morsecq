import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/receive_session.dart';

/// Bottom sheet listing the receive drills the learned set supports.
///
/// The list scrolls inside the sheet so a short phone screen (or a large
/// text scale) never overflows as more drills unlock. Resolves to the picked
/// kind, or null when dismissed.
Future<ReceiveDrillKind?> showDrillPickerSheet(
  BuildContext context,
  List<ReceiveDrillKind> kinds,
) => showModalBottomSheet<ReceiveDrillKind>(
  context: context,
  showDragHandle: true,
  builder: (sheetContext) => SafeArea(
    child: DrillPickerList(
      kinds: kinds,
      onPicked: (k) => Navigator.of(sheetContext).pop(k),
    ),
  ),
);

/// The scrollable content of [showDrillPickerSheet].
class DrillPickerList extends StatelessWidget {
  const DrillPickerList({
    super.key,
    required this.kinds,
    required this.onPicked,
  });

  final List<ReceiveDrillKind> kinds;
  final ValueChanged<ReceiveDrillKind> onPicked;

  /// Key of the row for [kind], for tests and driving harnesses.
  static Key tileKey(ReceiveDrillKind kind) => Key('drill-${kind.name}');

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            s.learnChooseDrill,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final k in kinds)
          ListTile(
            key: tileKey(k),
            leading: Icon(drillIcon(k)),
            title: Text(drillLabel(s, k)),
            subtitle: Text(drillDescription(s, k)),
            onTap: () => onPicked(k),
          ),
      ],
    );
  }
}

IconData drillIcon(ReceiveDrillKind kind) => switch (kind) {
  ReceiveDrillKind.groups => Icons.grid_view,
  ReceiveDrillKind.characters => Icons.bolt,
  ReceiveDrillKind.words => Icons.text_fields,
  ReceiveDrillKind.abbreviations => Icons.short_text,
  ReceiveDrillKind.numbers => Icons.pin_outlined,
  ReceiveDrillKind.callsigns => Icons.badge_outlined,
  ReceiveDrillKind.confusables => Icons.compare_arrows,
  ReceiveDrillKind.qso => Icons.forum_outlined,
  ReceiveDrillKind.contest => Icons.emoji_events_outlined,
  ReceiveDrillKind.review => Icons.replay,
};

String drillLabel(S s, ReceiveDrillKind kind) => switch (kind) {
  ReceiveDrillKind.groups => s.learnDrillGroups,
  ReceiveDrillKind.characters => s.learnDrillCharacters,
  ReceiveDrillKind.words => s.learnDrillWords,
  ReceiveDrillKind.abbreviations => s.learnDrillAbbreviations,
  ReceiveDrillKind.numbers => s.learnDrillNumbers,
  ReceiveDrillKind.callsigns => s.learnDrillCallsigns,
  ReceiveDrillKind.confusables => s.learnDrillConfusables,
  ReceiveDrillKind.qso => s.learnDrillQso,
  ReceiveDrillKind.contest => s.learnDrillContest,
  ReceiveDrillKind.review => s.learnReviewTitle,
};

String drillDescription(S s, ReceiveDrillKind kind) => switch (kind) {
  ReceiveDrillKind.groups => s.learnDrillGroupsHint,
  ReceiveDrillKind.characters => s.learnDrillCharactersHint,
  ReceiveDrillKind.words => s.learnDrillWordsHint,
  ReceiveDrillKind.abbreviations => s.learnDrillAbbreviationsHint,
  ReceiveDrillKind.numbers => s.learnDrillNumbersHint,
  ReceiveDrillKind.callsigns => s.learnDrillCallsignsHint,
  ReceiveDrillKind.confusables => s.learnDrillConfusablesHint,
  ReceiveDrillKind.qso => s.learnDrillQsoHint,
  ReceiveDrillKind.contest => s.learnDrillContestHint,
  ReceiveDrillKind.review => s.learnDrillReviewHint,
};
