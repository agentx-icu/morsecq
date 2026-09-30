/// User-facing strings for the chat / contacts / groups UI.
///
/// English only for now; kept in one place so a real l10n pass (ARB files
/// under `lib/l10n/`) can replace this class without touching widgets.
abstract final class ChatStrings {
  // Conversations
  static const String chatTitle = 'Chat';
  static const String searchConversations = 'Search conversations';
  static const String noConversations = 'No conversations yet';
  static const String noSearchResults = 'No conversations match';
  static const String pin = 'Pin';
  static const String unpin = 'Unpin';
  static const String markRead = 'Mark as read';
  static const String delete = 'Delete';
  static const String deleteConversationTitle = 'Delete conversation?';
  static const String deleteConversationBody =
      'Local history for this conversation is removed. Tox keeps no copy.';
  static const String cancel = 'Cancel';
  static const String draftPrefix = 'Draft: ';
  static const String selectConversation = 'Select a conversation';
  static const String contacts = 'Contacts';
  static const String backendUnavailable = 'Chat backend is not connected.';

  // Conversation screen
  static const String noMessages = 'No messages yet — send CQ to start.';
  static const String trainingMode = 'Training mode';
  static const String trainingModeOn = 'Training mode on: text hidden';
  static const String trainingModeOff = 'Training mode off';
  static const String reveal = 'Reveal';
  static const String hiddenText = 'Listen first, then reveal';
  static const String play = 'Play Morse';
  static const String stop = 'Stop';
  static const String playbackSettings = 'Playback settings';
  static const String characterSpeed = 'Character speed';
  static const String farnsworthSpeed = 'Farnsworth speed';
  static const String tone = 'Tone';
  static const String wpm = 'WPM';
  static const String hz = 'Hz';
  static const String statusPending = 'Queued — peer is offline';
  static const String statusPendingDetail =
      'Tox has no server: the message is delivered when the peer comes online.';
  static const String statusSending = 'Sending';
  static const String statusSent = 'Sent';
  static const String statusFailed = 'Failed to send';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String members = 'Members';
  static const String leaveGroup = 'Leave group';
  static const String leaveGroupTitle = 'Leave this group?';
  static const String leaveGroupBody =
      'You will stop receiving messages. Rejoin later with the chat id.';
  static const String leave = 'Leave';
  static const String conferenceNote =
      'Legacy conference: Morse keying metadata (v2) will not be available '
      'here. Text still works.';
  static const String clearHistory = 'Clear history';

  // Input area
  static const String modeKeyboard = 'Keyboard';
  static const String modeStraightKey = 'Straight key';
  static const String modePaddles = 'Paddles';
  static const String typeMessage = 'Type a message';
  static const String send = 'Send';
  static const String bytesLeft = 'bytes left';
  static const String tooLong = 'Too long for one Tox message';
  static const String keyHint = 'Key on the pad or press Space';
  static const String paddleHint =
      'Tap the paddles or hold Ctrl (left dit, right dah)';
  static const String clearDraft = 'Clear draft';
  static const String deleteLast = 'Delete last character';
  static const String decodedPreview = 'Decoded';

  // Contacts
  static const String friends = 'Friends';
  static const String friendRequests = 'Friend requests';
  static const String noFriends = 'No friends yet. Add one with their Tox ID.';
  static const String noRequests = 'No pending requests';
  static const String addFriend = 'Add friend';
  static const String myToxId = 'My Tox ID';
  static const String toxIdLabel = 'Tox ID (76 hex characters)';
  static const String toxIdInvalid = 'Tox ID must be exactly 76 hex characters';
  static const String toxIdOwn = 'That is your own Tox ID';
  static const String toxIdAlreadyFriend = 'Already in your friend list';
  static const String requestMessage = 'Message';
  static const String defaultRequestMessage = 'morsecq CQ';
  static const String sendRequest = 'Send request';
  static const String requestSent = 'Friend request sent';
  static const String scanQr = 'Scan QR';
  static const String scanQrDesktopHint = 'QR scanning needs a phone camera';
  static const String scanQrTitle = 'Scan a Tox ID';
  static const String scanQrNotToxId = 'That QR code is not a Tox ID';
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String copy = 'Copy';
  static const String copied = 'Copied to clipboard';
  static const String noIdentity = 'No identity loaded';
  static const String removeFriend = 'Remove friend';
  static const String removeFriendTitle = 'Remove this friend?';
  static const String removeFriendBody =
      'They will no longer be able to message you.';
  static const String remove = 'Remove';

  // Groups
  static const String groupsTitle = 'Groups';
  static const String noGroups =
      'No groups yet. Create one or join by chat id.';
  static const String createGroup = 'Create group';
  static const String joinGroup = 'Join group';
  static const String groupName = 'Group name';
  static const String groupNameRequired = 'Give the group a name';
  static const String advanced = 'Advanced';
  static const String legacyConference = 'Legacy conference (old clients)';
  static const String legacyConferenceHint =
      'Not recommended: no persistent chat id, no Morse metadata.';
  static const String create = 'Create';
  static const String chatIdLabel = 'Chat id (64 hex characters)';
  static const String chatIdInvalid =
      'Chat id must be exactly 64 hex characters';
  static const String password = 'Password (optional)';
  static const String join = 'Join';
  static const String joinRequested =
      'Joining — the group appears once a peer is found.';
  static const String groupInvites = 'Group invites';
  static const String noInvites = 'No pending invites';
  static const String invitedBy = 'Invited by';
  static const String membersCount = 'members';
  static const String conferenceBadge = 'Conference';
  static const String copyChatId = 'Copy chat id';
  static const String you = 'You';
  static const String error = 'Something went wrong';
}
