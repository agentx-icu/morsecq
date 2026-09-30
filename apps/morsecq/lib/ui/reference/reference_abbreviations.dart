import 'package:flutter/widgets.dart' show Locale;
import 'package:morse_trainer/morse_trainer.dart';

import 'reference_localized_text.dart';

/// CW abbreviations with meanings.
///
/// The word list the trainer drills with (`WordLists.cwAbbreviations`) is
/// the backbone so the reference and the drills never disagree; this table
/// adds the meaning for each of those and a few more that are common on the
/// air. A test asserts every drilled abbreviation has a meaning here.
///
/// Meanings are given per language (see [kReferenceLanguages]).
abstract final class ReferenceAbbreviations {
  static const Map<String, Map<String, String>> meanings =
      <String, Map<String, String>>{
    'CQ': {'en': 'Calling any station.', 'zh': '呼叫任意电台。'},
    'DE': {
      'en': 'From (precedes the sender\'s call sign).',
      'zh': '来自（后接发送方呼号）。',
    },
    'K': {'en': 'Go ahead, any station.', 'zh': '请讲，任何电台均可回答。'},
    'KN': {'en': 'Go ahead, named station only.', 'zh': '请讲，仅限被呼叫的电台。'},
    '73': {'en': 'Best regards.', 'zh': '致以问候 / 祝好。'},
    '88': {'en': 'Love and kisses.', 'zh': '爱与吻。'},
    'TU': {'en': 'Thank you.', 'zh': '谢谢。'},
    'AGN': {'en': 'Again.', 'zh': '再来一遍。'},
    'ANT': {'en': 'Antenna.', 'zh': '天线。'},
    'BK': {
      'en': 'Break; back to you (quick turnover).',
      'zh': '插入；交回给你（快速换手）。',
    },
    'BTU': {'en': 'Back to you.', 'zh': '交回给你。'},
    'CUL': {'en': 'See you later.', 'zh': '回见。'},
    'ES': {'en': 'And.', 'zh': '和。'},
    'FB': {'en': 'Fine business (excellent).', 'zh': '很棒（Fine business）。'},
    'GA': {'en': 'Good afternoon.', 'zh': '下午好。'},
    'GE': {'en': 'Good evening.', 'zh': '晚上好。'},
    'GM': {'en': 'Good morning.', 'zh': '早上好。'},
    'HR': {'en': 'Here.', 'zh': '这里。'},
    'HW': {'en': 'How do you copy?', 'zh': '抄收如何？'},
    'NR': {'en': 'Number.', 'zh': '号码 / 数字。'},
    'OM': {'en': 'Old man (any male operator).', 'zh': '老兄（对男性报务员的称呼）。'},
    'PSE': {'en': 'Please.', 'zh': '请。'},
    'PWR': {'en': 'Power.', 'zh': '功率。'},
    'R': {'en': 'Roger / received.', 'zh': '收到 / 明白。'},
    'RIG': {'en': 'Station equipment.', 'zh': '电台设备。'},
    'RST': {
      'en': 'Signal report: readability, strength, tone.',
      'zh': '信号报告：可辨度、强度、音调。',
    },
    'SRI': {'en': 'Sorry.', 'zh': '抱歉。'},
    'TNX': {'en': 'Thanks.', 'zh': '谢谢。'},
    'UR': {'en': 'Your / you are.', 'zh': '你的 / 你是。'},
    'WX': {'en': 'Weather.', 'zh': '天气。'},
    'XYL': {'en': 'Wife (ex-young lady).', 'zh': '太太（ex-young lady）。'},
    'YL': {'en': 'Young lady (female operator).', 'zh': '女士（女性报务员）。'},
    // Not drilled, but common.
    'ABT': {'en': 'About.', 'zh': '关于 / 大约。'},
    'ADR': {'en': 'Address.', 'zh': '地址。'},
    'B4': {'en': 'Before.', 'zh': '之前。'},
    'C': {'en': 'Yes / correct.', 'zh': '是 / 正确。'},
    'CFM': {'en': 'Confirm.', 'zh': '确认。'},
    'CPI': {'en': 'Copy.', 'zh': '抄收。'},
    'CUD': {'en': 'Could.', 'zh': '能够（could）。'},
    'DX': {'en': 'Distant station.', 'zh': '远距离电台。'},
    'GB': {'en': 'Goodbye.', 'zh': '再见。'},
    'GN': {'en': 'Good night.', 'zh': '晚安。'},
    'GND': {'en': 'Ground.', 'zh': '接地。'},
    'GUD': {'en': 'Good.', 'zh': '好。'},
    'HI': {'en': 'Laughter.', 'zh': '笑声。'},
    'HPE': {'en': 'Hope.', 'zh': '希望。'},
    'NW': {'en': 'Now.', 'zh': '现在。'},
    'OP': {'en': 'Operator.', 'zh': '报务员。'},
    'RPT': {'en': 'Repeat.', 'zh': '重复。'},
    'SIG': {'en': 'Signal.', 'zh': '信号。'},
    'TKS': {'en': 'Thanks.', 'zh': '谢谢。'},
    'TMW': {'en': 'Tomorrow.', 'zh': '明天。'},
    'VY': {'en': 'Very.', 'zh': '非常。'},
    'WKD': {'en': 'Worked.', 'zh': '已通联（worked）。'},
    'WUD': {'en': 'Would.', 'zh': '会（would）。'},
    '55': {'en': 'Good luck.', 'zh': '祝好运。'},
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

  /// Per-language meanings for [name]; empty when the table has none.
  static Map<String, String> meaningsOf(String name) =>
      meanings[name] ?? const <String, String>{};

  /// Meaning for [name] in [locale]'s language (English fallback), or an
  /// empty string when the table has none.
  static String meaningOf(String name, Locale locale) =>
      localizedReferenceText(meaningsOf(name), locale) ?? '';
}
