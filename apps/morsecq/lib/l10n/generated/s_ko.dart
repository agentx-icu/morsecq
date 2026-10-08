// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => '학습';

  @override
  String get navMe => '내 정보';

  @override
  String get navReference => '참고';

  @override
  String get navLearnDescription => 'Koch 방식 강의, 송신 연습과 수신 받아쓰기 연습.';

  @override
  String get navReferenceDescription => '문자표, 절차 부호, Q 부호, 약어와 양방향 변환기.';

  @override
  String get actionCancel => '취소';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionClose => '닫기';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystemDefault => '시스템 기본값';

  @override
  String get languageSaveFailed => '언어 설정을 저장할 수 없습니다. 다시 시도하세요.';

  @override
  String learnLessonOf(int lesson, int total) {
    return '강의 $lesson / $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 문자 학습 완료',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal개 문자';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days일 연속 연습',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '복습할 문자 $count개',
      zero: '복습할 문자가 없습니다',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$total개 중 $correct개 정답';
  }

  @override
  String learnRoundOf(int round) {
    return '라운드 $round';
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
      other: '$count개 문자 송신 완료',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return '다음 문자가 열렸습니다: $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target을 놓쳤습니다';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target을 $answered로 잘못 들었습니다';
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
      other: '문자 $count개',
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
      other: '$count개 문자 학습 완료',
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
      other: '$count개 문자 받아쓰기',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '연습 $count회',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '최장 $count일 연속',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal개 문자';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining개 문자 남음',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '최근 $count회 연습',
      one: '지난 연습',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return '연습 $index / $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total 정답';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return '강의 $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count회 시도',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$attempts회 중 $correct회 정답';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return '강의 $lesson에서 처음 학습';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return '상자 $box / $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days일 후 복습',
      one: '내일 복습',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count회',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count회',
    );
    return '$target을 $answered로 응답, $_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '문자 $chars개',
      zero: '연습 없음',
    );
    return '$date: $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '연습한 날 $count일',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목',
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
    return '건너뜀(모스 부호 없음): $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Koch 학습 순서: $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return '추정 $wpm WPM';
  }

  @override
  String get accountSectionTraining => '훈련';

  @override
  String get accountSectionAbout => '앱 정보';

  @override
  String get accountTrainingDefaults => '재생 및 훈련 기본 설정';

  @override
  String get accountTrainingDefaultsSubtitle => '속도, 음높이, Farnsworth 간격';

  @override
  String get accountAboutLicence => '라이선스';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => '소스 코드';

  @override
  String get accountAboutSourceCopied => '소스 코드 링크를 복사했습니다';

  @override
  String get chatSend => '보내기';

  @override
  String get learnLessonCardTitle => 'Koch 강의';

  @override
  String get learnCourseComplete => '과정 완료! 계속 실력을 다듬어 보세요.';

  @override
  String get learnDailyGoalTitle => '오늘';

  @override
  String get learnDailyGoalMet => '일일 목표 달성';

  @override
  String get learnNoStreak => '오늘부터 매일 연습해 보세요';

  @override
  String get learnContinueLesson => '강의 계속하기';

  @override
  String get learnReceivePractice => '수신 연습';

  @override
  String get learnSendPractice => '송신 연습';

  @override
  String get learnReviewDue => '복습할 문자';

  @override
  String get learnSettings => '훈련 설정';

  @override
  String get learnLoading => '학습 진도 불러오는 중…';

  @override
  String get learnLoadFailed => '저장된 진도를 읽을 수 없습니다. 처음부터 시작합니다. 기존 파일은 .corrupt로 보관되었습니다.';

  @override
  String get learnProgressSaveFailed => '진행 상황을 저장하지 못했습니다. MorseCQ를 닫기 전까지는 이번 결과가 유지됩니다.';

  @override
  String get learnChooseDrill => '연습 선택';

  @override
  String get learnDrillGroups => '무작위 문자 묶음';

  @override
  String get learnDrillWords => '단어';

  @override
  String get learnDrillCallsigns => '콜사인';

  @override
  String get learnDrillQso => '교신(QSO)';

  @override
  String get learnDrillCharacters => '한 문자씩';

  @override
  String get learnDrillAbbreviations => '약어와 Q 부호';

  @override
  String get learnDrillNumbers => '숫자 묶음';

  @override
  String get learnDrillConfusables => '혼동하기 쉬운 문자';

  @override
  String get learnDrillContest => '대회 교환 정보';

  @override
  String get learnDrillGroupsHint => '학습한 문자로 구성한 무작위 문자 묶음';

  @override
  String get learnDrillCharactersHint => '한 번에 한 문자씩 듣고 바로 답하세요';

  @override
  String get learnDrillWordsHint => '자주 쓰는 영어 단어';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL 등 무선 교신 약어';

  @override
  String get learnDrillNumbersHint => '전문과 일련번호에 쓰이는 다섯 자리 숫자 묶음';

  @override
  String get learnDrillCallsignsHint => '전 세계 아마추어 무선 콜사인';

  @override
  String get learnDrillConfusablesHint => 'S/H, U/V 등 혼동하기 쉬운 문자를 짝지어 연습';

  @override
  String get learnDrillQsoHint => '전체 교신에 쓰이는 문장';

  @override
  String get learnDrillContestHint => '대회 속도로 콜사인, 5NN과 일련번호 또는 구역 번호 수신';

  @override
  String get learnDrillReviewHint => '복습할 때가 된 문자';

  @override
  String get toolsTitle => '무선 도구';

  @override
  String get toolsGridTitle => '그리드 로케이터';

  @override
  String get toolsGridHint => '좌표를 로케이터로 변환하고 거리와 안테나 방위각 확인';

  @override
  String get toolsBandsTitle => '주파수 대역과 안테나';

  @override
  String get toolsBandsHint => '주파수가 속한 대역, 파장과 다이폴 길이 확인';

  @override
  String get toolsSpeedTitle => 'CW 속도';

  @override
  String get toolsSpeedHint => 'WPM을 단점 길이, 간격과 분당 문자 수로 변환';

  @override
  String get toolsRstTitle => 'RST 신호 보고';

  @override
  String get toolsRstHint => '신호 보고를 구성하고 각 숫자의 의미 확인';

  @override
  String get toolsClockTitle => 'UTC 시계';

  @override
  String get toolsClockHint => '로그에 쓰는 UTC 시간과 현지 시간을 함께 표시';

  @override
  String get toolsGridFromCoordinates => '좌표로 계산';

  @override
  String get toolsGridLatitude => '위도';

  @override
  String get toolsGridLongitude => '경도';

  @override
  String get toolsGridCoordinatesHelp => '십진수 도 단위로 입력하세요. 남위와 서경은 음수입니다';

  @override
  String get toolsGridInvalidCoordinates => '위도는 -90~90, 경도는 -180~180';

  @override
  String get toolsGridLocator => '로케이터';

  @override
  String get toolsGridDistanceSection => '거리와 방위각';

  @override
  String get toolsGridMine => '내 로케이터';

  @override
  String get toolsGridTheirs => '상대방 로케이터';

  @override
  String get toolsGridInvalidLocator => '2, 4, 6 또는 8자로 입력하세요. 예: OM89ex';

  @override
  String get toolsGridCenter => '그리드 중심';

  @override
  String get toolsGridDistance => '거리';

  @override
  String get toolsGridShortPath => '단경로 방위각';

  @override
  String get toolsGridLongPath => '장경로 방위각';

  @override
  String get toolsBandsFrequency => '주파수(MHz)';

  @override
  String get toolsBandsInvalidFrequency => '0보다 큰 주파수를 입력하세요';

  @override
  String toolsBandsRegionLabel(int number) {
    return '제$number지역';
  }

  @override
  String get toolsBandsRegionHelp => '1: 유럽, 아프리카, 중동 — 2: 아메리카 — 3: 아시아·태평양';

  @override
  String toolsBandsInBand(String band) {
    return '$band 아마추어 무선 대역에 포함';
  }

  @override
  String get toolsBandsOutOfBand => '아마추어 무선 대역 밖';

  @override
  String get toolsBandsWavelength => '파장';

  @override
  String get toolsBandsDipole => '반파장 다이폴(전체 길이)';

  @override
  String get toolsBandsQuarterWave => '1/4파장 수직 안테나';

  @override
  String get toolsBandsAntennaNote => '길이에 0.95 단축 계수가 반영되어 있습니다. 공진하도록 길이를 조정하세요.';

  @override
  String get toolsBandsTable => '주파수 대역 경계';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'ITU의 주파수 분배입니다. 면허와 국가별 주파수 계획에 따라 허용 범위가 더 좁을 수 있습니다.';

  @override
  String get toolsSpeedCharacter => '문자 속도';

  @override
  String get toolsSpeedFarnsworth => 'Farnsworth 간격';

  @override
  String get toolsSpeedOverall => '전체 속도';

  @override
  String get toolsSpeedDit => '단점';

  @override
  String get toolsSpeedDah => '장점';

  @override
  String get toolsSpeedCharGap => '문자 사이 간격';

  @override
  String get toolsSpeedWordGap => '단어 사이 간격';

  @override
  String get toolsSpeedCpm => '분당 문자 수';

  @override
  String get toolsSpeedParis => 'PARIS 한 단어 송신 시간';

  @override
  String get toolsRstReadability => '명료도(R)';

  @override
  String get toolsRstStrength => '신호 강도(S)';

  @override
  String get toolsRstTone => '음질(T)';

  @override
  String get toolsRstReport => '보고';

  @override
  String get toolsRstCut => '대회용 약식 표기';

  @override
  String get toolsRstPhone => '음성 통신(음질 항목 없음)';

  @override
  String get toolsRstR1 => '알아들을 수 없음';

  @override
  String get toolsRstR2 => '겨우 알아들을 수 있으며 가끔 단어가 들림';

  @override
  String get toolsRstR3 => '상당히 어렵지만 알아들을 수 있음';

  @override
  String get toolsRstR4 => '거의 어려움 없이 알아들을 수 있음';

  @override
  String get toolsRstR5 => '완전히 알아들을 수 있음';

  @override
  String get toolsRstS1 => '미약하여 겨우 감지됨';

  @override
  String get toolsRstS2 => '매우 약함';

  @override
  String get toolsRstS3 => '약함';

  @override
  String get toolsRstS4 => '보통';

  @override
  String get toolsRstS5 => '비교적 양호함';

  @override
  String get toolsRstS6 => '양호함';

  @override
  String get toolsRstS7 => '비교적 강함';

  @override
  String get toolsRstS8 => '강함';

  @override
  String get toolsRstS9 => '매우 강함';

  @override
  String get toolsRstT1 => '매우 거칠고 폭이 넓은 미정류 교류음';

  @override
  String get toolsRstT2 => '매우 거칠고 날카로우며 폭이 넓은 교류음';

  @override
  String get toolsRstT3 => '거친 음, 정류되었으나 평활화되지 않음';

  @override
  String get toolsRstT4 => '거친 음이나 약간의 평활화 흔적이 있음';

  @override
  String get toolsRstT5 => '평활화되었으나 리플 변조가 심함';

  @override
  String get toolsRstT6 => '평활화되었으나 뚜렷한 리플이 있음';

  @override
  String get toolsRstT7 => '거의 순수한 음이나 약간의 리플이 있음';

  @override
  String get toolsRstT8 => '거의 완벽한 음으로 아주 약한 변조 흔적이 있음';

  @override
  String get toolsRstT9 => '완벽한 음으로 리플이 전혀 없음';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => '현지 시간';

  @override
  String get toolsClockNote => '로그와 QSL 카드에는 UTC를 사용합니다.';

  @override
  String get learnReceiveTitle => '수신';

  @override
  String get learnReviewTitle => '복습';

  @override
  String get learnListen => '들어 보세요…';

  @override
  String get learnReady => '준비 완료';

  @override
  String get learnReplay => '다시 재생';

  @override
  String get learnAnswerHint => '들은 내용을 입력하세요';

  @override
  String get learnSubmit => '정답 확인';

  @override
  String get learnNext => '다음';

  @override
  String get learnFinish => '종료';

  @override
  String get learnDone => '완료';

  @override
  String get learnBackspace => '삭제';

  @override
  String get learnSpace => '공백';

  @override
  String get learnSent => '송신 내용';

  @override
  String get learnYourCopy => '받아쓴 내용';

  @override
  String get learnRoundPerfect => '모두 정확히 받아썼습니다!';

  @override
  String get learnSessionSummary => '연습 요약';

  @override
  String get learnLessonPassed => '강의 통과';

  @override
  String get learnLessonNotPassed => '계속 연습하세요: 정답률 90%면 다음 문자가 열립니다';

  @override
  String get learnReviewRecorded => '복습이 기록되었습니다';

  @override
  String get learnWeakChars => '더 연습할 문자';

  @override
  String get learnConfusions => '혼동한 문자';

  @override
  String get learnNoFeedbackWarning => '소리, 화면 깜박임과 진동이 모두 꺼져 있습니다. 대신 화면을 깜박입니다.';

  @override
  String get learnSendTitle => '송신';

  @override
  String get learnSendThis => '이 내용을 송신하세요';

  @override
  String get learnCopyFromMemory => '기억으로';

  @override
  String get learnHiddenTarget => '숨김 — 기억으로 송신하세요';

  @override
  String get learnDecoded => '해독 결과';

  @override
  String get learnWaitingForKey => '준비되면 송신을 시작하세요';

  @override
  String get learnRestart => '다시 시작';

  @override
  String get learnTryAnother => '다른 문제 풀기';

  @override
  String get learnKeyerStraight => '수동 전건';

  @override
  String get learnKeyerIambicA => '아이앰빅 A';

  @override
  String get learnKeyerIambicB => '아이앰빅 B';

  @override
  String get learnLegendStraight => '스페이스 키 = 전건';

  @override
  String get learnLegendPaddles => '왼쪽 Ctrl = 단점, 오른쪽 Ctrl = 장점';

  @override
  String get learnSendClean => '깔끔한 송신입니다. 고칠 부분이 없습니다.';

  @override
  String get learnSendIssues => '리듬 조언';

  @override
  String get learnYourSending => '해독된 내용';

  @override
  String get learnStraightKeyLabel => '전건';

  @override
  String get learnDitLabel => '단점';

  @override
  String get learnDahLabel => '장점';

  @override
  String get learnSettingsTitle => '훈련 설정';

  @override
  String get learnCharacterSpeed => '문자 속도';

  @override
  String get learnFarnsworth => 'Farnsworth 간격';

  @override
  String get learnFarnsworthHelp => '문자는 빠르게 유지하고 문자 사이 간격을 이 속도에 맞춰 늘립니다.';

  @override
  String get learnEffectiveSpeed => '실효 속도';

  @override
  String get learnTone => '음높이';

  @override
  String get learnPlaySample => '예시 재생';

  @override
  String get learnSessionLength => '연습 길이';

  @override
  String get learnFeedback => '피드백';

  @override
  String get learnSound => '소리';

  @override
  String get learnFlash => '화면 깜박임';

  @override
  String get learnHaptic => '진동';

  @override
  String get learnKeyer => '전건 모드';

  @override
  String get learnDailyGoal => '일일 목표';

  @override
  String get referenceReferenceTitle => '모스 부호 참고 자료';

  @override
  String get referenceTranslatorTitle => '변환기';

  @override
  String get referencePlay => '재생';

  @override
  String get referenceStop => '정지';

  @override
  String get referenceClear => '지우기';

  @override
  String get referenceClose => '닫기';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => '문자, 절차 부호, Q 부호 검색…';

  @override
  String get referenceClearSearch => '검색 지우기';

  @override
  String get referenceNoResults => '검색과 일치하는 항목이 없습니다.';

  @override
  String get referenceSectionAlphabet => '문자표';

  @override
  String get referenceSectionPunctuation => '문장 부호';

  @override
  String get referenceSectionProsigns => '절차 부호';

  @override
  String get referenceSectionQCodes => 'Q 부호';

  @override
  String get referenceSectionAbbreviations => 'CW 약어';

  @override
  String get referenceSectionKoch => 'Koch 학습 순서';

  @override
  String get referenceAlphabetHint => '카드를 탭하면 소리를 들을 수 있습니다. 길게 누르면 암기법을 볼 수 있습니다.';

  @override
  String get referenceKochHint => 'Koch 방식으로 문자를 배우는 순서입니다(LCWO 순서). K와 M으로 시작하고 받아쓰기 정답률이 90%에 도달하면 문자를 하나 추가합니다.';

  @override
  String get referenceMnemonicTitle => '암기법';

  @override
  String get referenceMeaningLabel => '의미';

  @override
  String get referencePlaybackSettings => '재생 설정';

  @override
  String get referenceCharacterSpeed => '문자 속도';

  @override
  String get referenceFarnsworth => 'Farnsworth 간격';

  @override
  String get referenceFarnsworthHelp => '문자 속도는 유지하고 간격을 실효 속도에 맞춰 늘립니다.';

  @override
  String get referenceEffectiveSpeed => '실효 속도';

  @override
  String get referenceTone => '음높이';

  @override
  String get referenceModeTextToMorse => '텍스트 → 모스 부호';

  @override
  String get referenceModeMorseToText => '모스 부호 → 텍스트';

  @override
  String get referenceModeKey => '전건 송신';

  @override
  String get referenceTextInputLabel => '텍스트';

  @override
  String get referenceTextInputHint => '부호로 변환할 텍스트 입력…';

  @override
  String get referencePatternOutputLabel => '모스 부호';

  @override
  String get referenceCopyPattern => '부호 복사';

  @override
  String get referencePatternCopied => '부호를 복사했습니다';

  @override
  String get referencePatternInputLabel => '모스 부호';

  @override
  String get referencePatternInputHint => '.과 -를 입력하고 문자 사이는 공백, 단어 사이는 /로 구분하세요';

  @override
  String get referenceTextOutputLabel => '텍스트';

  @override
  String get referenceCopyText => '텍스트 복사';

  @override
  String get referenceTextCopied => '텍스트를 복사했습니다';

  @override
  String get referenceUnknownPatternHelp => '대응하는 문자가 없는 부호는 <pattern>으로 표시됩니다.';

  @override
  String get referenceKeypadDit => '단점';

  @override
  String get referenceKeypadDah => '장점';

  @override
  String get referenceKeypadCharGap => '문자 간격';

  @override
  String get referenceKeypadWordGap => '단어 간격';

  @override
  String get referenceKeypadBackspace => '백스페이스';

  @override
  String get referenceKeyHint => '전건을 길게 눌러 송신하세요. 키보드에서는 스페이스 키를 길게 누르세요.';

  @override
  String get referenceKeyLabel => '전건';

  @override
  String get referenceKeyDecodedLabel => '해독 결과';

  @override
  String get referenceKeyPendingLabel => '송신 중';

  @override
  String get statsTitle => '통계';

  @override
  String get statsLoading => '통계 불러오는 중…';

  @override
  String get statsLoadFailed => '학습 진도를 불러올 수 없습니다. 아래로 당기거나 다시 열어 재시도하세요.';

  @override
  String get statsRetry => '다시 시도';

  @override
  String get statsEmptyTitle => '아직 연습 기록이 없습니다';

  @override
  String get statsEmptyBody => '첫 수신 또는 송신 연습을 마치면 정답률 추이, 문자별 숙련도와 연습 달력이 여기에 표시됩니다.';

  @override
  String get statsEmptyCallToAction => '「학습」에서 「강의 계속하기」를 눌러 시작하세요.';

  @override
  String get statsOverviewTitle => '개요';

  @override
  String get statsTileLesson => 'Koch 강의';

  @override
  String get statsTileAccuracy => '정답률';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => '연습량';

  @override
  String get statsTileStreak => '연속 일수';

  @override
  String get statsTileDailyGoal => '일일 목표';

  @override
  String get statsGoalMet => '오늘 달성';

  @override
  String get statsSummaryTitle => '내 통계';

  @override
  String get statsSummaryOpen => '통계 보기';

  @override
  String get statsTrendTitle => '정답률 추이';

  @override
  String get statsTrendHint => '데이터 점을 탭하면 해당 연습을 확인할 수 있습니다.';

  @override
  String get statsSeriesReceive => '수신';

  @override
  String get statsSeriesSend => '송신';

  @override
  String get statsAxisSessions => '연습';

  @override
  String get statsCharsTitle => '문자';

  @override
  String get statsCharsSubtitle => 'Koch 학습 순서입니다. 문자를 탭하면 자세히 볼 수 있습니다.';

  @override
  String get statsCharsNotStarted => '아직 연습하지 않았습니다';

  @override
  String get statsNotInCourse => 'Koch 과정에 포함되지 않습니다';

  @override
  String get statsSrsTitle => '간격 반복 학습';

  @override
  String get statsSrsNotTracked => '아직 예정되지 않았습니다';

  @override
  String get statsSrsDueNow => '지금 복습';

  @override
  String get statsConfusionsTitle => '자주 혼동하는 문자';

  @override
  String get statsConfusionsNone => '혼동 기록이 없습니다';

  @override
  String get statsConfusionMissed => '놓침';

  @override
  String get statsBucketLegendTitle => '정답률';

  @override
  String get statsBucketNone => '없음';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => '혼동 행렬';

  @override
  String get statsHeatmapSubtitle => '행은 송신된 문자, 열은 응답한 문자입니다. 색이 진할수록 횟수가 많습니다.';

  @override
  String get statsHeatmapEmpty => '아직 혼동 기록이 없습니다. 틀린 응답이 여기에 표시됩니다.';

  @override
  String get statsHeatmapLegendLow => '적음';

  @override
  String get statsHeatmapLegendHigh => '많음';

  @override
  String get statsHeatmapAxisTarget => '송신 문자';

  @override
  String get statsHeatmapAxisAnswered => '응답 문자';

  @override
  String get statsCalendarTitle => '연습 달력';

  @override
  String get statsCalendarSubtitle => '최근 12주';

  @override
  String get statsCalendarLegendLess => '적음';

  @override
  String get statsCalendarLegendMore => '많음';

  @override
  String get statsStreakExplanation => '하루에 한 번 이상 연습한 날이 연속으로 이어지면 연속 일수로 계산합니다. 하루를 통째로 쉬면 초기화됩니다. 하루에 두 번 연습해도 하루로 계산합니다.';

  @override
  String get learnStatistics => '통계';

  @override
  String get listenTitle => '듣기';

  @override
  String get listenStart => '시작';

  @override
  String get listenStop => '정지';

  @override
  String get listenStarting => '마이크 시작 중…';

  @override
  String get listenClear => '텍스트 지우기';

  @override
  String get listenCopy => '텍스트 복사';

  @override
  String get listenCopied => '해독된 텍스트를 복사했습니다';

  @override
  String get listenSettings => '듣기 설정';

  @override
  String get listenDecoded => '해독 결과';

  @override
  String get listenEmptyHint => '마이크를 모스 부호 소리 쪽으로 향하게 하세요. 해독된 텍스트가 여기에 표시됩니다.';

  @override
  String get listenIdleHint => '「시작」을 탭하여 모스 부호 소리를 들어 보세요.';

  @override
  String get listenPending => '수신 중';

  @override
  String get listenSpeed => '속도';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => '신호';

  @override
  String get listenToneOn => '소리 감지';

  @override
  String get listenTone => '음 주파수';

  @override
  String get listenToneLocked => '주파수 고정';

  @override
  String get listenToneSearching => '탐색 중';

  @override
  String get listenToneManual => '수동';

  @override
  String get listenAutoTune => '자동 동조';

  @override
  String get listenAutoTuneHelp => '400–1000 Hz 범위에서 가장 강한 음을 추적합니다. 슬라이더를 움직이면 수동으로 동조할 수 있습니다.';

  @override
  String get listenRetune => '자동';

  @override
  String get listenBlockSize => '분석 블록';

  @override
  String get listenBlockSizeHelp => '블록이 작을수록 단점과 장점의 경계를 정확히 찾지만 잡음에 더 민감해집니다. 256샘플(5.3 ms)은 5–40 WPM에 적합합니다.';

  @override
  String get listenMinElement => '최소 부호 요소 길이';

  @override
  String get listenMinElementHelp => '이 길이보다 짧은 음과 간격은 잡음이나 순간 끊김으로 보고 무시합니다.';

  @override
  String get listenPermissionDenied => '마이크 접근이 거부되었습니다. 시스템 설정에서 허용한 후 다시 시도하세요.';

  @override
  String get listenPermissionRetry => '다시 시도';

  @override
  String get listenStartFailed => '마이크를 시작할 수 없습니다.';

  @override
  String get listenNoInput => '마이크를 찾을 수 없습니다. 연결한 후 다시 시도하세요.';

  @override
  String get listenStreamFailed => '마이크가 예기치 않게 중지되었습니다. 다시 시도하세요.';

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
    return '$samples샘플($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => '앱이 백그라운드로 이동하여 듣기를 중지했습니다.';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => '단점이 너무 깁니다';

  @override
  String get learnTipDahTooShortTitle => '장점이 너무 짧습니다';

  @override
  String get learnTipIntraGapTooLongTitle => '부호 요소 간격이 너무 넓습니다';

  @override
  String get learnTipCharGapTooShortTitle => '문자 간격이 너무 좁습니다';

  @override
  String get learnTipWordGapTooShortTitle => '단어 간격이 너무 좁습니다';

  @override
  String get learnTipSpeedUnsteadyTitle => '속도가 일정하지 않습니다';

  @override
  String get learnSeverityMinor => '경미';

  @override
  String get learnSeverityModerate => '뚜렷함';

  @override
  String get learnSeveritySevere => '심함';

  @override
  String learnNewestCharIs(String char) {
    return '이번 강의의 새 문자: $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, 새 문자';
  }

  @override
  String learnPendingPattern(String pattern) {
    return '송신 중: $pattern';
  }

  @override
  String learnIssueHeadline(String title, String severity) {
    return '$title($severity)';
  }

  @override
  String learnRatioTimes(String ratio) {
    return '$ratio배';
  }

  @override
  String learnTipDitTooLong(String ratio) {
    return '단점이 너무 깁니다(단점 길이의 약 $ratio). \'다아\'가 아니라 \'딧\'처럼 짧게 내세요. 단점은 길게 누르지 않고 가볍게 톡 누릅니다.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return '장점이 너무 짧습니다(단점 길이의 약 $ratio, 목표는 3배). 단점 세 개 길이만큼 누르세요.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return '문자 안의 간격이 너무 넓습니다(단점 길이의 약 $ratio). 한 문자의 부호 요소를 촘촘하게 이어 송신하세요.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return '문자들이 붙어 있습니다(간격이 단점 길이의 약 $ratio, 목표는 3배). 문자마다 뚜렷한 쉼을 두세요.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return '단어들이 너무 가깝습니다(간격이 단점 길이의 약 $ratio, 목표는 7배). 단어 사이에는 긴 쉼을 두세요.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return '속도가 흔들립니다(변동 $percent%). 일정한 박자를 정하고 한 줄 내내 유지하세요.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '단점 $total개 중 $offending개가 너무 깁니다(평균: 단점 길이의 $ratio)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '장점 $total개 중 $offending개가 너무 짧습니다(평균: 단점 길이의 $ratio)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '문자 안 간격 $total개 중 $offending개가 너무 깁니다(평균: 단점 길이의 $ratio)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '문자 간격 $total개 중 $offending개가 너무 짧습니다(평균: 단점 길이의 $ratio)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '단어 간격 $total개 중 $offending개가 너무 짧습니다(평균: 단점 길이의 $ratio)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return '송신 속도가 일정하지 않습니다(변동 계수 $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return '최근 7일 / 전체 $allTime';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds초';
  }

  @override
  String desktopTrayShow(String app) {
    return '$app 표시';
  }

  @override
  String desktopTrayHide(String app) {
    return '$app 숨기기';
  }

  @override
  String get desktopTraySoundOn => '소리 켜짐';

  @override
  String get desktopTraySoundOff => '소리 꺼짐';

  @override
  String desktopTrayQuit(String app) {
    return '$app 종료';
  }

  @override
  String get listenStateOn => '켜짐';

  @override
  String get listenStateOff => '꺼짐';

  @override
  String referenceTelegraphCodes(String codes) {
    return '중국어 전신 부호: $codes';
  }

  @override
  String get referenceTelegraphMainland => '중국 본토(1983)';

  @override
  String get referenceTelegraphTaiwan => '대만 / 홍콩';

  @override
  String get referenceTelegraphNone => '이 부호표에 없음';

  @override
  String get appearanceTitle => '화면 모양';

  @override
  String get appearanceStyles => '인터페이스 스타일';

  @override
  String get appearanceChoose => '스타일을 선택하고 미리 본 후 적용하세요';

  @override
  String get appearanceMode => '밝기';

  @override
  String get appearancePreview => '미리 보기';

  @override
  String get appearanceApply => '스타일 적용';

  @override
  String get appearanceRestore => '기본값 복원';

  @override
  String get appearanceApplied => '화면 모양을 저장했습니다';

  @override
  String get appearanceSaveFailed => '화면 모양을 저장할 수 없습니다. 다시 시도하세요.';

  @override
  String get appearanceClassic => '고전적인 황동';

  @override
  String get appearanceModern => '차분한 현대';

  @override
  String get appearanceRadio => '밤의 무선국';

  @override
  String get appearancePaper => '종이 수첩';

  @override
  String get appearanceCartoon => '산뜻한 만화';

  @override
  String get appearanceLight => '밝게';

  @override
  String get appearanceDark => '어둡게';

  @override
  String learnShowAllChars(int count) {
    return '문자 $count개 모두 보기';
  }

  @override
  String get learnShowFewerChars => '문자 접기';

  @override
  String get learnLeaveDrillTitle => '이 세션을 나가시겠습니까?';

  @override
  String get learnLeaveDrillBody => '이 세션에서 진행한 라운드는 저장되지 않습니다.';

  @override
  String get learnLeaveDrillConfirm => '나가기';

  @override
  String get learnReplayAssistedNote => '다시 들음: 연습으로는 집계되지만 레슨 해제나 복습 갱신에는 반영되지 않습니다.';

  @override
  String get learnPlanTitle => '오늘의 계획';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return '약 $minutes분 · $total단계 중 $done단계 완료';
  }

  @override
  String get learnPlanBudget => '계획 길이';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get learnPlanStart => '계획 시작';

  @override
  String get learnPlanContinue => '계획 계속';

  @override
  String get learnPlanStepReview => '복습할 문자';

  @override
  String get learnPlanStepFocus => '집중 연습';

  @override
  String learnPlanStepCourse(int lesson) {
    return '레슨 $lesson';
  }

  @override
  String get learnPlanStepSend => '송신 연습';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return '복습 차례: $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return '자주 헷갈림: $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return '정확도 90% 미만: $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count자: 다음 레슨을 열 수 있음';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return '다음 레슨을 열 수 있도록 $count자로 늘렸습니다';
  }

  @override
  String get learnPlanReasonConsolidate => '짧은 연습: 이번 레슨을 다지며 다음 레슨은 열리지 않습니다';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return '코스가 진행됨: 레슨 $lesson을 연습하지만 해제하지 않습니다';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '짧은 목표 $count개 송신';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return '완료 · $percent%';
  }

  @override
  String get learnPlanStepDone => '완료';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$total개 중 $done개 송신';
  }

  @override
  String get learnPlanStale => '레슨 또는 속도가 바뀌었습니다. 시작하지 않은 단계를 갱신할까요?';

  @override
  String get learnPlanUpdate => '단계 갱신';

  @override
  String get learnPlanComplete => '오늘 계획 완료';

  @override
  String learnPlanNeedsWork(String symbols) {
    return '더 연습할 문자: $symbols';
  }

  @override
  String get learnPlanAllGood => '오늘은 약한 문자가 없습니다.';

  @override
  String get learnPlanTomorrow => '내일 새 계획이 만들어집니다. 자유 연습은 언제든 가능합니다.';

  @override
  String learnPlanEarlier(int done, int total) {
    return '이전 계획은 $total단계 중 $done단계에서 멈췄으며 오늘에는 반영되지 않습니다.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return '유효 속도 $wpm WPM으로 올릴 준비가 되었습니다';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return '$wpm WPM으로 올릴 준비가 되었습니다';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return '이 속도에서는 수신이 어렵습니다. 유효 속도 $wpm WPM 또는 집중 연습을 해 보세요.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return '최근 보조 없는 연습 $count회($percent%) 기준입니다. 적용하기 전에는 아무것도 바뀌지 않습니다.';
  }

  @override
  String get learnSpeedAdviceApply => '적용';

  @override
  String get learnSpeedAdviceDismiss => '나중에';

  @override
  String get learnSpeedAdviceInsufficient => '속도 조언에는 현재 속도에서 50자 이상의 보조 없는 연습 3회가 필요합니다.';

  @override
  String get learnQsoAction => 'QSO 시뮬레이터';

  @override
  String learnQsoLocked(int lesson) {
    return '레슨 $lesson부터';
  }

  @override
  String get learnQsoTitle => 'QSO 시뮬레이터';

  @override
  String get learnQsoRespond => 'CQ에 응답';

  @override
  String get learnQsoRespondHint => '한 국이 CQ를 냅니다. 응답하고 리포트를 교환하세요.';

  @override
  String get learnQsoCall => 'CQ 내기';

  @override
  String get learnQsoCallHint => 'CQ를 내면 한 국이 응답합니다.';

  @override
  String get learnQsoYourCall => '내 호출부호';

  @override
  String get learnQsoYourName => '내 이름';

  @override
  String get learnQsoYourQth => '내 QTH';

  @override
  String get learnQsoInvalidCall => 'BD1XYZ 같은 호출부호를 입력하세요';

  @override
  String get learnQsoInvalidWord => '한 단어, A–Z 문자만';

  @override
  String get learnQsoOffline => '이 기기에서만 동작하며 아무것도 전송하지 않습니다.';

  @override
  String get learnQsoStart => 'QSO 시작';

  @override
  String get learnQsoResume => '중단된 QSO 이어하기';

  @override
  String get learnQsoStageCallCq => '내 호출부호로 CQ 내기';

  @override
  String get learnQsoStageCallConfirm => '응답: 상대 부호, DE, 내 부호';

  @override
  String get learnQsoStageExchange => '리포트, 이름, QTH 보내기';

  @override
  String get learnQsoStageConfirmInfo => '상대 정보 확인';

  @override
  String get learnQsoStageClosing => '73과 <SK>로 마무리';

  @override
  String get learnQsoStageDone => 'QSO 완료';

  @override
  String learnQsoSpeed(int wpm) {
    return '상대는 유효 $wpm WPM으로 송신';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call 송신';
  }

  @override
  String get learnQsoRemoteHidden => '귀로 받아 적으세요. 텍스트는 숨겨져 있습니다.';

  @override
  String get learnQsoShowText => '텍스트 보기';

  @override
  String get learnQsoListen => '듣기';

  @override
  String get learnQsoAccepted => '통과';

  @override
  String get learnQsoRejected => '통과하지 못함';

  @override
  String get learnQsoRemoteSending => '상대 국이 송신 중…';

  @override
  String get learnQsoYourTurn => '내 차례: 응답을 키잉한 뒤 보내기를 누르세요.';

  @override
  String get learnQsoDecoded => '내 송신 내용';

  @override
  String get learnQsoNothingKeyed => '아직 키잉하지 않음';

  @override
  String get learnQsoPlayAgain => '반복 요청(AGN)';

  @override
  String get learnQsoSlower => '속도 낮춤 요청(QRS)';

  @override
  String get learnQsoHint => '힌트';

  @override
  String learnQsoHintLabel(String example) {
    return '예: $example';
  }

  @override
  String get learnQsoPause => '일시정지';

  @override
  String get learnQsoSend => '보내기';

  @override
  String get learnQsoClear => '지우기';

  @override
  String get learnQsoIssueEmpty => '키잉한 내용이 없습니다.';

  @override
  String get learnQsoIssueMissingCq => 'CQ로 시작하세요.';

  @override
  String get learnQsoIssueMissingDe => '호출부호 사이에 DE를 넣으세요.';

  @override
  String get learnQsoIssueWrongLocalCall => '내 호출부호가 없거나 틀렸습니다.';

  @override
  String get learnQsoIssueWrongRemoteCall => '상대 국의 호출부호가 틀렸습니다.';

  @override
  String get learnQsoIssueReversedCalls => '순서가 반대입니다: 상대, DE, 내 부호 순입니다.';

  @override
  String get learnQsoIssueMissingEnding => 'K 또는 KN으로 끝내세요.';

  @override
  String get learnQsoIssueMissingRst => '리포트를 주세요. 예: UR RST 599';

  @override
  String get learnQsoIssueInvalidRst => 'RST 범위를 벗어났습니다(R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'NAME과 이름을 보내세요.';

  @override
  String get learnQsoIssueWrongName => '이번 QSO의 내 이름이 아닙니다.';

  @override
  String get learnQsoIssueMissingQth => 'QTH와 위치를 보내세요.';

  @override
  String get learnQsoIssueWrongQth => '이번 QSO의 내 QTH가 아닙니다.';

  @override
  String get learnQsoIssueMissingAck => 'R 또는 QSL로 확인하세요.';

  @override
  String get learnQsoIssueWrongRemoteName => '상대 운용자 이름을 확인하세요.';

  @override
  String get learnQsoIssueMissing73 => '73을 넣으세요.';

  @override
  String get learnQsoIssueMissingSk => '<SK>로 교신을 끝내세요.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return '한 번에 통과: $total단계 중 $count';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return '반복: $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return '힌트: $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return '내 송신: 약 $wpm WPM';
  }

  @override
  String get learnQsoSummaryNote => 'QSO 결과는 수신 정확도와 따로 집계되며 레슨을 열지 않습니다.';

  @override
  String get learnTipDahTooLongTitle => '장점이 너무 김';

  @override
  String learnTipDahTooLong(String ratio) {
    return '장점이 깁니다(단점의 약 $ratio, 목표는 3배). 단점 세 개 길이가 지나면 떼세요.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '장점 $total개 중 $offending개가 너무 김(평균 $ratio 단점)';
  }

  @override
  String get learnRhythmTitle => '리듬';

  @override
  String get learnRhythmMine => '내 리듬';

  @override
  String get learnRhythmStandard => '표준 리듬(목표 속도)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return '문제는 내 단점 길이($ms ms)를 기준으로 판단하므로 느려도 고르면 괜찮습니다. 표준 줄은 목표 속도입니다.';
  }

  @override
  String get learnRhythmNotLocated => '키잉을 문자 단위로 맞추지 못했습니다. 목표 전체를 연습하세요.';

  @override
  String get learnRhythmPlayMine => '내 것 재생';

  @override
  String get learnRhythmPlayStandard => '표준 재생';

  @override
  String learnRhythmPracticePart(int count) {
    return '이것 연습($count회)';
  }

  @override
  String get learnRhythmPracticeWhole => '목표 전체 연습';

  @override
  String get learnRhythmSymbolOk => '좋음';

  @override
  String get learnRhythmZoomIn => '확대';

  @override
  String get learnRhythmZoomOut => '축소';

  @override
  String get workbenchTitle => '녹음 작업대';

  @override
  String get workbenchOpen => '녹음';

  @override
  String get workbenchImport => '녹음 가져오기';

  @override
  String get workbenchEmpty => 'WAV 녹음을 가져와 반복 재생, 해독, 직접 받아 적기를 할 수 있습니다. 마이크는 필요 없습니다.';

  @override
  String get workbenchFormats => 'WAV, 16비트 PCM, 모노 또는 스테레오, 8/16/44.1/48 kHz, 최대 50MB·20분.';

  @override
  String get workbenchBackupNote => '녹음은 이 기기에 저장됩니다. 학습 데이터를 지우거나 앱을 삭제하기 전에 사본을 보관하세요. 저장된 구간은 제목, 메모와 위치를 유지합니다.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => '모노';

  @override
  String get workbenchStereo => '스테레오';

  @override
  String get workbenchErrorNotWav => 'WAV 파일이 아닙니다.';

  @override
  String get workbenchErrorFormat => '현재는 16비트 PCM WAV만 지원합니다(MP3, AAC, 부동소수점 WAV 불가).';

  @override
  String get workbenchErrorChannels => '모노 또는 스테레오 녹음만 지원합니다.';

  @override
  String get workbenchErrorRate => '지원하지 않는 샘플레이트입니다. 8, 16, 44.1, 48kHz를 사용하세요.';

  @override
  String get workbenchErrorDamaged => '파일이 손상되었거나 불완전합니다.';

  @override
  String get workbenchErrorTooLarge => '파일이 50MB를 넘습니다.';

  @override
  String get workbenchErrorTooLong => '녹음이 20분을 넘습니다.';

  @override
  String get workbenchErrorIo => '파일을 읽을 수 없습니다.';

  @override
  String get workbenchErrorMissing => '녹음 파일이 없습니다.';

  @override
  String get workbenchStart => '시작(초)';

  @override
  String get workbenchEnd => '끝(초)';

  @override
  String get workbenchSelectAll => '전체 선택';

  @override
  String get workbenchPlay => '선택 구간 재생';

  @override
  String get workbenchStop => '정지';

  @override
  String get workbenchLoop => '반복';

  @override
  String get workbenchPlayLimit => '긴 구간은 처음 5분만 재생합니다.';

  @override
  String get workbenchAutoTune => '톤 자동 찾기';

  @override
  String workbenchManualTone(int hz) {
    return '톤: $hz Hz';
  }

  @override
  String get workbenchDecode => '선택 구간 해독';

  @override
  String get workbenchCancel => '취소';

  @override
  String workbenchDecoding(int percent) {
    return '해독 중… $percent%';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return '톤 ${hz}Hz · 약 $wpm WPM';
  }

  @override
  String get workbenchToneNotLocked => '안정된 톤을 찾지 못했습니다. 수동 조정을 해 보세요.';

  @override
  String get workbenchNoText => '이 구간에서 해독된 내용이 없습니다.';

  @override
  String workbenchUnknown(String patterns) {
    return '알 수 없는 패턴: $patterns';
  }

  @override
  String get workbenchEdgeCut => '구간 가장자리의 문자가 잘려 틀릴 수 있습니다.';

  @override
  String get workbenchToneNote => '톤 고정은 신뢰도가 아닙니다. 귀로 텍스트를 확인하세요.';

  @override
  String get workbenchModeDecoder => '디코더';

  @override
  String get workbenchModeCopy => '직접 받아 적기';

  @override
  String get workbenchDecoderHidden => '받아 적는 동안 디코더 텍스트는 숨겨집니다.';

  @override
  String get workbenchShowDecoder => '디코더 텍스트 보기';

  @override
  String get workbenchReference => '기준 텍스트(선택)';

  @override
  String get workbenchReferenceHelp => '보낸 텍스트를 붙여 넣으세요. 없으면 디코더 출력과 비교합니다.';

  @override
  String get workbenchAgainstDecoder => '디코더 출력과 비교했으며, 출력 자체가 틀릴 수 있습니다.';

  @override
  String get workbenchSave => '구간 저장';

  @override
  String get workbenchSaveTitle => '제목';

  @override
  String get workbenchSaveNote => '메모';

  @override
  String get workbenchSaved => '구간을 저장했습니다';

  @override
  String get workbenchSaveFailed => '구간을 저장할 수 없습니다.';

  @override
  String get workbenchLibrary => '저장한 구간';

  @override
  String get workbenchLibraryEmpty => '아직 저장한 구간이 없습니다.';

  @override
  String get workbenchMissing => '녹음 파일이 없습니다. 다시 선택하거나 항목을 삭제하세요.';

  @override
  String get workbenchRelink => '파일 다시 선택';

  @override
  String get workbenchDelete => '삭제';

  @override
  String get materialsTitle => '내 자료';

  @override
  String get materialsNew => '새 자료';

  @override
  String get materialsEdit => '편집';

  @override
  String get materialsSave => '저장';

  @override
  String get materialsSaveFailed => '자료를 저장하지 못했습니다.';

  @override
  String get materialsTitleField => '제목';

  @override
  String get materialsTagsField => '태그(쉼표로 구분)';

  @override
  String get materialsTextField => '텍스트';

  @override
  String get materialsListField => '한 줄에 한 항목';

  @override
  String get materialsKindText => '텍스트';

  @override
  String get materialsKindWords => '단어 목록';

  @override
  String get materialsKindCallsigns => '호출부호';

  @override
  String get materialsPreview => '미리 보기';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items개 항목 · $symbols자 · 절차 신호 $prosigns개';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return '모스 부호가 없어 연습에서 제외: $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '중복 항목 $count개는 한 번만 유지';
  }

  @override
  String get materialsProblemEmpty => '먼저 텍스트를 입력하세요.';

  @override
  String get materialsProblemTooLarge => '너무 큽니다. 자료는 1 MiB까지입니다.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return '항목이 너무 많습니다(최대 $count).';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return '너무 긴 항목이 있습니다(항목당 $count자까지).';
  }

  @override
  String get materialsProblemNothingTrainable => '모스로 연습할 내용이 없습니다.';

  @override
  String get materialsSearch => '자료 검색';

  @override
  String get materialsFavoritesOnly => '즐겨찾기';

  @override
  String get materialsFavorite => '즐겨찾기에 추가';

  @override
  String get materialsUnfavorite => '즐겨찾기에서 제거';

  @override
  String get materialsEmpty => '아직 자료가 없습니다. 텍스트, 단어 목록이나 호출 부호를 추가하세요.';

  @override
  String materialsItems(int count) {
    return '$count개 항목';
  }

  @override
  String get materialsActions => '자료 작업';

  @override
  String get materialsPractise => '연습';

  @override
  String get materialsDelete => '삭제';

  @override
  String get materialsDeleteTitle => '자료를 삭제할까요?';

  @override
  String materialsDeleteBody(String title) {
    return '‘$title’을(를) 이 기기에서 삭제합니다. 연습 기록은 남습니다.';
  }

  @override
  String get materialsImport => 'TXT 또는 JSON 가져오기';

  @override
  String get materialsImportDialogTitle => '자료 파일 선택';

  @override
  String get materialsSaveDialogTitle => '자료 저장';

  @override
  String get materialsImportFailed => '가져오기에 실패했습니다. 자료 목록은 그대로입니다.';

  @override
  String get materialsImportNotUtf8 => 'UTF-8 텍스트 파일만 가져올 수 있습니다.';

  @override
  String get materialsImportInvalid => '올바른 MorseCQ 자료 파일이 아닙니다. 아무것도 가져오지 않았습니다.';

  @override
  String materialsImported(int count) {
    return '자료 $count개를 가져왔습니다.';
  }

  @override
  String get materialsDuplicateTitle => '일부 자료가 이미 있습니다';

  @override
  String get materialsDuplicateOverwrite => '바꾸기';

  @override
  String get materialsDuplicateKeepCopy => '둘 다 유지(사본으로)';

  @override
  String get materialsDuplicateSkip => '건너뛰기';

  @override
  String get materialsExportJson => 'JSON으로 내보내기';

  @override
  String materialsExported(int count) {
    return '자료 $count개를 내보냈습니다.';
  }

  @override
  String get materialsExportFailed => '내보내기에 실패했습니다.';

  @override
  String get materialsExportWav => '오디오 내보내기(WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return '문자 속도: $wpm WPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return '유효 속도: $wpm WPM';
  }

  @override
  String materialsWavTone(int hz) {
    return '톤: $hz Hz';
  }

  @override
  String get materialsWavWithAnswer => '정답 텍스트 포함(.txt)';

  @override
  String get materialsWavFormat => '16비트 모노 WAV, 48kHz.';

  @override
  String materialsWavParts(int count) {
    return '10분이 넘어 파일 $count개로 내보냅니다.';
  }

  @override
  String materialsWavExported(int count) {
    return '오디오 파일 $count개를 저장했습니다.';
  }

  @override
  String get materialsPracticeMode => '연습 범위';

  @override
  String get materialsPracticeLearned => '배운 문자만';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return '배운 문자만(아직 배우지 않은 문자가 있어 $count개 항목 제외)';
  }

  @override
  String get materialsPracticeAll => '모든 모스 문자';

  @override
  String get materialsPracticeNothing => '이 모드에서 연습할 항목이 없습니다.';

  @override
  String get guestClearConfirm => '삭제';

  @override
  String get placementTitle => '내 수준 확인';

  @override
  String get placementCheckLevel => '현재 수준 확인';

  @override
  String get placementFromZero => '처음부터 시작';

  @override
  String get placementOfferTitle => '모스가 처음인가요, 이미 받아 적을 수 있나요?';

  @override
  String get placementOfferBody => '짧은 확인으로 시작 위치를 제안할 수 있습니다. 선택 사항이며 고르기 전에는 아무것도 바뀌지 않습니다.';

  @override
  String get placementIntro => '약 3~5분, 5단계로 받아 적습니다. 속도를 높여 가며 코흐 순서 문자 묶음, 마지막에 짧은 단어. 적은 표본에 따른 대략적 안내이며 인증이 아닙니다. 언제든 멈출 수 있습니다.';

  @override
  String get placementStart => '시작';

  @override
  String get placementSkip => '건너뛰기';

  @override
  String get placementStop => '중지';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return '$total단계 중 $step · 유효 $wpm WPM';
  }

  @override
  String get placementTierPassed => '잘 받아 적었습니다. 다음 단계는 더 빠릅니다.';

  @override
  String get placementTierStopped => '이 단계가 90% 미만이라 확인을 마칩니다.';

  @override
  String get placementNextTier => '다음 단계';

  @override
  String placementSuggestion(int lesson) {
    return '추천 시작: 레슨 $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return '코흐 순서 문자 $total개 중 $count개를 차례로 확인했습니다.';
  }

  @override
  String get placementLimits => '짧은 표본 기준입니다. 확인하지 않은 문자는 미확인으로 남고 습득으로 표시되지 않습니다. 레슨은 언제든 바꿀 수 있습니다.';

  @override
  String placementAdopt(int lesson) {
    return '레슨 $lesson부터 시작';
  }

  @override
  String materialsImportConfirm(int count) {
    return '자료 $count개를 가져올까요?';
  }

  @override
  String get materialsExportTxt => '텍스트로 내보내기(TXT)';

  @override
  String get conditionsTitle => '수신 환경';

  @override
  String get conditionsClear => '깨끗함';

  @override
  String get conditionsLight => '약한 간섭';

  @override
  String get conditionsRadio => '실전 무선';

  @override
  String get conditionsClearHint => '깨끗하고 일정한 톤: 일반 연습입니다.';

  @override
  String get conditionsLightHint => '잔잔한 배경 잡음과 약한 페이딩. 결과는 깨끗한 연습과 따로 기록됩니다.';

  @override
  String get conditionsRadioHint => '잡음, 깊은 페이딩, 가까운 다른 국, 약간 고르지 않은 타이밍. 결과는 깨끗한 연습과 따로 기록됩니다.';

  @override
  String get conditionsPreview => '미리 듣기';

  @override
  String conditionsActive(String name) {
    return '수신 환경: $name';
  }

  @override
  String get conditionsNeedSound => '무선 환경은 눈이 아니라 귀로 듣는 것입니다. 연습 설정에서 소리를 켜거나 깨끗한 환경으로 연습하세요.';

  @override
  String get conditionsCleanReplay => '효과 없이 재생';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 환경과 속도에서 $count회: 평균 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => '무선 환경 연습은 활동으로 기록되지만 레슨, 복습 일정, 속도 추천은 바뀌지 않습니다.';

  @override
  String get keysTitle => '키와 외부 키어';

  @override
  String get keysMeSubtitle => '키 할당, 패들, USB 키어 어댑터';

  @override
  String get keysIntro => '모스를 키잉할 키를 고르세요. 키보드처럼 동작하는 USB 키·패들 어댑터는 키보드와 같으니 여기서 키를 지정하세요. 앱은 어떤 기기가 키를 보냈는지 알 수 없으므로 프로필은 키 할당 묶음입니다.';

  @override
  String get keysStandardProfile => '기본';

  @override
  String get keysUnnamed => '이름 없는 프로필';

  @override
  String get keysEdit => '편집';

  @override
  String get keysNewProfile => '새 프로필';

  @override
  String get keysLimitations => 'MIDI·시리얼·블루투스 키어, 어댑터 펌웨어 설정, 송신기 제어는 지원하지 않습니다. 검증된 어댑터는 문서에 있습니다.';

  @override
  String get keysEditTitle => '키 프로필';

  @override
  String get keysName => '프로필 이름';

  @override
  String get keysActionStraight => '스트레이트 키';

  @override
  String get keysActionDit => '점 패들';

  @override
  String get keysActionDah => '선 패들';

  @override
  String get keysPressKey => '키를 누르세요…';

  @override
  String get keysNone => '설정 안 됨';

  @override
  String get keysSet => '지정';

  @override
  String keysReserved(String key) {
    return '$key은(는) 시스템이나 앱이 사용하는 키입니다. 다른 키를 고르세요.';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key은(는) 이미 $action에 쓰이고 있습니다.';
  }

  @override
  String keysConflictSave(String keys) {
    return '키 하나에는 동작 하나만 지정할 수 있습니다: $keys이(가) 중복되었습니다.';
  }

  @override
  String get keysMissing => '이 키어 모드에 필요한 키를 지정하세요(아이앰빅은 두 패들 모두).';

  @override
  String get keysSwapPaddles => '패들 바꾸기(왼손잡이)';

  @override
  String get keysKeyerMode => '키어 모드';

  @override
  String get keysIambicA => '아이앰빅 A';

  @override
  String get keysIambicB => '아이앰빅 B';

  @override
  String get keysAdapterKeyer => '어댑터가 직접 부호를 만듦';

  @override
  String get keysAdapterKeyerHint => '자체 키어가 있는 어댑터용: 어댑터가 타이밍을 맞춘 눌림·뗌을 그대로 쓰며 앱에서 아이앰빅을 한 번 더 만들지 않습니다.';

  @override
  String get keysAppSidetone => '키잉할 때 앱 사이드톤';

  @override
  String get keysAppSidetoneHint => '어댑터가 자체 사이드톤을 낼 때 끄세요. 해독에는 영향이 없습니다.';

  @override
  String get keysTestTitle => '테스트';

  @override
  String get keysTestNote => '테스트 전용: 아무것도 전송하거나 연습 기록에 더하지 않습니다.';

  @override
  String get keysTestRelease => '키 놓기';

  @override
  String get keysAdapterActive => '어댑터의 키어를 사용 중: 패들 키는 스트레이트 키로 동작합니다.';

  @override
  String keysHintCustom(String keys) {
    return '키: $keys';
  }

  @override
  String get telegraphTitle => '중국어 전신 부호';

  @override
  String get telegraphIntro => '한자는 한 글자씩 네 자리 숫자로 보냅니다. 숫자를 듣는 연습과, 어떤 부호가 어떤 글자인지 기억하는 연습을 따로 합니다.';

  @override
  String get telegraphCodebook => '부호표';

  @override
  String get telegraphCodebookMainland => '중국 대륙';

  @override
  String get telegraphCodebookTaiwan => '대만';

  @override
  String get telegraphDigitsTitle => '부호 묶음 받아쓰기';

  @override
  String get telegraphDigitsHint => '실제 부호의 네 자리 묶음을 듣고 숫자를 입력합니다.';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count회: 숫자 정확도 $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => '부호 떠올리기';

  @override
  String get telegraphRecallHint => '글자→부호, 부호→글자. 모스 진도와 따로 기록합니다.';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count장 답함: $accuracy% 정답',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => '부호 기억은 모스 레슨을 열거나 속도 추천을 바꾸지 않습니다. 숫자 받아쓰기는 다른 모스 수신과 똑같이 집계됩니다.';

  @override
  String get telegraphRecallCharPrompt => '이 글자의 부호를 입력하세요';

  @override
  String get telegraphRecallCodePrompt => '이 부호의 글자를 고르세요';

  @override
  String get telegraphReveal => '정답 보기';

  @override
  String get telegraphRevealAssisted => '표시함: 이 카드는 도움 받은 것으로 기록됩니다.';

  @override
  String get telegraphCorrect => '정답';

  @override
  String get telegraphIncorrect => '오답';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$total개 중 $correct개 정답';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '정답을 본 카드 $count장',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => '전신 부호 해석';

  @override
  String get telegraphInterpretNote => '여기에만 표시됩니다. 메시지는 바뀌지 않고 아무것도 전송되지 않습니다.';

  @override
  String get telegraphUnresolved => '미해결: 이 부호에 해당하는 글자가 없습니다';

  @override
  String get telegraphMalformed => '네 자리 묶음이 아닙니다';

  @override
  String get telegraphNotCode => '텍스트(그대로 둠)';

  @override
  String get telegraphAmbiguous => '여러 글자가 이 부호를 함께 씁니다';

  @override
  String get conditionsAudioFailed => '이 기기에서 오디오를 시작하지 못했습니다. 깨끗한 환경으로 연습하세요.';

  @override
  String get aboutPrivacyPolicy => '개인정보 처리방침';

  @override
  String get aboutTermsOfUse => '이용약관';

  @override
  String get aboutSupport => '지원 및 문의';

  @override
  String get aboutLinkFailed => '링크를 열 수 없어 복사했습니다.';

  @override
  String get offlineClearData => '학습 데이터 지우기';

  @override
  String get offlineClearDataBody => '이 기기의 진도, 계획, 자료를 삭제합니다.';

  @override
  String get offlineCleared => '학습 데이터를 지웠습니다.';

  @override
  String get offlineClearFailed => '학습 데이터를 지우지 못했습니다.';

  @override
  String get learnStorageUnavailable => '이 기기에서 훈련 데이터를 열 수 없습니다. 다시 시도하세요.';

  @override
  String get materialsImportedSource => '가져온 출처';
}
