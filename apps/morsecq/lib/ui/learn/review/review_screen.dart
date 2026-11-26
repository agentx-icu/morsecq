import 'package:flutter/material.dart';
import 'package:morse_session/morse_session.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../../common/app_bar_title.dart';
import '../../responsive.dart';
import '../../stats/stats_screen.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import '../mistakes/mistake_notebook_screen.dart';
import '../receive/receive_drill_screen.dart';

/// Shows what is due before starting a review. When nothing is due, free
/// practice remains available without creating a review session.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.controller,
    required this.playback,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;

  void _start(BuildContext context) {
    final hasDue = controller.reviewDueChars.isNotEmpty;
    final session = hasDue
        ? controller.startReviewSession()
        : controller.startReceiveSession(ReceiveDrillKind.characters);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ReceiveDrillScreen(
          controller: controller,
          playback: playback,
          session: session,
          title: hasDue ? context.s.learnReviewTitle : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: AppBarTitle(context.s.learnReviewTitle)),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final s = context.s;
          final due = controller.reviewDueChars;
          return AdaptivePanelBody(
            breakpoint: kLearnTwoColumnMinWidth,
            leading: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        s.learnReviewDueCount(due.length),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (due.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final symbol in due) Chip(label: Text(symbol)),
                          ],
                        ),
                      FilledButton.icon(
                        key: const ValueKey('review-practice'),
                        onPressed: () => _start(context),
                        icon: const Icon(Icons.headphones),
                        label: Text(
                          due.isEmpty
                              ? s.learnReceivePractice
                              : s.learnReviewDue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            trailing: [
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text(s.mistakesTitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (context) => MistakeNotebookScreen(
                            controller: controller,
                            playback: playback,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.insights_outlined),
                      title: Text(s.learnStatistics),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (context) => StatsScreen(
                            loadProgress: () async => controller.progress,
                            course: controller.course,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
