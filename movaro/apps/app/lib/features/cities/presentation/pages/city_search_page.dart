import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/empty_state_widget.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/journey_stage_banner.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_arrival_profile_ranker.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_search_matcher.dart';
import 'package:movaro_app/features/cities/presentation/widgets/methodology_info_banner.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({required this.citiesController, super.key});

  final CitiesController citiesController;

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultsKey = GlobalKey();
  _CityQuickFilter _quickFilter = _CityQuickFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchInputChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.citiesController.loadCatalog();
      widget.citiesController.loadMethodology();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchInputChange);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearchInputChange() {
    if (!mounted) {
      return;
    }

    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final controller = widget.citiesController;
        final l10n = context.l10n;
        final hasSearchQuery = _searchController.text.isNotEmpty;
        final visibleCities = _visibleCities(controller);
        final suggestions = _autocompleteSuggestions(controller);
        final isCatalogBootstrapping =
            controller.catalog.isEmpty && controller.catalogError == null;

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.citiesSearchTitle,
                      onBack: _goBackToCities,
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: FrostedPanel(
                        padding: const EdgeInsets.all(32),
                        gradient: LinearGradient(
                          colors: [
                            isDark
                                ? const Color(0xFF0F1A2A)
                                : Colors.white.withValues(alpha: 0.88),
                            isDark
                                ? const Color(0xFF13243D)
                                : const Color(0xFFF4F7FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        backgroundColor: isDark
                            ? const Color(0xD9111822)
                            : AppColors.frostedBackgroundFor(context),
                        borderColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.frostedBorderFor(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.citiesSearchHeadline,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: textPrimary),
                            ),
                            const SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: Text(
                                l10n.citiesSearchDescription,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: textSoft),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: l10n.citiesSearchHint,
                                labelText: l10n.citiesSearchFieldLabel,
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: hasSearchQuery
                                    ? IconButton(
                                        onPressed: _clearSearch,
                                        icon: const Icon(Icons.close_rounded),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          _handlePrimarySearchAction(
                                            suggestions,
                                          );
                                        },
                                        icon: const Icon(Icons.search_rounded),
                                      ),
                              ),
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                _handlePrimarySearchAction(suggestions);
                              },
                            ),
                            if (hasSearchQuery && suggestions.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _CityAutocompletePanel(
                                title: l10n.citiesSearchResultsCount(
                                  suggestions.length,
                                ),
                                subtitle: l10n.citiesSearchResultsHint,
                                cities: suggestions,
                                onTapCity: _openCityDetail,
                              ),
                            ],
                            const SizedBox(height: 16),
                            _CityQuickFilterRail(
                              filters: _CityQuickFilter.values
                                  .where(
                                    (filter) => filter != _CityQuickFilter.all,
                                  )
                                  .toList(),
                              selectedFilter: _quickFilter,
                              labelBuilder: (filter) =>
                                  _quickFilterLabel(l10n, filter),
                              onSelected: _handleQuickFilterSelection,
                              clearLabel: l10n.citiesFilterClear,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: MethodologyInfoBanner(
                        message: l10n.citiesMethodologyNote,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: JourneyStageBanner(
                        title: l10n.validateCityBannerTitle(),
                        body: l10n.validateCityBannerBody(),
                        action: l10n.validateCityBannerAction(),
                        icon: Icons.location_searching_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!hasSearchQuery &&
                        controller.isLoadingCatalog &&
                        controller.catalog.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: LoadingStateWidget(
                          label: l10n.citiesCatalogLoadingLabel,
                          compact: true,
                        ),
                      ),
                    if (!hasSearchQuery &&
                        controller.catalogError != null &&
                        controller.catalog.isEmpty)
                      Builder(
                        builder: (context) {
                          final error = ErrorHandler.resolve(
                            context,
                            controller.catalogError!,
                          );

                          return ErrorStateWidget(
                            title: error.title,
                            description: error.description,
                            illustrationAsset: error.illustrationAsset,
                            onRetry: error.isRetryable
                                ? widget.citiesController.loadCatalog
                                : null,
                            onBack: () => Navigator.pop(context),
                          );
                        },
                      )
                    else if ((!hasSearchQuery &&
                            controller.isLoadingCatalog &&
                            controller.catalog.isEmpty) ||
                        isCatalogBootstrapping)
                      Semantics(
                        container: true,
                        liveRegion: true,
                        label: l10n.loadingCitiesCatalogLabel,
                        child: ExcludeSemantics(
                          child: ListSkeleton(itemCount: 5),
                        ),
                      )
                    else if (visibleCities.isEmpty)
                      EmptyStateWidget(
                        title: l10n.citiesSearchEmptyTitle,
                        description: l10n.citiesSearchEmptyDescription,
                      )
                    else if (!hasSearchQuery && controller.catalog.isEmpty)
                      EmptyStateWidget(
                        title: l10n.citiesCatalogEmptyTitle,
                        description: l10n.citiesCatalogEmptyDescription,
                      )
                    else
                      AnimatedStateSwitcher(
                        child: KeyedSubtree(
                          key: ValueKey(
                            '${hasSearchQuery}_${visibleCities.length}',
                          ),
                          child: ConstrainedBox(
                            key: _resultsKey,
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ResultsHeader(
                                  title: l10n.citiesResultsTitle,
                                  body: l10n.citiesResultsBody(
                                    visibleCities.length,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                for (final city in visibleCities) ...[
                                  CityCard(
                                    city: city,
                                    highlightLabel: _highlightLabel(
                                      l10n,
                                      _quickFilter,
                                    ),
                                    citiesController: widget.citiesController,
                                    isFavorite: widget.citiesController
                                        .isFavorite(city.id),
                                    onFavoriteToggle: () =>
                                        _toggleFavoriteCity(city),
                                    onTap: () => _openCityDetail(city),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<City> _visibleCities(CitiesController controller) {
    final cities = List<City>.from(controller.catalog);
    final normalizedQuery = _normalizeSearch(_searchController.text);
    final semanticSearch = _CitySemanticSearch(normalizedQuery);

    final filteredCities = normalizedQuery.isEmpty
        ? cities
        : cities.where(semanticSearch.matches).toList();

    switch (_quickFilter) {
      case _CityQuickFilter.all:
        final ranked =
            filteredCities
                .map((city) => (city: city, score: semanticSearch.score(city)))
                .toList()
              ..sort((left, right) => right.score.compareTo(left.score));
        return ranked.map((entry) => entry.city).toList();
      case _CityQuickFilter.popular:
        filteredCities.sort(
          (a, b) => b.movaroScores.popularForArgentinians.compareTo(
            a.movaroScores.popularForArgentinians,
          ),
        );
        return filteredCities;
      case _CityQuickFilter.lowCost:
        filteredCities.sort(
          (a, b) =>
              b.movaroScores.economical.compareTo(a.movaroScores.economical),
        );
        return filteredCities;
      case _CityQuickFilter.work:
        filteredCities.sort(
          (a, b) => b.movaroScores.workOpportunity.compareTo(
            a.movaroScores.workOpportunity,
          ),
        );
        return filteredCities;
      case _CityQuickFilter.language:
        filteredCities.sort(
          (a, b) => b.movaroScores.languageAdaptation.compareTo(
            a.movaroScores.languageAdaptation,
          ),
        );
        return filteredCities;
      case _CityQuickFilter.housingEasy:
        filteredCities.sort((a, b) => b.rentScore.compareTo(a.rentScore));
        return filteredCities;
      case _CityQuickFilter.housingPressure:
        filteredCities.sort((a, b) => a.rentScore.compareTo(b.rentScore));
        return filteredCities;
      case _CityQuickFilter.softLanding:
        return CityArrivalProfileRanker.rank(
          filteredCities,
          profile: CityArrivalProfile.softLanding,
        );
      case _CityQuickFilter.familyStability:
        return CityArrivalProfileRanker.rank(
          filteredCities,
          profile: CityArrivalProfile.familyStability,
        );
      case _CityQuickFilter.incomeStart:
        return CityArrivalProfileRanker.rank(
          filteredCities,
          profile: CityArrivalProfile.incomeStart,
        );
      case _CityQuickFilter.coastal:
        final coastalCities = cities
            .where(CityCoastalProfile.isCoastal)
            .toList();
        if (normalizedQuery.isNotEmpty) {
          final matchingCoastal = coastalCities
              .where(semanticSearch.matches)
              .toList();
          if (matchingCoastal.isNotEmpty) {
            return CityCoastalProfile.rankCoastal(matchingCoastal);
          }
        }
        return CityCoastalProfile.rankCoastal(coastalCities);
      case _CityQuickFilter.metropolis:
        final metropolisCities = cities
            .where(
              (city) =>
                  CityCoastalProfile.lifestyleKind(city) ==
                  CityLifestyleKind.metropolis,
            )
            .toList();
        if (normalizedQuery.isNotEmpty) {
          final matchingMetropolis = metropolisCities
              .where(semanticSearch.matches)
              .toList();
          if (matchingMetropolis.isNotEmpty) {
            matchingMetropolis.sort(
              (a, b) => b.population.compareTo(a.population),
            );
            return matchingMetropolis;
          }
        }
        metropolisCities.sort((a, b) => b.population.compareTo(a.population));
        return metropolisCities;
      case _CityQuickFilter.inland:
        final inlandCities = cities
            .where(
              (city) =>
                  CityCoastalProfile.lifestyleKind(city) ==
                  CityLifestyleKind.inland,
            )
            .toList();
        if (normalizedQuery.isNotEmpty) {
          final matchingInland = inlandCities
              .where(semanticSearch.matches)
              .toList();
          if (matchingInland.isNotEmpty) {
            matchingInland.sort((a, b) => b.rentScore.compareTo(a.rentScore));
            return matchingInland;
          }
        }
        inlandCities.sort((a, b) => b.rentScore.compareTo(a.rentScore));
        return inlandCities;
      case _CityQuickFilter.border:
        final borderCities = cities
            .where(
              (city) =>
                  CityCoastalProfile.lifestyleKind(city) ==
                  CityLifestyleKind.border,
            )
            .toList();
        if (normalizedQuery.isNotEmpty) {
          final matchingBorder = borderCities
              .where(semanticSearch.matches)
              .toList();
          if (matchingBorder.isNotEmpty) {
            matchingBorder.sort(
              (a, b) => b.argentinaPopularityScore.compareTo(
                a.argentinaPopularityScore,
              ),
            );
            return matchingBorder;
          }
        }
        borderCities.sort(
          (a, b) =>
              b.argentinaPopularityScore.compareTo(a.argentinaPopularityScore),
        );
        return borderCities;
    }
  }

  List<City> _autocompleteSuggestions(CitiesController controller) {
    final normalizedQuery = _normalizeSearch(_searchController.text);
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final semanticSearch = _CitySemanticSearch(normalizedQuery);
    final ranked = List<City>.from(controller.catalog)
        .map(
          (city) => (
            city: city,
            score: semanticSearch.score(city) +
                CitySearchMatcher.score(
                  normalizedQuery,
                  city.name,
                  city.stateName,
                ) +
                (_startsWithQuery(city, normalizedQuery) ? 12 : 0),
          ),
        )
        .where((entry) => entry.score > 0)
        .toList()
      ..sort((left, right) => right.score.compareTo(left.score));
    return ranked.map((entry) => entry.city).take(5).toList();
  }

  bool _startsWithQuery(City city, String query) {
    final normalizedName = _normalizeSearch(city.name);
    return normalizedName.startsWith(query) ||
        _normalizeSearch(city.stateName).startsWith(query);
  }

  String _quickFilterLabel(dynamic l10n, _CityQuickFilter filter) {
    switch (filter) {
      case _CityQuickFilter.all:
        return l10n.citiesQuickFilterAll;
      case _CityQuickFilter.popular:
        return l10n.citiesQuickFilterPopular;
      case _CityQuickFilter.lowCost:
        return l10n.citiesQuickFilterLowCost;
      case _CityQuickFilter.work:
        return l10n.citiesQuickFilterWork;
      case _CityQuickFilter.language:
        return l10n.citiesQuickFilterLanguage;
      case _CityQuickFilter.housingEasy:
        return l10n.citiesQuickFilterHousingEasy;
      case _CityQuickFilter.housingPressure:
        return l10n.citiesQuickFilterHousingPressure;
      case _CityQuickFilter.softLanding:
        return l10n.citiesQuickFilterSoftLanding;
      case _CityQuickFilter.familyStability:
        return l10n.citiesQuickFilterFamilyStability;
      case _CityQuickFilter.incomeStart:
        return l10n.citiesQuickFilterIncomeStart;
      case _CityQuickFilter.coastal:
        return l10n.citiesQuickFilterCoastal;
      case _CityQuickFilter.metropolis:
        return l10n.cityLifestyleMetropolisLabel;
      case _CityQuickFilter.inland:
        return l10n.cityLifestyleInlandLabel;
      case _CityQuickFilter.border:
        return l10n.cityLifestyleBorderLabel;
    }
  }

  String _highlightLabel(dynamic l10n, _CityQuickFilter filter) {
    switch (filter) {
      case _CityQuickFilter.all:
      case _CityQuickFilter.popular:
        return l10n.citiesHighlightPopularLabel;
      case _CityQuickFilter.lowCost:
        return l10n.citiesHighlightEconomicalLabel;
      case _CityQuickFilter.work:
        return l10n.citiesHighlightWorkLabel;
      case _CityQuickFilter.language:
        return l10n.citiesHighlightLanguageLabel;
      case _CityQuickFilter.housingEasy:
        return l10n.citiesHighlightHousingEasyLabel;
      case _CityQuickFilter.housingPressure:
        return l10n.citiesHighlightHousingPressureLabel;
      case _CityQuickFilter.softLanding:
        return l10n.citiesHighlightSoftLandingLabel;
      case _CityQuickFilter.familyStability:
        return l10n.citiesHighlightFamilyStabilityLabel;
      case _CityQuickFilter.incomeStart:
        return l10n.citiesHighlightIncomeStartLabel;
      case _CityQuickFilter.coastal:
        return l10n.citiesHighlightCoastalLabel;
      case _CityQuickFilter.metropolis:
        return l10n.citiesHighlightMetropolisLabel;
      case _CityQuickFilter.inland:
        return l10n.citiesHighlightInlandLabel;
      case _CityQuickFilter.border:
        return l10n.citiesHighlightBorderLabel;
    }
  }

  void _handlePrimarySearchAction(List<City> suggestions) {
    if (suggestions.isNotEmpty) {
      _openCityDetail(suggestions.first);
      return;
    }

    _scrollToResults();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _handleQuickFilterSelection(_CityQuickFilter? filter) {
    setState(() {
      _quickFilter = filter ?? _CityQuickFilter.all;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToResults());
  }

  void _scrollToResults() {
    final resultsContext = _resultsKey.currentContext;
    if (resultsContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      resultsContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _openCityDetail(City city) {
    widget.citiesController.prefetchCityDetail(city.id);
    widget.citiesController.prefetchMethodology();
    Navigator.pushNamed(
      context,
      AppRoutes.cityDetail(city.id),
      arguments: const {'validationFlow': true},
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

class _CityAutocompletePanel extends StatelessWidget {
  const _CityAutocompletePanel({
    required this.title,
    required this.subtitle,
    required this.cities,
    required this.onTapCity,
  });

  final String title;
  final String subtitle;
  final List<City> cities;
  final ValueChanged<City> onTapCity;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.borderFor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          if (cities.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var index = 0; index < cities.length; index++) ...[
              _AutocompleteCityTile(
                city: cities[index],
                onTap: () => onTapCity(cities[index]),
              ),
              if (index != cities.length - 1) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _AutocompleteCityTile extends StatelessWidget {
  const _AutocompleteCityTile({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_city_rounded, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${city.stateName} (${city.stateCode})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.documentationOpenTopicAction,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityQuickFilterRail extends StatelessWidget {
  const _CityQuickFilterRail({
    required this.filters,
    required this.selectedFilter,
    required this.labelBuilder,
    required this.onSelected,
    required this.clearLabel,
  });

  final List<_CityQuickFilter> filters;
  final _CityQuickFilter selectedFilter;
  final String Function(_CityQuickFilter filter) labelBuilder;
  final ValueChanged<_CityQuickFilter?> onSelected;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _QuickFilterChip(
              label: clearLabel,
              selected: selectedFilter == _CityQuickFilter.all,
              icon: Icons.apps_rounded,
              onTap: () => onSelected(null),
            );
          }

          final filter = filters[index - 1];
          return _QuickFilterChip(
            label: labelBuilder(filter),
            selected: selectedFilter == filter,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
          : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CityQuickFilter {
  all,
  popular,
  lowCost,
  work,
  language,
  housingEasy,
  housingPressure,
  softLanding,
  familyStability,
  incomeStart,
  coastal,
  metropolis,
  inland,
  border,
}

String _normalizeSearch(String value) {
  var normalized = value.toLowerCase().trim();
  const replacements = <String, String>{
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };
  replacements.forEach((source, target) {
    normalized = normalized.replaceAll(source, target);
  });
  normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized;
}

class _CitySemanticSearch {
  _CitySemanticSearch(this.query)
    : tokens = query.split(' ').where((token) => token.isNotEmpty).toList();

  final String query;
  final List<String> tokens;

  static const _cheapTerms = {
    'barata',
    'barato',
    'baratas',
    'baratos',
    'cheap',
    'cheaper',
    'low',
    'cost',
    'costo',
    'custe',
    'custo',
    'economica',
    'economico',
    'economicao',
    'economical',
    'affordable',
  };
  static const _popularTerms = {
    'popular',
    'populares',
    'argentino',
    'argentina',
    'argentinians',
    'argentinos',
  };
  static const _workTerms = {
    'trabalho',
    'trabajo',
    'work',
    'job',
    'jobs',
    'empleo',
    'empleos',
    'laboral',
    'mercado',
  };
  static const _languageTerms = {
    'idioma',
    'language',
    'lengua',
    'espanhol',
    'espanol',
    'spanish',
    'portugues',
    'portuguese',
    'adaptacao',
    'adaptacion',
  };
  static const _safetyTerms = {
    'seguranca',
    'seguridad',
    'safe',
    'safety',
    'seguro',
    'segura',
  };
  static const _southTerms = {'sul', 'sur', 'south'};
  static const _housingEasyTerms = {
    'aluguel',
    'alquiler',
    'rent',
    'housing',
    'moradia',
    'caucao',
    'deposito',
    'deposit',
    'fiador',
    'leve',
    'light',
    'landing',
  };
  static const _housingPressureTerms = {
    'caro',
    'pesado',
    'heavy',
    'entrada',
    'entry',
    'pressao',
    'pressure',
    'cash',
    'caixa',
    'segurofianca',
    'garantia',
  };
  static const _softLandingTerms = {
    'soft',
    'landing',
    'leve',
    'liviana',
    'chegada',
    'llegada',
    'facil',
    'suave',
    'smooth',
    'inicio',
    'comeco',
    'comienzo',
  };
  static const _familyTerms = {
    'familia',
    'family',
    'kids',
    'filhos',
    'hijos',
    'criancas',
    'segura',
    'estavel',
    'estable',
    'stable',
    'escola',
    'school',
  };
  static const _incomeStartTerms = {
    'renda',
    'income',
    'ingreso',
    'salary',
    'salario',
    'dinero',
    'money',
    'emprego',
    'empleo',
    'job',
    'jobs',
    'trabajo',
    'work',
  };
  static const _coastalTerms = {
    'praia',
    'playa',
    'beach',
    'mar',
    'sea',
    'coast',
    'coastal',
    'litoral',
    'costa',
  };
  static const _metropolisTerms = {
    'metropole',
    'metropoli',
    'metropolis',
    'capital',
    'grande',
    'big',
    'urban',
    'urbana',
    'urbano',
  };
  static const _inlandTerms = {
    'interior',
    'inland',
    'calma',
    'quiet',
    'tranquila',
    'tranquilo',
    'small',
    'menor',
  };
  static const _borderTerms = {'fronteira', 'frontera', 'border', 'fronteriza'};

  bool matches(City city) {
    if (query.isEmpty) {
      return true;
    }

    return score(city) > 0;
  }

  int score(City city) {
    if (query.isEmpty) {
      return 0;
    }

    final haystack = _normalizeSearch(
      [
        city.name,
        city.stateName,
        city.stateCode,
        city.regionName ?? '',
        ...city.topIndustries,
      ].join(' '),
    );

    var total = 0;

    total += CitySearchMatcher.score(query, city.name, city.stateName);

    if (haystack.contains(query)) {
      total += 120;
    }

    for (final token in tokens) {
      if (haystack.contains(token)) {
        total += 36;
      }
    }

    if (_hasAny(_cheapTerms)) {
      total += city.movaroScores.economical;
    }
    if (_hasAny(_popularTerms)) {
      total += city.movaroScores.popularForArgentinians;
    }
    if (_hasAny(_workTerms)) {
      total += city.movaroScores.workOpportunity;
    }
    if (_hasAny(_languageTerms)) {
      total += city.movaroScores.languageAdaptation;
    }
    if (_hasAny(_safetyTerms)) {
      total += city.safetyScore;
    }
    if (_hasAny(_housingEasyTerms)) {
      total += city.rentScore;
    }
    if (_hasAny(_housingPressureTerms)) {
      total += (100 - city.rentScore);
    }
    if (_hasAny(_softLandingTerms)) {
      total +=
          CityArrivalProfileRanker.score(
            city,
            profile: CityArrivalProfile.softLanding,
          ) ~/
          100;
    }
    if (_hasAny(_familyTerms)) {
      total +=
          CityArrivalProfileRanker.score(
            city,
            profile: CityArrivalProfile.familyStability,
          ) ~/
          100;
    }
    if (_hasAny(_incomeStartTerms)) {
      total +=
          CityArrivalProfileRanker.score(
            city,
            profile: CityArrivalProfile.incomeStart,
          ) ~/
          100;
    }
    if (_hasAny(_coastalTerms) && CityCoastalProfile.isCoastal(city)) {
      total += 140;
    }
    if (_hasAny(_metropolisTerms) &&
        CityCoastalProfile.lifestyleKind(city) ==
            CityLifestyleKind.metropolis) {
      total += 120;
    }
    if (_hasAny(_inlandTerms) &&
        CityCoastalProfile.lifestyleKind(city) == CityLifestyleKind.inland) {
      total += 120;
    }
    if (_hasAny(_borderTerms) &&
        CityCoastalProfile.lifestyleKind(city) == CityLifestyleKind.border) {
      total += 120;
    }
    if (_hasAny(_southTerms) && _isSouth(city)) {
      total += 90;
    }

    return total;
  }

  bool _hasAny(Set<String> terms) => tokens.any(terms.contains);

  bool _isSouth(City city) {
    final region = _normalizeSearch(city.regionName ?? '');
    final state = _normalizeSearch(city.stateName);
    return region.contains('sul') ||
        region.contains('south') ||
        {'parana', 'santa catarina', 'rio grande do sul'}.contains(state);
  }
}
