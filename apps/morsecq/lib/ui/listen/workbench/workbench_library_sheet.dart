import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_session/morse_session.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../../common/feedback.dart';
import '../../common/field_label.dart';
import 'recording_files.dart';
import 'workbench_controller.dart';
import 'workbench_errors.dart';
import 'workbench_waveform.dart';

/// Asks for a title and note; returns null when cancelled.
Future<(String, String)?> showSaveSelectionDialog(
  BuildContext context,
  String suggestedTitle,
) => showDialog<(String, String)>(
  context: context,
  builder: (_) => _SaveDialog(suggestedTitle),
);

/// Owns its text controllers so they outlive the closing animation.
class _SaveDialog extends StatefulWidget {
  const _SaveDialog(this.suggestedTitle);

  final String suggestedTitle;

  @override
  State<_SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<_SaveDialog> {
  late final _title = TextEditingController(text: widget.suggestedTitle);
  final _note = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ScrollingAlertDialog(
      title: Text(s.workbenchSave),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            key: const ValueKey('workbench-save-title'),
            controller: _title,
            decoration: InputDecoration(
              label: FieldLabel(s.workbenchSaveTitle),
            ),
          ),
          TextField(
            controller: _note,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(label: FieldLabel(s.workbenchSaveNote)),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.actionCancel),
        ),
        FilledButton(
          key: const ValueKey('workbench-save-confirm'),
          onPressed: () => Navigator.of(context).pop((
            _title.text.trim().isEmpty
                ? widget.suggestedTitle
                : _title.text.trim(),
            _note.text.trim(),
          )),
          child: Text(s.workbenchSave),
        ),
      ],
    );
  }
}

/// Saved selections: open one, relink a missing recording, or delete the
/// entry. A missing media file never blocks the list.
Future<void> showWorkbenchLibrary(
  BuildContext context, {
  required WorkbenchController controller,
  required TrainingController training,
  required RecordingPicker? picker,
  required ValueChanged<WorkbenchController?> onFailure,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _LibrarySheet(
    controller: controller,
    training: training,
    picker: picker,
    onFailure: onFailure,
  ),
);

class _LibrarySheet extends StatefulWidget {
  const _LibrarySheet({
    required this.controller,
    required this.training,
    required this.picker,
    required this.onFailure,
  });

  final WorkbenchController controller;
  final TrainingController training;
  final RecordingPicker? picker;
  final ValueChanged<WorkbenchController?> onFailure;

  @override
  State<_LibrarySheet> createState() => _LibrarySheetState();
}

class _LibrarySheetState extends State<_LibrarySheet> {
  List<(AudioMaterial, bool)>? _items;
  bool _busy = false;
  (String, String)? _relinkFailure;

  @override
  void initState() {
    super.initState();
    unawaited(_run(_reload));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on Object {
      if (mounted) widget.onFailure(null);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reload() async {
    final all = await widget.training.loadAudioMaterials();
    final items = <(AudioMaterial, bool)>[
      for (final m in all) (m, await widget.controller.library.exists(m.file)),
    ];
    if (mounted) setState(() => _items = items);
  }

  Future<void> _open(AudioMaterial m) => _run(() async {
    final ok = await widget.controller.openSaved(
      m.file,
      m.title,
      selection: (m.start, m.end),
      originalName: m.originalName,
    );
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pop();
    if (!ok) widget.onFailure(widget.controller);
  });

  Future<void> _relink(AudioMaterial m) => _run(() async {
    final picked =
        await (widget.picker ??
                PlatformRecordingPicker(dialogTitle: context.s.workbenchRelink))
            .pick();
    if (picked == null ||
        !mounted ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    if (await widget.controller.relinkRecording(
      picked,
      m,
      training: widget.training,
    )) {
      if (mounted) {
        setState(() => _relinkFailure = null);
        await _reload();
      }
    } else if (mounted) {
      setState(() {
        _relinkFailure = (
          m.id,
          workbenchFailureText(context.s, widget.controller),
        );
      });
    }
  });

  Future<void> _delete(AudioMaterial m) => _run(() async {
    final s = context.s;
    final removesCopy =
        m.file != widget.controller.file &&
        m.file != RecordingLibrary.workingFile &&
        _items?.any((item) => item.$1.id == m.id && item.$2) == true &&
        _items?.any((item) => item.$1.id != m.id && item.$1.file == m.file) ==
            false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(s.workbenchDeleteTitle),
        content: Text(
          removesCopy
              ? s.workbenchDeleteWithCopy(m.title)
              : s.workbenchDeleteSelection(m.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(s.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('workbench-delete-confirm'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(s.workbenchDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await widget.controller.deleteSaved(widget.training, m);
    if (mounted) {
      if (!ok) widget.onFailure(widget.controller);
      await _reload();
    }
  });

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final items = _items;
    final references = <String, int>{};
    for (final (m, _) in items ?? <(AudioMaterial, bool)>[]) {
      references.update(m.file, (count) => count + 1, ifAbsent: () => 1);
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              s.workbenchLibrary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (items == null)
              if (_busy)
                const Center(child: CircularProgressIndicator())
              else
                TextButton(
                  onPressed: () => _run(_reload),
                  child: Text(s.actionRetry),
                )
            else if (items.isEmpty)
              Text(s.workbenchLibraryEmpty)
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final (m, present) in items)
                      ListTile(
                        key: ValueKey('workbench-item-${m.id}'),
                        minTileHeight: 56,
                        title: Text(m.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${formatClock(m.start)} – ${formatClock(m.end)}'
                              '${m.note.isEmpty ? '' : '\n${m.note}'}',
                            ),
                            if (!present) ...[
                              if (m.originalName.isNotEmpty)
                                Text(m.originalName),
                              Text(s.workbenchMissing),
                              Text(s.workbenchRelinkFormat),
                              if ((references[m.file] ?? 0) > 1)
                                Text(
                                  s.workbenchRelinkShared(references[m.file]!),
                                ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Tooltip(
                                    message: s.workbenchRelink,
                                    excludeFromSemantics: true,
                                    child: FilledButton.tonalIcon(
                                      onPressed: _busy
                                          ? null
                                          : () => _relink(m),
                                      icon: const Icon(Icons.link),
                                      label: Text(s.workbenchRelink),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _busy ? null : () => _delete(m),
                                    icon: const Icon(Icons.delete_outline),
                                    label: Text(s.workbenchDelete),
                                  ),
                                ],
                              ),
                            ],
                            if (_relinkFailure case (
                              final id,
                              final message,
                            ) when id == m.id)
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: present && !_busy ? () => _open(m) : null,
                        trailing: present
                            ? IconButton(
                                tooltip: s.workbenchDelete,
                                onPressed: _busy ? null : () => _delete(m),
                                icon: const Icon(Icons.delete_outline),
                              )
                            : null,
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
