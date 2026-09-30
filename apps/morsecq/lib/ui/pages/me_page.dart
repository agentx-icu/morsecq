import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../di/app_settings.dart';
import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import '../../i18n/language_settings_tile.dart';
import '../../startup/startup_controller.dart';
import '../account/account_routes.dart';
import '../account/account_widgets.dart';
import '../account/backup_actions.dart';
import '../account/change_password_page.dart';
import '../account/delete_identity_dialog.dart';
import '../account/edit_profile_page.dart';
import '../account/identity_card.dart';

/// Profile, account, progress and settings.
class MePage extends StatelessWidget {
  const MePage({super.key});

  /// Destination label, resolved in the current locale.
  static String title(S s) => s.navMe;

  /// One-line subtitle, resolved in the current locale.
  static String description(S s) => s.navMeDescription;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final service = context.read<IdentityService>();
    return Scaffold(
      appBar: AppBar(title: Text(title(s))),
      body: StreamBuilder<Identity?>(
        stream: service.identityChanges,
        initialData: service.current,
        builder: (context, snapshot) {
          final identity = snapshot.data;
          if (identity == null) {
            return Center(child: Text(s.accountMeNoIdentity));
          }
          return _MeBody(identity: identity);
        },
      ),
    );
  }
}

class _MeBody extends StatelessWidget {
  const _MeBody({required this.identity});

  final Identity identity;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _delete(BuildContext context) async {
    final s = context.s;
    final controller = context.read<StartupController>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (!await confirmDeleteIdentity(context)) return;
    try {
      await controller.deleteIdentity();
    } on Object catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text(describeChatError(s, e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final backend = context.watch<AppSettings>().backendLabel;
    return AccountPageBody(
      maxWidth: 640,
      children: [
        IdentityCard(identity: identity),
        _SectionHeader(s.accountSectionAccount),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(s.accountEditProfile),
          subtitle: Text(s.accountEditProfileBody),
          onTap: () => _push(context, EditProfilePage(identity: identity)),
        ),
        ListTile(
          leading: const Icon(Icons.password),
          title: Text(
            identity.hasPassword
                ? s.accountChangePassword
                : s.accountSetPassword,
          ),
          onTap: () => _push(
            context,
            ChangePasswordPage(hasPassword: identity.hasPassword),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.save_alt),
          title: Text(s.accountExportBackup),
          subtitle: Text(s.accountExportBackupSubtitle),
          onTap: () => exportBackupWithFeedback(context),
        ),
        _SectionHeader(s.accountSectionTraining),
        ListTile(
          leading: const Icon(Icons.tune),
          title: Text(s.accountTrainingDefaults),
          subtitle: Text(s.accountTrainingDefaultsSubtitle),
          onTap: () =>
              Navigator.of(context).pushNamed(kTrainingSettingsRoute),
        ),
        const LanguageSettingsTile(),
        _SectionHeader(s.accountSectionAbout),
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
        ListTile(
          leading: const Icon(Icons.hub_outlined),
          title: Text(s.accountAboutBackend),
          subtitle: Text(backend),
        ),
        _SectionHeader(s.accountSectionDanger, color: theme.colorScheme.error),
        ListTile(
          leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
          title: Text(
            s.accountDeleteIdentity,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          subtitle: Text(s.accountDeleteIdentitySubtitle),
          onTap: () => _delete(context),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, {this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4, left: 16),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}
