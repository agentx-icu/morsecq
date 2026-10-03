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
  String get navChat => 'Chat';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navMe => 'Yo';

  @override
  String get navReference => 'Referencia';

  @override
  String get navLearnDescription => 'Lecciones del método Koch, ejercicios de transmisión y práctica de recepción.';

  @override
  String get navChatDescription => 'Conversaciones Morse individuales sin servidor a través de Tox P2P.';

  @override
  String get navGroupsDescription => 'Redes de grupo: varios operadores transmiten en un canal compartido.';

  @override
  String get navReferenceDescription => 'Alfabeto, señales de procedimiento, códigos Q, abreviaturas y un traductor bidireccional.';

  @override
  String get navMeDescription => 'Tu indicativo, identidad Tox, progreso y ajustes.';

  @override
  String get shellOfflineBanner => 'Sin conexión a la red Tox. Los mensajes se enviarán cuando vuelvas a conectarte.';

  @override
  String get actionOk => 'Aceptar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionSettings => 'Ajustes';

  @override
  String get connectionConnecting => 'Conectando…';

  @override
  String get connectionOnline => 'En línea';

  @override
  String get connectionOffline => 'Sin conexión';

  @override
  String get messageStatusPending => 'En cola: el contacto está desconectado';

  @override
  String get messageStatusPendingDetail => 'Tox no tiene servidor: el mensaje se entrega cuando el contacto se conecta.';

  @override
  String get messageStatusSending => 'Enviando';

  @override
  String get messageStatusSent => 'Enviado';

  @override
  String get messageStatusFailed => 'Error al enviar';

  @override
  String get errorWrongPassword => 'Contraseña incorrecta. Inténtalo de nuevo.';

  @override
  String get errorPeerOffline => 'Este contacto está desconectado. Tox no tiene servidor, así que el mensaje espera hasta que vuelva a conectarse.';

  @override
  String get errorInvalidToxId => 'El Tox ID no es válido (debe tener 76 caracteres hexadecimales).';

  @override
  String get errorAlreadyFriend => 'Este Tox ID ya está en tu lista de amigos.';

  @override
  String get errorOwnId => 'Ese es tu propio Tox ID.';

  @override
  String get errorGroupNotFound => 'No se encontró el grupo.';

  @override
  String get errorMessageTooLong => 'El texto supera el límite de un mensaje de Tox.';

  @override
  String get errorUnknown => 'Se ha producido un error';

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
  String get accountCopied => 'Tox ID copiado al portapapeles';

  @override
  String get accountShowQr => 'Mostrar código QR';

  @override
  String get accountToxId => 'Tox ID';

  @override
  String get accountDisplayName => 'Nombre visible';

  @override
  String get accountDisplayNameHint => 'Tu indicativo o apodo';

  @override
  String get accountDisplayNameRequired => 'Introduce un nombre visible';

  @override
  String get accountStatusMessage => 'Mensaje de estado';

  @override
  String get accountPassword => 'Contraseña';

  @override
  String get accountPasswordOptional => 'Contraseña (opcional)';

  @override
  String get accountConfirmPassword => 'Confirmar contraseña';

  @override
  String get accountPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get accountShowPassword => 'Mostrar contraseña';

  @override
  String get accountHidePassword => 'Ocultar contraseña';

  @override
  String get accountStrengthWeak => 'Débil: usa al menos 8 caracteres';

  @override
  String get accountStrengthFair => 'Aceptable: mejor 12 o más caracteres de varios tipos';

  @override
  String get accountStrengthStrong => 'Fuerte';

  @override
  String get accountStartupInspecting => 'Comprobando tu identidad…';

  @override
  String get accountStartupOpening => 'Abriendo tu identidad…';

  @override
  String get accountStartupFailedTitle => 'No se pudo iniciar';

  @override
  String get accountStartupFailedBody => 'MorseCQ no pudo leer tu identidad. No se ha cambiado nada; puedes intentarlo de nuevo.';

  @override
  String get accountConnectionTapToReconnect => 'Toca para volver a conectar';

  @override
  String get accountWelcomeTitle => 'Tu identidad reside en este dispositivo';

  @override
  String get accountWelcomeIntro => 'MorseCQ usa la red entre pares Tox. No hay servidor ni cuenta que registrar: tu identidad es un par de claves guardado únicamente aquí.';

  @override
  String get accountWelcomePointNoServer => 'Sin servidor, número de teléfono ni correo electrónico. Los operadores hablan directamente en Morse.';

  @override
  String get accountWelcomePointTraining => 'El progreso se guarda con tu identidad para que puedas respaldarlo y trasladarlo entre dispositivos.';

  @override
  String get accountWelcomePointBackup => 'Nadie puede recuperar tu identidad por ti. Crea una copia de seguridad al terminar o la perderás junto con el dispositivo.';

  @override
  String get accountCreateIdentity => 'Crear identidad';

  @override
  String get accountRestoreFromBackup => 'Restaurar desde copia de seguridad';

  @override
  String get accountCreateTitle => 'Crea tu identidad';

  @override
  String get accountCreateBody => 'Elige un nombre que verán los demás. La contraseña cifra el archivo de identidad de este dispositivo; déjala vacía si prefieres abrir la aplicación sin ella.';

  @override
  String get accountCreateButton => 'Crear';

  @override
  String get accountCreating => 'Creando…';

  @override
  String get accountBackupTitle => 'Crea ahora una copia de tu identidad';

  @override
  String get accountBackupBody => 'Tu identidad solo existe en este dispositivo. Si lo pierdes, lo restableces o te lo roban, no podrás recuperarla: tus contactos no reconocerán una identidad nueva y perderás tu progreso.';

  @override
  String get accountBackupWhatIsInside => 'La copia contiene tu identidad cifrada y tu progreso. Guárdala en un lugar seguro fuera de este dispositivo.';

  @override
  String get accountBackupSaveFile => 'Guardar copia de seguridad';

  @override
  String get accountBackupShareFile => 'Compartir copia de seguridad';

  @override
  String get accountBackupSaved => 'Copia de seguridad guardada';

  @override
  String get accountBackupNotSaved => 'No se guardó la copia de seguridad';

  @override
  String get accountBackupFailed => 'No se pudo escribir la copia de seguridad';

  @override
  String get accountBackupAcknowledge => 'Entiendo que sin esta copia no podré recuperar mi identidad.';

  @override
  String get accountBackupContinue => 'Continuar a MorseCQ';

  @override
  String get accountBackupShowQrHint => 'Tus amigos te añaden con tu Tox ID. Compártelo como texto o como código QR.';

  @override
  String get accountRestoreTitle => 'Restaurar desde copia de seguridad';

  @override
  String get accountRestoreBody => 'Elige una copia de seguridad exportada desde MorseCQ. Si la identidad tenía contraseña, tendrás que introducirla aquí.';

  @override
  String get accountRestoreChooseFile => 'Elegir copia de seguridad';

  @override
  String get accountRestoreNoFile => 'Elige primero una copia de seguridad';

  @override
  String get accountRestoreButton => 'Restaurar';

  @override
  String get accountRestoring => 'Restaurando…';

  @override
  String get accountRestoreInvalidFile => 'Este archivo no es una copia de MorseCQ.';

  @override
  String get accountRestoreReplacesWarning => 'La restauración sustituye la identidad actual de este dispositivo.';

  @override
  String get accountUnlockTitle => 'Desbloquea tu identidad';

  @override
  String get accountUnlockBody => 'Tu archivo de identidad está cifrado. Introduce la contraseña para continuar.';

  @override
  String get accountUnlockButton => 'Desbloquear';

  @override
  String get accountUnlocking => 'Desbloqueando…';

  @override
  String get accountUnlockRestoreInstead => 'Restaurar desde copia de seguridad en su lugar';

  @override
  String get accountMeNoIdentity => 'No hay identidad cargada';

  @override
  String get accountSectionAccount => 'Cuenta';

  @override
  String get accountSectionTraining => 'Entrenamiento';

  @override
  String get accountSectionAbout => 'Acerca de';

  @override
  String get accountSectionDanger => 'Zona de peligro';

  @override
  String get accountEditProfile => 'Editar perfil';

  @override
  String get accountEditProfileBody => 'Visible para tus contactos de la red Tox.';

  @override
  String get accountSetPassword => 'Establecer contraseña';

  @override
  String get accountChangePassword => 'Cambiar contraseña';

  @override
  String get accountRemovePassword => 'Quitar contraseña';

  @override
  String get accountCurrentPassword => 'Contraseña actual';

  @override
  String get accountNewPassword => 'Nueva contraseña';

  @override
  String get accountPasswordUpdated => 'Contraseña actualizada';

  @override
  String get accountPasswordRemoved => 'Contraseña eliminada';

  @override
  String get accountProfileUpdated => 'Perfil actualizado';

  @override
  String get accountExportBackup => 'Exportar copia de seguridad';

  @override
  String get accountExportBackupSubtitle => 'Guarda tu identidad y progreso en un archivo';

  @override
  String get accountTrainingDefaults => 'Valores de reproducción y entrenamiento';

  @override
  String get accountTrainingDefaultsSubtitle => 'Velocidad, tono y espaciado Farnsworth';

  @override
  String get accountTrainingDefaultsPlaceholder => 'Aquí estarán los valores de velocidad, tono y Farnsworth.';

  @override
  String get accountAboutLicence => 'Licencia';

  @override
  String get accountAboutLicenceValue => 'GPL-3.0';

  @override
  String get accountAboutSource => 'Código fuente';

  @override
  String get accountAboutSourceCopied => 'Enlace al código copiado';

  @override
  String get accountAboutBackend => 'Motor interno';

  @override
  String get accountDeleteIdentity => 'Eliminar identidad';

  @override
  String get accountDeleteIdentitySubtitle => 'Borra la identidad, el historial y el progreso de este dispositivo';

  @override
  String get accountDeleteDialogTitle => '¿Eliminar esta identidad?';

  @override
  String get accountDeleteDialogBody => 'Se eliminarán tu identidad, historial de chat y progreso de este dispositivo. No podrás recuperarlos sin una copia de seguridad. Escribe DELETE para confirmar.';

  @override
  String get accountDeleteConfirmWord => 'DELETE';

  @override
  String get accountDeleteConfirmHint => 'Escribe DELETE';

  @override
  String get accountDeleteButton => 'Eliminar';

  @override
  String accountRestoreFileChosenSize(int bytes) {
    return 'Copia seleccionada ($bytes bytes)';
  }

  @override
  String get chatSearchConversations => 'Buscar conversaciones';

  @override
  String get chatNoConversations => 'Aún no hay conversaciones';

  @override
  String get chatNoSearchResults => 'No hay conversaciones que coincidan';

  @override
  String get chatPin => 'Fijar';

  @override
  String get chatUnpin => 'Desfijar';

  @override
  String get chatMarkRead => 'Marcar como leído';

  @override
  String get chatDelete => 'Eliminar';

  @override
  String get chatDeleteConversationTitle => '¿Eliminar conversación?';

  @override
  String get chatDeleteConversationBody => 'Se eliminará el historial local de esta conversación. Tox no conserva ninguna copia.';

  @override
  String get chatDraftPrefix => 'Borrador: ';

  @override
  String get chatSelectConversation => 'Selecciona una conversación';

  @override
  String get chatContacts => 'Contactos';

  @override
  String get chatNoMessages => 'Aún no hay mensajes: envía CQ para empezar.';

  @override
  String get chatTrainingMode => 'Modo de entrenamiento';

  @override
  String get chatTrainingModeOn => 'Entrenamiento activado: texto oculto';

  @override
  String get chatTrainingModeOff => 'Entrenamiento desactivado';

  @override
  String get chatAutoPlay => 'Reproducir automáticamente el Morse recibido';

  @override
  String get chatAutoPlayOn => 'Reproducción automática activada: los mensajes nuevos suenan al llegar';

  @override
  String get chatAutoPlayOff => 'Reproducción automática desactivada';

  @override
  String get chatReveal => 'Mostrar';

  @override
  String get chatHiddenText => 'Escucha primero y luego muestra el texto';

  @override
  String get chatPlay => 'Reproducir Morse';

  @override
  String get chatStop => 'Detener';

  @override
  String get chatPlaybackSettings => 'Ajustes de reproducción';

  @override
  String get chatCharacterSpeed => 'Velocidad de los caracteres';

  @override
  String get chatFarnsworthSpeed => 'Velocidad Farnsworth';

  @override
  String get chatTone => 'Tono';

  @override
  String get chatWpm => 'WPM';

  @override
  String get chatHz => 'Hz';

  @override
  String get chatMembers => 'Miembros';

  @override
  String get chatLeaveGroup => 'Salir del grupo';

  @override
  String get chatLeaveGroupTitle => '¿Salir de este grupo?';

  @override
  String get chatLeaveGroupBody => 'Dejarás de recibir mensajes. Puedes volver a entrar con el ID del chat.';

  @override
  String get chatLeave => 'Salir';

  @override
  String get chatConferenceNote => 'Conferencia antigua: aquí no están disponibles los metadatos de transmisión Morse (v2). El texto sigue funcionando.';

  @override
  String get chatClearHistory => 'Borrar historial';

  @override
  String get chatModeStraightKey => 'Llave vertical';

  @override
  String get chatModePaddles => 'Paletas';

  @override
  String get chatKeyMessage => 'Transmite tu mensaje en Morse';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatTooLong => 'Supera el límite de un mensaje de Tox';

  @override
  String get chatKeyHint => 'Usa la zona de llave o pulsa Espacio';

  @override
  String get chatPaddleHint => 'Toca las paletas o mantén Ctrl (izquierdo: punto; derecho: raya)';

  @override
  String get chatDeleteLast => 'Eliminar último carácter';

  @override
  String get chatNoFriends => 'Aún no hay amigos. Añade uno con su Tox ID.';

  @override
  String get chatNoRequests => 'No hay solicitudes pendientes';

  @override
  String get chatAddFriend => 'Añadir amigo';

  @override
  String get chatMyToxId => 'Mi Tox ID';

  @override
  String get chatToxIdLabel => 'Tox ID (76 caracteres hexadecimales)';

  @override
  String get chatToxIdInvalid => 'El Tox ID debe tener exactamente 76 caracteres hexadecimales';

  @override
  String get chatToxIdOwn => 'Ese es tu propio Tox ID';

  @override
  String get chatToxIdAlreadyFriend => 'Ya está en tu lista de amigos';

  @override
  String get chatRequestMessage => 'Mensaje';

  @override
  String get chatDefaultRequestMessage => 'MorseCQ CQ';

  @override
  String get chatSendRequest => 'Enviar solicitud';

  @override
  String get chatRequestSent => 'Solicitud de amistad enviada';

  @override
  String get chatScanQr => 'Escanear QR';

  @override
  String get chatScanQrDesktopHint => 'Para escanear QR se necesita la cámara de un teléfono';

  @override
  String get chatScanQrTitle => 'Escanear un Tox ID';

  @override
  String get chatScanQrNotToxId => 'Este código QR no es un Tox ID';

  @override
  String get chatAccept => 'Aceptar';

  @override
  String get chatReject => 'Rechazar';

  @override
  String get chatCopied => 'Copiado al portapapeles';

  @override
  String get chatNoIdentity => 'No hay identidad cargada';

  @override
  String get chatRemoveFriend => 'Eliminar amigo';

  @override
  String get chatRemoveFriendTitle => '¿Eliminar a este amigo?';

  @override
  String get chatRemoveFriendBody => 'Ya no podrá enviarte mensajes.';

  @override
  String get chatRemove => 'Eliminar';

  @override
  String get chatNoGroups => 'Aún no hay grupos. Crea uno o entra con el ID del chat.';

  @override
  String get chatCreateGroup => 'Crear grupo';

  @override
  String get chatJoinGroup => 'Unirse a grupo';

  @override
  String get chatGroupName => 'Nombre del grupo';

  @override
  String get chatGroupNameRequired => 'Dale un nombre al grupo';

  @override
  String get chatAdvanced => 'Avanzado';

  @override
  String get chatLegacyConference => 'Conferencia antigua (clientes anteriores)';

  @override
  String get chatLegacyConferenceHint => 'No recomendado: sin ID permanente ni metadatos Morse.';

  @override
  String get chatCreate => 'Crear';

  @override
  String get chatChatIdLabel => 'ID del chat (64 caracteres hexadecimales)';

  @override
  String get chatChatIdInvalid => 'El ID del chat debe tener exactamente 64 caracteres hexadecimales';

  @override
  String get chatPassword => 'Contraseña (opcional)';

  @override
  String get chatJoin => 'Unirse';

  @override
  String get chatJoinRequested => 'Uniéndote: el grupo aparecerá cuando se encuentre un miembro.';

  @override
  String get chatConferenceBadge => 'Conferencia';

  @override
  String get chatCopyChatId => 'Copiar ID del chat';

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
  String get learnIdentityRequired => 'Crea o desbloquea tu identidad para entrenar. El progreso se guarda con ella y se incluye en la copia de seguridad.';

  @override
  String get learnLoadFailed => 'No se pudo leer tu progreso. Empezarás de nuevo; el archivo anterior se conservó como .corrupt.';

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
  String get notificationOpen => 'Abrir';

  @override
  String get notificationChannelMessages => 'Mensajes';

  @override
  String get notificationChannelMessagesDescription => 'Nuevos mensajes Morse de amigos y grupos';

  @override
  String get notificationChannelFriendRequests => 'Solicitudes de amistad';

  @override
  String get notificationChannelFriendRequestsDescription => 'Alguien quiere añadirte como amigo';

  @override
  String get notificationChannelGroupInvites => 'Invitaciones a grupos';

  @override
  String get notificationChannelGroupInvitesDescription => 'Un amigo te ha invitado a un grupo';

  @override
  String get notificationNewMessage => 'Nuevo mensaje';

  @override
  String get notificationFriendRequestTitle => 'Nueva solicitud de amistad';

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
  String get accountNewPasswordRequired => 'Introduce una nueva contraseña';

  @override
  String get accountToxIdQrSemantics => 'Código QR del Tox ID';

  @override
  String get accountBackupSaveDialogTitle => 'Guardar copia de MorseCQ';

  @override
  String get accountBackupShareSubject => 'Copia de seguridad de identidad MorseCQ';

  @override
  String get accountBackupChooseDialogTitle => 'Elegir copia de MorseCQ';

  @override
  String notificationNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes nuevos',
      one: '$count mensaje nuevo',
    );
    return '$_temp0';
  }

  @override
  String notificationFriendRequestFrom(String name) {
    return 'Solicitud de amistad de $name';
  }

  @override
  String notificationFriendRequestBody(String name, String message) {
    return '$name: $message';
  }

  @override
  String notificationGroupInviteTitle(String group) {
    return 'Invitación a $group';
  }

  @override
  String notificationGroupInviteBody(String name) {
    return '$name te ha invitado';
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
  String desktopTrayTooltipUnread(String app, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes sin leer',
      one: '$count mensaje sin leer',
    );
    return '$app — $_temp0';
  }

  @override
  String desktopWindowTitleUnread(String badge, String app) {
    return '($badge) $app';
  }

  @override
  String get listenStateOn => 'Activado';

  @override
  String get listenStateOff => 'Desactivado';

  @override
  String chatBytesLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count bytes',
      one: 'Queda $count byte',
    );
    return '$_temp0';
  }

  @override
  String chatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '$count miembro',
    );
    return '$_temp0';
  }

  @override
  String chatFriendsCount(int count) {
    return 'Amigos ($count)';
  }

  @override
  String chatFriendRequestsCount(int count) {
    return 'Solicitudes de amistad ($count)';
  }

  @override
  String chatGroupInvitesCount(int count) {
    return 'Invitaciones a grupos ($count)';
  }

  @override
  String chatMembersTitleCount(int count) {
    return 'Miembros · $count';
  }

  @override
  String chatInvitedByName(String name) {
    return 'Invitado por $name';
  }

  @override
  String chatMemberSelf(String name) {
    return '$name (tú)';
  }

  @override
  String chatSliderValue(String label, int value, String unit) {
    return '$label: $value $unit';
  }

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
  String get appearanceSubtitle => 'Cinco estilos con modos claro y oscuro';

  @override
  String get chatClearHistoryBody => '¿Eliminar el historial de esta conversación de este dispositivo? Las copias de otros dispositivos no se verán afectadas. No se puede deshacer.';

  @override
  String get chatLoadEarlier => 'Cargar mensajes anteriores';

  @override
  String get chatHistoryLoadFailed => 'No se pudieron cargar los mensajes anteriores. Toca para reintentar.';

  @override
  String get chatRetryHistory => 'Reintentar';

  @override
  String chatNewMessages(int count) {
    return '$count mensajes nuevos';
  }

  @override
  String learnShowAllChars(int count) {
    return 'Mostrar los $count caracteres';
  }

  @override
  String get chatSelfMe => 'Yo';

  @override
  String get chatSelfLocalOnly => 'Guardado solo en este dispositivo';

  @override
  String get chatSelfContactSubtitle => 'Borradores, práctica y notas · nunca se envían';

  @override
  String get learnShowFewerChars => 'Mostrar menos caracteres';
}
