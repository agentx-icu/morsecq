// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => 'Learn';

  @override
  String get navChat => 'Chat';

  @override
  String get navGroups => 'Groups';

  @override
  String get navMe => 'Me';

  @override
  String get navReference => 'Reference';

  @override
  String get navLearnDescription => 'Koch-method lessons, keying drills and copy practice.';

  @override
  String get navChatDescription => 'Serverless one-to-one Morse conversations over Tox P2P.';

  @override
  String get navGroupsDescription => 'Group nets — many operators keying on one shared channel.';

  @override
  String get navReferenceDescription => 'Alphabet, prosigns, Q-codes, abbreviations and a two-way translator.';

  @override
  String get navMeDescription => 'Your callsign, Tox identity, progress and settings.';

  @override
  String get shellOfflineBanner => 'Offline: not connected to the Tox network. Messages will be sent when you are back online.';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionShare => 'Share';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionSettings => 'Settings';

  @override
  String get connectionConnecting => 'Connecting…';

  @override
  String get connectionOnline => 'Online';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get messageStatusPending => 'Queued — peer is offline';

  @override
  String get messageStatusPendingDetail => 'Tox has no server: the message is delivered when the peer comes online.';

  @override
  String get messageStatusSending => 'Sending';

  @override
  String get messageStatusSent => 'Sent';

  @override
  String get messageStatusFailed => 'Failed to send';

  @override
  String get errorWrongPassword => 'Wrong password. Try again.';

  @override
  String get errorPeerOffline => 'This contact is offline. Tox has no server, so the message waits until they come back.';

  @override
  String get errorInvalidToxId => 'That is not a valid Tox ID (76 hex characters).';

  @override
  String get errorAlreadyFriend => 'This Tox ID is already in your friend list.';

  @override
  String get errorOwnId => 'That is your own Tox ID.';

  @override
  String get errorGroupNotFound => 'Group not found.';

  @override
  String get errorMessageTooLong => 'Message is too long for one Tox message.';

  @override
  String get errorUnknown => 'Something went wrong';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageSaveFailed => 'Couldn\'t save the language setting. Try again.';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'Lesson $lesson of $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters learned',
      one: '1 character learned',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal chars';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
      zero: 'Nothing due',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String learnRoundOf(int round) {
    return 'Round $round';
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
      other: '$count characters sent',
      one: '1 character sent',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return 'Next character unlocked: $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target missed';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target heard as $answered';
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
      other: '$count characters',
      one: '1 character',
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
      other: '$count characters learned',
      one: '1 character learned',
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
      other: '$count chars copied',
      one: '1 char copied',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'best $count days',
      one: 'best 1 day',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal chars';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining chars to go',
      one: '1 char to go',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last $count sessions',
      one: 'Last session',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return 'Session $index of $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'Lesson $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$correct of $attempts correct';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'Introduced in lesson $lesson';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'Box $box of $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Due in $days days',
      one: 'Due tomorrow',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$target answered as $answered, $_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars chars',
      zero: 'no practice',
    );
    return '$date: $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active days',
      one: '1 active day',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
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
    return 'Skipped (no Morse code): $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Koch position: $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return 'Estimated $wpm WPM';
  }

  @override
  String get accountCopied => 'Tox ID copied to clipboard';

  @override
  String get accountShowQr => 'Show QR code';

  @override
  String get accountToxId => 'Tox ID';

  @override
  String get accountDisplayName => 'Display name';

  @override
  String get accountDisplayNameHint => 'Your callsign or nickname';

  @override
  String get accountDisplayNameRequired => 'Enter a display name';

  @override
  String get accountStatusMessage => 'Status message';

  @override
  String get accountPassword => 'Password';

  @override
  String get accountPasswordOptional => 'Password (optional)';

  @override
  String get accountConfirmPassword => 'Confirm password';

  @override
  String get accountPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountShowPassword => 'Show password';

  @override
  String get accountHidePassword => 'Hide password';

  @override
  String get accountStrengthWeak => 'Weak: use at least 8 characters';

  @override
  String get accountStrengthFair => 'Fair: 12+ characters with mixed types is better';

  @override
  String get accountStrengthStrong => 'Strong';

  @override
  String get accountStartupInspecting => 'Checking your identity…';

  @override
  String get accountStartupOpening => 'Opening your identity…';

  @override
  String get accountStartupFailedTitle => 'Could not start';

  @override
  String get accountStartupFailedBody => 'MorseCQ could not read your identity. Nothing was changed; you can try again.';

  @override
  String get accountConnectionTapToReconnect => 'Tap to reconnect';

  @override
  String get accountWelcomeTitle => 'Your identity lives on this device';

  @override
  String get accountWelcomeIntro => 'MorseCQ uses the Tox peer-to-peer network. There is no server and no account to sign up for: your identity is a key pair stored only here.';

  @override
  String get accountWelcomePointNoServer => 'No server, no phone number, no e-mail. Peers talk to each other directly, in Morse.';

  @override
  String get accountWelcomePointTraining => 'Training progress is saved with your identity, so it can be backed up and moved between devices.';

  @override
  String get accountWelcomePointBackup => 'Nobody can recover an identity for you. Back it up right after creating it, or you will lose it with the device.';

  @override
  String get accountCreateIdentity => 'Create identity';

  @override
  String get accountRestoreFromBackup => 'Restore from backup';

  @override
  String get accountCreateTitle => 'Create your identity';

  @override
  String get accountCreateBody => 'Pick a name others will see. A password encrypts the identity file on this device; leave it empty if you prefer to open the app without one.';

  @override
  String get accountCreateButton => 'Create';

  @override
  String get accountCreating => 'Creating…';

  @override
  String get accountBackupTitle => 'Back up your identity now';

  @override
  String get accountBackupBody => 'Your identity exists only on this device. If it is lost, reset or stolen, there is no way to recover it: your contacts will not recognise a new identity and your training progress is gone.';

  @override
  String get accountBackupWhatIsInside => 'The backup file contains your identity key, encrypted with your password, and your training progress. Keep it somewhere safe, outside this device.';

  @override
  String get accountBackupWhatIsInsidePlain => 'The backup file contains your identity key unencrypted, and your training progress. Anyone who gets this file can use your identity: set a password first if you want the key encrypted, and keep the file somewhere safe.';

  @override
  String get accountPasswordScope => 'Your password encrypts your identity key. Message history remains unencrypted on disk; device encryption can protect it.';

  @override
  String get accountSectionNotifications => 'Notifications';

  @override
  String get accountNotificationsEnable => 'Show notifications';

  @override
  String get accountNotificationsEnableSubtitle => 'New messages, friend requests and group invites';

  @override
  String get accountNotificationsContent => 'Show message content';

  @override
  String get accountNotificationsContentSubtitle => 'Text and Morse in banners and on the lock screen. Off: only that a message arrived.';

  @override
  String get accountNotificationsAllow => 'Allow notifications';

  @override
  String get accountNotificationsAllowSubtitle => 'Ask the system for permission';

  @override
  String get accountNotificationsDenied => 'Notifications are off for MorseCQ in the system settings.';

  @override
  String get accountBackupSaveFile => 'Save backup file';

  @override
  String get accountBackupShareFile => 'Share backup file';

  @override
  String get accountBackupSaved => 'Backup saved';

  @override
  String get accountBackupNotSaved => 'Backup was not saved';

  @override
  String get accountBackupFailed => 'Could not write the backup';

  @override
  String get accountBackupAcknowledge => 'I understand that without this backup my identity cannot be recovered.';

  @override
  String get accountBackupContinue => 'Continue to MorseCQ';

  @override
  String get accountBackupShowQrHint => 'Your Tox ID is how friends add you. Share it as text or as a QR code.';

  @override
  String get accountRestoreTitle => 'Restore from backup';

  @override
  String get accountRestoreBody => 'Choose a backup file exported from MorseCQ. If the identity was protected with a password you will need it here.';

  @override
  String get accountRestoreChooseFile => 'Choose backup file';

  @override
  String get accountRestoreNoFile => 'Choose a backup file first';

  @override
  String get accountRestoreButton => 'Restore';

  @override
  String get accountRestoring => 'Restoring…';

  @override
  String get accountRestoreInvalidFile => 'This file is not a MorseCQ backup.';

  @override
  String get accountRestoreReplacesWarning => 'Restoring replaces the identity currently on this device.';

  @override
  String get accountUnlockTitle => 'Unlock your identity';

  @override
  String get accountUnlockBody => 'Your identity file is encrypted. Enter the password to continue.';

  @override
  String get accountUnlockButton => 'Unlock';

  @override
  String get accountUnlocking => 'Unlocking…';

  @override
  String get accountUnlockRestoreInstead => 'Restore from backup instead';

  @override
  String get accountMeNoIdentity => 'No identity loaded';

  @override
  String get accountSectionAccount => 'Account';

  @override
  String get accountSectionTraining => 'Training';

  @override
  String get accountSectionAbout => 'About';

  @override
  String get accountSectionDanger => 'Danger zone';

  @override
  String get accountEditProfile => 'Edit profile';

  @override
  String get accountEditProfileBody => 'Shown to your contacts on the Tox network.';

  @override
  String get accountSetPassword => 'Set password';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountRemovePassword => 'Remove password';

  @override
  String get accountCurrentPassword => 'Current password';

  @override
  String get accountNewPassword => 'New password';

  @override
  String get accountPasswordUpdated => 'Password updated';

  @override
  String get accountPasswordRemoved => 'Password removed';

  @override
  String get accountProfileUpdated => 'Profile updated';

  @override
  String get accountExportBackup => 'Export backup';

  @override
  String get accountExportBackupSubtitle => 'Save your identity and training progress to a file';

  @override
  String get accountTrainingDefaults => 'Playback & training defaults';

  @override
  String get accountTrainingDefaultsSubtitle => 'Speed, tone, Farnsworth spacing';

  @override
  String get accountTrainingDefaultsPlaceholder => 'Speed, tone and Farnsworth defaults will live here.';

  @override
  String get accountAboutLicence => 'Licence';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Source code';

  @override
  String get accountAboutSourceCopied => 'Source link copied';

  @override
  String get accountAboutBackend => 'Backend';

  @override
  String get accountDeleteIdentity => 'Delete identity';

  @override
  String get accountDeleteIdentitySubtitle => 'Erase this identity, history and progress from this device';

  @override
  String get accountDeleteDialogTitle => 'Delete this identity?';

  @override
  String get accountDeleteDialogBody => 'This removes your identity, chat history and training progress from this device. Without a backup it cannot be recovered. Type DELETE to confirm.';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => 'Type DELETE';

  @override
  String get accountDeleteButton => 'Delete';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return 'Backup file selected ($bytes bytes)';
  }

  @override
  String get chatSearchConversations => 'Search conversations';

  @override
  String get chatNoConversations => 'No conversations yet';

  @override
  String get chatNoSearchResults => 'No conversations match';

  @override
  String get chatPin => 'Pin';

  @override
  String get chatUnpin => 'Unpin';

  @override
  String get chatMarkRead => 'Mark as read';

  @override
  String get chatDelete => 'Delete';

  @override
  String get chatDeleteConversationTitle => 'Delete conversation?';

  @override
  String get chatDeleteConversationBody => 'Local history for this conversation is removed. Tox keeps no copy.';

  @override
  String get chatDraftPrefix => 'Draft: ';

  @override
  String get chatSelectConversation => 'Select a conversation';

  @override
  String get chatContacts => 'Contacts';

  @override
  String get chatNoMessages => 'No messages yet — send CQ to start.';

  @override
  String get chatTrainingMode => 'Training mode';

  @override
  String get chatTrainingModeOn => 'Training mode on: text hidden';

  @override
  String get chatTrainingModeOff => 'Training mode off';

  @override
  String get chatAutoPlay => 'Auto-play received Morse';

  @override
  String get chatAutoPlayOn => 'Auto-play on: new messages play as they arrive';

  @override
  String get chatAutoPlayOff => 'Auto-play off';

  @override
  String get chatReveal => 'Reveal';

  @override
  String get chatHiddenText => 'Listen first, then reveal';

  @override
  String get chatPlay => 'Play Morse';

  @override
  String get chatStop => 'Stop';

  @override
  String get chatPlaybackSettings => 'Playback settings';

  @override
  String get chatCharacterSpeed => 'Character speed';

  @override
  String get chatFarnsworthSpeed => 'Farnsworth speed';

  @override
  String get chatTone => 'Tone';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => 'Members';

  @override
  String get chatLeaveGroup => 'Leave group';

  @override
  String get chatLeaveGroupTitle => 'Leave this group?';

  @override
  String get chatLeaveGroupBody => 'You will stop receiving messages. Rejoin later with the chat id.';

  @override
  String get chatLeave => 'Leave';

  @override
  String get chatConferenceNote => 'Legacy conference: Morse keying metadata (v2) will not be available here. Text still works.';

  @override
  String get chatClearHistory => 'Clear history';

  @override
  String get chatModeStraightKey => 'Straight key';

  @override
  String get chatModePaddles => 'Paddles';

  @override
  String get chatKeyMessage => 'Key your message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatTooLong => 'Too long for one Tox message';

  @override
  String get chatKeyHint => 'Key on the pad or press Space';

  @override
  String get chatPaddleHint => 'Tap the paddles or hold Ctrl (left dit, right dah)';

  @override
  String get chatDeleteLast => 'Delete last character';

  @override
  String get chatNoFriends => 'No friends yet. Add one with their Tox ID.';

  @override
  String get chatNoRequests => 'No pending requests';

  @override
  String get chatAddFriend => 'Add friend';

  @override
  String get chatMyToxId => 'My Tox ID';

  @override
  String get chatToxIdLabel => 'Tox ID (76 hex characters)';

  @override
  String get chatToxIdInvalid => 'Tox ID must be exactly 76 hex characters';

  @override
  String get chatToxIdOwn => 'That is your own Tox ID';

  @override
  String get chatToxIdAlreadyFriend => 'Already in your friend list';

  @override
  String get chatRequestMessage => 'Message';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => 'Send request';

  @override
  String get chatRequestSent => 'Friend request sent';

  @override
  String get chatScanQr => 'Scan QR';

  @override
  String get chatScanQrDesktopHint => 'QR scanning needs a phone camera';

  @override
  String get chatScanQrTitle => 'Scan a Tox ID';

  @override
  String get chatScanQrNotToxId => 'That QR code is not a Tox ID';

  @override
  String get chatAccept => 'Accept';

  @override
  String get chatReject => 'Reject';

  @override
  String get chatCopied => 'Copied to clipboard';

  @override
  String get chatNoIdentity => 'No identity loaded';

  @override
  String get chatRemoveFriend => 'Remove friend';

  @override
  String get chatRemoveFriendTitle => 'Remove this friend?';

  @override
  String get chatRemoveFriendBody => 'They will no longer be able to message you.';

  @override
  String get chatRemove => 'Remove';

  @override
  String get chatNoGroups => 'No groups yet. Create one or join by chat id.';

  @override
  String get chatCreateGroup => 'Create group';

  @override
  String get chatJoinGroup => 'Join group';

  @override
  String get chatGroupName => 'Group name';

  @override
  String get chatGroupNameRequired => 'Give the group a name';

  @override
  String get chatAdvanced => 'Advanced';

  @override
  String get chatLegacyConference => 'Legacy conference (old clients)';

  @override
  String get chatLegacyConferenceHint => 'Not recommended: no persistent chat id, no Morse metadata.';

  @override
  String get chatCreate => 'Create';

  @override
  String get chatChatIdLabel => 'Chat id (64 hex characters)';

  @override
  String get chatChatIdInvalid => 'Chat id must be exactly 64 hex characters';

  @override
  String get chatPassword => 'Password (optional)';

  @override
  String get chatJoin => 'Join';

  @override
  String get chatJoinRequested => 'Joining — the group appears once a peer is found.';

  @override
  String get chatConferenceBadge => 'Conference';

  @override
  String get chatCopyChatId => 'Copy chat id';

  @override
  String get learnLessonCardTitle => 'Koch lesson';

  @override
  String get learnCourseComplete => 'Course complete - keep sharpening!';

  @override
  String get learnDailyGoalTitle => 'Today';

  @override
  String get learnDailyGoalMet => 'Daily goal reached';

  @override
  String get learnNoStreak => 'Start a streak today';

  @override
  String get learnContinueLesson => 'Continue lesson';

  @override
  String get learnReceivePractice => 'Receive practice';

  @override
  String get learnSendPractice => 'Send practice';

  @override
  String get learnReviewDue => 'Review due characters';

  @override
  String get learnSettings => 'Training settings';

  @override
  String get learnLoading => 'Loading your progress...';

  @override
  String get learnIdentityRequired => 'Create or unlock your identity to start training. Progress is stored with your identity so it travels with your backup.';

  @override
  String get learnLoadFailed => 'Your saved progress could not be read. Starting fresh; the old file was kept as .corrupt.';

  @override
  String get learnProgressSaveFailed => 'Couldn\'t save your progress. The result still counts while MorseCQ stays open.';

  @override
  String get learnChooseDrill => 'Choose a drill';

  @override
  String get learnDrillGroups => 'Random groups';

  @override
  String get learnDrillWords => 'Words';

  @override
  String get learnDrillCallsigns => 'Callsigns';

  @override
  String get learnDrillQso => 'QSO';

  @override
  String get learnDrillCharacters => 'Single characters';

  @override
  String get learnDrillAbbreviations => 'Abbreviations & Q-codes';

  @override
  String get learnDrillNumbers => 'Number groups';

  @override
  String get learnDrillConfusables => 'Look-alike characters';

  @override
  String get learnDrillContest => 'Contest exchanges';

  @override
  String get learnDrillGroupsHint => 'Random groups from every letter you know';

  @override
  String get learnDrillCharactersHint => 'One character at a time - name it instantly';

  @override
  String get learnDrillWordsHint => 'Common English words';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL - the shorthand of the air';

  @override
  String get learnDrillNumbersHint => 'Five-digit groups, as in traffic and serials';

  @override
  String get learnDrillCallsignsHint => 'Amateur callsigns from around the world';

  @override
  String get learnDrillConfusablesHint => 'Pairs you mix up, like S/H or U/V, side by side';

  @override
  String get learnDrillQsoHint => 'Lines from a full contact';

  @override
  String get learnDrillContestHint => 'Call, 5NN and a serial or zone, at contest pace';

  @override
  String get learnDrillReviewHint => 'Characters that are due for review';

  @override
  String get toolsTitle => 'Radio tools';

  @override
  String get toolsGridTitle => 'Grid locator';

  @override
  String get toolsGridHint => 'Locator from coordinates, distance and beam heading';

  @override
  String get toolsBandsTitle => 'Bands & antennas';

  @override
  String get toolsBandsHint => 'Which band a frequency is in, wavelength, dipole length';

  @override
  String get toolsSpeedTitle => 'CW speed';

  @override
  String get toolsSpeedHint => 'WPM to dit length, gaps and characters per minute';

  @override
  String get toolsRstTitle => 'RST report';

  @override
  String get toolsRstHint => 'Build a signal report and see what each digit means';

  @override
  String get toolsClockTitle => 'UTC clock';

  @override
  String get toolsClockHint => 'Log time in UTC, next to your local time';

  @override
  String get toolsGridFromCoordinates => 'From coordinates';

  @override
  String get toolsGridLatitude => 'Latitude';

  @override
  String get toolsGridLongitude => 'Longitude';

  @override
  String get toolsGridCoordinatesHelp => 'Decimal degrees; south and west are negative';

  @override
  String get toolsGridInvalidCoordinates => 'Latitude -90 to 90, longitude -180 to 180';

  @override
  String get toolsGridLocator => 'Locator';

  @override
  String get toolsGridDistanceSection => 'Distance and heading';

  @override
  String get toolsGridMine => 'My locator';

  @override
  String get toolsGridTheirs => 'Their locator';

  @override
  String get toolsGridInvalidLocator => 'Use 2, 4, 6 or 8 characters, e.g. OM89ex';

  @override
  String get toolsGridCenter => 'Square centre';

  @override
  String get toolsGridDistance => 'Distance';

  @override
  String get toolsGridShortPath => 'Short-path heading';

  @override
  String get toolsGridLongPath => 'Long-path heading';

  @override
  String get toolsBandsFrequency => 'Frequency (MHz)';

  @override
  String get toolsBandsInvalidFrequency => 'Enter a frequency above 0';

  @override
  String toolsBandsRegionLabel(int number) {
    return 'Region $number';
  }

  @override
  String get toolsBandsRegionHelp => '1: Europe, Africa, Middle East - 2: the Americas - 3: Asia-Pacific';

  @override
  String toolsBandsInBand(String band) {
    return 'In the $band amateur band';
  }

  @override
  String get toolsBandsOutOfBand => 'Outside the amateur bands';

  @override
  String get toolsBandsWavelength => 'Wavelength';

  @override
  String get toolsBandsDipole => 'Half-wave dipole (total)';

  @override
  String get toolsBandsQuarterWave => 'Quarter-wave vertical';

  @override
  String get toolsBandsAntennaNote => 'Lengths include a 0.95 end factor; trim to resonance.';

  @override
  String get toolsBandsTable => 'Band edges';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'ITU allocations. Your licence and national band plan may be narrower.';

  @override
  String get toolsSpeedCharacter => 'Character speed';

  @override
  String get toolsSpeedFarnsworth => 'Farnsworth spacing';

  @override
  String get toolsSpeedOverall => 'Overall speed';

  @override
  String get toolsSpeedDit => 'Dit';

  @override
  String get toolsSpeedDah => 'Dah';

  @override
  String get toolsSpeedCharGap => 'Gap between characters';

  @override
  String get toolsSpeedWordGap => 'Gap between words';

  @override
  String get toolsSpeedCpm => 'Characters per minute';

  @override
  String get toolsSpeedParis => 'One PARIS word';

  @override
  String get toolsRstReadability => 'Readability (R)';

  @override
  String get toolsRstStrength => 'Strength (S)';

  @override
  String get toolsRstTone => 'Tone (T)';

  @override
  String get toolsRstReport => 'Report';

  @override
  String get toolsRstCut => 'Contest form';

  @override
  String get toolsRstPhone => 'On voice (no tone)';

  @override
  String get toolsRstR1 => 'Unreadable';

  @override
  String get toolsRstR2 => 'Barely readable, occasional words';

  @override
  String get toolsRstR3 => 'Readable with considerable difficulty';

  @override
  String get toolsRstR4 => 'Readable with practically no difficulty';

  @override
  String get toolsRstR5 => 'Perfectly readable';

  @override
  String get toolsRstS1 => 'Faint, barely perceptible';

  @override
  String get toolsRstS2 => 'Very weak';

  @override
  String get toolsRstS3 => 'Weak';

  @override
  String get toolsRstS4 => 'Fair';

  @override
  String get toolsRstS5 => 'Fairly good';

  @override
  String get toolsRstS6 => 'Good';

  @override
  String get toolsRstS7 => 'Moderately strong';

  @override
  String get toolsRstS8 => 'Strong';

  @override
  String get toolsRstS9 => 'Extremely strong';

  @override
  String get toolsRstT1 => 'Very rough and broad, raw AC';

  @override
  String get toolsRstT2 => 'Very rough AC, harsh and broad';

  @override
  String get toolsRstT3 => 'Rough, rectified but not filtered';

  @override
  String get toolsRstT4 => 'Rough, some trace of filtering';

  @override
  String get toolsRstT5 => 'Filtered but strongly ripple-modulated';

  @override
  String get toolsRstT6 => 'Filtered, definite trace of ripple';

  @override
  String get toolsRstT7 => 'Near pure, trace of ripple';

  @override
  String get toolsRstT8 => 'Near perfect, slight trace of modulation';

  @override
  String get toolsRstT9 => 'Perfect tone, no ripple at all';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => 'Local time';

  @override
  String get toolsClockNote => 'Logs and QSL cards use UTC.';

  @override
  String get learnReceiveTitle => 'Receive';

  @override
  String get learnReviewTitle => 'Review';

  @override
  String get learnListen => 'Listen...';

  @override
  String get learnReady => 'Ready';

  @override
  String get learnReplay => 'Replay';

  @override
  String get learnAnswerHint => 'Type what you heard';

  @override
  String get learnSubmit => 'Check';

  @override
  String get learnNext => 'Next';

  @override
  String get learnFinish => 'Finish';

  @override
  String get learnDone => 'Done';

  @override
  String get learnBackspace => 'Delete';

  @override
  String get learnSpace => 'Space';

  @override
  String get learnSent => 'Sent';

  @override
  String get learnYourCopy => 'Your copy';

  @override
  String get learnRoundPerfect => 'Perfect copy!';

  @override
  String get learnSessionSummary => 'Session summary';

  @override
  String get learnLessonPassed => 'Lesson passed';

  @override
  String get learnLessonNotPassed => 'Keep at it: 90% unlocks the next one';

  @override
  String get learnReviewRecorded => 'Review recorded';

  @override
  String get learnWeakChars => 'Needs work';

  @override
  String get learnConfusions => 'Confused';

  @override
  String get learnNoFeedbackWarning => 'Sound, flash and haptics are all off - the screen will flash instead.';

  @override
  String get learnSendTitle => 'Send';

  @override
  String get learnSendThis => 'Send this';

  @override
  String get learnCopyFromMemory => 'From memory';

  @override
  String get learnHiddenTarget => 'Hidden - key it from memory';

  @override
  String get learnDecoded => 'Decoded';

  @override
  String get learnWaitingForKey => 'Start keying when ready';

  @override
  String get learnRestart => 'Restart';

  @override
  String get learnTryAnother => 'Try another';

  @override
  String get learnKeyerStraight => 'Straight';

  @override
  String get learnKeyerIambicA => 'Iambic A';

  @override
  String get learnKeyerIambicB => 'Iambic B';

  @override
  String get learnLegendStraight => 'Space = key';

  @override
  String get learnLegendPaddles => 'Left Ctrl = dit, Right Ctrl = dah';

  @override
  String get learnSendClean => 'Clean fist - nothing to fix.';

  @override
  String get learnSendIssues => 'Rhythm notes';

  @override
  String get learnYourSending => 'Decoded as';

  @override
  String get learnStraightKeyLabel => 'KEY';

  @override
  String get learnDitLabel => 'DIT';

  @override
  String get learnDahLabel => 'DAH';

  @override
  String get learnSettingsTitle => 'Training settings';

  @override
  String get learnCharacterSpeed => 'Character speed';

  @override
  String get learnFarnsworth => 'Farnsworth spacing';

  @override
  String get learnFarnsworthHelp => 'Characters stay fast; the gaps between them stretch to this speed.';

  @override
  String get learnEffectiveSpeed => 'Effective speed';

  @override
  String get learnTone => 'Tone';

  @override
  String get learnPlaySample => 'Play sample';

  @override
  String get learnSessionLength => 'Session length';

  @override
  String get learnFeedback => 'Feedback';

  @override
  String get learnSound => 'Sound';

  @override
  String get learnFlash => 'Screen flash';

  @override
  String get learnHaptic => 'Vibration';

  @override
  String get learnKeyer => 'Keyer';

  @override
  String get learnDailyGoal => 'Daily goal';

  @override
  String get referenceReferenceTitle => 'Morse reference';

  @override
  String get referenceTranslatorTitle => 'Translator';

  @override
  String get referencePlay => 'Play';

  @override
  String get referenceStop => 'Stop';

  @override
  String get referenceClear => 'Clear';

  @override
  String get referenceClose => 'Close';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => 'Search characters, prosigns, Q-codes…';

  @override
  String get referenceClearSearch => 'Clear search';

  @override
  String get referenceNoResults => 'Nothing matches your search.';

  @override
  String get referenceSectionAlphabet => 'Alphabet';

  @override
  String get referenceSectionPunctuation => 'Punctuation';

  @override
  String get referenceSectionProsigns => 'Prosigns';

  @override
  String get referenceSectionQCodes => 'Q-codes';

  @override
  String get referenceSectionAbbreviations => 'CW abbreviations';

  @override
  String get referenceSectionKoch => 'Koch order';

  @override
  String get referenceAlphabetHint => 'Tap a card to hear it. Long-press for a mnemonic.';

  @override
  String get referenceKochHint => 'The order the Koch method introduces characters (LCWO sequence). Start with K and M; add one when you copy at 90 %.';

  @override
  String get referenceMnemonicTitle => 'Mnemonic';

  @override
  String get referenceMeaningLabel => 'Meaning';

  @override
  String get referencePlaybackSettings => 'Playback settings';

  @override
  String get referenceCharacterSpeed => 'Character speed';

  @override
  String get referenceFarnsworth => 'Farnsworth spacing';

  @override
  String get referenceFarnsworthHelp => 'Characters stay at full speed; gaps stretch to the effective speed.';

  @override
  String get referenceEffectiveSpeed => 'Effective speed';

  @override
  String get referenceTone => 'Tone';

  @override
  String get referenceModeTextToMorse => 'Text → Morse';

  @override
  String get referenceModeMorseToText => 'Morse → Text';

  @override
  String get referenceModeKey => 'Key';

  @override
  String get referenceTextInputLabel => 'Text';

  @override
  String get referenceTextInputHint => 'Type text to encode…';

  @override
  String get referencePatternOutputLabel => 'Morse';

  @override
  String get referenceCopyPattern => 'Copy pattern';

  @override
  String get referencePatternCopied => 'Pattern copied';

  @override
  String get referencePatternInputLabel => 'Morse';

  @override
  String get referencePatternInputHint => 'Type . and -, a space between letters, / between words';

  @override
  String get referenceTextOutputLabel => 'Text';

  @override
  String get referenceCopyText => 'Copy text';

  @override
  String get referenceTextCopied => 'Text copied';

  @override
  String get referenceUnknownPatternHelp => 'Patterns with no character are shown as <pattern>.';

  @override
  String get referenceKeypadDit => 'Dit';

  @override
  String get referenceKeypadDah => 'Dah';

  @override
  String get referenceKeypadCharGap => 'Letter gap';

  @override
  String get referenceKeypadWordGap => 'Word gap';

  @override
  String get referenceKeypadBackspace => 'Backspace';

  @override
  String get referenceKeyHint => 'Press and hold the key to send. On a keyboard, hold Space.';

  @override
  String get referenceKeyLabel => 'KEY';

  @override
  String get referenceKeyDecodedLabel => 'Decoded';

  @override
  String get referenceKeyPendingLabel => 'Keying';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsLoading => 'Loading your statistics...';

  @override
  String get statsLoadFailed => 'Your progress could not be loaded. Pull down or reopen to retry.';

  @override
  String get statsRetry => 'Retry';

  @override
  String get statsEmptyTitle => 'No sessions yet';

  @override
  String get statsEmptyBody => 'Finish your first receive or send session and this page fills up with your accuracy trend, per-character strengths and a practice calendar.';

  @override
  String get statsEmptyCallToAction => 'Head to Learn and press \"Continue lesson\" to start.';

  @override
  String get statsOverviewTitle => 'Overview';

  @override
  String get statsTileLesson => 'Koch lesson';

  @override
  String get statsTileAccuracy => 'Accuracy';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => 'Practice';

  @override
  String get statsTileStreak => 'Streak';

  @override
  String get statsTileDailyGoal => 'Daily goal';

  @override
  String get statsGoalMet => 'Reached today';

  @override
  String get statsSummaryTitle => 'Your stats';

  @override
  String get statsSummaryOpen => 'View statistics';

  @override
  String get statsTrendTitle => 'Accuracy trend';

  @override
  String get statsTrendHint => 'Tap a point to inspect a session.';

  @override
  String get statsSeriesReceive => 'Receive';

  @override
  String get statsSeriesSend => 'Send';

  @override
  String get statsAxisSessions => 'Session';

  @override
  String get statsCharsTitle => 'Characters';

  @override
  String get statsCharsSubtitle => 'Koch order. Tap a character for detail.';

  @override
  String get statsCharsNotStarted => 'Not practised yet';

  @override
  String get statsNotInCourse => 'Not part of the Koch course';

  @override
  String get statsSrsTitle => 'Spaced repetition';

  @override
  String get statsSrsNotTracked => 'Not scheduled yet';

  @override
  String get statsSrsDueNow => 'Due now';

  @override
  String get statsConfusionsTitle => 'Most often confused with';

  @override
  String get statsConfusionsNone => 'No confusions recorded';

  @override
  String get statsConfusionMissed => 'missed';

  @override
  String get statsBucketLegendTitle => 'Accuracy';

  @override
  String get statsBucketNone => 'None';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => 'Confusions';

  @override
  String get statsHeatmapSubtitle => 'Rows are the sent character, columns what you answered. Darker means more often.';

  @override
  String get statsHeatmapEmpty => 'No confusions yet. Wrong answers will show up here.';

  @override
  String get statsHeatmapLegendLow => 'Rare';

  @override
  String get statsHeatmapLegendHigh => 'Frequent';

  @override
  String get statsHeatmapAxisTarget => 'Sent';

  @override
  String get statsHeatmapAxisAnswered => 'Answered';

  @override
  String get statsCalendarTitle => 'Practice calendar';

  @override
  String get statsCalendarSubtitle => 'Last 12 weeks';

  @override
  String get statsCalendarLegendLess => 'Less';

  @override
  String get statsCalendarLegendMore => 'More';

  @override
  String get statsStreakExplanation => 'A streak counts consecutive calendar days with at least one session. Skipping a whole day resets it; practising twice in a day counts once.';

  @override
  String get learnStatistics => 'Statistics';

  @override
  String get listenTitle => 'Listen';

  @override
  String get listenStart => 'Start';

  @override
  String get listenStop => 'Stop';

  @override
  String get listenStarting => 'Starting microphone...';

  @override
  String get listenClear => 'Clear text';

  @override
  String get listenCopy => 'Copy text';

  @override
  String get listenCopied => 'Decoded text copied';

  @override
  String get listenSettings => 'Listen settings';

  @override
  String get listenDecoded => 'Decoded';

  @override
  String get listenEmptyHint => 'Point the microphone at a Morse tone. Decoded text appears here.';

  @override
  String get listenIdleHint => 'Tap Start to listen for a Morse tone.';

  @override
  String get listenPending => 'Receiving';

  @override
  String get listenSpeed => 'Speed';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => 'Signal';

  @override
  String get listenToneOn => 'Tone';

  @override
  String get listenTone => 'Tone frequency';

  @override
  String get listenToneLocked => 'Locked';

  @override
  String get listenToneSearching => 'Searching';

  @override
  String get listenToneManual => 'Manual';

  @override
  String get listenAutoTune => 'Auto-tune';

  @override
  String get listenAutoTuneHelp => 'Follow the strongest tone between 400 and 1000 Hz. Drag the slider to tune by hand instead.';

  @override
  String get listenRetune => 'Auto';

  @override
  String get listenBlockSize => 'Analysis block';

  @override
  String get listenBlockSizeHelp => 'Smaller blocks place mark edges more precisely but pick up more noise. 256 samples (5.3 ms) suits 5-40 WPM.';

  @override
  String get listenMinElement => 'Shortest element';

  @override
  String get listenMinElementHelp => 'Tones and gaps shorter than this are ignored as clicks and dropouts.';

  @override
  String get listenPermissionDenied => 'Microphone access was denied. Allow it in the system settings, then try again.';

  @override
  String get listenPermissionRetry => 'Try again';

  @override
  String get listenStartFailed => 'Could not start the microphone.';

  @override
  String get listenNoInput => 'No microphone was found. Connect one and try again.';

  @override
  String get listenStreamFailed => 'The microphone stopped unexpectedly. Try again.';

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
    return '$samples samples ($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'Listening stopped while the app was in the background.';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => 'Dits too long';

  @override
  String get learnTipDahTooShortTitle => 'Dahs too short';

  @override
  String get learnTipIntraGapTooLongTitle => 'Elements spread out';

  @override
  String get learnTipCharGapTooShortTitle => 'Characters crowded';

  @override
  String get learnTipWordGapTooShortTitle => 'Words crowded';

  @override
  String get learnTipSpeedUnsteadyTitle => 'Speed unsteady';

  @override
  String get learnSeverityMinor => 'minor';

  @override
  String get learnSeverityModerate => 'noticeable';

  @override
  String get learnSeveritySevere => 'major';

  @override
  String get notificationOpen => 'Open';

  @override
  String get notificationChannelMessages => 'Messages';

  @override
  String get notificationChannelMessagesDescription => 'New Morse messages from friends and groups';

  @override
  String get notificationChannelFriendRequests => 'Friend requests';

  @override
  String get notificationChannelFriendRequestsDescription => 'Someone wants to add you as a friend';

  @override
  String get notificationChannelGroupInvites => 'Group invites';

  @override
  String get notificationChannelGroupInvitesDescription => 'A friend invited you to a group';

  @override
  String get notificationNewMessage => 'New message';

  @override
  String get notificationFriendRequestTitle => 'New friend request';

  @override
  String learnNewestCharIs(String char) {
    return 'New this lesson: $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, new';
  }

  @override
  String learnPendingPattern(String pattern) {
    return 'Keying: $pattern';
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
    return 'Your dits are running long (about $ratio of a dit). Think \'di\', not \'daah\' - a dit is a tap, not a press.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return 'Your dahs are short (about $ratio of a dit; aim for 3). Hold the dah for the length of three dits.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return 'Gaps inside characters are too wide (about $ratio of a dit). Keep the elements of one character tight together.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return 'Characters are running into each other (gaps about $ratio of a dit; aim for 3). Leave a clear pause after each character.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return 'Words are too close (gaps about $ratio of a dit; aim for 7). Count a long pause between words.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return 'Your speed wanders (variation $percent%). Settle on one tempo and hold it for the whole line.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$offending of $total dits too long (avg $ratio dit)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$offending of $total dahs too short (avg $ratio dit)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$offending of $total gaps inside characters too long (avg $ratio dit)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$offending of $total character gaps too short (avg $ratio dit)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$offending of $total word gaps too short (avg $ratio dit)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return 'keying speed unsteady (cv $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return 'last 7 days / $allTime all time';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get accountNewPasswordRequired => 'Enter a new password';

  @override
  String get accountToxIdQrSemantics => 'Tox ID QR code';

  @override
  String get accountBackupSaveDialogTitle => 'Save MorseCQ backup';

  @override
  String get accountBackupShareSubject => 'MorseCQ identity backup';

  @override
  String get accountBackupChooseDialogTitle => 'Choose MorseCQ backup';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '1 new message',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return 'Friend request from $name';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name: $message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return 'Invite to $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name invited you';
  }

  @override
  String desktopTrayShow(String app) {
    return 'Show $app';
  }

  @override
  String desktopTrayHide(String app) {
    return 'Hide $app';
  }

  @override
  String get desktopTraySoundOn => 'Sound on';

  @override
  String get desktopTraySoundOff => 'Sound off';

  @override
  String desktopTrayQuit(String app) {
    return 'Quit $app';
  }

  @override
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => 'On';

  @override
  String get listenStateOff => 'Off';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bytes left',
      one: '1 byte left',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return 'Friends ($count)';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return 'Friend requests ($count)';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return 'Group invites ($count)';
  }

  @override
  String chatMembersTitleCount(int count) {
    return 'Members · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return 'Invited by $name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name (You)';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label: $value $unit';
  }

  @override
  String referenceTelegraphCodes(String codes) {
    return 'Chinese telegraph code: $codes';
  }

  @override
  String get referenceTelegraphMainland => 'Mainland 1983';

  @override
  String get referenceTelegraphTaiwan => 'Taiwan / HK';

  @override
  String get referenceTelegraphNone => 'not in this codebook';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceStyles => 'Interface style';

  @override
  String get appearanceChoose => 'Choose a style, preview, then apply';

  @override
  String get appearanceMode => 'Brightness';

  @override
  String get appearancePreview => 'Preview';

  @override
  String get appearanceApply => 'Apply style';

  @override
  String get appearanceRestore => 'Restore defaults';

  @override
  String get appearanceApplied => 'Appearance saved';

  @override
  String get appearanceSaveFailed => 'Could not save appearance. Try again.';

  @override
  String get appearanceClassic => 'Classic Brass';

  @override
  String get appearanceModern => 'Modern Calm';

  @override
  String get appearanceRadio => 'Night Radio';

  @override
  String get appearancePaper => 'Paper Handbook';

  @override
  String get appearanceCartoon => 'Fresh Cartoon';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceSubtitle => 'Five styles with light and dark modes';

  @override
  String get chatClearHistoryBody => 'Delete this conversation’s history on this device? Copies on other devices are unaffected. This cannot be undone.';

  @override
  String get chatLoadEarlier => 'Load earlier messages';

  @override
  String get chatHistoryLoadFailed => 'Could not load earlier messages. Tap to retry.';

  @override
  String get chatRetryHistory => 'Retry';

  @override
  String chatNewMessages(int count) {
    return '$count new messages';
  }

  @override
  String learnShowAllChars(int count) {
    return 'Show all $count characters';
  }

  @override
  String get chatSelfMe => 'Me';

  @override
  String get chatSelfLocalOnly => 'Saved on this device only';

  @override
  String get chatSelfContactSubtitle => 'Drafts, practice and notes · never sent';

  @override
  String get learnShowFewerChars => 'Show fewer characters';

  @override
  String get learnLeaveDrillTitle => 'Leave this session?';

  @override
  String get learnLeaveDrillBody => 'The rounds you have done in this session will not be saved.';

  @override
  String get learnLeaveDrillConfirm => 'Leave';

  @override
  String get chatScanQrPermissionDenied => 'MorseCQ needs camera access to scan a QR code. Allow it in the system settings.';

  @override
  String get chatScanQrCameraUnavailable => 'The camera is not available on this device.';

  @override
  String get learnReplayAssistedNote => 'Replayed: this session counts as practice but won\'t unlock a lesson or update reviews.';

  @override
  String get learnPlanTitle => 'Today\'s plan';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return 'About $minutes min · $done of $total steps';
  }

  @override
  String get learnPlanBudget => 'Plan length';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learnPlanStart => 'Start plan';

  @override
  String get learnPlanContinue => 'Continue plan';

  @override
  String get learnPlanStepReview => 'Review due symbols';

  @override
  String get learnPlanStepFocus => 'Focused practice';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'Lesson $lesson';
  }

  @override
  String get learnPlanStepSend => 'Sending practice';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return 'Due for review: $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'Often mixed up: $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return 'Below 90%: $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count symbols: can unlock the next lesson';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return 'Lengthened to $count symbols so it can unlock the next lesson';
  }

  @override
  String get learnPlanReasonConsolidate => 'Short session: consolidates this lesson, cannot unlock the next';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'Your course moved on: practises lesson $lesson without unlocking';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '$count short targets to key';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return 'Done · $percent%';
  }

  @override
  String get learnPlanStepDone => 'Done';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$done of $total keyed';
  }

  @override
  String get learnPlanStale => 'Your lesson or speed changed. Update the steps you haven\'t started?';

  @override
  String get learnPlanUpdate => 'Update steps';

  @override
  String get learnPlanComplete => 'Plan complete for today';

  @override
  String learnPlanNeedsWork(String symbols) {
    return 'Needs work: $symbols';
  }

  @override
  String get learnPlanAllGood => 'No weak symbols today.';

  @override
  String get learnPlanTomorrow => 'A new plan arrives tomorrow. Free practice is always open.';

  @override
  String learnPlanNext(String step) {
    return 'Next: $step';
  }

  @override
  String learnPlanEarlier(int done, int total) {
    return 'Yesterday\'s plan stopped at $done of $total steps; it no longer counts for today.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return 'Ready for $wpm WPM effective speed';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return 'Ready for $wpm WPM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'Copying is hard at this speed. Try $wpm WPM effective, or a focused drill.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return 'Based on your last $count unassisted sessions ($percent%). Nothing changes until you apply it.';
  }

  @override
  String get learnSpeedAdviceApply => 'Apply';

  @override
  String get learnSpeedAdviceDismiss => 'Not now';

  @override
  String get learnSpeedAdviceInsufficient => 'Speed advice needs 3 unassisted sessions of 50+ symbols at your current speed.';

  @override
  String get learnQsoAction => 'QSO simulator';

  @override
  String learnQsoLocked(int lesson) {
    return 'From lesson $lesson';
  }

  @override
  String get learnQsoTitle => 'QSO simulator';

  @override
  String get learnQsoRespond => 'Answer a CQ';

  @override
  String get learnQsoRespondHint => 'A station calls CQ. Answer it and exchange reports.';

  @override
  String get learnQsoCall => 'Call CQ';

  @override
  String get learnQsoCallHint => 'You call CQ and a station answers.';

  @override
  String get learnQsoYourCall => 'Your callsign';

  @override
  String get learnQsoYourName => 'Your name';

  @override
  String get learnQsoYourQth => 'Your QTH';

  @override
  String get learnQsoInvalidCall => 'Enter a callsign such as BD1XYZ';

  @override
  String get learnQsoInvalidWord => 'One word, letters A–Z only';

  @override
  String get learnQsoOffline => 'Runs entirely on this device. Nothing is sent to anyone.';

  @override
  String get learnQsoStart => 'Start QSO';

  @override
  String get learnQsoResume => 'Resume the unfinished QSO';

  @override
  String get learnQsoStageCallCq => 'Call CQ with your callsign';

  @override
  String get learnQsoStageCallConfirm => 'Answer: their call, DE, your call';

  @override
  String get learnQsoStageExchange => 'Send report, name and QTH';

  @override
  String get learnQsoStageConfirmInfo => 'Confirm their information';

  @override
  String get learnQsoStageClosing => 'Close with 73 and <SK>';

  @override
  String get learnQsoStageDone => 'QSO complete';

  @override
  String learnQsoSpeed(int wpm) {
    return 'Remote sends at $wpm WPM effective';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call sends';
  }

  @override
  String get learnQsoRemoteHidden => 'Copy by ear — the text is hidden.';

  @override
  String get learnQsoShowText => 'Show text';

  @override
  String get learnQsoListen => 'Listen';

  @override
  String get learnQsoAccepted => 'Accepted';

  @override
  String get learnQsoRejected => 'Not accepted';

  @override
  String get learnQsoRemoteSending => 'The other station is sending…';

  @override
  String get learnQsoYourTurn => 'Your turn: key your reply, then Send.';

  @override
  String get learnQsoDecoded => 'Your transmission';

  @override
  String get learnQsoNothingKeyed => 'Nothing keyed yet';

  @override
  String get learnQsoPlayAgain => 'Ask to repeat (AGN)';

  @override
  String get learnQsoSlower => 'Ask to slow down (QRS)';

  @override
  String get learnQsoHint => 'Hint';

  @override
  String learnQsoHintLabel(String example) {
    return 'Example: $example';
  }

  @override
  String get learnQsoPause => 'Pause';

  @override
  String get learnQsoSend => 'Send';

  @override
  String get learnQsoClear => 'Clear';

  @override
  String get learnQsoIssueEmpty => 'Nothing was keyed.';

  @override
  String get learnQsoIssueMissingCq => 'Start with CQ.';

  @override
  String get learnQsoIssueMissingDe => 'Put DE between the callsigns.';

  @override
  String get learnQsoIssueWrongLocalCall => 'Your own callsign is missing or wrong.';

  @override
  String get learnQsoIssueWrongRemoteCall => 'The other station\'s callsign is wrong.';

  @override
  String get learnQsoIssueReversedCalls => 'Callsigns are reversed: theirs first, then DE and yours.';

  @override
  String get learnQsoIssueMissingEnding => 'End with K or KN.';

  @override
  String get learnQsoIssueMissingRst => 'Give a report, e.g. UR RST 599.';

  @override
  String get learnQsoIssueInvalidRst => 'That RST is out of range (R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'Send NAME and your name.';

  @override
  String get learnQsoIssueWrongName => 'That is not your name for this QSO.';

  @override
  String get learnQsoIssueMissingQth => 'Send QTH and your location.';

  @override
  String get learnQsoIssueWrongQth => 'That is not your QTH for this QSO.';

  @override
  String get learnQsoIssueMissingAck => 'Acknowledge with R or QSL.';

  @override
  String get learnQsoIssueWrongRemoteName => 'Confirm the other operator\'s name.';

  @override
  String get learnQsoIssueMissing73 => 'Include 73.';

  @override
  String get learnQsoIssueMissingSk => 'End the contact with <SK>.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return 'Right first time: $count of $total steps';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return 'Repeats: $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'Hints: $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'Your sending: about $wpm WPM';
  }

  @override
  String get learnQsoSummaryNote => 'QSO results are kept apart from copying accuracy and never unlock lessons.';

  @override
  String get messageStatusCancelled => 'Cancelled — never sent';

  @override
  String get chatMessageLearnActions => 'Message actions';

  @override
  String get chatPracticeMessage => 'Practice this message';

  @override
  String get chatSaveAsMaterial => 'Save as training material';

  @override
  String get chatSavedAsMaterial => 'Saved to My materials';

  @override
  String get chatSaveMaterialFailed => 'Couldn\'t save the material. Try again.';

  @override
  String get chatListenOnly => 'Listen-only training';

  @override
  String get chatListenOnlyHidden => 'Listen-only: tap play to hear it';

  @override
  String chatClearHistoryMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages from this chat were saved as training material. Those copies stay until you delete them in Learn › My materials.',
      one: '1 message from this chat was saved as training material. That copy stays until you delete it in Learn › My materials.',
    );
    return '$_temp0';
  }

  @override
  String get chatPracticeTitle => 'Copy practice';

  @override
  String chatPracticeUnsupported(String chars) {
    return 'This message contains characters Morse can\'t key: $chars. They will be left out.';
  }

  @override
  String chatPracticeTrainableCount(int count) {
    return '$count symbols can be practised.';
  }

  @override
  String get chatPracticeNothingTrainable => 'Nothing in this message can be practised in Morse.';

  @override
  String get chatPracticeConfirm => 'Practice the rest';

  @override
  String get chatPracticeHint => 'Hint';

  @override
  String chatPracticeHintShown(String symbols) {
    return 'Hint: $symbols …';
  }

  @override
  String get chatPracticeAssisted => 'Assisted: counts as practice, not for reviews or speed advice.';

  @override
  String chatPracticeErrors(int wrong, int missed, int extra) {
    return '$wrong wrong · $missed missed · $extra extra';
  }

  @override
  String chatPracticeErrorsAction(String symbols) {
    return 'Practice errors: $symbols';
  }

  @override
  String get learnTipDahTooLongTitle => 'Dahs too long';

  @override
  String learnTipDahTooLong(String ratio) {
    return 'Your dahs run long (about $ratio of a dit; aim for 3). Release as soon as three dits have passed.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$offending of $total dahs too long (avg $ratio dit)';
  }

  @override
  String get learnRhythmTitle => 'Rhythm';

  @override
  String get learnRhythmMine => 'My rhythm';

  @override
  String get learnRhythmStandard => 'Standard rhythm (target speed)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return 'Problems are judged against your own dit ($ms ms), so an even but slow fist is fine. The standard lane is the target speed.';
  }

  @override
  String get learnRhythmNotLocated => 'Your marks couldn\'t be matched to single symbols, so problems aren\'t pinned to letters. Practise the whole target instead.';

  @override
  String get learnRhythmPlayMine => 'Play mine';

  @override
  String get learnRhythmPlayStandard => 'Play standard';

  @override
  String learnRhythmPracticePart(int count) {
    return 'Practise this ($count tries)';
  }

  @override
  String get learnRhythmPracticeWhole => 'Practise the whole target';

  @override
  String get learnRhythmSymbolOk => 'Looks good';

  @override
  String get learnRhythmZoomIn => 'Zoom in';

  @override
  String get learnRhythmZoomOut => 'Zoom out';

  @override
  String get chatSearchMessages => 'Search messages';

  @override
  String get chatSearchHint => 'Search this conversation';

  @override
  String get chatSearchAnyone => 'Anyone';

  @override
  String get chatSearchMe => 'Me';

  @override
  String get chatSearchThem => 'Them';

  @override
  String get chatSearchAnyDate => 'Any date';

  @override
  String chatSearchDateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get chatSearchBookmarked => 'Bookmarked';

  @override
  String get chatSearchNoResults => 'No matching messages.';

  @override
  String get chatSearchMore => 'Load more';

  @override
  String get chatAddBookmark => 'Bookmark';

  @override
  String get chatRemoveBookmark => 'Remove bookmark';

  @override
  String get chatBookmarked => 'Bookmarked';

  @override
  String get chatBookmarkFailed => 'Couldn\'t save the bookmark.';

  @override
  String get chatRetrySend => 'Retry sending';

  @override
  String get chatCancelSend => 'Cancel sending';

  @override
  String get chatRetryQueued => 'Queued again. It will be sent when your contact is online.';

  @override
  String get chatSendCancelled => 'Cancelled. The message was never sent.';

  @override
  String get chatRetryNotNeeded => 'This message is no longer failed; nothing to retry.';

  @override
  String get chatCancelTooLate => 'Too late to cancel: the message was already handed to the network and may arrive.';

  @override
  String get chatSendControlUnavailable => 'Not available for this message.';

  @override
  String get chatSendControlFailed => 'That didn\'t work. The message keeps its current state; try again.';

  @override
  String get workbenchTitle => 'Recording workbench';

  @override
  String get workbenchOpen => 'Recordings';

  @override
  String get workbenchImport => 'Import recording';

  @override
  String get workbenchEmpty => 'Import a WAV recording to loop, decode and copy it. No microphone needed.';

  @override
  String get workbenchFormats => 'WAV, 16-bit PCM, mono or stereo, 8/16/44.1/48 kHz; up to 50 MB and 20 minutes.';

  @override
  String get workbenchBackupNote => 'Recordings stay on this device and are left out of identity backups unless you choose to include them when exporting a backup. Saved selections always back up their titles, notes and positions.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => 'mono';

  @override
  String get workbenchStereo => 'stereo';

  @override
  String get workbenchTruncated => 'The file ends early; only the audio present is used.';

  @override
  String get workbenchErrorNotWav => 'This is not a WAV file.';

  @override
  String get workbenchErrorFormat => 'Only 16-bit PCM WAV is supported for now (no MP3, AAC or float WAV).';

  @override
  String get workbenchErrorChannels => 'Only mono or stereo recordings are supported.';

  @override
  String get workbenchErrorRate => 'Sample rate not supported. Use 8, 16, 44.1 or 48 kHz.';

  @override
  String get workbenchErrorDamaged => 'The file is damaged or incomplete.';

  @override
  String get workbenchErrorTooLarge => 'The file is larger than 50 MB.';

  @override
  String get workbenchErrorTooLong => 'The recording is longer than 20 minutes.';

  @override
  String get workbenchErrorIo => 'Couldn\'t read the file.';

  @override
  String get workbenchErrorMissing => 'The recording file is missing.';

  @override
  String get workbenchStart => 'Start (s)';

  @override
  String get workbenchEnd => 'End (s)';

  @override
  String get workbenchSelectAll => 'Select all';

  @override
  String get workbenchPlay => 'Play selection';

  @override
  String get workbenchStop => 'Stop';

  @override
  String get workbenchLoop => 'Loop';

  @override
  String get workbenchPlayLimit => 'Only the first 5 minutes of a longer selection are played.';

  @override
  String get workbenchAutoTune => 'Find the tone automatically';

  @override
  String workbenchManualTone(int hz) {
    return 'Tone: $hz Hz';
  }

  @override
  String get workbenchDecode => 'Decode selection';

  @override
  String get workbenchCancel => 'Cancel';

  @override
  String workbenchDecoding(int percent) {
    return 'Decoding… $percent%';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'Tone $hz Hz · about $wpm WPM';
  }

  @override
  String get workbenchToneNotLocked => 'No steady tone found; try manual tuning.';

  @override
  String get workbenchNoText => 'Nothing decoded in this selection.';

  @override
  String workbenchUnknown(String patterns) {
    return 'Unknown patterns: $patterns';
  }

  @override
  String get workbenchEdgeCut => 'A symbol at the edge of the selection is cut off and may be wrong.';

  @override
  String get workbenchToneNote => 'Tone lock is not a confidence score; check the text by ear.';

  @override
  String get workbenchModeDecoder => 'Decoder';

  @override
  String get workbenchModeCopy => 'Copy it myself';

  @override
  String get workbenchDecoderHidden => 'Decoder text is hidden while you copy.';

  @override
  String get workbenchShowDecoder => 'Show decoder text';

  @override
  String get workbenchReference => 'Reference text (optional)';

  @override
  String get workbenchReferenceHelp => 'Paste the text that was sent; otherwise your copy is compared with the decoder output.';

  @override
  String get workbenchAgainstDecoder => 'Compared with the decoder output, which can itself be wrong.';

  @override
  String get workbenchSave => 'Save selection';

  @override
  String get workbenchSaveTitle => 'Title';

  @override
  String get workbenchSaveNote => 'Note';

  @override
  String get workbenchSaved => 'Selection saved';

  @override
  String get workbenchSaveFailed => 'Couldn\'t save the selection.';

  @override
  String get workbenchLibrary => 'Saved selections';

  @override
  String get workbenchLibraryEmpty => 'No saved selections yet.';

  @override
  String get workbenchMissing => 'Recording file missing — choose it again or delete the entry.';

  @override
  String get workbenchRelink => 'Choose the file again';

  @override
  String get workbenchDelete => 'Delete';

  @override
  String get materialsTitle => 'My materials';

  @override
  String get materialsNew => 'New material';

  @override
  String get materialsEdit => 'Edit';

  @override
  String get materialsSave => 'Save';

  @override
  String get materialsSaveFailed => 'Couldn\'t save the material.';

  @override
  String get materialsTitleField => 'Title';

  @override
  String get materialsTagsField => 'Tags (comma separated)';

  @override
  String get materialsTextField => 'Text';

  @override
  String get materialsListField => 'One entry per line';

  @override
  String get materialsKindText => 'Text';

  @override
  String get materialsKindWords => 'Word list';

  @override
  String get materialsKindCallsigns => 'Callsigns';

  @override
  String get materialsPreview => 'Preview';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items items · $symbols symbols · $prosigns prosigns';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'No Morse code, left out of practice: $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count duplicate entries are kept once';
  }

  @override
  String get materialsProblemEmpty => 'Enter some text first.';

  @override
  String get materialsProblemTooLarge => 'Too large: materials are limited to 1 MiB.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return 'Too many entries: at most $count.';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return 'An entry is too long: at most $count symbols each.';
  }

  @override
  String get materialsProblemNothingTrainable => 'Nothing here can be practised in Morse.';

  @override
  String get materialsSearch => 'Search materials';

  @override
  String get materialsFavoritesOnly => 'Favourites';

  @override
  String get materialsFavorite => 'Add to favourites';

  @override
  String get materialsUnfavorite => 'Remove from favourites';

  @override
  String get materialsEmpty => 'No materials yet. Add your own texts, word lists or callsigns, or save a chat message.';

  @override
  String materialsItems(int count) {
    return '$count items';
  }

  @override
  String get materialsFromChat => 'From chat';

  @override
  String get materialsActions => 'Material actions';

  @override
  String get materialsPractise => 'Practise';

  @override
  String get materialsDelete => 'Delete';

  @override
  String get materialsDeleteTitle => 'Delete material?';

  @override
  String materialsDeleteBody(String title) {
    return '“$title” will be removed from this device. Your practice history stays.';
  }

  @override
  String get materialsImport => 'Import TXT or JSON';

  @override
  String get materialsImportDialogTitle => 'Choose a material file';

  @override
  String get materialsSaveDialogTitle => 'Save material';

  @override
  String get materialsImportFailed => 'Import failed. Your library is unchanged.';

  @override
  String get materialsImportNotUtf8 => 'Only UTF-8 text files can be imported.';

  @override
  String get materialsImportInvalid => 'Not a valid MorseCQ material file. Nothing was imported.';

  @override
  String materialsImported(int count) {
    return 'Imported $count materials.';
  }

  @override
  String get materialsDuplicateTitle => 'Some materials already exist';

  @override
  String get materialsDuplicateOverwrite => 'Replace them';

  @override
  String get materialsDuplicateKeepCopy => 'Keep both (import as copies)';

  @override
  String get materialsDuplicateSkip => 'Skip them';

  @override
  String get materialsExportJson => 'Export as JSON';

  @override
  String materialsExported(int count) {
    return 'Exported $count materials.';
  }

  @override
  String get materialsExportFailed => 'Export failed.';

  @override
  String get materialsExportWav => 'Export audio (WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return 'Character speed: $wpm WPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return 'Effective speed: $wpm WPM';
  }

  @override
  String materialsWavTone(int hz) {
    return 'Tone: $hz Hz';
  }

  @override
  String get materialsWavWithAnswer => 'Include the answer text (.txt)';

  @override
  String get materialsWavFormat => '16-bit mono WAV, 48 kHz.';

  @override
  String materialsWavParts(int count) {
    return 'Longer than 10 minutes: exported as $count files.';
  }

  @override
  String materialsWavExported(int count) {
    return 'Saved $count audio files.';
  }

  @override
  String get materialsPracticeMode => 'Practise with';

  @override
  String get materialsPracticeLearned => 'Learned symbols only';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return 'Learned symbols only ($count entries unavailable: they use symbols not learned yet)';
  }

  @override
  String get materialsPracticeAll => 'All Morse symbols';

  @override
  String get materialsPracticeNothing => 'No entries can be practised in this mode.';

  @override
  String get guestTryLearning => 'Try learning first';

  @override
  String get guestBanner => 'Guest learning: progress stays on this device. Chat needs an identity.';

  @override
  String get guestGetIdentity => 'Set up identity';

  @override
  String get guestIdentityTitle => 'Identity needed';

  @override
  String get guestIdentityBody => 'Chatting over Tox needs your own identity. Create a new one, restore a backup, or unlock the one on this device. Your guest learning progress moves to a new identity automatically.';

  @override
  String get guestClearData => 'Clear guest learning data';

  @override
  String get guestClearDataBody => 'Deletes the progress, plans and materials you made as a guest on this device. Identities are not affected.';

  @override
  String get guestClearConfirm => 'Clear';

  @override
  String get guestCleared => 'Guest learning data cleared.';

  @override
  String get guestClearFailed => 'Couldn\'t clear the guest data.';

  @override
  String get guestMigrationFailed => 'Your identity is ready, but your guest learning progress hasn\'t moved to it yet. It is safe on this device.';

  @override
  String get guestChoiceBody => 'You also have guest learning progress. The restored identity\'s progress is in use; nothing was merged.';

  @override
  String get guestChoiceKeep => 'Keep restored';

  @override
  String get guestChoiceUseGuest => 'Use guest progress';

  @override
  String get placementTitle => 'Check my level';

  @override
  String get placementCheckLevel => 'Check my current level';

  @override
  String get placementFromZero => 'Start from zero';

  @override
  String get placementOfferTitle => 'New to Morse, or already copying?';

  @override
  String get placementOfferBody => 'A short check can suggest where to start. It is optional and changes nothing until you choose.';

  @override
  String get placementIntro => 'About 3–5 minutes of copying in five steps: Koch symbols in groups at rising speed, then short words. It is a rough guide from a small sample, not a certificate. Stop whenever you like.';

  @override
  String get placementStart => 'Start';

  @override
  String get placementSkip => 'Skip';

  @override
  String get placementStop => 'Stop';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return 'Step $step of $total · $wpm WPM effective';
  }

  @override
  String get placementTierPassed => 'Well copied. Next step is faster.';

  @override
  String get placementTierStopped => 'That step was below 90%, so the check ends here.';

  @override
  String get placementNextTier => 'Next step';

  @override
  String placementSuggestion(int lesson) {
    return 'Suggested start: lesson $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return '$count of $total Koch symbols confirmed in order.';
  }

  @override
  String get placementLimits => 'Based on a short sample: symbols you were not tested on stay untested, and nothing is marked as learned. You can change the lesson any time.';

  @override
  String placementAdopt(int lesson) {
    return 'Start at lesson $lesson';
  }

  @override
  String get chatJumpToLatest => 'Latest messages';

  @override
  String get chatMessageGone => 'That message is no longer in this conversation.';

  @override
  String get chatListenOnlyPreview => 'New message — listen to copy it';

  @override
  String get chatSaveMaterialConfirm => 'Save the rest';

  @override
  String materialsImportConfirm(int count) {
    return 'Import $count materials?';
  }

  @override
  String get materialsExportTxt => 'Export as text (TXT)';

  @override
  String get accountBackupMediaTitle => 'Include saved recordings?';

  @override
  String accountBackupMediaBody(int count, String size) {
    return '$count saved recordings ($size MB). Their titles, notes and positions are always in the backup; the audio only if you include it.';
  }

  @override
  String accountBackupMediaTooLarge(String size) {
    return 'Saved recordings ($size MB) are too large to put in a backup; only their titles, notes and positions are included.';
  }

  @override
  String get accountBackupMediaInclude => 'Include recordings';

  @override
  String get accountBackupMediaSkip => 'Without recordings';
}
