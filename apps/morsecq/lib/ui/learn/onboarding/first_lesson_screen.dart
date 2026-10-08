import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/receive_session.dart';
import '../../../training/training_controller.dart';
import '../../../training/training_plan.dart';
import '../drill_session_guard.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import '../progress_save_snack.dart';
import '../receive/receive_drill_screen.dart';
import '../send/send_practice_screen.dart';
import 'first_lesson_steps.dart';
import 'first_lesson_trial_view.dart';

enum _Step { hear, sounds, worked, trials, next }

/// The guided first lesson (pedagogy review, stage 0): can you hear it,
/// short and long, a worked answer, K-or-M trials, and what to do next.
/// About three minutes, nothing graded, replayable; the trials are a real
/// practice session so the daily plan's intro step completes through it.
class FirstLessonScreen extends StatefulWidget {
  const FirstLessonScreen({
    super.key,
    required this.controller,
    required this.playback,
    this.trialSession,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;

  /// The trials session; defaults to `controller.startOnboardingSession()`
  /// (which binds today's pending intro plan step, if any).
  final ReceiveSession? trialSession;

  static const int stepCount = 5;

  /// Effective speed of the beginner pace offered during the trials.
  static const double beginnerEffectiveWpm = 6;

  @override
  State<FirstLessonScreen> createState() => _FirstLessonScreenState();
}

class _FirstLessonScreenState extends State<FirstLessonScreen>
    with WidgetsBindingObserver {
  _Step _step = _Step.hear;
  LearnPlayback? _playback;
  StreamSubscription<PlayerEvent>? _sub;
  int _generation = 0;
  String? _playingId;
  bool _heardNothing = false;
  final Set<String> _revealed = <String>{};
  late final ReceiveSession _trials;
  ReceiveRound? _lastRound;
  int _correct = 0;
  bool _recording = false;
  bool _changingPace = false;
  ReceiveOutcome? _outcome;

  TrainingController get _c => widget.controller;
  List<String> get _pair => _c.course.charsForLesson(_c.course.firstLesson);

  @override
  void initState() {
    super.initState();
    _trials = widget.trialSession ?? _c.startOnboardingSession();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_createPlayback());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isDrillBackground(state)) {
      _playback?.player.stop();
      _trials.pause();
    } else if (state == AppLifecycleState.resumed) {
      _trials.resume();
    }
  }

  /// Builds (or rebuilds, after a modality change) the playback bundle from
  /// the current settings: the bundle is a settings snapshot.
  Future<void> _createPlayback() async {
    final generation = ++_generation;
    final old = _playback;
    _playback = null;
    unawaited(_sub?.cancel());
    _sub = null;
    if (old != null) {
      old.player.stop();
      await old.dispose();
    }
    final created = await widget.playback.create(_c.settings);
    if (!mounted || generation != _generation) {
      await created.dispose();
      return;
    }
    _sub = created.player.events.listen((event) {
      if ((event is PlayerCompleted || event is PlayerStopped) && mounted) {
        setState(() {
          if (event is PlayerCompleted && _playingId != null) {
            _revealed.add(_playingId!);
          }
          _playingId = null;
        });
      }
    });
    setState(() => _playback = created);
  }

  MorseTiming get _timing => _step == _Step.trials || _step == _Step.next
      ? _trials.timing
      : _c.trainerSettings.toTiming();

  void _play(String id, List<MorseElement> elements) {
    final p = _playback;
    if (p == null) return;
    p.player.stop();
    setState(() => _playingId = id);
    p.player.play(elements);
  }

  void _playText(String text) =>
      _play(text, MorseEncoder.encode(text, _timing));

  void _playElement(MorseElementKind kind) => _play(kind.name, <MorseElement>[
    MorseElement(
      kind,
      kind == MorseElementKind.dah ? _timing.dah : _timing.dit,
    ),
  ]);

  Future<void> _setModality({bool? flash, bool? haptic}) async {
    final next = _c.settings.copyWith(
      flashEnabled: flash,
      hapticEnabled: haptic,
    );
    try {
      await _c.updateSettings(next);
    } on Object {
      // The in-memory setting applies; the save is retried later.
    }
    if (mounted) await _createPlayback();
  }

  Future<void> _setBeginnerPace(bool on) async {
    if (_trials.roundCount > 0 || _changingPace) return;
    setState(() => _changingPace = true);
    _playback?.player.stop();
    final t = _c.trainerSettings;
    final next = on
        ? t.copyWith(farnsworthWpm: FirstLessonScreen.beginnerEffectiveWpm)
        : t.copyWith(farnsworthWpm: TrainerSettings.defaults.farnsworthWpm);
    try {
      await _c.updateSettings(_c.settings.copyWith(trainer: next));
      // Pending work follows the learner's chosen pace; already started
      // steps retain their snapshot. The intro explicitly offers this change.
      await _c.refreshPlan();
    } on Object {
      // updateSettings rolls back failed writes. Use the actual setting,
      // rather than the requested value, for this attempt and its playback.
    }
    _trials.setTimingBeforeAnswer(_c.trainerSettings.toTiming());
    if (mounted) {
      setState(() => _changingPace = false);
      if (_step == _Step.trials) _playTrial();
    }
  }

  bool get _beginnerPace =>
      (_trials.timing.farnsworthWpm ?? _trials.timing.wpm) <=
      FirstLessonScreen.beginnerEffectiveWpm;

