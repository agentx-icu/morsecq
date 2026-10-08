// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navMe => 'Yo';

  @override
  String get navReference => 'Referencia';

  @override
  String get navLearnDescription => 'Lecciones del método Koch, ejercicios de transmisión y práctica de recepción.';

  @override
  String get navReferenceDescription => 'Alfabeto, señales de procedimiento, códigos Q, abreviaturas y un traductor bidireccional.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get languageSaveFailed => 'No se pudo guardar el idioma. Inténtalo de nuevo.';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'Lección $lesson de $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caracteres aprendidos',
      one: '$count carácter aprendido',
    );
    return '$_temp0';
  }

  @override
  String learnDailyGoalProgress(int done, int goal) {
    return '$done / $goal caracteres';
  }

  @override
  String learnStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días seguidos',
      one: '$days día seguido',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '$count pendiente',
      zero: 'Nada pendiente',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$correct de $total correctos';
  }

  @override
  String learnRoundOf(int round) {
    return 'Ronda $round';
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
      other: '$count caracteres transmitidos',
      one: '$count carácter transmitido',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return 'Nuevo carácter desbloqueado: $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target omitido';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target oído como $answered';
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
      other: '$count caracteres',
      one: '$count carácter',
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
      other: '$count caracteres aprendidos',
      one: '$count carácter aprendido',
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
      other: '$count caracteres recibidos',
      one: '$count carácter recibido',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '$count sesión',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Récord: $count días',
      one: 'Récord: $count día',
    );
    return '$_temp0';
  }

  @override
  String statsGoalProgress(int done, int goal) {
    return '$done / $goal caracteres';
  }

  @override
  String statsGoalRemaining(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Faltan $remaining caracteres',
      one: 'Falta $remaining carácter',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Últimas $count sesiones',
      one: 'Última sesión',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return 'Sesión $index de $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total correctos';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'Lección $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos',
      one: '$count intento',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$correct de $attempts correctos';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'Introducido en la lección $lesson';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'Caja $box de $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Repasar en $days días',
      one: 'Repasar en $days día',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '$count vez',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '$count vez',
    );
    return '$target respondido como $answered, $_temp0';
  }

  @override
  String statsCalendarDay(String date, int chars) {
    String _temp0 = intl.Intl.pluralLogic(
      chars,
      locale: localeName,
      other: '$chars caracteres',
      one: '$chars carácter',
      zero: 'sin práctica',
    );
    return '$date: $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días activos',
      one: '$count día activo',
    );
    return '$_temp0';
  }

  @override
  String referenceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '$count entrada',
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
    return 'Omitidos (sin código Morse): $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Posición Koch: $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return 'Aproximadamente $wpm WPM';
  }

  @override
  String get accountSectionTraining => 'Entrenamiento';

  @override
  String get accountSectionAbout => 'Acerca de';

  @override
  String get accountTrainingDefaults => 'Valores de reproducción y entrenamiento';

  @override
  String get accountTrainingDefaultsSubtitle => 'Velocidad, tono y espaciado Farnsworth';

  @override
  String get accountAboutLicence => 'Licencia';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Código fuente';

  @override
  String get accountAboutSourceCopied => 'Enlace al código copiado';

  @override
  String get chatSend => 'Enviar';

  @override
  String get learnLessonCardTitle => 'Lección Koch';

  @override
  String get learnCourseComplete => 'Curso completado: ¡sigue perfeccionándote!';

  @override
  String get learnDailyGoalTitle => 'Hoy';

  @override
  String get learnDailyGoalMet => 'Objetivo diario alcanzado';

  @override
  String get learnNoStreak => 'Empieza hoy una racha';

  @override
  String get learnContinueLesson => 'Continuar lección';

  @override
  String get learnReceivePractice => 'Práctica de recepción';

  @override
  String get learnSendPractice => 'Práctica de transmisión';

  @override
  String get learnReviewDue => 'Repasar caracteres pendientes';

  @override
  String get learnSettings => 'Ajustes de entrenamiento';

  @override
  String get learnLoading => 'Cargando tu progreso...';

  @override
  String get learnLoadFailed => 'No se pudo leer tu progreso. Empezarás de nuevo; el archivo anterior se conservó como .corrupt.';

  @override
  String get learnProgressSaveFailed => 'No se pudo guardar tu progreso. El resultado cuenta mientras MorseCQ siga abierto.';

  @override
  String get learnChooseDrill => 'Elige un ejercicio';

  @override
  String get learnDrillGroups => 'Grupos aleatorios';

  @override
  String get learnDrillWords => 'Palabras';

  @override
  String get learnDrillCallsigns => 'Indicativos';

  @override
  String get learnDrillQso => 'QSO';

  @override
  String get learnDrillCharacters => 'Caracteres sueltos';

  @override
  String get learnDrillAbbreviations => 'Abreviaturas y códigos Q';

  @override
  String get learnDrillNumbers => 'Grupos de números';

  @override
  String get learnDrillConfusables => 'Caracteres similares';

  @override
  String get learnDrillContest => 'Intercambio de concurso';

  @override
  String get learnDrillGroupsHint => 'Grupos aleatorios con todos los caracteres que conoces';

  @override
  String get learnDrillCharactersHint => 'Un carácter cada vez: reconócelo al instante';

  @override
  String get learnDrillWordsHint => 'Palabras habituales en inglés';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL: abreviaturas usadas en radio';

  @override
  String get learnDrillNumbersHint => 'Grupos de cinco dígitos, como en mensajes y números de serie';

  @override
  String get learnDrillCallsignsHint => 'Indicativos de radioaficionados de todo el mundo';

  @override
  String get learnDrillConfusablesHint => 'Pares que confundes, como S/H o U/V, uno junto al otro';

  @override
  String get learnDrillQsoHint => 'Frases de un contacto completo';

  @override
  String get learnDrillContestHint => 'Indicativo, 5NN y número de serie o zona, al ritmo de un concurso';

  @override
  String get learnDrillReviewHint => 'Caracteres pendientes de repaso';

  @override
  String get toolsTitle => 'Herramientas de radio';

  @override
  String get toolsGridTitle => 'Localizador';

  @override
  String get toolsGridHint => 'Localizador por coordenadas, distancia y rumbo de antena';

  @override
  String get toolsBandsTitle => 'Bandas y antenas';

  @override
  String get toolsBandsHint => 'Banda de una frecuencia, longitud de onda y longitud del dipolo';

  @override
  String get toolsSpeedTitle => 'Velocidad CW';

  @override
  String get toolsSpeedHint => 'De WPM a duración del punto, intervalos y caracteres por minuto';

  @override
  String get toolsRstTitle => 'Reporte RST';

  @override
  String get toolsRstHint => 'Crea un reporte de señal y consulta el significado de cada dígito';

  @override
  String get toolsClockTitle => 'Reloj UTC';

  @override
  String get toolsClockHint => 'Hora UTC para el registro, junto a tu hora local';

  @override
  String get toolsGridFromCoordinates => 'Desde coordenadas';

  @override
  String get toolsGridLatitude => 'Latitud';

  @override
  String get toolsGridLongitude => 'Longitud';

  @override
  String get toolsGridCoordinatesHelp => 'Grados decimales; sur y oeste son negativos';

  @override
  String get toolsGridInvalidCoordinates => 'Latitud de -90 a 90, longitud de -180 a 180';

  @override
  String get toolsGridLocator => 'Localizador';

  @override
  String get toolsGridDistanceSection => 'Distancia y rumbo';

  @override
  String get toolsGridMine => 'Mi localizador';

  @override
  String get toolsGridTheirs => 'Localizador remoto';

  @override
  String get toolsGridInvalidLocator => 'Usa 2, 4, 6 u 8 caracteres, p. ej., OM89ex';

  @override
  String get toolsGridCenter => 'Centro de la cuadrícula';

  @override
  String get toolsGridDistance => 'Distancia';

  @override
  String get toolsGridShortPath => 'Rumbo por vía corta';

  @override
  String get toolsGridLongPath => 'Rumbo por vía larga';

  @override
  String get toolsBandsFrequency => 'Frecuencia (MHz)';

  @override
  String get toolsBandsInvalidFrequency => 'Introduce una frecuencia mayor que 0';

  @override
  String toolsBandsRegionLabel(int number) {
    return 'Región $number';
  }

  @override
  String get toolsBandsRegionHelp => '1: Europa, África, Oriente Medio · 2: América · 3: Asia-Pacífico';

  @override
  String toolsBandsInBand(String band) {
    return 'En la banda de radioaficionados de $band';
  }

  @override
  String get toolsBandsOutOfBand => 'Fuera de las bandas de radioaficionados';

  @override
  String get toolsBandsWavelength => 'Longitud de onda';

  @override
  String get toolsBandsDipole => 'Dipolo de media onda (total)';

  @override
  String get toolsBandsQuarterWave => 'Vertical de cuarto de onda';

  @override
  String get toolsBandsAntennaNote => 'Las longitudes incluyen un factor de acortamiento de 0,95; recorta hasta la resonancia.';

  @override
  String get toolsBandsTable => 'Límites de banda';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'Asignaciones de la ITU. Tu licencia y el plan nacional de bandas pueden ser más restrictivos.';

  @override
  String get toolsSpeedCharacter => 'Velocidad de los caracteres';

  @override
  String get toolsSpeedFarnsworth => 'Espaciado Farnsworth';

  @override
  String get toolsSpeedOverall => 'Velocidad global';

  @override
  String get toolsSpeedDit => 'Punto';

  @override
  String get toolsSpeedDah => 'Raya';

  @override
  String get toolsSpeedCharGap => 'Intervalo entre caracteres';

  @override
  String get toolsSpeedWordGap => 'Intervalo entre palabras';

  @override
  String get toolsSpeedCpm => 'Caracteres por minuto';

  @override
  String get toolsSpeedParis => 'Una palabra PARIS';

  @override
  String get toolsRstReadability => 'Legibilidad (R)';

  @override
  String get toolsRstStrength => 'Intensidad (S)';

  @override
  String get toolsRstTone => 'Tono (T)';

  @override
  String get toolsRstReport => 'Reporte';

  @override
  String get toolsRstCut => 'Forma de concurso';

  @override
  String get toolsRstPhone => 'En voz (sin tono)';

  @override
  String get toolsRstR1 => 'Ilegible';

  @override
  String get toolsRstR2 => 'Apenas legible, palabras sueltas';

  @override
  String get toolsRstR3 => 'Legible con mucha dificultad';

  @override
  String get toolsRstR4 => 'Legible casi sin dificultad';

  @override
  String get toolsRstR5 => 'Perfectamente legible';

  @override
  String get toolsRstS1 => 'Tenue, apenas perceptible';

  @override
  String get toolsRstS2 => 'Muy débil';

  @override
  String get toolsRstS3 => 'Débil';

  @override
  String get toolsRstS4 => 'Aceptable';

  @override
  String get toolsRstS5 => 'Bastante buena';

  @override
  String get toolsRstS6 => 'Buena';

  @override
  String get toolsRstS7 => 'Moderadamente fuerte';

  @override
  String get toolsRstS8 => 'Fuerte';

  @override
  String get toolsRstS9 => 'Extremadamente fuerte';

  @override
  String get toolsRstT1 => 'Muy áspero y ancho, AC sin rectificar';

  @override
  String get toolsRstT2 => 'AC muy áspera, estridente y ancha';

  @override
  String get toolsRstT3 => 'Áspero, rectificado sin filtrar';

  @override
  String get toolsRstT4 => 'Áspero, con algo de filtrado';

  @override
  String get toolsRstT5 => 'Filtrado, con fuerte modulación de rizado';

  @override
  String get toolsRstT6 => 'Filtrado, con rizado evidente';

  @override
  String get toolsRstT7 => 'Casi puro, con algo de rizado';

  @override
  String get toolsRstT8 => 'Casi perfecto, con leve modulación';

  @override
  String get toolsRstT9 => 'Tono perfecto, sin rizado';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => 'Hora local';

  @override
  String get toolsClockNote => 'Los registros de contactos y las tarjetas QSL usan UTC.';

  @override
  String get learnReceiveTitle => 'Recepción';

  @override
  String get learnReviewTitle => 'Repaso';

  @override
  String get learnListen => 'Escucha...';

  @override
  String get learnReady => 'Listo';

  @override
  String get learnReplay => 'Repetir audio';

  @override
  String get learnAnswerHint => 'Escribe lo que has oído';

  @override
  String get learnSubmit => 'Comprobar';

  @override
  String get learnNext => 'Siguiente';

  @override
  String get learnFinish => 'Finalizar';

  @override
  String get learnDone => 'Hecho';

  @override
  String get learnBackspace => 'Eliminar';

  @override
  String get learnSpace => 'Espacio';

  @override
  String get learnSent => 'Transmitido';

  @override
  String get learnYourCopy => 'Tu recepción';

  @override
  String get learnRoundPerfect => '¡Recepción perfecta!';

  @override
  String get learnSessionSummary => 'Resumen de la sesión';

  @override
  String get learnLessonPassed => 'Lección superada';

  @override
  String get learnLessonNotPassed => 'Sigue practicando: el 90% desbloquea el siguiente carácter';

  @override
  String get learnReviewRecorded => 'Repaso registrado';

  @override
  String get learnWeakChars => 'Por mejorar';

  @override
  String get learnConfusions => 'Confusiones';

  @override
  String get learnNoFeedbackWarning => 'Sonido, destellos y vibración desactivados: la pantalla parpadeará en su lugar.';

  @override
  String get learnSendTitle => 'Transmisión';

  @override
  String get learnSendThis => 'Transmite esto';

  @override
  String get learnCopyFromMemory => 'De memoria';

  @override
  String get learnHiddenTarget => 'Oculto: transmítelo de memoria';

  @override
  String get learnDecoded => 'Decodificado';

  @override
  String get learnWaitingForKey => 'Empieza a transmitir cuando estés listo';

  @override
  String get learnRestart => 'Reiniciar';

  @override
  String get learnTryAnother => 'Probar otro';

  @override
  String get learnKeyerStraight => 'Vertical';

  @override
  String get learnKeyerIambicA => 'Yámbico A';

  @override
  String get learnKeyerIambicB => 'Yámbico B';

  @override
  String get learnLegendStraight => 'Espacio = llave';

  @override
  String get learnLegendPaddles => 'Ctrl izquierdo = punto; Ctrl derecho = raya';

  @override
  String get learnSendClean => 'Transmisión limpia: no hay nada que corregir.';

  @override
  String get learnSendIssues => 'Consejos de ritmo';

  @override
  String get learnYourSending => 'Decodificado como';

  @override
  String get learnStraightKeyLabel => 'LLAVE';

  @override
  String get learnDitLabel => 'PUNTO';

  @override
  String get learnDahLabel => 'RAYA';

  @override
  String get learnSettingsTitle => 'Ajustes de entrenamiento';

  @override
  String get learnCharacterSpeed => 'Velocidad de los caracteres';

  @override
  String get learnFarnsworth => 'Espaciado Farnsworth';

  @override
  String get learnFarnsworthHelp => 'Los caracteres siguen siendo rápidos; sus intervalos se alargan hasta esta velocidad.';

  @override
  String get learnEffectiveSpeed => 'Velocidad efectiva';

  @override
  String get learnTone => 'Tono';

  @override
  String get learnPlaySample => 'Reproducir ejemplo';

  @override
  String get learnSessionLength => 'Caracteres por sesión';

  @override
  String get learnFeedback => 'Respuesta sensorial';

  @override
  String get learnSound => 'Sonido';

  @override
  String get learnFlash => 'Destello de pantalla';

  @override
  String get learnHaptic => 'Vibración';

  @override
  String get learnKeyer => 'Manipulador';

  @override
  String get learnDailyGoal => 'Objetivo diario';

  @override
  String get referenceReferenceTitle => 'Referencia de Morse';

  @override
  String get referenceTranslatorTitle => 'Traductor';

  @override
  String get referencePlay => 'Reproducir';

  @override
  String get referenceStop => 'Detener';

  @override
  String get referenceClear => 'Borrar';

  @override
  String get referenceClose => 'Cerrar';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => 'Buscar caracteres, señales de procedimiento, códigos Q…';

  @override
  String get referenceClearSearch => 'Borrar búsqueda';

  @override
  String get referenceNoResults => 'No hay resultados para tu búsqueda.';

  @override
  String get referenceSectionAlphabet => 'Alfabeto';

  @override
  String get referenceSectionPunctuation => 'Puntuación';

  @override
  String get referenceSectionProsigns => 'Señales de procedimiento';

  @override
  String get referenceSectionQCodes => 'Códigos Q';

  @override
  String get referenceSectionAbbreviations => 'Abreviaturas CW';

  @override
  String get referenceSectionKoch => 'Orden Koch';

  @override
  String get referenceAlphabetHint => 'Toca una tarjeta para escucharla. Mantenla pulsada para ver una regla mnemotécnica.';

  @override
  String get referenceKochHint => 'Orden de introducción de caracteres del método Koch (secuencia LCWO). Empieza con K y M; añade uno al alcanzar un 90% de recepción correcta.';

  @override
  String get referenceMnemonicTitle => 'Regla mnemotécnica';

  @override
  String get referenceMeaningLabel => 'Significado';

  @override
  String get referencePlaybackSettings => 'Ajustes de reproducción';

  @override
  String get referenceCharacterSpeed => 'Velocidad de los caracteres';

  @override
  String get referenceFarnsworth => 'Espaciado Farnsworth';

  @override
  String get referenceFarnsworthHelp => 'Los caracteres mantienen su velocidad; los intervalos se alargan hasta la velocidad efectiva.';

  @override
  String get referenceEffectiveSpeed => 'Velocidad efectiva';

  @override
  String get referenceTone => 'Tono';

  @override
  String get referenceModeTextToMorse => 'Texto → Morse';

  @override
  String get referenceModeMorseToText => 'Morse → Texto';

  @override
  String get referenceModeKey => 'Transmitir';

  @override
  String get referenceTextInputLabel => 'Texto';

  @override
  String get referenceTextInputHint => 'Escribe el texto que quieres codificar…';

  @override
  String get referencePatternOutputLabel => 'Morse';

  @override
  String get referenceCopyPattern => 'Copiar código';

  @override
  String get referencePatternCopied => 'Código copiado';

  @override
  String get referencePatternInputLabel => 'Morse';

  @override
  String get referencePatternInputHint => 'Escribe . y -, un espacio entre letras y / entre palabras';

  @override
  String get referenceTextOutputLabel => 'Texto';

  @override
  String get referenceCopyText => 'Copiar texto';

  @override
  String get referenceTextCopied => 'Texto copiado';

  @override
  String get referenceUnknownPatternHelp => 'Los códigos sin carácter correspondiente se muestran como <código>.';

  @override
  String get referenceKeypadDit => 'Punto';

  @override
  String get referenceKeypadDah => 'Raya';

  @override
  String get referenceKeypadCharGap => 'Intervalo entre letras';

  @override
  String get referenceKeypadWordGap => 'Intervalo entre palabras';

  @override
  String get referenceKeypadBackspace => 'Retroceso';

  @override
  String get referenceKeyHint => 'Mantén pulsada la llave para transmitir. Con un teclado, mantén Espacio.';

  @override
  String get referenceKeyLabel => 'LLAVE';

  @override
  String get referenceKeyDecodedLabel => 'Decodificado';

  @override
  String get referenceKeyPendingLabel => 'Transmitiendo';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsLoading => 'Cargando tus estadísticas...';

  @override
  String get statsLoadFailed => 'No se pudo cargar tu progreso. Desliza hacia abajo o vuelve a abrir para reintentar.';

  @override
  String get statsRetry => 'Reintentar';

  @override
  String get statsEmptyTitle => 'Aún no hay sesiones';

  @override
  String get statsEmptyBody => 'Termina tu primera sesión de recepción o transmisión y aquí aparecerán la evolución de precisión, el dominio de cada carácter y un calendario de práctica.';

  @override
  String get statsEmptyCallToAction => 'Ve a Aprender y pulsa «Continuar lección» para empezar.';

  @override
  String get statsOverviewTitle => 'Vista general';

  @override
  String get statsTileLesson => 'Lección Koch';

  @override
  String get statsTileAccuracy => 'Precisión';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => 'Práctica';

  @override
  String get statsTileStreak => 'Racha';

  @override
  String get statsTileDailyGoal => 'Objetivo diario';

  @override
  String get statsGoalMet => 'Alcanzado hoy';

  @override
  String get statsSummaryTitle => 'Tus estadísticas';

  @override
  String get statsSummaryOpen => 'Ver estadísticas';

  @override
  String get statsTrendTitle => 'Evolución de precisión';

  @override
  String get statsTrendHint => 'Toca un punto para consultar la sesión.';

  @override
  String get statsSeriesReceive => 'Recepción';

  @override
  String get statsSeriesSend => 'Transmisión';

  @override
  String get statsAxisSessions => 'Sesión';

  @override
  String get statsCharsTitle => 'Caracteres';

  @override
  String get statsCharsSubtitle => 'Orden Koch. Toca un carácter para ver los detalles.';

  @override
  String get statsCharsNotStarted => 'Aún sin practicar';

  @override
  String get statsNotInCourse => 'No forma parte del curso Koch';

  @override
  String get statsSrsTitle => 'Repetición espaciada';

  @override
  String get statsSrsNotTracked => 'Aún sin programar';

  @override
  String get statsSrsDueNow => 'Repasar ahora';

  @override
  String get statsConfusionsTitle => 'Se confunde más con';

  @override
  String get statsConfusionsNone => 'No hay confusiones registradas';

  @override
  String get statsConfusionMissed => 'omitido';

  @override
  String get statsBucketLegendTitle => 'Precisión';

  @override
  String get statsBucketNone => 'Ninguna';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => 'Confusiones';

  @override
  String get statsHeatmapSubtitle => 'Las filas muestran el carácter transmitido y las columnas tu respuesta. Cuanto más oscuro, más frecuente.';

  @override
  String get statsHeatmapEmpty => 'Aún no hay confusiones. Las respuestas incorrectas aparecerán aquí.';

  @override
  String get statsHeatmapLegendLow => 'Poco frecuente';

  @override
  String get statsHeatmapLegendHigh => 'Frecuente';

  @override
  String get statsHeatmapAxisTarget => 'Transmitido';

  @override
  String get statsHeatmapAxisAnswered => 'Respondido';

  @override
  String get statsCalendarTitle => 'Calendario de práctica';

  @override
  String get statsCalendarSubtitle => 'Últimas 12 semanas';

  @override
  String get statsCalendarLegendLess => 'Menos';

  @override
  String get statsCalendarLegendMore => 'Más';

  @override
  String get statsStreakExplanation => 'Una racha cuenta los días consecutivos con al menos una sesión. Saltarse un día completo la reinicia; practicar dos veces en un día solo cuenta como un día.';

  @override
  String get learnStatistics => 'Estadísticas';

  @override
  String get listenTitle => 'Escuchar';

  @override
  String get listenStart => 'Iniciar';

  @override
  String get listenStop => 'Detener';

  @override
  String get listenStarting => 'Iniciando micrófono...';

  @override
  String get listenClear => 'Borrar texto';

  @override
  String get listenCopy => 'Copiar texto';

  @override
  String get listenCopied => 'Texto decodificado copiado';

  @override
  String get listenSettings => 'Ajustes de escucha';

  @override
  String get listenDecoded => 'Decodificado';

  @override
  String get listenEmptyHint => 'Acerca el micrófono a un tono Morse. El texto decodificado aparecerá aquí.';

  @override
  String get listenIdleHint => 'Toca Iniciar para escuchar un tono Morse.';

  @override
  String get listenPending => 'Recibiendo';

  @override
  String get listenSpeed => 'Velocidad';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => 'Señal';

  @override
  String get listenToneOn => 'Tono';

  @override
  String get listenTone => 'Frecuencia del tono';

  @override
  String get listenToneLocked => 'Fijada';

  @override
  String get listenToneSearching => 'Buscando';

  @override
  String get listenToneManual => 'Manual';

  @override
  String get listenAutoTune => 'Sintonización automática';

  @override
  String get listenAutoTuneHelp => 'Sigue el tono más fuerte entre 400 y 1000 Hz. Arrastra el control para sintonizar manualmente.';

  @override
  String get listenRetune => 'Automático';

  @override
  String get listenBlockSize => 'Bloque de análisis';

  @override
  String get listenBlockSizeHelp => 'Los bloques pequeños sitúan los bordes de los elementos con más precisión, pero captan más ruido. 256 muestras (5,3 ms) sirven para 5–40 WPM.';

  @override
  String get listenMinElement => 'Elemento más corto';

  @override
  String get listenMinElementHelp => 'Los tonos y pausas más cortos se ignoran como chasquidos y cortes de señal.';

  @override
  String get listenPermissionDenied => 'Se denegó el acceso al micrófono. Permítelo en los ajustes del sistema e inténtalo de nuevo.';

  @override
  String get listenPermissionRetry => 'Intentar de nuevo';

  @override
  String get listenStartFailed => 'No se pudo iniciar el micrófono.';

  @override
  String get listenNoInput => 'No se encontró ningún micrófono. Conecta uno e inténtalo de nuevo.';

  @override
  String get listenStreamFailed => 'El micrófono se detuvo inesperadamente. Inténtalo de nuevo.';

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
    return '$samples muestras ($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'La escucha se detuvo mientras la aplicación estaba en segundo plano.';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => 'Puntos demasiado largos';

  @override
  String get learnTipDahTooShortTitle => 'Rayas demasiado cortas';

  @override
  String get learnTipIntraGapTooLongTitle => 'Elementos muy separados';

  @override
  String get learnTipCharGapTooShortTitle => 'Caracteres muy juntos';

  @override
  String get learnTipWordGapTooShortTitle => 'Palabras muy juntas';

  @override
  String get learnTipSpeedUnsteadyTitle => 'Velocidad irregular';

  @override
  String get learnSeverityMinor => 'leve';

  @override
  String get learnSeverityModerate => 'perceptible';

  @override
  String get learnSeveritySevere => 'grave';

  @override
  String learnNewestCharIs(String char) {
    return 'Nuevo en esta lección: $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, nuevo';
  }

  @override
  String learnPendingPattern(String pattern) {
    return 'Transmitiendo: $pattern';
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
    return 'Tus puntos son largos (aproximadamente $ratio de un punto). Piensa «di», no «daah»: un punto es un toque, no una pulsación prolongada.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return 'Tus rayas son cortas (aproximadamente $ratio de un punto; el objetivo es 3). Mantén la raya durante tres puntos.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return 'Los intervalos dentro de los caracteres son amplios (aproximadamente $ratio de un punto). Mantén juntos los elementos de cada carácter.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return 'Los caracteres se juntan (intervalos de aproximadamente $ratio de un punto; el objetivo es 3). Deja una pausa clara después de cada carácter.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return 'Las palabras están muy juntas (intervalos de aproximadamente $ratio de un punto; el objetivo es 7). Cuenta una pausa larga entre palabras.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return 'Tu velocidad varía (variación del $percent%). Elige un ritmo y mantenlo durante toda la línea.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$offending de $total puntos demasiado largos (media: $ratio puntos)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$offending de $total rayas demasiado cortas (media: $ratio puntos)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$offending de $total intervalos dentro de caracteres demasiado largos (media: $ratio puntos)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$offending de $total intervalos entre caracteres demasiado cortos (media: $ratio puntos)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$offending de $total intervalos entre palabras demasiado cortos (media: $ratio puntos)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return 'Velocidad de transmisión irregular (coef. de variación: $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return 'Últimos 7 días / total: $allTime';
  }

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String statsDurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String desktopTrayShow(String app) {
    return 'Mostrar $app';
  }

  @override
  String desktopTrayHide(String app) {
    return 'Ocultar $app';
  }

  @override
  String get desktopTraySoundOn => 'Sonido activado';

  @override
  String get desktopTraySoundOff => 'Sonido desactivado';

  @override
  String desktopTrayQuit(String app) {
    return 'Salir de $app';
  }

  @override
  String get listenStateOn => 'Activado';

  @override
  String get listenStateOff => 'Desactivado';

  @override
  String referenceTelegraphCodes(String codes) {
    return 'Código telegráfico chino: $codes';
  }

  @override
  String get referenceTelegraphMainland => 'China continental 1983';

  @override
  String get referenceTelegraphTaiwan => 'Taiwán / Hong Kong';

  @override
  String get referenceTelegraphNone => 'No figura en este código';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get appearanceStyles => 'Estilo de interfaz';

  @override
  String get appearanceChoose => 'Elige un estilo, previsualízalo y aplícalo';

  @override
  String get appearanceMode => 'Brillo';

  @override
  String get appearancePreview => 'Vista previa';

  @override
  String get appearanceApply => 'Aplicar estilo';

  @override
  String get appearanceRestore => 'Restaurar valores predeterminados';

  @override
  String get appearanceApplied => 'Apariencia guardada';

  @override
  String get appearanceSaveFailed => 'No se pudo guardar la apariencia. Inténtalo de nuevo.';

  @override
  String get appearanceClassic => 'Latón clásico';

  @override
  String get appearanceModern => 'Calma moderna';

  @override
  String get appearanceRadio => 'Radio nocturna';

  @override
  String get appearancePaper => 'Manual de papel';

  @override
  String get appearanceCartoon => 'Dibujos frescos';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String learnShowAllChars(int count) {
    return 'Mostrar los $count caracteres';
  }

  @override
  String get learnShowFewerChars => 'Mostrar menos caracteres';

  @override
  String get learnLeaveDrillTitle => '¿Salir de esta sesión?';

  @override
  String get learnLeaveDrillBody => 'Las rondas de esta sesión no se guardarán.';

  @override
  String get learnLeaveDrillConfirm => 'Salir';

  @override
  String get learnReplayAssistedNote => 'Repetido: esta sesión cuenta como práctica, pero no desbloquea lecciones ni actualiza repasos.';

  @override
  String get learnPlanTitle => 'Plan de hoy';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return 'Unos $minutes min · $done de $total pasos';
  }

  @override
  String get learnPlanBudget => 'Duración del plan';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learnPlanStart => 'Empezar el plan';

  @override
  String get learnPlanContinue => 'Continuar el plan';

  @override
  String get learnPlanStepReview => 'Repasar símbolos pendientes';

  @override
  String get learnPlanStepFocus => 'Práctica enfocada';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'Lección $lesson';
  }

  @override
  String get learnPlanStepSend => 'Práctica de transmisión';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return 'Toca repasar: $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'Se confunden a menudo: $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return 'Por debajo del 90 %: $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count símbolos: puede desbloquear la siguiente lección';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return 'Ampliado a $count símbolos para poder desbloquear la siguiente lección';
  }

  @override
  String get learnPlanReasonConsolidate => 'Sesión corta: consolida la lección, no desbloquea la siguiente';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'Tu curso avanzó: practica la lección $lesson sin desbloquear';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '$count objetivos cortos para manipular';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return 'Hecho · $percent %';
  }

  @override
  String get learnPlanStepDone => 'Hecho';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$done de $total enviados';
  }

  @override
  String get learnPlanStale => 'Cambió tu lección o velocidad. ¿Actualizar los pasos sin empezar?';

  @override
  String get learnPlanUpdate => 'Actualizar pasos';

  @override
  String get learnPlanComplete => 'Plan de hoy completado';

  @override
  String learnPlanNeedsWork(String symbols) {
    return 'A reforzar: $symbols';
  }

  @override
  String get learnPlanAllGood => 'Hoy no hay símbolos flojos.';

  @override
  String get learnPlanTomorrow => 'Mañana llega un plan nuevo. La práctica libre siempre está disponible.';

  @override
  String learnPlanEarlier(int done, int total) {
    return 'El plan anterior quedó en $done de $total pasos; ya no cuenta para hoy.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return 'Listo para $wpm PPM de velocidad efectiva';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return 'Listo para $wpm PPM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'Copiar a esta velocidad cuesta. Prueba $wpm PPM efectivas o una práctica enfocada.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return 'Según tus últimas $count sesiones sin ayuda ($percent %). Nada cambia hasta que lo apliques.';
  }

  @override
  String get learnSpeedAdviceApply => 'Aplicar';

  @override
  String get learnSpeedAdviceDismiss => 'Ahora no';

  @override
  String get learnSpeedAdviceInsufficient => 'El consejo de velocidad necesita 3 sesiones sin ayuda de 50+ símbolos a tu velocidad actual.';

  @override
  String get learnQsoAction => 'Simulador de QSO';

  @override
  String learnQsoLocked(int lesson) {
    return 'Desde la lección $lesson';
  }

  @override
  String get learnQsoTitle => 'Simulador de QSO';

  @override
  String get learnQsoRespond => 'Responder a un CQ';

  @override
  String get learnQsoRespondHint => 'Una estación llama CQ. Respóndele e intercambiad reportes.';

  @override
  String get learnQsoCall => 'Llamar CQ';

  @override
  String get learnQsoCallHint => 'Llamas CQ y una estación responde.';

  @override
  String get learnQsoYourCall => 'Tu indicativo';

  @override
  String get learnQsoYourName => 'Tu nombre';

  @override
  String get learnQsoYourQth => 'Tu QTH';

  @override
  String get learnQsoInvalidCall => 'Introduce un indicativo como BD1XYZ';

  @override
  String get learnQsoInvalidWord => 'Una palabra, solo letras A–Z';

  @override
  String get learnQsoOffline => 'Funciona por completo en este dispositivo. No se envía nada.';

  @override
  String get learnQsoStart => 'Empezar QSO';

  @override
  String get learnQsoResume => 'Reanudar el QSO sin terminar';

  @override
  String get learnQsoStageCallCq => 'Llama CQ con tu indicativo';

  @override
  String get learnQsoStageCallConfirm => 'Responde: su indicativo, DE, el tuyo';

  @override
  String get learnQsoStageExchange => 'Envía reporte, nombre y QTH';

  @override
  String get learnQsoStageConfirmInfo => 'Confirma su información';

  @override
  String get learnQsoStageClosing => 'Cierra con 73 y <SK>';

  @override
  String get learnQsoStageDone => 'QSO completado';

  @override
  String learnQsoSpeed(int wpm) {
    return 'El corresponsal transmite a $wpm PPM efectivas';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call transmite';
  }

  @override
  String get learnQsoRemoteHidden => 'Copia de oído: el texto está oculto.';

  @override
  String get learnQsoShowText => 'Mostrar texto';

  @override
  String get learnQsoListen => 'Escuchar';

  @override
  String get learnQsoAccepted => 'Aceptado';

  @override
  String get learnQsoRejected => 'No aceptado';

  @override
  String get learnQsoRemoteSending => 'La otra estación está transmitiendo…';

  @override
  String get learnQsoYourTurn => 'Tu turno: manipula tu respuesta y pulsa Enviar.';

  @override
  String get learnQsoDecoded => 'Tu transmisión';

  @override
  String get learnQsoNothingKeyed => 'Aún no has manipulado nada';

  @override
  String get learnQsoPlayAgain => 'Pedir repetición (AGN)';

  @override
  String get learnQsoSlower => 'Pedir más despacio (QRS)';

  @override
  String get learnQsoHint => 'Pista';

  @override
  String learnQsoHintLabel(String example) {
    return 'Ejemplo: $example';
  }

  @override
  String get learnQsoPause => 'Pausa';

  @override
  String get learnQsoSend => 'Enviar';

  @override
  String get learnQsoClear => 'Borrar';

  @override
  String get learnQsoIssueEmpty => 'No se manipuló nada.';

  @override
  String get learnQsoIssueMissingCq => 'Empieza con CQ.';

  @override
  String get learnQsoIssueMissingDe => 'Pon DE entre los indicativos.';

  @override
  String get learnQsoIssueWrongLocalCall => 'Tu indicativo falta o es incorrecto.';

  @override
  String get learnQsoIssueWrongRemoteCall => 'El indicativo de la otra estación es incorrecto.';

  @override
  String get learnQsoIssueReversedCalls => 'Indicativos al revés: primero el suyo, luego DE y el tuyo.';

  @override
  String get learnQsoIssueMissingEnding => 'Termina con K o KN.';

  @override
  String get learnQsoIssueMissingRst => 'Da un reporte, p. ej. UR RST 599.';

  @override
  String get learnQsoIssueInvalidRst => 'Ese RST está fuera de rango (R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'Envía NAME y tu nombre.';

  @override
  String get learnQsoIssueWrongName => 'Ese no es tu nombre en este QSO.';

  @override
  String get learnQsoIssueMissingQth => 'Envía QTH y tu ubicación.';

  @override
  String get learnQsoIssueWrongQth => 'Ese no es tu QTH en este QSO.';

  @override
  String get learnQsoIssueMissingAck => 'Confirma con R o QSL.';

  @override
  String get learnQsoIssueWrongRemoteName => 'Confirma el nombre del otro operador.';

  @override
  String get learnQsoIssueMissing73 => 'Incluye 73.';

  @override
  String get learnQsoIssueMissingSk => 'Termina el contacto con <SK>.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return 'Bien a la primera: $count de $total pasos';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return 'Repeticiones: $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'Pistas: $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'Tu transmisión: unas $wpm PPM';
  }

  @override
  String get learnQsoSummaryNote => 'Los resultados de QSO van aparte de la precisión de copia y nunca desbloquean lecciones.';

  @override
  String get learnTipDahTooLongTitle => 'Rayas demasiado largas';

  @override
  String learnTipDahTooLong(String ratio) {
    return 'Tus rayas se alargan (unas $ratio de un punto; objetivo 3). Suelta al cumplir tres puntos.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$offending de $total rayas demasiado largas (media $ratio punto)';
  }

  @override
  String get learnRhythmTitle => 'Ritmo';

  @override
  String get learnRhythmMine => 'Mi ritmo';

  @override
  String get learnRhythmStandard => 'Ritmo estándar (velocidad objetivo)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return 'Los problemas se juzgan con tu propio punto ($ms ms); un ritmo parejo pero lento está bien. La pista estándar es la velocidad objetivo.';
  }

  @override
  String get learnRhythmNotLocated => 'No se pudieron asignar tus marcas a símbolos concretos. Practica el objetivo completo.';

  @override
  String get learnRhythmPlayMine => 'Reproducir el mío';

  @override
  String get learnRhythmPlayStandard => 'Reproducir estándar';

  @override
  String learnRhythmPracticePart(int count) {
    return 'Practicar esto ($count intentos)';
  }

  @override
  String get learnRhythmPracticeWhole => 'Practicar el objetivo completo';

  @override
  String get learnRhythmSymbolOk => 'Bien';

  @override
  String get learnRhythmZoomIn => 'Acercar';

  @override
  String get learnRhythmZoomOut => 'Alejar';

  @override
  String get workbenchTitle => 'Banco de grabaciones';

  @override
  String get workbenchOpen => 'Grabaciones';

  @override
  String get workbenchImport => 'Importar grabación';

  @override
  String get workbenchEmpty => 'Importa una grabación WAV para repetirla, decodificarla y copiarla. No hace falta micrófono.';

  @override
  String get workbenchFormats => 'WAV, PCM de 16 bits, mono o estéreo, 8/16/44,1/48 kHz; hasta 50 MB y 20 minutos.';

  @override
  String get workbenchBackupNote => 'Las grabaciones permanecen en este dispositivo. Guarda copias antes de borrar los datos o desinstalar. Las selecciones conservan sus títulos, notas y posiciones.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => 'mono';

  @override
  String get workbenchStereo => 'estéreo';

  @override
  String get workbenchErrorNotWav => 'No es un archivo WAV.';

  @override
  String get workbenchErrorFormat => 'Por ahora solo se admite WAV PCM de 16 bits (no MP3, AAC ni WAV en coma flotante).';

  @override
  String get workbenchErrorChannels => 'Solo se admiten grabaciones mono o estéreo.';

  @override
  String get workbenchErrorRate => 'Frecuencia de muestreo no admitida. Usa 8, 16, 44,1 o 48 kHz.';

  @override
  String get workbenchErrorDamaged => 'El archivo está dañado o incompleto.';

  @override
  String get workbenchErrorTooLarge => 'El archivo supera los 50 MB.';

  @override
  String get workbenchErrorTooLong => 'La grabación dura más de 20 minutos.';

  @override
  String get workbenchErrorIo => 'No se pudo leer el archivo.';

  @override
  String get workbenchErrorMissing => 'Falta el archivo de la grabación.';

  @override
  String get workbenchStart => 'Inicio (s)';

  @override
  String get workbenchEnd => 'Fin (s)';

  @override
  String get workbenchSelectAll => 'Seleccionar todo';

  @override
  String get workbenchPlay => 'Reproducir selección';

  @override
  String get workbenchStop => 'Detener';

  @override
  String get workbenchLoop => 'Repetir';

  @override
  String get workbenchPlayLimit => 'De una selección más larga solo se reproducen los primeros 5 minutos.';

  @override
  String get workbenchAutoTune => 'Buscar el tono automáticamente';

  @override
  String workbenchManualTone(int hz) {
    return 'Tono: $hz Hz';
  }

  @override
  String get workbenchDecode => 'Decodificar selección';

  @override
  String get workbenchCancel => 'Cancelar';

  @override
  String workbenchDecoding(int percent) {
    return 'Decodificando… $percent %';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'Tono $hz Hz · unas $wpm PPM';
  }

  @override
  String get workbenchToneNotLocked => 'No se encontró un tono estable; prueba el ajuste manual.';

  @override
  String get workbenchNoText => 'No se decodificó nada en esta selección.';

  @override
  String workbenchUnknown(String patterns) {
    return 'Patrones desconocidos: $patterns';
  }

  @override
  String get workbenchEdgeCut => 'Un símbolo en el borde de la selección está cortado y puede ser erróneo.';

  @override
  String get workbenchToneNote => 'Fijar el tono no es una medida de confianza; comprueba el texto de oído.';

  @override
  String get workbenchModeDecoder => 'Decodificador';

  @override
  String get workbenchModeCopy => 'Copiarlo yo';

  @override
  String get workbenchDecoderHidden => 'El texto del decodificador está oculto mientras copias.';

  @override
  String get workbenchShowDecoder => 'Mostrar texto del decodificador';

  @override
  String get workbenchReference => 'Texto de referencia (opcional)';

  @override
  String get workbenchReferenceHelp => 'Pega el texto enviado; si no, tu copia se compara con la salida del decodificador.';

  @override
  String get workbenchAgainstDecoder => 'Comparado con la salida del decodificador, que también puede fallar.';

  @override
  String get workbenchSave => 'Guardar selección';

  @override
  String get workbenchSaveTitle => 'Título';

  @override
  String get workbenchSaveNote => 'Nota';

  @override
  String get workbenchSaved => 'Selección guardada';

  @override
  String get workbenchSaveFailed => 'No se pudo guardar la selección.';

  @override
  String get workbenchLibrary => 'Selecciones guardadas';

  @override
  String get workbenchLibraryEmpty => 'Aún no hay selecciones guardadas.';

  @override
  String get workbenchMissing => 'Falta el archivo: vuelve a elegirlo o borra la entrada.';

  @override
  String get workbenchRelink => 'Elegir el archivo de nuevo';

  @override
  String get workbenchDelete => 'Eliminar';

  @override
  String get materialsTitle => 'Mis materiales';

  @override
  String get materialsNew => 'Nuevo material';

  @override
  String get materialsEdit => 'Editar';

  @override
  String get materialsSave => 'Guardar';

  @override
  String get materialsSaveFailed => 'No se pudo guardar el material.';

  @override
  String get materialsTitleField => 'Título';

  @override
  String get materialsTagsField => 'Etiquetas (separadas por comas)';

  @override
  String get materialsTextField => 'Texto';

  @override
  String get materialsListField => 'Una entrada por línea';

  @override
  String get materialsKindText => 'Texto';

  @override
  String get materialsKindWords => 'Lista de palabras';

  @override
  String get materialsKindCallsigns => 'Indicativos';

  @override
  String get materialsPreview => 'Vista previa';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items elementos · $symbols símbolos · $prosigns prosignos';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'Sin código Morse, se omiten en la práctica: $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count entradas duplicadas se conservan una vez';
  }

  @override
  String get materialsProblemEmpty => 'Escribe algo de texto primero.';

  @override
  String get materialsProblemTooLarge => 'Demasiado grande: el límite es 1 MiB.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return 'Demasiadas entradas: máximo $count.';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return 'Una entrada es demasiado larga: máximo $count símbolos.';
  }

  @override
  String get materialsProblemNothingTrainable => 'Aquí no hay nada que practicar en Morse.';

  @override
  String get materialsSearch => 'Buscar materiales';

  @override
  String get materialsFavoritesOnly => 'Favoritos';

  @override
  String get materialsFavorite => 'Añadir a favoritos';

  @override
  String get materialsUnfavorite => 'Quitar de favoritos';

  @override
  String get materialsEmpty => 'Aún no hay materiales. Añade textos, listas de palabras o indicativos propios.';

  @override
  String materialsItems(int count) {
    return '$count elementos';
  }

  @override
  String get materialsActions => 'Acciones';

  @override
  String get materialsPractise => 'Practicar';

  @override
  String get materialsDelete => 'Eliminar';

  @override
  String get materialsDeleteTitle => '¿Eliminar material?';

  @override
  String materialsDeleteBody(String title) {
    return '«$title» se eliminará de este dispositivo. Tu historial se conserva.';
  }

  @override
  String get materialsImport => 'Importar TXT o JSON';

  @override
  String get materialsImportDialogTitle => 'Elige un archivo';

  @override
  String get materialsSaveDialogTitle => 'Guardar material';

  @override
  String get materialsImportFailed => 'Error al importar. Tu biblioteca no cambió.';

  @override
  String get materialsImportNotUtf8 => 'Solo se pueden importar archivos de texto UTF-8.';

  @override
  String get materialsImportInvalid => 'No es un archivo de materiales de MorseCQ válido. No se importó nada.';

  @override
  String materialsImported(int count) {
    return 'Se importaron $count materiales.';
  }

  @override
  String get materialsDuplicateTitle => 'Algunos materiales ya existen';

  @override
  String get materialsDuplicateOverwrite => 'Reemplazarlos';

  @override
  String get materialsDuplicateKeepCopy => 'Conservar ambos (como copia)';

  @override
  String get materialsDuplicateSkip => 'Omitirlos';

  @override
  String get materialsExportJson => 'Exportar como JSON';

  @override
  String materialsExported(int count) {
    return 'Se exportaron $count materiales.';
  }

  @override
  String get materialsExportFailed => 'Error al exportar.';

  @override
  String get materialsExportWav => 'Exportar audio (WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return 'Velocidad de carácter: $wpm PPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return 'Velocidad efectiva: $wpm PPM';
  }

  @override
  String materialsWavTone(int hz) {
    return 'Tono: $hz Hz';
  }

  @override
  String get materialsWavWithAnswer => 'Incluir el texto de respuesta (.txt)';

  @override
  String get materialsWavFormat => 'WAV mono de 16 bits, 48 kHz.';

  @override
  String materialsWavParts(int count) {
    return 'Más de 10 minutos: se exporta en $count archivos.';
  }

  @override
  String materialsWavExported(int count) {
    return 'Se guardaron $count archivos de audio.';
  }

  @override
  String get materialsPracticeMode => 'Practicar con';

  @override
  String get materialsPracticeLearned => 'Solo símbolos aprendidos';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return 'Solo símbolos aprendidos ($count entradas no disponibles: usan símbolos aún no aprendidos)';
  }

  @override
  String get materialsPracticeAll => 'Todos los símbolos Morse';

  @override
  String get materialsPracticeNothing => 'No hay entradas para practicar en este modo.';

  @override
  String get guestClearConfirm => 'Borrar';

  @override
  String get placementTitle => 'Comprobar mi nivel';

  @override
  String get placementCheckLevel => 'Comprobar mi nivel actual';

  @override
  String get placementFromZero => 'Saltar la intro: reto de la lección 1';

  @override
  String get placementOfferTitle => '¿Nuevo en Morse o ya copias?';

  @override
  String get placementOfferBody => 'Una prueba breve puede sugerir dónde empezar. Es opcional y no cambia nada hasta que elijas.';

  @override
  String get placementIntro => 'Unos 3–5 minutos de copia en cinco pasos: símbolos Koch en grupos a velocidad creciente y luego palabras cortas. Es una guía aproximada con pocas muestras, no un certificado. Para cuando quieras.';

  @override
  String get placementStart => 'Empezar';

  @override
  String get placementSkip => 'Omitir';

  @override
  String get placementStop => 'Parar';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return 'Paso $step de $total · $wpm PPM efectivas';
  }

  @override
  String get placementTierPassed => 'Bien copiado. El siguiente paso es más rápido.';

  @override
  String get placementTierStopped => 'Ese paso quedó por debajo del 90 %, la prueba termina aquí.';

  @override
  String get placementNextTier => 'Siguiente paso';

  @override
  String placementSuggestion(int lesson) {
    return 'Inicio sugerido: lección $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return '$count de $total símbolos Koch confirmados en orden.';
  }

  @override
  String get placementLimits => 'Basado en una muestra corta: los símbolos no probados siguen sin probar y nada se marca como aprendido. Puedes cambiar la lección cuando quieras.';

  @override
  String placementAdopt(int lesson) {
    return 'Empezar en la lección $lesson';
  }

  @override
  String materialsImportConfirm(int count) {
    return '¿Importar $count materiales?';
  }

  @override
  String get materialsExportTxt => 'Exportar como texto (TXT)';

  @override
  String get conditionsTitle => 'Condiciones';

  @override
  String get conditionsClear => 'Limpio';

  @override
  String get conditionsLight => 'Interferencia leve';

  @override
  String get conditionsRadio => 'Práctica de radio';

  @override
  String get conditionsClearHint => 'Un tono limpio y estable: práctica normal.';

  @override
  String get conditionsLightHint => 'Ruido de fondo suave y desvanecimiento ligero. Los resultados se guardan aparte de la práctica limpia.';

  @override
  String get conditionsRadioHint => 'Ruido, desvanecimiento profundo, una estación cercana y ritmo algo irregular. Los resultados se guardan aparte de la práctica limpia.';

  @override
  String get conditionsPreview => 'Escuchar';

  @override
  String conditionsActive(String name) {
    return 'Condiciones: $name';
  }

  @override
  String get conditionsNeedSound => 'Las condiciones de radio se oyen, no se ven: activa el sonido en los ajustes de práctica o practica con condiciones limpias.';

  @override
  String get conditionsCleanReplay => 'Reproducir sin efectos';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos con estas condiciones y velocidad: $accuracy % de media',
      one: '1 intento con estas condiciones y velocidad: $accuracy %',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => 'La práctica con condiciones de radio cuenta como actividad, pero no cambia tus lecciones, tu repaso ni la recomendación de velocidad.';

  @override
  String get keysTitle => 'Teclas y manipuladores externos';

  @override
  String get keysMeSubtitle => 'Asignación de teclas, paletas y adaptadores USB';

  @override
  String get keysIntro => 'Elige qué teclas manipulan Morse. Los adaptadores USB de manipulador y paletas que emulan un teclado funcionan como tal: define aquí sus teclas. La app no sabe qué dispositivo envió una tecla, así que un perfil es un conjunto de asignaciones.';

  @override
  String get keysStandardProfile => 'Estándar';

  @override
  String get keysUnnamed => 'Perfil sin nombre';

  @override
  String get keysEdit => 'Editar';

  @override
  String get keysNewProfile => 'Nuevo perfil';

  @override
  String get keysLimitations => 'No se admiten manipuladores MIDI, serie ni Bluetooth, ajustes de firmware del adaptador ni control del transmisor. Los adaptadores probados figuran en la documentación.';

  @override
  String get keysEditTitle => 'Perfil de teclas';

  @override
  String get keysName => 'Nombre del perfil';

  @override
  String get keysActionStraight => 'Manipulador vertical';

  @override
  String get keysActionDit => 'Paleta de punto';

  @override
  String get keysActionDah => 'Paleta de raya';

  @override
  String get keysPressKey => 'Pulsa una tecla…';

  @override
  String get keysNone => 'Sin definir';

  @override
  String get keysSet => 'Definir';

  @override
  String keysReserved(String key) {
    return '$key está reservada por el sistema o la app; elige otra tecla.';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key ya se usa para $action.';
  }

  @override
  String keysConflictSave(String keys) {
    return 'Cada tecla solo puede hacer una cosa: $keys está asignada dos veces.';
  }

  @override
  String get keysMissing => 'Define las teclas que necesita este modo (ambas paletas en yámbico).';

  @override
  String get keysSwapPaddles => 'Invertir paletas (zurdos)';

  @override
  String get keysKeyerMode => 'Modo del manipulador';

  @override
  String get keysIambicA => 'Yámbico A';

  @override
  String get keysIambicB => 'Yámbico B';

  @override
  String get keysAdapterKeyer => 'El adaptador genera sus propios elementos';

  @override
  String get keysAdapterKeyerHint => 'Para un adaptador con manipulador propio: sus pulsaciones temporizadas se usan tal cual, sin un segundo manipulador yámbico en la app.';

  @override
  String get keysAppSidetone => 'Tono local de la app al manipular';

  @override
  String get keysAppSidetoneHint => 'Desactívalo si el adaptador genera su propio tono. La decodificación no cambia.';

  @override
  String get keysTestTitle => 'Prueba';

  @override
  String get keysTestNote => 'Solo prueba: no se envía nada ni cuenta para tu práctica.';

  @override
  String get keysTestRelease => 'Soltar teclas';

  @override
  String get keysAdapterActive => 'Se usa el manipulador del adaptador: las teclas de paleta actúan como manipulador vertical.';

  @override
  String keysHintCustom(String keys) {
    return 'Teclas: $keys';
  }

  @override
  String get telegraphTitle => 'Código telegráfico chino';

  @override
  String get telegraphIntro => 'Cada carácter chino se envía como un código de cuatro cifras. Practica oír las cifras y, por separado, recordar qué código corresponde a cada carácter.';

  @override
  String get telegraphCodebook => 'Libro de códigos';

  @override
  String get telegraphCodebookMainland => 'China continental';

  @override
  String get telegraphCodebookTaiwan => 'Taiwán';

  @override
  String get telegraphDigitsTitle => 'Copiar grupos de código';

  @override
  String get telegraphDigitsHint => 'Escucha grupos de cuatro cifras de códigos reales y escribe las cifras.';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones: $accuracy % de cifras',
      one: '1 sesión: $accuracy % de cifras',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => 'Recordar códigos';

  @override
  String get telegraphRecallHint => 'De carácter a código y de código a carácter. Separado del progreso en Morse.';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarjetas respondidas: $accuracy % sabido',
      one: '1 tarjeta respondida: $accuracy % sabido',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => 'Recordar códigos nunca desbloquea lecciones de Morse ni cambia la recomendación de velocidad; copiar cifras cuenta como cualquier otra copia en Morse.';

  @override
  String get telegraphRecallCharPrompt => 'Escribe el código de este carácter';

  @override
  String get telegraphRecallCodePrompt => 'Elige el carácter de este código';

  @override
  String get telegraphReveal => 'Ver respuesta';

  @override
  String get telegraphRevealAssisted => 'Mostrada: esta tarjeta cuenta como asistida.';

  @override
  String get telegraphCorrect => 'Correcto';

  @override
  String get telegraphIncorrect => 'No del todo';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$correct de $total sabidas';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarjetas con la respuesta mostrada',
      one: '1 tarjeta con la respuesta mostrada',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => 'Interpretación del código telegráfico';

  @override
  String get telegraphInterpretNote => 'Solo se muestra aquí: el mensaje no cambia y no se envía nada.';

  @override
  String get telegraphUnresolved => 'Sin resolver: ningún carácter tiene este código';

  @override
  String get telegraphMalformed => 'No es un grupo de cuatro cifras';

  @override
  String get telegraphNotCode => 'Texto, tal como está';

  @override
  String get telegraphAmbiguous => 'Varios caracteres comparten este código';

  @override
  String get conditionsAudioFailed => 'No se pudo iniciar el audio en este dispositivo. Practica con condiciones limpias.';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutTermsOfUse => 'Condiciones de uso';

  @override
  String get aboutSupport => 'Ayuda y contacto';

  @override
  String get aboutLinkFailed => 'No se pudo abrir el enlace, así que se copió.';

  @override
  String get offlineClearData => 'Borrar los datos de aprendizaje';

  @override
  String get offlineClearDataBody => 'Borra tu progreso, tus planes y tus materiales de este dispositivo.';

  @override
  String get offlineCleared => 'Datos de aprendizaje borrados.';

  @override
  String get offlineClearFailed => 'No se pudieron borrar los datos de aprendizaje.';

  @override
  String get learnStorageUnavailable => 'No se pudieron abrir tus datos de entrenamiento en este dispositivo. Inténtalo de nuevo.';

  @override
  String get materialsImportedSource => 'Origen importado';

  @override
  String get learnStartHereTitle => '¿Nuevo aquí? Empieza con una primera lección de 3 minutos';

  @override
  String get learnStartHereBody => 'Escucha los sonidos, aprende K y M y responde unas rondas fáciles. Nada se califica.';

  @override
  String get learnStartHere => 'Empezar aquí';

  @override
  String get learnReplayFirstLesson => 'Repetir la primera lección';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '$introduced presentados · $mastered dominados';
  }

  @override
  String get learnChipNew => 'Nuevo';

  @override
  String get learnChipPractising => 'En práctica';

  @override
  String get learnChipMastered => 'Dominado';

  @override
  String get learnChipWeak => 'Menos del 90 %';

  @override
  String get learnChipDue => 'Pendiente de repaso';

  @override
  String get learnTapChipHint => 'Toca un carácter para oírlo';

  @override
  String learnHearChar(String char) {
    return 'Oír $char';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a frente a $b';
  }

  @override
  String get learnGuidedPractice => 'Práctica corta (10 símbolos)';

  @override
  String learnChallengeHint(int count, int min) {
    return 'El reto de la lección: $count símbolos al 90 %, con cada símbolo nuevo copiado al menos $min veces. Aprobarlo desbloquea el siguiente carácter.';
  }

  @override
  String get learnAllUnlockedNotPassed => 'Todos los caracteres están desbloqueados. Supera el último reto para completar el curso.';

  @override
  String get learnGoalFirstUse => 'Ahora: distinguir K de M de oído. Después: el reto de la lección 1.';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return 'Ahora: reconocer $chars con seguridad ($min copias al 90 %). Después: el reto de la lección $lesson.';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return 'Ahora: superar el reto de la lección $lesson. Después: $next.';
  }

  @override
  String learnGoalNextChar(String char) {
    return 'el carácter $char';
  }

  @override
  String get learnGoalNextOperating => 'palabras, indicativos y un QSO completo';

  @override
  String get learnGoalOperating => 'Ahora: mensajes reales — palabras, indicativos, QSO. Después: subir la velocidad efectiva paso a paso.';

  @override
  String get learnMorePractice => 'Más práctica';

  @override
  String get learnQsoReady => 'Listo';

  @override
  String get learnQsoPractiseFirst => 'Practica primero las líneas';

  @override
  String learnQsoSymbolsToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count símbolos por aprender',
      one: '1 símbolo por aprender',
    );
    return '$_temp0';
  }

  @override
  String get learnGlossaryTitle => '¿Qué significan estas palabras?';

  @override
  String get glossaryKoch => 'Método Koch: los caracteres se aprenden a velocidad real, dos al principio y uno más por lección en cuanto copias el 90 % bien.';

  @override
  String get glossaryWpm => 'WPM: palabras por minuto, contadas con la palabra estándar PARIS. La velocidad de carácter es lo rápido que suena cada carácter.';

  @override
  String get glossaryFarnsworth => 'Farnsworth: los caracteres siguen rápidos, pero las pausas entre ellos se alargan para que te dé tiempo a pensar. La velocidad efectiva cuenta esas pausas.';

  @override
  String get glossaryQso => 'QSO: un contacto entre dos estaciones. CQ = llamada general, DE = de, K = cambio.';

  @override
  String get glossaryRst => 'RST: un informe de señal — legibilidad, intensidad, tono. 599 significa perfecto. 73 significa saludos.';

  @override
  String get learnVerdictNotCredited => 'Nada registrado: no se respondió ningún símbolo.';

  @override
  String get learnVerdictAssisted => 'Práctica con ayuda';

  @override
  String get learnVerdictAssistedHint => 'Se usaron repeticiones o revelaciones, así que este intento cuenta solo como práctica: sin desbloqueo ni actualización de repasos. Prueba el siguiente sin repetir.';

  @override
  String get learnVerdictPractice => 'Práctica registrada';

  @override
  String get learnVerdictPracticeHint => 'La práctica libre actualiza estadísticas y repasos, pero nunca avanza el curso. Solo lo hace el reto de la lección desde el inicio de Aprender.';

  @override
  String get learnVerdictCourseComplete => 'Último reto superado: todo el curso de caracteres es tuyo.';

  @override
  String learnVerdictTooShort(int count, int min) {
    return 'Reto incompleto: $count de $min símbolos';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return 'Un reto tiene al menos $min símbolos. Inicia la lección desde el inicio de Aprender o sube la longitud de sesión en los ajustes.';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return 'Pocas copias de $chars';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return 'Un reto necesita al menos $min copias de cada símbolo nuevo. Inténtalo de nuevo: el reto los incluye a propósito.';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return 'Símbolo nuevo por debajo del 90 %: $chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => 'El resto estuvo bien; el símbolo nuevo decide la lección. Escúchalo frente a su vecino y practícalo antes del próximo reto.';

  @override
  String get learnVerdictBelowAccuracyHint => 'Menos del 90 % en total. Un ejercicio corto con los símbolos débiles de abajo y vuelve a intentar el reto.';

  @override
  String get learnDrillWeak => 'Practicar símbolos débiles';

  @override
  String get learnRetryChallenge => 'Repetir el reto';

  @override
  String get learnTakeChallenge => 'Hacer el reto de la lección';

  @override
  String learnChallengeTitle(int lesson) {
    return 'Reto de la lección $lesson';
  }

  @override
  String get learnPracticeTitle => 'Práctica';

  @override
  String get learnMeaningsTitle => 'Significados';

  @override
  String get firstLessonTitle => 'Primera lección';

  @override
  String firstLessonStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get firstLessonHearTitle => '¿Lo oyes?';

  @override
  String get firstLessonHearBody => 'Toca Reproducir. Deberías oír un patrón corto de pitidos (o ver un destello / notar una vibración si están activos).';

  @override
  String get firstLessonHeard => 'Lo oí';

  @override
  String get firstLessonNotHeard => 'No oí nada';

  @override
  String get firstLessonNoSoundTitle => '¿Sin sonido?';

  @override
  String get firstLessonNoSoundBody => 'Sube el volumen y revisa el interruptor de silencio o No molestar. También puedes seguir un destello de pantalla o una vibración.';

  @override
  String get firstLessonUseFlash => 'También parpadear la pantalla';

  @override
  String get firstLessonUseVibration => 'También vibrar';

  @override
  String get firstLessonPlay => 'Reproducir';

  @override
  String get firstLessonSoundsTitle => 'Corto y largo';

  @override
  String get firstLessonSoundsBody => 'El morse tiene dos sonidos: un dit corto y un dah tres veces más largo. Un carácter es un patrón de ellos y un silencio corto separa los caracteres. Toca cada uno para oírlo.';

  @override
  String get firstLessonDit => 'dit';

  @override
  String get firstLessonDah => 'dah';

  @override
  String get firstLessonWorkedTitle => 'Un ejemplo resuelto';

  @override
  String get firstLessonWorkedBody => 'Escucha primero; la respuesta aparece tras el sonido. Aún no tienes que responder.';

  @override
  String firstLessonWorkedReveal(String char) {
    return 'Eso fue $char';
  }

  @override
  String get firstLessonTrialsTitle => '¿K o M?';

  @override
  String get firstLessonTrialsBody => 'Escucha y toca el carácter que oíste. Repite cuantas veces quieras: esto no es un examen.';

  @override
  String firstLessonTrialRound(int round, int total) {
    return 'Ronda $round de $total';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return 'Sí, era $char';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return 'Era $char, no $answer. Escúchalos uno tras otro.';
  }

  @override
  String get firstLessonTooFast => '¿Demasiado rápido? Usa el ritmo principiante (pausas más largas entre caracteres)';

  @override
  String get firstLessonNextTitle => 'Qué sigue';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '$correct / $total correctos en esta ronda. Elige el siguiente paso y continúa a tu ritmo.';
  }

  @override
  String get firstLessonNextGuided => 'Práctica corta: 10 símbolos sueltos';

  @override
  String get firstLessonNextSend => 'Probar a transmitir';

  @override
  String get firstLessonSendGuide => 'Transmitir: mantén brevemente para un dit, más tiempo para un dah. Con palas, un lado hace dits y el otro dahs. Suelta y haz una pausa breve entre caracteres. Manipulador vertical o yámbico A / B se cambia después; por ahora da igual.';

  @override
  String get firstLessonReplayAnytime => 'Puedes repetir esta lección cuando quieras desde el inicio de Aprender.';

  @override
  String get firstLessonContinue => 'Continuar';

  @override
  String get firstLessonTrialNext => 'Siguiente ronda';

  @override
  String get sendFirstUseTitle => '¿Primera vez manipulando?';

  @override
  String get sendFirstUseStraight => 'Mantén brevemente para un dit, unas tres veces más para un dah. Pausa breve entre caracteres, más larga entre palabras.';

  @override
  String get sendFirstUsePaddles => 'Mantén la paleta marcada como punto para puntos y la marcada como raya para rayas; el manipulador controla su duración. Pausa entre caracteres, más entre palabras.';

  @override
  String get sendFirstUseDismiss => 'Entendido';

  @override
  String get learnSpeedPresets => 'Ritmo';

  @override
  String get learnPresetBeginner => 'Principiante 20 / 6';

  @override
  String get learnPresetStandard => 'Estándar 20 / 8';

  @override
  String get learnPresetHelp => 'Los caracteres suenan a 20 WPM en ambos; el ritmo principiante deja pausas más largas entre ellos (6 WPM efectivos).';

  @override
  String get learnPlanStepIntro => 'Primera lección';

  @override
  String get learnPlanStepRecognition => 'Símbolos sueltos';

  @override
  String get learnPlanReasonFirstLesson => 'Oír los sonidos y distinguir K de M (unos 3 minutos)';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return 'Un símbolo cada vez: $symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return 'Grupos mixtos cortos de $count símbolos; el reto de 50 símbolos vendrá después';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return 'Opcional: oye el modelo y luego manipula $count objetivos cortos';
  }

  @override
  String get learnQsoReadyTitle => 'Listo para un QSO';

  @override
  String get learnQsoNotReadyTitle => 'Aún no has aprendido todos los símbolos';

  @override
  String get learnQsoMissingBody => 'Un QSO usa estos símbolos que aún no has aprendido: toca uno para oírlo. Puedes explorar igualmente; el teclado muestra todos los símbolos.';

  @override
  String get learnQsoShorthandHint => 'Practica primero las abreviaturas (CQ, DE, UR, RST, TNX, 73) para que las líneas tengan sentido.';

  @override
  String get learnQsoPractiseShorthand => 'Practicar abreviaturas';

  @override
  String get learnQsoHowTitle => 'Cómo va un QSO';

  @override
  String get learnQsoHowBody => 'Llamada (CQ = a todos, DE = de), respuesta con indicativos, intercambio de informe (RST), nombre y QTH (lugar), luego 73 (saludos) y <SK> (fin). K significa cambio.';

  @override
  String get learnQsoExploreLabel => 'Incluye símbolos no aprendidos';

  @override
  String get statsCoursePassed => 'Curso superado';

  @override
  String get firstLessonPlayAgain => 'Reproducir otra vez';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return 'Reto de la lección $lesson: $count símbolos, 90 % desbloquea $char';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return 'Reto de la lección $lesson: $count símbolos al 90 % completan el curso';
  }

  @override
  String get learnQsoShorthandTitle => 'Practica primero las abreviaturas';

  @override
  String get learnQsoExchangeTitle => 'Practica primero las líneas de QSO';

  @override
  String get learnQsoExchangeHint => 'Copia líneas sueltas de un contacto (un intercambio cada vez) antes de hacer un QSO completo en el simulador.';

  @override
  String get sendGuideTitle => 'Aprender a transmitir';

  @override
  String sendGuideStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get sendGuideHear => 'Escuchar el modelo';

  @override
  String get sendGuideListening => 'Escucha el ritmo completo…';

  @override
  String get sendGuideTry => 'Ahora transmítelo';

  @override
  String get sendGuideRetry => 'Practicar este objetivo otra vez';

  @override
  String get sendGuidePassed => 'Decodificado correctamente. Continúa con el siguiente objetivo.';

  @override
  String get sendGuideComplete => 'Has transmitido bien ambos símbolos y grupos. Continúa con la práctica libre.';

  @override
  String get sendGuideRhythm => 'Sigue el modelo: puntos cortos, rayas tres veces más largas y una pausa clara entre caracteres.';

  @override
  String get learnContinueToday => 'Continuar el aprendizaje de hoy';

  @override
  String get learnPlanDetails => 'Ver detalles del plan';

  @override
  String get learnGuidedSingle => 'Caracteres individuales · 10 caracteres';

  @override
  String get learnGuidedShort => 'Grupos de 3 · 15 caracteres';

  @override
  String get learnGuidedGroups => 'Grupos de 5 · 20 caracteres';

  @override
  String get learnGuidedRecommended => 'Siguiente paso recomendado';

  @override
  String get learnGuidedProgressHint => 'Al superar un nivel, continúa con grupos cortos y completos. La práctica guiada refuerza lo aprendido; el desafío del curso desbloquea la siguiente lección.';

  @override
  String get learnGuidedContinue => 'Continuar la práctica guiada';

  @override
  String get learnGuidedRetry => 'Practicar este nivel de nuevo';

  @override
  String get firstLessonZeroHint => 'Está bien si aún no has acertado. Escucha otra vez la diferencia entre K y M e inténtalo de nuevo.';

  @override
  String get firstLessonPartialHint => 'Has oído algunos correctamente. Compara K y M otra vez y continúa a tu ritmo.';

  @override
  String get firstLessonPerfectHint => 'Todas las respuestas fueron correctas en esta ronda. Refuérzalo con práctica de copia sin opciones de respuesta.';

  @override
  String get firstLessonPaceLocked => 'Esta ronda ya ha comenzado, así que su velocidad no cambia. Puedes ajustarla para la siguiente ronda en los ajustes.';

  @override
  String get learnRecentEvidenceHint => 'Las etapas se basan en copias sin ayuda de los últimos 14 días a la misma velocidad.';

  @override
  String get learnQsoConsolidateTitle => 'Reforzar los caracteres aprendidos';

  @override
  String get learnQsoConsolidateHint => 'Desbloquear no equivale a dominar. Empieza copiando caracteres individuales para obtener resultados recientes sin ayuda.';

  @override
  String get learnQsoPractiseSymbols => 'Practicar estos caracteres';

  @override
  String get learnQsoProtocolTitle => 'Entender los términos de QSO';

  @override
  String get learnQsoProtocolHint => 'Comprueba el significado de CQ, DE, RST y 73 antes de iniciar un QSO corto.';

  @override
  String get learnQsoProtocolStart => 'Comprobar los términos';

  @override
  String learnQsoProtocolQuestion(String token) {
    return '¿Qué significa $token en un QSO?';
  }

  @override
  String get learnQsoGeneralCall => 'Llamada a cualquier estación';

  @override
  String get learnQsoFromStation => 'Desde esta estación';

  @override
  String get learnQsoSignalReport => 'Informe de señal';

  @override
  String get learnQsoBestRegards => 'Saludos y despedida';

  @override
  String get learnQsoProtocolCorrect => 'Respuesta correcta';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return 'Significado correcto: $meaning';
  }

  @override
  String get learnQsoProtocolPass => 'Has acertado los cuatro términos sin ayuda. Puedes probar un QSO corto.';

  @override
  String get learnQsoProtocolPractice => 'Repasa estos significados antes de volver a comprobarlos.';

  @override
  String get learnQsoProtocolRetry => 'Comprobar de nuevo';

  @override
  String get learnQsoShortExchange => 'Practicar un QSO corto';

  @override
  String get learnQsoShortExchangeHint => 'Confirma los indicativos, intercambia informes de señal y despídete sin ayuda antes de pasar a un QSO completo.';

  @override
  String get learnQsoExplorePending => 'Explorar un QSO completo · aún falta práctica';

  @override
  String get learnQsoReadyHint => 'Tienes resultados recientes de práctica sin ayuda y puedes comenzar QSO simulados completos.';
}
