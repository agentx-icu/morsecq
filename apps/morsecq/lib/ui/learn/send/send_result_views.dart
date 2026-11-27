part of 'send_practice_screen.dart';

extension _SendResultViews on _SendPracticeScreenState {
  Widget _buildResult(BuildContext context) {
    final timeline = _timeline;
    final overview = Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SendResultView(
          diagnostics: _result!,
          showIssues: _guide == null,
        ),
      ),
    );
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return AdaptivePanelBody(
                breakpoint: 900,
                leading: [
                  if (_guide != null)
                    SendGuideResult(stage: _guide!, diagnostics: _result!),
                  if (!wide) overview,
                  if (timeline != null)
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SendTimelineView(
                          timeline: timeline,
                          onPlayMine: (i) => _playback?.player.play(
                            i == null
                                ? timeline.myElements
                                : timeline.myElementsFor(i),
                          ),
                          onPlayStandard: (i) => _playback?.player.play(
                            i == null
                                ? timeline.standardElements
                                : timeline.standardElementsFor(i),
                          ),
                          onPractice: _practisePart,
                        ),
                      ),
                    ),
                ],
                trailing: [if (wide) overview],
              );
            },
          ),
        ),
        LearnFooter(child: _resultActions(context)),
      ],
    );
  }

  Widget _resultActions(BuildContext context) {
    final s = context.s;
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(_result),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(s.learnDone),
          ),
        ),
        const SizedBox(width: 12),
        if (widget.maxAttempts == null || _attempts < widget.maxAttempts!)
          Expanded(
            child: FilledButton(
              onPressed: _another,
              autofocus: true,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _guide != null && _result!.score.strictAccuracy != 1
                    ? s.sendGuideRetry
                    : s.learnTryAnother,
              ),
            ),
          ),
      ],
    );
  }
}
