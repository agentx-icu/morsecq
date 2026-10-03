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
  String get navChat => 'Chat';

  @override
  String get navGroups => 'Gruppen';

  @override
  String get navMe => 'Ich';

  @override
  String get navReference => 'Nachschlagen';

  @override
  String get navLearnDescription => 'Lektionen nach der Koch-Methode, Gebeübungen und Hörtraining.';

  @override
  String get navChatDescription => 'Direkte Morsegespräche über Tox P2P ohne Server.';

  @override
  String get navGroupsDescription => 'Gruppenrunden – mehrere Funker morsen auf einem gemeinsamen Kanal.';

  @override
  String get navReferenceDescription => 'Alphabet, Verkehrszeichen, Q-Gruppen, Abkürzungen und Übersetzung in beide Richtungen.';

  @override
  String get navMeDescription => 'Dein Rufzeichen, deine Tox-Identität, Fortschritte und Einstellungen.';

  @override
  String get shellOfflineBanner => 'Offline: Keine Verbindung zum Tox-Netzwerk. Nachrichten werden gesendet, sobald du wieder online bist.';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionSearch => 'Suchen';

  @override
  String get actionSettings => 'Einstellungen';

  @override
  String get connectionConnecting => 'Verbindung wird hergestellt…';

  @override
  String get connectionOnline => 'Online';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get messageStatusPending => 'In Warteschlange – Kontakt ist offline';

  @override
  String get messageStatusPendingDetail => 'Tox hat keinen Server: Die Nachricht wird zugestellt, sobald der Kontakt online ist.';

  @override
  String get messageStatusSending => 'Wird gesendet';

  @override
  String get messageStatusSent => 'Gesendet';

  @override
  String get messageStatusFailed => 'Senden fehlgeschlagen';

  @override
  String get errorWrongPassword => 'Falsches Passwort. Versuche es erneut.';

  @override
  String get errorPeerOffline => 'Dieser Kontakt ist offline. Tox hat keinen Server, daher wartet die Nachricht, bis der Kontakt wieder online ist.';

  @override
  String get errorInvalidToxId => 'Dies ist keine gültige Tox-ID (76 Hexadezimalzeichen).';

  @override
  String get errorAlreadyFriend => 'Diese Tox-ID ist bereits in deiner Freundesliste.';

  @override
  String get errorOwnId => 'Das ist deine eigene Tox-ID.';

  @override
  String get errorGroupNotFound => 'Gruppe nicht gefunden.';

  @override
  String get errorMessageTooLong => 'Der Text ist zu lang für eine einzelne Tox-Nachricht.';

  @override
  String get errorUnknown => 'Ein Fehler ist aufgetreten';

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
  String get accountCopied => 'Tox-ID in die Zwischenablage kopiert';

  @override
  String get accountShowQr => 'QR-Code anzeigen';

  @override
  String get accountToxId => 'Tox-ID';

  @override
  String get accountDisplayName => 'Anzeigename';

  @override
  String get accountDisplayNameHint => 'Dein Rufzeichen oder Spitzname';

  @override
  String get accountDisplayNameRequired => 'Gib einen Anzeigenamen ein';

  @override
  String get accountStatusMessage => 'Statusnachricht';

  @override
  String get accountPassword => 'Passwort';

  @override
  String get accountPasswordOptional => 'Passwort (optional)';

  @override
  String get accountConfirmPassword => 'Passwort bestätigen';

  @override
  String get accountPasswordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get accountShowPassword => 'Passwort anzeigen';

  @override
  String get accountHidePassword => 'Passwort verbergen';

  @override
  String get accountStrengthWeak => 'Schwach: Verwende mindestens 8 Zeichen';

  @override
  String get accountStrengthFair => 'Mittel: Besser sind mindestens 12 Zeichen verschiedener Arten';

  @override
  String get accountStrengthStrong => 'Stark';

  @override
  String get accountStartupInspecting => 'Deine Identität wird geprüft…';

  @override
  String get accountStartupOpening => 'Deine Identität wird geöffnet…';

  @override
  String get accountStartupFailedTitle => 'Start fehlgeschlagen';

  @override
  String get accountStartupFailedBody => 'MorseCQ konnte deine Identität nicht lesen. Es wurde nichts geändert; versuche es erneut.';

  @override
  String get accountConnectionTapToReconnect => 'Tippen, um die Verbindung wiederherzustellen';

  @override
  String get accountWelcomeTitle => 'Deine Identität ist auf diesem Gerät gespeichert';

  @override
  String get accountWelcomeIntro => 'MorseCQ nutzt das Peer-to-Peer-Netzwerk Tox. Es gibt keinen Server und keine Registrierung: Deine Identität ist ein Schlüsselpaar, das nur hier gespeichert wird.';

  @override
  String get accountWelcomePointNoServer => 'Kein Server, keine Telefonnummer, keine E-Mail. Kontakte kommunizieren direkt miteinander in Morse.';

  @override
  String get accountWelcomePointTraining => 'Dein Lernfortschritt wird mit deiner Identität gespeichert und kann so gesichert und auf andere Geräte übertragen werden.';

  @override
  String get accountWelcomePointBackup => 'Niemand kann deine Identität für dich wiederherstellen. Sichere sie direkt nach dem Erstellen, sonst geht sie mit dem Gerät verloren.';

  @override
  String get accountCreateIdentity => 'Identität erstellen';

  @override
  String get accountRestoreFromBackup => 'Aus Sicherung wiederherstellen';

  @override
  String get accountCreateTitle => 'Deine Identität erstellen';

  @override
  String get accountCreateBody => 'Wähle einen Namen, den andere sehen. Ein Passwort verschlüsselt die Identitätsdatei auf diesem Gerät; lass das Feld leer, wenn du die App ohne Passwort öffnen möchtest.';

  @override
  String get accountCreateButton => 'Erstellen';

  @override
  String get accountCreating => 'Wird erstellt…';

  @override
  String get accountBackupTitle => 'Sichere jetzt deine Identität';

  @override
  String get accountBackupBody => 'Deine Identität existiert nur auf diesem Gerät. Geht das Gerät verloren, wird es zurückgesetzt oder gestohlen, kannst du sie nicht wiederherstellen: Deine Kontakte erkennen eine neue Identität nicht und dein Lernfortschritt geht verloren.';

  @override
  String get accountBackupWhatIsInside => 'Die Sicherungsdatei enthält deine verschlüsselte Identität und deinen Lernfortschritt. Bewahre sie an einem sicheren Ort außerhalb dieses Geräts auf.';

  @override
  String get accountBackupSaveFile => 'Sicherungsdatei speichern';

  @override
  String get accountBackupShareFile => 'Sicherungsdatei teilen';

  @override
  String get accountBackupSaved => 'Sicherung gespeichert';

  @override
  String get accountBackupNotSaved => 'Sicherung wurde nicht gespeichert';

  @override
  String get accountBackupFailed => 'Sicherung konnte nicht geschrieben werden';

  @override
  String get accountBackupAcknowledge => 'Ich verstehe, dass meine Identität ohne diese Sicherung nicht wiederhergestellt werden kann.';

  @override
  String get accountBackupContinue => 'Weiter zu MorseCQ';

  @override
  String get accountBackupShowQrHint => 'Über deine Tox-ID können dich Freunde hinzufügen. Teile sie als Text oder QR-Code.';

  @override
  String get accountRestoreTitle => 'Aus Sicherung wiederherstellen';

  @override
  String get accountRestoreBody => 'Wähle eine aus MorseCQ exportierte Sicherungsdatei. War die Identität mit einem Passwort geschützt, benötigst du es hier.';

  @override
  String get accountRestoreChooseFile => 'Sicherungsdatei wählen';

  @override
  String get accountRestoreNoFile => 'Wähle zuerst eine Sicherungsdatei';

  @override
  String get accountRestoreButton => 'Wiederherstellen';

  @override
  String get accountRestoring => 'Wird wiederhergestellt…';

  @override
  String get accountRestoreInvalidFile => 'Diese Datei ist keine MorseCQ-Sicherung.';

  @override
  String get accountRestoreReplacesWarning => 'Die Wiederherstellung ersetzt die aktuelle Identität auf diesem Gerät.';

  @override
  String get accountUnlockTitle => 'Deine Identität entsperren';

  @override
  String get accountUnlockBody => 'Deine Identitätsdatei ist verschlüsselt. Gib das Passwort ein, um fortzufahren.';

  @override
  String get accountUnlockButton => 'Entsperren';

  @override
  String get accountUnlocking => 'Wird entsperrt…';

  @override
  String get accountUnlockRestoreInstead => 'Stattdessen aus Sicherung wiederherstellen';

  @override
  String get accountMeNoIdentity => 'Keine Identität geladen';

  @override
  String get accountSectionAccount => 'Konto';

  @override
  String get accountSectionTraining => 'Training';

  @override
  String get accountSectionAbout => 'Über';

  @override
  String get accountSectionDanger => 'Gefahrenbereich';

  @override
  String get accountEditProfile => 'Profil bearbeiten';

  @override
  String get accountEditProfileBody => 'Wird deinen Kontakten im Tox-Netzwerk angezeigt.';

  @override
  String get accountSetPassword => 'Passwort festlegen';

  @override
  String get accountChangePassword => 'Passwort ändern';

  @override
  String get accountRemovePassword => 'Passwort entfernen';

  @override
  String get accountCurrentPassword => 'Aktuelles Passwort';

  @override
  String get accountNewPassword => 'Neues Passwort';

  @override
  String get accountPasswordUpdated => 'Passwort aktualisiert';

  @override
  String get accountPasswordRemoved => 'Passwort entfernt';

  @override
  String get accountProfileUpdated => 'Profil aktualisiert';

  @override
  String get accountExportBackup => 'Sicherung exportieren';

  @override
  String get accountExportBackupSubtitle => 'Identität und Lernfortschritt in einer Datei speichern';

  @override
  String get accountTrainingDefaults => 'Standardwerte für Wiedergabe und Training';

  @override
  String get accountTrainingDefaultsSubtitle => 'Geschwindigkeit, Tonhöhe, Farnsworth-Abstände';

  @override
  String get accountTrainingDefaultsPlaceholder => 'Hier werden die Standardwerte für Geschwindigkeit, Tonhöhe und Farnsworth eingestellt.';

  @override
  String get accountAboutLicence => 'Lizenz';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Quellcode';

  @override
  String get accountAboutSourceCopied => 'Quellcode-Link kopiert';

  @override
  String get accountAboutBackend => 'Backend';

  @override
  String get accountDeleteIdentity => 'Identität löschen';

  @override
  String get accountDeleteIdentitySubtitle => 'Diese Identität, den Verlauf und Fortschritt von diesem Gerät löschen';

  @override
  String get accountDeleteDialogTitle => 'Diese Identität löschen?';

  @override
  String get accountDeleteDialogBody => 'Dadurch werden deine Identität, dein Chatverlauf und dein Lernfortschritt von diesem Gerät gelöscht. Ohne Sicherung ist keine Wiederherstellung möglich. Gib zur Bestätigung DELETE ein.';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => 'DELETE eingeben';

  @override
  String get accountDeleteButton => 'Löschen';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return 'Sicherungsdatei ausgewählt ($bytes Bytes)';
  }

  @override
  String get chatSearchConversations => 'Gespräche durchsuchen';

  @override
  String get chatNoConversations => 'Noch keine Gespräche';

  @override
  String get chatNoSearchResults => 'Keine passenden Gespräche';

  @override
  String get chatPin => 'Anheften';

  @override
  String get chatUnpin => 'Lösen';

  @override
  String get chatMarkRead => 'Als gelesen markieren';

  @override
  String get chatDelete => 'Löschen';

  @override
  String get chatDeleteConversationTitle => 'Gespräch löschen?';

  @override
  String get chatDeleteConversationBody => 'Der lokale Verlauf dieses Gesprächs wird gelöscht. Tox speichert keine Kopie.';

  @override
  String get chatDraftPrefix => 'Entwurf: ';

  @override
  String get chatSelectConversation => 'Wähle ein Gespräch';

  @override
  String get chatContacts => 'Kontakte';

  @override
  String get chatNoMessages => 'Noch keine Nachrichten – sende CQ zum Starten.';

  @override
  String get chatTrainingMode => 'Trainingsmodus';

  @override
  String get chatTrainingModeOn => 'Trainingsmodus an: Text verborgen';

  @override
  String get chatTrainingModeOff => 'Trainingsmodus aus';

  @override
  String get chatAutoPlay => 'Empfangene Morsezeichen automatisch abspielen';

  @override
  String get chatAutoPlayOn => 'Automatische Wiedergabe an: neue Nachrichten werden beim Eintreffen abgespielt';

  @override
  String get chatAutoPlayOff => 'Automatische Wiedergabe aus';

  @override
  String get chatReveal => 'Einblenden';

  @override
  String get chatHiddenText => 'Erst hören, dann einblenden';

  @override
  String get chatPlay => 'Morse abspielen';

  @override
  String get chatStop => 'Stoppen';

  @override
  String get chatPlaybackSettings => 'Wiedergabeeinstellungen';

  @override
  String get chatCharacterSpeed => 'Zeichengeschwindigkeit';

  @override
  String get chatFarnsworthSpeed => 'Farnsworth-Geschwindigkeit';

  @override
  String get chatTone => 'Tonhöhe';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => 'Mitglieder';

  @override
  String get chatLeaveGroup => 'Gruppe verlassen';

  @override
  String get chatLeaveGroupTitle => 'Diese Gruppe verlassen?';

  @override
  String get chatLeaveGroupBody => 'Du empfängst keine Nachrichten mehr. Mit der Chat-ID kannst du später wieder beitreten.';

  @override
  String get chatLeave => 'Verlassen';

  @override
  String get chatConferenceNote => 'Klassische Konferenz: Morse-Tastdaten (v2) sind hier nicht verfügbar. Textnachrichten funktionieren weiterhin.';

  @override
  String get chatClearHistory => 'Verlauf löschen';

  @override
  String get chatModeStraightKey => 'Handtaste';

  @override
  String get chatModePaddles => 'Paddles';

  @override
  String get chatKeyMessage => 'Nachricht morsen';

  @override
  String get chatSend => 'Senden';

  @override
  String get chatTooLong => 'Zu lang für eine einzelne Tox-Nachricht';

  @override
  String get chatKeyHint => 'Auf der Taste morsen oder die Leertaste drücken';

  @override
  String get chatPaddleHint => 'Tippe auf die Paddles oder halte Ctrl gedrückt (links Punkt, rechts Strich)';

  @override
  String get chatDeleteLast => 'Letztes Zeichen löschen';

  @override
  String get chatNoFriends => 'Noch keine Freunde. Füge jemanden über die Tox-ID hinzu.';

  @override
  String get chatNoRequests => 'Keine offenen Anfragen';

  @override
  String get chatAddFriend => 'Freund hinzufügen';

  @override
  String get chatMyToxId => 'Meine Tox-ID';

  @override
  String get chatToxIdLabel => 'Tox-ID (76 Hexadezimalzeichen)';

  @override
  String get chatToxIdInvalid => 'Die Tox-ID muss genau 76 Hexadezimalzeichen lang sein';

  @override
  String get chatToxIdOwn => 'Das ist deine eigene Tox-ID';

  @override
  String get chatToxIdAlreadyFriend => 'Bereits in deiner Freundesliste';

  @override
  String get chatRequestMessage => 'Nachricht';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => 'Anfrage senden';

  @override
  String get chatRequestSent => 'Freundschaftsanfrage gesendet';

  @override
  String get chatScanQr => 'QR-Code scannen';

  @override
  String get chatScanQrDesktopHint => 'Zum Scannen von QR-Codes ist eine Handykamera erforderlich';

  @override
  String get chatScanQrTitle => 'Tox-ID scannen';

  @override
  String get chatScanQrNotToxId => 'Dieser QR-Code ist keine Tox-ID';

  @override
  String get chatAccept => 'Annehmen';

  @override
  String get chatReject => 'Ablehnen';

  @override
  String get chatCopied => 'In die Zwischenablage kopiert';

  @override
  String get chatNoIdentity => 'Keine Identität geladen';

  @override
  String get chatRemoveFriend => 'Freund entfernen';

  @override
  String get chatRemoveFriendTitle => 'Diesen Freund entfernen?';

  @override
  String get chatRemoveFriendBody => 'Diese Person kann dir danach keine Nachrichten mehr senden.';

  @override
  String get chatRemove => 'Entfernen';

  @override
  String get chatNoGroups => 'Noch keine Gruppen. Erstelle eine oder tritt über eine Chat-ID bei.';

  @override
  String get chatCreateGroup => 'Gruppe erstellen';

  @override
  String get chatJoinGroup => 'Gruppe beitreten';

  @override
  String get chatGroupName => 'Gruppenname';

  @override
  String get chatGroupNameRequired => 'Gib der Gruppe einen Namen';

  @override
  String get chatAdvanced => 'Erweitert';

  @override
  String get chatLegacyConference => 'Klassische Konferenz (ältere Clients)';

  @override
  String get chatLegacyConferenceHint => 'Nicht empfohlen: keine dauerhafte Chat-ID, keine Morse-Metadaten.';

  @override
  String get chatCreate => 'Erstellen';

  @override
  String get chatChatIdLabel => 'Chat-ID (64 Hexadezimalzeichen)';

  @override
  String get chatChatIdInvalid => 'Die Chat-ID muss genau 64 Hexadezimalzeichen lang sein';

  @override
  String get chatPassword => 'Passwort (optional)';

  @override
  String get chatJoin => 'Beitreten';

  @override
  String get chatJoinRequested => 'Beitritt läuft – die Gruppe erscheint, sobald ein Teilnehmer gefunden wurde.';

  @override
  String get chatConferenceBadge => 'Konferenz';

  @override
  String get chatCopyChatId => 'Chat-ID kopieren';

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
  String get learnIdentityRequired => 'Erstelle oder entsperre deine Identität, um mit dem Training zu beginnen. Dein Fortschritt wird mit der Identität gespeichert und mit deiner Sicherung übertragen.';

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
  String get notificationOpen => 'Öffnen';

  @override
  String get notificationChannelMessages => 'Nachrichten';

  @override
  String get notificationChannelMessagesDescription => 'Neue Morsenachrichten von Freunden und Gruppen';

  @override
  String get notificationChannelFriendRequests => 'Freundschaftsanfragen';

  @override
  String get notificationChannelFriendRequestsDescription => 'Jemand möchte dich als Freund hinzufügen';

  @override
  String get notificationChannelGroupInvites => 'Gruppeneinladungen';

  @override
  String get notificationChannelGroupInvitesDescription => 'Ein Freund hat dich in eine Gruppe eingeladen';

  @override
  String get notificationNewMessage => 'Neue Nachricht';

  @override
  String get notificationFriendRequestTitle => 'Neue Freundschaftsanfrage';

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
  String get accountNewPasswordRequired => 'Gib ein neues Passwort ein';

  @override
  String get accountToxIdQrSemantics => 'QR-Code der Tox-ID';

  @override
  String get accountBackupSaveDialogTitle => 'MorseCQ-Sicherung speichern';

  @override
  String get accountBackupShareSubject => 'MorseCQ-Identitätssicherung';

  @override
  String get accountBackupChooseDialogTitle => 'MorseCQ-Sicherung wählen';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Nachrichten',
      one: '$count neue Nachricht',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return 'Freundschaftsanfrage von $name';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name: $message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return 'Einladung zu $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name hat dich eingeladen';
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
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten',
      one: '$count ungelesene Nachricht',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => 'An';

  @override
  String get listenStateOff => 'Aus';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bytes übrig',
      one: '$count Byte übrig',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '$count Mitglied',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return 'Freunde ($count)';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return 'Freundschaftsanfragen ($count)';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return 'Gruppeneinladungen ($count)';
  }

  @override
  String chatMembersTitleCount(int count) {
    return 'Mitglieder · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return 'Eingeladen von $name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name (Du)';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label: $value $unit';
  }

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
  String get appearanceSubtitle => 'Fünf Stile mit hellem und dunklem Modus';

  @override
  String get chatClearHistoryBody => 'Den Verlauf dieses Gesprächs auf diesem Gerät löschen? Kopien auf anderen Geräten sind nicht betroffen. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get chatLoadEarlier => 'Ältere Nachrichten laden';

  @override
  String get chatHistoryLoadFailed => 'Ältere Nachrichten konnten nicht geladen werden. Tippe, um es erneut zu versuchen.';

  @override
  String get chatRetryHistory => 'Erneut versuchen';

  @override
  String chatNewMessages(int count) {
    return '$count neue Nachrichten';
  }

  @override
  String learnShowAllChars(int count) {
    return 'Alle $count Zeichen anzeigen';
  }

  @override
  String get chatSelfMe => 'Ich';

  @override
  String get chatSelfLocalOnly => 'Nur auf diesem Gerät gespeichert';

  @override
  String get chatSelfContactSubtitle => 'Entwürfe, Übungen und Notizen · werden nie gesendet';

  @override
  String get learnShowFewerChars => 'Weniger Zeichen anzeigen';

  @override
  String get learnLeaveDrillTitle => 'Diese Übung verlassen?';

  @override
  String get learnLeaveDrillBody => 'Die Runden dieser Übung werden nicht gespeichert.';

  @override
  String get learnLeaveDrillConfirm => 'Verlassen';

  @override
  String get chatScanQrPermissionDenied => 'MorseCQ benötigt Kamerazugriff, um einen QR-Code zu scannen. Erlaube ihn in den Systemeinstellungen.';

  @override
  String get chatScanQrCameraUnavailable => 'Die Kamera ist auf diesem Gerät nicht verfügbar.';
}
