import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/receive_session.dart';
import '../../../training/training_controller.dart';
import '../learn_playback.dart';
import 'receive_drill_screen.dart';
import 'guided_practice_sheet.dart';

/// What to do after a receive session, from its verdict: hear a confusion
/// pair side by side, drill the weak symbols, retry the challenge or take
/// it after free practice, and Done. Replaces the bare Done button of the
/// summary so a failed challenge always comes with a way forward.
class ReceiveNextSteps extends StatelessWidget {
  const ReceiveNextSteps({
    super.key,
    required this.controller,
    required this.playbackFactory,
    required this.playback,
    required this.session,
    required this.outcome,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playbackFactory;

  /// The finished screen's playback, for contrast playback; null while it
  /// is still being created.
  final LearnPlayback? playback;
  final ReceiveSession session;
  final ReceiveOutcome outcome;

  static const int maxContrastPairs = 3;

  /// Playing after the session is scored is not assistance.
  void _hear(String target, String answered) {
    final text = answered.isEmpty ? target : '$target $answered';
    playback?.player.play(MorseEncoder.encode(text, session.timing));
  }

  Future<void> _replaceWith(BuildContext context, ReceiveSession next) =>
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Object?>(
          builder: (_) => ReceiveDrillScreen(
            controller: controller,
            playback: playbackFactory,
            session: next,
          ),
        ),
      );

  void _drillWeak(BuildContext context, List<String> weak) {
    final next = controller.startFocusSession(
      weak,
      charBudget: ReceiveSessionStart.shortFocusChars,
    );
    if (next != null) _replaceWith(context, next);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final verdict = verdictOf(outcome, session);
    final learned = controller.learnedChars.toSet();
    final weak = outcome.score
        .weakChars()
        .where(learned.contains)
        .take(4)
        .toList(growable: false);
    final confusions = session
        .confusionPairs(limit: maxContrastPairs)
        .where((p) => learned.contains(p.$1))
        .toList(growable: false);
    final isReview = session.kind == ReceiveDrillKind.review;
    final offerChallenge =
        verdict.isFailedChallenge ||
        (verdict == ReceiveVerdict.practice &&
            !isReview &&
            session.conditions == null);
    final big = FilledButton.styleFrom(minimumSize: const Size.fromHeight(52));
    final nextLevel = controller.recommendedGuidedLevel;
    final retryGuided =
        session.sourceRef ==
        'guided/${controller.currentLesson}/${nextLevel.name}';
    final guided = session.sourceRef?.startsWith('guided/') ?? false;
    // A pass unlocked a symbol: meet it before anything else.
    final unlocked = verdict == ReceiveVerdict.unlocked;
    final newest = controller.newestChar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (unlocked) ...[
          FilledButton.icon(
            key: const ValueKey('practise-new-char'),
            onPressed: () =>
                _replaceWith(context, controller.startGuidedSession()),
            icon: const Icon(Icons.bolt),
            label: Text(s.learnPractiseNewChar(newest)),
            style: big,
          ),
          const SizedBox(height: 12),
          if (playback != null) ...[
            OutlinedButton.icon(
              key: const ValueKey('hear-new-char'),
              onPressed: () => _hear(newest, ''),
              icon: const Icon(Icons.hearing),
              label: Text(s.learnHearChar(newest)),
            ),
            const SizedBox(height: 12),
          ],
        ],
        if (guided) ...[
          FilledButton.icon(
            key: const ValueKey('guided-next'),
            onPressed: () =>
                _replaceWith(context, controller.startGuidedSession()),
            icon: const Icon(Icons.hearing),
            label: Text(
              '${retryGuided ? s.learnGuidedRetry : s.learnGuidedContinue}: ${guidedLevelLabel(s, nextLevel)}',
            ),
            style: big,
          ),
          const SizedBox(height: 12),
        ],
        if (confusions.isNotEmpty && playback != null) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              for (final (target, answered, _) in confusions)
                OutlinedButton.icon(
                  key: ValueKey<String>('hear-$target-$answered'),
                  onPressed: () => _hear(target, answered),
                  icon: const Icon(Icons.hearing),
                  label: Text(
                    answered.isEmpty
                        ? s.learnHearChar(target)
                        : s.learnCompareWith(target, answered),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (weak.isNotEmpty && !isReview) ...<Widget>[
          OutlinedButton.icon(
            key: const ValueKey('drill-weak'),
            onPressed: () => _drillWeak(context, weak),
            icon: const Icon(Icons.center_focus_strong_outlined),
            label: Text('${s.learnDrillWeak} (${weak.join(' ')})'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (offerChallenge) ...<Widget>[
          FilledButton.tonalIcon(
            key: const ValueKey('take-challenge'),
            onPressed: () =>
                _replaceWith(context, controller.startLessonSession()),
            icon: const Icon(Icons.school_outlined),
            label: Text(
              verdict.isFailedChallenge
                  ? s.learnRetryChallenge
                  : s.learnTakeChallenge,
            ),
            style: big,
          ),
          const SizedBox(height: 12),
        ],
        if (guided || unlocked)
          OutlinedButton(
            key: const ValueKey('receive-done'),
            onPressed: () => Navigator.of(context).pop(outcome),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(s.learnDone),
          )
        else
          FilledButton(
            key: const ValueKey('receive-done'),
            onPressed: () => Navigator.of(context).pop(outcome),
            autofocus: true,
            style: big,
            child: Text(s.learnDone),
          ),
      ],
    );
  }
}
