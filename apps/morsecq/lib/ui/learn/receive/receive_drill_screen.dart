import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../../common/app_bar_title.dart';
import '../../responsive.dart';
import '../../telegraph/telegraph_labels.dart';
import '../learn_footer.dart';
import '../conditions/conditions_playback.dart';
import '../conditions/conditions_widgets.dart';
import '../drill_session_guard.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import '../plan/plan_labels.dart';
import '../signal_activity.dart';
import 'answer_keypad.dart';
import 'guided_practice_sheet.dart';
import 'receive_next_steps.dart';
import 'receive_summary_view.dart';
import 'receive_widgets.dart';
import 'round_result_view.dart';

part 'receive_listen_view.dart';

part 'receive_result_views.dart';

enum _Phase { listen, result, summary }

/// Plays each round of a [ReceiveSession], collects the copy (text field on
/// desktop, restricted keypad everywhere), scores it, and on completion
/// records the session through the controller.
///
/// Leaving after the first answered round asks first (the rounds are only
/// saved on finish), and the screen is kept on ([screenWake]) until the
/// summary so a phone's auto-lock cannot background the app mid-drill.
class ReceiveDrillScreen extends StatefulWidget {
  const ReceiveDrillScreen({
    super.key,
    required this.controller,
    required this.playback,
    required this.session,
    this.title,
    this.screenWake = const WakelockScreenWake(),
    this.conditionsPlayback,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;
  final ReceiveSession session;
  final String? title;
  final ScreenWakeApi screenWake;

  /// Player for a session under radio conditions (F11); one is created when
  /// the session has conditions and none is given. Owned by the screen.
  final ConditionsPlayback? conditionsPlayback;

  @override
  State<ReceiveDrillScreen> createState() => _ReceiveDrillScreenState();
}

class _ReceiveDrillScreenState extends State<ReceiveDrillScreen>
    with WidgetsBindingObserver {
  final TextEditingController _answer = TextEditingController();
  final FocusNode _answerFocus = FocusNode();
  LearnPlayback? _playback;
  StreamSubscription<PlayerEvent>? _playerSub;
  _Phase _phase = _Phase.listen;
  bool _playing = false;
  bool _recording = false;
  bool _retryingSave = false;
  ReceiveRound? _lastRound;
  ReceiveOutcome? _outcome;
  String? _unlockedChar;
  late final DrillScreenWake _wake = DrillScreenWake(widget.screenWake);

  /// Radio-condition audio (F11), only for a session that has conditions.
  late final ConditionsPlayback? _conditions = _session.conditions == null
      ? null
      : widget.conditionsPlayback ?? ConditionsPlayback();
  StreamSubscription<bool>? _conditionsSub;
  StreamSubscription<void>? _conditionsInterruptionSub;
  int _conditionsRun = 0;

  /// Set right before we stop the conditions audio ourselves, so that stop
  /// does not count as having heard the round.
  bool _stopping = false;

  ReceiveSession get _session => widget.session;

  late final PlanStep? _planStep = _session.planStepId == null
      ? null
      : widget.controller.todayPlan?.stepById(_session.planStepId!);
  late final int _planGroupSize = _session.currentDrill.charCount;

  GuidedLevel? get _guidedLevel {
    final parts = _session.sourceRef?.split('/');
    if (parts == null || parts.length != 3 || parts.first != 'guided') {
      return null;
    }
    return GuidedLevel.values
        .where((level) => level.name == parts.last)
        .firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _conditionsInterruptionSub = _conditions?.interruptions.listen((_) {
      if (_phase == _Phase.listen && _playing) _stopConditions();
    });
    _wake.setActive(true);
    unawaited(_setup());
  }

  /// Set while the app is in the background on a phone: the sidetone is
  /// silenced there, so playback must not run (or start) unheard. The round
  /// is replayed with the Replay button on return.
  bool _backgrounded = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _wake.onLifecycle(state);
    final backgrounded = isDrillBackground(state);
    if (_backgrounded != backgrounded && mounted) {
      setState(() {
        _backgrounded = backgrounded;
        // Leaving cut the round off before it was heard to the end: the
        // next replay restores what was lost and is not assistance. A round
        // already heard stays heard, so replaying it is still assistance.
        if (backgrounded && _phase == _Phase.listen && !_heard) {
          _interrupted = true;
        }
      });
    }
    if (_backgrounded) {
      _playback?.player.stop();
      _stopConditions();
      _session.pause();
    } else if (state == AppLifecycleState.resumed) {
      _session.resume();
    }
  }

  /// Answered rounds that leaving now would throw away.
  bool get _hasUnsavedRounds =>
      _session.roundCount > 0 && !_recording && _phase != _Phase.summary;

  Future<void> _setup() async {
    if (_settingUp) return;
    _settingUp = true;
    try {
      final playback = await widget.playback.create(widget.controller.settings);
      if (!mounted) {
        await playback.dispose();
        return;
      }
      _playerSub = playback.player.events.listen(_onPlayerEvent);
      _conditionsSub = _conditions?.playing.listen(_onConditionsPlaying);
      setState(() => _playback = playback);
      _play();
    } on Object {
      if (mounted) setState(() => _audioFailed = true);
    } finally {
      _settingUp = false;
    }
  }

  /// The current round was heard to the end once. A replay of an
  /// interrupted round (background, stop) is not assistance.
  bool _heard = false;

  /// The app went to the background before this round was heard to the
  /// end; cleared by the replay that restores it or by answering.
  bool _interrupted = false;
  bool _audioFailed = false;
  bool _settingUp = false;

  void _onPlayerEvent(PlayerEvent event) {
    if (_phase != _Phase.listen) return;
    if (event is PlayerCompleted) _heard = true;
    if (event is PlayerStopped && event.error != null) {
      _heard = false;
      if (mounted) setState(() => _audioFailed = true);
    }
    if (event is PlayerCompleted || event is PlayerStopped) {
      if (mounted && _playing) {
        setState(() => _playing = false);
      }
    }
  }

  void _onConditionsPlaying(bool playing) {
    if (!playing && !_stopping) _heard = true;
    _stopping = false;
    if (mounted && _playing != playing) setState(() => _playing = playing);
  }

  /// Always stops: a clip still rendering or loading is not "playing" yet
  /// but must not start once the round is over or the app is hidden.
  void _stopConditions() {
    final c = _conditions;
    if (c == null) return;
    // Set even when nothing plays yet: a clip in its loading window still
    // emits start and stop, and that stop is ours, not "heard". The next
    // round's start event clears the flag.
    _stopping = true;
    unawaited(c.stop());
  }

  /// The audio engine could not play the rendering: the round says so
  /// instead of "listening" forever.
  bool _conditionsFailed = false;

  /// Radio conditions are an audio effect: without sound there is nothing
  /// realistic to hear, and an unaffected flash would give the copy away.
  bool get _conditionsBlocked =>
      _conditions != null && !widget.controller.settings.soundEnabled;

  void _play() {
    final playback = _playback;
    if (playback == null || _phase != _Phase.listen || _backgrounded) {
      return;
    }
    final conditions = _conditions;
    if (conditions != null) {
      if (_conditionsBlocked) return;
      final run = ++_conditionsRun;
      setState(() {
        _playing = true;
        _conditionsFailed = false;
      });
      conditions
          .play(_session.currentDrill.text, _session.currentConditions!)
          .then((started) {
            // Rendering or loading was cancelled before a clip started.
            if (!started && mounted && run == _conditionsRun) {
              setState(() => _playing = false);
            }
          })
          .catchError((Object _) {
            if (mounted && run == _conditionsRun) {
              setState(() {
                _playing = false;
                _conditionsFailed = true;
              });
            }
          });
      return;
    }
    setState(() {
      _playing = true;
      _audioFailed = false;
    });
    playback.player.play(_session.currentTimeline);
  }

  /// After answering: the same round without any effect, as a reference.
  /// The answer is already in, so this is not assistance.
  void _playCleanReference(ReceiveRound round) {
    _playback?.player.play(
      MorseEncoder.encode(round.drill.text, _session.timing),
    );
  }

  /// Playing the round again is assistance (functional spec §3.3): the
  /// session still counts as practice but no longer unlocks or feeds SRS.
  void _replay() {
    if (_heard) _session.markReplay();
    if (_interrupted) setState(() => _interrupted = false);
    if (_playback == null) {
      unawaited(_setup());
    } else {
      _play();
    }
  }

  bool get _canCheck =>
      _phase == _Phase.listen &&
      !_session.isFinished &&
      _heard &&
      !_playing &&
      !_audioFailed &&
      !_conditionsBlocked &&
      !_conditionsFailed &&
      _playback != null &&
      !_backgrounded;

  void _submit({bool skip = false}) {
    if (!_canCheck || (skip != _answer.text.trim().isEmpty)) return;
    _playback?.player.stop();
    _stopConditions();
    final round = _session.submit(_answer.text);
    _heard = false;
    _interrupted = false;
    _answer.clear();
    setState(() {
      _lastRound = round;
      _phase = _Phase.result;
    });
  }

  Future<void> _next() async {
    _playback?.player.stop();
    if (_session.isComplete) {
      await _finish();
      return;
    }
    setState(() {
      _heard = false;
      _phase = _Phase.listen;
    });
    _play();
    if (hasPhysicalKeyboardByDefault) {
      _answerFocus.requestFocus();
    }
  }

  Future<void> _finish() async {
    if (_recording) {
      return;
    }
    _recording = true;
    setState(() {});
    final outcome = await widget.controller.recordReceiveSession(_session);
    if (!mounted) {
      return;
    }
    _wake.setActive(false);
    setState(() {
      _outcome = outcome;
      _unlockedChar = outcome.advanced ? widget.controller.newestChar : null;
      _phase = _Phase.summary;
    });
  }

  Future<void> _retrySaving() async {
    if (_retryingSave) return;
    setState(() => _retryingSave = true);
    final saved = await widget.controller.retryProgressSave();
    if (!mounted) return;
    setState(() {
      _retryingSave = false;
      if (saved) _outcome = _outcome?.withSaved(true);
    });
  }

  static bool _perceivable(TrainingSettings settings) =>
      settings.soundEnabled ||
      settings.flashEnabled ||
      (settings.hapticEnabled && isTouchPlatform);

  TelegraphCodebook? get _codebook =>
      TelegraphCurriculum.codebookOf(_session.sourceRef);

  void _appendChar(String c) {
    if (_codebook != null && (_answer.text.length >= 4 || c == ' ')) return;
    _answer.text = '${_answer.text}$c';
  }

  void _backspace() => _answer.text = backspaceAnswer(_answer.text);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wake.dispose();
    unawaited(_playerSub?.cancel());
    unawaited(_conditionsSub?.cancel());
    unawaited(_conditionsInterruptionSub?.cancel());
    unawaited(_conditions?.dispose());
    unawaited(_playback?.dispose());
    _answer.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final step = _planStep;
    // A challenge says so in its title; everything else is practice.
    final title =
        widget.title ??
        (step != null
            ? PlanLabels.title(s, step)
            : _session.kind == ReceiveDrillKind.review
            ? s.learnReviewTitle
            : _session.countsTowardLesson && _session.lesson != null
            ? s.learnChallengeTitle(_session.lesson!)
            : _guidedLevel != null
            ? s.learnVerdictAssisted
            : s.learnPracticeTitle);
    final codebook = _codebook;
    const codebookBreakpoint = 900.0;
    final inlineFooter = LearnFooter.belongsInBody(context);
    final footer = switch (_phase) {
      _Phase.listen => _listenActions(context),
      _Phase.summary when _outcome?.saved == true => _summaryActions(context),
      _ => null,
    };
    final content = switch (_phase) {
      _Phase.listen => _buildListen(context),
      _Phase.result => _buildResult(context),
      _Phase.summary => _buildSummary(context),
    };
    final body = codebook != null && _phase == _Phase.listen
        ? SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < codebookBreakpoint;
                final codebookCard = Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.hearing),
                    title: Text(codebookLabel(s, codebook)),
                    subtitle: Text(s.telegraphDigitsHint),
                  ),
                );
                return AdaptivePanelBody(
                  breakpoint: codebookBreakpoint,
                  leading: [
                    if (compact) codebookCard,
                    content,
                    if (inlineFooter && footer != null) footer,
                  ],
                  trailing: [if (!compact) codebookCard],
                );
              },
            ),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: inlineFooter && footer != null
                      ? Column(children: [content, footer])
                      : content,
                ),
              ),
            ),
          );
    final flash = _playback?.flash;
    return DrillLeaveGuard(
      guard: _hasUnsavedRounds,
      child: Scaffold(
        appBar: AppBar(
          title: AppBarTitle(title),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: _session.progress,
              minHeight: 4,
            ),
          ),
        ),
        body: flash == null ? body : FlashOverlay(isOn: flash, child: body),
        bottomNavigationBar: inlineFooter ? null : footer,
      ),
    );
  }
}
