// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => '学习';

  @override
  String get navChat => '聊天';

  @override
  String get navGroups => '群组';

  @override
  String get navMe => '我';

  @override
  String get navReference => '参考';

  @override
  String get navLearnDescription => 'Koch 课程、发报练习与听抄练习。';

  @override
  String get navChatDescription => '基于 Tox P2P 的无服务器一对一莫尔斯通联。';

  @override
  String get navGroupsDescription => '群组网络 — 多位报务员在同一共享频道上拍发。';

  @override
  String get navReferenceDescription => '字母表、规程符号、Q 简语、缩写，以及双向翻译器。';

  @override
  String get navMeDescription => '你的呼号、Tox 身份、进度与设置。';

  @override
  String get shellOfflineBanner => '离线：未连接到 Tox 网络。消息将在你恢复在线后发送。';

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
  String get messageStatusFailed => '发送失败';

  @override
  String get errorWrongPassword => '密码错误，请重试。';

  @override
  String get errorPeerOffline => '该好友离线。Tox 没有服务器，消息会等到对方上线后再送达。';

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
  String get languageSaveFailed => '无法保存语言设置，请重试。';

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
  String referenceKochPositionValue(int position) {
    return 'Koch 序号：$position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return '估计 $wpm WPM';
  }

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
  String get accountShowPassword => '显示密码';

  @override
  String get accountHidePassword => '隐藏密码';

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
  String get accountStartupFailedBody => 'MorseCQ 无法读取你的身份。没有做任何更改；你可以重试。';

  @override
  String get accountConnectionTapToReconnect => '点按重新连接';

  @override
  String get accountWelcomeTitle => '你的身份只保存在这台设备上';

  @override
  String get accountWelcomeIntro => 'MorseCQ 使用 Tox 点对点网络。没有服务器，也无需注册账号：你的身份是一对只保存在本机的密钥。';

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
  String get accountBackupBody => '你的身份只存在于这台设备上。如果设备丢失、重置或被盗，将无法找回：好友不会认出新的身份，训练进度也会丢失。';

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
  String get accountBackupContinue => '进入 MorseCQ';

  @override
  String get accountBackupShowQrHint => '朋友通过你的 Tox ID 添加你。可以以文本或二维码的形式分享。';

  @override
  String get accountRestoreTitle => '从备份恢复';

  @override
  String get accountRestoreBody => '选择一个由 MorseCQ 导出的备份文件。如果该身份设置了密码，这里需要输入。';

  @override
  String get accountRestoreChooseFile => '选择备份文件';

  @override
  String get accountRestoreNoFile => '请先选择备份文件';

  @override
  String get accountRestoreButton => '恢复';

  @override
  String get accountRestoring => '恢复中…';

  @override
  String get accountRestoreInvalidFile => '这个文件不是 MorseCQ 备份。';

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
  String get accountEditProfileBody => '会显示给 Tox 网络上的好友。';

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
  String accountRestoreFileChosenSize(int bytes) {
    return '已选择备份文件（$bytes 字节）';
  }

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
  String get chatDraftPrefix => '草稿：';

  @override
  String get chatSelectConversation => '选择一个会话';

  @override
  String get chatContacts => '联系人';

  @override
  String get chatNoMessages => '还没有消息 — 呼叫 CQ 开始通联。';

  @override
  String get chatTrainingMode => '训练模式';

  @override
  String get chatTrainingModeOn => '训练模式已开：隐藏文本';

  @override
  String get chatTrainingModeOff => '训练模式已关';

  @override
  String get chatAutoPlay => '自动播放收到的电码';

  @override
  String get chatAutoPlayOn => '自动播放已开：新消息到达即播放';

  @override
  String get chatAutoPlayOff => '自动播放已关';

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
  String get chatModeStraightKey => '直键';

  @override
  String get chatModePaddles => '双桨';

  @override
  String get chatKeyMessage => '用电键拍发消息';

  @override
  String get chatSend => '发送';

  @override
  String get chatTooLong => '超出单条 Tox 消息的长度上限';

  @override
  String get chatKeyHint => '在电键区按键，或按空格';

  @override
  String get chatPaddleHint => '点按双桨，或按住 Ctrl（左 点，右 划）';

  @override
  String get chatDeleteLast => '删除最后一个字符';

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
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

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
  String get chatConferenceBadge => '会议群';

  @override
  String get chatCopyChatId => '复制 chat id';

  @override
  String get learnLessonCardTitle => 'Koch 课程';

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
  String get learnDrillCharacters => '单字速认';

  @override
  String get learnDrillAbbreviations => '缩语与 Q 简语';

  @override
  String get learnDrillNumbers => '数字组';

  @override
  String get learnDrillConfusables => '易混字符';

  @override
  String get learnDrillContest => '竞赛交换';

  @override
  String get learnDrillGroupsHint => '用已学字符组成的随机字组';

  @override
  String get learnDrillCharactersHint => '每次一个字符，听到即答';

  @override
  String get learnDrillWordsHint => '常用英文单词';

  @override
  String get learnDrillAbbreviationsHint => 'TNX、FB、QTH、QSL 等通联常用语';

  @override
  String get learnDrillNumbersHint => '五位数字组，如电报与序号';

  @override
  String get learnDrillCallsignsHint => '世界各地的业余电台呼号';

  @override
  String get learnDrillConfusablesHint => '成对练习容易听混的字符，如 S/H、U/V';

  @override
  String get learnDrillQsoHint => '完整通联中的句子';

  @override
  String get learnDrillContestHint => '呼号 + 5NN + 序号或分区，含缩略数字';

  @override
  String get learnDrillReviewHint => '到期需要复习的字符';

  @override
  String get toolsTitle => '无线电工具';

  @override
  String get toolsGridTitle => '网格定位';

  @override
  String get toolsGridHint => '坐标换算网格、两地距离与天线方位';

  @override
  String get toolsBandsTitle => '频段与天线';

  @override
  String get toolsBandsHint => '频率所在频段、波长与偶极天线长度';

  @override
  String get toolsSpeedTitle => '报速换算';

  @override
  String get toolsSpeedHint => 'WPM 换算点长、间隔与每分钟字符数';

  @override
  String get toolsRstTitle => 'RST 信号报告';

  @override
  String get toolsRstHint => '组合信号报告并查看每一位的含义';

  @override
  String get toolsClockTitle => 'UTC 时钟';

  @override
  String get toolsClockHint => '日志使用的 UTC 时间与本地时间';

  @override
  String get toolsGridFromCoordinates => '由坐标求网格';

  @override
  String get toolsGridLatitude => '纬度';

  @override
  String get toolsGridLongitude => '经度';

  @override
  String get toolsGridCoordinatesHelp => '十进制度数；南纬、西经为负';

  @override
  String get toolsGridInvalidCoordinates => '纬度 -90 至 90，经度 -180 至 180';

  @override
  String get toolsGridLocator => '网格';

  @override
  String get toolsGridDistanceSection => '距离与方位';

  @override
  String get toolsGridMine => '我的网格';

  @override
  String get toolsGridTheirs => '对方网格';

  @override
  String get toolsGridInvalidLocator => '需 2、4、6 或 8 位，如 OM89ex';

  @override
  String get toolsGridCenter => '网格中心';

  @override
  String get toolsGridDistance => '距离';

  @override
  String get toolsGridShortPath => '短程方位';

  @override
  String get toolsGridLongPath => '长程方位';

  @override
  String get toolsBandsFrequency => '频率（MHz）';

  @override
  String get toolsBandsInvalidFrequency => '请输入大于 0 的频率';

  @override
  String toolsBandsRegionLabel(int number) {
    return '$number 区';
  }

  @override
  String get toolsBandsRegionHelp => '1 区：欧洲、非洲、中东 · 2 区：美洲 · 3 区：亚太（含中国）';

  @override
  String toolsBandsInBand(String band) {
    return '位于 $band 业余频段';
  }

  @override
  String get toolsBandsOutOfBand => '不在业余频段内';

  @override
  String get toolsBandsWavelength => '波长';

  @override
  String get toolsBandsDipole => '半波偶极天线（全长）';

  @override
  String get toolsBandsQuarterWave => '四分之一波长垂直天线';

  @override
  String get toolsBandsAntennaNote => '长度已乘 0.95 缩短系数，实际需修剪至谐振。';

  @override
  String get toolsBandsTable => '频段边界';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => '以上为 ITU 划分，请以你的执照与本国频率规划为准（通常更窄）。';

  @override
  String get toolsSpeedCharacter => '字符速度';

  @override
  String get toolsSpeedFarnsworth => 'Farnsworth 间隔';

  @override
  String get toolsSpeedOverall => '整体速度';

  @override
  String get toolsSpeedDit => '点';

  @override
  String get toolsSpeedDah => '划';

  @override
  String get toolsSpeedCharGap => '字符间隔';

  @override
  String get toolsSpeedWordGap => '单词间隔';

  @override
  String get toolsSpeedCpm => '每分钟字符数';

  @override
  String get toolsSpeedParis => '一个 PARIS 单词';

  @override
  String get toolsRstReadability => '可读度 (R)';

  @override
  String get toolsRstStrength => '信号强度 (S)';

  @override
  String get toolsRstTone => '音调 (T)';

  @override
  String get toolsRstReport => '报告';

  @override
  String get toolsRstCut => '竞赛简写';

  @override
  String get toolsRstPhone => '话音（无音调）';

  @override
  String get toolsRstR1 => '无法辨认';

  @override
  String get toolsRstR2 => '勉强可辨，偶尔听出个别字';

  @override
  String get toolsRstR3 => '相当困难才能辨认';

  @override
  String get toolsRstR4 => '基本没有困难';

  @override
  String get toolsRstR5 => '完全清晰';

  @override
  String get toolsRstS1 => '微弱，几乎察觉不到';

  @override
  String get toolsRstS2 => '很弱';

  @override
  String get toolsRstS3 => '弱';

  @override
  String get toolsRstS4 => '尚可';

  @override
  String get toolsRstS5 => '较好';

  @override
  String get toolsRstS6 => '好';

  @override
  String get toolsRstS7 => '较强';

  @override
  String get toolsRstS8 => '强';

  @override
  String get toolsRstS9 => '极强';

  @override
  String get toolsRstT1 => '极粗糙、很宽，像未整流交流';

  @override
  String get toolsRstT2 => '很粗糙的交流音，刺耳且宽';

  @override
  String get toolsRstT3 => '粗糙，已整流未滤波';

  @override
  String get toolsRstT4 => '粗糙，略有滤波痕迹';

  @override
  String get toolsRstT5 => '已滤波，但纹波调制很重';

  @override
  String get toolsRstT6 => '已滤波，有明显纹波';

  @override
  String get toolsRstT7 => '接近纯音，略有纹波';

  @override
  String get toolsRstT8 => '近乎完美，仅有轻微调制';

  @override
  String get toolsRstT9 => '纯净音调，毫无纹波';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => '本地时间';

  @override
  String get toolsClockNote => '通联日志与 QSL 卡片统一使用 UTC。';

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
  String get statsAxisSessions => '练习次序';

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
  String get listenEmptyHint => '把麦克风对准莫尔斯电码音，解码文本会显示在这里。';

  @override
  String get listenIdleHint => '点击「开始」以收听莫尔斯电码音。';

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
  String get listenStreamFailed => '麦克风意外中断，请重试。';

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
    return '$samples 采样（$ms ms）';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => '应用进入后台，已停止收听。';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => '点太长';

  @override
  String get learnTipDahTooShortTitle => '划太短';

  @override
  String get learnTipIntraGapTooLongTitle => '码元过于分散';

  @override
  String get learnTipCharGapTooShortTitle => '字符过于拥挤';

  @override
  String get learnTipWordGapTooShortTitle => '单词过于拥挤';

  @override
  String get learnTipSpeedUnsteadyTitle => '速度不稳';

  @override
  String get learnSeverityMinor => '轻微';

  @override
  String get learnSeverityModerate => '明显';

  @override
  String get learnSeveritySevere => '严重';

  @override
  String get notificationOpen => '打开';

  @override
  String get notificationChannelMessages => '消息';

  @override
  String get notificationChannelMessagesDescription => '来自好友和群组的新莫尔斯电码消息';

  @override
  String get notificationChannelFriendRequests => '好友请求';

  @override
  String get notificationChannelFriendRequestsDescription => '有人想添加你为好友';

  @override
  String get notificationChannelGroupInvites => '群组邀请';

  @override
  String get notificationChannelGroupInvitesDescription => '好友邀请你加入群组';

  @override
  String get notificationNewMessage => '新消息';

  @override
  String get notificationFriendRequestTitle => '新的好友请求';

  @override
  String learnNewestCharIs(String char) {
    return '本课新字符：$char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char，新字符';
  }

  @override
  String learnPendingPattern(String pattern) {
    return '键控中：$pattern';
  }

  @override
  String learnIssueHeadline(String title, String severity) {
    return '$title（$severity）';
  }

  @override
  String learnRatioTimes(String ratio) {
    return '$ratio 倍';
  }

  @override
  String learnTipDitTooLong(String ratio) {
    return '你的点拖得太长（约为一个点的 $ratio）。想着“嘀”而不是“嗒”——点是轻敲，不是长按。';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return '你的划太短（约为一个点的 $ratio；目标是 3 倍）。划要按住三个点的时长。';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return '字符内部的间隔太宽（约为一个点的 $ratio）。同一字符的码元要紧凑相连。';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return '字符之间粘在一起了（间隔约为一个点的 $ratio；目标是 3 倍）。每个字符后留出明确的停顿。';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return '单词之间太近（间隔约为一个点的 $ratio；目标是 7 倍）。单词之间要数一个长停顿。';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return '你的速度飘忽不定（波动 $percent%）。定下一个节拍，整行保持不变。';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$total 个点中有 $offending 个太长（平均 $ratio 点长）';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$total 个划中有 $offending 个太短（平均 $ratio 点长）';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$total 个字符内间隔中有 $offending 个太长（平均 $ratio 点长）';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$total 个字符间隔中有 $offending 个太短（平均 $ratio 点长）';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$total 个单词间隔中有 $offending 个太短（平均 $ratio 点长）';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return '拍发速度不稳（变异系数 $cv）';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return '最近 7 天 / 全部 $allTime';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes 分';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get accountNewPasswordRequired => '请输入新密码';

  @override
  String get accountToxIdQrSemantics => 'Tox ID 二维码';

  @override
  String get accountBackupSaveDialogTitle => '保存 MorseCQ 备份';

  @override
  String get accountBackupShareSubject => 'MorseCQ 身份备份';

  @override
  String get accountBackupChooseDialogTitle => '选择 MorseCQ 备份';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新消息',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return '来自 $name 的好友请求';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name：$message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return '邀请加入 $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name 邀请你加入';
  }

  @override
  String desktopTrayShow(String app) {
    return '显示 $app';
  }

  @override
  String desktopTrayHide(String app) {
    return '隐藏 $app';
  }

  @override
  String get desktopTraySoundOn => '声音已开';

  @override
  String get desktopTraySoundOff => '声音已关';

  @override
  String desktopTrayQuit(String app) {
    return '退出 $app';
  }

  @override
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条未读',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => '开';

  @override
  String get listenStateOff => '关';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '剩余 $count 字节',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位成员',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return '好友（$count）';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return '好友请求（$count）';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return '群组邀请（$count）';
  }

  @override
  String chatMembersTitleCount(int count) {
    return '成员 · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return '邀请人：$name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name（你）';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label：$value $unit';
  }

  @override
  String referenceTelegraphCodes(String codes) {
    return '中文电码：$codes';
  }

  @override
  String get referenceTelegraphMainland => '大陆（1983）';

  @override
  String get referenceTelegraphTaiwan => '台湾 / 香港';

  @override
  String get referenceTelegraphNone => '本电码本无此字';

  @override
  String get appearanceTitle => '外观';

  @override
  String get appearanceStyles => '界面风格';

  @override
  String get appearanceChoose => '选择风格，预览后应用';

  @override
  String get appearanceMode => '明暗模式';

  @override
  String get appearancePreview => '效果预览';

  @override
  String get appearanceApply => '应用风格';

  @override
  String get appearanceRestore => '恢复默认';

  @override
  String get appearanceApplied => '外观已保存';

  @override
  String get appearanceSaveFailed => '无法保存外观，请重试。';

  @override
  String get appearanceClassic => '经典黄铜';

  @override
  String get appearanceModern => '清爽现代';

  @override
  String get appearanceRadio => '夜航电台';

  @override
  String get appearancePaper => '纸感手册';

  @override
  String get appearanceCartoon => '清新卡通';

  @override
  String get appearanceLight => '浅色';

  @override
  String get appearanceDark => '深色';

  @override
  String get appearanceSubtitle => '五种风格，支持浅色与深色';

  @override
  String get chatClearHistoryBody => '删除当前会话在本机保存的历史记录？其他设备上的副本不受影响。此操作无法撤销。';

  @override
  String get chatLoadEarlier => '加载更早消息';

  @override
  String get chatHistoryLoadFailed => '更早消息加载失败，点击重试。';

  @override
  String get chatRetryHistory => '重试';

  @override
  String chatNewMessages(int count) {
    return '$count 条新消息';
  }

  @override
  String learnShowAllChars(int count) {
    return '显示全部 $count 个字符';
  }

  @override
  String get chatSelfMe => '我';

  @override
  String get chatSelfLocalOnly => '仅保存在本机';

  @override
  String get chatSelfContactSubtitle => '草稿、练习与备忘 · 不会发送';

  @override
  String get learnShowFewerChars => '收起字符';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class SZhHant extends SZh {
  SZhHant(): super('zh_Hant');

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => '學習';

  @override
  String get navChat => '聊天';

  @override
  String get navGroups => '群組';

  @override
  String get navMe => '我';

  @override
  String get navReference => '參考';

  @override
  String get navLearnDescription => 'Koch 課程、發報練習與聽抄練習。';

  @override
  String get navChatDescription => '基於 Tox P2P 的無伺服器一對一摩斯通聯。';

  @override
  String get navGroupsDescription => '群組網路 — 多位報務員在同一共享頻道上拍發。';

  @override
  String get navReferenceDescription => '字母表、規程符號、Q 簡語、縮寫，以及雙向翻譯器。';

  @override
  String get navMeDescription => '你的呼號、Tox 身分、進度與設定。';

  @override
  String get shellOfflineBanner => '離線：未連線至 Tox 網路。重新上線後便會傳送訊息。';

  @override
  String get actionOk => '確定';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionCopy => '複製';

  @override
  String get actionShare => '分享';

  @override
  String get actionRetry => '重試';

  @override
  String get actionClose => '關閉';

  @override
  String get actionSearch => '搜尋';

  @override
  String get actionSettings => '設定';

  @override
  String get connectionConnecting => '連線中…';

  @override
  String get connectionOnline => '上線';

  @override
  String get connectionOffline => '離線';

  @override
  String get messageStatusPending => '已排隊 — 對方離線';

  @override
  String get messageStatusPendingDetail => 'Tox 沒有伺服器：訊息會在對方上線後送達。';

  @override
  String get messageStatusSending => '傳送中';

  @override
  String get messageStatusSent => '已傳送';

  @override
  String get messageStatusFailed => '傳送失敗';

  @override
  String get errorWrongPassword => '密碼錯誤，請重試。';

  @override
  String get errorPeerOffline => '該聯絡人離線。Tox 沒有伺服器，訊息會等到對方上線後再送達。';

  @override
  String get errorInvalidToxId => '這不是有效的 Tox ID（應為 76 位十六進位字元）。';

  @override
  String get errorAlreadyFriend => '這個 Tox ID 已在你的好友列表中。';

  @override
  String get errorOwnId => '這是你自己的 Tox ID。';

  @override
  String get errorGroupNotFound => '未找到該群組。';

  @override
  String get errorMessageTooLong => '訊息超出單條 Tox 訊息的長度上限。';

  @override
  String get errorUnknown => '出了點問題';

  @override
  String get languageTitle => '語言';

  @override
  String get languageSystemDefault => '跟隨系統';

  @override
  String get languageSaveFailed => '無法儲存語言設定，請重試。';

  @override
  String learnLessonOf(int lesson, int total) {
    return '第 $lesson 課 / 共 $total 課';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已學 $count 個字元',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal 字元';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '連續練習 $days 天',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個待複習',
      zero: '暫無待複習',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$total 個中抄對 $correct 個';
  }

  @override
  String learnRoundOf(int round) {
    return '第 $round 輪';
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
      other: '已發 $count 個字元',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return '已解鎖新字元：$char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target 漏抄';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target 聽成了 $answered';
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
      other: '$count 個字元',
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
      other: '已學 $count 個字元',
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
      other: '抄收 $count 個字元',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次練習',
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
      other: '最長連續 $count 天',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal 字元';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '還差 $remaining 個字元',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最近 $count 次練習',
      one: '最近一次練習',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return '第 $index 次練習 / 共 $total 次';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total 正確';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return '第 $lesson 課';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次嘗試',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$attempts 次中對 $correct 次';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return '在第 $lesson 課引入';
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
      other: '$days 天後到期',
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
      other: '$chars 個字元',
      zero: '未練習',
    );
    return '$date：$_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個活躍日',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 條',
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
    return '已跳過（無摩斯電碼）：$chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Koch 序號：$position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return '估計 $wpm WPM';
  }

  @override
  String get accountCopied => 'Tox ID 已複製到剪貼簿';

  @override
  String get accountShowQr => '顯示QR 碼';

  @override
  String get accountToxId => 'Tox ID';

  @override
  String get accountDisplayName => '顯示名稱';

  @override
  String get accountDisplayNameHint => '你的呼號或暱稱';

  @override
  String get accountDisplayNameRequired => '請輸入顯示名稱';

  @override
  String get accountStatusMessage => '狀態訊息';

  @override
  String get accountPassword => '密碼';

  @override
  String get accountPasswordOptional => '密碼（可選）';

  @override
  String get accountConfirmPassword => '確認密碼';

  @override
  String get accountPasswordsDoNotMatch => '兩次輸入的密碼不一致';

  @override
  String get accountShowPassword => '顯示密碼';

  @override
  String get accountHidePassword => '隱藏密碼';

  @override
  String get accountStrengthWeak => '弱：至少使用 8 個字元';

  @override
  String get accountStrengthFair => '一般：12 個以上字元並混合多種類型更好';

  @override
  String get accountStrengthStrong => '強';

  @override
  String get accountStartupInspecting => '正在檢查你的身分…';

  @override
  String get accountStartupOpening => '正在開啟你的身分…';

  @override
  String get accountStartupFailedTitle => '無法啟動';

  @override
  String get accountStartupFailedBody => 'MorseCQ 無法讀取你的身分。沒有做任何更改；你可以重試。';

  @override
  String get accountConnectionTapToReconnect => '點按重新連線';

  @override
  String get accountWelcomeTitle => '你的身分只儲存在這台裝置上';

  @override
  String get accountWelcomeIntro => 'MorseCQ 使用 Tox 點對點網路。沒有伺服器，也無需註冊帳號：你的身分是一對只儲存在本機的密鑰。';

  @override
  String get accountWelcomePointNoServer => '沒有伺服器，不需要手機號或電子郵件。報務員之間直接用摩斯電碼通聯。';

  @override
  String get accountWelcomePointTraining => '訓練進度隨身分一起儲存，因此可以備份並在裝置間遷移。';

  @override
  String get accountWelcomePointBackup => '沒有人能為你找回身分。建立後請立即備份，以免裝置遺失時連同身分一起遺失。';

  @override
  String get accountCreateIdentity => '建立身分';

  @override
  String get accountRestoreFromBackup => '從備份還原';

  @override
  String get accountCreateTitle => '建立你的身分';

  @override
  String get accountCreateBody => '取一個別人能看到的名字。密碼用於加密本機上的身分檔案；如果你希望不輸密碼就能開啟應用程式，可以留空。';

  @override
  String get accountCreateButton => '建立';

  @override
  String get accountCreating => '建立中…';

  @override
  String get accountBackupTitle => '現在就備份你的身分';

  @override
  String get accountBackupBody => '你的身分只存在於這台裝置上。若裝置遺失、重設或遭竊，身分將無法找回：聯絡人不會認出新的身分，訓練進度也會遺失。';

  @override
  String get accountBackupWhatIsInside => '備份檔案包含加密後的身分和你的訓練進度。請把它儲存在本機以外的安全位置。';

  @override
  String get accountBackupSaveFile => '儲存備份檔案';

  @override
  String get accountBackupShareFile => '分享備份檔案';

  @override
  String get accountBackupSaved => '備份已儲存';

  @override
  String get accountBackupNotSaved => '備份未儲存';

  @override
  String get accountBackupFailed => '無法寫入備份';

  @override
  String get accountBackupAcknowledge => '我瞭解：沒有這份備份，我的身分將無法找回。';

  @override
  String get accountBackupContinue => '進入 MorseCQ';

  @override
  String get accountBackupShowQrHint => '朋友通過你的 Tox ID 新增你。可以以文字或QR 碼的形式分享。';

  @override
  String get accountRestoreTitle => '從備份還原';

  @override
  String get accountRestoreBody => '選擇一個由 MorseCQ 匯出的備份檔案。如果該身分設定了密碼，這裡需要輸入。';

  @override
  String get accountRestoreChooseFile => '選擇備份檔案';

  @override
  String get accountRestoreNoFile => '請先選擇備份檔案';

  @override
  String get accountRestoreButton => '還原';

  @override
  String get accountRestoring => '還原中…';

  @override
  String get accountRestoreInvalidFile => '這個檔案不是 MorseCQ 備份。';

  @override
  String get accountRestoreReplacesWarning => '還原將替換當前裝置上的身分。';

  @override
  String get accountUnlockTitle => '解鎖你的身分';

  @override
  String get accountUnlockBody => '你的身分檔案已加密。請輸入密碼繼續。';

  @override
  String get accountUnlockButton => '解鎖';

  @override
  String get accountUnlocking => '解鎖中…';

  @override
  String get accountUnlockRestoreInstead => '改為從備份還原';

  @override
  String get accountMeNoIdentity => '未載入身分';

  @override
  String get accountSectionAccount => '帳戶';

  @override
  String get accountSectionTraining => '訓練';

  @override
  String get accountSectionAbout => '關於';

  @override
  String get accountSectionDanger => '危險操作';

  @override
  String get accountEditProfile => '編輯資料';

  @override
  String get accountEditProfileBody => '會顯示給 Tox 網路上的聯絡人。';

  @override
  String get accountSetPassword => '設定密碼';

  @override
  String get accountChangePassword => '修改密碼';

  @override
  String get accountRemovePassword => '移除密碼';

  @override
  String get accountCurrentPassword => '當前密碼';

  @override
  String get accountNewPassword => '新密碼';

  @override
  String get accountPasswordUpdated => '密碼已更新';

  @override
  String get accountPasswordRemoved => '密碼已移除';

  @override
  String get accountProfileUpdated => '資料已更新';

  @override
  String get accountExportBackup => '匯出備份';

  @override
  String get accountExportBackupSubtitle => '把你的身分和訓練進度儲存到檔案';

  @override
  String get accountTrainingDefaults => '播放與訓練預設值';

  @override
  String get accountTrainingDefaultsSubtitle => '速度、音調、Farnsworth 間距';

  @override
  String get accountTrainingDefaultsPlaceholder => '速度、音調和 Farnsworth 預設值將放在這裡。';

  @override
  String get accountAboutLicence => '授權條款';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => '原始碼';

  @override
  String get accountAboutSourceCopied => '原始碼連結已複製';

  @override
  String get accountAboutBackend => '後端';

  @override
  String get accountDeleteIdentity => '刪除身分';

  @override
  String get accountDeleteIdentitySubtitle => '從本機抹除這個身分、聊天紀錄和訓練進度';

  @override
  String get accountDeleteDialogTitle => '刪除這個身分？';

  @override
  String get accountDeleteDialogBody => '這會從本機刪除你的身分、聊天紀錄和訓練進度。沒有備份將無法找回。輸入 DELETE 以確認。';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => '輸入 DELETE';

  @override
  String get accountDeleteButton => '刪除';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return '已選擇備份檔案（$bytes 位元組）';
  }

  @override
  String get chatSearchConversations => '搜尋對話';

  @override
  String get chatNoConversations => '還沒有對話';

  @override
  String get chatNoSearchResults => '沒有匹配的對話';

  @override
  String get chatPin => '置頂';

  @override
  String get chatUnpin => '取消置頂';

  @override
  String get chatMarkRead => '標為已讀';

  @override
  String get chatDelete => '刪除';

  @override
  String get chatDeleteConversationTitle => '刪除對話？';

  @override
  String get chatDeleteConversationBody => '將刪除本機上這個對話的歷史紀錄。Tox 不保留副本。';

  @override
  String get chatDraftPrefix => '草稿：';

  @override
  String get chatSelectConversation => '選擇一個對話';

  @override
  String get chatContacts => '聯絡人';

  @override
  String get chatNoMessages => '還沒有訊息 — 呼叫 CQ 開始通聯。';

  @override
  String get chatTrainingMode => '訓練模式';

  @override
  String get chatTrainingModeOn => '訓練模式已開：隱藏文字';

  @override
  String get chatTrainingModeOff => '訓練模式已關';

  @override
  String get chatAutoPlay => '自動播放收到的電碼';

  @override
  String get chatAutoPlayOn => '自動播放已開啟：新訊息到達即播放';

  @override
  String get chatAutoPlayOff => '自動播放已關閉';

  @override
  String get chatReveal => '顯示';

  @override
  String get chatHiddenText => '先聽，再顯示';

  @override
  String get chatPlay => '播放摩斯';

  @override
  String get chatStop => '停止';

  @override
  String get chatPlaybackSettings => '播放設定';

  @override
  String get chatCharacterSpeed => '字元速度';

  @override
  String get chatFarnsworthSpeed => 'Farnsworth 速度';

  @override
  String get chatTone => '音調';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => '成員';

  @override
  String get chatLeaveGroup => '離開群組';

  @override
  String get chatLeaveGroupTitle => '離開這個群組？';

  @override
  String get chatLeaveGroupBody => '你將不再收到訊息。之後可憑 chat id 重新加入。';

  @override
  String get chatLeave => '離開';

  @override
  String get chatConferenceNote => '舊式會議群：此處無法使用摩斯鍵控中繼資料（v2）。文字仍然可用。';

  @override
  String get chatClearHistory => '清空歷史紀錄';

  @override
  String get chatModeStraightKey => '直鍵';

  @override
  String get chatModePaddles => '雙槳';

  @override
  String get chatKeyMessage => '用電鍵拍發訊息';

  @override
  String get chatSend => '傳送';

  @override
  String get chatTooLong => '超出單條 Tox 訊息的長度上限';

  @override
  String get chatKeyHint => '在電鍵區按鍵，或按空格';

  @override
  String get chatPaddleHint => '點按雙槳，或按住 Ctrl（左 點，右 劃）';

  @override
  String get chatDeleteLast => '刪除最後一個字元';

  @override
  String get chatNoFriends => '還沒有好友。用對方的 Tox ID 新增一位。';

  @override
  String get chatNoRequests => '沒有待處理的請求';

  @override
  String get chatAddFriend => '新增好友';

  @override
  String get chatMyToxId => '我的 Tox ID';

  @override
  String get chatToxIdLabel => 'Tox ID（76 位十六進位字元）';

  @override
  String get chatToxIdInvalid => 'Tox ID 必須正好是 76 位十六進位字元';

  @override
  String get chatToxIdOwn => '這是你自己的 Tox ID';

  @override
  String get chatToxIdAlreadyFriend => '已在你的好友列表中';

  @override
  String get chatRequestMessage => '附言';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => '傳送請求';

  @override
  String get chatRequestSent => '好友請求已傳送';

  @override
  String get chatScanQr => '掃描QR 碼';

  @override
  String get chatScanQrDesktopHint => '掃描 QR 碼需要手機相機';

  @override
  String get chatScanQrTitle => '掃描 Tox ID';

  @override
  String get chatScanQrNotToxId => '這個QR 碼不是 Tox ID';

  @override
  String get chatAccept => '接受';

  @override
  String get chatReject => '拒絕';

  @override
  String get chatCopied => '已複製到剪貼簿';

  @override
  String get chatNoIdentity => '未載入身分';

  @override
  String get chatRemoveFriend => '刪除好友';

  @override
  String get chatRemoveFriendTitle => '刪除這位好友？';

  @override
  String get chatRemoveFriendBody => '對方將無法再給你發訊息。';

  @override
  String get chatRemove => '刪除';

  @override
  String get chatNoGroups => '還沒有群組。建立一個，或憑 chat id 加入。';

  @override
  String get chatCreateGroup => '建立群組';

  @override
  String get chatJoinGroup => '加入群組';

  @override
  String get chatGroupName => '群組名稱';

  @override
  String get chatGroupNameRequired => '請給群組取個名字';

  @override
  String get chatAdvanced => '進階';

  @override
  String get chatLegacyConference => '舊式會議群（相容舊客戶端）';

  @override
  String get chatLegacyConferenceHint => '不推薦：沒有固定 chat id，也沒有摩斯中繼資料。';

  @override
  String get chatCreate => '建立';

  @override
  String get chatChatIdLabel => 'Chat id（64 位十六進位字元）';

  @override
  String get chatChatIdInvalid => 'Chat id 必須正好是 64 位十六進位字元';

  @override
  String get chatPassword => '密碼（可選）';

  @override
  String get chatJoin => '加入';

  @override
  String get chatJoinRequested => '加入中 — 找到一位成員後群組就會出現。';

  @override
  String get chatConferenceBadge => '會議群';

  @override
  String get chatCopyChatId => '複製 chat id';

  @override
  String get learnLessonCardTitle => 'Koch 課程';

  @override
  String get learnCourseComplete => '課程已完成 - 繼續磨練！';

  @override
  String get learnDailyGoalTitle => '今天';

  @override
  String get learnDailyGoalMet => '已達成每日目標';

  @override
  String get learnNoStreak => '從今天開始連續練習';

  @override
  String get learnContinueLesson => '繼續課程';

  @override
  String get learnReceivePractice => '聽抄練習';

  @override
  String get learnSendPractice => '發報練習';

  @override
  String get learnReviewDue => '複習到期字元';

  @override
  String get learnSettings => '訓練設定';

  @override
  String get learnLoading => '正在載入你的進度...';

  @override
  String get learnIdentityRequired => '建立或解鎖身分後即可開始訓練。進度隨身分儲存，會一同進入備份。';

  @override
  String get learnLoadFailed => '無法讀取已儲存的進度。將從頭開始；舊檔案已保留為 .corrupt。';

  @override
  String get learnChooseDrill => '選擇一種練習';

  @override
  String get learnDrillGroups => '隨機字組';

  @override
  String get learnDrillWords => '單字';

  @override
  String get learnDrillCallsigns => '呼號';

  @override
  String get learnDrillQso => '通聯（QSO）';

  @override
  String get learnDrillCharacters => '單字速認';

  @override
  String get learnDrillAbbreviations => '縮語與 Q 簡語';

  @override
  String get learnDrillNumbers => '數字組';

  @override
  String get learnDrillConfusables => '易混字元';

  @override
  String get learnDrillContest => '競賽交換';

  @override
  String get learnDrillGroupsHint => '用已學字元組成的隨機字組';

  @override
  String get learnDrillCharactersHint => '每次一個字元，聽到即答';

  @override
  String get learnDrillWordsHint => '常用英文單字';

  @override
  String get learnDrillAbbreviationsHint => 'TNX、FB、QTH、QSL 等通聯常用語';

  @override
  String get learnDrillNumbersHint => '五位數字組，如電報與序號';

  @override
  String get learnDrillCallsignsHint => '世界各地的業餘電台呼號';

  @override
  String get learnDrillConfusablesHint => '成對練習容易聽混的字元，如 S/H、U/V';

  @override
  String get learnDrillQsoHint => '完整通聯中的句子';

  @override
  String get learnDrillContestHint => '呼號 + 5NN + 序號或分區，含縮略數字';

  @override
  String get learnDrillReviewHint => '到期需要複習的字元';

  @override
  String get toolsTitle => '無線電工具';

  @override
  String get toolsGridTitle => '網格定位';

  @override
  String get toolsGridHint => '座標換算網格、兩地距離與天線方位';

  @override
  String get toolsBandsTitle => '頻段與天線';

  @override
  String get toolsBandsHint => '頻率所在頻段、波長與偶極天線長度';

  @override
  String get toolsSpeedTitle => '報速換算';

  @override
  String get toolsSpeedHint => 'WPM 換算點長、間隔與每分鐘字元數';

  @override
  String get toolsRstTitle => 'RST 訊號報告';

  @override
  String get toolsRstHint => '組合訊號報告並查看每一位的含義';

  @override
  String get toolsClockTitle => 'UTC 時鐘';

  @override
  String get toolsClockHint => '日誌使用的 UTC 時間與本地時間';

  @override
  String get toolsGridFromCoordinates => '由座標求網格';

  @override
  String get toolsGridLatitude => '緯度';

  @override
  String get toolsGridLongitude => '經度';

  @override
  String get toolsGridCoordinatesHelp => '十進位度數；南緯、西經為負';

  @override
  String get toolsGridInvalidCoordinates => '緯度 -90 至 90，經度 -180 至 180';

  @override
  String get toolsGridLocator => '網格';

  @override
  String get toolsGridDistanceSection => '距離與方位';

  @override
  String get toolsGridMine => '我的網格';

  @override
  String get toolsGridTheirs => '對方網格';

  @override
  String get toolsGridInvalidLocator => '需 2、4、6 或 8 位，如 OM89ex';

  @override
  String get toolsGridCenter => '網格中心';

  @override
  String get toolsGridDistance => '距離';

  @override
  String get toolsGridShortPath => '短程方位';

  @override
  String get toolsGridLongPath => '長程方位';

  @override
  String get toolsBandsFrequency => '頻率（MHz）';

  @override
  String get toolsBandsInvalidFrequency => '請輸入大於 0 的頻率';

  @override
  String toolsBandsRegionLabel(int number) {
    return '$number 區';
  }

  @override
  String get toolsBandsRegionHelp => '1 區：歐洲、非洲、中東 · 2 區：美洲 · 3 區：亞太';

  @override
  String toolsBandsInBand(String band) {
    return '位於 $band 業餘頻段';
  }

  @override
  String get toolsBandsOutOfBand => '不在業餘頻段內';

  @override
  String get toolsBandsWavelength => '波長';

  @override
  String get toolsBandsDipole => '半波偶極天線（全長）';

  @override
  String get toolsBandsQuarterWave => '四分之一波長垂直天線';

  @override
  String get toolsBandsAntennaNote => '長度已乘 0.95 縮短係數，實際需修剪至諧振。';

  @override
  String get toolsBandsTable => '頻段邊界';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => '以上為 ITU 劃分，請以你的執照與本國頻率規劃為準（可能更窄）。';

  @override
  String get toolsSpeedCharacter => '字元速度';

  @override
  String get toolsSpeedFarnsworth => 'Farnsworth 間隔';

  @override
  String get toolsSpeedOverall => '整體速度';

  @override
  String get toolsSpeedDit => '點';

  @override
  String get toolsSpeedDah => '劃';

  @override
  String get toolsSpeedCharGap => '字元間隔';

  @override
  String get toolsSpeedWordGap => '單字間隔';

  @override
  String get toolsSpeedCpm => '每分鐘字元數';

  @override
  String get toolsSpeedParis => '一個 PARIS 單字';

  @override
  String get toolsRstReadability => '可讀度 (R)';

  @override
  String get toolsRstStrength => '訊號強度 (S)';

  @override
  String get toolsRstTone => '音調 (T)';

  @override
  String get toolsRstReport => '報告';

  @override
  String get toolsRstCut => '競賽簡寫';

  @override
  String get toolsRstPhone => '話音（無音調）';

  @override
  String get toolsRstR1 => '無法辨認';

  @override
  String get toolsRstR2 => '勉強可辨，偶爾聽出個別字';

  @override
  String get toolsRstR3 => '相當困難才能辨認';

  @override
  String get toolsRstR4 => '基本沒有困難';

  @override
  String get toolsRstR5 => '完全清晰';

  @override
  String get toolsRstS1 => '微弱，幾乎察覺不到';

  @override
  String get toolsRstS2 => '很弱';

  @override
  String get toolsRstS3 => '弱';

  @override
  String get toolsRstS4 => '尚可';

  @override
  String get toolsRstS5 => '較好';

  @override
  String get toolsRstS6 => '好';

  @override
  String get toolsRstS7 => '較強';

  @override
  String get toolsRstS8 => '強';

  @override
  String get toolsRstS9 => '極強';

  @override
  String get toolsRstT1 => '極粗糙、很寬，像未整流交流';

  @override
  String get toolsRstT2 => '很粗糙的交流音，刺耳且寬';

  @override
  String get toolsRstT3 => '粗糙，已整流未濾波';

  @override
  String get toolsRstT4 => '粗糙，略有濾波痕跡';

  @override
  String get toolsRstT5 => '已濾波，但漣波調變很重';

  @override
  String get toolsRstT6 => '已濾波，有明顯漣波';

  @override
  String get toolsRstT7 => '接近純音，略有漣波';

  @override
  String get toolsRstT8 => '近乎完美，僅有輕微調變';

  @override
  String get toolsRstT9 => '純淨音調，毫無漣波';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => '本地時間';

  @override
  String get toolsClockNote => '通聯日誌與 QSL 卡片統一使用 UTC。';

  @override
  String get learnReceiveTitle => '聽抄';

  @override
  String get learnReviewTitle => '複習';

  @override
  String get learnListen => '請聽...';

  @override
  String get learnReady => '就緒';

  @override
  String get learnReplay => '重放';

  @override
  String get learnAnswerHint => '輸入你聽到的內容';

  @override
  String get learnSubmit => '核對';

  @override
  String get learnNext => '下一個';

  @override
  String get learnFinish => '結束';

  @override
  String get learnDone => '完成';

  @override
  String get learnBackspace => '刪除';

  @override
  String get learnSpace => '空格';

  @override
  String get learnSent => '發出';

  @override
  String get learnYourCopy => '你的抄收';

  @override
  String get learnRoundPerfect => '全部抄對！';

  @override
  String get learnSessionSummary => '練習小結';

  @override
  String get learnLessonPassed => '本課通過';

  @override
  String get learnLessonNotPassed => '繼續加油：正確率達 90% 即可解鎖下一個字元';

  @override
  String get learnReviewRecorded => '複習已紀錄';

  @override
  String get learnWeakChars => '需要加強';

  @override
  String get learnConfusions => '易混淆';

  @override
  String get learnNoFeedbackWarning => '聲音、閃光和振動都已關閉 - 將改用螢幕閃爍提示。';

  @override
  String get learnSendTitle => '發報';

  @override
  String get learnSendThis => '請傳送';

  @override
  String get learnCopyFromMemory => '憑記憶';

  @override
  String get learnHiddenTarget => '已隱藏 - 憑記憶拍發';

  @override
  String get learnDecoded => '譯碼';

  @override
  String get learnWaitingForKey => '準備好後開始拍發';

  @override
  String get learnRestart => '重新開始';

  @override
  String get learnTryAnother => '換一個';

  @override
  String get learnKeyerStraight => '直鍵';

  @override
  String get learnKeyerIambicA => 'Iambic A';

  @override
  String get learnKeyerIambicB => 'Iambic B';

  @override
  String get learnLegendStraight => '空格 = 電鍵';

  @override
  String get learnLegendPaddles => '左 Ctrl = 點，右 Ctrl = 劃';

  @override
  String get learnSendClean => '手法乾淨 - 無需修正。';

  @override
  String get learnSendIssues => '節奏提示';

  @override
  String get learnYourSending => '譯碼為';

  @override
  String get learnStraightKeyLabel => '電鍵';

  @override
  String get learnDitLabel => '點';

  @override
  String get learnDahLabel => '劃';

  @override
  String get learnSettingsTitle => '訓練設定';

  @override
  String get learnCharacterSpeed => '字元速度';

  @override
  String get learnFarnsworth => 'Farnsworth 間距';

  @override
  String get learnFarnsworthHelp => '字元保持高速；字元之間的間隔拉長到這個速度。';

  @override
  String get learnEffectiveSpeed => '有效速度';

  @override
  String get learnTone => '音調';

  @override
  String get learnPlaySample => '播放示例';

  @override
  String get learnSessionLength => '練習長度';

  @override
  String get learnFeedback => '回饋';

  @override
  String get learnSound => '聲音';

  @override
  String get learnFlash => '螢幕閃光';

  @override
  String get learnHaptic => '振動';

  @override
  String get learnKeyer => '電鍵模式';

  @override
  String get learnDailyGoal => '每日目標';

  @override
  String get referenceReferenceTitle => '摩斯電碼手冊';

  @override
  String get referenceTranslatorTitle => '翻譯器';

  @override
  String get referencePlay => '播放';

  @override
  String get referenceStop => '停止';

  @override
  String get referenceClear => '清空';

  @override
  String get referenceClose => '關閉';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => '搜尋字元、規程符號、Q 簡語…';

  @override
  String get referenceClearSearch => '清除搜尋';

  @override
  String get referenceNoResults => '沒有匹配的結果。';

  @override
  String get referenceSectionAlphabet => '字母與數字';

  @override
  String get referenceSectionPunctuation => '標點';

  @override
  String get referenceSectionProsigns => '規程符號（Prosign）';

  @override
  String get referenceSectionQCodes => 'Q 簡語';

  @override
  String get referenceSectionAbbreviations => 'CW 縮寫';

  @override
  String get referenceSectionKoch => 'Koch 順序';

  @override
  String get referenceAlphabetHint => '點按卡片試聽。長按查看記憶口訣。';

  @override
  String get referenceKochHint => 'Koch 法引入字元的順序（LCWO 序列）。從 K 和 M 開始；抄收正確率達 90% 時再加一個字元。';

  @override
  String get referenceMnemonicTitle => '記憶口訣';

  @override
  String get referenceMeaningLabel => '含義';

  @override
  String get referencePlaybackSettings => '播放設定';

  @override
  String get referenceCharacterSpeed => '字元速度';

  @override
  String get referenceFarnsworth => 'Farnsworth 間距';

  @override
  String get referenceFarnsworthHelp => '字元保持全速；間隔拉長到有效速度。';

  @override
  String get referenceEffectiveSpeed => '有效速度';

  @override
  String get referenceTone => '音調';

  @override
  String get referenceModeTextToMorse => '文字 → 摩斯';

  @override
  String get referenceModeMorseToText => '摩斯 → 文字';

  @override
  String get referenceModeKey => '拍發';

  @override
  String get referenceTextInputLabel => '文字';

  @override
  String get referenceTextInputHint => '輸入要編碼的文字…';

  @override
  String get referencePatternOutputLabel => '摩斯';

  @override
  String get referenceCopyPattern => '複製電碼';

  @override
  String get referencePatternCopied => '電碼已複製';

  @override
  String get referencePatternInputLabel => '摩斯';

  @override
  String get referencePatternInputHint => '輸入 . 和 -，字母間用空格，單字間用 /';

  @override
  String get referenceTextOutputLabel => '文字';

  @override
  String get referenceCopyText => '複製文字';

  @override
  String get referenceTextCopied => '文字已複製';

  @override
  String get referenceUnknownPatternHelp => '沒有對應字元的電碼顯示為 <電碼>。';

  @override
  String get referenceKeypadDit => '點';

  @override
  String get referenceKeypadDah => '劃';

  @override
  String get referenceKeypadCharGap => '字母間隔';

  @override
  String get referenceKeypadWordGap => '單字間隔';

  @override
  String get referenceKeypadBackspace => '退格';

  @override
  String get referenceKeyHint => '按住電鍵傳送。使用鍵盤時按住空格。';

  @override
  String get referenceKeyLabel => '電鍵';

  @override
  String get referenceKeyDecodedLabel => '譯碼';

  @override
  String get referenceKeyPendingLabel => '鍵控中';

  @override
  String get statsTitle => '統計';

  @override
  String get statsLoading => '正在載入你的統計...';

  @override
  String get statsLoadFailed => '無法載入你的進度。下拉或重新開啟以重試。';

  @override
  String get statsRetry => '重試';

  @override
  String get statsEmptyTitle => '還沒有練習紀錄';

  @override
  String get statsEmptyBody => '完成第一次聽抄或發報練習後，這裡會顯示你的正確率趨勢、各字元掌握程度和練習日曆。';

  @override
  String get statsEmptyCallToAction => '前往「學習」並點按「繼續課程」開始。';

  @override
  String get statsOverviewTitle => '總覽';

  @override
  String get statsTileLesson => 'Koch 課程';

  @override
  String get statsTileAccuracy => '正確率';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => '練習量';

  @override
  String get statsTileStreak => '連續天數';

  @override
  String get statsTileDailyGoal => '每日目標';

  @override
  String get statsGoalMet => '今日已達成';

  @override
  String get statsSummaryTitle => '你的統計';

  @override
  String get statsSummaryOpen => '查看統計';

  @override
  String get statsTrendTitle => '正確率趨勢';

  @override
  String get statsTrendHint => '點按資料點查看該次練習。';

  @override
  String get statsSeriesReceive => '聽抄';

  @override
  String get statsSeriesSend => '發報';

  @override
  String get statsAxisSessions => '練習次序';

  @override
  String get statsCharsTitle => '字元';

  @override
  String get statsCharsSubtitle => '按 Koch 順序。點按字元查看詳情。';

  @override
  String get statsCharsNotStarted => '尚未練習';

  @override
  String get statsNotInCourse => '不在 Koch 課程內';

  @override
  String get statsSrsTitle => '間隔重複';

  @override
  String get statsSrsNotTracked => '尚未安排';

  @override
  String get statsSrsDueNow => '現在到期';

  @override
  String get statsConfusionsTitle => '最常混淆為';

  @override
  String get statsConfusionsNone => '沒有混淆紀錄';

  @override
  String get statsConfusionMissed => '漏抄';

  @override
  String get statsBucketLegendTitle => '正確率';

  @override
  String get statsBucketNone => '無';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => '混淆矩陣';

  @override
  String get statsHeatmapSubtitle => '行是發出的字元，列是你的回答。顏色越深表示越頻繁。';

  @override
  String get statsHeatmapEmpty => '還沒有混淆紀錄。答錯的字元會顯示在這裡。';

  @override
  String get statsHeatmapLegendLow => '少';

  @override
  String get statsHeatmapLegendHigh => '多';

  @override
  String get statsHeatmapAxisTarget => '發出';

  @override
  String get statsHeatmapAxisAnswered => '回答';

  @override
  String get statsCalendarTitle => '練習日曆';

  @override
  String get statsCalendarSubtitle => '最近 12 週';

  @override
  String get statsCalendarLegendLess => '少';

  @override
  String get statsCalendarLegendMore => '多';

  @override
  String get statsStreakExplanation => '連續天數按至少有一次練習的連續日曆日計算。整天未練習會重置；一天內練習兩次只算一天。';

  @override
  String get learnStatistics => '統計';

  @override
  String get listenTitle => '收聽';

  @override
  String get listenStart => '開始';

  @override
  String get listenStop => '停止';

  @override
  String get listenStarting => '正在啟動麥克風…';

  @override
  String get listenClear => '清空文字';

  @override
  String get listenCopy => '複製文字';

  @override
  String get listenCopied => '已複製解碼文字';

  @override
  String get listenSettings => '收聽設定';

  @override
  String get listenDecoded => '解碼結果';

  @override
  String get listenEmptyHint => '把麥克風對準摩斯電碼音，解碼文字會顯示在這裡。';

  @override
  String get listenIdleHint => '點選「開始」以收聽摩斯電碼音。';

  @override
  String get listenPending => '接收中';

  @override
  String get listenSpeed => '速度';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => '信號';

  @override
  String get listenToneOn => '有音';

  @override
  String get listenTone => '音調頻率';

  @override
  String get listenToneLocked => '已鎖定';

  @override
  String get listenToneSearching => '搜尋中';

  @override
  String get listenToneManual => '手動';

  @override
  String get listenAutoTune => '自動調諧';

  @override
  String get listenAutoTuneHelp => '追蹤 400–1000 Hz 之間最強的音調；拖動滑桿可改為手動調諧。';

  @override
  String get listenRetune => '自動';

  @override
  String get listenBlockSize => '分析區塊長度';

  @override
  String get listenBlockSizeHelp => '區塊越小，點劃邊緣定位越精確，但更容易受雜訊影響。256 個取樣（5.3 ms）適合 5–40 WPM。';

  @override
  String get listenMinElement => '最短元素';

  @override
  String get listenMinElementHelp => '短於此時長的音與間隔會視為雜訊或斷續而忽略。';

  @override
  String get listenPermissionDenied => '麥克風權限被拒絕。請在系統設定中允許後重試。';

  @override
  String get listenPermissionRetry => '重試';

  @override
  String get listenStartFailed => '無法啟動麥克風。';

  @override
  String get listenNoInput => '未找到麥克風。請連線後重試。';

  @override
  String get listenStreamFailed => '麥克風意外中斷，請重試。';

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
    return '$samples 個取樣（$ms ms）';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => '應用程式進入背景，已停止收聽。';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => '點太長';

  @override
  String get learnTipDahTooShortTitle => '劃太短';

  @override
  String get learnTipIntraGapTooLongTitle => '碼元過於分散';

  @override
  String get learnTipCharGapTooShortTitle => '字元過於擁擠';

  @override
  String get learnTipWordGapTooShortTitle => '單字過於擁擠';

  @override
  String get learnTipSpeedUnsteadyTitle => '速度不穩';

  @override
  String get learnSeverityMinor => '輕微';

  @override
  String get learnSeverityModerate => '明顯';

  @override
  String get learnSeveritySevere => '嚴重';

  @override
  String get notificationOpen => '開啟';

  @override
  String get notificationChannelMessages => '訊息';

  @override
  String get notificationChannelMessagesDescription => '來自好友和群組的新摩斯電碼訊息';

  @override
  String get notificationChannelFriendRequests => '好友請求';

  @override
  String get notificationChannelFriendRequestsDescription => '有人想新增你為好友';

  @override
  String get notificationChannelGroupInvites => '群組邀請';

  @override
  String get notificationChannelGroupInvitesDescription => '好友邀請你加入群組';

  @override
  String get notificationNewMessage => '新訊息';

  @override
  String get notificationFriendRequestTitle => '新的好友請求';

  @override
  String learnNewestCharIs(String char) {
    return '本課新字元：$char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char，新字元';
  }

  @override
  String learnPendingPattern(String pattern) {
    return '鍵控中：$pattern';
  }

  @override
  String learnIssueHeadline(String title, String severity) {
    return '$title（$severity）';
  }

  @override
  String learnRatioTimes(String ratio) {
    return '$ratio 倍';
  }

  @override
  String learnTipDitTooLong(String ratio) {
    return '你的點拖得太長（約為一個點的 $ratio）。想著“嘀”而不是“嗒”——點是輕敲，不是長按。';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return '你的劃太短（約為一個點的 $ratio；目標是 3 倍）。劃要按住三個點的時長。';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return '字元內部的間隔太寬（約為一個點的 $ratio）。同一字元的碼元要緊湊相連。';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return '字元之間黏在一起了（間隔約為一個點的 $ratio；目標是 3 倍）。每個字元後留出明確的停頓。';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return '單字之間太近（間隔約為一個點的 $ratio；目標是 7 倍）。單字之間要數一個長停頓。';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return '你的速度飄忽不定（波動 $percent%）。定下一個節拍，整行保持不變。';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$total 個點中有 $offending 個太長（平均 $ratio 點長）';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$total 個劃中有 $offending 個太短（平均 $ratio 點長）';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$total 個字元內間隔中有 $offending 個太長（平均 $ratio 點長）';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$total 個字元間隔中有 $offending 個太短（平均 $ratio 點長）';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$total 個單字間隔中有 $offending 個太短（平均 $ratio 點長）';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return '拍發速度不穩（變異系數 $cv）';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return '最近 7 天 / 全部 $allTime';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours 小時 $minutes 分';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes 分';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get accountNewPasswordRequired => '請輸入新密碼';

  @override
  String get accountToxIdQrSemantics => 'Tox ID QR 碼';

  @override
  String get accountBackupSaveDialogTitle => '儲存 MorseCQ 備份';

  @override
  String get accountBackupShareSubject => 'MorseCQ 身分備份';

  @override
  String get accountBackupChooseDialogTitle => '選擇 MorseCQ 備份';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 條新訊息',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return '來自 $name 的好友請求';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name：$message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return '邀請加入 $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name 邀請你加入';
  }

  @override
  String desktopTrayShow(String app) {
    return '顯示 $app';
  }

  @override
  String desktopTrayHide(String app) {
    return '隱藏 $app';
  }

  @override
  String get desktopTraySoundOn => '聲音已開';

  @override
  String get desktopTraySoundOff => '聲音已關';

  @override
  String desktopTrayQuit(String app) {
    return '離開 $app';
  }

  @override
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 條未讀',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => '開';

  @override
  String get listenStateOff => '關';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '剩餘 $count 位元組',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位成員',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return '好友（$count）';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return '好友請求（$count）';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return '群組邀請（$count）';
  }

  @override
  String chatMembersTitleCount(int count) {
    return '成員 · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return '邀請人：$name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name（你）';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label：$value $unit';
  }

  @override
  String referenceTelegraphCodes(String codes) {
    return '中文電碼：$codes';
  }

  @override
  String get referenceTelegraphMainland => '大陸（1983）';

  @override
  String get referenceTelegraphTaiwan => '臺灣 / 香港';

  @override
  String get referenceTelegraphNone => '本電碼本無此字';

  @override
  String get appearanceTitle => '外觀';

  @override
  String get appearanceStyles => '界面風格';

  @override
  String get appearanceChoose => '選擇風格，預覽後套用';

  @override
  String get appearanceMode => '明暗模式';

  @override
  String get appearancePreview => '效果預覽';

  @override
  String get appearanceApply => '套用風格';

  @override
  String get appearanceRestore => '還原預設';

  @override
  String get appearanceApplied => '外觀已儲存';

  @override
  String get appearanceSaveFailed => '無法儲存外觀，請重試。';

  @override
  String get appearanceClassic => '經典黃銅';

  @override
  String get appearanceModern => '清爽現代';

  @override
  String get appearanceRadio => '夜航電台';

  @override
  String get appearancePaper => '紙感手冊';

  @override
  String get appearanceCartoon => '清新卡通';

  @override
  String get appearanceLight => '淺色';

  @override
  String get appearanceDark => '深色';

  @override
  String get appearanceSubtitle => '五種風格，支援淺色與深色';

  @override
  String get chatClearHistoryBody => '刪除當前對話在本機儲存的歷史紀錄？其他裝置上的副本不受影響。此操作無法撤銷。';

  @override
  String get chatLoadEarlier => '載入更早訊息';

  @override
  String get chatHistoryLoadFailed => '更早訊息載入失敗，點選重試。';

  @override
  String get chatRetryHistory => '重試';

  @override
  String chatNewMessages(int count) {
    return '$count 條新訊息';
  }

  @override
  String learnShowAllChars(int count) {
    return '顯示全部 $count 個字元';
  }

  @override
  String get chatSelfMe => '我';

  @override
  String get chatSelfLocalOnly => '僅儲存在本機';

  @override
  String get chatSelfContactSubtitle => '草稿、練習與備忘 · 不會傳送';

  @override
  String get learnShowFewerChars => '收起字元';
}
