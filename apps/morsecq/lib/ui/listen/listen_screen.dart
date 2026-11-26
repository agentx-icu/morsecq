import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morse_io/morse_io.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n_extension.dart';
import '../common/adaptive_fab.dart';
import '../common/app_bar_title.dart';
import '../common/feedback.dart';
import 'listen_controller.dart';
import 'listen_preferences.dart';
import 'listen_settings.dart';
import 'listen_widgets.dart';
import 'pcm_source.dart';
import 'record_pcm_source.dart';
import 'workbench/workbench_screen.dart';

/// Body height below which the screen scrolls as a whole (landscape phones).
const double _kShortHeight = 480;

/// Microphone -> Morse -> text.
///
/// Pass a [PcmSource] to inject audio (tests use a fake); by default the
/// screen creates a [RecordPcmSource] and owns it. Capture stops when the
/// app goes to the background and never resumes on its own; while it runs
/// the screen is kept on ([screenWake]) so the phone's auto-lock does not
/// background the app in the middle of a hands-free session.
class ListenScreen extends StatefulWidget {
  const ListenScreen({
    super.key,
    this.source,
    this.sampleRate = 48000,
    this.screenWake = const WakelockScreenWake(),
  });

  static const String routeName = '/listen';

  /// Key on the decoded-text widget so tests (and tools) can read it.
  static const Key decodedTextKey = Key('listen.decodedText');

  static Route<void> route({PcmSource? source}) => MaterialPageRoute<void>(
    settings: const RouteSettings(name: routeName),
    builder: (_) => ListenScreen(source: source),
  );

  final PcmSource? source;
  final int sampleRate;
  final ScreenWakeApi screenWake;

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen>
    with WidgetsBindingObserver {
  late final ListenController _controller;
  final ScrollController _scroll = ScrollController();

  /// Moves the transcript (and its scroll position) between the tall and
  /// short layouts when the window is rotated or resized.
  final GlobalKey _transcriptKey = GlobalKey(debugLabel: 'listen-transcript');
  int _shownTextLength = 0;
  ListenPreferences? _preferences;
  bool _keepingAwake = false;
  bool _micPurposeExplained = false;
  bool _openingWorkbench = false;
  DialogRoute<bool>? _micPurposeDialog;

  @override
  void initState() {
    super.initState();
    try {
      _preferences = context.read<ListenPreferences>();
    } on ProviderNotFoundException {
      // Isolated screens/tests use the decoder defaults.
    }
    _controller = ListenController(
      source: widget.source ?? RecordPcmSource(),
      ownsSource: widget.source == null,
      sampleRate: widget.sampleRate,
      settings: _preferences?.settings ?? const ListenSettings(),
    );
    _controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    if (_keepingAwake) unawaited(widget.screenWake.keepOn(false));
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Privacy: never keep the microphone open while the app is not visible.
    // `inactive` is skipped because iOS reports it for Control Center and
    // incoming-call banners; `paused`/`hidden` mean the UI is really gone.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_controller.isListening || _controller.isBusy) {
        unawaited(_controller.stop(fromBackground: true));
      }
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final dialog = _micPurposeDialog;
    if (!_controller.isBusy && dialog != null && dialog.isActive) {
      dialog.navigator?.removeRoute(dialog);
    }
    _preferences?.update(_controller.settings);
    final bool awake = _controller.isListening;
    if (awake != _keepingAwake) {
      _keepingAwake = awake;
      unawaited(widget.screenWake.keepOn(awake));
    }
    setState(() {});
    final length = _controller.text.length;
    if (length != _shownTextLength) {
      _shownTextLength = length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  void _scrollToEnd() {
    if (!mounted || !_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max > 0) _scroll.jumpTo(max);
  }

  Future<void> _toggle() async {
    if (_controller.isListening) {
      await _controller.stop();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    if (_openingWorkbench || !_controller.canStart) return;
    await _controller.start(explainPermission: _explainMicrophonePurpose);
  }

  Future<bool> _explainMicrophonePurpose() async {
    if (_micPurposeExplained) return true;
    final S s = context.s;
    final navigator = Navigator.of(context, rootNavigator: true);
    final dialog = DialogRoute<bool>(
      context: context,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      builder: (ctx) => ScrollingAlertDialog(
        title: Text(s.listenMicPurposeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [Text(s.listenMicPurposeBody), Text(s.listenMicNext)],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.s.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.s.listenMicPurposeContinue),
          ),
        ],
      ),
    );
    _micPurposeDialog = dialog;
    final proceed = await navigator.push(dialog);
    if (identical(_micPurposeDialog, dialog)) _micPurposeDialog = null;
    if (proceed == true) _micPurposeExplained = true;
    return proceed == true;
  }

  Future<void> _copy() async {
    final messenger = ScaffoldMessenger.of(context);
    final String copied = context.s.listenCopied;
    await Clipboard.setData(ClipboardData(text: _controller.text));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  Future<void> _openSettings() => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => ListenSettingsSheet(
      settings: _controller.settings,
      sampleRate: _controller.sampleRate,
      onChanged: (settings) {
        _controller.updateSettings(settings);
        _preferences?.update(settings);
      },
    ),
  );

  /// The microphone stops before the workbench plays anything (it would
  /// otherwise decode the playback); the learner restarts it by hand.
  Future<void> _openWorkbench() async {
    if (_openingWorkbench) return;
    _openingWorkbench = true;
    try {
      await _controller.stopBeforePlayback();
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const WorkbenchScreen()));
    } finally {
      _openingWorkbench = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listening = _controller.isListening;
    final S s = context.s;
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(s.listenTitle),
        actions: <Widget>[
          IconButton(
            key: const ValueKey('listen-open-workbench'),
            tooltip: s.workbenchOpen,
            onPressed: () => unawaited(_openWorkbench()),
            icon: const Icon(Icons.audio_file_outlined),
          ),
          IconButton(
            tooltip: s.listenClear,
            onPressed: _controller.hasText ? _controller.clear : null,
            icon: const Icon(Icons.backspace_outlined),
          ),
          IconButton(
            tooltip: s.listenSettings,
            onPressed: _openSettings,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final factor = MediaQuery.textScalerOf(context).scale(14) / 14;
            final short = constraints.maxHeight < _kShortHeight * factor;
            final wide = constraints.maxWidth >= 900 && !short;
            final decoded = ListenDecodedText(
              key: _transcriptKey,
              text: _controller.text,
              isListening: listening,
              scrollController: _scroll,
              onCopy: _copy,
              textKey: ListenScreen.decodedTextKey,
              margin: wide
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
            final status = ListenStatusBanner(
              controller: _controller,
              onRetry: () => unawaited(_start()),
            );
            final level = Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: ListenLevelMeter(meter: _controller.meter),
            );
            final tuning = ListenFrequencyPanel(controller: _controller);
            final stats = ListenStatsRow(controller: _controller);
            if (wide) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 76),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          status,
                          level,
                          const SizedBox(height: 12),
                          Expanded(child: decoded),
                          stats,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: tuning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            final column = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                status,
                level,
                tuning,
                if (short)
                  SizedBox(height: _kShortHeight / 2 * factor, child: decoded)
                else
                  Expanded(child: decoded),
                stats,
                const SizedBox(height: 72),
              ],
            );
            return short ? SingleChildScrollView(child: column) : column;
          },
        ),
      ),
      floatingActionButton: AdaptiveFab(
        onPressed: listening || _controller.canStart ? _toggle : null,
        icon: Icon(listening ? Icons.stop : Icons.mic),
        label: listening ? s.listenStop : s.listenStart,
      ),
    );
  }
}
