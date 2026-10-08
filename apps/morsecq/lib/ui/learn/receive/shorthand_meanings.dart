import 'package:flutter/widgets.dart' show Locale;
import 'package:morse_trainer/morse_trainer.dart';

import '../../../training/receive_session.dart';
import '../../reference/reference_catalog.dart';

/// Drill kinds whose words are CW shorthand with a meaning worth showing
/// after the answer (pedagogy review: explain the jargon as it comes up).
const Set<ReceiveDrillKind> kShorthandDrillKinds = <ReceiveDrillKind>{
  ReceiveDrillKind.abbreviations,
  ReceiveDrillKind.qso,
};

/// `(word, meaning)` for every distinct word of [text] the reference
/// catalogue explains (abbreviations, Q-codes, prosigns), in order of
/// appearance, in the language of [locale]. Plain words and callsigns are
/// skipped; at most [limit] entries.
List<(String, String)> shorthandMeanings(
  String text,
  Locale locale, {
  int limit = 8,
}) {
  final out = <(String, String)>[];
  final seen = <String>{};
  for (final word in text.split(' ')) {
    final label = word.trim().toUpperCase();
    if (label.isEmpty || !seen.add(label)) continue;
    final meaning = _lookup(label)?.meaning(locale);
    if (meaning == null) continue;
    out.add((label, meaning));
    if (out.length >= limit) break;
  }
  return out;
}

ReferenceEntry? _lookup(String label) {
  for (final section in <List<ReferenceEntry>>[
    ReferenceCatalog.abbreviations,
    ReferenceCatalog.qCodes,
    ReferenceCatalog.prosigns,
  ]) {
    for (final entry in section) {
      if (entry.label == label) return entry;
    }
  }
  // `HW?` and `QSL?` carry a question mark in the script.
  if (label.endsWith('?') && label.length > 1) {
    return _lookup(label.substring(0, label.length - 1));
  }
  return null;
}

/// Symbols of [text] that are not in [learned], distinct, in order.
List<String> untaughtSymbols(String text, Iterable<String> learned) {
  final known = learned.toSet();
  return MorseText.symbols(text).where((c) => !known.contains(c)).toSet().toList();
}
