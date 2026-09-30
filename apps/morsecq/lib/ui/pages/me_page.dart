import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../di/app_settings.dart';
import '../../i18n/language_settings_tile.dart';
import '../../startup/startup_controller.dart';
import '../account/account_strings.dart';
import '../account/account_widgets.dart';
import '../account/backup_actions.dart';
import '../account/change_password_page.dart';
import '../account/delete_identity_dialog.dart';
import '../account/edit_profile_page.dart';
import '../account/identity_card.dart';

/// Profile, account, progress and settings.
class MePage extends StatelessWidget {
  const MePage({super.key});

  static const String title = 'Me';
  static const String description =
      'Your callsign, Tox identity, progress and settings.';

  @override
  Widget build(BuildContext context) {
    final service = context.read<IdentityService>();
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: StreamBuilder<Identity?>(
        stream: service.identityChanges,
        initialData: service.current,
        builder: (context, snapshot) {
          final identity = snapshot.data;
          if (identity == null) {
            return const Center(child: Text(AccountStrings.meNoIdentity));
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
    final controller = context.read<StartupController>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (!await confirmDeleteIdentity(context)) return;
    try {
      await controller.deleteIdentity();
    } on Object catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text(StartupController.describeError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backend = context.watch<AppSettings>().backendLabel;
    return AccountPageBody(
      maxWidth: 640,
      children: [
        IdentityCard(identity: identity),
        _SectionHeader(AccountStrings.sectionAccount),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text(AccountStrings.editProfile),
          subtitle: const Text(AccountStrings.editProfileBody),
          onTap: () => _push(context, EditProfilePage(identity: identity)),
        ),
        ListTile(
          leading: const Icon(Icons.password),
          title: Text(
            identity.hasPassword
                ? AccountStrings.changePassword
                : AccountStrings.setPassword,
          ),
          onTap: () => _push(
            context,
            ChangePasswordPage(hasPassword: identity.hasPassword),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.save_alt),
          title: const Text(AccountStrings.exportBackup),
          subtitle: const Text(AccountStrings.exportBackupSubtitle),
          onTap: () => exportBackupWithFeedback(context),
        ),
        _SectionHeader(AccountStrings.sectionTraining),
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text(AccountStrings.trainingDefaults),
          subtitle: const Text(AccountStrings.trainingDefaultsSubtitle),
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AccountStrings.trainingSettingsRoute),
        ),
        const LanguageSettingsTile(),
        _SectionHeader(AccountStrings.sectionAbout),
        const ListTile(
          leading: Icon(Icons.gavel_outlined),
          title: Text(AccountStrings.aboutLicence),
          subtitle: Text(AccountStrings.aboutLicenceValue),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text(AccountStrings.aboutSource),
          subtitle: const Text(AccountStrings.aboutSourceUrl),
          trailing: const Icon(Icons.copy, size: 18),
          onTap: () => copyToClipboard(
            context,
            AccountStrings.aboutSourceUrl,
            confirmation: AccountStrings.aboutSourceCopied,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.hub_outlined),
          title: const Text(AccountStrings.aboutBackend),
          subtitle: Text(backend),
        ),
        _SectionHeader(
          AccountStrings.sectionDanger,
          color: theme.colorScheme.error,
        ),
        ListTile(
          leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
          title: Text(
            AccountStrings.deleteIdentity,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          subtitle: const Text(AccountStrings.deleteIdentitySubtitle),
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
