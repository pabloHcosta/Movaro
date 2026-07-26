import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:movaro_app/core/widgets/journey_stage_banner.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_work_area_lens.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_arrival_profile_ranker.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_picker_bottom_sheet.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_search_matcher.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class CitiesExplorePage extends StatefulWidget {
  const CitiesExplorePage({
    required this.citiesController,
    this.journeyContextController,
    this.migrationQuestionnaireController,
    this.entryMode = CitiesExploreEntryMode.explore,
    super.key,
  });

  final CitiesController citiesController;
  final JourneyContextController? journeyContextController;
  final MigrationQuestionnaireController? migrationQuestionnaireController;
  final CitiesExploreEntryMode entryMode;

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
  String? _workArea;
  int _visibleCount = _pageSize;
  bool _didTryAutoHelp = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.citiesController.loadExplore();
      widget.citiesController.loadCatalog();
      widget.citiesController.loadMethodology();
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
    final isValidationMode =
        widget.entryMode == CitiesExploreEntryMode.validation;
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
        final isCatalogBootstrapping =
            controller.catalog.isEmpty && controller.catalogError == null;
        // Default surface shows the full catalog — no empty landing. Results
        // are visible whenever there is a query, a filter, a loaded catalog,
        // a catalog still loading, or a catalog error to surface.
        final shouldShowResults =
            hasQuery ||
            _quickFilter != null ||
            controller.catalog.isNotEmpty ||
            isCatalogBootstrapping ||
            controller.catalogError != null;
        final isLoadingResults = hasQuery
            ? controller.isSearching
            : (_quickFilter != null || controller.catalog.isEmpty) &&
                  controller.isLoadingCatalog;
        final resultsError = hasQuery
            ? controller.searchError
            : controller.catalogError;

        final favoriteCities = widget.citiesController.favoriteCities;
        final canDecide =
            favoriteCities.length >= 2 &&
            widget.migrationQuestionnaireController != null;

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
                      title: isValidationMode
                          ? l10n.citiesSearchTitle
                          : l10n.citiesExploreTitle,
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
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? const [Color(0xFF111F31), Color(0xFF0B1625)]
                                : const [Colors.white, Color(0xFFF3F8FF)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : AppColors.primary.withValues(alpha: 0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.22)
                                  : const Color(
                                      0xFF315A8A,
                                    ).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ExplorePanelHeading(
                              icon: isValidationMode
                                  ? Icons.location_searching_rounded
                                  : Icons.travel_explore_rounded,
                              eyebrow: isValidationMode
                                  ? l10n.citiesSearchTitle
                                  : _exploreText(
                                      context,
                                      pt: 'DESCUBRA SEU LUGAR',
                                      es: 'DESCUBRÍ TU LUGAR',
                                      en: 'FIND YOUR PLACE',
                                    ),
                              title: isValidationMode
                                  ? l10n.citiesSearchHeadline
                                  : l10n.citiesExploreHeadline,
                              body: isValidationMode
                                  ? l10n.citiesSearchDescription
                                  : l10n.citiesExploreDescription,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _CitiesSearchField(
                                    controller: _searchController,
                                    hintText: l10n.citiesSearchHint,
                                    labelText: l10n.citiesSearchFieldLabel,
                                    onChanged: _handleSearchChanged,
                                    onSubmitted: (_) =>
                                        _handlePrimarySearchAction(suggestions),
                                    onClear: hasQuery ? _clearSearch : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _CitiesMapCallout(
                                  title: l10n.citiesMapOpenAction,
                                  body: l10n.citiesMapSheetBody,
                                  onTap: () => _openCitiesMapSheet(context),
                                ),
                              ],
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
                            const SizedBox(height: 16),
                            Text(
                              l10n.citiesQuickChoicesTitle,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.textSoftFor(context),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                            const SizedBox(height: 9),
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
                              clearLabel: l10n.citiesQuickFilterAll,
                            ),
                            if (_quickFilter == _CityQuickFilter.work) ...[
                              const SizedBox(height: 12),
                              _WorkAreaRail(
                                areas: CityWorkAreaLens.availableAreas(
                                  widget.citiesController.catalog,
                                ),
                                selectedArea: _workArea,
                                label: l10n.citiesWorkAreaFilterLabel(),
                                labelBuilder: l10n.workAreaLabel,
                                onSelected: _handleWorkAreaSelection,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (isValidationMode) ...[
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: JourneyStageBanner(
                          title: l10n.validateCityBannerTitle(),
                          body: l10n.validateCityBannerBody(),
                          action: l10n.validateCityBannerAction(),
                          icon: Icons.location_searching_rounded,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
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
                              filterLabel: _quickFilter == null
                                  ? null
                                  : _quickFilterLabel(l10n, _quickFilter!),
                              body: (!hasQuery && _quickFilter == null)
                                  ? _exploreText(
                                      context,
                                      pt: '${visibleCities.length} cidades no catálogo para explorar.',
                                      es: '${visibleCities.length} ciudades en el catálogo para explorar.',
                                      en: '${visibleCities.length} cities in the catalog to explore.',
                                    )
                                  : l10n.citiesResultsBody(
                                      visibleCities.length,
                                    ),
                            ),
                            const SizedBox(height: 12),
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
              // Sticky "decide" bar — appears once user has ≥2 favorites
              if (canDecide)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 72,
                  child: _FavoritesDecideBar(
                    favoriteCount: favoriteCities.length,
                    cityNames: favoriteCities.map((c) => c.name).toList(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.migrationQuestionnaire,
                    ),
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
      if (_quickFilter != _CityQuickFilter.work) {
        _workArea = null;
      }
      _visibleCount = _pageSize;
    });

    if (_quickFilter != null && widget.citiesController.catalog.isEmpty) {
      await widget.citiesController.loadCatalog();
    }
  }

  void _handleWorkAreaSelection(String? area) {
    setState(() {
      _workArea = area;
      _visibleCount = _pageSize;
    });
  }

  String _exploreText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        return es;
      case 'en':
        return en;
      default:
        return pt;
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
    final source = controller.catalog.isNotEmpty
        ? List<City>.from(controller.catalog)
        : List<City>.from(controller.searchResults);
    final ranked =
        source
            .map(
              (city) => (
                city: city,
                score:
                    semanticSearch.score(city) +
                    CitySearchMatcher.score(query, city.name, city.stateName),
              ),
            )
            .where((entry) => entry.score > 0)
            .toList()
          ..sort((left, right) => right.score.compareTo(left.score));
    return ranked.map((entry) => entry.city).take(5).toList();
  }

  List<City> _visibleCities(CitiesController controller) {
    final query = _normalizeSearch(_searchController.text);
    final semanticSearch = _CitySemanticSearch(query);
    final source = query.isNotEmpty
        ? List<City>.from(
            controller.catalog.isNotEmpty
                ? controller.catalog
                : controller.searchResults,
          )
        : List<City>.from(controller.catalog);

    if (source.isEmpty) {
      return const [];
    }

    final filtered = _applyQuickFilter(source, semanticSearch);
    if (query.isEmpty) {
      return filtered;
    }

    final ranked =
        filtered
            .map(
              (city) => (
                city: city,
                score:
                    semanticSearch.score(city) +
                    CitySearchMatcher.score(query, city.name, city.stateName),
              ),
            )
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
        return CityWorkAreaLens.applyWorkLens(activeCities, area: _workArea);
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
    Navigator.pushNamed(
      context,
      AppRoutes.cityDetail(city.id),
      arguments: {
        if (widget.entryMode == CitiesExploreEntryMode.validation)
          'validationFlow': true,
      },
    );
  }
}

enum CitiesExploreEntryMode { explore, validation }

class _ExplorePanelHeading extends StatelessWidget {
  const _ExplorePanelHeading({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF168BFF), Color(0xFF15B8FF)],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF168BFF).withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CitiesSearchField extends StatelessWidget {
  const _CitiesSearchField({
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.11)
              : AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: labelText,
          helperText: null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(11),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 19,
                color: AppColors.primary,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 56),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  tooltip: hintText,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onClear?.call();
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
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
            icon: _filterIcon(filter),
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }

  IconData _filterIcon(_CityQuickFilter filter) => switch (filter) {
    _CityQuickFilter.all => Icons.apps_rounded,
    _CityQuickFilter.popular => Icons.local_fire_department_outlined,
    _CityQuickFilter.lowCost => Icons.savings_outlined,
    _CityQuickFilter.work => Icons.work_outline_rounded,
    _CityQuickFilter.language => Icons.translate_rounded,
    _CityQuickFilter.housingEasy => Icons.home_outlined,
    _CityQuickFilter.housingPressure => Icons.trending_up_rounded,
    _CityQuickFilter.softLanding => Icons.flight_land_rounded,
    _CityQuickFilter.familyStability => Icons.family_restroom_rounded,
    _CityQuickFilter.incomeStart => Icons.payments_outlined,
    _CityQuickFilter.coastal => Icons.waves_rounded,
    _CityQuickFilter.metropolis => Icons.apartment_rounded,
    _CityQuickFilter.inland => Icons.nature_people_outlined,
    _CityQuickFilter.border => Icons.swap_horiz_rounded,
  };
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
    return Semantics(
      button: true,
      label: title,
      hint: body,
      child: Tooltip(
        message: title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(17),
            child: Ink(
              width: 64,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _shortLabel(context),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shortLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Mapa',
      'es' => 'Mapa',
      _ => 'Map',
    };
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF168BFF), Color(0xFF15B8FF)],
                  )
                : null,
            color: selected
                ? null
                : AppColors.surfaceMutedFor(context).withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF65C8FF).withValues(alpha: 0.35)
                  : AppColors.borderFor(context),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF168BFF).withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected
                      ? Colors.white
                      : AppColors.textSoftFor(context),
                ),
                const SizedBox(width: 6),
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
  const _ResultsHeader({
    required this.title,
    required this.body,
    this.filterLabel,
  });

  final String title;
  final String body;
  final String? filterLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.view_agenda_outlined,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (filterLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 118),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                filterLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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

