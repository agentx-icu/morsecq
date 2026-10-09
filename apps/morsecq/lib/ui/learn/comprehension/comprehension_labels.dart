import 'package:flutter/widgets.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';

String comprehensionModeLabel(BuildContext context, ListeningMode mode) {
  final s = context.s;
  return switch (mode) {
    ListeningMode.words => s.comprehensionWords,
    ListeningMode.phrases => s.comprehensionPhrases,
    ListeningMode.qso => s.comprehensionQso,
    ListeningMode.pota => s.comprehensionPota,
    ListeningMode.story => s.comprehensionStory,
  };
}

String comprehensionModeHelp(BuildContext context, ListeningMode mode) {
  final s = context.s;
  return switch (mode) {
    ListeningMode.words => s.comprehensionWordsHelp,
    ListeningMode.phrases => s.comprehensionPhrasesHelp,
    ListeningMode.qso => s.comprehensionQsoHelp,
    ListeningMode.pota => s.comprehensionPotaHelp,
    ListeningMode.story => s.comprehensionStoryHelp,
  };
}

String comprehensionFieldLabel(BuildContext context, ListeningField field) {
  final s = context.s;
  return switch (field) {
    ListeningField.answer => s.comprehensionAnswer,
    ListeningField.callsign => s.comprehensionCallsign,
    ListeningField.otherCallsign => s.comprehensionOtherCallsign,
    ListeningField.name => s.comprehensionName,
    ListeningField.qth => s.comprehensionQth,
    ListeningField.rst => s.comprehensionRst,
    ListeningField.park => s.comprehensionPark,
    ListeningField.person => s.comprehensionPerson,
    ListeningField.destination => s.comprehensionDestination,
    ListeningField.time => s.comprehensionTime,
    ListeningField.action => s.comprehensionAction,
  };
}
