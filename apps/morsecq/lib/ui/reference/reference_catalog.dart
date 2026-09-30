import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';

import 'morse_pattern_text.dart';
import 'reference_abbreviations.dart';
import 'reference_mnemonics.dart';
import 'reference_qcodes.dart';
import 'reference_strings.dart';

/// The sections of the reference, in display order.
enum ReferenceSection {
  alphabet(ReferenceStrings.sectionAlphabet, Icons.abc),
  punctuation(ReferenceStrings.sectionPunctuation, Icons.more_horiz),
  prosigns(ReferenceStrings.sectionProsigns, Icons.code),
  qCodes(ReferenceStrings.sectionQCodes, Icons.question_answer_outlined),
  abbreviations(ReferenceStrings.sectionAbbreviations, Icons.short_text),
  koch(ReferenceStrings.sectionKoch, Icons.format_list_numbered);

  const ReferenceSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// One playable row of the reference.
final class ReferenceEntry {
  const ReferenceEntry({
    required this.section,
    required this.label,
    required this.pattern,
    required this.playText,
    this.meaning,
    this.mnemonic,
    this.position,
  });

  final ReferenceSection section;

  /// What the row is called: `A`, `<AR>`, `QRL`, `73`.
  final String label;

  /// `.`/`-` pattern, with character gaps as spaces for multi-character
  /// entries.
  final String pattern;

  /// Text handed to `MorseEncoder` to play this entry.
  final String playText;

  final String? meaning;
  final String? mnemonic;

  /// 1-based position for Koch-order entries.
  final int? position;

  /// Stable id used by the playback controller.
  String get id => '${section.name}:$label';

  /// Case-insensitive match over label, meaning, mnemonic, and the pattern in
  /// both raw and display forms.
  bool matches(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (label.toLowerCase().contains(q)) return true;
    if (pattern.contains(q) || displayMorsePattern(pattern).contains(q)) {
      return true;
    }
    final String? m = meaning;
    if (m != null && m.toLowerCase().contains(q)) return true;
    final String? n = mnemonic;
    return n != null && n.toLowerCase().contains(q);
  }
}

/// Builds and caches the entries of every section.
abstract final class ReferenceCatalog {
  static final RegExp _alnum = RegExp(r'^[A-Z0-9]$');

  static const Map<String, String> _prosignMeanings = <String, String>{
    'AR': 'End of message.',
    'SK': 'End of contact (silent key).',
    'BT': 'Break / new paragraph.',
    'KN': 'Go ahead, named station only.',
    'AS': 'Wait / stand by.',
    'SN': 'Understood.',
    'SOS': 'Distress.',
    'CT': 'Start of transmission (attention).',
    'HH': 'Error; the last word will be repeated.',
  };

  static final List<ReferenceEntry> alphabet = <ReferenceEntry>[
    for (final MapEntry<String, String> e in MorseAlphabet.international.entries)
      if (_alnum.hasMatch(e.key))
        ReferenceEntry(
          section: ReferenceSection.alphabet,
          label: e.key,
          pattern: e.value,
          playText: e.key,
          mnemonic: ReferenceMnemonics.forCharacter(e.key, e.value),
        ),
  ];

  static final List<ReferenceEntry> punctuation = <ReferenceEntry>[
    for (final MapEntry<String, String> e in MorseAlphabet.international.entries)
      if (!_alnum.hasMatch(e.key))
        ReferenceEntry(
          section: ReferenceSection.punctuation,
          label: e.key,
          pattern: e.value,
          playText: e.key,
          meaning: _punctuationName(e.key),
          mnemonic: ReferenceMnemonics.forCharacter(e.key, e.value),
        ),
  ];

  static final List<ReferenceEntry> prosigns = <ReferenceEntry>[
    for (final MapEntry<String, String> e in MorseAlphabet.prosigns.entries)
      ReferenceEntry(
        section: ReferenceSection.prosigns,
        label: '<${e.key}>',
        pattern: e.value,
        playText: '<${e.key}>',
        meaning: _prosignMeanings[e.key],
        mnemonic: '<${e.key}>: ${ReferenceMnemonics.spokenRhythm(e.value)}',
      ),
  ];

