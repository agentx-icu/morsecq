import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import 'chat_layout.dart';
import 'chat_scope.dart';
import 'keying_input.dart';
import 'input_mode.dart';
import 'local_message_sends.dart';
import 'morse_pattern_text.dart';
import 'morse_playback_controller.dart';
import 'morse_playback_settings.dart';

/// Input modes from plan §5.3: typed text (auto-encoded), straight key,
/// iambic paddles. Hand-keyed characters land in the same draft field, so
/// the operator can mix modes and fix typos before sending.
export 'input_mode.dart';

// Share write ordering across editors for the same service and conversation.
// A pending dispose flush must finish before a reopened editor's newer draft.
final _draftWriters = Expando<Map<String, _DraftWriter>>();

_DraftWriter _writerFor(ChatService service, String id) {
  final writers = _draftWriters[service] ??= {};
  return writers.putIfAbsent(
    id,
    () => _DraftWriter((writer) {
      if (identical(writers[id], writer)) writers.remove(id);
    }),
  );
}

class _DraftWriter {
  _DraftWriter(this._invalidate);
  final void Function(_DraftWriter) _invalidate;
  Future<void> _tail = Future<void>.value();
  Future<void> get settled => _tail;
  int pending = 0;
  String latest = '';
  String savedDraft = '';
  Object? error;
  bool valid = true;
  TextEditingController? _controller;
  int _editors = 0;
  StreamSubscription<Identity?>? _identitySub;

  TextEditingController acquire(
    String initialDraft,
    IdentityService? identity,
  ) {
    if (_editors == 0 && pending == 0 && error == null) {
      savedDraft = latest = initialDraft;
    }
    _editors++;
    if (_identitySub == null && identity != null) {
      final key = identity.current?.publicKey;
      _identitySub = identity.identityChanges.listen((value) {
        if (value == null || value.publicKey != key) {
          valid = false;
          _invalidate(this);
          unawaited(_identitySub?.cancel());
          _identitySub = null;
        }
      });
    }
    return _controller ??= TextEditingController(
      text: pending > 0 || error != null ? latest : initialDraft,
    );
  }

  void _releaseIdleObserver() {
    if (_editors == 0 && pending == 0 && error == null) {
      _invalidate(this);
      unawaited(_identitySub?.cancel());
      _identitySub = null;
    }
  }

  void release() {
    if (--_editors == 0) {
      _controller?.dispose();
      _controller = null;
      _releaseIdleObserver();
    }
  }

  Future<void> save(String draft, Future<void> Function() write) {
    latest = draft;
    pending++;
    return _tail = _tail.then((_) async {
      try {
        await write();
      } finally {
        pending--;
        _releaseIdleObserver();
      }
    });
  }
}

