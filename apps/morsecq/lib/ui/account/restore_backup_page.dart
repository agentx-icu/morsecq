import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../startup/startup_controller.dart';
import 'account_strings.dart';
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
    final gateway = context.read<BackupFileGateway>();
    try {
      final bytes = await gateway.pickBackup();
      if (!mounted || bytes == null) return;
      setState(() {
        _bytes = bytes;
        _fileError = null;
        _passwordError = null;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _fileError = StartupController.describeError(e));
    }
  }

  Future<void> _restore() async {
    final bytes = _bytes;
    if (bytes == null) {
      setState(() => _fileError = AccountStrings.restoreNoFile);
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
        if (e.code == 'wrong_password') {
          _passwordError = AccountStrings.wrongPassword;
        } else if (e.code == 'invalid_backup') {
          _fileError = AccountStrings.restoreInvalidFile;
        } else {
          _fileError = e.message;
        }
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _fileError = StartupController.describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCurrent = context.read<IdentityService>().current != null;
    return Scaffold(
      appBar: AppBar(title: const Text(AccountStrings.restoreTitle)),
      body: AccountPageBody(
        children: [
          Text(AccountStrings.restoreBody, style: theme.textTheme.bodyMedium),
          if (hasCurrent) ...[
            const SizedBox(height: 12),
            Text(
              AccountStrings.restoreReplacesWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.folder_open),
            label: const Text(AccountStrings.restoreChooseFile),
          ),
          if (_bytes != null) ...[
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
                    '${AccountStrings.restoreFileChosen} '
                    '(${_bytes!.length} bytes)',
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
            label: AccountStrings.passwordOptional,
            errorText: _passwordError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _restore(),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _busy ? null : _restore,
            child: Text(
              _busy ? AccountStrings.restoring : AccountStrings.restoreButton,
            ),
          ),
        ],
      ),
    );
  }
}
