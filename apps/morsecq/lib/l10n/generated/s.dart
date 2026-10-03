import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_en.dart';
import 's_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// Product name; never translated
  ///
  /// In en, this message translates to:
  /// **'MorseCQ'**
  String get appName;

  /// Shell destination: Morse training
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// Shell destination: 1:1 Morse chat over Tox
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// Shell destination: Tox group chats
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// Shell destination: profile, identity, settings
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Shell destination: Morse handbook (alphabet, prosigns, Q-codes, translator)
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get navReference;

  /// One-line subtitle of the Learn destination (Learn home header)
  ///
  /// In en, this message translates to:
  /// **'Koch-method lessons, keying drills and copy practice.'**
  String get navLearnDescription;

  /// One-line subtitle of the Chat destination (empty conversation list, placeholder)
  ///
  /// In en, this message translates to:
  /// **'Serverless one-to-one Morse conversations over Tox P2P.'**
  String get navChatDescription;

  /// One-line subtitle of the Groups destination (empty group list, placeholder)
  ///
  /// In en, this message translates to:
  /// **'Group nets — many operators keying on one shared channel.'**
  String get navGroupsDescription;

  /// One-line subtitle of the Reference destination
  ///
  /// In en, this message translates to:
  /// **'Alphabet, prosigns, Q-codes, abbreviations and a two-way translator.'**
  String get navReferenceDescription;

  /// One-line subtitle of the Me destination
  ///
  /// In en, this message translates to:
  /// **'Your callsign, Tox identity, progress and settings.'**
  String get navMeDescription;

  /// Strip above the shell content after being offline for a while (ConnectionBannerPolicy)
  ///
  /// In en, this message translates to:
  /// **'Offline: not connected to the Tox network. Messages will be sent when you are back online.'**
  String get shellOfflineBanner;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get actionSettings;

  /// Tox DHT bootstrap in progress
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connectionConnecting;

  /// Connected to the Tox network
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get connectionOnline;

  /// Not connected to the Tox network
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get connectionOffline;

  /// Outgoing message waiting for the peer to come online
  ///
  /// In en, this message translates to:
  /// **'Queued — peer is offline'**
  String get messageStatusPending;

  /// Explains why a message can stay queued (P2P, no store-and-forward server)
  ///
  /// In en, this message translates to:
  /// **'Tox has no server: the message is delivered when the peer comes online.'**
  String get messageStatusPendingDetail;

  /// No description provided for @messageStatusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get messageStatusSending;

  /// No description provided for @messageStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get messageStatusSent;

  /// No description provided for @messageStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get messageStatusFailed;

  /// ChatException code wrong_password
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Try again.'**
  String get errorWrongPassword;

  /// ChatException code peer_offline
  ///
  /// In en, this message translates to:
  /// **'This contact is offline. Tox has no server, so the message waits until they come back.'**
  String get errorPeerOffline;

  /// ChatException code invalid_tox_id
  ///
  /// In en, this message translates to:
  /// **'That is not a valid Tox ID (76 hex characters).'**
  String get errorInvalidToxId;

  /// ChatException code already_friend
  ///
  /// In en, this message translates to:
  /// **'This Tox ID is already in your friend list.'**
  String get errorAlreadyFriend;

  /// ChatException code own_id
  ///
  /// In en, this message translates to:
  /// **'That is your own Tox ID.'**
  String get errorOwnId;

  /// ChatException code group_not_found
  ///
  /// In en, this message translates to:
  /// **'Group not found.'**
  String get errorGroupNotFound;

  /// ChatException code message_too_long
  ///
  /// In en, this message translates to:
  /// **'Message is too long for one Tox message.'**
  String get errorMessageTooLong;

  /// Fallback for any other ChatException code
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknown;

  /// Settings tile on the Me page
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Follow the OS language
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// From LearnStrings.lessonOf (Koch lesson progress)
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson} of {total}'**
  String learnLessonOf(int lesson, int total);

  /// From LearnStrings.charsLearned
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character learned} other{{count} characters learned}}'**
  String learnCharsLearned(int count);

  /// From LearnStrings.dailyGoalProgress (characters copied today vs goal)
  ///
  /// In en, this message translates to:
  /// **'{done} / {goal} chars'**
  String learnDailyGoalProgress(int done, int goal);

  /// From LearnStrings.streakDays
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day streak} other{{days} day streak}}'**
  String learnStreakDays(int days);

  /// From LearnStrings.reviewDueCount (spaced-repetition characters due)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing due} =1{1 due} other{{count} due}}'**
  String learnReviewDueCount(int count);

  /// From LearnStrings.roundScore
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String learnRoundScore(int correct, int total);

  /// From LearnStrings.roundOf
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String learnRoundOf(int round);

  /// From LearnStrings.accuracyPercent; percent is already rounded (0-100)
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String learnAccuracyPercent(int percent);

  /// From LearnStrings.charsSent
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character sent} other{{count} characters sent}}'**
  String learnCharsSent(int count);

  /// From LearnStrings.lessonUnlocked
  ///
  /// In en, this message translates to:
  /// **'Next character unlocked: {char}'**
  String learnLessonUnlocked(String char);

  /// From LearnStrings.confusedAs when nothing was answered
  ///
  /// In en, this message translates to:
  /// **'{target} missed'**
  String learnConfusedMissed(String target);

  /// From LearnStrings.confusedAs when a wrong character was answered
  ///
  /// In en, this message translates to:
  /// **'{target} heard as {answered}'**
  String learnConfusedAs(String target, String answered);

  /// From LearnStrings.wpm; wpm is pre-formatted (e.g. 18)
  ///
  /// In en, this message translates to:
  /// **'{wpm} wpm'**
  String learnWpmValue(String wpm);

  /// From LearnStrings.hz; hz is pre-formatted (e.g. 600)
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String learnHzValue(String hz);

  /// From LearnStrings.charsCount (session length)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character} other{{count} characters}}'**
  String learnCharsCount(int count);

  /// From StatsStrings.lessonOf
  ///
  /// In en, this message translates to:
  /// **'{lesson} / {total}'**
  String statsLessonOf(int lesson, int total);

  /// From StatsStrings.charsLearned
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character learned} other{{count} characters learned}}'**
  String statsCharsLearned(int count);

  /// From StatsStrings.percent; percent is pre-formatted (e.g. 92.5)
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statsPercent(String percent);

  /// From StatsStrings.charsCopied
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 char copied} other{{count} chars copied}}'**
  String statsCharsCopied(int count);

  /// From StatsStrings.sessions
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String statsSessions(int count);

  /// From StatsStrings.days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String statsDays(int count);

  /// From StatsStrings.bestStreak
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{best 1 day} other{best {count} days}}'**
  String statsBestStreak(int count);

  /// From StatsStrings.goalProgress
  ///
  /// In en, this message translates to:
  /// **'{done} / {goal} chars'**
  String statsGoalProgress(int done, int goal);

  /// From StatsStrings.goalRemaining
  ///
  /// In en, this message translates to:
  /// **'{remaining, plural, =1{1 char to go} other{{remaining} chars to go}}'**
  String statsGoalRemaining(int remaining);

  /// From StatsStrings.trendSubtitle
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last session} other{Last {count} sessions}}'**
  String statsTrendSubtitle(int count);

  /// From StatsStrings.tooltipSession
  ///
  /// In en, this message translates to:
  /// **'Session {index} of {total}'**
  String statsTooltipSession(int index, int total);

  /// From StatsStrings.tooltipCopied
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String statsTooltipCopied(int correct, int total);

  /// From StatsStrings.tooltipLesson
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson}'**
  String statsTooltipLesson(int lesson);

  /// From StatsStrings.attempts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String statsAttempts(int count);

  /// From StatsStrings.correctOf
  ///
  /// In en, this message translates to:
  /// **'{correct} of {attempts} correct'**
  String statsCorrectOf(int correct, int attempts);

  /// From StatsStrings.lessonIntroduced
  ///
  /// In en, this message translates to:
  /// **'Introduced in lesson {lesson}'**
  String statsLessonIntroduced(int lesson);

  /// From StatsStrings.srsBox (Leitner box)
  ///
  /// In en, this message translates to:
  /// **'Box {box} of {maxBox}'**
  String statsSrsBox(int box, int maxBox);

  /// From StatsStrings.srsDueIn
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Due tomorrow} other{Due in {days} days}}'**
  String statsSrsDueIn(int days);

  /// From StatsStrings.times
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String statsTimes(int count);

  /// From StatsStrings.heatmapCell (semantics label of one heatmap cell)
  ///
  /// In en, this message translates to:
  /// **'{target} answered as {answered}, {count, plural, =1{1 time} other{{count} times}}'**
  String statsHeatmapCell(String target, String answered, int count);

  /// From StatsStrings.calendarDay; date is pre-formatted
  ///
  /// In en, this message translates to:
  /// **'{date}: {chars, plural, =0{no practice} other{{chars} chars}}'**
  String statsCalendarDay(String date, int chars);

  /// From StatsStrings.activeDays
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day} other{{count} active days}}'**
  String statsActiveDays(int count);

  /// From ReferenceStrings.entryCount (matches in a reference section)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String referenceEntryCount(int count);

  /// From ReferenceStrings.wpm; wpm is pre-rounded (e.g. 18)
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM'**
  String referenceWpmValue(String wpm);

  /// From ReferenceStrings.hz; hz is pre-rounded (e.g. 600)
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String referenceHzValue(String hz);

  /// From ReferenceStrings.skippedChars; chars lists the characters that have no Morse code
  ///
  /// In en, this message translates to:
  /// **'Skipped (no Morse code): {chars}'**
  String referenceSkippedChars(String chars);

  /// Mnemonic dialog: 1-based position of the character in the Koch teaching order
  ///
  /// In en, this message translates to:
  /// **'Koch position: {position}'**
  String referenceKochPositionValue(int position);

  /// From ReferenceStrings.estimatedSpeed; wpm is pre-rounded
  ///
  /// In en, this message translates to:
  /// **'Estimated {wpm} WPM'**
  String referenceEstimatedSpeed(String wpm);

  /// From AccountStrings.copied (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tox ID copied to clipboard'**
  String get accountCopied;

  /// From AccountStrings.showQr (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get accountShowQr;

  /// From AccountStrings.toxId (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tox ID'**
  String get accountToxId;

  /// From AccountStrings.displayName (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get accountDisplayName;

  /// From AccountStrings.displayNameHint (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your callsign or nickname'**
  String get accountDisplayNameHint;

  /// From AccountStrings.displayNameRequired (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get accountDisplayNameRequired;

  /// From AccountStrings.statusMessage (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Status message'**
  String get accountStatusMessage;

  /// From AccountStrings.password (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// From AccountStrings.passwordOptional (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get accountPasswordOptional;

  /// From AccountStrings.confirmPassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get accountConfirmPassword;

  /// From AccountStrings.passwordsDoNotMatch (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get accountPasswordsDoNotMatch;

  /// From AccountStrings.showPassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get accountShowPassword;

  /// From AccountStrings.hidePassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get accountHidePassword;

  /// From AccountStrings.strengthWeak (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Weak: use at least 8 characters'**
  String get accountStrengthWeak;

  /// From AccountStrings.strengthFair (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Fair: 12+ characters with mixed types is better'**
  String get accountStrengthFair;

  /// From AccountStrings.strengthStrong (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get accountStrengthStrong;

  /// From AccountStrings.startupInspecting (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Checking your identity…'**
  String get accountStartupInspecting;

  /// From AccountStrings.startupOpening (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Opening your identity…'**
  String get accountStartupOpening;

  /// From AccountStrings.startupFailedTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Could not start'**
  String get accountStartupFailedTitle;

  /// From AccountStrings.startupFailedBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'MorseCQ could not read your identity. Nothing was changed; you can try again.'**
  String get accountStartupFailedBody;

  /// From AccountStrings.connectionTapToReconnect (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tap to reconnect'**
  String get accountConnectionTapToReconnect;

  /// From AccountStrings.welcomeTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your identity lives on this device'**
  String get accountWelcomeTitle;

  /// From AccountStrings.welcomeIntro (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'MorseCQ uses the Tox peer-to-peer network. There is no server and no account to sign up for: your identity is a key pair stored only here.'**
  String get accountWelcomeIntro;

  /// From AccountStrings.welcomePointNoServer (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No server, no phone number, no e-mail. Peers talk to each other directly, in Morse.'**
  String get accountWelcomePointNoServer;

  /// From AccountStrings.welcomePointTraining (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training progress is saved with your identity, so it can be backed up and moved between devices.'**
  String get accountWelcomePointTraining;

  /// From AccountStrings.welcomePointBackup (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Nobody can recover an identity for you. Back it up right after creating it, or you will lose it with the device.'**
  String get accountWelcomePointBackup;

  /// From AccountStrings.createIdentity (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Create identity'**
  String get accountCreateIdentity;

  /// From AccountStrings.restoreFromBackup (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get accountRestoreFromBackup;

  /// From AccountStrings.createTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Create your identity'**
  String get accountCreateTitle;

  /// From AccountStrings.createBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Pick a name others will see. A password encrypts the identity file on this device; leave it empty if you prefer to open the app without one.'**
  String get accountCreateBody;

  /// From AccountStrings.createButton (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get accountCreateButton;

  /// From AccountStrings.creating (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get accountCreating;

  /// From AccountStrings.backupTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Back up your identity now'**
  String get accountBackupTitle;

  /// From AccountStrings.backupBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your identity exists only on this device. If it is lost, reset or stolen, there is no way to recover it: your contacts will not recognise a new identity and your training progress is gone.'**
  String get accountBackupBody;

  /// From AccountStrings.backupWhatIsInside (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'The backup file contains your encrypted identity and your training progress. Keep it somewhere safe, outside this device.'**
  String get accountBackupWhatIsInside;

  /// From AccountStrings.backupSaveFile (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Save backup file'**
  String get accountBackupSaveFile;

  /// From AccountStrings.backupShareFile (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Share backup file'**
  String get accountBackupShareFile;

  /// From AccountStrings.backupSaved (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get accountBackupSaved;

  /// From AccountStrings.backupNotSaved (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Backup was not saved'**
  String get accountBackupNotSaved;

  /// From AccountStrings.backupFailed (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Could not write the backup'**
  String get accountBackupFailed;

  /// From AccountStrings.backupAcknowledge (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'I understand that without this backup my identity cannot be recovered.'**
  String get accountBackupAcknowledge;

  /// From AccountStrings.backupContinue (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Continue to MorseCQ'**
  String get accountBackupContinue;

  /// From AccountStrings.backupShowQrHint (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your Tox ID is how friends add you. Share it as text or as a QR code.'**
  String get accountBackupShowQrHint;

  /// From AccountStrings.restoreTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get accountRestoreTitle;

  /// From AccountStrings.restoreBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file exported from MorseCQ. If the identity was protected with a password you will need it here.'**
  String get accountRestoreBody;

  /// From AccountStrings.restoreChooseFile (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get accountRestoreChooseFile;

  /// From AccountStrings.restoreNoFile (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file first'**
  String get accountRestoreNoFile;

  /// From AccountStrings.restoreButton (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get accountRestoreButton;

  /// From AccountStrings.restoring (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get accountRestoring;

  /// From AccountStrings.restoreInvalidFile (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'This file is not a MorseCQ backup.'**
  String get accountRestoreInvalidFile;

  /// From AccountStrings.restoreReplacesWarning (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces the identity currently on this device.'**
  String get accountRestoreReplacesWarning;

  /// From AccountStrings.unlockTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Unlock your identity'**
  String get accountUnlockTitle;

  /// From AccountStrings.unlockBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your identity file is encrypted. Enter the password to continue.'**
  String get accountUnlockBody;

  /// From AccountStrings.unlockButton (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get accountUnlockButton;

  /// From AccountStrings.unlocking (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Unlocking…'**
  String get accountUnlocking;

  /// From AccountStrings.unlockRestoreInstead (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restore from backup instead'**
  String get accountUnlockRestoreInstead;

  /// From AccountStrings.meNoIdentity (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No identity loaded'**
  String get accountMeNoIdentity;

  /// From AccountStrings.sectionAccount (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionAccount;

  /// From AccountStrings.sectionTraining (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get accountSectionTraining;

  /// From AccountStrings.sectionAbout (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get accountSectionAbout;

  /// From AccountStrings.sectionDanger (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get accountSectionDanger;

  /// From AccountStrings.editProfile (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get accountEditProfile;

  /// From AccountStrings.editProfileBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Shown to your contacts on the Tox network.'**
  String get accountEditProfileBody;

  /// From AccountStrings.setPassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get accountSetPassword;

  /// From AccountStrings.changePassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accountChangePassword;

  /// From AccountStrings.removePassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Remove password'**
  String get accountRemovePassword;

  /// From AccountStrings.currentPassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get accountCurrentPassword;

  /// From AccountStrings.newPassword (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get accountNewPassword;

  /// From AccountStrings.passwordUpdated (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get accountPasswordUpdated;

  /// From AccountStrings.passwordRemoved (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Password removed'**
  String get accountPasswordRemoved;

  /// From AccountStrings.profileUpdated (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get accountProfileUpdated;

  /// From AccountStrings.exportBackup (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get accountExportBackup;

  /// From AccountStrings.exportBackupSubtitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Save your identity and training progress to a file'**
  String get accountExportBackupSubtitle;

  /// From AccountStrings.trainingDefaults (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Playback & training defaults'**
  String get accountTrainingDefaults;

  /// From AccountStrings.trainingDefaultsSubtitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Speed, tone, Farnsworth spacing'**
  String get accountTrainingDefaultsSubtitle;

  /// From AccountStrings.trainingDefaultsPlaceholder (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Speed, tone and Farnsworth defaults will live here.'**
  String get accountTrainingDefaultsPlaceholder;

  /// From AccountStrings.aboutLicence (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get accountAboutLicence;

  /// From AccountStrings.aboutLicenceValue (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'GPL-3.0'**
  String get accountAboutLicenceValue;

  /// From AccountStrings.aboutSource (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get accountAboutSource;

  /// From AccountStrings.aboutSourceCopied (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Source link copied'**
  String get accountAboutSourceCopied;

  /// From AccountStrings.aboutBackend (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Backend'**
  String get accountAboutBackend;

  /// From AccountStrings.deleteIdentity (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete identity'**
  String get accountDeleteIdentity;

  /// From AccountStrings.deleteIdentitySubtitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Erase this identity, history and progress from this device'**
  String get accountDeleteIdentitySubtitle;

  /// From AccountStrings.deleteDialogTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete this identity?'**
  String get accountDeleteDialogTitle;

  /// From AccountStrings.deleteDialogBody (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'This removes your identity, chat history and training progress from this device. Without a backup it cannot be recovered. Type DELETE to confirm.'**
  String get accountDeleteDialogBody;

  /// From AccountStrings.deleteConfirmWord (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get accountDeleteConfirmWord;

  /// From AccountStrings.deleteConfirmHint (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get accountDeleteConfirmHint;

  /// From AccountStrings.deleteButton (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDeleteButton;

  /// Restore page: confirmation line under the file picker with the picked file's size
  ///
  /// In en, this message translates to:
  /// **'Backup file selected ({bytes} bytes)'**
  String accountRestoreFileChosenSize(int bytes);

  /// From ChatStrings.searchConversations (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get chatSearchConversations;

  /// From ChatStrings.noConversations (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatNoConversations;

  /// From ChatStrings.noSearchResults (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No conversations match'**
  String get chatNoSearchResults;

  /// From ChatStrings.pin (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get chatPin;

  /// From ChatStrings.unpin (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get chatUnpin;

  /// From ChatStrings.markRead (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get chatMarkRead;

  /// From ChatStrings.delete (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDelete;

  /// From ChatStrings.deleteConversationTitle (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get chatDeleteConversationTitle;

  /// From ChatStrings.deleteConversationBody (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Local history for this conversation is removed. Tox keeps no copy.'**
  String get chatDeleteConversationBody;

  /// From ChatStrings.draftPrefix (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Draft: '**
  String get chatDraftPrefix;

  /// From ChatStrings.selectConversation (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get chatSelectConversation;

  /// From ChatStrings.contacts (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get chatContacts;

  /// From ChatStrings.noMessages (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No messages yet — send CQ to start.'**
  String get chatNoMessages;

  /// From ChatStrings.trainingMode (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training mode'**
  String get chatTrainingMode;

  /// From ChatStrings.trainingModeOn (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training mode on: text hidden'**
  String get chatTrainingModeOn;

  /// From ChatStrings.trainingModeOff (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training mode off'**
  String get chatTrainingModeOff;

  /// Chat app-bar toggle and playback-sheet switch: play incoming messages as they arrive
  ///
  /// In en, this message translates to:
  /// **'Auto-play received Morse'**
  String get chatAutoPlay;

  /// Snack bar after turning chat auto-play on
  ///
  /// In en, this message translates to:
  /// **'Auto-play on: new messages play as they arrive'**
  String get chatAutoPlayOn;

  /// Snack bar after turning chat auto-play off
  ///
  /// In en, this message translates to:
  /// **'Auto-play off'**
  String get chatAutoPlayOff;

  /// From ChatStrings.reveal (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get chatReveal;

  /// From ChatStrings.hiddenText (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Listen first, then reveal'**
  String get chatHiddenText;

  /// From ChatStrings.play (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Play Morse'**
  String get chatPlay;

  /// From ChatStrings.stop (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chatStop;

  /// From ChatStrings.playbackSettings (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get chatPlaybackSettings;

  /// From ChatStrings.characterSpeed (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Character speed'**
  String get chatCharacterSpeed;

  /// From ChatStrings.farnsworthSpeed (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Farnsworth speed'**
  String get chatFarnsworthSpeed;

  /// From ChatStrings.tone (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get chatTone;

  /// From ChatStrings.wpm (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'WPM'**
  String get chatWpm;

  /// From ChatStrings.hz (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Hz'**
  String get chatHz;

  /// From ChatStrings.members (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get chatMembers;

  /// From ChatStrings.leaveGroup (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get chatLeaveGroup;

  /// From ChatStrings.leaveGroupTitle (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Leave this group?'**
  String get chatLeaveGroupTitle;

  /// From ChatStrings.leaveGroupBody (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving messages. Rejoin later with the chat id.'**
  String get chatLeaveGroupBody;

  /// From ChatStrings.leave (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get chatLeave;

  /// From ChatStrings.conferenceNote (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Legacy conference: Morse keying metadata (v2) will not be available here. Text still works.'**
  String get chatConferenceNote;

  /// From ChatStrings.clearHistory (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get chatClearHistory;

  /// From ChatStrings.modeStraightKey (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Straight key'**
  String get chatModeStraightKey;

  /// From ChatStrings.modePaddles (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Paddles'**
  String get chatModePaddles;

  /// Hint in the read-only chat draft field: messages are keyed with the straight key or paddles, not typed
  ///
  /// In en, this message translates to:
  /// **'Key your message'**
  String get chatKeyMessage;

  /// From ChatStrings.send (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// From ChatStrings.tooLong (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Too long for one Tox message'**
  String get chatTooLong;

  /// From ChatStrings.keyHint (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Key on the pad or press Space'**
  String get chatKeyHint;

  /// From ChatStrings.paddleHint (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tap the paddles or hold Ctrl (left dit, right dah)'**
  String get chatPaddleHint;

  /// From ChatStrings.deleteLast (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete last character'**
  String get chatDeleteLast;

  /// From ChatStrings.noFriends (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No friends yet. Add one with their Tox ID.'**
  String get chatNoFriends;

  /// From ChatStrings.noRequests (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get chatNoRequests;

  /// From ChatStrings.addFriend (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get chatAddFriend;

  /// From ChatStrings.myToxId (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'My Tox ID'**
  String get chatMyToxId;

  /// From ChatStrings.toxIdLabel (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tox ID (76 hex characters)'**
  String get chatToxIdLabel;

  /// From ChatStrings.toxIdInvalid (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tox ID must be exactly 76 hex characters'**
  String get chatToxIdInvalid;

  /// From ChatStrings.toxIdOwn (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'That is your own Tox ID'**
  String get chatToxIdOwn;

  /// From ChatStrings.toxIdAlreadyFriend (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Already in your friend list'**
  String get chatToxIdAlreadyFriend;

  /// From ChatStrings.requestMessage (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatRequestMessage;

  /// From ChatStrings.defaultRequestMessage (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'MorseCQ CQ'**
  String get chatDefaultRequestMessage;

  /// From ChatStrings.sendRequest (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get chatSendRequest;

  /// From ChatStrings.requestSent (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get chatRequestSent;

  /// From ChatStrings.scanQr (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get chatScanQr;

  /// From ChatStrings.scanQrDesktopHint (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'QR scanning needs a phone camera'**
  String get chatScanQrDesktopHint;

  /// From ChatStrings.scanQrTitle (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Scan a Tox ID'**
  String get chatScanQrTitle;

  /// From ChatStrings.scanQrNotToxId (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'That QR code is not a Tox ID'**
  String get chatScanQrNotToxId;

  /// From ChatStrings.accept (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get chatAccept;

  /// From ChatStrings.reject (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get chatReject;

  /// From ChatStrings.copied (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get chatCopied;

  /// From ChatStrings.noIdentity (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No identity loaded'**
  String get chatNoIdentity;

  /// From ChatStrings.removeFriend (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get chatRemoveFriend;

  /// From ChatStrings.removeFriendTitle (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Remove this friend?'**
  String get chatRemoveFriendTitle;

  /// From ChatStrings.removeFriendBody (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'They will no longer be able to message you.'**
  String get chatRemoveFriendBody;

  /// From ChatStrings.remove (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get chatRemove;

  /// From ChatStrings.noGroups (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Create one or join by chat id.'**
  String get chatNoGroups;

  /// From ChatStrings.createGroup (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get chatCreateGroup;

  /// From ChatStrings.joinGroup (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get chatJoinGroup;

  /// From ChatStrings.groupName (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get chatGroupName;

  /// From ChatStrings.groupNameRequired (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Give the group a name'**
  String get chatGroupNameRequired;

  /// From ChatStrings.advanced (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get chatAdvanced;

  /// From ChatStrings.legacyConference (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Legacy conference (old clients)'**
  String get chatLegacyConference;

  /// From ChatStrings.legacyConferenceHint (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Not recommended: no persistent chat id, no Morse metadata.'**
  String get chatLegacyConferenceHint;

  /// From ChatStrings.create (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get chatCreate;

  /// From ChatStrings.chatIdLabel (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Chat id (64 hex characters)'**
  String get chatChatIdLabel;

  /// From ChatStrings.chatIdInvalid (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Chat id must be exactly 64 hex characters'**
  String get chatChatIdInvalid;

  /// From ChatStrings.password (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get chatPassword;

  /// From ChatStrings.join (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get chatJoin;

  /// From ChatStrings.joinRequested (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Joining — the group appears once a peer is found.'**
  String get chatJoinRequested;

  /// From ChatStrings.conferenceBadge (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Conference'**
  String get chatConferenceBadge;

  /// From ChatStrings.copyChatId (apps/morsecq/lib/ui/chat/chat_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Copy chat id'**
  String get chatCopyChatId;

  /// From LearnStrings.lessonCardTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Koch lesson'**
  String get learnLessonCardTitle;

  /// From LearnStrings.courseComplete (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Course complete - keep sharpening!'**
  String get learnCourseComplete;

  /// From LearnStrings.dailyGoalTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get learnDailyGoalTitle;

  /// From LearnStrings.dailyGoalMet (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached'**
  String get learnDailyGoalMet;

  /// From LearnStrings.noStreak (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Start a streak today'**
  String get learnNoStreak;

  /// From LearnStrings.continueLesson (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Continue lesson'**
  String get learnContinueLesson;

  /// From LearnStrings.receivePractice (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Receive practice'**
  String get learnReceivePractice;

  /// From LearnStrings.sendPractice (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Send practice'**
  String get learnSendPractice;

  /// From LearnStrings.reviewDue (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Review due characters'**
  String get learnReviewDue;

  /// From LearnStrings.settings (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training settings'**
  String get learnSettings;

  /// From LearnStrings.loading (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Loading your progress...'**
  String get learnLoading;

  /// From LearnStrings.identityRequired (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Create or unlock your identity to start training. Progress is stored with your identity so it travels with your backup.'**
  String get learnIdentityRequired;

  /// From LearnStrings.loadFailed (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your saved progress could not be read. Starting fresh; the old file was kept as .corrupt.'**
  String get learnLoadFailed;

  /// From LearnStrings.chooseDrill (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Choose a drill'**
  String get learnChooseDrill;

  /// From LearnStrings.drillGroups (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Random groups'**
  String get learnDrillGroups;

  /// From LearnStrings.drillWords (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get learnDrillWords;

  /// From LearnStrings.drillCallsigns (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Callsigns'**
  String get learnDrillCallsigns;

  /// From LearnStrings.drillQso (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'QSO'**
  String get learnDrillQso;

  /// Receive drill: one symbol per round
  ///
  /// In en, this message translates to:
  /// **'Single characters'**
  String get learnDrillCharacters;

  /// Receive drill: CW abbreviations and Q-codes
  ///
  /// In en, this message translates to:
  /// **'Abbreviations & Q-codes'**
  String get learnDrillAbbreviations;

  /// Receive drill: groups of digits
  ///
  /// In en, this message translates to:
  /// **'Number groups'**
  String get learnDrillNumbers;

  /// Receive drill: confusable pairs drilled against each other
  ///
  /// In en, this message translates to:
  /// **'Look-alike characters'**
  String get learnDrillConfusables;

  /// Receive drill: contest exchanges with cut numbers
  ///
  /// In en, this message translates to:
  /// **'Contest exchanges'**
  String get learnDrillContest;

  /// Drill picker subtitle for random groups
  ///
  /// In en, this message translates to:
  /// **'Random groups from every letter you know'**
  String get learnDrillGroupsHint;

  /// Drill picker subtitle for single characters
  ///
  /// In en, this message translates to:
  /// **'One character at a time - name it instantly'**
  String get learnDrillCharactersHint;

  /// Drill picker subtitle for words
  ///
  /// In en, this message translates to:
  /// **'Common English words'**
  String get learnDrillWordsHint;

  /// Drill picker subtitle for abbreviations
  ///
  /// In en, this message translates to:
  /// **'TNX, FB, QTH, QSL - the shorthand of the air'**
  String get learnDrillAbbreviationsHint;

  /// Drill picker subtitle for number groups
  ///
  /// In en, this message translates to:
  /// **'Five-digit groups, as in traffic and serials'**
  String get learnDrillNumbersHint;

  /// Drill picker subtitle for callsigns
  ///
  /// In en, this message translates to:
  /// **'Amateur callsigns from around the world'**
  String get learnDrillCallsignsHint;

  /// Drill picker subtitle for confusables
  ///
  /// In en, this message translates to:
  /// **'Pairs you mix up, like S/H or U/V, side by side'**
  String get learnDrillConfusablesHint;

  /// Drill picker subtitle for QSO
  ///
  /// In en, this message translates to:
  /// **'Lines from a full contact'**
  String get learnDrillQsoHint;

  /// Drill picker subtitle for contest exchanges
  ///
  /// In en, this message translates to:
  /// **'Call, 5NN and a serial or zone, at contest pace'**
  String get learnDrillContestHint;

  /// Drill picker subtitle for review
  ///
  /// In en, this message translates to:
  /// **'Characters that are due for review'**
  String get learnDrillReviewHint;

  /// Title of the radio tools screen and its entry button
  ///
  /// In en, this message translates to:
  /// **'Radio tools'**
  String get toolsTitle;

  /// Maidenhead locator tool title
  ///
  /// In en, this message translates to:
  /// **'Grid locator'**
  String get toolsGridTitle;

  /// Maidenhead tool subtitle
  ///
  /// In en, this message translates to:
  /// **'Locator from coordinates, distance and beam heading'**
  String get toolsGridHint;

  /// Band tool title
  ///
  /// In en, this message translates to:
  /// **'Bands & antennas'**
  String get toolsBandsTitle;

  /// Band tool subtitle
  ///
  /// In en, this message translates to:
  /// **'Which band a frequency is in, wavelength, dipole length'**
  String get toolsBandsHint;

  /// CW speed tool title
  ///
  /// In en, this message translates to:
  /// **'CW speed'**
  String get toolsSpeedTitle;

  /// CW speed tool subtitle
  ///
  /// In en, this message translates to:
  /// **'WPM to dit length, gaps and characters per minute'**
  String get toolsSpeedHint;

  /// RST tool title
  ///
  /// In en, this message translates to:
  /// **'RST report'**
  String get toolsRstTitle;

  /// RST tool subtitle
  ///
  /// In en, this message translates to:
  /// **'Build a signal report and see what each digit means'**
  String get toolsRstHint;

  /// UTC clock tool title
  ///
  /// In en, this message translates to:
  /// **'UTC clock'**
  String get toolsClockTitle;

  /// UTC clock tool subtitle
  ///
  /// In en, this message translates to:
  /// **'Log time in UTC, next to your local time'**
  String get toolsClockHint;

  /// Section header: coordinates to locator
  ///
  /// In en, this message translates to:
  /// **'From coordinates'**
  String get toolsGridFromCoordinates;

  /// Latitude field label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get toolsGridLatitude;

  /// Longitude field label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get toolsGridLongitude;

  /// Helper text under the coordinate fields
  ///
  /// In en, this message translates to:
  /// **'Decimal degrees; south and west are negative'**
  String get toolsGridCoordinatesHelp;

  /// Error for out-of-range coordinates
  ///
  /// In en, this message translates to:
  /// **'Latitude -90 to 90, longitude -180 to 180'**
  String get toolsGridInvalidCoordinates;

  /// Result label: the computed locator
  ///
  /// In en, this message translates to:
  /// **'Locator'**
  String get toolsGridLocator;

  /// Section header: distance between two locators
  ///
  /// In en, this message translates to:
  /// **'Distance and heading'**
  String get toolsGridDistanceSection;

  /// Field label: own locator
  ///
  /// In en, this message translates to:
  /// **'My locator'**
  String get toolsGridMine;

  /// Field label: other station's locator
  ///
  /// In en, this message translates to:
  /// **'Their locator'**
  String get toolsGridTheirs;

  /// Error for a malformed locator
  ///
  /// In en, this message translates to:
  /// **'Use 2, 4, 6 or 8 characters, e.g. OM89ex'**
  String get toolsGridInvalidLocator;

  /// Result label: centre of a locator square
  ///
  /// In en, this message translates to:
  /// **'Square centre'**
  String get toolsGridCenter;

  /// Result label: great-circle distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get toolsGridDistance;

  /// Result label: short-path bearing
  ///
  /// In en, this message translates to:
  /// **'Short-path heading'**
  String get toolsGridShortPath;

  /// Result label: long-path bearing
  ///
  /// In en, this message translates to:
  /// **'Long-path heading'**
  String get toolsGridLongPath;

  /// Frequency field label
  ///
  /// In en, this message translates to:
  /// **'Frequency (MHz)'**
  String get toolsBandsFrequency;

  /// Error for a non-positive frequency
  ///
  /// In en, this message translates to:
  /// **'Enter a frequency above 0'**
  String get toolsBandsInvalidFrequency;

  /// IARU region segment label
  ///
  /// In en, this message translates to:
  /// **'Region {number}'**
  String toolsBandsRegionLabel(int number);

  /// Explains the three IARU regions
  ///
  /// In en, this message translates to:
  /// **'1: Europe, Africa, Middle East - 2: the Americas - 3: Asia-Pacific'**
  String get toolsBandsRegionHelp;

  /// Result when the frequency is inside a band
  ///
  /// In en, this message translates to:
  /// **'In the {band} amateur band'**
  String toolsBandsInBand(String band);

  /// Result when the frequency is in no band
  ///
  /// In en, this message translates to:
  /// **'Outside the amateur bands'**
  String get toolsBandsOutOfBand;

  /// Result label: free-space wavelength
  ///
  /// In en, this message translates to:
  /// **'Wavelength'**
  String get toolsBandsWavelength;

  /// Result label: dipole cut length
  ///
  /// In en, this message translates to:
  /// **'Half-wave dipole (total)'**
  String get toolsBandsDipole;

  /// Result label: quarter-wave length
  ///
  /// In en, this message translates to:
  /// **'Quarter-wave vertical'**
  String get toolsBandsQuarterWave;

  /// Note under the antenna lengths
  ///
  /// In en, this message translates to:
  /// **'Lengths include a 0.95 end factor; trim to resonance.'**
  String get toolsBandsAntennaNote;

  /// Header of the band table
  ///
  /// In en, this message translates to:
  /// **'Band edges'**
  String get toolsBandsTable;

  /// QRP calling frequency in the band table
  ///
  /// In en, this message translates to:
  /// **'QRP CW {frequency}'**
  String toolsBandsQrp(String frequency);

  /// Disclaimer under the band table
  ///
  /// In en, this message translates to:
  /// **'ITU allocations. Your licence and national band plan may be narrower.'**
  String get toolsBandsDisclaimer;

  /// Slider label: character WPM
  ///
  /// In en, this message translates to:
  /// **'Character speed'**
  String get toolsSpeedCharacter;

  /// Switch: enable Farnsworth spacing
  ///
  /// In en, this message translates to:
  /// **'Farnsworth spacing'**
  String get toolsSpeedFarnsworth;

  /// Slider label: Farnsworth overall WPM
  ///
  /// In en, this message translates to:
  /// **'Overall speed'**
  String get toolsSpeedOverall;

  /// Result label: dit length
  ///
  /// In en, this message translates to:
  /// **'Dit'**
  String get toolsSpeedDit;

  /// Result label: dah length
  ///
  /// In en, this message translates to:
  /// **'Dah'**
  String get toolsSpeedDah;

  /// Result label: character gap
  ///
  /// In en, this message translates to:
  /// **'Gap between characters'**
  String get toolsSpeedCharGap;

  /// Result label: word gap
  ///
  /// In en, this message translates to:
  /// **'Gap between words'**
  String get toolsSpeedWordGap;

  /// Result label: characters per minute
  ///
  /// In en, this message translates to:
  /// **'Characters per minute'**
  String get toolsSpeedCpm;

  /// Result label: time for one PARIS word
  ///
  /// In en, this message translates to:
  /// **'One PARIS word'**
  String get toolsSpeedParis;

  /// RST: readability scale
  ///
  /// In en, this message translates to:
  /// **'Readability (R)'**
  String get toolsRstReadability;

  /// RST: strength scale
  ///
  /// In en, this message translates to:
  /// **'Strength (S)'**
  String get toolsRstStrength;

  /// RST: tone scale
  ///
  /// In en, this message translates to:
  /// **'Tone (T)'**
  String get toolsRstTone;

  /// RST: the composed report
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get toolsRstReport;

  /// RST: cut-number form
  ///
  /// In en, this message translates to:
  /// **'Contest form'**
  String get toolsRstCut;

  /// RST: two-digit RS report
  ///
  /// In en, this message translates to:
  /// **'On voice (no tone)'**
  String get toolsRstPhone;

  /// RST readability 1
  ///
  /// In en, this message translates to:
  /// **'Unreadable'**
  String get toolsRstR1;

  /// RST readability 2
  ///
  /// In en, this message translates to:
  /// **'Barely readable, occasional words'**
  String get toolsRstR2;

  /// RST readability 3
  ///
  /// In en, this message translates to:
  /// **'Readable with considerable difficulty'**
  String get toolsRstR3;

  /// RST readability 4
  ///
  /// In en, this message translates to:
  /// **'Readable with practically no difficulty'**
  String get toolsRstR4;

  /// RST readability 5
  ///
  /// In en, this message translates to:
  /// **'Perfectly readable'**
  String get toolsRstR5;

  /// RST strength 1
  ///
  /// In en, this message translates to:
  /// **'Faint, barely perceptible'**
  String get toolsRstS1;

  /// RST strength 2
  ///
  /// In en, this message translates to:
  /// **'Very weak'**
  String get toolsRstS2;

  /// RST strength 3
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get toolsRstS3;

  /// RST strength 4
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get toolsRstS4;

  /// RST strength 5
  ///
  /// In en, this message translates to:
  /// **'Fairly good'**
  String get toolsRstS5;

  /// RST strength 6
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get toolsRstS6;

  /// RST strength 7
  ///
  /// In en, this message translates to:
  /// **'Moderately strong'**
  String get toolsRstS7;

  /// RST strength 8
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get toolsRstS8;

  /// RST strength 9
  ///
  /// In en, this message translates to:
  /// **'Extremely strong'**
  String get toolsRstS9;

  /// RST tone 1
  ///
  /// In en, this message translates to:
  /// **'Very rough and broad, raw AC'**
  String get toolsRstT1;

  /// RST tone 2
  ///
  /// In en, this message translates to:
  /// **'Very rough AC, harsh and broad'**
  String get toolsRstT2;

  /// RST tone 3
  ///
  /// In en, this message translates to:
  /// **'Rough, rectified but not filtered'**
  String get toolsRstT3;

  /// RST tone 4
  ///
  /// In en, this message translates to:
  /// **'Rough, some trace of filtering'**
  String get toolsRstT4;

  /// RST tone 5
  ///
  /// In en, this message translates to:
  /// **'Filtered but strongly ripple-modulated'**
  String get toolsRstT5;

  /// RST tone 6
  ///
  /// In en, this message translates to:
  /// **'Filtered, definite trace of ripple'**
  String get toolsRstT6;

  /// RST tone 7
  ///
  /// In en, this message translates to:
  /// **'Near pure, trace of ripple'**
  String get toolsRstT7;

  /// RST tone 8
  ///
  /// In en, this message translates to:
  /// **'Near perfect, slight trace of modulation'**
  String get toolsRstT8;

  /// RST tone 9
  ///
  /// In en, this message translates to:
  /// **'Perfect tone, no ripple at all'**
  String get toolsRstT9;

  /// UTC clock label
  ///
  /// In en, this message translates to:
  /// **'UTC'**
  String get toolsClockUtc;

  /// Local clock label
  ///
  /// In en, this message translates to:
  /// **'Local time'**
  String get toolsClockLocal;

  /// Note under the UTC clock
  ///
  /// In en, this message translates to:
  /// **'Logs and QSL cards use UTC.'**
  String get toolsClockNote;

  /// From LearnStrings.receiveTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get learnReceiveTitle;

  /// From LearnStrings.reviewTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get learnReviewTitle;

  /// From LearnStrings.listen (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Listen...'**
  String get learnListen;

  /// From LearnStrings.ready (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get learnReady;

  /// From LearnStrings.replay (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get learnReplay;

  /// From LearnStrings.answerHint (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Type what you heard'**
  String get learnAnswerHint;

  /// From LearnStrings.submit (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get learnSubmit;

  /// From LearnStrings.next (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get learnNext;

  /// From LearnStrings.finish (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get learnFinish;

  /// From LearnStrings.done (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get learnDone;

  /// From LearnStrings.backspace (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get learnBackspace;

  /// From LearnStrings.space (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get learnSpace;

  /// From LearnStrings.sent (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get learnSent;

  /// From LearnStrings.yourCopy (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your copy'**
  String get learnYourCopy;

  /// From LearnStrings.roundPerfect (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Perfect copy!'**
  String get learnRoundPerfect;

  /// From LearnStrings.sessionSummary (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get learnSessionSummary;

  /// From LearnStrings.lessonPassed (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Lesson passed'**
  String get learnLessonPassed;

  /// From LearnStrings.lessonNotPassed (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Keep at it: 90% unlocks the next one'**
  String get learnLessonNotPassed;

  /// From LearnStrings.reviewRecorded (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Review recorded'**
  String get learnReviewRecorded;

  /// From LearnStrings.weakChars (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get learnWeakChars;

  /// From LearnStrings.confusions (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get learnConfusions;

  /// From LearnStrings.noFeedbackWarning (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Sound, flash and haptics are all off - the screen will flash instead.'**
  String get learnNoFeedbackWarning;

  /// From LearnStrings.sendTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get learnSendTitle;

  /// From LearnStrings.sendThis (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Send this'**
  String get learnSendThis;

  /// From LearnStrings.copyFromMemory (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'From memory'**
  String get learnCopyFromMemory;

  /// From LearnStrings.hiddenTarget (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Hidden - key it from memory'**
  String get learnHiddenTarget;

  /// From LearnStrings.decoded (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Decoded'**
  String get learnDecoded;

  /// From LearnStrings.waitingForKey (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Start keying when ready'**
  String get learnWaitingForKey;

  /// From LearnStrings.restart (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get learnRestart;

  /// From LearnStrings.tryAnother (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Try another'**
  String get learnTryAnother;

  /// From LearnStrings.keyerStraight (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get learnKeyerStraight;

  /// From LearnStrings.keyerIambicA (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Iambic A'**
  String get learnKeyerIambicA;

  /// From LearnStrings.keyerIambicB (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Iambic B'**
  String get learnKeyerIambicB;

  /// From LearnStrings.legendStraight (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Space = key'**
  String get learnLegendStraight;

  /// From LearnStrings.legendPaddles (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Left Ctrl = dit, Right Ctrl = dah'**
  String get learnLegendPaddles;

  /// From LearnStrings.sendClean (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Clean fist - nothing to fix.'**
  String get learnSendClean;

  /// From LearnStrings.sendIssues (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Rhythm notes'**
  String get learnSendIssues;

  /// From LearnStrings.yourSending (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Decoded as'**
  String get learnYourSending;

  /// From LearnStrings.straightKeyLabel (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'KEY'**
  String get learnStraightKeyLabel;

  /// From LearnStrings.ditLabel (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'DIT'**
  String get learnDitLabel;

  /// From LearnStrings.dahLabel (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'DAH'**
  String get learnDahLabel;

  /// From LearnStrings.settingsTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Training settings'**
  String get learnSettingsTitle;

  /// From LearnStrings.characterSpeed (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Character speed'**
  String get learnCharacterSpeed;

  /// From LearnStrings.farnsworth (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Farnsworth spacing'**
  String get learnFarnsworth;

  /// From LearnStrings.farnsworthHelp (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Characters stay fast; the gaps between them stretch to this speed.'**
  String get learnFarnsworthHelp;

  /// From LearnStrings.effectiveSpeed (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Effective speed'**
  String get learnEffectiveSpeed;

  /// From LearnStrings.tone (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get learnTone;

  /// From LearnStrings.playSample (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Play sample'**
  String get learnPlaySample;

  /// From LearnStrings.sessionLength (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get learnSessionLength;

  /// From LearnStrings.feedback (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get learnFeedback;

  /// From LearnStrings.sound (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get learnSound;

  /// From LearnStrings.flash (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Screen flash'**
  String get learnFlash;

  /// From LearnStrings.haptic (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get learnHaptic;

  /// From LearnStrings.keyer (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Keyer'**
  String get learnKeyer;

  /// From LearnStrings.dailyGoal (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get learnDailyGoal;

  /// From ReferenceStrings.referenceTitle (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Morse reference'**
  String get referenceReferenceTitle;

  /// From ReferenceStrings.translatorTitle (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get referenceTranslatorTitle;

  /// From ReferenceStrings.play (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get referencePlay;

  /// From ReferenceStrings.stop (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get referenceStop;

  /// From ReferenceStrings.clear (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get referenceClear;

  /// From ReferenceStrings.close (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get referenceClose;

  /// From ReferenceStrings.emptyOutput (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get referenceEmptyOutput;

  /// From ReferenceStrings.searchHint (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Search characters, prosigns, Q-codes…'**
  String get referenceSearchHint;

  /// From ReferenceStrings.clearSearch (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get referenceClearSearch;

  /// From ReferenceStrings.noResults (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search.'**
  String get referenceNoResults;

  /// From ReferenceStrings.sectionAlphabet (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get referenceSectionAlphabet;

  /// From ReferenceStrings.sectionPunctuation (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Punctuation'**
  String get referenceSectionPunctuation;

  /// From ReferenceStrings.sectionProsigns (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Prosigns'**
  String get referenceSectionProsigns;

  /// From ReferenceStrings.sectionQCodes (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Q-codes'**
  String get referenceSectionQCodes;

  /// From ReferenceStrings.sectionAbbreviations (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'CW abbreviations'**
  String get referenceSectionAbbreviations;

  /// From ReferenceStrings.sectionKoch (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Koch order'**
  String get referenceSectionKoch;

  /// From ReferenceStrings.alphabetHint (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tap a card to hear it. Long-press for a mnemonic.'**
  String get referenceAlphabetHint;

  /// From ReferenceStrings.kochHint (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'The order the Koch method introduces characters (LCWO sequence). Start with K and M; add one when you copy at 90 %.'**
  String get referenceKochHint;

  /// From ReferenceStrings.mnemonicTitle (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Mnemonic'**
  String get referenceMnemonicTitle;

  /// From ReferenceStrings.meaningLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get referenceMeaningLabel;

  /// From ReferenceStrings.playbackSettings (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get referencePlaybackSettings;

  /// From ReferenceStrings.characterSpeed (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Character speed'**
  String get referenceCharacterSpeed;

  /// From ReferenceStrings.farnsworth (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Farnsworth spacing'**
  String get referenceFarnsworth;

  /// From ReferenceStrings.farnsworthHelp (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Characters stay at full speed; gaps stretch to the effective speed.'**
  String get referenceFarnsworthHelp;

  /// From ReferenceStrings.effectiveSpeed (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Effective speed'**
  String get referenceEffectiveSpeed;

  /// From ReferenceStrings.tone (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get referenceTone;

  /// From ReferenceStrings.modeTextToMorse (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Text → Morse'**
  String get referenceModeTextToMorse;

  /// From ReferenceStrings.modeMorseToText (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Morse → Text'**
  String get referenceModeMorseToText;

  /// From ReferenceStrings.modeKey (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get referenceModeKey;

  /// From ReferenceStrings.textInputLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get referenceTextInputLabel;

  /// From ReferenceStrings.textInputHint (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Type text to encode…'**
  String get referenceTextInputHint;

  /// From ReferenceStrings.patternOutputLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Morse'**
  String get referencePatternOutputLabel;

  /// From ReferenceStrings.copyPattern (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Copy pattern'**
  String get referenceCopyPattern;

  /// From ReferenceStrings.patternCopied (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Pattern copied'**
  String get referencePatternCopied;

  /// From ReferenceStrings.patternInputLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Morse'**
  String get referencePatternInputLabel;

  /// From ReferenceStrings.patternInputHint (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Type . and -, a space between letters, / between words'**
  String get referencePatternInputHint;

  /// From ReferenceStrings.textOutputLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get referenceTextOutputLabel;

  /// From ReferenceStrings.copyText (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get referenceCopyText;

  /// From ReferenceStrings.textCopied (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get referenceTextCopied;

  /// From ReferenceStrings.unknownPatternHelp (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Patterns with no character are shown as <pattern>.'**
  String get referenceUnknownPatternHelp;

  /// From ReferenceStrings.keypadDit (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Dit'**
  String get referenceKeypadDit;

  /// From ReferenceStrings.keypadDah (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Dah'**
  String get referenceKeypadDah;

  /// From ReferenceStrings.keypadCharGap (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Letter gap'**
  String get referenceKeypadCharGap;

  /// From ReferenceStrings.keypadWordGap (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Word gap'**
  String get referenceKeypadWordGap;

  /// From ReferenceStrings.keypadBackspace (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get referenceKeypadBackspace;

  /// From ReferenceStrings.keyHint (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Press and hold the key to send. On a keyboard, hold Space.'**
  String get referenceKeyHint;

  /// From ReferenceStrings.keyLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'KEY'**
  String get referenceKeyLabel;

  /// From ReferenceStrings.keyDecodedLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Decoded'**
  String get referenceKeyDecodedLabel;

  /// From ReferenceStrings.keyPendingLabel (apps/morsecq/lib/ui/reference/reference_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Keying'**
  String get referenceKeyPendingLabel;

  /// From StatsStrings.title (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// From StatsStrings.loading (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Loading your statistics...'**
  String get statsLoading;

  /// From StatsStrings.loadFailed (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your progress could not be loaded. Pull down or reopen to retry.'**
  String get statsLoadFailed;

  /// From StatsStrings.retry (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get statsRetry;

  /// From StatsStrings.emptyTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get statsEmptyTitle;

  /// From StatsStrings.emptyBody (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Finish your first receive or send session and this page fills up with your accuracy trend, per-character strengths and a practice calendar.'**
  String get statsEmptyBody;

  /// From StatsStrings.emptyCallToAction (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Head to Learn and press \"Continue lesson\" to start.'**
  String get statsEmptyCallToAction;

  /// From StatsStrings.overviewTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statsOverviewTitle;

  /// From StatsStrings.tileLesson (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Koch lesson'**
  String get statsTileLesson;

  /// From StatsStrings.tileAccuracy (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsTileAccuracy;

  /// From StatsStrings.noData (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get statsNoData;

  /// From StatsStrings.tilePractice (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get statsTilePractice;

  /// From StatsStrings.tileStreak (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsTileStreak;

  /// From StatsStrings.tileDailyGoal (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get statsTileDailyGoal;

  /// From StatsStrings.goalMet (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Reached today'**
  String get statsGoalMet;

  /// From StatsStrings.summaryTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Your stats'**
  String get statsSummaryTitle;

  /// From StatsStrings.summaryOpen (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get statsSummaryOpen;

  /// From StatsStrings.trendTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Accuracy trend'**
  String get statsTrendTitle;

  /// From StatsStrings.trendHint (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tap a point to inspect a session.'**
  String get statsTrendHint;

  /// From StatsStrings.seriesReceive (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get statsSeriesReceive;

  /// From StatsStrings.seriesSend (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get statsSeriesSend;

  /// From StatsStrings.axisSessions (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get statsAxisSessions;

  /// From StatsStrings.charsTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get statsCharsTitle;

  /// From StatsStrings.charsSubtitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Koch order. Tap a character for detail.'**
  String get statsCharsSubtitle;

  /// From StatsStrings.charsNotStarted (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Not practised yet'**
  String get statsCharsNotStarted;

  /// From StatsStrings.notInCourse (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Not part of the Koch course'**
  String get statsNotInCourse;

  /// From StatsStrings.srsTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Spaced repetition'**
  String get statsSrsTitle;

  /// From StatsStrings.srsNotTracked (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Not scheduled yet'**
  String get statsSrsNotTracked;

  /// From StatsStrings.srsDueNow (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statsSrsDueNow;

  /// From StatsStrings.confusionsTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Most often confused with'**
  String get statsConfusionsTitle;

  /// From StatsStrings.confusionsNone (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No confusions recorded'**
  String get statsConfusionsNone;

  /// From StatsStrings.confusionMissed (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'missed'**
  String get statsConfusionMissed;

  /// From StatsStrings.bucketLegendTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsBucketLegendTitle;

  /// From StatsStrings.bucketNone (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get statsBucketNone;

  /// From StatsStrings.bucketWeak (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'< 70%'**
  String get statsBucketWeak;

  /// From StatsStrings.bucketFair (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'70-89%'**
  String get statsBucketFair;

  /// From StatsStrings.bucketGood (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'90-97%'**
  String get statsBucketGood;

  /// From StatsStrings.bucketStrong (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'>= 98%'**
  String get statsBucketStrong;

  /// From StatsStrings.heatmapTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Confusions'**
  String get statsHeatmapTitle;

  /// From StatsStrings.heatmapSubtitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Rows are the sent character, columns what you answered. Darker means more often.'**
  String get statsHeatmapSubtitle;

  /// From StatsStrings.heatmapEmpty (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No confusions yet. Wrong answers will show up here.'**
  String get statsHeatmapEmpty;

  /// From StatsStrings.heatmapLegendLow (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get statsHeatmapLegendLow;

  /// From StatsStrings.heatmapLegendHigh (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get statsHeatmapLegendHigh;

  /// From StatsStrings.heatmapAxisTarget (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statsHeatmapAxisTarget;

  /// From StatsStrings.heatmapAxisAnswered (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get statsHeatmapAxisAnswered;

  /// From StatsStrings.calendarTitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Practice calendar'**
  String get statsCalendarTitle;

  /// From StatsStrings.calendarSubtitle (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Last 12 weeks'**
  String get statsCalendarSubtitle;

  /// From StatsStrings.calendarLegendLess (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get statsCalendarLegendLess;

  /// From StatsStrings.calendarLegendMore (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get statsCalendarLegendMore;

  /// From StatsStrings.streakExplanation (apps/morsecq/lib/ui/stats/stats_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'A streak counts consecutive calendar days with at least one session. Skipping a whole day resets it; practising twice in a day counts once.'**
  String get statsStreakExplanation;

  /// From LearnStrings.statistics (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get learnStatistics;

  /// From ListenStrings.title (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenTitle;

  /// From ListenStrings.start (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get listenStart;

  /// From ListenStrings.stop (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get listenStop;

  /// From ListenStrings.starting (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Starting microphone...'**
  String get listenStarting;

  /// From ListenStrings.clear (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get listenClear;

  /// From ListenStrings.copy (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get listenCopy;

  /// From ListenStrings.copied (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Decoded text copied'**
  String get listenCopied;

  /// From ListenStrings.settings (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Listen settings'**
  String get listenSettings;

  /// From ListenStrings.decoded (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Decoded'**
  String get listenDecoded;

  /// From ListenStrings.emptyHint (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Point the microphone at a Morse tone. Decoded text appears here.'**
  String get listenEmptyHint;

  /// From ListenStrings.idleHint (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tap Start to listen for a Morse tone.'**
  String get listenIdleHint;

  /// From ListenStrings.pending (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get listenPending;

  /// From ListenStrings.speed (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get listenSpeed;

  /// From ListenStrings.speedUnknown (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'-- WPM'**
  String get listenSpeedUnknown;

  /// From ListenStrings.level (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get listenLevel;

  /// From ListenStrings.toneOn (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get listenToneOn;

  /// From ListenStrings.tone (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tone frequency'**
  String get listenTone;

  /// From ListenStrings.toneLocked (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get listenToneLocked;

  /// From ListenStrings.toneSearching (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get listenToneSearching;

  /// From ListenStrings.toneManual (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get listenToneManual;

  /// From ListenStrings.autoTune (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Auto-tune'**
  String get listenAutoTune;

  /// From ListenStrings.autoTuneHelp (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Follow the strongest tone between 400 and 1000 Hz. Drag the slider to tune by hand instead.'**
  String get listenAutoTuneHelp;

  /// From ListenStrings.retune (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get listenRetune;

  /// From ListenStrings.blockSize (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Analysis block'**
  String get listenBlockSize;

  /// From ListenStrings.blockSizeHelp (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Smaller blocks place mark edges more precisely but pick up more noise. 256 samples (5.3 ms) suits 5-40 WPM.'**
  String get listenBlockSizeHelp;

  /// From ListenStrings.minElement (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Shortest element'**
  String get listenMinElement;

  /// From ListenStrings.minElementHelp (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tones and gaps shorter than this are ignored as clicks and dropouts.'**
  String get listenMinElementHelp;

  /// From ListenStrings.permissionDenied (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Microphone access was denied. Allow it in the system settings, then try again.'**
  String get listenPermissionDenied;

  /// From ListenStrings.permissionRetry (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get listenPermissionRetry;

  /// From ListenStrings.startFailed (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Could not start the microphone.'**
  String get listenStartFailed;

  /// From ListenStrings.noInput (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'No microphone was found. Connect one and try again.'**
  String get listenNoInput;

  /// From ListenStrings.wpm; estimated speed, pre-rounded
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM'**
  String listenWpmValue(int wpm);

  /// From ListenStrings.hz; detected / manual tone frequency, pre-rounded
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String listenHzValue(int hz);

  /// From ListenStrings.blockSamples; analysis block length, ms pre-formatted with one decimal
  ///
  /// In en, this message translates to:
  /// **'{samples} samples ({ms} ms)'**
  String listenBlockSamples(int samples, String ms);

  /// From ListenStrings.ms; shortest-element debounce in milliseconds
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String listenMsValue(int ms);

  /// From ListenStrings.stoppedInBackground (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Listening stopped while the app was in the background.'**
  String get listenStoppedInBackground;

  /// From LearnStrings.wpmUnknown (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'- wpm'**
  String get learnWpmUnknown;

  /// From LearnStrings.tipDitTooLongTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Dits too long'**
  String get learnTipDitTooLongTitle;

  /// From LearnStrings.tipDahTooShortTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Dahs too short'**
  String get learnTipDahTooShortTitle;

  /// From LearnStrings.tipIntraGapTooLongTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Elements spread out'**
  String get learnTipIntraGapTooLongTitle;

  /// From LearnStrings.tipCharGapTooShortTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Characters crowded'**
  String get learnTipCharGapTooShortTitle;

  /// From LearnStrings.tipWordGapTooShortTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Words crowded'**
  String get learnTipWordGapTooShortTitle;

  /// From LearnStrings.tipSpeedUnsteadyTitle (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Speed unsteady'**
  String get learnTipSpeedUnsteadyTitle;

  /// From LearnStrings.severityMinor (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'minor'**
  String get learnSeverityMinor;

  /// From LearnStrings.severityModerate (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'noticeable'**
  String get learnSeverityModerate;

  /// From LearnStrings.severitySevere (apps/morsecq/lib/ui/learn/learn_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'major'**
  String get learnSeveritySevere;

  /// Linux D-Bus notification default action label (required by the backend)
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notificationOpen;

  /// Android notification channel name (visible in system settings): inbound chat messages
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationChannelMessages;

  /// Android channel description for the messages channel
  ///
  /// In en, this message translates to:
  /// **'New Morse messages from friends and groups'**
  String get notificationChannelMessagesDescription;

  /// Android notification channel name: friend requests
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get notificationChannelFriendRequests;

  /// Android channel description for the friend-requests channel
  ///
  /// In en, this message translates to:
  /// **'Someone wants to add you as a friend'**
  String get notificationChannelFriendRequestsDescription;

  /// Android notification channel name: group invites
  ///
  /// In en, this message translates to:
  /// **'Group invites'**
  String get notificationChannelGroupInvites;

  /// Android channel description for the group-invites channel
  ///
  /// In en, this message translates to:
  /// **'A friend invited you to a group'**
  String get notificationChannelGroupInvitesDescription;

  /// Neutral notification body when prefs hide both text and Morse pattern
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get notificationNewMessage;

  /// Title of a friend-request notification
  ///
  /// In en, this message translates to:
  /// **'New friend request'**
  String get notificationFriendRequestTitle;

  /// Lesson card footer naming the newest learned character
  ///
  /// In en, this message translates to:
  /// **'New this lesson: {char}'**
  String learnNewestCharIs(String char);

  /// Semantics label of the newest learned-character chip
  ///
  /// In en, this message translates to:
  /// **'{char}, new'**
  String learnCharNewSemantics(String char);

  /// Send live view: the dit/dah pattern of the character being keyed (or -)
  ///
  /// In en, this message translates to:
  /// **'Keying: {pattern}'**
  String learnPendingPattern(String pattern);

  /// Send result: issue title followed by its severity label
  ///
  /// In en, this message translates to:
  /// **'{title} ({severity})'**
  String learnIssueHeadline(String title, String severity);

  /// A measured ratio of a dit, pre-formatted with one decimal (e.g. 1.5)
  ///
  /// In en, this message translates to:
  /// **'{ratio}x'**
  String learnRatioTimes(String ratio);

  /// Send tip for SendIssueKind.ditTooLong; ratio via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'Your dits are running long (about {ratio} of a dit). Think \'di\', not \'daah\' - a dit is a tap, not a press.'**
  String learnTipDitTooLong(String ratio);

  /// Send tip for SendIssueKind.dahTooShort; ratio via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'Your dahs are short (about {ratio} of a dit; aim for 3). Hold the dah for the length of three dits.'**
  String learnTipDahTooShort(String ratio);

  /// Send tip for SendIssueKind.intraGapTooLong; ratio via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'Gaps inside characters are too wide (about {ratio} of a dit). Keep the elements of one character tight together.'**
  String learnTipIntraGapTooLong(String ratio);

  /// Send tip for SendIssueKind.charGapTooShort; ratio via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'Characters are running into each other (gaps about {ratio} of a dit; aim for 3). Leave a clear pause after each character.'**
  String learnTipCharGapTooShort(String ratio);

  /// Send tip for SendIssueKind.wordGapTooShort; ratio via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'Words are too close (gaps about {ratio} of a dit; aim for 7). Count a long pause between words.'**
  String learnTipWordGapTooShort(String ratio);

  /// Send tip for SendIssueKind.speedUnsteady; percent = coefficient of variation x 100, rounded
  ///
  /// In en, this message translates to:
  /// **'Your speed wanders (variation {percent}%). Settle on one tempo and hold it for the whole line.'**
  String learnTipSpeedUnsteady(int percent);

  /// Measurement line under the ditTooLong tip; ratio pre-formatted with two decimals via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'{offending} of {total} dits too long (avg {ratio} dit)'**
  String learnIssueDetailDitTooLong(int offending, int total, String ratio);

  /// Measurement line under the dahTooShort tip
  ///
  /// In en, this message translates to:
  /// **'{offending} of {total} dahs too short (avg {ratio} dit)'**
  String learnIssueDetailDahTooShort(int offending, int total, String ratio);

  /// Measurement line under the intraGapTooLong tip
  ///
  /// In en, this message translates to:
  /// **'{offending} of {total} gaps inside characters too long (avg {ratio} dit)'**
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio);

  /// Measurement line under the charGapTooShort tip
  ///
  /// In en, this message translates to:
  /// **'{offending} of {total} character gaps too short (avg {ratio} dit)'**
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio);

  /// Measurement line under the wordGapTooShort tip
  ///
  /// In en, this message translates to:
  /// **'{offending} of {total} word gaps too short (avg {ratio} dit)'**
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio);

  /// Measurement line under the speedUnsteady tip; cv pre-formatted with two decimals
  ///
  /// In en, this message translates to:
  /// **'keying speed unsteady (cv {cv})'**
  String learnIssueDetailSpeedUnsteady(String cv);

  /// Accuracy tile detail line; allTime is the all-time accuracy already formatted via statsPercent (or statsNoData)
  ///
  /// In en, this message translates to:
  /// **'last 7 days / {allTime} all time'**
  String statsAccuracyDetail(String allTime);

  /// Practice duration of one hour or more
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String statsDurationHoursMinutes(int hours, int minutes);

  /// Practice duration under one hour
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String statsDurationMinutes(int minutes);

  /// Practice duration under one minute
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String statsDurationSeconds(int seconds);

  /// From AccountStrings.newPasswordRequired (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get accountNewPasswordRequired;

  /// From AccountStrings.toxIdQrSemantics (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Tox ID QR code'**
  String get accountToxIdQrSemantics;

  /// From AccountStrings.backupSaveDialogTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Save MorseCQ backup'**
  String get accountBackupSaveDialogTitle;

  /// From AccountStrings.backupShareSubject (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'MorseCQ identity backup'**
  String get accountBackupShareSubject;

  /// From AccountStrings.backupChooseDialogTitle (apps/morsecq/lib/ui/account/account_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Choose MorseCQ backup'**
  String get accountBackupChooseDialogTitle;

  /// Collapsed summary under Android inbox-style grouped message notifications
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new message} other{{count} new messages}}'**
  String notificationNewMessages(int count);

  /// Body of a friend-request notification when the request carries no message; name = display name or short Tox key
  ///
  /// In en, this message translates to:
  /// **'Friend request from {name}'**
  String notificationFriendRequestFrom(String name);

  /// Body of a friend-request notification with the requester's message; localises the separator
  ///
  /// In en, this message translates to:
  /// **'{name}: {message}'**
  String notificationFriendRequestBody(String name, String message);

  /// Title of a group-invite notification; group = group name
  ///
  /// In en, this message translates to:
  /// **'Invite to {group}'**
  String notificationGroupInviteTitle(String group);

  /// Body of a group-invite notification; name = inviting friend's display name or short Tox key
  ///
  /// In en, this message translates to:
  /// **'{name} invited you'**
  String notificationGroupInviteBody(String name);

  /// Tray menu row while the window is hidden; app = product name
  ///
  /// In en, this message translates to:
  /// **'Show {app}'**
  String desktopTrayShow(String app);

  /// Tray menu row while the window is visible; app = product name
  ///
  /// In en, this message translates to:
  /// **'Hide {app}'**
  String desktopTrayHide(String app);

  /// Tray menu checkbox row label while the sidetone is on
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get desktopTraySoundOn;

  /// Tray menu checkbox row label while the sidetone is off
  ///
  /// In en, this message translates to:
  /// **'Sound off'**
  String get desktopTraySoundOff;

  /// Tray menu row that exits the app for real; app = product name
  ///
  /// In en, this message translates to:
  /// **'Quit {app}'**
  String desktopTrayQuit(String app);

  /// Tray icon tooltip while there is unread traffic (plain app name otherwise)
  ///
  /// In en, this message translates to:
  /// **'{app} — {count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String desktopTrayTooltipUnread(String app, int count);

  /// Desktop window title while there is unread traffic; badge = count capped at 99+
  ///
  /// In en, this message translates to:
  /// **'({badge}) {app}'**
  String desktopWindowTitleUnread(String badge, String app);

  /// From ListenStrings.stateOn (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get listenStateOn;

  /// From ListenStrings.stateOff (apps/morsecq/lib/ui/listen/listen_strings.dart)
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get listenStateOff;

  /// Remaining UTF-8 byte budget under the compose field; count can be negative when the draft is too long
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 byte left} other{{count} bytes left}}'**
  String chatBytesLeftCount(int count);

  /// Group tile subtitle and conversation title subtitle
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String chatMemberCount(int count);

  /// Contacts page section header
  ///
  /// In en, this message translates to:
  /// **'Friends ({count})'**
  String chatFriendsCount(int count);

  /// Friend request inbox header
  ///
  /// In en, this message translates to:
  /// **'Friend requests ({count})'**
  String chatFriendRequestsCount(int count);

  /// Group invite inbox header
  ///
  /// In en, this message translates to:
  /// **'Group invites ({count})'**
  String chatGroupInvitesCount(int count);

  /// Group members sheet title
  ///
  /// In en, this message translates to:
  /// **'Members · {count}'**
  String chatMembersTitleCount(int count);

  /// Group invite subtitle; name is the shortened public key of the inviter
  ///
  /// In en, this message translates to:
  /// **'Invited by {name}'**
  String chatInvitedByName(String name);

  /// Own row in the group members sheet
  ///
  /// In en, this message translates to:
  /// **'{name} (You)'**
  String chatMemberSelf(String name);

  /// Playback settings slider caption, e.g. 'Character speed: 18 WPM'
  ///
  /// In en, this message translates to:
  /// **'{label}: {value} {unit}'**
  String chatSliderValue(String label, int value, String unit);

  /// Translator: the four-digit Chinese telegraph code groups of the typed Chinese characters (sent in Morse as digits)
  ///
  /// In en, this message translates to:
  /// **'Chinese telegraph code: {codes}'**
  String referenceTelegraphCodes(String codes);

  /// Translator: codebook choice, the mainland China (1983) telegraph codebook
  ///
  /// In en, this message translates to:
  /// **'Mainland 1983'**
  String get referenceTelegraphMainland;

  /// Translator: codebook choice, the Taiwan / Hong Kong telegraph codebook
  ///
  /// In en, this message translates to:
  /// **'Taiwan / HK'**
  String get referenceTelegraphTaiwan;

  /// Translator: shown in place of the code groups when the typed Chinese characters exist only in the other codebook
  ///
  /// In en, this message translates to:
  /// **'not in this codebook'**
  String get referenceTelegraphNone;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceStyles.
  ///
  /// In en, this message translates to:
  /// **'Interface style'**
  String get appearanceStyles;

  /// No description provided for @appearanceChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a style, preview, then apply'**
  String get appearanceChoose;

  /// No description provided for @appearanceMode.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get appearanceMode;

  /// No description provided for @appearancePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get appearancePreview;

  /// No description provided for @appearanceApply.
  ///
  /// In en, this message translates to:
  /// **'Apply style'**
  String get appearanceApply;

  /// No description provided for @appearanceRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get appearanceRestore;

  /// No description provided for @appearanceApplied.
  ///
  /// In en, this message translates to:
  /// **'Appearance saved'**
  String get appearanceApplied;

  /// No description provided for @appearanceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save appearance. Try again.'**
  String get appearanceSaveFailed;

  /// No description provided for @appearanceClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Brass'**
  String get appearanceClassic;

  /// No description provided for @appearanceModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Calm'**
  String get appearanceModern;

  /// No description provided for @appearanceRadio.
  ///
  /// In en, this message translates to:
  /// **'Night Radio'**
  String get appearanceRadio;

  /// No description provided for @appearancePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper Handbook'**
  String get appearancePaper;

  /// No description provided for @appearanceCartoon.
  ///
  /// In en, this message translates to:
  /// **'Fresh Cartoon'**
  String get appearanceCartoon;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Five styles with light and dark modes'**
  String get appearanceSubtitle;

  /// No description provided for @chatClearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation’s history on this device? Copies on other devices are unaffected. This cannot be undone.'**
  String get chatClearHistoryBody;

  /// No description provided for @chatLoadEarlier.
  ///
  /// In en, this message translates to:
  /// **'Load earlier messages'**
  String get chatLoadEarlier;

  /// No description provided for @chatHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load earlier messages. Tap to retry.'**
  String get chatHistoryLoadFailed;

  /// No description provided for @chatRetryHistory.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chatRetryHistory;

  /// No description provided for @chatNewMessages.
  ///
  /// In en, this message translates to:
  /// **'{count} new messages'**
  String chatNewMessages(int count);

  /// No description provided for @learnShowAllChars.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} characters'**
  String learnShowAllChars(int count);

  /// Badge on the note-to-self conversation (contacts, conversation list), and its title while the profile has no display name
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get chatSelfMe;

  /// Subtitle of the note-to-self conversation header: its messages are stored locally and never sent
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only'**
  String get chatSelfLocalOnly;

  /// Subtitle of the note-to-self entry at the top of Contacts
  ///
  /// In en, this message translates to:
  /// **'Drafts, practice and notes · never sent'**
  String get chatSelfContactSubtitle;

  /// No description provided for @learnShowFewerChars.
  ///
  /// In en, this message translates to:
  /// **'Show fewer characters'**
  String get learnShowFewerChars;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'zh': return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
