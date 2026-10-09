// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'MorseCQ';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navMe => 'Eu';

  @override
  String get navReference => 'Referência';

  @override
  String get navLearnDescription => 'Lições do método Koch, exercícios de transmissão e prática de recepção.';

  @override
  String get navReferenceDescription => 'Alfabeto, sinais de procedimento, códigos Q, abreviaturas e um tradutor bidirecional.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionClose => 'Fechar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languageSaveFailed => 'Não foi possível salvar o idioma. Tente novamente.';

  @override
  String learnLessonOf(int lesson, int total) {
    return 'Lição $lesson de $total';
  }

  @override
  String learnCharsLearned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caracteres aprendidos',
      one: '$count caractere aprendido',
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
      other: '$days dias seguidos',
      one: '$days dia seguido',
    );
    return '$_temp0';
  }

  @override
  String learnReviewDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendentes',
      one: '$count pendente',
      zero: 'Nada pendente',
    );
    return '$_temp0';
  }

  @override
  String learnRoundScore(int correct, int total) {
    return '$correct de $total corretos';
  }

  @override
  String learnRoundOf(int round) {
    return 'Rodada $round';
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
      one: '$count caractere transmitido',
    );
    return '$_temp0';
  }

  @override
  String learnLessonUnlocked(String char) {
    return 'Novo caractere desbloqueado: $char';
  }

  @override
  String learnConfusedMissed(String target) {
    return '$target não recebido';
  }

  @override
  String learnConfusedAs(String target, String answered) {
    return '$target ouvido como $answered';
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
      one: '$count caractere',
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
      one: '$count caractere aprendido',
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
      other: '$count caracteres recebidos',
      one: '$count caractere recebido',
    );
    return '$_temp0';
  }

  @override
  String statsSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões',
      one: '$count sessão',
    );
    return '$_temp0';
  }

  @override
  String statsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recorde: $count dias',
      one: 'Recorde: $count dia',
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
      other: 'Faltam $remaining caracteres',
      one: 'Falta $remaining caractere',
    );
    return '$_temp0';
  }

  @override
  String statsTrendSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Últimas $count sessões',
      one: 'Última sessão',
      zero: 'Nenhuma sessão',
    );
    return '$_temp0';
  }

  @override
  String statsTooltipSession(int index, int total) {
    return 'Sessão $index de $total';
  }

  @override
  String statsTooltipCopied(int correct, int total) {
    return '$correct / $total corretos';
  }

  @override
  String statsTooltipLesson(int lesson) {
    return 'Lição $lesson';
  }

  @override
  String statsAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativas',
      one: '$count tentativa',
    );
    return '$_temp0';
  }

  @override
  String statsCorrectOf(int correct, int attempts) {
    return '$correct de $attempts corretos';
  }

  @override
  String statsLessonIntroduced(int lesson) {
    return 'Introduzido na lição $lesson';
  }

  @override
  String statsSrsBox(int box, int maxBox) {
    return 'Caixa $box de $maxBox';
  }

  @override
  String statsSrsDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Revisar em $days dias',
      one: 'Revisar em $days dia',
    );
    return '$_temp0';
  }

  @override
  String statsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes',
      one: '$count vez',
    );
    return '$_temp0';
  }

  @override
  String statsHeatmapCell(String target, String answered, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes',
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
      one: '$chars caractere',
      zero: 'sem prática',
    );
    return '$date: $_temp0';
  }

  @override
  String statsActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias ativos',
      one: '$count dia ativo',
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
    return 'Ignorados (sem código Morse): $chars';
  }

  @override
  String referenceKochPositionValue(int position) {
    return 'Posição Koch: $position';
  }

  @override
  String referenceEstimatedSpeed(String wpm) {
    return 'Aproximadamente $wpm WPM';
  }

  @override
  String get accountSectionTraining => 'Treinamento';

  @override
  String get accountSectionAbout => 'Sobre';

  @override
  String get accountTrainingDefaults => 'Padrões de reprodução e treinamento';

  @override
  String get accountTrainingDefaultsSubtitle => 'Velocidade, tom e espaçamento Farnsworth';

  @override
  String get accountAboutLicence => 'Licença';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Código-fonte';

  @override
  String get accountAboutSourceCopied => 'Link do código-fonte copiado';

  @override
  String get chatSend => 'Enviar';

  @override
  String get learnLessonCardTitle => 'Lição Koch';

  @override
  String get learnCourseComplete => 'Curso concluído: continue aperfeiçoando!';

  @override
  String get learnDailyGoalTitle => 'Hoje';

  @override
  String get learnDailyGoalMet => 'Meta diária alcançada';

  @override
  String get learnNoStreak => 'Comece hoje uma sequência';

  @override
  String get learnContinueLesson => 'Continuar lição';

  @override
  String get learnReceivePractice => 'Prática de recepção';

  @override
  String get learnSendPractice => 'Prática de transmissão';

  @override
  String get learnReviewDue => 'Revisar caracteres pendentes';

  @override
  String get learnSettings => 'Configurações de treinamento';

  @override
  String get learnLoading => 'Carregando seu progresso...';

  @override
  String get learnLoadFailed => 'Não foi possível ler seu progresso salvo. Você começará do zero; o arquivo antigo foi preservado como .corrupt.';

  @override
  String get learnProgressSaveFailed => 'Não foi possível salvar seu progresso. O resultado vale enquanto o MorseCQ estiver aberto.';

  @override
  String get learnChooseDrill => 'Escolha um exercício';

  @override
  String get learnDrillGroups => 'Grupos aleatórios';

  @override
  String get learnDrillWords => 'Palavras';

  @override
  String get learnDrillCallsigns => 'Indicativos';

  @override
  String get learnDrillQso => 'QSO';

  @override
  String get learnDrillCharacters => 'Caracteres individuais';

  @override
  String get learnDrillAbbreviations => 'Abreviações e códigos Q';

  @override
  String get learnDrillNumbers => 'Grupos de números';

  @override
  String get learnDrillConfusables => 'Caracteres parecidos';

  @override
  String get learnDrillContest => 'Trocas de concurso';

  @override
  String get learnDrillGroupsHint => 'Grupos aleatórios com todos os caracteres que você conhece';

  @override
  String get learnDrillCharactersHint => 'Um caractere por vez: reconheça na hora';

  @override
  String get learnDrillWordsHint => 'Palavras comuns em inglês';

  @override
  String get learnDrillAbbreviationsHint => 'TNX, FB, QTH, QSL: as abreviações do rádio';

  @override
  String get learnDrillNumbersHint => 'Grupos de cinco dígitos, como em mensagens e números de série';

  @override
  String get learnDrillCallsignsHint => 'Indicativos de radioamadores do mundo todo';

  @override
  String get learnDrillConfusablesHint => 'Pares que você confunde, como S/H ou U/V, lado a lado';

  @override
  String get learnDrillQsoHint => 'Frases de um contato completo';

  @override
  String get learnDrillContestHint => 'Indicativo, 5NN e número de série ou zona, no ritmo de um concurso';

  @override
  String get learnDrillReviewHint => 'Caracteres com revisão pendente';

  @override
  String get toolsTitle => 'Ferramentas de rádio';

  @override
  String get toolsGridTitle => 'Localizador';

  @override
  String get toolsGridHint => 'Localizador por coordenadas, distância e direção da antena';

  @override
  String get toolsBandsTitle => 'Bandas e antenas';

  @override
  String get toolsBandsHint => 'Banda de uma frequência, comprimento de onda e do dipolo';

  @override
  String get toolsSpeedTitle => 'Velocidade CW';

  @override
  String get toolsSpeedHint => 'De WPM para duração do ponto, intervalos e caracteres por minuto';

  @override
  String get toolsRstTitle => 'Relatório RST';

  @override
  String get toolsRstHint => 'Monte um relatório de sinal e veja o significado de cada dígito';

  @override
  String get toolsClockTitle => 'Relógio UTC';

  @override
  String get toolsClockHint => 'Hora UTC para o registro, ao lado da sua hora local';

  @override
  String get toolsGridFromCoordinates => 'A partir de coordenadas';

  @override
  String get toolsGridLatitude => 'Latitude';

  @override
  String get toolsGridLongitude => 'Longitude';

  @override
  String get toolsGridCoordinatesHelp => 'Graus decimais; sul e oeste são negativos';

  @override
  String get toolsGridInvalidCoordinates => 'Latitude de -90 a 90, longitude de -180 a 180';

  @override
  String get toolsGridLocator => 'Localizador';

  @override
  String get toolsGridDistanceSection => 'Distância e direção';

  @override
  String get toolsGridMine => 'Meu localizador';

  @override
  String get toolsGridTheirs => 'Localizador remoto';

  @override
  String get toolsGridInvalidLocator => 'Use 2, 4, 6 ou 8 caracteres, por exemplo, OM89ex';

  @override
  String get toolsGridCenter => 'Centro da quadrícula';

  @override
  String get toolsGridDistance => 'Distância';

  @override
  String get toolsGridShortPath => 'Direção pelo caminho curto';

  @override
  String get toolsGridLongPath => 'Direção pelo caminho longo';

  @override
  String get toolsBandsFrequency => 'Frequência (MHz)';

  @override
  String get toolsBandsInvalidFrequency => 'Digite uma frequência maior que 0';

  @override
  String toolsBandsRegionLabel(int number) {
    return 'Região $number';
  }

  @override
  String get toolsBandsRegionHelp => '1: Europa, África, Oriente Médio · 2: Américas · 3: Ásia-Pacífico';

  @override
  String toolsBandsInBand(String band) {
    return 'Na banda de radioamador de $band';
  }

  @override
  String get toolsBandsOutOfBand => 'Fora das bandas de radioamador';

  @override
  String get toolsBandsWavelength => 'Comprimento de onda';

  @override
  String get toolsBandsDipole => 'Dipolo de meia onda (total)';

  @override
  String get toolsBandsQuarterWave => 'Vertical de um quarto de onda';

  @override
  String get toolsBandsAntennaNote => 'Os comprimentos incluem um fator de encurtamento de 0,95; ajuste até a ressonância.';

  @override
  String get toolsBandsTable => 'Limites das bandas';

  @override
  String toolsBandsQrp(String frequency) {
    return 'QRP CW $frequency';
  }

  @override
  String get toolsBandsDisclaimer => 'Atribuições da ITU. Sua licença e o plano nacional de bandas podem ser mais restritos.';

  @override
  String get toolsSpeedCharacter => 'Velocidade dos caracteres';

  @override
  String get toolsSpeedFarnsworth => 'Espaçamento Farnsworth';

  @override
  String get toolsSpeedOverall => 'Velocidade geral';

  @override
  String get toolsSpeedDit => 'Ponto';

  @override
  String get toolsSpeedDah => 'Traço';

  @override
  String get toolsSpeedCharGap => 'Intervalo entre caracteres';

  @override
  String get toolsSpeedWordGap => 'Intervalo entre palavras';

  @override
  String get toolsSpeedCpm => 'Caracteres por minuto';

  @override
  String get toolsSpeedParis => 'Uma palavra PARIS';

  @override
  String get toolsRstReadability => 'Legibilidade (R)';

  @override
  String get toolsRstStrength => 'Intensidade (S)';

  @override
  String get toolsRstTone => 'Tom (T)';

  @override
  String get toolsRstReport => 'Relatório';

  @override
  String get toolsRstCut => 'Forma de concurso';

  @override
  String get toolsRstPhone => 'Em voz (sem tom)';

  @override
  String get toolsRstR1 => 'Ilegível';

  @override
  String get toolsRstR2 => 'Quase ilegível, palavras isoladas';

  @override
  String get toolsRstR3 => 'Legível com muita dificuldade';

  @override
  String get toolsRstR4 => 'Legível quase sem dificuldade';

  @override
  String get toolsRstR5 => 'Perfeitamente legível';

  @override
  String get toolsRstS1 => 'Fraco, quase imperceptível';

  @override
  String get toolsRstS2 => 'Muito fraco';

  @override
  String get toolsRstS3 => 'Fraco';

  @override
  String get toolsRstS4 => 'Razoável';

  @override
  String get toolsRstS5 => 'Razoavelmente bom';

  @override
  String get toolsRstS6 => 'Bom';

  @override
  String get toolsRstS7 => 'Moderadamente forte';

  @override
  String get toolsRstS8 => 'Forte';

  @override
  String get toolsRstS9 => 'Extremamente forte';

  @override
  String get toolsRstT1 => 'Muito áspero e largo, AC sem retificação';

  @override
  String get toolsRstT2 => 'AC muito áspera, estridente e larga';

  @override
  String get toolsRstT3 => 'Áspero, retificado sem filtragem';

  @override
  String get toolsRstT4 => 'Áspero, com alguma filtragem';

  @override
  String get toolsRstT5 => 'Filtrado, com forte modulação por ondulação';

  @override
  String get toolsRstT6 => 'Filtrado, com ondulação evidente';

  @override
  String get toolsRstT7 => 'Quase puro, com leve ondulação';

  @override
  String get toolsRstT8 => 'Quase perfeito, com leve modulação';

  @override
  String get toolsRstT9 => 'Tom perfeito, sem ondulação';

  @override
  String get toolsClockUtc => 'UTC';

  @override
  String get toolsClockLocal => 'Hora local';

  @override
  String get toolsClockNote => 'Os registros de contatos e os cartões QSL usam UTC.';

  @override
  String get learnReceiveTitle => 'Recepção';

  @override
  String get learnReviewTitle => 'Revisão';

  @override
  String get learnListen => 'Ouça...';

  @override
  String get learnReady => 'Pronto';

  @override
  String get learnReplay => 'Reproduzir novamente';

  @override
  String get learnAnswerHint => 'Digite o que ouviu';

  @override
  String get learnSubmit => 'Conferir';

  @override
  String get learnNext => 'Próximo';

  @override
  String get learnFinish => 'Finalizar';

  @override
  String get learnDone => 'Concluído';

  @override
  String get learnBackspace => 'Excluir';

  @override
  String get learnSpace => 'Espaço';

  @override
  String get learnSent => 'Transmitido';

  @override
  String get learnYourCopy => 'Sua recepção';

  @override
  String get learnRoundPerfect => 'Recepção perfeita!';

  @override
  String get learnSessionSummary => 'Resumo da sessão';

  @override
  String get learnLessonPassed => 'Lição concluída';

  @override
  String get learnLessonNotPassed => 'Continue praticando: 90% desbloqueia o próximo caractere';

  @override
  String get learnReviewRecorded => 'Revisão registrada';

  @override
  String get learnWeakChars => 'Precisa melhorar';

  @override
  String get learnConfusions => 'Confusões';

  @override
  String get learnNoFeedbackWarning => 'Som, flashes e vibração estão desligados: a tela piscará no lugar deles.';

  @override
  String get learnSendTitle => 'Transmissão';

  @override
  String get learnSendThis => 'Transmita isto';

  @override
  String get learnCopyFromMemory => 'De memória';

  @override
  String get learnHiddenTarget => 'Oculto: transmita de memória';

  @override
  String get learnDecoded => 'Decodificado';

  @override
  String get learnWaitingForKey => 'Comece a transmitir quando estiver pronto';

  @override
  String get learnRestart => 'Recomeçar';

  @override
  String get learnTryAnother => 'Tentar outro';

  @override
  String get learnKeyerStraight => 'Manual';

  @override
  String get learnKeyerIambicA => 'Iâmbico A';

  @override
  String get learnKeyerIambicB => 'Iâmbico B';

  @override
  String get learnLegendStraight => 'Espaço = chave';

  @override
  String get learnLegendPaddles => 'Ctrl esquerdo = ponto; Ctrl direito = traço';

  @override
  String get learnSendClean => 'Transmissão limpa: nada a corrigir.';

  @override
  String get learnSendIssues => 'Dicas de ritmo';

  @override
  String get learnYourSending => 'Decodificado como';

  @override
  String get learnStraightKeyLabel => 'CHAVE';

  @override
  String get learnDitLabel => 'PONTO';

  @override
  String get learnDahLabel => 'TRAÇO';

  @override
  String get learnSettingsTitle => 'Configurações de treinamento';

  @override
  String get learnCharacterSpeed => 'Velocidade dos caracteres';

  @override
  String get learnFarnsworth => 'Espaçamento Farnsworth';

  @override
  String get learnFarnsworthHelp => 'Os caracteres continuam rápidos; os intervalos entre eles se alongam até esta velocidade.';

  @override
  String get learnEffectiveSpeed => 'Velocidade efetiva';

  @override
  String get learnTone => 'Tom';

  @override
  String get learnPlaySample => 'Reproduzir exemplo';

  @override
  String get learnSessionLength => 'Caracteres por sessão';

  @override
  String get learnFeedback => 'Retorno sensorial';

  @override
  String get learnSound => 'Som';

  @override
  String get learnFlash => 'Flash da tela';

  @override
  String get learnHaptic => 'Vibração';

  @override
  String get learnKeyer => 'Manipulador';

  @override
  String get learnDailyGoal => 'Meta diária';

  @override
  String get referenceReferenceTitle => 'Referência de Morse';

  @override
  String get referenceTranslatorTitle => 'Tradutor';

  @override
  String get referencePlay => 'Reproduzir';

  @override
  String get referenceStop => 'Parar';

  @override
  String get referenceClear => 'Limpar';

  @override
  String get referenceClose => 'Fechar';

  @override
  String get referenceEmptyOutput => '—';

  @override
  String get referenceSearchHint => 'Buscar caracteres, sinais de procedimento, códigos Q…';

  @override
  String get referenceClearSearch => 'Limpar busca';

  @override
  String get referenceNoResults => 'Nenhum resultado para sua busca.';

  @override
  String get referenceSectionAlphabet => 'Alfabeto';

  @override
  String get referenceSectionPunctuation => 'Pontuação';

  @override
  String get referenceSectionProsigns => 'Sinais de procedimento';

  @override
  String get referenceSectionQCodes => 'Códigos Q';

  @override
  String get referenceSectionAbbreviations => 'Abreviações CW';

  @override
  String get referenceSectionKoch => 'Ordem Koch';

  @override
  String get referenceAlphabetHint => 'Toque em um cartão para ouvir. Pressione e segure para ver uma dica de memorização.';

  @override
  String get referenceKochHint => 'Ordem de introdução dos caracteres no método Koch (sequência LCWO). Comece com K e M; adicione um ao atingir 90% de acertos na recepção.';

  @override
  String get referenceMnemonicTitle => 'Dica de memorização';

  @override
  String get referenceMeaningLabel => 'Significado';

  @override
  String get referencePlaybackSettings => 'Configurações de reprodução';

  @override
  String get referenceCharacterSpeed => 'Velocidade dos caracteres';

  @override
  String get referenceFarnsworth => 'Espaçamento Farnsworth';

  @override
  String get referenceFarnsworthHelp => 'Os caracteres mantêm a velocidade máxima; os intervalos se alongam até a velocidade efetiva.';

  @override
  String get referenceEffectiveSpeed => 'Velocidade efetiva';

  @override
  String get referenceTone => 'Tom';

  @override
  String get referenceModeTextToMorse => 'Texto → Morse';

  @override
  String get referenceModeMorseToText => 'Morse → Texto';

  @override
  String get referenceModeKey => 'Transmitir';

  @override
  String get referenceTextInputLabel => 'Texto';

  @override
  String get referenceTextInputHint => 'Digite o texto para codificar…';

  @override
  String get referencePatternOutputLabel => 'Morse';

  @override
  String get referenceCopyPattern => 'Copiar código';

  @override
  String get referencePatternCopied => 'Código copiado';

  @override
  String get referencePatternInputLabel => 'Morse';

  @override
  String get referencePatternInputHint => 'Digite . e -, um espaço entre letras e / entre palavras';

  @override
  String get referenceTextOutputLabel => 'Texto';

  @override
  String get referenceCopyText => 'Copiar texto';

  @override
  String get referenceTextCopied => 'Texto copiado';

  @override
  String get referenceUnknownPatternHelp => 'Os códigos sem caractere correspondente aparecem como <código>.';

  @override
  String get referenceKeypadDit => 'Ponto';

  @override
  String get referenceKeypadDah => 'Traço';

  @override
  String get referenceKeypadCharGap => 'Intervalo entre letras';

  @override
  String get referenceKeypadWordGap => 'Intervalo entre palavras';

  @override
  String get referenceKeypadBackspace => 'Apagar';

  @override
  String get referenceKeyHint => 'Segure a chave para transmitir. No teclado, segure Espaço.';

  @override
  String get referenceKeyLabel => 'CHAVE';

  @override
  String get referenceKeyDecodedLabel => 'Decodificado';

  @override
  String get referenceKeyPendingLabel => 'Transmitindo';

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsLoading => 'Carregando suas estatísticas...';

  @override
  String get statsLoadFailed => 'Não foi possível carregar seu progresso. Puxe para baixo ou reabra para tentar novamente.';

  @override
  String get statsRetry => 'Tentar novamente';

  @override
  String get statsEmptyTitle => 'Ainda não há sessões';

  @override
  String get statsEmptyBody => 'Conclua sua primeira sessão de recepção ou transmissão para ver aqui a evolução da precisão, o domínio de cada caractere e um calendário de prática.';

  @override
  String get statsEmptyCallToAction => 'Vá para Aprender e toque em «Continuar lição» para começar.';

  @override
  String get statsOverviewTitle => 'Visão geral';

  @override
  String get statsTileLesson => 'Lição Koch';

  @override
  String get statsTileAccuracy => 'Precisão';

  @override
  String get statsNoData => '--';

  @override
  String get statsTilePractice => 'Prática';

  @override
  String get statsTileStreak => 'Sequência';

  @override
  String get statsTileDailyGoal => 'Meta diária';

  @override
  String get statsGoalMet => 'Alcançada hoje';

  @override
  String get statsSummaryTitle => 'Suas estatísticas';

  @override
  String get statsSummaryOpen => 'Ver estatísticas';

  @override
  String get statsTrendTitle => 'Evolução da precisão';

  @override
  String get statsTrendHint => 'Toque em um ponto para ver a sessão.';

  @override
  String get statsSeriesReceive => 'Recepção';

  @override
  String get statsSeriesSend => 'Transmissão';

  @override
  String get statsAxisSessions => 'Sessão';

  @override
  String get statsCharsTitle => 'Caracteres';

  @override
  String get statsCharsSubtitle => 'Ordem Koch. Toque em um caractere para ver detalhes.';

  @override
  String get statsCharsNotStarted => 'Ainda não praticado';

  @override
  String get statsNotInCourse => 'Não faz parte do curso Koch';

  @override
  String get statsSrsTitle => 'Repetição espaçada';

  @override
  String get statsSrsNotTracked => 'Ainda não agendado';

  @override
  String get statsSrsDueNow => 'Revisar agora';

  @override
  String get statsConfusionsTitle => 'Mais confundido com';

  @override
  String get statsConfusionsNone => 'Nenhuma confusão registrada';

  @override
  String get statsConfusionMissed => 'não recebido';

  @override
  String get statsBucketLegendTitle => 'Precisão';

  @override
  String get statsBucketNone => 'Nenhuma';

  @override
  String get statsBucketWeak => '< 70%';

  @override
  String get statsBucketFair => '70-89%';

  @override
  String get statsBucketGood => '90-97%';

  @override
  String get statsBucketStrong => '>= 98%';

  @override
  String get statsHeatmapTitle => 'Confusões';

  @override
  String get statsHeatmapSubtitle => 'As linhas mostram o caractere transmitido e as colunas, sua resposta. Quanto mais escuro, mais frequente.';

  @override
  String get statsHeatmapEmpty => 'Ainda não há confusões. As respostas incorretas aparecerão aqui.';

  @override
  String get statsHeatmapLegendLow => 'Rara';

  @override
  String get statsHeatmapLegendHigh => 'Frequente';

  @override
  String get statsHeatmapAxisTarget => 'Transmitido';

  @override
  String get statsHeatmapAxisAnswered => 'Respondido';

  @override
  String get statsCalendarTitle => 'Calendário de prática';

  @override
  String get statsCalendarSubtitle => 'Últimas 12 semanas';

  @override
  String get statsCalendarLegendLess => 'Menos';

  @override
  String get statsCalendarLegendMore => 'Mais';

  @override
  String get statsStreakExplanation => 'Uma sequência conta os dias consecutivos com pelo menos uma sessão. Ficar um dia inteiro sem praticar a reinicia; praticar duas vezes no mesmo dia conta apenas uma vez.';

  @override
  String get learnStatistics => 'Estatísticas';

  @override
  String get listenTitle => 'Escutar';

  @override
  String get listenStart => 'Iniciar';

  @override
  String get listenStop => 'Parar';

  @override
  String get listenStarting => 'Iniciando microfone...';

  @override
  String get listenClear => 'Limpar texto';

  @override
  String get listenCopy => 'Copiar texto';

  @override
  String get listenCopied => 'Texto decodificado copiado';

  @override
  String get listenSettings => 'Configurações de escuta';

  @override
  String get listenDecoded => 'Decodificado';

  @override
  String get listenEmptyHint => 'Aponte o microfone para um tom Morse. O texto decodificado aparecerá aqui.';

  @override
  String get listenIdleHint => 'Toque em Iniciar para escutar um tom Morse.';

  @override
  String get listenPending => 'Recebendo';

  @override
  String get listenSpeed => 'Velocidade';

  @override
  String get listenSpeedUnknown => '-- WPM';

  @override
  String get listenLevel => 'Sinal';

  @override
  String get listenToneOn => 'Tom';

  @override
  String get listenTone => 'Frequência do tom';

  @override
  String get listenToneLocked => 'Sintonizada';

  @override
  String get listenToneSearching => 'Buscando';

  @override
  String get listenToneManual => 'Manual';

  @override
  String get listenAutoTune => 'Sintonia automática';

  @override
  String get listenAutoTuneHelp => 'Acompanha o tom mais forte entre 400 e 1000 Hz. Arraste o controle para sintonizar manualmente.';

  @override
  String get listenRetune => 'Automático';

  @override
  String get listenBlockSize => 'Bloco de análise';

  @override
  String get listenBlockSizeHelp => 'Blocos menores localizam os limites dos elementos com mais precisão, mas captam mais ruído. 256 amostras (5,3 ms) são adequadas para 5–40 WPM.';

  @override
  String get listenMinElement => 'Elemento mais curto';

  @override
  String get listenMinElementHelp => 'Tons e intervalos mais curtos são ignorados como estalos e falhas de sinal.';

  @override
  String get listenPermissionDenied => 'O acesso ao microfone foi negado. Permita-o nas configurações do sistema e tente novamente.';

  @override
  String get listenPermissionRetry => 'Tentar novamente';

  @override
  String get listenStartFailed => 'Não foi possível iniciar o microfone.';

  @override
  String get listenNoInput => 'Nenhum microfone foi encontrado. Conecte um e tente novamente.';

  @override
  String get listenStreamFailed => 'O microfone parou inesperadamente. Tente novamente.';

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
    return '$samples amostras ($ms ms)';
  }

  @override
  String listenMsValue(int ms) {
    return '$ms ms';
  }

  @override
  String get listenStoppedInBackground => 'A escuta parou enquanto o aplicativo estava em segundo plano.';

  @override
  String get learnWpmUnknown => '-- WPM';

  @override
  String get learnTipDitTooLongTitle => 'Pontos longos demais';

  @override
  String get learnTipDahTooShortTitle => 'Traços curtos demais';

  @override
  String get learnTipIntraGapTooLongTitle => 'Elementos muito espaçados';

  @override
  String get learnTipCharGapTooShortTitle => 'Caracteres muito próximos';

  @override
  String get learnTipWordGapTooShortTitle => 'Palavras muito próximas';

  @override
  String get learnTipSpeedUnsteadyTitle => 'Velocidade irregular';

  @override
  String get learnSeverityMinor => 'leve';

  @override
  String get learnSeverityModerate => 'perceptível';

  @override
  String get learnSeveritySevere => 'grave';

  @override
  String learnNewestCharIs(String char) {
    return 'Novo nesta lição: $char';
  }

  @override
  String learnCharNewSemantics(String char) {
    return '$char, novo';
  }

  @override
  String learnPendingPattern(String pattern) {
    return 'Transmitindo: $pattern';
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
    return 'Seus pontos estão longos (cerca de $ratio de um ponto). Pense em «di», não «daah»: um ponto é um toque, não uma pressão prolongada.';
  }

  @override
  String learnTipDahTooShort(String ratio) {
    return 'Seus traços estão curtos (cerca de $ratio de um ponto; a meta é 3). Segure o traço pelo tempo de três pontos.';
  }

  @override
  String learnTipIntraGapTooLong(String ratio) {
    return 'Os intervalos dentro dos caracteres estão longos (cerca de $ratio de um ponto). Mantenha os elementos de cada caractere próximos.';
  }

  @override
  String learnTipCharGapTooShort(String ratio) {
    return 'Os caracteres se misturam (intervalos de cerca de $ratio de um ponto; a meta é 3). Deixe uma pausa clara após cada caractere.';
  }

  @override
  String learnTipWordGapTooShort(String ratio) {
    return 'As palavras estão próximas demais (intervalos de cerca de $ratio de um ponto; a meta é 7). Conte uma pausa longa entre as palavras.';
  }

  @override
  String learnTipSpeedUnsteady(int percent) {
    return 'Sua velocidade varia (variação de $percent%). Escolha um ritmo e mantenha-o durante toda a linha.';
  }

  @override
  String learnIssueDetailDitTooLong(int offending, int total, String ratio) {
    return '$offending de $total pontos longos demais (média: $ratio pontos)';
  }

  @override
  String learnIssueDetailDahTooShort(int offending, int total, String ratio) {
    return '$offending de $total traços curtos demais (média: $ratio pontos)';
  }

  @override
  String learnIssueDetailIntraGapTooLong(int offending, int total, String ratio) {
    return '$offending de $total intervalos dentro dos caracteres longos demais (média: $ratio pontos)';
  }

  @override
  String learnIssueDetailCharGapTooShort(int offending, int total, String ratio) {
    return '$offending de $total intervalos entre caracteres curtos demais (média: $ratio pontos)';
  }

  @override
  String learnIssueDetailWordGapTooShort(int offending, int total, String ratio) {
    return '$offending de $total intervalos entre palavras curtos demais (média: $ratio pontos)';
  }

  @override
  String learnIssueDetailSpeedUnsteady(String cv) {
    return 'Velocidade de transmissão irregular (coef. de variação: $cv)';
  }

  @override
  String statsAccuracyDetail(String allTime) {
    return 'Últimos 7 dias / total: $allTime';
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
  String get desktopTraySoundOn => 'Som ligado';

  @override
  String get desktopTraySoundOff => 'Som desligado';

  @override
  String desktopTrayQuit(String app) {
    return 'Sair do $app';
  }

  @override
  String get listenStateOn => 'Ligado';

  @override
  String get listenStateOff => 'Desligado';

  @override
  String referenceTelegraphCodes(String codes) {
    return 'Código telegráfico chinês: $codes';
  }

  @override
  String get referenceTelegraphMainland => 'China continental 1983';

  @override
  String get referenceTelegraphTaiwan => 'Taiwan / Hong Kong';

  @override
  String get referenceTelegraphNone => 'Não consta neste código';

  @override
  String get appearanceTitle => 'Aparência';

  @override
  String get appearanceStyles => 'Estilo da interface';

  @override
  String get appearanceChoose => 'Escolha um estilo, veja a prévia e aplique';

  @override
  String get appearanceMode => 'Luminosidade';

  @override
  String get appearancePreview => 'Prévia';

  @override
  String get appearanceApply => 'Aplicar estilo';

  @override
  String get appearanceRestore => 'Restaurar padrões';

  @override
  String get appearanceApplied => 'Aparência salva';

  @override
  String get appearanceSaveFailed => 'Não foi possível salvar a aparência. Tente novamente.';

  @override
  String get appearanceClassic => 'Latão clássico';

  @override
  String get appearanceModern => 'Calma moderna';

  @override
  String get appearanceRadio => 'Rádio noturno';

  @override
  String get appearancePaper => 'Manual de papel';

  @override
  String get appearanceCartoon => 'Desenho leve';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Escuro';

  @override
  String learnShowAllChars(int count) {
    return 'Mostrar todos os $count caracteres';
  }

  @override
  String get learnShowFewerChars => 'Mostrar menos caracteres';

  @override
  String get learnLeaveDrillTitle => 'Sair desta sessão?';

  @override
  String get learnLeaveDrillBody => 'As rodadas desta sessão não serão salvas.';

  @override
  String get learnLeaveDrillConfirm => 'Sair';

  @override
  String get learnReplayAssistedNote => 'Repetido: esta sessão conta como prática, mas não desbloqueia lições nem atualiza revisões.';

  @override
  String get learnPlanTitle => 'Plano de hoje';

  @override
  String learnPlanSummary(int minutes, int done, int total) {
    return 'Cerca de $minutes min · $done de $total passos';
  }

  @override
  String get learnPlanBudget => 'Duração do plano';

  @override
  String learnPlanBudgetMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learnPlanStart => 'Começar o plano';

  @override
  String get learnPlanContinue => 'Continuar o plano';

  @override
  String get learnPlanStepReview => 'Revisar símbolos pendentes';

  @override
  String get learnPlanStepFocus => 'Prática focada';

  @override
  String learnPlanStepCourse(int lesson) {
    return 'Lição $lesson';
  }

  @override
  String get learnPlanStepSend => 'Prática de transmissão';

  @override
  String learnPlanReasonDueReview(String symbols) {
    return 'Para revisar: $symbols';
  }

  @override
  String learnPlanReasonConfusions(String symbols) {
    return 'Confundidos com frequência: $symbols';
  }

  @override
  String learnPlanReasonWeak(String symbols) {
    return 'Abaixo de 90%: $symbols';
  }

  @override
  String learnPlanReasonChallenge(int count) {
    return '$count símbolos: pode desbloquear a próxima lição';
  }

  @override
  String learnPlanReasonExtended(int count) {
    return 'Ampliado para $count símbolos para poder desbloquear a próxima lição';
  }

  @override
  String get learnPlanReasonConsolidate => 'Sessão curta: consolida a lição, não desbloqueia a próxima';

  @override
  String learnPlanReasonOutdated(int lesson) {
    return 'Seu curso avançou: pratica a lição $lesson sem desbloquear';
  }

  @override
  String learnPlanReasonSend(int count) {
    return '$count alvos curtos para transmitir';
  }

  @override
  String learnPlanStepDonePercent(int percent) {
    return 'Concluído · $percent%';
  }

  @override
  String get learnPlanStepDone => 'Concluído';

  @override
  String learnPlanSendProgress(int done, int total) {
    return '$done de $total enviados';
  }

  @override
  String get learnPlanStale => 'Sua lição ou velocidade mudou. Atualizar os passos não iniciados?';

  @override
  String get learnPlanUpdate => 'Atualizar passos';

  @override
  String get learnPlanComplete => 'Plano de hoje concluído';

  @override
  String learnPlanNeedsWork(String symbols) {
    return 'Precisa de prática: $symbols';
  }

  @override
  String get learnPlanAllGood => 'Nenhum símbolo fraco hoje.';

  @override
  String get learnPlanTomorrow => 'Amanhã chega um plano novo. A prática livre está sempre aberta.';

  @override
  String learnPlanEarlier(int done, int total) {
    return 'O plano anterior parou em $done de $total passos; não conta para hoje.';
  }

  @override
  String learnSpeedAdviceRaise(int wpm) {
    return 'Pronto para $wpm PPM de velocidade efetiva';
  }

  @override
  String learnSpeedAdviceRaiseBoth(int wpm) {
    return 'Pronto para $wpm PPM';
  }

  @override
  String learnSpeedAdviceLower(int wpm) {
    return 'Copiar nesta velocidade está difícil. Tente $wpm PPM efetivas ou uma prática focada.';
  }

  @override
  String learnSpeedAdviceBody(int count, int percent) {
    return 'Com base nas suas últimas $count sessões sem ajuda ($percent%). Nada muda até você aplicar.';
  }

  @override
  String get learnSpeedAdviceApply => 'Aplicar';

  @override
  String get learnSpeedAdviceDismiss => 'Agora não';

  @override
  String get learnSpeedAdviceInsufficient => 'A sugestão de velocidade precisa de 3 sessões sem ajuda de 50+ símbolos na velocidade atual.';

  @override
  String get learnQsoAction => 'Simulador de QSO';

  @override
  String learnQsoLocked(int lesson) {
    return 'A partir da lição $lesson';
  }

  @override
  String get learnQsoTitle => 'Simulador de QSO';

  @override
  String get learnQsoRespond => 'Responder a um CQ';

  @override
  String get learnQsoRespondHint => 'Uma estação chama CQ. Responda e troquem reportagens.';

  @override
  String get learnQsoCall => 'Chamar CQ';

  @override
  String get learnQsoCallHint => 'Você chama CQ e uma estação responde.';

  @override
  String get learnQsoYourCall => 'Seu indicativo';

  @override
  String get learnQsoYourName => 'Seu nome';

  @override
  String get learnQsoYourQth => 'Seu QTH';

  @override
  String get learnQsoInvalidCall => 'Digite um indicativo como BD1XYZ';

  @override
  String get learnQsoInvalidWord => 'Uma palavra, apenas letras A–Z';

  @override
  String get learnQsoOffline => 'Funciona inteiramente neste dispositivo. Nada é enviado.';

  @override
  String get learnQsoStart => 'Iniciar QSO';

  @override
  String get learnQsoResume => 'Retomar o QSO inacabado';

  @override
  String get learnQsoStageCallCq => 'Chame CQ com seu indicativo';

  @override
  String get learnQsoStageCallConfirm => 'Responda: indicativo dele, DE, o seu';

  @override
  String get learnQsoStageExchange => 'Envie reportagem, nome e QTH';

  @override
  String get learnQsoStageConfirmInfo => 'Confirme as informações dele';

  @override
  String get learnQsoStageClosing => 'Encerre com 73 e <SK>';

  @override
  String get learnQsoStageDone => 'QSO concluído';

  @override
  String learnQsoSpeed(int wpm) {
    return 'O correspondente transmite a $wpm PPM efetivas';
  }

  @override
  String learnQsoRemote(String call) {
    return '$call transmite';
  }

  @override
  String get learnQsoRemoteHidden => 'Copie de ouvido: o texto está oculto.';

  @override
  String get learnQsoShowText => 'Mostrar texto';

  @override
  String get learnQsoListen => 'Ouvir';

  @override
  String get learnQsoAccepted => 'Aceito';

  @override
  String get learnQsoRejected => 'Não aceito';

  @override
  String get learnQsoRemoteSending => 'A outra estação está transmitindo…';

  @override
  String get learnQsoYourTurn => 'Sua vez: transmita a resposta e toque em Enviar.';

  @override
  String get learnQsoDecoded => 'Sua transmissão';

  @override
  String get learnQsoNothingKeyed => 'Nada transmitido ainda';

  @override
  String get learnQsoPlayAgain => 'Pedir repetição (AGN)';

  @override
  String get learnQsoSlower => 'Pedir mais devagar (QRS)';

  @override
  String get learnQsoHint => 'Dica';

  @override
  String learnQsoHintLabel(String example) {
    return 'Exemplo: $example';
  }

  @override
  String get learnQsoPause => 'Pausar';

  @override
  String get learnQsoSend => 'Enviar';

  @override
  String get learnQsoClear => 'Limpar';

  @override
  String get learnQsoIssueEmpty => 'Nada foi transmitido.';

  @override
  String get learnQsoIssueMissingCq => 'Comece com CQ.';

  @override
  String get learnQsoIssueMissingDe => 'Coloque DE entre os indicativos.';

  @override
  String get learnQsoIssueWrongLocalCall => 'Seu indicativo está ausente ou errado.';

  @override
  String get learnQsoIssueWrongRemoteCall => 'O indicativo da outra estação está errado.';

  @override
  String get learnQsoIssueReversedCalls => 'Indicativos invertidos: primeiro o dele, depois DE e o seu.';

  @override
  String get learnQsoIssueMissingEnding => 'Termine com K ou KN.';

  @override
  String get learnQsoIssueMissingRst => 'Dê uma reportagem, ex.: UR RST 599.';

  @override
  String get learnQsoIssueInvalidRst => 'Esse RST está fora do intervalo (R 1–5, S 1–9, T 1–9).';

  @override
  String get learnQsoIssueMissingName => 'Envie NAME e seu nome.';

  @override
  String get learnQsoIssueWrongName => 'Esse não é seu nome neste QSO.';

  @override
  String get learnQsoIssueMissingQth => 'Envie QTH e sua localização.';

  @override
  String get learnQsoIssueWrongQth => 'Esse não é seu QTH neste QSO.';

  @override
  String get learnQsoIssueMissingAck => 'Confirme com R ou QSL.';

  @override
  String get learnQsoIssueWrongRemoteName => 'Confirme o nome do outro operador.';

  @override
  String get learnQsoIssueMissing73 => 'Inclua 73.';

  @override
  String get learnQsoIssueMissingSk => 'Encerre o contato com <SK>.';

  @override
  String learnQsoSummaryFields(int count, int total) {
    return 'Certo de primeira: $count de $total passos';
  }

  @override
  String learnQsoSummaryRepeats(int count) {
    return 'Repetições: $count';
  }

  @override
  String learnQsoSummaryHints(int count) {
    return 'Dicas: $count';
  }

  @override
  String learnQsoSummaryRhythm(int wpm) {
    return 'Sua transmissão: cerca de $wpm PPM';
  }

  @override
  String get learnQsoSummaryNote => 'Os resultados de QSO ficam separados da precisão de cópia e nunca desbloqueiam lições.';

  @override
  String get learnTipDahTooLongTitle => 'Traços longos demais';

  @override
  String learnTipDahTooLong(String ratio) {
    return 'Seus traços estão longos (cerca de $ratio de um ponto; meta 3). Solte ao completar três pontos.';
  }

  @override
  String learnIssueDetailDahTooLong(int offending, int total, String ratio) {
    return '$offending de $total traços longos demais (média $ratio ponto)';
  }

  @override
  String get learnRhythmTitle => 'Ritmo';

  @override
  String get learnRhythmMine => 'Meu ritmo';

  @override
  String get learnRhythmStandard => 'Ritmo padrão (velocidade alvo)';

  @override
  String learnRhythmNormalizedNote(int ms) {
    return 'Os problemas são julgados pelo seu próprio ponto ($ms ms); regular mas lento está ok. A faixa padrão é a velocidade alvo.';
  }

  @override
  String get learnRhythmNotLocated => 'Não foi possível associar suas marcas a símbolos. Pratique o alvo inteiro.';

  @override
  String get learnRhythmPlayMine => 'Tocar o meu';

  @override
  String get learnRhythmPlayStandard => 'Tocar padrão';

  @override
  String learnRhythmPracticePart(int count) {
    return 'Praticar isto ($count tentativas)';
  }

  @override
  String get learnRhythmPracticeWhole => 'Praticar o alvo inteiro';

  @override
  String get learnRhythmSymbolOk => 'Bom';

  @override
  String get learnRhythmZoomIn => 'Ampliar';

  @override
  String get learnRhythmZoomOut => 'Reduzir';

  @override
  String get workbenchTitle => 'Bancada de gravações';

  @override
  String get workbenchOpen => 'Gravações';

  @override
  String get workbenchImport => 'Importar gravação';

  @override
  String get workbenchEmpty => 'Importe uma gravação WAV para repetir, decodificar e copiar. Não precisa de microfone.';

  @override
  String get workbenchFormats => 'WAV, PCM de 16 bits, mono ou estéreo, 8/16/44,1/48 kHz; até 50 MB e 20 minutos.';

  @override
  String get workbenchBackupNote => 'As gravações ficam neste dispositivo. Guarde cópias antes de apagar dados ou desinstalar. As seleções mantêm títulos, notas e posições.';

  @override
  String workbenchInfo(String rate, String channels, String duration) {
    return '$rate kHz · $channels · $duration';
  }

  @override
  String get workbenchMono => 'mono';

  @override
  String get workbenchStereo => 'estéreo';

  @override
  String get workbenchErrorNotWav => 'Este não é um arquivo WAV.';

  @override
  String get workbenchErrorFormat => 'Por enquanto só WAV PCM de 16 bits é suportado (sem MP3, AAC ou WAV float).';

  @override
  String get workbenchErrorChannels => 'Só gravações mono ou estéreo são suportadas.';

  @override
  String get workbenchErrorRate => 'Taxa de amostragem não suportada. Use 8, 16, 44,1 ou 48 kHz.';

  @override
  String get workbenchErrorDamaged => 'O arquivo está danificado ou incompleto.';

  @override
  String get workbenchErrorTooLarge => 'O arquivo tem mais de 50 MB.';

  @override
  String get workbenchErrorTooLong => 'A gravação tem mais de 20 minutos.';

  @override
  String get workbenchErrorIo => 'Não foi possível ler o arquivo.';

  @override
  String get workbenchErrorMissing => 'O arquivo da gravação está faltando.';

  @override
  String get workbenchStart => 'Início (s)';

  @override
  String get workbenchEnd => 'Fim (s)';

  @override
  String get workbenchSelectAll => 'Selecionar tudo';

  @override
  String get workbenchPlay => 'Tocar seleção';

  @override
  String get workbenchStop => 'Parar';

  @override
  String get workbenchLoop => 'Repetir';

  @override
  String get workbenchPlayLimit => 'Só os primeiros 5 minutos de uma seleção maior são tocados.';

  @override
  String get workbenchAutoTune => 'Encontrar o tom automaticamente';

  @override
  String workbenchManualTone(int hz) {
    return 'Tom: $hz Hz';
  }

  @override
  String get workbenchDecode => 'Decodificar seleção';

  @override
  String get workbenchCancel => 'Cancelar';

  @override
  String workbenchDecoding(int percent) {
    return 'Decodificando… $percent%';
  }

  @override
  String workbenchResultStats(int hz, int wpm) {
    return 'Tom $hz Hz · cerca de $wpm PPM';
  }

  @override
  String get workbenchToneNotLocked => 'Nenhum tom estável; tente o ajuste manual.';

  @override
  String get workbenchNoText => 'Nada decodificado nesta seleção.';

  @override
  String workbenchUnknown(String patterns) {
    return 'Padrões desconhecidos: $patterns';
  }

  @override
  String get workbenchEdgeCut => 'Um símbolo na borda da seleção está cortado e pode estar errado.';

  @override
  String get workbenchToneNote => 'Travar o tom não é uma medida de confiança; confira o texto de ouvido.';

  @override
  String get workbenchModeDecoder => 'Decodificador';

  @override
  String get workbenchModeCopy => 'Copiar eu mesmo';

  @override
  String get workbenchDecoderHidden => 'O texto do decodificador fica oculto enquanto você copia.';

  @override
  String get workbenchShowDecoder => 'Mostrar texto do decodificador';

  @override
  String get workbenchReference => 'Texto de referência (opcional)';

  @override
  String get workbenchReferenceHelp => 'Cole o texto enviado; caso contrário, sua cópia é comparada com a saída do decodificador.';

  @override
  String get workbenchAgainstDecoder => 'Comparado com a saída do decodificador, que também pode estar errada.';

  @override
  String get workbenchSave => 'Salvar seleção';

  @override
  String get workbenchSaveTitle => 'Título';

  @override
  String get workbenchSaveNote => 'Nota';

  @override
  String get workbenchSaved => 'Seleção salva';

  @override
  String get workbenchSaveFailed => 'Não foi possível salvar a seleção.';

  @override
  String get workbenchLibrary => 'Seleções salvas';

  @override
  String get workbenchLibraryEmpty => 'Nenhuma seleção salva ainda.';

  @override
  String get workbenchMissing => 'Arquivo faltando — escolha-o de novo ou exclua a entrada.';

  @override
  String get workbenchRelink => 'Escolher o arquivo de novo';

  @override
  String get workbenchDelete => 'Excluir';

  @override
  String get materialsTitle => 'Meus materiais';

  @override
  String get materialsNew => 'Novo material';

  @override
  String get materialsEdit => 'Editar';

  @override
  String get materialsSave => 'Salvar';

  @override
  String get materialsSaveFailed => 'Não foi possível salvar o material.';

  @override
  String get materialsTitleField => 'Título';

  @override
  String get materialsTagsField => 'Tags (separadas por vírgulas)';

  @override
  String get materialsTextField => 'Texto';

  @override
  String get materialsListField => 'Uma entrada por linha';

  @override
  String get materialsKindText => 'Texto';

  @override
  String get materialsKindWords => 'Lista de palavras';

  @override
  String get materialsKindCallsigns => 'Indicativos';

  @override
  String get materialsPreview => 'Prévia';

  @override
  String materialsPreviewCounts(int items, int symbols, int prosigns) {
    return '$items itens · $symbols símbolos · $prosigns prossinais';
  }

  @override
  String materialsPreviewUnsupported(String chars) {
    return 'Sem código Morse, omitidos na prática: $chars';
  }

  @override
  String materialsPreviewDuplicates(int count) {
    return '$count entradas duplicadas são mantidas uma vez';
  }

  @override
  String get materialsProblemEmpty => 'Digite algum texto primeiro.';

  @override
  String get materialsProblemTooLarge => 'Grande demais: o limite é 1 MiB.';

  @override
  String materialsProblemTooManyEntries(int count) {
    return 'Entradas demais: no máximo $count.';
  }

  @override
  String materialsProblemEntryTooLong(int count) {
    return 'Uma entrada é longa demais: no máximo $count símbolos.';
  }

  @override
  String get materialsProblemNothingTrainable => 'Nada aqui pode ser praticado em Morse.';

  @override
  String get materialsSearch => 'Pesquisar materiais';

  @override
  String get materialsFavoritesOnly => 'Favoritos';

  @override
  String get materialsFavorite => 'Adicionar aos favoritos';

  @override
  String get materialsUnfavorite => 'Remover dos favoritos';

  @override
  String get materialsEmpty => 'Ainda não há materiais. Adicione textos, listas de palavras ou indicativos próprios.';

  @override
  String materialsItems(int count) {
    return '$count itens';
  }

  @override
  String get materialsActions => 'Ações';

  @override
  String get materialsPractise => 'Praticar';

  @override
  String get materialsDelete => 'Excluir';

  @override
  String get materialsDeleteTitle => 'Excluir material?';

  @override
  String materialsDeleteBody(String title) {
    return '“$title” será removido deste dispositivo. Seu histórico permanece.';
  }

  @override
  String get materialsImport => 'Importar TXT ou JSON';

  @override
  String get materialsImportDialogTitle => 'Escolha um arquivo';

  @override
  String get materialsSaveDialogTitle => 'Salvar material';

  @override
  String get materialsImportFailed => 'Falha na importação. Sua biblioteca não mudou.';

  @override
  String get materialsImportNotUtf8 => 'Somente arquivos de texto UTF-8 podem ser importados.';

  @override
  String get materialsImportInvalid => 'Não é um arquivo de materiais do MorseCQ válido. Nada foi importado.';

  @override
  String materialsImported(int count) {
    return '$count materiais importados.';
  }

  @override
  String get materialsDuplicateTitle => 'Alguns materiais já existem';

  @override
  String get materialsDuplicateOverwrite => 'Substituir';

  @override
  String get materialsDuplicateKeepCopy => 'Manter ambos (como cópia)';

  @override
  String get materialsDuplicateSkip => 'Ignorar';

  @override
  String get materialsExportJson => 'Exportar como JSON';

  @override
  String materialsExported(int count) {
    return '$count materiais exportados.';
  }

  @override
  String get materialsExportFailed => 'Falha na exportação.';

  @override
  String get materialsExportWav => 'Exportar áudio (WAV)';

  @override
  String materialsWavCharSpeed(int wpm) {
    return 'Velocidade dos caracteres: $wpm PPM';
  }

  @override
  String materialsWavEffSpeed(int wpm) {
    return 'Velocidade efetiva: $wpm PPM';
  }

  @override
  String materialsWavTone(int hz) {
    return 'Tom: $hz Hz';
  }

  @override
  String get materialsWavWithAnswer => 'Incluir o texto da resposta (.txt)';

  @override
  String get materialsWavFormat => 'WAV mono de 16 bits, 48 kHz.';

  @override
  String materialsWavParts(int count) {
    return 'Mais de 10 minutos: exportado em $count arquivos.';
  }

  @override
  String materialsWavExported(int count) {
    return '$count arquivos de áudio salvos.';
  }

  @override
  String get materialsPracticeMode => 'Praticar com';

  @override
  String get materialsPracticeLearned => 'Somente símbolos aprendidos';

  @override
  String materialsPracticeLearnedPartial(int count) {
    return 'Somente símbolos aprendidos ($count entradas indisponíveis: usam símbolos ainda não aprendidos)';
  }

  @override
  String get materialsPracticeAll => 'Todos os símbolos Morse';

  @override
  String get materialsPracticeNothing => 'Nenhuma entrada pode ser praticada neste modo.';

  @override
  String get guestClearConfirm => 'Apagar';

  @override
  String get placementTitle => 'Verificar meu nível';

  @override
  String get placementCheckLevel => 'Verificar meu nível atual';

  @override
  String get placementFromZero => 'Saltar a introdução: desafio da lição 1';

  @override
  String get placementOfferTitle => 'Novo no Morse ou já copia?';

  @override
  String get placementOfferBody => 'Um teste curto pode sugerir por onde começar. É opcional e nada muda até você escolher.';

  @override
  String get placementIntro => 'Cerca de 3–5 minutos de cópia em cinco etapas: símbolos Koch em grupos com velocidade crescente e depois palavras curtas. É uma referência aproximada com poucas amostras, não um certificado. Pare quando quiser.';

  @override
  String get placementStart => 'Começar';

  @override
  String get placementSkip => 'Pular';

  @override
  String get placementStop => 'Parar';

  @override
  String placementTierProgress(int step, int total, int wpm) {
    return 'Etapa $step de $total · $wpm PPM efetivas';
  }

  @override
  String get placementTierPassed => 'Bem copiado. A próxima etapa é mais rápida.';

  @override
  String get placementTierStopped => 'Essa etapa ficou abaixo de 90%, o teste termina aqui.';

  @override
  String get placementNextTier => 'Próxima etapa';

  @override
  String placementSuggestion(int lesson) {
    return 'Início sugerido: lição $lesson';
  }

  @override
  String placementVerified(int count, int total) {
    return '$count de $total símbolos Koch confirmados em ordem.';
  }

  @override
  String get placementLimits => 'Baseado em uma amostra curta: símbolos não testados continuam não testados e nada é marcado como aprendido. Você pode mudar a lição quando quiser.';

  @override
  String placementAdopt(int lesson) {
    return 'Começar na lição $lesson';
  }

  @override
  String materialsImportConfirm(int count) {
    return 'Importar $count materiais?';
  }

  @override
  String get materialsExportTxt => 'Exportar como texto (TXT)';

  @override
  String get conditionsTitle => 'Condições';

  @override
  String get conditionsClear => 'Limpo';

  @override
  String get conditionsLight => 'Interferência leve';

  @override
  String get conditionsRadio => 'Prática de rádio';

  @override
  String get conditionsClearHint => 'Um tom limpo e estável: prática normal.';

  @override
  String get conditionsLightHint => 'Ruído de fundo suave e desvanecimento leve. Os resultados ficam separados da prática limpa.';

  @override
  String get conditionsRadioHint => 'Ruído, desvanecimento forte, uma estação vizinha e ritmo um pouco irregular. Os resultados ficam separados da prática limpa.';

  @override
  String get conditionsPreview => 'Ouvir';

  @override
  String conditionsActive(String name) {
    return 'Condições: $name';
  }

  @override
  String get conditionsNeedSound => 'Condições de rádio se ouvem, não se veem: ative o som nos ajustes de treino ou pratique com condições limpas.';

  @override
  String get conditionsCleanReplay => 'Tocar sem efeitos';

  @override
  String conditionsComparable(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativas nestas condições e velocidade: média de $accuracy%',
      one: '1 tentativa nestas condições e velocidade: $accuracy%',
    );
    return '$_temp0';
  }

  @override
  String get conditionsSeparateNote => 'A prática com condições de rádio conta como atividade, mas não muda suas lições, revisões nem a recomendação de velocidade.';

  @override
  String get keysTitle => 'Teclas e manipuladores externos';

  @override
  String get keysMeSubtitle => 'Atribuição de teclas, paletas e adaptadores USB';

  @override
  String get keysIntro => 'Escolha quais teclas manipulam Morse. Adaptadores USB de manipulador e paletas que emulam teclado funcionam como um: defina as teclas aqui. O app não sabe qual dispositivo enviou uma tecla, então um perfil é um conjunto de atribuições.';

  @override
  String get keysStandardProfile => 'Padrão';

  @override
  String get keysUnnamed => 'Perfil sem nome';

  @override
  String get keysEdit => 'Editar';

  @override
  String get keysNewProfile => 'Novo perfil';

  @override
  String get keysLimitations => 'Manipuladores MIDI, seriais e Bluetooth, ajustes de firmware de adaptadores e controle de transmissor não são suportados. Os adaptadores testados estão na documentação.';

  @override
  String get keysEditTitle => 'Perfil de teclas';

  @override
  String get keysName => 'Nome do perfil';

  @override
  String get keysActionStraight => 'Manipulador vertical';

  @override
  String get keysActionDit => 'Paleta de ponto';

  @override
  String get keysActionDah => 'Paleta de traço';

  @override
  String get keysPressKey => 'Pressione uma tecla…';

  @override
  String get keysNone => 'Não definido';

  @override
  String get keysSet => 'Definir';

  @override
  String keysReserved(String key) {
    return '$key é reservada pelo sistema ou pelo app; escolha outra tecla.';
  }

  @override
  String keysConflict(String key, String action) {
    return '$key já é usada para $action.';
  }

  @override
  String keysConflictSave(String keys) {
    return 'Cada tecla só pode fazer uma coisa: $keys está atribuída duas vezes.';
  }

  @override
  String get keysMissing => 'Defina as teclas que este modo precisa (as duas paletas no iâmbico).';

  @override
  String get keysSwapPaddles => 'Inverter paletas (canhoto)';

  @override
  String get keysKeyerMode => 'Modo do manipulador';

  @override
  String get keysIambicA => 'Iâmbico A';

  @override
  String get keysIambicB => 'Iâmbico B';

  @override
  String get keysAdapterKeyer => 'O adaptador gera os próprios elementos';

  @override
  String get keysAdapterKeyerHint => 'Para adaptador com manipulador próprio: suas pressões temporizadas são usadas como estão, sem um segundo manipulador iâmbico no app.';

  @override
  String get keysAppSidetone => 'Tom local do app ao manipular';

  @override
  String get keysAppSidetoneHint => 'Desligue quando o adaptador gerar o próprio tom. A decodificação não é afetada.';

  @override
  String get keysTestTitle => 'Teste';

  @override
  String get keysTestNote => 'Só teste: nada é enviado nem somado ao seu treino.';

  @override
  String get keysTestRelease => 'Soltar teclas';

  @override
  String get keysAdapterActive => 'O manipulador do adaptador é usado: as teclas de paleta agem como manipulador vertical.';

  @override
  String keysHintCustom(String keys) {
    return 'Teclas: $keys';
  }

  @override
  String get telegraphTitle => 'Código telegráfico chinês';

  @override
  String get telegraphIntro => 'Cada caractere chinês é enviado como um código de quatro dígitos. Pratique ouvir os dígitos e, separadamente, lembrar qual código corresponde a cada caractere.';

  @override
  String get telegraphCodebook => 'Livro de códigos';

  @override
  String get telegraphCodebookMainland => 'China continental';

  @override
  String get telegraphCodebookTaiwan => 'Taiwan';

  @override
  String get telegraphDigitsTitle => 'Copiar grupos de código';

  @override
  String get telegraphDigitsHint => 'Ouça grupos de quatro dígitos de códigos reais e digite os dígitos.';

  @override
  String telegraphDigitsResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões: $accuracy% dos dígitos',
      one: '1 sessão: $accuracy% dos dígitos',
    );
    return '$_temp0';
  }

  @override
  String get telegraphRecallTitle => 'Lembrar códigos';

  @override
  String get telegraphRecallHint => 'De caractere para código e de código para caractere. Separado do progresso em Morse.';

  @override
  String telegraphRecallResults(int count, int accuracy) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões respondidos: $accuracy% sabido',
      one: '1 cartão respondido: $accuracy% sabido',
    );
    return '$_temp0';
  }

  @override
  String get telegraphSeparateNote => 'Lembrar códigos nunca desbloqueia lições de Morse nem muda a recomendação de velocidade; copiar dígitos conta como qualquer cópia em Morse.';

  @override
  String get telegraphRecallCharPrompt => 'Digite o código deste caractere';

  @override
  String get telegraphRecallCodePrompt => 'Escolha o caractere deste código';

  @override
  String get telegraphReveal => 'Ver resposta';

  @override
  String get telegraphRevealAssisted => 'Mostrada: este cartão conta como assistido.';

  @override
  String get telegraphCorrect => 'Correto';

  @override
  String get telegraphIncorrect => 'Não exatamente';

  @override
  String telegraphRecallSummary(int correct, int total) {
    return '$correct de $total sabidas';
  }

  @override
  String telegraphRecallAssisted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões com a resposta mostrada',
      one: '1 cartão com a resposta mostrada',
    );
    return '$_temp0';
  }

  @override
  String get telegraphInterpretTitle => 'Interpretação do código telegráfico';

  @override
  String get telegraphInterpretNote => 'Só exibido aqui: a mensagem não muda e nada é enviado.';

  @override
  String get telegraphUnresolved => 'Não resolvido: nenhum caractere tem este código';

  @override
  String get telegraphMalformed => 'Não é um grupo de quatro dígitos';

  @override
  String get telegraphNotCode => 'Texto, mantido como está';

  @override
  String get telegraphAmbiguous => 'Vários caracteres compartilham este código';

  @override
  String get conditionsAudioFailed => 'Não foi possível iniciar o áudio neste dispositivo. Pratique com condições limpas.';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidade';

  @override
  String get aboutTermsOfUse => 'Termos de uso';

  @override
  String get aboutSupport => 'Suporte e contato';

  @override
  String get aboutLinkFailed => 'Não foi possível abrir o link, então ele foi copiado.';

  @override
  String get offlineClearData => 'Apagar os dados de aprendizagem';

  @override
  String get offlineClearDataBody => 'Apaga o seu progresso, planos e materiais neste dispositivo.';

  @override
  String get offlineCleared => 'Dados de aprendizagem apagados.';

  @override
  String get offlineClearFailed => 'Não foi possível apagar os dados de aprendizagem.';

  @override
  String get learnStorageUnavailable => 'Não foi possível abrir os seus dados de treino neste dispositivo. Tente de novo.';

  @override
  String get materialsImportedSource => 'Origem importada';

  @override
  String get learnStartHereTitle => 'Novo por aqui? Comece com uma primeira lição de 3 minutos';

  @override
  String get learnStartHereBody => 'Ouça os sons, aprenda K e M e responda a algumas rondas fáceis. Nada é avaliado.';

  @override
  String get learnStartHere => 'Começar aqui';

  @override
  String get learnReplayFirstLesson => 'Repetir a primeira lição';

  @override
  String learnCharsIntroducedMastered(int introduced, int mastered) {
    return '$introduced apresentados · $mastered dominados';
  }

  @override
  String get learnChipNew => 'Novo';

  @override
  String get learnChipPractising => 'Em prática';

  @override
  String get learnChipMastered => 'Dominado';

  @override
  String get learnChipWeak => 'Abaixo de 90%';

  @override
  String get learnChipDue => 'Para rever';

  @override
  String get learnTapChipHint => 'Toque num carácter para o ouvir';

  @override
  String learnHearChar(String char) {
    return 'Ouvir $char';
  }

  @override
  String learnCompareWith(String a, String b) {
    return '$a vs $b';
  }

  @override
  String get learnGuidedPractice => 'Prática curta (10 símbolos)';

  @override
  String learnChallengeHint(int count, int min) {
    return 'O desafio da lição: $count símbolos a 90%, com cada símbolo novo copiado pelo menos $min vezes. Passar desbloqueia o carácter seguinte.';
  }

  @override
  String get learnAllUnlockedNotPassed => 'Todos os caracteres estão desbloqueados. Passe o desafio final para concluir o curso.';

  @override
  String get learnGoalFirstUse => 'Agora: distinguir K de M de ouvido. A seguir: o desafio da lição 1.';

  @override
  String learnGoalRecognition(String chars, int min, int lesson) {
    return 'Agora: reconhecer $chars com segurança ($min cópias a 90%). A seguir: o desafio da lição $lesson.';
  }

  @override
  String learnGoalCopying(int lesson, String next) {
    return 'Agora: passar o desafio da lição $lesson. A seguir: $next.';
  }

  @override
  String learnGoalNextChar(String char) {
    return 'o carácter $char';
  }

  @override
  String get learnGoalNextOperating => 'palavras, indicativos e um QSO completo';

  @override
  String get learnGoalOperating => 'Agora: mensagens reais — palavras, indicativos, QSO. A seguir: subir a velocidade efetiva um passo de cada vez.';

  @override
  String get learnMorePractice => 'Mais prática';

  @override
  String get learnQsoReady => 'Pronto';

  @override
  String get learnQsoPractiseFirst => 'Pratique primeiro as linhas';

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
  String get learnGlossaryTitle => 'O que significam estas palavras?';

  @override
  String get glossaryKoch => 'Método Koch: os caracteres aprendem-se à velocidade real, dois no início e mais um por lição assim que copia 90% bem.';

  @override
  String get glossaryWpm => 'WPM: palavras por minuto, contadas com a palavra padrão PARIS. A velocidade de carácter é a rapidez com que cada carácter soa.';

  @override
  String get glossaryFarnsworth => 'Farnsworth: os caracteres continuam rápidos, mas as pausas entre eles alongam-se para lhe dar tempo de pensar. A velocidade efetiva conta essas pausas.';

  @override
  String get glossaryQso => 'QSO: um contacto entre duas estações. CQ = chamada geral, DE = de, K = câmbio.';

  @override
  String get glossaryRst => 'RST: um relatório de sinal — legibilidade, intensidade, tom. 599 significa perfeito. 73 significa cumprimentos.';

  @override
  String get learnVerdictNotCredited => 'Nada registado: nenhum símbolo respondido.';

  @override
  String get learnVerdictAssisted => 'Prática com ajuda';

  @override
  String get learnVerdictAssistedHint => 'Foram usadas repetições ou revelações, por isso esta tentativa conta apenas como prática: sem desbloqueio nem atualização de revisões. Tente a próxima sem repetir.';

  @override
  String get learnVerdictPractice => 'Prática registada';

  @override
  String get learnVerdictPracticeHint => 'A prática livre atualiza estatísticas e revisões, mas nunca avança o curso. Só o desafio da lição, a partir do início de Aprender, o faz.';

  @override
  String get learnVerdictCourseComplete => 'Desafio final passado: todo o curso de caracteres é seu.';

  @override
  String learnVerdictTooShort(int count, int min) {
    return 'Desafio incompleto: $count de $min símbolos';
  }

  @override
  String learnVerdictTooShortHint(int min) {
    return 'Um desafio tem pelo menos $min símbolos. Inicie a lição a partir do início de Aprender ou aumente o comprimento da sessão nas definições.';
  }

  @override
  String learnVerdictUncovered(String chars) {
    return 'Poucas cópias de $chars';
  }

  @override
  String learnVerdictUncoveredHint(int min) {
    return 'Um desafio precisa de pelo menos $min cópias de cada símbolo novo. Tente de novo: o desafio inclui-os de propósito.';
  }

  @override
  String learnVerdictNewSymbolWeak(String chars) {
    return 'Símbolo novo abaixo de 90%: $chars';
  }

  @override
  String get learnVerdictNewSymbolWeakHint => 'O resto esteve bem; o símbolo novo decide a lição. Ouça-o contra o vizinho e treine-o antes do próximo desafio.';

  @override
  String get learnVerdictBelowAccuracyHint => 'Abaixo de 90% no total. Um exercício curto com os símbolos fracos abaixo e volte a tentar o desafio.';

  @override
  String get learnDrillWeak => 'Treinar símbolos fracos';

  @override
  String get learnRetryChallenge => 'Repetir o desafio';

  @override
  String get learnTakeChallenge => 'Fazer o desafio da lição';

  @override
  String learnChallengeTitle(int lesson) {
    return 'Desafio da lição $lesson';
  }

  @override
  String get learnPracticeTitle => 'Prática';

  @override
  String get learnMeaningsTitle => 'Significados';

  @override
  String get firstLessonTitle => 'Primeira lição';

  @override
  String firstLessonStep(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String get firstLessonHearTitle => 'Consegue ouvir?';

  @override
  String get firstLessonHearBody => 'Toque em Reproduzir. Deve ouvir um padrão curto de bipes (ou ver um flash / sentir uma vibração, se ativos).';

  @override
  String get firstLessonHeard => 'Ouvi';

  @override
  String get firstLessonNotHeard => 'Não ouvi nada';

  @override
  String get firstLessonNoSoundTitle => 'Sem som?';

  @override
  String get firstLessonNoSoundBody => 'Suba o volume e verifique o interruptor de silêncio ou o Não incomodar. Também pode seguir um flash de ecrã ou uma vibração.';

  @override
  String get firstLessonUseFlash => 'Também piscar o ecrã';

  @override
  String get firstLessonUseVibration => 'Também vibrar';

  @override
  String get firstLessonPlay => 'Reproduzir';

  @override
  String get firstLessonSoundsTitle => 'Curto e longo';

  @override
  String get firstLessonSoundsBody => 'O morse tem dois sons: um dit curto e um dah três vezes mais longo. Um carácter é um padrão deles e um silêncio curto separa os caracteres. Toque em cada um para o ouvir.';

  @override
  String get firstLessonDit => 'dit';

  @override
  String get firstLessonDah => 'dah';

  @override
  String get firstLessonWorkedTitle => 'Um exemplo resolvido';

  @override
  String get firstLessonWorkedBody => 'Ouça primeiro; a resposta aparece depois do som. Ainda não precisa de responder.';

  @override
  String firstLessonWorkedReveal(String char) {
    return 'Foi $char';
  }

  @override
  String get firstLessonTrialsTitle => 'K ou M?';

  @override
  String get firstLessonTrialsBody => 'Ouça e toque no carácter que ouviu. Repita as vezes que quiser: isto não é um teste.';

  @override
  String firstLessonTrialRound(int round, int total) {
    return 'Ronda $round de $total';
  }

  @override
  String firstLessonTrialCorrect(String char) {
    return 'Sim, era $char';
  }

  @override
  String firstLessonTrialWrong(String char, String answer) {
    return 'Era $char, não $answer. Ouça-os lado a lado.';
  }

  @override
  String get firstLessonTooFast => 'Demasiado rápido? Use o ritmo de iniciante (pausas mais longas entre caracteres)';

  @override
  String get firstLessonNextTitle => 'E a seguir';

  @override
  String firstLessonNextBody(int correct, int total) {
    return '$correct / $total corretos nesta ronda. Escolha o próximo passo e continue ao seu ritmo.';
  }

  @override
  String get firstLessonNextGuided => 'Prática curta: 10 símbolos isolados';

  @override
  String get firstLessonNextSend => 'Experimentar transmitir';

  @override
  String get firstLessonSendGuide => 'Transmitir: segure brevemente para um dit, mais tempo para um dah. Com paddles, um lado faz dits e o outro dahs. Solte e faça uma pausa curta entre caracteres. Manipulador vertical ou iâmbico A / B muda-se depois; para já não importa.';

  @override
  String get firstLessonReplayAnytime => 'Pode repetir esta lição quando quiser a partir do início de Aprender.';

  @override
  String get firstLessonContinue => 'Continuar';

  @override
  String get firstLessonTrialNext => 'Próxima ronda';

  @override
  String get sendFirstUseTitle => 'Primeira vez a manipular?';

  @override
  String get sendFirstUseStraight => 'Segure brevemente para um dit, cerca de três vezes mais para um dah. Pausa curta entre caracteres, mais longa entre palavras.';

  @override
  String get sendFirstUsePaddles => 'Segure a palheta marcada como ponto para pontos e a marcada como traço para traços; o manipulador controla a duração. Pause entre caracteres e mais entre palavras.';

  @override
  String get sendFirstUseDismiss => 'Entendi';

  @override
  String get learnSpeedPresets => 'Ritmo';

  @override
  String get learnPresetBeginner => 'Iniciante 20 / 6';

  @override
  String get learnPresetStandard => 'Padrão 20 / 8';

  @override
  String get learnPresetHelp => 'Os caracteres soam a 20 WPM em ambos; o ritmo de iniciante deixa pausas mais longas entre eles (6 WPM efetivos).';

  @override
  String get learnPlanStepIntro => 'Primeira lição';

  @override
  String get learnPlanStepRecognition => 'Símbolos isolados';

  @override
  String get learnPlanReasonFirstLesson => 'Ouvir os sons e distinguir K de M (cerca de 3 minutos)';

  @override
  String learnPlanReasonRecognition(String symbols) {
    return 'Um símbolo de cada vez: $symbols';
  }

  @override
  String learnPlanReasonGuided(int count) {
    return 'Grupos mistos curtos de $count símbolos; o desafio de 50 símbolos vem depois';
  }

  @override
  String learnPlanReasonSendOptional(int count) {
    return 'Opcional: ouça o modelo e depois manipule $count alvos curtos';
  }

  @override
  String get learnQsoReadyTitle => 'Pronto para um QSO';

  @override
  String get learnQsoNotReadyTitle => 'Ainda não aprendeu todos os símbolos';

  @override
  String get learnQsoMissingBody => 'Um QSO usa estes símbolos que ainda não aprendeu — toque num para o ouvir. Pode explorar na mesma; o teclado mostra todos os símbolos.';

  @override
  String get learnQsoShorthandHint => 'Pratique primeiro as abreviaturas (CQ, DE, UR, RST, TNX, 73) para que as linhas façam sentido.';

  @override
  String get learnQsoPractiseShorthand => 'Praticar abreviaturas';

  @override
  String get learnQsoHowTitle => 'Como decorre um QSO';

  @override
  String get learnQsoHowBody => 'Chamada (CQ = a todos, DE = de), resposta com indicativos, troca de relatório (RST), nome e QTH (local), depois 73 (cumprimentos) e <SK> (fim). K significa câmbio.';

  @override
  String get learnQsoExploreLabel => 'Inclui símbolos não aprendidos';

  @override
  String get statsCoursePassed => 'Curso concluído';

  @override
  String get firstLessonPlayAgain => 'Reproduzir de novo';

  @override
  String firstLessonNextChallenge(int lesson, int count, String char) {
    return 'Desafio da lição $lesson: $count símbolos, 90% desbloqueia $char';
  }

  @override
  String firstLessonNextChallengeLast(int lesson, int count) {
    return 'Desafio da lição $lesson: $count símbolos a 90% concluem o curso';
  }

  @override
  String get learnQsoShorthandTitle => 'Pratique primeiro as abreviaturas';

  @override
  String get learnQsoExchangeTitle => 'Pratique primeiro as linhas de QSO';

  @override
  String get learnQsoExchangeHint => 'Copie linhas isoladas de um contacto (uma troca de cada vez) antes de fazer um QSO completo no simulador.';

  @override
  String get sendGuideTitle => 'Aprender a transmitir';

  @override
  String sendGuideStep(int step, int total) {
    return 'Etapa $step de $total';
  }

  @override
  String get sendGuideHear => 'Ouvir o modelo';

  @override
  String get sendGuideListening => 'Ouça o ritmo completo…';

  @override
  String get sendGuideTry => 'Agora transmita';

  @override
  String get sendGuideRetry => 'Praticar este alvo novamente';

  @override
  String get sendGuidePassed => 'Decodificado corretamente. Continue para o próximo alvo.';

  @override
  String get sendGuideComplete => 'Você transmitiu os dois símbolos e grupos corretamente. Continue com a prática livre.';

  @override
  String get sendGuideRhythm => 'Siga o modelo: pontos curtos, traços três vezes mais longos e uma pausa clara entre caracteres.';

  @override
  String get learnContinueToday => 'Continuar a aprendizagem de hoje';

  @override
  String get learnPlanDetails => 'Ver detalhes do plano';

  @override
  String get learnGuidedSingle => 'Caracteres individuais · 10 caracteres';

  @override
  String get learnGuidedShort => 'Grupos de 3 · 15 caracteres';

  @override
  String get learnGuidedGroups => 'Grupos de 5 · 20 caracteres';

  @override
  String get learnGuidedRecommended => 'Próximo passo recomendado';

  @override
  String get learnGuidedProgressHint => 'Ao passar, continue com grupos curtos e completos. A prática guiada consolida a aprendizagem; o desafio do curso desbloqueia a próxima lição.';

  @override
  String get learnGuidedContinue => 'Continuar a prática guiada';

  @override
  String get learnGuidedRetry => 'Praticar este nível novamente';

  @override
  String get firstLessonZeroHint => 'Não há problema se ainda não acertou. Ouça outra vez a diferença entre K e M e tente novamente.';

  @override
  String get firstLessonPartialHint => 'Ouviu alguns corretamente. Compare K e M outra vez e continue ao seu ritmo.';

  @override
  String get firstLessonPerfectHint => 'Todas as respostas desta ronda foram corretas. Consolide com prática de cópia sem opções de resposta.';

  @override
  String get firstLessonPaceLocked => 'Esta ronda já começou, por isso a velocidade fica fixa. Pode ajustá-la nas definições para a próxima ronda.';

  @override
  String get learnRecentEvidenceHint => 'As etapas usam cópias sem ajuda dos últimos 14 dias, à mesma velocidade.';

  @override
  String get learnQsoConsolidateTitle => 'Consolidar os caracteres aprendidos';

  @override
  String get learnQsoConsolidateHint => 'Desbloquear não significa dominar. Comece por copiar caracteres individuais para obter resultados recentes sem ajuda.';

  @override
  String get learnQsoPractiseSymbols => 'Praticar estes caracteres';

  @override
  String get learnQsoProtocolTitle => 'Compreender os termos de QSO';

  @override
  String get learnQsoProtocolHint => 'Confirme os significados de CQ, DE, RST e 73 antes de iniciar um QSO curto.';

  @override
  String get learnQsoProtocolStart => 'Verificar os termos';

  @override
  String learnQsoProtocolQuestion(String token) {
    return 'O que significa $token num QSO?';
  }

  @override
  String get learnQsoGeneralCall => 'Chamada a qualquer estação';

  @override
  String get learnQsoFromStation => 'Desta estação';

  @override
  String get learnQsoSignalReport => 'Relatório de sinal';

  @override
  String get learnQsoBestRegards => 'Cumprimentos e despedida';

  @override
  String get learnQsoProtocolCorrect => 'Resposta correta';

  @override
  String learnQsoProtocolWrong(String meaning) {
    return 'Significado correto: $meaning';
  }

  @override
  String get learnQsoProtocolPass => 'Acertou os quatro termos sem ajuda. Pode experimentar um QSO curto.';

  @override
  String get learnQsoProtocolPractice => 'Reveja estes significados antes de verificar novamente.';

  @override
  String get learnQsoProtocolRetry => 'Verificar novamente';

  @override
  String get learnQsoShortExchange => 'Praticar um QSO curto';

  @override
  String get learnQsoShortExchangeHint => 'Confirme os indicativos, troque relatórios de sinal e despeça-se sem ajuda antes de passar a um QSO completo.';

  @override
  String get learnQsoExplorePending => 'Explorar um QSO completo · ainda precisa de prática';

  @override
  String get learnQsoReadyHint => 'Tem resultados recentes de prática sem ajuda e pode começar QSO simulados completos.';

  @override
  String get goalsTitle => 'Objetivo de aprendizagem';

  @override
  String get goalsFirstQso => 'Primeiro QSO';

  @override
  String get goalsConversation => 'Conversa e cópia mental';

  @override
  String get goalsContest => 'Trocas de concurso';

  @override
  String get goalsExplanation => 'Inspirado na CW Academy. Cada etapa exige duas tentativas sem ajuda com pelo menos 90% na velocidade efetiva indicada nos últimos 28 dias.';

  @override
  String get goalsBeginner => 'Comece pelo curso de caracteres. Após concluí-lo, o plano diário inclui compreensão e QSO conforme o objetivo.';

  @override
  String get goalsComplete => 'Todas as etapas alcançadas';

  @override
  String get goalsPractice => 'Praticar a próxima habilidade';

  @override
  String get goalsCopying => 'Reconhecimento de caracteres';

  @override
  String get goalsSending => 'Transmissão legível';

  @override
  String get goalsWords => 'Reconhecimento de palavras';

  @override
  String get goalsPhrases => 'Compreensão de frases';

  @override
  String get goalsInformation => 'Informações de QSO';

  @override
  String get goalsStory => 'Cópia mental de histórias';

  @override
  String get goalsQso => 'Completar um QSO';

  @override
  String get goalsCompetition => 'Operação em concurso';

  @override
  String get goalsPlanListening => 'Ouça as informações necessárias para seu objetivo.';

  @override
  String get goalsPlanExchange => 'Pratique uma troca interativa para seu objetivo.';

  @override
  String get mistakesTitle => 'Caderno de erros';

  @override
  String get mistakesPending => 'A rever';

  @override
  String get mistakesRecovered => 'Dominado';

  @override
  String get mistakesHint => 'Repita o exercício original à velocidade e nas condições originais. Duas respostas exatas em dias diferentes marcam o exercício como dominado. Repetições do áudio e respostas reveladas não contam.';

  @override
  String get mistakesEmptyPending => 'Não há erros para rever. Os exercícios incorretos serão guardados aqui após a prática.';

  @override
  String get mistakesEmptyRecovered => 'Ainda não há exercícios dominados. Responda corretamente sem ajuda em dois dias diferentes.';

  @override
  String get mistakesOriginalCopy => 'Primeira resposta incorreta';

  @override
  String get mistakesLastCopy => 'Última resposta';

  @override
  String get mistakesNoAnswer => 'Sem resposta';

  @override
  String get mistakesFailures => 'Tentativas falhadas';

  @override
  String get mistakesFirstFailure => 'Primeiro erro';

  @override
  String get mistakesLastFailure => 'Último erro';

  @override
  String get mistakesCorrectDays => 'Dias com resposta correta sem ajuda';

  @override
  String get mistakesRecoveredOn => 'Dominado em';

  @override
  String get mistakesRetry => 'Repetir exercício original';

  @override
  String get qsoAdvancedContestTitle => 'Troca de concurso';

  @override
  String get qsoAdvancedContestHint => 'Troque indicativos, RST e números de série e confirme o número corrigido.';

  @override
  String get qsoAdvancedPotaTitle => 'POTA entre parques';

  @override
  String get qsoAdvancedPotaHint => 'Troque indicativos, RST e referências de parque e confirme o parque corrigido.';

  @override
  String get qsoAdvancedSerialLabel => 'Seu número de série';

  @override
  String get qsoAdvancedParkLabel => 'Sua referência de parque';

  @override
  String get qsoAdvancedInvalidSerial => 'Digite um número de 1 a 9999.';

  @override
  String get qsoAdvancedInvalidPark => 'Use o prefixo do parque e 4–5 dígitos, ex.: US-1234.';

  @override
  String get qsoAdvancedRepeatTitle => 'Repetir um campo';

  @override
  String get qsoAdvancedRepeatHint => 'Peça apenas a informação perdida; a etapa não muda.';

  @override
  String get qsoAdvancedTypedMode => 'Digitar resposta (com ajuda)';

  @override
  String get qsoAdvancedKeyedMode => 'Manipular resposta';

  @override
  String get qsoAdvancedTypedReply => 'Sua transmissão';

  @override
  String get qsoAdvancedContestStage => 'Enviar RST e seu número';

  @override
  String get qsoAdvancedPotaStage => 'Enviar RST e seu parque';

  @override
  String get qsoAdvancedCorrectionStage => 'Confirmar dados corrigidos';

  @override
  String get qsoAdvancedCorrectionHint => 'Ouça CORR e confirme o RST remoto e o número ou parque corrigido. Envie código legível antes de aumentar a velocidade.';

  @override
  String get qsoAdvancedIssueMissingSerial => 'Envie NR e seu número de série.';

  @override
  String get qsoAdvancedIssueInvalidSerial => 'O número deve ter 1–4 dígitos e ser maior que zero.';

  @override
  String get qsoAdvancedIssueWrongSerial => 'O número não corresponde ao esperado.';

  @override
  String get qsoAdvancedIssueMissingPark => 'Envie PARK e a referência do parque.';

  @override
  String get qsoAdvancedIssueInvalidPark => 'Use o prefixo completo do parque e 4–5 dígitos.';

  @override
  String get qsoAdvancedIssueWrongPark => 'A referência não corresponde ao parque esperado.';

  @override
  String get qsoAdvancedIssueWrongRemoteRst => 'Confirme o RST ouvido da outra estação.';

  @override
  String get qsoAdvancedContestSummary => 'Prática de concurso: indicativo, relatório, número e correção confirmados.';

  @override
  String get qsoAdvancedPotaSummary => 'Prática POTA: indicativo, relatório, parque e correção confirmados.';

  @override
  String get comprehensionTitle => 'Escuta de palavras e frases';

  @override
  String get comprehensionIntro => 'Ouça a mensagem completa, guarde o significado e depois responda. Todo o material é original e está disponível offline.';

  @override
  String get comprehensionModeLabel => 'Modo de prática';

  @override
  String get comprehensionWords => 'Palavras inteiras';

  @override
  String get comprehensionPhrases => 'Partes de palavras e frases';

  @override
  String get comprehensionQso => 'Informações de QSO';

  @override
  String get comprehensionPota => 'Troca POTA';

  @override
  String get comprehensionStory => 'Histórias curtas';

  @override
  String get comprehensionWordsHelp => 'Reconheça a palavra inteira pelo som, sem anotar cada letra.';

  @override
  String get comprehensionPhrasesHelp => 'Reconheça partes familiares de palavras e depois expressões e frases completas.';

  @override
  String get comprehensionQsoHelp => 'Lembre o indicativo, nome, local e relatório de sinal.';

  @override
  String get comprehensionPotaHelp => 'Lembre ambos os indicativos, o identificador do parque e o relatório. O primeiro indicativo é da estação chamada.';

  @override
  String get comprehensionStoryHelp => 'Ouça sem transcrever. Lembre quem, onde, quando e para quê. Responda com as palavras inglesas da mensagem.';

  @override
  String get comprehensionSpeedLabel => 'Velocidade efetiva';

  @override
  String comprehensionSpeed(String character, String effective) {
    return 'Caracteres $character / efetiva $effective PPM';
  }

  @override
  String comprehensionPreviewMissing(String symbols) {
    return 'A mensagem exige símbolos ainda não aprendidos: $symbols. Pode ouvir como prévia assistida.';
  }

  @override
  String get comprehensionAssisted => 'Prática assistida · repetição, texto revelado ou símbolos novos';

  @override
  String get comprehensionIndependent => 'Tentativa independente · uma escuta sem revelar o texto';

  @override
  String get comprehensionReveal => 'Revelar texto (com ajuda)';

  @override
  String get comprehensionTarget => 'Texto transmitido';

  @override
  String get comprehensionAnswer => 'Palavra ou frase';

  @override
  String get comprehensionCallsign => 'Estação chamada / indicativo';

  @override
  String get comprehensionOtherCallsign => 'Estação transmissora / indicativo';

  @override
  String get comprehensionName => 'Nome do operador';

  @override
  String get comprehensionQth => 'Local (QTH)';

  @override
  String get comprehensionRst => 'Relatório de sinal (RST)';

  @override
  String get comprehensionPark => 'Identificador do parque';

  @override
  String get comprehensionPerson => 'Quem?';

  @override
  String get comprehensionDestination => 'Aonde foi?';

  @override
  String get comprehensionTime => 'Quando?';

  @override
  String get comprehensionAction => 'O que foi fazer?';

  @override
  String comprehensionScore(int correct, int total) {
    return '$correct de $total campos corretos';
  }

  @override
  String get comprehensionNext => 'Próxima mensagem';

  @override
  String get comprehensionDone => 'Concluir';

  @override
  String get comprehensionSaveFailed => 'Não foi possível salvar o resultado. Tente novamente antes de sair.';

  @override
  String get comprehensionAudioFailed => 'Áudio indisponível. Verifique a saída do dispositivo e tente novamente.';

  @override
  String get comprehensionAudioRequired => 'Esta prática usa som mesmo que esteja desativado nas outras práticas.';

  @override
  String comprehensionHistory(int count, int percent) {
    return 'Tentativas independentes recentes: $count · precisão por campo $percent%';
  }

  @override
  String get comprehensionEmptyHistory => 'Os resultados independentes aparecerão aqui. A prática assistida é salva separadamente.';

  @override
  String get comprehensionFieldCorrect => 'Correto';

  @override
  String get comprehensionFieldWrong => 'Rever este campo';
}
