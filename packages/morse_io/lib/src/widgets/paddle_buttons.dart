import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../clock.dart';
import '../iambic_keyer.dart';
import '../keyboard_binding.dart';

/// Two side-by-side paddles (dit left, dah right by default) driving a
/// [PaddleInput] such as [IambicKeyer].
///
/// Each paddle tracks its own pointer ids, so both can be held at once with
/// two fingers (a squeeze) and a paddle only releases when its last finger
/// lifts. Keyboard keys bound to [KeyerAction.dit] / [KeyerAction.dah] in
/// [binding] work while the widget has focus; repeats are ignored.
class PaddleButtons extends StatefulWidget {
  PaddleButtons({
    super.key,
    required this.input,
    Clock? clock,
    KeyboardKeyBinding? binding,
    bool keyboard = true,
    this.height = 160,
    this.gap = 12,
    this.swapPaddles = false,
    this.autofocus = false,
    this.ditLabel = 'DIT',
    this.dahLabel = 'DAH',
  }) : clock = clock ?? SystemClock.shared,
       binding = keyboard ? (binding ?? KeyboardKeyBinding.defaults) : null;

  static const double minTouchTarget = 48;

  final PaddleInput input;
  final Clock clock;
  final KeyboardKeyBinding? binding;
  final double height;
  final double gap;

  /// Put dah on the left (left-handed layout). Keyboard mapping is unchanged.
  final bool swapPaddles;
  final bool autofocus;
  final String ditLabel;
  final String dahLabel;

  @override
  State<PaddleButtons> createState() => _PaddleButtonsState();
}

class _PaddleButtonsState extends State<PaddleButtons> {
  final _PaddleState _dit = _PaddleState();
  final _PaddleState _dah = _PaddleState();

  void _sync(_PaddleState paddle, bool isDit) {
    final down = paddle.isDown;
    if (down == paddle.reported) {
      return;
    }
    paddle.reported = down;
    final at = widget.clock.now();
    if (isDit) {
      widget.input.ditPaddle(down, at);
    } else {
      widget.input.dahPaddle(down, at);
    }
    setState(() {});
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final action = widget.binding?.actionFor(event.logicalKey);
    final paddle = switch (action) {
      KeyerAction.dit => _dit,
      KeyerAction.dah => _dah,
      _ => null,
    };
    if (paddle == null) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      paddle.keyboardDown = true;
      _sync(paddle, paddle == _dit);
    } else if (event is KeyUpEvent) {
      paddle.keyboardDown = false;
      _sync(paddle, paddle == _dit);
    }
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    final at = widget.clock.now();
    if (_dit.reported) {
      widget.input.ditPaddle(false, at);
    }
    if (_dah.reported) {
      widget.input.dahPaddle(false, at);
    }
    super.dispose();
  }

  Widget _paddle(_PaddleState state, bool isDit) => Expanded(
    child: _Paddle(
      label: isDit ? widget.ditLabel : widget.dahLabel,
      down: state.isDown,
      height: widget.height < PaddleButtons.minTouchTarget
          ? PaddleButtons.minTouchTarget
          : widget.height,
      onPointerDown: (event) {
        state.pointers.add(event.pointer);
        _sync(state, isDit);
      },
      onPointerUp: (event) {
        state.pointers.remove(event.pointer);
        _sync(state, isDit);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final left = _paddle(widget.swapPaddles ? _dah : _dit, !widget.swapPaddles);
    final right = _paddle(widget.swapPaddles ? _dit : _dah, widget.swapPaddles);
    return Focus(
      autofocus: widget.autofocus,
      onKeyEvent: widget.binding == null ? null : _onKey,
      child: Row(
        children: <Widget>[
          left,
          SizedBox(width: widget.gap),
          right,
        ],
      ),
    );
  }
}

class _PaddleState {
  final Set<int> pointers = <int>{};
  bool keyboardDown = false;
  bool reported = false;

  bool get isDown => pointers.isNotEmpty || keyboardDown;
}

class _Paddle extends StatelessWidget {
  const _Paddle({
    required this.label,
    required this.down,
    required this.height,
    required this.onPointerDown,
    required this.onPointerUp,
  });

  final String label;
  final bool down;
  final double height;
  final void Function(PointerDownEvent) onPointerDown;
  final void Function(PointerEvent) onPointerUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerUp,
        child: SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: down ? scheme.primary : scheme.primaryContainer,
              shape:
                  theme.outlinedButtonTheme.style?.shape?.resolve({}) ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
            ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: down ? scheme.onPrimary : scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
