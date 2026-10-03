import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import '../../startup/startup_controller.dart';
import 'account_widgets.dart';
import 'backup_file_gateway.dart';

/// Pick a backup file → optional password → `importBackup`. Reached from the
/// welcome page and from the unlock screen ("restore instead").
class RestoreBackupPage extends StatefulWidget {
  const RestoreBackupPage({super.key});

  @override
  State<RestoreBackupPage> createState() => _RestoreBackupPageState();
}

class _RestoreBackupPageState extends State<RestoreBackupPage> {
  final _password = TextEditingController();
  Uint8List? _bytes;
  String? _fileError;
  String? _passwordError;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final s = context.s;
    final gateway = context.read<BackupFileGateway>();
    try {
      final bytes = await gateway.pickBackup();
      if (!mounted || bytes == null) return;
      setState(() {
        _bytes = bytes;
        _fileError = null;
        _passwordError = null;
      });
    } on ChatException catch (e) {
      if (!mounted) return;
      // invalid_backup (e.g. a file far too large to be a backup) is
      // backup-only and not in the shared chat error table.
      setState(
        () => _fileError = e.code == 'invalid_backup'
            ? s.accountRestoreInvalidFile
            : describeChatError(s, e),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _fileError = describeChatError(s, e));
    }
  }

  Future<void> _restore() async {
    final s = context.s;
    final bytes = _bytes;
    if (bytes == null) {
      setState(() => _fileError = s.accountRestoreNoFile);
      return;
    }
    setState(() {
      _busy = true;
      _fileError = null;
      _passwordError = null;
    });
    final controller = context.read<StartupController>();
    final navigator = Navigator.of(context);
    try {
      await controller.restoreFromBackup(
        bytes,
        password: _password.text.isEmpty ? null : _password.text,
      );
      navigator.popUntil((route) => route.isFirst);
    } on ChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        switch (e.code) {
          case 'wrong_password':
            _passwordError = describeChatError(s, e);
          case 'invalid_backup':
            // Backup-only code; not part of the shared chat error table.
            _fileError = s.accountRestoreInvalidFile;
          default:
            _fileError = describeChatError(s, e);
        }
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _fileError = describeChatError(s, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final hasCurrent = context.read<IdentityService>().current != null;
    final bytes = _bytes;
    return Scaffold(
      appBar: AppBar(title: Text(s.accountRestoreTitle)),
      body: AccountPageBody(
        children: [
          Text(s.accountRestoreBody, style: theme.textTheme.bodyMedium),
          if (hasCurrent) ...[
            const SizedBox(height: 12),
            Text(
              s.accountRestoreReplacesWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.folder_open),
            label: Text(s.accountRestoreChooseFile),
          ),
          if (bytes != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.accountRestoreFileChosenSize(bytes.length),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          if (_fileError != null) ...[
            const SizedBox(height: 8),
            Text(
              _fileError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          PasswordField(
            controller: _password,
            label: s.accountPasswordOptional,
            errorText: _passwordError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _restore(),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _busy ? null : _restore,
            child: Text(_busy ? s.accountRestoring : s.accountRestoreButton),
          ),
        ],
      ),
    );
  }
}
