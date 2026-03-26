import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:permission_handler/permission_handler.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({
    required this.localeController,
    required this.themeController,
    super.key,
  });

  final LocaleController localeController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([localeController, themeController]),
      builder: (context, _) {
        final activeLocale = localeController.effectiveLocale;
        final currentOverride = localeController.locale?.languageCode;
        final currentTheme = themeController.themeMode;

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    AppGlassHeader(
                      title: context.l10n.settingsTitle(),
                      onBack: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 18),
                    FrostedPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsThemeTitle(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.settingsThemeBody(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 14),
                          _OptionTile(
                            label: context.l10n.settingsThemeDark(),
                            selected: currentTheme == ThemeMode.dark,
                            onTap: () =>
                                themeController.setThemeMode(ThemeMode.dark),
                          ),
                          const SizedBox(height: 10),
                          _OptionTile(
                            label: context.l10n.settingsThemeLight(),
                            selected: currentTheme == ThemeMode.light,
                            onTap: () =>
                                themeController.setThemeMode(ThemeMode.light),
                          ),
                          const SizedBox(height: 10),
                          _OptionTile(
                            label: context.l10n.settingsThemeSystem(),
                            selected: currentTheme == ThemeMode.system,
                            onTap: () =>
                                themeController.setThemeMode(ThemeMode.system),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FrostedPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsLanguageTitle(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.settingsLanguageBody(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 14),
                          _OptionTile(
                            label: context.l10n.settingsLanguageSystem(
                              _localeName(context, activeLocale),
                            ),
                            selected: currentOverride == null,
                            onTap: localeController.useSystemLocale,
                          ),
                          const SizedBox(height: 10),
                          _OptionTile(
                            label: context.l10n.languageOptionSpanishArgentina,
                            selected: currentOverride == 'es',
                            onTap: () =>
                                localeController.setLocale(const Locale('es')),
                          ),
                          const SizedBox(height: 10),
                          _OptionTile(
                            label: context.l10n.languageOptionEnglish,
                            selected: currentOverride == 'en',
                            onTap: () =>
                                localeController.setLocale(const Locale('en')),
                          ),
                          const SizedBox(height: 10),
                          _OptionTile(
                            label: context.l10n.languageOptionPortuguese,
                            selected: currentOverride == 'pt',
                            onTap: () =>
                                localeController.setLocale(const Locale('pt')),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FrostedPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsSystemLanguageTitle(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.settingsSystemLanguageBody(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: openAppSettings,
                            child: Text(context.l10n.settingsOpenAction()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _localeName(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return context.l10n.languageOptionSpanishArgentina;
      case 'pt':
        return context.l10n.languageOptionPortuguese;
      default:
        return context.l10n.languageOptionEnglish;
    }
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
