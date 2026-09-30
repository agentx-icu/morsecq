import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';
import '../contacts/tox_id.dart';

/// Join an NGC group by its 64-hex chat id (+ optional password). Resolves
/// to true when the join was requested; the group shows up in the list once
/// the DHT finds a peer.
Future<bool> showJoinGroupSheet(
  BuildContext context, {
  required ChatService service,
}) async {
  final bool? joined = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: JoinGroupForm(service: service),
    ),
  );
  return joined ?? false;
}

class JoinGroupForm extends StatefulWidget {
  const JoinGroupForm({super.key, required this.service});

  final ChatService service;

  @override
  State<JoinGroupForm> createState() => _JoinGroupFormState();
}

class _JoinGroupFormState extends State<JoinGroupForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _chatId = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _chatId.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await widget.service.joinGroup(
        normalizeToxId(_chatId.text),
        password: _password.text.isEmpty ? null : _password.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ChatStrings.joinGroup, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chatId,
                autofocus: true,
                minLines: 1,
                maxLines: 2,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: ChatStrings.chatIdLabel,
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                validator: validateChatIdInput,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: ChatStrings.password,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : () => unawaited(_submit()),
                icon: const Icon(Icons.login),
                label: const Text(ChatStrings.join),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
