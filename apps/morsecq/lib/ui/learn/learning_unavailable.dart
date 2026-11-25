import 'package:flutter/widgets.dart';
import 'package:morse_trainer/morse_trainer.dart';
import '../../i18n/l10n_extension.dart';

bool learningRetryable(BuildContext context) => true;
String learningUnavailableText(BuildContext context, [Object? error]) =>
    error is UnsupportedDataVersion
    ? context.s.learnNewerData
    : context.s.learnStorageUnavailable;
