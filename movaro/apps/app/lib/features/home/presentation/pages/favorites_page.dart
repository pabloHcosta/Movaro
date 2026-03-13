import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_weather_badge.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            title: context.l10n.mainNavFavorites,
                            onBack: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.publicHome,
                            ),
                          ),
                        ),
                        FrostedPanel(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.publicHomeFavoritesTitle,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                favorites.isEmpty
                                    ? context.l10n.favoritesEmptyBody
                                    : context.l10n.publicHomeFavoritesBody,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (favorites.isEmpty)
                          FrostedPanel(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.favorite_outline_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  context.l10n.favoritesEmptyTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.favoritesEmptyHint,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSoftFor(context),
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 18),
                                FilledButton.icon(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.cities,
                                      ),
                                  icon: const Icon(
                                    Icons.travel_explore_rounded,
                                  ),
                                  label: Text(
                                    context.l10n.favoritesExploreAction,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 820;
                              final medium = constraints.maxWidth >= 560;
                              final itemWidth = wide
                                  ? (constraints.maxWidth - 24) / 3
                                  : medium
                                  ? (constraints.maxWidth - 12) / 2
                                  : constraints.maxWidth;

                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (final city in favorites)
                                    SizedBox(
                                      width: itemWidth,
                                      child: FavoriteCityCard(
                                        city: city,
                                        citiesController: citiesController,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
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
        currentIndex: 1,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }
}

class FavoriteCityCard extends StatelessWidget {
  const FavoriteCityCard({
    required this.city,
    required this.citiesController,
    super.key,
  });

  final City city;
  final CitiesController citiesController;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final housing = city.rentScore >= 70
        ? context.l10n.cityHousingViabilityEasyBadge
        : city.rentScore >= 45
        ? context.l10n.cityHousingViabilityBalancedBadge
        : context.l10n.cityHousingViabilityHardBadge;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.10);
    final cardShadow = isDark
        ? Colors.black.withValues(alpha: 0.16)
        : const Color(0x1A315A8A);
    final accentPanel = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xCCFFFFFF);
    final accentBorder = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.primary.withValues(alpha: 0.10);
    final chrome = Colors.white;
    final textSoft = Colors.white.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.cityDetail(city.id)),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: cardShadow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CityImageBackdrop(
            city: city,
            borderRadius: BorderRadius.circular(24),
            overlayOpacity: isDark ? 0.76 : 0.68,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${city.stateName} (${city.stateCode})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: textSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => citiesController.toggleFavorite(
                            city.id,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x33E25273),
                            foregroundColor: const Color(0xFFE25273),
                          ),
                          icon: const Icon(
                            Icons.favorite_rounded,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 18,
                          color: chrome.withValues(alpha: 0.84),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CityWeatherBadge(
                  cityId: city.id,
                  citiesController: citiesController,
                  prominent: true,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentPanel,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 15,
                        color: chrome.withValues(alpha: 0.82),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          housing,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.publicHomeFavoriteCardHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: textSoft,
                    height: 1.3,
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
