import 'qso_scenario.dart';

/// What a learner transmission means, recognised before field validation.
enum QsoIntent {
  /// `AGN` / `PSE AGN` (optional `?`): repeat the remote's last text.
  repeat,

  /// `QRS` / `PSE QRS`: send slower.
  slowDown,

  /// A field answer for the current stage.
  answer,
}

/// Information which has already been heard and can be repeated alone.
enum QsoRepeatField {
  call('CALL'),
  rst('RST'),
  name('NAME'),
  qth('QTH'),
  serial('NR'),
  park('PARK');

  const QsoRepeatField(this.keyword);
  final String keyword;
}

/// Why an answer was not accepted. The app localises each.
enum QsoIssue {
  empty,
  missingCq,
  missingDe,
  wrongLocalCall,
  wrongRemoteCall,
  reversedCalls,
  missingEnding,
  missingRst,
  invalidRst,
  missingName,
  wrongName,
  missingQth,
  wrongQth,
  missingAck,
  wrongRemoteName,
  missing73,
  missingSk,
  missingSerial,
  invalidSerial,
  wrongSerial,
  missingPark,
  invalidPark,
  wrongPark,
  wrongRemoteRst,
}

/// Result of evaluating one transmission against a stage.
final class QsoEvaluation {
  const QsoEvaluation(
    this.intent, [
    this.issues = const <QsoIssue>[],
    this.repeatField,
  ]);

  final QsoIntent intent;
  final List<QsoIssue> issues;
  final QsoRepeatField? repeatField;

  bool get accepted => intent == QsoIntent.answer && issues.isEmpty;
}

/// Slot-based semantic evaluation (functional spec §5.3). It validates the
/// fields a stage needs and tolerates courtesy words around them; it never
/// relies on substring presence and does not claim language understanding.
abstract final class QsoEvaluator {
  /// Upper-cased words with prosign look-alikes mapped in context: `(` is
  /// `<KN>` and `+` is `<AR>` (the decoder reads those prosigns as
  /// punctuation), a trailing `?` is split off.
  static List<String> words(String text) {
    final out = <String>[];
    // A keyed prosign is one symbol even without a word gap around it
    // (`73<SK>`): split it into its own word before slot matching.
    final spaced = text.toUpperCase().replaceAllMapped(
      RegExp(r'<[A-Z]+>'),
      (m) => ' ${m[0]} ',
    );
    for (final raw in spaced.split(RegExp(r'\s+'))) {
      if (raw.isEmpty) continue;
      var w = raw;
      if (w.length > 1 && w.endsWith('?')) {
        out.add(w.substring(0, w.length - 1));
        out.add('?');
        continue;
      }
      w = switch (w) {
        '(' => '<KN>',
        '+' => '<AR>',
        _ => w,
      };
      out.add(w);
    }
    return out;
  }

  static QsoIntent intentOf(List<String> w) {
    final core = w.where((x) => x != '?').toList();
    if (core.isEmpty) return QsoIntent.answer;
    final last = core.last;
    final pse = core.length == 2 && core.first == 'PSE';
    if ((core.length == 1 || pse) && last == 'AGN') return QsoIntent.repeat;
    if ((core.length == 1 || pse) && last == 'QRS') return QsoIntent.slowDown;
    if (_repeatField(w) != null) return QsoIntent.repeat;
    return QsoIntent.answer;
  }

  static QsoRepeatField? _repeatField(List<String> w) {
    if (!w.contains('?')) return null;
    final core = w.where((x) => x != '?' && x != 'PSE' && x != 'AGN').toList();
    if (core.length != 1) return null;
    for (final field in QsoRepeatField.values) {
      if (field.keyword == core.single) return field;
    }
    return null;
  }

