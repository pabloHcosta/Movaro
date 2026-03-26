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

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppGlassHeader(
                        title: context.l10n.migrationStartPageTitle(),
                        onBack: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(height: 14),
                      FrostedPanel(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.migrationStartHeroTitle(),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.migrationStartHeroBody(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSoftFor(context),
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _StartOptionCard(
                              icon: Icons.location_city_outlined,
                              title: context.l10n
                                  .migrationStartKnownCityTitle(),
                              subtitle: context.l10n
                                  .migrationStartKnownCitySubtitle(),
                              ctaLabel: context.l10n
                                  .migrationStartKnownCityCta(),
                              isLoading: _isOpeningCityPicker,
                              onTap: _handleKnownCity,
                              accent: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            _StartOptionCard(
                              icon: Icons.alt_route_rounded,
                              title: context.l10n.migrationStartDecidingTitle(),
                              subtitle: context.l10n
                                  .migrationStartDecidingSubtitle(),
                              ctaLabel: context.l10n
                                  .migrationStartDecidingCta(),
                              isLoading: _isStartingQuestions,
                              onTap: _handleDeciding,
                              accent: isDark
                                  ? Colors.white.withValues(alpha: 0.88)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ],
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

class _StartOptionCard extends StatelessWidget {
  const _StartOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.isLoading,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final bool isLoading;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FrostedPanel(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.35,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
