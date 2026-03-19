import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/recommendation_reason_list.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_structure_widgets.dart';

class MigrationPlanResultPage extends StatefulWidget {
  const MigrationPlanResultPage({required this.controller, super.key});

  final MigrationQuestionnaireController controller;

  @override
  State<MigrationPlanResultPage> createState() =>
      _MigrationPlanResultPageState();
}

class _MigrationPlanResultPageState extends State<MigrationPlanResultPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(widget.controller.initialize());
      _syncScrollHint();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncScrollHint)
      ..dispose();
    super.dispose();
  }

  void _syncScrollHint() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final shouldShow =
        position.maxScrollExtent > 48 &&
        position.pixels < position.maxScrollExtent - 36;

    if (shouldShow != _showScrollHint && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || shouldShow == _showScrollHint) {
          return;
        }
        setState(() {
          _showScrollHint = shouldShow;
        });
      });
    }
  }

  Future<void> _scrollDown() async {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final target = (position.pixels + 420).clamp(0, position.maxScrollExtent);
    await _scrollController.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final l10n = context.l10n;
        final plan = widget.controller.generatedPlan;

        if (widget.controller.isInitializing || plan == null) {
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

        final shortlist = plan.candidateCities.isNotEmpty
            ? plan.candidateCities.take(3).toList()
            : plan.recommendedCity == null
            ? const <City>[]
            : [plan.recommendedCity!];

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Stack(
                      children: [
                        ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            context.pageHorizontalPadding,
                            context.pageVerticalPadding,
                            context.pageHorizontalPadding,
                            context.pageVerticalPadding + 96,
                          ),
                          children: [
                            AppGlassHeader(
                              title: l10n.migrationPlanPageTitle,
                              onBack: () => Navigator.maybePop(context),
                            ),
                            const SizedBox(height: 20),
                            _ResultHero(plan: plan),
                            const SizedBox(height: 16),
                            _ResultSummary(plan: plan),
                            if (shortlist.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _ResultExpandableSection(
                                title: l10n.migrationPlanShortlistTitle,
                                subtitle: l10n.migrationPlanShortlistBody,
                                initiallyExpanded: !plan.isCityConfirmed,
                                child: _CityShortlist(plan: plan, cities: shortlist),
                              ),
                            ],
                            if (plan.recommendedCity != null) ...[
                              const SizedBox(height: 16),
                              _ResultExpandableSection(
                                title: l10n.migrationPlanResultCitySectionTitle,
                                subtitle: l10n.migrationPlanResultCitySectionBody,
                                child: _LeadCityShowcase(
                                  city: plan.recommendedCity!,
                                  plan: plan,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _ResultExpandableSection(
                              title: l10n.migrationPlanResultPlanSectionTitle,
                              subtitle: l10n.migrationPlanResultPlanSectionBody,
                              initiallyExpanded: plan.isCityConfirmed,
                              child: plan.isCityConfirmed
                                  ? _ConfirmedCityPanel(plan: plan)
                                  : _PreparationPrompt(plan: plan),
                            ),
                          ],
                        ),
                        if (_showScrollHint)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 8,
                            child: Center(
                              child: _ScrollHintButton(onTap: _scrollDown),
                            ),
                          ),
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
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.plan});

  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final city = plan.recommendedCity;
    final reasons = (plan.cityRecommendationReasons.isNotEmpty
            ? plan.cityRecommendationReasons
            : city?.recommendationReasons ?? const <String>[])
        .take(3)
        .toList(growable: false);
    final compatibility = _compatibilityLabel(context, plan.confidence);

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroMiddle, AppColors.heroEnd],
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
            city == null
                ? l10n.migrationPlanDecisionTitle(l10n.goalLabel(plan.goal))
                : city.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (city != null)
            Text(
              '${city.stateName} (${city.stateCode})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.84),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryChip(label: compatibility),
              if (plan.isCityConfirmed)
                _SummaryChip(label: l10n.migrationPlanSelectedCityBadge),
            ],
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (final reason in reasons) ...[
              _ResultReasonRow(
                label: l10n.recommendationReasonLabel(reason),
              ),
              if (reason != reasons.last) const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 18),
          PlanNextActionCard(
            eyebrow: l10n.migrationPlanResultPrimaryCtaEyebrow,
            title: plan.isCityConfirmed
                ? l10n.migrationPlanResultOpenPlanTitle
                : l10n.migrationPlanResultStartPlanTitle,
            body: city == null
                ? l10n.migrationPlanDecisionSummaryBody
                : plan.isCityConfirmed
                ? l10n.migrationPlanPreparationBody(city.name)
                : l10n.migrationPlanResultStartPlanBody(city.name),
            actionLabel: plan.isCityConfirmed
                ? l10n.migrationPlanResultOpenPlanAction
                : l10n.migrationPlanResultStartPlanAction,
            onTap: () => plan.isCityConfirmed
                ? Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot)
                : Navigator.pushNamed(
                    context,
                    AppRoutes.cityDetail(city!.id),
                    arguments: const {'selectForPlan': true},
                  ),
            icon: plan.isCityConfirmed
                ? Icons.checklist_rounded
                : Icons.open_in_new_rounded,
          ),
        ],
      ),
    );
  }

  String _compatibilityLabel(BuildContext context, double confidence) {
    final l10n = context.l10n;
    if (confidence >= 0.72) {
      return l10n.migrationPlanResultCompatibilityHigh;
    }
    if (confidence >= 0.52) {
      return l10n.migrationPlanResultCompatibilityMedium;
    }
    return l10n.migrationPlanResultCompatibilityInitial;
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.plan});

  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final city = plan.recommendedCity;
    final totalDays = plan.steps.fold<int>(
      0,
      (sum, step) => sum + step.estimatedDays,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;
        final medium = constraints.maxWidth >= 640;
        final cardWidth = wide
            ? (constraints.maxWidth - 24) / 3
            : medium
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: PlanSummaryCard(
                label: context.l10n.migrationPlanResultCostLabel,
                value: _costLabel(context, city),
                supporting: context.l10n.migrationPlanResultCostSupporting,
                icon: Icons.payments_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: PlanSummaryCard(
                label: context.l10n.migrationPlanResultDifficultyLabel,
                value: _difficultyLabel(context),
                supporting:
                    context.l10n.migrationPlanResultDifficultySupporting,
                icon: Icons.route_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: PlanSummaryCard(
                label: context.l10n.migrationPlanResultTimelineLabel,
                value: context.l10n.migrationPlanResultTimelineValue(totalDays),
                supporting: context.l10n.timelineLabel(plan.timeline),
                icon: Icons.schedule_rounded,
              ),
            ),
          ],
        );
      },
    );
  }

  String _costLabel(BuildContext context, City? city) {
    final l10n = context.l10n;
    if (city == null) {
      return l10n.migrationPlanResultCostMedium;
    }

    final combined = (city.costOfLivingScore + city.rentScore) / 2;
    if (combined <= 45) {
      return l10n.migrationPlanResultCostLower;
    }
    if (combined <= 68) {
      return l10n.migrationPlanResultCostMedium;
    }
    return l10n.migrationPlanResultCostHigher;
  }

  String _difficultyLabel(BuildContext context) {
    final l10n = context.l10n;
    final totalDays = plan.steps.fold<int>(
      0,
      (sum, step) => sum + step.estimatedDays,
    );
    if (totalDays <= 45) {
      return l10n.migrationPlanResultDifficultyFocused;
    }
    if (totalDays <= 75) {
      return l10n.migrationPlanResultDifficultyModerate;
    }
    return l10n.migrationPlanResultDifficultyStructured;
  }
}

