import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../common/feedback.dart';
import '../../common/field_label.dart';
import 'qso_labels.dart';

/// End of a simulated QSO: flow completion, fields right first time,
/// repeats, hints and sending rhythm, kept apart from copying accuracy.
class QsoSummaryView extends StatelessWidget {
  const QsoSummaryView({
    super.key,
    required this.session,
    required this.sendingWpm,
    required this.onDone,
  });

  final QsoSession session;
  final double? sendingWpm;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          Icons.emoji_events_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          s.learnQsoStageDone,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          s.learnQsoSummaryFields(session.firstTryStages, session.answerStages),
        ),
        Text(s.learnQsoSummaryRepeats(session.repeats)),
        Text(s.learnQsoSummaryHints(session.hints)),
        if (session.scenario.isAdvanced) ...[
          const SizedBox(height: 8),
          Text(
            session.scenario == QsoScenario.contestExchange
                ? s.qsoAdvancedContestSummary
                : s.qsoAdvancedPotaSummary,
          ),
        ],
        if (sendingWpm != null)
          Text(s.learnQsoSummaryRhythm(sendingWpm!.round())),
        const SizedBox(height: 12),
        for (final stage in QsoScript.stagesFor(session.scenario))
          if (session.turns
                  .where(
                    (t) =>
                        t.stage == stage &&
                        !t.fromRemote &&
                        (t.accepted == true || t.issues.isNotEmpty),
                  )
                  .toList()
              case final attempts when attempts.isNotEmpty)
            _StageResult(
              session: session,
              first: attempts.first,
              last: attempts.last,
            ),
        const SizedBox(height: 12),
        Text(
          s.learnQsoSummaryNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const ValueKey('qso-done'),
          onPressed: onDone,
          autofocus: true,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(s.learnDone),
        ),
      ],
    );
  }
}

class _StageResult extends StatelessWidget {
  const _StageResult({
    required this.session,
    required this.first,
    required this.last,
  });

  final QsoSession session;
  final QsoTurn first;
  final QsoTurn last;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final passed = first.accepted == true;
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: ValueKey('qso-summary-stage-${first.stage.name}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              QsoLabels.task(s, session.scenario, first.stage),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              passed ? s.learnQsoFirstTryAccepted : s.learnQsoFirstTryRejected,
              style: TextStyle(color: passed ? colors.primary : colors.error),
            ),
            if (!passed && first.text.isNotEmpty) Text(first.text),
            for (final issue in first.issues) Text(QsoLabels.issue(s, issue)),
            if (last != first) Text(last.text),
            if (passed) Text(first.text),
            if (session.usedAssistanceAt(first.stage))
              Text(s.learnVerdictAssisted),
            if (!passed)
              TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _StagePractice(session: session, turn: first),
                ),
                icon: const Icon(Icons.replay),
                label: Text(s.learnQsoStagePractice),
              ),
          ],
        ),
      ),
    );
  }
}

class _StagePractice extends StatefulWidget {
  const _StagePractice({required this.session, required this.turn});

  final QsoSession session;
  final QsoTurn turn;

  @override
  State<_StagePractice> createState() => _StagePracticeState();
}

class _StagePracticeState extends State<_StagePractice> {
  late final _answer = TextEditingController(text: widget.turn.text);
  QsoEvaluation? _result;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _check() => setState(() {
    final session = widget.session;
    _result = QsoEvaluator.evaluate(
      _answer.text,
      stage: widget.turn.stage,
      scenario: session.scenario,
      local: session.local,
      remote: session.remote,
      remoteReport: session.report,
    );
  });

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final result = _result;
    return ScrollingAlertDialog(
      title: Text(
        QsoLabels.task(s, widget.session.scenario, widget.turn.stage),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.learnQsoPracticeNoRecord),
          TextField(
            controller: _answer,
            decoration: InputDecoration(
              label: FieldLabel(s.qsoAdvancedTypedReply),
            ),
            onSubmitted: (_) => _check(),
          ),
          if (result?.accepted ?? false) Text(s.learnQsoProtocolPass),
          for (final issue in result?.issues ?? const <QsoIssue>[])
            Text(QsoLabels.issue(s, issue)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.actionClose),
        ),
        FilledButton(onPressed: _check, child: Text(s.learnSubmit)),
      ],
    );
  }
}
