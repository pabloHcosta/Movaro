import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = AppColors.secondary;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppGlassHeader(
                        title: context.l10n.migrationStartPageTitle(),
                        onBack: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(height: 22),

                      // ── Section title ────────────────────────────────
                      Text(
                        context.l10n.migrationStartHeroTitle(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.migrationStartHeroBody(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Path cards ───────────────────────────────────
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 760;

                            if (isWide) {
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _IllustrativePathCard(
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
                                        isPrimary: true,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _IllustrativePathCard(
                                        icon: Icons.auto_awesome_rounded,
                                        title: context.l10n
                                            .migrationStartDecidingTitle(),
                                        subtitle: context.l10n
                                            .migrationStartDecidingSubtitle(),
                                        ctaLabel: context.l10n
                                            .migrationStartDecidingCta(),
                                        isLoading: _isStartingQuestions,
                                        onTap: _handleDeciding,
                                        accent: secondary,
                                        isPrimary: false,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: [
                                _IllustrativePathCard(
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
                                  isPrimary: true,
                                ),
                                const SizedBox(height: 14),
                                _IllustrativePathCard(
                                  icon: Icons.auto_awesome_rounded,
                                  title: context.l10n
                                      .migrationStartDecidingTitle(),
                                  subtitle: context.l10n
                                      .migrationStartDecidingSubtitle(),
                                  ctaLabel: context.l10n
                                      .migrationStartDecidingCta(),
                                  isLoading: _isStartingQuestions,
                                  onTap: _handleDeciding,
                                  accent: secondary,
                                  isPrimary: false,
                                ),
                                const Spacer(),
                              ],
                            );
                          },
                        ),
                      ),

                      // ── Footer ───────────────────────────────────────
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          context.l10n.migrationStartFootnote(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                AppColors.textSoftFor(context).withValues(
                                  alpha: 0.55,
                                ),
                          ),
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

// ─── Illustrative path card ───────────────────────────────────────────────────

class _IllustrativePathCard extends StatelessWidget {
  const _IllustrativePathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.isLoading,
    required this.onTap,
    required this.accent,
    required this.isPrimary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final bool isLoading;
  final VoidCallback onTap;
  final Color accent;

  /// True = solid primary button; False = outlined/tinted button.
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.12),
                  accent.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.15),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ── Decorative circles ────────────────────────────────
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  right: 22,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                // ── Card content ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon + title row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accent,
                                  accent.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                            child: Icon(icon, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        child: _CtaButton(
                          label: '→  $ctaLabel',
                          accent: accent,
                          isPrimary: isPrimary,
                          isLoading: isLoading,
                          onTap: onTap,
                        ),
                      ),
                    ],
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

// ─── CTA button variants ──────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.accent,
    required this.isPrimary,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isPrimary ? accent : accent.withValues(alpha: 0.20);
    final borderColor =
        isPrimary ? Colors.transparent : accent.withValues(alpha: 0.40);
    final textColor = isPrimary ? Colors.white : accent;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
