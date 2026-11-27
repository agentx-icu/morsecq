part of 'receive_drill_screen.dart';

extension _ReceiveListenView on _ReceiveDrillScreenState {
  Widget _buildListen(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final ready = _playback != null || _audioFailed;
    final step = _planStep;
    final round = _session.roundCount + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          step == null
              ? s.learnRoundOf(round)
              : s.firstLessonTrialRound(
                  round,
                  (_session.charBudget + _planGroupSize - 1) ~/ _planGroupSize,
                ),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (step != null)
          ListTile(
            title: Text(s.learnPlanTitle),
            subtitle: Text(
              [
                PlanLabels.reason(s, step),
                s.learnPlanCopyCounts(_session.charBudget, _planGroupSize),
                s.learnPlanReplayNote,
                if (!_session.countsTowardLesson) s.learnPlanNoUnlock,
              ].join('\n'),
            ),
          ),
        if (_guidedLevel case final level?)
          ListTile(
            key: const ValueKey('guided-round-brief'),
            title: Text(guidedLevelLabel(s, level)),
            subtitle: Text(s.learnGuidedReplayNote),
          ),
        if ((_session.countsTowardLesson ? _session.lesson : null)
            case final lesson?)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              challengeRule(s, widget.controller.course, lesson),
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (_session.conditions case final RadioScenario c)
          ConditionsChip(scenario: c),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                PlaybackStatusRow(
                  playing: _playing,
                  heard: _heard,
                  onReplay: ready && !_playing ? _replay : null,
                  replayLabel: _audioFailed
                      ? s.actionRetry
                      : _heard &&
                            _session.countsTowardLesson &&
                            !_session.isAssisted
                      ? s.learnReplayTurnsToPractice
                      : s.learnReplay,
                ),
                SignalActivity(playing: _playing),
              ],
            ),
          ),
        ),
        if (_audioFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              s.comprehensionAudioFailed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else if (_conditionsBlocked || _conditionsFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _conditionsFailed
                  ? s.conditionsAudioFailed
                  : s.conditionsNeedSound,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          )
        // Haptics only count on phones; elsewhere the flash fallback runs.
        else if (!_ReceiveDrillScreenState._perceivable(
          widget.controller.settings,
        ))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              s.learnNoFeedbackWarning,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (_interrupted && !_playing)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              s.learnRoundInterrupted,
              key: const ValueKey('round-interrupted'),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        if (_session.isAssisted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              s.learnReplayAssistedNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _answer,
          inputFormatters: _codebook == null
              ? null
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
          focusNode: _answerFocus,
          autofocus: hasPhysicalKeyboardByDefault,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: isTouchPlatform ? TextInputType.none : null,
          style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 2),
          decoration: InputDecoration(
            hintText: s.learnAnswerHint,
            // Smaller than the typed answer and wrapping, never clipped.
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        AnswerKeypad(
          chars: _session.chars,
          onChar: _appendChar,
          onBackspace: _backspace,
          onSpace: _codebook == null ? () => _appendChar(' ') : null,
        ),
      ],
    );
  }

  Widget _listenActions(BuildContext context) {
    final s = context.s;
    return LearnFooter(
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _answer,
        builder: (context, answer, _) {
          final empty = answer.text.trim().isEmpty;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_playing)
                Text(
                  s.learnFinishListeningBeforeCheck,
                  textAlign: TextAlign.center,
                ),
              FilledButton(
                onPressed: _canCheck && !empty ? _submit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(s.learnSubmit),
              ),
              if (_canCheck && empty)
                TextButton(
                  onPressed: () => _submit(skip: true),
                  child: Text(s.learnSkipRound),
                ),
            ],
          );
        },
      ),
    );
  }
}
