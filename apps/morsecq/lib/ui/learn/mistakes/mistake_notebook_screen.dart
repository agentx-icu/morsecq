import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morse_core/morse_core.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/mistake_practice.dart';
import '../../../training/receive_session.dart';
import '../../../training/training_controller.dart';
import '../../common/app_bar_title.dart';
import '../conditions/conditions_playback.dart';
import '../comprehension/comprehension_labels.dart';
import '../comprehension/listening_comprehension_screen.dart';
import '../learn_playback.dart';
import '../receive/drill_picker_sheet.dart';
import '../receive/receive_drill_screen.dart';

/// Failed exercises retained across sessions, with deliberate spaced retries.
class MistakeNotebookScreen extends StatefulWidget {
  const MistakeNotebookScreen({
    super.key,
    required this.controller,
    required this.playback,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;

  @override
  State<MistakeNotebookScreen> createState() => _MistakeNotebookScreenState();
}

class _MistakeNotebookScreenState extends State<MistakeNotebookScreen> {
  bool _showRecovered = false;

  void _retry(MistakeEntry entry) {
    final listening = entry.listeningContext;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => listening != null
            ? ListeningComprehensionScreen(
                controller: widget.controller,
                playback: widget.playback,
                exercise: listening.exercise,
                retryEntryId: entry.id,
                practiceTiming: MorseTiming(
                  wpm: entry.characterWpm,
                  farnsworthWpm: entry.effectiveWpm < entry.characterWpm
                      ? entry.effectiveWpm
                      : null,
                ),
              )
            : ReceiveDrillScreen(
                controller: widget.controller,
                playback: widget.playback,
                session: widget.controller.startMistakeSession(entry),
                title: context.s.mistakesRetry,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: AppBarTitle(context.s.mistakesTitle)),
    body: AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final book = widget.controller.progress.mistakeNotebook;
        final entries = _showRecovered ? book.recovered : book.pending;
        final s = context.s;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(s.mistakesHint),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const ValueKey('mistakes-filter-pending'),
                  label: Text('${s.mistakesPending} (${book.pending.length})'),
                  selected: !_showRecovered,
                  onSelected: (_) => setState(() => _showRecovered = false),
                ),
                ChoiceChip(
                  key: const ValueKey('mistakes-filter-recovered'),
                  label: Text(
                    '${s.mistakesRecovered} (${book.recovered.length})',
                  ),
                  selected: _showRecovered,
                  onSelected: (_) => setState(() => _showRecovered = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  _showRecovered
                      ? s.mistakesEmptyRecovered
                      : s.mistakesEmptyPending,
                ),
              ),
            for (final entry in entries)
              _MistakeCard(entry: entry, onRetry: () => _retry(entry)),
          ],
        );
      },
    ),
  );
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.entry, required this.onRetry});
  final MistakeEntry entry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final dates = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.target, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (entry.listeningContext != null)
              _ListeningMistakeAnswers(entry: entry)
            else ...[
              Text(s.mistakesOriginalCopy, style: theme.textTheme.labelLarge),
              Text(
                entry.originalAnswer.isEmpty
                    ? s.mistakesNoAnswer
                    : entry.originalAnswer,
              ),
              if (entry.answer != entry.originalAnswer) ...[
                Text(s.mistakesLastCopy, style: theme.textTheme.labelLarge),
                Text(entry.answer.isEmpty ? s.mistakesNoAnswer : entry.answer),
              ],
            ],
            const SizedBox(height: 12),
            if (entry.listeningContext
                case final MistakeListeningContext listening) ...[
              Text(s.comprehensionTitle),
              Text(comprehensionModeLabel(context, listening.exercise.mode)),
            ] else ...[
              Text(_sourceLabel(s, entry.source)),
              Text(drillLabel(s, ReceiveDrillKind.parse(entry.drillKind))),
            ],
            Text(
              '${s.learnCharacterSpeed}: ${s.learnWpmValue(entry.characterWpm.toStringAsFixed(0))}',
            ),
            Text(
              '${s.learnEffectiveSpeed}: ${s.learnWpmValue(entry.effectiveWpm.toStringAsFixed(0))}',
            ),
            Text(
              radioPresetLabel(
                s,
                entry.conditions?.preset ?? RadioPreset.clear,
              ),
            ),
            const SizedBox(height: 8),
            Text('${s.mistakesFailures}: ${entry.failureCount}'),
            Text(
              '${s.mistakesFirstFailure}: ${dates.formatCompactDate(entry.firstFailedAt)}',
            ),
            Text(
              '${s.mistakesLastFailure}: ${dates.formatCompactDate(entry.lastFailedAt)}',
            ),
            Text(
              '${s.mistakesCorrectDays}: ${entry.correctDayCount} / 2',
              key: ValueKey('mistakes-days-${entry.id}'),
            ),
            if (entry.recoveredAt case final DateTime recovered)
              Text(
                '${s.mistakesRecoveredOn}: ${dates.formatCompactDate(recovered)}',
                key: const ValueKey('mistakes-recovered-status'),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('mistakes-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.hearing),
              label: Text(s.mistakesRetry),
            ),
          ],
        ),
      ),
    );
  }
}

String _sourceLabel(S s, ExerciseSource source) => switch (source) {
  ExerciseSource.course => s.learnLessonCardTitle,
  ExerciseSource.review => s.learnReviewTitle,
  ExerciseSource.focus => s.learnReceivePractice,
  ExerciseSource.send => s.learnSendPractice,
  ExerciseSource.qso => s.learnQsoTitle,
  ExerciseSource.material => s.materialsTitle,
  ExerciseSource.placement => s.placementTitle,
  ExerciseSource.recording => s.workbenchTitle,
  ExerciseSource.conditions => s.conditionsRadio,
};

class _ListeningMistakeAnswers extends StatelessWidget {
  const _ListeningMistakeAnswers({required this.entry});
  final MistakeEntry entry;

  @override
  Widget build(BuildContext context) {
    final listening = entry.listeningContext!;
    final original = entry.originalListeningContext ?? listening;
    final s = context.s;
    String value(String? answer) =>
        answer == null || answer.isEmpty ? s.mistakesNoAnswer : answer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final question in listening.exercise.questions) ...[
          Text(
            '${comprehensionFieldLabel(context, question.field)}: ${question.answer}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            '${s.mistakesOriginalCopy}: ${value(original.answers[question.field])}',
          ),
          if (listening.answers[question.field] !=
              original.answers[question.field])
            Text(
              '${s.mistakesLastCopy}: ${value(listening.answers[question.field])}',
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
