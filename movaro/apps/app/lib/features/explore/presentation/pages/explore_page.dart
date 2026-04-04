import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/home/application/city_feed_datasource.dart';
import 'package:movaro_app/features/home/domain/city_feed_item.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const _helpPreferenceKey = 'explore_page';
  bool _didTryAutoHelp = false;

  JourneyContextController get journeyContextController =>
      widget.journeyContextController;
  CitiesController get citiesController => widget.citiesController;
  MigrationQuestionnaireController get migrationQuestionnaireController =>
      widget.migrationQuestionnaireController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowHelp();
    });
  }

  Future<void> _maybeShowHelp() async {
    if (_didTryAutoHelp) {
      return;
    }
    _didTryAutoHelp = true;
    await maybeShowContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _helpContent(context),
    );
  }

  Future<void> _showHelp() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _helpContent(context),
    );
  }

  ContextualHelpContent _helpContent(BuildContext context) {
    return ContextualHelpContent(
      eyebrow: context.l10n.mainNavExplore,
      contextIcon: Icons.explore_outlined,
      title: context.l10n.exploreGuideTitle(),
      body: context.l10n.exploreGuideBody(),
      steps: [
        FeatureGuideStep(
          number: '1',
          title: context.l10n.exploreGuideStepOneTitle(),
          body: context.l10n.exploreGuideStepOneBody(),
        ),
        FeatureGuideStep(
          number: '2',
          title: context.l10n.exploreGuideStepTwoTitle(),
          body: context.l10n.exploreGuideStepTwoBody(),
        ),
        FeatureGuideStep(
          number: '3',
          title: context.l10n.exploreGuideStepThreeTitle(),
          body: context.l10n.exploreGuideStepThreeBody(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    journeyContextController,
                    citiesController,
                    migrationQuestionnaireController,
                  ]),
                  builder: (context, _) {
                    final plan = migrationQuestionnaireController.generatedPlan;
                    final routeLabel = _routeLabel(
                      context,
                      journeyContextController,
                    );
                    final suggestedCities = _suggestedCities(
                      plan,
                      citiesController.catalog,
                    );
                    final locale =
                        Localizations.localeOf(context).languageCode;
                    final stage = _journeyStage(plan);
                    final seasonalCities = suggestedCities
                        .where(CitySeasonalityProfile.hasSeason)
                        .toList(growable: false);

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 96,
                      ),
                      children: [
                        AppGlassHeader(
                          title: l10n.mainNavExplore,
                          onBack: Navigator.canPop(context)
                              ? () => Navigator.maybePop(context)
                              : null,
                          onHelp: _showHelp,
                        ),
                        const SizedBox(height: 20),
                        _ExploreHeroPanel(
                          routeLabel: routeLabel,
                          plan: plan,
                          cityCount: suggestedCities.length,
                        ),
                        const SizedBox(height: 18),
                        _ExploreSectionShell(
                          title: l10n.explorePlanSectionTitle,
                          child: _PlanSection(
                            plan: plan,
                            onOpenPlan: () => Navigator.pushNamed(
                              context,
                              _planRoute(
                                journeyContextController,
                                migrationQuestionnaireController,
                              ),
                            ),
                            onOpenCity: (city) => Navigator.pushNamed(
                              context,
                              AppRoutes.cityDetail(city.id),
                            ),
                            onOpenDocs: (section) => Navigator.pushNamed(
                              context,
                              AppRoutes.documentationGuide,
                              arguments: section,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ExploreSectionShell(
                          title: l10n.exploreCitiesSectionTitle,
                          trailing: TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.cities),
                            child: Text(l10n.exploreCitiesAction),
                          ),
                          child: _CityShowcaseRail(cities: suggestedCities),
                        ),
                        const SizedBox(height: 16),
                        _ExploreSectionShell(
                          title: l10n.exploreContentSectionTitle,
                          child: _ContentSection(
                            onOpenSection: (section) => Navigator.pushNamed(
                              context,
                              AppRoutes.documentationGuide,
                              arguments: section,
                            ),
                          ),
                        ),
                        // ── Curated insights ─────────────────────────────────
                        const SizedBox(height: 16),
                        _ExploreSectionShell(
                          title: _insightsSectionTitle(locale),
                          child: _ExploreInsightsSection(
                            locale: locale,
                            stage: stage,
                            cityCode: plan?.recommendedCity?.id,
                            onTapCity: (city) => Navigator.pushNamed(
                              context,
                              AppRoutes.cityDetail(city.id),
                            ),
                          ),
                        ),
                        // ── Seasonality alerts ────────────────────────────────
                        if (seasonalCities.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _ExploreSectionShell(
                            title: _seasonalitySectionTitle(locale),
                            child: _ExploreSeasonalityAlerts(
                              cities: seasonalCities,
                              locale: locale,
                              onTapCity: (city) => Navigator.pushNamed(
                                context,
                                AppRoutes.cityDetail(city.id),
                              ),
                            ),
                          ),
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
        currentIndex: 1,
        journeyContextController: journeyContextController,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }

  String _routeLabel(
    BuildContext context,
    JourneyContextController journeyContextController,
  ) {
    final origin = journeyContextController.selectedOrigin;
    final destination = journeyContextController.selectedDestination;
    if (origin != null && destination != null) {
      return context.l10n.exploreRouteLabel(origin.name, destination.name);
    }
    if (destination != null) {
      return context.l10n.exploreDestinationLabel(destination.name);
    }
    return context.l10n.exploreNoJourneyLabel;
  }

  List<City> _suggestedCities(MigrationPlan? plan, List<City> catalog) {
    final suggestions = <City>[];
    if (plan?.candidateCities case final candidates?) {
      suggestions.addAll(candidates.take(3));
    }

    for (final city in catalog) {
      if (suggestions.any((item) => item.id == city.id)) {
        continue;
      }
      suggestions.add(city);
      if (suggestions.length == 3) {
        break;
      }
    }

    return suggestions.take(3).toList(growable: false);
  }

  static UserJourneyStage _journeyStage(MigrationPlan? plan) {
    if (plan == null) return UserJourneyStage.explorer;
    return switch (plan.timeline) {
      'in_0_3m' => UserJourneyStage.executor,
      'in_3_6m' => UserJourneyStage.planner,
      _ => UserJourneyStage.explorer,
    };
  }

  static String _insightsSectionTitle(String locale) => switch (locale) {
    'pt' => 'Insights para migrantes',
    'es' => 'Insights para migrantes',
    _ => 'Migrant insights',
  };

  static String _seasonalitySectionTitle(String locale) => switch (locale) {
    'pt' => 'Alertas de sazonalidade',
    'es' => 'Alertas de temporada',
    _ => 'Seasonality alerts',
  };

  String _planRoute(
    JourneyContextController journeyContextController,
    MigrationQuestionnaireController migrationQuestionnaireController,
  ) {
    final plan = migrationQuestionnaireController.generatedPlan;
    if (plan?.isCityConfirmed == true) {
      return AppRoutes.migrationPlanCopilot;
    }
    if (plan != null) {
      return AppRoutes.migrationResultReveal;
    }
    return AppRoutes.publicHome;
  }
}

class _ExploreHeroPanel extends StatelessWidget {
  const _ExploreHeroPanel({
    required this.routeLabel,
    required this.plan,
    required this.cityCount,
  });

  final String routeLabel;
  final MigrationPlan? plan;
  final int cityCount;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final leadCity = plan?.recommendedCity;
    final planReady = plan?.isCityConfirmed == true;
    final statusLabel = plan == null
        ? context.l10n.explorePlanEmptyTitle
        : planReady
        ? context.l10n.explorePlanReadyTitle
        : context.l10n.explorePlanDraftTitle;

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      gradient: LinearGradient(
        colors: isDark
            ? const [
                AppColors.heroStart,
                AppColors.heroMiddle,
                AppColors.heroEnd,
              ]
            : const [Color(0xFFF6FBFF), Color(0xFFE6F1FF), Color(0xFFD1E7FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: isDark
          ? const Color(0xB30B1320)
          : const Color(0xF7FFFFFF),
      borderColor: isDark
          ? const Color(0x1AFFFFFF)
          : AppColors.primary.withValues(alpha: 0.10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          final stats = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroStatCard(
                label: context.l10n.mainNavPlan,
                value: statusLabel,
                icon: planReady
                    ? Icons.check_circle_rounded
                    : Icons.explore_rounded,
              ),
              _HeroStatCard(
                label: context.l10n.exploreCitiesSectionTitle,
                value: '$cityCount',
                icon: Icons.location_city_rounded,
              ),
              if (leadCity != null)
                _HeroStatCard(
                  label: context.l10n.exploreRecommendedCityTitle,
                  value: leadCity.name,
                  icon: Icons.place_rounded,
                ),
            ],
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.exploreTrailsEyebrow,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.82)
                      : AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.exploreUnifiedTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: isDark
                      ? Colors.white
                      : AppColors.textPrimaryFor(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              ScoreBadge(
                label: routeLabel,
                icon: Icons.route_rounded,
                inverse: isDark,
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 18), stats],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: content),
              const SizedBox(width: 18),
              Expanded(flex: 5, child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white : AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.74)
                  : AppColors.textSoftFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreSectionShell extends StatelessWidget {
  const _ExploreSectionShell({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
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
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              if (trailing != null) ...[trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.plan,
    required this.onOpenPlan,
    required this.onOpenCity,
    required this.onOpenDocs,
  });

  final MigrationPlan? plan;
  final VoidCallback onOpenPlan;
  final ValueChanged<City> onOpenCity;
  final ValueChanged<DocumentationGuideSection> onOpenDocs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final leadCity = plan?.recommendedCity;
    final title = plan == null
        ? l10n.explorePlanEmptyTitle
        : plan!.isCityConfirmed
        ? l10n.explorePlanReadyTitle
        : l10n.explorePlanDraftTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlanFocusCard(
          title: title,
          city: leadCity,
          isConfirmed: plan?.isCityConfirmed == true,
          onOpenPlan: onOpenPlan,
        ),
        if (leadCity != null) ...[
          const SizedBox(height: 14),
          _CityFeatureCard(
            city: leadCity,
            badge: l10n.migrationPlanSuggestedCityBadge,
            accent: AppColors.primary,
            actionLabel: l10n.exploreOpenCityAction,
            onTap: () => onOpenCity(leadCity),
          ),
        ] else ...[
          const SizedBox(height: 14),
          _ContentTopicCard(
            title: l10n.documentationPathDocumentsTitle,
            subtitle: l10n.exploreOpenContentAction,
            icon: Icons.badge_outlined,
            accent: AppColors.primary,
            onTap: () => onOpenDocs(DocumentationGuideSection.documents),
          ),
        ],
      ],
    );
  }
}

class _PlanFocusCard extends StatelessWidget {
  const _PlanFocusCard({
    required this.title,
    required this.city,
    required this.isConfirmed,
    required this.onOpenPlan,
  });

  final String title;
  final City? city;
  final bool isConfirmed;
  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final actionLabel = isConfirmed
        ? context.l10n.mainNavPlan
        : context.l10n.publicHomeQuestionnaireAction;

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroMiddle, AppColors.heroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xB30B1320),
      borderColor: const Color(0x1AFFFFFF),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final metrics = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ScoreBadge(
                label: title,
                icon: isConfirmed
                    ? Icons.check_circle_rounded
                    : Icons.play_arrow_rounded,
                inverse: true,
              ),
              if (city != null)
                ScoreBadge(
                  label: '${city!.name} (${city!.stateCode})',
                  icon: Icons.location_city_rounded,
                  inverse: true,
                ),
            ],
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              metrics,
            ],
          );

          final action = FilledButton.icon(
            onPressed: onOpenPlan,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(actionLabel),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [content, const SizedBox(height: 16), action],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _CityShowcaseRail extends StatelessWidget {
  const _CityShowcaseRail({required this.cities});

  final List<City> cities;

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CityFeatureCard(
          city: cities.first,
          accent: const Color(0xFF35A8FF),
          actionLabel: context.l10n.exploreOpenCityAction,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.cityDetail(cities.first.id),
          ),
        ),
        if (cities.length > 1) ...[
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 760;
              final cardWidth = twoColumns
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final city in cities.skip(1))
                    SizedBox(
                      width: cardWidth,
                      child: _CityMiniCard(
                        city: city,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.cityDetail(city.id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.onOpenSection});

  final ValueChanged<DocumentationGuideSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final threeColumns = constraints.maxWidth >= 960;
        final twoColumns = constraints.maxWidth >= 640;
        final cardWidth = threeColumns
            ? (constraints.maxWidth - 24) / 3
            : twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _ContentTopicCard(
                title: context.l10n.documentationPathDocumentsTitle,
                subtitle: context.l10n.exploreOpenContentAction,
                icon: Icons.badge_outlined,
                accent: AppColors.primary,
                onTap: () => onOpenSection(DocumentationGuideSection.documents),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ContentTopicCard(
                title: context.l10n.documentationHousingArrivalSectionTitle,
                subtitle: context.l10n.exploreOpenContentAction,
                icon: Icons.home_work_outlined,
                accent: AppColors.success,
                onTap: () => onOpenSection(DocumentationGuideSection.housing),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ContentTopicCard(
                title: context.l10n.documentationPathWorkTitle,
                subtitle: context.l10n.exploreOpenContentAction,
                icon: Icons.work_outline_rounded,
                accent: AppColors.caution,
                onTap: () => onOpenSection(DocumentationGuideSection.work),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CityFeatureCard extends StatelessWidget {
  const _CityFeatureCard({
    required this.city,
    required this.actionLabel,
    required this.onTap,
    this.badge,
    this.accent = AppColors.primary,
  });

  final City city;
  final String actionLabel;
  final String? badge;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${city.stateName} (${city.stateCode})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                ScoreBadge(label: badge!, icon: Icons.auto_awesome_rounded),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;
              final metricWidth = stacked
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 3;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: metricWidth,
                    child: _CitySignalMetric(
                      label: context.l10n.cityDetailAffordabilityTitle,
                      score: city.rentScore,
                      icon: Icons.home_work_outlined,
                      accent: accent,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _CitySignalMetric(
                      label: context.l10n.cityDetailQualityLabel,
                      score: (city.idhmScore * 100).round(),
                      icon: Icons.favorite_outline_rounded,
                      accent: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _CitySignalMetric(
                      label: context.l10n.cityDetailWorkLabel,
                      score: city.movaroScores.workOpportunity,
                      icon: Icons.work_outline_rounded,
                      accent: AppColors.caution,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _CityMiniCard extends StatelessWidget {
  const _CityMiniCard({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CompareCard(
      title: city.name,
      subtitle: '${city.stateName} (${city.stateCode})',
      metrics: [
        CompareCardMetric(
          label: context.l10n.cityDetailAffordabilityTitle,
          value: city.rentScore.toString(),
          icon: Icons.home_work_outlined,
        ),
        CompareCardMetric(
          label: context.l10n.cityDetailQualityLabel,
          value: city.idhmScore.toStringAsFixed(2),
          icon: Icons.favorite_outline_rounded,
        ),
      ],
      onTap: onTap,
      actionLabel: context.l10n.exploreOpenCityAction,
    );
  }
}

class _CitySignalMetric extends StatelessWidget {
  const _CitySignalMetric({
    required this.label,
    required this.score,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int score;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tone = _signalTone(context, score);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tone.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tone.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: tone.color),
              ),
              const Spacer(),
              Icon(tone.icon, size: 18, color: tone.color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tone.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tone.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _ExploreSignalTone _signalTone(BuildContext context, int value) {
    if (value >= 72) {
      return _ExploreSignalTone(
        label: context.l10n.exploreSignalStrong(),
        color: AppColors.success,
        icon: Icons.trending_up_rounded,
      );
    }
    if (value >= 52) {
      return _ExploreSignalTone(
        label: context.l10n.exploreSignalBalanced(),
        color: AppColors.warning,
        icon: Icons.remove_rounded,
      );
    }
    return _ExploreSignalTone(
      label: context.l10n.exploreSignalWatch(),
      color: AppColors.caution,
      icon: Icons.trending_down_rounded,
    );
  }
}

class _ExploreSignalTone {
  const _ExploreSignalTone({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class _ContentTopicCard extends StatelessWidget {
  const _ContentTopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          ScoreBadge(
            label: subtitle,
            icon: Icons.arrow_outward_rounded,
            tint: accent,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(context.l10n.exploreOpenContentAction),
          ),
        ],
      ),
    );
  }
}

// ─── Explore Insights Section ─────────────────────────────────────────────────
//
// Shows curated CityFeedDatasource items as vertical cards inside the Explore
// page. Works without a plan — general content (no city filter) is shown to
// explorers, city-specific content when a recommended city is known.

class _ExploreInsightsSection extends StatelessWidget {
  const _ExploreInsightsSection({
    required this.locale,
    required this.stage,
    required this.onTapCity,
    this.cityCode,
  });

  final String locale;
  final UserJourneyStage stage;
  final String? cityCode;
  final ValueChanged<City> onTapCity;

  @override
  Widget build(BuildContext context) {
    final items = CityFeedDatasource.build(
      cityCode: cityCode,
      stage: stage,
      locale: locale,
    ).take(5).toList(growable: false);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ExploreFeedCard(item: items[i], locale: locale),
        ],
      ],
    );
  }
}

class _ExploreFeedCard extends StatelessWidget {
  const _ExploreFeedCard({required this.item, required this.locale});

  final CityFeedItem item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final typeColor = item.typeColor(isDark);

    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: typeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.typeLabel(locale),
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (item.updatedAt != null)
                          Text(
                            item.updatedAt!,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  fontSize: 10,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (item.badge != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.badge!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0A0F1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Explore Seasonality Alerts ───────────────────────────────────────────────
//
// Compact alert cards for each city with high/medium seasonality, linking to
// the city detail page where the full seasonality section is shown.

class _ExploreSeasonalityAlerts extends StatelessWidget {
  const _ExploreSeasonalityAlerts({
    required this.cities,
    required this.locale,
    required this.onTapCity,
  });

  final List<City> cities;
  final String locale;
  final ValueChanged<City> onTapCity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cities.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _SeasonalityAlertCard(
            city: cities[i],
            locale: locale,
            onTap: () => onTapCity(cities[i]),
          ),
        ],
      ],
    );
  }
}

class _SeasonalityAlertCard extends StatelessWidget {
  const _SeasonalityAlertCard({
    required this.city,
    required this.locale,
    required this.onTap,
  });

  final City city;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snapshot = CitySeasonalityProfile.of(city);
    if (snapshot == null) return const SizedBox.shrink();

    final isDark = AppColors.isDark(context);
    final isHigh = snapshot.severity == CitySeasonalitySeverity.high;
    final accentColor = isHigh ? AppColors.danger : AppColors.caution;
    final peakLabel = _peakLabel(snapshot.peakMonths);
    final severityText = isHigh
        ? switch (locale) {
            'pt' => 'Alta temporada',
            'es' => 'Temporada alta',
            _ => 'Peak season',
          }
        : switch (locale) {
            'pt' => 'Sazonalidade média',
            'es' => 'Temporada media',
            _ => 'Moderate season',
          };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isHigh ? Icons.warning_rounded : Icons.info_outline_rounded,
              size: 18,
              color: accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          city.name,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0A0F1E),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          severityText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$peakLabel · ${snapshot.visitorsLabel(locale)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  String _peakLabel(List<int> months) {
    const names = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    if (months.isEmpty) return '';
    return months.map((m) => names[m - 1]).join(', ');
  }
}
