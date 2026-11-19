import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:morse_dsp/morse_dsp.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_session/morse_session.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/local_learning_store.dart';
import '../../../training/training_controller.dart';
import '../../../training/training_controller_host.dart';
import '../../common/app_bar_title.dart';
import '../../learn/learning_unavailable.dart';
import 'recording_files.dart';
import 'workbench_controller.dart';
import 'workbench_decode_panel.dart';
import 'workbench_library_sheet.dart';
import 'workbench_waveform.dart';

/// Recorded-audio copying workbench (functional spec §11): import a WAV
/// recording, select and loop a part, decode it or copy it yourself, and
/// keep selections as local audio materials. Imports need no microphone
/// permission; nothing is ever sent anywhere.
class WorkbenchScreen extends StatefulWidget {
  const WorkbenchScreen({
    super.key,
    this.picker,
    this.player,
    this.profileRoot,
    this.training,
    this.iosRouteChanges,
    this.iosInterruptions,
  });

  /// Injected in tests; defaults to the platform file picker.
  final RecordingPicker? picker;

  /// Injected in tests; defaults to SoLoud.
  final ClipPlayer? player;

  /// The learning profile's media root ([RecordingLibrary.root]);
  /// defaults to the local learning directory.
  final Future<String> Function()? profileRoot;

  /// The shared training controller; defaults to the app's host.
  final Future<TrainingController> Function()? training;

  /// Injected in tests; defaults to the iOS audio session route stream.
  final Stream<AVAudioSessionRouteChange>? iosRouteChanges;

  /// Injected in tests; defaults to the iOS audio session interruptions.
  final Stream<AVAudioSessionInterruptionNotification>? iosInterruptions;

  @override
  State<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

/// The local learning directory also owns managed audio recordings.
Future<String> _profileDirectory(BuildContext context) {
  return context.read<LocalLearningStore>().directory();
}

class _WorkbenchScreenState extends State<WorkbenchScreen>
    with WidgetsBindingObserver {
  WorkbenchController? _c;
  TrainingController? _training;
  late final ClipPlayer _player = widget.player ?? SoloudClipPlayer();
  StreamSubscription<AVAudioSessionRouteChange>? _routeSubscription;
  StreamSubscription<AVAudioSessionInterruptionNotification>? _interruptionSub;
  bool _unavailable = false;
  bool _runningAction = false;

  bool get _mediaBusy => _runningAction || (_c?.busy ?? false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final session = !kIsWeb && Platform.isIOS ? AVAudioSession() : null;
    final routes = widget.iosRouteChanges ?? session?.routeChangeStream;
    _routeSubscription = routes?.listen((change) {
      if (change.reason ==
          AVAudioSessionRouteChangeReason.oldDeviceUnavailable) {
        unawaited(_c?.stopPlayback());
      }
    });
    final interruptions =
        widget.iosInterruptions ?? session?.interruptionNotificationStream;
    _interruptionSub = interruptions?.listen((notification) {
      // SoLoud restarts its output device when the interruption ends. Drop
      // the clip so playback still requires a new user action.
      if (notification.type == AVAudioSessionInterruptionType.began &&
          notification.wasSuspended != true) {
        unawaited(_c?.stopPlayback());
      }
    });
    unawaited(_setup());
  }

  Future<void> _setup() async {
    if (_unavailable) setState(() => _unavailable = false);
    try {
      final dir =
          await (widget.profileRoot ?? () => _profileDirectory(context))();
      if (!mounted) return;
      final controller = WorkbenchController(
        library: RecordingLibrary(dir),
        player: _player,
      )..addListener(_changed);
      // A retry replaces the controller of the failed attempt (the player
      // is the screen's and stays).
      final previous = _c;
      setState(() => _c = controller);
      previous
        ?..removeListener(_changed)
        ..dispose();
    } on Object {
      if (mounted) setState(() => _unavailable = true);
      return;
    }
    final TrainingController training;
    try {
      training = await (widget.training ?? _hostController)();
    } on Object {
      // A missing local store still allows transient audio decoding.
      // The offline build always has its profile, so a failure is a storage
      // problem: say so and offer a retry.
      if (mounted && learningRetryable(context)) {
        setState(() => _unavailable = true);
      }
      return;
    }
    try {
      // Saving and library actions are unavailable until sweeping finishes.
      final library = _c?.library;
      if (mounted && library != null) {
        await sweepUnreferencedRecordings(training, library);
      }
    } on Object {
      // Housekeeping only.
    }
    if (mounted) setState(() => _training = training);
  }

  Future<TrainingController> _hostController() {
    final host = context.read<TrainingControllerHost?>();
    if (host == null) throw StateError('no training host');
    return host.controller();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop on background; playing again is the learner's choice.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_c?.stopPlayback());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_routeSubscription?.cancel());
    unawaited(_interruptionSub?.cancel());
    _c?.dispose();
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_mediaBusy) return;
    setState(() => _runningAction = true);
    try {
      await action();
    } on Object {
      if (mounted) _showFailure(null);
    } finally {
      if (mounted) setState(() => _runningAction = false);
    }
  }

  Future<void> _import() => _runAction(() async {
    final c = _c;
    if (c == null) return;
    final picker =
        widget.picker ??
        PlatformRecordingPicker(dialogTitle: context.s.workbenchImport);
    final picked = await picker.pick();
    if (picked == null || !mounted) return;
    final ok = await c.importRecording(picked);
    if (!ok && mounted) _showFailure(c);
  });

  void _showFailure(WorkbenchController? c) {
    if (mounted) _showMessage(failureText(context.s, c));
  }

