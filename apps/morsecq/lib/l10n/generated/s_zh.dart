// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'morsecq';

  @override
  String get navLearn => '学习';

  @override
  String get navChat => '聊天';

  @override
  String get navGroups => '群组';

  @override
  String get navMe => '我';

  @override
  String get actionOk => '确定';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionCopy => '复制';

  @override
  String get actionShare => '分享';

  @override
  String get actionRetry => '重试';

  @override
  String get actionClose => '关闭';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionSettings => '设置';

  @override
  String get connectionConnecting => '连接中…';

  @override
  String get connectionOnline => '在线';

  @override
  String get connectionOffline => '离线';

  @override
  String get messageStatusPending => '已排队 — 对方离线';

  @override
  String get messageStatusPendingDetail => 'Tox 没有服务器：消息会在对方上线后送达。';

  @override
  String get messageStatusSending => '发送中';

  @override
  String get messageStatusSent => '已发送';

  @override
  String get messageStatusDelivered => '已送达';

  @override
  String get messageStatusFailed => '发送失败';

  @override
  String get errorWrongPassword => '密码错误，请重试。';

  @override
  String get errorPeerOffline => '该联系人离线。Tox 没有服务器，消息会等到对方上线后再送达。';

  @override
  String get errorInvalidToxId => '这不是有效的 Tox ID（应为 76 位十六进制字符）。';

  @override
  String get errorAlreadyFriend => '这个 Tox ID 已在你的好友列表中。';

  @override
  String get errorOwnId => '这是你自己的 Tox ID。';

  @override
  String get errorGroupNotFound => '未找到该群组。';

  @override
  String get errorMessageTooLong => '消息超出单条 Tox 消息的长度上限。';

  @override
  String get errorUnknown => '出了点问题';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String learnLessonOf(int lesson, int total) {
    return '第 $lesson 课 / 共 $total 课';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已学 $count 个字符',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal 字符';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '连续练习 $days 天',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个待复习',
      zero: '暂无待复习',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$total 个中抄对 $correct 个';
  }

  @override
  String learnRoundOf(int round) {
    return '第 $round 轮';
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
      other: '已发 $count 个字符',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return '已解锁新字符：$char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target 漏抄';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target 听成了 $answered';
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
      other: '$count 个字符',
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
      other: '已学 $count 个字符',
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
      other: '抄收 $count 个字符',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次练习',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最长连续 $count 天',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal 字符';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '还差 $remaining 个字符',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最近 $count 次练习',
      one: '最近一次练习',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return '第 $index 次练习 / 共 $total 次';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total 正确';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return '第 $lesson 课';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次尝试',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$attempts 次中对 $correct 次';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return '在第 $lesson 课引入';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return '第 $box 盒 / 共 $maxBox 盒';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天后到期',
      one: '明天到期',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
    );
    return '$target 被答成 $answered，$_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars 个字符',
      zero: '未练习',
    );
    return '$date：$_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个活跃日',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条',
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
    return '已跳过（无莫尔斯电码）：$chars';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return '估计 $wpm WPM';
  }

  @override
  String get accountAppName => 'morsecq';

  @override
  String get accountCancel => '取消';

  @override
  String get accountSave => '保存';

  @override
  String get accountRetry => '重试';

  @override
  String get accountContinueLabel => '继续';

  @override
  String get accountBack => '返回';

  @override
  String get accountCopy => '复制';

  @override
  String get accountCopied => 'Tox ID 已复制到剪贴板';

  @override
  String get accountShowQr => '显示二维码';

  @override
  String get accountToxId => 'Tox ID';

  @override
  String get accountDisplayName => '显示名称';

  @override
  String get accountDisplayNameHint => '你的呼号或昵称';

  @override
  String get accountDisplayNameRequired => '请输入显示名称';

  @override
  String get accountStatusMessage => '状态消息';

  @override
  String get accountPassword => '密码';

  @override
  String get accountPasswordOptional => '密码（可选）';

  @override
  String get accountConfirmPassword => '确认密码';

  @override
  String get accountPasswordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get accountWrongPassword => '密码错误，请重试。';

  @override
  String get accountShowPassword => '显示密码';

  @override
  String get accountHidePassword => '隐藏密码';

  @override
  String get accountGenericError => '出了点问题';

  @override
  String get accountStrengthWeak => '弱：至少使用 8 个字符';

  @override
  String get accountStrengthFair => '一般：12 个以上字符并混合多种类型更好';

  @override
  String get accountStrengthStrong => '强';

  @override
  String get accountStartupInspecting => '正在检查你的身份…';

  @override
  String get accountStartupOpening => '正在打开你的身份…';

  @override
  String get accountStartupFailedTitle => '无法启动';

  @override
  String get accountStartupFailedBody => 'morsecq 无法读取你的身份。没有做任何更改；你可以重试。';

  @override
  String get accountConnectionConnecting => '连接中…';

  @override
  String get accountConnectionOffline => '离线';

  @override
  String get accountConnectionOnline => '在线';

  @override
  String get accountConnectionTapToReconnect => '点按重新连接';

  @override
  String get accountWelcomeTitle => '你的身份只保存在这台设备上';

  @override
  String get accountWelcomeIntro => 'morsecq 使用 Tox 点对点网络。没有服务器，也无需注册账号：你的身份是一对只保存在本机的密钥。';

  @override
  String get accountWelcomePointNoServer => '没有服务器，不需要手机号或电子邮件。报务员之间直接用莫尔斯电码通联。';

  @override
  String get accountWelcomePointTraining => '训练进度随身份一起保存，因此可以备份并在设备间迁移。';

  @override
  String get accountWelcomePointBackup => '没有人能为你找回身份。创建后请立即备份，否则设备丢失时身份也会一起丢失。';

  @override
  String get accountCreateIdentity => '创建身份';

  @override
  String get accountRestoreFromBackup => '从备份恢复';

  @override
  String get accountCreateTitle => '创建你的身份';

  @override
  String get accountCreateBody => '取一个别人能看到的名字。密码用于加密本机上的身份文件；如果你希望不输密码就能打开应用，可以留空。';

  @override
  String get accountCreateButton => '创建';

  @override
  String get accountCreating => '创建中…';

  @override
  String get accountBackupTitle => '现在就备份你的身份';

  @override
  String get accountBackupBody => '你的身份只存在于这台设备上。如果设备丢失、重置或被盗，将无法找回：联系人不会认出新的身份，训练进度也会丢失。';

  @override
  String get accountBackupWhatIsInside => '备份文件包含加密后的身份和你的训练进度。请把它保存在本机以外的安全位置。';

  @override
  String get accountBackupSaveFile => '保存备份文件';

  @override
  String get accountBackupShareFile => '分享备份文件';

  @override
  String get accountBackupSaved => '备份已保存';

  @override
  String get accountBackupNotSaved => '备份未保存';

  @override
  String get accountBackupFailed => '无法写入备份';

  @override
  String get accountBackupAcknowledge => '我了解：没有这份备份，我的身份将无法找回。';

  @override
  String get accountBackupContinue => '进入 morsecq';

  @override
  String get accountBackupShowQrHint => '朋友通过你的 Tox ID 添加你。可以以文本或二维码的形式分享。';

  @override
  String get accountRestoreTitle => '从备份恢复';

  @override
  String get accountRestoreBody => '选择一个由 morsecq 导出的备份文件。如果该身份设置了密码，这里需要输入。';

  @override
  String get accountRestoreChooseFile => '选择备份文件';

  @override
  String get accountRestoreFileChosen => '已选择备份文件';

  @override
  String get accountRestoreNoFile => '请先选择备份文件';

  @override
  String get accountRestoreButton => '恢复';

  @override
  String get accountRestoring => '恢复中…';

  @override
  String get accountRestoreInvalidFile => '这个文件不是 morsecq 备份。';

  @override
  String get accountRestoreReplacesWarning => '恢复将替换当前设备上的身份。';

  @override
  String get accountUnlockTitle => '解锁你的身份';

  @override
  String get accountUnlockBody => '你的身份文件已加密。请输入密码继续。';

  @override
  String get accountUnlockButton => '解锁';

  @override
  String get accountUnlocking => '解锁中…';

  @override
  String get accountUnlockRestoreInstead => '改为从备份恢复';

  @override
  String get accountMeTitle => '我';

  @override
  String get accountMeNoIdentity => '未加载身份';

  @override
  String get accountSectionAccount => '账户';

  @override
  String get accountSectionTraining => '训练';

  @override
  String get accountSectionAbout => '关于';

  @override
  String get accountSectionDanger => '危险操作';

  @override
  String get accountEditProfile => '编辑资料';

  @override
  String get accountEditProfileBody => '会显示给 Tox 网络上的联系人。';

  @override
  String get accountSetPassword => '设置密码';

  @override
  String get accountChangePassword => '修改密码';

  @override
  String get accountRemovePassword => '移除密码';

  @override
  String get accountCurrentPassword => '当前密码';

  @override
  String get accountNewPassword => '新密码';

  @override
  String get accountPasswordUpdated => '密码已更新';

  @override
  String get accountPasswordRemoved => '密码已移除';

  @override
  String get accountProfileUpdated => '资料已更新';

  @override
  String get accountExportBackup => '导出备份';

  @override
  String get accountExportBackupSubtitle => '把你的身份和训练进度保存到文件';

  @override
  String get accountTrainingDefaults => '播放与训练默认值';

  @override
  String get accountTrainingDefaultsSubtitle => '速度、音调、Farnsworth 间距';

  @override
  String get accountTrainingDefaultsPlaceholder => '速度、音调和 Farnsworth 默认值将放在这里。';

  @override
  String get accountAboutLicence => '许可证';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => '源代码';

  @override
  String get accountAboutSourceCopied => '源代码链接已复制';

  @override
  String get accountAboutBackend => '后端';

  @override
  String get accountDeleteIdentity => '删除身份';

  @override
  String get accountDeleteIdentitySubtitle => '从本机抹除这个身份、聊天记录和训练进度';

  @override
  String get accountDeleteDialogTitle => '删除这个身份？';

  @override
  String get accountDeleteDialogBody => '这会从本机删除你的身份、聊天记录和训练进度。没有备份将无法找回。输入 DELETE 以确认。';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => '输入 DELETE';

  @override
  String get accountDeleteButton => '删除';

  @override
  String get chatChatTitle => '聊天';

  @override
  String get chatSearchConversations => '搜索会话';

  @override
  String get chatNoConversations => '还没有会话';

  @override
  String get chatNoSearchResults => '没有匹配的会话';

  @override
  String get chatPin => '置顶';

  @override
  String get chatUnpin => '取消置顶';

  @override
  String get chatMarkRead => '标为已读';

  @override
  String get chatDelete => '删除';

  @override
  String get chatDeleteConversationTitle => '删除会话？';

  @override
  String get chatDeleteConversationBody => '将删除本机上这个会话的历史记录。Tox 不保留副本。';

  @override
  String get chatCancel => '取消';

  @override
  String get chatDraftPrefix => '草稿：';

  @override
  String get chatSelectConversation => '选择一个会话';

  @override
  String get chatContacts => '联系人';

  @override
  String get chatBackendUnavailable => '聊天后端未连接。';

  @override
  String get chatNoMessages => '还没有消息 — 呼叫 CQ 开始通联。';

  @override
  String get chatTrainingMode => '训练模式';

  @override
  String get chatTrainingModeOn => '训练模式已开：隐藏文本';

  @override
  String get chatTrainingModeOff => '训练模式已关';

  @override
  String get chatReveal => '显示';

  @override
  String get chatHiddenText => '先听，再显示';

  @override
  String get chatPlay => '播放莫尔斯';

  @override
  String get chatStop => '停止';

  @override
  String get chatPlaybackSettings => '播放设置';

  @override
  String get chatCharacterSpeed => '字符速度';

  @override
  String get chatFarnsworthSpeed => 'Farnsworth 速度';

  @override
  String get chatTone => '音调';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatStatusPending => '已排队 — 对方离线';

  @override
  String get chatStatusPendingDetail => 'Tox 没有服务器：消息会在对方上线后送达。';

  @override
  String get chatStatusSending => '发送中';

  @override
  String get chatStatusSent => '已发送';

  @override
  String get chatStatusFailed => '发送失败';

  @override
  String get chatOnline => '在线';

  @override
  String get chatOffline => '离线';

  @override
  String get chatMembers => '成员';

  @override
  String get chatLeaveGroup => '退出群组';

  @override
  String get chatLeaveGroupTitle => '退出这个群组？';

  @override
  String get chatLeaveGroupBody => '你将不再收到消息。之后可凭 chat id 重新加入。';

  @override
  String get chatLeave => '退出';

  @override
  String get chatConferenceNote => '旧式会议群：此处无法使用莫尔斯键控元数据（v2）。文本仍然可用。';

  @override
  String get chatClearHistory => '清空历史记录';

  @override
  String get chatModeKeyboard => '键盘';

  @override
  String get chatModeStraightKey => '直键';

  @override
  String get chatModePaddles => '双桨';

  @override
  String get chatTypeMessage => '输入消息';

  @override
  String get chatSend => '发送';

  @override
  String get chatBytesLeft => '字节剩余';

  @override
  String get chatTooLong => '超出单条 Tox 消息的长度上限';

  @override
  String get chatKeyHint => '在电键区按键，或按空格';

  @override
  String get chatPaddleHint => '点按双桨，或按住 Ctrl（左 点，右 划）';

  @override
  String get chatClearDraft => '清空草稿';

  @override
  String get chatDeleteLast => '删除最后一个字符';

  @override
  String get chatDecodedPreview => '译码';

  @override
  String get chatFriends => '好友';

  @override
  String get chatFriendRequests => '好友请求';

  @override
  String get chatNoFriends => '还没有好友。用对方的 Tox ID 添加一位。';

  @override
  String get chatNoRequests => '没有待处理的请求';

  @override
  String get chatAddFriend => '添加好友';

  @override
  String get chatMyToxId => '我的 Tox ID';

  @override
  String get chatToxIdLabel => 'Tox ID（76 位十六进制字符）';

  @override
  String get chatToxIdInvalid => 'Tox ID 必须正好是 76 位十六进制字符';

  @override
  String get chatToxIdOwn => '这是你自己的 Tox ID';

  @override
  String get chatToxIdAlreadyFriend => '已在你的好友列表中';

  @override
  String get chatRequestMessage => '附言';

  @override
  String get chatDefaultRequestMessage => 'morsecq CQ';

  @override
  String get chatSendRequest => '发送请求';

  @override
  String get chatRequestSent => '好友请求已发送';

  @override
  String get chatScanQr => '扫描二维码';

  @override
  String get chatScanQrDesktopHint => '扫描二维码需要手机摄像头';

  @override
  String get chatScanQrTitle => '扫描 Tox ID';

  @override
  String get chatScanQrNotToxId => '这个二维码不是 Tox ID';

  @override
  String get chatAccept => '接受';

  @override
  String get chatReject => '拒绝';

  @override
  String get chatCopy => '复制';

  @override
  String get chatCopied => '已复制到剪贴板';

  @override
  String get chatNoIdentity => '未加载身份';

  @override
  String get chatRemoveFriend => '删除好友';

  @override
  String get chatRemoveFriendTitle => '删除这位好友？';

  @override
  String get chatRemoveFriendBody => '对方将无法再给你发消息。';

  @override
  String get chatRemove => '删除';

  @override
  String get chatGroupsTitle => '群组';

  @override
  String get chatNoGroups => '还没有群组。创建一个，或凭 chat id 加入。';

  @override
  String get chatCreateGroup => '创建群组';

  @override
  String get chatJoinGroup => '加入群组';

  @override
  String get chatGroupName => '群组名称';

  @override
  String get chatGroupNameRequired => '请给群组取个名字';

  @override
  String get chatAdvanced => '高级';

  @override
  String get chatLegacyConference => '旧式会议群（兼容旧客户端）';

  @override
  String get chatLegacyConferenceHint => '不推荐：没有固定 chat id，也没有莫尔斯元数据。';

  @override
  String get chatCreate => '创建';

  @override
  String get chatChatIdLabel => 'Chat id（64 位十六进制字符）';

  @override
  String get chatChatIdInvalid => 'Chat id 必须正好是 64 位十六进制字符';

  @override
  String get chatPassword => '密码（可选）';

  @override
  String get chatJoin => '加入';

  @override
  String get chatJoinRequested => '加入中 — 找到一位成员后群组就会出现。';

  @override
  String get chatGroupInvites => '群组邀请';

  @override
  String get chatNoInvites => '没有待处理的邀请';

  @override
  String get chatInvitedBy => '邀请人';

  @override
  String get chatMembersCount => '位成员';

  @override
  String get chatConferenceBadge => '会议群';

  @override
  String get chatCopyChatId => '复制 chat id';

  @override
  String get chatYou => '你';

  @override
  String get chatError => '出了点问题';

  @override
  String get learnLearnTitle => '学习';

  @override
  String get learnLessonCardTitle => 'Koch 课程';

  @override
  String get learnNewestChar => '本课新字符';

  @override
  String get learnCourseComplete => '课程已完成 - 继续磨练！';

  @override
  String get learnDailyGoalTitle => '今天';

  @override
  String get learnDailyGoalMet => '已达成每日目标';

  @override
  String get learnNoStreak => '从今天开始连续练习';

  @override
  String get learnContinueLesson => '继续课程';

  @override
  String get learnReceivePractice => '听抄练习';

  @override
  String get learnSendPractice => '发报练习';

  @override
  String get learnReviewDue => '复习到期字符';

  @override
  String get learnSettings => '训练设置';

  @override
  String get learnLoading => '正在加载你的进度...';

  @override
  String get learnIdentityRequired => '创建或解锁身份后即可开始训练。进度随身份保存，会一同进入备份。';

  @override
  String get learnLoadFailed => '无法读取已保存的进度。将从头开始；旧文件已保留为 .corrupt。';

  @override
  String get learnChooseDrill => '选择一种练习';

  @override
  String get learnDrillGroups => '随机字组';

  @override
  String get learnDrillWords => '单词';

  @override
  String get learnDrillCallsigns => '呼号';

  @override
  String get learnDrillQso => '通联（QSO）';

  @override
  String get learnReceiveTitle => '听抄';

  @override
  String get learnReviewTitle => '复习';

  @override
  String get learnListen => '请听...';

  @override
  String get learnReady => '就绪';

  @override
  String get learnReplay => '重放';

  @override
  String get learnPlay => '播放';

  @override
  String get learnAnswerHint => '输入你听到的内容';

  @override
  String get learnSubmit => '核对';

  @override
  String get learnNext => '下一个';

  @override
  String get learnFinish => '结束';

  @override
  String get learnDone => '完成';

  @override
  String get learnBackspace => '删除';

  @override
  String get learnSpace => '空格';

  @override
  String get learnSent => '发出';

  @override
  String get learnYourCopy => '你的抄收';

  @override
  String get learnRoundPerfect => '全部抄对！';

  @override
  String get learnSessionSummary => '练习小结';

  @override
  String get learnLessonPassed => '本课通过';

  @override
  String get learnLessonNotPassed => '继续加油：正确率达 90% 即可解锁下一个字符';

  @override
  String get learnReviewRecorded => '复习已记录';

  @override
  String get learnWeakChars => '需要加强';

  @override
  String get learnConfusions => '易混淆';

  @override
  String get learnNoFeedbackWarning => '声音、闪光和振动都已关闭 - 将改用屏幕闪烁提示。';

  @override
  String get learnSendTitle => '发报';

  @override
  String get learnSendThis => '请发送';

  @override
  String get learnCopyFromMemory => '凭记忆';

  @override
  String get learnHiddenTarget => '已隐藏 - 凭记忆拍发';

  @override
  String get learnDecoded => '译码';

  @override
  String get learnPending => '键控中';

  @override
  String get learnWaitingForKey => '准备好后开始拍发';

  @override
  String get learnRestart => '重新开始';

  @override
  String get learnTryAnother => '换一个';

  @override
  String get learnKeyerStraight => '直键';

  @override
  String get learnKeyerIambicA => 'Iambic A';

  @override
  String get learnKeyerIambicB => 'Iambic B';

  @override
  String get learnLegendStraight => '空格 = 电键';

  @override
  String get learnLegendPaddles => '左 Ctrl = 点，右 Ctrl = 划';

  @override
  String get learnSendClean => '手法干净 - 无需修正。';

  @override
  String get learnSendIssues => '节奏提示';

  @override
  String get learnYourSending => '译码为';

  @override
  String get learnStraightKeyLabel => '电键';

  @override
  String get learnDitLabel => '点';

  @override
  String get learnDahLabel => '划';

  @override
  String get learnSettingsTitle => '训练设置';

  @override
  String get learnCharacterSpeed => '字符速度';

  @override
  String get learnFarnsworth => 'Farnsworth 间距';

  @override
  String get learnFarnsworthHelp => '字符保持高速；字符之间的间隔拉长到这个速度。';

  @override
  String get learnEffectiveSpeed => '有效速度';

  @override
  String get learnTone => '音调';

  @override
  String get learnPlaySample => '播放示例';

  @override
  String get learnSessionLength => '练习长度';

  @override
  String get learnFeedback => '反馈';

  @override
  String get learnSound => '声音';

  @override
  String get learnFlash => '屏幕闪光';

  @override
  String get learnHaptic => '振动';

  @override
  String get learnKeyer => '电键模式';

  @override
  String get learnDailyGoal => '每日目标';

  @override
  String get learnSampleText => 'CQ';

  @override
  String get referenceReferenceTitle => '莫尔斯电码手册';

  @override
  String get referenceTranslatorTitle => '翻译器';

  @override
  String get referencePlay => '播放';

  @override
  String get referenceStop => '停止';

  @override
  String get referenceClear => '清空';

  @override
  String get referenceClose => '关闭';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => '搜索字符、规程符号、Q 简语…';

  @override
  String get referenceClearSearch => '清除搜索';

  @override
  String get referenceNoResults => '没有匹配的结果。';

  @override
  String get referenceSectionAlphabet => '字母与数字';

  @override
  String get referenceSectionPunctuation => '标点';

  @override
  String get referenceSectionProsigns => '规程符号（Prosign）';

  @override
  String get referenceSectionQCodes => 'Q 简语';

  @override
  String get referenceSectionAbbreviations => 'CW 缩写';

  @override
  String get referenceSectionKoch => 'Koch 顺序';

  @override
  String get referenceAlphabetHint => '点按卡片试听。长按查看记忆口诀。';

  @override
  String get referenceKochHint => 'Koch 法引入字符的顺序（LCWO 序列）。从 K 和 M 开始；抄收正确率达 90% 时再加一个字符。';

  @override
  String get referenceMnemonicTitle => '记忆口诀';

  @override
  String get referenceKochPosition => 'Koch 序号';

  @override
  String get referenceMeaningLabel => '含义';

  @override
  String get referencePlaybackSettings => '播放设置';

  @override
  String get referenceCharacterSpeed => '字符速度';

  @override
  String get referenceFarnsworth => 'Farnsworth 间距';

  @override
  String get referenceFarnsworthHelp => '字符保持全速；间隔拉长到有效速度。';

  @override
  String get referenceEffectiveSpeed => '有效速度';

  @override
  String get referenceTone => '音调';

  @override
  String get referenceModeTextToMorse => '文本 → 莫尔斯';

  @override
  String get referenceModeMorseToText => '莫尔斯 → 文本';

  @override
  String get referenceModeKey => '拍发';

  @override
  String get referenceTextInputLabel => '文本';

  @override
  String get referenceTextInputHint => '输入要编码的文本…';

  @override
  String get referencePatternOutputLabel => '莫尔斯';

  @override
  String get referenceCopyPattern => '复制电码';

  @override
  String get referencePatternCopied => '电码已复制';

  @override
  String get referencePatternInputLabel => '莫尔斯';

  @override
  String get referencePatternInputHint => '输入 . 和 -，字母间用空格，单词间用 /';

  @override
  String get referenceTextOutputLabel => '文本';

  @override
  String get referenceCopyText => '复制文本';

  @override
  String get referenceTextCopied => '文本已复制';

  @override
  String get referenceUnknownPatternHelp => '没有对应字符的电码显示为 <电码>。';

  @override
  String get referenceKeypadDit => '点';

  @override
  String get referenceKeypadDah => '划';

  @override
  String get referenceKeypadCharGap => '字母间隔';

  @override
  String get referenceKeypadWordGap => '单词间隔';

  @override
  String get referenceKeypadBackspace => '退格';

  @override
  String get referenceKeyHint => '按住电键发送。使用键盘时按住空格。';

  @override
  String get referenceKeyLabel => '电键';

  @override
  String get referenceKeyDecodedLabel => '译码';

  @override
  String get referenceKeyPendingLabel => '键控中';

  @override
  String get statsTitle => '统计';

  @override
  String get statsLoading => '正在加载你的统计...';

  @override
  String get statsLoadFailed => '无法加载你的进度。下拉或重新打开以重试。';

  @override
  String get statsRetry => '重试';

  @override
  String get statsEmptyTitle => '还没有练习记录';

  @override
  String get statsEmptyBody => '完成第一次听抄或发报练习后，这里会显示你的正确率趋势、各字符掌握程度和练习日历。';

  @override
  String get statsEmptyCallToAction => '前往「学习」并点按「继续课程」开始。';

  @override
  String get statsOverviewTitle => '总览';

  @override
  String get statsTileLesson => 'Koch 课程';

  @override
  String get statsTileAccuracy => '正确率';

  @override
  String get statsAccuracyLast7Days => '最近 7 天';

  @override
  String get statsAccuracyAllTime => '全部';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => '练习量';

  @override
  String get statsTileStreak => '连续天数';

  @override
  String get statsTileDailyGoal => '每日目标';

  @override
  String get statsGoalMet => '今日已达成';

  @override
  String get statsSummaryTitle => '你的统计';

  @override
  String get statsSummaryOpen => '查看统计';

  @override
  String get statsTrendTitle => '正确率趋势';

  @override
  String get statsTrendHint => '点按数据点查看该次练习。';

  @override
  String get statsSeriesReceive => '听抄';

  @override
  String get statsSeriesSend => '发报';

  @override
  String get statsSeriesAll => '练习';

  @override
  String get statsAxisSessions => '练习次序';

  @override
  String get statsAxisAccuracy => '正确率';

  @override
  String get statsCharsTitle => '字符';

  @override
  String get statsCharsSubtitle => '按 Koch 顺序。点按字符查看详情。';

  @override
  String get statsCharsNotStarted => '尚未练习';

  @override
  String get statsNotInCourse => '不在 Koch 课程内';

  @override
  String get statsSrsTitle => '间隔重复';

  @override
  String get statsSrsNotTracked => '尚未安排';

  @override
  String get statsSrsDueNow => '现在到期';

  @override
  String get statsConfusionsTitle => '最常混淆为';

  @override
  String get statsConfusionsNone => '没有混淆记录';

  @override
  String get statsConfusionMissed => '漏抄';

  @override
  String get statsBucketLegendTitle => '正确率';

  @override
  String get statsBucketNone => '无';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => '混淆矩阵';

  @override
  String get statsHeatmapSubtitle => '行是发出的字符，列是你的回答。颜色越深表示越频繁。';

  @override
  String get statsHeatmapEmpty => '还没有混淆记录。答错的字符会显示在这里。';

  @override
  String get statsHeatmapLegendLow => '少';

  @override
  String get statsHeatmapLegendHigh => '多';

  @override
  String get statsHeatmapAxisTarget => '发出';

  @override
  String get statsHeatmapAxisAnswered => '回答';

  @override
  String get statsCalendarTitle => '练习日历';

  @override
  String get statsCalendarSubtitle => '最近 12 周';

  @override
  String get statsCalendarLegendLess => '少';

  @override
  String get statsCalendarLegendMore => '多';

  @override
  String get statsStreakExplanation => '连续天数按至少有一次练习的连续日历日计算。整天未练习会重置；一天内练习两次只算一天。';

  @override
  String get learnStatistics => '统计';

  @override
  String get listenTitle => '收听';

  @override
  String get listenStart => '开始';

  @override
  String get listenStop => '停止';

  @override
  String get listenStarting => '正在启动麦克风…';

  @override
  String get listenClear => '清空文本';

  @override
  String get listenCopy => '复制文本';

  @override
  String get listenCopied => '已复制解码文本';

  @override
  String get listenSettings => '收听设置';

  @override
  String get listenDecoded => '解码结果';

  @override
  String get listenEmptyHint => '把麦克风对准莫斯电码音，解码文本会显示在这里。';

  @override
  String get listenIdleHint => '点击「开始」以收听莫斯电码音。';

  @override
  String get listenPending => '接收中';

  @override
  String get listenSpeed => '速度';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => '信号';

  @override
  String get listenToneOn => '有音';

  @override
  String get listenTone => '音调频率';

  @override
  String get listenToneLocked => '已锁定';

  @override
  String get listenToneSearching => '搜索中';

  @override
  String get listenToneManual => '手动';

  @override
  String get listenAutoTune => '自动调谐';

  @override
  String get listenAutoTuneHelp => '跟踪 400–1000 Hz 之间最强的音调；拖动滑块可改为手动调谐。';

  @override
  String get listenRetune => '自动';

  @override
  String get listenBlockSize => '分析块长';

  @override
  String get listenBlockSizeHelp => '块越小，点划边沿定位越精确，但更容易受噪声影响。256 采样（5.3 ms）适合 5–40 WPM。';

  @override
  String get listenMinElement => '最短元素';

  @override
  String get listenMinElementHelp => '短于此时长的音与间隔将被视为杂音或断续而忽略。';

  @override
  String get listenPermissionDenied => '麦克风权限被拒绝。请在系统设置中允许后重试。';

  @override
  String get listenPermissionRetry => '重试';

  @override
  String get listenStartFailed => '无法启动麦克风。';

  @override
  String get listenNoInput => '未找到麦克风。请连接后重试。';

  @override
  String get listenStoppedInBackground => '应用进入后台，已停止收听。';
}
