import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../di/privacy_consent.dart';
import '../../diagnostics/local_diagnostics.dart';
import '../../i18n/l10n_extension.dart';
import '../common/feedback.dart';
import 'legal_pages.dart';

/// Whether this build must show the first-run privacy gate: a **release
/// Android** build, which is what the mainland stores require. Debug and
/// profile builds (and every other platform) open the app directly and keep
/// the policy reachable under Me > Privacy and permissions.
bool requiresPrivacyConsent({
  bool releaseMode = kReleaseMode,
  TargetPlatform? platform,
}) =>
    releaseMode &&
    (platform ?? defaultTargetPlatform) == TargetPlatform.android;

/// Full-screen first-run gate: the policy summary, the policy and terms to
/// read, then "agree and continue" or "disagree and exit". Acceptance is
/// persisted by [PrivacyConsent]; declining finishes the Android activity.
class PrivacyConsentGate extends StatefulWidget {
  const PrivacyConsentGate({super.key});

  @override
  State<PrivacyConsentGate> createState() => _PrivacyConsentGateState();
}

class _PrivacyConsentGateState extends State<PrivacyConsentGate> {
  bool _saving = false;

  Future<void> _accept() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<PrivacyConsent>().accept();
    } on Object catch (error, stack) {
      LocalDiagnostics.capture(DiagnosticContext.preferencesSave, error, stack);
      if (mounted) showSnack(context, context.s.privacyConsentSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.privacyConsentTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.privacyConsentSummary,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _open(context, const PrivacyPolicyPage()),
                      icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                      label: Text(s.aboutPrivacyPolicy),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _open(context, const TermsOfUsePage()),
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: Text(s.aboutTermsOfUse),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _accept,
                    child: Text(
                      _saving ? s.privacyConsentSaving : s.privacyConsentAccept,
                    ),
                  ),
                  TextButton(
                    onPressed: _saving ? null : () => SystemNavigator.pop(),
                    child: Text(s.privacyConsentDecline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
