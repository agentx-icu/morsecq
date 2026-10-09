import 'package:flutter/material.dart';

/// A training setting with its current value and a slider below. Title and
/// value share a line when they fit; large text moves the value (and its
/// optional [trailing] button) below instead of squeezing the title out.
class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    super.key,
    required this.title,
    required this.value,
    required this.slider,
    this.trailing,
  });

  final String title;
  final String value;
  final Slider slider;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: <Widget>[
              Text(title, style: theme.textTheme.bodyLarge),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(value, style: theme.textTheme.titleMedium),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
        slider,
      ],
    );
  }
}
