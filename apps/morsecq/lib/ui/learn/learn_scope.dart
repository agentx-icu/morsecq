import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../training/file_trainer_store.dart';
import '../../training/training_controller.dart';
import '../../training/training_settings_store.dart';
import 'learn_playback.dart';
import 'learn_strings.dart';

/// Builds the [TrainingController] for the current identity and hands it to
/// [builder].
///
/// Progress is stored per identity (product decision), so the scope asks the
/// app's [IdentityService] for `dataDirectory()` and points the file stores
/// there. Without a provided service, or before the identity is ready, it
/// shows [LearnScope.identityRequired] instead of the home. When the
/// identity changes the controller is rebuilt for the new directory.
class LearnScope extends StatefulWidget {
  const LearnScope({
    super.key,
    required this.builder,
    this.controllerFactory,
    this.playback = const DevicePlaybackFactory(),
    this.title = LearnStrings.learnTitle,
    this.description,
  });

  /// Builds the controller; defaults to the per-identity file stores. Tests
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

  /// Shown in the loading / identity-required placeholder.
  final String title;
  final String? description;

  /// Default factory: file stores under `<dataDirectory>/training/`.
  static Future<TrainingController> controllerForIdentity(
    IdentityService identity,
  ) async {
    final dir = await identity.dataDirectory();
    final controller = TrainingController(
      progressStore: FileTrainerStore.inDataDirectory(dir),
      settingsStore: FileTrainingSettingsStore.inDataDirectory(dir),
    );
    await controller.load();
    return controller;
  }

  @override
  State<LearnScope> createState() => _LearnScopeState();
}

enum _ScopeState { loading, ready, identityRequired }

class _LearnScopeState extends State<LearnScope> {
  _ScopeState _state = _ScopeState.loading;
  TrainingController? _controller;
  bool _ownsController = false;
  StreamSubscription<Identity?>? _identitySub;
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
    final owns = factory == null;
    try {
      if (factory != null) {
        controller = await factory(context);
      } else {
        final identity = _identityService();
        if (identity == null) {
          controller = null;
        } else {
          _watchIdentity(identity);
          controller = await LearnScope.controllerForIdentity(identity);
        }
      }
    } on Object {
      // No identity yet (dataDirectory threw) or a factory failure: fall
      // back to the placeholder rather than crash the tab.
      controller = null;
    }
    if (!mounted || generation != _generation) {
      if (owns) controller?.dispose();
      return;
    }
    final previous = _controller;
    final previousOwned = _ownsController;
    setState(() {
      _controller = controller;
      _ownsController = owns;
      _state = controller == null
          ? _ScopeState.identityRequired
          : _ScopeState.ready;
    });
    if (previousOwned && !identical(previous, controller)) previous?.dispose();
  }

  IdentityService? _identityService() {
    try {
      return context.read<IdentityService>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  void _watchIdentity(IdentityService identity) {
    if (_identitySub != null) {
      return;
    }
    try {
      _identitySub = identity.identityChanges.listen((_) => _load());
    } on Object {
      // A service without change notifications (test stubs) is fine.
    }
  }

  @override
  void dispose() {
    unawaited(_identitySub?.cancel());
    if (_ownsController) _controller?.dispose();
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
          title: widget.title,
          description: widget.description,
          message: LearnStrings.loading,
          busy: true,
        );
      case _ScopeState.identityRequired:
        return _Placeholder(
          title: widget.title,
          description: widget.description,
          message: LearnStrings.identityRequired,
          busy: false,
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
  });

  final String title;
  final String? description;
  final String message;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
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
            ],
          ),
        ),
      ),
    );
  }
}
