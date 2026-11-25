import 'package:flutter/material.dart';

/// Visible keyboard/assistive-input equivalent for existing chart details.
/// The small painted data cells retain their original pointer hit regions.
/// Callers key this by snapshot identity to dismiss menus when data changes.
class StatsDetailsPicker extends StatelessWidget {
  const StatsDetailsPicker({
    super.key,
    required this.label,
    required this.options,
    required this.selectedLabels,
    required this.selected,
    required this.onSelected,
  }) : assert(options.length == selectedLabels.length);

  final String label;
  final List<String> options;
  final List<String> selectedLabels;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final value =
        selected != null && selected! >= 0 && selected! < options.length
        ? selected
        : null;
    return Semantics(
      label: label,
      value: value == null ? null : options[value],
      child: DropdownButton<int>(
        isExpanded: true,
        itemHeight: null,
        value: value,
        hint: Text('$label…'),
        selectedItemBuilder: (_) => [
          for (final text in selectedLabels)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(text),
              ),
            ),
        ],
        items: [
          for (var i = 0; i < options.length; i++)
            DropdownMenuItem(
              value: i,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(options[i]),
              ),
            ),
        ],
        onChanged: options.isEmpty
            ? null
            : (value) {
                if (value != null) onSelected(value);
              },
      ),
    );
  }
}
