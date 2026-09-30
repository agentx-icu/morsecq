import 'account_strings.dart';

/// Coarse password strength for the create / change-password hints. Not a
/// security boundary — it only nudges users away from trivially short
/// passwords for a file that never leaves their device unencrypted.
enum PasswordStrength {
  empty,
  weak,
  fair,
  strong;

  String get label => switch (this) {
    PasswordStrength.empty => '',
    PasswordStrength.weak => AccountStrings.strengthWeak,
    PasswordStrength.fair => AccountStrings.strengthFair,
    PasswordStrength.strong => AccountStrings.strengthStrong,
  };
}

/// Minimum length before a password stops being [PasswordStrength.weak].
const int kMinPasswordLength = 8;

PasswordStrength ratePassword(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  if (password.length < kMinPasswordLength) return PasswordStrength.weak;
  var classes = 0;
  if (password.contains(RegExp('[a-z]'))) classes++;
  if (password.contains(RegExp('[A-Z]'))) classes++;
  if (password.contains(RegExp('[0-9]'))) classes++;
  if (password.contains(RegExp(r'[^A-Za-z0-9]'))) classes++;
  if (password.length >= 12 && classes >= 3) return PasswordStrength.strong;
  return PasswordStrength.fair;
}
