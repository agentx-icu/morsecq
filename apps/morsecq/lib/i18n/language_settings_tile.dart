import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n_extension.dart';
import 'locale_controller.dart';

/// "Language" row for the Me page: shows the current choice and opens a
/// dialog listing "System default" plus every shipped locale by its native
/// name (`LanguageCatalog`), so a new ARB file appears here automatically.
/// Works the same on phone and desktop (plain dialog, no platform pickers).
/// Needs a [LocaleController] provided above it.
class LanguageSettingsTile extends StatelessWidget {
  const LanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    final s = context.s;
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(s.languageTitle),
      subtitle: Text(localeDisplayName(s, controller.locale)),
      onTap: () => showLanguageDialog(context),
    );
  }
}

/// Sentinel tag for "follow the system"; supported locales use
/// [LocaleController.localeName].
const String _systemTag = 'system';

/// Opens the language chooser; resolves when it closes.
Future<void> showLanguageDialog(BuildContext context) {
  final controller = context.read<LocaleController>();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _LanguageDialog(controller: controller),
  );
}

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog({required this.controller});

  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = controller.locale;
        return SimpleDialog(
          title: Text(s.languageTitle),
          contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
          children: [
            RadioGroup<String>(
              groupValue: current == null
                  ? _systemTag
                  : LocaleController.localeName(current),
              onChanged: (tag) async {
                final navigator = Navigator.of(context);
                await controller.setLocale(
                  tag == null || tag == _systemTag
                      ? null
                      : LocaleController.parseLocaleName(tag),
                );
                if (navigator.mounted) navigator.pop();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: _systemTag,
                    title: Text(localeDisplayName(s, null)),
                  ),
                  for (final locale in LocaleController.supportedLocales)
                    RadioListTile<String>(
                      value: LocaleController.localeName(locale),
                      title: Text(localeDisplayName(s, locale)),
                    ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(s.actionClose),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
