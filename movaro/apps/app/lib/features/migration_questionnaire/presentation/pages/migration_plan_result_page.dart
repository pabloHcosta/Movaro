import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_public_opinion.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';

class MigrationPlanResultPage extends StatefulWidget {
  const MigrationPlanResultPage({
    required this.controller,
    required this.citiesController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CitiesController citiesController;

  @override
  State<MigrationPlanResultPage> createState() =>
      _MigrationPlanResultPageState();
}

class _MigrationPlanResultPageState extends State<MigrationPlanResultPage> {
  bool _isStartingPlan = false;
  String? _weatherRequestedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initialize());
    });
  }

  Future<void> _initialize() async {
    await widget.controller.initialize();
    if (!mounted) {
      return;
    }
    _prefetchWeather();
  }

  void _prefetchWeather() {
    final cityId = widget.controller.generatedPlan?.recommendedCity?.id;
    if (cityId == null || cityId == _weatherRequestedFor) {
      return;
    }

    _weatherRequestedFor = cityId;
    unawaited(widget.citiesController.loadWeatherForCity(cityId));
  }

  Future<void> _toggleFavoriteCity(City city) async {
    final result = await widget.citiesController.toggleFavorite(city.id);
    if (!mounted) {
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

  Future<void> _startPlan(City city) async {
    if (_isStartingPlan) {
      return;
    }

    setState(() {
      _isStartingPlan = true;
    });

    try {
      if (!widget.controller.generatedPlan!.isCityConfirmed) {
        await widget.controller.confirmPlanCity(city);
      }
      if (!mounted) {
        return;
      }
      await Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot);
    } finally {
      if (mounted) {
        setState(() {
          _isStartingPlan = false;
        });
      }
    }
  }

  Future<void> _showCompatibilityHelp() {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FrostedPanel(
              padding: const EdgeInsets.all(24),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.migrationPlanResultCompatibilityHelpTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.migrationPlanResultCompatibilityHelpBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.commonGotItAction),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, widget.citiesController]),
      builder: (context, _) {
        final l10n = context.l10n;
        final plan = widget.controller.generatedPlan;
        final city = plan?.recommendedCity;

        if (widget.controller.isInitializing) {
          return Scaffold(
            body: Stack(
              children: [
                const AmbientBackground(),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        children: const [_PlanResultSkeleton()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (plan == null || city == null) {
          return Scaffold(
            body: Stack(
              children: [
                const AmbientBackground(),
                SafeArea(
                  child: ErrorStateWidget(
                    title: l10n.migrationPlanResultUnavailableTitle,
                    description: l10n.migrationPlanResultUnavailableBody,
                    illustrationAsset: 'assets/illustrations/error.svg',
                    onRetry: _initialize,
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
              ],
            ),
          );
        }

        _prefetchWeather();
        final weather = widget.citiesController.weatherFor(city.id);
        final alternativeCities = plan.candidateCities
            .where((candidate) => candidate.id != city.id)
            .toList(growable: false);

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 40),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: AppGlassHeader(
                            title: l10n.migrationPlanPageTitle,
                            onBack: () => Navigator.maybePop(context),
                            onHelp: _showCompatibilityHelp,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _PlanHero(
                          city: city,
                          weather: weather,
                          compatibilityLabel: _compatibilityLabel(
                            context,
                            plan.confidence,
                          ),
                          isFavorite: widget.citiesController.isFavorite(
                            city.id,
                          ),
                          onFavoriteTap: () => _toggleFavoriteCity(city),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle(
                                title:
                                    l10n.migrationPlanResultBasedOnAnswersTitle,
                              ),
                              const SizedBox(height: 12),
                              _ReasonsPanel(
                                plan: plan,
                                city: city,
                                weather: weather,
                              ),
                              const SizedBox(height: 20),
                              _SectionTitle(
                                title: l10n.migrationPlanResultCityDataTitle,
                              ),
                              const SizedBox(height: 12),
                              _MetricsGrid(city: city, weather: weather),
                              const SizedBox(height: 20),
                              _ActionStack(
                                city: city,
                                isLoading: _isStartingPlan,
                                onStartPlan: () => _startPlan(city),
                                onExploreCity: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.cityDetail(city.id),
                                ),
                              ),
                              if (alternativeCities.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _SectionTitle(
                                  title:
                                      l10n.migrationPlanResultOtherCitiesTitle,
                                ),
                                if (alternativeCities.length >= 2) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => CityComparisonScreen(
                                            initialCities: [
                                              city,
                                              ...alternativeCities,
                                            ],
                                            citiesController:
                                                widget.citiesController,
                                            migrationQuestionnaireController:
                                                widget.controller,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.compare_rounded),
                                    label: Text(
                                      l10n.migrationPlanCompareThreeCitiesAction,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                _AlternativeCitiesList(
                                  cities: alternativeCities,
                                  citiesController: widget.citiesController,
                                ),
                              ],
                            ],
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

class _PlanResultSkeleton extends StatelessWidget {
  const _PlanResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          height: 60,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: const SkeletonBox(height: 220),
        ),
        const SizedBox(height: 20),
        const CardSkeleton(showLeading: false, lineCount: 4),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var index = 0; index < 4; index++)
                  SizedBox(
                    width: width,
                    child: const CardSkeleton(showLeading: false, lineCount: 3),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const CardSkeleton(showLeading: false, lineCount: 2),
        const SizedBox(height: 12),
        const CardSkeleton(showLeading: false, lineCount: 2),
        const SizedBox(height: 16),
        const ListSkeleton(
          itemCount: 2,
          showLeading: false,
          showTrailing: true,
        ),
      ],
    );
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({
    required this.city,
    required this.weather,
    required this.compatibilityLabel,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final City city;
  final CityWeather? weather;
  final String compatibilityLabel;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attributes = _heroAttributes(context, city, weather);

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final bottomAttributes = attributes
              .where(
                (attribute) => attribute.kind != _HeroAttributeKind.weather,
              )
              .toList(growable: false);
          final visibleAttributes = compact
              ? bottomAttributes.take(2).toList(growable: false)
              : bottomAttributes;
          final weatherAttribute = attributes
              .where(
                (attribute) => attribute.kind == _HeroAttributeKind.weather,
              )
              .firstOrNull;

          return Stack(
            fit: StackFit.expand,
            children: [
              _HeroImage(city: city),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.heroStart.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, compact ? 14 : 16, 20, 18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: ScoreBadge(
                                label: compatibilityLabel,
                                icon: Icons.auto_awesome_rounded,
                                inverse: true,
                              ),
                            ),
                          ),
                          if (weatherAttribute != null) ...[
                            const SizedBox(width: 8),
                            _TopHeroChip(attribute: weatherAttribute),
                          ],
                          const SizedBox(width: 8),
                          _FavoriteButton(
                            isFavorite: isFavorite,
                            onTap: onFavoriteTap,
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
                            style:
                                (compact
                                        ? theme.textTheme.headlineSmall
                                        : theme.textTheme.headlineMedium)
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${city.stateName} (${city.stateCode})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.84),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: visibleAttributes
                                .map(
                                  (attribute) =>
                                      _AttributeChip(attribute: attribute),
                                )
                                .toList(growable: false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroImage extends StatefulWidget {
  const _HeroImage({required this.city});

  final City city;

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  int _sourceIndex = 0;

  List<String> get _imageSources {
    final urls = <String>[];
    final primary = cityImageUrlFor(widget.city.id);
    if (primary != null && primary.isNotEmpty) {
      urls.add(primary);
    }
    urls.add(
      'https://source.unsplash.com/featured/1400x900/?${Uri.encodeQueryComponent('${widget.city.name} Brazil')}',
    );
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _imageSources;
    if (_sourceIndex >= urls.length) {
      return _HeroImageFallback(city: widget.city);
    }

    return CachedNetworkImage(
      imageUrl: urls[_sourceIndex],
      fit: BoxFit.cover,
      httpHeaders: const {'User-Agent': 'Movaro/1.0'},
      placeholder: (_, _) => const _HeroImagePlaceholder(),
      errorWidget: (_, _, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _sourceIndex >= urls.length - 1) {
            return;
          }
          setState(() {
            _sourceIndex += 1;
          });
        });
        if (_sourceIndex < urls.length - 1) {
          return const _HeroImagePlaceholder();
        }
        return _HeroImageFallback(city: widget.city);
      },
    );
  }
}

class _HeroImagePlaceholder extends StatelessWidget {
  const _HeroImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.heroStart,
                AppColors.heroMiddle,
                AppColors.heroEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 180, height: 34),
              Spacer(),
              SkeletonBox(width: 220, height: 32),
              SizedBox(height: 10),
              SkeletonBox(width: 140, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.heroStart,
            AppColors.heroMiddle,
            AppColors.heroEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.location_city_outlined,
          size: 52,
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.heroStart.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.danger : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AttributeChip extends StatelessWidget {
  const _AttributeChip({required this.attribute});

  final _HeroAttribute attribute;

  @override
  Widget build(BuildContext context) {
    return ScoreBadge(
      label: attribute.label,
      icon: attribute.icon,
      tint: attribute.color,
      tone: attribute.tone,
      inverse: true,
    );
  }
}

class _TopHeroChip extends StatelessWidget {
  const _TopHeroChip({required this.attribute});

  final _HeroAttribute attribute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.heroStart.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(attribute.icon, size: 16, color: attribute.color),
          const SizedBox(width: 6),
          Text(
            attribute.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ReasonsPanel extends StatelessWidget {
  const _ReasonsPanel({
    required this.plan,
    required this.city,
    required this.weather,
  });

  final MigrationPlan plan;
  final City city;
  final CityWeather? weather;

  @override
  Widget build(BuildContext context) {
    final reasons = _buildReasonInsights(context, plan, city, weather);

    return FrostedPanel(
      child: Column(
        children: [
          for (var index = 0; index < reasons.length; index++) ...[
            _ReasonInsightTile(reason: reasons[index]),
            if (index != reasons.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ReasonInsightTile extends StatelessWidget {
  const _ReasonInsightTile({required this.reason});

  final _ReasonInsight reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reason.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: reason.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: reason.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(reason.icon, color: reason.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reason.userAnswer.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: reason.color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reason.explanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w600,
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

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.city, required this.weather});

  final City city;
  final CityWeather? weather;

  @override
  Widget build(BuildContext context) {
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final quality = CityIdhmPresentation.resolve(
      context,
      value: city.idhmScore,
    );
    final work = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: city.movaroScores.workOpportunity,
    );
    final publicOpinion = city.publicOpinion;
    final alternativeMetric = publicOpinion?.rating != null
        ? _CityMetricCardData(
            title: context.l10n.migrationPlanResultReviewsMetricTitle,
            value: publicOpinion!.rating!.toStringAsFixed(1),
            detail: _reviewsDetail(context, publicOpinion),
            color: AppColors.warning,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFFFF8E7),
            ),
          )
        : _CityMetricCardData(
            title: context.l10n.migrationPlanResultSafetyMetricTitle,
            value: _safetyValue(context, city.safetyScore),
            detail: _safetyDetail(context, city.safetyScore),
            color: _safetyColor(city.safetyScore),
            background: AppColors.tintedSurfaceFor(
              context,
              tint: _safetyColor(city.safetyScore),
              lightColor: AppColors.surfaceElevated,
            ),
          );
    final metrics = <_CityMetricCardData>[
      _CityMetricCardData(
        title: context.l10n.migrationPlanResultCostLabel,
        value: housing.badge,
        detail: housing.supporting,
        color: housing.tint,
        background: housing.background,
      ),
      _CityMetricCardData(
        title: context.l10n.cityDetailQualityLabel,
        value: quality.headline,
        detail: quality.supporting,
        color: quality.tint,
        background: quality.background,
      ),
      _CityMetricCardData(
        title: context.l10n.cityDetailWorkLabel,
        value: work.headline,
        detail: work.supporting,
        color: work.tint,
        background: work.background,
      ),
      alternativeMetric,
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _CityMetricCard(metric: metrics[0])),
            const SizedBox(width: 12),
            Expanded(child: _CityMetricCard(metric: metrics[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _CityMetricCard(metric: metrics[2])),
            const SizedBox(width: 12),
            Expanded(child: _CityMetricCard(metric: metrics[3])),
          ],
        ),
      ],
    );
  }
}

class _CityMetricCard extends StatelessWidget {
  const _CityMetricCard({required this.metric});

  final _CityMetricCardData metric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: metric.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: metric.color.withValues(
              alpha: AppColors.isDark(context) ? 0.24 : 0.16,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              metric.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                metric.detail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionStack extends StatelessWidget {
  const _ActionStack({
    required this.city,
    required this.isLoading,
    required this.onStartPlan,
    required this.onExploreCity,
  });

  final City city;
  final bool isLoading;
  final VoidCallback onStartPlan;
  final VoidCallback onExploreCity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isLoading ? null : onStartPlan,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  l10n.migrationPlanResultPrimaryAction(city.name),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onExploreCity,
          child: Text(l10n.migrationPlanResultExploreDetailsAction),
        ),
      ],
    );
  }
}

class _AlternativeCitiesList extends StatelessWidget {
  const _AlternativeCitiesList({
    required this.cities,
    required this.citiesController,
  });

  final List<City> cities;
  final CitiesController citiesController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < cities.length; index++) ...[
          _AlternativeCityTile(city: cities[index], rank: index + 2),
          if (index != cities.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AlternativeCityTile extends StatelessWidget {
  const _AlternativeCityTile({required this.city, required this.rank});

  final City city;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final attributes = _heroAttributes(context, city, null).take(2).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.cityDetail(city.id)),
        borderRadius: BorderRadius.circular(28),
        child: FrostedPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${city.stateName} (${city.stateCode})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: attributes
                          .map(
                            (attribute) =>
                                _SmallAttributeChip(attribute: attribute),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
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

class _SmallAttributeChip extends StatelessWidget {
  const _SmallAttributeChip({required this.attribute});

  final _HeroAttribute attribute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: attribute.color.withValues(
          alpha: AppColors.isDark(context) ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: attribute.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(attribute.icon, size: 14, color: attribute.color),
          const SizedBox(width: 6),
          Text(
            attribute.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: attribute.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

List<_HeroAttribute> _heroAttributes(
  BuildContext context,
  City city,
  CityWeather? weather,
) {
  final housing = CityHousingViabilityPresenter.resolve(
    context,
    rentScore: city.rentScore,
  );
  final lifestyle = switch (CityCoastalProfile.lifestyleKind(city)) {
    CityLifestyleKind.coastal => _HeroAttribute(
      label: context.l10n.cityLifestyleCoastalLabel,
      icon: Icons.waves_rounded,
      color: AppColors.accent,
      tone: ScoreTone.neutral,
      kind: _HeroAttributeKind.lifestyle,
    ),
    CityLifestyleKind.metropolis => _HeroAttribute(
      label: context.l10n.cityLifestyleMetropolisLabel,
      icon: Icons.location_city_rounded,
      color: AppColors.primary,
      tone: ScoreTone.neutral,
      kind: _HeroAttributeKind.lifestyle,
    ),
    CityLifestyleKind.border => _HeroAttribute(
      label: context.l10n.cityLifestyleBorderLabel,
      icon: Icons.compare_arrows_rounded,
      color: AppColors.warning,
      tone: ScoreTone.balanced,
      kind: _HeroAttributeKind.lifestyle,
    ),
    CityLifestyleKind.inland => _HeroAttribute(
      label: context.l10n.cityLifestyleInlandLabel,
      icon: Icons.terrain_rounded,
      color: AppColors.success,
      tone: ScoreTone.positive,
      kind: _HeroAttributeKind.lifestyle,
    ),
  };

  final attributes = <_HeroAttribute>[
    _HeroAttribute(
      label: housing.badge,
      icon: Icons.home_work_outlined,
      color: housing.tint,
      tone: housing.tint == AppColors.success
          ? ScoreTone.positive
          : housing.tint == AppColors.warning
          ? ScoreTone.balanced
          : ScoreTone.attention,
      kind: _HeroAttributeKind.cost,
    ),
    lifestyle,
  ];

  if (weather != null) {
    attributes.add(
      _HeroAttribute(
        label: '${weather.temperatureCelsius.round()}°C',
        icon: _weatherIcon(weather),
        color: _weatherColor(context, weather),
        tone: ScoreTone.neutral,
        kind: _HeroAttributeKind.weather,
      ),
    );
  }

  return attributes;
}

List<_ReasonInsight> _buildReasonInsights(
  BuildContext context,
  MigrationPlan plan,
  City city,
  CityWeather? weather,
) {
  final source = plan.cityRecommendationReasons.isNotEmpty
      ? plan.cityRecommendationReasons
      : city.recommendationReasons;
  final uniqueReasons = source.toSet().take(3);
  final results = uniqueReasons
      .map((reason) => _reasonInsightFor(context, plan, city, weather, reason))
      .whereType<_ReasonInsight>()
      .toList(growable: false);

  if (results.isNotEmpty) {
    return results;
  }

  return [
    _reasonInsightFor(
      context,
      plan,
      city,
      weather,
      'plan_reason_balanced_profile',
    )!,
  ];
}

_ReasonInsight? _reasonInsightFor(
  BuildContext context,
  MigrationPlan plan,
  City city,
  CityWeather? weather,
  String reasonId,
) {
  final housing = CityHousingViabilityPresenter.resolve(
    context,
    rentScore: city.rentScore,
  );
  final quality = CityIdhmPresentation.resolve(context, value: city.idhmScore);
  final work = CityMetricPresentation.resolve(
    context,
    kind: CityMetricKind.work,
    value: city.movaroScores.workOpportunity,
  );

  switch (reasonId) {
    case 'plan_reason_budget_fit':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('low_cost'),
        ),
        explanation: context.l10n.migrationPlanResultReasonBudget(city.name),
        icon: Icons.savings_outlined,
        color: housing.tint,
        background: housing.background,
        border: housing.tint.withValues(alpha: 0.18),
      );
    case 'plan_reason_job_mobility':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('job_opportunities'),
        ),
        explanation: context.l10n.migrationPlanResultReasonWork(
          city.name,
          work.headline,
        ),
        icon: work.icon,
        color: work.tint,
        background: work.background,
        border: work.border,
      );
    case 'plan_reason_safety':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('safety'),
        ),
        explanation: context.l10n.migrationPlanResultReasonQuality(
          city.name,
          quality.headline,
        ),
        icon: Icons.favorite_outline_rounded,
        color: quality.tint,
        background: quality.background,
        border: quality.border,
      );
    case 'plan_reason_climate_nature':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          _climateUserAnswer(context, plan),
        ),
        explanation: context.l10n.migrationPlanResultReasonClimate(
          city.name,
          _weatherNarrative(context, weather),
        ),
        icon: weather == null ? Icons.wb_sunny_rounded : _weatherIcon(weather),
        color: _weatherColor(context, weather),
        background: AppColors.tintedSurfaceFor(
          context,
          tint: _weatherColor(context, weather),
          lightColor: AppColors.surfaceElevated,
        ),
        border: _weatherColor(context, weather).withValues(alpha: 0.18),
      );
    case 'plan_reason_transit':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('transit_infra'),
        ),
        explanation: context.l10n.migrationPlanResultReasonTransit(city.name),
        icon: Icons.route_rounded,
        color: AppColors.primary,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: AppColors.surfaceElevated,
        ),
        border: AppColors.primary.withValues(alpha: 0.18),
      );
    case 'plan_reason_university':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('university'),
        ),
        explanation: context.l10n.migrationPlanResultReasonUniversity(
          city.name,
        ),
        icon: Icons.school_outlined,
        color: AppColors.primary,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: AppColors.surfaceElevated,
        ),
        border: AppColors.primary.withValues(alpha: 0.18),
      );
    case 'plan_reason_community':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('community'),
        ),
        explanation: context.l10n.migrationPlanResultReasonCommunity(city.name),
        icon: Icons.groups_rounded,
        color: AppColors.success,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFF1F8F3),
        ),
        border: AppColors.success.withValues(alpha: 0.18),
      );
    case 'plan_reason_proximity_argentina':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.priorityLabel('close_to_argentina'),
        ),
        explanation: context.l10n.migrationPlanResultReasonProximity(city.name),
        icon: Icons.south_america_rounded,
        color: AppColors.warning,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFFFF8E7),
        ),
        border: AppColors.warning.withValues(alpha: 0.18),
      );
    case 'plan_reason_balanced_profile':
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          context.l10n.questionOptionBalancedUnsure,
        ),
        explanation: context.l10n.migrationPlanResultReasonBalanced(city.name),
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primary,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: AppColors.surfaceElevated,
        ),
        border: AppColors.primary.withValues(alpha: 0.18),
      );
    default:
      return _ReasonInsight(
        userAnswer: context.l10n.migrationPlanResultReasonFromPriority(
          _bestAvailableAnswerLabel(context, plan),
        ),
        explanation: context.l10n.recommendationReasonLabel(reasonId),
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primary,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: AppColors.surfaceElevated,
        ),
        border: AppColors.primary.withValues(alpha: 0.18),
      );
  }
}

