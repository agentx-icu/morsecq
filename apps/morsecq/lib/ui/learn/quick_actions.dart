import 'package:flutter/material.dart';

import '../../i18n/l10n_extension.dart';
import '../appearance/style_tokens.dart';

/// The practice entry points: copying, sending and review stay visible;
/// the QSO simulator shows its readiness instead of a lesson lock; the
/// less common entries (materials, telegraph code) fold into *More
/// practice* so a beginner sees one obvious path.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.dueCount,
    required this.onContinueLesson,
    required this.onReceivePractice,
    required this.onSendPractice,
    required this.onReview,
    this.showContinue = true,
    this.onQso,
    this.qsoStatus,
    this.onMaterials,
    this.onTelegraph,
    this.onGuidedSend,
  });

  /// Opens My materials.
  final VoidCallback? onMaterials;

  /// Opens Chinese telegraph-code practice (F13).
  final VoidCallback? onTelegraph;
  final VoidCallback? onGuidedSend;

  /// Opens the QSO simulator setup (always available; readiness is shown,
  /// never enforced by a lesson number).
  final VoidCallback? onQso;

  /// Readiness label shown beside the QSO entry.
  final String? qsoStatus;

  final int dueCount;
  final VoidCallback onContinueLesson;
  final VoidCallback onReceivePractice;
  final VoidCallback onSendPractice;
  final VoidCallback onReview;
  final bool showContinue;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final more = <Widget>[
      if (onGuidedSend != null)
        _ActionTile(
          key: const ValueKey('guided-send'),
          icon: Icons.school_outlined,
          label: s.sendGuideTitle,
          onTap: onGuidedSend,
        ),
      if (onMaterials != null)
        _ActionTile(
          icon: Icons.library_books_outlined,
          label: s.materialsTitle,
          onTap: onMaterials,
        ),
      if (onTelegraph != null)
        _ActionTile(
          icon: Icons.translate,
          label: s.telegraphTitle,
          onTap: onTelegraph,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showContinue)
          FilledButton.icon(
            onPressed: onContinueLesson,
            icon: const Icon(Icons.play_arrow),
            label: Text(s.learnContinueLesson),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        if (showContinue) const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.hearing,
          label: s.learnReceivePractice,
          onTap: onReceivePractice,
          color: StyleTokens.of(context)?.receiveSurface,
        ),
        _ActionTile(
          icon: Icons.touch_app_outlined,
          label: s.learnSendPractice,
          onTap: onSendPractice,
          color: StyleTokens.of(context)?.sendSurface,
        ),
        _ActionTile(
          icon: Icons.replay,
          label: s.learnReviewDue,
          trailing: s.learnReviewDueCount(dueCount),
          onTap: onReview,
        ),
        if (onQso != null)
          _ActionTile(
            icon: Icons.cell_tower,
            label: s.learnQsoAction,
            trailing: qsoStatus,
            onTap: onQso,
          ),
        if (more.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              key: const ValueKey('more-practice'),
              leading: const Icon(Icons.more_horiz),
              title: Text(s.learnMorePractice),
              shape: const Border(),
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              children: more,
            ),
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        minTileHeight: 56,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: trailing == null
            ? Text(label)
            : Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(label),
                  Text(trailing!, style: theme.textTheme.labelLarge),
                ],
              ),
        trailing: trailing == null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
