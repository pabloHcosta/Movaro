import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/recommendation_reason_list.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class MigrationPlanResultPage extends StatelessWidget {
  const MigrationPlanResultPage({
    required this.controller,
    super.key,
  });

  final MigrationQuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final l10n = context.l10n;
        final plan = controller.generatedPlan;

        if (plan == null) {
          return Scaffold(
            body: Stack(
              children: [
                const AmbientBackground(),
                PageSkeleton(
                  label: l10n.migrationPlanPageTitle,
                  maxWidth: 1040,
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: const [DetailSkeleton()],
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 20,
                      ),
                      children: [
                        AppGlassHeader(
                          title: l10n.migrationPlanPageTitle,
                          onBack: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(height: 20),
                        _DecisionHero(
                          plan: plan,
                          onOpenCities: () =>
                              _openCandidateCitiesSheet(context, plan),
                        ),
                        const SizedBox(height: 16),
                        _DecisionExplanation(plan: plan),
                        if (plan.recommendedCity != null) ...[
                          const SizedBox(height: 16),
                          if (plan.isCityConfirmed)
                            _ConfirmedCityPanel(plan: plan)
                          else
                            _SuggestedCityPanel(
                              plan: plan,
                              onOpenCities: () =>
                                  _openCandidateCitiesSheet(context, plan),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCandidateCitiesSheet(
    BuildContext context,
    MigrationPlan plan,
  ) {
    final cities = plan.candidateCities.isNotEmpty
        ? plan.candidateCities
        : plan.recommendedCity == null
        ? const <City>[]
        : [plan.recommendedCity!];

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = context.l10n;
        final media = MediaQuery.of(context);

        return SafeArea(
          top: false,
          child: Container(
            height: media.size.height * 0.82,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FrostedPanel(
              borderRadius: BorderRadius.circular(32),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.migrationPlanCandidateCitiesTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.migrationPlanCandidateCitiesSheetBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cities.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return _CandidateCityCard(
                          city: city,
                          isSuggested: plan.recommendedCity?.id == city.id,
                        );
                      },
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

class _DecisionHero extends StatelessWidget {
  const _DecisionHero({
    required this.plan,
    required this.onOpenCities,
  });

  final MigrationPlan plan;
  final VoidCallback onOpenCities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      gradient: const LinearGradient(
        colors: [
          AppColors.heroStart,
          AppColors.heroMiddle,
          AppColors.heroEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xB30B1320),
      borderColor: const Color(0x1AFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.migrationPlanDecisionLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.migrationPlanDecisionTitle(l10n.goalLabel(plan.goal)),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.migrationPlanDecisionBody(l10n.timelineLabel(plan.timeline)),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryChip(label: l10n.countryLabel(plan.originCountry)),
              _SummaryChip(label: l10n.countryLabel(plan.destinationCountry)),
              _SummaryChip(label: l10n.goalLabel(plan.goal)),
              _SummaryChip(label: l10n.timelineLabel(plan.timeline)),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpenCities,
            icon: const Icon(Icons.location_city_rounded),
            label: Text(l10n.migrationPlanOpenCitiesAction),
          ),
        ],
      ),
    );
  }
}

class _DecisionExplanation extends StatelessWidget {
  const _DecisionExplanation({required this.plan});

  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanDecisionSummaryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _SummaryLine(
            label: l10n.planSummaryGoal(l10n.goalLabel(plan.goal)),
          ),
          _SummaryLine(
            label: l10n.planSummaryTimeline(l10n.timelineLabel(plan.timeline)),
          ),
          _SummaryLine(label: l10n.migrationPlanDecisionSummaryBody),
        ],
      ),
    );
  }
}

class _SuggestedCityPanel extends StatelessWidget {
  const _SuggestedCityPanel({
    required this.plan,
    required this.onOpenCities,
  });

  final MigrationPlan plan;
  final VoidCallback onOpenCities;

  @override
  Widget build(BuildContext context) {
    final city = plan.recommendedCity!;
    final l10n = context.l10n;
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanSuggestedCityTitle(city.name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.migrationPlanSuggestedCityBody(
              city.name,
              housing.headline,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          RecommendationReasonList(
            reasons: plan.cityRecommendationReasons,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cityDetail(city.id),
                  arguments: const {'selectForPlan': true},
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.migrationPlanInspectCityAction),
              ),
              OutlinedButton.icon(
                onPressed: onOpenCities,
                icon: const Icon(Icons.unfold_more_rounded),
                label: Text(l10n.migrationPlanCompareOtherCitiesAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmedCityPanel extends StatelessWidget {
  const _ConfirmedCityPanel({required this.plan});

  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final city = plan.recommendedCity!;
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.migrationPlanConfirmedCityTitle(city.name),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.migrationPlanSelectedCityBadge,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.migrationPlanPreparationBody(city.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.migrationPlanCopilot,
                ),
                icon: const Icon(Icons.checklist_rounded),
                label: Text(l10n.migrationPlanCopilotAction),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cityDetail(city.id),
                  arguments: const {'selectForPlan': true},
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.planRecommendedCityAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CandidateCityCard extends StatelessWidget {
  const _CandidateCityCard({
    required this.city,
    required this.isSuggested,
  });

  final City city;
  final bool isSuggested;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${city.stateName} (${city.stateCode})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSuggested)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tintedSurfaceFor(
                      context,
                      tint: AppColors.primary,
                      lightColor: const Color(0xFFEFF5FF),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.migrationPlanSuggestedCityBadge,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(
                icon: _lifestyleIcon(city),
                label: _lifestyleLabel(context, city),
              ),
              _MetaPill(
                icon: Icons.home_work_outlined,
                label: housing.badge,
                tint: housing.tint,
              ),
            ],
          ),
          const SizedBox(height: 14),
          RecommendationReasonList(
            reasons: city.recommendationReasons.take(2).toList(),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.cityDetail(city.id),
                arguments: const {'selectForPlan': true},
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.migrationPlanInspectCityAction),
          ),
        ],
      ),
    );
  }

  String _lifestyleLabel(BuildContext context, City city) {
    final l10n = context.l10n;
    return switch (CityCoastalProfile.lifestyleKind(city)) {
      CityLifestyleKind.coastal => l10n.cityLifestyleCoastalLabel,
      CityLifestyleKind.metropolis => l10n.cityLifestyleMetropolisLabel,
      CityLifestyleKind.border => l10n.cityLifestyleBorderLabel,
      CityLifestyleKind.inland => l10n.cityLifestyleInlandLabel,
    };
  }

  IconData _lifestyleIcon(City city) {
    return switch (CityCoastalProfile.lifestyleKind(city)) {
      CityLifestyleKind.coastal => Icons.waves_rounded,
      CityLifestyleKind.metropolis => Icons.location_city_rounded,
      CityLifestyleKind.border => Icons.compare_arrows_rounded,
      CityLifestyleKind.inland => Icons.terrain_rounded,
    };
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSoftFor(context),
          height: 1.45,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.tint,
  });

  final IconData icon;
  final String label;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final resolvedTint = tint ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: resolvedTint,
          lightColor: const Color(0xFFF4F7FB),
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: resolvedTint),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: resolvedTint,
            ),
          ),
        ],
      ),
    );
  }
}
