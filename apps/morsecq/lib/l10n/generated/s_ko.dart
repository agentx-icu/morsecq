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
  String get navChat => '채팅';

  @override
  String get navGroups => '그룹';

  @override
  String get navMe => '내 정보';

  @override
  String get navReference => '참고';

  @override
  String get navLearnDescription => 'Koch 방식 강의, 송신 연습과 수신 받아쓰기 연습.';

  @override
  String get navChatDescription => 'Tox P2P를 통한 서버 없는 일대일 모스 통신.';

  @override
  String get navGroupsDescription => '그룹 통신망 — 여러 운용자가 하나의 채널을 공유하며 송신합니다.';

  @override
  String get navReferenceDescription => '문자표, 절차 부호, Q 부호, 약어와 양방향 변환기.';

  @override
  String get navMeDescription => '콜사인, Tox 신원 정보, 학습 진도와 설정.';

  @override
  String get shellOfflineBanner => '오프라인: Tox 네트워크에 연결되지 않았습니다. 온라인으로 돌아오면 메시지를 보냅니다.';

  @override
  String get actionOk => '확인';

  @override
  String get actionCancel => '취소';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionCopy => '복사';

  @override
  String get actionShare => '공유';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionClose => '닫기';

  @override
  String get actionSearch => '검색';

  @override
  String get actionSettings => '설정';

  @override
  String get connectionConnecting => '연결 중…';

  @override
  String get connectionOnline => '온라인';

  @override
  String get connectionOffline => '오프라인';

  @override
  String get messageStatusPending => '전송 대기 — 상대방이 오프라인입니다';

  @override
  String get messageStatusPendingDetail => 'Tox에는 서버가 없습니다. 상대방이 온라인이 되면 메시지가 전달됩니다.';

  @override
  String get messageStatusSending => '전송 중';

  @override
  String get messageStatusSent => '전송됨';

  @override
  String get messageStatusFailed => '전송 실패';

  @override
  String get errorWrongPassword => '비밀번호가 올바르지 않습니다. 다시 시도하세요.';

  @override
  String get errorPeerOffline => '이 연락처는 오프라인입니다. Tox에는 서버가 없으므로 상대방이 돌아올 때까지 메시지가 대기합니다.';

  @override
  String get errorInvalidToxId => '유효한 Tox ID가 아닙니다(16진수 문자 76개여야 합니다).';

  @override
  String get errorAlreadyFriend => '이 Tox ID는 이미 친구 목록에 있습니다.';

  @override
  String get errorOwnId => '본인의 Tox ID입니다.';

  @override
  String get errorGroupNotFound => '그룹을 찾을 수 없습니다.';

  @override
  String get errorMessageTooLong => '메시지가 Tox 메시지 한 건의 길이 제한을 초과합니다.';

  @override
  String get errorUnknown => '문제가 발생했습니다';

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
  String get accountCopied => 'Tox ID를 클립보드에 복사했습니다';

  @override
  String get accountShowQr => 'QR 코드 보기';

  @override
  String get accountToxId => 'Tox ID';

  @override
  String get accountDisplayName => '표시 이름';

  @override
  String get accountDisplayNameHint => '콜사인 또는 별명';

  @override
  String get accountDisplayNameRequired => '표시 이름을 입력하세요';

  @override
  String get accountStatusMessage => '상태 메시지';

  @override
  String get accountPassword => '비밀번호';

  @override
  String get accountPasswordOptional => '비밀번호(선택 사항)';

  @override
  String get accountConfirmPassword => '비밀번호 확인';

  @override
  String get accountPasswordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get accountShowPassword => '비밀번호 표시';

  @override
  String get accountHidePassword => '비밀번호 숨기기';

  @override
  String get accountStrengthWeak => '약함: 8자 이상 사용하세요';

  @override
  String get accountStrengthFair => '보통: 12자 이상으로 여러 문자 종류를 섞으면 더 안전합니다';

  @override
  String get accountStrengthStrong => '강함';

  @override
  String get accountStartupInspecting => '신원 정보 확인 중…';

  @override
  String get accountStartupOpening => '신원 정보 여는 중…';

  @override
  String get accountStartupFailedTitle => '시작할 수 없습니다';

  @override
  String get accountStartupFailedBody => 'MorseCQ가 신원 정보를 읽지 못했습니다. 변경된 내용은 없습니다. 다시 시도할 수 있습니다.';

  @override
  String get accountConnectionTapToReconnect => '탭하여 다시 연결';

  @override
  String get accountWelcomeTitle => '신원 정보는 이 기기에 저장됩니다';

  @override
  String get accountWelcomeIntro => 'MorseCQ는 Tox P2P 네트워크를 사용합니다. 서버도 계정 가입도 없습니다. 신원 정보는 이 기기에만 저장되는 키 쌍입니다.';

  @override
  String get accountWelcomePointNoServer => '서버, 전화번호, 이메일이 필요 없습니다. 운용자끼리 모스 부호로 직접 통신합니다.';

  @override
  String get accountWelcomePointTraining => '학습 진도는 신원 정보와 함께 저장되므로 백업하고 다른 기기로 옮길 수 있습니다.';

  @override
  String get accountWelcomePointBackup => '다른 누구도 신원 정보를 복구해 줄 수 없습니다. 생성 후 바로 백업하세요. 백업이 없으면 기기를 잃을 때 신원 정보도 잃게 됩니다.';

  @override
  String get accountCreateIdentity => '신원 정보 생성';

  @override
  String get accountRestoreFromBackup => '백업에서 복원';

  @override
  String get accountCreateTitle => '내 신원 정보 생성';

  @override
  String get accountCreateBody => '다른 사람에게 보일 이름을 정하세요. 비밀번호는 이 기기의 신원 정보 파일을 암호화합니다. 비밀번호 없이 앱을 열려면 비워 두세요.';

  @override
  String get accountCreateButton => '생성';

  @override
  String get accountCreating => '생성 중…';

  @override
  String get accountBackupTitle => '지금 신원 정보를 백업하세요';

  @override
  String get accountBackupBody => '신원 정보는 이 기기에만 있습니다. 기기를 잃어버리거나 초기화하거나 도난당하면 복구할 수 없습니다. 연락처는 새로운 신원 정보를 알아보지 못하고 학습 진도도 사라집니다.';

  @override
  String get accountBackupWhatIsInside => '백업 파일에는 암호화된 신원 정보와 학습 진도가 들어 있습니다. 이 기기 밖의 안전한 곳에 보관하세요.';

  @override
  String get accountBackupSaveFile => '백업 파일 저장';

  @override
  String get accountBackupShareFile => '백업 파일 공유';

  @override
  String get accountBackupSaved => '백업이 저장되었습니다';

  @override
  String get accountBackupNotSaved => '백업이 저장되지 않았습니다';

  @override
  String get accountBackupFailed => '백업을 기록할 수 없습니다';

  @override
  String get accountBackupAcknowledge => '이 백업이 없으면 신원 정보를 복구할 수 없음을 이해했습니다.';

  @override
  String get accountBackupContinue => 'MorseCQ 시작';

  @override
  String get accountBackupShowQrHint => '친구는 Tox ID로 나를 추가합니다. 텍스트나 QR 코드로 공유할 수 있습니다.';

  @override
  String get accountRestoreTitle => '백업에서 복원';

  @override
  String get accountRestoreBody => 'MorseCQ에서 내보낸 백업 파일을 선택하세요. 신원 정보에 비밀번호를 설정했다면 여기서 입력해야 합니다.';

  @override
  String get accountRestoreChooseFile => '백업 파일 선택';

  @override
  String get accountRestoreNoFile => '먼저 백업 파일을 선택하세요';

  @override
  String get accountRestoreButton => '복원';

  @override
  String get accountRestoring => '복원 중…';

  @override
  String get accountRestoreInvalidFile => '이 파일은 MorseCQ 백업이 아닙니다.';

  @override
  String get accountRestoreReplacesWarning => '복원하면 이 기기의 현재 신원 정보가 교체됩니다.';

  @override
  String get accountUnlockTitle => '신원 정보 잠금 해제';

  @override
  String get accountUnlockBody => '신원 정보 파일이 암호화되어 있습니다. 계속하려면 비밀번호를 입력하세요.';

  @override
  String get accountUnlockButton => '잠금 해제';

  @override
  String get accountUnlocking => '잠금 해제 중…';

  @override
  String get accountUnlockRestoreInstead => '대신 백업에서 복원';

  @override
  String get accountMeNoIdentity => '신원 정보가 불러와지지 않았습니다';

  @override
  String get accountSectionAccount => '계정';

  @override
  String get accountSectionTraining => '훈련';

  @override
  String get accountSectionAbout => '앱 정보';

  @override
  String get accountSectionDanger => '위험한 작업';

  @override
  String get accountEditProfile => '프로필 편집';

  @override
  String get accountEditProfileBody => 'Tox 네트워크의 연락처에게 표시됩니다.';

  @override
  String get accountSetPassword => '비밀번호 설정';

  @override
  String get accountChangePassword => '비밀번호 변경';

  @override
  String get accountRemovePassword => '비밀번호 제거';

  @override
  String get accountCurrentPassword => '현재 비밀번호';

  @override
  String get accountNewPassword => '새 비밀번호';

  @override
  String get accountPasswordUpdated => '비밀번호가 변경되었습니다';

  @override
  String get accountPasswordRemoved => '비밀번호가 제거되었습니다';

  @override
  String get accountProfileUpdated => '프로필이 수정되었습니다';

  @override
  String get accountExportBackup => '백업 내보내기';

  @override
  String get accountExportBackupSubtitle => '신원 정보와 학습 진도를 파일에 저장';

  @override
  String get accountTrainingDefaults => '재생 및 훈련 기본 설정';

  @override
  String get accountTrainingDefaultsSubtitle => '속도, 음높이, Farnsworth 간격';

  @override
  String get accountTrainingDefaultsPlaceholder => '속도, 음높이, Farnsworth 간격의 기본 설정이 여기에 표시됩니다.';

  @override
  String get accountAboutLicence => '라이선스';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => '소스 코드';

  @override
  String get accountAboutSourceCopied => '소스 코드 링크를 복사했습니다';

  @override
  String get accountAboutBackend => '백엔드';

  @override
  String get accountDeleteIdentity => '신원 정보 삭제';

  @override
  String get accountDeleteIdentitySubtitle => '이 기기에서 신원 정보, 기록과 학습 진도 삭제';

  @override
  String get accountDeleteDialogTitle => '이 신원 정보를 삭제할까요?';

  @override
  String get accountDeleteDialogBody => '이 기기에서 신원 정보, 채팅 기록과 학습 진도를 삭제합니다. 백업이 없으면 복구할 수 없습니다. 확인하려면 DELETE를 입력하세요.';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => 'DELETE 입력';

  @override
  String get accountDeleteButton => '삭제';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return '백업 파일 선택됨($bytes바이트)';
  }

  @override
  String get chatSearchConversations => '대화 검색';

  @override
  String get chatNoConversations => '아직 대화가 없습니다';

  @override
  String get chatNoSearchResults => '일치하는 대화가 없습니다';

  @override
  String get chatPin => '고정';

  @override
  String get chatUnpin => '고정 해제';

  @override
  String get chatMarkRead => '읽음으로 표시';

  @override
  String get chatDelete => '삭제';

  @override
  String get chatDeleteConversationTitle => '대화를 삭제할까요?';

  @override
  String get chatDeleteConversationBody => '이 기기에 저장된 대화 기록이 삭제됩니다. Tox에는 사본이 없습니다.';

  @override
  String get chatDraftPrefix => '초안: ';

  @override
  String get chatSelectConversation => '대화 선택';

  @override
  String get chatContacts => '연락처';

  @override
  String get chatNoMessages => '아직 메시지가 없습니다. CQ를 보내 통신을 시작하세요.';

  @override
  String get chatTrainingMode => '훈련 모드';

  @override
  String get chatTrainingModeOn => '훈련 모드 켜짐: 텍스트 숨김';

  @override
  String get chatTrainingModeOff => '훈련 모드 꺼짐';

  @override
  String get chatAutoPlay => '받은 모스 부호 자동 재생';

  @override
  String get chatAutoPlayOn => '자동 재생 켜짐: 새 메시지가 도착하면 재생됩니다';

  @override
  String get chatAutoPlayOff => '자동 재생 꺼짐';

  @override
  String get chatReveal => '보기';

  @override
  String get chatHiddenText => '먼저 듣고 나서 보기';

  @override
  String get chatPlay => '모스 부호 재생';

  @override
  String get chatStop => '정지';

  @override
  String get chatPlaybackSettings => '재생 설정';

  @override
  String get chatCharacterSpeed => '문자 속도';

  @override
  String get chatFarnsworthSpeed => 'Farnsworth 속도';

  @override
  String get chatTone => '음높이';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => '회원';

  @override
  String get chatLeaveGroup => '그룹 나가기';

  @override
  String get chatLeaveGroupTitle => '이 그룹에서 나갈까요?';

  @override
  String get chatLeaveGroupBody => '더 이상 메시지를 받지 않습니다. 나중에 채팅 ID로 다시 참여할 수 있습니다.';

  @override
  String get chatLeave => '나가기';

  @override
  String get chatConferenceNote => '구형 회의: 여기서는 모스 전건 조작 메타데이터(v2)를 사용할 수 없습니다. 텍스트는 사용할 수 있습니다.';

  @override
  String get chatClearHistory => '기록 지우기';

  @override
  String get chatModeStraightKey => '수동 전건';

  @override
  String get chatModePaddles => '패들';

  @override
  String get chatKeyMessage => '전건으로 메시지를 입력하세요';

  @override
  String get chatSend => '보내기';

  @override
  String get chatTooLong => 'Tox 메시지 한 건의 길이 제한을 초과합니다';

  @override
  String get chatKeyHint => '전건 영역을 누르거나 스페이스 키를 누르세요';

  @override
  String get chatPaddleHint => '패들을 탭하거나 Ctrl을 누르세요(왼쪽: 단점, 오른쪽: 장점)';

  @override
  String get chatDeleteLast => '마지막 문자 삭제';

  @override
  String get chatNoFriends => '아직 친구가 없습니다. 상대방의 Tox ID로 추가하세요.';

  @override
  String get chatNoRequests => '대기 중인 요청이 없습니다';

  @override
  String get chatAddFriend => '친구 추가';

  @override
  String get chatMyToxId => '내 Tox ID';

  @override
  String get chatToxIdLabel => 'Tox ID(16진수 문자 76개)';

  @override
  String get chatToxIdInvalid => 'Tox ID는 정확히 76개의 16진수 문자여야 합니다';

  @override
  String get chatToxIdOwn => '본인의 Tox ID입니다';

  @override
  String get chatToxIdAlreadyFriend => '이미 친구 목록에 있습니다';

  @override
  String get chatRequestMessage => '메시지';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => '요청 보내기';

  @override
  String get chatRequestSent => '친구 요청을 보냈습니다';

  @override
  String get chatScanQr => 'QR 코드 스캔';

  @override
  String get chatScanQrDesktopHint => 'QR 코드 스캔에는 휴대폰 카메라가 필요합니다';

  @override
  String get chatScanQrTitle => 'Tox ID 스캔';

  @override
  String get chatScanQrNotToxId => '이 QR 코드는 Tox ID가 아닙니다';

  @override
  String get chatAccept => '수락';

  @override
  String get chatReject => '거절';

  @override
  String get chatCopied => '클립보드에 복사했습니다';

  @override
  String get chatNoIdentity => '신원 정보가 불러와지지 않았습니다';

  @override
  String get chatRemoveFriend => '친구 삭제';

  @override
  String get chatRemoveFriendTitle => '이 친구를 삭제할까요?';

  @override
  String get chatRemoveFriendBody => '상대방이 더 이상 나에게 메시지를 보낼 수 없습니다.';

  @override
  String get chatRemove => '삭제';

  @override
  String get chatNoGroups => '아직 그룹이 없습니다. 그룹을 만들거나 채팅 ID로 참여하세요.';

  @override
  String get chatCreateGroup => '그룹 만들기';

  @override
  String get chatJoinGroup => '그룹 참여';

  @override
  String get chatGroupName => '그룹 이름';

  @override
  String get chatGroupNameRequired => '그룹 이름을 입력하세요';

  @override
  String get chatAdvanced => '고급';

  @override
  String get chatLegacyConference => '구형 회의(이전 클라이언트용)';

  @override
  String get chatLegacyConferenceHint => '권장하지 않음: 고정 채팅 ID와 모스 메타데이터가 없습니다.';

  @override
  String get chatCreate => '만들기';

  @override
  String get chatChatIdLabel => '채팅 ID(16진수 문자 64개)';

  @override
  String get chatChatIdInvalid => '채팅 ID는 정확히 64개의 16진수 문자여야 합니다';

  @override
  String get chatPassword => '비밀번호(선택 사항)';

  @override
  String get chatJoin => '참여';

  @override
  String get chatJoinRequested => '참여 중 — 회원을 찾으면 그룹이 표시됩니다.';

  @override
  String get chatConferenceBadge => '회의';

  @override
  String get chatCopyChatId => '채팅 ID 복사';

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
  String get learnIdentityRequired => '훈련을 시작하려면 신원 정보를 생성하거나 잠금을 해제하세요. 진도는 신원 정보와 함께 저장되며 백업에도 포함됩니다.';

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
  String get notificationOpen => '열기';

  @override
  String get notificationChannelMessages => '메시지';

  @override
  String get notificationChannelMessagesDescription => '친구와 그룹이 보내는 새 모스 메시지';

  @override
  String get notificationChannelFriendRequests => '친구 요청';

  @override
  String get notificationChannelFriendRequestsDescription => '누군가 나를 친구로 추가하려고 합니다';

  @override
  String get notificationChannelGroupInvites => '그룹 초대';

  @override
  String get notificationChannelGroupInvitesDescription => '친구가 그룹에 초대했습니다';

  @override
  String get notificationNewMessage => '새 메시지';

  @override
  String get notificationFriendRequestTitle => '새 친구 요청';

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
  String get accountNewPasswordRequired => '새 비밀번호를 입력하세요';

  @override
  String get accountToxIdQrSemantics => 'Tox ID QR 코드';

  @override
  String get accountBackupSaveDialogTitle => 'MorseCQ 백업 저장';

  @override
  String get accountBackupShareSubject => 'MorseCQ 신원 정보 백업';

  @override
  String get accountBackupChooseDialogTitle => 'MorseCQ 백업 선택';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '새 메시지 $count개',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return '$name님의 친구 요청';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name: $message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return '$group 초대';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name님이 초대했습니다';
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
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '읽지 않은 메시지 $count개',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => '켜짐';

  @override
  String get listenStateOff => '꺼짐';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count바이트 남음',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '회원 $count명',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return '친구($count)';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return '친구 요청($count)';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return '그룹 초대($count)';
  }

  @override
  String chatMembersTitleCount(int count) {
    return '회원 · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return '초대한 사람: $name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name(나)';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label: $value $unit';
  }

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
  String get appearanceSubtitle => '밝은 모드와 어두운 모드를 지원하는 다섯 가지 스타일';

  @override
  String get chatClearHistoryBody => '이 기기에 저장된 대화 기록을 삭제할까요? 다른 기기의 사본에는 영향을 주지 않습니다. 되돌릴 수 없습니다.';

  @override
  String get chatLoadEarlier => '이전 메시지 불러오기';

  @override
  String get chatHistoryLoadFailed => '이전 메시지를 불러올 수 없습니다. 탭하여 다시 시도하세요.';

  @override
  String get chatRetryHistory => '다시 시도';

  @override
  String chatNewMessages(int count) {
    return '새 메시지 $count개';
  }

  @override
  String learnShowAllChars(int count) {
    return '문자 $count개 모두 보기';
  }

  @override
  String get chatSelfMe => '나';

  @override
  String get chatSelfLocalOnly => '이 기기에만 저장';

  @override
  String get chatSelfContactSubtitle => '초안, 연습과 메모 · 전송되지 않음';

  @override
  String get learnShowFewerChars => '문자 접기';

  @override
  String get learnLeaveDrillTitle => '이 세션을 나가시겠습니까?';

  @override
  String get learnLeaveDrillBody => '이 세션에서 진행한 라운드는 저장되지 않습니다.';

  @override
  String get learnLeaveDrillConfirm => '나가기';

  @override
  String get chatScanQrPermissionDenied => 'QR 코드를 스캔하려면 MorseCQ에 카메라 접근 권한이 필요합니다. 시스템 설정에서 허용하세요.';

  @override
  String get chatScanQrCameraUnavailable => '이 기기에서는 카메라를 사용할 수 없습니다.';
}