String _bestAvailableAnswerLabel(BuildContext context, MigrationPlan plan) {
  if (plan.selectedPriorities.isNotEmpty) {
    return context.l10n.priorityLabel(plan.selectedPriorities.first);
  }
  return context.l10n.goalLabel(plan.goal);
}

String _climateUserAnswer(BuildContext context, MigrationPlan plan) {
  if (plan.selectedPriorities.contains('warm_climate_beach')) {
    return context.l10n.priorityLabel('warm_climate_beach');
  }
  if (plan.selectedPriorities.contains('nature')) {
    return context.l10n.priorityLabel('nature');
  }
  return context.l10n.goalLabel(plan.goal);
}

String _reviewsDetail(BuildContext context, CityPublicOpinion opinion) {
  final count = opinion.userRatingCount;
  if (count != null) {
    return context.l10n.migrationPlanResultReviewsLabel(count);
  }
  return opinion.provider;
}

String _safetyValue(BuildContext context, int safetyScore) {
  if (safetyScore >= 70) {
    return context.l10n.cityMetricSafetyHighHeadline;
  }
  if (safetyScore >= 55) {
    return context.l10n.cityMetricSafetyMediumHeadline;
  }
  return context.l10n.cityMetricSafetyLowHeadline;
}

String _safetyDetail(BuildContext context, int safetyScore) {
  if (safetyScore >= 70) {
    return context.l10n.cityMetricSafetyHighSupporting;
  }
  if (safetyScore >= 55) {
    return context.l10n.cityMetricSafetyMediumSupporting;
  }
  return context.l10n.cityMetricSafetyLowSupporting;
}