  static final List<ReferenceEntry> qCodes = <ReferenceEntry>[
    for (final MapEntry<String, String> e in ReferenceQCodes.meanings.entries)
      ReferenceEntry(
        section: ReferenceSection.qCodes,
        label: e.key,
        pattern: MorseEncoder.toPattern(e.key),
        playText: e.key,
        meaning: e.value,
      ),
  ];

  static final List<ReferenceEntry> abbreviations = <ReferenceEntry>[
    for (final String name in ReferenceAbbreviations.names)
      ReferenceEntry(
        section: ReferenceSection.abbreviations,
        label: name,
        pattern: MorseEncoder.toPattern(name),
        playText: name,
        meaning: ReferenceAbbreviations.meaningOf(name),
      ),
  ];

  static final List<ReferenceEntry> koch = <ReferenceEntry>[
    for (int i = 0; i < MorseAlphabet.kochOrder.length; i++)
      _kochEntry(i + 1, MorseAlphabet.kochOrder[i]),
  ];

  static ReferenceEntry _kochEntry(int position, String symbol) {
    final String pattern = MorseEncoder.toPattern(symbol);
    final bool isProsign = symbol.startsWith('<');
    return ReferenceEntry(
      section: ReferenceSection.koch,
      label: symbol,
      pattern: pattern,
      playText: symbol,
      position: position,
      meaning: isProsign
          ? _prosignMeanings[symbol.substring(1, symbol.length - 1)]
          : _punctuationName(symbol),
      mnemonic: isProsign
          ? '$symbol: ${ReferenceMnemonics.spokenRhythm(pattern)}'
          : ReferenceMnemonics.forCharacter(symbol, pattern),
    );
  }

  static List<ReferenceEntry> entriesFor(ReferenceSection section) =>
      switch (section) {
        ReferenceSection.alphabet => alphabet,
        ReferenceSection.punctuation => punctuation,
        ReferenceSection.prosigns => prosigns,
        ReferenceSection.qCodes => qCodes,
        ReferenceSection.abbreviations => abbreviations,
        ReferenceSection.koch => koch,
      };

  /// Every entry of every section, in display order.
  static List<ReferenceEntry> get all => <ReferenceEntry>[
    for (final ReferenceSection s in ReferenceSection.values) ...entriesFor(s),
  ];

  /// Entries matching [query], grouped by section; sections with no match
  /// are omitted. An empty query returns everything.
  static Map<ReferenceSection, List<ReferenceEntry>> search(String query) {
    final Map<ReferenceSection, List<ReferenceEntry>> out =
        <ReferenceSection, List<ReferenceEntry>>{};
    for (final ReferenceSection s in ReferenceSection.values) {
      final List<ReferenceEntry> hits = entriesFor(s)
          .where((ReferenceEntry e) => e.matches(query))
          .toList(growable: false);
      if (hits.isNotEmpty) out[s] = hits;
    }
    return out;
  }

  static String? _punctuationName(String ch) => switch (ch) {
    '.' => 'Period (full stop)',
    ',' => 'Comma',
    '?' => 'Question mark',
    "'" => 'Apostrophe',
    '!' => 'Exclamation mark',
    '/' => 'Slash (fraction bar)',
    '(' => 'Open parenthesis',
    ')' => 'Close parenthesis',
    '&' => 'Ampersand (wait)',
    ':' => 'Colon',
    ';' => 'Semicolon',
    '=' => 'Equals (break, BT)',
    '+' => 'Plus (end of message, AR)',
    '-' => 'Hyphen / minus',
    '_' => 'Underscore',
    '"' => 'Quotation mark',
    r'$' => 'Dollar sign',
    '@' => 'At sign',
    _ => null,
  };
}
