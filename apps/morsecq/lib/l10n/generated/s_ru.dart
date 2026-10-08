// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => 'Обучение';

  @override
  String get navMe => 'Профиль';

  @override
  String get navReference => 'Справочник';

  @override
  String get navLearnDescription => 'Уроки по методу Коха, упражнения по передаче и приёму на слух.';

  @override
  String get navReferenceDescription => 'Алфавит, служебные сигналы, Q-коды, сокращения и двусторонний переводчик.';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languageSaveFailed => 'Не удалось сохранить язык. Попробуйте ещё раз.';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'Урок $lesson из $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изучено $count символа',
      many: 'Изучено $count символов',
      few: 'Изучено $count символа',
      one: 'Изучен $count символ',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal символов';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня подряд',
      many: '$days дней подряд',
      few: '$days дня подряд',
      one: '$days день подряд',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count символа для повторения',
      many: '$count символов для повторения',
      few: '$count символа для повторения',
      one: '$count символ для повторения',
      zero: 'Нет символов для повторения',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return 'Верно: $correct из $total';
  }

  @override
  String learnRoundOf(int round) {
    return 'Раунд $round';
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
      other: 'Передано $count символа',
      many: 'Передано $count символов',
      few: 'Передано $count символа',
      one: 'Передан $count символ',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return 'Открыт новый символ: $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target пропущен';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target принят как $answered';
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
      other: '$count символа',
      many: '$count символов',
      few: '$count символа',
      one: '$count символ',
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
      other: 'Изучено $count символа',
      many: 'Изучено $count символов',
      few: 'Изучено $count символа',
      one: 'Изучен $count символ',
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
      other: 'Принято $count символа',
      many: 'Принято $count символов',
      few: 'Принято $count символа',
      one: 'Принят $count символ',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count занятия',
      many: '$count занятий',
      few: '$count занятия',
      one: '$count занятие',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Рекорд: $count дня',
      many: 'Рекорд: $count дней',
      few: 'Рекорд: $count дня',
      one: 'Рекорд: $count день',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal символов';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Осталось $remaining символа',
      many: 'Осталось $remaining символов',
      few: 'Осталось $remaining символа',
      one: 'Остался $remaining символ',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Последние $count занятия',
      many: 'Последние $count занятий',
      few: 'Последние $count занятия',
      one: 'Последнее $count занятие',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return 'Занятие $index из $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return 'Верно: $correct / $total';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'Урок $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count попытки',
      many: '$count попыток',
      few: '$count попытки',
      one: '$count попытка',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return 'Верно: $correct из $attempts';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'Вводится в уроке $lesson';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'Коробка $box из $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Повторить через $days дня',
      many: 'Повторить через $days дней',
      few: 'Повторить через $days дня',
      one: 'Повторить через $days день',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза',
      many: '$count раз',
      few: '$count раза',
      one: '$count раз',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза',
      many: '$count раз',
      few: '$count раза',
      one: '$count раз',
    );
    return '$target принят как $answered, $_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars символа',
      many: '$chars символов',
      few: '$chars символа',
      one: '$chars символ',
      zero: 'без занятий',
    );
    return '$date: $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня занятий',
      many: '$count дней занятий',
      few: '$count дня занятий',
      one: '$count день занятий',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
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
    return 'Пропущены (нет кода Морзе): $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Номер по методу Коха: $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return 'Примерно $wpm WPM';
  }

  @override
  String get accountSectionTraining => 'Обучение';

  @override
  String get accountSectionAbout => 'О приложении';

  @override
  String get accountTrainingDefaults => 'Параметры воспроизведения и обучения';

  @override
  String get accountTrainingDefaultsSubtitle => 'Скорость, тон и интервалы Фарнсворта';

  @override
  String get accountAboutLicence => 'Лицензия';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Исходный код';

  @override
  String get accountAboutSourceCopied => 'Ссылка на исходный код скопирована';

  @override
  String get chatSend => 'Отправить';

  @override
  String get learnLessonCardTitle => 'Урок по методу Коха';

  @override
  String get learnCourseComplete => 'Курс завершён — продолжайте совершенствоваться!';

  @override
  String get learnDailyGoalTitle => 'Сегодня';

  @override
  String get learnDailyGoalMet => 'Дневная цель достигнута';

  @override
  String get learnNoStreak => 'Начните серию занятий сегодня';

  @override
  String get learnContinueLesson => 'Продолжить урок';

  @override
  String get learnReceivePractice => 'Практика приёма';

  @override
  String get learnSendPractice => 'Практика передачи';

  @override
  String get learnReviewDue => 'Повторить назначенные символы';

  @override
  String get learnSettings => 'Настройки обучения';

  @override
  String get learnLoading => 'Загрузка прогресса...';

  @override
  String get learnLoadFailed => 'Не удалось прочитать сохранённый прогресс. Обучение начнётся заново; старый файл сохранён с расширением .corrupt.';

  @override
  String get learnProgressSaveFailed => 'Не удалось сохранить прогресс. Результат учитывается, пока MorseCQ открыт.';

  @override
  String get learnChooseDrill => 'Выберите упражнение';

  @override
  String get learnDrillGroups => 'Случайные группы';

  @override
  String get learnDrillWords => 'Слова';

  @override
  String get learnDrillCallsigns => 'Позывные';

  @override
  String get learnDrillQso => 'QSO';

  @override
  String get learnDrillCharacters => 'Отдельные символы';

  @override
  String get learnDrillAbbreviations => 'Сокращения и Q-коды';

  @override
  String get learnDrillNumbers => 'Группы цифр';

  @override
  String get learnDrillConfusables => 'Похожие символы';

  @override
  String get learnDrillContest => 'Обмен в соревнованиях';

  @override
  String get learnDrillGroupsHint => 'Случайные группы из всех изученных символов';

  @override
  String get learnDrillCharactersHint => 'По одному символу — распознайте сразу';

  @override
  String get learnDrillWordsHint => 'Распространённые английские слова';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL — сокращения для работы в эфире';

  @override
  String get learnDrillNumbersHint => 'Группы из пяти цифр, как в радиограммах и порядковых номерах';

  @override
  String get learnDrillCallsignsHint => 'Радиолюбительские позывные со всего мира';

  @override
  String get learnDrillConfusablesHint => 'Пары символов, которые вы путаете, например S/H или U/V, рядом друг с другом';

  @override
  String get learnDrillQsoHint => 'Фразы из полной радиосвязи';

  @override
  String get learnDrillContestHint => 'Позывной, 5NN и порядковый номер или зона в темпе соревнований';

  @override
  String get learnDrillReviewHint => 'Символы, которые пора повторить';

  @override
  String get toolsTitle => 'Радиоинструменты';

  @override
  String get toolsGridTitle => 'Локатор';

  @override
  String get toolsGridHint => 'Локатор по координатам, расстояние и направление антенны';

  @override
  String get toolsBandsTitle => 'Диапазоны и антенны';

  @override
  String get toolsBandsHint => 'Диапазон частоты, длина волны и длина диполя';

  @override
  String get toolsSpeedTitle => 'Скорость CW';

  @override
  String get toolsSpeedHint => 'Из WPM в длительность точки, паузы и символы в минуту';

  @override
  String get toolsRstTitle => 'Рапорт RST';

  @override
  String get toolsRstHint => 'Составьте рапорт о сигнале и узнайте значение каждой цифры';

  @override
  String get toolsClockTitle => 'Часы UTC';

  @override
  String get toolsClockHint => 'Время UTC для журнала рядом с местным временем';

  @override
  String get toolsGridFromCoordinates => 'По координатам';

  @override
  String get toolsGridLatitude => 'Широта';

  @override
  String get toolsGridLongitude => 'Долгота';

  @override
  String get toolsGridCoordinatesHelp => 'Градусы в десятичном виде; юг и запад — отрицательные значения';

  @override
  String get toolsGridInvalidCoordinates => 'Широта от -90 до 90, долгота от -180 до 180';

  @override
  String get toolsGridLocator => 'Локатор';

  @override
  String get toolsGridDistanceSection => 'Расстояние и азимут';

  @override
  String get toolsGridMine => 'Мой локатор';

  @override
  String get toolsGridTheirs => 'Локатор собеседника';

  @override
  String get toolsGridInvalidLocator => 'Используйте 2, 4, 6 или 8 символов, например OM89ex';

  @override
  String get toolsGridCenter => 'Центр квадрата';

  @override
  String get toolsGridDistance => 'Расстояние';

  @override
  String get toolsGridShortPath => 'Азимут короткого пути';

  @override
  String get toolsGridLongPath => 'Азимут длинного пути';

  @override
  String get toolsBandsFrequency => 'Частота (MHz)';

  @override
  String get toolsBandsInvalidFrequency => 'Введите частоту больше 0';

  @override
  String toolsBandsRegionLabel(int number) {
    return 'Регион $number';
  }

  @override
  String get toolsBandsRegionHelp => '1: Европа, Африка, Ближний Восток · 2: Америка · 3: Азиатско-Тихоокеанский регион';

  @override
  String toolsBandsInBand(String band) {
    return 'В радиолюбительском диапазоне $band';
  }

  @override
  String get toolsBandsOutOfBand => 'Вне радиолюбительских диапазонов';

  @override
  String get toolsBandsWavelength => 'Длина волны';

  @override
  String get toolsBandsDipole => 'Полуволновый диполь (целиком)';

  @override
  String get toolsBandsQuarterWave => 'Вертикальная антенна ¼ волны';

  @override
  String get toolsBandsAntennaNote => 'Длины учитывают коэффициент укорочения 0,95; подрежьте до резонанса.';

  @override
  String get toolsBandsTable => 'Границы диапазонов';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'Распределение ITU. Ваша лицензия и национальный частотный план могут задавать более узкие границы.';

  @override
  String get toolsSpeedCharacter => 'Скорость символов';

  @override
  String get toolsSpeedFarnsworth => 'Интервалы Фарнсворта';

  @override
  String get toolsSpeedOverall => 'Общая скорость';

  @override
  String get toolsSpeedDit => 'Точка';

  @override
  String get toolsSpeedDah => 'Тире';

  @override
  String get toolsSpeedCharGap => 'Пауза между символами';

  @override
  String get toolsSpeedWordGap => 'Пауза между словами';

  @override
  String get toolsSpeedCpm => 'Символов в минуту';

  @override
  String get toolsSpeedParis => 'Одно слово PARIS';

  @override
  String get toolsRstReadability => 'Разборчивость (R)';

  @override
  String get toolsRstStrength => 'Сила сигнала (S)';

  @override
  String get toolsRstTone => 'Тон (T)';

  @override
  String get toolsRstReport => 'Рапорт';

  @override
  String get toolsRstCut => 'Для соревнований';

  @override
  String get toolsRstPhone => 'Голосом (без тона)';

  @override
  String get toolsRstR1 => 'Неразборчиво';

  @override
  String get toolsRstR2 => 'Едва разборчиво, отдельные слова';

  @override
  String get toolsRstR3 => 'Разборчиво с большим трудом';

  @override
  String get toolsRstR4 => 'Разборчиво почти без труда';

  @override
  String get toolsRstR5 => 'Полностью разборчиво';

  @override
  String get toolsRstS1 => 'Едва заметный';

  @override
  String get toolsRstS2 => 'Очень слабый';

  @override
  String get toolsRstS3 => 'Слабый';

  @override
  String get toolsRstS4 => 'Умеренный';

  @override
  String get toolsRstS5 => 'Довольно хороший';

  @override
  String get toolsRstS6 => 'Хороший';

  @override
  String get toolsRstS7 => 'Довольно сильный';

  @override
  String get toolsRstS8 => 'Сильный';

  @override
  String get toolsRstS9 => 'Очень сильный';

  @override
  String get toolsRstT1 => 'Очень грубый и широкий, невыпрямленный AC';

  @override
  String get toolsRstT2 => 'Очень грубый тон AC, резкий и широкий';

  @override
  String get toolsRstT3 => 'Грубый, выпрямленный, без фильтрации';

  @override
  String get toolsRstT4 => 'Грубый, с признаками фильтрации';

  @override
  String get toolsRstT5 => 'Отфильтрованный, с сильной модуляцией пульсациями';

  @override
  String get toolsRstT6 => 'Отфильтрованный, с заметной пульсацией';

  @override
  String get toolsRstT7 => 'Почти чистый, со слабой пульсацией';

  @override
  String get toolsRstT8 => 'Почти идеальный, со слабой модуляцией';

  @override
  String get toolsRstT9 => 'Чистый тон, без пульсации';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => 'Местное время';

  @override
  String get toolsClockNote => 'В журналах связей и QSL-карточках используют UTC.';

  @override
  String get learnReceiveTitle => 'Приём';

  @override
  String get learnReviewTitle => 'Повторение';

  @override
  String get learnListen => 'Слушайте...';

  @override
  String get learnReady => 'Готово';

  @override
  String get learnReplay => 'Прослушать снова';

  @override
  String get learnAnswerHint => 'Введите услышанное';

  @override
  String get learnSubmit => 'Проверить';

  @override
  String get learnNext => 'Далее';

  @override
  String get learnFinish => 'Завершить';

  @override
  String get learnDone => 'Готово';

  @override
  String get learnBackspace => 'Удалить';

  @override
  String get learnSpace => 'Пробел';

  @override
  String get learnSent => 'Передано';

  @override
  String get learnYourCopy => 'Ваш приём';

  @override
  String get learnRoundPerfect => 'Всё принято верно!';

  @override
  String get learnSessionSummary => 'Итоги занятия';

  @override
  String get learnLessonPassed => 'Урок пройден';

  @override
  String get learnLessonNotPassed => 'Продолжайте: точность 90% откроет следующий символ';

  @override
  String get learnReviewRecorded => 'Повторение записано';

  @override
  String get learnWeakChars => 'Нужно улучшить';

  @override
  String get learnConfusions => 'Путаете';

  @override
  String get learnNoFeedbackWarning => 'Звук, вспышки и вибрация отключены — вместо них будет мигать экран.';

  @override
  String get learnSendTitle => 'Передача';

  @override
  String get learnSendThis => 'Передайте это';

  @override
  String get learnCopyFromMemory => 'По памяти';

  @override
  String get learnHiddenTarget => 'Скрыто — передайте по памяти';

  @override
  String get learnDecoded => 'Расшифровано';

  @override
  String get learnWaitingForKey => 'Начните передачу, когда будете готовы';

  @override
  String get learnRestart => 'Начать заново';

  @override
  String get learnTryAnother => 'Другой пример';

  @override
  String get learnKeyerStraight => 'Вертикальный';

  @override
  String get learnKeyerIambicA => 'Ямбический A';

  @override
  String get learnKeyerIambicB => 'Ямбический B';

  @override
  String get learnLegendStraight => 'Пробел = ключ';

  @override
  String get learnLegendPaddles => 'Левый Ctrl = точка, правый Ctrl = тире';

  @override
  String get learnSendClean => 'Чёткая передача — исправлять нечего.';

  @override
  String get learnSendIssues => 'Подсказки по ритму';

  @override
  String get learnYourSending => 'Расшифровано как';

  @override
  String get learnStraightKeyLabel => 'КЛЮЧ';

  @override
  String get learnDitLabel => 'ТОЧКА';

  @override
  String get learnDahLabel => 'ТИРЕ';

  @override
  String get learnSettingsTitle => 'Настройки обучения';

  @override
  String get learnCharacterSpeed => 'Скорость символов';

  @override
  String get learnFarnsworth => 'Интервалы Фарнсворта';

  @override
  String get learnFarnsworthHelp => 'Символы передаются быстро, а интервалы между ними увеличиваются до этой скорости.';

  @override
  String get learnEffectiveSpeed => 'Эффективная скорость';

  @override
  String get learnTone => 'Тон';

  @override
  String get learnPlaySample => 'Прослушать пример';

  @override
  String get learnSessionLength => 'Символов за занятие';

  @override
  String get learnFeedback => 'Обратная связь';

  @override
  String get learnSound => 'Звук';

  @override
  String get learnFlash => 'Вспышка экрана';

  @override
  String get learnHaptic => 'Вибрация';

  @override
  String get learnKeyer => 'Тип ключа';

  @override
  String get learnDailyGoal => 'Дневная цель';

  @override
  String get referenceReferenceTitle => 'Справочник азбуки Морзе';

  @override
  String get referenceTranslatorTitle => 'Переводчик';

  @override
  String get referencePlay => 'Воспроизвести';

  @override
  String get referenceStop => 'Остановить';

  @override
  String get referenceClear => 'Очистить';

  @override
  String get referenceClose => 'Закрыть';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => 'Поиск символов, служебных сигналов, Q-кодов…';

  @override
  String get referenceClearSearch => 'Очистить поиск';

  @override
  String get referenceNoResults => 'По вашему запросу ничего не найдено.';

  @override
  String get referenceSectionAlphabet => 'Алфавит';

  @override
  String get referenceSectionPunctuation => 'Знаки препинания';

  @override
  String get referenceSectionProsigns => 'Служебные сигналы';

  @override
  String get referenceSectionQCodes => 'Q-коды';

  @override
  String get referenceSectionAbbreviations => 'Сокращения CW';

  @override
  String get referenceSectionKoch => 'Порядок Коха';

  @override
  String get referenceAlphabetHint => 'Нажмите на карточку, чтобы прослушать. Удерживайте её, чтобы увидеть подсказку для запоминания.';

  @override
  String get referenceKochHint => 'Порядок введения символов по методу Коха (последовательность LCWO). Начните с K и M; добавляйте символ, когда точность приёма достигнет 90%.';

  @override
  String get referenceMnemonicTitle => 'Подсказка для запоминания';

  @override
  String get referenceMeaningLabel => 'Значение';

  @override
  String get referencePlaybackSettings => 'Настройки воспроизведения';

  @override
  String get referenceCharacterSpeed => 'Скорость символов';

  @override
  String get referenceFarnsworth => 'Интервалы Фарнсворта';

  @override
  String get referenceFarnsworthHelp => 'Символы передаются на полной скорости, а интервалы увеличиваются до эффективной скорости.';

  @override
  String get referenceEffectiveSpeed => 'Эффективная скорость';

  @override
  String get referenceTone => 'Тон';

  @override
  String get referenceModeTextToMorse => 'Текст → Морзе';

  @override
  String get referenceModeMorseToText => 'Морзе → Текст';

  @override
  String get referenceModeKey => 'Передача';

  @override
  String get referenceTextInputLabel => 'Текст';

  @override
  String get referenceTextInputHint => 'Введите текст для кодирования…';

  @override
  String get referencePatternOutputLabel => 'Морзе';

  @override
  String get referenceCopyPattern => 'Копировать код';

  @override
  String get referencePatternCopied => 'Код скопирован';

  @override
  String get referencePatternInputLabel => 'Морзе';

  @override
  String get referencePatternInputHint => 'Введите . и -, пробел между буквами и / между словами';

  @override
  String get referenceTextOutputLabel => 'Текст';

  @override
  String get referenceCopyText => 'Копировать текст';

  @override
  String get referenceTextCopied => 'Текст скопирован';

  @override
  String get referenceUnknownPatternHelp => 'Коды без соответствующего символа отображаются как <код>.';

  @override
  String get referenceKeypadDit => 'Точка';

  @override
  String get referenceKeypadDah => 'Тире';

  @override
  String get referenceKeypadCharGap => 'Интервал между буквами';

  @override
  String get referenceKeypadWordGap => 'Интервал между словами';

  @override
  String get referenceKeypadBackspace => 'Удалить символ';

  @override
  String get referenceKeyHint => 'Удерживайте ключ для передачи. На клавиатуре удерживайте пробел.';

  @override
  String get referenceKeyLabel => 'КЛЮЧ';

  @override
  String get referenceKeyDecodedLabel => 'Расшифровано';

  @override
  String get referenceKeyPendingLabel => 'Передача';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsLoading => 'Загрузка статистики...';

  @override
  String get statsLoadFailed => 'Не удалось загрузить прогресс. Потяните вниз или откройте снова для повторной попытки.';

  @override
  String get statsRetry => 'Повторить';

  @override
  String get statsEmptyTitle => 'Занятий пока нет';

  @override
  String get statsEmptyBody => 'Завершите первое занятие по приёму или передаче, и здесь появятся график точности, данные по каждому символу и календарь занятий.';

  @override
  String get statsEmptyCallToAction => 'Перейдите в «Обучение» и нажмите «Продолжить урок».';

  @override
  String get statsOverviewTitle => 'Обзор';

  @override
  String get statsTileLesson => 'Урок по методу Коха';

  @override
  String get statsTileAccuracy => 'Точность';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => 'Практика';

  @override
  String get statsTileStreak => 'Серия занятий';

  @override
  String get statsTileDailyGoal => 'Дневная цель';

  @override
  String get statsGoalMet => 'Достигнута сегодня';

  @override
  String get statsSummaryTitle => 'Ваша статистика';

  @override
  String get statsSummaryOpen => 'Просмотреть статистику';

  @override
  String get statsTrendTitle => 'Динамика точности';

  @override
  String get statsTrendHint => 'Нажмите на точку, чтобы посмотреть занятие.';

  @override
  String get statsSeriesReceive => 'Приём';

  @override
  String get statsSeriesSend => 'Передача';

  @override
  String get statsAxisSessions => 'Занятие';

  @override
  String get statsCharsTitle => 'Символы';

  @override
  String get statsCharsSubtitle => 'В порядке Коха. Нажмите на символ для подробностей.';

  @override
  String get statsCharsNotStarted => 'Ещё не изучался';

  @override
  String get statsNotInCourse => 'Не входит в курс Коха';

  @override
  String get statsSrsTitle => 'Интервальное повторение';

  @override
  String get statsSrsNotTracked => 'Повторение ещё не назначено';

  @override
  String get statsSrsDueNow => 'Пора повторить';

  @override
  String get statsConfusionsTitle => 'Чаще всего путается с';

  @override
  String get statsConfusionsNone => 'Ошибок распознавания не записано';

  @override
  String get statsConfusionMissed => 'пропущен';

  @override
  String get statsBucketLegendTitle => 'Точность';

  @override
  String get statsBucketNone => 'Нет';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => 'Ошибки распознавания';

  @override
  String get statsHeatmapSubtitle => 'В строках — переданные символы, в столбцах — ваши ответы. Чем темнее цвет, тем чаще ошибка.';

  @override
  String get statsHeatmapEmpty => 'Ошибок пока нет. Неверные ответы будут показаны здесь.';

  @override
  String get statsHeatmapLegendLow => 'Редко';

  @override
  String get statsHeatmapLegendHigh => 'Часто';

  @override
  String get statsHeatmapAxisTarget => 'Передано';

  @override
  String get statsHeatmapAxisAnswered => 'Ответ';

  @override
  String get statsCalendarTitle => 'Календарь занятий';

  @override
  String get statsCalendarSubtitle => 'Последние 12 недель';

  @override
  String get statsCalendarLegendLess => 'Меньше';

  @override
  String get statsCalendarLegendMore => 'Больше';

  @override
  String get statsStreakExplanation => 'Серия — это последовательные календарные дни хотя бы с одним занятием. Пропуск целого дня обнуляет её; два занятия в один день засчитываются как один день.';

  @override
  String get learnStatistics => 'Статистика';

  @override
  String get listenTitle => 'Прослушивание';

  @override
  String get listenStart => 'Начать';

  @override
  String get listenStop => 'Остановить';

  @override
  String get listenStarting => 'Запуск микрофона...';

  @override
  String get listenClear => 'Очистить текст';

  @override
  String get listenCopy => 'Копировать текст';

  @override
  String get listenCopied => 'Расшифрованный текст скопирован';

  @override
  String get listenSettings => 'Настройки прослушивания';

  @override
  String get listenDecoded => 'Расшифровано';

  @override
  String get listenEmptyHint => 'Направьте микрофон на источник сигнала Морзе. Здесь появится расшифрованный текст.';

  @override
  String get listenIdleHint => 'Нажмите «Начать», чтобы принимать сигнал Морзе.';

  @override
  String get listenPending => 'Приём';

  @override
  String get listenSpeed => 'Скорость';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => 'Сигнал';

  @override
  String get listenToneOn => 'Есть тон';

  @override
  String get listenTone => 'Частота тона';

  @override
  String get listenToneLocked => 'Частота найдена';

  @override
  String get listenToneSearching => 'Поиск';

  @override
  String get listenToneManual => 'Вручную';

  @override
  String get listenAutoTune => 'Автонастройка';

  @override
  String get listenAutoTuneHelp => 'Следить за самым сильным тоном в диапазоне 400–1000 Hz. Для ручной настройки переместите ползунок.';

  @override
  String get listenRetune => 'Авто';

  @override
  String get listenBlockSize => 'Блок анализа';

  @override
  String get listenBlockSizeHelp => 'Меньшие блоки точнее определяют границы точек и тире, но сильнее реагируют на шум. 256 отсчётов (5,3 ms) подходят для 5–40 WPM.';

  @override
  String get listenMinElement => 'Минимальная длительность';

  @override
  String get listenMinElementHelp => 'Более короткие тоны и паузы считаются щелчками и провалами сигнала и игнорируются.';

  @override
  String get listenPermissionDenied => 'Доступ к микрофону запрещён. Разрешите его в настройках системы и попробуйте ещё раз.';

  @override
  String get listenPermissionRetry => 'Повторить';

  @override
  String get listenStartFailed => 'Не удалось запустить микрофон.';

  @override
  String get listenNoInput => 'Микрофон не найден. Подключите его и попробуйте ещё раз.';

  @override
  String get listenStreamFailed => 'Микрофон неожиданно отключился. Попробуйте ещё раз.';

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
    return '$samples отсчётов ($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'Прослушивание остановлено после перехода приложения в фоновый режим.';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => 'Слишком длинные точки';

  @override
  String get learnTipDahTooShortTitle => 'Слишком короткие тире';

  @override
  String get learnTipIntraGapTooLongTitle => 'Элементы слишком разнесены';

  @override
  String get learnTipCharGapTooShortTitle => 'Символы сливаются';

  @override
  String get learnTipWordGapTooShortTitle => 'Слова сливаются';

  @override
  String get learnTipSpeedUnsteadyTitle => 'Неровная скорость';

  @override
  String get learnSeverityMinor => 'незначительно';

  @override
  String get learnSeverityModerate => 'заметно';

  @override
  String get learnSeveritySevere => 'сильно';

  @override
  String learnNewestCharIs(String char) {
    return 'Новый символ в уроке: $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, новый символ';
  }

  @override
  String learnPendingPattern(String pattern) {
    return 'Передача: $pattern';
  }

  @override
  String learnIssueHeadline(String title, String severity) {
    return '$title ($severity)';
  }

  @override
  String learnRatioTimes(String ratio) {
    return '$ratio×';
  }

  @override
  String learnTipDitTooLong(String ratio) {
    return 'Ваши точки слишком длинные (примерно $ratio длительности точки). Думайте «ти», а не «таа»: точка — это короткое нажатие, без удержания.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return 'Ваши тире слишком короткие (примерно $ratio длительности точки; цель — 3). Удерживайте тире в течение трёх точек.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return 'Паузы внутри символов слишком длинные (примерно $ratio длительности точки). Передавайте элементы одного символа компактно.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return 'Символы сливаются (паузы примерно $ratio длительности точки; цель — 3). Делайте отчётливую паузу после каждого символа.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return 'Слова слишком близко друг к другу (паузы примерно $ratio длительности точки; цель — 7). Выдерживайте длинную паузу между словами.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return 'Ваша скорость меняется (разброс $percent%). Выберите один темп и придерживайтесь его на протяжении всей строки.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return 'Слишком длинных точек: $offending из $total (в среднем $ratio длительности точки)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return 'Слишком коротких тире: $offending из $total (в среднем $ratio длительности точки)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return 'Слишком длинных пауз внутри символов: $offending из $total (в среднем $ratio длительности точки)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return 'Слишком коротких пауз между символами: $offending из $total (в среднем $ratio длительности точки)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return 'Слишком коротких пауз между словами: $offending из $total (в среднем $ratio длительности точки)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return 'Неровная скорость передачи (коэффициент вариации $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return 'Последние 7 дней / за всё время: $allTime';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds с';
  }

  @override
  String desktopTrayShow(String app) {
    return 'Показать $app';
  }

  @override
  String desktopTrayHide(String app) {
    return 'Скрыть $app';
  }

  @override
  String get desktopTraySoundOn => 'Звук включён';

  @override
  String get desktopTraySoundOff => 'Звук выключен';

  @override
  String desktopTrayQuit(String app) {
    return 'Закрыть $app';
  }

  @override
  String get listenStateOn => 'Вкл.';

  @override
  String get listenStateOff => 'Выкл.';

  @override
  String referenceTelegraphCodes(String codes) {
    return 'Китайский телеграфный код: $codes';
  }

  @override
  String get referenceTelegraphMainland => 'Материковый Китай, 1983';

  @override
  String get referenceTelegraphTaiwan => 'Тайвань / Гонконг';

  @override
  String get referenceTelegraphNone => 'Нет в этом справочнике кодов';

  @override
  String get appearanceTitle => 'Внешний вид';

  @override
  String get appearanceStyles => 'Стиль интерфейса';

  @override
  String get appearanceChoose => 'Выберите стиль, просмотрите и примените';

  @override
  String get appearanceMode => 'Светлый или тёмный режим';

  @override
  String get appearancePreview => 'Предпросмотр';

  @override
  String get appearanceApply => 'Применить стиль';

  @override
  String get appearanceRestore => 'Восстановить настройки по умолчанию';

  @override
  String get appearanceApplied => 'Внешний вид сохранён';

  @override
  String get appearanceSaveFailed => 'Не удалось сохранить внешний вид. Попробуйте ещё раз.';

  @override
  String get appearanceClassic => 'Классическая латунь';

  @override
  String get appearanceModern => 'Современное спокойствие';

  @override
  String get appearanceRadio => 'Ночное радио';

  @override
  String get appearancePaper => 'Бумажный справочник';

  @override
  String get appearanceCartoon => 'Яркий мультфильм';

  @override
  String get appearanceLight => 'Светлый';

  @override
  String get appearanceDark => 'Тёмный';

  @override
  String learnShowAllChars(int count) {
    return 'Показать все символы ($count)';
  }

  @override
  String get learnShowFewerChars => 'Свернуть символы';

  @override
  String get learnLeaveDrillTitle => 'Выйти из занятия?';

  @override
  String get learnLeaveDrillBody => 'Пройденные в этом занятии раунды не сохранятся.';

  @override
  String get learnLeaveDrillConfirm => 'Выйти';

  @override
  String get learnReplayAssistedNote => 'Повтор: занятие засчитано как практика, но не открывает урок и не обновляет повторения.';

  @override
  String get learnPlanTitle => 'План на сегодня';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return 'Около $minutes мин · $done из $total шагов';
  }

  @override
  String get learnPlanBudget => 'Длительность плана';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get learnPlanStart => 'Начать план';

  @override
  String get learnPlanContinue => 'Продолжить план';

  @override
  String get learnPlanStepReview => 'Повторить знаки';

  @override
  String get learnPlanStepFocus => 'Точечная практика';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'Урок $lesson';
  }

  @override
  String get learnPlanStepSend => 'Практика передачи';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return 'Пора повторить: $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'Часто путаются: $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return 'Ниже 90 %: $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count знаков: может открыть следующий урок';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return 'Увеличено до $count знаков, чтобы можно было открыть следующий урок';
  }

  @override
  String get learnPlanReasonConsolidate => 'Короткое занятие: закрепляет урок, не открывает следующий';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'Курс продвинулся: урок $lesson без открытия нового';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '$count коротких заданий на передачу';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return 'Готово · $percent %';
  }

  @override
  String get learnPlanStepDone => 'Готово';

  @override
  String learnPlanSendProgress(int done, int total) {
    return 'Передано $done из $total';
  }

  @override
  String get learnPlanStale => 'Урок или скорость изменились. Обновить ещё не начатые шаги?';

  @override
  String get learnPlanUpdate => 'Обновить шаги';

  @override
  String get learnPlanComplete => 'План на сегодня выполнен';

  @override
  String learnPlanNeedsWork(String symbols) {
    return 'Нужно подтянуть: $symbols';
  }

  @override
  String get learnPlanAllGood => 'Сегодня слабых знаков нет.';

  @override
  String get learnPlanTomorrow => 'Завтра будет новый план. Свободная практика доступна всегда.';

  @override
  String learnPlanEarlier(int done, int total) {
    return 'Прошлый план остановился на $done из $total шагов и сегодня не засчитывается.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return 'Можно перейти на эффективную скорость $wpm WPM';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return 'Можно перейти на $wpm WPM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'На этой скорости принимать трудно. Попробуйте $wpm WPM эффективной скорости или точечную практику.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return 'По последним $count занятиям без подсказок ($percent %). Ничего не изменится, пока вы не примените.';
  }

  @override
  String get learnSpeedAdviceApply => 'Применить';

  @override
  String get learnSpeedAdviceDismiss => 'Не сейчас';

  @override
  String get learnSpeedAdviceInsufficient => 'Для совета по скорости нужно 3 занятия без подсказок по 50+ знаков на текущей скорости.';

  @override
  String get learnQsoAction => 'Симулятор QSO';

  @override
  String learnQsoLocked(int lesson) {
    return 'С урока $lesson';
  }

  @override
  String get learnQsoTitle => 'Симулятор QSO';

  @override
  String get learnQsoRespond => 'Ответить на CQ';

  @override
  String get learnQsoRespondHint => 'Станция зовёт CQ. Ответьте и обменяйтесь рапортами.';

  @override
  String get learnQsoCall => 'Дать CQ';

  @override
  String get learnQsoCallHint => 'Вы даёте CQ, и станция отвечает.';

  @override
  String get learnQsoYourCall => 'Ваш позывной';

  @override
  String get learnQsoYourName => 'Ваше имя';

  @override
  String get learnQsoYourQth => 'Ваш QTH';

  @override
  String get learnQsoInvalidCall => 'Введите позывной, например BD1XYZ';

  @override
  String get learnQsoInvalidWord => 'Одно слово, только буквы A–Z';

  @override
  String get learnQsoOffline => 'Работает только на этом устройстве. Ничего не отправляется.';

  @override
  String get learnQsoStart => 'Начать QSO';

  @override
  String get learnQsoResume => 'Продолжить незавершённое QSO';

  @override
  String get learnQsoStageCallCq => 'Дайте CQ со своим позывным';

  @override
  String get learnQsoStageCallConfirm => 'Ответ: его позывной, DE, ваш';

  @override
  String get learnQsoStageExchange => 'Передайте рапорт, имя и QTH';

  @override
  String get learnQsoStageConfirmInfo => 'Подтвердите его данные';

  @override
  String get learnQsoStageClosing => 'Завершите 73 и <SK>';

  @override
  String get learnQsoStageDone => 'QSO завершено';

  @override
  String learnQsoSpeed(int wpm) {
    return 'Корреспондент передаёт на $wpm WPM';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call передаёт';
  }

  @override
  String get learnQsoRemoteHidden => 'Принимайте на слух — текст скрыт.';

  @override
  String get learnQsoShowText => 'Показать текст';

  @override
  String get learnQsoListen => 'Слушать';

  @override
  String get learnQsoAccepted => 'Принято';

  @override
  String get learnQsoRejected => 'Не принято';

  @override
  String get learnQsoRemoteSending => 'Корреспондент передаёт…';

  @override
  String get learnQsoYourTurn => 'Ваша очередь: передайте ответ и нажмите «Отправить».';

  @override
  String get learnQsoDecoded => 'Ваша передача';

  @override
  String get learnQsoNothingKeyed => 'Пока ничего не передано';

  @override
  String get learnQsoPlayAgain => 'Попросить повторить (AGN)';

  @override
  String get learnQsoSlower => 'Попросить медленнее (QRS)';

  @override
  String get learnQsoHint => 'Подсказка';

  @override
  String learnQsoHintLabel(String example) {
    return 'Пример: $example';
  }

  @override
  String get learnQsoPause => 'Пауза';

  @override
  String get learnQsoSend => 'Отправить';

  @override
  String get learnQsoClear => 'Очистить';

  @override
  String get learnQsoIssueEmpty => 'Ничего не передано.';

  @override
  String get learnQsoIssueMissingCq => 'Начните с CQ.';

  @override
  String get learnQsoIssueMissingDe => 'Поставьте DE между позывными.';

  @override
  String get learnQsoIssueWrongLocalCall => 'Ваш позывной отсутствует или неверен.';

  @override
  String get learnQsoIssueWrongRemoteCall => 'Позывной корреспондента неверен.';

  @override
  String get learnQsoIssueReversedCalls => 'Позывные перепутаны: сначала его, затем DE и ваш.';

  @override
  String get learnQsoIssueMissingEnding => 'Закончите K или KN.';

  @override
  String get learnQsoIssueMissingRst => 'Дайте рапорт, например UR RST 599.';

  @override
  String get learnQsoIssueInvalidRst => 'RST вне диапазона (R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'Передайте NAME и своё имя.';

  @override
  String get learnQsoIssueWrongName => 'Это не ваше имя в этом QSO.';

  @override
  String get learnQsoIssueMissingQth => 'Передайте QTH и своё местоположение.';

  @override
  String get learnQsoIssueWrongQth => 'Это не ваш QTH в этом QSO.';

  @override
  String get learnQsoIssueMissingAck => 'Подтвердите R или QSL.';

  @override
  String get learnQsoIssueWrongRemoteName => 'Подтвердите имя оператора.';

  @override
  String get learnQsoIssueMissing73 => 'Добавьте 73.';

  @override
  String get learnQsoIssueMissingSk => 'Завершите связь <SK>.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return 'С первого раза: $count из $total шагов';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return 'Повторы: $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'Подсказки: $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'Ваша передача: около $wpm WPM';
  }

  @override
  String get learnQsoSummaryNote => 'Результаты QSO учитываются отдельно от точности приёма и не открывают уроки.';

  @override
  String get learnTipDahTooLongTitle => 'Слишком длинные тире';

  @override
  String learnTipDahTooLong(String ratio) {
    return 'Ваши тире затянуты (примерно $ratio длительности точки; цель — 3). Отпускайте через три точки.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return 'Слишком длинных тире: $offending из $total (в среднем $ratio длительности точки)';
  }

  @override
  String get learnRhythmTitle => 'Ритм';

  @override
  String get learnRhythmMine => 'Мой ритм';

  @override
  String get learnRhythmStandard => 'Эталонный ритм (целевая скорость)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return 'Ошибки оцениваются по вашей длительности точки ($ms мс): ровно, но медленно — нормально. Эталон — целевая скорость.';
  }

  @override
  String get learnRhythmNotLocated => 'Не удалось сопоставить нажатия с отдельными знаками. Потренируйте всё задание целиком.';

  @override
  String get learnRhythmPlayMine => 'Мой вариант';

  @override
  String get learnRhythmPlayStandard => 'Эталон';

  @override
  String learnRhythmPracticePart(int count) {
    return 'Потренировать ($count попытки)';
  }

  @override
  String get learnRhythmPracticeWhole => 'Тренировать задание целиком';

  @override
  String get learnRhythmSymbolOk => 'Хорошо';

  @override
  String get learnRhythmZoomIn => 'Увеличить';

  @override
  String get learnRhythmZoomOut => 'Уменьшить';

  @override
  String get workbenchTitle => 'Работа с записями';

  @override
  String get workbenchOpen => 'Записи';

  @override
  String get workbenchImport => 'Импортировать запись';

  @override
  String get workbenchEmpty => 'Импортируйте запись WAV, чтобы прослушивать её по кругу, декодировать и принимать самостоятельно. Микрофон не нужен.';

  @override
  String get workbenchFormats => 'WAV, 16-битный PCM, моно или стерео, 8/16/44,1/48 кГц; до 50 МБ и 20 минут.';

  @override
  String get workbenchBackupNote => 'Записи остаются на этом устройстве. Сохраните копии перед очисткой данных или удалением приложения. Сохранённые фрагменты сохраняют названия, заметки и позиции.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate кГц · $channels · $duration';
  }

  @override
  String get workbenchMono => 'моно';

  @override
  String get workbenchStereo => 'стерео';

  @override
  String get workbenchErrorNotWav => 'Это не файл WAV.';

  @override
  String get workbenchErrorFormat => 'Пока поддерживается только 16-битный PCM WAV (без MP3, AAC и WAV с плавающей точкой).';

  @override
  String get workbenchErrorChannels => 'Поддерживаются только моно- или стереозаписи.';

  @override
  String get workbenchErrorRate => 'Частота дискретизации не поддерживается. Используйте 8, 16, 44,1 или 48 кГц.';

  @override
  String get workbenchErrorDamaged => 'Файл повреждён или неполон.';

  @override
  String get workbenchErrorTooLarge => 'Файл больше 50 МБ.';

  @override
  String get workbenchErrorTooLong => 'Запись длиннее 20 минут.';

  @override
  String get workbenchErrorIo => 'Не удалось прочитать файл.';

  @override
  String get workbenchErrorMissing => 'Файл записи не найден.';

  @override
  String get workbenchStart => 'Начало (с)';

  @override
  String get workbenchEnd => 'Конец (с)';

  @override
  String get workbenchSelectAll => 'Выбрать всё';

  @override
  String get workbenchPlay => 'Воспроизвести фрагмент';

  @override
  String get workbenchStop => 'Стоп';

  @override
  String get workbenchLoop => 'Повтор';

  @override
  String get workbenchPlayLimit => 'У длинного фрагмента воспроизводятся только первые 5 минут.';

  @override
  String get workbenchAutoTune => 'Искать тон автоматически';

  @override
  String workbenchManualTone(int hz) {
    return 'Тон: $hz Гц';
  }

  @override
  String get workbenchDecode => 'Декодировать фрагмент';

  @override
  String get workbenchCancel => 'Отмена';

  @override
  String workbenchDecoding(int percent) {
    return 'Декодирование… $percent %';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'Тон $hz Гц · около $wpm WPM';
  }

  @override
  String get workbenchToneNotLocked => 'Устойчивый тон не найден; попробуйте ручную настройку.';

  @override
  String get workbenchNoText => 'В этом фрагменте ничего не декодировано.';

  @override
  String workbenchUnknown(String patterns) {
    return 'Неизвестные коды: $patterns';
  }

  @override
  String get workbenchEdgeCut => 'Знак на краю фрагмента обрезан и может быть неверен.';

  @override
  String get workbenchToneNote => 'Захват тона — не показатель достоверности; проверьте текст на слух.';

  @override
  String get workbenchModeDecoder => 'Декодер';

  @override
  String get workbenchModeCopy => 'Принять самому';

  @override
  String get workbenchDecoderHidden => 'Текст декодера скрыт, пока вы принимаете.';

  @override
  String get workbenchShowDecoder => 'Показать текст декодера';

  @override
  String get workbenchReference => 'Эталонный текст (необязательно)';

  @override
  String get workbenchReferenceHelp => 'Вставьте переданный текст; иначе ваш приём сравнивается с выводом декодера.';

  @override
  String get workbenchAgainstDecoder => 'Сравнено с выводом декодера, который сам может ошибаться.';

  @override
  String get workbenchSave => 'Сохранить фрагмент';

  @override
  String get workbenchSaveTitle => 'Название';

  @override
  String get workbenchSaveNote => 'Заметка';

  @override
  String get workbenchSaved => 'Фрагмент сохранён';

  @override
  String get workbenchSaveFailed => 'Не удалось сохранить фрагмент.';

  @override
  String get workbenchLibrary => 'Сохранённые фрагменты';

  @override
  String get workbenchLibraryEmpty => 'Сохранённых фрагментов пока нет.';

  @override
  String get workbenchMissing => 'Файл записи отсутствует — выберите его снова или удалите запись.';

  @override
  String get workbenchRelink => 'Выбрать файл снова';

  @override
  String get workbenchDelete => 'Удалить';

  @override
  String get materialsTitle => 'Мои материалы';

  @override
  String get materialsNew => 'Новый материал';

  @override
  String get materialsEdit => 'Изменить';

  @override
  String get materialsSave => 'Сохранить';

  @override
  String get materialsSaveFailed => 'Не удалось сохранить материал.';

  @override
  String get materialsTitleField => 'Название';

  @override
  String get materialsTagsField => 'Теги (через запятую)';

  @override
  String get materialsTextField => 'Текст';

  @override
  String get materialsListField => 'По одной записи в строке';

  @override
  String get materialsKindText => 'Текст';

  @override
  String get materialsKindWords => 'Список слов';

  @override
  String get materialsKindCallsigns => 'Позывные';

  @override
  String get materialsPreview => 'Предпросмотр';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items записей · $symbols знаков · $prosigns процедурных';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'Без кода Морзе, пропускаются: $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return 'Повторов: $count, сохраняется по одному';
  }

  @override
  String get materialsProblemEmpty => 'Сначала введите текст.';

  @override
  String get materialsProblemTooLarge => 'Слишком большой: ограничение 1 МиБ.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return 'Слишком много записей: не более $count.';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return 'Запись слишком длинная: не более $count знаков.';
  }

  @override
  String get materialsProblemNothingTrainable => 'Здесь нечего тренировать азбукой Морзе.';

  @override
  String get materialsSearch => 'Поиск материалов';

  @override
  String get materialsFavoritesOnly => 'Избранное';

  @override
  String get materialsFavorite => 'В избранное';

  @override
  String get materialsUnfavorite => 'Убрать из избранного';

  @override
  String get materialsEmpty => 'Материалов пока нет. Добавьте тексты, списки слов или позывные.';

  @override
  String materialsItems(int count) {
    return 'Записей: $count';
  }

  @override
  String get materialsActions => 'Действия';

  @override
  String get materialsPractise => 'Тренировать';

  @override
  String get materialsDelete => 'Удалить';

  @override
  String get materialsDeleteTitle => 'Удалить материал?';

  @override
  String materialsDeleteBody(String title) {
    return '«$title» будет удалён с устройства. История занятий сохранится.';
  }

  @override
  String get materialsImport => 'Импорт TXT или JSON';

  @override
  String get materialsImportDialogTitle => 'Выберите файл материала';

  @override
  String get materialsSaveDialogTitle => 'Сохранить материал';

  @override
  String get materialsImportFailed => 'Импорт не удался. Библиотека не изменилась.';

  @override
  String get materialsImportNotUtf8 => 'Можно импортировать только текст в UTF-8.';

  @override
  String get materialsImportInvalid => 'Это не файл материалов MorseCQ. Ничего не импортировано.';

  @override
  String materialsImported(int count) {
    return 'Импортировано материалов: $count.';
  }

  @override
  String get materialsDuplicateTitle => 'Некоторые материалы уже есть';

  @override
  String get materialsDuplicateOverwrite => 'Заменить';

  @override
  String get materialsDuplicateKeepCopy => 'Оставить оба (как копии)';

  @override
  String get materialsDuplicateSkip => 'Пропустить';

  @override
  String get materialsExportJson => 'Экспорт в JSON';

  @override
  String materialsExported(int count) {
    return 'Экспортировано материалов: $count.';
  }

  @override
  String get materialsExportFailed => 'Экспорт не удался.';

  @override
  String get materialsExportWav => 'Экспорт аудио (WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return 'Скорость знаков: $wpm WPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return 'Эффективная скорость: $wpm WPM';
  }

  @override
  String materialsWavTone(int hz) {
    return 'Тон: $hz Гц';
  }

  @override
  String get materialsWavWithAnswer => 'Добавить текст ответа (.txt)';

  @override
  String get materialsWavFormat => 'WAV, 16 бит, моно, 48 кГц.';

  @override
  String materialsWavParts(int count) {
    return 'Длиннее 10 минут: будет $count файлов.';
  }

  @override
  String materialsWavExported(int count) {
    return 'Сохранено аудиофайлов: $count.';
  }

  @override
  String get materialsPracticeMode => 'Тренировать';

  @override
  String get materialsPracticeLearned => 'Только изученные знаки';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return 'Только изученные ($count записей недоступны: в них неизученные знаки)';
  }

  @override
  String get materialsPracticeAll => 'Все знаки Морзе';

  @override
  String get materialsPracticeNothing => 'В этом режиме нет записей для тренировки.';

  @override
  String get guestClearConfirm => 'Удалить';

  @override
  String get placementTitle => 'Проверить уровень';

  @override
  String get placementCheckLevel => 'Проверить текущий уровень';

  @override
  String get placementFromZero => 'Начать с нуля';

  @override
  String get placementOfferTitle => 'Новичок или уже принимаете?';

  @override
  String get placementOfferBody => 'Короткая проверка подскажет, с чего начать. Она необязательна и ничего не меняет, пока вы не решите.';

  @override
  String get placementIntro => 'Около 3–5 минут приёма в пять этапов: знаки Коха группами с ростом скорости, затем короткие слова. Это грубая оценка по малой выборке, а не сертификат. Можно остановиться в любой момент.';

  @override
  String get placementStart => 'Начать';

  @override
  String get placementSkip => 'Пропустить';

  @override
  String get placementStop => 'Стоп';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return 'Этап $step из $total · $wpm WPM';
  }

  @override
  String get placementTierPassed => 'Хорошо принято. Следующий этап быстрее.';

  @override
  String get placementTierStopped => 'Этап ниже 90 %, проверка завершена.';

  @override
  String get placementNextTier => 'Следующий этап';

  @override
  String placementSuggestion(int lesson) {
    return 'Рекомендуемый старт: урок $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return 'Подтверждено по порядку: $count из $total знаков Коха.';
  }

  @override
  String get placementLimits => 'По короткой выборке: непроверенные знаки остаются непроверенными, ничего не отмечается как выученное. Урок можно сменить в любой момент.';

  @override
  String placementAdopt(int lesson) {
    return 'Начать с урока $lesson';
  }

  @override
  String materialsImportConfirm(int count) {
    return 'Импортировать материалов: $count?';
  }

  @override
  String get materialsExportTxt => 'Экспорт в текст (TXT)';

  @override
  String get conditionsTitle => 'Условия';

  @override
  String get conditionsClear => 'Чисто';

  @override
  String get conditionsLight => 'Лёгкие помехи';

  @override
  String get conditionsRadio => 'Эфирная практика';

  @override
  String get conditionsClearHint => 'Чистый ровный тон — обычная тренировка.';

  @override
  String get conditionsLightHint => 'Тихий шум и мягкие замирания. Результаты хранятся отдельно от чистой тренировки.';

  @override
  String get conditionsRadioHint => 'Шум, глубокие замирания, соседняя станция и немного неровный темп. Результаты хранятся отдельно от чистой тренировки.';

  @override
  String get conditionsPreview => 'Прослушать';

  @override
  String conditionsActive(String name) {
    return 'Условия: $name';
  }

  @override
  String get conditionsNeedSound => 'Эфирные условия слышны, а не видны: включите звук в настройках тренировки или занимайтесь в чистых условиях.';

  @override
  String get conditionsCleanReplay => 'Воспроизвести без эффектов';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count попытки: в среднем $accuracy%',
      many: '$count попыток в этих условиях на этой скорости: в среднем $accuracy%',
      few: '$count попытки в этих условиях на этой скорости: в среднем $accuracy%',
      one: '$count попытка в этих условиях на этой скорости: $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => 'Тренировка в эфирных условиях засчитывается как активность, но не меняет уроки, график повторения и советы по скорости.';

  @override
  String get keysTitle => 'Клавиши и внешние ключи';

  @override
  String get keysMeSubtitle => 'Назначение клавиш, манипуляторы и USB-адаптеры';

  @override
  String get keysIntro => 'Выберите клавиши для передачи Морзе. USB-адаптеры ключа и манипулятора, эмулирующие клавиатуру, работают как она: задайте их клавиши здесь. Приложение не знает, какое устройство прислало клавишу, поэтому профиль — это набор назначений.';

  @override
  String get keysStandardProfile => 'Стандарт';

  @override
  String get keysUnnamed => 'Профиль без названия';

  @override
  String get keysEdit => 'Изменить';

  @override
  String get keysNewProfile => 'Новый профиль';

  @override
  String get keysLimitations => 'MIDI-, последовательные и Bluetooth-ключи, настройки прошивки адаптеров и управление передатчиком не поддерживаются. Проверенные адаптеры перечислены в документации.';

  @override
  String get keysEditTitle => 'Профиль клавиш';

  @override
  String get keysName => 'Название профиля';

  @override
  String get keysActionStraight => 'Прямой ключ';

  @override
  String get keysActionDit => 'Лопатка точки';

  @override
  String get keysActionDah => 'Лопатка тире';

  @override
  String get keysPressKey => 'Нажмите клавишу…';

  @override
  String get keysNone => 'Не задано';

  @override
  String get keysSet => 'Задать';

  @override
  String keysReserved(String key) {
    return '$key зарезервирована системой или приложением; выберите другую клавишу.';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key уже используется для: $action.';
  }

  @override
  String keysConflictSave(String keys) {
    return 'Каждая клавиша может выполнять только одно действие: $keys назначена дважды.';
  }

  @override
  String get keysMissing => 'Задайте клавиши, нужные этому режиму (обе лопатки для ямбического).';

  @override
  String get keysSwapPaddles => 'Поменять лопатки (левша)';

  @override
  String get keysKeyerMode => 'Режим ключа';

  @override
  String get keysIambicA => 'Ямбический A';

  @override
  String get keysIambicB => 'Ямбический B';

  @override
  String get keysAdapterKeyer => 'Адаптер сам формирует элементы';

  @override
  String get keysAdapterKeyerHint => 'Для адаптера со своим ключом: его нажатия и отпускания используются как есть, без второго ямбического ключа в приложении.';

  @override
  String get keysAppSidetone => 'Самоконтроль приложения при передаче';

  @override
  String get keysAppSidetoneHint => 'Выключите, если адаптер сам даёт самоконтроль. На декодирование не влияет.';

  @override
  String get keysTestTitle => 'Проверка';

  @override
  String get keysTestNote => 'Только проверка: ничего не отправляется и не засчитывается в тренировку.';

  @override
  String get keysTestRelease => 'Отпустить клавиши';

  @override
  String get keysAdapterActive => 'Используется ключ адаптера: клавиши лопаток работают как прямой ключ.';

  @override
  String keysHintCustom(String keys) {
    return 'Клавиши: $keys';
  }

  @override
  String get telegraphTitle => 'Китайский телеграфный код';

  @override
  String get telegraphIntro => 'Каждый китайский иероглиф передаётся четырёхзначным кодом. Тренируйте приём цифр и отдельно — запоминание, какой код означает какой иероглиф.';

  @override
  String get telegraphCodebook => 'Кодовая книга';

  @override
  String get telegraphCodebookMainland => 'Материковый';

  @override
  String get telegraphCodebookTaiwan => 'Тайвань';

  @override
  String get telegraphDigitsTitle => 'Приём кодовых групп';

  @override
  String get telegraphDigitsHint => 'Слушайте четырёхзначные группы настоящих кодов и вводите цифры.';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count занятия: $accuracy% цифр',
      many: '$count занятий: $accuracy% цифр',
      few: '$count занятия: $accuracy% цифр',
      one: '$count занятие: $accuracy% цифр',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => 'Вспомнить коды';

  @override
  String get telegraphRecallHint => 'Иероглиф → код и код → иероглиф. Отдельно от прогресса в Морзе.';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count карточки: известно $accuracy%',
      many: '$count карточек: известно $accuracy%',
      few: '$count карточки: известно $accuracy%',
      one: '$count карточка: известно $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => 'Запоминание кодов не открывает уроки Морзе и не меняет советы по скорости; приём цифр засчитывается как обычный приём Морзе.';

  @override
  String get telegraphRecallCharPrompt => 'Введите код этого иероглифа';

  @override
  String get telegraphRecallCodePrompt => 'Выберите иероглиф для этого кода';

  @override
  String get telegraphReveal => 'Показать ответ';

  @override
  String get telegraphRevealAssisted => 'Показано: карточка засчитывается как с подсказкой.';

  @override
  String get telegraphCorrect => 'Верно';

  @override
  String get telegraphIncorrect => 'Не совсем';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return 'Известно $correct из $total';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count карточки с показанным ответом',
      many: '$count карточек с показанным ответом',
      few: '$count карточки с показанным ответом',
      one: '$count карточка с показанным ответом',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => 'Расшифровка телеграфного кода';

  @override
  String get telegraphInterpretNote => 'Только для просмотра: само сообщение не меняется, ничего не отправляется.';

  @override
  String get telegraphUnresolved => 'Не найдено: нет иероглифа с этим кодом';

  @override
  String get telegraphMalformed => 'Не четырёхзначная группа';

  @override
  String get telegraphNotCode => 'Текст, без изменений';

  @override
  String get telegraphAmbiguous => 'Этот код у нескольких иероглифов';

  @override
  String get conditionsAudioFailed => 'Не удалось запустить звук на этом устройстве. Занимайтесь в чистых условиях.';

  @override
  String get aboutPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get aboutTermsOfUse => 'Условия использования';

  @override
  String get aboutSupport => 'Поддержка и контакты';

  @override
  String get aboutLinkFailed => 'Не удалось открыть ссылку, она скопирована.';

  @override
  String get offlineClearData => 'Удалить данные обучения';

  @override
  String get offlineClearDataBody => 'Удаляет прогресс, планы и материалы на этом устройстве.';

  @override
  String get offlineCleared => 'Данные обучения удалены.';

  @override
  String get offlineClearFailed => 'Не удалось удалить данные обучения.';

  @override
  String get learnStorageUnavailable => 'Не удалось открыть данные тренировок на этом устройстве. Попробуйте ещё раз.';

  @override
  String get materialsImportedSource => 'Импортированный источник';
}