  void _showMessage(String text) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _save() => _runAction(() async {
    final c = _c;
    final training = _training;
    final info = c?.info;
    if (c == null || training == null || info == null) return;
    final s = context.s;
    final originalName = c.name ?? '';
    final start = c.positionOf(c.start);
    final end = c.positionOf(c.end);
    var file = c.file;
    final entry = await showSaveSelectionDialog(context, originalName);
    if (entry == null || !mounted) return;
    final id = training.newAudioMaterialId();
    var ok = true;
    try {
      if (file == RecordingLibrary.workingFile) {
        file = 'media/recordings/$id.wav';
        await c.library.keepWorkingAs(file);
      }
      await training.upsertAudioMaterial(
        AudioMaterial(
          id: id,
          title: entry.$1,
          note: entry.$2,
          file: file,
          originalName: originalName,
          start: start,
          end: end,
          sampleRate: info.sampleRate,
          channels: info.channels,
          createdAt: training.now(),
        ),
      );
    } on Object {
      ok = false;
    }
    if (!mounted) return;
    _showMessage(ok ? s.workbenchSaved : s.workbenchSaveFailed);
  });

  Future<void> _library() => _runAction(() async {
    final c = _c;
    final training = _training;
    if (c == null || training == null) return;
    await showWorkbenchLibrary(
      context,
      controller: c,
      training: training,
      picker: widget.picker,
      onFailure: _showFailure,
    );
  });

  Future<void> _play(WorkbenchController c) async {
    if (!await c.togglePlay() && mounted) {
      _showMessage(context.s.comprehensionAudioFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = _c;
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(s.workbenchTitle),
        actions: <Widget>[
          IconButton(
            tooltip: s.workbenchLibrary,
            onPressed: _training == null || _mediaBusy ? null : _library,
            icon: const Icon(Icons.library_music_outlined),
          ),
          IconButton(
            key: const ValueKey('workbench-import'),
            tooltip: s.workbenchImport,
            onPressed: c == null || _mediaBusy ? null : _import,
            icon: const Icon(Icons.file_open_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: _unavailable
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        learningUnavailableText(context),
                        textAlign: TextAlign.center,
                      ),
                      if (learningRetryable(context)) ...[
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          key: const ValueKey('workbench-retry'),
                          onPressed: () => unawaited(_setup()),
                          child: Text(s.actionRetry),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : c == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: c.info == null ? _empty(context, c) : _loaded(c),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _empty(BuildContext context, WorkbenchController c) {
    final s = context.s;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          Icons.audio_file_outlined,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(s.workbenchEmpty, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          s.workbenchFormats,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          s.workbenchBackupNote,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (c.busy)
          const Center(child: CircularProgressIndicator())
        else
          FilledButton.icon(
            key: const ValueKey('workbench-import-empty'),
            onPressed: _mediaBusy ? null : _import,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(s.workbenchImport),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
      ],
    );
  }

  Widget _loaded(WorkbenchController c) {
    final s = context.s;
    final theme = Theme.of(context);
    final info = c.info!;
    final rate = (info.sampleRate / 1000).toStringAsFixed(
      info.sampleRate % 1000 == 0 ? 0 : 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(c.name ?? '', style: theme.textTheme.titleMedium),
        Text(
          s.workbenchInfo(
            rate,
            info.channels == 1 ? s.workbenchMono : s.workbenchStereo,
            formatClock(info.duration),
          ),
          key: const ValueKey('workbench-info'),
        ),
        Text(s.workbenchBackupNote, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        WorkbenchWaveform(key: ValueKey(c.recordingKey), controller: c),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilledButton.tonalIcon(
              key: const ValueKey('workbench-play'),
              onPressed: c.busy ? null : () => _play(c),
              icon: Icon(
                c.playing || c.preparingPlayback
                    ? Icons.stop
                    : Icons.play_arrow,
              ),
              label: Text(
                c.preparingPlayback
                    ? s.workbenchCancel
                    : c.playing
                    ? s.workbenchStop
                    : s.workbenchPlay,
              ),
            ),
            FilterChip(
              label: Text(s.workbenchLoop),
              selected: c.loop,
              onSelected: c.setLoop,
            ),
            OutlinedButton.icon(
              key: const ValueKey('workbench-save'),
              onPressed: _training == null || _mediaBusy ? null : _save,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(s.workbenchSave),
            ),
          ],
        ),
        if (c.positionOf(c.end - c.start) > WorkbenchController.maxPlay)
          Text(s.workbenchPlayLimit, style: theme.textTheme.bodySmall),
        const Divider(height: 32),
        WorkbenchDecodePanel(controller: c, training: _training),
      ],
    );
  }
}

/// Localised reason an import or open failed.
String failureText(S s, WorkbenchController? c) => switch (c?.failure) {
  WorkbenchFailure.missingFile => s.workbenchErrorMissing,
  WorkbenchFailure.io || null => s.workbenchErrorIo,
  WorkbenchFailure.format => switch (c?.wavError) {
    WavError.notRiff || WavError.notWave => s.workbenchErrorNotWav,
    WavError.unsupportedFormat ||
    WavError.unsupportedBitDepth => s.workbenchErrorFormat,
    WavError.unsupportedChannels => s.workbenchErrorChannels,
    WavError.unsupportedRate => s.workbenchErrorRate,
    WavError.tooLarge => s.workbenchErrorTooLarge,
    WavError.tooLong => s.workbenchErrorTooLong,
    WavError.missingFmt ||
    WavError.missingData ||
    WavError.truncated ||
    null => s.workbenchErrorDamaged,
  },
};
