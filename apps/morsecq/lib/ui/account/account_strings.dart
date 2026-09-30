/// English UI strings for the identity / account surfaces. Kept as consts in
/// one place so a later l10n pass (ARB extraction) only has to touch this
/// file and the call sites, not the widget logic.
abstract final class AccountStrings {
  // ---- Shared ---------------------------------------------------------------
  static const appName = 'morsecq';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const retry = 'Retry';
  static const continueLabel = 'Continue';
  static const back = 'Back';
  static const copy = 'Copy';
  static const copied = 'Tox ID copied to clipboard';
  static const showQr = 'Show QR code';
  static const toxId = 'Tox ID';
  static const displayName = 'Display name';
  static const displayNameHint = 'Your callsign or nickname';
  static const displayNameRequired = 'Enter a display name';
  static const statusMessage = 'Status message';
  static const password = 'Password';
  static const passwordOptional = 'Password (optional)';
  static const confirmPassword = 'Confirm password';
  static const passwordsDoNotMatch = 'Passwords do not match';
  static const wrongPassword = 'Wrong password. Try again.';
  static const showPassword = 'Show password';
  static const hidePassword = 'Hide password';
  static const genericError = 'Something went wrong';

  static const strengthWeak = 'Weak: use at least 8 characters';
  static const strengthFair = 'Fair: 12+ characters with mixed types is better';
  static const strengthStrong = 'Strong';

  // ---- Startup --------------------------------------------------------------
  static const startupInspecting = 'Checking your identity…';
  static const startupOpening = 'Opening your identity…';
  static const startupFailedTitle = 'Could not start';
  static const startupFailedBody =
      'morsecq could not read your identity. Nothing was changed; '
      'you can try again.';

  static const connectionConnecting = 'Connecting…';
  static const connectionOffline = 'Offline';
  static const connectionOnline = 'Online';
  static const connectionTapToReconnect = 'Tap to reconnect';

  // ---- Welcome --------------------------------------------------------------
  static const welcomeTitle = 'Your identity lives on this device';
  static const welcomeIntro =
      'morsecq uses the Tox peer-to-peer network. There is no server and no '
      'account to sign up for: your identity is a key pair stored only here.';
  static const welcomePointNoServer =
      'No server, no phone number, no e-mail. Peers talk to each other '
      'directly, in Morse.';
  static const welcomePointTraining =
      'Training progress is saved with your identity, so it can be backed up '
      'and moved between devices.';
  static const welcomePointBackup =
      'Nobody can recover an identity for you. Back it up right after '
      'creating it, or you will lose it with the device.';
  static const createIdentity = 'Create identity';
  static const restoreFromBackup = 'Restore from backup';

  // ---- Create ---------------------------------------------------------------
  static const createTitle = 'Create your identity';
  static const createBody =
      'Pick a name others will see. A password encrypts the identity file on '
      'this device; leave it empty if you prefer to open the app without one.';
  static const createButton = 'Create';
  static const creating = 'Creating…';

  // ---- Backup wizard --------------------------------------------------------
  static const backupTitle = 'Back up your identity now';
  static const backupBody =
      'Your identity exists only on this device. If it is lost, reset or '
      'stolen, there is no way to recover it: your contacts will not '
      'recognise a new identity and your training progress is gone.';
  static const backupWhatIsInside =
      'The backup file contains your encrypted identity and your training '
      'progress. Keep it somewhere safe, outside this device.';
  static const backupSaveFile = 'Save backup file';
  static const backupShareFile = 'Share backup file';
  static const backupSaved = 'Backup saved';
  static const backupNotSaved = 'Backup was not saved';
  static const backupFailed = 'Could not write the backup';
  static const backupAcknowledge =
      'I understand that without this backup my identity cannot be recovered.';
  static const backupContinue = 'Continue to morsecq';
  static const backupShowQrHint =
      'Your Tox ID is how friends add you. Share it as text or as a QR code.';

  // ---- Restore --------------------------------------------------------------
  static const restoreTitle = 'Restore from backup';
  static const restoreBody =
      'Choose a backup file exported from morsecq. If the identity was '
      'protected with a password you will need it here.';
  static const restoreChooseFile = 'Choose backup file';
  static const restoreFileChosen = 'Backup file selected';
  static const restoreNoFile = 'Choose a backup file first';
  static const restoreButton = 'Restore';
  static const restoring = 'Restoring…';
  static const restoreInvalidFile = 'This file is not a morsecq backup.';
  static const restoreReplacesWarning =
      'Restoring replaces the identity currently on this device.';

  // ---- Unlock ---------------------------------------------------------------
  static const unlockTitle = 'Unlock your identity';
  static const unlockBody =
      'Your identity file is encrypted. Enter the password to continue.';
  static const unlockButton = 'Unlock';
  static const unlocking = 'Unlocking…';
  static const unlockRestoreInstead = 'Restore from backup instead';

  // ---- Me page --------------------------------------------------------------
  static const meTitle = 'Me';
  static const meNoIdentity = 'No identity loaded';
  static const sectionAccount = 'Account';
  static const sectionTraining = 'Training';
  static const sectionAbout = 'About';
  static const sectionDanger = 'Danger zone';
  static const editProfile = 'Edit profile';
  static const editProfileBody = 'Shown to your contacts on the Tox network.';
  static const setPassword = 'Set password';
  static const changePassword = 'Change password';
  static const removePassword = 'Remove password';
  static const currentPassword = 'Current password';
  static const newPassword = 'New password';
  static const passwordUpdated = 'Password updated';
  static const passwordRemoved = 'Password removed';
  static const profileUpdated = 'Profile updated';
  static const exportBackup = 'Export backup';
  static const exportBackupSubtitle =
      'Save your identity and training progress to a file';
  static const trainingDefaults = 'Playback & training defaults';
  static const trainingDefaultsSubtitle = 'Speed, tone, Farnsworth spacing';
  static const trainingDefaultsPlaceholder =
      'Speed, tone and Farnsworth defaults will live here.';
  static const aboutLicence = 'Licence';
  static const aboutLicenceValue = 'GPL-3.0';
  static const aboutSource = 'Source code';
  static const aboutSourceUrl = 'https://github.com/agentx-icu/morsecq';
  static const aboutSourceCopied = 'Source link copied';
  static const aboutBackend = 'Backend';
  static const deleteIdentity = 'Delete identity';
  static const deleteIdentitySubtitle =
      'Erase this identity, history and progress from this device';
  static const deleteDialogTitle = 'Delete this identity?';
  static const deleteDialogBody =
      'This removes your identity, chat history and training progress from '
      'this device. Without a backup it cannot be recovered. Type DELETE to '
      'confirm.';
  static const deleteConfirmWord = 'DELETE';
  static const deleteConfirmHint = 'Type DELETE';
  static const deleteButton = 'Delete';

  /// Route name of the training-defaults page (filled in by the learn UI).
  static const trainingSettingsRoute = '/settings/training';
}
