// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => 'Apprendre';

  @override
  String get navChat => 'Discussion';

  @override
  String get navGroups => 'Groupes';

  @override
  String get navMe => 'Moi';

  @override
  String get navReference => 'Référence';

  @override
  String get navLearnDescription => 'Leçons selon la méthode Koch, exercices de manipulation et de réception.';

  @override
  String get navChatDescription => 'Conversations en Morse à deux via Tox P2P, sans serveur.';

  @override
  String get navGroupsDescription => 'Réseaux de groupe : plusieurs opérateurs transmettent sur un canal commun.';

  @override
  String get navReferenceDescription => 'Alphabet, signaux de procédure, codes Q, abréviations et traduction dans les deux sens.';

  @override
  String get navMeDescription => 'Votre indicatif, votre identité Tox, votre progression et vos réglages.';

  @override
  String get shellOfflineBanner => 'Hors ligne : aucune connexion au réseau Tox. Les messages seront envoyés dès votre retour en ligne.';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionSettings => 'Réglages';

  @override
  String get connectionConnecting => 'Connexion…';

  @override
  String get connectionOnline => 'En ligne';

  @override
  String get connectionOffline => 'Hors ligne';

  @override
  String get messageStatusPending => 'En attente : le contact est hors ligne';

  @override
  String get messageStatusPendingDetail => 'Tox n’a pas de serveur : le message sera remis dès que le contact sera en ligne.';

  @override
  String get messageStatusSending => 'Envoi en cours';

  @override
  String get messageStatusSent => 'Envoyé';

  @override
  String get messageStatusFailed => 'Échec de l’envoi';

  @override
  String get errorWrongPassword => 'Mot de passe incorrect. Réessayez.';

  @override
  String get errorPeerOffline => 'Ce contact est hors ligne. Tox n’a pas de serveur ; le message attendra son retour.';

  @override
  String get errorInvalidToxId => 'Cet identifiant Tox n’est pas valide (76 caractères hexadécimaux).';

  @override
  String get errorAlreadyFriend => 'Cet identifiant Tox figure déjà dans votre liste d’amis.';

  @override
  String get errorOwnId => 'Il s’agit de votre propre identifiant Tox.';

  @override
  String get errorGroupNotFound => 'Groupe introuvable.';

  @override
  String get errorMessageTooLong => 'Le texte est trop long pour un seul message Tox.';

  @override
  String get errorUnknown => 'Une erreur est survenue';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystemDefault => 'Langue du système';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'Leçon $lesson sur $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères appris',
      one: '$count caractère appris',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal caractères';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours consécutifs',
      one: '$days jour consécutif',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count révisions à faire',
      one: '$count révision à faire',
      zero: 'Aucune révision à faire',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$correct bonnes réponses sur $total';
  }

  @override
  String learnRoundOf(int round) {
    return 'Série $round';
  }

  @override
  String learnAccuracyPercent(int percent) {
    return '$percent %';
  }

  @override
  String learnCharsSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères envoyés',
      one: '$count caractère envoyé',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return 'Caractère suivant débloqué : $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target manqué';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target entendu comme $answered';
  }

  @override
  String learnWpmValue(String wpm) {
    return '$wpm wpm';
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
      other: '$count caractères',
      one: '$count caractère',
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
      other: '$count caractères appris',
      one: '$count caractère appris',
    );
    return '$_temp0';
  }

  @override
  String statsPercent(String percent) {
    return '$percent %';
  }

  @override
  String statsCharsCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères reçus',
      one: '$count caractère reçu',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances',
      one: '$count séance',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'record : $count jours',
      one: 'record : $count jour',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal caractères';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Encore $remaining caractères',
      one: 'Encore $remaining caractère',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dernières $count séances',
      one: 'Dernière séance',
      zero: 'Aucune séance',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return 'Séance $index sur $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total bonnes réponses';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'Leçon $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count essais',
      one: '$count essai',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$correct bonnes réponses sur $attempts';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'Introduit à la leçon $lesson';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'Boîte $box sur $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'À revoir dans $days jours',
      one: 'À revoir dans $days jour',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '$count fois',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '$count fois',
    );
    return '$target répondu comme $answered, $_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars caractères',
      one: '$chars caractère',
      zero: 'aucun exercice',
    );
    return '$date : $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours actifs',
      one: '$count jour actif',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
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
    return 'Ignorés (sans code Morse) : $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Position dans la méthode Koch : $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return 'Estimation : $wpm WPM';
  }

  @override
  String get accountCopied => 'Identifiant Tox copié dans le presse-papiers';

  @override
  String get accountShowQr => 'Afficher le code QR';

  @override
  String get accountToxId => 'Identifiant Tox';

  @override
  String get accountDisplayName => 'Nom affiché';

  @override
  String get accountDisplayNameHint => 'Votre indicatif ou surnom';

  @override
  String get accountDisplayNameRequired => 'Saisissez un nom à afficher';

  @override
  String get accountStatusMessage => 'Message de statut';

  @override
  String get accountPassword => 'Mot de passe';

  @override
  String get accountPasswordOptional => 'Mot de passe (facultatif)';

  @override
  String get accountConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get accountPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get accountShowPassword => 'Afficher le mot de passe';

  @override
  String get accountHidePassword => 'Masquer le mot de passe';

  @override
  String get accountStrengthWeak => 'Faible : utilisez au moins 8 caractères';

  @override
  String get accountStrengthFair => 'Moyen : préférez au moins 12 caractères de types différents';

  @override
  String get accountStrengthStrong => 'Fort';

  @override
  String get accountStartupInspecting => 'Vérification de votre identité…';

  @override
  String get accountStartupOpening => 'Ouverture de votre identité…';

  @override
  String get accountStartupFailedTitle => 'Démarrage impossible';

  @override
  String get accountStartupFailedBody => 'MorseCQ n’a pas pu lire votre identité. Rien n’a été modifié ; vous pouvez réessayer.';

  @override
  String get accountConnectionTapToReconnect => 'Touchez pour vous reconnecter';

  @override
  String get accountWelcomeTitle => 'Votre identité réside sur cet appareil';

  @override
  String get accountWelcomeIntro => 'MorseCQ utilise le réseau pair à pair Tox. Il n’y a ni serveur ni compte à créer : votre identité est une paire de clés stockée uniquement ici.';

  @override
  String get accountWelcomePointNoServer => 'Aucun serveur, numéro de téléphone ni adresse e-mail. Les contacts communiquent directement entre eux, en Morse.';

  @override
  String get accountWelcomePointTraining => 'Votre progression est enregistrée avec votre identité pour pouvoir être sauvegardée et transférée entre appareils.';

  @override
  String get accountWelcomePointBackup => 'Personne ne peut récupérer votre identité à votre place. Sauvegardez-la dès sa création pour ne pas la perdre avec l’appareil.';

  @override
  String get accountCreateIdentity => 'Créer une identité';

  @override
  String get accountRestoreFromBackup => 'Restaurer une sauvegarde';

  @override
  String get accountCreateTitle => 'Créer votre identité';

  @override
  String get accountCreateBody => 'Choisissez un nom que les autres verront. Un mot de passe chiffre le fichier d’identité sur cet appareil ; laissez le champ vide si vous préférez ouvrir l’application sans mot de passe.';

  @override
  String get accountCreateButton => 'Créer';

  @override
  String get accountCreating => 'Création…';

  @override
  String get accountBackupTitle => 'Sauvegardez votre identité maintenant';

  @override
  String get accountBackupBody => 'Votre identité existe uniquement sur cet appareil. S’il est perdu, réinitialisé ou volé, elle sera irrécupérable : vos contacts ne reconnaîtront pas une nouvelle identité et votre progression sera perdue.';

  @override
  String get accountBackupWhatIsInside => 'Le fichier de sauvegarde contient votre identité chiffrée et votre progression. Conservez-le en lieu sûr, ailleurs que sur cet appareil.';

  @override
  String get accountBackupSaveFile => 'Enregistrer le fichier de sauvegarde';

  @override
  String get accountBackupShareFile => 'Partager le fichier de sauvegarde';

  @override
  String get accountBackupSaved => 'Sauvegarde enregistrée';

  @override
  String get accountBackupNotSaved => 'La sauvegarde n’a pas été enregistrée';

  @override
  String get accountBackupFailed => 'Impossible d’écrire la sauvegarde';

  @override
  String get accountBackupAcknowledge => 'Je comprends que sans cette sauvegarde, mon identité sera irrécupérable.';

  @override
  String get accountBackupContinue => 'Continuer vers MorseCQ';

  @override
  String get accountBackupShowQrHint => 'Vos amis vous ajoutent grâce à votre identifiant Tox. Partagez-le sous forme de texte ou de code QR.';

  @override
  String get accountRestoreTitle => 'Restaurer une sauvegarde';

  @override
  String get accountRestoreBody => 'Choisissez un fichier de sauvegarde exporté depuis MorseCQ. Si l’identité était protégée par un mot de passe, vous devrez le saisir ici.';

  @override
  String get accountRestoreChooseFile => 'Choisir un fichier de sauvegarde';

  @override
  String get accountRestoreNoFile => 'Choisissez d’abord un fichier de sauvegarde';

  @override
  String get accountRestoreButton => 'Restaurer';

  @override
  String get accountRestoring => 'Restauration…';

  @override
  String get accountRestoreInvalidFile => 'Ce fichier n’est pas une sauvegarde MorseCQ.';

  @override
  String get accountRestoreReplacesWarning => 'La restauration remplace l’identité actuellement sur cet appareil.';

  @override
  String get accountUnlockTitle => 'Déverrouiller votre identité';

  @override
  String get accountUnlockBody => 'Votre fichier d’identité est chiffré. Saisissez le mot de passe pour continuer.';

  @override
  String get accountUnlockButton => 'Déverrouiller';

  @override
  String get accountUnlocking => 'Déverrouillage…';

  @override
  String get accountUnlockRestoreInstead => 'Restaurer plutôt une sauvegarde';

  @override
  String get accountMeNoIdentity => 'Aucune identité chargée';

  @override
  String get accountSectionAccount => 'Compte';

  @override
  String get accountSectionTraining => 'Entraînement';

  @override
  String get accountSectionAbout => 'À propos';

  @override
  String get accountSectionDanger => 'Zone de danger';

  @override
  String get accountEditProfile => 'Modifier le profil';

  @override
  String get accountEditProfileBody => 'Visible par vos contacts sur le réseau Tox.';

  @override
  String get accountSetPassword => 'Définir un mot de passe';

  @override
  String get accountChangePassword => 'Changer le mot de passe';

  @override
  String get accountRemovePassword => 'Supprimer le mot de passe';

  @override
  String get accountCurrentPassword => 'Mot de passe actuel';

  @override
  String get accountNewPassword => 'Nouveau mot de passe';

  @override
  String get accountPasswordUpdated => 'Mot de passe mis à jour';

  @override
  String get accountPasswordRemoved => 'Mot de passe supprimé';

  @override
  String get accountProfileUpdated => 'Profil mis à jour';

  @override
  String get accountExportBackup => 'Exporter une sauvegarde';

  @override
  String get accountExportBackupSubtitle => 'Enregistrer votre identité et votre progression dans un fichier';

  @override
  String get accountTrainingDefaults => 'Réglages de lecture et d’entraînement par défaut';

  @override
  String get accountTrainingDefaultsSubtitle => 'Vitesse, tonalité et espacement Farnsworth';

  @override
  String get accountTrainingDefaultsPlaceholder => 'Les réglages de vitesse, de tonalité et de Farnsworth par défaut seront disponibles ici.';

  @override
  String get accountAboutLicence => 'Licence';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Code source';

  @override
  String get accountAboutSourceCopied => 'Lien du code source copié';

  @override
  String get accountAboutBackend => 'Moteur';

  @override
  String get accountDeleteIdentity => 'Supprimer l’identité';

  @override
  String get accountDeleteIdentitySubtitle => 'Effacer cette identité, l’historique et la progression de cet appareil';

  @override
  String get accountDeleteDialogTitle => 'Supprimer cette identité ?';

  @override
  String get accountDeleteDialogBody => 'Votre identité, votre historique de discussion et votre progression seront supprimés de cet appareil. Sans sauvegarde, ils seront irrécupérables. Saisissez DELETE pour confirmer.';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => 'Saisissez DELETE';

  @override
  String get accountDeleteButton => 'Supprimer';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return 'Fichier de sauvegarde sélectionné ($bytes octets)';
  }

  @override
  String get chatSearchConversations => 'Rechercher des conversations';

  @override
  String get chatNoConversations => 'Aucune conversation pour l’instant';

  @override
  String get chatNoSearchResults => 'Aucune conversation correspondante';

  @override
  String get chatPin => 'Épingler';

  @override
  String get chatUnpin => 'Désépingler';

  @override
  String get chatMarkRead => 'Marquer comme lu';

  @override
  String get chatDelete => 'Supprimer';

  @override
  String get chatDeleteConversationTitle => 'Supprimer la conversation ?';

  @override
  String get chatDeleteConversationBody => 'L’historique local de cette conversation sera supprimé. Tox n’en conserve aucune copie.';

  @override
  String get chatDraftPrefix => 'Brouillon : ';

  @override
  String get chatSelectConversation => 'Sélectionnez une conversation';

  @override
  String get chatContacts => 'Contacts';

  @override
  String get chatNoMessages => 'Aucun message pour l’instant : envoyez CQ pour commencer.';

  @override
  String get chatTrainingMode => 'Mode entraînement';

  @override
  String get chatTrainingModeOn => 'Mode entraînement activé : texte masqué';

  @override
  String get chatTrainingModeOff => 'Mode entraînement désactivé';

  @override
  String get chatAutoPlay => 'Lire automatiquement le morse reçu';

  @override
  String get chatAutoPlayOn => 'Lecture auto activée : les nouveaux messages sont lus à leur arrivée';

  @override
  String get chatAutoPlayOff => 'Lecture auto désactivée';

  @override
  String get chatReveal => 'Révéler';

  @override
  String get chatHiddenText => 'Écoutez d’abord, puis révélez le texte';

  @override
  String get chatPlay => 'Écouter le Morse';

  @override
  String get chatStop => 'Arrêter';

  @override
  String get chatPlaybackSettings => 'Réglages de lecture';

  @override
  String get chatCharacterSpeed => 'Vitesse des caractères';

  @override
  String get chatFarnsworthSpeed => 'Vitesse Farnsworth';

  @override
  String get chatTone => 'Tonalité';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => 'Membres';

  @override
  String get chatLeaveGroup => 'Quitter le groupe';

  @override
  String get chatLeaveGroupTitle => 'Quitter ce groupe ?';

  @override
  String get chatLeaveGroupBody => 'Vous ne recevrez plus de messages. Vous pourrez revenir avec l’identifiant de discussion.';

  @override
  String get chatLeave => 'Quitter';

  @override
  String get chatConferenceNote => 'Conférence ancienne : les métadonnées de manipulation Morse (v2) ne sont pas disponibles ici. Les messages texte fonctionnent toujours.';

  @override
  String get chatClearHistory => 'Effacer l’historique';

  @override
  String get chatModeStraightKey => 'Pioche';

  @override
  String get chatModePaddles => 'Palettes';

  @override
  String get chatKeyMessage => 'Manipulez votre message';

  @override
  String get chatSend => 'Envoyer';

  @override
  String get chatTooLong => 'Trop long pour un seul message Tox';

  @override
  String get chatKeyHint => 'Manipulez sur la zone de saisie ou appuyez sur Espace';

  @override
  String get chatPaddleHint => 'Touchez les palettes ou maintenez Ctrl (gauche : point, droite : trait)';

  @override
  String get chatDeleteLast => 'Supprimer le dernier caractère';

  @override
  String get chatNoFriends => 'Aucun ami pour l’instant. Ajoutez-en un avec son identifiant Tox.';

  @override
  String get chatNoRequests => 'Aucune demande en attente';

  @override
  String get chatAddFriend => 'Ajouter un ami';

  @override
  String get chatMyToxId => 'Mon identifiant Tox';

  @override
  String get chatToxIdLabel => 'Identifiant Tox (76 caractères hexadécimaux)';

  @override
  String get chatToxIdInvalid => 'L’identifiant Tox doit comporter exactement 76 caractères hexadécimaux';

  @override
  String get chatToxIdOwn => 'Il s’agit de votre propre identifiant Tox';

  @override
  String get chatToxIdAlreadyFriend => 'Déjà dans votre liste d’amis';

  @override
  String get chatRequestMessage => 'Message';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => 'Envoyer la demande';

  @override
  String get chatRequestSent => 'Demande d’ami envoyée';

  @override
  String get chatScanQr => 'Scanner un code QR';

  @override
  String get chatScanQrDesktopHint => 'La lecture des codes QR nécessite une caméra de téléphone';

  @override
  String get chatScanQrTitle => 'Scanner un identifiant Tox';

  @override
  String get chatScanQrNotToxId => 'Ce code QR n’est pas un identifiant Tox';

  @override
  String get chatAccept => 'Accepter';

  @override
  String get chatReject => 'Refuser';

  @override
  String get chatCopied => 'Copié dans le presse-papiers';

  @override
  String get chatNoIdentity => 'Aucune identité chargée';

  @override
  String get chatRemoveFriend => 'Retirer un ami';

  @override
  String get chatRemoveFriendTitle => 'Retirer cet ami ?';

  @override
  String get chatRemoveFriendBody => 'Cette personne ne pourra plus vous envoyer de messages.';

  @override
  String get chatRemove => 'Retirer';

  @override
  String get chatNoGroups => 'Aucun groupe pour l’instant. Créez-en un ou rejoignez-en un avec son identifiant de discussion.';

  @override
  String get chatCreateGroup => 'Créer un groupe';

  @override
  String get chatJoinGroup => 'Rejoindre un groupe';

  @override
  String get chatGroupName => 'Nom du groupe';

  @override
  String get chatGroupNameRequired => 'Donnez un nom au groupe';

  @override
  String get chatAdvanced => 'Avancé';

  @override
  String get chatLegacyConference => 'Conférence ancienne (anciens clients)';

  @override
  String get chatLegacyConferenceHint => 'Déconseillé : aucun identifiant de discussion permanent ni métadonnées Morse.';

  @override
  String get chatCreate => 'Créer';

  @override
  String get chatChatIdLabel => 'Identifiant de discussion (64 caractères hexadécimaux)';

  @override
  String get chatChatIdInvalid => 'L’identifiant de discussion doit comporter exactement 64 caractères hexadécimaux';

  @override
  String get chatPassword => 'Mot de passe (facultatif)';

  @override
  String get chatJoin => 'Rejoindre';

  @override
  String get chatJoinRequested => 'Connexion au groupe : il apparaîtra dès qu’un pair sera trouvé.';

  @override
  String get chatConferenceBadge => 'Conférence';

  @override
  String get chatCopyChatId => 'Copier l’identifiant de discussion';

  @override
  String get learnLessonCardTitle => 'Leçon Koch';

  @override
  String get learnCourseComplete => 'Cours terminé : continuez à vous perfectionner !';

  @override
  String get learnDailyGoalTitle => 'Aujourd’hui';

  @override
  String get learnDailyGoalMet => 'Objectif quotidien atteint';

  @override
  String get learnNoStreak => 'Commencez une série aujourd’hui';

  @override
  String get learnContinueLesson => 'Continuer la leçon';

  @override
  String get learnReceivePractice => 'Exercice de réception';

  @override
  String get learnSendPractice => 'Exercice de transmission';

  @override
  String get learnReviewDue => 'Réviser les caractères à revoir';

  @override
  String get learnSettings => 'Réglages d’entraînement';

  @override
  String get learnLoading => 'Chargement de votre progression…';

  @override
  String get learnIdentityRequired => 'Créez ou déverrouillez votre identité pour commencer l’entraînement. Votre progression est enregistrée avec votre identité et suit votre sauvegarde.';

  @override
  String get learnLoadFailed => 'Votre progression enregistrée n’a pas pu être lue. Vous repartez de zéro ; l’ancien fichier a été conservé avec le suffixe .corrupt.';

  @override
  String get learnChooseDrill => 'Choisir un exercice';

  @override
  String get learnDrillGroups => 'Groupes aléatoires';

  @override
  String get learnDrillWords => 'Mots';

  @override
  String get learnDrillCallsigns => 'Indicatifs';

  @override
  String get learnDrillQso => 'QSO';

  @override
  String get learnDrillCharacters => 'Caractères isolés';

  @override
  String get learnDrillAbbreviations => 'Abréviations et codes Q';

  @override
  String get learnDrillNumbers => 'Groupes de chiffres';

  @override
  String get learnDrillConfusables => 'Caractères proches';

  @override
  String get learnDrillContest => 'Échanges de concours';

  @override
  String get learnDrillGroupsHint => 'Groupes aléatoires avec les lettres que vous connaissez';

  @override
  String get learnDrillCharactersHint => 'Un caractère à la fois : reconnaissez-le aussitôt';

  @override
  String get learnDrillWordsHint => 'Mots anglais courants';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL : les raccourcis des ondes';

  @override
  String get learnDrillNumbersHint => 'Groupes de cinq chiffres, comme dans les messages et numéros de série';

  @override
  String get learnDrillCallsignsHint => 'Indicatifs radioamateurs du monde entier';

  @override
  String get learnDrillConfusablesHint => 'Comparez les paires que vous confondez, comme S/H ou U/V';

  @override
  String get learnDrillQsoHint => 'Phrases d’un contact complet';

  @override
  String get learnDrillContestHint => 'Indicatif, 5NN et numéro de série ou zone, au rythme d’un concours';

  @override
  String get learnDrillReviewHint => 'Caractères à revoir';

  @override
  String get toolsTitle => 'Outils radio';

  @override
  String get toolsGridTitle => 'Localisateur';

  @override
  String get toolsGridHint => 'Localisateur à partir des coordonnées, distance et azimut';

  @override
  String get toolsBandsTitle => 'Bandes et antennes';

  @override
  String get toolsBandsHint => 'Bande d’une fréquence, longueur d’onde et longueur du dipôle';

  @override
  String get toolsSpeedTitle => 'Vitesse CW';

  @override
  String get toolsSpeedHint => 'Convertir les WPM en durée des points, pauses et caractères par minute';

  @override
  String get toolsRstTitle => 'Rapport RST';

  @override
  String get toolsRstHint => 'Composez un rapport de signal et découvrez le sens de chaque chiffre';

  @override
  String get toolsClockTitle => 'Horloge UTC';

  @override
  String get toolsClockHint => 'Heure UTC pour le journal, à côté de votre heure locale';

  @override
  String get toolsGridFromCoordinates => 'Depuis les coordonnées';

  @override
  String get toolsGridLatitude => 'Latitude';

  @override
  String get toolsGridLongitude => 'Longitude';

  @override
  String get toolsGridCoordinatesHelp => 'Degrés décimaux ; sud et ouest sont négatifs';

  @override
  String get toolsGridInvalidCoordinates => 'Latitude de −90 à 90, longitude de −180 à 180';

  @override
  String get toolsGridLocator => 'Localisateur';

  @override
  String get toolsGridDistanceSection => 'Distance et azimut';

  @override
  String get toolsGridMine => 'Mon localisateur';

  @override
  String get toolsGridTheirs => 'Localisateur du correspondant';

  @override
  String get toolsGridInvalidLocator => 'Utilisez 2, 4, 6 ou 8 caractères, par exemple OM89ex';

  @override
  String get toolsGridCenter => 'Centre du carré';

  @override
  String get toolsGridDistance => 'Distance';

  @override
  String get toolsGridShortPath => 'Azimut trajet court';

  @override
  String get toolsGridLongPath => 'Azimut trajet long';

  @override
  String get toolsBandsFrequency => 'Fréquence (MHz)';

  @override
  String get toolsBandsInvalidFrequency => 'Saisissez une fréquence supérieure à 0';

  @override
  String toolsBandsRegionLabel(int number) {
    return 'Région $number';
  }

  @override
  String get toolsBandsRegionHelp => '1 : Europe, Afrique, Moyen-Orient – 2 : Amériques – 3 : Asie-Pacifique';

  @override
  String toolsBandsInBand(String band) {
    return 'Dans la bande amateur $band';
  }

  @override
  String get toolsBandsOutOfBand => 'Hors des bandes amateurs';

  @override
  String get toolsBandsWavelength => 'Longueur d’onde';

  @override
  String get toolsBandsDipole => 'Dipôle demi-onde (total)';

  @override
  String get toolsBandsQuarterWave => 'Verticale quart d’onde';

  @override
  String get toolsBandsAntennaNote => 'Longueurs avec facteur de raccourcissement de 0,95 ; ajustez pour la résonance.';

  @override
  String get toolsBandsTable => 'Limites des bandes';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'Attributions UIT. Votre licence et le plan de bandes national peuvent être plus restrictifs.';

  @override
  String get toolsSpeedCharacter => 'Vitesse des caractères';

  @override
  String get toolsSpeedFarnsworth => 'Espacement Farnsworth';

  @override
  String get toolsSpeedOverall => 'Vitesse globale';

  @override
  String get toolsSpeedDit => 'Point';

  @override
  String get toolsSpeedDah => 'Trait';

  @override
  String get toolsSpeedCharGap => 'Pause entre caractères';

  @override
  String get toolsSpeedWordGap => 'Pause entre mots';

  @override
  String get toolsSpeedCpm => 'Caractères par minute';

  @override
  String get toolsSpeedParis => 'Un mot PARIS';

  @override
  String get toolsRstReadability => 'Lisibilité (R)';

  @override
  String get toolsRstStrength => 'Force du signal (S)';

  @override
  String get toolsRstTone => 'Tonalité (T)';

  @override
  String get toolsRstReport => 'Rapport';

  @override
  String get toolsRstCut => 'Notation concours';

  @override
  String get toolsRstPhone => 'Phonie (sans tonalité)';

  @override
  String get toolsRstR1 => 'Illisible';

  @override
  String get toolsRstR2 => 'À peine lisible, quelques mots';

  @override
  String get toolsRstR3 => 'Lisible avec beaucoup de difficulté';

  @override
  String get toolsRstR4 => 'Lisible sans difficulté notable';

  @override
  String get toolsRstR5 => 'Parfaitement lisible';

  @override
  String get toolsRstS1 => 'Faible, à peine perceptible';

  @override
  String get toolsRstS2 => 'Très faible';

  @override
  String get toolsRstS3 => 'Faible';

  @override
  String get toolsRstS4 => 'Moyenne';

  @override
  String get toolsRstS5 => 'Assez bonne';

  @override
  String get toolsRstS6 => 'Bonne';

  @override
  String get toolsRstS7 => 'Modérément forte';

  @override
  String get toolsRstS8 => 'Forte';

  @override
  String get toolsRstS9 => 'Extrêmement forte';

  @override
  String get toolsRstT1 => 'Très rauque et large, son alternatif non redressé';

  @override
  String get toolsRstT2 => 'Son alternatif très rauque, strident et large';

  @override
  String get toolsRstT3 => 'Rauque, redressée mais non filtrée';

  @override
  String get toolsRstT4 => 'Rauque, légèrement filtrée';

  @override
  String get toolsRstT5 => 'Filtrée, mais fortement modulée par l’ondulation';

  @override
  String get toolsRstT6 => 'Filtrée, avec une ondulation nette';

  @override
  String get toolsRstT7 => 'Presque pure, faible ondulation';

  @override
  String get toolsRstT8 => 'Presque parfaite, légère modulation';

  @override
  String get toolsRstT9 => 'Tonalité pure, sans ondulation';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => 'Heure locale';

  @override
  String get toolsClockNote => 'Les journaux de trafic et les cartes QSL utilisent UTC.';

  @override
  String get learnReceiveTitle => 'Réception';

  @override
  String get learnReviewTitle => 'Révision';

  @override
  String get learnListen => 'Écoutez…';

  @override
  String get learnReady => 'Prêt';

  @override
  String get learnReplay => 'Réécouter';

  @override
  String get learnAnswerHint => 'Saisissez ce que vous avez entendu';

  @override
  String get learnSubmit => 'Vérifier';

  @override
  String get learnNext => 'Suivant';

  @override
  String get learnFinish => 'Terminer';

  @override
  String get learnDone => 'Terminé';

  @override
  String get learnBackspace => 'Supprimer';

  @override
  String get learnSpace => 'Espace';

  @override
  String get learnSent => 'Envoyé';

  @override
  String get learnYourCopy => 'Votre réception';

  @override
  String get learnRoundPerfect => 'Réception parfaite !';

  @override
  String get learnSessionSummary => 'Bilan de la séance';

  @override
  String get learnLessonPassed => 'Leçon réussie';

  @override
  String get learnLessonNotPassed => 'Persévérez : 90 % débloquent la leçon suivante';

  @override
  String get learnReviewRecorded => 'Révision enregistrée';

  @override
  String get learnWeakChars => 'À travailler';

  @override
  String get learnConfusions => 'Confusions';

  @override
  String get learnNoFeedbackWarning => 'Le son, les flashs et les vibrations sont désactivés ; l’écran clignotera à leur place.';

  @override
  String get learnSendTitle => 'Transmission';

  @override
  String get learnSendThis => 'Transmettez ceci';

  @override
  String get learnCopyFromMemory => 'De mémoire';

  @override
  String get learnHiddenTarget => 'Masqué : manipulez de mémoire';

  @override
  String get learnDecoded => 'Décodé';

  @override
  String get learnWaitingForKey => 'Commencez à manipuler quand vous êtes prêt';

  @override
  String get learnRestart => 'Recommencer';

  @override
  String get learnTryAnother => 'Essayer un autre texte';

  @override
  String get learnKeyerStraight => 'Pioche';

  @override
  String get learnKeyerIambicA => 'Iambic A';

  @override
  String get learnKeyerIambicB => 'Iambic B';

  @override
  String get learnLegendStraight => 'Espace = manipulateur';

  @override
  String get learnLegendPaddles => 'Ctrl gauche = point, Ctrl droite = trait';

  @override
  String get learnSendClean => 'Manipulation nette : rien à corriger.';

  @override
  String get learnSendIssues => 'Remarques sur le rythme';

  @override
  String get learnYourSending => 'Décodé comme';

  @override
  String get learnStraightKeyLabel => 'MANIPULATEUR';

  @override
  String get learnDitLabel => 'POINT';

  @override
  String get learnDahLabel => 'TRAIT';

  @override
  String get learnSettingsTitle => 'Réglages d’entraînement';

  @override
  String get learnCharacterSpeed => 'Vitesse des caractères';

  @override
  String get learnFarnsworth => 'Espacement Farnsworth';

  @override
  String get learnFarnsworthHelp => 'Les caractères restent rapides ; les pauses entre eux sont allongées pour atteindre cette vitesse.';

  @override
  String get learnEffectiveSpeed => 'Vitesse effective';

  @override
  String get learnTone => 'Tonalité';

  @override
  String get learnPlaySample => 'Écouter un exemple';

  @override
  String get learnSessionLength => 'Longueur de la séance';

  @override
  String get learnFeedback => 'Retour sensoriel';

  @override
  String get learnSound => 'Son';

  @override
  String get learnFlash => 'Flash de l’écran';

  @override
  String get learnHaptic => 'Vibration';

  @override
  String get learnKeyer => 'Manipulateur';

  @override
  String get learnDailyGoal => 'Objectif quotidien';

  @override
  String get referenceReferenceTitle => 'Référence Morse';

  @override
  String get referenceTranslatorTitle => 'Traducteur';

  @override
  String get referencePlay => 'Écouter';

  @override
  String get referenceStop => 'Arrêter';

  @override
  String get referenceClear => 'Effacer';

  @override
  String get referenceClose => 'Fermer';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => 'Rechercher des caractères, signaux de procédure, codes Q…';

  @override
  String get referenceClearSearch => 'Effacer la recherche';

  @override
  String get referenceNoResults => 'Aucun résultat pour votre recherche.';

  @override
  String get referenceSectionAlphabet => 'Alphabet';

  @override
  String get referenceSectionPunctuation => 'Ponctuation';

  @override
  String get referenceSectionProsigns => 'Signaux de procédure';

  @override
  String get referenceSectionQCodes => 'Codes Q';

  @override
  String get referenceSectionAbbreviations => 'Abréviations CW';

  @override
  String get referenceSectionKoch => 'Ordre Koch';

  @override
  String get referenceAlphabetHint => 'Touchez une carte pour l’écouter. Faites un appui long pour voir un moyen mnémotechnique.';

  @override
  String get referenceKochHint => 'Ordre d’introduction des caractères selon la méthode Koch (séquence LCWO). Commencez par K et M ; ajoutez-en un lorsque votre réception atteint 90 %.';

  @override
  String get referenceMnemonicTitle => 'Moyen mnémotechnique';

  @override
  String get referenceMeaningLabel => 'Signification';

  @override
  String get referencePlaybackSettings => 'Réglages de lecture';

  @override
  String get referenceCharacterSpeed => 'Vitesse des caractères';

  @override
  String get referenceFarnsworth => 'Espacement Farnsworth';

  @override
  String get referenceFarnsworthHelp => 'Les caractères gardent leur vitesse maximale ; les pauses sont allongées pour atteindre la vitesse effective.';

  @override
  String get referenceEffectiveSpeed => 'Vitesse effective';

  @override
  String get referenceTone => 'Tonalité';

  @override
  String get referenceModeTextToMorse => 'Texte → Morse';

  @override
  String get referenceModeMorseToText => 'Morse → Texte';

  @override
  String get referenceModeKey => 'Manipuler';

  @override
  String get referenceTextInputLabel => 'Texte';

  @override
  String get referenceTextInputHint => 'Saisissez le texte à coder…';

  @override
  String get referencePatternOutputLabel => 'Morse';

  @override
  String get referenceCopyPattern => 'Copier la séquence';

  @override
  String get referencePatternCopied => 'Séquence copiée';

  @override
  String get referencePatternInputLabel => 'Morse';

  @override
  String get referencePatternInputHint => 'Saisissez . et -, un espace entre les lettres, / entre les mots';

  @override
  String get referenceTextOutputLabel => 'Texte';

  @override
  String get referenceCopyText => 'Copier le texte';

  @override
  String get referenceTextCopied => 'Texte copié';

  @override
  String get referenceUnknownPatternHelp => 'Les séquences sans caractère correspondant s’affichent sous la forme <pattern>.';

  @override
  String get referenceKeypadDit => 'Point';

  @override
  String get referenceKeypadDah => 'Trait';

  @override
  String get referenceKeypadCharGap => 'Pause entre lettres';

  @override
  String get referenceKeypadWordGap => 'Pause entre mots';

  @override
  String get referenceKeypadBackspace => 'Retour arrière';

  @override
  String get referenceKeyHint => 'Maintenez le manipulateur pour transmettre. Sur un clavier, maintenez la touche Espace.';

  @override
  String get referenceKeyLabel => 'MANIPULATEUR';

  @override
  String get referenceKeyDecodedLabel => 'Décodé';

  @override
  String get referenceKeyPendingLabel => 'Manipulation';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsLoading => 'Chargement de vos statistiques…';

  @override
  String get statsLoadFailed => 'Votre progression n’a pas pu être chargée. Faites glisser vers le bas ou rouvrez la page pour réessayer.';

  @override
  String get statsRetry => 'Réessayer';

  @override
  String get statsEmptyTitle => 'Aucune séance pour l’instant';

  @override
  String get statsEmptyBody => 'Terminez votre première séance de réception ou de transmission pour afficher l’évolution de votre précision, vos points forts par caractère et un calendrier d’entraînement.';

  @override
  String get statsEmptyCallToAction => 'Allez dans « Apprendre » et touchez « Continuer la leçon » pour commencer.';

  @override
  String get statsOverviewTitle => 'Vue d’ensemble';

  @override
  String get statsTileLesson => 'Leçon Koch';

  @override
  String get statsTileAccuracy => 'Précision';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => 'Entraînement';

  @override
  String get statsTileStreak => 'Série';

  @override
  String get statsTileDailyGoal => 'Objectif quotidien';

  @override
  String get statsGoalMet => 'Atteint aujourd’hui';

  @override
  String get statsSummaryTitle => 'Vos statistiques';

  @override
  String get statsSummaryOpen => 'Voir les statistiques';

  @override
  String get statsTrendTitle => 'Évolution de la précision';

  @override
  String get statsTrendHint => 'Touchez un point pour consulter une séance.';

  @override
  String get statsSeriesReceive => 'Réception';

  @override
  String get statsSeriesSend => 'Transmission';

  @override
  String get statsAxisSessions => 'Séance';

  @override
  String get statsCharsTitle => 'Caractères';

  @override
  String get statsCharsSubtitle => 'Ordre Koch. Touchez un caractère pour voir les détails.';

  @override
  String get statsCharsNotStarted => 'Pas encore travaillé';

  @override
  String get statsNotInCourse => 'Hors du cours Koch';

  @override
  String get statsSrsTitle => 'Répétition espacée';

  @override
  String get statsSrsNotTracked => 'Pas encore planifié';

  @override
  String get statsSrsDueNow => 'À revoir maintenant';

  @override
  String get statsConfusionsTitle => 'Le plus souvent confondu avec';

  @override
  String get statsConfusionsNone => 'Aucune confusion enregistrée';

  @override
  String get statsConfusionMissed => 'manqué';

  @override
  String get statsBucketLegendTitle => 'Précision';

  @override
  String get statsBucketNone => 'Aucune';

  @override
  String get statsBucketWeak => '< 70 %';

  @override
  String get statsBucketFair => '70–89 %';

  @override
  String get statsBucketGood => '90–97 %';

  @override
  String get statsBucketStrong => '≥ 98 %';

  @override
  String get statsHeatmapTitle => 'Confusions';

  @override
  String get statsHeatmapSubtitle => 'Les lignes indiquent le caractère envoyé, les colonnes votre réponse. Plus la couleur est foncée, plus la confusion est fréquente.';

  @override
  String get statsHeatmapEmpty => 'Aucune confusion pour l’instant. Les mauvaises réponses apparaîtront ici.';

  @override
  String get statsHeatmapLegendLow => 'Rare';

  @override
  String get statsHeatmapLegendHigh => 'Fréquent';

  @override
  String get statsHeatmapAxisTarget => 'Envoyé';

  @override
  String get statsHeatmapAxisAnswered => 'Répondu';

  @override
  String get statsCalendarTitle => 'Calendrier d’entraînement';

  @override
  String get statsCalendarSubtitle => '12 dernières semaines';

  @override
  String get statsCalendarLegendLess => 'Moins';

  @override
  String get statsCalendarLegendMore => 'Plus';

  @override
  String get statsStreakExplanation => 'Une série compte les jours consécutifs avec au moins une séance. Une journée entière sans entraînement la remet à zéro ; deux séances le même jour ne comptent qu’une fois.';

  @override
  String get learnStatistics => 'Statistiques';

  @override
  String get listenTitle => 'Écoute';

  @override
  String get listenStart => 'Démarrer';

  @override
  String get listenStop => 'Arrêter';

  @override
  String get listenStarting => 'Démarrage du microphone…';

  @override
  String get listenClear => 'Effacer le texte';

  @override
  String get listenCopy => 'Copier le texte';

  @override
  String get listenCopied => 'Texte décodé copié';

  @override
  String get listenSettings => 'Réglages d’écoute';

  @override
  String get listenDecoded => 'Décodé';

  @override
  String get listenEmptyHint => 'Dirigez le microphone vers un signal sonore Morse. Le texte décodé apparaîtra ici.';

  @override
  String get listenIdleHint => 'Touchez « Démarrer » pour écouter un signal Morse.';

  @override
  String get listenPending => 'Réception en cours';

  @override
  String get listenSpeed => 'Vitesse';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => 'Signal';

  @override
  String get listenToneOn => 'Tonalité';

  @override
  String get listenTone => 'Fréquence de la tonalité';

  @override
  String get listenToneLocked => 'Verrouillée';

  @override
  String get listenToneSearching => 'Recherche';

  @override
  String get listenToneManual => 'Manuelle';

  @override
  String get listenAutoTune => 'Accord automatique';

  @override
  String get listenAutoTuneHelp => 'Suit la tonalité la plus forte entre 400 et 1000 Hz. Déplacez le curseur pour régler la fréquence manuellement.';

  @override
  String get listenRetune => 'Automatique';

  @override
  String get listenBlockSize => 'Bloc d’analyse';

  @override
  String get listenBlockSizeHelp => 'Les petits blocs repèrent mieux les transitions du signal, mais captent davantage de bruit. 256 échantillons (5,3 ms) conviennent à 5–40 WPM.';

  @override
  String get listenMinElement => 'Élément le plus court';

  @override
  String get listenMinElementHelp => 'Les sons et pauses plus courts que cette durée sont ignorés comme des clics ou des coupures.';

  @override
  String get listenPermissionDenied => 'L’accès au microphone a été refusé. Autorisez-le dans les réglages du système, puis réessayez.';

  @override
  String get listenPermissionRetry => 'Réessayer';

  @override
  String get listenStartFailed => 'Impossible de démarrer le microphone.';

  @override
  String get listenNoInput => 'Aucun microphone trouvé. Connectez-en un et réessayez.';

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
    return '$samples échantillons ($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'L’écoute s’est arrêtée lorsque l’application est passée en arrière-plan.';

  @override
  String get learnWpmUnknown => '- wpm';

  @override
  String get learnTipDitTooLongTitle => 'Points trop longs';

  @override
  String get learnTipDahTooShortTitle => 'Traits trop courts';

  @override
  String get learnTipIntraGapTooLongTitle => 'Éléments trop espacés';

  @override
  String get learnTipCharGapTooShortTitle => 'Caractères trop rapprochés';

  @override
  String get learnTipWordGapTooShortTitle => 'Mots trop rapprochés';

  @override
  String get learnTipSpeedUnsteadyTitle => 'Vitesse irrégulière';

  @override
  String get learnSeverityMinor => 'léger';

  @override
  String get learnSeverityModerate => 'notable';

  @override
  String get learnSeveritySevere => 'majeur';

  @override
  String get notificationOpen => 'Ouvrir';

  @override
  String get notificationChannelMessages => 'Messages';

  @override
  String get notificationChannelMessagesDescription => 'Nouveaux messages Morse de vos amis et groupes';

  @override
  String get notificationChannelFriendRequests => 'Demandes d’ami';

  @override
  String get notificationChannelFriendRequestsDescription => 'Quelqu’un souhaite vous ajouter comme ami';

  @override
  String get notificationChannelGroupInvites => 'Invitations de groupe';

  @override
  String get notificationChannelGroupInvitesDescription => 'Un ami vous a invité dans un groupe';

  @override
  String get notificationNewMessage => 'Nouveau message';

  @override
  String get notificationFriendRequestTitle => 'Nouvelle demande d’ami';

  @override
  String learnNewestCharIs(String char) {
    return 'Nouveau dans cette leçon : $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, nouveau';
  }

  @override
  String learnPendingPattern(String pattern) {
    return 'Manipulation : $pattern';
  }

  @override
  String learnIssueHeadline(String title, String severity) {
    return '$title ($severity)';
  }

  @override
  String learnRatioTimes(String ratio) {
    return '$ratio×';
  }

  @override
  String learnTipDitTooLong(String ratio) {
    return 'Vos points sont trop longs (environ $ratio la durée d’un point). Pensez « di », pas « daaah » : un point est une brève impulsion.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return 'Vos traits sont trop courts (environ $ratio la durée d’un point ; visez 3). Maintenez chaque trait pendant la durée de trois points.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return 'Les pauses à l’intérieur des caractères sont trop longues (environ $ratio la durée d’un point). Rapprochez les éléments d’un même caractère.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return 'Les caractères se confondent (pauses d’environ $ratio la durée d’un point ; visez 3). Laissez une pause nette après chaque caractère.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return 'Les mots sont trop rapprochés (pauses d’environ $ratio la durée d’un point ; visez 7). Marquez une longue pause entre les mots.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return 'Votre vitesse varie (variation de $percent %). Choisissez un rythme et maintenez-le sur toute la ligne.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$offending points sur $total trop longs (moyenne : $ratio la durée d’un point)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$offending traits sur $total trop courts (moyenne : $ratio la durée d’un point)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$offending pauses sur $total trop longues à l’intérieur des caractères (moyenne : $ratio la durée d’un point)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$offending pauses sur $total trop courtes entre les caractères (moyenne : $ratio la durée d’un point)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$offending pauses sur $total trop courtes entre les mots (moyenne : $ratio la durée d’un point)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return 'Vitesse de manipulation irrégulière (coefficient de variation : $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return '7 derniers jours / $allTime depuis le début';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get accountNewPasswordRequired => 'Saisissez un nouveau mot de passe';

  @override
  String get accountToxIdQrSemantics => 'Code QR de l’identifiant Tox';

  @override
  String get accountBackupSaveDialogTitle => 'Enregistrer la sauvegarde MorseCQ';

  @override
  String get accountBackupShareSubject => 'Sauvegarde d’identité MorseCQ';

  @override
  String get accountBackupChooseDialogTitle => 'Choisir une sauvegarde MorseCQ';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux messages',
      one: '$count nouveau message',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return 'Demande d’ami de $name';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name : $message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return 'Invitation dans $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name vous a invité';
  }

  @override
  String desktopTrayShow(String app) {
    return 'Afficher $app';
  }

  @override
  String desktopTrayHide(String app) {
    return 'Masquer $app';
  }

  @override
  String get desktopTraySoundOn => 'Son activé';

  @override
  String get desktopTraySoundOff => 'Son désactivé';

  @override
  String desktopTrayQuit(String app) {
    return 'Quitter $app';
  }

  @override
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus',
      one: '$count message non lu',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => 'Activé';

  @override
  String get listenStateOff => 'Désactivé';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count octets restants',
      one: '$count octet restant',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '$count membre',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return 'Amis ($count)';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return 'Demandes d’ami ($count)';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return 'Invitations de groupe ($count)';
  }

  @override
  String chatMembersTitleCount(int count) {
    return 'Membres · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return 'Invité par $name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name (Vous)';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label : $value $unit';
  }

  @override
  String referenceTelegraphCodes(String codes) {
    return 'Code télégraphique chinois : $codes';
  }

  @override
  String get referenceTelegraphMainland => 'Chine continentale 1983';

  @override
  String get referenceTelegraphTaiwan => 'Taïwan / HK';

  @override
  String get referenceTelegraphNone => 'Absent de ce répertoire';

  @override
  String get appearanceTitle => 'Apparence';

  @override
  String get appearanceStyles => 'Style de l’interface';

  @override
  String get appearanceChoose => 'Choisissez un style, prévisualisez-le, puis appliquez-le';

  @override
  String get appearanceMode => 'Luminosité';

  @override
  String get appearancePreview => 'Aperçu';

  @override
  String get appearanceApply => 'Appliquer le style';

  @override
  String get appearanceRestore => 'Rétablir les valeurs par défaut';

  @override
  String get appearanceApplied => 'Apparence enregistrée';

  @override
  String get appearanceSaveFailed => 'Impossible d’enregistrer l’apparence. Réessayez.';

  @override
  String get appearanceClassic => 'Laiton classique';

  @override
  String get appearanceModern => 'Calme moderne';

  @override
  String get appearanceRadio => 'Radio de nuit';

  @override
  String get appearancePaper => 'Manuel papier';

  @override
  String get appearanceCartoon => 'Dessin pétillant';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get appearanceSubtitle => 'Cinq styles avec modes clair et sombre';

  @override
  String get chatClearHistoryBody => 'Supprimer l’historique de cette conversation sur cet appareil ? Les copies sur les autres appareils sont conservées. Cette action est irréversible.';

  @override
  String get chatLoadEarlier => 'Charger les messages précédents';

  @override
  String get chatHistoryLoadFailed => 'Impossible de charger les messages précédents. Touchez pour réessayer.';

  @override
  String get chatRetryHistory => 'Réessayer';

  @override
  String chatNewMessages(int count) {
    return '$count nouveaux messages';
  }

  @override
  String learnShowAllChars(int count) {
    return 'Afficher les $count caractères';
  }

  @override
  String get chatSelfMe => 'Moi';

  @override
  String get chatSelfLocalOnly => 'Enregistré uniquement sur cet appareil';

  @override
  String get chatSelfContactSubtitle => 'Brouillons, exercices et notes · jamais envoyés';

  @override
  String get learnShowFewerChars => 'Afficher moins de caractères';

  @override
  String get learnLeaveDrillTitle => 'Quitter cette séance ?';

  @override
  String get learnLeaveDrillBody => 'Les manches de cette séance ne seront pas enregistrées.';

  @override
  String get learnLeaveDrillConfirm => 'Quitter';

  @override
  String get chatScanQrPermissionDenied => 'MorseCQ a besoin de la caméra pour scanner un code QR. Autorisez-la dans les réglages du système.';

  @override
  String get chatScanQrCameraUnavailable => 'La caméra n\'est pas disponible sur cet appareil.';
}
