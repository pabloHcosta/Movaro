import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_scope.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({
    this.foregroundColor,
    this.backgroundColor,
    super.key,
  });

  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final controller = context.localeController;
    final l10n = context.l10n;
    final activeLocale = Localizations.localeOf(context);

    return PopupMenuButton<String>(
      tooltip: l10n.languageSelectorTooltip,
      initialValue:
          controller.locale?.languageCode ??
          'system_${activeLocale.languageCode}',
      onSelected: (value) {
        switch (value) {
          case 'system':
            controller.useSystemLocale();
            break;
          case 'es':
            controller.setLocale(const Locale('es'));
            break;
          case 'pt':
            controller.setLocale(const Locale('pt'));
            break;
          default:
            controller.setLocale(const Locale('en'));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'system',
          child: Text(
            '${l10n.languageSelectorSystem} (${_labelForLocale(activeLocale)})',
          ),
        ),
        PopupMenuItem<String>(
          value: 'es',
          child: Text(l10n.languageOptionSpanishArgentina),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Text(l10n.languageOptionEnglish),
        ),
        PopupMenuItem<String>(
          value: 'pt',
          child: Text(l10n.languageOptionPortuguese),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              _labelForLocale(activeLocale),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color:
                    foregroundColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return 'ES';
      case 'pt':
        return 'PT';
      default:
        return 'EN';
    }
  }
}
