import 'package:flutter/widgets.dart';
import 'package:morse_core/morse_core.dart';
import 'package:provider/provider.dart';

/// The listener's own playback preferences (plan §5.2: the sender's speed is
/// never transmitted; every message is rendered at the receiver's settings).
///
/// Defaults: 15 wpm characters, Farnsworth 8 wpm overall, 700 Hz sidetone.
/// Provide one instance above the shell with `ChangeNotifierProvider`; until
/// the app does, [MorsePlaybackSettings.of] falls back to [shared] so the chat
/// UI works standalone and in widget tests.
class MorsePlaybackSettings extends ChangeNotifier {
  MorsePlaybackSettings({
    double wpm = 15,
    double farnsworthWpm = 8,
    double toneHz = 700,
    bool trainingMode = false,
  }) : _wpm = wpm,
       _farnsworthWpm = farnsworthWpm,
       _toneHz = toneHz,
       _trainingMode = trainingMode;

  static const double minWpm = 5;
  static const double maxWpm = 40;
  static const double minToneHz = 400;
  static const double maxToneHz = 1000;

  /// Process-wide fallback used when no provider is installed.
  static final MorsePlaybackSettings shared = MorsePlaybackSettings();

  /// Nearest provided instance, subscribing when [listen] is true; falls back
  /// to [shared].
  static MorsePlaybackSettings of(BuildContext context, {bool listen = true}) {
    try {
      return Provider.of<MorsePlaybackSettings>(context, listen: listen);
    } on ProviderNotFoundException {
      return shared;
    }
  }

  double _wpm;
  double _farnsworthWpm;
  double _toneHz;
  bool _trainingMode;

  double get wpm => _wpm;
  double get farnsworthWpm => _farnsworthWpm;
  double get toneHz => _toneHz;

  /// Hide plain text until the listener taps "reveal" (plan §5.3).
  bool get trainingMode => _trainingMode;

  MorseTiming get timing => MorseTiming(
    wpm: _wpm,
    farnsworthWpm: _farnsworthWpm < _wpm ? _farnsworthWpm : null,
  );

  set wpm(double value) {
    final double v = value.clamp(minWpm, maxWpm);
    if (v == _wpm) return;
    _wpm = v;
    if (_farnsworthWpm > _wpm) _farnsworthWpm = _wpm;
    notifyListeners();
  }

  set farnsworthWpm(double value) {
    final double v = value.clamp(minWpm, _wpm);
    if (v == _farnsworthWpm) return;
    _farnsworthWpm = v;
    notifyListeners();
  }

  set toneHz(double value) {
    final double v = value.clamp(minToneHz, maxToneHz);
    if (v == _toneHz) return;
    _toneHz = v;
    notifyListeners();
  }

  set trainingMode(bool value) {
    if (value == _trainingMode) return;
    _trainingMode = value;
    notifyListeners();
  }
}
