import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/empty_state_widget.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_arrival_profile_ranker.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_picker_bottom_sheet.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class CitiesExplorePage extends StatefulWidget {
  const CitiesExplorePage({
    required this.citiesController,
    this.journeyContextController,
    this.migrationQuestionnaireController,
    super.key,
  });

  final CitiesController citiesController;
  final JourneyContextController? journeyContextController;
  final MigrationQuestionnaireController? migrationQuestionnaireController;

  @override
  State<CitiesExplorePage> createState() => _CitiesExplorePageState();
}

class _CitiesExplorePageState extends State<CitiesExplorePage> {
  static const _helpPreferenceKey = 'cities_explore_page';
  static const _pageSize = 8;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;
  _CityQuickFilter? _quickFilter;
  int _visibleCount = _pageSize;
  bool _didTryAutoHelp = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    widget.citiesController.loadExplore();
    widget.citiesController.loadCatalog();
    widget.citiesController.loadMethodology();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowHelp();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final controller = widget.citiesController;
        final l10n = context.l10n;
        final isDark = AppColors.isDark(context);
        final textSoft = AppColors.textSoftFor(context);
        final hasQuery = _searchController.text.trim().isNotEmpty;
        final visibleCities = _visibleCities(controller);
        final pagedCities = visibleCities.take(_visibleCount).toList();
        final suggestions = _autocompleteSuggestions(controller);
        final shouldShowResults = hasQuery || _quickFilter != null;
        final isLoadingResults = hasQuery
            ? controller.isSearching
            : _quickFilter != null && controller.isLoadingCatalog;
        final resultsError = hasQuery
            ? controller.searchError
            : _quickFilter != null
            ? controller.catalogError
            : null;
        final isCatalogBootstrapping =
            controller.catalog.isEmpty &&
            controller.catalogError == null &&
            (controller.isLoadingCatalog || hasQuery || _quickFilter != null);

