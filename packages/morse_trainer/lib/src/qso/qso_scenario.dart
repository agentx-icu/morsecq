import 'dart:math';

import '../callsign_drill.dart';
import '../word_lists.dart';

/// Offline exchanges from a first contact to intermediate CW practice.
enum QsoScenario {
  /// A first interactive exchange: callsigns, signal report and closing.
  shortExchange,

  /// The remote station calls CQ; the learner answers.
  respondToCq,

  /// The learner calls CQ; a remote station answers.
  callCq,

  /// A contest contact with reports, serials and a corrected serial.
  contestExchange,

  /// A park-to-park contact with reports and a corrected park reference.
  potaActivation;

  bool get isAdvanced => this == contestExchange || this == potaActivation;

  static QsoScenario parse(String? name) => values.firstWhere(
    (v) => v.name == name,
    orElse: () => QsoScenario.respondToCq,
  );
}

/// Learner-side stages, in order. Each stage waits for one accepted
/// transmission from the learner.
enum QsoStage {
  /// Call CQ with the local callsign (call-CQ scenario only).
  callCq,

  /// `{REMOTE} DE {LOCAL} K` (respond scenario only).
  callConfirm,

  /// RST, name and QTH (call-CQ: also the callsign pair).
  exchange,

  /// Acknowledge the remote's information: `R` plus the remote's name.
  confirmInfo,

  /// `73` and `<SK>`.
  closing,

  /// Finished.
  done;

  static QsoStage parse(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => QsoStage.done);
}

/// One station's controlled-vocabulary details.
final class QsoStation {
  const QsoStation({
    required this.callsign,
    required this.name,
    required this.qth,
    this.serialNumber = '001',
    this.parkReference = 'US-1234',
  });

  final String callsign;
  final String name;
  final String qth;
  final String serialNumber;
  final String parkReference;

  /// Park identifiers are sent without punctuation, retaining the full
  /// prefix and number; typed hyphen/slash forms are equivalent.
  String get parkOnAir => normalizePark(parkReference).replaceAll('-', '');

  static final RegExp _call = RegExp(r'^[A-Z0-9]{1,3}[0-9][A-Z0-9]{0,3}[A-Z]$');
  static final RegExp _word = RegExp(r'^[A-Z]{2,12}$');

  /// Whether [callsign] looks like an amateur callsign (format only; it does
  /// not claim the callsign exists).
  static bool isValidCallsign(String callsign) =>
      _call.hasMatch(callsign.trim().toUpperCase());

  /// Names and QTHs are single controlled-vocabulary words.
  static bool isValidWord(String word) =>
      _word.hasMatch(word.trim().toUpperCase());

  static bool isValidSerial(String value) =>
      RegExp(r'^[0-9]{1,4}$').hasMatch(value.trim()) &&
      (int.tryParse(value.trim()) ?? 0) > 0;

  static bool isValidPark(String value) => RegExp(
    r'^[A-Z]{1,3}[-/]?[0-9]{4,5}$',
  ).hasMatch(value.trim().toUpperCase());

  static String normalizePark(String value) {
    final compact = value.trim().toUpperCase().replaceAll(RegExp(r'[-/]'), '');
    final match = RegExp(r'^([A-Z]{1,3})([0-9]{4,5})$').firstMatch(compact);
    return match == null
        ? value.trim().toUpperCase()
        : '${match[1]}-${match[2]}';
  }

  QsoStation normalized() => QsoStation(
    callsign: callsign.trim().toUpperCase(),
    name: name.trim().toUpperCase(),
    qth: qth.trim().toUpperCase(),
    serialNumber: serialNumber.trim().padLeft(3, '0'),
    parkReference: normalizePark(parkReference),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'callsign': callsign,
    'name': name,
    'qth': qth,
    'serialNumber': serialNumber,
    'parkReference': parkReference,
  };

  factory QsoStation.fromJson(Map<String, Object?> json) => QsoStation(
    callsign: json['callsign']! as String,
    name: json['name']! as String,
    qth: json['qth']! as String,
    serialNumber: json['serialNumber'] as String? ?? '001',
    parkReference: json['parkReference'] as String? ?? 'US-1234',
  );

  /// A random but seed-stable station; QTHs are single words.
  factory QsoStation.random(Random random) {
    final qths = WordLists.qthNames.where((q) => !q.contains(' ')).toList();
    String call;
    do {
      call = CallsignDrill(count: 1).nextCallsign(random);
    } while (!isValidCallsign(call));
    return QsoStation(
      callsign: call,
      name: WordLists
          .operatorNames[random.nextInt(WordLists.operatorNames.length)],
      qth: qths[random.nextInt(qths.length)],
      serialNumber: (1 + random.nextInt(998)).toString().padLeft(3, '0'),
      parkReference: 'US-${1000 + random.nextInt(8999)}',
    );
  }
}

