/// The four meanings needed before a first interactive CW exchange.
enum QsoProtocolConcept {
  generalCall('CQ'),
  fromStation('DE'),
  signalReport('RST'),
  bestRegards('73');

  const QsoProtocolConcept(this.token);
  final String token;
}

/// One independent understanding exercise. Each concept is answered once;
/// feedback appears afterward and cannot replace an incorrect first answer.
/// Retrying creates a new attempt with a new id.
final class QsoProtocolAttempt {
  QsoProtocolAttempt({required this.id, required this.at});

  static const String drillKind = 'qso-protocol';
  static const String passedSourceRef = 'protocol:4/4:firstTry=true';

  final String id;
  final DateTime at;
  final List<QsoProtocolConcept> _answers = [];

  int get answered => _answers.length;
  int get total => QsoProtocolConcept.values.length;
  bool get completed => answered == total;
  QsoProtocolConcept? get current =>
      completed ? null : QsoProtocolConcept.values[answered];
  int get correct => [
    for (var i = 0; i < answered; i++)
      if (_answers[i] == QsoProtocolConcept.values[i]) i,
  ].length;
  bool get passed => completed && correct == total;
  String get sourceRef => 'protocol:$correct/$total:firstTry=$passed';

  /// Returns whether this first answer is right. Completed attempts cannot
  /// be answered again or earn a different result.
  bool answer(QsoProtocolConcept meaning) {
    final expected = current;
    if (expected == null) return false;
    _answers.add(meaning);
    return meaning == expected;
  }

  /// Text snapshots for activity scoring, never copying statistics. Tokens
  /// represent meanings chosen, so wrong concepts do not compare as correct.
  String get targetText =>
      QsoProtocolConcept.values.take(answered).map((c) => c.token).join(' ');
  String get answerText => _answers.map((c) => c.token).join(' ');
}
