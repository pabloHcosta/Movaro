import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/explore_entry_card.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_explore_screen.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: AnimatedBuilder(
                  animation: citiesController,
                  builder: (context, _) {
                    final favorites = citiesController.favoriteCities;
                    final activePlanCityId = _resolveActivePlanCityId(
                      migrationQuestionnaireController,
                    );

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 24,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: AppGlassHeader(
                            title: context.l10n.favoritesPageTitle,
                            onBack: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.publicHome,
                            ),
                            trailing: _FavoritesCountBadge(
                              current: favorites.length,
                            ),
                          ),
                        ),
                        if (favorites.isEmpty)
                          _FavoritesEmptyState()
                        else ...[
                          if (favorites.length >= 2) ...[
                            _CompareBanner(
                              cities: favorites,
                              onCompare: () => _openComparison(
                                context,
                                favorites: favorites,
                                activePlanCityId: activePlanCityId,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          for (final city in favorites) ...[
                            _FavoriteCityCard(
                              city: city,
                              citiesController: citiesController,
                              migrationQuestionnaireController:
                                  migrationQuestionnaireController,
                              isActivePlanCity: city.id == activePlanCityId,
                            ),
                            if (city != favorites.last)
                              const SizedBox(height: 16),
                          ],
                          if (favorites.length <
                              CitiesController.maxFavoriteCities) ...[
                            const SizedBox(height: 16),
                            _AddCitySlot(currentCount: favorites.length),
                          ],
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 4,
        journeyContextController: journeyContextController,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }

  String? _resolveActivePlanCityId(
    MigrationQuestionnaireController controller,
  ) {
    final plan = controller.generatedPlan;
    if (plan == null || !plan.isCityConfirmed) {
      return null;
    }
    return plan.recommendedCity?.id;
  }

  void _openComparison(
    BuildContext context, {
    required List<City> favorites,
    required String? activePlanCityId,
  }) {
    final ordered = [...favorites];
    if (activePlanCityId != null) {
      ordered.sort((left, right) {
        final leftPriority = left.id == activePlanCityId ? 0 : 1;
        final rightPriority = right.id == activePlanCityId ? 0 : 1;
        return leftPriority.compareTo(rightPriority);
      });
    }
    Navigator.pushNamed(context, AppRoutes.cityComparison, arguments: ordered);
  }
}

class _FavoritesCountBadge extends StatelessWidget {
  const _FavoritesCountBadge({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        context.l10n.favoritesPageCount(
          current,
          CitiesController.maxFavoriteCities,
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompareBanner extends StatelessWidget {
  const _CompareBanner({required this.cities, required this.onCompare});

  final List<City> cities;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final left = cities.first.name;
    final right = cities[1].name;

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.compare_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.favoritesCompareTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.favoritesCompareSubtitle(left, right),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onCompare,
            child: Text(context.l10n.favoritesCompareAction),
          ),
        ],
      ),
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.favoritesPageEmptyTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.favoritesPageEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.cities),
            icon: const Icon(Icons.travel_explore_rounded),
            label: Text(context.l10n.favoritesExploreAction),
          ),
        ],
      ),
    );
  }
}

class _AddCitySlot extends StatelessWidget {
  const _AddCitySlot({required this.currentCount});

  final int currentCount;

