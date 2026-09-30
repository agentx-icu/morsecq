import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../training/training_controller.dart';
import '../../../training/training_settings.dart';
import '../learn_platform.dart';
import '../learn_playback.dart';
import '../learn_strings.dart';

/// Training preferences. Reachable from the Learn home gear and pushable
/// from the Me page via [routeName] / [route].
class TrainingSettingsScreen extends StatefulWidget {
  const TrainingSettingsScreen({
    super.key,
    required this.controller,
    required this.playback,
  });

  static const String routeName = '/settings/training';

  static Route<void> route({
    required TrainingController controller,
    required LearnPlaybackFactory playback,
  }) => MaterialPageRoute<void>(
    settings: const RouteSettings(name: routeName),
    builder: (_) =>
        TrainingSettingsScreen(controller: controller, playback: playback),
  );

  final TrainingController controller;
  final LearnPlaybackFactory playback;

  @override
  State<TrainingSettingsScreen> createState() => _TrainingSettingsScreenState();
}

class _TrainingSettingsScreenState extends State<TrainingSettingsScreen> {
  late TrainingSettings _draft = widget.controller.settings;
  LearnPlayback? _sample;
  StreamSubscription<PlayerEvent>? _sampleSub;
  bool _samplePlaying = false;

  TrainerSettings get _t => _draft.trainer;

  /// Updates the draft; persists when [persist] (slider release, toggles).
  void _apply(TrainingSettings next, {bool persist = true}) {
    setState(() => _draft = next);
    _sample?.sidetone?.frequencyHz = next.trainer.toneHz;
    if (persist) {
      unawaited(widget.controller.updateSettings(next));
    }
  }

  void _applyTrainer(TrainerSettings trainer, {bool persist = true}) =>
      _apply(_draft.copyWith(trainer: trainer), persist: persist);

  void _setCharacterWpm(double wpm, {bool persist = true}) {
    final fw = _t.farnsworthWpm;
    _applyTrainer(
      _t.copyWith(
        characterWpm: wpm,
        farnsworthWpm: fw == null ? null : math.min(fw, wpm),
      ),
      persist: persist,
    );
  }

  void _setFarnsworth(bool on) {
    if (on) {
      final fw = math.min(_t.characterWpm, 8.0);
      _applyTrainer(_t.copyWith(farnsworthWpm: fw));
    } else {
      _applyTrainer(_t.copyWith(clearFarnsworth: true));
    }
  }

  Future<void> _playSample() async {
    if (_samplePlaying) {
      return;
    }
    setState(() => _samplePlaying = true);
    var playback = _sample;
    if (playback == null) {
      playback = await widget.playback.create(_draft);
      if (!mounted) {
        await playback.dispose();
        return;
      }
      _sample = playback;
      _sampleSub = playback.player.events.listen((event) {
        if ((event is PlayerCompleted || event is PlayerStopped) && mounted) {
          setState(() => _samplePlaying = false);
        }
      });
    }
    playback.sidetone?.frequencyHz = _t.toneHz;
    playback.player.play(
      MorseEncoder.encode(LearnStrings.sampleText, _t.toTiming()),
    );
  }