        return Scaffold(
          extendBody: true,
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
                      title: l10n.citiesExploreTitle,
                      onBack: () => Navigator.canPop(context)
                          ? Navigator.maybePop(context)
                          : Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.publicHome,
                              (route) => false,
                            ),
                      onHelp: _showHelp,
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: FrostedPanel(
                        padding: const EdgeInsets.all(24),
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
                            _CitiesSearchField(
                              controller: _searchController,
                              hintText: l10n.citiesSearchHint,
                              onChanged: _handleSearchChanged,
                              onSubmitted: (_) =>
                                  _handlePrimarySearchAction(suggestions),
                              onClear: hasQuery ? _clearSearch : null,
                            ),
                            if (hasQuery) ...[
                              const SizedBox(height: 12),
                              _CityAutocompletePanel(
                                title: l10n.citiesSearchResultsCount(
                                  visibleCities.length,
                                ),
                                subtitle: l10n.citiesSearchResultsHint,
                                cities: suggestions,
                                onTapCity: _openCityDetail,
                              ),
                            ],
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 14),
                            _CitiesMapCallout(
                              title: l10n.citiesMapOpenAction,
                              body: l10n.citiesMapSheetBody,
                              onTap: () => _openCitiesMapSheet(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!shouldShowResults)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: EmptyStateWidget(
                          title: l10n.citiesExploreSearchIdleTitle,
                          description: l10n.citiesExploreSearchIdleDescription,
                        ),
                      )
                    else if (resultsError != null)
                      Builder(
                        builder: (context) {
                          final error = ErrorHandler.resolve(
                            context,
                            resultsError,
                          );
                          return ErrorStateWidget(
                            title: error.title,
                            description: error.description,
                            illustrationAsset: error.illustrationAsset,
                            onRetry: error.isRetryable
                                ? () => _retryCurrentMode(hasQuery)
                                : null,
                            onBack: () => Navigator.maybePop(context),
                          );
                        },
                      )
                    else if ((isLoadingResults && pagedCities.isEmpty) ||
                        isCatalogBootstrapping)
                      Semantics(
                        container: true,
                        liveRegion: true,
                        label: hasQuery
                            ? l10n.citiesSearchingLabel
                            : l10n.loadingCitiesCatalogLabel,
                        child: ExcludeSemantics(
                          child: ListSkeleton(itemCount: 4),
                        ),
                      )
                    else if (visibleCities.isEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: EmptyStateWidget(
                          title: l10n.citiesSearchEmptyTitle,
                          description: l10n.citiesSearchFirstEmptyDescription,
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ResultsHeader(
                              title: l10n.citiesResultsTitle,
                              body: l10n.citiesResultsBody(pagedCities.length),
                            ),
                            const SizedBox(height: 16),
                            for (final city in pagedCities) ...[
                              CityCard(
                                city: city,
                                highlightLabel: _highlightLabel(
                                  l10n,
                                  _quickFilter ?? _CityQuickFilter.all,
                                ),
                                citiesController: widget.citiesController,
                                isFavorite: widget.citiesController.isFavorite(
                                  city.id,
                                ),
                                onFavoriteToggle: () =>
                                    _toggleFavoriteCity(city),
                                onTap: () => _openCityDetail(city),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (isLoadingResults && pagedCities.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: LoadingStateWidget(
                                  label: hasQuery
                                      ? l10n.citiesSearchingLabel
                                      : l10n.citiesCatalogLoadingLabel,
                                  compact: true,
                                ),
                              ),
                            if (_visibleCount < visibleCities.length)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Center(
                                  child: Text(
                                    l10n.citiesResultsMoreHint,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: textSoft),
                                  ),
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
          bottomNavigationBar:
              widget.journeyContextController != null &&
                  widget.migrationQuestionnaireController != null
              ? MainNavigationBar(
                  currentIndex: 1,
                  journeyContextController: widget.journeyContextController!,
                  citiesController: widget.citiesController,
                  migrationQuestionnaireController:
                      widget.migrationQuestionnaireController!,
                )
              : null,
        );
      },
    );
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
      eyebrow: context.l10n.citiesGuideEyebrow,
      contextIcon: Icons.travel_explore_rounded,
      title: context.l10n.citiesGuideTitle,
      body: context.l10n.citiesGuideBody,
      steps: [
        FeatureGuideStep(
          number: '1',
          title: context.l10n.citiesGuideStepOneTitle,
          body: context.l10n.citiesGuideStepOneBody,
        ),
        FeatureGuideStep(
          number: '2',
          title: context.l10n.citiesGuideStepTwoTitle,
          body: context.l10n.citiesGuideStepTwoBody,
        ),
        FeatureGuideStep(
          number: '3',
          title: context.l10n.citiesGuideStepThreeTitle,
          body: context.l10n.citiesGuideStepThreeBody,
        ),
      ],
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) {
      return;
    }

