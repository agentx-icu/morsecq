import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../clock.dart';
import '../keyboard_binding.dart';
import '../straight_key.dart';

/// Large touch target that drives a [StraightKeyInput].
///
/// * Pointer handling uses a raw [Listener] (no gesture arena, no delay) and
///   tracks pointer ids, so a second finger landing on the key keeps it down
///   until the *last* finger lifts.
/// * Keyboard: when the widget has focus, keys bound to
///   [KeyerAction.straight] in [binding] press/release it. Repeat events are
///   ignored. Pass `binding: null` explicitly to disable the keyboard.
/// * Timestamps come from [clock] (default [SystemClock.shared]); use the same
///   clock for the decoder's `tick`.
class StraightKeyButton extends StatefulWidget {
  StraightKeyButton({
    super.key,
    required this.input,
    Clock? clock,
    KeyboardKeyBinding? binding,
    bool keyboard = true,
    this.size = 160,
    this.label = 'KEY',
    this.autofocus = false,
    this.color,
    this.pressedColor,
  })  : clock = clock ?? SystemClock.shared,
        binding = keyboard ? (binding ?? KeyboardKeyBinding.defaults) : null;

  /// Minimum touch target in logical pixels.
  static const double minTouchTarget = 48;

  final StraightKeyInput input;
  final Clock clock;
  final KeyboardKeyBinding? binding;
  final double size;
  final String label;
  final bool autofocus;
  final Color? color;
  final Color? pressedColor;

  @override
  State<StraightKeyButton> createState() => _StraightKeyButtonState();
}

class _StraightKeyButtonState extends State<StraightKeyButton> {
  final Set<int> _pointers = <int>{};
  bool _keyboardDown = false;
  bool _reportedDown = false;

  bool get _isDown => _pointers.isNotEmpty || _keyboardDown;

  void _sync() {
    final down = _isDown;
    if (down == _reportedDown) {
      return;
    }
    _reportedDown = down;
    final at = widget.clock.now();
    if (down) {
      widget.input.press(at);
    } else {
      widget.input.release(at);
    }
    setState(() {});
  }

  void _pointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    _sync();
  }

  void _pointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    _sync();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final binding = widget.binding;
    if (binding == null || binding.actionFor(event.logicalKey) != KeyerAction.straight) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      _keyboardDown = true;
      _sync();
    } else if (event is KeyUpEvent) {
      _keyboardDown = false;
      _sync();
    }
    // KeyRepeatEvent: swallow so the OS does not treat it as typing.
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    if (_reportedDown) {
      widget.input.release(widget.clock.now());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final side = widget.size < StraightKeyButton.minTouchTarget
        ? StraightKeyButton.minTouchTarget
        : widget.size;
    final down = _isDown;
    final background = down
        ? (widget.pressedColor ?? scheme.primary)
        : (widget.color ?? scheme.primaryContainer);
    final foreground = down ? scheme.onPrimary : scheme.onPrimaryContainer;

    return Focus(
      autofocus: widget.autofocus,
      onKeyEvent: widget.binding == null ? null : _onKey,
      child: Semantics(
        button: true,
        label: widget.label,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDown,
          onPointerUp: _pointerUp,
          onPointerCancel: _pointerUp,
          child: SizedBox(
            width: side,
            height: side,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                boxShadow: down
                    ? const <BoxShadow>[]
                    : <BoxShadow>[
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
