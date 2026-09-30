import 'package:flutter/material.dart';

import '../../training/receive_session.dart';
import '../../training/training_controller.dart';
import '../stats/stats_screen.dart';
import 'learn_home_widgets.dart';
import 'learn_platform.dart';
import 'learn_playback.dart';
import 'learn_strings.dart';
import 'receive/receive_drill_screen.dart';
import 'review/review_screen.dart';
import 'send/send_practice_screen.dart';
import 'settings/training_settings_screen.dart';

/// Learn tab home: lesson state, daily goal, streak and the practice entry
/// points. One column on phones, two from [kLearnTwoColumnMinWidth].
class LearnHome extends StatelessWidget {
  const LearnHome({
    super.key,
    required this.controller,
    required this.playback,
    this.subtitle,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;

  /// Optional one-liner under the title (the shell's page description).
  final String? subtitle;

  Future<void> _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(
        MaterialPageRoute<Object?>(builder: (_) => screen),
      );

  void _continueLesson(BuildContext context) => _push(
    context,
    ReceiveDrillScreen(
      controller: controller,
      playback: playback,
      session: controller.startLessonSession(),
    ),
  );

  Future<void> _receivePractice(BuildContext context) async {
    final kinds = controller.availableReceiveKinds;
    final kind = await showModalBottomSheet<ReceiveDrillKind>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                LearnStrings.chooseDrill,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final k in kinds)
              ListTile(
                leading: Icon(_iconFor(k)),
                title: Text(_labelFor(k)),
                onTap: () => Navigator.of(sheetContext).pop(k),
              ),
          ],
        ),
      ),
    );
    if (kind == null || !context.mounted) {
      return;
    }
    await _push(
      context,
      ReceiveDrillScreen(
        controller: controller,
        playback: playback,
        session: controller.startReceiveSession(kind),
      ),
    );
  }

  void _sendPractice(BuildContext context) => _push(
    context,
    SendPracticeScreen(controller: controller, playback: playback),
  );

  void _review(BuildContext context) => _push(
    context,
    ReviewScreen(controller: controller, playback: playback),
  );

  void _settings(BuildContext context) => Navigator.of(context).push(
    TrainingSettingsScreen.route(controller: controller, playback: playback),
  );

  static IconData _iconFor(ReceiveDrillKind kind) => switch (kind) {
    ReceiveDrillKind.groups => Icons.grid_view,
    ReceiveDrillKind.words => Icons.text_fields,
    ReceiveDrillKind.callsigns => Icons.badge_outlined,
    ReceiveDrillKind.qso => Icons.forum_outlined,
    ReceiveDrillKind.review => Icons.replay,
  };

  static String _labelFor(ReceiveDrillKind kind) => switch (kind) {
    ReceiveDrillKind.groups => LearnStrings.drillGroups,
    ReceiveDrillKind.words => LearnStrings.drillWords,
    ReceiveDrillKind.callsigns => LearnStrings.drillCallsigns,
    ReceiveDrillKind.qso => LearnStrings.drillQso,
    ReceiveDrillKind.review => LearnStrings.reviewTitle,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(LearnStrings.learnTitle),
        actions: <Widget>[
          IconButton(
            tooltip: LearnStrings.statistics,
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StatsScreen(
                  loadProgress: () async => controller.progress,
                  course: controller.course,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: LearnStrings.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _settings(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns =
                  constraints.maxWidth >= kLearnTwoColumnMinWidth;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: twoColumns
                        ? _twoColumn(context)
                        : _oneColumn(context),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (controller.loadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              LearnStrings.loadFailed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _status() => Column(
    children: <Widget>[
      LessonCard(controller: controller),
      const SizedBox(height: 12),
      DailyGoalCard(controller: controller),
    ],
  );

  Widget _actions(BuildContext context) => QuickActions(
    dueCount: controller.dueChars.length,
    onContinueLesson: () => _continueLesson(context),
    onReceivePractice: () => _receivePractice(context),
    onSendPractice: () => _sendPractice(context),
    onReview: () => _review(context),
  );

  Widget _oneColumn(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      _header(context),
      _status(),
      const SizedBox(height: 16),
      _actions(context),
    ],
  );

  Widget _twoColumn(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      _header(context),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(flex: 3, child: _status()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _actions(context)),
        ],
      ),
    ],
  );
}