  @override
  Widget build(BuildContext context) {
    final available = CitiesController.maxFavoriteCities - currentCount;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.cities),
      child: CustomPaint(
        painter: _DashedCardPainter(color: AppColors.borderFor(context)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.favoritesAddCityTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.favoritesAddCitySubtitle(available),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteCityCard extends StatelessWidget {
  const _FavoriteCityCard({
    required this.city,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.isActivePlanCity,
  });

  final City city;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final bool isActivePlanCity;

  @override
  Widget build(BuildContext context) {
    unawaited(citiesController.loadWeatherForCity(city.id));
    final weather = citiesController.weatherFor(city.id);
    final cost = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.cost,
      value: city.costOfLivingScore,
    );
    final quality = CityIdhmPresentation.resolve(
      context,
      value: city.idhmScore,
    );
    final alert = _FavoriteCityAlert.resolve(context, city);
    final cardBorder = isActivePlanCity
        ? AppColors.primary.withValues(alpha: 0.24)
        : AppColors.borderFor(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _FavoriteCityHero(
              city: city,
              citiesController: citiesController,
              isActivePlanCity: isActivePlanCity,
              onToggleFavorite: () => _toggleFavorite(context),
              onOpenExternal: () => _openExternalOverview(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCell(
                          label: context.l10n.cityDetailCostLabel,
                          value: cost.headline,
                          tint: cost.tint,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCell(
                          label: context.l10n.favoritesClimateLabel,
                          value: _weatherLabel(context, weather),
                          tint: AppColors.primary,
                          loading: weather == null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCell(
                          label: context.l10n.favoritesQualityLabel,
                          value: quality.headline,
                          tint: quality.tint,
                        ),
                      ),
                    ],
                  ),
                  if (alert != null) ...[
                    const SizedBox(height: 12),
                    _AlertRow(alert: alert),
                  ],
                  const SizedBox(height: 12),
                  ExploreEntryCard(
                    cityName: city.name,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CityExploreScreen(
                          city: city,
                          isPlanCity: isActivePlanCity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _handlePrimaryAction(context),
                          child: Text(
                            isActivePlanCity
                                ? context.l10n.favoritesContinuePlanAction
                                : context.l10n.favoritesOpenDetailsAction,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => _toggleFavorite(context),
                        child: Text(context.l10n.favoritesRemoveAction),
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

  Future<void> _toggleFavorite(BuildContext context) async {
    final result = await citiesController.toggleFavorite(city.id);
    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      CityFavoriteToggleResult.added =>
        context.l10n.cityDetailFavoriteAddedFeedback(city.name),
      CityFavoriteToggleResult.removed =>
        context.l10n.cityDetailFavoriteRemovedFeedback(city.name),
      CityFavoriteToggleResult.limitReached =>
        context.l10n.cityDetailFavoriteLimitFeedback(
          CitiesController.maxFavoriteCities,
        ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handlePrimaryAction(BuildContext context) {
    if (isActivePlanCity) {
      Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.cityDetail(city.id));
  }

  Future<void> _openExternalOverview(BuildContext context) async {
    final uri = PreparationResourceLinks.buildCityGoogleSearch(city);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.cityDetailDiscoverAction,
          uri: uri,
        ),
      ),
    );
  }

  String _weatherLabel(BuildContext context, CityWeather? weather) {
    if (weather == null) {
      return context.l10n.favoritesClimatePending;
    }
    return '${weather.temperatureCelsius.round()}°C';
  }
}

class _FavoriteCityHero extends StatelessWidget {
  const _FavoriteCityHero({
    required this.city,
    required this.citiesController,
    required this.isActivePlanCity,
    required this.onToggleFavorite,
    required this.onOpenExternal,
  });

  final City city;
  final CitiesController citiesController;
  final bool isActivePlanCity;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CityResolvedImage(
            city: city,
            fit: BoxFit.cover,
            placeholder: const SkeletonBox(height: 80),
            errorWidget: _HeroFallback(city: city),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF07111F).withValues(alpha: 0.70),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                if (isActivePlanCity)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.l10n.favoritesActivePlanBadge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HeroIconButton(
                        icon: Icons.favorite_rounded,
                        tint: const Color(0xFFE25273),
                        onTap: onToggleFavorite,
                      ),
                      const SizedBox(width: 8),
                      _HeroIconButton(
                        icon: Icons.arrow_outward_rounded,
                        tint: Colors.white,
                        onTap: onOpenExternal,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${city.stateName} (${city.stateCode})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
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
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, size: 18, color: tint),
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102038), Color(0xFF17345D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.location_city_outlined,
          size: 26,
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.tint,
    this.loading = false,
  });

  final String label;
  final String value;
  final Color tint;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          if (loading)
            const SkeletonBox(height: 14, width: 56)
          else
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: tint,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final _FavoriteCityAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: alert.tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alert.tint.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, size: 16, color: alert.tint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: alert.tint,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCityAlert {
  const _FavoriteCityAlert({
    required this.text,
    required this.tint,
    required this.icon,
  });

  final String text;
  final Color tint;
  final IconData icon;

  static _FavoriteCityAlert? resolve(BuildContext context, City city) {
    final criticalPoints =
        city.publicOpinion?.criticalPoints ?? const <String>[];
    final criticalPoint = criticalPoints.isNotEmpty
        ? criticalPoints.first
        : null;
    if (criticalPoint != null && criticalPoint.isNotEmpty) {
      return _FavoriteCityAlert(
        text: criticalPoint,
        tint: AppColors.danger,
        icon: Icons.warning_amber_rounded,
      );
    }

    if (city.rentScore < 55) {
      return _FavoriteCityAlert(
        text: CityHousingViabilityPresenter.resolve(
          context,
          rentScore: city.rentScore,
        ).supporting,
        tint: AppColors.warning,
        icon: Icons.home_work_outlined,
      );
    }

    return null;
  }
}

class _DashedCardPainter extends CustomPainter {
  const _DashedCardPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 24.0;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth)
            .clamp(0.0, metric.length.toDouble())
            .toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCardPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
