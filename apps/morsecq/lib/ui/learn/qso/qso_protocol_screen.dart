import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/qso_practice.dart';
import '../../../training/training_controller.dart';
import '../drill_session_guard.dart';
import '../learn_platform.dart';
import '../progress_save_snack.dart';

/// A meaning check, distinct from listening to or copying abbreviations.
/// First answers are final; feedback teaches afterward and a retry is new.
class QsoProtocolScreen extends StatefulWidget {
  const QsoProtocolScreen({super.key, required this.controller});
  final TrainingController controller;

  @override
  State<QsoProtocolScreen> createState() => _QsoProtocolScreenState();
}

class _QsoProtocolScreenState extends State<QsoProtocolScreen>
    with WidgetsBindingObserver {
  late QsoProtocolAttempt _attempt;
  late MorseTiming _timing;
  late List<QsoProtocolConcept> _options;
  final Stopwatch _active = Stopwatch();
  QsoProtocolConcept? _answeredConcept;
  bool? _correct;
  bool _saving = false;
  bool _showResult = false;
  TrainingController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  void _start() {
    final at = _c.now();
    _attempt = QsoProtocolAttempt(id: ExerciseIds.next(at, _c.random), at: at);
    _timing = _c.trainerSettings.toTiming();
    _options = [...QsoProtocolConcept.values]..shuffle(_c.random);
    _answeredConcept = null;
    _correct = null;
    _showResult = false;
    _active.reset();
    _active.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isDrillBackground(state)) {
      _active.stop();
    } else if (state == AppLifecycleState.resumed && !_attempt.completed) {
      _active.start();
    }
  }

  Future<void> _answer(QsoProtocolConcept choice) async {
    if (_answeredConcept != null || _attempt.completed || _saving) return;
    final expected = _attempt.current!;
    setState(() {
      _answeredConcept = expected;
      _correct = _attempt.answer(choice);
    });
    if (!_attempt.completed) return;
    setState(() => _saving = true);
    _active.stop();
    final result = await _c.recordQsoProtocol(
      _attempt,
      timing: _timing,
      active: _active.elapsed,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!result.saved) showProgressSaveFailed(context, _c);
  }

  void _next() => setState(() {
    if (_attempt.completed) {
      _showResult = true;
    } else {
      _answeredConcept = null;
      _correct = null;
      _options = [...QsoProtocolConcept.values]..shuffle(_c.random);
    }
  });

  static String _meaning(S s, QsoProtocolConcept concept) => switch (concept) {
    QsoProtocolConcept.generalCall => s.learnQsoGeneralCall,
    QsoProtocolConcept.fromStation => s.learnQsoFromStation,
    QsoProtocolConcept.signalReport => s.learnQsoSignalReport,
    QsoProtocolConcept.bestRegards => s.learnQsoBestRegards,
  };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _active.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final question = _answeredConcept ?? _attempt.current;
    return Scaffold(
      appBar: AppBar(title: Text(s.learnQsoProtocolTitle)),
      body: DrillLeaveGuard(
        guard: _attempt.answered > 0 && !_attempt.completed,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(s.learnQsoProtocolHint),
                    const SizedBox(height: 16),
                    if (_showResult) ...[
                      Icon(
                        _attempt.passed
                            ? Icons.check_circle_outline
                            : Icons.school_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _attempt.passed
                            ? s.learnQsoProtocolPass
                            : s.learnQsoProtocolPractice,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      if (!_attempt.passed)
                        FilledButton(
                          onPressed: () => setState(_start),
                          child: Text(s.learnQsoProtocolRetry),
                        ),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(s.learnDone),
                      ),
                    ] else ...[
                      Text(
                        s.learnQsoProtocolQuestion(question!.token),
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      for (final option in _options)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OutlinedButton(
                            key: ValueKey('qso-protocol-answer-${option.name}'),
                            onPressed: _answeredConcept == null
                                ? () => unawaited(_answer(option))
                                : null,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            child: Text(_meaning(s, option)),
                          ),
                        ),
                      if (_correct != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _correct!
                              ? s.learnQsoProtocolCorrect
                              : s.learnQsoProtocolWrong(_meaning(s, question)),
                          key: const ValueKey('qso-protocol-feedback'),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          key: const ValueKey('qso-protocol-next'),
                          onPressed: _saving ? null : _next,
                          child: Text(s.learnNext),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
