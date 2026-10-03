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
  String get navChat => 'Conversas';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navMe => 'Eu';

  @override
  String get navReference => 'Referência';

  @override
  String get navLearnDescription => 'Lições do método Koch, exercícios de transmissão e prática de recepção.';

  @override
  String get navChatDescription => 'Conversas individuais em Morse, sem servidor, pela rede Tox P2P.';

  @override
  String get navGroupsDescription => 'Redes de grupo: vários operadores transmitem em um canal compartilhado.';

  @override
  String get navReferenceDescription => 'Alfabeto, sinais de procedimento, códigos Q, abreviaturas e um tradutor bidirecional.';

  @override
  String get navMeDescription => 'Seu indicativo, identidade Tox, progresso e configurações.';

  @override
  String get shellOfflineBanner => 'Sem conexão com a rede Tox. As mensagens serão enviadas quando você se conectar novamente.';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionSettings => 'Configurações';

  @override
  String get connectionConnecting => 'Conectando…';

  @override
  String get connectionOnline => 'Online';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get messageStatusPending => 'Na fila: o contato está offline';

  @override
  String get messageStatusPendingDetail => 'O Tox não tem servidor: a mensagem é entregue quando o contato fica online.';

  @override
  String get messageStatusSending => 'Enviando';

  @override
  String get messageStatusSent => 'Enviada';

  @override
  String get messageStatusFailed => 'Falha ao enviar';

  @override
  String get errorWrongPassword => 'Senha incorreta. Tente novamente.';

  @override
  String get errorPeerOffline => 'Este contato está offline. O Tox não tem servidor, então a mensagem aguarda até ele se conectar novamente.';

  @override
  String get errorInvalidToxId => 'Este Tox ID não é válido (deve ter 76 caracteres hexadecimais).';

  @override
  String get errorAlreadyFriend => 'Este Tox ID já está na sua lista de amigos.';

  @override
  String get errorOwnId => 'Este é o seu próprio Tox ID.';

  @override
  String get errorGroupNotFound => 'Grupo não encontrado.';

  @override
  String get errorMessageTooLong => 'O texto ultrapassa o limite de uma mensagem do Tox.';

  @override
  String get errorUnknown => 'Ocorreu um erro';

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
  String get accountCopied => 'Tox ID copiado para a área de transferência';

  @override
  String get accountShowQr => 'Mostrar código QR';

  @override
  String get accountToxId => 'Tox ID';

  @override
  String get accountDisplayName => 'Nome de exibição';

  @override
  String get accountDisplayNameHint => 'Seu indicativo ou apelido';

  @override
  String get accountDisplayNameRequired => 'Digite um nome de exibição';

  @override
  String get accountStatusMessage => 'Mensagem de status';

  @override
  String get accountPassword => 'Senha';

  @override
  String get accountPasswordOptional => 'Senha (opcional)';

  @override
  String get accountConfirmPassword => 'Confirmar senha';

  @override
  String get accountPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get accountShowPassword => 'Mostrar senha';

  @override
  String get accountHidePassword => 'Ocultar senha';

  @override
  String get accountStrengthWeak => 'Fraca: use pelo menos 8 caracteres';

  @override
  String get accountStrengthFair => 'Razoável: prefira 12 ou mais caracteres de tipos variados';

  @override
  String get accountStrengthStrong => 'Forte';

  @override
  String get accountStartupInspecting => 'Verificando sua identidade…';

  @override
  String get accountStartupOpening => 'Abrindo sua identidade…';

  @override
  String get accountStartupFailedTitle => 'Não foi possível iniciar';

  @override
  String get accountStartupFailedBody => 'O MorseCQ não conseguiu ler sua identidade. Nada foi alterado; você pode tentar novamente.';

  @override
  String get accountConnectionTapToReconnect => 'Toque para reconectar';

  @override
  String get accountWelcomeTitle => 'Sua identidade fica neste dispositivo';

  @override
  String get accountWelcomeIntro => 'O MorseCQ usa a rede ponto a ponto Tox. Não há servidor nem conta para cadastrar: sua identidade é um par de chaves armazenado apenas aqui.';

  @override
  String get accountWelcomePointNoServer => 'Sem servidor, telefone ou e-mail. Os operadores conversam diretamente em Morse.';

  @override
  String get accountWelcomePointTraining => 'O progresso dos treinos é salvo com sua identidade, permitindo fazer backup e transferir entre dispositivos.';

  @override
  String get accountWelcomePointBackup => 'Ninguém pode recuperar sua identidade por você. Faça um backup logo após criá-la ou ela será perdida junto com o dispositivo.';

  @override
  String get accountCreateIdentity => 'Criar identidade';

  @override
  String get accountRestoreFromBackup => 'Restaurar do backup';

  @override
  String get accountCreateTitle => 'Crie sua identidade';

  @override
  String get accountCreateBody => 'Escolha um nome que os outros verão. Uma senha criptografa o arquivo de identidade neste dispositivo; deixe em branco se preferir abrir o aplicativo sem senha.';

  @override
  String get accountCreateButton => 'Criar';

  @override
  String get accountCreating => 'Criando…';

  @override
  String get accountBackupTitle => 'Faça um backup da sua identidade agora';

  @override
  String get accountBackupBody => 'Sua identidade existe apenas neste dispositivo. Se ele for perdido, redefinido ou roubado, não será possível recuperá-la: seus contatos não reconhecerão uma nova identidade e seu progresso será perdido.';

  @override
  String get accountBackupWhatIsInside => 'O arquivo de backup contém sua identidade criptografada e seu progresso. Guarde-o em um local seguro fora deste dispositivo.';

  @override
  String get accountBackupSaveFile => 'Salvar arquivo de backup';

  @override
  String get accountBackupShareFile => 'Compartilhar arquivo de backup';

  @override
  String get accountBackupSaved => 'Backup salvo';

  @override
  String get accountBackupNotSaved => 'O backup não foi salvo';

  @override
  String get accountBackupFailed => 'Não foi possível gravar o backup';

  @override
  String get accountBackupAcknowledge => 'Entendo que, sem este backup, minha identidade não poderá ser recuperada.';

  @override
  String get accountBackupContinue => 'Continuar para o MorseCQ';

  @override
  String get accountBackupShowQrHint => 'Seus amigos adicionam você pelo seu Tox ID. Compartilhe-o como texto ou código QR.';

  @override
  String get accountRestoreTitle => 'Restaurar do backup';

  @override
  String get accountRestoreBody => 'Escolha um arquivo de backup exportado pelo MorseCQ. Se a identidade estava protegida por senha, você precisará dela aqui.';

  @override
  String get accountRestoreChooseFile => 'Escolher arquivo de backup';

  @override
  String get accountRestoreNoFile => 'Escolha primeiro um arquivo de backup';

  @override
  String get accountRestoreButton => 'Restaurar';

  @override
  String get accountRestoring => 'Restaurando…';

  @override
  String get accountRestoreInvalidFile => 'Este arquivo não é um backup do MorseCQ.';

  @override
  String get accountRestoreReplacesWarning => 'A restauração substitui a identidade atual neste dispositivo.';

  @override
  String get accountUnlockTitle => 'Desbloqueie sua identidade';

  @override
  String get accountUnlockBody => 'Seu arquivo de identidade está criptografado. Digite a senha para continuar.';

  @override
  String get accountUnlockButton => 'Desbloquear';

  @override
  String get accountUnlocking => 'Desbloqueando…';

  @override
  String get accountUnlockRestoreInstead => 'Restaurar do backup em vez disso';

  @override
  String get accountMeNoIdentity => 'Nenhuma identidade carregada';

  @override
  String get accountSectionAccount => 'Conta';

  @override
  String get accountSectionTraining => 'Treinamento';

  @override
  String get accountSectionAbout => 'Sobre';

  @override
  String get accountSectionDanger => 'Zona de perigo';

  @override
  String get accountEditProfile => 'Editar perfil';

  @override
  String get accountEditProfileBody => 'Visível para seus contatos na rede Tox.';

  @override
  String get accountSetPassword => 'Definir senha';

  @override
  String get accountChangePassword => 'Alterar senha';

  @override
  String get accountRemovePassword => 'Remover senha';

  @override
  String get accountCurrentPassword => 'Senha atual';

  @override
  String get accountNewPassword => 'Nova senha';

  @override
  String get accountPasswordUpdated => 'Senha atualizada';

  @override
  String get accountPasswordRemoved => 'Senha removida';

  @override
  String get accountProfileUpdated => 'Perfil atualizado';

  @override
  String get accountExportBackup => 'Exportar backup';

  @override
  String get accountExportBackupSubtitle => 'Salve sua identidade e seu progresso em um arquivo';

  @override
  String get accountTrainingDefaults => 'Padrões de reprodução e treinamento';

  @override
  String get accountTrainingDefaultsSubtitle => 'Velocidade, tom e espaçamento Farnsworth';

  @override
  String get accountTrainingDefaultsPlaceholder => 'Os padrões de velocidade, tom e Farnsworth ficarão aqui.';

  @override
  String get accountAboutLicence => 'Licença';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Código-fonte';

  @override
  String get accountAboutSourceCopied => 'Link do código-fonte copiado';

  @override
  String get accountAboutBackend => 'Motor interno';

  @override
  String get accountDeleteIdentity => 'Excluir identidade';

  @override
  String get accountDeleteIdentitySubtitle => 'Apague a identidade, o histórico e o progresso deste dispositivo';

  @override
  String get accountDeleteDialogTitle => 'Excluir esta identidade?';

  @override
  String get accountDeleteDialogBody => 'Isso remove sua identidade, histórico de conversas e progresso deste dispositivo. Sem backup, não será possível recuperar. Digite DELETE para confirmar.';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => 'Digite DELETE';

  @override
  String get accountDeleteButton => 'Excluir';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return 'Arquivo de backup selecionado ($bytes bytes)';
  }

  @override
  String get chatSearchConversations => 'Buscar conversas';

  @override
  String get chatNoConversations => 'Ainda não há conversas';

  @override
  String get chatNoSearchResults => 'Nenhuma conversa corresponde à busca';

  @override
  String get chatPin => 'Fixar';

  @override
  String get chatUnpin => 'Desafixar';

  @override
  String get chatMarkRead => 'Marcar como lida';

  @override
  String get chatDelete => 'Excluir';

  @override
  String get chatDeleteConversationTitle => 'Excluir conversa?';

  @override
  String get chatDeleteConversationBody => 'O histórico local desta conversa será removido. O Tox não mantém cópias.';

  @override
  String get chatDraftPrefix => 'Rascunho: ';

  @override
  String get chatSelectConversation => 'Selecione uma conversa';

  @override
  String get chatContacts => 'Contatos';

  @override
  String get chatNoMessages => 'Ainda não há mensagens: envie CQ para começar.';

  @override
  String get chatTrainingMode => 'Modo de treinamento';

  @override
  String get chatTrainingModeOn => 'Treinamento ativado: texto oculto';

  @override
  String get chatTrainingModeOff => 'Treinamento desativado';

  @override
  String get chatAutoPlay => 'Reproduzir automaticamente o Morse recebido';

  @override
  String get chatAutoPlayOn => 'Reprodução automática ativada: novas mensagens tocam ao chegar';

  @override
  String get chatAutoPlayOff => 'Reprodução automática desativada';

  @override
  String get chatReveal => 'Mostrar';

  @override
  String get chatHiddenText => 'Ouça primeiro e depois mostre o texto';

  @override
  String get chatPlay => 'Reproduzir Morse';

  @override
  String get chatStop => 'Parar';

  @override
  String get chatPlaybackSettings => 'Configurações de reprodução';

  @override
  String get chatCharacterSpeed => 'Velocidade dos caracteres';

  @override
  String get chatFarnsworthSpeed => 'Velocidade Farnsworth';

  @override
  String get chatTone => 'Tom';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => 'Membros';

  @override
  String get chatLeaveGroup => 'Sair do grupo';

  @override
  String get chatLeaveGroupTitle => 'Sair deste grupo?';

  @override
  String get chatLeaveGroupBody => 'Você deixará de receber mensagens. Entre novamente depois com o ID do chat.';

  @override
  String get chatLeave => 'Sair';

  @override
  String get chatConferenceNote => 'Conferência antiga: os metadados de transmissão Morse (v2) não estão disponíveis aqui. O texto continua funcionando.';

  @override
  String get chatClearHistory => 'Limpar histórico';

  @override
  String get chatModeStraightKey => 'Chave manual';

  @override
  String get chatModePaddles => 'Palhetas';

  @override
  String get chatKeyMessage => 'Transmita sua mensagem em Morse';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatTooLong => 'Ultrapassa o limite de uma mensagem do Tox';

  @override
  String get chatKeyHint => 'Use a área da chave ou pressione Espaço';

  @override
  String get chatPaddleHint => 'Toque nas palhetas ou segure Ctrl (esquerdo: ponto; direito: traço)';

  @override
  String get chatDeleteLast => 'Excluir último caractere';

  @override
  String get chatNoFriends => 'Ainda não há amigos. Adicione alguém pelo Tox ID.';

  @override
  String get chatNoRequests => 'Não há solicitações pendentes';

  @override
  String get chatAddFriend => 'Adicionar amigo';

  @override
  String get chatMyToxId => 'Meu Tox ID';

  @override
  String get chatToxIdLabel => 'Tox ID (76 caracteres hexadecimais)';

  @override
  String get chatToxIdInvalid => 'O Tox ID deve ter exatamente 76 caracteres hexadecimais';

  @override
  String get chatToxIdOwn => 'Este é o seu próprio Tox ID';

  @override
  String get chatToxIdAlreadyFriend => 'Já está na sua lista de amigos';

  @override
  String get chatRequestMessage => 'Mensagem';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => 'Enviar solicitação';

  @override
  String get chatRequestSent => 'Solicitação de amizade enviada';

  @override
  String get chatScanQr => 'Ler QR';

  @override
  String get chatScanQrDesktopHint => 'A leitura de QR requer a câmera de um celular';

  @override
  String get chatScanQrTitle => 'Ler um Tox ID';

  @override
  String get chatScanQrNotToxId => 'Este código QR não é um Tox ID';

  @override
  String get chatAccept => 'Aceitar';

  @override
  String get chatReject => 'Recusar';

  @override
  String get chatCopied => 'Copiado para a área de transferência';

  @override
  String get chatNoIdentity => 'Nenhuma identidade carregada';

  @override
  String get chatRemoveFriend => 'Remover amigo';

  @override
  String get chatRemoveFriendTitle => 'Remover este amigo?';

  @override
  String get chatRemoveFriendBody => 'Ele não poderá mais enviar mensagens para você.';

  @override
  String get chatRemove => 'Remover';

  @override
  String get chatNoGroups => 'Ainda não há grupos. Crie um ou entre pelo ID do chat.';

  @override
  String get chatCreateGroup => 'Criar grupo';

  @override
  String get chatJoinGroup => 'Entrar em um grupo';

  @override
  String get chatGroupName => 'Nome do grupo';

  @override
  String get chatGroupNameRequired => 'Dê um nome ao grupo';

  @override
  String get chatAdvanced => 'Avançado';

  @override
  String get chatLegacyConference => 'Conferência antiga (clientes antigos)';

  @override
  String get chatLegacyConferenceHint => 'Não recomendado: sem ID permanente do chat nem metadados Morse.';

  @override
  String get chatCreate => 'Criar';

  @override
  String get chatChatIdLabel => 'ID do chat (64 caracteres hexadecimais)';

  @override
  String get chatChatIdInvalid => 'O ID do chat deve ter exatamente 64 caracteres hexadecimais';

  @override
  String get chatPassword => 'Senha (opcional)';

  @override
  String get chatJoin => 'Entrar';

  @override
  String get chatJoinRequested => 'Entrando: o grupo aparecerá quando um membro for encontrado.';

  @override
  String get chatConferenceBadge => 'Conferência';

  @override
  String get chatCopyChatId => 'Copiar ID do chat';

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
  String get learnIdentityRequired => 'Crie ou desbloqueie sua identidade para começar a treinar. O progresso é salvo com ela e incluído no backup.';

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
  String get notificationOpen => 'Abrir';

  @override
  String get notificationChannelMessages => 'Mensagens';

  @override
  String get notificationChannelMessagesDescription => 'Novas mensagens Morse de amigos e grupos';

  @override
  String get notificationChannelFriendRequests => 'Solicitações de amizade';

  @override
  String get notificationChannelFriendRequestsDescription => 'Alguém quer adicionar você como amigo';

  @override
  String get notificationChannelGroupInvites => 'Convites para grupos';

  @override
  String get notificationChannelGroupInvitesDescription => 'Um amigo convidou você para um grupo';

  @override
  String get notificationNewMessage => 'Nova mensagem';

  @override
  String get notificationFriendRequestTitle => 'Nova solicitação de amizade';

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
  String get accountNewPasswordRequired => 'Digite uma nova senha';

  @override
  String get accountToxIdQrSemantics => 'Código QR do Tox ID';

  @override
  String get accountBackupSaveDialogTitle => 'Salvar backup do MorseCQ';

  @override
  String get accountBackupShareSubject => 'Backup da identidade MorseCQ';

  @override
  String get accountBackupChooseDialogTitle => 'Escolher backup do MorseCQ';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novas mensagens',
      one: '$count nova mensagem',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return 'Solicitação de amizade de $name';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name: $message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return 'Convite para $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name convidou você';
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
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens não lidas',
      one: '$count mensagem não lida',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => 'Ligado';

  @override
  String get listenStateOff => 'Desligado';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count bytes',
      one: 'Resta $count byte',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return 'Amigos ($count)';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return 'Solicitações de amizade ($count)';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return 'Convites para grupos ($count)';
  }

  @override
  String chatMembersTitleCount(int count) {
    return 'Membros · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return 'Convidado por $name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name (você)';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label: $value $unit';
  }

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
  String get appearanceSubtitle => 'Cinco estilos com modos claro e escuro';

  @override
  String get chatClearHistoryBody => 'Excluir o histórico desta conversa neste dispositivo? As cópias em outros dispositivos não serão afetadas. Esta ação não pode ser desfeita.';

  @override
  String get chatLoadEarlier => 'Carregar mensagens anteriores';

  @override
  String get chatHistoryLoadFailed => 'Não foi possível carregar as mensagens anteriores. Toque para tentar novamente.';

  @override
  String get chatRetryHistory => 'Tentar novamente';

  @override
  String chatNewMessages(int count) {
    return '$count novas mensagens';
  }

  @override
  String learnShowAllChars(int count) {
    return 'Mostrar todos os $count caracteres';
  }

  @override
  String get chatSelfMe => 'Eu';

  @override
  String get chatSelfLocalOnly => 'Salvo apenas neste dispositivo';

  @override
  String get chatSelfContactSubtitle => 'Rascunhos, prática e notas · nunca enviados';

  @override
  String get learnShowFewerChars => 'Mostrar menos caracteres';

  @override
  String get learnLeaveDrillTitle => 'Sair desta sessão?';

  @override
  String get learnLeaveDrillBody => 'As rodadas desta sessão não serão salvas.';

  @override
  String get learnLeaveDrillConfirm => 'Sair';

  @override
  String get chatScanQrPermissionDenied => 'O MorseCQ precisa de acesso à câmera para ler um código QR. Permita-o nas configurações do sistema.';

  @override
  String get chatScanQrCameraUnavailable => 'A câmera não está disponível neste dispositivo.';

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
  String learnPlanNext(String step) {
    return 'Próximo: $step';
  }

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
  String get messageStatusCancelled => 'Cancelado — nunca enviado';

  @override
  String get chatMessageLearnActions => 'Ações da mensagem';

  @override
  String get chatPracticeMessage => 'Praticar esta mensagem';

  @override
  String get chatSaveAsMaterial => 'Salvar como material de treino';

  @override
  String get chatSavedAsMaterial => 'Salvo em Meus materiais';

  @override
  String get chatSaveMaterialFailed => 'Não foi possível salvar o material. Tente novamente.';

  @override
  String get chatListenOnly => 'Treino só de escuta';

  @override
  String get chatListenOnlyHidden => 'Só escuta: toque em reproduzir';

  @override
  String chatClearHistoryMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens deste chat foram salvas como material. Essas cópias ficam até você excluí-las em Aprender › Meus materiais.',
      one: '1 mensagem deste chat foi salva como material. Essa cópia fica até você excluí-la em Aprender › Meus materiais.',
    );
    return '$_temp0';
  }

  @override
  String get chatPracticeTitle => 'Prática de cópia';

  @override
  String chatPracticeUnsupported(String chars) {
    return 'Esta mensagem tem caracteres sem código Morse: $chars. Eles serão omitidos.';
  }

  @override
  String chatPracticeTrainableCount(int count) {
    return '$count símbolos podem ser praticados.';
  }

  @override
  String get chatPracticeNothingTrainable => 'Nada nesta mensagem pode ser praticado em Morse.';

  @override
  String get chatPracticeConfirm => 'Praticar o resto';

  @override
  String get chatPracticeHint => 'Dica';

  @override
  String chatPracticeHintShown(String symbols) {
    return 'Dica: $symbols …';
  }

  @override
  String get chatPracticeAssisted => 'Com ajuda: conta como prática, não para revisões nem sugestão de velocidade.';

  @override
  String chatPracticeErrors(int wrong, int missed, int extra) {
    return '$wrong errados · $missed omitidos · $extra a mais';
  }

  @override
  String chatPracticeErrorsAction(String symbols) {
    return 'Praticar erros: $symbols';
  }

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
  String get chatSearchMessages => 'Pesquisar mensagens';

  @override
  String get chatSearchHint => 'Pesquisar nesta conversa';

  @override
  String get chatSearchAnyone => 'Todos';

  @override
  String get chatSearchMe => 'Eu';

  @override
  String get chatSearchThem => 'A outra pessoa';

  @override
  String get chatSearchAnyDate => 'Qualquer data';

  @override
  String chatSearchDateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get chatSearchBookmarked => 'Favoritos';

  @override
  String get chatSearchNoResults => 'Nenhuma mensagem correspondente.';

  @override
  String get chatSearchMore => 'Carregar mais';

  @override
  String get chatAddBookmark => 'Favoritar';

  @override
  String get chatRemoveBookmark => 'Remover dos favoritos';

  @override
  String get chatBookmarked => 'Favoritado';

  @override
  String get chatBookmarkFailed => 'Não foi possível salvar o favorito.';

  @override
  String get chatRetrySend => 'Tentar enviar de novo';

  @override
  String get chatCancelSend => 'Cancelar envio';

  @override
  String get chatRetryQueued => 'Na fila de novo. Será enviada quando o contato estiver online.';

  @override
  String get chatSendCancelled => 'Cancelado. A mensagem nunca foi enviada.';

  @override
  String get chatRetryNotNeeded => 'Esta mensagem não está mais com falha.';

  @override
  String get chatCancelTooLate => 'Tarde demais: a mensagem já saiu e pode chegar.';

  @override
  String get chatSendControlUnavailable => 'Indisponível para esta mensagem.';

  @override
  String get chatSendControlFailed => 'Não funcionou. A mensagem mantém o estado; tente novamente.';
}
