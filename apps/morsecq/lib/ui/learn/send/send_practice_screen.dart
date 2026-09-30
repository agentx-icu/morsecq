import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/send_session.dart';
import '../../../training/training_controller.dart';
import '../../../training/training_settings.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import 'keyer_legend.dart';
import 'send_live_view.dart';
import 'send_result_view.dart';

/// Send practice: a target to key, an on-screen straight key or paddles (also
/// driven by Space / left Ctrl / right Ctrl when focused), live decode, and
/// rhythm diagnostics with tips when the operator hits Done.
class SendPracticeScreen extends StatefulWidget {
  const SendPracticeScreen({
    super.key,
    required this.controller,
    required this.playback,
    this.session,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;

  /// Initial session; defaults to `controller.startSendSession()`.
  final SendSession? session;

  /// Decoder tick period on the playback clock.
  static const Duration tickPeriod = Duration(milliseconds: 40);

  @override
  State<SendPracticeScreen> createState() => _SendPracticeScreenState();
}

class _SendPracticeScreenState extends State<SendPracticeScreen> {
  late SendSession _session;
  late KeyerMode _mode;
  LearnPlayback? _playback;
  StraightKey? _straight;
  IambicKeyer? _keyer;
  Timer? _tick;
  SendDiagnostics? _result;
  bool _hideTarget = false;
  bool _recording = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session ?? widget.controller.startSendSession();
    _session.listenToDecoder();
    _mode = widget.controller.settings.keyerMode;
    unawaited(_setup());
  }

  Future<void> _setup() async {
    final playback = await widget.playback.create(widget.controller.settings);
    if (_disposed) {
      await playback.dispose();
      return;
    }
    _playback = playback;
    _buildKeyer();
    _scheduleTick();
    setState(() {});
  }

  void _buildKeyer() {
    final playback = _playback;
    if (playback == null) {
      return;
    }
    unawaited(_straight?.dispose());
    unawaited(_keyer?.dispose());
    _straight = null;
    _keyer = null;
    switch (_mode) {
      case KeyerMode.straight:
        _straight = StraightKey(target: _session, sink: playback.sink);
      case KeyerMode.iambicA:
      case KeyerMode.iambicB:
        _keyer = IambicKeyer(
          timing: KeyerTiming.fromMorseTiming(_session.nominalTiming),
          target: _session,
          sink: playback.sink,
          clock: playback.clock,
          mode: _mode == KeyerMode.iambicA ? IambicMode.a : IambicMode.b,
        );
    }
  }

  void _scheduleTick() {
    final playback = _playback;
    if (playback == null || _disposed) {
      return;
    }
    _tick = playback.clock.schedule(SendPracticeScreen.tickPeriod, () {
      if (_disposed) {
        return;
      }
      _session.tick(playback.clock.now());
      _scheduleTick();
    });
  }

  void _setMode(KeyerMode mode) {
    if (mode == _mode) {
      return;
    }
    setState(() => _mode = mode);
    _buildKeyer();
    unawaited(
      widget.controller.updateSettings(
        widget.controller.settings.copyWith(keyerMode: mode),
      ),
    );
  }

  Future<void> _finish() async {
    if (_recording || _result != null) {
      return;
    }
    _recording = true;
    final result = _session.finish();
    await widget.controller.recordSendSession(_session);
    if (!mounted) {
      return;
    }
    setState(() => _result = result);
  }

  void _restart() {
    _session.restart();
    setState(() {});
  }

  void _another() {
    _session.dispose();
    _session = widget.controller.startSendSession();
    _session.listenToDecoder();
    _result = null;
    _recording = false;
    _buildKeyer();
    setState(() {});
  }

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    unawaited(_straight?.dispose());
    unawaited(_keyer?.dispose());
    _session.dispose();
    unawaited(_playback?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _result == null
                ? _buildPractice(context)
                : _buildResult(context),
          ),
        ),
      ),
    );
    final flash = _playback?.flash;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.learnSendTitle),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text(s.learnCopyFromMemory),
              Switch(
                value: _hideTarget,
                onChanged: _result == null
                    ? (v) => setState(() => _hideTarget = v)
                    : null,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: flash == null ? body : FlashOverlay(isOn: flash, child: body),
    );
  }

  Widget _buildPractice(BuildContext context) {
    final playback = _playback;
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SegmentedButton<KeyerMode>(
          segments: <ButtonSegment<KeyerMode>>[
            ButtonSegment(
              value: KeyerMode.straight,
              label: Text(s.learnKeyerStraight),
            ),
            ButtonSegment(
              value: KeyerMode.iambicA,
              label: Text(s.learnKeyerIambicA),
            ),
            ButtonSegment(
              value: KeyerMode.iambicB,
              label: Text(s.learnKeyerIambicB),
            ),
          ],
          selected: <KeyerMode>{_mode},
          onSelectionChanged: (s) => _setMode(s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 16),
        SendLiveView(session: _session, hideTarget: _hideTarget),
        const SizedBox(height: 20),
        if (playback == null)
          const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildKey(playback, s),
        if (hasPhysicalKeyboardByDefault) ...<Widget>[
          const SizedBox(height: 8),
          KeyerLegend(mode: _mode),
        ],
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: Text(s.learnRestart),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // Enabled once there is something to evaluate; follows the
              // session stream because key events do not rebuild this widget.
              child: StreamBuilder<void>(
                stream: _session.changes,
                builder: (context, _) => FilledButton.icon(
                  onPressed: _session.hasInput ? _finish : null,
                  icon: const Icon(Icons.check),
                  label: Text(s.learnDone),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(LearnPlayback playback, S s) {
    // The keyers are rebuilt whenever the mode changes; the widgets get a
    // key per mode so Flutter never reuses a paddle state for a straight key.
    final straight = _straight;
    if (straight != null) {
      return Center(
        child: StraightKeyButton(
          key: const ValueKey<String>('straight-key'),
          input: straight,
          clock: playback.clock,
          autofocus: true,
          size: 180,
          label: s.learnStraightKeyLabel,
        ),
      );
    }
    final keyer = _keyer!;
    return PaddleButtons(
      key: const ValueKey<String>('paddles'),
      input: keyer,
      clock: playback.clock,
      autofocus: true,
      height: 180,
      ditLabel: s.learnDitLabel,
      dahLabel: s.learnDahLabel,
    );
  }

  Widget _buildResult(BuildContext context) {
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SendResultView(diagnostics: _result!),
        const SizedBox(height: 24),
        Row(
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
            Expanded(
              child: FilledButton(
                onPressed: _another,
                autofocus: true,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(s.learnTryAnother),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
