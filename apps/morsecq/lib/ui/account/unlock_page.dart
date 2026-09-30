import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../startup/startup_controller.dart';
import 'account_strings.dart';
import 'account_widgets.dart';
import 'restore_backup_page.dart';

/// Password prompt for an encrypted profile. The password is never persisted;
/// every cold start comes back here (same fail-closed stance as toxee).
class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_password.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<StartupController>().unlock(_password.text);
      // On success the gate swaps this page out; nothing to do here.
    } on ChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.code == 'wrong_password'
            ? AccountStrings.wrongPassword
            : e.message;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = StartupController.describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AccountPageBody(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            AccountStrings.unlockTitle,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AccountStrings.unlockBody,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PasswordField(
            controller: _password,
            label: AccountStrings.password,
            errorText: _error,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _unlock(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy || _password.text.isEmpty ? null : _unlock,
            child: Text(
              _busy ? AccountStrings.unlocking : AccountStrings.unlockButton,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RestoreBackupPage(),
              ),
            ),
            child: const Text(AccountStrings.unlockRestoreInstead),
          ),
        ],
      ),
    );
  }
}