class _ResultExpandableSection extends StatelessWidget {
  const _ResultExpandableSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _ResultReasonRow extends StatelessWidget {
  const _ResultReasonRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadCityShowcase extends StatelessWidget {
  const _LeadCityShowcase({required this.city, required this.plan});

  final City city;
  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final compact = MediaQuery.sizeOf(context).width < 760;

    return FrostedPanel(
      padding: EdgeInsets.zero,
      child: CityImageBackdrop(
        city: city,
        borderRadius: BorderRadius.circular(32),
        overlayOpacity: 0.78,
        padding: const EdgeInsets.all(22),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LeadCityContent(city: city, plan: plan, housing: housing),
                  const SizedBox(height: 16),
                  _MiniCityMap(city: city),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _LeadCityContent(
                      city: city,
                      plan: plan,
                      housing: housing,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _MiniCityMap(city: city)),
                ],
              ),
      ),
    );
  }
}

class _LeadCityContent extends StatelessWidget {
  const _LeadCityContent({
    required this.city,
    required this.plan,
    required this.housing,
  });

  final City city;
  final MigrationPlan plan;
  final CityHousingViabilityPresentation housing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSelected = plan.isCityConfirmed;
    final textSoft = Colors.white.withValues(alpha: 0.8);
    final visibleReasons = plan.cityRecommendationReasons.isNotEmpty
        ? plan.cityRecommendationReasons
        : city.recommendationReasons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                isSelected
                    ? l10n.migrationPlanConfirmedCityTitle(city.name)
                    : l10n.migrationPlanSuggestedCityTitle(city.name),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : AppColors.accent)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
                child: Text(
                isSelected
                    ? l10n.migrationPlanSelectedCityBadge
                    : l10n.migrationPlanSuggestedCityBadge,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${city.stateName} (${city.stateCode})',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textSoft,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(
              icon: _lifestyleIcon(city),
              label: _lifestyleLabel(context, city),
              textColor: Colors.white,
              iconColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
            _MetaPill(
              icon: Icons.home_work_outlined,
              label: housing.badge,
              tint: housing.tint,
              textColor: Colors.white,
              iconColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
          ],
        ),
        const SizedBox(height: 14),
        RecommendationReasonList(
          reasons: visibleReasons,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => isSelected
              ? Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot)
              : Navigator.pushNamed(
                  context,
                  AppRoutes.cityDetail(city.id),
                  arguments: const {'selectForPlan': true},
                ),
          icon: Icon(
            isSelected ? Icons.checklist_rounded : Icons.open_in_new_rounded,
          ),
          label: Text(
            isSelected
                ? l10n.migrationPlanCopilotAction
                : l10n.migrationPlanInspectCityAction,
          ),
        ),
      ],
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

