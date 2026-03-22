import 'dart:async';

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

  bool _isStarting = false;

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

  Future<void> _startPlan(City city) async {
    if (_isStarting) return;
    setState(() => _isStarting = true);

    try {
      if (!widget.controller.generatedPlan!.isCityConfirmed) {
        await widget.controller.confirmPlanCity(city);
      }
      if (!mounted) return;
      await _showCelebration(city.name);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.migrationPlanCopilot,
        (route) => route.settings.name == AppRoutes.publicHome,
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _showCelebration(String cityName) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        builder: (_) => _CelebrationOverlay(cityName: cityName),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _openCityDetail(City city) {
    Navigator.pushNamed(
      context,
      AppRoutes.cityDetail(city.id),
      arguments: <String, dynamic>{
        'fromMigrationResult': true,
      },
    );
  }

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
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          children: [
                            _CompatibilityCard(
                              city: recommendedCity,
                              compatibilityPct: compatibilityPct,
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
                      isLoading: _isStarting,
                      onStart: () => _startPlan(recommendedCity),
                      onRedo: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.migrationQuestionnaire,
                      ),
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
  });

  final City city;
  final int compatibilityPct;

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

    return FrostedPanel(
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
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            context.l10n.migrationResultRevealWhyTitle(cityName),
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
                      reason,
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
    required this.onTap,
  });

  final List<City> cities;
  final void Function(City) onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            context.l10n.migrationResultRevealOtherOptionsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...cities.take(2).map(
          (city) {
            final imageUrl = cityImageUrlFor(city.id);
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

// ─── Footer CTA ────────────────────────────────────────────────────────────────

class _FooterCta extends StatelessWidget {
  const _FooterCta({
    required this.city,
    required this.isLoading,
    required this.onStart,
    required this.onRedo,
  });

  final City city;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

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
              onPressed: isLoading ? null : onStart,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.l10n.migrationResultRevealStartCta(city.name),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRedo,
            child: Text(
              context.l10n.migrationResultRevealRedoAction,
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

// ─── Celebration overlay ───────────────────────────────────────────────────────

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2818),
          border: Border.all(color: const Color(0xFF1A4428)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              _localized(context, pt: 'Plano iniciado!', es: 'Plan iniciado!', en: 'Plan started!'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFF0F6FC),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _localized(
                context,
                pt: 'Você escolheu $cityName.\nVamos transformar isso em realidade.',
                es: 'Elegiste $cityName.\nVamos a convertirlo en realidad.',
                en: 'You chose $cityName.\nLet\'s turn that into reality.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _localized(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    final lang = Localizations.localeOf(context).languageCode;
    return switch (lang) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}