    final total = _visibleCities(widget.citiesController).length;
    if (_visibleCount >= total) {
      return;
    }

    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
    });
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() {
      _visibleCount = _pageSize;
    });

    final query = value.trim();
    if (query.isEmpty) {
      widget.citiesController.search('');
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      widget.citiesController.search(query);
    });
  }

  Future<void> _handleQuickFilterSelection(_CityQuickFilter? filter) async {
    setState(() {
      _quickFilter = _quickFilter == filter ? null : filter;
      _visibleCount = _pageSize;
    });

    if (_quickFilter != null && widget.citiesController.catalog.isEmpty) {
      await widget.citiesController.loadCatalog();
    }
  }

  void _handlePrimarySearchAction(List<City> suggestions) {
    if (suggestions.isNotEmpty) {
      _openCityDetail(suggestions.first);
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    widget.citiesController.search('');
    setState(() {
      _visibleCount = _pageSize;
    });
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

  Future<void> _openCitiesMapSheet(BuildContext context) async {
    if (widget.citiesController.catalog.isEmpty) {
      await widget.citiesController.loadCatalog();
    }

    if (!context.mounted) {
      return;
    }

    final cities = widget.citiesController.catalog;
    final selected = await CityPickerBottomSheet.show(
      context: context,
      cities: cities,
      title: context.l10n.citiesMapSheetTitle,
      subtitle: context.l10n.citiesMapSheetBody,
      confirmLabel: context.l10n.citiesMapOpenCityAction,
    );
    if (selected != null && mounted) {
      _openCityDetail(selected);
    }
  }

  void _retryCurrentMode(bool hasQuery) {
    if (hasQuery) {
      widget.citiesController.search(_searchController.text.trim());
      return;
    }
    widget.citiesController.loadCatalog();
  }

  List<City> _autocompleteSuggestions(CitiesController controller) {
    final query = _normalizeSearch(_searchController.text);
    if (query.isEmpty) {
      return const [];
    }

    final semanticSearch = _CitySemanticSearch(query);
    final ranked = List<City>.from(controller.searchResults)
      ..sort(
        (left, right) =>
            semanticSearch.score(right).compareTo(semanticSearch.score(left)),
      );
    return ranked.take(5).toList();
  }

  List<City> _visibleCities(CitiesController controller) {
    final query = _normalizeSearch(_searchController.text);
    final semanticSearch = _CitySemanticSearch(query);
    final source = query.isNotEmpty
        ? List<City>.from(controller.searchResults)
        : _quickFilter != null
        ? List<City>.from(controller.catalog)
        : <City>[];

    if (source.isEmpty) {
      return const [];
    }

    final filtered = _applyQuickFilter(source, semanticSearch);
    if (query.isEmpty) {
      return filtered;
    }

    final ranked =
        filtered
            .map((city) => (city: city, score: semanticSearch.score(city)))
            .where((entry) => entry.score > 0)
            .toList()
          ..sort((left, right) => right.score.compareTo(left.score));
    return ranked.map((entry) => entry.city).toList();
  }

  List<City> _applyQuickFilter(List<City> cities, _CitySemanticSearch search) {
    final filteredCities = cities.where(search.matches).toList();
    final activeCities = search.query.isEmpty ? cities : filteredCities;

    switch (_quickFilter ?? _CityQuickFilter.all) {
      case _CityQuickFilter.all:
        return activeCities;
      case _CityQuickFilter.popular:
        activeCities.sort(
          (a, b) => b.movaroScores.popularForArgentinians.compareTo(
            a.movaroScores.popularForArgentinians,
          ),
        );
        return activeCities;
      case _CityQuickFilter.lowCost:
        activeCities.sort(
          (a, b) =>
              b.movaroScores.economical.compareTo(a.movaroScores.economical),
        );
        return activeCities;
      case _CityQuickFilter.work:
        activeCities.sort(
          (a, b) => b.movaroScores.workOpportunity.compareTo(
            a.movaroScores.workOpportunity,
          ),
        );
        return activeCities;
      case _CityQuickFilter.language:
        activeCities.sort(
          (a, b) => b.movaroScores.languageAdaptation.compareTo(
            a.movaroScores.languageAdaptation,
          ),
        );
        return activeCities;
      case _CityQuickFilter.housingEasy:
        activeCities.sort((a, b) => b.rentScore.compareTo(a.rentScore));
        return activeCities;
      case _CityQuickFilter.housingPressure:
        activeCities.sort((a, b) => a.rentScore.compareTo(b.rentScore));
        return activeCities;
      case _CityQuickFilter.softLanding:
        return CityArrivalProfileRanker.rank(
          activeCities,
          profile: CityArrivalProfile.softLanding,
        );
      case _CityQuickFilter.familyStability:
        return CityArrivalProfileRanker.rank(
          activeCities,
          profile: CityArrivalProfile.familyStability,
        );
      case _CityQuickFilter.incomeStart:
        return CityArrivalProfileRanker.rank(
          activeCities,
          profile: CityArrivalProfile.incomeStart,
        );
      case _CityQuickFilter.coastal:
        return CityCoastalProfile.rankCoastal(
          activeCities.where(CityCoastalProfile.isCoastal).toList(),
        );
      case _CityQuickFilter.metropolis:
        final metropolis = activeCities
            .where(
              (city) =>
                  CityCoastalProfile.lifestyleKind(city) ==
                  CityLifestyleKind.metropolis,
            )
            .toList();
        metropolis.sort((a, b) => b.population.compareTo(a.population));
        return metropolis;
      case _CityQuickFilter.inland:
        final inland = activeCities
            .where(
              (city) =>
                  CityCoastalProfile.lifestyleKind(city) ==
                  CityLifestyleKind.inland,
            )
            .toList();
        inland.sort((a, b) => b.rentScore.compareTo(a.rentScore));
        return inland;
      case _CityQuickFilter.border:
        final border = activeCities
            .where(
              (city) =>
                  CityCoastalProfile.lifestyleKind(city) ==
                  CityLifestyleKind.border,
            )
            .toList();
        border.sort(
          (a, b) =>
              b.argentinaPopularityScore.compareTo(a.argentinaPopularityScore),
        );
        return border;
    }
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

  void _openCityDetail(City city) {
    widget.citiesController.prefetchCityDetail(city.id);
    widget.citiesController.prefetchMethodology();
    Navigator.pushNamed(context, AppRoutes.cityDetail(city.id));
  }
}

class _CitiesSearchField extends StatelessWidget {
  const _CitiesSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
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
  final _CityQuickFilter? selectedFilter;
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
              selected: selectedFilter == null,
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

class _CitiesMapCallout extends StatelessWidget {
  const _CitiesMapCallout({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.16),
                const Color(0xFF2A6FBE).withValues(alpha: 0.14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
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

class _CitiesMapBottomSheet extends StatefulWidget {
  const _CitiesMapBottomSheet({required this.cities, required this.onTapCity});

  final List<City> cities;
  final ValueChanged<City> onTapCity;

  @override
  State<_CitiesMapBottomSheet> createState() => _CitiesMapBottomSheetState();
}

class _CitiesMapBottomSheetState extends State<_CitiesMapBottomSheet> {
  late City _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.cities.first;
  }

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.citiesMapSheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.citiesMapSheetBody,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textSoft),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 320,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(-14.2350, -51.9253),
                    initialZoom: 4.0,
                    minZoom: 3,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.movaro.app',
                    ),
                    MarkerLayer(
                      markers: [
                        for (final city in widget.cities)
                          Marker(
                            point: LatLng(city.latitude, city.longitude),
                            width: 44,
                            height: 44,
                            child: _MapCityMarker(
                              selected: city.id == _selectedCity.id,
                              onTap: () {
                                setState(() {
                                  _selectedCity = city;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SelectedCityCard(
              city: _selectedCity,
              onOpen: () => widget.onTapCity(_selectedCity),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: widget.cities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final city = widget.cities[index];
                  return _MapCityListTile(
                    city: city,
                    selected: city.id == _selectedCity.id,
                    onTap: () {
                      setState(() {
                        _selectedCity = city;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCityMarker extends StatelessWidget {
  const _MapCityMarker({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFF16324F),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330071E3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 22),
      ),
    );
  }
}

class _SelectedCityCard extends StatelessWidget {
  const _SelectedCityCard({required this.city, required this.onOpen});

  final City city;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city.name, style: Theme.of(context).textTheme.titleMedium),
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
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onOpen,
            child: Text(context.l10n.citiesMapOpenCityAction),
          ),
        ],
      ),
    );
  }
}

class _MapCityListTile extends StatelessWidget {
  const _MapCityListTile({
    required this.city,
    required this.selected,
    required this.onTap,
  });

  final City city;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.10)
          : AppColors.surfaceMutedFor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.location_city_rounded,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSoftFor(context),
              ),
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
            ],
          ),
        ),
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
    'economica',
    'economico',
    'cheap',
    'budget',
    'custo',
    'cost',
  };

  static const _jobTerms = {
    'trabalho',
    'trabajo',
    'job',
    'jobs',
    'work',
    'empleo',
    'emprego',
  };

  static const _beachTerms = {'praia', 'beach', 'playa', 'coast', 'litoral'};

  bool matches(City city) {
    if (query.isEmpty) {
      return true;
    }
    return score(city) > 0;
  }

  int score(City city) {
    final haystacks = [
      _normalizeSearch(city.name),
      _normalizeSearch(city.stateName),
      _normalizeSearch(city.regionName ?? ''),
      ...city.recommendationReasons.map(_normalizeSearch),
      ...city.topIndustries.map(_normalizeSearch),
    ];

    var score = 0;
    for (final token in tokens) {
      if (haystacks.any((value) => value == token)) {
        score += 12;
        continue;
      }
      if (haystacks.any((value) => value.startsWith(token))) {
        score += 8;
        continue;
      }
      if (haystacks.any((value) => value.contains(token))) {
        score += 4;
      }
    }

    if (tokens.any(_cheapTerms.contains)) {
      score += city.movaroScores.economical;
    }
    if (tokens.any(_jobTerms.contains)) {
      score += city.movaroScores.workOpportunity;
    }
    if (tokens.any(_beachTerms.contains) &&
        CityCoastalProfile.isCoastal(city)) {
      score += 14;
    }

    return score;
  }
}
