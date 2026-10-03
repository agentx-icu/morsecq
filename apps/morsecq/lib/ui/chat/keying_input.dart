import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';

import '../../i18n/l10n_extension.dart';
import 'morse_pattern_text.dart';

/// Which hand-keying widget the input area shows.
enum KeyingMode { straightKey, paddles }

/// Straight key or iambic paddles wired to a [MorseDecoder]; decoded
/// characters are handed to [onText] so the owner can append them to the
/// draft. Both modalities work by touch (on-screen pads, ≥ 48 dp) and by
/// keyboard (Space / left+right Ctrl via `morse_io`'s default binding).
///
/// The decoder is seeded with the listener's own dit length so the first
/// characters decode sensibly before it adapts to the operator's fist.
class KeyingInput extends StatefulWidget {
  const KeyingInput({
    super.key,
    required this.mode,
    required this.timing,
    required this.sink,
    required this.clock,
    required this.onText,
    this.height = 132,
  });

  final KeyingMode mode;
  final MorseTiming timing;
  final MorseSink sink;
  final Clock clock;
  final ValueChanged<String> onText;
  final double height;

  @override
  State<KeyingInput> createState() => _KeyingInputState();
}

class _KeyingInputState extends State<KeyingInput> {
  late MorseDecoder _decoder;
  late StreamSubscription<DecodeEvent> _events;
  StraightKey? _straight;
  IambicKeyer? _keyer;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _decoder = MorseDecoder(
      config: DecoderConfig(initialDit: widget.timing.dit),
    );
    _events = _decoder.events.listen(_onDecode);
    _buildKeyer();
    // A sink sounds nothing until prepared (the audio engine starts here).
    unawaited(widget.sink.prepare());
    _tick = Timer.periodic(const Duration(milliseconds: 40), (_) {
      final String before = _decoder.pendingPattern;
      _decoder.tick(widget.clock.now());
      if (before != _decoder.pendingPattern && mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(KeyingInput old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.sink != widget.sink) {
      _disposeKeyer();
      _buildKeyer();
      if (old.sink != widget.sink) unawaited(widget.sink.prepare());
    } else if (old.timing != widget.timing) {
      _keyer?.timing = KeyerTiming.fromMorseTiming(widget.timing);
    }
  }

  void _buildKeyer() {
    final KeyTarget target = MorseDecoderTarget(_decoder);
    switch (widget.mode) {
      case KeyingMode.straightKey:
        _straight = StraightKey(target: target, sink: widget.sink);
      case KeyingMode.paddles:
        _keyer = IambicKeyer(
          timing: KeyerTiming.fromMorseTiming(widget.timing),
          target: target,
          sink: widget.sink,
          clock: widget.clock,
        );
    }
  }

  void _disposeKeyer() {
    final StraightKey? s = _straight;
    final IambicKeyer? k = _keyer;
    _straight = null;
    _keyer = null;
    if (s != null) unawaited(s.dispose());
    if (k != null) unawaited(k.dispose());
  }

  void _onDecode(DecodeEvent event) {
    switch (event.kind) {
      case DecodeEventKind.character:
      case DecodeEventKind.word:
      case DecodeEventKind.unknownPattern:
        final String? text = event.text;
        if (text != null && text.isNotEmpty) widget.onText(text);
      case DecodeEventKind.element:
        break;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_events.cancel());
    _disposeKeyer();
    _decoder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String pending = _decoder.pendingPattern;
    final Widget pad = switch (widget.mode) {
      KeyingMode.straightKey => Center(
        child: StraightKeyButton(
          input: _straight!,
          clock: widget.clock,
          size: widget.height - 12,
          autofocus: true,
        ),
      ),
      KeyingMode.paddles => PaddleButtons(
        input: _keyer!,
        clock: widget.clock,
        height: widget.height - 12,
        autofocus: true,
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.mode == KeyingMode.straightKey
                      ? context.s.chatKeyHint
                      : context.s.chatPaddleHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              MorsePatternText(
                pending.isEmpty ? ' ' : pending,
                style: theme.textTheme.titleMedium,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(height: widget.height, child: pad),
        ],
      ),
    );
  }
}
