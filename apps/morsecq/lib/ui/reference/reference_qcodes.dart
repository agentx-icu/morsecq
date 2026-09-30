import 'package:flutter/widgets.dart' show Locale;

import 'reference_localized_text.dart';

/// Q-codes commonly heard on CW, with the meaning in the form that suits
/// both the question (with `?`) and the statement.
///
/// Meanings are given per language (see [kReferenceLanguages]); the code
/// itself is language-neutral.
abstract final class ReferenceQCodes {
  /// Insertion order is display order: the everyday set first, then the
  /// rest alphabetically.
  static const Map<String, Map<String, String>> meanings =
      <String, Map<String, String>>{
    'QRL': {
      'en': 'Is the frequency in use? / The frequency is in use.',
      'zh': '频率是否有人使用？/ 频率正在使用中。',
    },
    'QRM': {
      'en': 'Interference from other stations (man-made).',
      'zh': '受到其他电台的干扰（人为干扰）。',
    },
    'QRN': {
      'en': 'Static / atmospheric noise.',
      'zh': '静电 / 天电噪声干扰。',
    },
    'QRO': {
      'en': 'Increase power / high power.',
      'zh': '请增大功率 / 大功率。',
    },
    'QRP': {
      'en': 'Reduce power / low power (5 W or less).',
      'zh': '请减小功率 / 小功率（5 W 及以下）。',
    },
    'QRQ': {
      'en': 'Send faster.',
      'zh': '请发快一点。',
    },
    'QRS': {
      'en': 'Send more slowly.',
      'zh': '请发慢一点。',
    },
    'QRT': {
      'en': 'Stop sending / I am closing down.',
      'zh': '停止发射 / 我要关机了。',
    },
    'QRU': {
      'en': 'Have you anything for me? / I have nothing for you.',
      'zh': '你有事找我吗？/ 我没有事找你。',
    },
    'QRV': {
      'en': 'Are you ready? / I am ready.',
      'zh': '你准备好了吗？/ 我已准备好。',
    },
    'QRX': {
      'en': 'Stand by; I will call you again at (time).',
      'zh': '请稍等；我将在（时间）再呼叫你。',
    },
    'QRZ': {
      'en': 'Who is calling me?',
      'zh': '谁在呼叫我？',
    },
    'QSB': {
      'en': 'Your signal is fading.',
      'zh': '你的信号有衰落。',
    },
    'QSL': {
      'en': 'Can you acknowledge? / I acknowledge receipt.',
      'zh': '你能确认收到吗？/ 我确认收到。',
    },
    'QSO': {
      'en': 'A contact; I can communicate with (station).',
      'zh': '一次通联；我能与（电台）通信。',
    },
    'QSY': {
      'en': 'Change to another frequency.',
      'zh': '换到另一个频率。',
    },
    'QTH': {
      'en': 'What is your location? / My location is (place).',
      'zh': '你的位置在哪里？/ 我的位置是（地点）。',
    },
    'QRA': {
      'en': 'The name of my station is (call).',
      'zh': '我的电台名称（呼号）是……。',
    },
    'QRG': {
      'en': 'Your exact frequency is (kHz).',
      'zh': '你的准确频率是（kHz）。',
    },
    'QRH': {
      'en': 'Your frequency varies.',
      'zh': '你的频率在漂移。',
    },
    'QRI': {
      'en': 'The tone of your transmission is (good / variable / bad).',
      'zh': '你发射的音调是（好 / 不稳 / 差）。',
    },
    'QRK': {
      'en': 'The readability of your signal is (1 to 5).',
      'zh': '你信号的可辨度是（1 至 5）。',
    },
    'QSA': {
      'en': 'The strength of your signal is (1 to 5).',
      'zh': '你信号的强度是（1 至 5）。',
    },
    'QSK': {
      'en': 'I can hear you between my signals; break in on my transmission.',
      'zh': '我能在自己信号的间隙听到你；可随时插入。',
    },
    'QSP': {
      'en': 'Will you relay to (station)? / I will relay.',
      'zh': '你能转发给（电台）吗？/ 我将转发。',
    },
    'QST': {
      'en': 'General call to all amateur stations.',
      'zh': '致所有业余电台的通告。',
    },
    'QSV': {
      'en': 'Send a series of Vs for tuning.',
      'zh': '请发一串 V 供调谐。',
    },
    'QSZ': {
      'en': 'Send each word or group twice.',
      'zh': '每个词或每组请发两遍。',
    },
    'QTC': {
      'en': 'I have (number) messages for you.',
      'zh': '我有（数量）份报文给你。',
    },
    'QTR': {
      'en': 'What is the correct time? / The correct time is (UTC).',
      'zh': '准确时间是多少？/ 准确时间是（UTC）。',
    },
  };

  static List<String> get codes => meanings.keys.toList(growable: false);

  /// Meaning of [code] in [locale]'s language (English fallback), or null
  /// for a code the table does not carry.
  static String? meaning(String code, Locale locale) {
    final Map<String, String>? row = meanings[code];
    return row == null ? null : localizedReferenceText(row, locale);
  }
}
