import 'package:morse_trainer/morse_trainer.dart';

/// CW abbreviations with meanings.
///
/// The word list the trainer drills with (`WordLists.cwAbbreviations`) is
/// the backbone so the reference and the drills never disagree; this table
/// adds the meaning for each of those and a few more that are common on the
/// air. A test asserts every drilled abbreviation has a meaning here.
abstract final class ReferenceAbbreviations {
  static const Map<String, String> meanings = <String, String>{
    'CQ': 'Calling any station.',
    'DE': 'From (precedes the sender\'s call sign).',
    'K': 'Go ahead, any station.',
    'KN': 'Go ahead, named station only.',
    '73': 'Best regards.',
    '88': 'Love and kisses.',
    'TU': 'Thank you.',
    'AGN': 'Again.',
    'ANT': 'Antenna.',
    'BK': 'Break; back to you (quick turnover).',
    'BTU': 'Back to you.',
    'CUL': 'See you later.',
    'ES': 'And.',
    'FB': 'Fine business (excellent).',
    'GA': 'Good afternoon.',
    'GE': 'Good evening.',
    'GM': 'Good morning.',
    'HR': 'Here.',
    'HW': 'How do you copy?',
    'NR': 'Number.',
    'OM': 'Old man (any male operator).',
    'PSE': 'Please.',
    'PWR': 'Power.',
    'R': 'Roger / received.',
    'RIG': 'Station equipment.',
    'RST': 'Signal report: readability, strength, tone.',
    'SRI': 'Sorry.',
    'TNX': 'Thanks.',
    'UR': 'Your / you are.',
    'WX': 'Weather.',
    'XYL': 'Wife (ex-young lady).',
    'YL': 'Young lady (female operator).',
    // Not drilled, but common.
    'ABT': 'About.',
    'ADR': 'Address.',
    'B4': 'Before.',
    'C': 'Yes / correct.',
    'CFM': 'Confirm.',
    'CPI': 'Copy.',
    'CUD': 'Could.',
    'DX': 'Distant station.',
    'GB': 'Goodbye.',
    'GN': 'Good night.',
    'GND': 'Ground.',
    'GUD': 'Good.',
    'HI': 'Laughter.',
    'HPE': 'Hope.',
    'NW': 'Now.',
    'OP': 'Operator.',
    'RPT': 'Repeat.',
    'SIG': 'Signal.',
    'TKS': 'Thanks.',
    'TMW': 'Tomorrow.',
    'VY': 'Very.',
    'WKD': 'Worked.',
    'WUD': 'Would.',
    '55': 'Good luck.',
  };

  /// Display order: the trainer's list first (in its order), then the extra
  /// entries in table order, without duplicates.
  static List<String> get names {
    final List<String> out = <String>[];
    final Set<String> seen = <String>{};
    for (final String name in WordLists.cwAbbreviations) {
      if (seen.add(name)) out.add(name);
    }
    for (final String name in meanings.keys) {
      if (seen.add(name)) out.add(name);
    }
    return out;
  }

  /// Meaning for [name], or an empty string when the table has none.
  static String meaningOf(String name) => meanings[name] ?? '';
}