  static QsoEvaluation evaluate(
    String text, {
    required QsoStage stage,
    required QsoScenario scenario,
    required QsoStation local,
    required QsoStation remote,
    String? remoteReport,
  }) {
    final w = words(text);
    if (w.isEmpty) {
      return const QsoEvaluation(QsoIntent.answer, [QsoIssue.empty]);
    }
    final intent = intentOf(w);
    if (intent != QsoIntent.answer) {
      return QsoEvaluation(intent, const [], _repeatField(w));
    }
    final issues = <QsoIssue>[];
    switch (stage) {
      case QsoStage.callCq:
        _checkCq(w, local, issues);
      case QsoStage.callConfirm:
        _checkCalls(w, local, remote, issues);
        _checkEnding(w, issues);
      case QsoStage.exchange:
        if (scenario == QsoScenario.callCq) {
          _checkCalls(w, local, remote, issues);
        }
        _checkRst(w, issues);
        if (scenario.isAdvanced) {
          if (w.contains('DE')) _checkCalls(w, local, remote, issues);
          if (scenario == QsoScenario.contestExchange) {
            _checkSerial(w, local.serialNumber, issues);
          } else {
            _checkPark(w, local.parkReference, issues);
          }
          _checkEnding(w, issues);
          break;
        }
        if (scenario == QsoScenario.shortExchange) {
          _checkEnding(w, issues);
          break;
        }
        _checkField(
          w,
          'NAME',
          local.name,
          QsoIssue.missingName,
          QsoIssue.wrongName,
          issues,
        );
        _checkField(
          w,
          'QTH',
          local.qth,
          QsoIssue.missingQth,
          QsoIssue.wrongQth,
          issues,
        );
      case QsoStage.confirmInfo:
        if (scenario.isAdvanced) {
          _checkAckWord(w, issues);
          _checkRst(w, issues);
          final value = _fieldValue(w, 'RST');
          if (value != null &&
              remoteReport != null &&
              normalizeRst(value) != normalizeRst(remoteReport)) {
            issues.add(QsoIssue.wrongRemoteRst);
          }
          if (scenario == QsoScenario.contestExchange) {
            _checkSerial(w, remote.serialNumber, issues);
          } else {
            _checkPark(w, remote.parkReference, issues);
          }
          _checkEnding(w, issues);
        } else {
          _checkAck(w, remote, issues);
        }
      case QsoStage.closing:
        if (!w.contains('73')) issues.add(QsoIssue.missing73);
        if (scenario != QsoScenario.contestExchange && !w.contains('<SK>')) {
          issues.add(QsoIssue.missingSk);
        }
      case QsoStage.done:
        break;
    }
    return QsoEvaluation(QsoIntent.answer, issues);
  }

  static void _checkCq(List<String> w, QsoStation local, List<QsoIssue> out) {
    final de = w.indexOf('DE');
    if (de < 0) {
      if (!w.contains('CQ')) out.add(QsoIssue.missingCq);
      out.add(QsoIssue.missingDe);
      return;
    }
    if (!w.sublist(0, de).contains('CQ')) out.add(QsoIssue.missingCq);
    // After DE: the local call (repeated as often as liked) plus listed
    // courtesy words; any other word is a wrong (or malformed) call.
    final after = w.sublist(de + 1).where((x) => !_courtesy.contains(x));
    if (after.isEmpty || after.any((x) => x != local.callsign)) {
      out.add(QsoIssue.wrongLocalCall);
    }
    if (w.last != 'K') out.add(QsoIssue.missingEnding);
  }

  /// `{REMOTE} DE {LOCAL}`, distinguishing reversed roles and which side is
  /// wrong.
  static void _checkCalls(
    List<String> w,
    QsoStation local,
    QsoStation remote,
    List<QsoIssue> out,
  ) {
    final de = w.indexOf('DE');
    if (de <= 0 || de == w.length - 1) {
      out.add(QsoIssue.missingDe);
      return;
    }
    final before = w[de - 1];
    final after = w[de + 1];
    if (before == local.callsign && after == remote.callsign) {
      out.add(QsoIssue.reversedCalls);
      return;
    }
    if (before != remote.callsign) out.add(QsoIssue.wrongRemoteCall);
    if (after != local.callsign) out.add(QsoIssue.wrongLocalCall);
  }

