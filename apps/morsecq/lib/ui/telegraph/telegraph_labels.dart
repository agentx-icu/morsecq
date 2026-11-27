import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';

import '../../i18n/l10n_extension.dart';
import '../common/wrapping_choice_chip.dart';

/// Name of a codebook in the current UI language.
String codebookLabel(S s, TelegraphCodebook book) => switch (book) {
  TelegraphCodebook.mainland => s.telegraphCodebookMainland,
  TelegraphCodebook.taiwan => s.telegraphCodebookTaiwan,
};

/// The always-visible mainland / Taiwan choice.
class TelegraphCodebookPicker extends StatelessWidget {
  const TelegraphCodebookPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TelegraphCodebook value;
  final ValueChanged<TelegraphCodebook> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final enlargedLabels = MediaQuery.textScalerOf(context).scale(14) > 14;
    Widget choice(TelegraphCodebook book) {
      final key = ValueKey('codebook-${book.name}');
      final label = codebookLabel(s, book);
      final selected = value == book;
      void onSelected(bool _) => onChanged(book);

      if (enlargedLabels) {
        return wrappingChoiceChip(
          key: key,
          label: label,
          selected: selected,
          onSelected: onSelected,
        );
      }
      return ChoiceChip(
        key: key,
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(s.telegraphCodebook),
        for (final book in TelegraphCodebook.values) choice(book),
      ],
    );
  }
}