  void _goTo(_Step step) {
    _playback?.player.stop();
    setState(() {
      _step = step;
      _playingId = null;
    });
    if (step == _Step.trials && _lastRound == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _trials.roundCount == 0) _playTrial();
      });
    }
  }

  void _playTrial() => _playText(_trials.currentDrill.text);

  /// Replaying is encouraged here; the session records it honestly.
  void _replayTrial() {
    _trials.markReplay();
    _playTrial();
  }

  void _answer(String answer) {
    if (_trials.isFinished || _lastRound != null || _changingPace) return;
    _playback?.player.stop();
    final round = _trials.submit(answer);
    setState(() {
      _lastRound = round;
      if (round.score.isPerfect) _correct++;
    });
  }

  Future<void> _nextTrial() async {
    if (_trials.isComplete) {
      await _finishTrials();
      return;
    }
    setState(() => _lastRound = null);
    _playTrial();
  }

  Future<void> _finishTrials() async {
    if (_recording) return;
    setState(() => _recording = true);
    final outcome = await _c.recordReceiveSession(_trials);
    try {
      await _c.markFirstLessonDone();
    } on Object {
      // Retried with the next successful save.
    }
    if (!mounted) return;
    setState(() {
      _outcome = outcome;
      _recording = false;
      _step = _Step.next;
    });
    if (!outcome.saved) showProgressSaveFailed(context, _c);
  }

  Future<void> _replaceWith(Widget screen) => Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute<Object?>(builder: (_) => screen));

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_sub?.cancel());
    unawaited(_playback?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final flash = _playback?.flash;
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: switch (_step) {
              _Step.hear => _buildHear(s),
              _Step.sounds => _buildSounds(s),
              _Step.worked => _buildWorked(s),
              _Step.trials => _buildTrials(s),
              _Step.next => _buildNext(s),
            },
          ),
        ),
      ),
    );
    return DrillLeaveGuard(
      guard: _trials.roundCount > 0 && _outcome == null && !_recording,
      child: Scaffold(
        appBar: AppBar(title: Text(s.firstLessonTitle)),
        body: flash == null ? body : FlashOverlay(isOn: flash, child: body),
      ),
    );
  }

  Widget _continue(S s, _Step next, {String? label}) => FilledButton(
    key: ValueKey<String>('first-lesson-continue-${next.name}'),
    onPressed: () => _goTo(next),
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    child: Text(label ?? s.firstLessonContinue),
  );

  Widget _buildHear(S s) {
    final probe = _pair.first;
    return FirstLessonStep(
      index: 1,
      total: FirstLessonScreen.stepCount,
      title: s.firstLessonHearTitle,
      body: s.firstLessonHearBody,
      children: <Widget>[
        FilledButton.tonalIcon(
          key: const ValueKey('first-lesson-play'),
          onPressed: _playback == null ? null : () => _playText(probe),
          icon: Icon(_playingId == probe ? Icons.volume_up : Icons.play_arrow),
          label: Text(
            _heardNothing ? s.firstLessonPlayAgain : s.firstLessonPlay,
          ),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        ),
        const SizedBox(height: 16),
        if (_heardNothing) ...<Widget>[
          NoSoundCard(
            flash: _c.settings.flashEnabled,
            haptic: _c.settings.hapticEnabled,
            showHaptic: isTouchPlatform,
            onFlash: (v) => unawaited(_setModality(flash: v)),
            onHaptic: (v) => unawaited(_setModality(haptic: v)),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('first-lesson-not-heard'),
                onPressed: () => setState(() => _heardNothing = true),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(s.firstLessonNotHeard),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const ValueKey('first-lesson-heard'),
                onPressed: () => _goTo(_Step.sounds),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(s.firstLessonHeard),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
      const SizedBox(height: 16),
      _continue(s, _Step.worked),
    ],
  );

  Widget _buildWorked(S s) => FirstLessonStep(
    index: 3,
    total: FirstLessonScreen.stepCount,
    title: s.firstLessonWorkedTitle,
    body: s.firstLessonWorkedBody,
    children: <Widget>[
      for (final c in _pair) ...<Widget>[
        FilledButton.tonalIcon(
          key: ValueKey<String>('worked-$c'),
          onPressed: _playback == null ? null : () => _playText(c),
          icon: Icon(_playingId == c ? Icons.volume_up : Icons.play_arrow),
          label: Text(s.firstLessonPlay),
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
      _continue(s, _Step.trials),
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
    onCompare: _playText,
    onNext: () => unawaited(_nextTrial()),
    onPace: (v) => unawaited(_setBeginnerPace(v)),
  );

  Widget _buildNext(S s) => FirstLessonNextPanel(
    correct: _correct,
    total: _trials.charBudget,
    // Describes exactly what the button starts: the current lesson's
    // challenge at the configured length.
    lesson: _c.currentLesson,
    challengeChars: _c.trainerSettings.sessionLengthChars,
    nextChar: _c.course.isLastLesson(_c.currentLesson)
        ? null
        : _c.course.newCharForLesson(_c.currentLesson + 1),
    onCompare: () => _playText('K M'),
    onGuided: () => _replaceWith(
      ReceiveDrillScreen(
        controller: _c,
        playback: widget.playback,
        session: _c.startGuidedSession(),
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
