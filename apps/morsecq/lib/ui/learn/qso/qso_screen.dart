import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/qso_practice.dart';
import '../../../training/send_session.dart';
import '../../../training/training_controller.dart';
import '../drill_session_guard.dart';
import '../keying/keyer_panel.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import '../progress_save_snack.dart';
import 'qso_labels.dart';
import 'qso_log_view.dart';
import 'qso_summary_view.dart';

part 'qso_screen_views.dart';

/// A running simulated QSO (functional spec §5.2): the remote station's
/// complete text snapshots are played at the learner's speed; the learner
/// keys a reply (touch or keyboard) and submits it explicitly. Pausing,
/// backgrounding and leaving stop playback; the text state is kept as a
/// draft and can be resumed.
class QsoScreen extends StatefulWidget {
  const QsoScreen({
    super.key,
    required this.controller,
    required this.playback,
    required this.session,
    this.resumed,
    this.screenWake = const WakelockScreenWake(),
  });

  /// The draft this QSO was resumed from (null for a fresh QSO): its
  /// unsent keyed reply is kept, and nothing plays until asked.
  final QsoDraft? resumed;

  final TrainingController controller;
  final LearnPlaybackFactory playback;
  final QsoSession session;
  final ScreenWakeApi screenWake;

  @override
  State<QsoScreen> createState() => _QsoScreenState();
}

class _QsoScreenState extends State<QsoScreen> with WidgetsBindingObserver {
  final GlobalKey<KeyerPanelState> _panel = GlobalKey<KeyerPanelState>();
  final Set<int> _revealed = <int>{};
  final List<double> _wpms = <double>[];
  final Stopwatch _active = Stopwatch();
  late final TextEditingController _typedText = TextEditingController(
    text: widget.resumed?.typedReply == true ? widget.resumed!.pendingText : '',
  );
  late bool _typing = widget.resumed?.typedReply ?? false;
  late bool _pendingWasTyped =
      (widget.resumed?.pendingWasTyped ?? false) ||
      (widget.resumed?.typedReply ?? false);
  late final Duration _activeBefore = widget.resumed?.active ?? Duration.zero;

  /// A keyed but unsent reply restored from the draft, and its id.
  late String _carry = widget.resumed?.pendingText ?? '';
  late String? _carryId = widget.resumed?.pendingId;

  Duration get _activeTotal => _activeBefore + _active.elapsed;

  /// Restored and newly keyed text joined as keyed: the decoder decides
  /// where word gaps are, so a reply resumed mid-word stays one word.
  String get _pendingText =>
      _typing ? _typedText.text : '$_carry${_keying.decodedText}';

  /// Text snapshot including the released pattern awaiting a character gap.
  String get _pendingSnapshot {
    final pattern = _typing ? '' : _keying.pendingPattern;
    final pendingCharacter = pattern.isEmpty
        ? ''
        : MorseAlphabet.decodePattern(pattern) ?? '<$pattern>';
    return '$_pendingText$pendingCharacter';
  }

  late final DrillScreenWake _wake = DrillScreenWake(widget.screenWake);
  LearnPlayback? _playback;
  StreamSubscription<PlayerEvent>? _playerSub;
  late SendSession _keying;
  StreamSubscription<void>? _keyingSub;
  bool _remotePlaying = false;
  bool _recorded = false;
  bool _disposed = false;
  QsoHint? _hint;
  List<QsoIssue> _issues = const <QsoIssue>[];

  QsoSession get _session => widget.session;
  TrainingController get _c => widget.controller;

  MorseTiming get _remoteTiming => MorseTiming(
    wpm: _session.characterWpm,
    farnsworthWpm: _session.effectiveWpm < _session.characterWpm
        ? _session.effectiveWpm
        : null,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _newKeying();
    _active.start();
    _wake.setActive(true);
    unawaited(_setup());
  }

  Future<void> _setup() async {
    final playback = await widget.playback.create(_c.settings);
    if (_disposed) {
      await playback.dispose();
      return;
    }
    _playerSub = playback.player.events.listen((event) {
      if ((event is PlayerCompleted || event is PlayerStopped) &&
          _remotePlaying &&
          !_disposed) {
        setState(() => _remotePlaying = false);
      }
    });
    setState(() => _playback = playback);
    // A fresh QSO starts with the remote's call; a resumed one never
    // restarts playback on its own.
    if (widget.resumed == null && _session.learnerTurns == 0) {
      _playRemote(_session.lastRemoteText);
    }
  }

  void _newKeying() {
    unawaited(_keyingSub?.cancel());
    _keying = SendSession(target: '', timing: _remoteTiming, now: _c.now);
    _keying.listenToDecoder();
    var marks = _keying.markCount;
    _keyingSub = _keying.changes.listen((_) {
      // Real keying is practice even after Pause stopped the clock; a
      // decoder committing a pending gap is not.
      final keyed = _keying.isKeyDown || _keying.markCount != marks;
      marks = _keying.markCount;
      if (keyed && !_active.isRunning && !_session.isDone) _active.start();
      if (!_disposed) setState(() {});
    });
  }

  void _playRemote(String? text) {
    final playback = _playback;
    if (text == null || playback == null || _disposed) return;
    _panel.currentState?.releaseHeld();
    _active.start();
    setState(() => _remotePlaying = true);
    playback.player.play(MorseEncoder.encode(text, _remoteTiming));
  }

