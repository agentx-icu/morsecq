import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../startup/startup_controller.dart';
import 'account_strings.dart';
import 'account_widgets.dart';

/// Display name + optional password (with strength hint and confirmation).
/// On success the page pops back to the gate, which is now showing the
/// mandatory backup wizard.
class CreateIdentityPage extends StatefulWidget {
  const CreateIdentityPage({super.key});

  @override
  State<CreateIdentityPage> createState() => _CreateIdentityPageState();
}

class _CreateIdentityPageState extends State<CreateIdentityPage> {
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _nameError;
  String? _confirmError;
  String? _submitError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _wantsPassword => _password.text.isNotEmpty;

  Future<void> _submit() async {
    final name = _name.text.trim();
    setState(() {
      _nameError = name.isEmpty ? AccountStrings.displayNameRequired : null;
      _confirmError = _wantsPassword && _confirm.text != _password.text
          ? AccountStrings.passwordsDoNotMatch
          : null;
      _submitError = null;
    });
    if (_nameError != null || _confirmError != null) return;

    setState(() => _busy = true);
    final controller = context.read<StartupController>();
    final navigator = Navigator.of(context);
    try {
      await controller.createIdentity(
        displayName: name,
        password: _wantsPassword ? _password.text : null,
      );
      // The gate (route 0) now renders the backup wizard.
      navigator.popUntil((route) => route.isFirst);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _submitError = StartupController.describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AccountStrings.createTitle)),
      body: AccountPageBody(
        children: [
          Text(AccountStrings.createBody, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.next,
            maxLength: 64,
            decoration: InputDecoration(
              labelText: AccountStrings.displayName,
              hintText: AccountStrings.displayNameHint,
              errorText: _nameError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _password,
            label: AccountStrings.passwordOptional,
            showStrength: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          if (_wantsPassword) ...[
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: AccountStrings.confirmPassword,
              errorText: _confirmError,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
          if (_submitError != null) ...[
            const SizedBox(height: 16),
            Text(
              _submitError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(
              _busy ? AccountStrings.creating : AccountStrings.createButton,
            ),
          ),
        ],
      ),
    );
  }
}
