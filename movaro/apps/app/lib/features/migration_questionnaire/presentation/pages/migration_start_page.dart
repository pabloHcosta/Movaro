import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_picker_bottom_sheet.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class MigrationStartPage extends StatefulWidget {
  const MigrationStartPage({
    required this.controller,
    required this.citiesController,
    required this.locationController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CitiesController citiesController;
  final LocationController locationController;

  @override
  State<MigrationStartPage> createState() => _MigrationStartPageState();
}

class _MigrationStartPageState extends State<MigrationStartPage> {
  bool _isOpeningCityPicker = false;
  bool _isStartingQuestions = false;
  bool _didGateLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.citiesController.prefetchCatalog();
      widget.controller.initialize();
      _ensureLocationGate();
    });
  }

  Future<void> _ensureLocationGate() async {
    if (_didGateLocation) {
      return;
    }
    _didGateLocation = true;

    await widget.locationController.initialize();
    if (!mounted || widget.locationController.hasGrantedPermission) {
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.locationPermission,
      arguments: const LocationPermissionScreenArgs(
        returnToPrevious: true,
        isRequired: true,
      ),
    );
  }

  Future<void> _handleKnownCity() async {
    if (_isOpeningCityPicker) {
      return;
    }

    setState(() {
      _isOpeningCityPicker = true;
    });

    try {
      await widget.citiesController.loadCatalog();
      if (!mounted) {
        return;
      }

      final cities = widget.citiesController.catalog;
      if (cities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.migrationStartCityLoadError())),
        );
        return;
      }

      final selectedCity = await CityPickerBottomSheet.show(
        context: context,
        cities: cities,
        title: context.l10n.migrationStartKnownCityTitle(),
        subtitle: context.l10n.migrationStartKnownCitySubtitle(),
        initialSelection: widget.controller.preferredCity,
        confirmLabel: context.l10n.migrationStartConfirmCityAction(),
      );
      if (!mounted || selectedCity == null) {
        return;
      }

      widget.controller.setPreferredCity(selectedCity);
      Navigator.pushNamed(
        context,
        AppRoutes.cityDetail(selectedCity.id),
        arguments: const <String, dynamic>{'selectForPlan': true},
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningCityPicker = false;
        });
      }
    }
  }

  Future<void> _handleDeciding() async {
    if (_isStartingQuestions) {
      return;
    }

    setState(() {
      _isStartingQuestions = true;
    });

    try {
      await widget.controller.initializeForQuestionnaire();
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
    } finally {
      if (mounted) {
        setState(() {
          _isStartingQuestions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.pageHorizontalPadding,
                context.pageVerticalPadding,
                context.pageHorizontalPadding,
                context.pageVerticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    children: [
                      AppGlassHeader(
                        title: context.l10n.migrationStartPageTitle(),
                        onBack: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 760;

                            return ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _StartHeroPanel(
                                  title: context.l10n.migrationStartHeroTitle(),
                                  body: context.l10n.migrationStartHeroBody(),
                                  primary: primary,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 18),
                                if (isWide)
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _StartPathCard(
                                            icon: Icons.location_city_outlined,
                                            title: context.l10n
                                                .migrationStartKnownCityTitle(),
                                            subtitle: context.l10n
                                                .migrationStartKnownCitySubtitle(),
                                            ctaLabel: context.l10n
                                                .migrationStartKnownCityCta(),
                                            isLoading: _isOpeningCityPicker,
                                            onTap: _handleKnownCity,
                                            accent: primary,
                                            surfaceTint: primary.withValues(
                                              alpha: isDark ? 0.16 : 0.10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _StartPathCard(
                                            icon: Icons.alt_route_rounded,
                                            title: context.l10n
                                                .migrationStartDecidingTitle(),
                                            subtitle: context.l10n
                                                .migrationStartDecidingSubtitle(),
                                            ctaLabel: context.l10n
                                                .migrationStartDecidingCta(),
                                            isLoading: _isStartingQuestions,
                                            onTap: _handleDeciding,
                                            accent: isDark
                                                ? Colors.white
                                                : theme.colorScheme.onSurface,
                                            surfaceTint: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.06,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.03,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      _StartPathCard(
                                        icon: Icons.location_city_outlined,
                                        title: context.l10n
                                            .migrationStartKnownCityTitle(),
                                        subtitle: context.l10n
                                            .migrationStartKnownCitySubtitle(),
                                        ctaLabel: context.l10n
                                            .migrationStartKnownCityCta(),
                                        isLoading: _isOpeningCityPicker,
                                        onTap: _handleKnownCity,
                                        accent: primary,
                                        surfaceTint: primary.withValues(
                                          alpha: isDark ? 0.16 : 0.10,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _StartPathCard(
                                        icon: Icons.alt_route_rounded,
                                        title: context.l10n
                                            .migrationStartDecidingTitle(),
                                        subtitle: context.l10n
                                            .migrationStartDecidingSubtitle(),
                                        ctaLabel: context.l10n
                                            .migrationStartDecidingCta(),
                                        isLoading: _isStartingQuestions,
                                        onTap: _handleDeciding,
                                        accent: isDark
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                        surfaceTint: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.06,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartHeroPanel extends StatelessWidget {
  const _StartHeroPanel({
    required this.title,
    required this.body,
    required this.primary,
    required this.isDark,
  });

  final String title;
  final String body;
  final Color primary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      borderRadius: BorderRadius.circular(36),
      backgroundColor: isDark
          ? const Color(0xC0161D29)
          : Colors.white.withValues(alpha: 0.72),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withValues(alpha: isDark ? 0.24 : 0.12),
          (isDark ? const Color(0xFF111827) : Colors.white).withValues(
            alpha: isDark ? 0.82 : 0.56,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartPathCard extends StatelessWidget {
  const _StartPathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.isLoading,
    required this.onTap,
    required this.accent,
    required this.surfaceTint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final bool isLoading;
  final VoidCallback onTap;
  final Color accent;
  final Color surfaceTint;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 240),
      child: FrostedPanel(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        borderRadius: BorderRadius.circular(32),
        backgroundColor: surfaceTint == Colors.transparent
            ? AppColors.frostedBackgroundFor(context)
            : AppColors.frostedBackgroundFor(context).withValues(alpha: 0.92),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceTint, AppColors.frostedBackgroundFor(context)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