  void _pause() {
    _playback?.player.stop();
    // A paused QSO is not active practice.
    _active.stop();
    _panel.currentState?.releaseHeld();
    if (mounted) setState(() => _remotePlaying = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _wake.onLifecycle(state);
    if (isDrillBackground(state)) {
      _pause();
      _active.stop();
      unawaited(_saveDraft());
    } else if (state == AppLifecycleState.resumed && !_session.isDone) {
      _active.start();
    }
  }

  Future<void> _saveDraft() async {
    // Let the decoder commit a pending character / word gap first, so a
    // restored reply keeps its word boundaries.
    final playback = _playback;
    if (playback != null) _keying.tick(playback.clock.now());
    // A released final mark may still be waiting for its character gap.
    // Snapshot that pattern without flushing the live decoder: a hint or
    // repeat can save while the learner continues the same character.
    try {
      await _c.saveQsoDraft(
        _session,
        pendingText: _pendingSnapshot,
        pendingId: _carryId ?? _keying.id,
        typedReply: _typing,
        pendingWasTyped: _pendingWasTyped,
        active: _activeTotal,
      );
    } on Object {
      // A lost draft only costs the resume option.
    }
  }

  Future<void> _submitText(String id, String text, {bool typed = false}) async {
    if (_session.isDone) return;
    final reply = _session.submit(id, text, typed: typed);
    if (reply.duplicate) return;
    setState(() {
      _issues = reply.evaluation.issues;
      if (reply.advanced) _hint = null;
    });
    unawaited(_saveDraft());
    if (_session.isDone) {
      await _finish();
    }
    _playRemote(reply.remoteText);
  }

  Future<void> _send() async {
    // An enabled button callback may survive until the next frame. Check
    // current state before clearing input or creating a new reply id.
    if (_disposed || _session.isDone || _remotePlaying || _playback == null) {
      return;
    }
    if (_typing
        ? _typedText.text.trim().isEmpty
        : (!_keying.hasInput && _carry.trim().isEmpty)) {
      return;
    }
    final keying = _keying;
    final typed = _typing || _pendingWasTyped;
    String text;
    if (_typing) {
      text = _typedText.text;
      _typedText.clear();
    } else {
      final result = keying.finish();
      if (result.attempt.marks.length >= 3 && result.measuredWpm > 0) {
        _wpms.add(result.measuredWpm);
      }
      text = '$_carry${result.attempt.decoded}';
    }
    final id = _carryId ?? keying.id;
    _carry = '';
    _carryId = null;
    _pendingWasTyped = false;
    _newKeying();
    keying.dispose();
    _active.start();
    await _submitText(id, text, typed: typed);
  }

  void _clear() {
    setState(() {
      _carry = '';
      _carryId = null;
      _typedText.clear();
      _pendingWasTyped = false;
    });
    _keying.restart();
    _panel.currentState?.releaseHeld();
  }

  void _toggleTyping() {
    _panel.currentState?.releaseHeld();
    final pending = _pendingSnapshot;
    setState(() {
      if (_typing) {
        _carry = pending;
        _typedText.clear();
      } else {
        _typedText.text = pending;
        _carry = '';
      }
      _typing = !_typing;
      _keying.restart();
    });
    unawaited(_saveDraft());
  }

  void _request(String intent) =>
      unawaited(_submitText('${_keying.id}-${_session.turns.length}', intent));

  void _showHint() {
    setState(() => _hint = _session.hint());
    unawaited(_saveDraft());
  }

  void _reveal(int index) {
    if (_revealed.add(index)) _session.hints++;
    setState(() {});
    unawaited(_saveDraft());
  }

  Future<void> _finish() async {
    if (_recorded) return;
    _recorded = true;
    _active.stop();
    _wake.setActive(false);
    var saved = false;
    try {
      saved = await _c.finishQso(_session, _activeTotal);
    } on Object {
      saved = false;
    }
    // The draft stays until the result is saved; reopening the simulator
    // commits it again (idempotent), and Retry writes the progress now.
    if (!saved && mounted) showProgressSaveFailed(context, _c);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    if (!_session.isDone && !_recorded) unawaited(_saveDraft());
    _wake.dispose();
    unawaited(_playerSub?.cancel());
    unawaited(_keyingSub?.cancel());
    _keying.dispose();
    _typedText.dispose();
    unawaited(_playback?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final playback = _playback;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.learnQsoTitle),
        actions: <Widget>[
          if (_remotePlaying)
            IconButton(
              tooltip: s.learnQsoPause,
              icon: const Icon(Icons.pause),
              onPressed: _pause,
            ),
        ],
      ),
      body: _withFlash(
        playback,
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _session.isDone
                    ? QsoSummaryView(
                        session: _session,
                        sendingWpm: _wpms.isEmpty
                            ? null
                            : _wpms.reduce((a, b) => a + b) / _wpms.length,
                        onDone: () => Navigator.of(context).pop(),
                      )
                    : _running(context, s, playback),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Flash-only settings (or the fallback when audio fails) must still
  /// show the remote's transmission.
  static Widget _withFlash(LearnPlayback? playback, Widget body) {
    final flash = playback?.flash;
    return flash == null ? body : FlashOverlay(isOn: flash, child: body);
  }

  void _typedChanged() {
    _pendingWasTyped = _typedText.text.trim().isNotEmpty;
    _active.start();
    setState(() {});
  }
}
