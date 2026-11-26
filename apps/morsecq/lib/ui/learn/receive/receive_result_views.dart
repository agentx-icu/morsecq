part of 'receive_drill_screen.dart';

extension _ReceiveResultViews on _ReceiveDrillScreenState {
  Widget _buildResult(BuildContext context) {
    final round = _lastRound!;
    final isLast = _session.isComplete;
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RoundResultView(
          round: round,
          kind: _session.kind,
          onReplaySymbol: (symbol) {
            if (_backgrounded) return;
            _playback?.player.play(
              MorseEncoder.encode(symbol, _session.timing),
            );
          },
        ),
        if (_session.conditions != null)
          CleanReferenceButton(onPressed: () => _playCleanReference(round)),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _next,
          autofocus: true,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(isLast ? s.learnFinish : s.learnNext),
        ),
      ],
    );
  }

  Widget _summaryActions(BuildContext context) {
    final s = context.s;
    final outcome = _outcome!;
    final guided = _session.sourceRef?.startsWith('guided/') ?? false;
    final offerGuided =
        guided ||
        (outcome.credit.receiveStats &&
            _session.sourceRef == null &&
            !_session.countsTowardLesson &&
            _session.kind != ReceiveDrillKind.review &&
            _session.conditions == null);
    final nextLevel = widget.controller.recommendedGuidedLevel;
    final retryGuided =
        _session.sourceRef ==
        'guided/${widget.controller.currentLesson}/${nextLevel.name}';
    final guidedAction = retryGuided
        ? s.learnGuidedRetry
        : s.learnGuidedContinue;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            if (offerGuided)
              FilledButton.icon(
                key: const ValueKey('guided-next'),
                icon: const Icon(Icons.hearing),
                label: Text(
                  guided
                      ? '$guidedAction: ${guidedLevelLabel(s, nextLevel)}'
                      : s.learnBeginGuided(guidedLevelLabel(s, nextLevel)),
                ),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<Object?>(
                    builder: (_) => ReceiveDrillScreen(
                      controller: widget.controller,
                      playback: widget.playback,
                      session: widget.controller.startGuidedSession(),
                    ),
                  ),
                ),
              ),
            FilledButton.tonal(
              key: const ValueKey('receive-done'),
              autofocus: !offerGuided,
              onPressed: () => Navigator.of(context).pop(outcome),
              child: Text(s.learnDone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final outcome = _outcome;
    if (outcome == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!outcome.saved)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(
                    context.s.learnProgressSaveFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('receive-save-retry'),
                    onPressed: _retryingSave ? null : _retrySaving,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.s.actionRetry),
                  ),
                ],
              ),
            ),
          ),
        ReceiveSummaryView(
          session: _session,
          outcome: outcome,
          course: widget.controller.course,
          unlockedChar: _unlockedChar,
        ),
        if (_session.conditions case final RadioScenario c)
          ConditionsSummary(
            scenario: c,
            history: widget.controller.progress.history,
          ),
        const SizedBox(height: 24),
        if (outcome.saved)
          ReceiveNextSteps(
            controller: widget.controller,
            playbackFactory: widget.playback,
            playback: _playback,
            session: _session,
            outcome: outcome,
            showCompletionActions: false,
          ),
      ],
    );
  }
}
