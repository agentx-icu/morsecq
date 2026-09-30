import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

import '../l10n/generated/s.dart';
import 'key_value_store.dart';

/// The user's language choice: follow the system, or force one of the
/// locales the app ships (see [supportedLocales]).
///
/// Wire it above `MaterialApp` and pass [locale] to `MaterialApp.locale`
/// (null means "follow the system", which Flutter resolves against
/// `supportedLocales` itself). Persistence goes through the injected
/// [KeyValueStore] under [storageKey].
class LocaleController extends ChangeNotifier {
  /// Restores the saved choice synchronously from [store]; an unknown or
  /// unsupported saved value falls back to "follow the system".
  LocaleController(this._store)
    : _override = parseLocaleName(_store.getString(storageKey));

  final KeyValueStore _store;

  /// Key under which the chosen locale is persisted (as a [localeName]).
  static const String storageKey = 'i18n.locale';

  /// Locales with an ARB file; the generated `S` class is the source of truth.
  static List<Locale> get supportedLocales => S.supportedLocales;

  Locale? _override;

  /// The forced locale, or null to follow the system.
  Locale? get locale => _override;

  bool get followsSystem => _override == null;

  /// Sets (and persists) the locale; null returns to the system default.
  /// A locale outside [supportedLocales] is mapped to the supported locale
  /// with the same language code, or ignored when there is none.
  Future<void> setLocale(Locale? value) async {
    final resolved = value == null ? null : supportedLocaleFor(value);
    if (value != null && resolved == null) return;
    if (resolved == _override) return;
    _override = resolved;
    notifyListeners();
    if (resolved == null) {
      await _store.remove(storageKey);
    } else {
      await _store.setString(storageKey, localeName(resolved));
    }
  }

  /// The supported locale matching [candidate]'s language, or null.
  static Locale? supportedLocaleFor(Locale candidate) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == candidate.languageCode) return supported;
    }
    return null;
  }

  /// Canonical, persisted name of a supported locale: `en`, `zh_CN`.
  static String localeName(Locale locale) => switch (locale.languageCode) {
    'zh' => 'zh_CN',
    final code => code,
  };

  /// Inverse of [localeName]; tolerant of `zh`, `zh-Hans`, `zh_Hans_CN`,
  /// `en_US`… Returns null for null/empty/unsupported input.
  static Locale? parseLocaleName(String? name) {
    if (name == null || name.isEmpty) return null;
    final language = name.split(RegExp('[-_]')).first.toLowerCase();
    return supportedLocaleFor(Locale(language));
  }
}

/// Human-readable, localized label for a language choice (null = system).
String localeDisplayName(S s, Locale? locale) {
  if (locale == null) return s.languageSystemDefault;
  return switch (locale.languageCode) {
    'zh' => s.languageChinese,
    _ => s.languageEnglish,
  };
}
