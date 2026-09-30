import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/account/account_widgets.dart';
import 'package:morsecq/ui/account/password_strength.dart';

void main() {
  test('ratePassword buckets by length and character classes', () {
    expect(ratePassword(''), PasswordStrength.empty);
    expect(ratePassword('short'), PasswordStrength.weak);
    expect(ratePassword('1234567'), PasswordStrength.weak);
    expect(ratePassword('12345678'), PasswordStrength.fair);
    expect(ratePassword('correct horse'), PasswordStrength.fair);
    expect(ratePassword('Correct-horse-9'), PasswordStrength.strong);
    expect(ratePassword('abcdefghijklmnop'), PasswordStrength.fair);
  });

  test('labels exist for every non-empty bucket', () {
    for (final s in PasswordStrength.values) {
      expect(s.label.isEmpty, s == PasswordStrength.empty);
    }
  });

  test('groupToxId splits into 4-char groups', () {
    expect(groupToxId('ABCDEFGHIJ'), 'ABCD EFGH IJ');
    expect(groupToxId(''), '');
  });
}
