part of 'first_lesson_screen.dart';

extension _FirstLessonViews on _FirstLessonScreenState {
  Widget _buildHear(S s) => FirstLessonStep(
    index: 1,
    total: FirstLessonScreen.stepCount,
    title: s.firstLessonHearTitle,
    body: s.firstLessonHearBody,
    children: [
      Card(
        key: const ValueKey('first-lesson-signal'),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              Icon(
                _playingId == null
                    ? Icons.volume_down_outlined
                    : Icons.volume_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(child: SignalActivity(playing: _playingId != null)),
            ],
          ),
        ),
      ),
      if (_heardNothing)
        NoSoundCard(
          flash: _c.settings.flashEnabled,
          haptic: _c.settings.hapticEnabled,
          showHaptic: isTouchPlatform,
          onFlash: (v) => unawaited(_setModality(flash: v)),
          onHaptic: (v) => unawaited(_setModality(haptic: v)),
        ),
    ],
  );

  Widget _buildSounds(S s) => FirstLessonStep(
    index: 2,
    total: FirstLessonScreen.stepCount,
    title: s.firstLessonSoundsTitle,
    body: s.firstLessonSoundsBody,
    children: <Widget>[
      SoundTile(
        label: s.firstLessonDit,
        pattern: '.',
        playing: _playingId == MorseElementKind.dit.name,
        onPlay: () => _playElement(MorseElementKind.dit),
      ),
      SoundTile(
        label: s.firstLessonDah,
        pattern: '-',
        playing: _playingId == MorseElementKind.dah.name,
        onPlay: () => _playElement(MorseElementKind.dah),
      ),
      for (final c in _pair)
        SoundTile(
          label: c,
          pattern: MorseEncoder.toPattern(c),
          playing: _playingId == c,
          onPlay: () => _playText(c),
        ),
      // Both symbols as one group: the silence between them is the
      // character gap of the current timing.
      SoundTile(
        key: const ValueKey('sound-pause'),
        label: s.firstLessonPauseDemo(_pair.first, _pair.last),
        pattern: _pair.map(MorseEncoder.toPattern).join('   '),
        playing: _playingId == _pair.join(),
        onPlay: () => _playText(_pair.join()),
      ),
    ],
  );

  Widget _buildWorked(S s) => FirstLessonStep(
    index: 3,
    total: FirstLessonScreen.stepCount,
    title: s.firstLessonWorkedTitle,
    body: s.firstLessonWorkedBody,
    children: <Widget>[
      for (final (i, c) in _pair.indexed) ...<Widget>[
        FilledButton.tonalIcon(
          key: ValueKey<String>('worked-$c'),
          onPressed: _playback == null ? null : () => _playText(c),
          icon: Icon(_playingId == c ? Icons.volume_up : Icons.play_arrow),
          // Numbered, not named: the symbol is the answer revealed after.
          label: Text(s.firstLessonWorkedPlay(i + 1)),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
        const SizedBox(height: 6),
        Text(
          _revealed.contains(c) && _playingId != c
              ? s.firstLessonWorkedReveal(c)
              : '',
          key: ValueKey<String>('worked-reveal-$c'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    ],
  );

  Widget _buildTrials(S s) => FirstLessonTrialView(
    session: _trials,
    round: _lastRound,
    choices: _pair,
    ready: _playback != null && !_changingPace,
    recording: _recording,
    beginnerPace: _beginnerPace,
    onAnswer: _answer,
    onReplay: _replayTrial,
    onSlowReplay: () => _replayTrial(slow: true),
    onCompare: _playText,
    onNext: () => unawaited(_nextTrial()),
    onPace: (v) => unawaited(_setBeginnerPace(v)),
  );

  Widget _buildNext(S s) => FirstLessonNextPanel(
    correct: _correct,
    total: _trials.charBudget,
    lesson: _c.currentLesson,
    challengeRequirements: challengeRule(s, _c.course, _c.currentLesson),
    onCompare: () => _playText('K M'),
    onGuided: () => _replaceWith(
      ReceiveDrillScreen(
        controller: _c,
        playback: widget.playback,
        session: _c.startFirstLessonPractice(),
      ),
    ),
    onChallenge: () => _replaceWith(
      ReceiveDrillScreen(
        controller: _c,
        playback: widget.playback,
        session: _c.startLessonSession(),
      ),
    ),
    onSend: () => _replaceWith(
      SendPracticeScreen(controller: _c, playback: widget.playback),
    ),
    onDone: () => Navigator.of(context).pop(_outcome),
  );
}
