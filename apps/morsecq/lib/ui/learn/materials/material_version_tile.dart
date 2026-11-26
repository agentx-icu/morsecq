part of 'materials_screen.dart';

class _MaterialVersionTile extends StatelessWidget {
  const _MaterialVersionTile({required this.label, required this.material});

  final String label;
  final TrainingMaterial material;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final localizations = MaterialLocalizations.of(context);
    final updatedAt = material.updatedAt.toLocal();
    final stamp =
        '${localizations.formatCompactDate(updatedAt)} '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(updatedAt))}';
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(
        '$label · ${material.title} · ${MaterialLabels.kind(s, material.kind)}',
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${s.materialsItems(material.normalizedItems.length)} · ${s.materialsImportUpdated(stamp)}',
          ),
          Text(
            material.originalText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      children: [SelectableText(material.originalText)],
    );
  }
}
