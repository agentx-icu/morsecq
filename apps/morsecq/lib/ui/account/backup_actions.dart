import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import 'backup_file_gateway.dart';

/// File name for a backup of [identity]: readable, unique per identity, and
/// with an extension the restore picker can recognise.
String backupFileName(Identity identity) {
  final safeName = identity.displayName
      .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final prefix = safeName.isEmpty ? 'identity' : safeName;
  return 'morsecq-$prefix-${identity.publicKey.substring(0, 8)}.mcqbackup';
}

/// Outcome of [exportBackupWithFeedback].
enum BackupExportResult { saved, cancelled, failed }

/// Exports the current identity through the [BackupFileGateway] and reports
/// the outcome with a snackbar. Shared by the first-run wizard and the Me
/// page so both surfaces behave identically on every platform.
Future<BackupExportResult> exportBackupWithFeedback(
  BuildContext context,
) async {
  final s = context.s;
  final identityService = context.read<IdentityService>();
  final gateway = context.read<BackupFileGateway>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final identity = identityService.current;
  if (identity == null) {
    messenger?.showSnackBar(SnackBar(content: Text(s.accountMeNoIdentity)));
    return BackupExportResult.failed;
  }
  try {
    final bytes = await identityService.exportBackup();
    final saved = await gateway.saveBackup(
      bytes,
      fileName: backupFileName(identity),
    );
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          saved ? s.accountBackupSaved : s.accountBackupNotSaved,
        ),
      ),
    );
    return saved ? BackupExportResult.saved : BackupExportResult.cancelled;
  } on Object catch (e) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text('${s.accountBackupFailed}: ${describeChatError(s, e)}'),
      ),
    );
    return BackupExportResult.failed;
  }
}