/// The remote station's scripted transmissions. Templates are complete
/// text snapshots; the session fills them once per seed so every repeat is
/// identical.
abstract final class QsoScript {
  static const int version = 2;

  /// Signal reports the remote may give.
  static const List<String> remoteReports = <String>[
    '599',
    '579',
    '589',
    '559',
    '5NN',
  ];

  static List<QsoStage> stagesFor(QsoScenario scenario) => switch (scenario) {
    QsoScenario.shortExchange => const <QsoStage>[
      QsoStage.callConfirm,
      QsoStage.exchange,
      QsoStage.closing,
    ],
    QsoScenario.respondToCq => const <QsoStage>[
      QsoStage.callConfirm,
      QsoStage.exchange,
      QsoStage.confirmInfo,
      QsoStage.closing,
    ],
    QsoScenario.callCq => const <QsoStage>[
      QsoStage.callCq,
      QsoStage.exchange,
      QsoStage.confirmInfo,
      QsoStage.closing,
    ],
    QsoScenario.contestExchange ||
    QsoScenario.potaActivation => const <QsoStage>[
      QsoStage.callConfirm,
      QsoStage.exchange,
      QsoStage.confirmInfo,
      QsoStage.closing,
    ],
  };

  /// What the remote sends before the learner's [stage] (null: the learner
  /// opens, as when calling CQ).
  static String? remoteBefore(
    QsoScenario scenario,
    QsoStage stage, {
    required QsoStation local,
    required QsoStation remote,
    required String report,
  }) {
    final l = local.callsign;
    final r = remote.callsign;
    switch ((scenario, stage)) {
      case (QsoScenario.contestExchange, QsoStage.callConfirm):
        return 'CQ TEST DE $r $r K';
      case (QsoScenario.contestExchange, QsoStage.exchange):
        final preliminary = (int.parse(remote.serialNumber) % 999 + 1)
            .toString()
            .padLeft(3, '0');
        return '$l DE $r UR RST $report NR $preliminary $preliminary K';
      case (QsoScenario.contestExchange, QsoStage.confirmInfo):
        return '$l DE $r R CORR NR ${remote.serialNumber} '
            '${remote.serialNumber} CFM? K';
      case (QsoScenario.potaActivation, QsoStage.callConfirm):
        return 'CQ POTA DE $r $r K';
      case (QsoScenario.potaActivation, QsoStage.exchange):
        final compact = remote.parkOnAir;
        final preliminary =
            '${compact.substring(0, compact.length - 1)}'
            '${(int.parse(compact[compact.length - 1]) + 1) % 10}';
        return '$l DE $r UR RST $report PARK $preliminary K';
      case (QsoScenario.potaActivation, QsoStage.confirmInfo):
        return '$l DE $r R CORR PARK ${remote.parkOnAir} '
            '${remote.parkOnAir} CFM? K';
      case (QsoScenario.contestExchange, QsoStage.closing):
        return 'QSL TU $l DE $r 73';
      case (QsoScenario.potaActivation, QsoStage.closing):
        return 'QSL TNX P2P 73 $l DE $r <SK>';
      case (QsoScenario.shortExchange, QsoStage.callConfirm):
        return 'CQ CQ DE $r $r K';
      case (QsoScenario.shortExchange, QsoStage.exchange):
        return '$l DE $r UR RST $report K';
      case (QsoScenario.shortExchange, QsoStage.closing):
        return 'R TU 73 $l DE $r <SK>';
      case (QsoScenario.respondToCq, QsoStage.callConfirm):
        return 'CQ CQ CQ DE $r $r K';
      case (QsoScenario.respondToCq, QsoStage.exchange):
        return '$l DE $r GM TNX FER CALL UR RST $report $report '
            'NAME ${remote.name} ${remote.name} QTH ${remote.qth} '
            '${remote.qth} HW? $l DE $r K';
      case (QsoScenario.callCq, QsoStage.callCq):
        return null;
      case (QsoScenario.callCq, QsoStage.exchange):
        return '$l DE $r $r K';
      case (_, QsoStage.confirmInfo):
        final intro = scenario == QsoScenario.callCq
            ? 'R R TNX ${local.name} UR RST $report $report NAME '
                  '${remote.name} ${remote.name} QTH ${remote.qth} '
                  '${remote.qth}'
            : 'R R FB ${local.name} TNX FER RPRT';
        return '$l DE $r $intro QSL? $l DE $r K';
      case (_, QsoStage.closing):
        return 'R TU ${local.name} TNX QSO 73 $l DE $r <SK>';
      case (_, QsoStage.done):
        return 'TU 73 EE';
      default:
        return null;
    }
  }
}
