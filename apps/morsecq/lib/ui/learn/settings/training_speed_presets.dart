part of 'training_settings_screen.dart';

/// Plain presets over the two speed sliders: the beginner pace stretches
/// the pauses (20 / 6), the standard one is the Koch default (20 / 8).
/// The glossary explains character vs effective speed.
class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.trainer, required this.onPick});

  final TrainerSettings trainer;
  final ValueChanged<TrainerSettings> onPick;

  static const double presetCharacterWpm = 20;
  static const double beginnerEffectiveWpm = 6;
  static const double standardEffectiveWpm = 8;

  bool _matches(double effective) =>
      trainer.characterWpm == presetCharacterWpm &&
      trainer.farnsworthWpm == effective;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  s.learnSpeedPresets,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const LearnGlossaryButton(),
            ],
          ),
          Wrap(
            spacing: 8,
            children: <Widget>[
              wrappingChoiceChip(
                key: const ValueKey('preset-beginner'),
                label: s.learnPresetBeginner,
                selected: _matches(beginnerEffectiveWpm),
                onSelected: (_) => onPick(
                  trainer.copyWith(
                    characterWpm: presetCharacterWpm,
                    farnsworthWpm: beginnerEffectiveWpm,
                  ),
                ),
              ),
              wrappingChoiceChip(
                key: const ValueKey('preset-standard'),
                label: s.learnPresetStandard,
                selected: _matches(standardEffectiveWpm),
                onSelected: (_) => onPick(
                  trainer.copyWith(
                    characterWpm: presetCharacterWpm,
                    farnsworthWpm: standardEffectiveWpm,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            s.learnPresetHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