  /// Courtesy words allowed around the callsign slot when calling CQ.
  static const Set<String> _courtesy = <String>{
    'PSE',
    'K',
    'KN',
    '<KN>',
    'AR',
    '<AR>',
    '<BT>',
    '?',
  };

  static void _checkEnding(List<String> w, List<QsoIssue> out) {
    const endings = {'K', 'KN', '<KN>'};
    if (!endings.contains(w.last)) out.add(QsoIssue.missingEnding);
  }

  /// RST after `RST` (`UR RST 599` or `RST 599`); cut numbers are only
  /// interpreted inside this slot.
  static void _checkRst(List<String> w, List<QsoIssue> out) {
    final at = w.indexOf('RST');
    if (at < 0 || at == w.length - 1) {
      out.add(QsoIssue.missingRst);
      return;
    }
    if (!isValidRst(w[at + 1])) out.add(QsoIssue.invalidRst);
  }

  /// Readability 1–5, strength 1–9, tone 1–9; `N` = 9 and `T` = 0 as cut
  /// numbers (so `5NN` is 599 and a cut `T` tone is out of range).
  static bool isValidRst(String report) {
    if (report.length != 3) return false;
    final digits = report
        .split('')
        .map(
          (c) => switch (c) {
            'N' => 9,
            'T' => 0,
            'A' => 1,
            'E' => 5,
            _ => int.tryParse(c),
          },
        )
        .toList();
    if (digits.any((d) => d == null)) return false;
    final r = digits[0]!;
    final s = digits[1]!;
    final t = digits[2]!;
    return r >= 1 && r <= 5 && s >= 1 && s <= 9 && t >= 1 && t <= 9;
  }

  static String normalizeRst(String value) => value
      .toUpperCase()
      .replaceAll('N', '9')
      .replaceAll('T', '0')
      .replaceAll('A', '1')
      .replaceAll('E', '5');

  static String? _fieldValue(List<String> w, String keyword) {
    final at = w.lastIndexOf(keyword);
    if (at < 0 || at + 1 >= w.length) return null;
    final value = w[at + 1] == 'IS' ? at + 2 : at + 1;
    return value < w.length ? w[value] : null;
  }

  static void _checkSerial(
    List<String> w,
    String expected,
    List<QsoIssue> out,
  ) {
    final value = _fieldValue(w, 'NR');
    if (value == null) {
      out.add(QsoIssue.missingSerial);
    } else if (!QsoStation.isValidSerial(value)) {
      out.add(QsoIssue.invalidSerial);
    } else if (int.parse(value) != int.parse(expected)) {
      out.add(QsoIssue.wrongSerial);
    }
  }

  static void _checkPark(List<String> w, String expected, List<QsoIssue> out) {
    final value = _fieldValue(w, 'PARK');
    if (value == null) {
      out.add(QsoIssue.missingPark);
    } else if (!QsoStation.isValidPark(value)) {
      out.add(QsoIssue.invalidPark);
    } else if (QsoStation.normalizePark(value) !=
        QsoStation.normalizePark(expected)) {
      out.add(QsoIssue.wrongPark);
    }
  }

  static void _checkField(
    List<String> w,
    String keyword,
    String expected,
    QsoIssue missing,
    QsoIssue wrong,
    List<QsoIssue> out,
  ) {
    final at = w.indexOf(keyword);
    if (at < 0) {
      out.add(missing);
      return;
    }
    var value = at + 1;
    if (value < w.length && w[value] == 'IS') value++;
    if (value >= w.length) {
      out.add(missing);
      return;
    }
    if (w[value] != expected) out.add(wrong);
  }

  static void _checkAck(List<String> w, QsoStation remote, List<QsoIssue> out) {
    _checkAckWord(w, out);
    if (!w.contains(remote.name)) out.add(QsoIssue.wrongRemoteName);
  }

  static void _checkAckWord(List<String> w, List<QsoIssue> out) {
    if (!w.contains('R') && !w.contains('QSL') && !w.contains('RR')) {
      out.add(QsoIssue.missingAck);
    }
  }
}
