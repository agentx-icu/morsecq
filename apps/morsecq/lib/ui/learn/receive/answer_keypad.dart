import 'package:flutter/material.dart';

import '../learn_strings.dart';

/// On-screen keypad restricted to the symbols the trainee has learned.
///
/// Primary input on phones; also usable on desktop next to the text field.
/// Every key is at least 48 dp so it is a comfortable touch target. Prosigns
/// (`<BT>`) render as one key and insert their bracketed token.
class AnswerKeypad extends StatelessWidget {
  const AnswerKeypad({
    super.key,
    required this.chars,
    required this.onChar,
    required this.onBackspace,
    required this.onSpace,
    this.enabled = true,
  });

  /// Symbols to offer, in teaching order.
  final List<String> chars;
  final ValueChanged<String> onChar;
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final bool enabled;

  static const double keySize = 48;
  static const double keyGap = 6;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: keyGap,
          runSpacing: keyGap,
          children: <Widget>[
            for (final c in chars)
              _Key(
                label: c,
                semanticsLabel: c,
                enabled: enabled,
                onTap: () => onChar(c),
                minWidth: c.length > 1 ? keySize * 1.5 : keySize,
              ),
          ],
        ),
        const SizedBox(height: keyGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Key(
              label: LearnStrings.space,
              semanticsLabel: LearnStrings.space,
              enabled: enabled,
              onTap: onSpace,
              minWidth: keySize * 3,
              background: scheme.surfaceContainerHigh,
            ),
            const SizedBox(width: keyGap),
            _Key(
              label: '⌫',
              semanticsLabel: LearnStrings.backspace,
              enabled: enabled,
              onTap: onBackspace,
              minWidth: keySize * 1.5,
              background: scheme.surfaceContainerHigh,
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.semanticsLabel,
    required this.enabled,
    required this.onTap,
    required this.minWidth,
    this.background,
  });

  final String label;
  final String semanticsLabel;
  final bool enabled;
  final VoidCallback onTap;
  final double minWidth;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: background ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth,
              minHeight: AnswerKeypad.keySize,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: enabled
                        ? scheme.onPrimaryContainer
                        : scheme.onSurface.withValues(alpha: 0.38),
                    fontWeight: FontWeight.w600,
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