Color _safetyColor(int safetyScore) {
  if (safetyScore >= 70) {
    return AppColors.success;
  }
  if (safetyScore >= 55) {
    return AppColors.warning;
  }
  return AppColors.danger;
}

String _weatherNarrative(BuildContext context, CityWeather? weather) {
  if (weather == null) {
    return context.l10n.migrationPlanResultWeatherPending;
  }

  final code = weather.weatherCode ?? -1;
  if (weather.isDay == false) {
    return context.l10n.migrationPlanResultWeatherClearNight;
  }
  if (code == 0 || code == 1) {
    return context.l10n.migrationPlanResultWeatherSunny;
  }
  if (code >= 2 && code <= 48) {
    return context.l10n.migrationPlanResultWeatherCloudy;
  }
  if (code >= 51 && code <= 67) {
    return context.l10n.migrationPlanResultWeatherRain;
  }
  if (code >= 71 && code <= 77) {
    return context.l10n.migrationPlanResultWeatherCold;
  }
  if (code >= 80 && code <= 99) {
    return context.l10n.migrationPlanResultWeatherStorm;
  }
  return context.l10n.migrationPlanResultWeatherMild;
}

Color _weatherColor(BuildContext context, CityWeather? weather) {
  if (weather == null) {
    return AppColors.primary;
  }
  if (weather.isDay == false) {
    return AppColors.secondary;
  }
  if (weather.temperatureCelsius >= 28) {
    return AppColors.warning;
  }
  if (weather.temperatureCelsius <= 14) {
    return AppColors.accent;
  }
  return AppColors.primary;
}

