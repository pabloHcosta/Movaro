import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_structure_widgets.dart';

class ExplorePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = AppColors.isDark(context);

    return Scaffold(
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
                        ),
                        const SizedBox(height: 20),
                        FrostedPanel(
                          padding: const EdgeInsets.all(32),
                          gradient: LinearGradient(
                            colors: isDark
                                ? const [
                                    AppColors.heroStart,
                                    AppColors.heroMiddle,
                                    AppColors.heroEnd,
                                  ]
                                : const [
                                    Color(0xFFF8FBFF),
                                    Color(0xFFEAF3FF),
                                    Color(0xFFD9EAFF),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          backgroundColor: isDark
                              ? const Color(0xB30B1320)
                              : const Color(0xF5FFFFFF),
                          borderColor: isDark
                              ? const Color(0x1AFFFFFF)
                              : AppColors.primary.withValues(alpha: 0.10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.exploreTrailsEyebrow,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.82)
                                          : AppColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.exploreUnifiedTitle,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimaryFor(context),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                routeLabel,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.78)
                                          : AppColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 720),
                                child: Text(
                                  l10n.exploreUnifiedBody,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.78,
                                              )
                                            : AppColors.textSoftFor(context),
                                        height: 1.45,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ExploreSection(
                          title: l10n.explorePlanSectionTitle,
                          body: l10n.explorePlanSectionBody,
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
                        _ExploreSection(
                          title: l10n.exploreCitiesSectionTitle,
                          body: l10n.exploreCitiesSectionBody,
                          trailing: TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.cities),
                            child: Text(l10n.exploreCitiesAction),
                          ),
                          child: _CitySuggestionRail(cities: suggestedCities),
                        ),
                        const SizedBox(height: 16),
                        _ExploreSection(
                          title: l10n.exploreContentSectionTitle,
                          body: l10n.exploreContentSectionBody,
                          child: _ContentSection(
                            onOpenSection: (section) => Navigator.pushNamed(
                              context,
                              AppRoutes.documentationGuide,
                              arguments: section,
                            ),
                          ),
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

  String _planRoute(
    JourneyContextController journeyContextController,
    MigrationQuestionnaireController migrationQuestionnaireController,
  ) {
    final plan = migrationQuestionnaireController.generatedPlan;
    if (plan?.isCityConfirmed == true) {
      return AppRoutes.migrationPlanCopilot;
    }
    if (plan != null) {
      return AppRoutes.migrationPlanResult;
    }
    if (journeyContextController.hasDestinationSelected) {
      return AppRoutes.migrationQuestionnaire;
    }
    return AppRoutes.journeySetup;
  }
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection({
    required this.title,
    required this.body,
    required this.child,
    this.trailing,
  });

  final String title;
  final String body;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
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
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanNextActionCard(
          eyebrow: l10n.migrationPlanResultPrimaryCtaEyebrow,
          title: plan == null
              ? l10n.explorePlanEmptyTitle
              : plan!.isCityConfirmed
              ? l10n.explorePlanReadyTitle
              : l10n.explorePlanDraftTitle,
          body: plan == null
              ? l10n.explorePlanEmptyBody
              : leadCity == null
              ? l10n.explorePlanDraftBody
              : plan!.isCityConfirmed
              ? l10n.explorePlanReadyBody(leadCity.name)
              : l10n.explorePlanDraftBodyWithCity(leadCity.name),
          actionLabel: plan?.isCityConfirmed == true
              ? l10n.mainNavPlan
              : l10n.publicHomeQuestionnaireAction,
          onTap: onOpenPlan,
          icon: plan?.isCityConfirmed == true
              ? Icons.checklist_rounded
              : Icons.play_arrow_rounded,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 700;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (leadCity != null)
                  SizedBox(
                    width: cardWidth,
                    child: _CompactCityCard(
                      city: leadCity,
                      title: l10n.exploreRecommendedCityTitle,
                      body: l10n.exploreRecommendedCityBody,
                      actionLabel: l10n.exploreOpenCityAction,
                      onTap: () => onOpenCity(leadCity),
                    ),
                  ),
                SizedBox(
                  width: cardWidth,
                  child: _ContentCard(
                    title: l10n.documentationPathDocumentsTitle,
                    body: l10n.explorePlanDocsBody,
                    actionLabel: l10n.exploreOpenContentAction,
                    icon: Icons.badge_outlined,
                    onTap: () => onOpenDocs(DocumentationGuideSection.documents),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CitySuggestionRail extends StatelessWidget {
  const _CitySuggestionRail({required this.cities});

  final List<City> cities;

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
      return const SizedBox.shrink();
    }

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
            for (final city in cities)
              SizedBox(
                width: cardWidth,
                child: _CompactCityCard(
                  city: city,
                  title: city.name,
                  body: '${city.stateName} · ${city.regionName ?? city.stateCode}',
                  actionLabel: context.l10n.exploreOpenCityAction,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.cityDetail(city.id)),
                ),
              ),
          ],
        );
      },
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
              child: _ContentCard(
                title: context.l10n.documentationPathDocumentsTitle,
                body: context.l10n.exploreContentDocumentsBody,
                actionLabel: context.l10n.exploreOpenContentAction,
                icon: Icons.badge_outlined,
                onTap: () => onOpenSection(DocumentationGuideSection.documents),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ContentCard(
                title: context.l10n.documentationHousingArrivalSectionTitle,
                body: context.l10n.exploreContentHousingBody,
                actionLabel: context.l10n.exploreOpenContentAction,
                icon: Icons.home_work_outlined,
                onTap: () => onOpenSection(DocumentationGuideSection.housing),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ContentCard(
                title: context.l10n.documentationPathWorkTitle,
                body: context.l10n.exploreContentWorkBody,
                actionLabel: context.l10n.exploreOpenContentAction,
                icon: Icons.work_outline_rounded,
                onTap: () => onOpenSection(DocumentationGuideSection.work),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompactCityCard extends StatelessWidget {
  const _CompactCityCard({
    required this.city,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
  });

  final City city;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label:
                    '${context.l10n.cityDetailAffordabilityTitle}: ${city.rentScore}',
              ),
              _MetricChip(
                label:
                    '${context.l10n.cityDetailSafetyLabel}: ${city.safetyScore}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String body;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSoftFor(context),
        ),
      ),
    );
  }
}
