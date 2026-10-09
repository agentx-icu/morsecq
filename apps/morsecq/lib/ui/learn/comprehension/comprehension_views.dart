part of 'listening_comprehension_screen.dart';

extension _ComprehensionViews on _ListeningComprehensionScreenState {
  Widget _content(BuildContext context) {
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_started) ...[
          Text(s.comprehensionIntro),
          const SizedBox(height: 12),
          Text(
            s.comprehensionAudioRequired,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<ListeningMode>(
          key: const ValueKey('comprehension-mode'),
          initialValue: _mode,
          isExpanded: true,
          decoration: InputDecoration(
            label: FieldLabel(s.comprehensionModeLabel),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final mode in ListeningMode.values)
              DropdownMenuItem(
                value: mode,
                child: Text(comprehensionModeLabel(context, mode)),
              ),
          ],
          onChanged:
              _started || widget.planStepId != null || widget.exercise != null
              ? null
              : (mode) {
                  if (mode != null) _switchMode(mode);
                },
        ),
        const SizedBox(height: 12),
        Text(comprehensionModeHelp(context, _mode)),
        const SizedBox(height: 12),
        Text(
          s.comprehensionSpeed(
            _settings.trainer.characterWpm.toStringAsFixed(0),
            _effective.toStringAsFixed(0),
          ),
        ),
        if (!_started &&
            widget.planStepId == null &&
            widget.practiceTiming == null &&
            widget.exercise == null) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            key: const ValueKey('comprehension-speed'),
            initialValue: _effective,
            decoration: InputDecoration(
              label: FieldLabel(s.comprehensionSpeedLabel),
            ),
            items: [
              for (final speed in ({
                10.0,
                13.0,
                15.0,
                18.0,
                20.0,
                25.0,
                _effective,
              }.toList()..sort()))
                DropdownMenuItem(
                  value: speed,
                  child: Text(speed.toStringAsFixed(0)),
                ),
            ],
            onChanged: (speed) {
              if (speed != null) _setSpeed(speed);
            },
          ),
        ],
        if (_exercise.previewRequired) ...[
          const SizedBox(height: 12),
          Card(
            key: const ValueKey('comprehension-preview'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                s.comprehensionPreviewMissing(
                  _exercise.missingSymbols.join(' '),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_score == null) ...[
          OutlinedButton.icon(
            key: const ValueKey('comprehension-play'),
            onPressed: _playback == null || _playing || _backgrounded
                ? null
                : _listen,
            icon: Icon(
              _playing
                  ? Icons.volume_up
                  : _started
                  ? Icons.replay
                  : Icons.hearing,
            ),
            label: Text(
              _playing
                  ? s.learnListen
                  : _started
                  ? s.learnReplay
                  : s.comprehensionListen,
            ),
          ),
          if (_playing) const LinearProgressIndicator(),
          if (_audioFailed) ...[
            Text(s.comprehensionAudioFailed),
            TextButton(
              onPressed: () => unawaited(_setup()),
              child: Text(s.actionRetry),
            ),
          ],
          if (_assisted) Text(s.comprehensionAssisted),
          if (_heard) ...[
            const SizedBox(height: 16),
            for (final question in _exercise.questions) ...[
              TextField(
                key: ValueKey('comprehension-answer-${question.field.name}'),
                controller: _answers[question.field],
                enabled: !_playing,
                autocorrect: false,
                maxLength: 800,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  counterText: '',
                  label: FieldLabel(
                    comprehensionFieldLabel(context, question.field),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  if (_exercise.questions.length == 1) _submit();
                },
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              key: const ValueKey('comprehension-submit'),
              onPressed: _playing ? null : _submit,
              child: Text(s.learnSubmit),
            ),
            TextButton(
              key: const ValueKey('comprehension-reveal'),
              onPressed: _playing || _revealed ? null : _reveal,
              child: Text(s.comprehensionReveal),
            ),
          ],
        ] else ...[
          Text(
            s.comprehensionScore(_score!.correct, _score!.total),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _assisted ? s.comprehensionAssisted : s.comprehensionIndependent,
          ),
          const SizedBox(height: 8),
          for (final question in _exercise.questions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _score!.results[question.field]!
                        ? Icons.check_circle
                        : Icons.refresh,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comprehensionFieldLabel(context, question.field),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(question.answer),
                        Text(
                          _score!.results[question.field]!
                              ? s.comprehensionFieldCorrect
                              : s.comprehensionFieldWrong,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_saving) const LinearProgressIndicator(),
          if (_saveFailed) ...[
            Text(s.comprehensionSaveFailed),
            TextButton(
              onPressed: () => unawaited(_record()),
              child: Text(s.actionRetry),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('comprehension-next'),
            onPressed: _saved ? _next : null,
            child: Text(
              widget.planStepId == null && widget.exercise == null
                  ? s.comprehensionNext
                  : s.comprehensionDone,
            ),
          ),
        ],
        if (_revealed || _score != null) ...[
          const SizedBox(height: 12),
          Card(
            key: const ValueKey('comprehension-target'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.comprehensionTarget,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(_exercise.spokenText),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _history(context),
      ],
    );
  }

  Widget _history(BuildContext context) {
    final all = widget.controller.progress.listeningAttempts
        .where((a) => a.mode == _mode)
        .toList();
    final independent = all
        .where((a) => a.independent)
        .toList()
        .reversed
        .take(20)
        .toList();
    final total = independent.fold<int>(0, (sum, a) => sum + a.total);
    final correct = independent.fold<int>(0, (sum, a) => sum + a.correct);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          total == 0
              ? context.s.comprehensionEmptyHistory
              : context.s.comprehensionHistory(
                  independent.length,
                  (100 * correct / total).round(),
                ),
        ),
      ),
    );
  }
}
