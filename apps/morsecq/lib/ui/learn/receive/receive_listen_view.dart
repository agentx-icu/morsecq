part of 'receive_drill_screen.dart';

extension _ReceiveListenView on _ReceiveDrillScreenState {
  Widget _buildListen(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final ready = _playback != null || _audioFailed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          s.learnRoundOf(_session.roundCount + 1),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (_session.conditions case final RadioScenario c)
          ConditionsChip(scenario: c),
        const SizedBox(height: 8),
        PlaybackStatusRow(
          playing: _playing,
          onReplay: ready && !_playing ? _replay : null,
          replayLabel: _audioFailed ? s.actionRetry : s.learnReplay,
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
          onSpace: () => _appendChar(' '),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed:
              !_audioFailed &&
                  !_conditionsBlocked &&
                  !_conditionsFailed &&
                  _playback != null &&
                  !_backgrounded
              ? _submit
              : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(s.learnSubmit),
        ),
      ],
    );
  }
}