IconData _weatherIcon(CityWeather weather) {
  final code = weather.weatherCode ?? -1;
  if (weather.isDay == false) {
    return Icons.nights_stay_rounded;
  }
  if (code >= 51 && code <= 67) {
    return Icons.water_drop_rounded;
  }
  if (code >= 71 && code <= 77) {
    return Icons.ac_unit_rounded;
  }
  if (code == 0 || code == 1) {
    return Icons.wb_sunny_rounded;
  }
  if (code >= 2 && code <= 48) {
    return Icons.cloud_rounded;
  }
  if (code >= 80 && code <= 99) {
    return Icons.thunderstorm_rounded;
  }
  return Icons.thermostat_rounded;
}

class _HeroAttribute {
  const _HeroAttribute({
    required this.label,
    required this.icon,
    required this.color,
    required this.tone,
    required this.kind,
  });

  final String label;
  final IconData icon;
  final Color color;
  final ScoreTone tone;
  final _HeroAttributeKind kind;
}

enum _HeroAttributeKind { cost, lifestyle, weather }

class _ReasonInsight {
  const _ReasonInsight({
    required this.userAnswer,
    required this.explanation,
    required this.icon,
    required this.color,
    required this.background,
    required this.border,
  });

  final String userAnswer;
  final String explanation;
  final IconData icon;
  final Color color;
  final Color background;
  final Color border;
}

class _CityMetricCardData {
  const _CityMetricCardData({
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
    required this.background,
  });

  final String title;
  final String value;
  final String detail;
  final Color color;
  final Color background;
}
