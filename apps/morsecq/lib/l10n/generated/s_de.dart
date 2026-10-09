// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => 'Lernen';

  @override
  String get navMe => 'Ich';

  @override
  String get navReference => 'Nachschlagen';

  @override
  String get navLearnDescription => 'Lektionen nach der Koch-Methode, Gebeübungen und Hörtraining.';

  @override
  String get navReferenceDescription => 'Alphabet, Verkehrszeichen, Q-Gruppen, Abkürzungen und Übersetzung in beide Richtungen.';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemsprache';

  @override
  String get languageSaveFailed => 'Die Spracheinstellung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'Lektion $lesson von $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeichen gelernt',
      one: '$count Zeichen gelernt',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal Zeichen';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage in Folge',
      one: '$days Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wiederholungen fällig',
      one: '$count Wiederholung fällig',
      zero: 'Keine Wiederholung fällig',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$correct von $total richtig';
  }

  @override
  String learnRoundOf(int round) {
    return 'Runde $round';
  }

  @override
  String learnAccuracyPercent(int percent) {
    return '$percent%';
  }

  @override
  String learnCharsSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeichen gesendet',
      one: '$count Zeichen gesendet',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return 'Nächstes Zeichen freigeschaltet: $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target überhört';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target als $answered gehört';
  }

  @override
  String learnWpmValue(String wpm) {
    return '$wpm WPM';
  }

  @override
  String learnHzValue(String hz) {
    return '$hz Hz';
  }

  @override
  String learnCharsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeichen',
      one: '$count Zeichen',
    );
    return '$_temp0';
  }

  @override
  String statsLessonOf(int lesson, int total) {
    return '$lesson / $total';
  }

  @override
  String statsCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeichen gelernt',
      one: '$count Zeichen gelernt',
    );
    return '$_temp0';
  }

  @override
  String statsPercent(String percent) {
    return '$percent%';
  }

  @override
  String statsCharsCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeichen aufgenommen',
      one: '$count Zeichen aufgenommen',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Übungseinheiten',
      one: '$count Übungseinheit',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '$count Tag',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rekord: $count Tage',
      one: 'Rekord: $count Tag',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal Zeichen';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Noch $remaining Zeichen',
      one: 'Noch $remaining Zeichen',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Letzte $count Übungseinheiten',
      one: 'Letzte Übungseinheit',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return 'Übungseinheit $index von $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total richtig';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'Lektion $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versuche',
      one: '$count Versuch',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$correct von $attempts richtig';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'In Lektion $lesson eingeführt';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'Fach $box von $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $days Tagen fällig',
      one: 'Morgen fällig',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal',
      one: '$count-mal',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal',
      one: '$count-mal',
    );
    return '$target als $answered beantwortet, $_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars Zeichen',
      one: '$chars Zeichen',
      zero: 'Nicht geübt',
    );
    return '$date: $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Tage',
      one: '$count aktiver Tag',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '$count Eintrag',
    );
    return '$_temp0';
  }

  @override
  String referenceWpmValue(String wpm) {
    return '$wpm WPM';
  }

  @override
  String referenceHzValue(String hz) {
    return '$hz Hz';
  }

  @override
  String referenceSkippedChars(String chars) {
    return 'Übersprungen (kein Morsecode): $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Koch-Reihenfolge: $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return 'Geschätzt $wpm WPM';
  }

  @override
  String get accountSectionTraining => 'Training';

  @override
  String get accountSectionAbout => 'Über';

  @override
  String get accountTrainingDefaults => 'Standardwerte für Wiedergabe und Training';

  @override
  String get accountTrainingDefaultsSubtitle => 'Geschwindigkeit, Tonhöhe, Farnsworth-Abstände';

  @override
  String get accountAboutLicence => 'Lizenz';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Quellcode';

  @override
  String get accountAboutSourceCopied => 'Quellcode-Link kopiert';

  @override
  String get chatSend => 'Senden';

  @override
  String get learnLessonCardTitle => 'Koch-Lektion';

  @override
  String get learnCourseComplete => 'Kurs abgeschlossen – bleib dran!';

  @override
  String get learnDailyGoalTitle => 'Heute';

  @override
  String get learnDailyGoalMet => 'Tagesziel erreicht';

  @override
  String get learnNoStreak => 'Starte heute eine Serie';

  @override
  String get learnContinueLesson => 'Lektion fortsetzen';

  @override
  String get learnReceivePractice => 'Hörtraining';

  @override
  String get learnSendPractice => 'Gebetraining';

  @override
  String get learnReviewDue => 'Fällige Zeichen wiederholen';

  @override
  String get learnSettings => 'Trainingseinstellungen';

  @override
  String get learnLoading => 'Dein Fortschritt wird geladen…';

  @override
  String get learnLoadFailed => 'Dein gespeicherter Fortschritt konnte nicht gelesen werden. Du beginnst neu; die alte Datei wurde als .corrupt aufbewahrt.';

  @override
  String get learnProgressSaveFailed => 'Fortschritt konnte nicht gespeichert werden. Das Ergebnis zählt, solange MorseCQ geöffnet bleibt.';

  @override
  String get learnChooseDrill => 'Übung wählen';

  @override
  String get learnDrillGroups => 'Zufällige Gruppen';

  @override
  String get learnDrillWords => 'Wörter';

  @override
  String get learnDrillCallsigns => 'Rufzeichen';

  @override
  String get learnDrillQso => 'QSO';

  @override
  String get learnDrillCharacters => 'Einzelzeichen';

  @override
  String get learnDrillAbbreviations => 'Abkürzungen und Q-Gruppen';

  @override
  String get learnDrillNumbers => 'Zifferngruppen';

  @override
  String get learnDrillConfusables => 'Ähnliche Zeichen';

  @override
  String get learnDrillContest => 'Contest-Austausch';

  @override
  String get learnDrillGroupsHint => 'Zufällige Gruppen aus allen gelernten Buchstaben';

  @override
  String get learnDrillCharactersHint => 'Ein Zeichen nach dem anderen – sofort erkennen';

  @override
  String get learnDrillWordsHint => 'Häufige englische Wörter';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL – Kurzformen im Funkverkehr';

  @override
  String get learnDrillNumbersHint => 'Fünfstellige Gruppen, wie in Telegrammen und laufenden Nummern';

  @override
  String get learnDrillCallsignsHint => 'Amateurfunkrufzeichen aus aller Welt';

  @override
  String get learnDrillConfusablesHint => 'Verwechselte Zeichenpaare wie S/H oder U/V direkt vergleichen';

  @override
  String get learnDrillQsoHint => 'Zeilen aus einer vollständigen Funkverbindung';

  @override
  String get learnDrillContestHint => 'Rufzeichen, 5NN und laufende Nummer oder Zone im Contest-Tempo';

  @override
  String get learnDrillReviewHint => 'Zeichen, deren Wiederholung fällig ist';

  @override
  String get toolsTitle => 'Funkwerkzeuge';

  @override
  String get toolsGridTitle => 'Locator';

  @override
  String get toolsGridHint => 'Locator aus Koordinaten, Entfernung und Antennenrichtung';

  @override
  String get toolsBandsTitle => 'Bänder und Antennen';

  @override
  String get toolsBandsHint => 'Band einer Frequenz, Wellenlänge und Dipollänge';

  @override
  String get toolsSpeedTitle => 'CW-Geschwindigkeit';

  @override
  String get toolsSpeedHint => 'WPM in Punktlänge, Pausen und Zeichen pro Minute umrechnen';

  @override
  String get toolsRstTitle => 'RST-Rapport';

  @override
  String get toolsRstHint => 'Signalrapport erstellen und die Bedeutung jeder Ziffer ansehen';

  @override
  String get toolsClockTitle => 'UTC-Uhr';

  @override
  String get toolsClockHint => 'UTC-Zeit fürs Logbuch neben deiner Ortszeit';

  @override
  String get toolsGridFromCoordinates => 'Aus Koordinaten';

  @override
  String get toolsGridLatitude => 'Breitengrad';

  @override
  String get toolsGridLongitude => 'Längengrad';

  @override
  String get toolsGridCoordinatesHelp => 'Dezimalgrad; Süden und Westen sind negativ';

  @override
  String get toolsGridInvalidCoordinates => 'Breitengrad −90 bis 90, Längengrad −180 bis 180';

  @override
  String get toolsGridLocator => 'Locator';

  @override
  String get toolsGridDistanceSection => 'Entfernung und Richtung';

  @override
  String get toolsGridMine => 'Mein Locator';

  @override
  String get toolsGridTheirs => 'Locator der Gegenstation';

  @override
  String get toolsGridInvalidLocator => '2, 4, 6 oder 8 Zeichen, z. B. OM89ex';

  @override
  String get toolsGridCenter => 'Feldmitte';

  @override
  String get toolsGridDistance => 'Entfernung';

  @override
  String get toolsGridShortPath => 'Kurzweg-Richtung';

  @override
  String get toolsGridLongPath => 'Langweg-Richtung';

  @override
  String get toolsBandsFrequency => 'Frequenz (MHz)';

  @override
  String get toolsBandsInvalidFrequency => 'Gib eine Frequenz größer als 0 ein';

  @override
  String toolsBandsRegionLabel(int number) {
    return 'Region $number';
  }

  @override
  String get toolsBandsRegionHelp => '1: Europa, Afrika, Naher Osten – 2: Amerika – 3: Asien-Pazifik';

  @override
  String toolsBandsInBand(String band) {
    return 'Im Amateurband $band';
  }

  @override
  String get toolsBandsOutOfBand => 'Außerhalb der Amateurbänder';

  @override
  String get toolsBandsWavelength => 'Wellenlänge';

  @override
  String get toolsBandsDipole => 'Halbwellendipol (gesamt)';

  @override
  String get toolsBandsQuarterWave => 'Viertelwellenstrahler';

  @override
  String get toolsBandsAntennaNote => 'Längen mit Verkürzungsfaktor 0,95; auf Resonanz kürzen.';

  @override
  String get toolsBandsTable => 'Bandgrenzen';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'ITU-Zuweisungen. Deine Lizenz und der nationale Bandplan können enger sein.';

  @override
  String get toolsSpeedCharacter => 'Zeichengeschwindigkeit';

  @override
  String get toolsSpeedFarnsworth => 'Farnsworth-Abstände';

  @override
  String get toolsSpeedOverall => 'Gesamtgeschwindigkeit';

  @override
  String get toolsSpeedDit => 'Punkt';

  @override
  String get toolsSpeedDah => 'Strich';

  @override
  String get toolsSpeedCharGap => 'Zeichenpause';

  @override
  String get toolsSpeedWordGap => 'Wortpause';

  @override
  String get toolsSpeedCpm => 'Zeichen pro Minute';

  @override
  String get toolsSpeedParis => 'Ein PARIS-Wort';

  @override
  String get toolsRstReadability => 'Lesbarkeit (R)';

  @override
  String get toolsRstStrength => 'Signalstärke (S)';

  @override
  String get toolsRstTone => 'Tonqualität (T)';

  @override
  String get toolsRstReport => 'Rapport';

  @override
  String get toolsRstCut => 'Contest-Form';

  @override
  String get toolsRstPhone => 'Sprechfunk (ohne T)';

  @override
  String get toolsRstR1 => 'Nicht lesbar';

  @override
  String get toolsRstR2 => 'Kaum lesbar, einzelne Wörter';

  @override
  String get toolsRstR3 => 'Nur mit großer Mühe lesbar';

  @override
  String get toolsRstR4 => 'Fast mühelos lesbar';

  @override
  String get toolsRstR5 => 'Einwandfrei lesbar';

  @override
  String get toolsRstS1 => 'Schwach, kaum wahrnehmbar';

  @override
  String get toolsRstS2 => 'Sehr schwach';

  @override
  String get toolsRstS3 => 'Schwach';

  @override
  String get toolsRstS4 => 'Mäßig';

  @override
  String get toolsRstS5 => 'Ziemlich gut';

  @override
  String get toolsRstS6 => 'Gut';

  @override
  String get toolsRstS7 => 'Mäßig stark';

  @override
  String get toolsRstS8 => 'Stark';

  @override
  String get toolsRstS9 => 'Äußerst stark';

  @override
  String get toolsRstT1 => 'Sehr rau und breit, roher Wechselstromton';

  @override
  String get toolsRstT2 => 'Sehr rauer Wechselstromton, scharf und breit';

  @override
  String get toolsRstT3 => 'Rau, gleichgerichtet, aber ungefiltert';

  @override
  String get toolsRstT4 => 'Rau, mit geringer Filterung';

  @override
  String get toolsRstT5 => 'Gefiltert, aber stark durch Restwelligkeit moduliert';

  @override
  String get toolsRstT6 => 'Gefiltert, mit deutlicher Restwelligkeit';

  @override
  String get toolsRstT7 => 'Fast rein, mit geringer Restwelligkeit';

  @override
  String get toolsRstT8 => 'Nahezu perfekt, mit geringer Modulation';

  @override
  String get toolsRstT9 => 'Reiner Ton, ohne Restwelligkeit';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => 'Ortszeit';

  @override
  String get toolsClockNote => 'Logbücher und QSL-Karten verwenden UTC.';

  @override
  String get learnReceiveTitle => 'Empfangen';

  @override
  String get learnReviewTitle => 'Wiederholen';

  @override
  String get learnListen => 'Hören…';

  @override
  String get learnReady => 'Bereit';

  @override
  String get learnReplay => 'Erneut abspielen';

  @override
  String get learnAnswerHint => 'Gib ein, was du gehört hast';

  @override
  String get learnSubmit => 'Prüfen';

  @override
  String get learnNext => 'Weiter';

  @override
  String get learnFinish => 'Beenden';

  @override
  String get learnDone => 'Fertig';

  @override
  String get learnBackspace => 'Löschen';

  @override
  String get learnSpace => 'Leerzeichen';

  @override
  String get learnSent => 'Gesendet';

  @override
  String get learnYourCopy => 'Deine Mitschrift';

  @override
  String get learnRoundPerfect => 'Fehlerfrei aufgenommen!';

  @override
  String get learnSessionSummary => 'Übungsübersicht';

  @override
  String get learnLessonPassed => 'Lektion bestanden';

  @override
  String get learnLessonNotPassed => 'Bleib dran: 90 % schalten die nächste Lektion frei';

  @override
  String get learnReviewRecorded => 'Wiederholung gespeichert';

  @override
  String get learnWeakChars => 'Noch üben';

  @override
  String get learnConfusions => 'Verwechselt';

  @override
  String get learnNoFeedbackWarning => 'Ton, Blinken und Vibration sind ausgeschaltet – stattdessen blinkt der Bildschirm.';

  @override
  String get learnSendTitle => 'Senden';

  @override
  String get learnSendThis => 'Sende diesen Text';

  @override
  String get learnCopyFromMemory => 'Aus dem Gedächtnis';

  @override
  String get learnHiddenTarget => 'Verborgen – aus dem Gedächtnis morsen';

  @override
  String get learnDecoded => 'Decodiert';

  @override
  String get learnWaitingForKey => 'Beginne zu morsen, sobald du bereit bist';

  @override
  String get learnRestart => 'Neu starten';

  @override
  String get learnTryAnother => 'Anderen Text versuchen';

  @override
  String get learnKeyerStraight => 'Handtaste';

  @override
  String get learnKeyerIambicA => 'Iambic A';

  @override
  String get learnKeyerIambicB => 'Iambic B';

  @override
  String get learnLegendStraight => 'Leertaste = Taste';

  @override
  String get learnLegendPaddles => 'Linke Ctrl = Punkt, rechte Ctrl = Strich';

  @override
  String get learnSendClean => 'Sauber gegeben – nichts zu verbessern.';

  @override
  String get learnSendIssues => 'Hinweise zum Rhythmus';

  @override
  String get learnYourSending => 'Decodiert als';

  @override
  String get learnStraightKeyLabel => 'TASTE';

  @override
  String get learnDitLabel => 'PUNKT';

  @override
  String get learnDahLabel => 'STRICH';

  @override
  String get learnSettingsTitle => 'Trainingseinstellungen';

  @override
  String get learnCharacterSpeed => 'Zeichengeschwindigkeit';

  @override
  String get learnFarnsworth => 'Farnsworth-Abstände';

  @override
  String get learnFarnsworthHelp => 'Die Zeichen bleiben schnell; die Pausen dazwischen werden auf diese Geschwindigkeit verlängert.';

  @override
  String get learnEffectiveSpeed => 'Effektive Geschwindigkeit';

  @override
  String get learnTone => 'Tonhöhe';

  @override
  String get learnPlaySample => 'Beispiel abspielen';

  @override
  String get learnSessionLength => 'Übungslänge';

  @override
  String get learnFeedback => 'Rückmeldung';

  @override
  String get learnSound => 'Ton';

  @override
  String get learnFlash => 'Bildschirmblinken';

  @override
  String get learnHaptic => 'Vibration';

  @override
  String get learnKeyer => 'Morsetaste';

  @override
  String get learnDailyGoal => 'Tagesziel';

  @override
  String get referenceReferenceTitle => 'Morse-Nachschlagewerk';

  @override
  String get referenceTranslatorTitle => 'Übersetzer';

  @override
  String get referencePlay => 'Abspielen';

  @override
  String get referenceStop => 'Stoppen';

  @override
  String get referenceClear => 'Leeren';

  @override
  String get referenceClose => 'Schließen';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => 'Zeichen, Verkehrszeichen, Q-Gruppen suchen…';

  @override
  String get referenceClearSearch => 'Suche löschen';

  @override
  String get referenceNoResults => 'Keine passenden Suchergebnisse.';

  @override
  String get referenceSectionAlphabet => 'Alphabet';

  @override
  String get referenceSectionPunctuation => 'Satzzeichen';

  @override
  String get referenceSectionProsigns => 'Verkehrszeichen';

  @override
  String get referenceSectionQCodes => 'Q-Gruppen';

  @override
  String get referenceSectionAbbreviations => 'CW-Abkürzungen';

  @override
  String get referenceSectionKoch => 'Koch-Reihenfolge';

  @override
  String get referenceAlphabetHint => 'Tippe auf eine Karte, um sie zu hören. Halte sie gedrückt, um eine Merkhilfe anzuzeigen.';

  @override
  String get referenceKochHint => 'Die Reihenfolge, in der die Koch-Methode Zeichen einführt (LCWO-Abfolge). Beginne mit K und M; füge bei 90 % richtig aufgenommenen Zeichen ein weiteres hinzu.';

  @override
  String get referenceMnemonicTitle => 'Merkhilfe';

  @override
  String get referenceMeaningLabel => 'Bedeutung';

  @override
  String get referencePlaybackSettings => 'Wiedergabeeinstellungen';

  @override
  String get referenceCharacterSpeed => 'Zeichengeschwindigkeit';

  @override
  String get referenceFarnsworth => 'Farnsworth-Abstände';

  @override
  String get referenceFarnsworthHelp => 'Die Zeichen behalten ihre volle Geschwindigkeit; die Pausen werden für die effektive Geschwindigkeit verlängert.';

  @override
  String get referenceEffectiveSpeed => 'Effektive Geschwindigkeit';

  @override
  String get referenceTone => 'Tonhöhe';

  @override
  String get referenceModeTextToMorse => 'Text → Morse';

  @override
  String get referenceModeMorseToText => 'Morse → Text';

  @override
  String get referenceModeKey => 'Morsen';

  @override
  String get referenceTextInputLabel => 'Text';

  @override
  String get referenceTextInputHint => 'Text zum Codieren eingeben…';

  @override
  String get referencePatternOutputLabel => 'Morse';

  @override
  String get referenceCopyPattern => 'Muster kopieren';

  @override
  String get referencePatternCopied => 'Muster kopiert';

  @override
  String get referencePatternInputLabel => 'Morse';

  @override
  String get referencePatternInputHint => 'Gib . und - ein, Leerzeichen zwischen Buchstaben und / zwischen Wörtern';

  @override
  String get referenceTextOutputLabel => 'Text';

  @override
  String get referenceCopyText => 'Text kopieren';

  @override
  String get referenceTextCopied => 'Text kopiert';

  @override
  String get referenceUnknownPatternHelp => 'Muster ohne zugeordnetes Zeichen werden als <pattern> angezeigt.';

  @override
  String get referenceKeypadDit => 'Punkt';

  @override
  String get referenceKeypadDah => 'Strich';

  @override
  String get referenceKeypadCharGap => 'Buchstabenpause';

  @override
  String get referenceKeypadWordGap => 'Wortpause';

  @override
  String get referenceKeypadBackspace => 'Rücktaste';

  @override
  String get referenceKeyHint => 'Halte die Taste gedrückt, um zu senden. Halte auf einer Tastatur die Leertaste gedrückt.';

  @override
  String get referenceKeyLabel => 'TASTE';

  @override
  String get referenceKeyDecodedLabel => 'Decodiert';

  @override
  String get referenceKeyPendingLabel => 'Tastung';

  @override
  String get statsTitle => 'Statistik';

  @override
  String get statsLoading => 'Deine Statistik wird geladen…';

  @override
  String get statsLoadFailed => 'Dein Fortschritt konnte nicht geladen werden. Ziehe nach unten oder öffne die Seite erneut, um es noch einmal zu versuchen.';

  @override
  String get statsRetry => 'Erneut versuchen';

  @override
  String get statsEmptyTitle => 'Noch keine Übungseinheiten';

  @override
  String get statsEmptyBody => 'Schließe deine erste Hör- oder Gebeübung ab. Dann erscheinen hier dein Genauigkeitsverlauf, deine Stärken bei einzelnen Zeichen und ein Übungskalender.';

  @override
  String get statsEmptyCallToAction => 'Gehe zu „Lernen“ und drücke „Lektion fortsetzen“, um zu beginnen.';

  @override
  String get statsOverviewTitle => 'Übersicht';

  @override
  String get statsTileLesson => 'Koch-Lektion';

  @override
  String get statsTileAccuracy => 'Genauigkeit';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => 'Übung';

  @override
  String get statsTileStreak => 'Serie';

  @override
  String get statsTileDailyGoal => 'Tagesziel';

  @override
  String get statsGoalMet => 'Heute erreicht';

  @override
  String get statsSummaryTitle => 'Deine Statistik';

  @override
  String get statsSummaryOpen => 'Statistik anzeigen';

  @override
  String get statsTrendTitle => 'Genauigkeitsverlauf';

  @override
  String get statsTrendHint => 'Tippe auf einen Punkt, um eine Übungseinheit anzusehen.';

  @override
  String get statsSeriesReceive => 'Empfangen';

  @override
  String get statsSeriesSend => 'Senden';

  @override
  String get statsAxisSessions => 'Übungseinheit';

  @override
  String get statsCharsTitle => 'Zeichen';

  @override
  String get statsCharsSubtitle => 'Koch-Reihenfolge. Tippe auf ein Zeichen für Details.';

  @override
  String get statsCharsNotStarted => 'Noch nicht geübt';

  @override
  String get statsNotInCourse => 'Nicht im Koch-Kurs enthalten';

  @override
  String get statsSrsTitle => 'Verteilte Wiederholung';

  @override
  String get statsSrsNotTracked => 'Noch nicht eingeplant';

  @override
  String get statsSrsDueNow => 'Jetzt fällig';

  @override
  String get statsConfusionsTitle => 'Am häufigsten verwechselt mit';

  @override
  String get statsConfusionsNone => 'Keine Verwechslungen aufgezeichnet';

  @override
  String get statsConfusionMissed => 'überhört';

  @override
  String get statsBucketLegendTitle => 'Genauigkeit';

  @override
  String get statsBucketNone => 'Keine';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => 'Verwechslungen';

  @override
  String get statsHeatmapSubtitle => 'Zeilen zeigen das gesendete Zeichen, Spalten deine Antwort. Dunkler bedeutet häufiger.';

  @override
  String get statsHeatmapEmpty => 'Noch keine Verwechslungen. Falsche Antworten erscheinen hier.';

  @override
  String get statsHeatmapLegendLow => 'Selten';

  @override
  String get statsHeatmapLegendHigh => 'Häufig';

  @override
  String get statsHeatmapAxisTarget => 'Gesendet';

  @override
  String get statsHeatmapAxisAnswered => 'Geantwortet';

  @override
  String get statsCalendarTitle => 'Übungskalender';

  @override
  String get statsCalendarSubtitle => 'Letzte 12 Wochen';

  @override
  String get statsCalendarLegendLess => 'Weniger';

  @override
  String get statsCalendarLegendMore => 'Mehr';

  @override
  String get statsStreakExplanation => 'Eine Serie zählt aufeinanderfolgende Kalendertage mit mindestens einer Übungseinheit. Ein ganzer Tag ohne Übung setzt sie zurück; zweimal an einem Tag zu üben zählt nur einmal.';

  @override
  String get learnStatistics => 'Statistik';

  @override
  String get listenTitle => 'Mithören';

  @override
  String get listenStart => 'Starten';

  @override
  String get listenStop => 'Stoppen';

  @override
  String get listenStarting => 'Mikrofon wird gestartet…';

  @override
  String get listenClear => 'Text löschen';

  @override
  String get listenCopy => 'Text kopieren';

  @override
  String get listenCopied => 'Decodierter Text kopiert';

  @override
  String get listenSettings => 'Mithöreinstellungen';

  @override
  String get listenDecoded => 'Decodiert';

  @override
  String get listenEmptyHint => 'Richte das Mikrofon auf einen Morseton. Der decodierte Text erscheint hier.';

  @override
  String get listenIdleHint => 'Tippe auf „Starten“, um einen Morseton mitzuhören.';

  @override
  String get listenPending => 'Empfang läuft';

  @override
  String get listenSpeed => 'Geschwindigkeit';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => 'Signal';

  @override
  String get listenToneOn => 'Ton';

  @override
  String get listenTone => 'Tonfrequenz';

  @override
  String get listenToneLocked => 'Erfasst';

  @override
  String get listenToneSearching => 'Wird gesucht';

  @override
  String get listenToneManual => 'Manuell';

  @override
  String get listenAutoTune => 'Automatisch abstimmen';

  @override
  String get listenAutoTuneHelp => 'Folgt dem stärksten Ton zwischen 400 und 1000 Hz. Ziehe am Regler, um stattdessen manuell abzustimmen.';

  @override
  String get listenRetune => 'Automatisch';

  @override
  String get listenBlockSize => 'Analyseblock';

  @override
  String get listenBlockSizeHelp => 'Kleinere Blöcke erfassen Signalflanken genauer, nehmen aber mehr Rauschen auf. 256 Abtastwerte (5,3 ms) eignen sich für 5–40 WPM.';

  @override
  String get listenMinElement => 'Kürzestes Element';

  @override
  String get listenMinElementHelp => 'Kürzere Töne und Pausen werden als Klicks und Aussetzer ignoriert.';

  @override
  String get listenPermissionDenied => 'Der Mikrofonzugriff wurde verweigert. Erlaube ihn in den Systemeinstellungen und versuche es erneut.';

  @override
  String get listenPermissionRetry => 'Erneut versuchen';

  @override
  String get listenStartFailed => 'Das Mikrofon konnte nicht gestartet werden.';

  @override
  String get listenNoInput => 'Kein Mikrofon gefunden. Schließe eines an und versuche es erneut.';

  @override
  String get listenStreamFailed => 'Das Mikrofon wurde unerwartet beendet. Versuche es erneut.';

  @override
  String listenWpmValue(int wpm) {
    return '$wpm WPM';
  }

  @override
  String listenHzValue(int hz) {
    return '$hz Hz';
  }

  @override
  String listenBlockSamples(int samples, String ms) {
    return '$samples Abtastwerte ($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'Das Mithören wurde gestoppt, während die App im Hintergrund war.';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => 'Punkte zu lang';

  @override
  String get learnTipDahTooShortTitle => 'Striche zu kurz';

  @override
  String get learnTipIntraGapTooLongTitle => 'Elemente zu weit auseinander';

  @override
  String get learnTipCharGapTooShortTitle => 'Zeichen zu dicht beieinander';

  @override
  String get learnTipWordGapTooShortTitle => 'Wörter zu dicht beieinander';

  @override
  String get learnTipSpeedUnsteadyTitle => 'Ungleichmäßiges Tempo';

  @override
  String get learnSeverityMinor => 'leicht';

  @override
  String get learnSeverityModerate => 'merklich';

  @override
  String get learnSeveritySevere => 'stark';

  @override
  String learnNewestCharIs(String char) {
    return 'Neu in dieser Lektion: $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, neu';
  }

  @override
  String learnPendingPattern(String pattern) {
    return 'Tastung: $pattern';
  }

  @override
  String learnIssueHeadline(String title, String severity) {
    return '$title ($severity)';
  }

  @override
  String learnRatioTimes(String ratio) {
    return '${ratio}x';
  }

  @override
  String learnTipDitTooLong(String ratio) {
    return 'Deine Punkte sind zu lang (etwa $ratio einer Punktlänge). Denke an „di“, nicht „daaah“ – ein Punkt ist ein kurzes Antippen.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return 'Deine Striche sind zu kurz (etwa $ratio einer Punktlänge; Ziel ist 3). Halte einen Strich so lang wie drei Punkte.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return 'Die Pausen innerhalb der Zeichen sind zu lang (etwa $ratio einer Punktlänge). Halte die Elemente eines Zeichens eng zusammen.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return 'Die Zeichen laufen ineinander (Pausen etwa $ratio einer Punktlänge; Ziel ist 3). Lass nach jedem Zeichen eine deutliche Pause.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return 'Die Wörter liegen zu dicht beieinander (Pausen etwa $ratio einer Punktlänge; Ziel ist 7). Halte eine lange Pause zwischen Wörtern.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return 'Dein Tempo schwankt (Abweichung $percent %). Wähle ein Tempo und behalte es die ganze Zeile bei.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$offending von $total Punkten zu lang (Ø $ratio Punktlängen)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$offending von $total Strichen zu kurz (Ø $ratio Punktlängen)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$offending von $total Pausen innerhalb der Zeichen zu lang (Ø $ratio Punktlängen)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$offending von $total Zeichenpausen zu kurz (Ø $ratio Punktlängen)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$offending von $total Wortpausen zu kurz (Ø $ratio Punktlängen)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return 'Ungleichmäßiges Gebetempo (Variationskoeffizient $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return 'Letzte 7 Tage / $allTime insgesamt';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds Sek.';
  }

  @override
  String desktopTrayShow(String app) {
    return '$app anzeigen';
  }

  @override
  String desktopTrayHide(String app) {
    return '$app verbergen';
  }

  @override
  String get desktopTraySoundOn => 'Ton an';

  @override
  String get desktopTraySoundOff => 'Ton aus';

  @override
  String desktopTrayQuit(String app) {
    return '$app beenden';
  }

  @override
  String get listenStateOn => 'An';

  @override
  String get listenStateOff => 'Aus';

  @override
  String referenceTelegraphCodes(String codes) {
    return 'Chinesischer Telegrafencode: $codes';
  }

  @override
  String get referenceTelegraphMainland => 'Festlandchina 1983';

  @override
  String get referenceTelegraphTaiwan => 'Taiwan / HK';

  @override
  String get referenceTelegraphNone => 'Nicht in diesem Codebuch';

  @override
  String get appearanceTitle => 'Darstellung';

  @override
  String get appearanceStyles => 'Oberflächenstil';

  @override
  String get appearanceChoose => 'Stil auswählen, Vorschau ansehen und anwenden';

  @override
  String get appearanceMode => 'Helligkeit';

  @override
  String get appearancePreview => 'Vorschau';

  @override
  String get appearanceApply => 'Stil anwenden';

  @override
  String get appearanceRestore => 'Standardwerte wiederherstellen';

  @override
  String get appearanceApplied => 'Darstellung gespeichert';

  @override
  String get appearanceSaveFailed => 'Darstellung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get appearanceClassic => 'Klassisches Messing';

  @override
  String get appearanceModern => 'Moderne Ruhe';

  @override
  String get appearanceRadio => 'Nachtradio';

  @override
  String get appearancePaper => 'Papierhandbuch';

  @override
  String get appearanceCartoon => 'Lebendiger Comic';

  @override
  String get appearanceLight => 'Hell';

  @override
  String get appearanceDark => 'Dunkel';

  @override
  String learnShowAllChars(int count) {
    return 'Alle $count Zeichen anzeigen';
  }

  @override
  String get learnShowFewerChars => 'Weniger Zeichen anzeigen';

  @override
  String get learnLeaveDrillTitle => 'Diese Übung verlassen?';

  @override
  String get learnLeaveDrillBody => 'Die Runden dieser Übung werden nicht gespeichert.';

  @override
  String get learnLeaveDrillConfirm => 'Verlassen';

  @override
  String get learnReplayAssistedNote => 'Wiederholt: Diese Übung zählt als Training, schaltet aber keine Lektion frei und ändert keine Wiederholungen.';

  @override
  String get learnPlanTitle => 'Plan für heute';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return 'Etwa $minutes Min. · $done von $total Schritten';
  }

  @override
  String get learnPlanBudget => 'Planlänge';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get learnPlanStart => 'Plan starten';

  @override
  String get learnPlanContinue => 'Plan fortsetzen';

  @override
  String get learnPlanStepReview => 'Fällige Zeichen wiederholen';

  @override
  String get learnPlanStepFocus => 'Gezieltes Üben';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'Lektion $lesson';
  }

  @override
  String get learnPlanStepSend => 'Gebeübung';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return 'Zur Wiederholung fällig: $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'Oft verwechselt: $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return 'Unter 90 %: $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count Zeichen: kann die nächste Lektion freischalten';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return 'Auf $count Zeichen verlängert, damit sie die nächste Lektion freischalten kann';
  }

  @override
  String get learnPlanReasonConsolidate => 'Kurze Übung: festigt diese Lektion, schaltet die nächste nicht frei';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'Dein Kurs ist weiter: übt Lektion $lesson ohne Freischaltung';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '$count kurze Ziele geben';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return 'Erledigt · $percent %';
  }

  @override
  String get learnPlanStepDone => 'Erledigt';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$done von $total gegeben';
  }

  @override
  String get learnPlanStale => 'Lektion oder Tempo haben sich geändert. Noch nicht begonnene Schritte aktualisieren?';

  @override
  String get learnPlanUpdate => 'Schritte aktualisieren';

  @override
  String get learnPlanComplete => 'Plan für heute erledigt';

  @override
  String learnPlanNeedsWork(String symbols) {
    return 'Noch üben: $symbols';
  }

  @override
  String get learnPlanAllGood => 'Heute keine schwachen Zeichen.';

  @override
  String get learnPlanTomorrow => 'Morgen gibt es einen neuen Plan. Freies Üben ist jederzeit möglich.';

  @override
  String learnPlanEarlier(int done, int total) {
    return 'Der frühere Plan endete bei $done von $total Schritten und zählt heute nicht mehr.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return 'Bereit für $wpm WpM effektives Tempo';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return 'Bereit für $wpm WpM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'Das Mitschreiben fällt bei diesem Tempo schwer. Versuch $wpm WpM effektiv oder eine gezielte Übung.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return 'Basierend auf deinen letzten $count Übungen ohne Hilfe ($percent %). Nichts ändert sich, bevor du es übernimmst.';
  }

  @override
  String get learnSpeedAdviceApply => 'Übernehmen';

  @override
  String get learnSpeedAdviceDismiss => 'Nicht jetzt';

  @override
  String get learnSpeedAdviceInsufficient => 'Für Tempo-Tipps braucht es 3 Übungen ohne Hilfe mit je 50+ Zeichen bei deinem aktuellen Tempo.';

  @override
  String get learnQsoAction => 'QSO-Simulator';

  @override
  String learnQsoLocked(int lesson) {
    return 'Ab Lektion $lesson';
  }

  @override
  String get learnQsoTitle => 'QSO-Simulator';

  @override
  String get learnQsoRespond => 'Auf CQ antworten';

  @override
  String get learnQsoRespondHint => 'Eine Station ruft CQ. Antworte und tauscht Rapporte aus.';

  @override
  String get learnQsoCall => 'CQ rufen';

  @override
  String get learnQsoCallHint => 'Du rufst CQ und eine Station antwortet.';

  @override
  String get learnQsoYourCall => 'Dein Rufzeichen';

  @override
  String get learnQsoYourName => 'Dein Name';

  @override
  String get learnQsoYourQth => 'Dein QTH';

  @override
  String get learnQsoInvalidCall => 'Gib ein Rufzeichen wie BD1XYZ ein';

  @override
  String get learnQsoInvalidWord => 'Ein Wort, nur Buchstaben A–Z';

  @override
  String get learnQsoOffline => 'Läuft komplett auf diesem Gerät. Es wird nichts gesendet.';

  @override
  String get learnQsoStart => 'QSO starten';

  @override
  String get learnQsoResume => 'Unterbrochenes QSO fortsetzen';

  @override
  String get learnQsoStageCallCq => 'Rufe CQ mit deinem Rufzeichen';

  @override
  String get learnQsoStageCallConfirm => 'Antworte: ihr Rufzeichen, DE, deins';

  @override
  String get learnQsoStageExchange => 'Rapport, Name und QTH senden';

  @override
  String get learnQsoStageConfirmInfo => 'Ihre Angaben bestätigen';

  @override
  String get learnQsoStageClosing => 'Mit 73 und <SK> beenden';

  @override
  String get learnQsoStageDone => 'QSO abgeschlossen';

  @override
  String learnQsoSpeed(int wpm) {
    return 'Gegenstation gibt mit $wpm WpM effektiv';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call gibt';
  }

  @override
  String get learnQsoRemoteHidden => 'Nach Gehör mitschreiben – der Text ist verborgen.';

  @override
  String get learnQsoShowText => 'Text zeigen';

  @override
  String get learnQsoListen => 'Anhören';

  @override
  String get learnQsoAccepted => 'Angenommen';

  @override
  String get learnQsoRejected => 'Nicht angenommen';

  @override
  String get learnQsoRemoteSending => 'Die Gegenstation gibt …';

  @override
  String get learnQsoYourTurn => 'Du bist dran: gib deine Antwort und tippe auf Senden.';

  @override
  String get learnQsoDecoded => 'Deine Sendung';

  @override
  String get learnQsoNothingKeyed => 'Noch nichts gegeben';

  @override
  String get learnQsoPlayAgain => 'Wiederholung erbitten (AGN)';

  @override
  String get learnQsoSlower => 'Langsamer erbitten (QRS)';

  @override
  String get learnQsoHint => 'Tipp';

  @override
  String learnQsoHintLabel(String example) {
    return 'Beispiel: $example';
  }

  @override
  String get learnQsoPause => 'Pause';

  @override
  String get learnQsoSend => 'Senden';

  @override
  String get learnQsoClear => 'Löschen';

  @override
  String get learnQsoIssueEmpty => 'Es wurde nichts gegeben.';

  @override
  String get learnQsoIssueMissingCq => 'Beginne mit CQ.';

  @override
  String get learnQsoIssueMissingDe => 'Setze DE zwischen die Rufzeichen.';

  @override
  String get learnQsoIssueWrongLocalCall => 'Dein Rufzeichen fehlt oder ist falsch.';

  @override
  String get learnQsoIssueWrongRemoteCall => 'Das Rufzeichen der Gegenstation ist falsch.';

  @override
  String get learnQsoIssueReversedCalls => 'Rufzeichen vertauscht: zuerst ihres, dann DE und deins.';

  @override
  String get learnQsoIssueMissingEnding => 'Ende mit K oder KN.';

  @override
  String get learnQsoIssueMissingRst => 'Gib einen Rapport, z. B. UR RST 599.';

  @override
  String get learnQsoIssueInvalidRst => 'Dieser RST ist ungültig (R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'Sende NAME und deinen Namen.';

  @override
  String get learnQsoIssueWrongName => 'Das ist nicht dein Name in diesem QSO.';

  @override
  String get learnQsoIssueMissingQth => 'Sende QTH und deinen Standort.';

  @override
  String get learnQsoIssueWrongQth => 'Das ist nicht dein QTH in diesem QSO.';

  @override
  String get learnQsoIssueMissingAck => 'Bestätige mit R oder QSL.';

  @override
  String get learnQsoIssueWrongRemoteName => 'Bestätige den Namen der Gegenstation.';

  @override
  String get learnQsoIssueMissing73 => '73 einfügen.';

  @override
  String get learnQsoIssueMissingSk => 'Beende die Verbindung mit <SK>.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return 'Beim ersten Mal richtig: $count von $total Schritten';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return 'Wiederholungen: $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'Tipps: $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'Dein Geben: etwa $wpm WpM';
  }

  @override
  String get learnQsoSummaryNote => 'QSO-Ergebnisse zählen getrennt von der Mitschreib-Genauigkeit und schalten keine Lektionen frei.';

  @override
  String get learnTipDahTooLongTitle => 'Striche zu lang';

  @override
  String learnTipDahTooLong(String ratio) {
    return 'Deine Striche sind zu lang (etwa $ratio eines Punkts; Ziel 3). Lass nach drei Punktlängen los.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$offending von $total Strichen zu lang (Ø $ratio Punkt)';
  }

  @override
  String get learnRhythmTitle => 'Rhythmus';

  @override
  String get learnRhythmMine => 'Mein Rhythmus';

  @override
  String get learnRhythmStandard => 'Standardrhythmus (Zieltempo)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return 'Probleme werden an deiner eigenen Punktlänge ($ms ms) gemessen; gleichmäßig, aber langsam ist in Ordnung. Die Standardspur zeigt das Zieltempo.';
  }

  @override
  String get learnRhythmNotLocated => 'Deine Zeichen ließen sich nicht einzelnen Buchstaben zuordnen. Übe stattdessen das ganze Ziel.';

  @override
  String get learnRhythmPlayMine => 'Meins abspielen';

  @override
  String get learnRhythmPlayStandard => 'Standard abspielen';

  @override
  String learnRhythmPracticePart(int count) {
    return 'Das üben ($count Versuche)';
  }

  @override
  String get learnRhythmPracticeWhole => 'Ganzes Ziel üben';

  @override
  String get learnRhythmSymbolOk => 'Sieht gut aus';

  @override
  String get learnRhythmZoomIn => 'Vergrößern';

  @override
  String get learnRhythmZoomOut => 'Verkleinern';

  @override
  String get workbenchTitle => 'Aufnahme-Werkbank';

  @override
  String get workbenchOpen => 'Aufnahmen';

  @override
  String get workbenchImport => 'Aufnahme importieren';

  @override
  String get workbenchEmpty => 'Importiere eine WAV-Aufnahme, um sie zu wiederholen, zu dekodieren und mitzuschreiben. Kein Mikrofon nötig.';

  @override
  String get workbenchFormats => 'WAV, 16-Bit-PCM, Mono oder Stereo, 8/16/44,1/48 kHz; bis 50 MB und 20 Minuten.';

  @override
  String get workbenchBackupNote => 'Aufnahmen bleiben auf diesem Gerät. Sichere sie vor dem Löschen von Lerndaten oder der Deinstallation. Gespeicherte Ausschnitte behalten Titel, Notizen und Positionen.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => 'Mono';

  @override
  String get workbenchStereo => 'Stereo';

  @override
  String get workbenchErrorNotWav => 'Das ist keine WAV-Datei.';

  @override
  String get workbenchErrorFormat => 'Derzeit wird nur 16-Bit-PCM-WAV unterstützt (kein MP3, AAC oder Float-WAV).';

  @override
  String get workbenchErrorChannels => 'Nur Mono- oder Stereoaufnahmen werden unterstützt.';

  @override
  String get workbenchErrorRate => 'Abtastrate nicht unterstützt. Verwende 8, 16, 44,1 oder 48 kHz.';

  @override
  String get workbenchErrorDamaged => 'Die Datei ist beschädigt oder unvollständig.';

  @override
  String get workbenchErrorTooLarge => 'Die Datei ist größer als 50 MB.';

  @override
  String get workbenchErrorTooLong => 'Die Aufnahme ist länger als 20 Minuten.';

  @override
  String get workbenchErrorIo => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get workbenchErrorMissing => 'Die Aufnahmedatei fehlt.';

  @override
  String get workbenchStart => 'Start (s)';

  @override
  String get workbenchEnd => 'Ende (s)';

  @override
  String get workbenchSelectAll => 'Alles auswählen';

  @override
  String get workbenchPlay => 'Auswahl abspielen';

  @override
  String get workbenchStop => 'Stopp';

  @override
  String get workbenchLoop => 'Schleife';

  @override
  String get workbenchPlayLimit => 'Von längeren Auswahlen werden nur die ersten 5 Minuten abgespielt.';

  @override
  String get workbenchAutoTune => 'Ton automatisch finden';

  @override
  String workbenchManualTone(int hz) {
    return 'Ton: $hz Hz';
  }

  @override
  String get workbenchDecode => 'Auswahl dekodieren';

  @override
  String get workbenchCancel => 'Abbrechen';

  @override
  String workbenchDecoding(int percent) {
    return 'Dekodiere … $percent %';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'Ton $hz Hz · etwa $wpm WpM';
  }

  @override
  String get workbenchToneNotLocked => 'Kein stabiler Ton gefunden; versuch die manuelle Abstimmung.';

  @override
  String get workbenchNoText => 'In dieser Auswahl wurde nichts dekodiert.';

  @override
  String workbenchUnknown(String patterns) {
    return 'Unbekannte Muster: $patterns';
  }

  @override
  String get workbenchEdgeCut => 'Ein Zeichen am Rand der Auswahl ist abgeschnitten und kann falsch sein.';

  @override
  String get workbenchToneNote => 'Die Tonerkennung ist kein Vertrauenswert; prüfe den Text mit dem Ohr.';

  @override
  String get workbenchModeDecoder => 'Decoder';

  @override
  String get workbenchModeCopy => 'Selbst mitschreiben';

  @override
  String get workbenchDecoderHidden => 'Der Decodertext ist beim Mitschreiben verborgen.';

  @override
  String get workbenchShowDecoder => 'Decodertext zeigen';

  @override
  String get workbenchReference => 'Referenztext (optional)';

  @override
  String get workbenchReferenceHelp => 'Füge den gesendeten Text ein; sonst wird mit der Decoderausgabe verglichen.';

  @override
  String get workbenchAgainstDecoder => 'Mit der Decoderausgabe verglichen, die selbst falsch sein kann.';

  @override
  String get workbenchSave => 'Auswahl speichern';

  @override
  String get workbenchSaveTitle => 'Titel';

  @override
  String get workbenchSaveNote => 'Notiz';

  @override
  String get workbenchSaved => 'Auswahl gespeichert';

  @override
  String get workbenchSaveFailed => 'Auswahl konnte nicht gespeichert werden.';

  @override
  String get workbenchLibrary => 'Gespeicherte Auswahlen';

  @override
  String get workbenchLibraryEmpty => 'Noch keine gespeicherten Auswahlen.';

  @override
  String get workbenchMissing => 'Aufnahmedatei fehlt – wähle sie erneut oder lösche den Eintrag.';

  @override
  String get workbenchRelink => 'Datei erneut wählen';

  @override
  String get workbenchDelete => 'Löschen';

  @override
  String get materialsTitle => 'Meine Materialien';

  @override
  String get materialsNew => 'Neues Material';

  @override
  String get materialsEdit => 'Bearbeiten';

  @override
  String get materialsSave => 'Speichern';

  @override
  String get materialsSaveFailed => 'Material konnte nicht gespeichert werden.';

  @override
  String get materialsTitleField => 'Titel';

  @override
  String get materialsTagsField => 'Schlagwörter (durch Komma getrennt)';

  @override
  String get materialsTextField => 'Text';

  @override
  String get materialsListField => 'Ein Eintrag pro Zeile';

  @override
  String get materialsKindText => 'Text';

  @override
  String get materialsKindWords => 'Wortliste';

  @override
  String get materialsKindCallsigns => 'Rufzeichen';

  @override
  String get materialsPreview => 'Vorschau';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items Einträge · $symbols Zeichen · $prosigns Betriebszeichen';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'Ohne Morsecode, beim Üben ausgelassen: $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count doppelte Einträge werden einmal behalten';
  }

  @override
  String get materialsProblemEmpty => 'Gib zuerst Text ein.';

  @override
  String get materialsProblemTooLarge => 'Zu groß: Materialien sind auf 1 MiB begrenzt.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return 'Zu viele Einträge: höchstens $count.';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return 'Ein Eintrag ist zu lang: höchstens $count Zeichen.';
  }

  @override
  String get materialsProblemNothingTrainable => 'Hier lässt sich nichts morsen.';

  @override
  String get materialsSearch => 'Materialien durchsuchen';

  @override
  String get materialsFavoritesOnly => 'Favoriten';

  @override
  String get materialsFavorite => 'Zu Favoriten';

  @override
  String get materialsUnfavorite => 'Aus Favoriten entfernen';

  @override
  String get materialsEmpty => 'Noch keine Materialien. Füge eigene Texte, Wortlisten oder Rufzeichen hinzu.';

  @override
  String materialsItems(int count) {
    return '$count Einträge';
  }

  @override
  String get materialsActions => 'Aktionen';

  @override
  String get materialsPractise => 'Üben';

  @override
  String get materialsDelete => 'Löschen';

  @override
  String get materialsDeleteTitle => 'Material löschen?';

  @override
  String materialsDeleteBody(String title) {
    return '„$title“ wird von diesem Gerät entfernt. Dein Übungsverlauf bleibt.';
  }

  @override
  String get materialsImport => 'TXT oder JSON importieren';

  @override
  String get materialsImportDialogTitle => 'Materialdatei wählen';

  @override
  String get materialsSaveDialogTitle => 'Material speichern';

  @override
  String get materialsImportFailed => 'Import fehlgeschlagen. Deine Bibliothek ist unverändert.';

  @override
  String get materialsImportNotUtf8 => 'Nur UTF-8-Textdateien können importiert werden.';

  @override
  String get materialsImportInvalid => 'Keine gültige MorseCQ-Materialdatei. Nichts importiert.';

  @override
  String materialsImported(int count) {
    return '$count Materialien importiert.';
  }

  @override
  String get materialsDuplicateTitle => 'Einige Materialien gibt es schon';

  @override
  String get materialsDuplicateOverwrite => 'Ersetzen';

  @override
  String get materialsDuplicateKeepCopy => 'Beide behalten (als Kopie)';

  @override
  String get materialsDuplicateSkip => 'Überspringen';

  @override
  String get materialsExportJson => 'Als JSON exportieren';

  @override
  String materialsExported(int count) {
    return '$count Materialien exportiert.';
  }

  @override
  String get materialsExportFailed => 'Export fehlgeschlagen.';

  @override
  String get materialsExportWav => 'Audio exportieren (WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return 'Zeichentempo: $wpm WpM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return 'Effektives Tempo: $wpm WpM';
  }

  @override
  String materialsWavTone(int hz) {
    return 'Ton: $hz Hz';
  }

  @override
  String get materialsWavWithAnswer => 'Lösungstext beilegen (.txt)';

  @override
  String get materialsWavFormat => '16-Bit-Mono-WAV, 48 kHz.';

  @override
  String materialsWavParts(int count) {
    return 'Länger als 10 Minuten: wird als $count Dateien exportiert.';
  }

  @override
  String materialsWavExported(int count) {
    return '$count Audiodateien gespeichert.';
  }

  @override
  String get materialsPracticeMode => 'Üben mit';

  @override
  String get materialsPracticeLearned => 'Nur gelernte Zeichen';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return 'Nur gelernte Zeichen ($count Einträge nicht verfügbar: noch nicht gelernte Zeichen)';
  }

  @override
  String get materialsPracticeAll => 'Alle Morsezeichen';

  @override
  String get materialsPracticeNothing => 'In diesem Modus lässt sich kein Eintrag üben.';

  @override
  String get guestClearConfirm => 'Löschen';

  @override
  String get placementTitle => 'Mein Niveau prüfen';

  @override
  String get placementCheckLevel => 'Mein aktuelles Niveau prüfen';

  @override
  String get placementFromZero => 'Einführung überspringen: Prüfung Lektion 1';

  @override
  String get placementOfferTitle => 'Neu bei Morse oder schon geübt?';

  @override
  String get placementOfferBody => 'Ein kurzer Test kann einen Startpunkt vorschlagen. Er ist freiwillig und ändert nichts, bis du dich entscheidest.';

  @override
  String get placementIntro => 'Etwa 3–5 Minuten Mitschreiben in fünf Stufen: Koch-Zeichen in Gruppen mit steigendem Tempo, dann kurze Wörter. Eine grobe Orientierung aus wenigen Proben, kein Zertifikat. Jederzeit abbrechbar.';

  @override
  String get placementStart => 'Starten';

  @override
  String get placementSkip => 'Überspringen';

  @override
  String get placementStop => 'Beenden';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return 'Stufe $step von $total · $wpm WpM effektiv';
  }

  @override
  String get placementTierPassed => 'Gut mitgeschrieben. Die nächste Stufe ist schneller.';

  @override
  String get placementTierStopped => 'Diese Stufe lag unter 90 %, der Test endet hier.';

  @override
  String get placementNextTier => 'Nächste Stufe';

  @override
  String placementSuggestion(int lesson) {
    return 'Vorgeschlagener Start: Lektion $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return '$count von $total Koch-Zeichen der Reihe nach bestätigt.';
  }

  @override
  String get placementLimits => 'Auf Basis einer kleinen Probe: nicht geprüfte Zeichen bleiben ungeprüft, nichts wird als gelernt markiert. Die Lektion lässt sich jederzeit ändern.';

  @override
  String placementAdopt(int lesson) {
    return 'Mit Lektion $lesson beginnen';
  }

  @override
  String materialsImportConfirm(int count) {
    return '$count Materialien importieren?';
  }

  @override
  String get materialsExportTxt => 'Als Text exportieren (TXT)';

  @override
  String get conditionsTitle => 'Bedingungen';

  @override
  String get conditionsClear => 'Klar';

  @override
  String get conditionsLight => 'Leichte Störungen';

  @override
  String get conditionsRadio => 'Funkpraxis';

  @override
  String get conditionsClearHint => 'Ein sauberer, gleichmäßiger Ton: normales Training.';

  @override
  String get conditionsLightHint => 'Leises Rauschen und sanftes Fading. Ergebnisse bleiben getrennt vom klaren Training.';

  @override
  String get conditionsRadioHint => 'Rauschen, tiefes Fading, eine Nachbarstation und leicht ungleichmäßiges Timing. Ergebnisse bleiben getrennt vom klaren Training.';

  @override
  String get conditionsPreview => 'Probe hören';

  @override
  String conditionsActive(String name) {
    return 'Bedingungen: $name';
  }

  @override
  String get conditionsNeedSound => 'Funkbedingungen hört man, man sieht sie nicht: Schalte den Ton in den Trainingseinstellungen ein oder übe mit klaren Bedingungen.';

  @override
  String get conditionsCleanReplay => 'Ohne Effekte abspielen';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versuche unter diesen Bedingungen bei diesem Tempo: im Schnitt $accuracy %',
      one: '1 Versuch unter diesen Bedingungen bei diesem Tempo: $accuracy %',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => 'Training unter Funkbedingungen zählt als Aktivität, ändert aber weder Lektionen noch Wiederholungsplan oder Tempo-Empfehlung.';

  @override
  String get keysTitle => 'Tasten und externe Keyer';

  @override
  String get keysMeSubtitle => 'Tastenbelegung, Paddles und USB-Keyer-Adapter';

  @override
  String get keysIntro => 'Wähle, welche Tasten Morse geben. USB-Adapter für Tasten und Paddles, die eine Tastatur nachbilden, verhalten sich wie eine Tastatur: Lege ihre Tasten hier fest. Die App erkennt nicht, welches Gerät eine Taste gesendet hat; ein Profil ist daher eine Tastenbelegung.';

  @override
  String get keysStandardProfile => 'Standard';

  @override
  String get keysUnnamed => 'Unbenanntes Profil';

  @override
  String get keysEdit => 'Bearbeiten';

  @override
  String get keysNewProfile => 'Neues Profil';

  @override
  String get keysLimitations => 'MIDI-, serielle und Bluetooth-Keyer, Adapter-Firmware-Einstellungen und Sendersteuerung werden nicht unterstützt. Getestete Adapter stehen in der Dokumentation.';

  @override
  String get keysEditTitle => 'Tastenprofil';

  @override
  String get keysName => 'Profilname';

  @override
  String get keysActionStraight => 'Handtaste';

  @override
  String get keysActionDit => 'Punkt-Paddle';

  @override
  String get keysActionDah => 'Strich-Paddle';

  @override
  String get keysPressKey => 'Taste drücken …';

  @override
  String get keysNone => 'Nicht festgelegt';

  @override
  String get keysSet => 'Festlegen';

  @override
  String keysReserved(String key) {
    return '$key ist vom System oder der App reserviert; wähle eine andere Taste.';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key wird bereits für $action verwendet.';
  }

  @override
  String keysConflictSave(String keys) {
    return 'Jede Taste darf nur eine Aufgabe haben: $keys ist doppelt belegt.';
  }

  @override
  String get keysMissing => 'Lege die Tasten fest, die dieser Keyer-Modus braucht (beide Paddles bei Iambic).';

  @override
  String get keysSwapPaddles => 'Paddles tauschen (Linkshänder)';

  @override
  String get keysKeyerMode => 'Keyer-Modus';

  @override
  String get keysIambicA => 'Iambic A';

  @override
  String get keysIambicB => 'Iambic B';

  @override
  String get keysAdapterKeyer => 'Der Adapter erzeugt die Zeichen selbst';

  @override
  String get keysAdapterKeyerHint => 'Für Adapter mit eigenem Keyer: Seine getakteten Tastendrücke werden unverändert verwendet, ohne zweiten Iambic-Keyer in der App.';

  @override
  String get keysAppSidetone => 'App-Mithörton beim Geben';

  @override
  String get keysAppSidetoneHint => 'Ausschalten, wenn der Adapter selbst einen Mithörton erzeugt. Die Dekodierung bleibt unberührt.';

  @override
  String get keysTestTitle => 'Test';

  @override
  String get keysTestNote => 'Nur zum Testen: Nichts wird gesendet oder dem Training angerechnet.';

  @override
  String get keysTestRelease => 'Tasten lösen';

  @override
  String get keysAdapterActive => 'Der Keyer des Adapters wird verwendet: Paddle-Tasten wirken wie eine Handtaste.';

  @override
  String keysHintCustom(String keys) {
    return 'Tasten: $keys';
  }

  @override
  String get telegraphTitle => 'Chinesischer Telegrafencode';

  @override
  String get telegraphIntro => 'Jedes chinesische Zeichen wird als vierstelliger Code gesendet. Übe das Hören der Ziffern und, getrennt davon, welcher Code für welches Zeichen steht.';

  @override
  String get telegraphCodebook => 'Codebuch';

  @override
  String get telegraphCodebookMainland => 'Festland';

  @override
  String get telegraphCodebookTaiwan => 'Taiwan';

  @override
  String get telegraphDigitsTitle => 'Codegruppen mitschreiben';

  @override
  String get telegraphDigitsHint => 'Höre vierstellige Gruppen echter Codes und tippe die Ziffern.';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Durchgänge: $accuracy % der Ziffern',
      one: '1 Durchgang: $accuracy % der Ziffern',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => 'Codes abrufen';

  @override
  String get telegraphRecallHint => 'Zeichen zu Code und Code zu Zeichen. Getrennt vom Morse-Fortschritt.';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten beantwortet: $accuracy % gewusst',
      one: '1 Karte beantwortet: $accuracy % gewusst',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => 'Code-Abruf schaltet nie Morse-Lektionen frei und ändert keine Tempo-Empfehlung; Ziffern-Mitschreiben zählt wie anderes Morse-Mitschreiben.';

  @override
  String get telegraphRecallCharPrompt => 'Tippe den Code dieses Zeichens';

  @override
  String get telegraphRecallCodePrompt => 'Wähle das Zeichen zu diesem Code';

  @override
  String get telegraphReveal => 'Lösung zeigen';

  @override
  String get telegraphRevealAssisted => 'Angezeigt: Diese Karte zählt als unterstützt.';

  @override
  String get telegraphCorrect => 'Richtig';

  @override
  String get telegraphIncorrect => 'Nicht ganz';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$correct von $total gewusst';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten mit angezeigter Lösung',
      one: '1 Karte mit angezeigter Lösung',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => 'Deutung als Telegrafencode';

  @override
  String get telegraphInterpretNote => 'Nur hier angezeigt: Die Nachricht selbst bleibt unverändert und nichts wird gesendet.';

  @override
  String get telegraphUnresolved => 'Ungeklärt: Kein Zeichen hat diesen Code';

  @override
  String get telegraphMalformed => 'Keine vierstellige Gruppe';

  @override
  String get telegraphNotCode => 'Text, unverändert';

  @override
  String get telegraphAmbiguous => 'Mehrere Zeichen teilen sich diesen Code';

  @override
  String get conditionsAudioFailed => 'Der Ton ließ sich auf diesem Gerät nicht starten. Übe stattdessen mit klaren Bedingungen.';

  @override
  String get aboutPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get aboutTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get aboutSupport => 'Hilfe und Kontakt';

  @override
  String get aboutLinkFailed => 'Der Link ließ sich nicht öffnen und wurde kopiert.';

  @override
  String get offlineClearData => 'Lerndaten löschen';

  @override
  String get offlineClearDataBody => 'Löscht deinen Fortschritt, deine Pläne und Materialien auf diesem Gerät.';

  @override
  String get offlineCleared => 'Lerndaten gelöscht.';

  @override
  String get offlineClearFailed => 'Die Lerndaten konnten nicht gelöscht werden.';

  @override
  String get learnStorageUnavailable => 'Deine Trainingsdaten ließen sich auf diesem Gerät nicht öffnen. Versuche es erneut.';

  @override
  String get materialsImportedSource => 'Importierte Quelle';

  @override
  String get learnStartHereTitle => 'Neu hier? Beginne mit einer 3-Minuten-Lektion';

  @override
  String get learnStartHereBody => 'Höre die Töne, lerne K und M und beantworte ein paar leichte Runden. Nichts wird bewertet.';

  @override
  String get learnStartHere => 'Hier starten';

  @override
  String get learnReplayFirstLesson => 'Erste Lektion wiederholen';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '$introduced eingeführt · $mastered gemeistert';
  }

  @override
  String get learnChipNew => 'Neu';

  @override
  String get learnChipPractising => 'In Übung';

  @override
  String get learnChipMastered => 'Gemeistert';

  @override
  String get learnChipWeak => 'Unter 90 %';

  @override
  String get learnChipDue => 'Zur Wiederholung';

  @override
  String get learnTapChipHint => 'Tippe auf ein Zeichen, um es zu hören';

  @override
  String learnHearChar(String char) {
    return '$char anhören';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a gegen $b';
  }

  @override
  String get learnGuidedPractice => 'Kurze Übung (10 Zeichen)';

  @override
  String learnChallengeHint(int count, int min) {
    return 'Die Lektionsprüfung: $count Zeichen bei 90 %, jedes neue Zeichen mindestens $min-mal. Bestehen schaltet das nächste Zeichen frei.';
  }

  @override
  String get learnAllUnlockedNotPassed => 'Alle Zeichen sind freigeschaltet. Bestehe die letzte Prüfung, um den Kurs abzuschließen.';

  @override
  String get learnGoalFirstUse => 'Jetzt: K und M nach Gehör unterscheiden. Danach: die Prüfung zu Lektion 1.';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return 'Jetzt: $chars sicher erkennen ($min Kopien bei 90 %). Danach: die Prüfung zu Lektion $lesson.';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return 'Jetzt: die Prüfung zu Lektion $lesson bestehen. Danach: $next.';
  }

  @override
  String learnGoalNextChar(String char) {
    return 'das Zeichen $char';
  }

  @override
  String get learnGoalNextOperating => 'Wörter, Rufzeichen und ein ganzes QSO';

  @override
  String get learnGoalOperating => 'Jetzt: echte Texte – Wörter, Rufzeichen, QSO. Danach: die effektive Geschwindigkeit Schritt für Schritt erhöhen.';

  @override
  String get learnMorePractice => 'Weitere Übungen';

  @override
  String get learnQsoReady => 'Bereit';

  @override
  String get learnQsoPractiseFirst => 'Erst die Zeilen üben';

  @override
  String learnQsoSymbolsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Zeichen',
      one: 'Noch 1 Zeichen',
    );
    return '$_temp0';
  }

  @override
  String get learnGlossaryTitle => 'Was bedeuten diese Begriffe?';

  @override
  String get glossaryKoch => 'Koch-Methode: Zeichen werden von Anfang an in voller Geschwindigkeit gelernt, zwei zu Beginn und eines mehr pro Lektion, sobald du 90 % richtig mitschreibst.';

  @override
  String get glossaryWpm => 'WPM: Wörter pro Minute, gezählt mit dem Standardwort PARIS. Die Zeichengeschwindigkeit ist, wie schnell jedes Zeichen selbst klingt.';

  @override
  String get glossaryFarnsworth => 'Farnsworth: Die Zeichen bleiben schnell, die Pausen dazwischen werden gedehnt, damit du Zeit zum Denken hast. Die effektive Geschwindigkeit zählt diese Pausen mit.';

  @override
  String get glossaryQso => 'QSO: ein Funkkontakt zwischen zwei Stationen. CQ = allgemeiner Anruf, DE = von, K = bitte kommen.';

  @override
  String get glossaryRst => 'RST: ein Rapport – Lesbarkeit, Stärke, Ton. 599 heißt perfekt. 73 heißt viele Grüße.';

  @override
  String get learnVerdictNotCredited => 'Nichts gespeichert: keine Zeichen beantwortet.';

  @override
  String get learnVerdictAssisted => 'Übung mit Hilfe';

  @override
  String get learnVerdictAssistedHint => 'Wiederholungen oder Aufdecken wurden genutzt, daher zählt dieser Versuch nur als Übung: keine Freischaltung, keine Wiederholungs-Aktualisierung. Versuche den nächsten ohne Wiederholung.';

  @override
  String get learnVerdictPractice => 'Übung gespeichert';

  @override
  String get learnVerdictPracticeHint => 'Freie Übung aktualisiert Statistik und Wiederholungen, bringt den Kurs aber nie voran. Das tut nur die Lektionsprüfung von der Lernen-Startseite.';

  @override
  String get learnVerdictCourseComplete => 'Letzte Prüfung bestanden: Der ganze Zeichenkurs gehört dir.';

  @override
  String learnVerdictTooShort(int count, int min) {
    return 'Keine volle Prüfung: $count von $min Zeichen';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return 'Eine Prüfung umfasst mindestens $min Zeichen. Starte die Lektion von der Lernen-Startseite oder erhöhe die Sitzungslänge in den Trainingseinstellungen.';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return 'Zu wenige Kopien von $chars';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return 'Eine Prüfung braucht mindestens $min Kopien jedes neuen Zeichens. Versuch es erneut: Die Prüfung enthält sie absichtlich.';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return 'Neues Zeichen unter 90 %: $chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => 'Der Rest war gut; das neue Zeichen entscheidet die Lektion. Höre es gegen seinen Nachbarn und übe es vor der nächsten Prüfung.';

  @override
  String get learnVerdictBelowAccuracyHint => 'Insgesamt unter 90 %. Eine kurze Übung mit den schwachen Zeichen unten, dann die Prüfung noch einmal.';

  @override
  String get learnDrillWeak => 'Schwache Zeichen üben';

  @override
  String get learnRetryChallenge => 'Prüfung wiederholen';

  @override
  String get learnTakeChallenge => 'Zur Lektionsprüfung';

  @override
  String learnChallengeTitle(int lesson) {
    return 'Prüfung Lektion $lesson';
  }

  @override
  String get learnPracticeTitle => 'Übung';

  @override
  String get learnMeaningsTitle => 'Bedeutungen';

  @override
  String get firstLessonTitle => 'Erste Lektion';

  @override
  String firstLessonStep(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get firstLessonHearTitle => 'Hörst du es?';

  @override
  String get firstLessonHearBody => 'Tippe auf Abspielen. Du solltest ein kurzes Piepmuster hören (oder Blitz / Vibration bemerken, falls aktiv).';

  @override
  String get firstLessonHeard => 'Ich habe es gehört';

  @override
  String get firstLessonNotHeard => 'Ich habe nichts gehört';

  @override
  String get firstLessonNoSoundTitle => 'Kein Ton?';

  @override
  String get firstLessonNoSoundBody => 'Lautstärke erhöhen und Stummschalter oder „Nicht stören“ prüfen. Statt Ton kannst du auch Bildschirmblitz oder Vibration nutzen.';

  @override
  String get firstLessonUseFlash => 'Bildschirm zusätzlich blitzen';

  @override
  String get firstLessonUseVibration => 'Zusätzlich vibrieren';

  @override
  String get firstLessonPlay => 'Abspielen';

  @override
  String get firstLessonSoundsTitle => 'Kurz und lang';

  @override
  String get firstLessonSoundsBody => 'Morse hat zwei Töne: ein kurzes Dit und ein dreimal so langes Dah. Ein Zeichen ist ein Muster daraus, eine kurze Pause trennt Zeichen. Tippe auf jedes, um es zu hören.';

  @override
  String get firstLessonDit => 'Dit';

  @override
  String get firstLessonDah => 'Dah';

  @override
  String get firstLessonWorkedTitle => 'Ein Beispiel mit Lösung';

  @override
  String get firstLessonWorkedBody => 'Erst hören; die Antwort erscheint nach dem Ton. Du musst noch nicht antworten.';

  @override
  String firstLessonWorkedReveal(String char) {
    return 'Das war $char';
  }

  @override
  String get firstLessonTrialsTitle => 'K oder M?';

  @override
  String get firstLessonTrialsBody => 'Höre zu und tippe auf das gehörte Zeichen. Wiederhole so oft du willst – das ist kein Test.';

  @override
  String firstLessonTrialRound(int round, int total) {
    return 'Runde $round von $total';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return 'Ja, das war $char';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return 'Das war $char, nicht $answer. Höre beide nacheinander.';
  }

  @override
  String get firstLessonTooFast => 'Zu schnell? Anfängertempo nutzen (längere Pausen zwischen Zeichen)';

  @override
  String get firstLessonNextTitle => 'Wie weiter';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '$correct / $total in dieser Runde richtig. Wähle den nächsten Schritt und mache in deinem Tempo weiter.';
  }

  @override
  String get firstLessonNextGuided => 'Kurze Übung: 10 einzelne Zeichen';

  @override
  String get firstLessonNextSend => 'Senden ausprobieren';

  @override
  String get firstLessonSendGuide => 'Senden: kurz halten für ein Dit, länger für ein Dah. Bei Paddles macht eine Seite Dits, die andere Dahs. Loslassen und zwischen Zeichen kurz pausieren. Handtaste oder Iambic A / B kannst du später ändern; das ist jetzt egal.';

  @override
  String get firstLessonReplayAnytime => 'Du kannst diese Lektion jederzeit von der Lernen-Startseite wiederholen.';

  @override
  String get firstLessonContinue => 'Weiter';

  @override
  String get firstLessonTrialNext => 'Nächste Runde';

  @override
  String get sendFirstUseTitle => 'Zum ersten Mal tasten?';

  @override
  String get sendFirstUseStraight => 'Taste kurz halten für ein Dit, etwa dreimal so lang für ein Dah. Zwischen Zeichen kurz, zwischen Wörtern länger pausieren.';

  @override
  String get sendFirstUsePaddles => 'Das Paddle mit der Punkt-Beschriftung für Punkte halten, das mit der Strich-Beschriftung für Striche; der Keyer steuert die Länge. Zwischen Zeichen kurz, zwischen Wörtern länger pausieren.';

  @override
  String get sendFirstUseDismiss => 'Verstanden';

  @override
  String get learnSpeedPresets => 'Tempo';

  @override
  String get learnPresetBeginner => 'Anfänger 20 / 6';

  @override
  String get learnPresetStandard => 'Standard 20 / 8';

  @override
  String get learnPresetHelp => 'Zeichen klingen in beiden mit 20 WPM; das Anfängertempo lässt längere Pausen dazwischen (6 WPM effektiv).';

  @override
  String get learnPlanStepIntro => 'Erste Lektion';

  @override
  String get learnPlanStepRecognition => 'Einzelne Zeichen';

  @override
  String get learnPlanReasonFirstLesson => 'Töne hören und K von M unterscheiden (etwa 3 Minuten)';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return 'Ein Zeichen nach dem anderen: $symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return 'Kurze gemischte Gruppen aus $count Zeichen; die 50-Zeichen-Prüfung kommt später';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return 'Optional: Vorbild hören, dann $count kurze Ziele tasten';
  }

  @override
  String get learnQsoReadyTitle => 'Bereit für ein QSO';

  @override
  String get learnQsoNotReadyTitle => 'Noch nicht alle Zeichen gelernt';

  @override
  String get learnQsoMissingBody => 'Ein QSO nutzt diese noch nicht gelernten Zeichen – tippe eines an, um es zu hören. Du kannst trotzdem erkunden; das Tastenfeld zeigt alle Zeichen.';

  @override
  String get learnQsoShorthandHint => 'Übe zuerst die Abkürzungen (CQ, DE, UR, RST, TNX, 73), damit die Zeilen Sinn ergeben.';

  @override
  String get learnQsoPractiseShorthand => 'Abkürzungen üben';

  @override
  String get learnQsoHowTitle => 'So läuft ein QSO';

  @override
  String get learnQsoHowBody => 'Anruf (CQ = an alle, DE = von), Antwort mit Rufzeichen, Austausch von Rapport (RST), Name und QTH (Standort), dann 73 (viele Grüße) und <SK> (Ende). K heißt bitte kommen.';

  @override
  String get learnQsoExploreLabel => 'Enthält ungelernte Zeichen';

  @override
  String get statsCoursePassed => 'Kurs bestanden';

  @override
  String get firstLessonPlayAgain => 'Noch einmal abspielen';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return 'Prüfung Lektion $lesson: $count Zeichen, 90 % schaltet $char frei';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return 'Prüfung Lektion $lesson: $count Zeichen bei 90 % schließen den Kurs ab';
  }

  @override
  String get learnQsoShorthandTitle => 'Übe zuerst die Abkürzungen';

  @override
  String get learnQsoExchangeTitle => 'Übe zuerst QSO-Zeilen';

  @override
  String get learnQsoExchangeHint => 'Schreibe erst einzelne Zeilen eines Kontakts mit (ein Austausch nach dem anderen), bevor du ein ganzes QSO im Simulator führst.';

  @override
  String get sendGuideTitle => 'Senden lernen';

  @override
  String sendGuideStep(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get sendGuideHear => 'Vorbild anhören';

  @override
  String get sendGuideListening => 'Den ganzen Rhythmus anhören…';

  @override
  String get sendGuideTry => 'Jetzt senden';

  @override
  String get sendGuideRetry => 'Dieses Ziel erneut üben';

  @override
  String get sendGuidePassed => 'Richtig dekodiert. Weiter zum nächsten Ziel.';

  @override
  String get sendGuideComplete => 'Beide Zeichen und Gruppen wurden richtig gesendet. Weiter mit freiem Sendetraining.';

  @override
  String get sendGuideRhythm => 'Dem Vorbild folgen: kurze Punkte, Striche dreimal so lang und deutliche Zeichenpausen.';

  @override
  String get learnContinueToday => 'Heute weiterlernen';

  @override
  String get learnPlanDetails => 'Plandetails ansehen';

  @override
  String get learnGuidedSingle => 'Einzelzeichen · 10 Zeichen';

  @override
  String get learnGuidedShort => '3er-Gruppen · 15 Zeichen';

  @override
  String get learnGuidedGroups => '5er-Gruppen · 20 Zeichen';

  @override
  String get learnGuidedRecommended => 'Empfohlener nächster Schritt';

  @override
  String get learnGuidedProgressHint => 'Nach dem Bestehen mit kurzen und vollständigen Gruppen weitermachen. Geführtes Üben festigt die Fähigkeiten; eine Kursprüfung schaltet die nächste Lektion frei.';

  @override
  String get learnGuidedContinue => 'Geführt weiterüben';

  @override
  String get learnGuidedRetry => 'Diese Stufe erneut üben';

  @override
  String get firstLessonZeroHint => 'Noch keine richtige Antwort? Das ist in Ordnung. Höre dir den Unterschied zwischen K und M noch einmal an und versuche es erneut.';

  @override
  String get firstLessonPartialHint => 'Einige Zeichen hast du richtig gehört. Vergleiche K und M erneut und mache in deinem Tempo weiter.';

  @override
  String get firstLessonPerfectHint => 'In dieser Runde waren alle Antworten richtig. Festige das mit Hörübungen ohne Antwortauswahl.';

  @override
  String get firstLessonPaceLocked => 'Die Runde hat begonnen, deshalb bleibt ihr Tempo unverändert. Für die nächste Runde kannst du es in den Einstellungen ändern.';

  @override
  String get learnRecentEvidenceHint => 'Die Stufen berücksichtigen Hörübungen ohne Hilfe aus den letzten 14 Tagen bei gleichem Tempo.';

  @override
  String get learnQsoConsolidateTitle => 'Gelernte Zeichen festigen';

  @override
  String get learnQsoConsolidateHint => 'Freigeschaltet bedeutet nicht beherrscht. Beginne mit Einzelzeichen, um aktuelle eigenständige Ergebnisse zu sammeln.';

  @override
  String get learnQsoPractiseSymbols => 'Diese Zeichen üben';

  @override
  String get learnQsoProtocolTitle => 'QSO-Begriffe verstehen';

  @override
  String get learnQsoProtocolHint => 'Prüfe die Bedeutungen von CQ, DE, RST und 73, bevor du ein kurzes QSO beginnst.';

  @override
  String get learnQsoProtocolStart => 'Begriffsverständnis prüfen';

  @override
  String learnQsoProtocolQuestion(String token) {
    return 'Was bedeutet $token in einem QSO?';
  }

  @override
  String get learnQsoGeneralCall => 'Ruf an eine beliebige Station';

  @override
  String get learnQsoFromStation => 'Von dieser Station';

  @override
  String get learnQsoSignalReport => 'Signalrapport';

  @override
  String get learnQsoBestRegards => 'Beste Grüße und Abschied';

  @override
  String get learnQsoProtocolCorrect => 'Richtige Antwort';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return 'Richtige Bedeutung: $meaning';
  }

  @override
  String get learnQsoProtocolPass => 'Alle vier Begriffe wurden ohne Hilfe richtig beantwortet. Du kannst ein kurzes QSO versuchen.';

  @override
  String get learnQsoProtocolPractice => 'Wiederhole diese Bedeutungen vor der nächsten Prüfung.';

  @override
  String get learnQsoProtocolRetry => 'Erneut prüfen';

  @override
  String get learnQsoShortExchange => 'Kurzes QSO üben';

  @override
  String get learnQsoShortExchangeHint => 'Bestätige Rufzeichen, tausche Signalrapporte aus und verabschiede dich ohne Hilfe, bevor du ein vollständiges QSO übst.';

  @override
  String get learnQsoExplorePending => 'Vollständiges QSO erkunden · weitere Übung nötig';

  @override
  String get learnQsoReadyHint => 'Du hast aktuelle eigenständige Übungsergebnisse und kannst vollständige simulierte QSOs beginnen.';

  @override
  String get goalsTitle => 'Lernziel';

  @override
  String get goalsFirstQso => 'Erstes QSO';

  @override
  String get goalsConversation => 'Gespräche und Kopfhören';

  @override
  String get goalsContest => 'Contest-QSOs';

  @override
  String get goalsExplanation => 'Nach CW Academy. Pro Meilenstein sind zwei selbstständige Versuche mit mindestens 90 % bei der angegebenen Effektivgeschwindigkeit innerhalb von 28 Tagen erforderlich.';

  @override
  String get goalsBeginner => 'Beginne mit dem Zeichenkurs. Danach ergänzt der Tagesplan Hörverständnis und QSOs passend zum Ziel.';

  @override
  String get goalsComplete => 'Alle Meilensteine derzeit erreicht';

  @override
  String get goalsPractice => 'Nächste Fähigkeit üben';

  @override
  String get goalsCopying => 'Zeichenerkennung';

  @override
  String get goalsSending => 'Lesbares Geben';

  @override
  String get goalsWords => 'Worterkennung';

  @override
  String get goalsPhrases => 'Satzverständnis';

  @override
  String get goalsInformation => 'QSO-Informationen';

  @override
  String get goalsStory => 'Kurzgeschichten im Kopf';

  @override
  String get goalsQso => 'QSO abschließen';

  @override
  String get goalsCompetition => 'Contest-Betrieb';

  @override
  String get goalsPlanListening => 'Höre die für dein Ziel benötigten Informationen.';

  @override
  String get goalsPlanExchange => 'Übe einen interaktiven Austausch passend zu deinem Ziel.';

  @override
  String get mistakesTitle => 'Fehlerheft';

  @override
  String get mistakesPending => 'Zu wiederholen';

  @override
  String get mistakesRecovered => 'Beherrscht';

  @override
  String get mistakesHint => 'Wiederhole die ursprüngliche Aufgabe bei gleicher Geschwindigkeit und gleichen Bedingungen. Zwei genaue Antworten an verschiedenen Tagen gelten als beherrscht. Wiederholtes Abspielen und angezeigte Antworten zählen nicht.';

  @override
  String get mistakesEmptyPending => 'Keine Fehler zur Wiederholung. Falsch beantwortete Aufgaben werden hier nach dem Üben gespeichert.';

  @override
  String get mistakesEmptyRecovered => 'Noch keine beherrschten Aufgaben. Beantworte eine Aufgabe an zwei verschiedenen Tagen selbstständig richtig.';

  @override
  String get mistakesOriginalCopy => 'Erste falsche Antwort';

  @override
  String get mistakesLastCopy => 'Letzte Antwort';

  @override
  String get mistakesNoAnswer => 'Keine Antwort';

  @override
  String get mistakesFailures => 'Fehlversuche';

  @override
  String get mistakesFirstFailure => 'Erster Fehler';

  @override
  String get mistakesLastFailure => 'Letzter Fehler';

  @override
  String get mistakesCorrectDays => 'Tage mit selbstständiger richtiger Antwort';

  @override
  String get mistakesRecoveredOn => 'Beherrscht seit';

  @override
  String get mistakesRetry => 'Ursprüngliche Aufgabe wiederholen';

  @override
  String get qsoAdvancedContestTitle => 'Contest-Austausch';

  @override
  String get qsoAdvancedContestHint => 'Rufzeichen, RST und Seriennummer austauschen, dann eine korrigierte Nummer bestätigen.';

  @override
  String get qsoAdvancedPotaTitle => 'POTA Park zu Park';

  @override
  String get qsoAdvancedPotaHint => 'Rufzeichen, RST und Parkreferenzen austauschen, dann den korrigierten Park bestätigen.';

  @override
  String get qsoAdvancedSerialLabel => 'Deine Seriennummer';

  @override
  String get qsoAdvancedParkLabel => 'Deine Parkreferenz';

  @override
  String get qsoAdvancedInvalidSerial => 'Gib eine Seriennummer von 1 bis 9999 ein.';

  @override
  String get qsoAdvancedInvalidPark => 'Parkpräfix und 4–5 Ziffern verwenden, z. B. US-1234.';

  @override
  String get qsoAdvancedRepeatTitle => 'Ein Feld wiederholen';

  @override
  String get qsoAdvancedRepeatHint => 'Nur verpasste Informationen anfordern; die Phase bleibt gleich.';

  @override
  String get qsoAdvancedTypedMode => 'Antwort tippen (mit Hilfe)';

  @override
  String get qsoAdvancedKeyedMode => 'Antwort tasten';

  @override
  String get qsoAdvancedTypedReply => 'Deine Sendung';

  @override
  String get qsoAdvancedContestStage => 'RST und deine Seriennummer senden';

  @override
  String get qsoAdvancedPotaStage => 'RST und deinen Park senden';

  @override
  String get qsoAdvancedCorrectionStage => 'Korrigierte Angaben bestätigen';

  @override
  String get qsoAdvancedCorrectionHint => 'Auf CORR achten, dann das RST der Gegenstation und die korrigierte Nummer oder den Park bestätigen. Erst sauber senden, dann das Tempo erhöhen.';

  @override
  String get qsoAdvancedIssueMissingSerial => 'NR und deine Seriennummer senden.';

  @override
  String get qsoAdvancedIssueInvalidSerial => 'Die Nummer muss aus 1–4 Ziffern bestehen und größer als null sein.';

  @override
  String get qsoAdvancedIssueWrongSerial => 'Die Seriennummer stimmt nicht mit der erwarteten Nummer überein.';

  @override
  String get qsoAdvancedIssueMissingPark => 'PARK und die Parkreferenz senden.';

  @override
  String get qsoAdvancedIssueInvalidPark => 'Vollständiges Parkpräfix und 4–5 Ziffern verwenden.';

  @override
  String get qsoAdvancedIssueWrongPark => 'Die Parkreferenz stimmt nicht mit dem erwarteten Park überein.';

  @override
  String get qsoAdvancedIssueWrongRemoteRst => 'Bestätige das gehörte RST der Gegenstation.';

  @override
  String get qsoAdvancedContestSummary => 'Contest-Übung: Rufzeichen, Rapport, Seriennummer und Korrektur bestätigt.';

  @override
  String get qsoAdvancedPotaSummary => 'POTA-Übung: Rufzeichen, Rapport, Park und Korrektur bestätigt.';

  @override
  String get comprehensionTitle => 'Wörter und Sätze im Kopf hören';

  @override
  String get comprehensionIntro => 'Höre die ganze Nachricht, behalte ihren Sinn im Kopf und beantworte dann die Fragen. Alle Übungen sind eigens erstellt und offline verfügbar.';

  @override
  String get comprehensionModeLabel => 'Übungsart';

  @override
  String get comprehensionWords => 'Ganze Wörter';

  @override
  String get comprehensionPhrases => 'Wortteile und Sätze';

  @override
  String get comprehensionQso => 'QSO-Informationen';

  @override
  String get comprehensionPota => 'POTA-Austausch';

  @override
  String get comprehensionStory => 'Kurze Geschichten';

  @override
  String get comprehensionWordsHelp => 'Erkenne das ganze Wort am Klang, ohne jeden Buchstaben mitzuschreiben.';

  @override
  String get comprehensionPhrasesHelp => 'Erkenne vertraute Wortteile, dann kurze Ausdrücke und vollständige Sätze.';

  @override
  String get comprehensionQsoHelp => 'Merke dir Rufzeichen, Name, Ort und Signalrapport.';

  @override
  String get comprehensionPotaHelp => 'Merke dir beide Rufzeichen, die Parkkennung und den Signalrapport. Das erste Rufzeichen gehört der gerufenen Station.';

  @override
  String get comprehensionStoryHelp => 'Schreibe nicht mit. Merke dir wer, wohin, wann und wozu. Antworte mit den englischen Wörtern aus der Nachricht.';

  @override
  String get comprehensionSpeedLabel => 'Effektive Geschwindigkeit';

  @override
  String comprehensionSpeed(String character, String effective) {
    return 'Zeichen $character / effektiv $effective WPM';
  }

  @override
  String comprehensionPreviewMissing(String symbols) {
    return 'Die Nachricht enthält noch nicht gelernte Zeichen: $symbols. Du kannst sie als unterstützte Vorschau hören.';
  }

  @override
  String get comprehensionAssisted => 'Unterstützte Übung · Wiederholung, Textanzeige oder neue Zeichen';

  @override
  String get comprehensionIndependent => 'Unabhängiger Versuch · einmal gehört, ohne Textanzeige';

  @override
  String get comprehensionReveal => 'Text anzeigen (mit Hilfe)';

  @override
  String get comprehensionTarget => 'Sendetext';

  @override
  String get comprehensionAnswer => 'Wort oder Satz';

  @override
  String get comprehensionCallsign => 'Gerufene Station / Rufzeichen';

  @override
  String get comprehensionOtherCallsign => 'Sendende Station / Rufzeichen';

  @override
  String get comprehensionName => 'Name des Operators';

  @override
  String get comprehensionQth => 'Ort (QTH)';

  @override
  String get comprehensionRst => 'Signalrapport (RST)';

  @override
  String get comprehensionPark => 'Parkkennung';

  @override
  String get comprehensionPerson => 'Wer?';

  @override
  String get comprehensionDestination => 'Wohin ging die Person?';

  @override
  String get comprehensionTime => 'Wann?';

  @override
  String get comprehensionAction => 'Was wollte die Person tun?';

  @override
  String comprehensionScore(int correct, int total) {
    return '$correct von $total Informationsfeldern richtig';
  }

  @override
  String get comprehensionNext => 'Nächste Nachricht';

  @override
  String get comprehensionDone => 'Fertig';

  @override
  String get comprehensionSaveFailed => 'Das Ergebnis konnte nicht gespeichert werden. Versuche es vor dem Verlassen erneut.';

  @override
  String get comprehensionAudioFailed => 'Audio ist nicht verfügbar. Prüfe die Ausgabe und versuche es erneut.';

  @override
  String get comprehensionAudioRequired => 'Diese Hörübung verwendet Ton, auch wenn er in anderen Übungen deaktiviert ist.';

  @override
  String comprehensionHistory(int count, int percent) {
    return 'Letzte unabhängige Versuche: $count · Feldgenauigkeit $percent%';
  }

  @override
  String get comprehensionEmptyHistory => 'Hier erscheinen unabhängige Hörergebnisse. Unterstützte Übungen werden separat gespeichert.';

  @override
  String get comprehensionFieldCorrect => 'Richtig';

  @override
  String get comprehensionFieldWrong => 'Dieses Feld wiederholen';
}
