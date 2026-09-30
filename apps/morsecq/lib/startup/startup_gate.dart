import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/l10n_extension.dart';
import '../ui/account/backup_wizard_page.dart';
import '../ui/account/connection_chip.dart';
import '../ui/account/unlock_page.dart';
import '../ui/account/welcome_page.dart';
import 'startup_controller.dart';
import 'startup_screens.dart';

/// Wraps the whole shell: nothing behind it renders until an identity is
/// loaded (product decision: training needs an identity too). Reads the
/// [StartupController] provided by `AppScope` and kicks it off once.
///
/// While [StartupPhase.ready], [child] is shown with a small connection chip
/// overlaid top-right whenever the node is not online.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    // Notifies only after an await, so no markNeedsBuild during this build.
    context.read<StartupController>().ensureStarted().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final controller = context.watch<StartupController>();
    final phase = controller.phase;
    final Widget page = switch (phase) {
      StartupPhase.inspecting => StartupSplash(
        message: s.accountStartupInspecting,
      ),
      StartupPhase.opening => StartupSplash(message: s.accountStartupOpening),
      StartupPhase.onboarding => const WelcomePage(),
      StartupPhase.locked => const UnlockPage(),
      StartupPhase.backupRequired => const BackupWizardPage(mandatory: true),
      StartupPhase.failed => StartupErrorPage(
        error: controller.error,
        onRetry: () => controller.retry().ignore(),
      ),
      StartupPhase.ready => Stack(
        children: [
          widget.child,
          const Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ConnectionChip(),
              ),
            ),
          ),
        ],
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(phase), child: page),
    );
  }
}
