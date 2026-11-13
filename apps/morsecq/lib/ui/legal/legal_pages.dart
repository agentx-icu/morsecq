import 'package:flutter/material.dart';

import '../../i18n/l10n_extension.dart';
import '../common/app_bar_title.dart';
import '../common/settings_body.dart';

/// A read-only in-app page with scrollable text.
class LegalTextPage extends StatelessWidget {
  const LegalTextPage({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: AppBarTitle(title)),
      body: SettingsBody(
        children: [Text(body, style: theme.textTheme.bodyMedium)],
      ),
    );
  }
}

/// The in-app privacy policy (App Review 5.1.1; the mainland stores' in-app
/// policy requirement).
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return LegalTextPage(
      title: s.aboutPrivacyPolicy,
      body: s.privacyPolicyText,
    );
  }
}

/// The in-app terms of use.
class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return LegalTextPage(title: s.aboutTermsOfUse, body: s.termsOfUseText);
  }
}

/// The "personal information collected" list (the mainland stores' double
/// list: collected + shared). This app collects nothing.
class PersonalInfoListPage extends StatelessWidget {
  const PersonalInfoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return LegalTextPage(
      title: s.accountPersonalInfoList,
      body: s.personalInfoListText,
    );
  }
}

/// The "third-party sharing" list (the mainland stores' double list).
class ThirdPartyShareListPage extends StatelessWidget {
  const ThirdPartyShareListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return LegalTextPage(
      title: s.accountThirdPartyShareList,
      body: s.thirdPartyShareText,
    );
  }
}

/// The permission list and purpose of each permission.
class PermissionListPage extends StatelessWidget {
  const PermissionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return LegalTextPage(
      title: s.accountPermissionList,
      body: s.permissionListText,
    );
  }
}

/// Troubleshooting and instructions for preparing a bug report.
class TechnicalSupportPage extends StatelessWidget {
  const TechnicalSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    return LegalTextPage(title: s.aboutSupport, body: s.technicalSupportText);
  }
}

/// The privacy, permissions and technical support pages in Me.
class LegalLinksSection extends StatelessWidget {
  const LegalLinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = context.s;
    Widget pageTile(Key key, IconData icon, String title, Widget page) =>
        ListTile(
          key: key,
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => page)),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        pageTile(
          const ValueKey('about-privacy'),
          Icons.privacy_tip_outlined,
          s.aboutPrivacyPolicy,
          const PrivacyPolicyPage(),
        ),
        pageTile(
          const ValueKey('about-terms'),
          Icons.description_outlined,
          s.aboutTermsOfUse,
          const TermsOfUsePage(),
        ),
        pageTile(
          const ValueKey('account-personal-info'),
          Icons.badge_outlined,
          s.accountPersonalInfoList,
          const PersonalInfoListPage(),
        ),
        pageTile(
          const ValueKey('account-third-party'),
          Icons.handshake_outlined,
          s.accountThirdPartyShareList,
          const ThirdPartyShareListPage(),
        ),
        pageTile(
          const ValueKey('account-permissions'),
          Icons.mic_none_outlined,
          s.accountPermissionList,
          const PermissionListPage(),
        ),
        pageTile(
          const ValueKey('about-support'),
          Icons.support_agent,
          s.aboutSupport,
          const TechnicalSupportPage(),
        ),
      ],
    );
  }
}
