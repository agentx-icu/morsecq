import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_io/morse_io.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/send_session.dart';
import '../../../training/training_settings.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import '../send/keyer_legend.dart';

/// On-screen straight key or paddles (plus Space / Ctrl keys when a
/// hardware keyboard is present) feeding a [SendSession] as decoder. Owns
/// the keyer objects and the decoder tick; the parent owns the session and
/// the playback. Both keying modalities are always available.
class KeyerPanel extends StatefulWidget {
  const KeyerPanel({
    super.key,
    required this.session,
    required this.playback,
    required this.mode,
    this.enabled = true,
    this.size = 150,
  });

  final SendSession session;
  final LearnPlayback playback;
  final KeyerMode mode;

  /// False while the remote station is sending: keying is ignored.
  final bool enabled;
  final double size;

  static const Duration tickPeriod = Duration(milliseconds: 40);

  @override
  State<KeyerPanel> createState() => KeyerPanelState();
}

class KeyerPanelState extends State<KeyerPanel> {
  StraightKey? _straight;
  IambicKeyer? _keyer;
  Timer? _tick;
  int _generation = 0;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _build();
    _scheduleTick();
  }

  @override
  void didUpdateWidget(KeyerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget;
    if (!identical(old.session, widget.session) ||
        old.mode != widget.mode ||
        old.enabled != widget.enabled) {
      _build();
    }
  }

  /// Drops a held key (focus loss, background, remote turn) without
  /// measuring it.
  void releaseHeld() {
    widget.session.cancelHeld();
    _build();
    if (mounted) setState(() {});
  }

  void _build() {
    widget.session.cancelHeld();
    unawaited(_straight?.dispose());
    unawaited(_keyer?.dispose());
    _straight = null;
    _keyer = null;
    _generation++;
    if (!widget.enabled) return;
    final playback = widget.playback;
    switch (widget.mode) {
      case KeyerMode.straight:
        _straight = StraightKey(target: widget.session, sink: playback.sink);
      case KeyerMode.iambicA:
      case KeyerMode.iambicB:
        _keyer = IambicKeyer(
          timing: KeyerTiming.fromMorseTiming(widget.session.nominalTiming),
          target: widget.session,
          sink: playback.sink,
          clock: playback.clock,
          mode: widget.mode == KeyerMode.iambicA ? IambicMode.a : IambicMode.b,
        );
    }
  }

  void _scheduleTick() {
    if (_disposed) return;
    final clock = widget.playback.clock;
    _tick = clock.schedule(KeyerPanel.tickPeriod, () {
      if (_disposed) return;
      widget.session.tick(clock.now());
      _scheduleTick();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    unawaited(_straight?.dispose());
    unawaited(_keyer?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final playback = widget.playback;
    final Widget key;
    final straight = _straight;
    final keyer = _keyer;
    if (straight != null) {
      key = Center(
        child: StraightKeyButton(
          key: ValueKey<String>('panel-straight-$_generation'),
          input: straight,
          clock: playback.clock,
          autofocus: true,
          size: widget.size,
          label: s.learnStraightKeyLabel,
          semanticDit: widget.session.nominalTiming.dit,
          semanticDitLabel: s.learnDitLabel,
          semanticDahLabel: s.learnDahLabel,
        ),
      );
    } else if (keyer != null) {
      key = PaddleButtons(
        key: ValueKey<String>('panel-paddles-$_generation'),
        input: keyer,
        clock: playback.clock,
        autofocus: true,
        height: widget.size,
        ditLabel: s.learnDitLabel,
        dahLabel: s.learnDahLabel,
      );
    } else {
      key = SizedBox(height: widget.size);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        key,
        if (hasPhysicalKeyboardByDefault && widget.enabled) ...<Widget>[
          const SizedBox(height: 8),
          KeyerLegend(mode: widget.mode),
        ],
      ],
    );
  }
}