/// Horizontal row of work-area (industry) chips for the "Trabalho" jobs lens.
/// Lets the economic-migrant ICP narrow the catalog to "where can I work in my
/// field?". Tapping a selected chip clears the filter.
class _WorkAreaRail extends StatelessWidget {
  const _WorkAreaRail({
    required this.areas,
    required this.selectedArea,
    required this.label,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<String> areas;
  final String? selectedArea;
  final String label;
  final String Function(String area) labelBuilder;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (areas.isEmpty) {
      return const SizedBox.shrink();
    }
    final selected = selectedArea?.toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: areas.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final area = areas[index];
              final isSelected =
                  selected != null && selected == area.toLowerCase();
              return ChoiceChip(
                label: Text(labelBuilder(area)),
                selected: isSelected,
                onSelected: (_) => onSelected(isSelected ? null : area),
              );
            },
          ),
        ),
      ],
    );
  }
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

// ─── Sticky favorites-decide bar ─────────────────────────────────────────────

/// Floats above the nav bar when the user has ≥2 favorites.
/// One tap bridges exploration directly into the decision questionnaire.
class _FavoritesDecideBar extends StatelessWidget {
  const _FavoritesDecideBar({
    required this.favoriteCount,
    required this.cityNames,
    required this.onTap,
  });

  final int favoriteCount;
  final List<String> cityNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = AppColors.isDark(context);

    final namesLabel =
        cityNames.take(2).join(' · ') +
        (cityNames.length > 2 ? ' +${cityNames.length - 2}' : '');

    final label = switch (locale) {
      'pt' => '$namesLabel · Decidir agora',
      'es' => '$namesLabel · Decidir ahora',
      _ => '$namesLabel · Decide now',
    };

    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1D30) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
