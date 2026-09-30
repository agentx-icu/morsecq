import 'package:flutter/foundation.dart';

import '../l10n/generated/s.dart';
import 'current_strings.dart';
import 'locale_controller.dart';

/// Listenable view of [currentS] for long-lived services that must react to
/// a language change (rebuild the tray menu, relabel a persistent
/// notification). Fires when the user changes the setting or, while
/// following the system, when the OS locale changes.
class StringsResolver extends ChangeNotifier {
  StringsResolver(this._controller) {
    _controller.addListener(_changed);
    final dispatcher = PlatformDispatcher.instance;
    _previousOnLocaleChanged = dispatcher.onLocaleChanged;
    dispatcher.onLocaleChanged = _onPlatformLocaleChanged;
  }

  final LocaleController _controller;
  VoidCallback? _previousOnLocaleChanged;
  bool _disposed = false;

  /// Strings in the current UI language (never cached: cheap lookup).
  S get s => lookupSFor(_controller.effectiveLocale);

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _onPlatformLocaleChanged() {
    _previousOnLocaleChanged?.call();
    if (_controller.followsSystem) _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.removeListener(_changed);
    final dispatcher = PlatformDispatcher.instance;
    if (dispatcher.onLocaleChanged == _onPlatformLocaleChanged) {
      dispatcher.onLocaleChanged = _previousOnLocaleChanged;
    }
    super.dispose();
  }
}