/// The compose area: mode selector, optional keying pad, draft field with
/// live Morse preview and remaining-byte counter, send button. Drafts are
/// persisted through [ChatService.setDraft] (debounced, flushed on dispose).
class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.service,
    required this.conversationId,
    required this.playback,
    this.initialDraft = '',
    this.onSent,
  });

  final ChatService service;
  final String conversationId;
  final MorsePlaybackController playback;
  final String initialDraft;
  final ValueChanged<ChatMessage>? onSent;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with WidgetsBindingObserver
    implements IdentityDataStore {
  static const Duration _draftDebounce = Duration(milliseconds: 400);

  late final _DraftWriter _writer = _writerFor(
    widget.service,
    widget.conversationId,
  );
  // Multiple routes can open the same conversation. Share their text so each
  // editor observes every edit revision, and an older send cannot clear it.
  late final TextEditingController _text = _writer.acquire(
    widget.initialDraft,
    _identity,
  );
  final FocusNode _focus = FocusNode();
  InputMode _mode = InputMode.keyboard;
  Timer? _draftTimer;
  late String _lastDraft;
  int _editRevision = 0;
  bool _sending = false;
  IdentityService? _identity;
  String? _identityKey;
  bool _acceptDrafts = true;
  StreamSubscription<Identity?>? _identitySub;
  bool _identityInvalidated = false;

  @override
  void initState() {
    super.initState();
    _mode = MorsePlaybackSettings.of(context, listen: false).inputMode;
    _identity = maybeIdentityService(context);
    _lastDraft = _text.text;
    _identityKey = _identity?.current?.publicKey;
    _identitySub = _identity?.identityChanges.listen((identity) {
      if (identity == null || identity.publicKey != _identityKey) {
        _identityInvalidated = true;
        _acceptDrafts = false;
        _draftTimer?.cancel();
      } else if (!_identityInvalidated) {
        // Failed replacement republishes the old identity without a null
        // boundary. A committed same-key restore must keep this editor stale.
        _acceptDrafts = true;
      }
    });
    final identity = _identity;
    if (identity is PersistentIdentityService) identity.registerDataStore(this);
    _text.addListener(_onChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_identitySub?.cancel());
    final identity = _identity;
    if (identity is PersistentIdentityService) {
      identity.unregisterDataStore(this);
    }
    _draftTimer?.cancel();
    unawaited(_persistDraft());
    _text.removeListener(_onChanged);
    _writer.release();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Selection/focus changes do not create a new draft revision.
    if (_text.text == _lastDraft) return;
    _lastDraft = _text.text;
    _editRevision++;
    setState(() {});
    _draftTimer?.cancel();
    _draftTimer = Timer(_draftDebounce, () => unawaited(_persistDraft()));
  }

  Future<void> _persistDraft() {
    final String draft = _lastDraft;
    if (!_acceptDrafts || !_writer.valid) return _writer.settled;
    if (_writer.pending > 0 && draft == _writer.latest) return _writer.settled;
    if (_writer.pending == 0 &&
        draft == _writer.savedDraft &&
        _writer.error == null) {
      return _writer.settled;
    }
    final service = widget.service;
    final conversationId = widget.conversationId;
    return _writer.save(draft, () async {
      if (!_acceptDrafts ||
          !_writer.valid ||
          (_identity != null &&
              _identity?.current?.publicKey != _identityKey)) {
        return;
      }
      try {
        await service.setDraft(conversationId, draft);
        _writer.savedDraft = draft;
        _writer.error = null;
      } on Object catch (error) {
        _writer.error = error;
        debugPrint('[MessageInput] draft save failed: $error');
      }
    });
  }

  @override
  Future<void> flush() async {
    _draftTimer?.cancel();
    await _persistDraft();
    if (_writer.error != null && _acceptDrafts && _writer.valid) {
      throw StateError('Could not save compose draft: ${_writer.error}');
    }
  }

  @override
  Future<void> prepareForReplacement() {
    _acceptDrafts = false;
    _draftTimer?.cancel();
    return _writer.settled;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(
        flush().catchError((Object error) {
          debugPrint('[MessageInput] background flush failed: $error');
        }),
      );
    }
  }

  int get _bytesUsed => utf8.encode(_text.text).length;

  int get _bytesLeft => widget.service.maxMessageBytes - _bytesUsed;

  bool get _canSend =>
      !_sending && _text.text.trim().isNotEmpty && _bytesLeft >= 0;

  Future<void> _send() async {
    if (!_canSend) return;
    final String text = _text.text.trim();
    final int revision = _editRevision;
    final S s = context.s;
    setState(() => _sending = true);
    try {
      final ChatMessage sent = await widget.service.sendText(
        widget.conversationId,
        text,
      );
      LocalMessageSends.forService(widget.service).publish(sent);
      if (!mounted) return;
      _draftTimer?.cancel();
      if (_editRevision == revision) _text.clear();
      unawaited(_persistDraft());
      widget.onSent?.call(sent);
    } on Object catch (e) {
      if (mounted) showSnack(context, describeChatError(s, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _appendDecoded(String text) {
    final String current = _text.text;
    // A word gap right after nothing (or after a space) adds no information.
    if (text == ' ' && (current.isEmpty || current.endsWith(' '))) return;
    _text.value = TextEditingValue(
      text: current + text,
      selection: TextSelection.collapsed(offset: current.length + text.length),
    );
  }

  void _deleteLast() {
    final String current = _text.text;
    if (current.isEmpty) return;
    final String next = current.substring(0, current.length - 1);
    _text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final S s = context.s;
    final MorsePlaybackSettings settings = MorsePlaybackSettings.of(context);
    final String pattern = MorseEncoder.toPattern(_text.text);
    final int left = _bytesLeft;
    final bool tooLong = left < 0;

    return Material(
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: LayoutBuilder(
                builder: (context, constraints) => _ModeSelector(
                  mode: _mode,
                  // Icon-only below ~420 px so all three segments fit a phone.
                  showLabels: constraints.maxWidth >= 420,
                  onChanged: (m) {
                    setState(() => _mode = m);
                    settings.inputMode = m;
                  },
                ),
              ),
            ),
            if (_mode != InputMode.keyboard)
              KeyingInput(
                key: ValueKey<InputMode>(_mode),
                mode: _mode == InputMode.straightKey
                    ? KeyingMode.straightKey
                    : KeyingMode.paddles,
                timing: settings.timing,
                sink: widget.playback.sink,
                clock: widget.playback.clock,
                onText: _appendDecoded,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => unawaited(_send()),
                      decoration: InputDecoration(
                        hintText: s.chatTypeMessage,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        errorText: tooLong ? s.chatTooLong : null,
                      ),
                    ),
                  ),
                  if (_mode != InputMode.keyboard)
                    IconButton(
                      tooltip: s.chatDeleteLast,
                      onPressed: _text.text.isEmpty ? null : _deleteLast,
                      icon: const Icon(Icons.backspace_outlined),
                    ),
                  IconButton.filled(
                    tooltip: s.chatSend,
                    onPressed: _canSend ? () => unawaited(_send()) : null,
                    icon: _sending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MorsePatternText(
                      pattern.isEmpty ? ' ' : pattern,
                      maxLines: 2,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.chatBytesLeftCount(left),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tooLong ? scheme.error : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.showLabels,
    required this.onChanged,
  });

  final InputMode mode;
  final bool showLabels;
  final ValueChanged<InputMode> onChanged;

  ButtonSegment<InputMode> _segment(
    InputMode value,
    IconData icon,
    String label,
  ) => ButtonSegment<InputMode>(
    value: value,
    icon: Icon(icon),
    label: showLabels ? Text(label) : null,
    tooltip: label,
  );

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return SegmentedButton<InputMode>(
      showSelectedIcon: false,
      selected: <InputMode>{mode},
      onSelectionChanged: (sel) => onChanged(sel.first),
      segments: [
        _segment(
          InputMode.keyboard,
          Icons.keyboard_alt_outlined,
          s.chatModeKeyboard,
        ),
        _segment(
          InputMode.straightKey,
          Icons.radio_button_checked,
          s.chatModeStraightKey,
        ),
        _segment(
          InputMode.paddles,
          Icons.view_column_outlined,
          s.chatModePaddles,
        ),
      ],
    );
  }
}
