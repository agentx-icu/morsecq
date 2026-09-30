import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_layout.dart';
import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';
import 'qr_scan_page.dart';
import 'tox_id.dart';

/// Bottom sheet: paste a Tox ID (validated live), optional greeting, QR scan
/// on phones. Resolves to true when a request was sent.
Future<bool> showAddFriendSheet(
  BuildContext context, {
  required ChatService service,
  String? ownToxId,
  bool? canScan,
}) async {
  final bool? sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AddFriendForm(
        service: service,
        ownToxId: ownToxId,
        canScan: canScan ?? isTouchPlatform,
      ),
    ),
  );
  return sent ?? false;
}

class AddFriendForm extends StatefulWidget {
  const AddFriendForm({
    super.key,
    required this.service,
    this.ownToxId,
    this.canScan = false,
  });

  final ChatService service;
  final String? ownToxId;

  /// Whether the QR button is enabled (phones); desktop shows a hint instead.
  final bool canScan;

  @override
  State<AddFriendForm> createState() => _AddFriendFormState();
}

class _AddFriendFormState extends State<AddFriendForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _message = TextEditingController(
    text: ChatStrings.defaultRequestMessage,
  );
  String? _serverError;
  bool _busy = false;

  @override
  void dispose() {
    _id.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final String? scanned = await QrScanPage.open(context);
    if (scanned == null || !mounted) return;
    _id.text = scanned;
    _form.currentState?.validate();
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await widget.service.addFriend(
        normalizeToxId(_id.text),
        message: _message.text.trim().isEmpty
            ? ChatStrings.defaultRequestMessage
            : _message.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverError = switch (e.code) {
          'invalid_tox_id' => ChatStrings.toxIdInvalid,
          'own_id' => ChatStrings.toxIdOwn,
          'already_friend' => ChatStrings.toxIdAlreadyFriend,
          _ => e.message,
        };
      });
    } on Object catch (e) {
      if (mounted) setState(() => _serverError = describeError(e));
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
              Text(ChatStrings.addFriend, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _id,
                autofocus: true,
                maxLines: 2,
                minLines: 1,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: ChatStrings.toxIdLabel,
                  border: const OutlineInputBorder(),
                  errorText: _serverError,
                  suffixIcon: Tooltip(
                    message: widget.canScan
                        ? ChatStrings.scanQr
                        : ChatStrings.scanQrDesktopHint,
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: widget.canScan
                          ? () => unawaited(_scan())
                          : null,
                    ),
                  ),
                ),
                validator: (v) =>
                    validateToxIdInput(v, ownToxId: widget.ownToxId),
                onChanged: (_) {
                  if (_serverError != null) {
                    setState(() => _serverError = null);
                  }
                },
              ),
              if (!widget.canScan)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    ChatStrings.scanQrDesktopHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _message,
                decoration: const InputDecoration(
                  labelText: ChatStrings.requestMessage,
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _busy ? null : () => unawaited(_submit()),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text(ChatStrings.sendRequest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
