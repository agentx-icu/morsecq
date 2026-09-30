import 'package:flutter/material.dart';

import 'account_strings.dart';

/// Typed-confirmation dialog. Resolves true only when the user typed the
/// confirm word exactly and pressed Delete; the caller performs the deletion.
Future<bool> confirmDeleteIdentity(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const DeleteIdentityDialog(),
  );
  return result ?? false;
}

class DeleteIdentityDialog extends StatefulWidget {
  const DeleteIdentityDialog({super.key});

  @override
  State<DeleteIdentityDialog> createState() => _DeleteIdentityDialogState();
}

class _DeleteIdentityDialogState extends State<DeleteIdentityDialog> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  bool get _confirmed => _typed.text.trim() == AccountStrings.deleteConfirmWord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
      title: const Text(AccountStrings.deleteDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(AccountStrings.deleteDialogBody),
          const SizedBox(height: 16),
          TextField(
            controller: _typed,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_confirmed) Navigator.of(context).pop(true);
            },
            decoration: const InputDecoration(
              hintText: AccountStrings.deleteConfirmHint,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AccountStrings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: _confirmed ? () => Navigator.of(context).pop(true) : null,
          child: const Text(AccountStrings.deleteButton),
        ),
      ],
    );
  }
}
