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
  String get navMe => 'Moi';

  @override
  String get navReference => 'Référence';

  @override
  String get navLearnDescription => 'Leçons selon la méthode Koch, exercices de manipulation et de réception.';

  @override
  String get navReferenceDescription => 'Alphabet, signaux de procédure, codes Q, abréviations et traduction dans les deux sens.';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystemDefault => 'Langue du système';

  @override
  String get languageSaveFailed => 'Impossible d’enregistrer la langue. Réessayez.';

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
  String get accountSectionTraining => 'Entraînement';

  @override
  String get accountSectionAbout => 'À propos';

  @override
  String get accountTrainingDefaults => 'Réglages de lecture et d’entraînement par défaut';

  @override
  String get accountTrainingDefaultsSubtitle => 'Vitesse, tonalité et espacement Farnsworth';

  @override
  String get accountAboutLicence => 'Licence';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Code source';

  @override
  String get accountAboutSourceCopied => 'Lien du code source copié';

  @override
  String get chatSend => 'Envoyer';

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
  String get learnLoadFailed => 'Votre progression enregistrée n’a pas pu être lue. Vous repartez de zéro ; l’ancien fichier a été conservé avec le suffixe .corrupt.';

  @override
  String get learnProgressSaveFailed => 'Impossible d\'enregistrer votre progression. Le résultat compte tant que MorseCQ reste ouvert.';

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
  String get listenStreamFailed => 'Le microphone s’est arrêté de façon inattendue. Réessayez.';

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
  String get learnWpmUnknown => '-- WPM';

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
    return 'Vos points sont trop longs (environ $ratio la durée d’un point). Pensez « ti », pas « taaah » : un point est une brève impulsion.';
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
  String get listenStateOn => 'Activé';

  @override
  String get listenStateOff => 'Désactivé';

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
  String learnShowAllChars(int count) {
    return 'Afficher les $count caractères';
  }

  @override
  String get learnShowFewerChars => 'Afficher moins de caractères';

  @override
  String get learnLeaveDrillTitle => 'Quitter cette séance ?';

  @override
  String get learnLeaveDrillBody => 'Les manches de cette séance ne seront pas enregistrées.';

  @override
  String get learnLeaveDrillConfirm => 'Quitter';

  @override
  String get learnReplayAssistedNote => 'Rejoué : cette séance compte comme entraînement mais ne débloque pas de leçon et ne met pas à jour les révisions.';

  @override
  String get learnPlanTitle => 'Programme du jour';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return 'Environ $minutes min · $done étape(s) sur $total';
  }

  @override
  String get learnPlanBudget => 'Durée du programme';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learnPlanStart => 'Commencer';

  @override
  String get learnPlanContinue => 'Continuer';

  @override
  String get learnPlanStepReview => 'Réviser les signes dus';

  @override
  String get learnPlanStepFocus => 'Entraînement ciblé';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'Leçon $lesson';
  }

  @override
  String get learnPlanStepSend => 'Entraînement à la manipulation';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return 'À réviser : $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'Souvent confondus : $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return 'Sous 90 % : $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count signes : peut débloquer la leçon suivante';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return 'Allongé à $count signes pour pouvoir débloquer la leçon suivante';
  }

  @override
  String get learnPlanReasonConsolidate => 'Séance courte : consolide la leçon, ne débloque pas la suivante';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'Votre cours a avancé : entraîne la leçon $lesson sans déblocage';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '$count courtes cibles à manipuler';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return 'Terminé · $percent %';
  }

  @override
  String get learnPlanStepDone => 'Terminé';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$done sur $total manipulés';
  }

  @override
  String get learnPlanStale => 'Votre leçon ou vitesse a changé. Mettre à jour les étapes non commencées ?';

  @override
  String get learnPlanUpdate => 'Mettre à jour';

  @override
  String get learnPlanComplete => 'Programme du jour terminé';

  @override
  String learnPlanNeedsWork(String symbols) {
    return 'À retravailler : $symbols';
  }

  @override
  String get learnPlanAllGood => 'Aucun signe faible aujourd\'hui.';

  @override
  String get learnPlanTomorrow => 'Un nouveau programme demain. L\'entraînement libre reste ouvert.';

  @override
  String learnPlanEarlier(int done, int total) {
    return 'Le programme précédent s\'est arrêté à $done étape(s) sur $total ; il ne compte plus aujourd\'hui.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return 'Prêt pour $wpm mots/min en vitesse effective';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return 'Prêt pour $wpm mots/min';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'La copie est difficile à cette vitesse. Essayez $wpm mots/min effectifs ou un exercice ciblé.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return 'D\'après vos $count dernières séances sans aide ($percent %). Rien ne change tant que vous n\'appliquez pas.';
  }

  @override
  String get learnSpeedAdviceApply => 'Appliquer';

  @override
  String get learnSpeedAdviceDismiss => 'Pas maintenant';

  @override
  String get learnSpeedAdviceInsufficient => 'Le conseil de vitesse demande 3 séances sans aide de 50 signes ou plus à votre vitesse actuelle.';

  @override
  String get learnQsoAction => 'Simulateur de QSO';

  @override
  String learnQsoLocked(int lesson) {
    return 'Dès la leçon $lesson';
  }

  @override
  String get learnQsoTitle => 'Simulateur de QSO';

  @override
  String get learnQsoRespond => 'Répondre à un CQ';

  @override
  String get learnQsoRespondHint => 'Une station lance CQ. Répondez et échangez les reports.';

  @override
  String get learnQsoCall => 'Lancer CQ';

  @override
  String get learnQsoCallHint => 'Vous lancez CQ et une station répond.';

  @override
  String get learnQsoYourCall => 'Votre indicatif';

  @override
  String get learnQsoYourName => 'Votre prénom';

  @override
  String get learnQsoYourQth => 'Votre QTH';

  @override
  String get learnQsoInvalidCall => 'Saisissez un indicatif comme BD1XYZ';

  @override
  String get learnQsoInvalidWord => 'Un mot, lettres A–Z uniquement';

  @override
  String get learnQsoOffline => 'Fonctionne entièrement sur cet appareil. Rien n\'est envoyé.';

  @override
  String get learnQsoStart => 'Démarrer le QSO';

  @override
  String get learnQsoResume => 'Reprendre le QSO inachevé';

  @override
  String get learnQsoStageCallCq => 'Lancez CQ avec votre indicatif';

  @override
  String get learnQsoStageCallConfirm => 'Répondez : son indicatif, DE, le vôtre';

  @override
  String get learnQsoStageExchange => 'Envoyez report, prénom et QTH';

  @override
  String get learnQsoStageConfirmInfo => 'Confirmez ses informations';

  @override
  String get learnQsoStageClosing => 'Terminez par 73 et <SK>';

  @override
  String get learnQsoStageDone => 'QSO terminé';

  @override
  String learnQsoSpeed(int wpm) {
    return 'Le correspondant manipule à $wpm mots/min effectifs';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call manipule';
  }

  @override
  String get learnQsoRemoteHidden => 'Copiez à l\'oreille : le texte est masqué.';

  @override
  String get learnQsoShowText => 'Afficher le texte';

  @override
  String get learnQsoListen => 'Écouter';

  @override
  String get learnQsoAccepted => 'Accepté';

  @override
  String get learnQsoRejected => 'Refusé';

  @override
  String get learnQsoRemoteSending => 'L\'autre station manipule…';

  @override
  String get learnQsoYourTurn => 'À vous : manipulez votre réponse, puis Envoyer.';

  @override
  String get learnQsoDecoded => 'Votre émission';

  @override
  String get learnQsoNothingKeyed => 'Rien manipulé pour l\'instant';

  @override
  String get learnQsoPlayAgain => 'Demander de répéter (AGN)';

  @override
  String get learnQsoSlower => 'Demander de ralentir (QRS)';

  @override
  String get learnQsoHint => 'Indice';

  @override
  String learnQsoHintLabel(String example) {
    return 'Exemple : $example';
  }

  @override
  String get learnQsoPause => 'Pause';

  @override
  String get learnQsoSend => 'Envoyer';

  @override
  String get learnQsoClear => 'Effacer';

  @override
  String get learnQsoIssueEmpty => 'Rien n\'a été manipulé.';

  @override
  String get learnQsoIssueMissingCq => 'Commencez par CQ.';

  @override
  String get learnQsoIssueMissingDe => 'Mettez DE entre les indicatifs.';

  @override
  String get learnQsoIssueWrongLocalCall => 'Votre indicatif manque ou est faux.';

  @override
  String get learnQsoIssueWrongRemoteCall => 'L\'indicatif de l\'autre station est faux.';

  @override
  String get learnQsoIssueReversedCalls => 'Indicatifs inversés : d\'abord le sien, puis DE et le vôtre.';

  @override
  String get learnQsoIssueMissingEnding => 'Terminez par K ou KN.';

  @override
  String get learnQsoIssueMissingRst => 'Donnez un report, p. ex. UR RST 599.';

  @override
  String get learnQsoIssueInvalidRst => 'Ce RST est hors plage (R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'Envoyez NAME et votre prénom.';

  @override
  String get learnQsoIssueWrongName => 'Ce n\'est pas votre prénom pour ce QSO.';

  @override
  String get learnQsoIssueMissingQth => 'Envoyez QTH et votre lieu.';

  @override
  String get learnQsoIssueWrongQth => 'Ce n\'est pas votre QTH pour ce QSO.';

  @override
  String get learnQsoIssueMissingAck => 'Accusez réception avec R ou QSL.';

  @override
  String get learnQsoIssueWrongRemoteName => 'Confirmez le prénom de l\'autre opérateur.';

  @override
  String get learnQsoIssueMissing73 => 'Ajoutez 73.';

  @override
  String get learnQsoIssueMissingSk => 'Terminez le contact par <SK>.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return 'Juste du premier coup : $count étape(s) sur $total';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return 'Répétitions : $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'Indices : $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'Votre manipulation : environ $wpm mots/min';
  }

  @override
  String get learnQsoSummaryNote => 'Les résultats de QSO sont séparés de la précision de copie et ne débloquent jamais de leçon.';

  @override
  String get learnTipDahTooLongTitle => 'Traits trop longs';

  @override
  String learnTipDahTooLong(String ratio) {
    return 'Vos traits durent trop (environ $ratio d\'un point ; visez 3). Relâchez après trois points.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$offending trait(s) sur $total trop longs (moy. $ratio point)';
  }

  @override
  String get learnRhythmTitle => 'Rythme';

  @override
  String get learnRhythmMine => 'Mon rythme';

  @override
  String get learnRhythmStandard => 'Rythme standard (vitesse cible)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return 'Les problèmes sont jugés sur votre propre point ($ms ms) : régulier mais lent, c\'est correct. La piste standard suit la vitesse cible.';
  }

  @override
  String get learnRhythmNotLocated => 'Impossible d\'associer vos signaux à des signes précis. Entraînez-vous sur la cible entière.';

  @override
  String get learnRhythmPlayMine => 'Écouter le mien';

  @override
  String get learnRhythmPlayStandard => 'Écouter le standard';

  @override
  String learnRhythmPracticePart(int count) {
    return 'S\'exercer ($count essais)';
  }

  @override
  String get learnRhythmPracticeWhole => 'S\'exercer sur toute la cible';

  @override
  String get learnRhythmSymbolOk => 'Correct';

  @override
  String get learnRhythmZoomIn => 'Zoom avant';

  @override
  String get learnRhythmZoomOut => 'Zoom arrière';

  @override
  String get workbenchTitle => 'Atelier d\'enregistrements';

  @override
  String get workbenchOpen => 'Enregistrements';

  @override
  String get workbenchImport => 'Importer un enregistrement';

  @override
  String get workbenchEmpty => 'Importez un enregistrement WAV pour le boucler, le décoder et le copier. Aucun micro requis.';

  @override
  String get workbenchFormats => 'WAV, PCM 16 bits, mono ou stéréo, 8/16/44,1/48 kHz ; jusqu\'à 50 Mo et 20 minutes.';

  @override
  String get workbenchBackupNote => 'Les enregistrements restent sur cet appareil. Gardez une copie avant d’effacer les données ou de désinstaller. Les sélections conservent leurs titres, notes et positions.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => 'mono';

  @override
  String get workbenchStereo => 'stéréo';

  @override
  String get workbenchErrorNotWav => 'Ce n\'est pas un fichier WAV.';

  @override
  String get workbenchErrorFormat => 'Seul le WAV PCM 16 bits est pris en charge pour l\'instant (pas de MP3, AAC ni WAV flottant).';

  @override
  String get workbenchErrorChannels => 'Seuls les enregistrements mono ou stéréo sont pris en charge.';

  @override
  String get workbenchErrorRate => 'Fréquence d\'échantillonnage non prise en charge. Utilisez 8, 16, 44,1 ou 48 kHz.';

  @override
  String get workbenchErrorDamaged => 'Le fichier est endommagé ou incomplet.';

  @override
  String get workbenchErrorTooLarge => 'Le fichier dépasse 50 Mo.';

  @override
  String get workbenchErrorTooLong => 'L\'enregistrement dure plus de 20 minutes.';

  @override
  String get workbenchErrorIo => 'Impossible de lire le fichier.';

  @override
  String get workbenchErrorMissing => 'Le fichier d\'enregistrement est introuvable.';

  @override
  String get workbenchStart => 'Début (s)';

  @override
  String get workbenchEnd => 'Fin (s)';

  @override
  String get workbenchSelectAll => 'Tout sélectionner';

  @override
  String get workbenchPlay => 'Lire la sélection';

  @override
  String get workbenchStop => 'Arrêter';

  @override
  String get workbenchLoop => 'Boucle';

  @override
  String get workbenchPlayLimit => 'Seules les 5 premières minutes d\'une sélection plus longue sont lues.';

  @override
  String get workbenchAutoTune => 'Trouver la tonalité automatiquement';

  @override
  String workbenchManualTone(int hz) {
    return 'Tonalité : $hz Hz';
  }

  @override
  String get workbenchDecode => 'Décoder la sélection';

  @override
  String get workbenchCancel => 'Annuler';

  @override
  String workbenchDecoding(int percent) {
    return 'Décodage… $percent %';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'Tonalité $hz Hz · environ $wpm mots/min';
  }

  @override
  String get workbenchToneNotLocked => 'Aucune tonalité stable ; essayez le réglage manuel.';

  @override
  String get workbenchNoText => 'Rien n\'a été décodé dans cette sélection.';

  @override
  String workbenchUnknown(String patterns) {
    return 'Motifs inconnus : $patterns';
  }

  @override
  String get workbenchEdgeCut => 'Un signe au bord de la sélection est coupé et peut être faux.';

  @override
  String get workbenchToneNote => 'Le verrouillage de tonalité n\'est pas un indice de confiance ; vérifiez le texte à l\'oreille.';

  @override
  String get workbenchModeDecoder => 'Décodeur';

  @override
  String get workbenchModeCopy => 'Le copier moi-même';

  @override
  String get workbenchDecoderHidden => 'Le texte du décodeur est masqué pendant la copie.';

  @override
  String get workbenchShowDecoder => 'Afficher le texte du décodeur';

  @override
  String get workbenchReference => 'Texte de référence (facultatif)';

  @override
  String get workbenchReferenceHelp => 'Collez le texte envoyé ; sinon votre copie est comparée à la sortie du décodeur.';

  @override
  String get workbenchAgainstDecoder => 'Comparé à la sortie du décodeur, qui peut elle-même être fausse.';

  @override
  String get workbenchSave => 'Enregistrer la sélection';

  @override
  String get workbenchSaveTitle => 'Titre';

  @override
  String get workbenchSaveNote => 'Note';

  @override
  String get workbenchSaved => 'Sélection enregistrée';

  @override
  String get workbenchSaveFailed => 'Impossible d\'enregistrer la sélection.';

  @override
  String get workbenchLibrary => 'Sélections enregistrées';

  @override
  String get workbenchLibraryEmpty => 'Aucune sélection enregistrée pour l\'instant.';

  @override
  String get workbenchMissing => 'Fichier manquant : choisissez-le à nouveau ou supprimez l\'entrée.';

  @override
  String get workbenchRelink => 'Choisir à nouveau le fichier';

  @override
  String get workbenchDelete => 'Supprimer';

  @override
  String get materialsTitle => 'Mes supports';

  @override
  String get materialsNew => 'Nouveau support';

  @override
  String get materialsEdit => 'Modifier';

  @override
  String get materialsSave => 'Enregistrer';

  @override
  String get materialsSaveFailed => 'Impossible d\'enregistrer le support.';

  @override
  String get materialsTitleField => 'Titre';

  @override
  String get materialsTagsField => 'Étiquettes (séparées par des virgules)';

  @override
  String get materialsTextField => 'Texte';

  @override
  String get materialsListField => 'Une entrée par ligne';

  @override
  String get materialsKindText => 'Texte';

  @override
  String get materialsKindWords => 'Liste de mots';

  @override
  String get materialsKindCallsigns => 'Indicatifs';

  @override
  String get materialsPreview => 'Aperçu';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items éléments · $symbols signes · $prosigns procédures';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'Sans code Morse, ignorés à l\'entraînement : $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count entrées en double conservées une seule fois';
  }

  @override
  String get materialsProblemEmpty => 'Saisissez d\'abord du texte.';

  @override
  String get materialsProblemTooLarge => 'Trop volumineux : limite de 1 Mio.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return 'Trop d\'entrées : $count au maximum.';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return 'Une entrée est trop longue : $count signes au maximum.';
  }

  @override
  String get materialsProblemNothingTrainable => 'Rien ici ne peut être travaillé en Morse.';

  @override
  String get materialsSearch => 'Rechercher';

  @override
  String get materialsFavoritesOnly => 'Favoris';

  @override
  String get materialsFavorite => 'Ajouter aux favoris';

  @override
  String get materialsUnfavorite => 'Retirer des favoris';

  @override
  String get materialsEmpty => 'Aucun support. Ajoutez vos textes, listes de mots ou indicatifs.';

  @override
  String materialsItems(int count) {
    return '$count éléments';
  }

  @override
  String get materialsActions => 'Actions';

  @override
  String get materialsPractise => 'S\'entraîner';

  @override
  String get materialsDelete => 'Supprimer';

  @override
  String get materialsDeleteTitle => 'Supprimer le support ?';

  @override
  String materialsDeleteBody(String title) {
    return '« $title » sera supprimé de cet appareil. Votre historique reste.';
  }

  @override
  String get materialsImport => 'Importer TXT ou JSON';

  @override
  String get materialsImportDialogTitle => 'Choisir un fichier';

  @override
  String get materialsSaveDialogTitle => 'Enregistrer le support';

  @override
  String get materialsImportFailed => 'Échec de l\'import. Votre bibliothèque est inchangée.';

  @override
  String get materialsImportNotUtf8 => 'Seuls les fichiers texte UTF-8 sont acceptés.';

  @override
  String get materialsImportInvalid => 'Fichier de supports MorseCQ invalide. Rien n\'a été importé.';

  @override
  String materialsImported(int count) {
    return '$count supports importés.';
  }

  @override
  String get materialsDuplicateTitle => 'Certains supports existent déjà';

  @override
  String get materialsDuplicateOverwrite => 'Les remplacer';

  @override
  String get materialsDuplicateKeepCopy => 'Garder les deux (copies)';

  @override
  String get materialsDuplicateSkip => 'Les ignorer';

  @override
  String get materialsExportJson => 'Exporter en JSON';

  @override
  String materialsExported(int count) {
    return '$count supports exportés.';
  }

  @override
  String get materialsExportFailed => 'Échec de l\'export.';

  @override
  String get materialsExportWav => 'Exporter l\'audio (WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return 'Vitesse des caractères : $wpm mots/min';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return 'Vitesse effective : $wpm mots/min';
  }

  @override
  String materialsWavTone(int hz) {
    return 'Tonalité : $hz Hz';
  }

  @override
  String get materialsWavWithAnswer => 'Inclure le texte de réponse (.txt)';

  @override
  String get materialsWavFormat => 'WAV mono 16 bits, 48 kHz.';

  @override
  String materialsWavParts(int count) {
    return 'Plus de 10 minutes : exporté en $count fichiers.';
  }

  @override
  String materialsWavExported(int count) {
    return '$count fichiers audio enregistrés.';
  }

  @override
  String get materialsPracticeMode => 'S\'entraîner avec';

  @override
  String get materialsPracticeLearned => 'Signes appris uniquement';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return 'Signes appris uniquement ($count entrées indisponibles : signes pas encore appris)';
  }

  @override
  String get materialsPracticeAll => 'Tous les signes Morse';

  @override
  String get materialsPracticeNothing => 'Aucune entrée utilisable dans ce mode.';

  @override
  String get guestClearConfirm => 'Effacer';

  @override
  String get placementTitle => 'Évaluer mon niveau';

  @override
  String get placementCheckLevel => 'Évaluer mon niveau actuel';

  @override
  String get placementFromZero => 'Passer l’intro : défi de la leçon 1';

  @override
  String get placementOfferTitle => 'Débutant en Morse ou déjà à l\'aise ?';

  @override
  String get placementOfferBody => 'Un court test peut suggérer un point de départ. Il est facultatif et ne change rien tant que vous ne choisissez pas.';

  @override
  String get placementIntro => 'Environ 3 à 5 minutes de copie en cinq étapes : signes Koch par groupes à vitesse croissante, puis mots courts. Indication approximative sur peu d\'échantillons, pas un certificat. Arrêtez quand vous voulez.';

  @override
  String get placementStart => 'Commencer';

  @override
  String get placementSkip => 'Passer';

  @override
  String get placementStop => 'Arrêter';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return 'Étape $step sur $total · $wpm mots/min effectifs';
  }

  @override
  String get placementTierPassed => 'Bien copié. L\'étape suivante est plus rapide.';

  @override
  String get placementTierStopped => 'Cette étape était sous 90 %, l\'évaluation s\'arrête ici.';

  @override
  String get placementNextTier => 'Étape suivante';

  @override
  String placementSuggestion(int lesson) {
    return 'Départ suggéré : leçon $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return '$count signes Koch sur $total confirmés dans l\'ordre.';
  }

  @override
  String get placementLimits => 'Sur un court échantillon : les signes non testés restent non testés et rien n\'est marqué comme acquis. Vous pouvez changer de leçon à tout moment.';

  @override
  String placementAdopt(int lesson) {
    return 'Commencer à la leçon $lesson';
  }

  @override
  String materialsImportConfirm(int count) {
    return 'Importer $count supports ?';
  }

  @override
  String get materialsExportTxt => 'Exporter en texte (TXT)';

  @override
  String get conditionsTitle => 'Conditions';

  @override
  String get conditionsClear => 'Clair';

  @override
  String get conditionsLight => 'Légères perturbations';

  @override
  String get conditionsRadio => 'Pratique radio';

  @override
  String get conditionsClearHint => 'Une tonalité nette et stable : entraînement habituel.';

  @override
  String get conditionsLightHint => 'Léger bruit de fond et fading doux. Les résultats sont séparés de l\'entraînement clair.';

  @override
  String get conditionsRadioHint => 'Bruit, fading profond, une station voisine et un rythme légèrement irrégulier. Les résultats sont séparés de l\'entraînement clair.';

  @override
  String get conditionsPreview => 'Écouter';

  @override
  String conditionsActive(String name) {
    return 'Conditions : $name';
  }

  @override
  String get conditionsNeedSound => 'Les conditions radio s\'entendent, elles ne se voient pas : activez le son dans les réglages d\'entraînement ou entraînez-vous en conditions claires.';

  @override
  String get conditionsCleanReplay => 'Écouter sans effets';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count essais dans ces conditions à cette vitesse : $accuracy % en moyenne',
      one: '1 essai dans ces conditions à cette vitesse : $accuracy %',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => 'L\'entraînement en conditions radio compte comme activité mais ne modifie ni vos leçons, ni vos révisions, ni les conseils de vitesse.';

  @override
  String get keysTitle => 'Touches et manipulateurs externes';

  @override
  String get keysMeSubtitle => 'Affectation des touches, palettes et adaptateurs USB';

  @override
  String get keysIntro => 'Choisissez les touches qui manipulent le Morse. Les adaptateurs USB de manipulateur et de palettes qui émulent un clavier fonctionnent comme lui : définissez leurs touches ici. L\'app ne sait pas quel appareil a envoyé une touche ; un profil est donc un ensemble d\'affectations.';

  @override
  String get keysStandardProfile => 'Standard';

  @override
  String get keysUnnamed => 'Profil sans nom';

  @override
  String get keysEdit => 'Modifier';

  @override
  String get keysNewProfile => 'Nouveau profil';

  @override
  String get keysLimitations => 'Les manipulateurs MIDI, série et Bluetooth, les réglages du firmware des adaptateurs et la commande d\'émetteur ne sont pas pris en charge. Les adaptateurs testés figurent dans la documentation.';

  @override
  String get keysEditTitle => 'Profil de touches';

  @override
  String get keysName => 'Nom du profil';

  @override
  String get keysActionStraight => 'Manipulateur droit';

  @override
  String get keysActionDit => 'Palette point';

  @override
  String get keysActionDah => 'Palette trait';

  @override
  String get keysPressKey => 'Appuyez sur une touche…';

  @override
  String get keysNone => 'Non défini';

  @override
  String get keysSet => 'Définir';

  @override
  String keysReserved(String key) {
    return '$key est réservée par le système ou l\'app ; choisissez une autre touche.';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key est déjà utilisée pour $action.';
  }

  @override
  String keysConflictSave(String keys) {
    return 'Chaque touche ne peut faire qu\'une chose : $keys est affectée deux fois.';
  }

  @override
  String get keysMissing => 'Définissez les touches requises par ce mode (les deux palettes en iambique).';

  @override
  String get keysSwapPaddles => 'Inverser les palettes (gaucher)';

  @override
  String get keysKeyerMode => 'Mode du manipulateur';

  @override
  String get keysIambicA => 'Iambique A';

  @override
  String get keysIambicB => 'Iambique B';

  @override
  String get keysAdapterKeyer => 'L\'adaptateur génère lui-même les éléments';

  @override
  String get keysAdapterKeyerHint => 'Pour un adaptateur doté de son propre manipulateur : ses appuis temporisés sont utilisés tels quels, sans second manipulateur iambique dans l\'app.';

  @override
  String get keysAppSidetone => 'Tonalité locale de l\'app en manipulant';

  @override
  String get keysAppSidetoneHint => 'Désactivez-la si l\'adaptateur produit sa propre tonalité. Le décodage n\'est pas affecté.';

  @override
  String get keysTestTitle => 'Test';

  @override
  String get keysTestNote => 'Test uniquement : rien n\'est envoyé ni ajouté à votre entraînement.';

  @override
  String get keysTestRelease => 'Relâcher les touches';

  @override
  String get keysAdapterActive => 'Le manipulateur de l\'adaptateur est utilisé : les touches de palette agissent comme un manipulateur droit.';

  @override
  String keysHintCustom(String keys) {
    return 'Touches : $keys';
  }

  @override
  String get telegraphTitle => 'Code télégraphique chinois';

  @override
  String get telegraphIntro => 'Chaque caractère chinois est transmis sous forme d\'un code à quatre chiffres. Entraînez-vous à entendre les chiffres et, séparément, à retenir quel code correspond à quel caractère.';

  @override
  String get telegraphCodebook => 'Code de référence';

  @override
  String get telegraphCodebookMainland => 'Chine continentale';

  @override
  String get telegraphCodebookTaiwan => 'Taïwan';

  @override
  String get telegraphDigitsTitle => 'Copier des groupes de code';

  @override
  String get telegraphDigitsHint => 'Écoutez des groupes de quatre chiffres de vrais codes et tapez les chiffres.';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances : $accuracy % des chiffres',
      one: '1 séance : $accuracy % des chiffres',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => 'Retrouver les codes';

  @override
  String get telegraphRecallHint => 'Du caractère au code et du code au caractère. Séparé de la progression en Morse.';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes répondues : $accuracy % sus',
      one: '1 carte répondue : $accuracy % sus',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => 'Retrouver les codes ne débloque jamais de leçon Morse ni ne change les conseils de vitesse ; copier des chiffres compte comme toute autre copie en Morse.';

  @override
  String get telegraphRecallCharPrompt => 'Tapez le code de ce caractère';

  @override
  String get telegraphRecallCodePrompt => 'Choisissez le caractère de ce code';

  @override
  String get telegraphReveal => 'Voir la réponse';

  @override
  String get telegraphRevealAssisted => 'Affichée : cette carte compte comme assistée.';

  @override
  String get telegraphCorrect => 'Correct';

  @override
  String get telegraphIncorrect => 'Pas tout à fait';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$correct sur $total sues';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes avec la réponse affichée',
      one: '1 carte avec la réponse affichée',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => 'Interprétation du code télégraphique';

  @override
  String get telegraphInterpretNote => 'Affiché ici seulement : le message n\'est pas modifié et rien n\'est envoyé.';

  @override
  String get telegraphUnresolved => 'Non résolu : aucun caractère n\'a ce code';

  @override
  String get telegraphMalformed => 'Pas un groupe de quatre chiffres';

  @override
  String get telegraphNotCode => 'Texte, laissé tel quel';

  @override
  String get telegraphAmbiguous => 'Plusieurs caractères partagent ce code';

  @override
  String get conditionsAudioFailed => 'Le son n\'a pas pu démarrer sur cet appareil. Entraînez-vous plutôt en conditions claires.';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutTermsOfUse => 'Conditions d’utilisation';

  @override
  String get aboutSupport => 'Assistance et contact';

  @override
  String get aboutLinkFailed => 'Le lien n’a pas pu s’ouvrir ; il a été copié.';

  @override
  String get offlineClearData => 'Effacer les données d’apprentissage';

  @override
  String get offlineClearDataBody => 'Supprime votre progression, vos plans et vos supports sur cet appareil.';

  @override
  String get offlineCleared => 'Données d’apprentissage effacées.';

  @override
  String get offlineClearFailed => 'Impossible d’effacer les données d’apprentissage.';

  @override
  String get learnStorageUnavailable => 'Vos données d’entraînement n’ont pas pu être ouvertes sur cet appareil. Réessayez.';

  @override
  String get materialsImportedSource => 'Source importée';

  @override
  String get learnStartHereTitle => 'Nouveau ? Commencez par une première leçon de 3 minutes';

  @override
  String get learnStartHereBody => 'Écoutez les sons, apprenez K et M, puis répondez à quelques tours faciles. Rien n’est noté.';

  @override
  String get learnStartHere => 'Commencer ici';

  @override
  String get learnReplayFirstLesson => 'Revoir la première leçon';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '$introduced introduits · $mastered maîtrisés';
  }

  @override
  String get learnChipNew => 'Nouveau';

  @override
  String get learnChipPractising => 'En cours';

  @override
  String get learnChipMastered => 'Maîtrisé';

  @override
  String get learnChipWeak => 'Sous 90 %';

  @override
  String get learnChipDue => 'À réviser';

  @override
  String get learnTapChipHint => 'Touchez un caractère pour l’entendre';

  @override
  String learnHearChar(String char) {
    return 'Écouter $char';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a contre $b';
  }

  @override
  String get learnGuidedPractice => 'Courte pratique (10 symboles)';

  @override
  String learnChallengeHint(int count, int min) {
    return 'Le défi de la leçon : $count symboles à 90 %, chaque nouveau symbole copié au moins $min fois. Le réussir débloque le caractère suivant.';
  }

  @override
  String get learnAllUnlockedNotPassed => 'Tous les caractères sont débloqués. Réussissez le dernier défi pour terminer le cours.';

  @override
  String get learnGoalFirstUse => 'Maintenant : distinguer K de M à l’oreille. Ensuite : le défi de la leçon 1.';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return 'Maintenant : reconnaître $chars sûrement ($min copies à 90 %). Ensuite : le défi de la leçon $lesson.';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return 'Maintenant : réussir le défi de la leçon $lesson. Ensuite : $next.';
  }

  @override
  String learnGoalNextChar(String char) {
    return 'le caractère $char';
  }

  @override
  String get learnGoalNextOperating => 'mots, indicatifs et QSO complet';

  @override
  String get learnGoalOperating => 'Maintenant : vrais messages — mots, indicatifs, QSO. Ensuite : augmenter la vitesse effective pas à pas.';

  @override
  String get learnMorePractice => 'Autres exercices';

  @override
  String get learnQsoReady => 'Prêt';

  @override
  String get learnQsoPractiseFirst => 'Exercez d’abord les lignes';

  @override
  String learnQsoSymbolsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count symboles à apprendre',
      one: '1 symbole à apprendre',
    );
    return '$_temp0';
  }

  @override
  String get learnGlossaryTitle => 'Que signifient ces mots ?';

  @override
  String get glossaryKoch => 'Méthode Koch : les caractères s’apprennent à pleine vitesse, deux au départ puis un de plus par leçon, dès que vous copiez à 90 %.';

  @override
  String get glossaryWpm => 'WPM : mots par minute, comptés avec le mot standard PARIS. La vitesse des caractères est la rapidité de chaque caractère lui-même.';

  @override
  String get glossaryFarnsworth => 'Farnsworth : les caractères restent rapides, mais les pauses entre eux s’allongent pour vous laisser réfléchir. La vitesse effective compte ces pauses.';

  @override
  String get glossaryQso => 'QSO : un contact entre deux stations. CQ = appel à tous, DE = de, K = à vous.';

  @override
  String get glossaryRst => 'RST : un rapport de signal — lisibilité, force, tonalité. 599 signifie parfait. 73 signifie amitiés.';

  @override
  String get learnVerdictNotCredited => 'Rien d’enregistré : aucun symbole répondu.';

  @override
  String get learnVerdictAssisted => 'Pratique avec aide';

  @override
  String get learnVerdictAssistedHint => 'Des réécoutes ou révélations ont été utilisées : cet essai compte seulement comme pratique, sans déblocage ni mise à jour des révisions. Essayez le prochain sans réécoute.';

  @override
  String get learnVerdictPractice => 'Pratique enregistrée';

  @override
  String get learnVerdictPracticeHint => 'La pratique libre met à jour statistiques et révisions mais ne fait jamais avancer le cours. Seul le défi de leçon, depuis l’accueil Apprendre, le fait.';

  @override
  String get learnVerdictCourseComplete => 'Dernier défi réussi : tout le cours des caractères est à vous.';

  @override
  String learnVerdictTooShort(int count, int min) {
    return 'Défi incomplet : $count symboles sur $min';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return 'Un défi compte au moins $min symboles. Lancez la leçon depuis l’accueil Apprendre ou augmentez la longueur de session dans les réglages.';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return 'Pas assez de copies de $chars';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return 'Un défi exige au moins $min copies de chaque nouveau symbole. Réessayez : le défi les inclut exprès.';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return 'Nouveau symbole sous 90 % : $chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => 'Le reste était bon ; le nouveau symbole décide de la leçon. Écoutez-le face à son voisin et exercez-le avant le prochain défi.';

  @override
  String get learnVerdictBelowAccuracyHint => 'Moins de 90 % au total. Un court exercice sur les symboles faibles ci-dessous, puis retentez le défi.';

  @override
  String get learnDrillWeak => 'Exercer les symboles faibles';

  @override
  String get learnRetryChallenge => 'Retenter le défi';

  @override
  String get learnTakeChallenge => 'Passer le défi de la leçon';

  @override
  String learnChallengeTitle(int lesson) {
    return 'Défi de la leçon $lesson';
  }

  @override
  String get learnPracticeTitle => 'Pratique';

  @override
  String get learnMeaningsTitle => 'Significations';

  @override
  String get firstLessonTitle => 'Première leçon';

  @override
  String firstLessonStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get firstLessonHearTitle => 'Vous l’entendez ?';

  @override
  String get firstLessonHearBody => 'Touchez Lire. Vous devriez entendre une courte suite de bips (ou voir un flash / sentir une vibration si activés).';

  @override
  String get firstLessonHeard => 'Je l’ai entendu';

  @override
  String get firstLessonNotHeard => 'Je n’ai rien entendu';

  @override
  String get firstLessonNoSoundTitle => 'Pas de son ?';

  @override
  String get firstLessonNoSoundBody => 'Montez le volume et vérifiez le mode silencieux ou Ne pas déranger. Vous pouvez aussi suivre un flash d’écran ou une vibration.';

  @override
  String get firstLessonUseFlash => 'Faire aussi clignoter l’écran';

  @override
  String get firstLessonUseVibration => 'Vibrer aussi';

  @override
  String get firstLessonPlay => 'Lire';

  @override
  String get firstLessonSoundsTitle => 'Court et long';

  @override
  String get firstLessonSoundsBody => 'Le morse a deux sons : un dit court et un dah trois fois plus long. Un caractère est un motif de ces sons ; un court silence sépare les caractères. Touchez chacun pour l’entendre.';

  @override
  String get firstLessonDit => 'dit';

  @override
  String get firstLessonDah => 'dah';

  @override
  String get firstLessonWorkedTitle => 'Un exemple résolu';

  @override
  String get firstLessonWorkedBody => 'Écoutez d’abord ; la réponse apparaît après le son. Vous n’avez pas encore à répondre.';

  @override
  String firstLessonWorkedReveal(String char) {
    return 'C’était $char';
  }

  @override
  String get firstLessonTrialsTitle => 'K ou M ?';

  @override
  String get firstLessonTrialsBody => 'Écoutez, puis touchez le caractère entendu. Réécoutez autant que vous voulez : ce n’est pas un test.';

  @override
  String firstLessonTrialRound(int round, int total) {
    return 'Tour $round sur $total';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return 'Oui, c’était $char';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return 'C’était $char, pas $answer. Écoutez-les côte à côte.';
  }

  @override
  String get firstLessonTooFast => 'Trop rapide ? Rythme débutant (pauses plus longues entre caractères)';

  @override
  String get firstLessonNextTitle => 'Et ensuite';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '$correct / $total réponses correctes cette manche. Choisissez la suite et continuez à votre rythme.';
  }

  @override
  String get firstLessonNextGuided => 'Courte pratique : 10 symboles seuls';

  @override
  String get firstLessonNextSend => 'Essayer d’émettre';

  @override
  String get firstLessonSendGuide => 'Émettre : maintenez brièvement pour un dit, plus longtemps pour un dah. Avec des palettes, un côté fait les dits et l’autre les dahs. Relâchez et marquez une courte pause entre caractères. Pioche ou iambique A / B se change plus tard ; peu importe pour l’instant.';

  @override
  String get firstLessonReplayAnytime => 'Vous pouvez revoir cette leçon à tout moment depuis l’accueil Apprendre.';

  @override
  String get firstLessonContinue => 'Continuer';

  @override
  String get firstLessonTrialNext => 'Tour suivant';

  @override
  String get sendFirstUseTitle => 'Première manipulation ?';

  @override
  String get sendFirstUseStraight => 'Maintenez brièvement pour un dit, environ trois fois plus pour un dah. Courte pause entre caractères, plus longue entre mots.';

  @override
  String get sendFirstUsePaddles => 'Maintenez la palette marquée point pour les points, celle marquée trait pour les traits ; le manipulateur règle leur durée. Pause brève entre caractères, plus longue entre mots.';

  @override
  String get sendFirstUseDismiss => 'Compris';

  @override
  String get learnSpeedPresets => 'Rythme';

  @override
  String get learnPresetBeginner => 'Débutant 20 / 6';

  @override
  String get learnPresetStandard => 'Standard 20 / 8';

  @override
  String get learnPresetHelp => 'Les caractères sonnent à 20 WPM dans les deux ; le rythme débutant laisse des pauses plus longues (6 WPM effectifs).';

  @override
  String get learnPlanStepIntro => 'Première leçon';

  @override
  String get learnPlanStepRecognition => 'Symboles seuls';

  @override
  String get learnPlanReasonFirstLesson => 'Écouter les sons et distinguer K de M (environ 3 minutes)';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return 'Un symbole à la fois : $symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return 'Courts groupes mélangés de $count symboles ; le défi de 50 symboles viendra plus tard';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return 'Facultatif : écoutez le modèle, puis manipulez $count cibles courtes';
  }

  @override
  String get learnQsoReadyTitle => 'Prêt pour un QSO';

  @override
  String get learnQsoNotReadyTitle => 'Tous les symboles ne sont pas encore appris';

  @override
  String get learnQsoMissingBody => 'Un QSO utilise ces symboles pas encore appris — touchez-en un pour l’entendre. Vous pouvez explorer quand même ; le clavier montre tous les symboles.';

  @override
  String get learnQsoShorthandHint => 'Exercez d’abord les abréviations (CQ, DE, UR, RST, TNX, 73) pour que les lignes aient un sens.';

  @override
  String get learnQsoPractiseShorthand => 'Exercer les abréviations';

  @override
  String get learnQsoHowTitle => 'Déroulement d’un QSO';

  @override
  String get learnQsoHowBody => 'Appel (CQ = à tous, DE = de), réponse avec indicatifs, échange d’un rapport (RST), du prénom et du QTH (lieu), puis 73 (amitiés) et <SK> (fin). K signifie à vous.';

  @override
  String get learnQsoExploreLabel => 'Contient des symboles non appris';

  @override
  String get statsCoursePassed => 'Cours réussi';

  @override
  String get firstLessonPlayAgain => 'Rejouer';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return 'Défi de la leçon $lesson : $count symboles, 90 % débloque $char';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return 'Défi de la leçon $lesson : $count symboles à 90 % terminent le cours';
  }

  @override
  String get learnQsoShorthandTitle => 'Exercez d’abord les abréviations';

  @override
  String get learnQsoExchangeTitle => 'Exercez d’abord les lignes de QSO';

  @override
  String get learnQsoExchangeHint => 'Copiez des lignes isolées d’un contact (un échange à la fois) avant de mener un QSO complet dans le simulateur.';

  @override
  String get sendGuideTitle => 'Apprendre à émettre';

  @override
  String sendGuideStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get sendGuideHear => 'Écouter le modèle';

  @override
  String get sendGuideListening => 'Écoutez le rythme complet…';

  @override
  String get sendGuideTry => 'À vous d’émettre';

  @override
  String get sendGuideRetry => 'Reprendre cette cible';

  @override
  String get sendGuidePassed => 'Décodage correct. Passez à la cible suivante.';

  @override
  String get sendGuideComplete => 'Les deux signes et les groupes ont été émis correctement. Continuez en pratique libre.';

  @override
  String get sendGuideRhythm => 'Suivez le modèle : points courts, traits trois fois plus longs et une pause nette entre caractères.';

  @override
  String get learnContinueToday => 'Continuer l’apprentissage du jour';

  @override
  String get learnPlanDetails => 'Voir les détails du programme';

  @override
  String get learnGuidedSingle => 'Caractères seuls · 10 caractères';

  @override
  String get learnGuidedShort => 'Groupes de 3 · 15 caractères';

  @override
  String get learnGuidedGroups => 'Groupes de 5 · 20 caractères';

  @override
  String get learnGuidedRecommended => 'Prochaine étape recommandée';

  @override
  String get learnGuidedProgressHint => 'Après avoir réussi, passez aux groupes courts puis complets. La pratique guidée consolide les acquis ; le défi du cours débloque la leçon suivante.';

  @override
  String get learnGuidedContinue => 'Continuer la pratique guidée';

  @override
  String get learnGuidedRetry => 'Reprendre ce niveau';

  @override
  String get firstLessonZeroHint => 'Aucune bonne réponse pour le moment ? Ce n’est pas grave. Réécoutez la différence entre K et M, puis réessayez.';

  @override
  String get firstLessonPartialHint => 'Vous en avez reconnu certains. Comparez encore K et M et continuez à votre rythme.';

  @override
  String get firstLessonPerfectHint => 'Toutes les réponses de cette manche sont correctes. Consolidez cela avec une copie sans choix de réponses.';

  @override
  String get firstLessonPaceLocked => 'Cette manche a commencé : sa vitesse reste fixe. Vous pourrez la modifier dans les paramètres pour la prochaine manche.';

  @override
  String get learnRecentEvidenceHint => 'Les étapes reposent sur les copies sans aide des 14 derniers jours, à la même vitesse.';

  @override
  String get learnQsoConsolidateTitle => 'Consolider les caractères appris';

  @override
  String get learnQsoConsolidateHint => 'Débloqué ne signifie pas maîtrisé. Commencez par copier des caractères seuls pour obtenir des résultats récents sans aide.';

  @override
  String get learnQsoPractiseSymbols => 'Pratiquer ces caractères';

  @override
  String get learnQsoProtocolTitle => 'Comprendre les termes de QSO';

  @override
  String get learnQsoProtocolHint => 'Vérifiez le sens de CQ, DE, RST et 73 avant de commencer un QSO court.';

  @override
  String get learnQsoProtocolStart => 'Vérifier les termes';

  @override
  String learnQsoProtocolQuestion(String token) {
    return 'Que signifie $token dans un QSO ?';
  }

  @override
  String get learnQsoGeneralCall => 'Appel à toute station';

  @override
  String get learnQsoFromStation => 'De cette station';

  @override
  String get learnQsoSignalReport => 'Rapport de signal';

  @override
  String get learnQsoBestRegards => 'Salutations et au revoir';

  @override
  String get learnQsoProtocolCorrect => 'Bonne réponse';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return 'Sens correct : $meaning';
  }

  @override
  String get learnQsoProtocolPass => 'Les quatre termes ont été reconnus sans aide. Vous pouvez essayer un QSO court.';

  @override
  String get learnQsoProtocolPractice => 'Révisez ces significations avant de refaire la vérification.';

  @override
  String get learnQsoProtocolRetry => 'Vérifier à nouveau';

  @override
  String get learnQsoShortExchange => 'Pratiquer un QSO court';

  @override
  String get learnQsoShortExchangeHint => 'Confirmez les indicatifs, échangez les rapports de signal et prenez congé sans aide avant de passer au QSO complet.';

  @override
  String get learnQsoExplorePending => 'Explorer un QSO complet · pratique encore nécessaire';

  @override
  String get learnQsoReadyHint => 'Vous disposez de résultats récents sans aide et pouvez commencer des QSO simulés complets.';
}
