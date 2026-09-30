import 'package:flutter/widgets.dart' show Locale;

/// Reference *content* (Q-code meanings, CW abbreviations, prosign meanings,
/// mnemonics) is data, not UI chrome, so it does not live in the ARB files.
/// Each row of a data table carries its text per language, keyed by ISO
/// language code; a new language adds one entry per row.
///
/// [kReferenceFallbackLanguage] is the language every row must have; the
/// lookup helpers fall back to it when a row lacks the requested language.
const String kReferenceFallbackLanguage = 'en';

/// Languages the reference tables carry today. Derived mnemonic lines are
/// generated for each of these.
const List<String> kReferenceLanguages = <String>['en', 'zh'];

/// Picks the text of [byLanguage] for [locale]'s language, falling back to
/// English. Null when the row has neither.
String? localizedReferenceText(Map<String, String> byLanguage, Locale locale) =>
    byLanguage[locale.languageCode] ?? byLanguage[kReferenceFallbackLanguage];

/// Separator between a label and its explanation: `: ` in Latin-script
/// languages, the full-width colon in Chinese.
String referenceLabelSeparator(String language) => language == 'zh' ? '：' : ': ';
