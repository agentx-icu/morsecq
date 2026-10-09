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
  String get navMe => '我';

  @override
  String get navReference => '参考';

  @override
  String get navLearnDescription => 'Koch 课程、发报练习与听抄练习。';

  @override
  String get navReferenceDescription => '字母表、规程符号、Q 简语、缩写，以及双向翻译器。';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionRetry => '重试';

  @override
  String get actionClose => '关闭';

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
  String get accountSectionTraining => '训练';

  @override
  String get accountSectionAbout => '关于';

  @override
  String get accountTrainingDefaults => '播放与训练默认值';

  @override
  String get accountTrainingDefaultsSubtitle => '速度、音调、Farnsworth 间距';

  @override
  String get accountAboutLicence => '许可证';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => '源代码';

  @override
  String get accountAboutSourceCopied => '源代码链接已复制';

  @override
  String get chatSend => '发送';

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
  String get learnLoadFailed => '无法读取已保存的进度。将从头开始；旧文件已保留为 .corrupt。';

  @override
  String get learnProgressSaveFailed => '无法保存进度。在 MorseCQ 关闭前，本次成绩仍然有效。';

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
  String get listenStateOn => '开';

  @override
  String get listenStateOff => '关';

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
  String learnShowAllChars(int count) {
    return '显示全部 $count 个字符';
  }

  @override
  String get learnShowFewerChars => '收起字符';

  @override
  String get learnLeaveDrillTitle => '退出本次练习？';

  @override
  String get learnLeaveDrillBody => '本次练习已完成的轮次不会被保存。';

  @override
  String get learnLeaveDrillConfirm => '退出';

  @override
  String get learnReplayAssistedNote => '已重播：本次练习计入练习量，但不会解锁课程或更新复习。';

  @override
  String get learnPlanTitle => '今日计划';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return '约 $minutes 分钟 · 已完成 $done/$total 步';
  }

  @override
  String get learnPlanBudget => '计划时长';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get learnPlanStart => '开始计划';

  @override
  String get learnPlanContinue => '继续计划';

  @override
  String get learnPlanStepReview => '复习到期字符';

  @override
  String get learnPlanStepFocus => '重点练习';

  @override
  String learnPlanStepCourse(int lesson) {
    return '第 $lesson 课';
  }

  @override
  String get learnPlanStepSend => '发报练习';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return '到期复习：$symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return '经常混淆：$symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return '正确率低于 90%：$symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count 个字符：可以解锁下一课';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return '已延长到 $count 个字符，以便能解锁下一课';
  }

  @override
  String get learnPlanReasonConsolidate => '短练习：巩固本课，不会解锁下一课';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return '课程已前进：练习第 $lesson 课，但不会解锁';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '发送 $count 个短目标';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return '完成 · $percent%';
  }

  @override
  String get learnPlanStepDone => '完成';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '已发送 $done/$total';
  }

  @override
  String get learnPlanStale => '课程或速度已更改。要更新尚未开始的步骤吗？';

  @override
  String get learnPlanUpdate => '更新步骤';

  @override
  String get learnPlanComplete => '今日计划已完成';

  @override
  String learnPlanNeedsWork(String symbols) {
    return '需要加强：$symbols';
  }

  @override
  String get learnPlanAllGood => '今天没有薄弱字符。';

  @override
  String get learnPlanTomorrow => '明天会生成新计划。自由练习随时可用。';

  @override
  String learnPlanEarlier(int done, int total) {
    return '之前的计划停在第 $done/$total 步，不再计入今天。';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return '可以把有效速度提高到 $wpm WPM';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return '可以提高到 $wpm WPM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return '当前速度抄收较吃力。可以试试 $wpm WPM 有效速度，或做重点练习。';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return '依据你最近 $count 次无辅助练习（$percent%）。点“应用”前不会改变任何设置。';
  }

  @override
  String get learnSpeedAdviceApply => '应用';

  @override
  String get learnSpeedAdviceDismiss => '暂不';

  @override
  String get learnSpeedAdviceInsufficient => '速度建议需要在当前速度下完成 3 次、每次 50 个字符以上的无辅助练习。';

  @override
  String get learnQsoAction => 'QSO 模拟';

  @override
  String learnQsoLocked(int lesson) {
    return '第 $lesson 课起开放';
  }

  @override
  String get learnQsoTitle => 'QSO 模拟';

  @override
  String get learnQsoRespond => '回应 CQ';

  @override
  String get learnQsoRespondHint => '一个电台在呼叫 CQ。回应它并交换信号报告。';

  @override
  String get learnQsoCall => '呼叫 CQ';

  @override
  String get learnQsoCallHint => '你呼叫 CQ，会有电台回应。';

  @override
  String get learnQsoYourCall => '你的呼号';

  @override
  String get learnQsoYourName => '你的名字';

  @override
  String get learnQsoYourQth => '你的 QTH';

  @override
  String get learnQsoInvalidCall => '请输入呼号，例如 BD1XYZ';

  @override
  String get learnQsoInvalidWord => '一个单词，仅限字母 A–Z';

  @override
  String get learnQsoOffline => '完全在本机运行，不会向任何人发送内容。';

  @override
  String get learnQsoStart => '开始 QSO';

  @override
  String get learnQsoResume => '继续未完成的 QSO';

  @override
  String get learnQsoStageCallCq => '用你的呼号呼叫 CQ';

  @override
  String get learnQsoStageCallConfirm => '回应：对方呼号、DE、你的呼号';

  @override
  String get learnQsoStageExchange => '发送信号报告、名字和 QTH';

  @override
  String get learnQsoStageConfirmInfo => '确认对方的信息';

  @override
  String get learnQsoStageClosing => '以 73 和 <SK> 结束';

  @override
  String get learnQsoStageDone => 'QSO 完成';

  @override
  String learnQsoSpeed(int wpm) {
    return '对方以 $wpm WPM 有效速度发送';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call 发送';
  }

  @override
  String get learnQsoRemoteHidden => '请凭听觉抄收——文本已隐藏。';

  @override
  String get learnQsoShowText => '显示文本';

  @override
  String get learnQsoListen => '收听';

  @override
  String get learnQsoAccepted => '已接受';

  @override
  String get learnQsoRejected => '未通过';

  @override
  String get learnQsoRemoteSending => '对方正在发送……';

  @override
  String get learnQsoYourTurn => '轮到你了：拍发回复，然后点“发送”。';

  @override
  String get learnQsoDecoded => '你的发送内容';

  @override
  String get learnQsoNothingKeyed => '尚未拍发';

  @override
  String get learnQsoPlayAgain => '请求重复（AGN）';

  @override
  String get learnQsoSlower => '请求放慢（QRS）';

  @override
  String get learnQsoHint => '提示';

  @override
  String learnQsoHintLabel(String example) {
    return '示例：$example';
  }

  @override
  String get learnQsoPause => '暂停';

  @override
  String get learnQsoSend => '发送';

  @override
  String get learnQsoClear => '清除';

  @override
  String get learnQsoIssueEmpty => '没有拍发任何内容。';

  @override
  String get learnQsoIssueMissingCq => '以 CQ 开头。';

  @override
  String get learnQsoIssueMissingDe => '在两个呼号之间加 DE。';

  @override
  String get learnQsoIssueWrongLocalCall => '你的呼号缺失或错误。';

  @override
  String get learnQsoIssueWrongRemoteCall => '对方的呼号错误。';

  @override
  String get learnQsoIssueReversedCalls => '呼号顺序反了：先对方，再 DE，再你的。';

  @override
  String get learnQsoIssueMissingEnding => '以 K 或 KN 结尾。';

  @override
  String get learnQsoIssueMissingRst => '给出信号报告，例如 UR RST 599。';

  @override
  String get learnQsoIssueInvalidRst => 'RST 超出范围（R 1–5、S 1–9、T 1–9）。';

  @override
  String get learnQsoIssueMissingName => '发送 NAME 和你的名字。';

  @override
  String get learnQsoIssueWrongName => '这不是你在本次 QSO 中的名字。';

  @override
  String get learnQsoIssueMissingQth => '发送 QTH 和你的位置。';

  @override
  String get learnQsoIssueWrongQth => '这不是你在本次 QSO 中的 QTH。';

  @override
  String get learnQsoIssueMissingAck => '用 R 或 QSL 表示确认。';

  @override
  String get learnQsoIssueWrongRemoteName => '确认对方操作员的名字。';

  @override
  String get learnQsoIssueMissing73 => '加上 73。';

  @override
  String get learnQsoIssueMissingSk => '以 <SK> 结束联络。';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return '一次通过：$total 步中 $count 步';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return '重复次数：$count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return '提示次数：$count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return '你的发报：约 $wpm WPM';
  }

  @override
  String get learnQsoSummaryNote => 'QSO 成绩与抄收正确率分开统计，不会解锁课程。';

  @override
  String get learnTipDahTooLongTitle => '划太长';

  @override
  String learnTipDahTooLong(String ratio) {
    return '你的划太长（约为一个点的 $ratio；目标是 3 倍）。满三个点长就松开。';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$total 个划中有 $offending 个太长（平均 $ratio 点长）';
  }

  @override
  String get learnRhythmTitle => '节奏';

  @override
  String get learnRhythmMine => '我的节奏';

  @override
  String get learnRhythmStandard => '标准节奏（目标速度）';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return '问题按你自己的点长（$ms 毫秒）判断，节奏均匀但偏慢没有问题。标准行按目标速度绘制。';
  }

  @override
  String get learnRhythmNotLocated => '无法把你的拍发逐个对应到字符，因此问题未定位到具体字母。请改为练习整个目标。';

  @override
  String get learnRhythmPlayMine => '播放我的';

  @override
  String get learnRhythmPlayStandard => '播放标准';

  @override
  String learnRhythmPracticePart(int count) {
    return '练习这个（$count 次）';
  }

  @override
  String get learnRhythmPracticeWhole => '练习整个目标';

  @override
  String get learnRhythmSymbolOk => '很好';

  @override
  String get learnRhythmZoomIn => '放大';

  @override
  String get learnRhythmZoomOut => '缩小';

  @override
  String get workbenchTitle => '录音工作台';

  @override
  String get workbenchOpen => '录音';

  @override
  String get workbenchImport => '导入录音';

  @override
  String get workbenchEmpty => '导入 WAV 录音，即可循环播放、解码并自己抄收。无需麦克风。';

  @override
  String get workbenchFormats => 'WAV，16 位 PCM，单声道或立体声，8/16/44.1/48 kHz；最大 50 MB、20 分钟。';

  @override
  String get workbenchBackupNote => '录音保存在本机。清除学习数据或卸载前请保留副本。已保存的选段保留标题、笔记和位置。';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => '单声道';

  @override
  String get workbenchStereo => '立体声';

  @override
  String get workbenchErrorNotWav => '这不是 WAV 文件。';

  @override
  String get workbenchErrorFormat => '目前只支持 16 位 PCM WAV（不支持 MP3、AAC 或浮点 WAV）。';

  @override
  String get workbenchErrorChannels => '只支持单声道或立体声录音。';

  @override
  String get workbenchErrorRate => '不支持该采样率。请使用 8、16、44.1 或 48 kHz。';

  @override
  String get workbenchErrorDamaged => '文件已损坏或不完整。';

  @override
  String get workbenchErrorTooLarge => '文件超过 50 MB。';

  @override
  String get workbenchErrorTooLong => '录音超过 20 分钟。';

  @override
  String get workbenchErrorIo => '无法读取该文件。';

  @override
  String get workbenchErrorMissing => '录音文件不见了。';

  @override
  String get workbenchStart => '开始（秒）';

  @override
  String get workbenchEnd => '结束（秒）';

  @override
  String get workbenchSelectAll => '全选';

  @override
  String get workbenchPlay => '播放所选片段';

  @override
  String get workbenchStop => '停止';

  @override
  String get workbenchLoop => '循环';

  @override
  String get workbenchPlayLimit => '较长的片段只播放前 5 分钟。';

  @override
  String get workbenchAutoTune => '自动寻找音调';

  @override
  String workbenchManualTone(int hz) {
    return '音调：$hz Hz';
  }

  @override
  String get workbenchDecode => '解码所选片段';

  @override
  String get workbenchCancel => '取消';

  @override
  String workbenchDecoding(int percent) {
    return '正在解码……$percent%';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return '音调 $hz Hz · 约 $wpm WPM';
  }

  @override
  String get workbenchToneNotLocked => '没有找到稳定的音调，请尝试手动调谐。';

  @override
  String get workbenchNoText => '该片段没有解出内容。';

  @override
  String workbenchUnknown(String patterns) {
    return '无法识别的码型：$patterns';
  }

  @override
  String get workbenchEdgeCut => '片段边缘的字符被截断，可能不准确。';

  @override
  String get workbenchToneNote => '锁定音调不代表结果可信，请用耳朵核对文本。';

  @override
  String get workbenchModeDecoder => '解码器';

  @override
  String get workbenchModeCopy => '我自己抄收';

  @override
  String get workbenchDecoderHidden => '抄收时解码文本会隐藏。';

  @override
  String get workbenchShowDecoder => '显示解码文本';

  @override
  String get workbenchReference => '参考答案（可选）';

  @override
  String get workbenchReferenceHelp => '粘贴实际发送的文本；否则会与解码结果比较。';

  @override
  String get workbenchAgainstDecoder => '已与解码结果比较，而解码结果本身也可能有误。';

  @override
  String get workbenchSave => '保存片段';

  @override
  String get workbenchSaveTitle => '标题';

  @override
  String get workbenchSaveNote => '备注';

  @override
  String get workbenchSaved => '片段已保存';

  @override
  String get workbenchSaveFailed => '无法保存片段。';

  @override
  String get workbenchLibrary => '已保存的片段';

  @override
  String get workbenchLibraryEmpty => '还没有保存的片段。';

  @override
  String get workbenchMissing => '录音文件不见了——请重新选择文件或删除此项。';

  @override
  String get workbenchRelink => '重新选择文件';

  @override
  String get workbenchDelete => '删除';

  @override
  String get materialsTitle => '我的素材';

  @override
  String get materialsNew => '新建素材';

  @override
  String get materialsEdit => '编辑';

  @override
  String get materialsSave => '保存';

  @override
  String get materialsSaveFailed => '无法保存素材。';

  @override
  String get materialsTitleField => '标题';

  @override
  String get materialsTagsField => '标签（用逗号分隔）';

  @override
  String get materialsTextField => '文本';

  @override
  String get materialsListField => '每行一项';

  @override
  String get materialsKindText => '文本';

  @override
  String get materialsKindWords => '单词表';

  @override
  String get materialsKindCallsigns => '呼号';

  @override
  String get materialsPreview => '预览';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items 项 · $symbols 个字符 · $prosigns 个程序信号';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return '无莫尔斯码，练习时略过：$chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count 个重复项只保留一次';
  }

  @override
  String get materialsProblemEmpty => '请先输入文本。';

  @override
  String get materialsProblemTooLarge => '过大：素材上限为 1 MiB。';

  @override
  String materialsProblemTooManyEntries(int count) {
    return '条目过多：最多 $count 条。';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return '某个条目过长：每条最多 $count 个字符。';
  }

  @override
  String get materialsProblemNothingTrainable => '这里没有可以用莫尔斯码练习的内容。';

  @override
  String get materialsSearch => '搜索素材';

  @override
  String get materialsFavoritesOnly => '收藏';

  @override
  String get materialsFavorite => '加入收藏';

  @override
  String get materialsUnfavorite => '取消收藏';

  @override
  String get materialsEmpty => '暂无素材。可添加自己的文本、词表或呼号。';

  @override
  String materialsItems(int count) {
    return '$count 项';
  }

  @override
  String get materialsActions => '素材操作';

  @override
  String get materialsPractise => '练习';

  @override
  String get materialsDelete => '删除';

  @override
  String get materialsDeleteTitle => '删除素材？';

  @override
  String materialsDeleteBody(String title) {
    return '“$title”将从本设备删除，练习记录会保留。';
  }

  @override
  String get materialsImport => '导入 TXT 或 JSON';

  @override
  String get materialsImportDialogTitle => '选择素材文件';

  @override
  String get materialsSaveDialogTitle => '保存素材';

  @override
  String get materialsImportFailed => '导入失败，素材库未改变。';

  @override
  String get materialsImportNotUtf8 => '只能导入 UTF-8 文本文件。';

  @override
  String get materialsImportInvalid => '不是有效的 MorseCQ 素材文件，未导入任何内容。';

  @override
  String materialsImported(int count) {
    return '已导入 $count 个素材。';
  }

  @override
  String get materialsDuplicateTitle => '部分素材已存在';

  @override
  String get materialsDuplicateOverwrite => '替换';

  @override
  String get materialsDuplicateKeepCopy => '两者都保留（作为副本导入）';

  @override
  String get materialsDuplicateSkip => '跳过';

  @override
  String get materialsExportJson => '导出为 JSON';

  @override
  String materialsExported(int count) {
    return '已导出 $count 个素材。';
  }

  @override
  String get materialsExportFailed => '导出失败。';

  @override
  String get materialsExportWav => '导出音频（WAV）';

  @override
  String materialsWavCharSpeed(int wpm) {
    return '字符速度：$wpm WPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return '有效速度：$wpm WPM';
  }

  @override
  String materialsWavTone(int hz) {
    return '音调：$hz Hz';
  }

  @override
  String get materialsWavWithAnswer => '附带答案文本（.txt）';

  @override
  String get materialsWavFormat => '16 位单声道 WAV，48 kHz。';

  @override
  String materialsWavParts(int count) {
    return '超过 10 分钟：将导出为 $count 个文件。';
  }

  @override
  String materialsWavExported(int count) {
    return '已保存 $count 个音频文件。';
  }

  @override
  String get materialsPracticeMode => '练习范围';

  @override
  String get materialsPracticeLearned => '仅已学字符';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return '仅已学字符（$count 项不可用：含尚未学习的字符）';
  }

  @override
  String get materialsPracticeAll => '所有莫尔斯字符';

  @override
  String get materialsPracticeNothing => '此模式下没有可练习的条目。';

  @override
  String get guestClearConfirm => '清除';

  @override
  String get placementTitle => '测试我的水平';

  @override
  String get placementCheckLevel => '测试我现在的水平';

  @override
  String get placementFromZero => '跳过引导：直接第 1 课挑战';

  @override
  String get placementOfferTitle => '刚接触莫尔斯码，还是已经会抄收？';

  @override
  String get placementOfferBody => '简短测试可以建议起点。测试是可选的，在你选择前不会改变任何设置。';

  @override
  String get placementIntro => '约 3–5 分钟，分五步抄收：先按柯赫顺序分组、速度逐级提高，最后是短单词。这只是基于少量样本的粗略参考，不是认证。随时可以停止。';

  @override
  String get placementStart => '开始';

  @override
  String get placementSkip => '跳过';

  @override
  String get placementStop => '停止';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return '第 $step/$total 步 · 有效速度 $wpm WPM';
  }

  @override
  String get placementTierPassed => '抄得很好，下一步更快。';

  @override
  String get placementTierStopped => '这一步低于 90%，测试到此结束。';

  @override
  String get placementNextTier => '下一步';

  @override
  String placementSuggestion(int lesson) {
    return '建议从第 $lesson 课开始';
  }

  @override
  String placementVerified(int count, int total) {
    return '按顺序确认了 $total 个柯赫字符中的 $count 个。';
  }

  @override
  String get placementLimits => '基于少量样本：未测到的字符仍视为未测试，也不会被标记为已掌握。你可以随时更改课程。';

  @override
  String placementAdopt(int lesson) {
    return '从第 $lesson 课开始';
  }

  @override
  String materialsImportConfirm(int count) {
    return '导入 $count 个素材？';
  }

  @override
  String get materialsExportTxt => '导出为文本（TXT）';

  @override
  String get conditionsTitle => '收听环境';

  @override
  String get conditionsClear => '清晰';

  @override
  String get conditionsLight => '轻度干扰';

  @override
  String get conditionsRadio => '实战电台';

  @override
  String get conditionsClearHint => '干净稳定的音调，即普通练习。';

  @override
  String get conditionsLightHint => '轻微底噪和缓慢衰落。成绩与清晰练习分开记录。';

  @override
  String get conditionsRadioHint => '噪声、深度衰落、邻近电台干扰和略不均匀的节奏。成绩与清晰练习分开记录。';

  @override
  String get conditionsPreview => '试听';

  @override
  String conditionsActive(String name) {
    return '收听环境：$name';
  }

  @override
  String get conditionsNeedSound => '电台环境只能听不能看：请在训练设置中打开声音，或改用“清晰”环境练习。';

  @override
  String get conditionsCleanReplay => '无效果重播';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在此环境和速度下共 $count 次：平均 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => '电台环境练习计入活动，但不会改变课程进度、复习计划或速度建议。';

  @override
  String get keysTitle => '按键与外接电键';

  @override
  String get keysMeSubtitle => '按键绑定、双桨与 USB 电键适配器';

  @override
  String get keysIntro => '选择用哪些键拍发莫尔斯。模拟键盘的 USB 电键/双桨适配器与键盘相同，请在此设置其按键。应用无法分辨按键来自哪个设备，因此配置方案就是一组按键绑定。';

  @override
  String get keysStandardProfile => '标准';

  @override
  String get keysUnnamed => '未命名方案';

  @override
  String get keysEdit => '编辑';

  @override
  String get keysNewProfile => '新建方案';

  @override
  String get keysLimitations => '不支持 MIDI、串口和蓝牙电键，也不支持适配器固件设置和电台控制。已测试的适配器列在文档中。';

  @override
  String get keysEditTitle => '按键方案';

  @override
  String get keysName => '方案名称';

  @override
  String get keysActionStraight => '手键';

  @override
  String get keysActionDit => '点桨';

  @override
  String get keysActionDah => '划桨';

  @override
  String get keysPressKey => '请按一个键…';

  @override
  String get keysNone => '未设置';

  @override
  String get keysSet => '设置';

  @override
  String keysReserved(String key) {
    return '$key 已被系统或应用占用，请换一个键。';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key 已用于“$action”。';
  }

  @override
  String keysConflictSave(String keys) {
    return '每个键只能有一种用途：$keys 被重复绑定。';
  }

  @override
  String get keysMissing => '请设置此电键模式需要的键（自动键需同时设置两只桨）。';

  @override
  String get keysSwapPaddles => '交换双桨（左手）';

  @override
  String get keysKeyerMode => '电键模式';

  @override
  String get keysIambicA => '自动键 A';

  @override
  String get keysIambicB => '自动键 B';

  @override
  String get keysAdapterKeyer => '适配器自行生成点划';

  @override
  String get keysAdapterKeyerHint => '适用于自带电键逻辑的适配器：直接使用它计时好的按下和松开，应用不会再生成一遍自动键序列。';

  @override
  String get keysAppSidetone => '拍发时的应用侧音';

  @override
  String get keysAppSidetoneHint => '适配器自带侧音时请关闭。不影响解码。';

  @override
  String get keysTestTitle => '测试';

  @override
  String get keysTestNote => '仅用于测试：不会发送，也不计入训练。';

  @override
  String get keysTestRelease => '释放按键';

  @override
  String get keysAdapterActive => '正在使用适配器自带的电键逻辑：桨对应的键按手键处理。';

  @override
  String keysHintCustom(String keys) {
    return '按键：$keys';
  }

  @override
  String get telegraphTitle => '中文电码';

  @override
  String get telegraphIntro => '每个汉字以四位数字码拍发。分别练习听写数字，以及记住哪个码对应哪个字。';

  @override
  String get telegraphCodebook => '码本';

  @override
  String get telegraphCodebookMainland => '大陆';

  @override
  String get telegraphCodebookTaiwan => '台湾';

  @override
  String get telegraphDigitsTitle => '抄收电码组';

  @override
  String get telegraphDigitsHint => '收听真实电码的四位数字组并输入数字。';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共 $count 次：数字正确率 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => '记忆码本';

  @override
  String get telegraphRecallHint => '由字查码、由码认字。与莫尔斯进度分开记录。';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已答 $count 张：掌握 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => '码本记忆不会解锁莫尔斯课程，也不改变速度建议；数字抄收与其他莫尔斯抄收同等计入。';

  @override
  String get telegraphRecallCharPrompt => '输入这个字的电码';

  @override
  String get telegraphRecallCodePrompt => '选出这个电码对应的字';

  @override
  String get telegraphReveal => '显示答案';

  @override
  String get telegraphRevealAssisted => '已显示：本题计为有提示。';

  @override
  String get telegraphCorrect => '正确';

  @override
  String get telegraphIncorrect => '不对';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$total 题中答对 $correct 题';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 题看过答案',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => '电码解读';

  @override
  String get telegraphInterpretNote => '仅在此显示：不会修改原消息，也不会发送任何内容。';

  @override
  String get telegraphUnresolved => '无法解读：没有字对应此码';

  @override
  String get telegraphMalformed => '不是四位数字组';

  @override
  String get telegraphNotCode => '文字，保持原样';

  @override
  String get telegraphAmbiguous => '多个字共用此码';

  @override
  String get conditionsAudioFailed => '本设备无法播放音频。请改用“清晰”环境练习。';

  @override
  String get aboutPrivacyPolicy => '隐私政策';

  @override
  String get aboutTermsOfUse => '使用条款';

  @override
  String get aboutSupport => '技术支持与联系';

  @override
  String get aboutLinkFailed => '无法打开链接，已复制链接。';

  @override
  String get offlineClearData => '清除学习数据';

  @override
  String get offlineClearDataBody => '删除此设备上的学习进度、计划和材料。';

  @override
  String get offlineCleared => '学习数据已清除。';

  @override
  String get offlineClearFailed => '无法清除学习数据。';

  @override
  String get learnStorageUnavailable => '无法在此设备上打开你的训练数据，请重试。';

  @override
  String get materialsImportedSource => '导入来源';

  @override
  String get learnStartHereTitle => '刚开始？先上一节 3 分钟的第一课';

  @override
  String get learnStartHereBody => '听听声音，认识 K 和 M，再做几轮简单练习。不计成绩。';

  @override
  String get learnStartHere => '从这里开始';

  @override
  String get learnReplayFirstLesson => '重温第一课';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '已引入 $introduced 个 · 已掌握 $mastered 个';
  }

  @override
  String get learnChipNew => '新字符';

  @override
  String get learnChipPractising => '练习中';

  @override
  String get learnChipMastered => '已掌握';

  @override
  String get learnChipWeak => '低于 90%';

  @override
  String get learnChipDue => '待复习';

  @override
  String get learnTapChipHint => '点按字符即可试听';

  @override
  String learnHearChar(String char) {
    return '听 $char';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a 对比 $b';
  }

  @override
  String get learnGuidedPractice => '简短练习（10 个字符）';

  @override
  String learnChallengeHint(int count, int min) {
    return '本课挑战：$count 个字符、正确率 90%，且每个新字符至少抄收 $min 次。通过即可解锁下一个字符。';
  }

  @override
  String get learnAllUnlockedNotPassed => '所有字符都已解锁。通过最后一课的挑战即可完成课程。';

  @override
  String get learnGoalFirstUse => '当前目标：用耳朵分辨 K 和 M。下一步：第 1 课挑战。';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return '当前目标：稳定认出 $chars（$min 次抄收、正确率 90%）。下一步：第 $lesson 课挑战。';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return '当前目标：通过第 $lesson 课挑战。下一步：$next。';
  }

  @override
  String learnGoalNextChar(String char) {
    return '字符 $char';
  }

  @override
  String get learnGoalNextOperating => '单词、呼号和完整 QSO';

  @override
  String get learnGoalOperating => '当前目标：真实报文——单词、呼号、QSO。下一步：逐级提高有效速度。';

  @override
  String get learnMorePractice => '更多练习';

  @override
  String get learnQsoReady => '已就绪';

  @override
  String get learnQsoPractiseFirst => '先练习报文行';

  @override
  String learnQsoSymbolsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还差 $count 个字符',
    );
    return '$_temp0';
  }

  @override
  String get learnGlossaryTitle => '这些术语是什么意思？';

  @override
  String get glossaryKoch => 'Koch 法：字符一开始就按全速学习，先学两个，每课再加一个；抄收正确率达到 90% 才进入下一课。';

  @override
  String get glossaryWpm => 'WPM：每分钟词数，以标准词 PARIS 计算。字符速度指每个字符本身响起的快慢。';

  @override
  String get glossaryFarnsworth => 'Farnsworth：字符保持快速，但字符之间的停顿被拉长，给你时间反应。有效速度把这些停顿算在内。';

  @override
  String get glossaryQso => 'QSO：两个电台之间的一次双向通联。CQ = 呼叫任意电台，DE = 来自，K = 请讲。';

  @override
  String get glossaryRst => 'RST：信号报告——可辨度、强度、音调。599 表示完美。73 表示致意。';

  @override
  String get learnVerdictNotCredited => '未记录：没有抄收任何字符。';

  @override
  String get learnVerdictAssisted => '辅助练习';

  @override
  String get learnVerdictAssistedHint => '使用了重播或揭示答案，所以本次只计入练习量：不解锁课程，也不更新复习。下一次试试不重播。';

  @override
  String get learnVerdictPractice => '练习已记录';

  @override
  String get learnVerdictPracticeHint => '自由练习会更新统计和复习，但不会推进课程。课程只通过学习主页的本课挑战推进。';

  @override
  String get learnVerdictCourseComplete => '最后一课挑战通过：整个字符课程已完成。';

  @override
  String learnVerdictTooShort(int count, int min) {
    return '未达到完整挑战：$count / $min 个字符';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return '一次挑战至少 $min 个字符。请从学习主页开始本课，或在训练设置中加长练习长度。';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return '$chars 抄收次数不足';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return '挑战要求每个新字符至少抄收 $min 次。再试一次：挑战会特意包含它们。';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return '新字符低于 90%：$chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => '其余都不错；新字符决定本课结果。先听它和相近字符的对比，再练一练，然后重新挑战。';

  @override
  String get learnVerdictBelowAccuracyHint => '总体正确率低于 90%。先针对下面的薄弱字符做个简短练习，再重新挑战。';

  @override
  String get learnDrillWeak => '练习薄弱字符';

  @override
  String get learnRetryChallenge => '重新挑战';

  @override
  String get learnTakeChallenge => '开始本课挑战';

  @override
  String learnChallengeTitle(int lesson) {
    return '第 $lesson 课挑战';
  }

  @override
  String get learnPracticeTitle => '练习';

  @override
  String get learnMeaningsTitle => '含义';

  @override
  String get firstLessonTitle => '第一课';

  @override
  String firstLessonStep(int step, int total) {
    return '第 $step / $total 步';
  }

  @override
  String get firstLessonHearTitle => '能听到吗？';

  @override
  String get firstLessonHearBody => '点按播放。你应该能听到一小段哔哔声（如果开启了闪屏或振动，也会看到或感觉到）。';

  @override
  String get firstLessonHeard => '听到了';

  @override
  String get firstLessonNotHeard => '什么都没听到';

  @override
  String get firstLessonNoSoundTitle => '没有声音？';

  @override
  String get firstLessonNoSoundBody => '请调高音量，检查静音开关或勿扰模式。你也可以改用屏幕闪烁或振动来代替声音。';

  @override
  String get firstLessonUseFlash => '同时闪烁屏幕';

  @override
  String get firstLessonUseVibration => '同时振动';

  @override
  String get firstLessonPlay => '播放';

  @override
  String get firstLessonSoundsTitle => '短与长';

  @override
  String get firstLessonSoundsBody => '莫尔斯码只有两种声音：短的\"滴\"和长的\"嗒\"，嗒是滴的三倍长。字符是它们的组合，字符之间用短暂的停顿隔开。点按每一个试听。';

  @override
  String get firstLessonDit => '滴（短）';

  @override
  String get firstLessonDah => '嗒（长）';

  @override
  String get firstLessonWorkedTitle => '看一个示范';

  @override
  String get firstLessonWorkedBody => '先听，声音结束后会显示答案。现在还不需要作答。';

  @override
  String firstLessonWorkedReveal(String char) {
    return '刚才是 $char';
  }

  @override
  String get firstLessonTrialsTitle => 'K 还是 M？';

  @override
  String get firstLessonTrialsBody => '听完后点按你听到的字符。想重播多少次都可以——这不是考试。';

  @override
  String firstLessonTrialRound(int round, int total) {
    return '第 $round / $total 轮';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return '对，刚才是 $char';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return '刚才是 $char，不是 $answer。听听两者的对比。';
  }

  @override
  String get firstLessonTooFast => '太快了？改用入门节奏（字符之间停顿更长）';

  @override
  String get firstLessonNextTitle => '接下来';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '本轮答对 $correct / $total。选择下一步，按自己的节奏继续。';
  }

  @override
  String get firstLessonNextGuided => '简短练习：10 个单字符';

  @override
  String get firstLessonNextSend => '试试发报';

  @override
  String get firstLessonSendGuide => '发报：短按是滴，长按是嗒。用拨片时，一侧发滴、另一侧发嗒。松开，并在字符之间稍作停顿。手键或 iambic A / B 以后可以再改，现在不重要。';

  @override
  String get firstLessonReplayAnytime => '随时可以从学习主页重温这一课。';

  @override
  String get firstLessonContinue => '继续';

  @override
  String get firstLessonTrialNext => '下一轮';

  @override
  String get sendFirstUseTitle => '第一次发报？';

  @override
  String get sendFirstUseStraight => '短按电键是滴，大约三倍长是嗒。字符之间稍作停顿，单词之间停顿更长。';

  @override
  String get sendFirstUsePaddles => '按住标有“点”的键发点，按住标有“划”的键发划；键控器会自动控制时长。字符间稍作停顿，单词间停顿更长。';

  @override
  String get sendFirstUseDismiss => '知道了';

  @override
  String get learnSpeedPresets => '节奏';

  @override
  String get learnPresetBeginner => '入门 20 / 6';

  @override
  String get learnPresetStandard => '标准 20 / 8';

  @override
  String get learnPresetHelp => '两种节奏的字符都按 20 WPM 发出；入门节奏在字符之间留更长的停顿（有效速度 6 WPM）。';

  @override
  String get learnPlanStepIntro => '第一课';

  @override
  String get learnPlanStepRecognition => '单字符识别';

  @override
  String get learnPlanReasonFirstLesson => '听声音，分辨 K 和 M（约 3 分钟）';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return '一次一个字符：$symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return '$count 个字符的短混合组；50 字符挑战稍后再说';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return '可选：先听示范，再发 $count 个短目标';
  }

  @override
  String get learnQsoReadyTitle => '可以开始 QSO 了';

  @override
  String get learnQsoNotReadyTitle => '还有字符没学到';

  @override
  String get learnQsoMissingBody => 'QSO 会用到这些你还没学的字符——点按即可试听。你也可以先体验：键盘会显示全部字符。';

  @override
  String get learnQsoShorthandHint => '先练习缩语（CQ、DE、UR、RST、TNX、73），这样报文才看得懂。';

  @override
  String get learnQsoPractiseShorthand => '练习缩语';

  @override
  String get learnQsoHowTitle => 'QSO 是怎么进行的';

  @override
  String get learnQsoHowBody => '呼叫（CQ = 任意电台，DE = 来自），用呼号应答，交换信号报告（RST）、姓名和 QTH（地点），最后 73（致意）和 <SK>（结束）。K 表示请讲。';

  @override
  String get learnQsoExploreLabel => '包含未学字符';

  @override
  String get statsCoursePassed => '课程已通过';

  @override
  String get firstLessonPlayAgain => '再播一次';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return '第 $lesson 课挑战：$count 个字符，90% 即可解锁 $char';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return '第 $lesson 课挑战：$count 个字符、90% 即完成课程';
  }

  @override
  String get learnQsoShorthandTitle => '先练习缩语';

  @override
  String get learnQsoExchangeTitle => '先练习 QSO 报文行';

  @override
  String get learnQsoExchangeHint => '先逐行抄收通联内容（一次一个交换），再到模拟器里跑完整 QSO。';

  @override
  String get sendGuideTitle => '发报带练';

  @override
  String sendGuideStep(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get sendGuideHear => '先听示范';

  @override
  String get sendGuideListening => '先听完整节奏…';

  @override
  String get sendGuideTry => '现在试着发';

  @override
  String get sendGuideRetry => '重练这个目标';

  @override
  String get sendGuidePassed => '解码正确，可以继续下一个目标。';

  @override
  String get sendGuideComplete => '两个字符和短组都已正确发出，可以继续自由发报练习。';

  @override
  String get sendGuideRhythm => '跟随示范节奏：点要短，划约为点的三倍，字符之间留清晰的停顿。';

  @override
  String get learnContinueToday => '继续今天的学习';

  @override
  String get learnPlanDetails => '查看计划详情';

  @override
  String get learnGuidedSingle => '单字符 · 10 字符';

  @override
  String get learnGuidedShort => '3 字符短组 · 15 字符';

  @override
  String get learnGuidedGroups => '5 字符一组 · 20 字符';

  @override
  String get learnGuidedRecommended => '推荐下一步';

  @override
  String get learnGuidedProgressHint => '通过后继续短组和完整组。带练用于巩固，通关挑战才会解锁下一课。';

  @override
  String get learnGuidedContinue => '继续带练';

  @override
  String get learnGuidedRetry => '再练这一档';

  @override
  String get firstLessonZeroHint => '还没有答对也没关系。先再听一遍 K 和 M 的差别，然后重试。';

  @override
  String get firstLessonPartialHint => '已经听对了一部分。再比较一下 K 和 M，按自己的节奏继续。';

  @override
  String get firstLessonPerfectHint => '这轮全部答对了。接着用不显示选项的听抄练习巩固。';

  @override
  String get firstLessonPaceLocked => '本轮已开始作答，速度保持不变；下一轮可在设置中调整。';

  @override
  String get learnRecentEvidenceHint => '阶段按近 14 天、同速且无辅助的听抄证据判断。';

  @override
  String get learnQsoConsolidateTitle => '巩固已学字符';

  @override
  String get learnQsoConsolidateHint => '已解锁不代表已掌握。先用单字符听抄取得近期独立成绩。';

  @override
  String get learnQsoPractiseSymbols => '练习这些字符';

  @override
  String get learnQsoProtocolTitle => '理解通联用语';

  @override
  String get learnQsoProtocolHint => '确认 CQ、DE、RST 和 73 的含义，再开始短通联。';

  @override
  String get learnQsoProtocolStart => '检查用语理解';

  @override
  String learnQsoProtocolQuestion(String token) {
    return '$token 在通联中表示什么？';
  }

  @override
  String get learnQsoGeneralCall => '呼叫任意电台';

  @override
  String get learnQsoFromStation => '来自这个电台';

  @override
  String get learnQsoSignalReport => '信号报告';

  @override
  String get learnQsoBestRegards => '致意并告别';

  @override
  String get learnQsoProtocolCorrect => '回答正确';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return '正确含义：$meaning';
  }

  @override
  String get learnQsoProtocolPass => '四个用语均独立答对，可以尝试短通联。';

  @override
  String get learnQsoProtocolPractice => '先复习这些含义，再重新检查。';

  @override
  String get learnQsoProtocolRetry => '重新检查';

  @override
  String get learnQsoShortExchange => '练习短通联';

  @override
  String get learnQsoShortExchangeHint => '独立完成呼号确认、信号报告和告别，再进行完整通联。';

  @override
  String get learnQsoExplorePending => '自由体验完整通联 · 仍有待练项目';

  @override
  String get learnQsoReadyHint => '已具备近期独立练习证据，可以开始完整模拟通联。';

  @override
  String get goalsTitle => '学习目标';

  @override
  String get goalsFirstQso => '第一次通联';

  @override
  String get goalsConversation => '日常交谈与脑内听抄';

  @override
  String get goalsContest => '竞赛交换';

  @override
  String get goalsExplanation => '参考 CW Academy。每个里程碑需要在标示有效速度下，近期至少两次独立练习达到 90% 准确率；证据有效期为 28 天。';

  @override
  String get goalsBeginner => '先完成字符课程；通过后，每日计划会加入对应目标的听懂训练和模拟通联。';

  @override
  String get goalsComplete => '当前已达到全部里程碑';

  @override
  String get goalsPractice => '练习下一项能力';

  @override
  String get goalsCopying => '字符听辨';

  @override
  String get goalsSending => '清晰发报';

  @override
  String get goalsWords => '整词听辨';

  @override
  String get goalsPhrases => '短句理解';

  @override
  String get goalsInformation => '通联信息提取';

  @override
  String get goalsStory => '短故事脑内听抄';

  @override
  String get goalsQso => '完整通联';

  @override
  String get goalsCompetition => '竞赛操作';

  @override
  String get goalsPlanListening => '按学习目标练习整词与通联信息听辨。';

  @override
  String get goalsPlanExchange => '进行与学习目标对应的互动通联。';

  @override
  String get mistakesTitle => '跨次错题本';

  @override
  String get mistakesPending => '待复习';

  @override
  String get mistakesRecovered => '已掌握';

  @override
  String get mistakesHint => '按原速度与原干扰条件重练原题。在两个不同日期独立、完整答对后标记为已掌握。重播或显示答案不计入掌握证据。';

  @override
  String get mistakesEmptyPending => '暂无待复习的错题。练习中答错的原题将在这里保存。';

  @override
  String get mistakesEmptyRecovered => '暂无已掌握的错题。在两个不同日期独立答对原题即可掌握。';

  @override
  String get mistakesOriginalCopy => '首次错误答案';

  @override
  String get mistakesLastCopy => '最近答案';

  @override
  String get mistakesNoAnswer => '未作答';

  @override
  String get mistakesFailures => '错误次数';

  @override
  String get mistakesFirstFailure => '首次答错';

  @override
  String get mistakesLastFailure => '最近答错';

  @override
  String get mistakesCorrectDays => '独立答对的日期数';

  @override
  String get mistakesRecoveredOn => '掌握日期';

  @override
  String get mistakesRetry => '重练原题';

  @override
  String get qsoAdvancedContestTitle => '竞赛交换';

  @override
  String get qsoAdvancedContestHint => '交换呼号、RST 和序号，再确认更正后的序号。';

  @override
  String get qsoAdvancedPotaTitle => 'POTA 公园间通联';

  @override
  String get qsoAdvancedPotaHint => '交换呼号、RST 和公园编号，再确认更正后的公园。';

  @override
  String get qsoAdvancedSerialLabel => '你的序号';

  @override
  String get qsoAdvancedParkLabel => '你的公园编号';

  @override
  String get qsoAdvancedInvalidSerial => '输入 1–9999 的序号。';

  @override
  String get qsoAdvancedInvalidPark => '使用公园前缀和 4–5 位数字，例如 US-1234。';

  @override
  String get qsoAdvancedRepeatTitle => '只重发一项';

  @override
  String get qsoAdvancedRepeatHint => '只请求没听清的信息，通联仍停留在当前阶段。';

  @override
  String get qsoAdvancedTypedMode => '文字作答（辅助）';

  @override
  String get qsoAdvancedKeyedMode => '拍发回复';

  @override
  String get qsoAdvancedTypedReply => '你的发报内容';

  @override
  String get qsoAdvancedContestStage => '发送 RST 和你的序号';

  @override
  String get qsoAdvancedPotaStage => '发送 RST 和你的公园编号';

  @override
  String get qsoAdvancedCorrectionStage => '确认更正后的信息';

  @override
  String get qsoAdvancedCorrectionHint => '听到 CORR 后，确认对方的 RST 和更正后的序号或公园。先保证拍发清晰，再提高速度。';

  @override
  String get qsoAdvancedIssueMissingSerial => '发送 NR 和你的序号。';

  @override
  String get qsoAdvancedIssueInvalidSerial => '序号必须是大于零的 1–4 位数字。';

  @override
  String get qsoAdvancedIssueWrongSerial => '序号与应确认的号码不一致。';

  @override
  String get qsoAdvancedIssueMissingPark => '发送 PARK 和公园编号。';

  @override
  String get qsoAdvancedIssueInvalidPark => '使用完整公园前缀和 4–5 位数字。';

  @override
  String get qsoAdvancedIssueWrongPark => '公园编号与应确认的公园不一致。';

  @override
  String get qsoAdvancedIssueWrongRemoteRst => '确认刚才听到的对方 RST。';

  @override
  String get qsoAdvancedContestSummary => '竞赛练习：已确认呼号、报告、序号和更正信息。';

  @override
  String get qsoAdvancedPotaSummary => 'POTA 练习：已确认呼号、报告、公园和更正信息。';

  @override
  String get comprehensionTitle => '整词整句听懂';

  @override
  String get comprehensionIntro => '听完完整消息，在脑中保留含义，再回答问题。素材为原创，可离线使用。';

  @override
  String get comprehensionModeLabel => '练习模式';

  @override
  String get comprehensionWords => '整词识别';

  @override
  String get comprehensionPhrases => '词语片段与短句';

  @override
  String get comprehensionQso => '通联信息';

  @override
  String get comprehensionPota => 'POTA 交换';

  @override
  String get comprehensionStory => '短故事';

  @override
  String get comprehensionWordsHelp => '通过声音整体识别单词，不逐字母抄写。';

  @override
  String get comprehensionPhrasesHelp => '先识别熟悉的词语片段，再听懂短语与完整句子。';

  @override
  String get comprehensionQsoHelp => '记住操作员呼号、姓名、地点和信号报告。';

  @override
  String get comprehensionPotaHelp => '记住双方呼号、公园编号和信号报告。第一个呼号是被呼叫的电台。';

  @override
  String get comprehensionStoryHelp => '不逐字抄写，记住人物、地点、时间和目的。使用消息中的英语词语作答。';

  @override
  String get comprehensionSpeedLabel => '有效速度';

  @override
  String comprehensionSpeed(String character, String effective) {
    return '字符 $character / 有效 $effective WPM';
  }

  @override
  String comprehensionPreviewMissing(String symbols) {
    return '消息包含尚未学过的符号：$symbols。可作为辅助预览听练。';
  }

  @override
  String get comprehensionAssisted => '辅助练习 · 重播、查看文本或包含未学符号';

  @override
  String get comprehensionIndependent => '独立尝试 · 只听一次，未查看文本';

  @override
  String get comprehensionReveal => '查看文本（辅助）';

  @override
  String get comprehensionTarget => '播发文本';

  @override
  String get comprehensionAnswer => '单词或短句';

  @override
  String get comprehensionCallsign => '被呼叫电台 / 呼号';

  @override
  String get comprehensionOtherCallsign => '发信电台 / 呼号';

  @override
  String get comprehensionName => '操作员姓名';

  @override
  String get comprehensionQth => '地点（QTH）';

  @override
  String get comprehensionRst => '信号报告（RST）';

  @override
  String get comprehensionPark => '公园编号';

  @override
  String get comprehensionPerson => '谁？';

  @override
  String get comprehensionDestination => '去了哪里？';

  @override
  String get comprehensionTime => '何时？';

  @override
  String get comprehensionAction => '去做什么？';

  @override
  String comprehensionScore(int correct, int total) {
    return '$total 个信息项答对 $correct 个';
  }

  @override
  String get comprehensionNext => '下一条消息';

  @override
  String get comprehensionDone => '完成';

  @override
  String get comprehensionSaveFailed => '结果未能保存，请在离开前重试。';

  @override
  String get comprehensionAudioFailed => '音频不可用，请检查设备输出后重试。';

  @override
  String get comprehensionAudioRequired => '此听懂练习使用声音，即使其他练习设置已关闭声音。';

  @override
  String comprehensionHistory(int count, int percent) {
    return '近期独立尝试：$count 次 · 信息准确率 $percent%';
  }

  @override
  String get comprehensionEmptyHistory => '独立听懂的结果将在这里显示，辅助练习单独记录。';

  @override
  String get comprehensionFieldCorrect => '正确';

  @override
  String get comprehensionFieldWrong => '需要重练';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class SZhHant extends SZh {
  SZhHant(): super('zh_Hant');

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => '學習';

  @override
  String get navMe => '我';

  @override
  String get navReference => '參考';

  @override
  String get navLearnDescription => 'Koch 課程、發報練習與聽抄練習。';

  @override
  String get navReferenceDescription => '字母表、規程符號、Q 簡語、縮寫，以及雙向翻譯器。';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionRetry => '重試';

  @override
  String get actionClose => '關閉';

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
  String get accountSectionTraining => '訓練';

  @override
  String get accountSectionAbout => '關於';

  @override
  String get accountTrainingDefaults => '播放與訓練預設值';

  @override
  String get accountTrainingDefaultsSubtitle => '速度、音調、Farnsworth 間距';

  @override
  String get accountAboutLicence => '授權條款';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => '原始碼';

  @override
  String get accountAboutSourceCopied => '原始碼連結已複製';

  @override
  String get chatSend => '傳送';

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
  String get learnLoadFailed => '無法讀取已儲存的進度。將從頭開始；舊檔案已保留為 .corrupt。';

  @override
  String get learnProgressSaveFailed => '無法儲存進度。在 MorseCQ 關閉前，本次成績仍然有效。';

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
    return '你的點拖得太長（約為一個點的 $ratio）。想著「滴」而不是「答」——點是輕敲，不是長按。';
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
  String get listenStateOn => '開';

  @override
  String get listenStateOff => '關';

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
  String learnShowAllChars(int count) {
    return '顯示全部 $count 個字元';
  }

  @override
  String get learnShowFewerChars => '收起字元';

  @override
  String get learnLeaveDrillTitle => '退出本次練習？';

  @override
  String get learnLeaveDrillBody => '本次練習已完成的輪次不會被儲存。';

  @override
  String get learnLeaveDrillConfirm => '退出';

  @override
  String get learnReplayAssistedNote => '已重播：本次練習計入練習量，但不會解鎖課程或更新複習。';

  @override
  String get learnPlanTitle => '今日計畫';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return '約 $minutes 分鐘 · 已完成 $done/$total 步';
  }

  @override
  String get learnPlanBudget => '計畫時長';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String get learnPlanStart => '開始計畫';

  @override
  String get learnPlanContinue => '繼續計畫';

  @override
  String get learnPlanStepReview => '複習到期字元';

  @override
  String get learnPlanStepFocus => '重點練習';

  @override
  String learnPlanStepCourse(int lesson) {
    return '第 $lesson 課';
  }

  @override
  String get learnPlanStepSend => '發報練習';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return '到期複習：$symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return '經常混淆：$symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return '正確率低於 90%：$symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count 個字元：可以解鎖下一課';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return '已延長到 $count 個字元，以便能解鎖下一課';
  }

  @override
  String get learnPlanReasonConsolidate => '短練習：鞏固本課，不會解鎖下一課';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return '課程已前進：練習第 $lesson 課，但不會解鎖';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '發送 $count 個短目標';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return '完成 · $percent%';
  }

  @override
  String get learnPlanStepDone => '完成';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '已發送 $done/$total';
  }

  @override
  String get learnPlanStale => '課程或速度已變更。要更新尚未開始的步驟嗎？';

  @override
  String get learnPlanUpdate => '更新步驟';

  @override
  String get learnPlanComplete => '今日計畫已完成';

  @override
  String learnPlanNeedsWork(String symbols) {
    return '需要加強：$symbols';
  }

  @override
  String get learnPlanAllGood => '今天沒有薄弱字元。';

  @override
  String get learnPlanTomorrow => '明天會產生新計畫。自由練習隨時可用。';

  @override
  String learnPlanEarlier(int done, int total) {
    return '之前的計畫停在第 $done/$total 步，不再計入今天。';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return '可以把有效速度提高到 $wpm WPM';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return '可以提高到 $wpm WPM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return '目前速度抄收較吃力。可以試試 $wpm WPM 有效速度，或做重點練習。';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return '依據你最近 $count 次無輔助練習（$percent%）。按「套用」前不會變更任何設定。';
  }

  @override
  String get learnSpeedAdviceApply => '套用';

  @override
  String get learnSpeedAdviceDismiss => '暫不';

  @override
  String get learnSpeedAdviceInsufficient => '速度建議需要在目前速度下完成 3 次、每次 50 個字元以上的無輔助練習。';

  @override
  String get learnQsoAction => 'QSO 模擬';

  @override
  String learnQsoLocked(int lesson) {
    return '第 $lesson 課起開放';
  }

  @override
  String get learnQsoTitle => 'QSO 模擬';

  @override
  String get learnQsoRespond => '回應 CQ';

  @override
  String get learnQsoRespondHint => '一個電台在呼叫 CQ。回應它並交換信號報告。';

  @override
  String get learnQsoCall => '呼叫 CQ';

  @override
  String get learnQsoCallHint => '你呼叫 CQ，會有電台回應。';

  @override
  String get learnQsoYourCall => '你的呼號';

  @override
  String get learnQsoYourName => '你的名字';

  @override
  String get learnQsoYourQth => '你的 QTH';

  @override
  String get learnQsoInvalidCall => '請輸入呼號，例如 BD1XYZ';

  @override
  String get learnQsoInvalidWord => '一個單字，僅限字母 A–Z';

  @override
  String get learnQsoOffline => '完全在本機執行，不會向任何人傳送內容。';

  @override
  String get learnQsoStart => '開始 QSO';

  @override
  String get learnQsoResume => '繼續未完成的 QSO';

  @override
  String get learnQsoStageCallCq => '用你的呼號呼叫 CQ';

  @override
  String get learnQsoStageCallConfirm => '回應：對方呼號、DE、你的呼號';

  @override
  String get learnQsoStageExchange => '發送信號報告、名字和 QTH';

  @override
  String get learnQsoStageConfirmInfo => '確認對方的資訊';

  @override
  String get learnQsoStageClosing => '以 73 和 <SK> 結束';

  @override
  String get learnQsoStageDone => 'QSO 完成';

  @override
  String learnQsoSpeed(int wpm) {
    return '對方以 $wpm WPM 有效速度發送';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call 發送';
  }

  @override
  String get learnQsoRemoteHidden => '請憑聽覺抄收——文字已隱藏。';

  @override
  String get learnQsoShowText => '顯示文字';

  @override
  String get learnQsoListen => '收聽';

  @override
  String get learnQsoAccepted => '已接受';

  @override
  String get learnQsoRejected => '未通過';

  @override
  String get learnQsoRemoteSending => '對方正在發送……';

  @override
  String get learnQsoYourTurn => '輪到你了：拍發回覆，然後按「發送」。';

  @override
  String get learnQsoDecoded => '你的發送內容';

  @override
  String get learnQsoNothingKeyed => '尚未拍發';

  @override
  String get learnQsoPlayAgain => '請求重複（AGN）';

  @override
  String get learnQsoSlower => '請求放慢（QRS）';

  @override
  String get learnQsoHint => '提示';

  @override
  String learnQsoHintLabel(String example) {
    return '範例：$example';
  }

  @override
  String get learnQsoPause => '暫停';

  @override
  String get learnQsoSend => '發送';

  @override
  String get learnQsoClear => '清除';

  @override
  String get learnQsoIssueEmpty => '沒有拍發任何內容。';

  @override
  String get learnQsoIssueMissingCq => '以 CQ 開頭。';

  @override
  String get learnQsoIssueMissingDe => '在兩個呼號之間加 DE。';

  @override
  String get learnQsoIssueWrongLocalCall => '你的呼號缺失或錯誤。';

  @override
  String get learnQsoIssueWrongRemoteCall => '對方的呼號錯誤。';

  @override
  String get learnQsoIssueReversedCalls => '呼號順序反了：先對方，再 DE，再你的。';

  @override
  String get learnQsoIssueMissingEnding => '以 K 或 KN 結尾。';

  @override
  String get learnQsoIssueMissingRst => '給出信號報告，例如 UR RST 599。';

  @override
  String get learnQsoIssueInvalidRst => 'RST 超出範圍（R 1–5、S 1–9、T 1–9）。';

  @override
  String get learnQsoIssueMissingName => '發送 NAME 和你的名字。';

  @override
  String get learnQsoIssueWrongName => '這不是你在本次 QSO 中的名字。';

  @override
  String get learnQsoIssueMissingQth => '發送 QTH 和你的位置。';

  @override
  String get learnQsoIssueWrongQth => '這不是你在本次 QSO 中的 QTH。';

  @override
  String get learnQsoIssueMissingAck => '用 R 或 QSL 表示確認。';

  @override
  String get learnQsoIssueWrongRemoteName => '確認對方操作員的名字。';

  @override
  String get learnQsoIssueMissing73 => '加上 73。';

  @override
  String get learnQsoIssueMissingSk => '以 <SK> 結束聯絡。';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return '一次通過：$total 步中 $count 步';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return '重複次數：$count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return '提示次數：$count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return '你的發報：約 $wpm WPM';
  }

  @override
  String get learnQsoSummaryNote => 'QSO 成績與抄收正確率分開統計，不會解鎖課程。';

  @override
  String get learnTipDahTooLongTitle => '劃太長';

  @override
  String learnTipDahTooLong(String ratio) {
    return '你的劃太長（約為一個點的 $ratio；目標是 3 倍）。滿三個點長就鬆開。';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$total 個劃中有 $offending 個太長（平均 $ratio 點長）';
  }

  @override
  String get learnRhythmTitle => '節奏';

  @override
  String get learnRhythmMine => '我的節奏';

  @override
  String get learnRhythmStandard => '標準節奏（目標速度）';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return '問題依你自己的點長（$ms 毫秒）判斷，節奏均勻但偏慢沒有問題。標準列依目標速度繪製。';
  }

  @override
  String get learnRhythmNotLocated => '無法把你的拍發逐個對應到字元，因此問題未定位到具體字母。請改為練習整個目標。';

  @override
  String get learnRhythmPlayMine => '播放我的';

  @override
  String get learnRhythmPlayStandard => '播放標準';

  @override
  String learnRhythmPracticePart(int count) {
    return '練習這個（$count 次）';
  }

  @override
  String get learnRhythmPracticeWhole => '練習整個目標';

  @override
  String get learnRhythmSymbolOk => '很好';

  @override
  String get learnRhythmZoomIn => '放大';

  @override
  String get learnRhythmZoomOut => '縮小';

  @override
  String get workbenchTitle => '錄音工作台';

  @override
  String get workbenchOpen => '錄音';

  @override
  String get workbenchImport => '匯入錄音';

  @override
  String get workbenchEmpty => '匯入 WAV 錄音，即可循環播放、解碼並自己抄收。不需要麥克風。';

  @override
  String get workbenchFormats => 'WAV，16 位元 PCM，單聲道或立體聲，8/16/44.1/48 kHz；最大 50 MB、20 分鐘。';

  @override
  String get workbenchBackupNote => '錄音保存在本機。清除學習資料或解除安裝前請保留副本。已儲存的選段保留標題、筆記和位置。';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => '單聲道';

  @override
  String get workbenchStereo => '立體聲';

  @override
  String get workbenchErrorNotWav => '這不是 WAV 檔案。';

  @override
  String get workbenchErrorFormat => '目前只支援 16 位元 PCM WAV（不支援 MP3、AAC 或浮點 WAV）。';

  @override
  String get workbenchErrorChannels => '只支援單聲道或立體聲錄音。';

  @override
  String get workbenchErrorRate => '不支援該取樣率。請使用 8、16、44.1 或 48 kHz。';

  @override
  String get workbenchErrorDamaged => '檔案已損毀或不完整。';

  @override
  String get workbenchErrorTooLarge => '檔案超過 50 MB。';

  @override
  String get workbenchErrorTooLong => '錄音超過 20 分鐘。';

  @override
  String get workbenchErrorIo => '無法讀取該檔案。';

  @override
  String get workbenchErrorMissing => '錄音檔案不見了。';

  @override
  String get workbenchStart => '開始（秒）';

  @override
  String get workbenchEnd => '結束（秒）';

  @override
  String get workbenchSelectAll => '全選';

  @override
  String get workbenchPlay => '播放所選片段';

  @override
  String get workbenchStop => '停止';

  @override
  String get workbenchLoop => '循環';

  @override
  String get workbenchPlayLimit => '較長的片段只播放前 5 分鐘。';

  @override
  String get workbenchAutoTune => '自動尋找音調';

  @override
  String workbenchManualTone(int hz) {
    return '音調：$hz Hz';
  }

  @override
  String get workbenchDecode => '解碼所選片段';

  @override
  String get workbenchCancel => '取消';

  @override
  String workbenchDecoding(int percent) {
    return '正在解碼……$percent%';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return '音調 $hz Hz · 約 $wpm WPM';
  }

  @override
  String get workbenchToneNotLocked => '沒有找到穩定的音調，請嘗試手動調諧。';

  @override
  String get workbenchNoText => '該片段沒有解出內容。';

  @override
  String workbenchUnknown(String patterns) {
    return '無法識別的碼型：$patterns';
  }

  @override
  String get workbenchEdgeCut => '片段邊緣的字元被截斷，可能不準確。';

  @override
  String get workbenchToneNote => '鎖定音調不代表結果可信，請用耳朵核對文字。';

  @override
  String get workbenchModeDecoder => '解碼器';

  @override
  String get workbenchModeCopy => '我自己抄收';

  @override
  String get workbenchDecoderHidden => '抄收時解碼文字會隱藏。';

  @override
  String get workbenchShowDecoder => '顯示解碼文字';

  @override
  String get workbenchReference => '參考答案（選填）';

  @override
  String get workbenchReferenceHelp => '貼上實際發送的文字；否則會與解碼結果比較。';

  @override
  String get workbenchAgainstDecoder => '已與解碼結果比較，而解碼結果本身也可能有誤。';

  @override
  String get workbenchSave => '儲存片段';

  @override
  String get workbenchSaveTitle => '標題';

  @override
  String get workbenchSaveNote => '備註';

  @override
  String get workbenchSaved => '片段已儲存';

  @override
  String get workbenchSaveFailed => '無法儲存片段。';

  @override
  String get workbenchLibrary => '已儲存的片段';

  @override
  String get workbenchLibraryEmpty => '還沒有儲存的片段。';

  @override
  String get workbenchMissing => '錄音檔案不見了——請重新選擇檔案或刪除此項。';

  @override
  String get workbenchRelink => '重新選擇檔案';

  @override
  String get workbenchDelete => '刪除';

  @override
  String get materialsTitle => '我的素材';

  @override
  String get materialsNew => '新增素材';

  @override
  String get materialsEdit => '編輯';

  @override
  String get materialsSave => '儲存';

  @override
  String get materialsSaveFailed => '無法儲存素材。';

  @override
  String get materialsTitleField => '標題';

  @override
  String get materialsTagsField => '標籤（以逗號分隔）';

  @override
  String get materialsTextField => '文字';

  @override
  String get materialsListField => '每行一項';

  @override
  String get materialsKindText => '文字';

  @override
  String get materialsKindWords => '單字表';

  @override
  String get materialsKindCallsigns => '呼號';

  @override
  String get materialsPreview => '預覽';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items 項 · $symbols 個字元 · $prosigns 個程序信號';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return '無摩斯碼，練習時略過：$chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count 個重複項只保留一次';
  }

  @override
  String get materialsProblemEmpty => '請先輸入文字。';

  @override
  String get materialsProblemTooLarge => '過大：素材上限為 1 MiB。';

  @override
  String materialsProblemTooManyEntries(int count) {
    return '條目過多：最多 $count 條。';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return '某個條目過長：每條最多 $count 個字元。';
  }

  @override
  String get materialsProblemNothingTrainable => '這裡沒有可以用摩斯碼練習的內容。';

  @override
  String get materialsSearch => '搜尋素材';

  @override
  String get materialsFavoritesOnly => '收藏';

  @override
  String get materialsFavorite => '加入收藏';

  @override
  String get materialsUnfavorite => '取消收藏';

  @override
  String get materialsEmpty => '尚無素材。可加入自己的文字、詞表或呼號。';

  @override
  String materialsItems(int count) {
    return '$count 項';
  }

  @override
  String get materialsActions => '素材操作';

  @override
  String get materialsPractise => '練習';

  @override
  String get materialsDelete => '刪除';

  @override
  String get materialsDeleteTitle => '刪除素材？';

  @override
  String materialsDeleteBody(String title) {
    return '「$title」將從本裝置刪除，練習紀錄會保留。';
  }

  @override
  String get materialsImport => '匯入 TXT 或 JSON';

  @override
  String get materialsImportDialogTitle => '選擇素材檔案';

  @override
  String get materialsSaveDialogTitle => '儲存素材';

  @override
  String get materialsImportFailed => '匯入失敗，素材庫未變更。';

  @override
  String get materialsImportNotUtf8 => '只能匯入 UTF-8 文字檔。';

  @override
  String get materialsImportInvalid => '不是有效的 MorseCQ 素材檔，未匯入任何內容。';

  @override
  String materialsImported(int count) {
    return '已匯入 $count 個素材。';
  }

  @override
  String get materialsDuplicateTitle => '部分素材已存在';

  @override
  String get materialsDuplicateOverwrite => '取代';

  @override
  String get materialsDuplicateKeepCopy => '兩者都保留（作為副本匯入）';

  @override
  String get materialsDuplicateSkip => '略過';

  @override
  String get materialsExportJson => '匯出為 JSON';

  @override
  String materialsExported(int count) {
    return '已匯出 $count 個素材。';
  }

  @override
  String get materialsExportFailed => '匯出失敗。';

  @override
  String get materialsExportWav => '匯出音訊（WAV）';

  @override
  String materialsWavCharSpeed(int wpm) {
    return '字元速度：$wpm WPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return '有效速度：$wpm WPM';
  }

  @override
  String materialsWavTone(int hz) {
    return '音調：$hz Hz';
  }

  @override
  String get materialsWavWithAnswer => '附帶答案文字（.txt）';

  @override
  String get materialsWavFormat => '16 位元單聲道 WAV，48 kHz。';

  @override
  String materialsWavParts(int count) {
    return '超過 10 分鐘：將匯出為 $count 個檔案。';
  }

  @override
  String materialsWavExported(int count) {
    return '已儲存 $count 個音訊檔。';
  }

  @override
  String get materialsPracticeMode => '練習範圍';

  @override
  String get materialsPracticeLearned => '僅已學字元';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return '僅已學字元（$count 項不可用：含尚未學習的字元）';
  }

  @override
  String get materialsPracticeAll => '所有摩斯字元';

  @override
  String get materialsPracticeNothing => '此模式下沒有可練習的條目。';

  @override
  String get guestClearConfirm => '清除';

  @override
  String get placementTitle => '測試我的程度';

  @override
  String get placementCheckLevel => '測試我現在的程度';

  @override
  String get placementFromZero => '跳過引導：直接第 1 課挑戰';

  @override
  String get placementOfferTitle => '剛接觸摩斯碼，還是已經會抄收？';

  @override
  String get placementOfferBody => '簡短測試可以建議起點。測試是可選的，在你選擇前不會改變任何設定。';

  @override
  String get placementIntro => '約 3–5 分鐘，分五步抄收：先按柯赫順序分組、速度逐級提高，最後是短單字。這只是基於少量樣本的粗略參考，不是認證。隨時可以停止。';

  @override
  String get placementStart => '開始';

  @override
  String get placementSkip => '略過';

  @override
  String get placementStop => '停止';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return '第 $step/$total 步 · 有效速度 $wpm WPM';
  }

  @override
  String get placementTierPassed => '抄得很好，下一步更快。';

  @override
  String get placementTierStopped => '這一步低於 90%，測試到此結束。';

  @override
  String get placementNextTier => '下一步';

  @override
  String placementSuggestion(int lesson) {
    return '建議從第 $lesson 課開始';
  }

  @override
  String placementVerified(int count, int total) {
    return '依順序確認了 $total 個柯赫字元中的 $count 個。';
  }

  @override
  String get placementLimits => '基於少量樣本：未測到的字元仍視為未測試，也不會被標記為已掌握。你可以隨時變更課程。';

  @override
  String placementAdopt(int lesson) {
    return '從第 $lesson 課開始';
  }

  @override
  String materialsImportConfirm(int count) {
    return '匯入 $count 個素材？';
  }

  @override
  String get materialsExportTxt => '匯出為文字（TXT）';

  @override
  String get conditionsTitle => '收聽環境';

  @override
  String get conditionsClear => '清晰';

  @override
  String get conditionsLight => '輕度干擾';

  @override
  String get conditionsRadio => '實戰電台';

  @override
  String get conditionsClearHint => '乾淨穩定的音調，即一般練習。';

  @override
  String get conditionsLightHint => '輕微底噪與緩慢衰落。成績與清晰練習分開記錄。';

  @override
  String get conditionsRadioHint => '雜訊、深度衰落、鄰近電台干擾與略不均勻的節奏。成績與清晰練習分開記錄。';

  @override
  String get conditionsPreview => '試聽';

  @override
  String conditionsActive(String name) {
    return '收聽環境：$name';
  }

  @override
  String get conditionsNeedSound => '電台環境只能聽不能看：請在訓練設定中開啟聲音，或改用「清晰」環境練習。';

  @override
  String get conditionsCleanReplay => '無效果重播';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在此環境與速度下共 $count 次：平均 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => '電台環境練習計入活動，但不會改變課程進度、複習計畫或速度建議。';

  @override
  String get keysTitle => '按鍵與外接電鍵';

  @override
  String get keysMeSubtitle => '按鍵綁定、雙槳與 USB 電鍵轉接器';

  @override
  String get keysIntro => '選擇用哪些鍵拍發摩斯。模擬鍵盤的 USB 電鍵／雙槳轉接器與鍵盤相同，請在此設定其按鍵。應用程式無法分辨按鍵來自哪個裝置，因此設定方案就是一組按鍵綁定。';

  @override
  String get keysStandardProfile => '標準';

  @override
  String get keysUnnamed => '未命名方案';

  @override
  String get keysEdit => '編輯';

  @override
  String get keysNewProfile => '新增方案';

  @override
  String get keysLimitations => '不支援 MIDI、序列埠與藍牙電鍵，也不支援轉接器韌體設定與電台控制。已測試的轉接器列在文件中。';

  @override
  String get keysEditTitle => '按鍵方案';

  @override
  String get keysName => '方案名稱';

  @override
  String get keysActionStraight => '手鍵';

  @override
  String get keysActionDit => '點槳';

  @override
  String get keysActionDah => '劃槳';

  @override
  String get keysPressKey => '請按一個鍵…';

  @override
  String get keysNone => '未設定';

  @override
  String get keysSet => '設定';

  @override
  String keysReserved(String key) {
    return '$key 已被系統或應用程式佔用，請換一個鍵。';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key 已用於「$action」。';
  }

  @override
  String keysConflictSave(String keys) {
    return '每個鍵只能有一種用途：$keys 被重複綁定。';
  }

  @override
  String get keysMissing => '請設定此電鍵模式需要的鍵（自動鍵需同時設定兩隻槳）。';

  @override
  String get keysSwapPaddles => '交換雙槳（左手）';

  @override
  String get keysKeyerMode => '電鍵模式';

  @override
  String get keysIambicA => '自動鍵 A';

  @override
  String get keysIambicB => '自動鍵 B';

  @override
  String get keysAdapterKeyer => '轉接器自行產生點劃';

  @override
  String get keysAdapterKeyerHint => '適用於內建電鍵邏輯的轉接器：直接使用它計時好的按下與放開，應用程式不會再產生一遍自動鍵序列。';

  @override
  String get keysAppSidetone => '拍發時的應用程式側音';

  @override
  String get keysAppSidetoneHint => '轉接器內建側音時請關閉。不影響解碼。';

  @override
  String get keysTestTitle => '測試';

  @override
  String get keysTestNote => '僅用於測試：不會傳送，也不計入訓練。';

  @override
  String get keysTestRelease => '放開按鍵';

  @override
  String get keysAdapterActive => '正在使用轉接器內建的電鍵邏輯：槳對應的鍵按手鍵處理。';

  @override
  String keysHintCustom(String keys) {
    return '按鍵：$keys';
  }

  @override
  String get telegraphTitle => '中文電碼';

  @override
  String get telegraphIntro => '每個漢字以四位數字碼拍發。分別練習聽寫數字，以及記住哪個碼對應哪個字。';

  @override
  String get telegraphCodebook => '碼本';

  @override
  String get telegraphCodebookMainland => '大陸';

  @override
  String get telegraphCodebookTaiwan => '臺灣';

  @override
  String get telegraphDigitsTitle => '抄收電碼組';

  @override
  String get telegraphDigitsHint => '收聽真實電碼的四位數字組並輸入數字。';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共 $count 次：數字正確率 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => '記憶碼本';

  @override
  String get telegraphRecallHint => '由字查碼、由碼認字。與摩斯進度分開記錄。';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已答 $count 張：掌握 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => '碼本記憶不會解鎖摩斯課程，也不改變速度建議；數字抄收與其他摩斯抄收同等計入。';

  @override
  String get telegraphRecallCharPrompt => '輸入這個字的電碼';

  @override
  String get telegraphRecallCodePrompt => '選出這個電碼對應的字';

  @override
  String get telegraphReveal => '顯示答案';

  @override
  String get telegraphRevealAssisted => '已顯示：本題計為有提示。';

  @override
  String get telegraphCorrect => '正確';

  @override
  String get telegraphIncorrect => '不對';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$total 題中答對 $correct 題';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 題看過答案',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => '電碼解讀';

  @override
  String get telegraphInterpretNote => '僅在此顯示：不會修改原訊息，也不會傳送任何內容。';

  @override
  String get telegraphUnresolved => '無法解讀：沒有字對應此碼';

  @override
  String get telegraphMalformed => '不是四位數字組';

  @override
  String get telegraphNotCode => '文字，保持原樣';

  @override
  String get telegraphAmbiguous => '多個字共用此碼';

  @override
  String get conditionsAudioFailed => '本裝置無法播放音訊。請改用「清晰」環境練習。';

  @override
  String get aboutPrivacyPolicy => '隱私權政策';

  @override
  String get aboutTermsOfUse => '使用條款';

  @override
  String get aboutSupport => '技術支援與聯絡';

  @override
  String get aboutLinkFailed => '無法開啟連結，已複製連結。';

  @override
  String get offlineClearData => '清除學習資料';

  @override
  String get offlineClearDataBody => '刪除此裝置上的學習進度、計畫和材料。';

  @override
  String get offlineCleared => '學習資料已清除。';

  @override
  String get offlineClearFailed => '無法清除學習資料。';

  @override
  String get learnStorageUnavailable => '無法在此裝置上開啟你的訓練資料，請再試一次。';

  @override
  String get materialsImportedSource => '匯入來源';

  @override
  String get learnStartHereTitle => '剛開始？先上一節 3 分鐘的第一課';

  @override
  String get learnStartHereBody => '聽聽聲音，認識 K 和 M，再做幾輪簡單練習。不計成績。';

  @override
  String get learnStartHere => '從這裡開始';

  @override
  String get learnReplayFirstLesson => '重溫第一課';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '已引入 $introduced 個 · 已掌握 $mastered 個';
  }

  @override
  String get learnChipNew => '新字元';

  @override
  String get learnChipPractising => '練習中';

  @override
  String get learnChipMastered => '已掌握';

  @override
  String get learnChipWeak => '低於 90%';

  @override
  String get learnChipDue => '待複習';

  @override
  String get learnTapChipHint => '點按字元即可試聽';

  @override
  String learnHearChar(String char) {
    return '聽 $char';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a 對比 $b';
  }

  @override
  String get learnGuidedPractice => '簡短練習（10 個字元）';

  @override
  String learnChallengeHint(int count, int min) {
    return '本課挑戰：$count 個字元、正確率 90%，且每個新字元至少抄收 $min 次。通過即可解鎖下一個字元。';
  }

  @override
  String get learnAllUnlockedNotPassed => '所有字元都已解鎖。通過最後一課的挑戰即可完成課程。';

  @override
  String get learnGoalFirstUse => '當前目標：用耳朵分辨 K 和 M。下一步：第 1 課挑戰。';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return '當前目標：穩定認出 $chars（$min 次抄收、正確率 90%）。下一步：第 $lesson 課挑戰。';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return '當前目標：通過第 $lesson 課挑戰。下一步：$next。';
  }

  @override
  String learnGoalNextChar(String char) {
    return '字元 $char';
  }

  @override
  String get learnGoalNextOperating => '單字、呼號和完整 QSO';

  @override
  String get learnGoalOperating => '當前目標：真實報文——單字、呼號、QSO。下一步：逐級提高有效速度。';

  @override
  String get learnMorePractice => '更多練習';

  @override
  String get learnQsoReady => '已就緒';

  @override
  String get learnQsoPractiseFirst => '先練習報文行';

  @override
  String learnQsoSymbolsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '還差 $count 個字元',
    );
    return '$_temp0';
  }

  @override
  String get learnGlossaryTitle => '這些術語是什麼意思？';

  @override
  String get glossaryKoch => 'Koch 法：字元一開始就按全速學習，先學兩個，每課再加一個；抄收正確率達到 90% 才進入下一課。';

  @override
  String get glossaryWpm => 'WPM：每分鐘詞數，以標準詞 PARIS 計算。字元速度指每個字元本身響起的快慢。';

  @override
  String get glossaryFarnsworth => 'Farnsworth：字元保持快速，但字元之間的停頓被拉長，給你時間反應。有效速度把這些停頓算在內。';

  @override
  String get glossaryQso => 'QSO：兩個電台之間的一次雙向通聯。CQ = 呼叫任意電台，DE = 來自，K = 請講。';

  @override
  String get glossaryRst => 'RST：信號報告——可辨度、強度、音調。599 表示完美。73 表示致意。';

  @override
  String get learnVerdictNotCredited => '未記錄：沒有抄收任何字元。';

  @override
  String get learnVerdictAssisted => '輔助練習';

  @override
  String get learnVerdictAssistedHint => '使用了重播或揭示答案，所以本次只計入練習量：不解鎖課程，也不更新複習。下一次試試不重播。';

  @override
  String get learnVerdictPractice => '練習已記錄';

  @override
  String get learnVerdictPracticeHint => '自由練習會更新統計和複習，但不會推進課程。課程只透過學習主頁的本課挑戰推進。';

  @override
  String get learnVerdictCourseComplete => '最後一課挑戰通過：整個字元課程已完成。';

  @override
  String learnVerdictTooShort(int count, int min) {
    return '未達到完整挑戰：$count / $min 個字元';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return '一次挑戰至少 $min 個字元。請從學習主頁開始本課，或在訓練設定中加長練習長度。';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return '$chars 抄收次數不足';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return '挑戰要求每個新字元至少抄收 $min 次。再試一次：挑戰會特意包含它們。';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return '新字元低於 90%：$chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => '其餘都不錯；新字元決定本課結果。先聽它和相近字元的對比，再練一練，然後重新挑戰。';

  @override
  String get learnVerdictBelowAccuracyHint => '總體正確率低於 90%。先針對下面的薄弱字元做個簡短練習，再重新挑戰。';

  @override
  String get learnDrillWeak => '練習薄弱字元';

  @override
  String get learnRetryChallenge => '重新挑戰';

  @override
  String get learnTakeChallenge => '開始本課挑戰';

  @override
  String learnChallengeTitle(int lesson) {
    return '第 $lesson 課挑戰';
  }

  @override
  String get learnPracticeTitle => '練習';

  @override
  String get learnMeaningsTitle => '含義';

  @override
  String get firstLessonTitle => '第一課';

  @override
  String firstLessonStep(int step, int total) {
    return '第 $step / $total 步';
  }

  @override
  String get firstLessonHearTitle => '能聽到嗎？';

  @override
  String get firstLessonHearBody => '點按播放。你應該能聽到一小段嗶嗶聲（如果開啟了閃屏或震動，也會看到或感覺到）。';

  @override
  String get firstLessonHeard => '聽到了';

  @override
  String get firstLessonNotHeard => '什麼都沒聽到';

  @override
  String get firstLessonNoSoundTitle => '沒有聲音？';

  @override
  String get firstLessonNoSoundBody => '請調高音量，檢查靜音開關或勿擾模式。你也可以改用螢幕閃爍或震動來代替聲音。';

  @override
  String get firstLessonUseFlash => '同時閃爍螢幕';

  @override
  String get firstLessonUseVibration => '同時震動';

  @override
  String get firstLessonPlay => '播放';

  @override
  String get firstLessonSoundsTitle => '短與長';

  @override
  String get firstLessonSoundsBody => '摩斯密碼只有兩種聲音：短的「滴」和長的「答」，答是滴的三倍長。字元是它們的組合，字元之間用短暫的停頓隔開。點按每一個試聽。';

  @override
  String get firstLessonDit => '滴（短）';

  @override
  String get firstLessonDah => '答（長）';

  @override
  String get firstLessonWorkedTitle => '看一個示範';

  @override
  String get firstLessonWorkedBody => '先聽，聲音結束後會顯示答案。現在還不需要作答。';

  @override
  String firstLessonWorkedReveal(String char) {
    return '剛才是 $char';
  }

  @override
  String get firstLessonTrialsTitle => 'K 還是 M？';

  @override
  String get firstLessonTrialsBody => '聽完後點按你聽到的字元。想重播多少次都可以——這不是考試。';

  @override
  String firstLessonTrialRound(int round, int total) {
    return '第 $round / $total 輪';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return '對，剛才是 $char';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return '剛才是 $char，不是 $answer。聽聽兩者的對比。';
  }

  @override
  String get firstLessonTooFast => '太快了？改用入門節奏（字元之間停頓更長）';

  @override
  String get firstLessonNextTitle => '接下來';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '本輪答對 $correct / $total。選擇下一步，按自己的節奏繼續。';
  }

  @override
  String get firstLessonNextGuided => '簡短練習：10 個單字元';

  @override
  String get firstLessonNextSend => '試試發報';

  @override
  String get firstLessonSendGuide => '發報：短按是滴，長按是答。用撥片時，一側發滴、另一側發答。鬆開，並在字元之間稍作停頓。手鍵或 iambic A / B 以後可以再改，現在不重要。';

  @override
  String get firstLessonReplayAnytime => '隨時可以從學習主頁重溫這一課。';

  @override
  String get firstLessonContinue => '繼續';

  @override
  String get firstLessonTrialNext => '下一輪';

  @override
  String get sendFirstUseTitle => '第一次發報？';

  @override
  String get sendFirstUseStraight => '短按電鍵是滴，大約三倍長是答。字元之間稍作停頓，單字之間停頓更長。';

  @override
  String get sendFirstUsePaddles => '按住標有「點」的鍵發點，按住標有「劃」的鍵發劃；鍵控器會自動控制時長。字元間稍作停頓，單詞間停頓更長。';

  @override
  String get sendFirstUseDismiss => '知道了';

  @override
  String get learnSpeedPresets => '節奏';

  @override
  String get learnPresetBeginner => '入門 20 / 6';

  @override
  String get learnPresetStandard => '標準 20 / 8';

  @override
  String get learnPresetHelp => '兩種節奏的字元都按 20 WPM 發出；入門節奏在字元之間留更長的停頓（有效速度 6 WPM）。';

  @override
  String get learnPlanStepIntro => '第一課';

  @override
  String get learnPlanStepRecognition => '單字元辨識';

  @override
  String get learnPlanReasonFirstLesson => '聽聲音，分辨 K 和 M（約 3 分鐘）';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return '一次一個字元：$symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return '$count 個字元的短混合組；50 字元挑戰稍後再說';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return '可選：先聽示範，再發 $count 個短目標';
  }

  @override
  String get learnQsoReadyTitle => '可以開始 QSO 了';

  @override
  String get learnQsoNotReadyTitle => '還有字元沒學到';

  @override
  String get learnQsoMissingBody => 'QSO 會用到這些你還沒學的字元——點按即可試聽。你也可以先體驗：鍵盤會顯示全部字元。';

  @override
  String get learnQsoShorthandHint => '先練習縮語（CQ、DE、UR、RST、TNX、73），這樣報文才看得懂。';

  @override
  String get learnQsoPractiseShorthand => '練習縮語';

  @override
  String get learnQsoHowTitle => 'QSO 是怎麼進行的';

  @override
  String get learnQsoHowBody => '呼叫（CQ = 任意電台，DE = 來自），用呼號應答，交換信號報告（RST）、姓名和 QTH（地點），最後 73（致意）和 <SK>（結束）。K 表示請講。';

  @override
  String get learnQsoExploreLabel => '包含未學字元';

  @override
  String get statsCoursePassed => '課程已通過';

  @override
  String get firstLessonPlayAgain => '再播一次';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return '第 $lesson 課挑戰：$count 個字元，90% 即可解鎖 $char';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return '第 $lesson 課挑戰：$count 個字元、90% 即完成課程';
  }

  @override
  String get learnQsoShorthandTitle => '先練習縮語';

  @override
  String get learnQsoExchangeTitle => '先練習 QSO 報文行';

  @override
  String get learnQsoExchangeHint => '先逐行抄收通聯內容（一次一個交換），再到模擬器裡跑完整 QSO。';

  @override
  String get sendGuideTitle => '發報帶練';

  @override
  String sendGuideStep(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get sendGuideHear => '先聽示範';

  @override
  String get sendGuideListening => '先聽完整節奏…';

  @override
  String get sendGuideTry => '現在試著發';

  @override
  String get sendGuideRetry => '重練這個目標';

  @override
  String get sendGuidePassed => '解碼正確，可以繼續下一個目標。';

  @override
  String get sendGuideComplete => '兩個字元和短組都已正確發出，可以繼續自由發報練習。';

  @override
  String get sendGuideRhythm => '跟隨示範節奏：點要短，劃約為點的三倍，字元之間留清晰的停頓。';

  @override
  String get learnContinueToday => '繼續今天的學習';

  @override
  String get learnPlanDetails => '查看計畫詳情';

  @override
  String get learnGuidedSingle => '單字元 · 10 字元';

  @override
  String get learnGuidedShort => '3 字元短組 · 15 字元';

  @override
  String get learnGuidedGroups => '5 字元一組 · 20 字元';

  @override
  String get learnGuidedRecommended => '推薦下一步';

  @override
  String get learnGuidedProgressHint => '通過後繼續短組和完整組。帶練用於鞏固，通關挑戰才會解鎖下一課。';

  @override
  String get learnGuidedContinue => '繼續帶練';

  @override
  String get learnGuidedRetry => '再練這一級';

  @override
  String get firstLessonZeroHint => '還沒有答對也沒關係。先再聽一遍 K 和 M 的差別，然後重試。';

  @override
  String get firstLessonPartialHint => '已經聽對了一部分。再比較一下 K 和 M，按自己的節奏繼續。';

  @override
  String get firstLessonPerfectHint => '這輪全部答對了。接著用不顯示選項的聽抄練習鞏固。';

  @override
  String get firstLessonPaceLocked => '本輪已開始作答，速度保持不變；下一輪可在設定中調整。';

  @override
  String get learnRecentEvidenceHint => '階段按近 14 天、同速且無輔助的聽抄證據判斷。';

  @override
  String get learnQsoConsolidateTitle => '鞏固已學字元';

  @override
  String get learnQsoConsolidateHint => '已解鎖不代表已掌握。先用單字元聽抄取得近期獨立成績。';

  @override
  String get learnQsoPractiseSymbols => '練習這些字元';

  @override
  String get learnQsoProtocolTitle => '理解通聯用語';

  @override
  String get learnQsoProtocolHint => '確認 CQ、DE、RST 和 73 的含義，再開始短通聯。';

  @override
  String get learnQsoProtocolStart => '檢查用語理解';

  @override
  String learnQsoProtocolQuestion(String token) {
    return '$token 在通聯中表示什麼？';
  }

  @override
  String get learnQsoGeneralCall => '呼叫任意電臺';

  @override
  String get learnQsoFromStation => '來自這個電臺';

  @override
  String get learnQsoSignalReport => '訊號報告';

  @override
  String get learnQsoBestRegards => '致意並告別';

  @override
  String get learnQsoProtocolCorrect => '回答正確';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return '正確含義：$meaning';
  }

  @override
  String get learnQsoProtocolPass => '四個用語均獨立答對，可以嘗試短通聯。';

  @override
  String get learnQsoProtocolPractice => '先複習這些含義，再重新檢查。';

  @override
  String get learnQsoProtocolRetry => '重新檢查';

  @override
  String get learnQsoShortExchange => '練習短通聯';

  @override
  String get learnQsoShortExchangeHint => '獨立完成呼號確認、訊號報告和告別，再進行完整通聯。';

  @override
  String get learnQsoExplorePending => '自由體驗完整通聯 · 仍有待練項目';

  @override
  String get learnQsoReadyHint => '已具備近期獨立練習證據，可以開始完整模擬通聯。';

  @override
  String get goalsTitle => '學習目標';

  @override
  String get goalsFirstQso => '第一次通聯';

  @override
  String get goalsConversation => '日常交談與腦內聽抄';

  @override
  String get goalsContest => '競賽交換';

  @override
  String get goalsExplanation => '參考 CW Academy。每個里程碑需要在標示有效速度下，近期至少兩次獨立練習達到 90% 準確率；證據有效期為 28 天。';

  @override
  String get goalsBeginner => '先完成字元課程；通過後，每日計畫會加入對應目標的聽懂訓練和模擬通聯。';

  @override
  String get goalsComplete => '目前已達到全部里程碑';

  @override
  String get goalsPractice => '練習下一項能力';

  @override
  String get goalsCopying => '字元聽辨';

  @override
  String get goalsSending => '清晰發報';

  @override
  String get goalsWords => '整詞聽辨';

  @override
  String get goalsPhrases => '短句理解';

  @override
  String get goalsInformation => '通聯資訊提取';

  @override
  String get goalsStory => '短故事腦內聽抄';

  @override
  String get goalsQso => '完整通聯';

  @override
  String get goalsCompetition => '競賽操作';

  @override
  String get goalsPlanListening => '按學習目標練習整詞與通聯資訊聽辨。';

  @override
  String get goalsPlanExchange => '進行與學習目標對應的互動通聯。';

  @override
  String get mistakesTitle => '跨次錯題本';

  @override
  String get mistakesPending => '待複習';

  @override
  String get mistakesRecovered => '已掌握';

  @override
  String get mistakesHint => '以原速度與原干擾條件重練原題。在兩個不同日期獨立、完整答對後標記為已掌握。重播或顯示答案不計入掌握證據。';

  @override
  String get mistakesEmptyPending => '暫無待複習的錯題。練習中答錯的原題會儲存在這裡。';

  @override
  String get mistakesEmptyRecovered => '暫無已掌握的錯題。在兩個不同日期獨立答對原題即可掌握。';

  @override
  String get mistakesOriginalCopy => '首次錯誤答案';

  @override
  String get mistakesLastCopy => '最近答案';

  @override
  String get mistakesNoAnswer => '未作答';

  @override
  String get mistakesFailures => '錯誤次數';

  @override
  String get mistakesFirstFailure => '首次答錯';

  @override
  String get mistakesLastFailure => '最近答錯';

  @override
  String get mistakesCorrectDays => '獨立答對的日期數';

  @override
  String get mistakesRecoveredOn => '掌握日期';

  @override
  String get mistakesRetry => '重練原題';

  @override
  String get qsoAdvancedContestTitle => '競賽交換';

  @override
  String get qsoAdvancedContestHint => '交換呼號、RST 和序號，再確認更正後的序號。';

  @override
  String get qsoAdvancedPotaTitle => 'POTA 公園間通聯';

  @override
  String get qsoAdvancedPotaHint => '交換呼號、RST 和公園編號，再確認更正後的公園。';

  @override
  String get qsoAdvancedSerialLabel => '你的序號';

  @override
  String get qsoAdvancedParkLabel => '你的公園編號';

  @override
  String get qsoAdvancedInvalidSerial => '輸入 1–9999 的序號。';

  @override
  String get qsoAdvancedInvalidPark => '使用公園前綴和 4–5 位數字，例如 US-1234。';

  @override
  String get qsoAdvancedRepeatTitle => '只重發一項';

  @override
  String get qsoAdvancedRepeatHint => '只請求沒聽清的資訊，通聯仍停留在目前階段。';

  @override
  String get qsoAdvancedTypedMode => '文字作答（輔助）';

  @override
  String get qsoAdvancedKeyedMode => '拍發回覆';

  @override
  String get qsoAdvancedTypedReply => '你的發報內容';

  @override
  String get qsoAdvancedContestStage => '傳送 RST 和你的序號';

  @override
  String get qsoAdvancedPotaStage => '傳送 RST 和你的公園編號';

  @override
  String get qsoAdvancedCorrectionStage => '確認更正後的資訊';

  @override
  String get qsoAdvancedCorrectionHint => '聽到 CORR 後，確認對方的 RST 和更正後的序號或公園。先確保拍發清晰，再提高速度。';

  @override
  String get qsoAdvancedIssueMissingSerial => '傳送 NR 和你的序號。';

  @override
  String get qsoAdvancedIssueInvalidSerial => '序號必須是大於零的 1–4 位數字。';

  @override
  String get qsoAdvancedIssueWrongSerial => '序號與應確認的號碼不一致。';

  @override
  String get qsoAdvancedIssueMissingPark => '傳送 PARK 和公園編號。';

  @override
  String get qsoAdvancedIssueInvalidPark => '使用完整公園前綴和 4–5 位數字。';

  @override
  String get qsoAdvancedIssueWrongPark => '公園編號與應確認的公園不一致。';

  @override
  String get qsoAdvancedIssueWrongRemoteRst => '確認剛才聽到的對方 RST。';

  @override
  String get qsoAdvancedContestSummary => '競賽練習：已確認呼號、報告、序號和更正資訊。';

  @override
  String get qsoAdvancedPotaSummary => 'POTA 練習：已確認呼號、報告、公園和更正資訊。';

  @override
  String get comprehensionTitle => '整詞整句聽懂';

  @override
  String get comprehensionIntro => '聽完完整訊息，在腦中保留含義，再回答問題。素材為原創，可離線使用。';

  @override
  String get comprehensionModeLabel => '練習模式';

  @override
  String get comprehensionWords => '整詞辨識';

  @override
  String get comprehensionPhrases => '詞語片段與短句';

  @override
  String get comprehensionQso => '通聯資訊';

  @override
  String get comprehensionPota => 'POTA 交換';

  @override
  String get comprehensionStory => '短故事';

  @override
  String get comprehensionWordsHelp => '透過聲音整體辨識單字，不逐字母抄寫。';

  @override
  String get comprehensionPhrasesHelp => '先辨識熟悉的詞語片段，再聽懂短語與完整句子。';

  @override
  String get comprehensionQsoHelp => '記住操作員呼號、姓名、地點和訊號報告。';

  @override
  String get comprehensionPotaHelp => '記住雙方呼號、公園編號和訊號報告。第一個呼號是被呼叫的電台。';

  @override
  String get comprehensionStoryHelp => '不逐字抄寫，記住人物、地點、時間和目的。使用訊息中的英語詞語作答。';

  @override
  String get comprehensionSpeedLabel => '有效速度';

  @override
  String comprehensionSpeed(String character, String effective) {
    return '字元 $character / 有效 $effective WPM';
  }

  @override
  String comprehensionPreviewMissing(String symbols) {
    return '訊息包含尚未學過的符號：$symbols。可作為輔助預覽聽練。';
  }

  @override
  String get comprehensionAssisted => '輔助練習 · 重播、查看文字或包含未學符號';

  @override
  String get comprehensionIndependent => '獨立嘗試 · 只聽一次，未查看文字';

  @override
  String get comprehensionReveal => '查看文字（輔助）';

  @override
  String get comprehensionTarget => '播發文字';

  @override
  String get comprehensionAnswer => '單字或短句';

  @override
  String get comprehensionCallsign => '被呼叫電台 / 呼號';

  @override
  String get comprehensionOtherCallsign => '發信電台 / 呼號';

  @override
  String get comprehensionName => '操作員姓名';

  @override
  String get comprehensionQth => '地點（QTH）';

  @override
  String get comprehensionRst => '訊號報告（RST）';

  @override
  String get comprehensionPark => '公園編號';

  @override
  String get comprehensionPerson => '誰？';

  @override
  String get comprehensionDestination => '去了哪裡？';

  @override
  String get comprehensionTime => '何時？';

  @override
  String get comprehensionAction => '去做什麼？';

  @override
  String comprehensionScore(int correct, int total) {
    return '$total 個資訊項答對 $correct 個';
  }

  @override
  String get comprehensionNext => '下一則訊息';

  @override
  String get comprehensionDone => '完成';

  @override
  String get comprehensionSaveFailed => '結果未能儲存，請在離開前重試。';

  @override
  String get comprehensionAudioFailed => '音訊無法使用，請檢查裝置輸出後重試。';

  @override
  String get comprehensionAudioRequired => '此聽懂練習使用聲音，即使其他練習設定已關閉聲音。';

  @override
  String comprehensionHistory(int count, int percent) {
    return '近期獨立嘗試：$count 次 · 資訊準確率 $percent%';
  }

  @override
  String get comprehensionEmptyHistory => '獨立聽懂的結果將在這裡顯示，輔助練習分開記錄。';

  @override
  String get comprehensionFieldCorrect => '正確';

  @override
  String get comprehensionFieldWrong => '需要重練';
}
