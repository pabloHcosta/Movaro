import 'package:flutter/material.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/presentation/pages/trust_and_support_page.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:permission_handler/permission_handler.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({
    required this.localeController,
    required this.themeController,
    required this.currencyController,
    required this.locationController,
    required this.guideFlowMetricsStore,
    super.key,
  });

  final LocaleController localeController;
  final ThemeController themeController;
  final CurrencyController currencyController;
  final LocationController locationController;
  final GuideFlowMetricsStore guideFlowMetricsStore;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        localeController,
        themeController,
        currencyController,
        locationController,
        guideFlowMetricsStore,
      ]),
      builder: (context, _) {
        final activeLocale = localeController.effectiveLocale;
        final currentOverride = localeController.locale?.languageCode;
        final currentTheme = themeController.themeMode;
        final currentCurrency = currencyController.currencyCode;
        final currentLanguageLabel = currentOverride == null
            ? context.l10n.settingsLanguageSystem(
                _localeName(context, activeLocale),
              )
            : _languageLabel(context, currentOverride);
        final currentThemeLabel = switch (currentTheme) {
          ThemeMode.dark => context.l10n.settingsThemeDark(),
          ThemeMode.light => context.l10n.settingsThemeLight(),
          ThemeMode.system => context.l10n.settingsThemeSystem(),
        };
        final currentCurrencyLabel =
            _currencyOptions
                .where((entry) => entry.code == currentCurrency)
                .firstOrNull
                ?.label ??
            currentCurrency;
        final settingsIntro = _settingsIntro(context);
        final settingsEyebrow = _settingsEyebrow(context);

        return Scaffold(
          backgroundColor: AppColors.backgroundFor(context),
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      sliver: SliverToBoxAdapter(
                        child: AppGlassHeader(
                          title: context.l10n.settingsTitle(),
                          onBack: () => Navigator.maybePop(context),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      sliver: SliverList.list(
                        children: [
                          _EntranceReveal(
                            delayIndex: 0,
                            child: _SettingsHeroCard(
                              eyebrow: settingsEyebrow,
                              intro: settingsIntro,
                              currentThemeLabel: currentThemeLabel,
                              currentLanguageLabel: currentLanguageLabel,
                              currentCurrencyLabel: currentCurrencyLabel,
                            ),
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 760;
                              return Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 1,
                                      child: _SettingCard(
                                        icon: Icons.palette_outlined,
                                        title: context.l10n
                                            .settingsThemeTitle(),
                                        description: context.l10n
                                            .settingsThemeBody(),
                                        trailingLabel: currentThemeLabel,
                                        accentColor: const Color(0xFF0071E3),
                                        child:
                                            _SegmentedSettingGroup<ThemeMode>(
                                              value: currentTheme,
                                              segments: [
                                                _SettingSegment(
                                                  value: ThemeMode.dark,
                                                  label: context.l10n
                                                      .settingsThemeDark(),
                                                ),
                                                _SettingSegment(
                                                  value: ThemeMode.light,
                                                  label: context.l10n
                                                      .settingsThemeLight(),
                                                ),
                                                _SettingSegment(
                                                  value: ThemeMode.system,
                                                  label: context.l10n
                                                      .settingsThemeSystem(),
                                                ),
                                              ],
                                              onChanged:
                                                  themeController.setThemeMode,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 4,
                                      child: _SettingCard(
                                        icon: Icons.insights_outlined,
                                        title: _settingsText(
                                          context,
                                          pt: 'Ajudar a melhorar o Movaro',
                                          es: 'Ayudar a mejorar Movaro',
                                          en: 'Help improve Movaro',
                                        ),
                                        description: _settingsText(
                                          context,
                                          pt: 'Com sua autorização, enviamos apenas eventos anônimos do fluxo. Nunca enviamos respostas, cidade, localização, documentos ou valores.',
                                          es: 'Con tu autorización, enviamos solo eventos anónimos del flujo. Nunca enviamos respuestas, ciudad, ubicación, documentos ni valores.',
                                          en: 'With your permission, we send only anonymous flow events. We never send answers, city, location, documents, or amounts.',
                                        ),
                                        trailingLabel:
                                            guideFlowMetricsStore.isEnabled
                                            ? _settingsText(
                                                context,
                                                pt: 'Ativado',
                                                es: 'Activado',
                                                en: 'Enabled',
                                              )
                                            : _settingsText(
                                                context,
                                                pt: 'Desativado',
                                                es: 'Desactivado',
                                                en: 'Disabled',
                                              ),
                                        accentColor: const Color(0xFF536DFE),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SwitchListTile.adaptive(
                                              contentPadding: EdgeInsets.zero,
                                              value: guideFlowMetricsStore
                                                  .isEnabled,
                                              title: Text(
                                                _settingsText(
                                                  context,
                                                  pt: 'Compartilhar métricas anônimas',
                                                  es: 'Compartir métricas anónimas',
                                                  en: 'Share anonymous metrics',
                                                ),
                                              ),
                                              subtitle: Text(
                                                _settingsText(
                                                  context,
                                                  pt: 'Você pode mudar de ideia e apagar o histórico deste aparelho a qualquer momento.',
                                                  es: 'Podés cambiar de idea y borrar el historial de este teléfono en cualquier momento.',
                                                  en: 'You can change your mind and delete this device history at any time.',
                                                ),
                                              ),
                                              onChanged: (enabled) {
                                                guideFlowMetricsStore.setConsent(
                                                  enabled
                                                      ? ProductAnalyticsConsent
                                                            .granted
                                                      : ProductAnalyticsConsent
                                                            .denied,
                                                );
                                              },
                                            ),
                                            TextButton.icon(
                                              onPressed:
                                                  guideFlowMetricsStore.clear,
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                              ),
                                              label: Text(
                                                _settingsText(
                                                  context,
                                                  pt: 'Apagar métricas deste aparelho',
                                                  es: 'Borrar métricas de este teléfono',
                                                  en: 'Delete this device metrics',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 2,
                                      child: _SettingCard(
                                        icon: Icons.language_rounded,
                                        title: context.l10n
                                            .settingsLanguageTitle(),
                                        description: context.l10n
                                            .settingsLanguageBody(),
                                        trailingLabel: currentLanguageLabel,
                                        accentColor: const Color(0xFF0B8F78),
                                        child: _SegmentedSettingGroup<String?>(
                                          value: currentOverride,
                                          segments: [
                                            _SettingSegment<String?>(
                                              value: null,
                                              label: context.l10n
                                                  .settingsLanguageSystem(
                                                    _localeName(
                                                      context,
                                                      activeLocale,
                                                    ),
                                                  ),
                                            ),
                                            _SettingSegment<String?>(
                                              value: 'es',
                                              label: context
                                                  .l10n
                                                  .languageOptionSpanishArgentina,
                                            ),
                                            _SettingSegment<String?>(
                                              value: 'en',
                                              label: context
                                                  .l10n
                                                  .languageOptionEnglish,
                                            ),
                                            _SettingSegment<String?>(
                                              value: 'pt',
                                              label: context
                                                  .l10n
                                                  .languageOptionPortuguese,
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value == null) {
                                              localeController
                                                  .useSystemLocale();
                                              return;
                                            }
                                            localeController.setLocale(
                                              Locale(value),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 3,
                                      child: _SettingCard(
                                        icon: Icons.payments_outlined,
                                        title: context.l10n
                                            .settingsCurrencyTitle(),
                                        description: context.l10n
                                            .settingsCurrencyBody(),
                                        trailingLabel: currentCurrencyLabel,
                                        accentColor: const Color(0xFFE38B00),
                                        child: _CurrencySelector(
                                          value: currentCurrency,
                                          onChanged: (value) {
                                            if (value != null) {
                                              currencyController.setCurrency(
                                                value,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 5,
                                      child: _SettingCard(
                                        icon: Icons.tune_rounded,
                                        title: context.l10n
                                            .settingsSystemLanguageTitle(),
                                        description: context.l10n
                                            .settingsSystemLanguageBody(),
                                        accentColor: const Color(0xFF7C8DFF),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _SystemSettingsAction(
                                            label: context.l10n
                                                .settingsOpenAction(),
                                            onTap: openAppSettings,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 6,
                                      child: _SettingCard(
                                        icon: Icons.verified_user_outlined,
                                        title: _settingsText(
                                          context,
                                          pt: 'Confiança e apoio',
                                          es: 'Confianza y apoyo',
                                          en: 'Trust & support',
                                        ),
                                        description: _settingsText(
                                          context,
                                          pt: 'Fontes, metodologia e apoio oficial gratuito.',
                                          es: 'Fuentes, metodología y apoyo oficial gratuito.',
                                          en: 'Sources, methodology and free official support.',
                                        ),
                                        accentColor: const Color(0xFF2E9E6B),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _SystemSettingsAction(
                                            label: _settingsText(
                                              context,
                                              pt: 'Abrir',
                                              es: 'Abrir',
                                              en: 'Open',
                                            ),
                                            onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    const TrustAndSupportPage(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: compact
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 14) / 2,
                                    child: _EntranceReveal(
                                      delayIndex: 7,
                                      child: _SettingCard(
                                        icon: Icons.location_on_outlined,
                                        title: _settingsText(
                                          context,
                                          pt: 'Cidade de origem e privacidade',
                                          es: 'Ciudad de origen y privacidad',
                                          en: 'Origin city and privacy',
                                        ),
                                        description: _settingsText(
                                          context,
                                          pt:
                                              locationController
                                                      .savedLocation ==
                                                  null
                                              ? 'Nenhuma cidade está salva. O assistente funciona sem localização e sem IA.'
                                              : 'Salvo no aparelho: ${locationController.savedLocation!.cityName}. A posição GPS exata não é armazenada.',
                                          es:
                                              locationController
                                                      .savedLocation ==
                                                  null
                                              ? 'No hay una ciudad guardada. El asistente funciona sin ubicación y sin IA.'
                                              : 'Guardado en el teléfono: ${locationController.savedLocation!.cityName}. No almacenamos la posición GPS exacta.',
                                          en:
                                              locationController
                                                      .savedLocation ==
                                                  null
                                              ? 'No city is saved. The assistant works without location and without AI.'
                                              : 'Saved on device: ${locationController.savedLocation!.cityName}. The exact GPS fix is not stored.',
                                        ),
                                        accentColor: const Color(0xFF8A63D2),
                                        child:
                                            locationController.savedLocation ==
                                                null
                                            ? Text(
                                                _settingsText(
                                                  context,
                                                  pt: 'Se você autorizar a detecção, guardamos apenas a cidade confirmada e um ponto municipal aproximado.',
                                                  es: 'Si autorizás la detección, guardamos solo la ciudad confirmada y un punto municipal aproximado.',
                                                  en: 'If you allow detection, we keep only the confirmed city and an approximate municipal point.',
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          AppColors.textSoftFor(
                                                            context,
                                                          ),
                                                      height: 1.4,
                                                    ),
                                              )
                                            : Align(
                                                alignment: Alignment.centerLeft,
                                                child: _SystemSettingsAction(
                                                  label: _settingsText(
                                                    context,
                                                    pt: 'Apagar cidade salva',
                                                    es: 'Borrar ciudad guardada',
                                                    en: 'Delete saved city',
                                                  ),
                                                  onTap: () =>
                                                      _confirmDeleteLocation(
                                                        context,
                                                      ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
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

  String _languageLabel(BuildContext context, String code) {
    switch (code) {
      case 'es':
        return context.l10n.languageOptionSpanishArgentina;
      case 'pt':
        return context.l10n.languageOptionPortuguese;
      default:
        return context.l10n.languageOptionEnglish;
    }
  }

  String _settingsIntro(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        return 'Preferencias clave, organizadas para cambiar rápido sin perder tiempo en una pantalla larga.';
      case 'en':
        return 'Core preferences, reorganized to be faster to scan and quicker to change.';
      default:
        return 'Preferências centrais, organizadas para você ajustar rápido sem perder tempo numa tela longa.';
    }
  }

  String _settingsEyebrow(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        return 'Experiencia del app';
      case 'en':
        return 'App experience';
      default:
        return 'Experiência do app';
    }
  }

  Future<void> _confirmDeleteLocation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _settingsText(
            dialogContext,
            pt: 'Apagar cidade de origem?',
            es: '¿Borrar ciudad de origen?',
            en: 'Delete origin city?',
          ),
        ),
        content: Text(
          _settingsText(
            dialogContext,
            pt: 'O dado salvo neste aparelho será removido. Você poderá escolher a cidade novamente quando precisar.',
            es: 'Se eliminará el dato guardado en este teléfono. Podrás elegir la ciudad de nuevo cuando la necesites.',
            en: 'The data saved on this device will be removed. You can choose the city again when needed.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              _settingsText(
                dialogContext,
                pt: 'Cancelar',
                es: 'Cancelar',
                en: 'Cancel',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              _settingsText(
                dialogContext,
                pt: 'Apagar',
                es: 'Borrar',
                en: 'Delete',
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await locationController.clearSavedLocation();
    }
  }
}

const _currencyOptions = [
  _CurrencyOption(label: 'US Dollar (USD)', code: 'USD'),
  _CurrencyOption(label: 'Real Brasileiro (BRL)', code: 'BRL'),
  _CurrencyOption(label: 'Peso Argentino (ARS)', code: 'ARS'),
  _CurrencyOption(label: 'Peso Chileno (CLP)', code: 'CLP'),
];

String _settingsText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };
}

class _CurrencyOption {
  const _CurrencyOption({required this.label, required this.code});

  final String label;
  final String code;
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({
    required this.eyebrow,
    required this.intro,
    required this.currentThemeLabel,
    required this.currentLanguageLabel,
    required this.currentCurrencyLabel,
  });

  final String eyebrow;
  final String intro;
  final String currentThemeLabel;
  final String currentLanguageLabel;
  final String currentCurrencyLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF101827),
                            const Color(0xFF173150),
                            const Color(0xFF22558A),
                          ]
                        : [
                            const Color(0xFFF7FBFF),
                            const Color(0xFFEAF2FF),
                            const Color(0xFFDCEBFF),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.borderFor(context)),
                ),
              ),
            ),
            Positioned(
              right: -28,
              top: -20,
              child: Container(
                width: 122,
                height: 122,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.35),
                ),
              ),
            ),
            Positioned(
              right: 36,
              top: 28,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.24 : 0.70),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.08 : 0.66,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.10 : 0.82,
                        ),
                      ),
                    ),
                    child: Text(
                      eyebrow,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.settingsTitle(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      intro,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.78)
                            : const Color(0xFF4B5A72),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _CurrentSettingPill(
                        icon: Icons.palette_outlined,
                        label: currentThemeLabel,
                      ),
                      _CurrentSettingPill(
                        icon: Icons.language_rounded,
                        label: currentLanguageLabel,
                      ),
                      _CurrentSettingPill(
                        icon: Icons.payments_outlined,
                        label: currentCurrencyLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentSettingPill extends StatelessWidget {
  const _CurrentSettingPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
    required this.accentColor,
    this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;
  final Color accentColor;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.frostedBackgroundFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.frostedBorderFor(context)),
        boxShadow: AppColors.frostedShadowFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingLabel != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                    child: _SelectionBadge(
                      key: ValueKey(trailingLabel),
                      label: trailingLabel!,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context).withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryFor(context),
        ),
      ),
    );
  }
}

class _SegmentedSettingGroup<T> extends StatelessWidget {
  const _SegmentedSettingGroup({
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  final T value;
  final List<_SettingSegment<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: segments
          .map(
            (segment) => _ChoicePill(
              label: segment.label,
              selected: value == segment.value,
              onTap: () => onChanged(segment.value),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SettingSegment<T> {
  const _SettingSegment({required this.value, required this.label});

  final T value;
  final String label;
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: selected ? 1.0 : 0.985,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceMutedFor(context),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.borderFor(context),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: selected
                      ? Row(
                          key: const ValueKey('selected'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                          ],
                        )
                      : const SizedBox(key: ValueKey('empty')),
                ),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? AppColors.textPrimaryFor(context)
                          : AppColors.textSoftFor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final quickCodes = <String>['USD', 'BRL', 'ARS', 'CLP'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickCodes
              .map(
                (code) => _ChoicePill(
                  label: code,
                  selected: value == code,
                  onTap: () => onChanged(code),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMutedFor(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.borderFor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.borderFor(context)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
          items: [
            ..._currencyOptions.map(
              (entry) =>
                  DropdownMenuItem(value: entry.code, child: Text(entry.label)),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SystemSettingsAction extends StatelessWidget {
  const _SystemSettingsAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C8DFF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: Color(0xFF5D6DFF),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntranceReveal extends StatelessWidget {
  const _EntranceReveal({required this.delayIndex, required this.child});

  final int delayIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final begin = 0.92 + (delayIndex * 0.01);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin.clamp(0.9, 0.98), end: 1),
      duration: Duration(milliseconds: 320 + (delayIndex * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, builtChild) {
        return Opacity(
          opacity: ((value - begin) / (1 - begin)).clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 28),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }
}
