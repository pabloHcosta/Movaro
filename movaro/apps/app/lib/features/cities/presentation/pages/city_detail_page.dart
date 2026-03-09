import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/language_selector_button.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/utils/number_formatters.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/empty_state_widget.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_map_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_score_badge.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_snapshot_tile.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_sources_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/methodology_info_banner.dart';
import 'package:movaro_app/features/cities/presentation/widgets/recommendation_reason_list.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class CityDetailPage extends StatefulWidget {
  const CityDetailPage({
    required this.cityId,
    required this.citiesController,
    this.migrationQuestionnaireController,
    this.selectForPlan = false,
    super.key,
  });

  final String cityId;
  final CitiesController citiesController;
  final MigrationQuestionnaireController? migrationQuestionnaireController;
  final bool selectForPlan;

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  City? _city;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _load();
    });
  }

  Future<void> _load() async {
    final cityFuture = widget.citiesController.loadCityById(widget.cityId);
    final methodologyFuture = widget.citiesController.loadMethodology();
    final city = await cityFuture;

    if (!mounted) {
      return;
    }

    setState(() {
      _city = city;
    });

    await methodologyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final city = _city;
        final methodology = widget.citiesController.methodology;
        final l10n = context.l10n;
        final localeName = Localizations.localeOf(context).toString();

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    if (city == null && widget.citiesController.isLoadingCity)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1160),
                        child: DetailSkeleton(),
                      )
                    else if (city == null &&
                        widget.citiesController.cityError != null)
                      Builder(
                        builder: (context) {
                          final error = ErrorHandler.resolve(
                            context,
                            widget.citiesController.cityError!,
                          );

                          return ErrorStateWidget(
                            title: error.title,
                            description: error.description,
                            illustrationAsset: error.illustrationAsset,
                            onRetry: error.isRetryable ? _load : null,
                            onBack: () => Navigator.pop(context),
                          );
                        },
                      )
                    else if (city == null)
                      EmptyStateWidget(
                        title: l10n.cityDetailEmptyTitle,
                        description: l10n.cityDetailEmptyDescription,
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: _goBackToCities,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(l10n.citiesExploreTitle),
                          ),
                          const LanguageSelectorButton(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: FrostedPanel(
                          padding: const EdgeInsets.all(32),
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
                          borderColor: Color(0x1AFFFFFF),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city.name,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${city.stateName} (${city.stateCode})',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 10),
                              _LifestyleBadge(city: city),
                              const SizedBox(height: 10),
                              Text(
                                l10n.cityDetailContextNote,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 20),
                              _IdhmHighlight(city: city),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount =
                                      constraints.maxWidth >= 920 ? 4 : 2;

                                  return GridView.count(
                                    crossAxisCount: crossAxisCount,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: crossAxisCount == 4
                                        ? 1.52
                                        : 1.12,
                                    children: [
                                      CityScoreBadge(
                                        label: l10n.cityDetailCostLabel,
                                        value: city.movaroScores.economical,
                                        kind: CityMetricKind.cost,
                                        compact: true,
                                      ),
                                      CityScoreBadge(
                                        label: l10n.cityDetailSafetyLabel,
                                        value: city.safetyScore,
                                        kind: CityMetricKind.safety,
                                        compact: true,
                                      ),
                                      CityScoreBadge(
                                        label: l10n.cityDetailLanguageLabel,
                                        value: city
                                            .movaroScores
                                            .languageAdaptation,
                                        kind: CityMetricKind.language,
                                        compact: true,
                                      ),
                                      CityScoreBadge(
                                        label: l10n.cityDetailWorkLabel,
                                        value:
                                            city.movaroScores.workOpportunity,
                                        kind: CityMetricKind.work,
                                        compact: true,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: CityMapCard(city: city),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: SectionLoadingOverlay(
                          isLoading: methodology == null,
                          label: l10n.cityDetailLoadingLabel,
                          child: MethodologyInfoBanner(
                            message:
                                methodology?.note ?? l10n.citiesMethodologyNote,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: _PracticalAnswersPanel(city: city),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 980;
                            final detailWidth = wide
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: detailWidth,
                                  child: _SnapshotPanel(
                                    city: city,
                                    localeName: localeName,
                                  ),
                                ),
                                SizedBox(
                                  width: detailWidth,
                                  child: _DetailBlock(
                                    title: l10n.cityDetailReasonsTitle,
                                    children: [
                                      RecommendationReasonList(
                                        reasons: city.recommendationReasons,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: detailWidth,
                                  child: _DetailBlock(
                                    title: l10n.cityDetailIndustriesTitle,
                                    children: [
                                      Text(
                                        city.topIndustries
                                            .map(l10n.industryLabel)
                                            .join(', '),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: CitySourcesSection(sources: city.sources),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: FrostedPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.selectForPlan) ...[
                                FilledButton.icon(
                                  onPressed: () async {
                                    await widget
                                        .migrationQuestionnaireController
                                        ?.confirmPlanCity(city);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    Navigator.maybePop(context);
                                  },
                                  icon: const Icon(Icons.check_circle_rounded),
                                  label: Text(
                                    l10n.migrationPlanChooseCityAction,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              FilledButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.citiesSearch,
                                ),
                                icon: const Icon(Icons.search_rounded),
                                label: Text(l10n.cityDetailCompareAction),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.migrationQuestionnaire,
                                ),
                                icon: const Icon(Icons.route_outlined),
                                label: Text(l10n.cityDetailPlanAction),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.cityDetailFooterNote,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goBackToCities() {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushNamed(context, AppRoutes.cities);
  }
}

class _LifestyleBadge extends StatelessWidget {
  const _LifestyleBadge({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final kind = CityCoastalProfile.lifestyleKind(city);
    final (icon, label) = switch (kind) {
      CityLifestyleKind.coastal => (
        Icons.waves_rounded,
        context.l10n.cityLifestyleCoastalLabel,
      ),
      CityLifestyleKind.metropolis => (
        Icons.location_city_rounded,
        context.l10n.cityLifestyleMetropolisLabel,
      ),
      CityLifestyleKind.border => (
        Icons.compare_arrows_rounded,
        context.l10n.cityLifestyleBorderLabel,
      ),
      CityLifestyleKind.inland => (
        Icons.terrain_rounded,
        context.l10n.cityLifestyleInlandLabel,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PracticalAnswersPanel extends StatelessWidget {
  const _PracticalAnswersPanel({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cityPracticalAnswersTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _PracticalAnswerRow(
            icon: Icons.translate_rounded,
            question: l10n.cityPracticalLanguageQuestion,
            answer: _languageAnswer(context, city),
          ),
          const SizedBox(height: 12),
          _PracticalAnswerRow(
            icon: Icons.payments_outlined,
            question: l10n.cityPracticalCostQuestion,
            answer: _costAnswer(context, city),
          ),
          const SizedBox(height: 12),
          _PracticalAnswerRow(
            icon: Icons.work_outline_rounded,
            question: l10n.cityPracticalWorkQuestion,
            answer: _workAnswer(context, city),
          ),
          const SizedBox(height: 12),
          _PracticalAnswerRow(
            icon: Icons.shield_outlined,
            question: l10n.cityPracticalSafetyQuestion,
            answer: _safetyAnswer(context, city),
          ),
        ],
      ),
    );
  }

  String _languageAnswer(BuildContext context, City city) {
    final l10n = context.l10n;
    final score = city.movaroScores.languageAdaptation;
    if (score >= 82) {
      return l10n.cityPracticalLanguageEasy;
    }
    if (score >= 65) {
      return l10n.cityPracticalLanguageMedium;
    }
    return l10n.cityPracticalLanguageHard;
  }

  String _costAnswer(BuildContext context, City city) {
    final l10n = context.l10n;
    final score = city.movaroScores.economical;
    if (score >= 72) {
      return l10n.cityPracticalCostEasy;
    }
    if (score >= 55) {
      return l10n.cityPracticalCostMedium;
    }
    return l10n.cityPracticalCostHard;
  }

  String _workAnswer(BuildContext context, City city) {
    final l10n = context.l10n;
    final score = city.movaroScores.workOpportunity;
    if (score >= 78) {
      return l10n.cityPracticalWorkStrong;
    }
    if (score >= 62) {
      return l10n.cityPracticalWorkMedium;
    }
    return l10n.cityPracticalWorkLow;
  }

  String _safetyAnswer(BuildContext context, City city) {
    final l10n = context.l10n;
    final score = city.safetyScore;
    if (score >= 70) {
      return l10n.cityPracticalSafetyGood;
    }
    if (score >= 55) {
      return l10n.cityPracticalSafetyMedium;
    }
    return l10n.cityPracticalSafetyLow;
  }
}

class _IdhmHighlight extends StatelessWidget {
  const _IdhmHighlight({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final presentation = CityIdhmPresentation.resolve(
      context,
      value: city.idhmScore,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: presentation.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: presentation.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: presentation.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.public_rounded,
              color: presentation.tint,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  presentation.headline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  presentation.supporting,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.35,
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

class _PracticalAnswerRow extends StatelessWidget {
  const _PracticalAnswerRow({
    required this.icon,
    required this.question,
    required this.answer,
  });

  final IconData icon;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textPrimaryFor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                answer,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SnapshotPanel extends StatelessWidget {
  const _SnapshotPanel({required this.city, required this.localeName});

  final City city;
  final String localeName;

  @override
  Widget build(BuildContext context) {
    final idhm = CityIdhmPresentation.resolve(context, value: city.idhmScore);
    final cost = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.cost,
      value: city.movaroScores.economical,
    );
    final safety = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.safety,
      value: city.safetyScore,
    );
    final language = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.language,
      value: city.movaroScores.languageAdaptation,
    );
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final work = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: city.movaroScores.workOpportunity,
    );

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.cityDetailSnapshotTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 680;
              return GridView.count(
                crossAxisCount: wide ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: wide ? 1.08 : 0.92,
                children: [
                  CitySnapshotTile(
                    label: context.l10n.cityDetailPopulationLabel,
                    value: NumberFormatters.compactPopulation(
                      value: city.population,
                      locale: localeName,
                    ),
                    supporting: NumberFormatters.fullInteger(
                      value: city.population,
                      locale: localeName,
                    ),
                    tint: AppColors.primary,
                    background: AppColors.surfaceMutedFor(context),
                    icon: Icons.groups_rounded,
                  ),
                  CitySnapshotTile(
                    label:
                        '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear}',
                    value: idhm.headline,
                    supporting: context.l10n.cityDetailIdhmOfficialNote,
                    tint: idhm.tint,
                    background: idhm.background,
                    icon: Icons.public_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailCostLabel,
                    value: cost.headline,
                    supporting: cost.supporting,
                    tint: cost.tint,
                    background: cost.background,
                    icon: Icons.payments_outlined,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailRentLabel,
                    value: _rentHeadline(context, city.rentScore),
                    supporting: _rentSupporting(context, city.rentScore),
                    tint: _rentTint(city.rentScore),
                    background: _rentBackground(context, city.rentScore),
                    icon: Icons.house_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityHousingViabilityTileLabel,
                    value: housing.headline,
                    supporting: housing.supporting,
                    tint: housing.tint,
                    background: housing.background,
                    icon: Icons.home_work_outlined,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailSafetyLabel,
                    value: safety.headline,
                    supporting: safety.supporting,
                    tint: safety.tint,
                    background: safety.background,
                    icon: Icons.shield_outlined,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailPopularityLabel,
                    value: _popularityHeadline(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    supporting: _popularitySupporting(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    tint: _popularityTint(city.argentinaPopularityScore),
                    background: _popularityBackground(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    icon: Icons.favorite_border_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailLanguageLabel,
                    value: language.headline,
                    supporting: language.supporting,
                    tint: language.tint,
                    background: language.background,
                    icon: Icons.translate_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailWorkLabel,
                    value: work.headline,
                    supporting: work.supporting,
                    tint: work.tint,
                    background: work.background,
                    icon: Icons.work_outline_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailUnemploymentLabel,
                    value: _unemploymentHeadline(context, city.unemploymentRate),
                    supporting: '${city.unemploymentRate.toStringAsFixed(1)}%',
                    tint: _unemploymentTint(city.unemploymentRate),
                    background: _unemploymentBackground(
                      context,
                      city.unemploymentRate,
                    ),
                    icon: Icons.query_stats_rounded,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _rentHeadline(BuildContext context, int score) {
    if (score >= 72) {
      return context.l10n.citySnapshotRentLower;
    }
    if (score >= 55) {
      return context.l10n.citySnapshotRentModerate;
    }
    return context.l10n.citySnapshotRentHigher;
  }

  String _rentSupporting(BuildContext context, int score) {
    if (score >= 72) {
      return context.l10n.citySnapshotRentLowerSupporting;
    }
    if (score >= 55) {
      return context.l10n.citySnapshotRentModerateSupporting;
    }
    return context.l10n.citySnapshotRentHigherSupporting;
  }

  Color _rentTint(int score) {
    if (score >= 72) {
      return AppColors.success;
    }
    if (score >= 55) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }

  Color _rentBackground(BuildContext context, int score) {
    if (score >= 72) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFF1F8F3),
      );
    }
    if (score >= 55) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      );
    }
    return AppColors.tintedSurfaceFor(
      context,
      tint: AppColors.danger,
      lightColor: const Color(0xFFFDEEE8),
    );
  }

  String _popularityHeadline(BuildContext context, int score) {
    if (score >= 80) {
      return context.l10n.citySnapshotPopularityHigh;
    }
    if (score >= 60) {
      return context.l10n.citySnapshotPopularityMedium;
    }
    return context.l10n.citySnapshotPopularityLow;
  }

  String _popularitySupporting(BuildContext context, int score) {
    if (score >= 80) {
      return context.l10n.citySnapshotPopularityHighSupporting;
    }
    if (score >= 60) {
      return context.l10n.citySnapshotPopularityMediumSupporting;
    }
    return context.l10n.citySnapshotPopularityLowSupporting;
  }

  Color _popularityTint(int score) {
    if (score >= 80) {
      return AppColors.success;
    }
    if (score >= 60) {
      return AppColors.warning;
    }
    return AppColors.caution;
  }

  Color _popularityBackground(BuildContext context, int score) {
    if (score >= 80) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFF1F8F3),
      );
    }
    if (score >= 60) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      );
    }
    return AppColors.tintedSurfaceFor(
      context,
      tint: AppColors.caution,
      lightColor: const Color(0xFFFFF1E8),
    );
  }

  String _unemploymentHeadline(BuildContext context, double value) {
    if (value <= 5.5) {
      return context.l10n.citySnapshotUnemploymentLower;
    }
    if (value <= 7.0) {
      return context.l10n.citySnapshotUnemploymentModerate;
    }
    return context.l10n.citySnapshotUnemploymentHigher;
  }

  Color _unemploymentTint(double value) {
    if (value <= 5.5) {
      return AppColors.success;
    }
    if (value <= 7.0) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }

  Color _unemploymentBackground(BuildContext context, double value) {
    if (value <= 5.5) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFF1F8F3),
      );
    }
    if (value <= 7.0) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      );
    }
    return AppColors.tintedSurfaceFor(
      context,
      tint: AppColors.danger,
      lightColor: const Color(0xFFFDEEE8),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
