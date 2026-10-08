import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_de.dart';
import 's_en.dart';
import 's_es.dart';
import 's_fr.dart';
import 's_ja.dart';
import 's_ko.dart';
import 's_pt.dart';
import 's_ru.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
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

  /// Shell destination for local preferences and learning data
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

  /// One-line subtitle of the Reference destination
  ///
  /// In en, this message translates to:
  /// **'Alphabet, prosigns, Q-codes, abbreviations and a two-way translator.'**
  String get navReferenceDescription;

  /// Generic button that dismisses a dialog or sheet without changing anything
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic button that saves a form (edit profile, change password pages)
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Generic destructive button that deletes an item (currently unused; keep short)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Button that retries loading local data after a storage error
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// Generic button that closes a dialog, such as the language picker
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

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

  /// Inline error inside the language dialog when persisting the chosen language failed (the previous choice is kept and the dialog stays open)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the language setting. Try again.'**
  String get languageSaveFailed;

  /// Learn home, Koch lesson card: which lesson the user is on out of the whole course (e.g. 'Lesson 4 of 42'); also used in the appearance style preview
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson} of {total}'**
  String learnLessonOf(int lesson, int total);

  /// Learn home, Koch lesson card: how many Morse characters the user has unlocked so far
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character learned} other{{count} characters learned}}'**
  String learnCharsLearned(int count);

  /// Learn home, 'Today' card: characters practised today (receive and send practice both count) versus the daily goal (e.g. '120 / 200 chars')
  ///
  /// In en, this message translates to:
  /// **'{done} / {goal} chars'**
  String learnDailyGoalProgress(int done, int goal);

  /// Learn home, 'Today' card: number of consecutive days with practice
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day streak} other{{days} day streak}}'**
  String learnStreakDays(int days);

  /// Learn home: trailing count on the 'Review due characters' button — how many spaced-repetition characters are due for review
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing due} =1{1 due} other{{count} due}}'**
  String learnReviewDueCount(int count);

  /// Receive drill: result line for any round that was not a perfect copy (including one where every sent character was right but extra characters were typed); correct and total count characters
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String learnRoundScore(int correct, int total);

  /// Receive drill: header showing the number of the current round (1-based)
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String learnRoundOf(int round);

  /// A percentage; percent is already rounded (0-100). Used for the daily-goal completion inside the ring on the Learn home 'Today' card, and for accuracy in receive/send results and their per-character list
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String learnAccuracyPercent(int percent);

  /// Receive drill session summary: how many characters were played to the user in the session
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character sent} other{{count} characters sent}}'**
  String learnCharsSent(int count);

  /// Receive drill session summary: verdict when the lesson was passed and a new Koch character was unlocked; {char} is that character
  ///
  /// In en, this message translates to:
  /// **'Next character unlocked: {char}'**
  String learnLessonUnlocked(String char);

  /// Receive drill: confusion chip when the user typed nothing for the sent character {target}
  ///
  /// In en, this message translates to:
  /// **'{target} missed'**
  String learnConfusedMissed(String target);

  /// Receive drill: confusion chip when the user typed {answered} for the sent character {target}
  ///
  /// In en, this message translates to:
  /// **'{target} heard as {answered}'**
  String learnConfusedAs(String target, String answered);

  /// Training settings and send-practice tips: a speed in words per minute; wpm is pre-formatted (e.g. 18).
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM'**
  String learnWpmValue(String wpm);

  /// Training settings: the sidetone pitch in hertz; hz is pre-formatted (e.g. 600)
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String learnHzValue(String hz);

  /// Training settings: the session length in characters (slider value and label)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character} other{{count} characters}}'**
  String learnCharsCount(int count);

  /// Statistics overview, 'Koch lesson' tile: current lesson out of the total (e.g. '4 / 42')
  ///
  /// In en, this message translates to:
  /// **'{lesson} / {total}'**
  String statsLessonOf(int lesson, int total);

  /// Statistics overview, 'Koch lesson' tile: detail line with the number of unlocked characters
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character learned} other{{count} characters learned}}'**
  String statsCharsLearned(int count);

  /// Statistics: a percentage (accuracy tiles, chart axis ticks); percent is pre-formatted (e.g. 92.5)
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statsPercent(String percent);

  /// Statistics overview, 'Practice' tile: total characters copied across all sessions
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 char copied} other{{count} chars copied}}'**
  String statsCharsCopied(int count);

  /// Statistics: number of practice sessions (overview 'Practice' tile, statistics summary card)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String statsSessions(int count);

  /// Statistics: the current streak length in days ('Streak' tile)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String statsDays(int count);

  /// Statistics, 'Streak' tile: detail line with the longest streak ever reached
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{best 1 day} other{best {count} days}}'**
  String statsBestStreak(int count);

  /// Statistics, 'Daily goal' tile: characters practised today (receive and send practice both count) versus the daily goal
  ///
  /// In en, this message translates to:
  /// **'{done} / {goal} chars'**
  String statsGoalProgress(int done, int goal);

  /// Statistics, 'Daily goal' tile: how many more characters must be practised to reach today's goal
  ///
  /// In en, this message translates to:
  /// **'{remaining, plural, =1{1 char to go} other{{remaining} chars to go}}'**
  String statsGoalRemaining(int remaining);

  /// Statistics, accuracy trend chart: subtitle saying how many recent sessions are plotted
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last session} other{Last {count} sessions}}'**
  String statsTrendSubtitle(int count);

  /// Statistics, accuracy trend chart: tooltip heading for a tapped point — which session out of those plotted
  ///
  /// In en, this message translates to:
  /// **'Session {index} of {total}'**
  String statsTooltipSession(int index, int total);

  /// Statistics, accuracy trend chart: tooltip line with correct characters out of characters attempted in that session (copied for a receive session, keyed for a send session)
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String statsTooltipCopied(int correct, int total);

  /// Statistics, accuracy trend chart: tooltip line with the Koch lesson the session belonged to
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson}'**
  String statsTooltipLesson(int lesson);

  /// Statistics, character grid: semantics label giving how many times a character was played
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String statsAttempts(int count);

  /// Statistics, character detail dialog: how often the character was copied correctly out of all attempts
  ///
  /// In en, this message translates to:
  /// **'{correct} of {attempts} correct'**
  String statsCorrectOf(int correct, int attempts);

  /// Statistics, character detail dialog: the Koch lesson in which this character was introduced
  ///
  /// In en, this message translates to:
  /// **'Introduced in lesson {lesson}'**
  String statsLessonIntroduced(int lesson);

  /// Statistics, character detail dialog: the character's Leitner box in spaced repetition (e.g. 'Box 2 of 5')
  ///
  /// In en, this message translates to:
  /// **'Box {box} of {maxBox}'**
  String statsSrsBox(int box, int maxBox);

  /// Statistics, character detail dialog: when the character is next due for spaced-repetition review
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Due tomorrow} other{Due in {days} days}}'**
  String statsSrsDueIn(int days);

  /// Statistics, character detail dialog: how many times the character was confused with another one
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String statsTimes(int count);

  /// Statistics, confusion heatmap: screen-reader label of one cell — sent character {target} was answered as {answered} {count} times
  ///
  /// In en, this message translates to:
  /// **'{target} answered as {answered}, {count, plural, =1{1 time} other{{count} times}}'**
  String statsHeatmapCell(String target, String answered, int count);

  /// Statistics, practice calendar: line under the calendar describing the selected day; date is pre-formatted, chars is the characters practised that day
  ///
  /// In en, this message translates to:
  /// **'{date}: {chars, plural, =0{no practice} other{{chars} chars}}'**
  String statsCalendarDay(String date, int chars);

  /// Statistics, practice calendar: subtitle with how many days had practice in the shown period
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day} other{{count} active days}}'**
  String statsActiveDays(int count);

  /// Reference: number of entries in a group, shown at the right of the group's header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String referenceEntryCount(int count);

  /// Reference playback settings: a speed in words per minute; wpm is pre-rounded (e.g. 18)
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM'**
  String referenceWpmValue(String wpm);

  /// Reference playback settings: the tone pitch in hertz; hz is pre-rounded (e.g. 600)
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String referenceHzValue(String hz);

  /// Reference translator, Text to Morse: note listing input characters that have no Morse code and were skipped; chars is that list
  ///
  /// In en, this message translates to:
  /// **'Skipped (no Morse code): {chars}'**
  String referenceSkippedChars(String chars);

  /// Mnemonic dialog: 1-based position of the character in the Koch teaching order
  ///
  /// In en, this message translates to:
  /// **'Koch position: {position}'**
  String referenceKochPositionValue(int position);

  /// Reference translator, Key mode: the speed estimated from the user's keying; wpm is pre-rounded
  ///
  /// In en, this message translates to:
  /// **'Estimated {wpm} WPM'**
  String referenceEstimatedSpeed(String wpm);

  /// Me page: section header for training settings
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get accountSectionTraining;

  /// Me page: section header for app information (licence, source code, backend)
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get accountSectionAbout;

  /// Me page: tile that opens the training / playback settings
  ///
  /// In en, this message translates to:
  /// **'Playback & training defaults'**
  String get accountTrainingDefaults;

  /// Me page: subtitle of the training-defaults tile listing what it controls
  ///
  /// In en, this message translates to:
  /// **'Speed, tone, Farnsworth spacing'**
  String get accountTrainingDefaultsSubtitle;

  /// Me page, About section: tile title for the software licence
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get accountAboutLicence;

  /// Me page, About section: the licence identifier; normally kept as is (SPDX id)
  ///
  /// In en, this message translates to:
  /// **'GPL-3.0'**
  String get accountAboutLicenceValue;

  /// Me page, About section: tile that copies the source-code link
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get accountAboutSource;

  /// Snackbar after the source-code link was copied
  ///
  /// In en, this message translates to:
  /// **'Source link copied'**
  String get accountAboutSourceCopied;

  /// Conversation composer: tooltip of the send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// Learn home: title of the Koch lesson card
  ///
  /// In en, this message translates to:
  /// **'Koch lesson'**
  String get learnLessonCardTitle;

  /// Learn home, Koch lesson card: shown once every Koch character is unlocked
  ///
  /// In en, this message translates to:
  /// **'Course complete - keep sharpening!'**
  String get learnCourseComplete;

  /// Learn home: title of the daily goal card
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get learnDailyGoalTitle;

  /// Learn home, daily goal card: shown when today's goal is reached
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached'**
  String get learnDailyGoalMet;

  /// Learn home, daily goal card: shown instead of the streak when there is none
  ///
  /// In en, this message translates to:
  /// **'Start a streak today'**
  String get learnNoStreak;

  /// Learn home: primary button that starts the current Koch lesson
  ///
  /// In en, this message translates to:
  /// **'Continue lesson'**
  String get learnContinueLesson;

  /// Learn home: button that opens the receive (copy) drill picker
  ///
  /// In en, this message translates to:
  /// **'Receive practice'**
  String get learnReceivePractice;

  /// Learn home: button that opens send (keying) practice
  ///
  /// In en, this message translates to:
  /// **'Send practice'**
  String get learnSendPractice;

  /// Learn home: button that starts a spaced-repetition review of due characters
  ///
  /// In en, this message translates to:
  /// **'Review due characters'**
  String get learnReviewDue;

  /// Learn home: tooltip of the training settings button and that page's title
  ///
  /// In en, this message translates to:
  /// **'Training settings'**
  String get learnSettings;

  /// Learn tab: shown while training progress loads
  ///
  /// In en, this message translates to:
  /// **'Loading your progress...'**
  String get learnLoading;

  /// Learn home: error line shown when saved progress was unreadable and training restarted fresh
  ///
  /// In en, this message translates to:
  /// **'Your saved progress could not be read. Starting fresh; the old file was kept as .corrupt.'**
  String get learnLoadFailed;

  /// Learn drills: snack bar when a finished session could not be written to disk; the action retries the save
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your progress. The result still counts while MorseCQ stays open.'**
  String get learnProgressSaveFailed;

  /// Receive drill picker sheet: title
  ///
  /// In en, this message translates to:
  /// **'Choose a drill'**
  String get learnChooseDrill;

  /// Receive drill picker: drill with random groups of the characters the user already knows
  ///
  /// In en, this message translates to:
  /// **'Random groups'**
  String get learnDrillGroups;

  /// Receive drill picker: drill with common words
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get learnDrillWords;

  /// Receive drill picker: drill with amateur radio callsigns
  ///
  /// In en, this message translates to:
  /// **'Callsigns'**
  String get learnDrillCallsigns;

  /// Receive drill picker: drill with short QSO (radio contact) exchanges; QSO is a Q-code, keep as is
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

  /// Receive drill screen: app bar title
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get learnReceiveTitle;

  /// Receive drill picker / screen: title of the spaced-repetition review drill
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get learnReviewTitle;

  /// Receive drill: status while Morse is playing
  ///
  /// In en, this message translates to:
  /// **'Listen...'**
  String get learnListen;

  /// Receive drill: status when playback finished and an answer is expected
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get learnReady;

  /// Receive drill: button that plays the round again
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get learnReplay;

  /// Receive drill: hint inside the answer field
  ///
  /// In en, this message translates to:
  /// **'Type what you heard'**
  String get learnAnswerHint;

  /// Receive drill: button that checks the typed answer
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get learnSubmit;

  /// Receive drill: button that moves to the next round
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get learnNext;

  /// Receive drill: button on the last round that ends the session
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get learnFinish;

  /// Receive drill summary: button that closes the screen. Send practice: button that ends the attempt, records it and shows the result
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get learnDone;

  /// Receive drill on-screen keypad: screen-reader label of the backspace key
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get learnBackspace;

  /// Receive drill on-screen keypad: label of the space key
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get learnSpace;

  /// Receive drill round result: label of the line with what was sent
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get learnSent;

  /// Receive drill round result: label of the line with what the user typed
  ///
  /// In en, this message translates to:
  /// **'Your copy'**
  String get learnYourCopy;

  /// Receive drill round result: shown when every character was copied correctly
  ///
  /// In en, this message translates to:
  /// **'Perfect copy!'**
  String get learnRoundPerfect;

  /// Receive drill: title of the end-of-session summary
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get learnSessionSummary;

  /// Receive drill summary: verdict when the lesson was passed
  ///
  /// In en, this message translates to:
  /// **'Lesson passed'**
  String get learnLessonPassed;

  /// Receive drill summary: verdict when accuracy stayed under the 90% pass mark
  ///
  /// In en, this message translates to:
  /// **'Keep at it: 90% unlocks the next one'**
  String get learnLessonNotPassed;

  /// Receive drill summary: verdict after a review session
  ///
  /// In en, this message translates to:
  /// **'Review recorded'**
  String get learnReviewRecorded;

  /// Receive drill summary: heading over characters copied poorly
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get learnWeakChars;

  /// Receive drill summary: heading over characters mistaken for others
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get learnConfusions;

  /// Receive drill: warning when sound, flash and haptics are all disabled
  ///
  /// In en, this message translates to:
  /// **'Sound, flash and haptics are all off - the screen will flash instead.'**
  String get learnNoFeedbackWarning;

  /// Send practice screen: app bar title
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get learnSendTitle;

  /// Send practice: label above the text the user should key
  ///
  /// In en, this message translates to:
  /// **'Send this'**
  String get learnSendThis;

  /// Send practice: app bar switch that hides the target so the user keys it from memory
  ///
  /// In en, this message translates to:
  /// **'From memory'**
  String get learnCopyFromMemory;

  /// Send practice: placeholder replacing the hidden target text
  ///
  /// In en, this message translates to:
  /// **'Hidden - key it from memory'**
  String get learnHiddenTarget;

  /// Send practice: label above the text decoded from the user's keying
  ///
  /// In en, this message translates to:
  /// **'Decoded'**
  String get learnDecoded;

  /// Send practice: shown before the user has keyed anything
  ///
  /// In en, this message translates to:
  /// **'Start keying when ready'**
  String get learnWaitingForKey;

  /// Send practice: button that clears the attempt and starts over
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get learnRestart;

  /// Send practice result: button that picks a new target
  ///
  /// In en, this message translates to:
  /// **'Try another'**
  String get learnTryAnother;

  /// Keyer type option: straight key (training settings, send practice)
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get learnKeyerStraight;

  /// Keyer type option: iambic paddles, mode A (technical term, usually kept)
  ///
  /// In en, this message translates to:
  /// **'Iambic A'**
  String get learnKeyerIambicA;

  /// Keyer type option: iambic paddles, mode B (technical term, usually kept)
  ///
  /// In en, this message translates to:
  /// **'Iambic B'**
  String get learnKeyerIambicB;

  /// Send practice: keyboard legend for the straight key
  ///
  /// In en, this message translates to:
  /// **'Space = key'**
  String get learnLegendStraight;

  /// Send practice: keyboard legend for paddles (left/right Ctrl)
  ///
  /// In en, this message translates to:
  /// **'Left Ctrl = dit, Right Ctrl = dah'**
  String get learnLegendPaddles;

  /// Send practice result: shown when the keying had no timing issues ('fist' is ham slang for a sender's keying style)
  ///
  /// In en, this message translates to:
  /// **'Clean fist - nothing to fix.'**
  String get learnSendClean;

  /// Send practice result: heading over the list of timing issues
  ///
  /// In en, this message translates to:
  /// **'Rhythm notes'**
  String get learnSendIssues;

  /// Send practice result: label above what the user's keying decoded to
  ///
  /// In en, this message translates to:
  /// **'Decoded as'**
  String get learnYourSending;

  /// Send practice: label printed on the on-screen straight key (short, upper case in English)
  ///
  /// In en, this message translates to:
  /// **'KEY'**
  String get learnStraightKeyLabel;

  /// Send practice: label on the on-screen dit (short element) paddle
  ///
  /// In en, this message translates to:
  /// **'DIT'**
  String get learnDitLabel;

  /// Send practice: label on the on-screen dah (long element) paddle
  ///
  /// In en, this message translates to:
  /// **'DAH'**
  String get learnDahLabel;

  /// Training settings page: app bar title
  ///
  /// In en, this message translates to:
  /// **'Training settings'**
  String get learnSettingsTitle;

  /// Training settings: title of the character speed slider
  ///
  /// In en, this message translates to:
  /// **'Character speed'**
  String get learnCharacterSpeed;

  /// Training settings: switch for Farnsworth spacing (stretched gaps between characters)
  ///
  /// In en, this message translates to:
  /// **'Farnsworth spacing'**
  String get learnFarnsworth;

  /// Training settings: explanation under the Farnsworth switch
  ///
  /// In en, this message translates to:
  /// **'Characters stay fast; the gaps between them stretch to this speed.'**
  String get learnFarnsworthHelp;

  /// Training settings: title of the Farnsworth effective speed slider
  ///
  /// In en, this message translates to:
  /// **'Effective speed'**
  String get learnEffectiveSpeed;

  /// Training settings: title of the tone pitch slider
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get learnTone;

  /// Training settings: tooltip of the button that plays a sample at the chosen settings
  ///
  /// In en, this message translates to:
  /// **'Play sample'**
  String get learnPlaySample;

  /// Training settings: practice length in characters, not time; labels the per-session character count slider
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get learnSessionLength;

  /// Training settings: section header over the switches that choose how Morse is output during drills (sound, screen flash, vibration) — not right/wrong feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get learnFeedback;

  /// Training settings, output section: switch that plays Morse as a sidetone
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get learnSound;

  /// Training settings, output section: switch that flashes the screen in time with the Morse
  ///
  /// In en, this message translates to:
  /// **'Screen flash'**
  String get learnFlash;

  /// Training settings, output section: switch that vibrates in time with the Morse
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get learnHaptic;

  /// Training settings: title of the keyer type selector
  ///
  /// In en, this message translates to:
  /// **'Keyer'**
  String get learnKeyer;

  /// Training settings: title of the daily goal slider (characters per day)
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get learnDailyGoal;

  /// Reference tab: app bar title
  ///
  /// In en, this message translates to:
  /// **'Morse reference'**
  String get referenceReferenceTitle;

  /// Translator screen title and tooltip of the button that opens it
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get referenceTranslatorTitle;

  /// Reference: button / tooltip that plays an entry or translated text as Morse
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get referencePlay;

  /// Reference: button / tooltip that stops Morse playback
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get referenceStop;

  /// Reference translator: tooltip of the button that clears keyed input
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get referenceClear;

  /// Reference entry dialog: close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get referenceClose;

  /// Reference translator: placeholder shown when the output is empty (a dash)
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get referenceEmptyOutput;

  /// Reference tab: hint inside the search field
  ///
  /// In en, this message translates to:
  /// **'Search characters, prosigns, Q-codes…'**
  String get referenceSearchHint;

  /// Reference tab: tooltip of the button that clears the search
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get referenceClearSearch;

  /// Reference tab: empty state when the search matches nothing
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search.'**
  String get referenceNoResults;

  /// Reference section tab: letters and digits
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get referenceSectionAlphabet;

  /// Reference section tab: punctuation marks
  ///
  /// In en, this message translates to:
  /// **'Punctuation'**
  String get referenceSectionPunctuation;

  /// Reference section tab: procedural signals such as AR, SK
  ///
  /// In en, this message translates to:
  /// **'Prosigns'**
  String get referenceSectionProsigns;

  /// Reference section tab: Q-codes such as QTH, QRZ
  ///
  /// In en, this message translates to:
  /// **'Q-codes'**
  String get referenceSectionQCodes;

  /// Reference section tab: common CW (Morse) abbreviations
  ///
  /// In en, this message translates to:
  /// **'CW abbreviations'**
  String get referenceSectionAbbreviations;

  /// Reference section tab: the Koch teaching order of characters
  ///
  /// In en, this message translates to:
  /// **'Koch order'**
  String get referenceSectionKoch;

  /// Reference alphabet: hint above the grid on tapping and long-pressing
  ///
  /// In en, this message translates to:
  /// **'Tap a card to hear it. Long-press for a mnemonic.'**
  String get referenceAlphabetHint;

  /// Reference, Koch order section: explanation of the Koch character order
  ///
  /// In en, this message translates to:
  /// **'The order the Koch method introduces characters (LCWO sequence). Start with K and M; add one when you copy at 90 %.'**
  String get referenceKochHint;

  /// Reference entry dialog: heading of the memory aid for a character
  ///
  /// In en, this message translates to:
  /// **'Mnemonic'**
  String get referenceMnemonicTitle;

  /// Reference entry dialog: heading of the meaning of a prosign / Q-code / abbreviation
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get referenceMeaningLabel;

  /// Reference playback settings sheet title and tooltip of its button
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get referencePlaybackSettings;

  /// Reference playback settings: character speed slider label
  ///
  /// In en, this message translates to:
  /// **'Character speed'**
  String get referenceCharacterSpeed;

  /// Reference playback settings: switch for Farnsworth spacing
  ///
  /// In en, this message translates to:
  /// **'Farnsworth spacing'**
  String get referenceFarnsworth;

  /// Reference playback settings: explanation under the Farnsworth switch
  ///
  /// In en, this message translates to:
  /// **'Characters stay at full speed; gaps stretch to the effective speed.'**
  String get referenceFarnsworthHelp;

  /// Reference playback settings: effective speed slider label
  ///
  /// In en, this message translates to:
  /// **'Effective speed'**
  String get referenceEffectiveSpeed;

  /// Reference playback settings: tone pitch slider label
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get referenceTone;

  /// Translator: mode segment that converts text to Morse
  ///
  /// In en, this message translates to:
  /// **'Text → Morse'**
  String get referenceModeTextToMorse;

  /// Translator: mode segment that converts Morse to text
  ///
  /// In en, this message translates to:
  /// **'Morse → Text'**
  String get referenceModeMorseToText;

  /// Translator: mode segment where the user keys Morse by hand
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get referenceModeKey;

  /// Translator, Text to Morse: label of the text input
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get referenceTextInputLabel;

  /// Translator, Text to Morse: hint inside the text input
  ///
  /// In en, this message translates to:
  /// **'Type text to encode…'**
  String get referenceTextInputHint;

  /// Translator, Text to Morse: label above the dot-dash output
  ///
  /// In en, this message translates to:
  /// **'Morse'**
  String get referencePatternOutputLabel;

  /// Translator, Text to Morse: tooltip of the button that copies the dot-dash pattern
  ///
  /// In en, this message translates to:
  /// **'Copy pattern'**
  String get referenceCopyPattern;

  /// Translator: snackbar after the pattern was copied
  ///
  /// In en, this message translates to:
  /// **'Pattern copied'**
  String get referencePatternCopied;

  /// Translator, Morse to Text: label of the dot-dash input
  ///
  /// In en, this message translates to:
  /// **'Morse'**
  String get referencePatternInputLabel;

  /// Translator, Morse to Text: hint explaining the input syntax (. and -, space, /); keep the symbols
  ///
  /// In en, this message translates to:
  /// **'Type . and -, a space between letters, / between words'**
  String get referencePatternInputHint;

  /// Translator, Morse to Text: label above the decoded text
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get referenceTextOutputLabel;

  /// Translator, Morse to Text: tooltip of the button that copies the decoded text
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get referenceCopyText;

  /// Translator: snackbar after the decoded text was copied
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get referenceTextCopied;

  /// Translator, Morse to Text: note on how undecodable patterns are shown; keep '<pattern>' as an example
  ///
  /// In en, this message translates to:
  /// **'Patterns with no character are shown as <pattern>.'**
  String get referenceUnknownPatternHelp;

  /// Translator keypad: tooltip of the dit (short element) key
  ///
  /// In en, this message translates to:
  /// **'Dit'**
  String get referenceKeypadDit;

  /// Translator keypad: tooltip of the dah (long element) key
  ///
  /// In en, this message translates to:
  /// **'Dah'**
  String get referenceKeypadDah;

  /// Translator keypad: tooltip of the key inserting a gap between letters
  ///
  /// In en, this message translates to:
  /// **'Letter gap'**
  String get referenceKeypadCharGap;

  /// Translator keypad: tooltip of the key inserting a gap between words
  ///
  /// In en, this message translates to:
  /// **'Word gap'**
  String get referenceKeypadWordGap;

  /// Translator keypad: tooltip of the backspace key
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get referenceKeypadBackspace;

  /// Translator, Key mode: hint on how to key (touch or Space bar)
  ///
  /// In en, this message translates to:
  /// **'Press and hold the key to send. On a keyboard, hold Space.'**
  String get referenceKeyHint;

  /// Translator, Key mode: label on the on-screen key (short, upper case in English)
  ///
  /// In en, this message translates to:
  /// **'KEY'**
  String get referenceKeyLabel;

  /// Translator, Key mode: label above the decoded text
  ///
  /// In en, this message translates to:
  /// **'Decoded'**
  String get referenceKeyDecodedLabel;

  /// Translator, Key mode: label above the character currently being keyed
  ///
  /// In en, this message translates to:
  /// **'Keying'**
  String get referenceKeyPendingLabel;

  /// Statistics screen: app bar title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// Statistics screen: shown while statistics load
  ///
  /// In en, this message translates to:
  /// **'Loading your statistics...'**
  String get statsLoading;

  /// Statistics screen: error when progress could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Your progress could not be loaded. Pull down or reopen to retry.'**
  String get statsLoadFailed;

  /// Statistics screen: button that retries loading
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get statsRetry;

  /// Statistics: empty state title before any session
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get statsEmptyTitle;

  /// Statistics: empty state explanation of what the page will show
  ///
  /// In en, this message translates to:
  /// **'Finish your first receive or send session and this page fills up with your accuracy trend, per-character strengths and a practice calendar.'**
  String get statsEmptyBody;

  /// Statistics: empty state call to action; the quoted button name must match learnContinueLesson
  ///
  /// In en, this message translates to:
  /// **'Head to Learn and press \"Continue lesson\" to start.'**
  String get statsEmptyCallToAction;

  /// Statistics: title of the overview tiles section
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statsOverviewTitle;

  /// Statistics overview: label of the Koch lesson tile
  ///
  /// In en, this message translates to:
  /// **'Koch lesson'**
  String get statsTileLesson;

  /// Statistics overview / summary card: label of the accuracy tile
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsTileAccuracy;

  /// Statistics: placeholder shown for a value that has no data yet
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get statsNoData;

  /// Statistics overview: label of the practice totals tile
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get statsTilePractice;

  /// Statistics overview / summary card: label of the streak tile
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsTileStreak;

  /// Statistics overview: label of the daily goal tile
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get statsTileDailyGoal;

  /// Statistics, daily goal tile: detail line when today's goal is reached
  ///
  /// In en, this message translates to:
  /// **'Reached today'**
  String get statsGoalMet;

  /// Statistics summary card: title (the card is not placed on any screen at the moment)
  ///
  /// In en, this message translates to:
  /// **'Your stats'**
  String get statsSummaryTitle;

  /// Statistics summary card: link that opens the statistics screen (the card is not placed on any screen at the moment)
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get statsSummaryOpen;

  /// Statistics: title of the accuracy trend chart
  ///
  /// In en, this message translates to:
  /// **'Accuracy trend'**
  String get statsTrendTitle;

  /// Statistics, accuracy trend chart: hint below the chart
  ///
  /// In en, this message translates to:
  /// **'Tap a point to inspect a session.'**
  String get statsTrendHint;

  /// Statistics, accuracy trend chart: legend / tooltip for receive (copy) sessions
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get statsSeriesReceive;

  /// Statistics, accuracy trend chart: legend / tooltip for send (keying) sessions
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get statsSeriesSend;

  /// Statistics, accuracy trend chart: x-axis label
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get statsAxisSessions;

  /// Statistics: title of the per-character grid
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get statsCharsTitle;

  /// Statistics, character grid: subtitle
  ///
  /// In en, this message translates to:
  /// **'Koch order. Tap a character for detail.'**
  String get statsCharsSubtitle;

  /// Statistics, character grid / detail: a character never practised
  ///
  /// In en, this message translates to:
  /// **'Not practised yet'**
  String get statsCharsNotStarted;

  /// Statistics, character detail: character outside the Koch course
  ///
  /// In en, this message translates to:
  /// **'Not part of the Koch course'**
  String get statsNotInCourse;

  /// Statistics, character detail: heading of the spaced-repetition section
  ///
  /// In en, this message translates to:
  /// **'Spaced repetition'**
  String get statsSrsTitle;

  /// Statistics, character detail: character not yet scheduled for review
  ///
  /// In en, this message translates to:
  /// **'Not scheduled yet'**
  String get statsSrsNotTracked;

  /// Statistics, character detail: character due for review now
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statsSrsDueNow;

  /// Statistics, character detail: heading over the characters it is confused with
  ///
  /// In en, this message translates to:
  /// **'Most often confused with'**
  String get statsConfusionsTitle;

  /// Statistics, character detail: no confusions recorded
  ///
  /// In en, this message translates to:
  /// **'No confusions recorded'**
  String get statsConfusionsNone;

  /// Statistics: shown in place of the answered character when nothing was typed (lower case)
  ///
  /// In en, this message translates to:
  /// **'missed'**
  String get statsConfusionMissed;

  /// Statistics, character grid: title of the accuracy colour legend
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsBucketLegendTitle;

  /// Statistics, character grid legend: no data bucket
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get statsBucketNone;

  /// Statistics, character grid legend: accuracy under 70%
  ///
  /// In en, this message translates to:
  /// **'< 70%'**
  String get statsBucketWeak;

  /// Statistics, character grid legend: accuracy 70 to 89%
  ///
  /// In en, this message translates to:
  /// **'70-89%'**
  String get statsBucketFair;

  /// Statistics, character grid legend: accuracy 90 to 97%
  ///
  /// In en, this message translates to:
  /// **'90-97%'**
  String get statsBucketGood;

  /// Statistics, character grid legend: accuracy 98% or more
  ///
  /// In en, this message translates to:
  /// **'>= 98%'**
  String get statsBucketStrong;

  /// Statistics: title of the confusion heatmap
  ///
  /// In en, this message translates to:
  /// **'Confusions'**
  String get statsHeatmapTitle;

  /// Statistics, confusion heatmap: how to read rows and columns
  ///
  /// In en, this message translates to:
  /// **'Rows are the sent character, columns what you answered. Darker means more often.'**
  String get statsHeatmapSubtitle;

  /// Statistics, confusion heatmap: empty state
  ///
  /// In en, this message translates to:
  /// **'No confusions yet. Wrong answers will show up here.'**
  String get statsHeatmapEmpty;

  /// Statistics, confusion heatmap: legend end for rare confusions
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get statsHeatmapLegendLow;

  /// Statistics, confusion heatmap: legend end for frequent confusions
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get statsHeatmapLegendHigh;

  /// Statistics, confusion heatmap: row axis name (the character that was sent)
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statsHeatmapAxisTarget;

  /// Statistics, confusion heatmap: column axis name (what the user answered)
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get statsHeatmapAxisAnswered;

  /// Statistics: title of the practice calendar
  ///
  /// In en, this message translates to:
  /// **'Practice calendar'**
  String get statsCalendarTitle;

  /// Statistics, practice calendar: the period shown
  ///
  /// In en, this message translates to:
  /// **'Last 12 weeks'**
  String get statsCalendarSubtitle;

  /// Statistics, practice calendar: legend end for little practice
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get statsCalendarLegendLess;

  /// Statistics, practice calendar: legend end for much practice
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get statsCalendarLegendMore;

  /// Statistics, practice calendar: explanation of how a streak is counted
  ///
  /// In en, this message translates to:
  /// **'A streak counts consecutive calendar days with at least one session. Skipping a whole day resets it; practising twice in a day counts once.'**
  String get statsStreakExplanation;

  /// Learn home: tooltip of the button that opens the statistics screen
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get learnStatistics;

  /// Listen (microphone decoder) screen title and tooltip of the Reference button that opens it
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenTitle;

  /// Listen screen: button that starts decoding from the microphone
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get listenStart;

  /// Listen screen: button that stops decoding
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get listenStop;

  /// Listen screen: status while the microphone starts
  ///
  /// In en, this message translates to:
  /// **'Starting microphone...'**
  String get listenStarting;

  /// Listen screen: tooltip of the button that clears the decoded text
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get listenClear;

  /// Listen screen: tooltip of the button that copies the decoded text
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get listenCopy;

  /// Listen screen: snackbar after the decoded text was copied
  ///
  /// In en, this message translates to:
  /// **'Decoded text copied'**
  String get listenCopied;

  /// Listen settings sheet title and tooltip of its button
  ///
  /// In en, this message translates to:
  /// **'Listen settings'**
  String get listenSettings;

  /// Listen screen: label above the decoded text
  ///
  /// In en, this message translates to:
  /// **'Decoded'**
  String get listenDecoded;

  /// Listen screen: placeholder while listening but nothing decoded yet
  ///
  /// In en, this message translates to:
  /// **'Point the microphone at a Morse tone. Decoded text appears here.'**
  String get listenEmptyHint;

  /// Listen screen: placeholder before listening starts; 'Start' refers to listenStart
  ///
  /// In en, this message translates to:
  /// **'Tap Start to listen for a Morse tone.'**
  String get listenIdleHint;

  /// Listen screen: label of the character currently being received
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get listenPending;

  /// Listen screen: label of the estimated sending speed
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get listenSpeed;

  /// Listen screen: shown instead of a speed before one can be estimated; same form as learnWpmUnknown
  ///
  /// In en, this message translates to:
  /// **'-- WPM'**
  String get listenSpeedUnknown;

  /// Listen screen: label of the input signal level meter
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get listenLevel;

  /// Listen screen: label of the tone-detected indicator
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get listenToneOn;

  /// Listen screen: title of the tone frequency control
  ///
  /// In en, this message translates to:
  /// **'Tone frequency'**
  String get listenTone;

  /// Listen screen: auto-tune has locked onto a tone
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get listenToneLocked;

  /// Listen screen: auto-tune is still searching for a tone
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get listenToneSearching;

  /// Listen screen: the frequency is tuned by hand
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get listenToneManual;

  /// Listen settings: switch for automatic tone tracking
  ///
  /// In en, this message translates to:
  /// **'Auto-tune'**
  String get listenAutoTune;

  /// Listen settings: explanation under the auto-tune switch
  ///
  /// In en, this message translates to:
  /// **'Follow the strongest tone between 400 and 1000 Hz. Drag the slider to tune by hand instead.'**
  String get listenAutoTuneHelp;

  /// Listen screen: button that returns to automatic tuning (short)
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get listenRetune;

  /// Listen settings: title of the analysis block size setting
  ///
  /// In en, this message translates to:
  /// **'Analysis block'**
  String get listenBlockSize;

  /// Listen settings: explanation of the analysis block size
  ///
  /// In en, this message translates to:
  /// **'Smaller blocks place mark edges more precisely but pick up more noise. 256 samples (5.3 ms) suits 5-40 WPM.'**
  String get listenBlockSizeHelp;

  /// Listen settings: title of the shortest element (debounce) setting
  ///
  /// In en, this message translates to:
  /// **'Shortest element'**
  String get listenMinElement;

  /// Listen settings: explanation of the shortest element setting
  ///
  /// In en, this message translates to:
  /// **'Tones and gaps shorter than this are ignored as clicks and dropouts.'**
  String get listenMinElementHelp;

  /// Listen banner when microphone permission was denied
  ///
  /// In en, this message translates to:
  /// **'Microphone access was denied. Allow it in the system settings, then try again.'**
  String get listenPermissionDenied;

  /// Listen banner: button that retries starting the microphone
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get listenPermissionRetry;

  /// Listen banner when the microphone could not be started
  ///
  /// In en, this message translates to:
  /// **'Could not start the microphone.'**
  String get listenStartFailed;

  /// Listen banner when no microphone input device exists
  ///
  /// In en, this message translates to:
  /// **'No microphone was found. Connect one and try again.'**
  String get listenNoInput;

  /// Listen banner shown when the microphone stream fails after capture has started.
  ///
  /// In en, this message translates to:
  /// **'The microphone stopped unexpectedly. Try again.'**
  String get listenStreamFailed;

  /// Listen screen: estimated sending speed in words per minute; wpm is pre-rounded
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM'**
  String listenWpmValue(int wpm);

  /// Listen screen / settings: detected or manual tone frequency in hertz; hz is pre-rounded
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String listenHzValue(int hz);

  /// Listen settings: analysis block length in samples and milliseconds; ms is pre-formatted with one decimal
  ///
  /// In en, this message translates to:
  /// **'{samples} samples ({ms} ms)'**
  String listenBlockSamples(int samples, String ms);

  /// Listen settings: shortest-element debounce in milliseconds
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String listenMsValue(int ms);

  /// Listen screen: status when listening stopped because the app went to the background
  ///
  /// In en, this message translates to:
  /// **'Listening stopped while the app was in the background.'**
  String get listenStoppedInBackground;

  /// Send practice tips: shown instead of a speed when it could not be measured; same form as listenSpeedUnknown
  ///
  /// In en, this message translates to:
  /// **'-- WPM'**
  String get learnWpmUnknown;

  /// Send practice tip title: dits were keyed too long
  ///
  /// In en, this message translates to:
  /// **'Dits too long'**
  String get learnTipDitTooLongTitle;

  /// Send practice tip title: dahs were keyed too short
  ///
  /// In en, this message translates to:
  /// **'Dahs too short'**
  String get learnTipDahTooShortTitle;

  /// Send practice tip title: gaps inside a character were too long
  ///
  /// In en, this message translates to:
  /// **'Elements spread out'**
  String get learnTipIntraGapTooLongTitle;

  /// Send practice tip title: gaps between characters were too short
  ///
  /// In en, this message translates to:
  /// **'Characters crowded'**
  String get learnTipCharGapTooShortTitle;

  /// Send practice tip title: gaps between words were too short
  ///
  /// In en, this message translates to:
  /// **'Words crowded'**
  String get learnTipWordGapTooShortTitle;

  /// Send practice tip title: keying speed varied too much
  ///
  /// In en, this message translates to:
  /// **'Speed unsteady'**
  String get learnTipSpeedUnsteadyTitle;

  /// Send practice tip: severity tag for a minor issue (lower case, shown next to the tip title)
  ///
  /// In en, this message translates to:
  /// **'minor'**
  String get learnSeverityMinor;

  /// Send practice tip: severity tag for a noticeable issue
  ///
  /// In en, this message translates to:
  /// **'noticeable'**
  String get learnSeverityModerate;

  /// Send practice tip: severity tag for a major issue
  ///
  /// In en, this message translates to:
  /// **'major'**
  String get learnSeveritySevere;

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

  /// Listen screen: value of the tone indicator when a tone is present (screen-reader)
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get listenStateOn;

  /// Listen screen: value of the tone indicator when no tone is present (screen-reader)
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get listenStateOff;

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

  /// Appearance page title and tooltip of the Learn home button that opens it
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Appearance page: heading over the interface style choices
  ///
  /// In en, this message translates to:
  /// **'Interface style'**
  String get appearanceStyles;

  /// Appearance page: instruction under the style heading
  ///
  /// In en, this message translates to:
  /// **'Choose a style, preview, then apply'**
  String get appearanceChoose;

  /// Appearance page: heading over the light / dark choice
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get appearanceMode;

  /// Appearance page: heading over the live preview
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get appearancePreview;

  /// Appearance page: button that saves the chosen style
  ///
  /// In en, this message translates to:
  /// **'Apply style'**
  String get appearanceApply;

  /// Appearance page: button that resets style and brightness to defaults
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get appearanceRestore;

  /// Appearance page: snackbar after saving
  ///
  /// In en, this message translates to:
  /// **'Appearance saved'**
  String get appearanceApplied;

  /// Appearance page: snackbar when saving failed
  ///
  /// In en, this message translates to:
  /// **'Could not save appearance. Try again.'**
  String get appearanceSaveFailed;

  /// Appearance style name (brass-instrument themed); translate as a name
  ///
  /// In en, this message translates to:
  /// **'Classic Brass'**
  String get appearanceClassic;

  /// Appearance style name (calm modern theme); translate as a name
  ///
  /// In en, this message translates to:
  /// **'Modern Calm'**
  String get appearanceModern;

  /// Appearance style name (dark radio-room theme); translate as a name
  ///
  /// In en, this message translates to:
  /// **'Night Radio'**
  String get appearanceRadio;

  /// Appearance style name (printed handbook theme); translate as a name
  ///
  /// In en, this message translates to:
  /// **'Paper Handbook'**
  String get appearancePaper;

  /// Appearance style name (bright cartoon theme); translate as a name
  ///
  /// In en, this message translates to:
  /// **'Fresh Cartoon'**
  String get appearanceCartoon;

  /// Appearance page: light brightness option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// Appearance page: dark brightness option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// Learn home, Koch lesson card: button that expands the learned-character list to all {count} characters
  ///
  /// In en, this message translates to:
  /// **'Show all {count} characters'**
  String learnShowAllChars(int count);

  /// Learn home, Koch lesson card: button that collapses the expanded learned-character list
  ///
  /// In en, this message translates to:
  /// **'Show fewer characters'**
  String get learnShowFewerChars;

  /// Title of the dialog shown when backing out of a drill or send practice mid-session
  ///
  /// In en, this message translates to:
  /// **'Leave this session?'**
  String get learnLeaveDrillTitle;

  /// Body of the leave-drill confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'The rounds you have done in this session will not be saved.'**
  String get learnLeaveDrillBody;

  /// Confirm button of the leave-drill dialog
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get learnLeaveDrillConfirm;

  /// Receive drill: shown after the learner replayed a round; replays make the session assisted
  ///
  /// In en, this message translates to:
  /// **'Replayed: this session counts as practice but won\'t unlock a lesson or update reviews.'**
  String get learnReplayAssistedNote;

  /// Learn home: title of the daily plan card
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get learnPlanTitle;

  /// Daily plan card: estimated minutes and completed steps
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min · {done} of {total} steps'**
  String learnPlanSummary(int minutes, int done, int total);

  /// Daily plan card: label of the plan-length selector
  ///
  /// In en, this message translates to:
  /// **'Plan length'**
  String get learnPlanBudget;

  /// Daily plan card: one plan-length choice in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String learnPlanBudgetMinutes(int minutes);

  /// Daily plan card: start the first step
  ///
  /// In en, this message translates to:
  /// **'Start plan'**
  String get learnPlanStart;

  /// Daily plan card: continue with the next step
  ///
  /// In en, this message translates to:
  /// **'Continue plan'**
  String get learnPlanContinue;

  /// Daily plan step title: spaced review
  ///
  /// In en, this message translates to:
  /// **'Review due symbols'**
  String get learnPlanStepReview;

  /// Daily plan step title: focused drill on weak symbols
  ///
  /// In en, this message translates to:
  /// **'Focused practice'**
  String get learnPlanStepFocus;

  /// Daily plan step title: Koch course copying of a lesson
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson}'**
  String learnPlanStepCourse(int lesson);

  /// Daily plan step title: short sending practice
  ///
  /// In en, this message translates to:
  /// **'Sending practice'**
  String get learnPlanStepSend;

  /// Daily plan reason: symbols due for spaced review
  ///
  /// In en, this message translates to:
  /// **'Due for review: {symbols}'**
  String learnPlanReasonDueReview(String symbols);

  /// Daily plan reason: symbols often confused with each other
  ///
  /// In en, this message translates to:
  /// **'Often mixed up: {symbols}'**
  String learnPlanReasonConfusions(String symbols);

  /// Daily plan reason: symbols copied below 90 percent
  ///
  /// In en, this message translates to:
  /// **'Below 90%: {symbols}'**
  String learnPlanReasonWeak(String symbols);

  /// Daily plan reason: course step long enough to unlock
  ///
  /// In en, this message translates to:
  /// **'{count} symbols: can unlock the next lesson'**
  String learnPlanReasonChallenge(int count);

  /// Daily plan reason: course step lengthened beyond its time share so it can unlock
  ///
  /// In en, this message translates to:
  /// **'Lengthened to {count} symbols so it can unlock the next lesson'**
  String learnPlanReasonExtended(int count);

  /// Daily plan reason: course step too short to unlock
  ///
  /// In en, this message translates to:
  /// **'Short session: consolidates this lesson, cannot unlock the next'**
  String get learnPlanReasonConsolidate;

  /// Daily plan reason: the course moved on after the plan was made
  ///
  /// In en, this message translates to:
  /// **'Your course moved on: practises lesson {lesson} without unlocking'**
  String learnPlanReasonOutdated(int lesson);

  /// Daily plan reason: number of short sending targets
  ///
  /// In en, this message translates to:
  /// **'{count} short targets to key'**
  String learnPlanReasonSend(int count);

  /// Daily plan step: completed with strict accuracy
  ///
  /// In en, this message translates to:
  /// **'Done · {percent}%'**
  String learnPlanStepDonePercent(int percent);

  /// Daily plan step: completed (no accuracy, e.g. sending)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get learnPlanStepDone;

  /// Daily plan send step: keyed targets so far
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} keyed'**
  String learnPlanSendProgress(int done, int total);

  /// Daily plan card: lesson or speed changed after planning
  ///
  /// In en, this message translates to:
  /// **'Your lesson or speed changed. Update the steps you haven\'t started?'**
  String get learnPlanStale;

  /// Daily plan card: regenerate steps that have not started
  ///
  /// In en, this message translates to:
  /// **'Update steps'**
  String get learnPlanUpdate;

  /// Daily plan card: every step done today
  ///
  /// In en, this message translates to:
  /// **'Plan complete for today'**
  String get learnPlanComplete;

  /// Daily plan card: symbols that need work after today's plan
  ///
  /// In en, this message translates to:
  /// **'Needs work: {symbols}'**
  String learnPlanNeedsWork(String symbols);

  /// Daily plan card: no weak symbols after today's plan
  ///
  /// In en, this message translates to:
  /// **'No weak symbols today.'**
  String get learnPlanAllGood;

  /// Daily plan card: after completing the plan
  ///
  /// In en, this message translates to:
  /// **'A new plan arrives tomorrow. Free practice is always open.'**
  String get learnPlanTomorrow;

  /// Daily plan card: an earlier day's unfinished plan (inspect only)
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s plan stopped at {done} of {total} steps; it no longer counts for today.'**
  String learnPlanEarlier(int done, int total);

  /// Speed advice: raise the effective (Farnsworth) speed
  ///
  /// In en, this message translates to:
  /// **'Ready for {wpm} WPM effective speed'**
  String learnSpeedAdviceRaise(int wpm);

  /// Speed advice: raise character and effective speed together
  ///
  /// In en, this message translates to:
  /// **'Ready for {wpm} WPM'**
  String learnSpeedAdviceRaiseBoth(int wpm);

  /// Speed advice: suggest lowering the effective speed
  ///
  /// In en, this message translates to:
  /// **'Copying is hard at this speed. Try {wpm} WPM effective, or a focused drill.'**
  String learnSpeedAdviceLower(int wpm);

  /// Speed advice: evidence behind the recommendation
  ///
  /// In en, this message translates to:
  /// **'Based on your last {count} unassisted sessions ({percent}%). Nothing changes until you apply it.'**
  String learnSpeedAdviceBody(int count, int percent);

  /// Speed advice: apply the proposed speed
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get learnSpeedAdviceApply;

  /// Speed advice: dismiss for this evidence batch
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get learnSpeedAdviceDismiss;

  /// Daily plan card: why there is no speed advice yet
  ///
  /// In en, this message translates to:
  /// **'Speed advice needs 3 unassisted sessions of 50+ symbols at your current speed.'**
  String get learnSpeedAdviceInsufficient;

  /// Learn home: entry to the interactive QSO simulator
  ///
  /// In en, this message translates to:
  /// **'QSO simulator'**
  String get learnQsoAction;

  /// Learn home: QSO simulator is locked until a lesson
  ///
  /// In en, this message translates to:
  /// **'From lesson {lesson}'**
  String learnQsoLocked(int lesson);

  /// QSO simulator: screen title
  ///
  /// In en, this message translates to:
  /// **'QSO simulator'**
  String get learnQsoTitle;

  /// QSO setup: scenario where the remote calls CQ
  ///
  /// In en, this message translates to:
  /// **'Answer a CQ'**
  String get learnQsoRespond;

  /// QSO setup: description of the answer-CQ scenario
  ///
  /// In en, this message translates to:
  /// **'A station calls CQ. Answer it and exchange reports.'**
  String get learnQsoRespondHint;

  /// QSO setup: scenario where the learner calls CQ
  ///
  /// In en, this message translates to:
  /// **'Call CQ'**
  String get learnQsoCall;

  /// QSO setup: description of the call-CQ scenario
  ///
  /// In en, this message translates to:
  /// **'You call CQ and a station answers.'**
  String get learnQsoCallHint;

  /// QSO setup: learner's callsign field
  ///
  /// In en, this message translates to:
  /// **'Your callsign'**
  String get learnQsoYourCall;

  /// QSO setup: learner's name field (one word)
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get learnQsoYourName;

  /// QSO setup: learner's location field (one word)
  ///
  /// In en, this message translates to:
  /// **'Your QTH'**
  String get learnQsoYourQth;

  /// QSO setup: callsign validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a callsign such as BD1XYZ'**
  String get learnQsoInvalidCall;

  /// QSO setup: name/QTH validation error
  ///
  /// In en, this message translates to:
  /// **'One word, letters A–Z only'**
  String get learnQsoInvalidWord;

  /// QSO setup: privacy note
  ///
  /// In en, this message translates to:
  /// **'Runs entirely on this device. Nothing is sent to anyone.'**
  String get learnQsoOffline;

  /// QSO setup: start button
  ///
  /// In en, this message translates to:
  /// **'Start QSO'**
  String get learnQsoStart;

  /// QSO setup: resume an unfinished simulated QSO
  ///
  /// In en, this message translates to:
  /// **'Resume the unfinished QSO'**
  String get learnQsoResume;

  /// QSO stage: call CQ
  ///
  /// In en, this message translates to:
  /// **'Call CQ with your callsign'**
  String get learnQsoStageCallCq;

  /// QSO stage: answer with both callsigns
  ///
  /// In en, this message translates to:
  /// **'Answer: their call, DE, your call'**
  String get learnQsoStageCallConfirm;

  /// QSO stage: send report, name and QTH
  ///
  /// In en, this message translates to:
  /// **'Send report, name and QTH'**
  String get learnQsoStageExchange;

  /// QSO stage: acknowledge the remote's information
  ///
  /// In en, this message translates to:
  /// **'Confirm their information'**
  String get learnQsoStageConfirmInfo;

  /// QSO stage: close the contact
  ///
  /// In en, this message translates to:
  /// **'Close with 73 and <SK>'**
  String get learnQsoStageClosing;

  /// QSO stage/summary: contact finished
  ///
  /// In en, this message translates to:
  /// **'QSO complete'**
  String get learnQsoStageDone;

  /// QSO screen: current remote playback effective speed
  ///
  /// In en, this message translates to:
  /// **'Remote sends at {wpm} WPM effective'**
  String learnQsoSpeed(int wpm);

  /// QSO log: caption of a remote transmission
  ///
  /// In en, this message translates to:
  /// **'{call} sends'**
  String learnQsoRemote(String call);

  /// QSO log: placeholder while the remote text is hidden
  ///
  /// In en, this message translates to:
  /// **'Copy by ear — the text is hidden.'**
  String get learnQsoRemoteHidden;

  /// QSO log: reveal a remote transmission (counts as a hint)
  ///
  /// In en, this message translates to:
  /// **'Show text'**
  String get learnQsoShowText;

  /// QSO log: play a remote transmission again
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get learnQsoListen;

  /// QSO log: semantics for an accepted transmission
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get learnQsoAccepted;

  /// QSO log: semantics for a rejected transmission
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get learnQsoRejected;

  /// QSO screen: remote is transmitting; keying is paused
  ///
  /// In en, this message translates to:
  /// **'The other station is sending…'**
  String get learnQsoRemoteSending;

  /// QSO screen: learner's turn to key
  ///
  /// In en, this message translates to:
  /// **'Your turn: key your reply, then Send.'**
  String get learnQsoYourTurn;

  /// QSO screen: label of the decoded own transmission
  ///
  /// In en, this message translates to:
  /// **'Your transmission'**
  String get learnQsoDecoded;

  /// QSO screen: nothing keyed yet
  ///
  /// In en, this message translates to:
  /// **'Nothing keyed yet'**
  String get learnQsoNothingKeyed;

  /// QSO screen: send PSE AGN (ask the remote to repeat)
  ///
  /// In en, this message translates to:
  /// **'Ask to repeat (AGN)'**
  String get learnQsoPlayAgain;

  /// QSO screen: send QRS (ask the remote to slow down)
  ///
  /// In en, this message translates to:
  /// **'Ask to slow down (QRS)'**
  String get learnQsoSlower;

  /// QSO screen: show an example for the current stage
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get learnQsoHint;

  /// QSO screen: hint example (protocol text, not translated)
  ///
  /// In en, this message translates to:
  /// **'Example: {example}'**
  String learnQsoHintLabel(String example);

  /// QSO screen: stop the remote's playback
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get learnQsoPause;

  /// QSO screen: submit the keyed transmission
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get learnQsoSend;

  /// QSO screen: discard the keyed transmission
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get learnQsoClear;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Nothing was keyed.'**
  String get learnQsoIssueEmpty;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Start with CQ.'**
  String get learnQsoIssueMissingCq;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Put DE between the callsigns.'**
  String get learnQsoIssueMissingDe;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Your own callsign is missing or wrong.'**
  String get learnQsoIssueWrongLocalCall;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'The other station\'s callsign is wrong.'**
  String get learnQsoIssueWrongRemoteCall;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Callsigns are reversed: theirs first, then DE and yours.'**
  String get learnQsoIssueReversedCalls;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'End with K or KN.'**
  String get learnQsoIssueMissingEnding;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Give a report, e.g. UR RST 599.'**
  String get learnQsoIssueMissingRst;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'That RST is out of range (R 1–5, S 1–9, T 1–9).'**
  String get learnQsoIssueInvalidRst;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Send NAME and your name.'**
  String get learnQsoIssueMissingName;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'That is not your name for this QSO.'**
  String get learnQsoIssueWrongName;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Send QTH and your location.'**
  String get learnQsoIssueMissingQth;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'That is not your QTH for this QSO.'**
  String get learnQsoIssueWrongQth;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Acknowledge with R or QSL.'**
  String get learnQsoIssueMissingAck;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Confirm the other operator\'s name.'**
  String get learnQsoIssueWrongRemoteName;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'Include 73.'**
  String get learnQsoIssueMissing73;

  /// QSO feedback
  ///
  /// In en, this message translates to:
  /// **'End the contact with <SK>.'**
  String get learnQsoIssueMissingSk;

  /// QSO summary: stages accepted on the first try
  ///
  /// In en, this message translates to:
  /// **'Right first time: {count} of {total} steps'**
  String learnQsoSummaryFields(int count, int total);

  /// QSO summary: number of repeat requests
  ///
  /// In en, this message translates to:
  /// **'Repeats: {count}'**
  String learnQsoSummaryRepeats(int count);

  /// QSO summary: hints and revealed texts
  ///
  /// In en, this message translates to:
  /// **'Hints: {count}'**
  String learnQsoSummaryHints(int count);

  /// QSO summary: average measured sending speed
  ///
  /// In en, this message translates to:
  /// **'Your sending: about {wpm} WPM'**
  String learnQsoSummaryRhythm(int wpm);

  /// QSO summary: how the result is counted
  ///
  /// In en, this message translates to:
  /// **'QSO results are kept apart from copying accuracy and never unlock lessons.'**
  String get learnQsoSummaryNote;

  /// Send practice tip title: dahs were held far too long
  ///
  /// In en, this message translates to:
  /// **'Dahs too long'**
  String get learnTipDahTooLongTitle;

  /// Send tip for SendIssueKind.dahTooLong; ratio via learnRatioTimes
  ///
  /// In en, this message translates to:
  /// **'Your dahs run long (about {ratio} of a dit; aim for 3). Release as soon as three dits have passed.'**
  String learnTipDahTooLong(String ratio);

  /// Measurement line under the dahTooLong tip
  ///
  /// In en, this message translates to:
  /// **'{offending} of {total} dahs too long (avg {ratio} dit)'**
  String learnIssueDetailDahTooLong(int offending, int total, String ratio);

  /// Send result: rhythm timeline section title
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get learnRhythmTitle;

  /// Rhythm timeline lane: measured keying
  ///
  /// In en, this message translates to:
  /// **'My rhythm'**
  String get learnRhythmMine;

  /// Rhythm timeline lane: standard timing at the target speed
  ///
  /// In en, this message translates to:
  /// **'Standard rhythm (target speed)'**
  String get learnRhythmStandard;

  /// Rhythm timeline: how problems are judged
  ///
  /// In en, this message translates to:
  /// **'Problems are judged against your own dit ({ms} ms), so an even but slow fist is fine. The standard lane is the target speed.'**
  String learnRhythmNormalizedNote(int ms);

  /// Rhythm timeline: marks could not be matched symbol by symbol
  ///
  /// In en, this message translates to:
  /// **'Your marks couldn\'t be matched to single symbols, so problems aren\'t pinned to letters. Practise the whole target instead.'**
  String get learnRhythmNotLocated;

  /// Rhythm timeline: replay the measured timing
  ///
  /// In en, this message translates to:
  /// **'Play mine'**
  String get learnRhythmPlayMine;

  /// Rhythm timeline / send screen: play the standard timing
  ///
  /// In en, this message translates to:
  /// **'Play standard'**
  String get learnRhythmPlayStandard;

  /// Rhythm symbol card: start targeted practice
  ///
  /// In en, this message translates to:
  /// **'Practise this ({count} tries)'**
  String learnRhythmPracticePart(int count);

  /// Rhythm timeline: practise the whole target
  ///
  /// In en, this message translates to:
  /// **'Practise the whole target'**
  String get learnRhythmPracticeWhole;

  /// Rhythm symbol card: no problem found
  ///
  /// In en, this message translates to:
  /// **'Looks good'**
  String get learnRhythmSymbolOk;

  /// Rhythm timeline: zoom in
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get learnRhythmZoomIn;

  /// Rhythm timeline: zoom out
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get learnRhythmZoomOut;

  /// Recording workbench: screen title
  ///
  /// In en, this message translates to:
  /// **'Recording workbench'**
  String get workbenchTitle;

  /// Listen screen: open the recorded-audio workbench
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get workbenchOpen;

  /// Recording workbench: pick a WAV file
  ///
  /// In en, this message translates to:
  /// **'Import recording'**
  String get workbenchImport;

  /// Recording workbench: empty state
  ///
  /// In en, this message translates to:
  /// **'Import a WAV recording to loop, decode and copy it. No microphone needed.'**
  String get workbenchEmpty;

  /// Recording workbench: supported formats and limits
  ///
  /// In en, this message translates to:
  /// **'WAV, 16-bit PCM, mono or stereo, 8/16/44.1/48 kHz; up to 50 MB and 20 minutes.'**
  String get workbenchFormats;

  /// Reminder to preserve device-local audio recordings before clearing or uninstalling
  ///
  /// In en, this message translates to:
  /// **'Recordings stay on this device. Keep copies before clearing learning data or uninstalling. Saved selections retain their titles, notes and positions.'**
  String get workbenchBackupNote;

  /// Recording workbench: recording format line
  ///
  /// In en, this message translates to:
  /// **'{rate} kHz · {channels} · {duration}'**
  String workbenchInfo(String rate, String channels, String duration);

  /// Recording workbench: one channel
  ///
  /// In en, this message translates to:
  /// **'mono'**
  String get workbenchMono;

  /// Recording workbench: two channels
  ///
  /// In en, this message translates to:
  /// **'stereo'**
  String get workbenchStereo;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'This is not a WAV file.'**
  String get workbenchErrorNotWav;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'Only 16-bit PCM WAV is supported for now (no MP3, AAC or float WAV).'**
  String get workbenchErrorFormat;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'Only mono or stereo recordings are supported.'**
  String get workbenchErrorChannels;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'Sample rate not supported. Use 8, 16, 44.1 or 48 kHz.'**
  String get workbenchErrorRate;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'The file is damaged or incomplete.'**
  String get workbenchErrorDamaged;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 50 MB.'**
  String get workbenchErrorTooLarge;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'The recording is longer than 20 minutes.'**
  String get workbenchErrorTooLong;

  /// Recording workbench: import error
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the file.'**
  String get workbenchErrorIo;

  /// Recording workbench: saved recording file not found
  ///
  /// In en, this message translates to:
  /// **'The recording file is missing.'**
  String get workbenchErrorMissing;

  /// Recording workbench: selection start field (seconds)
  ///
  /// In en, this message translates to:
  /// **'Start (s)'**
  String get workbenchStart;

  /// Recording workbench: selection end field (seconds)
  ///
  /// In en, this message translates to:
  /// **'End (s)'**
  String get workbenchEnd;

  /// Recording workbench: select the whole recording
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get workbenchSelectAll;

  /// Recording workbench: play the selection
  ///
  /// In en, this message translates to:
  /// **'Play selection'**
  String get workbenchPlay;

  /// Recording workbench: stop playback
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get workbenchStop;

  /// Recording workbench: loop the selection
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get workbenchLoop;

  /// Recording workbench: long selections play partly
  ///
  /// In en, this message translates to:
  /// **'Only the first 5 minutes of a longer selection are played.'**
  String get workbenchPlayLimit;

  /// Recording workbench: automatic tone search
  ///
  /// In en, this message translates to:
  /// **'Find the tone automatically'**
  String get workbenchAutoTune;

  /// Recording workbench: manual tone frequency
  ///
  /// In en, this message translates to:
  /// **'Tone: {hz} Hz'**
  String workbenchManualTone(int hz);

  /// Recording workbench: decode the selection
  ///
  /// In en, this message translates to:
  /// **'Decode selection'**
  String get workbenchDecode;

  /// Recording workbench: cancel decoding
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workbenchCancel;

  /// Recording workbench: decoding progress
  ///
  /// In en, this message translates to:
  /// **'Decoding… {percent}%'**
  String workbenchDecoding(int percent);

  /// Recording workbench: decoder tone and speed
  ///
  /// In en, this message translates to:
  /// **'Tone {hz} Hz · about {wpm} WPM'**
  String workbenchResultStats(int hz, int wpm);

  /// Recording workbench: no steady tone
  ///
  /// In en, this message translates to:
  /// **'No steady tone found; try manual tuning.'**
  String get workbenchToneNotLocked;

  /// Recording workbench: nothing decoded
  ///
  /// In en, this message translates to:
  /// **'Nothing decoded in this selection.'**
  String get workbenchNoText;

  /// Recording workbench: patterns that match no symbol
  ///
  /// In en, this message translates to:
  /// **'Unknown patterns: {patterns}'**
  String workbenchUnknown(String patterns);

  /// Recording workbench: symbol cut by the selection boundary
  ///
  /// In en, this message translates to:
  /// **'A symbol at the edge of the selection is cut off and may be wrong.'**
  String get workbenchEdgeCut;

  /// Recording workbench: tone lock is not a confidence score
  ///
  /// In en, this message translates to:
  /// **'Tone lock is not a confidence score; check the text by ear.'**
  String get workbenchToneNote;

  /// Recording workbench: show decoder output
  ///
  /// In en, this message translates to:
  /// **'Decoder'**
  String get workbenchModeDecoder;

  /// Recording workbench: copy the selection yourself
  ///
  /// In en, this message translates to:
  /// **'Copy it myself'**
  String get workbenchModeCopy;

  /// Recording workbench: decoder output hidden in copy mode
  ///
  /// In en, this message translates to:
  /// **'Decoder text is hidden while you copy.'**
  String get workbenchDecoderHidden;

  /// Recording workbench: reveal decoder output (assisted)
  ///
  /// In en, this message translates to:
  /// **'Show decoder text'**
  String get workbenchShowDecoder;

  /// Recording workbench: optional answer text field
  ///
  /// In en, this message translates to:
  /// **'Reference text (optional)'**
  String get workbenchReference;

  /// Recording workbench: reference text help
  ///
  /// In en, this message translates to:
  /// **'Paste the text that was sent; otherwise your copy is compared with the decoder output.'**
  String get workbenchReferenceHelp;

  /// Recording workbench: scored against decoder output
  ///
  /// In en, this message translates to:
  /// **'Compared with the decoder output, which can itself be wrong.'**
  String get workbenchAgainstDecoder;

  /// Recording workbench: save the selection as an audio material
  ///
  /// In en, this message translates to:
  /// **'Save selection'**
  String get workbenchSave;

  /// Recording workbench: title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get workbenchSaveTitle;

  /// Recording workbench: note field
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get workbenchSaveNote;

  /// Recording workbench: selection saved
  ///
  /// In en, this message translates to:
  /// **'Selection saved'**
  String get workbenchSaved;

  /// Recording workbench: saving failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the selection.'**
  String get workbenchSaveFailed;

  /// Recording workbench: saved selections list
  ///
  /// In en, this message translates to:
  /// **'Saved selections'**
  String get workbenchLibrary;

  /// Recording workbench: no saved selections
  ///
  /// In en, this message translates to:
  /// **'No saved selections yet.'**
  String get workbenchLibraryEmpty;

  /// Recording workbench: saved selection whose media file is gone
  ///
  /// In en, this message translates to:
  /// **'Recording file missing — choose it again or delete the entry.'**
  String get workbenchMissing;

  /// Recording workbench: choose the missing file again
  ///
  /// In en, this message translates to:
  /// **'Choose the file again'**
  String get workbenchRelink;

  /// Recording workbench: delete a saved selection
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get workbenchDelete;

  /// My materials: screen title / Learn entry
  ///
  /// In en, this message translates to:
  /// **'My materials'**
  String get materialsTitle;

  /// My materials: create a material
  ///
  /// In en, this message translates to:
  /// **'New material'**
  String get materialsNew;

  /// My materials: edit a material
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get materialsEdit;

  /// Material editor: save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get materialsSave;

  /// Material editor: saving failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the material.'**
  String get materialsSaveFailed;

  /// Material editor: title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get materialsTitleField;

  /// Material editor: tags field (comma separated)
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get materialsTagsField;

  /// Material editor: running text field
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get materialsTextField;

  /// Material editor: one entry per line field
  ///
  /// In en, this message translates to:
  /// **'One entry per line'**
  String get materialsListField;

  /// Material kind: running text
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get materialsKindText;

  /// Material kind: word list
  ///
  /// In en, this message translates to:
  /// **'Word list'**
  String get materialsKindWords;

  /// Material kind: callsign list
  ///
  /// In en, this message translates to:
  /// **'Callsigns'**
  String get materialsKindCallsigns;

  /// Material editor: preview heading
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get materialsPreview;

  /// Material preview: item/symbol/prosign counts
  ///
  /// In en, this message translates to:
  /// **'{items} items · {symbols} symbols · {prosigns} prosigns'**
  String materialsPreviewCounts(int items, int symbols, int prosigns);

  /// Material preview: characters without Morse code (left out of practice)
  ///
  /// In en, this message translates to:
  /// **'No Morse code, left out of practice: {chars}'**
  String materialsPreviewUnsupported(String chars);

  /// Material preview: duplicate list entries kept once
  ///
  /// In en, this message translates to:
  /// **'{count} duplicate entries are kept once'**
  String materialsPreviewDuplicates(int count);

  /// Material problem
  ///
  /// In en, this message translates to:
  /// **'Enter some text first.'**
  String get materialsProblemEmpty;

  /// Material problem: over 1 MiB
  ///
  /// In en, this message translates to:
  /// **'Too large: materials are limited to 1 MiB.'**
  String get materialsProblemTooLarge;

  /// Material problem: too many entries
  ///
  /// In en, this message translates to:
  /// **'Too many entries: at most {count}.'**
  String materialsProblemTooManyEntries(int count);

  /// Material problem: an entry is too long
  ///
  /// In en, this message translates to:
  /// **'An entry is too long: at most {count} symbols each.'**
  String materialsProblemEntryTooLong(int count);

  /// Material problem: nothing can be keyed
  ///
  /// In en, this message translates to:
  /// **'Nothing here can be practised in Morse.'**
  String get materialsProblemNothingTrainable;

  /// My materials: search field
  ///
  /// In en, this message translates to:
  /// **'Search materials'**
  String get materialsSearch;

  /// My materials: favourites filter
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get materialsFavoritesOnly;

  /// My materials: mark favourite
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get materialsFavorite;

  /// My materials: unmark favourite
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get materialsUnfavorite;

  /// My materials: empty library
  ///
  /// In en, this message translates to:
  /// **'No materials yet. Add your own texts, word lists or callsigns.'**
  String get materialsEmpty;

  /// My materials: number of items
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String materialsItems(int count);

  /// My materials: per-material menu
  ///
  /// In en, this message translates to:
  /// **'Material actions'**
  String get materialsActions;

  /// My materials: start practice
  ///
  /// In en, this message translates to:
  /// **'Practise'**
  String get materialsPractise;

  /// My materials: delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get materialsDelete;

  /// My materials: delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete material?'**
  String get materialsDeleteTitle;

  /// My materials: delete confirmation body
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from this device. Your practice history stays.'**
  String materialsDeleteBody(String title);

  /// My materials: import a TXT or JSON file
  ///
  /// In en, this message translates to:
  /// **'Import TXT or JSON'**
  String get materialsImport;

  /// Native file picker title for material import
  ///
  /// In en, this message translates to:
  /// **'Choose a material file'**
  String get materialsImportDialogTitle;

  /// Native save dialog title for material export
  ///
  /// In en, this message translates to:
  /// **'Save material'**
  String get materialsSaveDialogTitle;

  /// My materials: import failed, library unchanged
  ///
  /// In en, this message translates to:
  /// **'Import failed. Your library is unchanged.'**
  String get materialsImportFailed;

  /// My materials: file is not UTF-8 text
  ///
  /// In en, this message translates to:
  /// **'Only UTF-8 text files can be imported.'**
  String get materialsImportNotUtf8;

  /// My materials: JSON library invalid, nothing imported
  ///
  /// In en, this message translates to:
  /// **'Not a valid MorseCQ material file. Nothing was imported.'**
  String get materialsImportInvalid;

  /// My materials: import done
  ///
  /// In en, this message translates to:
  /// **'Imported {count} materials.'**
  String materialsImported(int count);

  /// Import: some ids already exist
  ///
  /// In en, this message translates to:
  /// **'Some materials already exist'**
  String get materialsDuplicateTitle;

  /// Import duplicate policy
  ///
  /// In en, this message translates to:
  /// **'Replace them'**
  String get materialsDuplicateOverwrite;

  /// Import duplicate policy
  ///
  /// In en, this message translates to:
  /// **'Keep both (import as copies)'**
  String get materialsDuplicateKeepCopy;

  /// Import duplicate policy
  ///
  /// In en, this message translates to:
  /// **'Skip them'**
  String get materialsDuplicateSkip;

  /// My materials: export the (filtered) library as JSON
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get materialsExportJson;

  /// My materials: export done
  ///
  /// In en, this message translates to:
  /// **'Exported {count} materials.'**
  String materialsExported(int count);

  /// My materials: export failed
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get materialsExportFailed;

  /// My materials: export audio
  ///
  /// In en, this message translates to:
  /// **'Export audio (WAV)'**
  String get materialsExportWav;

  /// WAV export: character speed
  ///
  /// In en, this message translates to:
  /// **'Character speed: {wpm} WPM'**
  String materialsWavCharSpeed(int wpm);

  /// WAV export: effective speed
  ///
  /// In en, this message translates to:
  /// **'Effective speed: {wpm} WPM'**
  String materialsWavEffSpeed(int wpm);

  /// WAV export: tone
  ///
  /// In en, this message translates to:
  /// **'Tone: {hz} Hz'**
  String materialsWavTone(int hz);

  /// WAV export: also save the answer text
  ///
  /// In en, this message translates to:
  /// **'Include the answer text (.txt)'**
  String get materialsWavWithAnswer;

  /// WAV export: file format note
  ///
  /// In en, this message translates to:
  /// **'16-bit mono WAV, 48 kHz.'**
  String get materialsWavFormat;

  /// WAV export: split into parts of at most 10 minutes
  ///
  /// In en, this message translates to:
  /// **'Longer than 10 minutes: exported as {count} files.'**
  String materialsWavParts(int count);

  /// WAV export: done
  ///
  /// In en, this message translates to:
  /// **'Saved {count} audio files.'**
  String materialsWavExported(int count);

  /// Material practice: choose symbol set
  ///
  /// In en, this message translates to:
  /// **'Practise with'**
  String get materialsPracticeMode;

  /// Material practice: learned symbols only
  ///
  /// In en, this message translates to:
  /// **'Learned symbols only'**
  String get materialsPracticeLearned;

  /// Material practice: learned-only leaves some entries out
  ///
  /// In en, this message translates to:
  /// **'Learned symbols only ({count} entries unavailable: they use symbols not learned yet)'**
  String materialsPracticeLearnedPartial(int count);

  /// Material practice: every supported symbol
  ///
  /// In en, this message translates to:
  /// **'All Morse symbols'**
  String get materialsPracticeAll;

  /// Material practice: no usable entries in this mode
  ///
  /// In en, this message translates to:
  /// **'No entries can be practised in this mode.'**
  String get materialsPracticeNothing;

  /// Guest clear dialog: confirm
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get guestClearConfirm;

  /// Placement assessment: screen title
  ///
  /// In en, this message translates to:
  /// **'Check my level'**
  String get placementTitle;

  /// Placement offer: start the assessment
  ///
  /// In en, this message translates to:
  /// **'Check my current level'**
  String get placementCheckLevel;

  /// Placement: start the course at lesson one
  ///
  /// In en, this message translates to:
  /// **'Skip the intro: lesson 1 challenge'**
  String get placementFromZero;

  /// Learn home: offer for brand-new learners
  ///
  /// In en, this message translates to:
  /// **'New to Morse, or already copying?'**
  String get placementOfferTitle;

  /// Learn home: placement offer explanation
  ///
  /// In en, this message translates to:
  /// **'A short check can suggest where to start. It is optional and changes nothing until you choose.'**
  String get placementOfferBody;

  /// Placement intro
  ///
  /// In en, this message translates to:
  /// **'About 3–5 minutes of copying in five steps: Koch symbols in groups at rising speed, then short words. It is a rough guide from a small sample, not a certificate. Stop whenever you like.'**
  String get placementIntro;

  /// Placement: start
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get placementStart;

  /// Placement: skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get placementSkip;

  /// Placement: stop early and see the suggestion
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get placementStop;

  /// Placement: current step and effective speed
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total} · {wpm} WPM effective'**
  String placementTierProgress(int step, int total, int wpm);

  /// Placement: step passed
  ///
  /// In en, this message translates to:
  /// **'Well copied. Next step is faster.'**
  String get placementTierPassed;

  /// Placement: step below 90 percent, check ends
  ///
  /// In en, this message translates to:
  /// **'That step was below 90%, so the check ends here.'**
  String get placementTierStopped;

  /// Placement: continue to the next step
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get placementNextTier;

  /// Placement result headline
  ///
  /// In en, this message translates to:
  /// **'Suggested start: lesson {lesson}'**
  String placementSuggestion(int lesson);

  /// Placement result: verified Koch prefix
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} Koch symbols confirmed in order.'**
  String placementVerified(int count, int total);

  /// Placement result: limitations
  ///
  /// In en, this message translates to:
  /// **'Based on a short sample: symbols you were not tested on stay untested, and nothing is marked as learned. You can change the lesson any time.'**
  String get placementLimits;

  /// Placement result: apply the suggested lesson
  ///
  /// In en, this message translates to:
  /// **'Start at lesson {lesson}'**
  String placementAdopt(int lesson);

  /// JSON import preview dialog title
  ///
  /// In en, this message translates to:
  /// **'Import {count} materials?'**
  String materialsImportConfirm(int count);

  /// My materials: export the original text as a .txt file
  ///
  /// In en, this message translates to:
  /// **'Export as text (TXT)'**
  String get materialsExportTxt;

  /// Drill picker: heading of the channel conditions selector
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditionsTitle;

  /// Conditions preset: clean tone (default)
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get conditionsClear;

  /// Conditions preset: light interference
  ///
  /// In en, this message translates to:
  /// **'Light interference'**
  String get conditionsLight;

  /// Conditions preset: realistic radio practice
  ///
  /// In en, this message translates to:
  /// **'Radio practice'**
  String get conditionsRadio;

  /// Conditions preset hint: clear
  ///
  /// In en, this message translates to:
  /// **'A clean, steady tone: ordinary practice.'**
  String get conditionsClearHint;

  /// Conditions preset hint: light
  ///
  /// In en, this message translates to:
  /// **'Soft background noise and gentle fading. Results are kept apart from clean practice.'**
  String get conditionsLightHint;

  /// Conditions preset hint: radio practice
  ///
  /// In en, this message translates to:
  /// **'Noise, deep fading, a nearby station and slightly uneven timing. Results are kept apart from clean practice.'**
  String get conditionsRadioHint;

  /// Drill picker: play a short sample under the chosen conditions
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get conditionsPreview;

  /// Receive drill: chip naming the active conditions
  ///
  /// In en, this message translates to:
  /// **'Conditions: {name}'**
  String conditionsActive(String name);

  /// Receive drill: conditions need sound
  ///
  /// In en, this message translates to:
  /// **'Radio conditions are heard, not seen: turn sound on in the training settings, or practise with Clear conditions.'**
  String get conditionsNeedSound;

  /// Round result: replay the round without effects
  ///
  /// In en, this message translates to:
  /// **'Play without effects'**
  String get conditionsCleanReplay;

  /// Receive summary: results under the same conditions and speed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt under these conditions at this speed: {accuracy}%} other{{count} attempts under these conditions at this speed: {accuracy}% on average}}'**
  String conditionsComparable(int count, int accuracy);

  /// Receive summary: conditions results do not change progress
  ///
  /// In en, this message translates to:
  /// **'Practice under radio conditions counts as activity but does not change your lessons, review schedule or speed advice.'**
  String get conditionsSeparateNote;

  /// Key setup page title; also the Me entry
  ///
  /// In en, this message translates to:
  /// **'Keys and external keyers'**
  String get keysTitle;

  /// Me page: subtitle of the key setup entry
  ///
  /// In en, this message translates to:
  /// **'Key bindings, paddles and USB keyer adapters'**
  String get keysMeSubtitle;

  /// Key setup: introduction
  ///
  /// In en, this message translates to:
  /// **'Choose which keys key Morse. Keyboard-emulating USB key and paddle adapters work like a keyboard: set their keys here. The app cannot tell which device sent a key, so a profile is a set of bindings.'**
  String get keysIntro;

  /// Key setup: built-in default profile
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get keysStandardProfile;

  /// Key setup: profile without a name
  ///
  /// In en, this message translates to:
  /// **'Unnamed profile'**
  String get keysUnnamed;

  /// Key setup: edit a profile
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get keysEdit;

  /// Key setup: create a profile
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get keysNewProfile;

  /// Key setup: what is not supported
  ///
  /// In en, this message translates to:
  /// **'MIDI, serial and Bluetooth keyers, adapter firmware settings and transmitter control are not supported. Tested adapters are listed in the documentation.'**
  String get keysLimitations;

  /// Key profile editor title
  ///
  /// In en, this message translates to:
  /// **'Key profile'**
  String get keysEditTitle;

  /// Key profile editor: name field
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get keysName;

  /// Key action/keyer mode: straight key
  ///
  /// In en, this message translates to:
  /// **'Straight key'**
  String get keysActionStraight;

  /// Key action: dit paddle
  ///
  /// In en, this message translates to:
  /// **'Dit paddle'**
  String get keysActionDit;

  /// Key action: dah paddle
  ///
  /// In en, this message translates to:
  /// **'Dah paddle'**
  String get keysActionDah;

  /// Key capture: waiting for a key
  ///
  /// In en, this message translates to:
  /// **'Press a key…'**
  String get keysPressKey;

  /// Key capture: no key bound
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get keysNone;

  /// Key capture: start capturing
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get keysSet;

  /// Key capture: reserved key refused
  ///
  /// In en, this message translates to:
  /// **'{key} is reserved by the system or the app; choose another key.'**
  String keysReserved(String key);

  /// Key capture: key already used for another action
  ///
  /// In en, this message translates to:
  /// **'{key} is already used for {action}.'**
  String keysConflict(String key, String action);

  /// Key profile save refused: duplicate binding
  ///
  /// In en, this message translates to:
  /// **'Each key can do only one thing: {keys} is bound twice.'**
  String keysConflictSave(String keys);

  /// Key profile save refused: keys missing for the mode
  ///
  /// In en, this message translates to:
  /// **'Set the keys this keyer mode needs (both paddles for iambic).'**
  String get keysMissing;

  /// Key profile: swap dit and dah paddles
  ///
  /// In en, this message translates to:
  /// **'Swap paddles (left-handed)'**
  String get keysSwapPaddles;

  /// Key profile: keyer mode heading
  ///
  /// In en, this message translates to:
  /// **'Keyer mode'**
  String get keysKeyerMode;

  /// Keyer mode: iambic A
  ///
  /// In en, this message translates to:
  /// **'Iambic A'**
  String get keysIambicA;

  /// Keyer mode: iambic B
  ///
  /// In en, this message translates to:
  /// **'Iambic B'**
  String get keysIambicB;

  /// Key profile: adapter has its own keyer
  ///
  /// In en, this message translates to:
  /// **'The adapter keys its own elements'**
  String get keysAdapterKeyer;

  /// Key profile: adapter keyer explanation
  ///
  /// In en, this message translates to:
  /// **'For an adapter with its own keyer: its timed key-down and key-up are used as they are, without a second iambic keyer in the app.'**
  String get keysAdapterKeyerHint;

  /// Key profile: app sidetone while keying
  ///
  /// In en, this message translates to:
  /// **'App sidetone while keying'**
  String get keysAppSidetone;

  /// Key profile: sidetone explanation
  ///
  /// In en, this message translates to:
  /// **'Turn off when the adapter makes its own sidetone. Decoding is not affected.'**
  String get keysAppSidetoneHint;

  /// Key profile: test area title
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get keysTestTitle;

  /// Key profile: test area is not sent or credited
  ///
  /// In en, this message translates to:
  /// **'Testing only: nothing is sent or added to your training.'**
  String get keysTestNote;

  /// Key profile: release all keys (stop a stuck tone)
  ///
  /// In en, this message translates to:
  /// **'Release keys'**
  String get keysTestRelease;

  /// Key profile test: adapter keyer active
  ///
  /// In en, this message translates to:
  /// **'The adapter\'s own keyer is used: paddle keys act as a straight key.'**
  String get keysAdapterActive;

  /// Keying hint with the active profile's keys
  ///
  /// In en, this message translates to:
  /// **'Keys: {keys}'**
  String keysHintCustom(String keys);

  /// Chinese telegraph-code practice title / Learn entry
  ///
  /// In en, this message translates to:
  /// **'Chinese telegraph code'**
  String get telegraphTitle;

  /// Telegraph practice: introduction
  ///
  /// In en, this message translates to:
  /// **'Each Chinese character is sent as a four-digit code. Practise hearing the digits and, separately, remembering which code stands for which character.'**
  String get telegraphIntro;

  /// Codebook selector label
  ///
  /// In en, this message translates to:
  /// **'Codebook'**
  String get telegraphCodebook;

  /// Codebook: mainland China (1983)
  ///
  /// In en, this message translates to:
  /// **'Mainland'**
  String get telegraphCodebookMainland;

  /// Codebook: Taiwan / Hong Kong
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get telegraphCodebookTaiwan;

  /// Telegraph practice: digit copying task
  ///
  /// In en, this message translates to:
  /// **'Copy code groups'**
  String get telegraphDigitsTitle;

  /// Telegraph practice: digit copying explanation
  ///
  /// In en, this message translates to:
  /// **'Hear four-digit groups of real codes and type the digits.'**
  String get telegraphDigitsHint;

  /// Telegraph practice: digit copying results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session: {accuracy}% of digits} other{{count} sessions: {accuracy}% of digits}}'**
  String telegraphDigitsResults(int count, int accuracy);

  /// Telegraph practice: codebook recall task
  ///
  /// In en, this message translates to:
  /// **'Recall codes'**
  String get telegraphRecallTitle;

  /// Telegraph practice: recall explanation
  ///
  /// In en, this message translates to:
  /// **'Character to code and code to character. Kept apart from Morse progress.'**
  String get telegraphRecallHint;

  /// Telegraph practice: recall results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card answered: {accuracy}% known} other{{count} cards answered: {accuracy}% known}}'**
  String telegraphRecallResults(int count, int accuracy);

  /// Telegraph practice: recall does not affect Morse progress
  ///
  /// In en, this message translates to:
  /// **'Codebook recall never unlocks Morse lessons or changes speed advice; digit copying counts like other Morse copying.'**
  String get telegraphSeparateNote;

  /// Recall card: type the code of this character
  ///
  /// In en, this message translates to:
  /// **'Type the code of this character'**
  String get telegraphRecallCharPrompt;

  /// Recall card: pick the character of this code
  ///
  /// In en, this message translates to:
  /// **'Pick the character for this code'**
  String get telegraphRecallCodePrompt;

  /// Recall card: reveal the answer (assisted)
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get telegraphReveal;

  /// Recall card: revealed answers count as assisted
  ///
  /// In en, this message translates to:
  /// **'Shown: this card counts as assisted.'**
  String get telegraphRevealAssisted;

  /// Recall card: correct
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get telegraphCorrect;

  /// Recall card: incorrect
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get telegraphIncorrect;

  /// Recall summary: correct of total
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} known'**
  String telegraphRecallSummary(int correct, int total);

  /// Recall summary: cards with a revealed answer
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card with the answer shown} other{{count} cards with the answer shown}}'**
  String telegraphRecallAssisted(int count);

  /// Telegraph interpretation sheet title
  ///
  /// In en, this message translates to:
  /// **'Telegraph code interpretation'**
  String get telegraphInterpretTitle;

  /// Telegraph interpretation: local and read-only
  ///
  /// In en, this message translates to:
  /// **'Shown here only: the message itself is not changed and nothing is sent.'**
  String get telegraphInterpretNote;

  /// Telegraph interpretation: unassigned code
  ///
  /// In en, this message translates to:
  /// **'Unresolved: no character has this code'**
  String get telegraphUnresolved;

  /// Telegraph interpretation: digits but not four
  ///
  /// In en, this message translates to:
  /// **'Not a four-digit group'**
  String get telegraphMalformed;

  /// Telegraph interpretation: ordinary text token
  ///
  /// In en, this message translates to:
  /// **'Text, kept as written'**
  String get telegraphNotCode;

  /// Telegraph interpretation: several characters share the code
  ///
  /// In en, this message translates to:
  /// **'Several characters share this code'**
  String get telegraphAmbiguous;

  /// Receive drill: the conditions audio could not be started
  ///
  /// In en, this message translates to:
  /// **'The audio could not be started on this device. Practise with Clear conditions instead.'**
  String get conditionsAudioFailed;

  /// About: privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacyPolicy;

  /// About: terms of use link
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get aboutTermsOfUse;

  /// About: support and contact link
  ///
  /// In en, this message translates to:
  /// **'Support and contact'**
  String get aboutSupport;

  /// About: a link could not be opened and was copied
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened, so it was copied.'**
  String get aboutLinkFailed;

  /// Offline build Me: clear the local learning data
  ///
  /// In en, this message translates to:
  /// **'Clear learning data'**
  String get offlineClearData;

  /// Offline build Me: what clearing removes
  ///
  /// In en, this message translates to:
  /// **'Deletes your progress, plans and materials on this device.'**
  String get offlineClearDataBody;

  /// Offline build Me: snack after clearing
  ///
  /// In en, this message translates to:
  /// **'Learning data cleared.'**
  String get offlineCleared;

  /// Offline build Me: clearing failed
  ///
  /// In en, this message translates to:
  /// **'Couldn’t clear the learning data.'**
  String get offlineClearFailed;

  /// Offline build: the local learning data could not be opened
  ///
  /// In en, this message translates to:
  /// **'Your training data could not be opened on this device. Try again.'**
  String get learnStorageUnavailable;

  /// Label for a learning material with imported source metadata
  ///
  /// In en, this message translates to:
  /// **'Imported source'**
  String get materialsImportedSource;

  /// Learn home, new-learner card title
  ///
  /// In en, this message translates to:
  /// **'New here? Start with a 3-minute first lesson'**
  String get learnStartHereTitle;

  /// Learn home, new-learner card body
  ///
  /// In en, this message translates to:
  /// **'Hear the sounds, learn K and M, and answer a few easy rounds. Nothing is graded.'**
  String get learnStartHereBody;

  /// Learn home, new-learner card: primary button opening the first lesson
  ///
  /// In en, this message translates to:
  /// **'Start here'**
  String get learnStartHere;

  /// Learn home: button that reopens the first lesson after it was done
  ///
  /// In en, this message translates to:
  /// **'Replay the first lesson'**
  String get learnReplayFirstLesson;

  /// Lesson card: how many symbols were introduced and how many are mastered
  ///
  /// In en, this message translates to:
  /// **'{introduced} introduced · {mastered} mastered'**
  String learnCharsIntroducedMastered(int introduced, int mastered);

  /// Lesson card legend: the symbol this lesson introduces
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get learnChipNew;

  /// Lesson card legend: some attempts, not yet mastered
  ///
  /// In en, this message translates to:
  /// **'Practising'**
  String get learnChipPractising;

  /// Lesson card legend: 10+ attempts at 90%+
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get learnChipMastered;

  /// Lesson card legend: below 90% accuracy
  ///
  /// In en, this message translates to:
  /// **'Below 90%'**
  String get learnChipWeak;

  /// Lesson card legend: due for spaced review
  ///
  /// In en, this message translates to:
  /// **'Due for review'**
  String get learnChipDue;

  /// Lesson card: hint that the symbol chips play their sound when tapped
  ///
  /// In en, this message translates to:
  /// **'Tap a character to hear it'**
  String get learnTapChipHint;

  /// Button: play one symbol
  ///
  /// In en, this message translates to:
  /// **'Hear {char}'**
  String learnHearChar(String char);

  /// Button: play two symbols one after the other so they can be told apart
  ///
  /// In en, this message translates to:
  /// **'{a} vs {b}'**
  String learnCompareWith(String a, String b);

  /// Lesson card: secondary button starting a short guided session
  ///
  /// In en, this message translates to:
  /// **'Short practice (10 symbols)'**
  String get learnGuidedPractice;

  /// Lesson card: what the Continue lesson button starts and what passing requires
  ///
  /// In en, this message translates to:
  /// **'The lesson challenge: {count} symbols at 90%, with each new symbol copied at least {min} times. Passing unlocks the next character.'**
  String learnChallengeHint(int count, int min);

  /// Lesson card: on the last lesson before its challenge is passed
  ///
  /// In en, this message translates to:
  /// **'Every character is unlocked. Pass the final challenge to complete the course.'**
  String get learnAllUnlockedNotPassed;

  /// Lesson card goal line, stage: first use
  ///
  /// In en, this message translates to:
  /// **'Now: tell K from M by ear. Next: the lesson 1 challenge.'**
  String get learnGoalFirstUse;

  /// Lesson card goal line, stage: recognising the new symbol(s)
  ///
  /// In en, this message translates to:
  /// **'Now: recognise {chars} reliably ({min} copies at 90%). Next: the lesson {lesson} challenge.'**
  String learnGoalRecognition(String chars, int min, int lesson);

  /// Lesson card goal line, stage: ready for the lesson challenge
  ///
  /// In en, this message translates to:
  /// **'Now: pass the lesson {lesson} challenge. Next: {next}.'**
  String learnGoalCopying(int lesson, String next);

  /// Fills learnGoalCopying {next}: the character the next lesson introduces
  ///
  /// In en, this message translates to:
  /// **'the character {char}'**
  String learnGoalNextChar(String char);

  /// Fills learnGoalCopying {next} on the last lesson
  ///
  /// In en, this message translates to:
  /// **'words, callsigns and a full QSO'**
  String get learnGoalNextOperating;

  /// Lesson card goal line, stage: course completed
  ///
  /// In en, this message translates to:
  /// **'Now: real messages — words, callsigns, QSO. Next: raise the effective speed one step at a time.'**
  String get learnGoalOperating;

  /// Learn home: expandable section with the less common practice entries
  ///
  /// In en, this message translates to:
  /// **'More practice'**
  String get learnMorePractice;

  /// Learn home QSO tile: every required symbol is learned
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get learnQsoReady;

  /// Learn home QSO tile: symbols known but the abbreviations / QSO-lines drills not practised yet
  ///
  /// In en, this message translates to:
  /// **'Practise the lines first'**
  String get learnQsoPractiseFirst;

  /// Learn home QSO tile: symbols still to learn before a full QSO
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 symbol to learn} other{{count} symbols to learn}}'**
  String learnQsoSymbolsToGo(int count);

  /// Learn home / settings: plain-language glossary dialog title and tooltip
  ///
  /// In en, this message translates to:
  /// **'What do these words mean?'**
  String get learnGlossaryTitle;

  /// Glossary entry
  ///
  /// In en, this message translates to:
  /// **'Koch method: characters are learned at full speed, two to start and one more per lesson, once you copy 90% correctly.'**
  String get glossaryKoch;

  /// Glossary entry
  ///
  /// In en, this message translates to:
  /// **'WPM: words per minute, counted with the standard word PARIS. Character speed is how fast each character itself sounds.'**
  String get glossaryWpm;

  /// Glossary entry
  ///
  /// In en, this message translates to:
  /// **'Farnsworth: characters stay fast, but the pauses between them are stretched so you have time to think. The effective speed counts those pauses.'**
  String get glossaryFarnsworth;

  /// Glossary entry
  ///
  /// In en, this message translates to:
  /// **'QSO: one two-way contact between two stations. CQ = calling anyone, DE = from, K = over to you.'**
  String get glossaryQso;

  /// Glossary entry
  ///
  /// In en, this message translates to:
  /// **'RST: a signal report — readability, strength, tone. 599 means perfect. 73 means best regards.'**
  String get glossaryRst;

  /// Receive summary: no symbol was answered
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded: no symbols were answered.'**
  String get learnVerdictNotCredited;

  /// Receive summary headline: replay / reveal was used
  ///
  /// In en, this message translates to:
  /// **'Practice with help'**
  String get learnVerdictAssisted;

  /// Receive summary explanation for an assisted attempt
  ///
  /// In en, this message translates to:
  /// **'Replays or reveals were used, so this attempt counts as practice only: no unlock, no review update. Try the next one without replays.'**
  String get learnVerdictAssistedHint;

  /// Receive summary headline: free practice (not a course challenge)
  ///
  /// In en, this message translates to:
  /// **'Practice recorded'**
  String get learnVerdictPractice;

  /// Receive summary explanation: free practice never advances the course
  ///
  /// In en, this message translates to:
  /// **'Free practice updates your statistics and reviews but never advances the course. The lesson challenge from the Learn home does.'**
  String get learnVerdictPracticeHint;

  /// Receive summary headline: the last lesson challenge was passed
  ///
  /// In en, this message translates to:
  /// **'Final challenge passed: the whole character course is yours.'**
  String get learnVerdictCourseComplete;

  /// Receive summary headline: fewer symbols than a challenge needs
  ///
  /// In en, this message translates to:
  /// **'Not a full challenge: {count} of {min} symbols'**
  String learnVerdictTooShort(int count, int min);

  /// Receive summary explanation for a too-short challenge
  ///
  /// In en, this message translates to:
  /// **'A challenge is at least {min} symbols. Start the lesson from the Learn home or raise the session length in training settings.'**
  String learnVerdictTooShortHint(int min);

  /// Receive summary headline: the new symbol was not heard often enough
  ///
  /// In en, this message translates to:
  /// **'Not enough copies of {chars}'**
  String learnVerdictUncovered(String chars);

  /// Receive summary explanation for an uncovered new symbol
  ///
  /// In en, this message translates to:
  /// **'A challenge needs at least {min} copies of each new symbol. Try again: the challenge includes them on purpose.'**
  String learnVerdictUncoveredHint(int min);

  /// Receive summary headline: the new symbol was below 90%
  ///
  /// In en, this message translates to:
  /// **'New symbol below 90%: {chars}'**
  String learnVerdictNewSymbolWeak(String chars);

  /// Receive summary explanation when only the new symbol failed
  ///
  /// In en, this message translates to:
  /// **'The rest was fine; the new symbol decides the lesson. Hear it against its neighbour and drill it before the next challenge.'**
  String get learnVerdictNewSymbolWeakHint;

  /// Receive summary explanation for an overall accuracy below 90%
  ///
  /// In en, this message translates to:
  /// **'Below 90% overall. A short drill on the weak symbols below, then try the challenge again.'**
  String get learnVerdictBelowAccuracyHint;

  /// Receive summary action: short focus session on the weak symbols
  ///
  /// In en, this message translates to:
  /// **'Drill weak symbols'**
  String get learnDrillWeak;

  /// Receive summary action: start the lesson challenge again
  ///
  /// In en, this message translates to:
  /// **'Retry the challenge'**
  String get learnRetryChallenge;

  /// Receive summary action after free practice: start the lesson challenge
  ///
  /// In en, this message translates to:
  /// **'Take the lesson challenge'**
  String get learnTakeChallenge;

  /// Receive drill screen title for a course challenge
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson} challenge'**
  String learnChallengeTitle(int lesson);

  /// Receive drill screen title for free practice
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get learnPracticeTitle;

  /// Round result: heading over the meanings of the abbreviations just copied
  ///
  /// In en, this message translates to:
  /// **'Meanings'**
  String get learnMeaningsTitle;

  /// First lesson screen title
  ///
  /// In en, this message translates to:
  /// **'First lesson'**
  String get firstLessonTitle;

  /// First lesson: step counter
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String firstLessonStep(int step, int total);

  /// First lesson step 1 title: audibility check
  ///
  /// In en, this message translates to:
  /// **'Can you hear it?'**
  String get firstLessonHearTitle;

  /// First lesson step 1 body
  ///
  /// In en, this message translates to:
  /// **'Tap Play. You should hear a short pattern of beeps (or see a flash / feel a vibration if those are on).'**
  String get firstLessonHearBody;

  /// First lesson: confirm the sound was perceived
  ///
  /// In en, this message translates to:
  /// **'I heard it'**
  String get firstLessonHeard;

  /// First lesson: the sound was not perceived
  ///
  /// In en, this message translates to:
  /// **'I heard nothing'**
  String get firstLessonNotHeard;

  /// First lesson: recovery card title when nothing was heard
  ///
  /// In en, this message translates to:
  /// **'No sound?'**
  String get firstLessonNoSoundTitle;

  /// First lesson: recovery tips when nothing was heard
  ///
  /// In en, this message translates to:
  /// **'Turn the volume up and check the silent switch or Do Not Disturb. You can also follow a screen flash or vibration instead of sound.'**
  String get firstLessonNoSoundBody;

  /// First lesson: switch enabling the screen flash modality
  ///
  /// In en, this message translates to:
  /// **'Flash the screen too'**
  String get firstLessonUseFlash;

  /// First lesson: switch enabling vibration (phones)
  ///
  /// In en, this message translates to:
  /// **'Vibrate too'**
  String get firstLessonUseVibration;

  /// First lesson: play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get firstLessonPlay;

  /// First lesson step 2 title: dit and dah
  ///
  /// In en, this message translates to:
  /// **'Short and long'**
  String get firstLessonSoundsTitle;

  /// First lesson step 2 body
  ///
  /// In en, this message translates to:
  /// **'Morse has two sounds: a short dit and a long dah, three times as long. A character is a pattern of them, and a short silence separates characters. Tap each one to hear it.'**
  String get firstLessonSoundsBody;

  /// First lesson: the short element
  ///
  /// In en, this message translates to:
  /// **'dit'**
  String get firstLessonDit;

  /// First lesson: the long element
  ///
  /// In en, this message translates to:
  /// **'dah'**
  String get firstLessonDah;

  /// First lesson step 3 title: worked example
  ///
  /// In en, this message translates to:
  /// **'A worked answer'**
  String get firstLessonWorkedTitle;

  /// First lesson step 3 body
  ///
  /// In en, this message translates to:
  /// **'Listen first; the answer appears after the sound. You don’t have to answer yet.'**
  String get firstLessonWorkedBody;

  /// First lesson: the revealed answer of the worked example
  ///
  /// In en, this message translates to:
  /// **'That was {char}'**
  String firstLessonWorkedReveal(String char);

  /// First lesson step 4 title: two-choice trials
  ///
  /// In en, this message translates to:
  /// **'K or M?'**
  String get firstLessonTrialsTitle;

  /// First lesson step 4 body
  ///
  /// In en, this message translates to:
  /// **'Listen, then tap the character you heard. Replay as often as you like — this is not a test.'**
  String get firstLessonTrialsBody;

  /// First lesson: trial counter
  ///
  /// In en, this message translates to:
  /// **'Round {round} of {total}'**
  String firstLessonTrialRound(int round, int total);

  /// First lesson: trial feedback, right answer
  ///
  /// In en, this message translates to:
  /// **'Yes, that was {char}'**
  String firstLessonTrialCorrect(String char);

  /// First lesson: trial feedback, wrong answer
  ///
  /// In en, this message translates to:
  /// **'That was {char}, not {answer}. Hear them side by side.'**
  String firstLessonTrialWrong(String char, String answer);

  /// First lesson: switch to the beginner pace (longer pauses)
  ///
  /// In en, this message translates to:
  /// **'Too fast? Use the beginner pace (longer pauses between characters)'**
  String get firstLessonTooFast;

  /// First lesson step 5 title
  ///
  /// In en, this message translates to:
  /// **'What next'**
  String get firstLessonNextTitle;

  /// First lesson step 5 body with the trial result
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct this round. Choose your next step and continue at your own pace.'**
  String firstLessonNextBody(int correct, int total);

  /// First lesson next action: short guided session
  ///
  /// In en, this message translates to:
  /// **'Short practice: 10 single symbols'**
  String get firstLessonNextGuided;

  /// First lesson next action: open send practice
  ///
  /// In en, this message translates to:
  /// **'Try sending'**
  String get firstLessonNextSend;

  /// First lesson: first-use keying guidance
  ///
  /// In en, this message translates to:
  /// **'Sending: hold the control briefly for a dit, longer for a dah. With paddles one side makes dits and the other dahs. Release, and pause briefly between characters. Straight key or iambic A / B can be changed later; it doesn’t matter yet.'**
  String get firstLessonSendGuide;

  /// First lesson: footer note
  ///
  /// In en, this message translates to:
  /// **'You can replay this lesson any time from the Learn home.'**
  String get firstLessonReplayAnytime;

  /// First lesson: next step button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get firstLessonContinue;

  /// First lesson: next trial button
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get firstLessonTrialNext;

  /// Send practice: first-use hint card title
  ///
  /// In en, this message translates to:
  /// **'First time keying?'**
  String get sendFirstUseTitle;

  /// Send practice first-use hint for the straight key
  ///
  /// In en, this message translates to:
  /// **'Hold the key briefly for a dit, about three times longer for a dah. Pause briefly between characters, longer between words.'**
  String get sendFirstUseStraight;

  /// Send practice first-use hint for paddles
  ///
  /// In en, this message translates to:
  /// **'Hold the paddle labelled dit for dits and the one labelled dah for dahs; the keyer times them for you. Pause briefly between characters, longer between words.'**
  String get sendFirstUsePaddles;

  /// Send practice first-use hint: dismiss button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get sendFirstUseDismiss;

  /// Training settings: label over the pace presets
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get learnSpeedPresets;

  /// Training settings preset: 20 WPM characters, 6 WPM effective
  ///
  /// In en, this message translates to:
  /// **'Beginner 20 / 6'**
  String get learnPresetBeginner;

  /// Training settings preset: 20 WPM characters, 8 WPM effective
  ///
  /// In en, this message translates to:
  /// **'Standard 20 / 8'**
  String get learnPresetStandard;

  /// Training settings: what the two presets mean
  ///
  /// In en, this message translates to:
  /// **'Characters sound at 20 WPM in both; the beginner pace leaves longer pauses between them (6 WPM effective).'**
  String get learnPresetHelp;

  /// Daily plan step title: the first lesson
  ///
  /// In en, this message translates to:
  /// **'First lesson'**
  String get learnPlanStepIntro;

  /// Daily plan step title: single-symbol recognition
  ///
  /// In en, this message translates to:
  /// **'Single symbols'**
  String get learnPlanStepRecognition;

  /// Daily plan reason for the first-lesson step
  ///
  /// In en, this message translates to:
  /// **'Hear the sounds and tell K from M (about 3 minutes)'**
  String get learnPlanReasonFirstLesson;

  /// Daily plan reason for the recognition step
  ///
  /// In en, this message translates to:
  /// **'One symbol at a time: {symbols}'**
  String learnPlanReasonRecognition(String symbols);

  /// Daily plan reason for guided (non-unlocking) copying
  ///
  /// In en, this message translates to:
  /// **'Short mixed groups of {count} symbols; the 50-symbol challenge comes later'**
  String learnPlanReasonGuided(int count);

  /// Daily plan reason for the optional beginner sending step
  ///
  /// In en, this message translates to:
  /// **'Optional: hear the model, then key {count} short targets'**
  String learnPlanReasonSendOptional(int count);

  /// QSO setup readiness card: all symbols learned and abbreviations practised
  ///
  /// In en, this message translates to:
  /// **'Ready for a QSO'**
  String get learnQsoReadyTitle;

  /// QSO setup readiness card: some required symbols are not learned
  ///
  /// In en, this message translates to:
  /// **'Not every symbol is learned yet'**
  String get learnQsoNotReadyTitle;

  /// QSO setup readiness card body listing untaught symbols
  ///
  /// In en, this message translates to:
  /// **'A QSO uses these symbols you haven’t learned yet — tap one to hear it. You can explore anyway; the keypad shows every symbol.'**
  String get learnQsoMissingBody;

  /// QSO setup readiness card: abbreviations not practised yet
  ///
  /// In en, this message translates to:
  /// **'Practise the abbreviations first (CQ, DE, UR, RST, TNX, 73) so the lines make sense.'**
  String get learnQsoShorthandHint;

  /// QSO setup readiness card: button opening the abbreviations drill
  ///
  /// In en, this message translates to:
  /// **'Practise abbreviations'**
  String get learnQsoPractiseShorthand;

  /// QSO setup: short protocol explainer title
  ///
  /// In en, this message translates to:
  /// **'How a QSO goes'**
  String get learnQsoHowTitle;

  /// QSO setup: short protocol explainer body
  ///
  /// In en, this message translates to:
  /// **'Call (CQ = anyone, DE = from), answer with callsigns, exchange a report (RST), name and QTH (location), then 73 (best regards) and <SK> (end). K means over to you.'**
  String get learnQsoHowBody;

  /// QSO drill / simulator label when untaught symbols are included
  ///
  /// In en, this message translates to:
  /// **'Includes untaught symbols'**
  String get learnQsoExploreLabel;

  /// Statistics lesson tile value once the last lesson challenge was passed
  ///
  /// In en, this message translates to:
  /// **'Course passed'**
  String get statsCoursePassed;

  /// First lesson: play button after the learner reported hearing nothing
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get firstLessonPlayAgain;

  /// First lesson next action: the current lesson challenge, naming what it unlocks
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson} challenge: {count} symbols, 90% unlocks {char}'**
  String firstLessonNextChallenge(int lesson, int count, String char);

  /// First lesson next action on the last lesson: passing completes the course
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson} challenge: {count} symbols at 90% completes the course'**
  String firstLessonNextChallengeLast(int lesson, int count);

  /// QSO setup readiness card title: symbols known, abbreviations not practised
  ///
  /// In en, this message translates to:
  /// **'Practise the abbreviations first'**
  String get learnQsoShorthandTitle;

  /// QSO setup readiness card title: abbreviations practised, QSO lines not yet
  ///
  /// In en, this message translates to:
  /// **'Practise QSO lines first'**
  String get learnQsoExchangeTitle;

  /// QSO setup readiness card body for the exchange level
  ///
  /// In en, this message translates to:
  /// **'Copy single lines of a contact (one exchange at a time) before running a whole QSO in the simulator.'**
  String get learnQsoExchangeHint;

  /// Guided sending: sendGuideTitle
  ///
  /// In en, this message translates to:
  /// **'Learn to send'**
  String get sendGuideTitle;

  /// Guided sending: sendGuideStep
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String sendGuideStep(int step, int total);

  /// Guided sending: sendGuideHear
  ///
  /// In en, this message translates to:
  /// **'Hear the model'**
  String get sendGuideHear;

  /// Guided sending: sendGuideListening
  ///
  /// In en, this message translates to:
  /// **'Listen to the whole rhythm…'**
  String get sendGuideListening;

  /// Guided sending: sendGuideTry
  ///
  /// In en, this message translates to:
  /// **'Now send it'**
  String get sendGuideTry;

  /// Guided sending: sendGuideRetry
  ///
  /// In en, this message translates to:
  /// **'Practise this again'**
  String get sendGuideRetry;

  /// Guided sending: sendGuidePassed
  ///
  /// In en, this message translates to:
  /// **'Decoded correctly. Continue to the next target.'**
  String get sendGuidePassed;

  /// Guided sending: sendGuideComplete
  ///
  /// In en, this message translates to:
  /// **'You sent both symbols and the groups correctly. Continue with free sending practice.'**
  String get sendGuideComplete;

  /// Guided sending: sendGuideRhythm
  ///
  /// In en, this message translates to:
  /// **'Match the model: short dits, dahs three times longer, and a clear pause between characters.'**
  String get sendGuideRhythm;

  /// Learning pedagogy: learnContinueToday
  ///
  /// In en, this message translates to:
  /// **'Continue today\'s learning'**
  String get learnContinueToday;

  /// Learning pedagogy: learnPlanDetails
  ///
  /// In en, this message translates to:
  /// **'View plan details'**
  String get learnPlanDetails;

  /// Learning pedagogy: learnGuidedSingle
  ///
  /// In en, this message translates to:
  /// **'Single characters · 10 characters'**
  String get learnGuidedSingle;

  /// Learning pedagogy: learnGuidedShort
  ///
  /// In en, this message translates to:
  /// **'3-character groups · 15 characters'**
  String get learnGuidedShort;

  /// Learning pedagogy: learnGuidedGroups
  ///
  /// In en, this message translates to:
  /// **'5-character groups · 20 characters'**
  String get learnGuidedGroups;

  /// Learning pedagogy: learnGuidedRecommended
  ///
  /// In en, this message translates to:
  /// **'Recommended next step'**
  String get learnGuidedRecommended;

  /// Learning pedagogy: learnGuidedProgressHint
  ///
  /// In en, this message translates to:
  /// **'Continue to short groups and full groups after passing. Guided practice builds fluency; a course challenge unlocks the next lesson.'**
  String get learnGuidedProgressHint;

  /// Learning pedagogy: learnGuidedContinue
  ///
  /// In en, this message translates to:
  /// **'Continue guided practice'**
  String get learnGuidedContinue;

  /// Learning pedagogy: learnGuidedRetry
  ///
  /// In en, this message translates to:
  /// **'Practise this level again'**
  String get learnGuidedRetry;

  /// Learning pedagogy: firstLessonZeroHint
  ///
  /// In en, this message translates to:
  /// **'No correct answers yet is okay. Listen to the difference between K and M again, then retry.'**
  String get firstLessonZeroHint;

  /// Learning pedagogy: firstLessonPartialHint
  ///
  /// In en, this message translates to:
  /// **'You heard some correctly. Compare K and M again and continue at your own pace.'**
  String get firstLessonPartialHint;

  /// Learning pedagogy: firstLessonPerfectHint
  ///
  /// In en, this message translates to:
  /// **'Every answer was correct this round. Reinforce this with copying practice without answer choices.'**
  String get firstLessonPerfectHint;

  /// Learning pedagogy: firstLessonPaceLocked
  ///
  /// In en, this message translates to:
  /// **'This round has started, so its speed stays fixed. You can change the speed in settings for the next round.'**
  String get firstLessonPaceLocked;

  /// Learning pedagogy: learnRecentEvidenceHint
  ///
  /// In en, this message translates to:
  /// **'Stages use unassisted copying evidence from the last 14 days at the same speed.'**
  String get learnRecentEvidenceHint;

  /// Learning pedagogy: learnQsoConsolidateTitle
  ///
  /// In en, this message translates to:
  /// **'Reinforce learned characters'**
  String get learnQsoConsolidateTitle;

  /// Learning pedagogy: learnQsoConsolidateHint
  ///
  /// In en, this message translates to:
  /// **'Unlocked does not mean mastered. Start with single-character copying to build recent independent evidence.'**
  String get learnQsoConsolidateHint;

  /// Learning pedagogy: learnQsoPractiseSymbols
  ///
  /// In en, this message translates to:
  /// **'Practise these characters'**
  String get learnQsoPractiseSymbols;

  /// Learning pedagogy: learnQsoProtocolTitle
  ///
  /// In en, this message translates to:
  /// **'Understand QSO terms'**
  String get learnQsoProtocolTitle;

  /// Learning pedagogy: learnQsoProtocolHint
  ///
  /// In en, this message translates to:
  /// **'Check the meanings of CQ, DE, RST and 73 before starting a short QSO.'**
  String get learnQsoProtocolHint;

  /// Learning pedagogy: learnQsoProtocolStart
  ///
  /// In en, this message translates to:
  /// **'Check term understanding'**
  String get learnQsoProtocolStart;

  /// Learning pedagogy: learnQsoProtocolQuestion
  ///
  /// In en, this message translates to:
  /// **'What does {token} mean in a QSO?'**
  String learnQsoProtocolQuestion(String token);

  /// Learning pedagogy: learnQsoGeneralCall
  ///
  /// In en, this message translates to:
  /// **'Calling any station'**
  String get learnQsoGeneralCall;

  /// Learning pedagogy: learnQsoFromStation
  ///
  /// In en, this message translates to:
  /// **'From this station'**
  String get learnQsoFromStation;

  /// Learning pedagogy: learnQsoSignalReport
  ///
  /// In en, this message translates to:
  /// **'Signal report'**
  String get learnQsoSignalReport;

  /// Learning pedagogy: learnQsoBestRegards
  ///
  /// In en, this message translates to:
  /// **'Best regards and goodbye'**
  String get learnQsoBestRegards;

  /// Learning pedagogy: learnQsoProtocolCorrect
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get learnQsoProtocolCorrect;

  /// Learning pedagogy: learnQsoProtocolWrong
  ///
  /// In en, this message translates to:
  /// **'Correct meaning: {meaning}'**
  String learnQsoProtocolWrong(String meaning);

  /// Learning pedagogy: learnQsoProtocolPass
  ///
  /// In en, this message translates to:
  /// **'All four terms were answered correctly without help. You can try a short QSO.'**
  String get learnQsoProtocolPass;

  /// Learning pedagogy: learnQsoProtocolPractice
  ///
  /// In en, this message translates to:
  /// **'Review these meanings before checking again.'**
  String get learnQsoProtocolPractice;

  /// Learning pedagogy: learnQsoProtocolRetry
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get learnQsoProtocolRetry;

  /// Learning pedagogy: learnQsoShortExchange
  ///
  /// In en, this message translates to:
  /// **'Practise a short QSO'**
  String get learnQsoShortExchange;

  /// Learning pedagogy: learnQsoShortExchangeHint
  ///
  /// In en, this message translates to:
  /// **'Confirm callsigns, exchange signal reports and close without help before moving to a full QSO.'**
  String get learnQsoShortExchangeHint;

  /// Learning pedagogy: learnQsoExplorePending
  ///
  /// In en, this message translates to:
  /// **'Explore a full QSO · practice still needed'**
  String get learnQsoExplorePending;

  /// Learning pedagogy: learnQsoReadyHint
  ///
  /// In en, this message translates to:
  /// **'You have recent independent practice evidence and can begin full simulated QSOs.'**
  String get learnQsoReadyHint;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'ja', 'ko', 'pt', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return SZhHant();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return SDe();
    case 'en': return SEn();
    case 'es': return SEs();
    case 'fr': return SFr();
    case 'ja': return SJa();
    case 'ko': return SKo();
    case 'pt': return SPt();
    case 'ru': return SRu();
    case 'zh': return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
