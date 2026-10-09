import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n_extension.dart';
import '../../training/file_trainer_store.dart';
import '../../training/qso_practice.dart';
import '../../training/training_controller_host.dart';
import '../../training/training_doc_store.dart';
import '../../training/training_controller.dart';
import '../../training/training_settings_store.dart';
import '../common/app_bar_title.dart';
import 'learn_playback.dart';
import 'learning_unavailable.dart';

/// Resolves the shared local learning controller and renders its loading,
/// ready or retryable storage-error state. Tests may inject a controller.
class LearnScope extends StatefulWidget {
  const LearnScope({
    super.key,
    required this.builder,
    this.controllerFactory,
    this.playback = const DevicePlaybackFactory(),
    this.title,
    this.description,
  });

  /// Builds the controller; defaults to the local file stores. Tests
  /// pass a factory that returns an in-memory controller.
  final Future<TrainingController> Function(BuildContext context)?
  controllerFactory;

  final LearnPlaybackFactory playback;
  final Widget Function(
    BuildContext context,
    TrainingController controller,
    LearnPlaybackFactory playback,
  )
  builder;

  /// Shown in the loading / storage-error placeholder; defaults to the
  /// localised Learn destination label.
  final String? title;
  final String? description;

  /// File stores under `<dir>/training/` for the local learning profile.
  static Future<TrainingController> controllerForDirectory(
    String dir, {
    required String profileKey,
  }) async {
    final controller = TrainingController(
      progressStore: FileTrainerStore.inDataDirectory(dir),
      settingsStore: FileTrainingSettingsStore.inDataDirectory(dir),
      profileKey: profileKey,
      docs: FileTrainingDocStore.inDataDirectory(dir),
    );
    await controller.load();
    // A finished QSO whose save failed last time is committed now.
    await controller.recoverFinishedQso();
    return controller;
  }

  @override
  State<LearnScope> createState() => _LearnScopeState();
}

enum _ScopeState { loading, ready, storageError }

class _LearnScopeState extends State<LearnScope> {
  _ScopeState _state = _ScopeState.loading;
  TrainingController? _controller;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final factory = widget.controllerFactory;
    TrainingController? controller;
    // A controller obtained from a factory is owned by whoever backs the
    // factory (e.g. the app-wide TrainingControllerHost shares one instance
    // with the settings route); only self-created controllers are disposed.
    try {
      _watchReloads();
      controller = await (factory == null
          ? TrainingControllerHost.fromContext(context)
          : factory(context));
    } on Object {
      // A local storage or factory failure has a retryable placeholder.
      controller = null;
    }
    if (!mounted || generation != _generation) {
      return;
    }
    setState(() {
      _controller = controller;
      _state = controller == null
          ? _ScopeState.storageError
          : _ScopeState.ready;
    });
  }

  ValueListenable<int>? _reloads;

  /// Clearing local files retires the shared controller; load again.
  void _watchReloads() {
    if (_reloads != null) return;
    try {
      _reloads = context.read<TrainingControllerHost?>()?.reloads;
    } on ProviderNotFoundException {
      _reloads = null;
    }
    _reloads?.addListener(_onReload);
  }

  void _onReload() {
    if (mounted) unawaited(_load());
  }

  @override
  void dispose() {
    _reloads?.removeListener(_onReload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    switch (_state) {
      case _ScopeState.ready:
        return widget.builder(context, controller!, widget.playback);
      case _ScopeState.loading:
        return _Placeholder(
          title: widget.title ?? context.s.navLearn,
          description: widget.description,
          message: context.s.learnLoading,
          busy: true,
        );
      case _ScopeState.storageError:
        return _Placeholder(
          title: widget.title ?? context.s.navLearn,
          description: widget.description,
          message: learningUnavailableText(context),
          busy: false,
          onRetry: learningRetryable(context) ? () => unawaited(_load()) : null,
        );
    }
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.title,
    required this.description,
    required this.message,
    required this.busy,
    this.onRetry,
  });

  final String title;
  final String? description;
  final String message;
  final bool busy;

  /// Offline build: the local profile failed to open; try again.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: AppBarTitle(title)),
      // Scrolls instead of overflowing on a small phone with large text;
      // centred whenever it fits.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (busy)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        Icons.school_outlined,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (onRetry != null) ...<Widget>[
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        key: const ValueKey('learn-retry'),
                        onPressed: onRetry,
                        child: Text(context.s.actionRetry),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
