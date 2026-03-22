import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_image_catalog.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';

/// Shown immediately after the questionnaire completes.
///
/// Reveals the recommended city with a cinematic hero image, a compatibility
/// score, the top reasons for the recommendation, and alternative cities the
/// user can explore before starting the guided plan.
class MigrationResultRevealPage extends StatefulWidget {
  const MigrationResultRevealPage({
    required this.controller,
    required this.citiesController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CitiesController citiesController;

  @override
  State<MigrationResultRevealPage> createState() =>
      _MigrationResultRevealPageState();
}

class _MigrationResultRevealPageState extends State<MigrationResultRevealPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.controller.initialize();
      if (!mounted) return;
      _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _openCityDetail(City city) {
    Navigator.pushNamed(
      context,
      AppRoutes.cityDetail(city.id),
      arguments: <String, dynamic>{
        'fromMigrationResult': true,
      },
    );
  }

  Future<void> _confirmAndRedo() async {
    final confirmed = await _showRedoConfirmationDialog();
    if (confirmed != true || !mounted) return;

    await widget.controller.clearCurrentPlan();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.migrationQuestionnaire);
  }

  Future<bool?> _showRedoConfirmationDialog() {
    final l10n = context.l10n;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              border: Border.all(color: const Color(0xFF1E2636)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 48,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1A2E),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        l10n.redoQuestionnaireDialogTitle(),
                        style: Theme.of(
                          dialogContext,
                        ).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF0F6FC),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Body
                      Text(
                        l10n.redoQuestionnaireDialogBody(),
                        style: Theme.of(
                          dialogContext,
                        ).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Warning callout
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.warning,
                              size: 13,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                l10n.redoQuestionnaireDialogWarning(),
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.warning,
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFF0D1117)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    children: [
                      // Confirm button
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F6FEB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.redoQuestionnaireDialogConfirm(),
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Cancel button
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(false),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2128),
                            border: Border.all(
                              color: const Color(0xFF2D333B),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.redoQuestionnaireDialogCancel(),
                            textAlign: TextAlign.center,
                            style: Theme.of(dialogContext)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCompatibilityBreakdown(City city, int compatibilityPct) {
    final l10n = context.l10n;
    final dims = MigrationPlanGenerator.cityDimensionsPublic(city);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: FrostedPanel(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.migrationResultRevealBreakdownTitle(city.name),
                          style: Theme.of(sheetCtx)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Dimension bars ──────────────────────────────────
                  ...dims.entries.map(
                    (entry) => _DimensionBar(
                      label: l10n.dimensionLabel(entry.key),
                      value: entry.value,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Overall ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.migrationResultRevealBreakdownOverall(),
                          style: Theme.of(sheetCtx)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '$compatibilityPct%',
                        style: Theme.of(sheetCtx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final plan = widget.controller.generatedPlan;
        final recommendedCity = plan?.recommendedCity;

        if (widget.controller.isInitializing ||
            plan == null ||
            recommendedCity == null) {
          return const Scaffold(
            body: Stack(
              children: [
                AmbientBackground(),
                SafeArea(
                  child: _RevealSkeleton(),
                ),
              ],
            ),
          );
        }

        final alternatives = plan.candidateCities
            .where((c) => c.id != recommendedCity.id)
            .toList(growable: false);

        final compatibilityPct =
            (plan.confidence * 100).round().clamp(0, 100);

        final reasons = plan.cityRecommendationReasons.isNotEmpty
            ? plan.cityRecommendationReasons
            : recommendedCity.recommendationReasons;

        final preferredCity = plan.preferredCity;
        final hasPreferred = preferredCity != null;
        final preferredMatchesRecommended =
            hasPreferred && preferredCity.id == recommendedCity.id;

        return Scaffold(
          body: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Stack(
                children: [
                  const AmbientBackground(),
                  // ── Main scrollable content ─────────────────────────
                  Column(
                    children: [
                      _HeroSection(city: recommendedCity),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                          children: [
                            // ── Anti-anchoring: reinforcement ──
                            if (hasPreferred && preferredMatchesRecommended)
                              _AntiAnchorReinforcementBanner(
                                cityName: recommendedCity.name,
                              ),

                            // ── Anti-anchoring: comparison ──
                            if (hasPreferred && !preferredMatchesRecommended)
                              _AntiAnchorComparisonSection(
                                preferredCity: preferredCity,
                                recommendedCity: recommendedCity,
                                onGoWithPreferred: () =>
                                    _openCityDetail(preferredCity),
                                onTryRecommended: () =>
                                    _openCityDetail(recommendedCity),
                              ),

                            if (hasPreferred) const SizedBox(height: 16),

                            _CompatibilityCard(
                              city: recommendedCity,
                              compatibilityPct: compatibilityPct,
                              onTap: () => _showCompatibilityBreakdown(
                                recommendedCity,
                                compatibilityPct,
                              ),
                            ),
                            if (reasons.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _WhyCitySection(
                                cityName: recommendedCity.name,
                                reasons: reasons,
                              ),
                            ],
                            if (alternatives.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _AlternativesSection(
                                cities: alternatives,
                                confidence: plan.confidence,
                                onTap: _openCityDetail,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ── Fixed footer ───────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _FooterCta(
                      city: recommendedCity,
                      onViewDetails: () => _openCityDetail(recommendedCity),
                      onRedo: _confirmAndRedo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final imageUrl = cityImageUrlFor(city.id);
    final heroHeight = MediaQuery.of(context).size.height * 0.38;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _PlaceholderHero(city: city),
            )
          else
            _PlaceholderHero(city: city),

          // Gradient overlay: transparent top → dark bottom
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),

          // City name + eyebrow
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.migrationResultRevealEyebrow,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city.name,
                    style:
                        Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${city.stateName} · ${city.stateCode}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderHero extends StatelessWidget {
  const _PlaceholderHero({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.isDark(context)
          ? const Color(0xFF0D1B2A)
          : const Color(0xFF1A3A5C),
      child: Center(
        child: Text(
          city.name[0],
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.2),
            fontSize: 120,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ─── Compatibility card ────────────────────────────────────────────────────────

class _CompatibilityCard extends StatelessWidget {
  const _CompatibilityCard({
    required this.city,
    required this.compatibilityPct,
    required this.onTap,
  });

  final City city;
  final int compatibilityPct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compatLabel = compatibilityPct >= 80
        ? l10n.migrationPlanResultCompatibilityHigh
        : compatibilityPct >= 60
        ? l10n.migrationPlanResultCompatibilityMedium
        : l10n.migrationPlanResultCompatibilityInitial;

    final barColor = compatibilityPct >= 80
        ? AppColors.success
        : compatibilityPct >= 60
        ? AppColors.warning
        : const Color(0xFF0088FF);

    return GestureDetector(
      onTap: onTap,
      child: FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    compatLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  l10n.migrationResultRevealCompatibilityLabel(compatibilityPct),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: barColor,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textSoftFor(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: compatibilityPct / 100,
                minHeight: 6,
                backgroundColor: AppColors.isDark(context)
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.migrationResultRevealTapToSeeDetails(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Why this city ─────────────────────────────────────────────────────────────

class _WhyCitySection extends StatelessWidget {
  const _WhyCitySection({
    required this.cityName,
    required this.reasons,
  });

  final String cityName;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            l10n.migrationResultRevealWhyTitle(cityName),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...reasons.take(3).map(
          (reason) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FrostedPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 5, right: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      // Resolve l10n key → human-readable text
                      l10n.recommendationReasonLabel(reason),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Alternatives ──────────────────────────────────────────────────────────────

class _AlternativesSection extends StatelessWidget {
  const _AlternativesSection({
    required this.cities,
    required this.confidence,
    required this.onTap,
  });

  final List<City> cities;
  final double confidence;
  final void Function(City) onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            l10n.migrationResultRevealOtherOptionsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...cities.take(2).indexed.map(
          (entry) {
            final (index, city) = entry;
            final imageUrl = cityImageUrlFor(city.id);
            // Alternatives receive a lower compatibility estimate:
            // 2nd city = ~85% of top; 3rd city = ~70% of top
            final altPct = ((confidence * (index == 0 ? 0.85 : 0.70)) * 100)
                .round()
                .clamp(0, 100);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => onTap(city),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // City thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) =>
                                        _AltCityPlaceholder(city: city),
                                  )
                                : _AltCityPlaceholder(city: city),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${city.stateName} · ${city.stateCode}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Compatibility badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$altPct%',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textSoftFor(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AltCityPlaceholder extends StatelessWidget {
  const _AltCityPlaceholder({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.isDark(context)
          ? const Color(0xFF1A3A5C)
          : const Color(0xFF2E5C8A),
      alignment: Alignment.center,
      child: Text(
        city.name[0],
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.6),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Dimension breakdown bar ──────────────────────────────────────────────────

class _DimensionBar extends StatelessWidget {
  const _DimensionBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 5,
              backgroundColor: AppColors.isDark(context)
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer CTA ────────────────────────────────────────────────────────────────

class _FooterCta extends StatelessWidget {
  const _FooterCta({
    required this.city,
    required this.onViewDetails,
    required this.onRedo,
  });

  final City city;
  final VoidCallback onViewDetails;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF07101C).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onViewDetails,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.migrationResultRevealViewDetailsCta(city.name),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRedo,
            child: Text(
              l10n.migrationResultRevealRedoAction,
              style: TextStyle(
                color: AppColors.textSoftFor(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ──────────────────────────────────────────────────────────

class _RevealSkeleton extends StatelessWidget {
  const _RevealSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final shimmer = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    return Column(
      children: [
        // Hero placeholder
        Container(
          height: MediaQuery.of(context).size.height * 0.38,
          color: shimmer,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Anti-Anchoring: Reinforcement Banner ───────────────────────────────────

class _AntiAnchorReinforcementBanner extends StatelessWidget {
  const _AntiAnchorReinforcementBanner({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.thumb_up_alt_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.antiAnchorReinforcementTitle(cityName),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.antiAnchorReinforcementBody(cityName),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Anti-Anchoring: Comparison Section ─────────────────────────────────────

class _AntiAnchorComparisonSection extends StatelessWidget {
  const _AntiAnchorComparisonSection({
    required this.preferredCity,
    required this.recommendedCity,
    required this.onGoWithPreferred,
    required this.onTryRecommended,
  });

  final City preferredCity;
  final City recommendedCity;
  final VoidCallback onGoWithPreferred;
  final VoidCallback onTryRecommended;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);

    // Build dimension comparisons.
    final prefDims = MigrationPlanGenerator.cityDimensionsPublic(preferredCity);
    final recDims = MigrationPlanGenerator.cityDimensionsPublic(recommendedCity);

    // Find key differences (where recommended beats preferred by >10 points).
    final strengths = <String>[];
    final attentionPoints = <String>[];

    for (final key in recDims.keys) {
      final recVal = recDims[key] ?? 0;
      final prefVal = prefDims[key] ?? 0;
      final diff = recVal - prefVal;
      if (diff > 0.10) {
        strengths.add(l10n.dimensionLabel(key));
      } else if (diff < -0.10) {
        attentionPoints.add(l10n.dimensionLabel(key));
      }
    }

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.antiAnchorComparisonTitle(preferredCity.name),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.antiAnchorComparisonBody(
                        preferredCity.name,
                        recommendedCity.name,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Strengths of recommended city
          if (strengths.isNotEmpty) ...[
            Text(
              '${l10n.antiAnchorStrength()} · ${recommendedCity.name}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 6),
            ...strengths.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(s, style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Attention points (where preferred city does better)
          if (attentionPoints.isNotEmpty) ...[
            Text(
              '${l10n.antiAnchorAttention()} · ${recommendedCity.name}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 6),
            ...attentionPoints.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(s, style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Dual CTA
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onGoWithPreferred,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.antiAnchorGoWithPreferred(preferredCity.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onTryRecommended,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.antiAnchorTryRecommended(recommendedCity.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
