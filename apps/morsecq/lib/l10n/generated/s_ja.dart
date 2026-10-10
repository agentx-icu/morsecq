// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => '学習';

  @override
  String get navMe => '自分';

  @override
  String get navReference => '資料';

  @override
  String get navLearnDescription => 'Koch 法のレッスン、送信練習、受信練習。';

  @override
  String get navReferenceDescription => '文字表、手続き符号、Q 符号、略語、双方向変換ツール。';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionClose => '閉じる';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystemDefault => 'システムの設定に従う';

  @override
  String get languageSaveFailed => '言語設定を保存できませんでした。もう一度お試しください。';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'レッスン $lesson / $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 文字を習得',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal 文字';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 日連続で練習',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '復習する文字：$count 文字',
      zero: '復習する文字はありません',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$total 文字中 $correct 文字正解';
  }

  @override
  String learnRoundOf(int round) {
    return 'ラウンド $round';
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
      other: '$count 文字を送信',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return '次の文字を解放しました：$char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target を聞き逃しました';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target を $answered と聞き違えました';
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
      other: '$count 文字',
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
      other: '$count 文字を習得',
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
      other: '$count 文字を受信記録',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 回の練習',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最長 $count 日連続',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal 文字';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'あと $remaining 文字',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最近 $count 回の練習',
      one: '前回の練習',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return '練習 $index / $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total 正解';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'レッスン $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 回の試行',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$attempts 回中 $correct 回正解';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'レッスン $lesson で登場';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'ボックス $box / $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 日後に復習',
      one: '明日復習',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 回',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 回',
    );
    return '$target を $answered と回答：$_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars 文字',
      zero: '練習なし',
    );
    return '$date：$_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '練習した日：$count 日',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
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
    return 'スキップしました（モールス符号なし）：$chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Koch 法での順番：$position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return '推定 $wpm WPM';
  }

  @override
  String get accountSectionTraining => '練習';

  @override
  String get accountSectionAbout => 'アプリについて';

  @override
  String get accountTrainingDefaults => '再生と練習の初期設定';

  @override
  String get accountTrainingDefaultsSubtitle => '速度、音の高さ、Farnsworth 間隔';

  @override
  String get accountAboutLicence => 'ライセンス';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'ソースコード';

  @override
  String get accountAboutSourceCopied => 'ソースコードのリンクをコピーしました';

  @override
  String get chatSend => '送信';

  @override
  String get learnLessonCardTitle => 'Koch 法のレッスン';

  @override
  String get learnCourseComplete => 'コース完了！引き続き腕を磨きましょう。';

  @override
  String get learnDailyGoalTitle => '今日';

  @override
  String get learnDailyGoalMet => '今日の目標を達成';

  @override
  String get learnNoStreak => '今日から毎日練習しましょう';

  @override
  String get learnContinueLesson => 'レッスンを続ける';

  @override
  String get learnReceivePractice => '受信練習';

  @override
  String get learnSendPractice => '送信練習';

  @override
  String get learnReviewDue => '復習の時期が来た文字';

  @override
  String get learnSettings => '練習設定';

  @override
  String get learnLoading => '学習の進捗を読み込み中…';

  @override
  String get learnLoadFailed => '保存済みの進捗を読み取れませんでした。最初から始めます。元のファイルは .corrupt として保存されています。';

  @override
  String get learnProgressSaveFailed => '進捗を保存できませんでした。MorseCQ を閉じるまでは今回の結果が有効です。';

  @override
  String get learnChooseDrill => '練習を選択';

  @override
  String get learnDrillGroups => 'ランダムな文字列';

  @override
  String get learnDrillWords => '単語';

  @override
  String get learnDrillCallsigns => 'コールサイン';

  @override
  String get learnDrillQso => '交信（QSO）';

  @override
  String get learnDrillCharacters => '1 文字ずつ';

  @override
  String get learnDrillAbbreviations => '略語と Q 符号';

  @override
  String get learnDrillNumbers => '数字のグループ';

  @override
  String get learnDrillConfusables => '聞き違えやすい文字';

  @override
  String get learnDrillContest => 'コンテストの交信';

  @override
  String get learnDrillGroupsHint => '学習済みの文字から作るランダムな文字列';

  @override
  String get learnDrillCharactersHint => '1 文字ずつ聞いて、すぐに答えましょう';

  @override
  String get learnDrillWordsHint => 'よく使う英単語';

  @override
  String get learnDrillAbbreviationsHint => 'TNX、FB、QTH、QSL など、無線交信で使う略語';

  @override
  String get learnDrillNumbersHint => '電文や通し番号で使う 5 桁の数字グループ';

  @override
  String get learnDrillCallsignsHint => '世界各地のアマチュア無線のコールサイン';

  @override
  String get learnDrillConfusablesHint => 'S/H、U/V など、聞き違えやすい文字をペアで練習';

  @override
  String get learnDrillQsoHint => '一連の交信で使う文章';

  @override
  String get learnDrillContestHint => 'コンテストの速度でコールサイン、5NN、通し番号やゾーンを受信';

  @override
  String get learnDrillReviewHint => '復習の時期が来た文字';

  @override
  String get toolsTitle => '無線のツール';

  @override
  String get toolsGridTitle => 'グリッドロケーター';

  @override
  String get toolsGridHint => '座標からロケーターを算出し、距離とアンテナの方位を確認';

  @override
  String get toolsBandsTitle => '周波数帯とアンテナ';

  @override
  String get toolsBandsHint => '周波数が属するバンド、波長、ダイポールの長さを確認';

  @override
  String get toolsSpeedTitle => 'CW の速度';

  @override
  String get toolsSpeedHint => 'WPM を短点の長さ、間隔、1 分あたりの文字数に換算';

  @override
  String get toolsRstTitle => 'RST レポート';

  @override
  String get toolsRstHint => '信号レポートを作成し、各桁の意味を確認';

  @override
  String get toolsClockTitle => 'UTC 時計';

  @override
  String get toolsClockHint => 'ログに記録する UTC と現地時刻を並べて表示';

  @override
  String get toolsGridFromCoordinates => '座標から算出';

  @override
  String get toolsGridLatitude => '緯度';

  @override
  String get toolsGridLongitude => '経度';

  @override
  String get toolsGridCoordinatesHelp => '十進数の度数で入力。南緯と西経は負の値です';

  @override
  String get toolsGridInvalidCoordinates => '緯度は -90～90、経度は -180～180';

  @override
  String get toolsGridLocator => 'ロケーター';

  @override
  String get toolsGridDistanceSection => '距離と方位';

  @override
  String get toolsGridMine => '自局のロケーター';

  @override
  String get toolsGridTheirs => '相手局のロケーター';

  @override
  String get toolsGridInvalidLocator => '2、4、6、8 文字で入力してください。例：OM89ex';

  @override
  String get toolsGridCenter => 'グリッドの中心';

  @override
  String get toolsGridDistance => '距離';

  @override
  String get toolsGridShortPath => 'ショートパスの方位';

  @override
  String get toolsGridLongPath => 'ロングパスの方位';

  @override
  String get toolsBandsFrequency => '周波数（MHz）';

  @override
  String get toolsBandsInvalidFrequency => '0 より大きい周波数を入力してください';

  @override
  String toolsBandsRegionLabel(int number) {
    return '第 $number 地域';
  }

  @override
  String get toolsBandsRegionHelp => '1：ヨーロッパ・アフリカ・中東 — 2：南北アメリカ — 3：アジア・太平洋';

  @override
  String toolsBandsInBand(String band) {
    return '$band アマチュア無線バンド内';
  }

  @override
  String get toolsBandsOutOfBand => 'アマチュア無線バンド外';

  @override
  String get toolsBandsWavelength => '波長';

  @override
  String get toolsBandsDipole => '半波長ダイポール（全長）';

  @override
  String get toolsBandsQuarterWave => '1/4 波長の垂直アンテナ';

  @override
  String get toolsBandsAntennaNote => '長さには 0.95 の短縮係数を含みます。共振するように長さを調整してください。';

  @override
  String get toolsBandsTable => '周波数帯の範囲';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'ITU の周波数分配です。免許や各国のバンドプランでは、利用できる範囲が狭い場合があります。';

  @override
  String get toolsSpeedCharacter => '文字速度';

  @override
  String get toolsSpeedFarnsworth => 'Farnsworth 間隔';

  @override
  String get toolsSpeedOverall => '全体の速度';

  @override
  String get toolsSpeedDit => '短点';

  @override
  String get toolsSpeedDah => '長点';

  @override
  String get toolsSpeedCharGap => '文字間の間隔';

  @override
  String get toolsSpeedWordGap => '単語間の間隔';

  @override
  String get toolsSpeedCpm => '1 分あたりの文字数';

  @override
  String get toolsSpeedParis => 'PARIS 1 語の所要時間';

  @override
  String get toolsRstReadability => '了解度（R）';

  @override
  String get toolsRstStrength => '信号強度（S）';

  @override
  String get toolsRstTone => '音調（T）';

  @override
  String get toolsRstReport => 'レポート';

  @override
  String get toolsRstCut => 'コンテスト用の略記';

  @override
  String get toolsRstPhone => '音声通信（T の報告なし）';

  @override
  String get toolsRstR1 => '了解できない';

  @override
  String get toolsRstR2 => 'かろうじて了解でき、ときどき単語が聞き取れる';

  @override
  String get toolsRstR3 => 'かなり困難だが了解できる';

  @override
  String get toolsRstR4 => 'ほぼ困難なく了解できる';

  @override
  String get toolsRstR5 => '完全に了解できる';

  @override
  String get toolsRstS1 => '非常に弱く、かろうじて感じられる';

  @override
  String get toolsRstS2 => '非常に弱い';

  @override
  String get toolsRstS3 => '弱い';

  @override
  String get toolsRstS4 => 'まずまずの強さ';

  @override
  String get toolsRstS5 => 'やや良好';

  @override
  String get toolsRstS6 => '良好';

  @override
  String get toolsRstS7 => 'かなり強い';

  @override
  String get toolsRstS8 => '強い';

  @override
  String get toolsRstS9 => '極めて強い';

  @override
  String get toolsRstT1 => '非常に粗く帯域が広い、未整流の交流音';

  @override
  String get toolsRstT2 => '非常に粗い交流音で、耳障りかつ帯域が広い';

  @override
  String get toolsRstT3 => '粗い音。整流されているが、平滑化されていない';

  @override
  String get toolsRstT4 => '粗い音だが、わずかに平滑化されている';

  @override
  String get toolsRstT5 => '平滑化されているが、リップル変調が強い';

  @override
  String get toolsRstT6 => '平滑化されているが、明らかなリップルがある';

  @override
  String get toolsRstT7 => 'ほぼ純音だが、わずかなリップルがある';

  @override
  String get toolsRstT8 => 'ほぼ完全な音で、ごくわずかな変調がある';

  @override
  String get toolsRstT9 => '完全な純音で、リップルがない';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => '現地時刻';

  @override
  String get toolsClockNote => 'ログと QSL カードには UTC を使います。';

  @override
  String get learnReceiveTitle => '受信';

  @override
  String get learnReviewTitle => '復習';

  @override
  String get learnListen => '再生中';

  @override
  String get learnReady => '準備完了';

  @override
  String get learnReplay => 'もう一度再生';

  @override
  String get learnAnswerHint => '聞こえた内容を入力';

  @override
  String get learnSubmit => '答え合わせ';

  @override
  String get learnNext => '次へ';

  @override
  String get learnFinish => '終了';

  @override
  String get learnDone => '完了';

  @override
  String get learnBackspace => '削除';

  @override
  String get learnSpace => 'スペース';

  @override
  String get learnSent => '送信内容';

  @override
  String get learnYourCopy => '受信記録';

  @override
  String get learnRoundPerfect => '全問正解！';

  @override
  String get learnSessionSummary => '練習結果';

  @override
  String get learnLessonPassed => 'レッスン合格';

  @override
  String get learnLessonNotPassed => '続けましょう：正答率 90% で次の文字を解放';

  @override
  String get learnReviewRecorded => '復習を記録しました';

  @override
  String get learnWeakChars => '練習が必要';

  @override
  String get learnConfusions => '聞き違い';

  @override
  String get learnNoFeedbackWarning => '音、画面点滅、振動がすべて無効です。代わりに画面を点滅させます。';

  @override
  String get learnSendTitle => '送信';

  @override
  String get learnSendThis => 'これを送信';

  @override
  String get learnCopyFromMemory => '記憶を頼りに';

  @override
  String get learnHiddenTarget => '非表示 — 記憶を頼りに送信';

  @override
  String get learnDecoded => '解読結果';

  @override
  String get learnWaitingForKey => '準備ができたら送信を始めてください';

  @override
  String get learnRestart => '最初から';

  @override
  String get learnTryAnother => '別の問題に挑戦';

  @override
  String get learnKeyerStraight => '縦振れ電鍵';

  @override
  String get learnKeyerIambicA => 'アイアンビック A';

  @override
  String get learnKeyerIambicB => 'アイアンビック B';

  @override
  String get learnLegendStraight => 'スペースキー = 電鍵';

  @override
  String get learnLegendPaddles => '左 Ctrl = 短点、右 Ctrl = 長点';

  @override
  String get learnSendClean => '正確な送信です。修正点はありません。';

  @override
  String get learnSendIssues => 'リズムのアドバイス';

  @override
  String get learnYourSending => '解読結果';

  @override
  String get learnStraightKeyLabel => '電鍵';

  @override
  String get learnDitLabel => '短点';

  @override
  String get learnDahLabel => '長点';

  @override
  String get learnSettingsTitle => '練習設定';

  @override
  String get learnCharacterSpeed => '文字速度';

  @override
  String get learnFarnsworth => 'Farnsworth 間隔';

  @override
  String get learnFarnsworthHelp => '文字自体の速度は速いまま、文字間の間隔をこの速度に合わせて広げます。';

  @override
  String get learnEffectiveSpeed => '実効速度';

  @override
  String get learnTone => '音の高さ';

  @override
  String get learnPlaySample => 'サンプルを再生';

  @override
  String get learnSessionLength => '練習の長さ';

  @override
  String get learnFeedback => 'フィードバック';

  @override
  String get learnSound => '音';

  @override
  String get learnFlash => '画面点滅';

  @override
  String get learnHaptic => '振動';

  @override
  String get learnKeyer => '電鍵モード';

  @override
  String get learnDailyGoal => '毎日の目標';

  @override
  String get referenceReferenceTitle => 'モールス符号の資料';

  @override
  String get referenceTranslatorTitle => '変換ツール';

  @override
  String get referencePlay => '再生';

  @override
  String get referenceStop => '停止';

  @override
  String get referenceClear => '消去';

  @override
  String get referenceClose => '閉じる';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => '文字、手続き符号、Q 符号を検索…';

  @override
  String get referenceClearSearch => '検索をクリア';

  @override
  String get referenceNoResults => '検索に一致する項目がありません。';

  @override
  String get referenceSectionAlphabet => '文字表';

  @override
  String get referenceSectionPunctuation => '句読点';

  @override
  String get referenceSectionProsigns => '手続き符号';

  @override
  String get referenceSectionQCodes => 'Q 符号';

  @override
  String get referenceSectionAbbreviations => 'CW 略語';

  @override
  String get referenceSectionKoch => 'Koch 法の順番';

  @override
  String get referenceAlphabetHint => 'カードをタップすると音を聞けます。長押しすると覚え方を表示します。';

  @override
  String get referenceKochHint => 'Koch 法で文字を学ぶ順番です（LCWO の順番）。K と M から始め、受信の正答率が 90% に達したら 1 文字追加します。';

  @override
  String get referenceMnemonicTitle => '覚え方';

  @override
  String get referenceMeaningLabel => '意味';

  @override
  String get referencePlaybackSettings => '再生設定';

  @override
  String get referenceCharacterSpeed => '文字速度';

  @override
  String get referenceFarnsworth => 'Farnsworth 間隔';

  @override
  String get referenceFarnsworthHelp => '文字自体の速度はそのまま、間隔を実効速度に合わせて広げます。';

  @override
  String get referenceEffectiveSpeed => '実効速度';

  @override
  String get referenceTone => '音の高さ';

  @override
  String get referenceModeTextToMorse => 'テキスト → モールス符号';

  @override
  String get referenceModeMorseToText => 'モールス符号 → テキスト';

  @override
  String get referenceModeKey => '電鍵で送信';

  @override
  String get referenceTextInputLabel => 'テキスト';

  @override
  String get referenceTextInputHint => '符号に変換するテキストを入力…';

  @override
  String get referencePatternOutputLabel => 'モールス符号';

  @override
  String get referenceCopyPattern => '符号をコピー';

  @override
  String get referencePatternCopied => '符号をコピーしました';

  @override
  String get referencePatternInputLabel => 'モールス符号';

  @override
  String get referencePatternInputHint => '. と - を入力し、文字間はスペース、単語間は / で区切ってください';

  @override
  String get referenceTextOutputLabel => 'テキスト';

  @override
  String get referenceCopyText => 'テキストをコピー';

  @override
  String get referenceTextCopied => 'テキストをコピーしました';

  @override
  String get referenceUnknownPatternHelp => '対応する文字がない符号は <pattern> として表示されます。';

  @override
  String get referenceKeypadDit => '短点';

  @override
  String get referenceKeypadDah => '長点';

  @override
  String get referenceKeypadCharGap => '文字間隔';

  @override
  String get referenceKeypadWordGap => '単語間隔';

  @override
  String get referenceKeypadBackspace => 'バックスペース';

  @override
  String get referenceKeyHint => '電鍵を押し続けて送信してください。キーボードではスペースキーを押し続けます。';

  @override
  String get referenceKeyLabel => '電鍵';

  @override
  String get referenceKeyDecodedLabel => '解読結果';

  @override
  String get referenceKeyPendingLabel => '送信中';

  @override
  String get statsTitle => '統計';

  @override
  String get statsLoading => '統計を読み込み中…';

  @override
  String get statsLoadFailed => '学習の進捗を読み込めませんでした。下に引くか、開き直して再試行してください。';

  @override
  String get statsRetry => '再試行';

  @override
  String get statsEmptyTitle => 'まだ練習記録がありません';

  @override
  String get statsEmptyBody => '初めての受信練習または送信練習を終えると、正答率の推移、文字ごとの習熟度、練習カレンダーがここに表示されます。';

  @override
  String get statsEmptyCallToAction => '「学習」で「レッスンを続ける」を押すと始められます。';

  @override
  String get statsOverviewTitle => '概要';

  @override
  String get statsTileLesson => 'Koch 法のレッスン';

  @override
  String get statsTileAccuracy => '正答率';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => '練習量';

  @override
  String get statsTileStreak => '連続日数';

  @override
  String get statsTileDailyGoal => '毎日の目標';

  @override
  String get statsGoalMet => '今日の目標達成';

  @override
  String get statsSummaryTitle => '自分の統計';

  @override
  String get statsSummaryOpen => '統計を見る';

  @override
  String get statsTrendTitle => '正答率の推移';

  @override
  String get statsTrendHint => '点をタップすると練習の詳細を確認できます。';

  @override
  String get statsSeriesReceive => '受信';

  @override
  String get statsSeriesSend => '送信';

  @override
  String get statsAxisSessions => '練習';

  @override
  String get statsCharsTitle => '文字';

  @override
  String get statsCharsSubtitle => 'Koch 法の順番です。文字をタップすると詳細を表示します。';

  @override
  String get statsCharsNotStarted => 'まだ練習していません';

  @override
  String get statsNotInCourse => 'Koch 法のコースに含まれていません';

  @override
  String get statsSrsTitle => '間隔反復学習';

  @override
  String get statsSrsNotTracked => 'まだ予定がありません';

  @override
  String get statsSrsDueNow => '今すぐ復習';

  @override
  String get statsConfusionsTitle => 'よく聞き違える文字';

  @override
  String get statsConfusionsNone => '聞き違いの記録はありません';

  @override
  String get statsConfusionMissed => '聞き逃し';

  @override
  String get statsBucketLegendTitle => '正答率';

  @override
  String get statsBucketNone => 'なし';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => '聞き違いの一覧';

  @override
  String get statsHeatmapSubtitle => '行は送信された文字、列は回答した文字です。色が濃いほど回数が多いことを示します。';

  @override
  String get statsHeatmapEmpty => 'まだ聞き違いの記録がありません。間違えた回答がここに表示されます。';

  @override
  String get statsHeatmapLegendLow => '少ない';

  @override
  String get statsHeatmapLegendHigh => '多い';

  @override
  String get statsHeatmapAxisTarget => '送信内容';

  @override
  String get statsHeatmapAxisAnswered => '回答内容';

  @override
  String get statsCalendarTitle => '練習カレンダー';

  @override
  String get statsCalendarSubtitle => '最近 12 週間';

  @override
  String get statsCalendarLegendLess => '少ない';

  @override
  String get statsCalendarLegendMore => '多い';

  @override
  String get statsStreakExplanation => '1 回以上練習した日が何日続いたかを数えます。丸 1 日練習を休むとリセットされます。同じ日に 2 回練習しても 1 日として数えます。';

  @override
  String get learnStatistics => '統計';

  @override
  String get listenTitle => '受信する';

  @override
  String get listenStart => '開始';

  @override
  String get listenStop => '停止';

  @override
  String get listenStarting => 'マイクを起動中…';

  @override
  String get listenClear => 'テキストを消去';

  @override
  String get listenCopy => 'テキストをコピー';

  @override
  String get listenCopied => '解読したテキストをコピーしました';

  @override
  String get listenSettings => '受信設定';

  @override
  String get listenDecoded => '解読結果';

  @override
  String get listenEmptyHint => 'モールスの音にマイクを向けてください。解読したテキストがここに表示されます。';

  @override
  String get listenIdleHint => '「開始」をタップしてモールスの音を受信してください。';

  @override
  String get listenPending => '受信中';

  @override
  String get listenSpeed => '速度';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => '信号';

  @override
  String get listenToneOn => '音あり';

  @override
  String get listenTone => '音の周波数';

  @override
  String get listenToneLocked => '周波数ロック中';

  @override
  String get listenToneSearching => '探索中';

  @override
  String get listenToneManual => '手動';

  @override
  String get listenAutoTune => '自動同調';

  @override
  String get listenAutoTuneHelp => '400–1000 Hz の範囲で最も強い音を追尾します。スライダーを動かすと手動で同調できます。';

  @override
  String get listenRetune => '自動';

  @override
  String get listenBlockSize => '解析ブロック';

  @override
  String get listenBlockSizeHelp => 'ブロックが小さいほど短点・長点の境界を正確に捉えますが、ノイズの影響を受けやすくなります。256 サンプル（5.3 ms）は 5–40 WPM に適しています。';

  @override
  String get listenMinElement => '最短の符号要素';

  @override
  String get listenMinElementHelp => 'これより短い音や間隔は、クリックノイズや音切れとして無視します。';

  @override
  String get listenPermissionDenied => 'マイクへのアクセスが許可されていません。システム設定で許可してから再試行してください。';

  @override
  String get listenPermissionRetry => '再試行';

  @override
  String get listenStartFailed => 'マイクを起動できませんでした。';

  @override
  String get listenNoInput => 'マイクが見つかりません。接続してから再試行してください。';

  @override
  String get listenStreamFailed => 'マイクが予期せず停止しました。もう一度お試しください。';

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
    return '$samples サンプル（$ms ms）';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'アプリがバックグラウンドに移ったため、受信を停止しました。';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => '短点が長すぎます';

  @override
  String get learnTipDahTooShortTitle => '長点が短すぎます';

  @override
  String get learnTipIntraGapTooLongTitle => '符号要素が離れすぎています';

  @override
  String get learnTipCharGapTooShortTitle => '文字間が詰まっています';

  @override
  String get learnTipWordGapTooShortTitle => '単語間が詰まっています';

  @override
  String get learnTipSpeedUnsteadyTitle => '速度が不安定です';

  @override
  String get learnSeverityMinor => '軽微';

  @override
  String get learnSeverityModerate => '目立つ';

  @override
  String get learnSeveritySevere => '大きい';

  @override
  String learnNewestCharIs(String char) {
    return 'このレッスンの新しい文字：$char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char、新しい文字';
  }

  @override
  String learnPendingPattern(String pattern) {
    return '送信中：$pattern';
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
    return '短点が長すぎます（短点の約 $ratio）。「ツー」ではなく「トン」と短く、押し続けずに軽くたたく感覚で送信してください。';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return '長点が短すぎます（短点の約 $ratio、目標は 3 倍）。短点 3 つ分の長さで押し続けてください。';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return '文字内の間隔が広すぎます（短点の約 $ratio）。1 文字の符号要素は間隔を詰めて送信してください。';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return '文字同士がつながっています（間隔は短点の約 $ratio、目標は 3 倍）。文字の後に明確な休止を入れてください。';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return '単語同士が近すぎます（間隔は短点の約 $ratio、目標は 7 倍）。単語の間には長めの休止を入れてください。';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return '速度が変動しています（変動 $percent%）。一定のテンポを決め、行の最後まで保ちましょう。';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '短点 $total 個中 $offending 個が長すぎます（平均：短点の $ratio）';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '長点 $total 個中 $offending 個が短すぎます（平均：短点の $ratio）';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '文字内の間隔 $total 個中 $offending 個が長すぎます（平均：短点の $ratio）';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '文字間隔 $total 個中 $offending 個が短すぎます（平均：短点の $ratio）';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '単語間隔 $total 個中 $offending 個が短すぎます（平均：短点の $ratio）';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return '送信速度が不安定です（変動係数 $cv）';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return '最近 7 日間 / 全期間 $allTime';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours 時間 $minutes 分';
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
    return '$app を表示';
  }

  @override
  String desktopTrayHide(String app) {
    return '$app を非表示';
  }

  @override
  String get desktopTraySoundOn => '音を有効にしました';

  @override
  String get desktopTraySoundOff => '音を無効にしました';

  @override
  String desktopTrayQuit(String app) {
    return '$app を終了';
  }

  @override
  String get listenStateOn => 'オン';

  @override
  String get listenStateOff => 'オフ';

  @override
  String referenceTelegraphCodes(String codes) {
    return '中国語電信コード：$codes';
  }

  @override
  String get referenceTelegraphMainland => '中国本土（1983 年版）';

  @override
  String get referenceTelegraphTaiwan => '台湾 / 香港';

  @override
  String get referenceTelegraphNone => 'このコード表にありません';

  @override
  String get appearanceTitle => '外観';

  @override
  String get appearanceStyles => 'インターフェースのスタイル';

  @override
  String get appearanceChoose => 'スタイルを選び、プレビューしてから適用';

  @override
  String get appearanceMode => '明るさ';

  @override
  String get appearancePreview => 'プレビュー';

  @override
  String get appearanceApply => 'スタイルを適用';

  @override
  String get appearanceRestore => '初期設定に戻す';

  @override
  String get appearanceApplied => '外観を保存しました';

  @override
  String get appearanceSaveFailed => '外観を保存できませんでした。再試行してください。';

  @override
  String get appearanceClassic => 'クラシックな真鍮';

  @override
  String get appearanceModern => '落ち着いたモダン';

  @override
  String get appearanceRadio => '夜の無線局';

  @override
  String get appearancePaper => '紙のハンドブック';

  @override
  String get appearanceCartoon => 'さわやかなカートゥーン';

  @override
  String get appearanceLight => 'ライト';

  @override
  String get appearanceDark => 'ダーク';

  @override
  String learnShowAllChars(int count) {
    return '全 $count 文字を表示';
  }

  @override
  String get learnShowFewerChars => '文字を折りたたむ';

  @override
  String get learnLeaveDrillTitle => 'このセッションを終了しますか？';

  @override
  String get learnLeaveDrillBody => 'このセッションで行ったラウンドは保存されません。';

  @override
  String get learnLeaveDrillConfirm => '終了';

  @override
  String get learnReplayAssistedNote => '再生し直しました：練習には数えますが、レッスンの解放や復習の更新は行いません。';

  @override
  String get learnPlanTitle => '今日のプラン';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return '約$minutes分 · $totalステップ中$done完了';
  }

  @override
  String get learnPlanBudget => 'プランの長さ';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get learnPlanStart => 'プランを始める';

  @override
  String get learnPlanContinue => 'プランを続ける';

  @override
  String get learnPlanStepReview => '復習期限の文字';

  @override
  String get learnPlanStepFocus => '重点練習';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'レッスン$lesson';
  }

  @override
  String get learnPlanStepSend => '送信練習';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return '復習時期：$symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'よく取り違える：$symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return '正答率90%未満：$symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count文字：次のレッスンを解放できます';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return '次のレッスンを解放できるよう$count文字に延長しました';
  }

  @override
  String get learnPlanReasonConsolidate => '短い練習：このレッスンの定着用で、次は解放されません';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'コースが進みました：レッスン$lessonを練習しますが解放はしません';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '短い課題を$count回送信';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return '完了 · $percent%';
  }

  @override
  String get learnPlanStepDone => '完了';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$total中$done送信済み';
  }

  @override
  String get learnPlanStale => 'レッスンまたは速度が変わりました。未開始のステップを更新しますか？';

  @override
  String get learnPlanUpdate => 'ステップを更新';

  @override
  String get learnPlanComplete => '今日のプランは完了です';

  @override
  String learnPlanNeedsWork(String symbols) {
    return '要練習：$symbols';
  }

  @override
  String get learnPlanAllGood => '今日は苦手な文字はありません。';

  @override
  String get learnPlanTomorrow => '明日は新しいプランです。自由練習はいつでもできます。';

  @override
  String learnPlanEarlier(int done, int total) {
    return '前回のプランは$totalステップ中$doneで止まりました。今日の分には数えません。';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return '実効速度$wpm WPMに進めます';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return '$wpm WPMに進めます';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'この速度では受信が難しいようです。実効$wpm WPMか重点練習を試しましょう。';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return '直近の補助なし練習$count回（$percent%）に基づきます。適用するまで設定は変わりません。';
  }

  @override
  String get learnSpeedAdviceApply => '適用';

  @override
  String get learnSpeedAdviceDismiss => '今はしない';

  @override
  String get learnSpeedAdviceInsufficient => '速度アドバイスには、現在の速度で50文字以上の補助なし練習が3回必要です。';

  @override
  String get learnQsoAction => 'QSOシミュレーター';

  @override
  String learnQsoLocked(int lesson) {
    return 'レッスン$lessonから';
  }

  @override
  String get learnQsoTitle => 'QSOシミュレーター';

  @override
  String get learnQsoRespond => 'CQに応答する';

  @override
  String get learnQsoRespondHint => '局がCQを出しています。応答してレポートを交換します。';

  @override
  String get learnQsoCall => 'CQを出す';

  @override
  String get learnQsoCallHint => 'あなたがCQを出し、局が応答します。';

  @override
  String get learnQsoYourCall => 'あなたのコールサイン';

  @override
  String get learnQsoYourName => 'あなたの名前';

  @override
  String get learnQsoYourQth => 'あなたのQTH';

  @override
  String get learnQsoInvalidCall => 'BD1XYZのようなコールサインを入力してください';

  @override
  String get learnQsoInvalidWord => '1語、A–Zの文字のみ';

  @override
  String get learnQsoOffline => 'すべてこの端末内で動作し、誰にも送信しません。';

  @override
  String get learnQsoStart => 'QSOを始める';

  @override
  String get learnQsoResume => '途中のQSOを再開';

  @override
  String get learnQsoStageCallCq => '自分のコールサインでCQを出す';

  @override
  String get learnQsoStageCallConfirm => '応答：相手のコール、DE、自分のコール';

  @override
  String get learnQsoStageExchange => 'レポート・名前・QTHを送る';

  @override
  String get learnQsoStageConfirmInfo => '相手の情報を確認する';

  @override
  String get learnQsoStageClosing => '73と<SK>で終える';

  @override
  String get learnQsoStageDone => 'QSO完了';

  @override
  String learnQsoSpeed(int wpm) {
    return '相手は実効$wpm WPMで送信';
  }

  @override
  String learnQsoRemote(String call) {
    return '$callの送信';
  }

  @override
  String get learnQsoRemoteHidden => '耳で受信してください（テキストは非表示）。';

  @override
  String get learnQsoShowText => 'テキストを表示';

  @override
  String get learnQsoListen => '聴く';

  @override
  String get learnQsoAccepted => '受理';

  @override
  String get learnQsoRejected => '不受理';

  @override
  String get learnQsoRemoteSending => '相手局が送信中…';

  @override
  String get learnQsoYourTurn => 'あなたの番です：返信を打鍵して「送信」。';

  @override
  String get learnQsoDecoded => 'あなたの送信内容';

  @override
  String get learnQsoNothingKeyed => 'まだ打鍵していません';

  @override
  String get learnQsoPlayAgain => '再送を頼む（AGN）';

  @override
  String get learnQsoSlower => '減速を頼む（QRS）';

  @override
  String get learnQsoHint => 'ヒント';

  @override
  String learnQsoHintLabel(String example) {
    return '例：$example';
  }

  @override
  String get learnQsoPause => '一時停止';

  @override
  String get learnQsoSend => '送信';

  @override
  String get learnQsoClear => '消去';

  @override
  String get learnQsoIssueEmpty => '何も打鍵されていません。';

  @override
  String get learnQsoIssueMissingCq => 'CQで始めてください。';

  @override
  String get learnQsoIssueMissingDe => 'コールサインの間にDEを入れてください。';

  @override
  String get learnQsoIssueWrongLocalCall => '自分のコールサインがないか誤っています。';

  @override
  String get learnQsoIssueWrongRemoteCall => '相手局のコールサインが違います。';

  @override
  String get learnQsoIssueReversedCalls => '順序が逆です：相手、DE、自分の順です。';

  @override
  String get learnQsoIssueMissingEnding => 'KまたはKNで終えてください。';

  @override
  String get learnQsoIssueMissingRst => 'レポートを送ってください（例：UR RST 599）。';

  @override
  String get learnQsoIssueInvalidRst => 'RSTが範囲外です（R 1–5、S 1–9、T 1–9）。';

  @override
  String get learnQsoIssueMissingName => 'NAMEと名前を送ってください。';

  @override
  String get learnQsoIssueWrongName => 'このQSOでのあなたの名前ではありません。';

  @override
  String get learnQsoIssueMissingQth => 'QTHと場所を送ってください。';

  @override
  String get learnQsoIssueWrongQth => 'このQSOでのあなたのQTHではありません。';

  @override
  String get learnQsoIssueMissingAck => 'RまたはQSLで了解を伝えてください。';

  @override
  String get learnQsoIssueWrongRemoteName => '相手のオペレーター名を確認してください。';

  @override
  String get learnQsoIssueMissing73 => '73を入れてください。';

  @override
  String get learnQsoIssueMissingSk => '<SK>で交信を終えてください。';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return '一度で正解：$totalステップ中$count';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return '再送：$count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'ヒント：$count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'あなたの送信：約$wpm WPM';
  }

  @override
  String get learnQsoSummaryNote => 'QSOの結果は受信正答率とは別に扱い、レッスンは解放しません。';

  @override
  String get learnTipDahTooLongTitle => '長点が長すぎる';

  @override
  String learnTipDahTooLong(String ratio) {
    return '長点が長すぎます（短点の約$ratio、目標は3倍）。短点3つ分で離しましょう。';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '長点$total個中$offending個が長すぎ（平均$ratio短点）';
  }

  @override
  String get learnRhythmTitle => 'リズム';

  @override
  String get learnRhythmMine => '自分のリズム';

  @override
  String get learnRhythmStandard => '標準のリズム（目標速度）';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return '問題は自分の短点（$ms ms）を基準に判断します。遅くても均等なら問題ありません。標準は目標速度です。';
  }

  @override
  String get learnRhythmNotLocated => '打鍵を1文字ずつ対応付けられませんでした。課題全体を練習してください。';

  @override
  String get learnRhythmPlayMine => '自分のを再生';

  @override
  String get learnRhythmPlayStandard => '標準を再生';

  @override
  String learnRhythmPracticePart(int count) {
    return 'これを練習（$count回）';
  }

  @override
  String get learnRhythmPracticeWhole => '課題全体を練習';

  @override
  String get learnRhythmSymbolOk => '良好';

  @override
  String get learnRhythmZoomIn => '拡大';

  @override
  String get learnRhythmZoomOut => '縮小';

  @override
  String get workbenchTitle => '録音ワークベンチ';

  @override
  String get workbenchOpen => '録音';

  @override
  String get workbenchImport => '録音を読み込む';

  @override
  String get workbenchEmpty => 'WAV録音を読み込むと、ループ再生・解読・自分での受信練習ができます。マイクは不要です。';

  @override
  String get workbenchFormats => 'WAV（16ビットPCM、モノラル/ステレオ、8/16/44.1/48 kHz）、最大50 MB・20分。';

  @override
  String get workbenchBackupNote => '録音はこの端末に保存されます。学習データの削除やアンインストール前にコピーを保管してください。保存済みの区間はタイトル、メモ、位置を保持します。';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => 'モノラル';

  @override
  String get workbenchStereo => 'ステレオ';

  @override
  String get workbenchErrorNotWav => 'WAVファイルではありません。';

  @override
  String get workbenchErrorFormat => '現在は16ビットPCMのWAVのみ対応です（MP3・AAC・浮動小数点WAVは不可）。';

  @override
  String get workbenchErrorChannels => 'モノラルかステレオの録音のみ対応しています。';

  @override
  String get workbenchErrorRate => 'このサンプルレートは非対応です。8・16・44.1・48 kHzを使ってください。';

  @override
  String get workbenchErrorDamaged => 'ファイルが壊れているか不完全です。';

  @override
  String get workbenchErrorTooLarge => 'ファイルが50 MBを超えています。';

  @override
  String get workbenchErrorTooLong => '録音が20分を超えています。';

  @override
  String get workbenchErrorIo => 'ファイルを読み込めませんでした。';

  @override
  String get workbenchErrorMissing => '録音ファイルが見つかりません。';

  @override
  String get workbenchStart => '開始（秒）';

  @override
  String get workbenchEnd => '終了（秒）';

  @override
  String get workbenchSelectAll => 'すべて選択';

  @override
  String get workbenchPlay => '選択範囲を再生';

  @override
  String get workbenchStop => '停止';

  @override
  String get workbenchLoop => 'ループ';

  @override
  String get workbenchPlayLimit => '長い選択範囲は最初の5分だけ再生します。';

  @override
  String get workbenchAutoTune => 'トーンを自動で探す';

  @override
  String workbenchManualTone(int hz) {
    return 'トーン：$hz Hz';
  }

  @override
  String get workbenchDecode => '選択範囲を解読';

  @override
  String get workbenchCancel => 'キャンセル';

  @override
  String workbenchDecoding(int percent) {
    return '解読中… $percent%';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'トーン$hz Hz · 約$wpm WPM';
  }

  @override
  String get workbenchToneNotLocked => '安定したトーンが見つかりません。手動で合わせてください。';

  @override
  String get workbenchNoText => 'この範囲では何も解読できませんでした。';

  @override
  String workbenchUnknown(String patterns) {
    return '不明な符号：$patterns';
  }

  @override
  String get workbenchEdgeCut => '選択範囲の端の文字が切れており、誤っている可能性があります。';

  @override
  String get workbenchToneNote => 'トーンの捕捉は信頼度ではありません。耳で確認してください。';

  @override
  String get workbenchModeDecoder => 'デコーダー';

  @override
  String get workbenchModeCopy => '自分で受信する';

  @override
  String get workbenchDecoderHidden => '受信中はデコーダーの文字を隠します。';

  @override
  String get workbenchShowDecoder => 'デコーダーの文字を表示';

  @override
  String get workbenchReference => '正解テキスト（任意）';

  @override
  String get workbenchReferenceHelp => '送信されたテキストを貼り付けてください。なければデコーダーの出力と比較します。';

  @override
  String get workbenchAgainstDecoder => 'デコーダーの出力と比較しました。出力自体が誤っている可能性があります。';

  @override
  String get workbenchSave => '選択範囲を保存';

  @override
  String get workbenchSaveTitle => 'タイトル';

  @override
  String get workbenchSaveNote => 'メモ';

  @override
  String get workbenchSaved => '選択範囲を保存しました';

  @override
  String get workbenchSaveFailed => '選択範囲を保存できませんでした。';

  @override
  String get workbenchLibrary => '保存した区間';

  @override
  String get workbenchLibraryEmpty => '保存した区間はまだありません。';

  @override
  String get workbenchMissing => '録音ファイルがありません。選び直すか項目を削除してください。';

  @override
  String get workbenchRelink => 'ファイルを選び直す';

  @override
  String get workbenchDelete => '削除';

  @override
  String get materialsTitle => 'マイ素材';

  @override
  String get materialsNew => '新しい素材';

  @override
  String get materialsEdit => '編集';

  @override
  String get materialsSave => '保存';

  @override
  String get materialsSaveFailed => '素材を保存できませんでした。';

  @override
  String get materialsTitleField => 'タイトル';

  @override
  String get materialsTagsField => 'タグ';

  @override
  String get materialsTagsHelper => 'タグはカンマで区切ります';

  @override
  String get materialsTextField => 'テキスト';

  @override
  String get materialsListField => '1行に1項目';

  @override
  String get materialsKindText => 'テキスト';

  @override
  String get materialsKindWords => '単語リスト';

  @override
  String get materialsKindCallsigns => 'コールサイン';

  @override
  String get materialsPreview => 'プレビュー';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items項目 · $symbols文字 · $prosigns略符号';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'モールス符号がなく練習で省く文字：$chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '重複$count件は1つにまとめます';
  }

  @override
  String get materialsProblemEmpty => '先にテキストを入力してください。';

  @override
  String get materialsProblemTooLarge => '大きすぎます（上限1 MiB）。';

  @override
  String materialsProblemTooManyEntries(int count) {
    return '項目が多すぎます（最大$count）。';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return '長すぎる項目があります（各$count文字まで）。';
  }

  @override
  String get materialsProblemNothingTrainable => 'モールスで練習できる内容がありません。';

  @override
  String get materialsSearch => '素材を検索';

  @override
  String get materialsFavoritesOnly => 'お気に入り';

  @override
  String get materialsFavorite => 'お気に入りに追加';

  @override
  String get materialsUnfavorite => 'お気に入りから削除';

  @override
  String get materialsEmpty => '教材はまだありません。テキスト、単語リスト、コールサインを追加できます。';

  @override
  String materialsItems(int count) {
    return '$count項目';
  }

  @override
  String get materialsActions => '素材の操作';

  @override
  String get materialsPractise => '練習';

  @override
  String get materialsDelete => '削除';

  @override
  String get materialsDeleteTitle => '素材を削除しますか？';

  @override
  String materialsDeleteBody(String title) {
    return '「$title」をこの端末から削除します。練習履歴は残ります。';
  }

  @override
  String get materialsImport => 'TXT/JSONを読み込む';

  @override
  String get materialsImportDialogTitle => '素材ファイルを選択';

  @override
  String get materialsSaveDialogTitle => '素材を保存';

  @override
  String get materialsImportFailed => '読み込みに失敗しました。ライブラリは変更されていません。';

  @override
  String get materialsImportNotUtf8 => 'UTF-8のテキストファイルのみ読み込めます。';

  @override
  String get materialsImportInvalid => '有効なMorseCQ素材ファイルではありません。何も読み込んでいません。';

  @override
  String materialsImported(int count) {
    return '$count件の素材を読み込みました。';
  }

  @override
  String get materialsDuplicateTitle => '一部の素材はすでにあります';

  @override
  String get materialsDuplicateOverwrite => '置き換える';

  @override
  String get materialsDuplicateKeepCopy => '両方残す（コピーとして）';

  @override
  String get materialsDuplicateSkip => 'スキップ';

  @override
  String get materialsExportJson => 'JSONで書き出す';

  @override
  String materialsExported(int count) {
    return '$count件の素材を書き出しました。';
  }

  @override
  String get materialsExportFailed => '書き出しに失敗しました。';

  @override
  String get materialsExportWav => '音声を書き出す（WAV）';

  @override
  String materialsWavCharSpeed(int wpm) {
    return '文字速度：$wpm WPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return '実効速度：$wpm WPM';
  }

  @override
  String materialsWavTone(int hz) {
    return '音程：$hz Hz';
  }

  @override
  String get materialsWavWithAnswer => '答えのテキストも付ける（.txt）';

  @override
  String get materialsWavFormat => '16ビット・モノラルWAV、48 kHz。';

  @override
  String materialsWavParts(int count) {
    return '10分を超えるため$count個のファイルに分けて書き出します。';
  }

  @override
  String materialsWavExported(int count) {
    return '音声ファイルを$count個保存しました。';
  }

  @override
  String get materialsPracticeMode => '練習の範囲';

  @override
  String get materialsPracticeLearned => '習得済みの文字のみ';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return '習得済みのみ（$count項目は未習得の文字を含むため使えません）';
  }

  @override
  String get materialsPracticeAll => 'すべてのモールス文字';

  @override
  String get materialsPracticeNothing => 'このモードで練習できる項目はありません。';

  @override
  String get guestClearConfirm => '消去';

  @override
  String get placementTitle => 'レベルチェック';

  @override
  String get placementCheckLevel => '今のレベルをチェック';

  @override
  String get placementFromZero => '導入をスキップ：レッスン1の課題へ';

  @override
  String get placementOfferTitle => 'モールスは初めて？それとも受信できる？';

  @override
  String get placementOfferBody => '短いチェックで開始位置を提案できます。任意で、選ぶまで何も変わりません。';

  @override
  String get placementIntro => '約3〜5分、5段階で受信します。速度を上げながらコッホ順の文字グループ、最後に短い単語。少ないサンプルによる目安で、認定ではありません。いつでも中止できます。';

  @override
  String get placementStart => '開始';

  @override
  String get placementSkip => 'スキップ';

  @override
  String get placementStop => '中止';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return '$total段階中$step · 実効 $wpm WPM';
  }

  @override
  String get placementTierPassed => 'よく受信できました。次はもっと速くなります。';

  @override
  String get placementTierStopped => 'この段階は90%未満だったため、ここで終了します。';

  @override
  String get placementNextTier => '次の段階';

  @override
  String placementSuggestion(int lesson) {
    return 'おすすめの開始：レッスン$lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return 'コッホ順の$total文字中$count文字を順に確認しました。';
  }

  @override
  String get placementLimits => '少ないサンプルに基づきます。テストしていない文字は未テストのままで、習得済みにはなりません。レッスンはいつでも変えられます。';

  @override
  String placementAdopt(int lesson) {
    return 'レッスン$lessonから始める';
  }

  @override
  String materialsImportConfirm(int count) {
    return '$count件の素材を読み込みますか？';
  }

  @override
  String get materialsExportTxt => 'テキストで書き出す（TXT）';

  @override
  String get conditionsTitle => '受信環境';

  @override
  String get conditionsClear => 'クリア';

  @override
  String get conditionsLight => '軽い混信';

  @override
  String get conditionsRadio => '実戦練習';

  @override
  String get conditionsClearHint => 'きれいで一定の音。通常の練習です。';

  @override
  String get conditionsLightHint => '小さな雑音とゆるやかなフェージング。結果はクリアな練習とは別に記録します。';

  @override
  String get conditionsRadioHint => '雑音、深いフェージング、近くの局、少し不揃いなタイミング。結果はクリアな練習とは別に記録します。';

  @override
  String get conditionsPreview => '試聴';

  @override
  String conditionsActive(String name) {
    return '受信環境：$name';
  }

  @override
  String get conditionsNeedSound => '受信環境は音で聞くものです。練習設定で音をオンにするか、「クリア」で練習してください。';

  @override
  String get conditionsCleanReplay => '効果なしで再生';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この環境・速度での挑戦 $count 回：平均 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => '受信環境つきの練習は活動として記録されますが、レッスン・復習スケジュール・速度のおすすめは変わりません。';

  @override
  String get keysTitle => 'キーと外部キーヤー';

  @override
  String get keysMeSubtitle => 'キー割り当て・パドル・USB キーヤーアダプター';

  @override
  String get keysIntro => 'モールスを打つキーを選びます。キーボードとして動作する USB 電鍵・パドルアダプターはキーボードと同じ扱いなので、ここでキーを設定してください。どの機器からのキー入力かはアプリには分からないため、プロファイルはキー割り当ての組み合わせです。';

  @override
  String get keysStandardProfile => '標準';

  @override
  String get keysUnnamed => '名前のないプロファイル';

  @override
  String get keysEdit => '編集';

  @override
  String get keysNewProfile => '新しいプロファイル';

  @override
  String get keysLimitations => 'MIDI・シリアル・Bluetooth のキーヤー、アダプターのファームウェア設定、送信機の制御には対応していません。検証済みのアダプターはドキュメントに記載しています。';

  @override
  String get keysEditTitle => 'キープロファイル';

  @override
  String get keysName => 'プロファイル名';

  @override
  String get keysActionStraight => '縦振り電鍵';

  @override
  String get keysActionDit => '短点パドル';

  @override
  String get keysActionDah => '長点パドル';

  @override
  String get keysPressKey => 'キーを押してください…';

  @override
  String get keysNone => '未設定';

  @override
  String get keysSet => '設定';

  @override
  String keysReserved(String key) {
    return '$key はシステムまたはアプリが使用するため設定できません。別のキーを選んでください。';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key はすでに「$action」に使われています。';
  }

  @override
  String keysConflictSave(String keys) {
    return '1 つのキーに割り当てられる動作は 1 つだけです：$keys が重複しています。';
  }

  @override
  String get keysMissing => 'このキーヤーモードに必要なキーを設定してください（iambic では両方のパドル）。';

  @override
  String get keysSwapPaddles => 'パドルを入れ替える（左利き）';

  @override
  String get keysKeyerMode => 'キーヤーモード';

  @override
  String get keysIambicA => 'Iambic A';

  @override
  String get keysIambicB => 'Iambic B';

  @override
  String get keysAdapterKeyer => 'アダプターが自分で符号を作る';

  @override
  String get keysAdapterKeyerHint => 'キーヤー内蔵のアダプター向け：アダプターが計った押下・解放をそのまま使い、アプリ側で二重に iambic 処理しません。';

  @override
  String get keysAppSidetone => '打鍵時のアプリのサイドトーン';

  @override
  String get keysAppSidetoneHint => 'アダプターがサイドトーンを出す場合はオフにします。解読には影響しません。';

  @override
  String get keysTestTitle => 'テスト';

  @override
  String get keysTestNote => 'テスト専用です。送信も練習記録への追加もされません。';

  @override
  String get keysTestRelease => 'キーを解放';

  @override
  String get keysAdapterActive => 'アダプターのキーヤーを使用中：パドルのキーは縦振り電鍵として扱います。';

  @override
  String keysHintCustom(String keys) {
    return 'キー：$keys';
  }

  @override
  String get telegraphTitle => '中文電碼';

  @override
  String get telegraphIntro => '漢字は 1 文字ずつ 4 桁の番号で送られます。数字を聞き取る練習と、どの番号がどの字かを覚える練習を別々に行います。';

  @override
  String get telegraphCodebook => '電碼本';

  @override
  String get telegraphCodebookMainland => '中国大陸';

  @override
  String get telegraphCodebookTaiwan => '台湾';

  @override
  String get telegraphDigitsTitle => '電碼を聞き取る';

  @override
  String get telegraphDigitsHint => '実在する電碼の 4 桁を聞いて、数字を入力します。';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 回：数字の正答率 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => '電碼を思い出す';

  @override
  String get telegraphRecallHint => '字から番号、番号から字。モールスの進捗とは別に記録します。';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 枚回答：正答率 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => '電碼の暗記がモールスのレッスン解放や速度のおすすめに影響することはありません。数字の聞き取りは他のモールス受信と同じ扱いです。';

  @override
  String get telegraphRecallCharPrompt => 'この字の電碼を入力';

  @override
  String get telegraphRecallCodePrompt => 'この電碼の字を選ぶ';

  @override
  String get telegraphReveal => '答えを見る';

  @override
  String get telegraphRevealAssisted => '表示済み：このカードは補助ありとして記録します。';

  @override
  String get telegraphCorrect => '正解';

  @override
  String get telegraphIncorrect => '不正解';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$total 問中 $correct 問正解';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '答えを見たカード $count 枚',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => '電碼の解釈';

  @override
  String get telegraphInterpretNote => 'ここに表示するだけで、メッセージ自体は変わらず、何も送信されません。';

  @override
  String get telegraphUnresolved => '未解決：この番号の字はありません';

  @override
  String get telegraphMalformed => '4 桁のグループではありません';

  @override
  String get telegraphNotCode => '文字列（そのまま）';

  @override
  String get telegraphAmbiguous => 'この番号を共有する字が複数あります';

  @override
  String get conditionsAudioFailed => 'この端末では音声を開始できませんでした。「クリア」で練習してください。';

  @override
  String get aboutPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get aboutTermsOfUse => '利用規約';

  @override
  String get aboutSupport => 'サポート・お問い合わせ';

  @override
  String get aboutLinkFailed => 'リンクを開けなかったため、コピーしました。';

  @override
  String get offlineClearData => '学習データを消去';

  @override
  String get offlineClearDataBody => 'この端末の進捗、プラン、教材を削除します。';

  @override
  String get offlineCleared => '学習データを消去しました。';

  @override
  String get offlineClearFailed => '学習データを消去できませんでした。';

  @override
  String get learnStorageUnavailable => 'この端末でトレーニングデータを開けませんでした。もう一度お試しください。';

  @override
  String get materialsImportedSource => '読み込み元';

  @override
  String get learnStartHereTitle => 'はじめての方へ：3分の最初のレッスンから';

  @override
  String get learnStartHereBody => '音を聞き、KとMを覚え、簡単な問題に数回答えます。採点はありません。';

  @override
  String get learnStartHere => 'ここから始める';

  @override
  String get learnReplayFirstLesson => '最初のレッスンをもう一度';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '導入済み $introduced · 習得済み $mastered';
  }

  @override
  String get learnChipNew => '新規';

  @override
  String get learnChipPractising => '練習中';

  @override
  String get learnChipMastered => '習得済み';

  @override
  String get learnChipWeak => '90%未満';

  @override
  String get learnChipDue => '復習待ち';

  @override
  String get learnTapChipHint => '文字をタップすると音が聞けます';

  @override
  String learnHearChar(String char) {
    return '$char を聞く';
  }

  @override
  String learnPractiseNewChar(String char) {
    return '新しい文字 $char を練習';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a と $b を聞き比べ';
  }

  @override
  String get learnGuidedPractice => '短い練習（10文字）';

  @override
  String learnChallengeHint(int count, int min) {
    return 'レッスン課題：$count文字を正答率90%で、新しい文字はそれぞれ$min回以上。合格すると次の文字が開きます。';
  }

  @override
  String get learnAllUnlockedNotPassed => 'すべての文字が開きました。最後の課題に合格するとコース修了です。';

  @override
  String get learnGoalFirstUse => '今の目標：耳でKとMを聞き分ける。次：レッスン1の課題。';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return '今の目標：$chars を確実に聞き取る（$min回、正答率90%）。次：レッスン$lessonの課題。';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return '今の目標：レッスン$lessonの課題に合格。次：$next。';
  }

  @override
  String learnGoalNextChar(String char) {
    return '文字 $char';
  }

  @override
  String get learnGoalNextOperating => '単語・コールサイン・QSO全体';

  @override
  String get learnGoalOperating => '今の目標：実際の交信文（単語・コールサイン・QSO）。次：実効速度を一段ずつ上げる。';

  @override
  String get learnMorePractice => 'その他の練習';

  @override
  String get learnQsoReady => '準備OK';

  @override
  String get learnQsoPractiseFirst => '先に交信文を練習';

  @override
  String learnQsoSymbolsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$count文字',
    );
    return '$_temp0';
  }

  @override
  String get learnGlossaryTitle => '用語の意味';

  @override
  String get glossaryKoch => 'コッホ法：文字を最初から実速で学び、2文字から始めて1レッスンごとに1文字追加。正答率90%で次へ進みます。';

  @override
  String get glossaryWpm => 'WPM：1分あたりの語数（標準語 PARIS 基準）。文字速度は各文字そのものの速さです。';

  @override
  String get glossaryFarnsworth => 'ファーンズワース：文字は速いまま、文字間の間隔だけを伸ばして考える時間を作ります。実効速度はその間隔を含めた速さです。';

  @override
  String get glossaryQso => 'QSO：2局間の1回の交信。CQ＝誰でも応答どうぞ、DE＝こちらは、K＝どうぞ。';

  @override
  String get glossaryRst => 'RST：信号レポート（了解度・信号強度・音調）。599は最良。73は「よろしく」の挨拶。';

  @override
  String get learnVerdictNotCredited => '記録なし：何も回答されませんでした。';

  @override
  String get learnVerdictAssisted => '補助つきの練習';

  @override
  String get learnVerdictAssistedHint => '再生や答えの表示を使ったため、今回は練習としてのみ記録されます。解除も復習の更新もありません。次は再生なしで試してみましょう。';

  @override
  String get learnVerdictPractice => '練習を記録しました';

  @override
  String get learnVerdictPracticeHint => '自由練習は統計と復習を更新しますが、コースは進みません。コースは学習ホームのレッスン課題で進みます。';

  @override
  String get learnVerdictCourseComplete => '最終課題に合格：文字コースをすべて修了しました。';

  @override
  String learnVerdictTooShort(int count, int min) {
    return '課題として不足：$min文字中$count文字';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return '課題は$min文字以上です。学習ホームからレッスンを始めるか、トレーニング設定でセッション長を増やしてください。';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return '$chars の回数が足りません';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return '課題では新しい文字をそれぞれ$min回以上聞く必要があります。もう一度どうぞ。課題には意図的に含まれています。';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return '新しい文字が90%未満：$chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => '他は良好です。レッスンの合否は新しい文字で決まります。似た文字と聞き比べ、練習してから再挑戦しましょう。';

  @override
  String get learnVerdictBelowAccuracyHint => '全体の正答率が90%未満です。下の苦手な文字を短く練習してから、もう一度課題に挑戦しましょう。';

  @override
  String get learnDrillWeak => '苦手な文字を練習';

  @override
  String get learnRetryChallenge => '課題に再挑戦';

  @override
  String get learnTakeChallenge => 'レッスン課題に挑戦';

  @override
  String learnChallengeTitle(int lesson) {
    return 'レッスン$lessonの課題';
  }

  @override
  String get learnPracticeTitle => '練習';

  @override
  String get learnMeaningsTitle => '意味';

  @override
  String get firstLessonTitle => '最初のレッスン';

  @override
  String firstLessonStep(int step, int total) {
    return 'ステップ $step / $total';
  }

  @override
  String get firstLessonHearTitle => '聞こえますか？';

  @override
  String get firstLessonHearBody => '再生をタップしてください。短いビープ音のパターンが聞こえるはずです（点滅や振動をオンにしていればそれも）。';

  @override
  String get firstLessonHeard => '聞こえた';

  @override
  String get firstLessonNotHeard => '何も聞こえない';

  @override
  String get firstLessonNoSoundTitle => '音が出ない？';

  @override
  String get firstLessonNoSoundBody => '音量を上げ、サイレントスイッチやおやすみモードを確認してください。音の代わりに画面の点滅や振動を使うこともできます。';

  @override
  String get firstLessonUseFlash => '画面も点滅させる';

  @override
  String get firstLessonUseVibration => '振動もさせる';

  @override
  String get firstLessonPlay => '再生';

  @override
  String get firstLessonSoundsTitle => '短い音と長い音';

  @override
  String get firstLessonSoundsBody => 'モールスの音は2種類：短い「トン」と、その3倍の長さの「ツー」。文字はその組み合わせで、文字の間には短い無音があります。それぞれタップして聞いてみましょう。';

  @override
  String get firstLessonDit => 'トン（短）';

  @override
  String get firstLessonDah => 'ツー（長）';

  @override
  String get firstLessonWorkedTitle => '答え合わせの例';

  @override
  String get firstLessonWorkedBody => 'まず聞いてください。音のあとに答えが表示されます。まだ答える必要はありません。';

  @override
  String firstLessonWorkedReveal(String char) {
    return '今のは $char でした';
  }

  @override
  String get firstLessonTrialsTitle => 'KかMか？';

  @override
  String get firstLessonTrialsBody => '聞いてから、聞こえた文字をタップしてください。何度再生しても構いません。テストではありません。';

  @override
  String firstLessonTrialRound(int round, int total) {
    return '第$round問 / $total';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return '正解、$char でした';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return '今のは $answer ではなく $char でした。聞き比べてみましょう。';
  }

  @override
  String get firstLessonTooFast => '速すぎる？初心者ペース（文字間の間隔を長く）にする';

  @override
  String get firstLessonNextTitle => '次にすること';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '$total問中$correct問正解です。次のステップを選び、自分のペースで続けましょう。';
  }

  @override
  String get firstLessonNextGuided => '短い練習：1文字ずつ10回';

  @override
  String get firstLessonNextSend => '送信してみる';

  @override
  String get firstLessonSendGuide => '送信：短く押すとトン、長く押すとツー。パドルでは片側がトン、もう片側がツーです。離して、文字の間に少し間を置きます。縦振れ電鍵かアイアンビックA/Bかは後で変えられます。今は気にしなくて大丈夫です。';

  @override
  String get firstLessonReplayAnytime => 'このレッスンは学習ホームからいつでも見直せます。';

  @override
  String get firstLessonContinue => '続ける';

  @override
  String get firstLessonTrialNext => '次の問題';

  @override
  String get sendFirstUseTitle => '初めての送信ですか？';

  @override
  String get sendFirstUseStraight => '電鍵を短く押すとトン、約3倍の長さでツー。文字の間は少し、単語の間はもっと長く間を置きます。';

  @override
  String get sendFirstUsePaddles => '短点と表示されたパドルで短点、長点と表示されたパドルで長点を送ります。長さはキーヤーが調整します。文字間は短く、単語間は長く間を置きます。';

  @override
  String get sendFirstUseDismiss => 'わかった';

  @override
  String get learnSpeedPresets => 'ペース';

  @override
  String get learnPresetBeginner => '初心者 20 / 6';

  @override
  String get learnPresetStandard => '標準 20 / 8';

  @override
  String get learnPresetHelp => 'どちらも文字は20 WPMで鳴ります。初心者ペースは文字間の間隔を長くします（実効6 WPM）。';

  @override
  String get learnPlanStepIntro => '最初のレッスン';

  @override
  String get learnPlanStepRecognition => '1文字ずつ';

  @override
  String get learnPlanReasonFirstLesson => '音を聞いてKとMを聞き分ける';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return '1文字ずつ：$symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return '$count文字の短い混合グループ。50文字の課題はあとで';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return '任意：お手本を聞いてから$count個の短い課題を送信';
  }

  @override
  String get learnQsoReadyTitle => 'QSOの準備ができました';

  @override
  String get learnQsoNotReadyTitle => 'まだ学んでいない文字があります';

  @override
  String get learnQsoMissingBody => 'QSOにはまだ学んでいない次の文字が出てきます。タップすると聞けます。先に試すこともできます。キーパッドにはすべての文字が表示されます。';

  @override
  String get learnQsoShorthandHint => '先に略語（CQ、DE、UR、RST、TNX、73）を練習すると、交信文の意味がわかります。';

  @override
  String get learnQsoPractiseShorthand => '略語を練習';

  @override
  String get learnQsoHowTitle => 'QSOの流れ';

  @override
  String get learnQsoHowBody => '呼び出し（CQ＝誰でも、DE＝こちらは）、コールサインで応答、レポート（RST）・名前・QTH（場所）を交換し、73（よろしく）と<SK>（終了）で締めます。Kは「どうぞ」です。';

  @override
  String get learnQsoExploreLabel => '未習の文字を含む';

  @override
  String get statsCoursePassed => 'コース修了';

  @override
  String get firstLessonPlayAgain => 'もう一度再生';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return 'レッスン$lessonの課題：$count文字、90%で $char が開く';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return 'レッスン$lessonの課題：$count文字を90%でコース修了';
  }

  @override
  String get learnQsoShorthandTitle => 'まず略語を練習しましょう';

  @override
  String get learnQsoExchangeTitle => 'まずQSOの交信文を練習しましょう';

  @override
  String get learnQsoExchangeHint => 'シミュレーターでQSO全体を行う前に、交信文を1行ずつ（1回の交換ずつ）聞き取ってみましょう。';

  @override
  String get sendGuideTitle => '送信の練習ガイド';

  @override
  String sendGuideStep(int step, int total) {
    return '$total 段階中 $step 段階目';
  }

  @override
  String get sendGuideHear => 'まずお手本を聴く';

  @override
  String get sendGuideListening => '最後までリズムを聴きましょう…';

  @override
  String get sendGuideTry => '送信してみる';

  @override
  String get sendGuideRetry => '同じ目標をもう一度';

  @override
  String get sendGuidePassed => '正しく解読されました。次の目標へ進みましょう。';

  @override
  String get sendGuideComplete => '2 文字と文字列を正しく送信できました。自由送信練習へ進めます。';

  @override
  String get sendGuideRhythm => 'お手本に合わせましょう：短点は短く、長点はその 3 倍、文字間には明確な間隔を置きます。';

  @override
  String get learnContinueToday => '今日の学習を続ける';

  @override
  String get learnPlanDetails => '計画の詳細を見る';

  @override
  String get learnGuidedSingle => '1文字ずつ · 10文字';

  @override
  String get learnGuidedShort => '3文字の短いグループ · 15文字';

  @override
  String get learnGuidedGroups => '5文字のグループ · 20文字';

  @override
  String get learnGuidedRecommended => 'おすすめの次のステップ';

  @override
  String get learnGuidedProgressHint => '合格したら短いグループから5文字のグループへ進みます。ガイド練習で定着させ、コースの挑戦に合格すると次のレッスンが開きます。';

  @override
  String get learnGuidedContinue => 'ガイド練習を続ける';

  @override
  String get learnGuidedRetry => 'このレベルをもう一度練習';

  @override
  String get firstLessonZeroHint => 'まだ正解がなくても大丈夫です。KとMの違いをもう一度聞いてから、再挑戦しましょう。';

  @override
  String get firstLessonPartialHint => 'いくつか正しく聞き取れました。KとMをもう一度比べ、自分のペースで続けましょう。';

  @override
  String get firstLessonPerfectHint => 'このラウンドは全問正解です。次は選択肢のない聞き取り練習で定着させましょう。';

  @override
  String get firstLessonPaceLocked => '回答を始めたので、これらのラウンドが終わるまで速度は変わりません。後で設定から変更できます。';

  @override
  String get learnRecentEvidenceHint => '段階は、過去14日間の同じ速度での補助なしの聞き取り記録で判断します。';

  @override
  String get learnQsoConsolidateTitle => '学んだ文字を定着させる';

  @override
  String get learnQsoConsolidateHint => '解放済みでも習得済みとは限りません。1文字ずつの聞き取りで、最近の独力での成績を残しましょう。';

  @override
  String get learnQsoPractiseSymbols => 'これらの文字を練習';

  @override
  String get learnQsoProtocolTitle => 'QSOの用語を理解する';

  @override
  String get learnQsoProtocolHint => '短いQSOを始める前に、CQ、DE、RST、73の意味を確認しましょう。';

  @override
  String get learnQsoProtocolStart => '用語の理解を確認';

  @override
  String learnQsoProtocolQuestion(String token) {
    return 'QSOで$tokenは何を意味しますか？';
  }

  @override
  String get learnQsoGeneralCall => 'どの局にも向けた呼び出し';

  @override
  String get learnQsoFromStation => 'この局から';

  @override
  String get learnQsoSignalReport => '信号レポート';

  @override
  String get learnQsoBestRegards => '挨拶とお別れ';

  @override
  String get learnQsoProtocolCorrect => '正解です';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return '正しい意味：$meaning';
  }

  @override
  String get learnQsoProtocolPass => '4つの用語すべてを補助なしで正解しました。短いQSOに挑戦できます。';

  @override
  String get learnQsoProtocolPractice => '意味を復習してから、もう一度確認しましょう。';

  @override
  String get learnQsoProtocolRetry => 'もう一度確認';

  @override
  String get learnQsoShortExchange => '短いQSOを練習';

  @override
  String get learnQsoShortExchangeHint => 'コールサインの確認、信号レポートの交換、終了の挨拶を独力で行ってから、完全なQSOへ進みます。';

  @override
  String get learnQsoExplorePending => '完全なQSOを体験 · まだ練習が必要です';

  @override
  String get learnQsoReadyHint => '最近の独力での練習記録がそろいました。完全なQSOのシミュレーションを始められます。';

  @override
  String get goalsTitle => '学習目標';

  @override
  String get goalsFirstQso => '初めての交信';

  @override
  String get goalsConversation => '会話とヘッドコピー';

  @override
  String get goalsContest => 'コンテスト交信';

  @override
  String get goalsExplanation => 'CW Academyを参考にした目標です。表示の実効速度で、28日以内に独力で正答率90%以上の練習を2回達成すると通過します。';

  @override
  String get goalsBeginner => 'まず文字コースを進めましょう。修了後、目標に合わせた聞き取りと交信練習が毎日の計画に加わります。';

  @override
  String get goalsComplete => 'すべての目標を達成';

  @override
  String get goalsPractice => '次の技能を練習';

  @override
  String get goalsCopying => '文字の聞き取り';

  @override
  String get goalsSending => '読みやすい送信';

  @override
  String get goalsWords => '単語の聞き取り';

  @override
  String get goalsPhrases => '短文の理解';

  @override
  String get goalsInformation => '交信情報の把握';

  @override
  String get goalsStory => '短い物語のヘッドコピー';

  @override
  String get goalsQso => '交信を完了';

  @override
  String get goalsCompetition => 'コンテスト運用';

  @override
  String get goalsPlanListening => '目標に必要な情報を聞き取りましょう。';

  @override
  String get goalsPlanExchange => '目標に合わせた対話型交信を練習しましょう。';

  @override
  String get mistakesTitle => '復習用の間違いノート';

  @override
  String get mistakesPending => '要復習';

  @override
  String get mistakesRecovered => '習得済み';

  @override
  String get mistakesHint => '元の問題を元の速度と受信条件で再練習します。異なる2日間で補助なしに完全正解すると習得済みになります。再生し直したり答えを表示した場合は習得の判定に含まれません。';

  @override
  String get mistakesEmptyPending => '復習待ちの問題はありません。練習で間違えた問題がここに保存されます。';

  @override
  String get mistakesEmptyRecovered => '習得済みの問題はまだありません。異なる2日間で補助なしに正解してください。';

  @override
  String get mistakesOriginalCopy => '最初の誤答';

  @override
  String get mistakesLastCopy => '最近の回答';

  @override
  String get mistakesNoAnswer => '未回答';

  @override
  String get mistakesFailures => '誤答回数';

  @override
  String get mistakesFirstFailure => '最初の誤答日';

  @override
  String get mistakesLastFailure => '最近の誤答日';

  @override
  String get mistakesCorrectDays => '補助なしで正解した日数';

  @override
  String get mistakesRecoveredOn => '習得日';

  @override
  String get mistakesRetry => '元の問題を再練習';

  @override
  String get qsoAdvancedContestTitle => 'コンテスト交信';

  @override
  String get qsoAdvancedContestHint => 'コールサイン、RST、連番を交換し、訂正された連番を確認します。';

  @override
  String get qsoAdvancedPotaTitle => 'POTA 公園間交信';

  @override
  String get qsoAdvancedPotaHint => 'コールサイン、RST、公園番号を交換し、訂正された公園を確認します。';

  @override
  String get qsoAdvancedSerialLabel => '自局の連番';

  @override
  String get qsoAdvancedParkLabel => '自局の公園番号';

  @override
  String get qsoAdvancedInvalidSerial => '1〜9999 の連番を入力してください。';

  @override
  String get qsoAdvancedInvalidPark => '公園の接頭辞と 4〜5 桁の数字を入力します。例：US-1234。';

  @override
  String get qsoAdvancedRepeatTitle => '一項目だけ再送';

  @override
  String get qsoAdvancedRepeatHint => '聞き逃した情報だけを要求します。交信の段階は進みません。';

  @override
  String get qsoAdvancedTypedMode => '文字で返信（補助あり）';

  @override
  String get qsoAdvancedKeyedMode => '返信を打鍵';

  @override
  String get qsoAdvancedTypedReply => '自局の送信内容';

  @override
  String get qsoAdvancedContestStage => 'RST と自局の連番を送信';

  @override
  String get qsoAdvancedPotaStage => 'RST と自局の公園番号を送信';

  @override
  String get qsoAdvancedCorrectionStage => '訂正情報を確認';

  @override
  String get qsoAdvancedCorrectionHint => 'CORR を聞いたら、相手の RST と訂正された連番または公園を確認します。速度を上げる前に明瞭な送信を練習します。';

  @override
  String get qsoAdvancedIssueMissingSerial => 'NR と自局の連番を送信してください。';

  @override
  String get qsoAdvancedIssueInvalidSerial => '連番は 0 より大きい 1〜4 桁の数字です。';

  @override
  String get qsoAdvancedIssueWrongSerial => '連番が確認すべき番号と一致しません。';

  @override
  String get qsoAdvancedIssueMissingPark => 'PARK と公園番号を送信してください。';

  @override
  String get qsoAdvancedIssueInvalidPark => '公園の接頭辞と 4〜5 桁の数字を使用してください。';

  @override
  String get qsoAdvancedIssueWrongPark => '公園番号が確認すべき公園と一致しません。';

  @override
  String get qsoAdvancedIssueWrongRemoteRst => '相手から聞いた RST を確認してください。';

  @override
  String get qsoAdvancedContestSummary => 'コンテスト練習：コールサイン、レポート、連番、訂正を確認しました。';

  @override
  String get qsoAdvancedPotaSummary => 'POTA 練習：コールサイン、レポート、公園、訂正を確認しました。';

  @override
  String get comprehensionTitle => '単語・文章の聞き取り';

  @override
  String get comprehensionIntro => 'メッセージ全体を聞き、意味を覚えてから答えましょう。教材はオリジナルで、オフラインでも使えます。';

  @override
  String get comprehensionModeLabel => '練習モード';

  @override
  String get comprehensionWords => '単語';

  @override
  String get comprehensionPhrases => '語の一部と短文';

  @override
  String get comprehensionQso => 'QSO 情報';

  @override
  String get comprehensionPota => 'POTA 交換';

  @override
  String get comprehensionStory => '短い物語';

  @override
  String get comprehensionWordsHelp => '文字を書き取らず、音から単語全体を認識します。';

  @override
  String get comprehensionPhrasesHelp => 'なじみのある語の一部から、短い表現や文の聞き取りへ進みます。';

  @override
  String get comprehensionQsoHelp => 'コールサイン、名前、所在地、信号レポートを覚えます。';

  @override
  String get comprehensionPotaHelp => '双方のコールサイン、公園番号、信号レポートを覚えます。最初は呼び出される局のコールサインです。';

  @override
  String get comprehensionStoryHelp => '書き取らず、誰が、どこへ、いつ、何をしに行ったかを覚えます。音声中の英単語で答えます。';

  @override
  String get comprehensionSpeedLabel => '実効速度';

  @override
  String comprehensionSpeed(String character, String effective) {
    return '文字 $character / 実効 $effective WPM';
  }

  @override
  String comprehensionPreviewMissing(String symbols) {
    return '未習得の記号が含まれます：$symbols。補助付きプレビューとして聞けます。';
  }

  @override
  String get comprehensionAssisted => '補助付き練習 · 再生・テキスト表示・未習得記号';

  @override
  String get comprehensionIndependent => '独立した試行 · 1 回聞き、テキストを表示しない';

  @override
  String get comprehensionReveal => 'テキストを表示（補助）';

  @override
  String get comprehensionTarget => '送信テキスト';

  @override
  String get comprehensionAnswer => '単語または短文';

  @override
  String get comprehensionCallsign => '呼び出される局 / コールサイン';

  @override
  String get comprehensionOtherCallsign => '送信局 / コールサイン';

  @override
  String get comprehensionName => 'オペレーター名';

  @override
  String get comprehensionQth => '所在地（QTH）';

  @override
  String get comprehensionRst => '信号レポート（RST）';

  @override
  String get comprehensionPark => '公園番号';

  @override
  String get comprehensionPerson => '誰？';

  @override
  String get comprehensionDestination => 'どこへ行った？';

  @override
  String get comprehensionTime => 'いつ？';

  @override
  String get comprehensionAction => '何をしに行った？';

  @override
  String comprehensionScore(int correct, int total) {
    return '$total 項目中 $correct 項目正解';
  }

  @override
  String get comprehensionNext => '次のメッセージ';

  @override
  String get comprehensionDone => '完了';

  @override
  String get comprehensionSaveFailed => '結果を保存できませんでした。退出前に再試行してください。';

  @override
  String get comprehensionAudioFailed => '音声を利用できません。出力機器を確認して再試行してください。';

  @override
  String get comprehensionAudioRequired => '他の練習で音声を無効にしていても、この聞き取り練習は音声を使います。';

  @override
  String comprehensionHistory(int count, int percent) {
    return '最近の独立した試行：$count 回 · 情報正答率 $percent%';
  }

  @override
  String get comprehensionEmptyHistory => '独立した聞き取りの結果がここに表示されます。補助付き練習は別に記録されます。';

  @override
  String get comprehensionFieldCorrect => '正解';

  @override
  String get comprehensionFieldWrong => 'この項目を復習';

  @override
  String get comprehensionListen => '聞く';
}
