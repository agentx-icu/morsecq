import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n_extension.dart';
import '../../i18n/language_settings_tile.dart';
import '../../training/training_controller_host.dart';
import '../settings/settings_routes.dart';
import '../common/settings_body.dart';
import '../appearance/appearance_page.dart';
import '../common/feedback.dart';
import '../keying/key_setup_page.dart';
import '../moderation/site_links.dart';

/// Me in the offline build (all platforms): settings for the local
/// learning profile. No identity, account, connection or chat entries exist.
class OfflineMePage extends StatelessWidget {
  const OfflineMePage({super.key});
  static String title(S s) => s.navMe;

  Future<void> _clear(BuildContext context) async {
    final S s = context.s;
    final TrainingControllerHost controller = context
        .read<TrainingControllerHost>();
    final bool ok = await confirm(
      context,
      title: s.offlineClearData,
      body: s.offlineClearDataBody,
      confirmLabel: s.guestClearConfirm,
    );
    if (!ok || !context.mounted) return;
    try {
      await controller.clear();
      if (context.mounted) showSnack(context, s.offlineCleared);
    } on Object {
      if (context.mounted) showSnack(context, s.offlineClearFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    final ThemeData theme = Theme.of(context);
    Widget header(String label) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4, left: 16),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(s.navMe)),
      body: SettingsBody(
        maxWidth: 640,
        children: [
          header(s.accountSectionTraining),
          ListTile(
            key: const ValueKey('offline-training-defaults'),
            leading: const Icon(Icons.tune),
            title: Text(s.accountTrainingDefaults),
            subtitle: Text(s.accountTrainingDefaultsSubtitle),
            onTap: () =>
                Navigator.of(context).pushNamed(kTrainingSettingsRoute),
          ),
          ListTile(
            key: const ValueKey('offline-keys'),
            leading: const Icon(Icons.keyboard_outlined),
            title: Text(s.keysTitle),
            subtitle: Text(s.keysMeSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => KeySetupPage.open(context),
          ),
          const LanguageSettingsTile(),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(s.appearanceTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppearancePage.open(context),
          ),
          ListTile(
            key: const ValueKey('offline-clear'),
            leading: const Icon(Icons.delete_outline),
            title: Text(s.offlineClearData),
            subtitle: Text(s.offlineClearDataBody),
            onTap: () => unawaited(_clear(context)),
          ),
          header(s.accountSectionAbout),
          const SiteLinksSection(),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(s.accountAboutLicence),
            subtitle: Text(s.accountAboutLicenceValue),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(s.accountAboutSource),
            subtitle: const Text(kAboutSourceUrl),
            trailing: const Icon(Icons.copy, size: 18),
            onTap: () => copyToClipboard(
              context,
              kAboutSourceUrl,
              confirmation: s.accountAboutSourceCopied,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
