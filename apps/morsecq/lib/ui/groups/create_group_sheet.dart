import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';

/// Create a group. Kind is fixed to NGC; an "advanced" expander exposes the
/// legacy conference switch for interop with old clients (plan §5.4).
/// Resolves to the created group, or null when dismissed.
Future<Group?> showCreateGroupSheet(
  BuildContext context, {
  required ChatService service,
}) {
  return showModalBottomSheet<Group>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CreateGroupForm(service: service),
    ),
  );
}

class CreateGroupForm extends StatefulWidget {
  const CreateGroupForm({super.key, required this.service});

  final ChatService service;

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  bool _advanced = false;
  bool _conference = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final Group group = await widget.service.createGroup(
        _name.text.trim(),
        kind: _conference ? GroupKind.conference : GroupKind.group,
      );
      if (mounted) Navigator.of(context).pop(group);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ChatStrings.createGroup, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => unawaited(_submit()),
                decoration: InputDecoration(
                  labelText: ChatStrings.groupName,
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? ChatStrings.groupNameRequired
                    : null,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _advanced = !_advanced),
                icon: Icon(_advanced ? Icons.expand_less : Icons.expand_more),
                label: const Text(ChatStrings.advanced),
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              ),
              if (_advanced)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(ChatStrings.legacyConference),
                  subtitle: const Text(ChatStrings.legacyConferenceHint),
                  value: _conference,
                  onChanged: (v) => setState(() => _conference = v),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _busy ? null : () => unawaited(_submit()),
                icon: const Icon(Icons.group_add),
                label: const Text(ChatStrings.create),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