class _CityShortlist extends StatelessWidget {
  const _CityShortlist({required this.plan, required this.cities});

  final MigrationPlan plan;
  final List<City> cities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanShortlistTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.migrationPlanShortlistBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < cities.length; index++) ...[
            _CityOptionCard(
              city: cities[index],
              isLeading: plan.recommendedCity?.id == cities[index].id,
              isSelected:
                  plan.isCityConfirmed &&
                  plan.recommendedCity?.id == cities[index].id,
            ),
            if (index != cities.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _CityOptionCard extends StatelessWidget {
  const _CityOptionCard({
    required this.city,
    required this.isLeading,
    required this.isSelected,
  });

  final City city;
  final bool isLeading;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primary).withValues(
                alpha: isDark ? 0.16 : 0.05,
              ),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CityImageBackdrop(
          city: city,
          borderRadius: BorderRadius.circular(24),
          overlayOpacity: isDark ? 0.8 : 0.72,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${city.stateName} (${city.stateCode})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLeading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.14)
                          : const Color(0xCCFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : AppColors.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Text(
                      isSelected
                          ? l10n.migrationPlanSelectedCityBadge
                          : l10n.migrationPlanSuggestedCityBadge,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
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
                  icon: Icons.home_work_outlined,
                  label: housing.badge,
                  tint: housing.tint,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xCCFFFFFF),
                ),
                _MetaPill(
                  icon: Icons.trending_up_rounded,
                  label: context.l10n.recommendationReasonLabel(
                    city.recommendationReasons.isEmpty
                        ? 'plan_reason_balanced_profile'
                        : city.recommendationReasons.first,
                  ),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xCCFFFFFF),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => isSelected
                    ? Navigator.pushNamed(
                        context,
                        AppRoutes.migrationPlanCopilot,
                      )
                    : Navigator.pushNamed(
                        context,
                        AppRoutes.cityDetail(city.id),
                        arguments: const {'selectForPlan': true},
                      ),
                icon: Icon(
                  isSelected
                      ? Icons.checklist_rounded
                      : Icons.open_in_new_rounded,
                ),
                label: Text(
                  isSelected
                      ? l10n.migrationPlanSelectedCityAction
                      : l10n.migrationPlanInspectCityAction,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreparationPrompt extends StatelessWidget {
  const _PreparationPrompt({required this.plan});

  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final city = plan.recommendedCity;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanDecisionSummaryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            city == null
                ? l10n.migrationPlanDecisionSummaryBody
                : l10n.migrationPlanPreparationBody(city.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
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
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot),
            icon: const Icon(Icons.checklist_rounded),
            label: Text(l10n.migrationPlanCopilotAction),
          ),
        ],
      ),
    );
  }
}

class _MiniCityMap extends StatelessWidget {
  const _MiniCityMap({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(city.latitude, city.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 9.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.movaro.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 42,
                      height: 42,
                      child: const _MiniMapMarker(),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC0D1625),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${city.name}, ${city.stateCode}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollHintButton extends StatelessWidget {
  const _ScrollHintButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.isDark(context)
                ? const Color(0xE5121C2A)
                : const Color(0xF8FFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.migrationPlanScrollHint,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMapMarker extends StatelessWidget {
  const _MiniMapMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x330071E3), blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(
          color: isDark ? Colors.white : const Color(0xFF183A70),
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
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? tint;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final resolvedTint = tint ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            AppColors.tintedSurfaceFor(
              context,
              tint: resolvedTint,
              lightColor: const Color(0xFFF4F7FB),
            ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? resolvedTint),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: textColor ?? AppColors.textPrimaryFor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
