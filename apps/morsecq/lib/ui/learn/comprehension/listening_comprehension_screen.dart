import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../../../training/training_settings.dart';
import '../drill_session_guard.dart';
import '../learn_playback.dart';
import 'comprehension_labels.dart';

part 'comprehension_views.dart';

/// Original offline head-copy material; its evidence never updates Koch/SRS.
class ListeningComprehensionScreen extends StatefulWidget {
  const ListeningComprehensionScreen({
    super.key,
    required this.controller,
    required this.playback,
    this.initialMode,
    this.planStepId,
    this.practiceTiming,
    this.exercise,
    this.retryEntryId,
    this.screenWake = const WakelockScreenWake(),
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;
  final ListeningMode? initialMode;
  final String? planStepId;
  final MorseTiming? practiceTiming;
  final ListeningExercise? exercise;
  final String? retryEntryId;
  final ScreenWakeApi screenWake;

  @override
  State<ListeningComprehensionScreen> createState() =>
      _ListeningComprehensionScreenState();
}

class _ListeningComprehensionScreenState
    extends State<ListeningComprehensionScreen>
    with WidgetsBindingObserver {
  late ListeningMode _mode;
  late TrainingSettings _settings;
  late ListeningExercise _exercise;
  late String _id;
  final Map<ListeningField, TextEditingController> _answers = {};
  late final DrillScreenWake _wake = DrillScreenWake(widget.screenWake);
  LearnPlayback? _playback;
  MorsePlayer? _player;
  StreamSubscription<PlayerEvent>? _subscription;
  Future<void> _closingPlayback = Future<void>.value();
  ListeningScore? _score;
  ListeningAttempt? _attempt;
  bool _playing = false;
  bool _heard = false;
  bool _started = false;
  bool _replayed = false;
  bool _revealed = false;
  bool _backgrounded = false;
  bool _saving = false;
  bool _saved = false;
  bool _saveFailed = false;
  bool _audioFailed = false;

  double get _effective => _settings.trainer.isFarnsworth
      ? _settings.trainer.farnsworthWpm!
      : _settings.trainer.characterWpm;
  bool get _assisted => _replayed || _revealed || _exercise.previewRequired;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mode = widget.exercise?.mode ?? widget.initialMode ?? ListeningMode.words;
    var trainer = widget.controller.trainerSettings;
    final plan = widget.controller.progress.dailyPlan;
    final step = widget.planStepId == null
        ? null
        : plan?.stepById(widget.planStepId!);
    if (plan != null && step != null) {
      final frozen = plan.settingsOf(step);
      trainer = trainer.copyWith(
        characterWpm: frozen.characterWpm,
        farnsworthWpm: frozen.effectiveWpm,
        toneHz: frozen.toneHz,
      );
    } else if (widget.practiceTiming case final timing?) {
      trainer = trainer.copyWith(
        characterWpm: timing.wpm,
        farnsworthWpm: timing.farnsworthWpm,
        clearFarnsworth: timing.farnsworthWpm == null,
      );
    }
    // A sound-based assessment cannot silently fall back to visual keying.
    _settings = widget.controller.settings.copyWith(
      trainer: trainer,
      soundEnabled: true,
      flashEnabled: false,
      hapticEnabled: false,
    );
    _newExercise(step?.seed ?? widget.controller.random.nextInt(1 << 30));
    unawaited(_setup());
  }

  Future<void> _setup() async {
    setState(() => _audioFailed = false);
    try {
      await _closingPlayback;
      if (!mounted) return;
      final playback = await widget.playback.create(_settings);
      if (!mounted) {
        await playback.dispose();
        return;
      }
      if (widget.playback is DevicePlaybackFactory &&
          playback.sidetone == null) {
        await playback.dispose();
        setState(() => _audioFailed = true);
        return;
      }
      final player = playback.createAssessmentPlayer(requireSound: true);
      _subscription = player.events.listen(_onPlayerEvent);
      setState(() {
        _playback = playback;
        _player = player;
      });
    } on Object {
      if (mounted) setState(() => _audioFailed = true);
    }
  }

  void _newExercise(int seed) {
    for (final answer in _answers.values) {
      answer.dispose();
    }
    _answers.clear();
    _exercise =
        widget.exercise?.forAlphabet(widget.controller.learnedChars) ??
        ListeningExercise.generate(
          mode: _mode,
          seed: seed,
          allowedChars: widget.controller.learnedChars,
        );
    for (final question in _exercise.questions) {
      _answers[question.field] = TextEditingController();
    }
    _id = ExerciseIds.next(widget.controller.now(), widget.controller.random);
    _score = null;
    _attempt = null;
    _playing = false;
    _heard = false;
    _started = false;
    _replayed = false;
    _revealed = false;
    _saving = false;
    _saved = false;
    _saveFailed = false;
  }

  void _onPlayerEvent(PlayerEvent event) {
    if (!mounted) return;
    if (event is PlayerStopped && event.error != null) {
      _failPlayback();
      return;
    }
    if (event is PlayerCompleted || event is PlayerStopped) {
      _wake.setActive(false);
      setState(() {
        _playing = false;
        if (event is PlayerCompleted) _heard = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _wake.onLifecycle(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _backgrounded = true;
      _player?.stop();
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _backgrounded = false);
    }
  }

  void _listen() {
    if (_playback == null || _playing || _backgrounded || _score != null) {
      return;
    }
    setState(() {
      if (_started) _replayed = true;
      _started = true;
      _playing = true;
    });
    _wake.setActive(true);
    try {
      _player!.play(
        MorseEncoder.encode(_exercise.spokenText, _settings.trainer.toTiming()),
      );
    } on Object {
      // The player reports mark/release errors, including timer callbacks;
      // this catches other startup failures such as a removed clock/device.
      _failPlayback();
    }
  }

  void _failPlayback() {
    final playback = _playback;
    final player = _player;
    if (playback == null || player == null) return;
    final subscription = _subscription;
    _subscription = null;
    _wake.setActive(false);
    setState(() {
      _playback = null;
      _player = null;
      _playing = false;
      _heard = false;
      _revealed = false;
      _audioFailed = true;
    });
    player.stop();
    _closingPlayback = _closeFailedPlayback(playback, player, subscription);
  }

  Future<void> _closeFailedPlayback(
    LearnPlayback playback,
    MorsePlayer player,
    StreamSubscription<PlayerEvent>? subscription,
  ) async {
    await subscription?.cancel();
    try {
      try {
        await player.dispose();
      } finally {
        await playback.dispose();
      }
    } on Object {
      // A removed output may also reject cleanup. The visible error remains
      // and the player already canceled its failed timeline before disposal.
    }
  }

  void _reveal() {
    if (!_heard || _playing || _score != null) return;
    setState(() => _revealed = true);
  }

  void _submit() {
    if (!_heard || _playing || _score != null) return;
    final score = _exercise.score({
      for (final e in _answers.entries) e.key: e.value.text,
    });
    setState(() {
      _score = score;
      _attempt = score.attempt(
        id: _id,
        at: widget.controller.now(),
        characterWpm: _settings.trainer.characterWpm,
        effectiveWpm: _effective,
        replayed: _replayed,
        revealed: _revealed,
        planStepId: widget.planStepId,
        exercise: _exercise,
        answers: {for (final e in _answers.entries) e.key: e.value.text},
        retryEntryId: widget.retryEntryId,
      );
    });
    unawaited(_record());
  }

  Future<void> _record() async {
    if (_attempt == null || _saving || _saved) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await widget.controller.recordListeningAttempt(_attempt!);
      if (mounted) setState(() => _saved = true);
    } on Object {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _switchMode(ListeningMode mode) {
    if (_started || widget.planStepId != null || widget.exercise != null) {
      return;
    }
    setState(() {
      _mode = mode;
      _newExercise(widget.controller.random.nextInt(1 << 30));
    });
  }

  void _setSpeed(double effective) {
    if (_started ||
        widget.planStepId != null ||
        widget.practiceTiming != null ||
        widget.exercise != null) {
      return;
    }
    setState(() {
      _settings = _settings.copyWith(
        trainer: _settings.trainer.copyWith(
          characterWpm: max(_settings.trainer.characterWpm, effective),
          farnsworthWpm: effective,
        ),
      );
    });
  }

  void _next() {
    if (!_saved) return;
    if (widget.planStepId != null || widget.exercise != null) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _newExercise(widget.controller.random.nextInt(1 << 30)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wake.dispose();
    unawaited(_subscription?.cancel());
    unawaited(_player?.dispose());
    unawaited(_playback?.dispose());
    for (final answer in _answers.values) {
      answer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DrillLeaveGuard(
    guard: _started && !_saved,
    child: Scaffold(
      appBar: AppBar(title: Text(context.s.comprehensionTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: _content(context),
            ),
          ),
        ),
      ),
    ),
  );
}