  @override
  void dispose() {
    unawaited(_sampleSub?.cancel());
    unawaited(_sample?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flash = _sample?.flash;
    final body = ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: <Widget>[
        _SliderTile(
          title: LearnStrings.characterSpeed,
          value: LearnStrings.wpm(_t.characterWpm),
          slider: Slider(
            value: _t.characterWpm.clamp(
              TrainingSettings.minCharacterWpm,
              TrainingSettings.maxCharacterWpm,
            ),
            min: TrainingSettings.minCharacterWpm,
            max: TrainingSettings.maxCharacterWpm,
            divisions:
                (TrainingSettings.maxCharacterWpm -
                        TrainingSettings.minCharacterWpm)
                    .round(),
            label: LearnStrings.wpm(_t.characterWpm),
            onChanged: (v) => _setCharacterWpm(v.roundToDouble(), persist: false),
            onChangeEnd: (v) => _setCharacterWpm(v.roundToDouble()),
          ),
        ),
        SwitchListTile(
          title: const Text(LearnStrings.farnsworth),
          subtitle: const Text(LearnStrings.farnsworthHelp),
          value: _t.farnsworthWpm != null,
          onChanged: _setFarnsworth,
        ),
        if (_t.farnsworthWpm != null) _buildFarnsworthSlider(),
        const Divider(),
        _SliderTile(
          title: LearnStrings.tone,
          value: LearnStrings.hz(_t.toneHz),
          trailing: IconButton.filledTonal(
            tooltip: LearnStrings.playSample,
            onPressed: _samplePlaying ? null : _playSample,
            icon: Icon(_samplePlaying ? Icons.volume_up : Icons.play_arrow),
          ),
          slider: Slider(
            value: _t.toneHz.clamp(
              TrainingSettings.minToneHz,
              TrainingSettings.maxToneHz,
            ),
            min: TrainingSettings.minToneHz,
            max: TrainingSettings.maxToneHz,
            divisions:
                ((TrainingSettings.maxToneHz - TrainingSettings.minToneHz) / 10)
                    .round(),
            label: LearnStrings.hz(_t.toneHz),
            onChanged: (v) => _applyTrainer(
              _t.copyWith(toneHz: v.roundToDouble()),
              persist: false,
            ),
            onChangeEnd: (v) =>
                _applyTrainer(_t.copyWith(toneHz: v.roundToDouble())),
          ),
        ),
        const Divider(),
        _SliderTile(
          title: LearnStrings.sessionLength,
          value: LearnStrings.charsCount(_t.sessionLengthChars),
          slider: Slider(
            value: _t.sessionLengthChars
                .clamp(
                  TrainingSettings.minSessionChars,
                  TrainingSettings.maxSessionChars,
                )
                .toDouble(),
            min: TrainingSettings.minSessionChars.toDouble(),
            max: TrainingSettings.maxSessionChars.toDouble(),
            divisions:
                (TrainingSettings.maxSessionChars -
                    TrainingSettings.minSessionChars) ~/
                10,
            label: LearnStrings.charsCount(_t.sessionLengthChars),
            onChanged: (v) => _applyTrainer(
              _t.copyWith(sessionLengthChars: v.round()),
              persist: false,
            ),
            onChangeEnd: (v) =>
                _applyTrainer(_t.copyWith(sessionLengthChars: v.round())),
          ),
        ),
        _SliderTile(
          title: LearnStrings.dailyGoal,
          value: LearnStrings.charsCount(widget.controller.dailyGoal),
          slider: Slider(
            value: widget.controller.dailyGoal.clamp(25, 500).toDouble(),
            min: 25,
            max: 500,
            divisions: 19,
            label: LearnStrings.charsCount(widget.controller.dailyGoal),
            onChanged: (v) =>
                unawaited(widget.controller.setDailyGoal(v.round())),
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(
            LearnStrings.feedback,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          dense: true,
        ),
        SwitchListTile(
          title: const Text(LearnStrings.sound),
          secondary: const Icon(Icons.volume_up_outlined),
          value: _draft.soundEnabled,
          onChanged: (v) => _apply(_draft.copyWith(soundEnabled: v)),
        ),
        SwitchListTile(
          title: const Text(LearnStrings.flash),
          secondary: const Icon(Icons.flashlight_on_outlined),
          value: _draft.flashEnabled,
          onChanged: (v) => _apply(_draft.copyWith(flashEnabled: v)),
        ),
        if (isTouchPlatform)
          SwitchListTile(
            title: const Text(LearnStrings.haptic),
            secondary: const Icon(Icons.vibration),
            value: _draft.hapticEnabled,
            onChanged: (v) => _apply(_draft.copyWith(hapticEnabled: v)),
          ),
        const Divider(),
        ListTile(
          title: const Text(LearnStrings.keyer),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<KeyerMode>(
              segments: const <ButtonSegment<KeyerMode>>[
                ButtonSegment(
                  value: KeyerMode.straight,
                  label: Text(LearnStrings.keyerStraight),
                ),
                ButtonSegment(
                  value: KeyerMode.iambicA,
                  label: Text(LearnStrings.keyerIambicA),
                ),
                ButtonSegment(
                  value: KeyerMode.iambicB,
                  label: Text(LearnStrings.keyerIambicB),
                ),
              ],
              selected: <KeyerMode>{_draft.keyerMode},
              onSelectionChanged: (s) =>
                  _apply(_draft.copyWith(keyerMode: s.first)),
              showSelectedIcon: false,
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text(LearnStrings.settingsTitle)),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: flash == null ? body : FlashOverlay(isOn: flash, child: body),
          ),
        ),
      ),
    );
  }

  Widget _buildFarnsworthSlider() {
    final max = _t.characterWpm;
    final min = math.min(TrainingSettings.minFarnsworthWpm, max);
    final value = (_t.farnsworthWpm ?? max).clamp(min, max);
    final divisions = (max - min).round();
    return _SliderTile(
      title: LearnStrings.effectiveSpeed,
      value: LearnStrings.wpm(value),
      slider: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions > 0 ? divisions : null,
        label: LearnStrings.wpm(value),
        onChanged: (v) => _applyTrainer(
          _t.copyWith(farnsworthWpm: v.roundToDouble()),
          persist: false,
        ),
        onChangeEnd: (v) =>
            _applyTrainer(_t.copyWith(farnsworthWpm: v.roundToDouble())),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
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
        ListTile(
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(value, style: theme.textTheme.titleMedium),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
        slider,
      ],
    );
  }
}
