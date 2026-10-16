import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

void main() {
  test('every issue kind has its own English diagnostic with the counts', () {
    final Set<String> seen = <String>{};
    for (final SendIssueKind kind in SendIssueKind.values) {
      final SendIssue issue = SendIssue(
        kind: kind,
        severity: SendSeverity.moderate,
        offending: 3,
        total: 7,
        meanRatio: 1.234,
      );
      final String text = issue.describe();
      expect(seen.add(text), isTrue, reason: '$kind repeats another text');
      expect(text, contains('1.23'), reason: '$kind shows the ratio');
      if (kind != SendIssueKind.speedUnsteady) {
        expect(text, startsWith('3 of 7 '), reason: '$kind');
      }
      expect(issue.toString(), contains(kind.name));
      expect(issue.toString(), contains('moderate'));
      expect(issue.toString(), contains(text));
    }
  });
}
