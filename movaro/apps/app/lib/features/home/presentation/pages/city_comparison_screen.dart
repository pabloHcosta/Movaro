import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_strength_story_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_search_matcher.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_price_insight_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/location/location_data.dart';

class CityComparisonScreen extends StatefulWidget {
  const CityComparisonScreen({
    required this.initialCities,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final List<City> initialCities;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  State<CityComparisonScreen> createState() => _CityComparisonScreenState();
}

class _CityComparisonScreenState extends State<CityComparisonScreen> {
  static const _helpPreferenceKey = 'city_comparison';
  late int _mode;
  late List<City?> _selectedCities;
  late bool _isComparing;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CopilotExchangeRatesStore _exchangeRatesStore =
      CopilotExchangeRatesStore();
  CopilotExchangeRates? _exchangeRates;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCities.length >= 3 ? 3 : 2;
    _selectedCities = List<City?>.filled(_mode, null, growable: true);
    for (
      var index = 0;
      index < widget.initialCities.length && index < _mode;
      index++
    ) {
      _selectedCities[index] = widget.initialCities[index];
    }
    _isComparing = widget.initialCities.length >= 2;
    unawaited(widget.citiesController.prefetchCatalog());
    unawaited(_loadExchangeRates());
    unawaited(_prefetchComparisonSignals(widget.initialCities));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: AnimatedBuilder(
                  animation: widget.citiesController,
                  builder: (context, _) {
                    return _isComparing
                        ? _buildComparisonState(context)
                        : _buildSelectionState(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadExchangeRates() async {
    final snapshot = await _exchangeRatesStore.read();
    if (!mounted) {
      return;
    }
    setState(() {
      _exchangeRates = snapshot;
    });
  }

  Widget _buildSelectionState(BuildContext context) {
    final selectedCount = _selectedCount;
    final canCompare = selectedCount >= 2;
    final searchQuery = _searchController.text.trim().toLowerCase();
    final results = _filteredResults(searchQuery);
    final suggestions = _quickSuggestions();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pageHorizontalPadding,
        context.pageVerticalPadding,
        context.pageHorizontalPadding,
        context.pageVerticalPadding + 24,
      ),
      children: [
        AppGlassHeader(
          title: context.l10n.cityComparisonTitle,
          onBack: () => Navigator.of(context).pop(),
          trailing: SizedBox(
            width: 96,
            child: TextButton(
              onPressed: canCompare ? _startComparison : null,
              child: Text(context.l10n.cityComparisonCompareAction),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _ModeToggle(mode: _mode, onModeChanged: _changeMode),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var index = 0; index < _mode; index++) ...[
              Expanded(
                child: _SelectedCitySlot(
                  city: _selectedCities[index],
                  onRemove: _selectedCities[index] == null
                      ? null
                      : () => _removeCityAt(index),
                  onAdd: () => _searchFocusNode.requestFocus(),
                ),
              ),
              if (index != _mode - 1) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: context.l10n.cityComparisonSearchPlaceholder,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        if (suggestions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final city in suggestions)
                ActionChip(
                  label: Text(city.name),
                  onPressed: () => _addCity(city),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (results.isNotEmpty)
          FrostedPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final city in results.take(8)) ...[
                  _SearchResultTile(city: city, onTap: () => _addCity(city)),
                  if (city != results.take(8).last)
                    Divider(height: 1, color: AppColors.borderFor(context)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildComparisonState(BuildContext context) {
    final cities = _comparisonCities(context);
    if (cities.length < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isComparing) {
          setState(() => _isComparing = false);
        }
      });
      return _buildSelectionState(context);
    }
    final winner = _winner(cities);
    final compact = cities.length >= 3;
    final scoredMetricCount = _scoredMetricDefinitions.length;
    final lens = _resolveComparisonLens();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.pageHorizontalPadding,
              context.pageVerticalPadding,
              context.pageHorizontalPadding,
              0,
            ),
            child: AppGlassHeader(
              title: context.l10n.cityComparisonTitle,
              onBack: () => Navigator.of(context).pop(),
              onHelp: _showHelp,
              trailing: IconButton(
                onPressed: () => setState(() => _isComparing = false),
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.cityComparisonEditAction,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.pageHorizontalPadding,
              18,
              context.pageHorizontalPadding,
              0,
            ),
            child: const SizedBox(height: 0),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _ComparisonHeaderDelegate(
            minExtentValue: compact ? 188 : 204,
            maxExtentValue: compact ? 188 : 204,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.pageHorizontalPadding,
              ),
              child: _ComparisonHeader(
                cities: cities,
                winner: winner,
                compact: compact,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.pageHorizontalPadding,
              12,
              context.pageHorizontalPadding,
              24,
            ),
            child: Column(
              children: [
                _ComparisonIntelligencePanel(
                  cities: cities,
                  winner: winner,
                  lens: lens,
                ),
                if (cities.any((city) => city.hasBudgetSnapshot)) ...[
                  const SizedBox(height: 16),
                ],
                _WinnerBanner(winner: winner, totalMetrics: scoredMetricCount),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _startPlanWithWinner(winner.city),
                  child: Text(
                    context.l10n.cityComparisonStartPlanAction(
                      winner.city.name,
                    ),
                  ),
                ),
                if (cities.length == 2) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.cityDetail(
                        cities
                            .firstWhere(
                              (item) => item.city.id != winner.city.id,
                            )
                            .city
                            .id,
                      ),
                    ),
                    child: Text(
                      context.l10n.cityComparisonOtherDetailsAction(
                        cities
                            .firstWhere(
                              (item) => item.city.id != winner.city.id,
                            )
                            .city
                            .name,
                      ),
                    ),
                  ),
                ],
                if (cities.any((city) => city.hasBudgetSnapshot)) ...[
                  const SizedBox(height: 16),
                  _CostFitOverviewPanel(cities: cities),
                ],
                const SizedBox(height: 16),
                _ArrivalDecisionPanel(cities: cities),
                const SizedBox(height: 16),
                _StabilityDecisionPanel(cities: cities),
                const SizedBox(height: 16),
                for (final city in cities) ...[
                  _CityTradeoffPanel(
                    city: city,
                    winnerId: winner.city.id,
                    allCities: cities,
                    lens: lens,
                  ),
                  const SizedBox(height: 16),
                ],
                for (final group in _metricGroups(context)) ...[
                  _MetricSection(
                    title: group.title,
                    cities: cities,
                    metrics: group.metrics,
                    compact: compact,
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int get _selectedCount =>
      _selectedCities.where((city) => city != null).length;

  void _changeMode(int nextMode) {
    setState(() {
      _mode = nextMode;
      if (_selectedCities.length > nextMode) {
        _selectedCities = _selectedCities.take(nextMode).toList(growable: true);
      } else {
        while (_selectedCities.length < nextMode) {
          _selectedCities.add(null);
        }
      }
    });
  }

  void _removeCityAt(int index) {
    setState(() {
      _selectedCities[index] = null;
      _isComparing = false;
    });
  }

  void _addCity(City city) {
    final currentIds = _selectedCities.whereType<City>().map((item) => item.id);
    if (currentIds.contains(city.id)) {
      return;
    }
    final emptyIndex = _selectedCities.indexWhere((item) => item == null);
    if (emptyIndex == -1) {
      return;
    }
    setState(() {
      _selectedCities[emptyIndex] = city;
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
    unawaited(_prefetchComparisonSignals([city]));
  }

  void _startComparison() {
    if (_selectedCount < 2) {
      return;
    }
    unawaited(_prefetchComparisonSignals(_selectedCities.whereType<City>()));
    setState(() => _isComparing = true);
  }

  Future<void> _prefetchComparisonSignals(Iterable<City> cities) async {
    final cityList = cities.toList(growable: false);
    if (cityList.isEmpty) {
      return;
    }

    final detectedLocation = widget
        .migrationQuestionnaireController
        .journeyContextController
        .detectedLocation;
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final originCountryIso = FlightRouteContextResolver.resolveOriginCountryIso(
      savedCountryCode: detectedLocation?.countryId,
      planOriginCountry: plan?.originCountry,
    );
    final originAirport = FlightRouteContextResolver.resolveOriginAirport(
      savedLocation: detectedLocation == null
          ? null
          : LocationData(
              cityName: detectedLocation.city ?? '',
              stateName: detectedLocation.region ?? '',
              countryName: detectedLocation.countryName,
              countryCode: detectedLocation.countryId ?? '',
              latitude: detectedLocation.latitude ?? 0,
              longitude: detectedLocation.longitude ?? 0,
            ),
      originCountryIso: originCountryIso,
    );

    final requests = <Future<Object?>>[];
    for (final city in cityList) {
      requests.add(widget.citiesController.loadWeatherForCity(city.id));
      final destinationAirport = FlightRouteContextResolver.resolveDestinationAirport(
        destinationCityName: city.name,
        destinationCountryIso: FlightRouteContextResolver.resolveDestinationCountryIso(
          cityCountryCode: city.countryCode,
          planDestinationCountry: plan?.destinationCountry,
        ),
        destinationLatitude: city.latitude,
        destinationLongitude: city.longitude,
      );
      if (originAirport?.iataCode != null && destinationAirport?.iataCode != null) {
        requests.add(
          widget.citiesController.loadTravelInsightForCity(
            city.id,
            originIata: originAirport?.iataCode,
            destIata: destinationAirport?.iataCode,
          ),
        );
      }
    }

    await Future.wait(requests);
  }

  List<City> _filteredResults(String query) {
    final selectedIds = _selectedCities
        .whereType<City>()
        .map((city) => city.id)
        .toSet();
    final catalog = widget.citiesController.catalog;
    if (query.isEmpty) {
      return const [];
    }
    final scored = catalog
        .where((city) => !selectedIds.contains(city.id))
        .map((city) => (city: city, score: CitySearchMatcher.score(query, city.name, city.stateName)))
        .where((entry) => entry.score > 0)
        .toList(growable: false)
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return a.city.name.compareTo(b.city.name);
      });

    return scored
        .map((entry) => entry.city)
        .take(12)
        .toList(growable: false);
  }

  List<City> _quickSuggestions() {
    final selectedIds = _selectedCities
        .whereType<City>()
        .map((city) => city.id)
        .toSet();
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final candidates = <City>[
      if (plan?.recommendedCity != null) plan!.recommendedCity!,
      ...?plan?.candidateCities,
    ];
    final unique = <String, City>{};
    for (final city in candidates) {
      if (!selectedIds.contains(city.id)) {
        unique[city.id] = city;
      }
    }
    return unique.values.take(5).toList(growable: false);
  }

  List<_ComparisonCityData> _comparisonCities(BuildContext context) {
    final preferredCountryId = _preferredCurrencyCountryId;
    final detectedLocation = widget
        .migrationQuestionnaireController
        .journeyContextController
        .detectedLocation;
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final originCountryIso = FlightRouteContextResolver.resolveOriginCountryIso(
      savedCountryCode: detectedLocation?.countryId,
      planOriginCountry: plan?.originCountry,
    );
    final originAirport = FlightRouteContextResolver.resolveOriginAirport(
      savedLocation: detectedLocation == null
          ? null
          : LocationData(
              cityName: detectedLocation.city ?? '',
              stateName: detectedLocation.region ?? '',
              countryName: detectedLocation.countryName,
              countryCode: detectedLocation.countryId ?? '',
              latitude: detectedLocation.latitude ?? 0,
              longitude: detectedLocation.longitude ?? 0,
            ),
      originCountryIso: originCountryIso,
    );
    final lens = _resolveComparisonLens();
    return _selectedCities
        .whereType<City>()
        .map(
          (city) {
            final destinationAirport = FlightRouteContextResolver.resolveDestinationAirport(
              destinationCityName: city.name,
              destinationCountryIso: FlightRouteContextResolver.resolveDestinationCountryIso(
                cityCountryCode: city.countryCode,
                planDestinationCountry: plan?.destinationCountry,
              ),
              destinationLatitude: city.latitude,
              destinationLongitude: city.longitude,
            );
            return _ComparisonCityData.fromCity(
              context,
              city,
              widget.citiesController.weatherFor(city.id),
              exchangeRates: _exchangeRates,
              preferredCountryId: preferredCountryId,
              detectedLocation: detectedLocation,
              originAirportIata: originAirport?.iataCode,
              routeInsight: originAirport?.iataCode == null
                  ? null
                  : widget.citiesController.travelInsightFor(
                      city.id,
                      originIata: originAirport?.iataCode,
                      destIata: destinationAirport?.iataCode,
                    ),
              lens: lens,
            );
          },
        )
        .toList(growable: false);
  }

  String? get _preferredCurrencyCountryId {
    final journeyOrigin = widget
        .migrationQuestionnaireController
        .journeyContextController
        .originCountryId;
    if (journeyOrigin != null && journeyOrigin.isNotEmpty) {
      return journeyOrigin;
    }
    final detectedCountry = widget
        .migrationQuestionnaireController
        .journeyContextController
        .detectedLocation
        ?.countryId;
    if (detectedCountry != null && detectedCountry.isNotEmpty) {
      return detectedCountry;
    }
    return widget.migrationQuestionnaireController.generatedPlan?.originCountry;
  }

  _CityWinner _winner(List<_ComparisonCityData> cities) {
    final scored = {
      for (final city in cities) city.city.id: _calculateScore(city, cities),
    };
    final sorted = cities.toList()
      ..sort(
        (a, b) => (scored[b.city.id] ?? 0).compareTo(scored[a.city.id] ?? 0),
      );
    final winner = sorted.first;
    return _CityWinner(city: winner.city, score: scored[winner.city.id] ?? 0);
  }

  int _calculateScore(
    _ComparisonCityData city,
    List<_ComparisonCityData> allCities,
  ) {
    final lens = _resolveComparisonLens();
    final score = switch (lens) {
      _ComparisonLens.softLanding =>
        (city.arrivalEaseScore * 0.34) +
            (city.languageScore * 0.20) +
            (city.safetyLevelScore * 0.18) +
            (city.costScore * 0.14) +
            (city.flightAccessScore * 0.14),
      _ComparisonLens.familyStability =>
        (city.safetyLevelScore * 0.28) +
            (city.hdiScore * 100 * 0.22) +
            (city.arrivalEaseScore * 0.18) +
            (city.languageScore * 0.14) +
            (city.costScore * 0.10) +
            (city.jobStabilityScore * 0.08),
      _ComparisonLens.incomeStart =>
        (city.jobMarketScore * 0.28) +
            (city.jobStabilityScore * 0.22) +
            (city.salaryFitScore * 0.18) +
            (city.economicActivityScore * 0.12) +
            (city.arrivalEaseScore * 0.10) +
            (city.flightAccessScore * 0.05) +
            (city.communityScore * 0.05),
      _ComparisonLens.balanced =>
        (city.arrivalEaseScore * 0.22) +
            (city.jobMarketScore * 0.18) +
            (city.safetyLevelScore * 0.18) +
            (city.languageScore * 0.14) +
            (city.costScore * 0.14) +
            (city.flightAccessScore * 0.14),
    };
    return score.round();
  }

  _ComparisonLens _resolveComparisonLens() {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    if (plan?.travelGroup == 'family_kids' || plan?.travelGroup == 'solo_parent') {
      return _ComparisonLens.familyStability;
    }
    if (plan?.goal == 'work' ||
        plan?.goal == 'find_job_br' ||
        plan?.goal == 'entrepreneur' ||
        plan?.selectedPriorities.contains('job_opportunities') == true) {
      return _ComparisonLens.incomeStart;
    }
    if (plan?.selectedPriorities.contains('low_cost') == true ||
        plan?.selectedPriorities.contains('community') == true) {
      return _ComparisonLens.softLanding;
    }
    return _ComparisonLens.balanced;
  }

  Future<void> _startPlanWithWinner(City city) async {
    final controller = widget.migrationQuestionnaireController;
    if (controller.generatedPlan != null) {
      await controller.confirmPlanCity(city);
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot);
      return;
    }

    if (!mounted) {
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.cityDetail(city.id),
      arguments: {'selectForPlan': true},
    );
  }

  Future<void> _showHelp() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: ContextualHelpContent(
        eyebrow: context.l10n.cityComparisonTitle,
        contextIcon: Icons.compare_arrows_rounded,
        title: context.l10n.cityComparisonGuideTitle(),
        body: context.l10n.cityComparisonGuideBody(),
        steps: [
          FeatureGuideStep(
            number: '1',
            title: context.l10n.cityComparisonGuideStepOneTitle(),
            body: context.l10n.cityComparisonGuideStepOneBody(),
          ),
          FeatureGuideStep(
            number: '2',
            title: context.l10n.cityComparisonGuideStepTwoTitle(),
            body: context.l10n.cityComparisonGuideStepTwoBody(),
          ),
          FeatureGuideStep(
            number: '3',
            title: context.l10n.cityComparisonGuideStepThreeTitle(),
            body: context.l10n.cityComparisonGuideStepThreeBody(),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onModeChanged});

  final int mode;
  final ValueChanged<int> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: context.l10n.cityComparisonModeTwo,
            selected: mode == 2,
            onTap: () => onModeChanged(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeButton(
            label: context.l10n.cityComparisonModeThree,
            selected: mode == 3,
            onTap: () => onModeChanged(3),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.22)
                : AppColors.borderFor(context),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected
                ? AppColors.primary
                : AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SelectedCitySlot extends StatelessWidget {
  const _SelectedCitySlot({
    required this.city,
    required this.onAdd,
    this.onRemove,
  });

  final City? city;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (city == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAdd,
        child: CustomPaint(
          painter: _DashedPainter(color: AppColors.borderFor(context)),
          child: SizedBox(
            height: 94,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: AppColors.textSoftFor(context)),
                const SizedBox(height: 4),
                Text(
                  context.l10n.cityComparisonAddAction,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 94,
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 44,
                    height: 32,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CityResolvedImage(
                          city: city!,
                          fit: BoxFit.cover,
                          placeholder: const SkeletonBox(height: 32),
                          errorWidget: const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFF17345D)),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.38),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        city!.stateCode,
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
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.location_city_outlined,
          color: AppColors.primary,
        ),
      ),
      title: Text(city.name),
      subtitle: Text('${city.stateName} (${city.stateCode})'),
      trailing: const Icon(Icons.add_rounded),
    );
  }
}

class _ComparisonHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ComparisonHeaderDelegate({
    required this.minExtentValue,
    required this.maxExtentValue,
    required this.child,
  });

  final double minExtentValue;
  final double maxExtentValue;
  final Widget child;

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox.expand(
        child: Padding(padding: const EdgeInsets.only(bottom: 8), child: child),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ComparisonHeaderDelegate oldDelegate) {
    return oldDelegate.minExtentValue != minExtentValue ||
        oldDelegate.maxExtentValue != maxExtentValue ||
        oldDelegate.child != child;
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({
    required this.cities,
    required this.winner,
    required this.compact,
  });

  final List<_ComparisonCityData> cities;
  final _CityWinner winner;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelWidth = compact ? 72.0 : 80.0;
    final gap = compact ? 8.0 : 10.0;

    return FrostedPanel(
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label ─────────────────────────────────────────────
          Row(
            children: [
              Text(
                context.l10n.cityComparisonHeaderLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.1,
                  color: AppColors.textSoftFor(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 10),
                  color: scheme.outlineVariant.withValues(alpha: 0.30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── City columns ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacer aligning with metric label column below
              SizedBox(width: labelWidth),
              SizedBox(width: gap),
              for (final city in cities) ...[
                Expanded(
                  child: _CityHeaderColumn(
                    city: city,
                    isWinner: city.city.id == winner.city.id,
                    compact: compact,
                  ),
                ),
                if (city != cities.last) SizedBox(width: gap),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CityHeaderColumn extends StatelessWidget {
  const _CityHeaderColumn({
    required this.city,
    required this.isWinner,
    required this.compact,
  });

  final _ComparisonCityData city;
  final bool isWinner;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final scheme = Theme.of(context).colorScheme;

    // Compute a composite score 0–100 for the bar
    final composite = ((city.city.rentScore +
                city.city.movaroScores.languageAdaptation +
                city.city.safetyScore +
                city.city.costOfLivingScore) /
            4)
        .clamp(0, 100)
        .toDouble();

    final initials = city.city.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    final cardBg = isWinner
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              const Color(0xFF0055EE),
            ],
          )
        : null;

    final cardColor = isWinner
        ? null
        : (isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.72)
            : scheme.surfaceContainerLow);

    final onCard = isWinner ? Colors.white : scheme.onSurface;
    final onCardMuted = isWinner
        ? Colors.white.withValues(alpha: 0.65)
        : AppColors.textSoftFor(context);

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        gradient: cardBg,
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner
              ? AppColors.primary.withValues(alpha: 0.0)
              : scheme.outlineVariant.withValues(alpha: 0.40),
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Initials avatar ────────────────────────────────────────
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: BoxDecoration(
              color: isWinner
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: isWinner ? Colors.white : AppColors.primary,
                  letterSpacing: 0.5,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 10),

          // ── City name ──────────────────────────────────────────────
          Text(
            city.city.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _nameFontSize(city.city.name),
              fontWeight: FontWeight.w800,
              color: onCard,
              height: 1.15,
            ),
          ),
          SizedBox(height: compact ? 4 : 5),

          // ── State · code ───────────────────────────────────────────
          Text(
            '${city.city.stateCode} · ${city.cityCode}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 8 : 8.5,
              color: onCardMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: compact ? 10 : 12),

          // ── Score bar ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: composite / 100,
              minHeight: 4,
              backgroundColor: isWinner
                  ? Colors.white.withValues(alpha: 0.20)
                  : scheme.outlineVariant.withValues(alpha: 0.30),
              valueColor: AlwaysStoppedAnimation<Color>(
                isWinner
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
          SizedBox(height: compact ? 4 : 5),

          // ── Score label ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.l10n.cityComparisonTopBadge,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                '${composite.round()}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: onCardMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _nameFontSize(String name) {
    if (name.length >= 18) return compact ? 8.5 : 9.5;
    if (name.length >= 12) return compact ? 9.0 : 10.0;
    return compact ? 10.0 : 11.0;
  }
}

class _MetricSectionGroup {
  const _MetricSectionGroup({required this.title, required this.metrics});

  final String title;
  final List<_MetricDefinition> metrics;
}

List<_MetricSectionGroup> _metricGroups(BuildContext context) => [
  _MetricSectionGroup(
    title: _localizedText(
      context,
      pt: 'Métricas de apoio',
      es: 'Métricas de apoyo',
      en: 'Supporting metrics',
    ),
    metrics: const [
      _MetricDefinition.salaryCoverage,
      _MetricDefinition.safety,
      _MetricDefinition.language,
      _MetricDefinition.jobStability,
    ],
  ),
];

class _MetricSection extends StatelessWidget {
  const _MetricSection({
    required this.title,
    required this.cities,
    required this.metrics,
    required this.compact,
  });

  final String title;
  final List<_ComparisonCityData> cities;
  final List<_MetricDefinition> metrics;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedPanel(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ───────────────────────────────────────────
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textSoftFor(context),
                  fontSize: 9,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 10),
                  color: scheme.outlineVariant.withValues(alpha: 0.30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < metrics.length; i++) ...[
            _MetricRow(
              metric: metrics[i],
              cities: cities,
              compact: compact,
              isEven: i.isEven,
            ),
            if (i < metrics.length - 1)
              Divider(
                height: compact ? 10 : 12,
                color: scheme.outlineVariant.withValues(alpha: 0.20),
              ),
          ],
        ],
      ),
    );
  }
}

// Maps metric keys to icons for scannability
IconData _metricIcon(String key) => switch (key) {
  'salary_coverage' => Icons.account_balance_wallet_outlined,
  'safety' => Icons.shield_outlined,
  'language' => Icons.translate_rounded,
  'job_stability' => Icons.work_outline_rounded,
  'salary' => Icons.payments_outlined,
  'rent' => Icons.home_outlined,
  'food' => Icons.restaurant_outlined,
  'transport' => Icons.directions_bus_outlined,
  'hdi' => Icons.bar_chart_rounded,
  'job' => Icons.business_center_outlined,
  'community' => Icons.people_outline_rounded,
  'cost' => Icons.receipt_long_outlined,
  'distance' => Icons.straighten_rounded,
  'size' => Icons.location_city_outlined,
  'flight' => Icons.flight_takeoff_rounded,
  'arrival' => Icons.flag_outlined,
  _ => Icons.data_usage_rounded,
};

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.cities,
    required this.compact,
    this.isEven = false,
  });

  final _MetricDefinition metric;
  final List<_ComparisonCityData> cities;
  final bool compact;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final winners = metric.bestCityIds(cities);
    final losers = metric.worstCityIds(cities);
    final labelWidth = compact ? 72.0 : 80.0;
    final gap = compact ? 8.0 : 10.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Metric label ─────────────────────────────────────────────
        SizedBox(
          width: labelWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  _metricIcon(metric.key),
                  size: 13,
                  color: AppColors.textSoftFor(context),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  metric.label(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 10 : 11,
                    color: AppColors.textSoftFor(context),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: gap),
        // ── Value cells ───────────────────────────────────────────────
        for (final city in cities) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final state = metric.cellStateFor(
                  cityId: city.city.id,
                  winners: winners,
                  losers: losers,
                );
                final colors =
                    metric.semanticColors(context, city) ??
                    _MetricCellColors.resolve(context, state);
                final value = metric.displayValue(context, city);
                final isBest = state == _MetricCellState.best;
                final isWorst = state == _MetricCellState.worst;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 7,
                    vertical: compact ? 8 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.border,
                      width: isBest ? 1.2 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBest || isWorst) ...[
                        Icon(
                          isBest
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 9,
                          color: colors.text,
                        ),
                        const SizedBox(width: 2),
                      ],
                      Flexible(
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 10 : 10.5,
                            fontWeight: isBest ? FontWeight.w800 : FontWeight.w700,
                            color: colors.text,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (city != cities.last) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _WinnerBanner extends StatelessWidget {
  const _WinnerBanner({required this.winner, required this.totalMetrics});

  final _CityWinner winner;
  final int totalMetrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.star_rounded, color: AppColors.success),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cityComparisonWinnerLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  winner.city.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${winner.score}/$totalMetrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CityWinner {
  const _CityWinner({required this.city, required this.score});

  final City city;
  final int score;
}

enum _ComparisonLens { balanced, softLanding, familyStability, incomeStart }

String _localizedText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };
}

class _ComparisonIntelligencePanel extends StatelessWidget {
  const _ComparisonIntelligencePanel({
    required this.cities,
    required this.winner,
    required this.lens,
  });

  final List<_ComparisonCityData> cities;
  final _CityWinner winner;
  final _ComparisonLens lens;

  @override
  Widget build(BuildContext context) {
    final winnerData = cities.firstWhere((city) => city.city.id == winner.city.id);
    final topStrengths = _topStrengths(context, winnerData);
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lensTitle(context, lens),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _lensBody(context, lens, winner.city.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topStrengths
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _lensTitle(BuildContext context, _ComparisonLens lens) {
    return switch (lens) {
      _ComparisonLens.softLanding => _localizedText(
        context,
        pt: 'Comparação focada em chegada leve',
        es: 'Comparación enfocada en una llegada liviana',
        en: 'Comparison focused on an easier landing',
      ),
      _ComparisonLens.familyStability => _localizedText(
        context,
        pt: 'Comparação focada em estabilidade para família',
        es: 'Comparación enfocada en estabilidad familiar',
        en: 'Comparison focused on family stability',
      ),
      _ComparisonLens.incomeStart => _localizedText(
        context,
        pt: 'Comparação focada em renda e trabalho',
        es: 'Comparación enfocada en ingresos y trabajo',
        en: 'Comparison focused on income and work',
      ),
      _ComparisonLens.balanced => _localizedText(
        context,
        pt: 'Comparação focada no melhor equilíbrio',
        es: 'Comparación enfocada en el mejor equilibrio',
        en: 'Comparison focused on the best balance',
      ),
    };
  }

  String _lensBody(BuildContext context, _ComparisonLens lens, String winnerName) {
    return switch (lens) {
      _ComparisonLens.softLanding => _localizedText(
        context,
        pt: '$winnerName ganhou porque combina entrada mais leve, menor atrito com português e chegada menos pesada.',
        es: '$winnerName ganó porque combina una llegada más liviana, menos fricción con el portugués y un arranque menos pesado.',
        en: '$winnerName wins because it combines an easier landing, less Portuguese friction, and a lighter start.',
      ),
      _ComparisonLens.familyStability => _localizedText(
        context,
        pt: '$winnerName ganhou porque entrega combinação melhor de segurança, estabilidade e qualidade de vida para rotina familiar.',
        es: '$winnerName ganó porque ofrece mejor combinación de seguridad, estabilidad y calidad de vida para una rutina familiar.',
        en: '$winnerName wins because it offers a better mix of safety, stability, and quality of life for family routines.',
      ),
      _ComparisonLens.incomeStart => _localizedText(
        context,
        pt: '$winnerName ganhou porque junta mercado mais forte, trabalho menos sazonal e melhor chegada para começar a gerar renda.',
        es: '$winnerName ganó porque combina un mercado más fuerte, trabajo menos estacional y una mejor llegada para empezar a generar ingresos.',
        en: '$winnerName wins because it combines a stronger market, less seasonal work, and a better setup to start earning.',
      ),
      _ComparisonLens.balanced => _localizedText(
        context,
        pt: '$winnerName ganhou no equilíbrio geral entre chegada, segurança, custo e potencial de trabalho.',
        es: '$winnerName ganó en equilibrio general entre llegada, seguridad, costo y potencial laboral.',
        en: '$winnerName wins on overall balance across arrival, safety, cost, and work potential.',
      ),
    };
  }

  List<String> _topStrengths(BuildContext context, _ComparisonCityData city) {
    return [
      city.arrivalEaseLabel,
      city.jobStabilityLabel,
      if (city.hasBudgetSnapshot) city.salaryCoverageLabel,
      city.languageLabel,
      city.flightPressureLabel == '—'
          ? _localizedText(context, pt: 'rota aérea sem leitura', es: 'ruta aérea sin lectura', en: 'no flight read')
          : '${_localizedText(context, pt: 'passagem', es: 'vuelo', en: 'flight')}: ${city.flightPressureLabel.toLowerCase()}',
    ];
  }
}

class _CostFitOverviewPanel extends StatelessWidget {
  const _CostFitOverviewPanel({required this.cities});

  final List<_ComparisonCityData> cities;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'Salário x custo real',
              es: 'Salario vs costo real',
              en: 'Salary vs real cost',
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _localizedText(
              context,
              pt: 'Quanto o salário líquido médio da cidade cobre do custo base de viver ali. Toque no valor para ver em BRL, USD ou sua moeda.',
              es: 'Cuánto cubre el salario neto medio de la ciudad del costo base de vivir allí. Tocá el valor para verlo en BRL, USD o tu moneda.',
              en: 'How much the city average net salary covers the base cost of living there. Tap values to view them in BRL, USD, or your currency.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          for (final city in cities.where((item) => item.hasBudgetSnapshot)) ...[
            _CostFitCityRow(city: city),
            if (city != cities.where((item) => item.hasBudgetSnapshot).last)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ArrivalDecisionPanel extends StatelessWidget {
  const _ArrivalDecisionPanel({required this.cities});

  final List<_ComparisonCityData> cities;

  @override
  Widget build(BuildContext context) {
    final nearestDistance = cities
        .where((city) => city.distanceKm != null)
        .map((city) => city.distanceKm!)
        .fold<int?>(null, (best, value) => best == null || value < best ? value : best);

    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'Chegada e deslocamento',
              es: 'Llegada y desplazamiento',
              en: 'Arrival and distance',
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _localizedText(
              context,
              pt: 'Leitura rápida de entrada, distância e peso da passagem para você bater o olho e entender qual cidade exige menos esforço para começar.',
              es: 'Lectura rápida de entrada, distancia y peso del vuelo para entender qué ciudad exige menos esfuerzo para empezar.',
              en: 'Quick read of arrival ease, distance, and flight burden so you can see which city is easier to start in.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              final itemWidth = wide
                  ? (constraints.maxWidth - ((cities.length - 1) * 12)) / cities.length
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final city in cities)
                    SizedBox(
                      width: itemWidth,
                      child: _VisualDecisionCard(
                        title: city.city.name,
                        accent: city.arrivalEaseScore >= 72
                            ? AppColors.success
                            : city.arrivalEaseScore >= 58
                            ? AppColors.warning
                            : AppColors.danger,
                        summary: city.arrivalEaseLabel,
                        bullets: [
                          if (city.distanceKm != null && nearestDistance != null)
                            city.distanceKm == nearestDistance
                                ? _localizedText(
                                    context,
                                    pt: 'mais próxima do seu ponto de partida',
                                    es: 'más cercana a tu punto de partida',
                                    en: 'closest to your starting point',
                                  )
                                : city.distanceLabel,
                          '${_localizedText(context, pt: 'passagem', es: 'vuelo', en: 'flight')}: ${city.flightPressureLabel.toLowerCase()}',
                          _localizedText(
                            context,
                            pt: 'entrada: ${city.arrivalEaseLabel.toLowerCase()}',
                            es: 'entrada: ${city.arrivalEaseLabel.toLowerCase()}',
                            en: 'arrival: ${city.arrivalEaseLabel.toLowerCase()}',
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StabilityDecisionPanel extends StatelessWidget {
  const _StabilityDecisionPanel({required this.cities});

  final List<_ComparisonCityData> cities;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'Rotina, idioma e trabalho',
              es: 'Rutina, idioma y trabajo',
              en: 'Routine, language, and work',
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _localizedText(
              context,
              pt: 'Em vez de comparar linha por linha, aqui você vê o encaixe da cidade para segurança, adaptação e estabilidade de trabalho.',
              es: 'En vez de comparar línea por línea, aquí ves el encaje de la ciudad para seguridad, adaptación y estabilidad laboral.',
              en: 'Instead of comparing line by line, here you see the city fit for safety, adaptation, and work stability.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              final itemWidth = wide
                  ? (constraints.maxWidth - ((cities.length - 1) * 12)) / cities.length
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final city in cities)
                    SizedBox(
                      width: itemWidth,
                      child: _VisualDecisionCard(
                        title: city.city.name,
                        accent: city.jobStabilityScore >= 72
                            ? AppColors.success
                            : city.jobStabilityScore >= 55
                            ? AppColors.warning
                            : AppColors.danger,
                        summary: _localizedText(
                          context,
                          pt: '${city.jobStabilityLabel} · ${city.safetyLabel} · ${city.languageLabel}',
                          es: '${city.jobStabilityLabel} · ${city.safetyLabel} · ${city.languageLabel}',
                          en: '${city.jobStabilityLabel} · ${city.safetyLabel} · ${city.languageLabel}',
                        ),
                        bullets: [
                          _localizedText(
                            context,
                            pt: 'segurança: ${city.safetyLabel.toLowerCase()}',
                            es: 'seguridad: ${city.safetyLabel.toLowerCase()}',
                            en: 'safety: ${city.safetyLabel.toLowerCase()}',
                          ),
                          _localizedText(
                            context,
                            pt: 'português: ${city.languageLabel.toLowerCase()}',
                            es: 'portugués: ${city.languageLabel.toLowerCase()}',
                            en: 'portuguese: ${city.languageLabel.toLowerCase()}',
                          ),
                          _localizedText(
                            context,
                            pt: 'trabalho: ${city.jobStabilityLabel.toLowerCase()}',
                            es: 'trabajo: ${city.jobStabilityLabel.toLowerCase()}',
                            en: 'work: ${city.jobStabilityLabel.toLowerCase()}',
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VisualDecisionCard extends StatelessWidget {
  const _VisualDecisionCard({
    required this.title,
    required this.accent,
    required this.summary,
    required this.bullets,
  });

  final String title;
  final Color accent;
  final String summary;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (final bullet in bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 7, color: accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bullet,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            if (bullet != bullets.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _CostFitCityRow extends StatelessWidget {
  const _CostFitCityRow({required this.city});

  final _ComparisonCityData city;

  @override
  Widget build(BuildContext context) {
    final ratio = (city.salaryFitScore / 100).clamp(0.0, 1.0);
    final progressColor = city.salaryFitScore >= 80
        ? AppColors.success
        : city.salaryFitScore >= 55
        ? AppColors.warning
        : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  city.city.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  city.salaryCoverageLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _VisualMoneyCard(
                  label: _localizedText(
                    context,
                    pt: 'Salário líquido',
                    es: 'Salario neto',
                    en: 'Net salary',
                  ),
                  amountInBrl: city.averageNetSalaryBrl,
                  exchangeRates: city.exchangeRates,
                  preferredCountryId: city.preferredCountryId,
                  accent: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VisualMoneyCard(
                  label: _localizedText(
                    context,
                    pt: 'Custo base',
                    es: 'Costo base',
                    en: 'Base cost',
                  ),
                  amountInBrl: city.baseLivingCostBrl,
                  exchangeRates: city.exchangeRates,
                  preferredCountryId: city.preferredCountryId,
                  accent: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.borderFor(context),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            city.salaryBalanceLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualMoneyCard extends StatelessWidget {
  const _VisualMoneyCard({
    required this.label,
    required this.amountInBrl,
    required this.exchangeRates,
    required this.preferredCountryId,
    required this.accent,
  });

  final String label;
  final int amountInBrl;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          MultiCurrencyAmount(
            amountInBrl: amountInBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _CityTradeoffPanel extends StatelessWidget {
  const _CityTradeoffPanel({
    required this.city,
    required this.winnerId,
    required this.allCities,
    required this.lens,
  });

  final _ComparisonCityData city;
  final String winnerId;
  final List<_ComparisonCityData> allCities;
  final _ComparisonLens lens;

  @override
  Widget build(BuildContext context) {
    final gains = _gains(context);
    final watchouts = _watchouts(context);
    final tradeoff = _tradeoff(context);
    final isWinner = city.city.id == winnerId;

    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  city.city.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    _localizedText(
                      context,
                      pt: 'Melhor encaixe agora',
                      es: 'Mejor encaje ahora',
                      en: 'Best fit now',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _InsightRow(
            icon: Icons.add_circle_outline_rounded,
            color: AppColors.success,
            title: _localizedText(
              context,
              pt: 'Você ganha',
              es: 'Lo que ganas',
              en: 'What you gain',
            ),
            body: gains,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            title: _localizedText(
              context,
              pt: 'Pedem atenção',
              es: 'Piden atención',
              en: 'Needs attention',
            ),
            body: watchouts,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.compare_arrows_rounded,
            color: AppColors.primary,
            title: _localizedText(
              context,
              pt: 'Trade-off real',
              es: 'Trade-off real',
              en: 'Real trade-off',
            ),
            body: tradeoff,
          ),
        ],
      ),
    );
  }

  String _gains(BuildContext context) {
    final strengths = CityStrengthStoryService.strongest(context, city.city);
    if (strengths.isNotEmpty) {
      return strengths.take(2).map((item) => item.title).join(', ');
    }
    final parts = <String>[];
    if (city.arrivalEaseScore >= 72) {
      parts.add(_localizedText(
        context,
        pt: 'chegada mais leve',
        es: 'llegada más liviana',
        en: 'lighter arrival',
      ));
    }
    if (city.jobMarketScore >= 72) {
      parts.add(_localizedText(
        context,
        pt: 'mercado mais forte',
        es: 'mercado más fuerte',
        en: 'stronger job market',
      ));
    }
    if (city.hasBudgetSnapshot && city.salaryFitScore >= 68) {
      parts.add(_localizedText(
        context,
        pt: 'salário médio cobre melhor o custo',
        es: 'el salario medio cubre mejor el costo',
        en: 'average salary covers the cost better',
      ));
    }
    if (city.safetyLevelScore >= 68) {
      parts.add(_localizedText(
        context,
        pt: 'segurança melhor',
        es: 'mejor seguridad',
        en: 'better safety',
      ));
    }
    if (city.languageScore >= 68) {
      parts.add(_localizedText(
        context,
        pt: 'adaptação mais fácil',
        es: 'adaptación más fácil',
        en: 'easier adaptation',
      ));
    }
    if (parts.isEmpty) {
      return _localizedText(
        context,
        pt: 'ganho mais equilibrado, sem um único destaque dominante',
        es: 'ganancia más equilibrada, sin un único destaque dominante',
        en: 'more balanced gains, without one dominant advantage',
      );
    }
    return parts.join(', ');
  }

  String _watchouts(BuildContext context) {
    final parts = <String>[];
    if (city.flightAccessScore <= 50) {
      parts.add(_localizedText(
        context,
        pt: 'passagem pesa mais na entrada',
        es: 'el vuelo pesa más al inicio',
        en: 'flight weighs more on arrival',
      ));
    }
    if (city.jobStabilityScore <= 54) {
      parts.add(_localizedText(
        context,
        pt: 'trabalho oscila ao longo do ano',
        es: 'el trabajo oscila durante el año',
        en: 'work fluctuates through the year',
      ));
    }
    if (city.costScore <= 52) {
      parts.add(_localizedText(
        context,
        pt: 'custo aperta mais no começo',
        es: 'el costo aprieta más al inicio',
        en: 'cost is tighter at the start',
      ));
    }
    if (city.hasBudgetSnapshot && city.salaryFitScore <= 52) {
      parts.add(_localizedText(
        context,
        pt: 'salário médio local não cobre bem o custo base',
        es: 'el salario medio local no cubre bien el costo base',
        en: 'local average salary does not cover the base cost well',
      ));
    }
    if (parts.isEmpty) {
      return _localizedText(
        context,
        pt: 'sem alerta forte entre as cidades comparadas',
        es: 'sin alerta fuerte entre las ciudades comparadas',
        en: 'no major warning among the compared cities',
      );
    }
    return parts.join(', ');
  }

  String _tradeoff(BuildContext context) {
    final nearest = allCities
        .where((item) => item.distanceKm != null)
        .fold<_ComparisonCityData?>(null, (best, item) {
          if (best == null) return item;
          return (item.distanceKm ?? 999999) < (best.distanceKm ?? 999999)
              ? item
              : best;
        });
    if (lens == _ComparisonLens.incomeStart && city.jobMarketScore >= 72) {
      return _localizedText(
        context,
        pt: 'vale mais se seu foco é renda, mesmo quando o custo de chegada sobe.',
        es: 'vale más si tu foco es ingreso, incluso cuando el costo de llegada sube.',
        en: 'it pays off more if income is your focus, even when arrival cost rises.',
      );
    }
    if (nearest != null && nearest.city.id == city.city.id) {
      return _localizedText(
        context,
        pt: 'é a opção mais próxima do seu ponto de partida entre as comparadas.',
        es: 'es la opción más cercana a tu punto de partida entre las comparadas.',
        en: 'it is the closest option to your starting point among the compared cities.',
      );
    }
    return _localizedText(
      context,
      pt: 'entrega equilíbrio diferente: você troca alguma facilidade por outro ganho importante.',
      es: 'ofrece un equilibrio distinto: cambias algo de facilidad por otra ganancia importante.',
      en: 'it offers a different balance: you trade some ease for another meaningful gain.',
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonCityData {
  const _ComparisonCityData({
    required this.city,
    required this.cityCode,
    required this.hasBudgetSnapshot,
    required this.rentEstimateBrl,
    required this.monthlyFoodCostBrl,
    required this.monthlyTransportCostBrl,
    required this.hdiScore,
    required this.currentTempC,
    required this.safetyLevelScore,
    required this.safetyLabel,
    required this.jobMarketScore,
    required this.jobMarketLabel,
    required this.economicActivityScore,
    required this.averageNetSalaryBrl,
    required this.baseLivingCostBrl,
    required this.salaryFitScore,
    required this.salaryCoverageLabel,
    required this.salaryBalanceLabel,
    required this.jobStabilityScore,
    required this.jobStabilityLabel,
    required this.communityScore,
    required this.communityLabel,
    required this.languageScore,
    required this.languageLabel,
    required this.costScore,
    required this.distanceKm,
    required this.distanceLabel,
    required this.sizeScore,
    required this.sizeLabel,
    required this.flightAccessScore,
    required this.flightRangeLabel,
    required this.flightPressureLabel,
    required this.arrivalEaseScore,
    required this.arrivalEaseLabel,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final City city;
  final String cityCode;
  final bool hasBudgetSnapshot;
  final int rentEstimateBrl;
  final int monthlyFoodCostBrl;
  final int monthlyTransportCostBrl;
  final double hdiScore;
  final double? currentTempC;
  final int safetyLevelScore;
  final String safetyLabel;
  final int jobMarketScore;
  final String jobMarketLabel;
  final int economicActivityScore;
  final int averageNetSalaryBrl;
  final int baseLivingCostBrl;
  final int salaryFitScore;
  final String salaryCoverageLabel;
  final String salaryBalanceLabel;
  final int jobStabilityScore;
  final String jobStabilityLabel;
  final int communityScore;
  final String communityLabel;
  final int languageScore;
  final String languageLabel;
  final int costScore;
  final int? distanceKm;
  final String distanceLabel;
  final int sizeScore;
  final String sizeLabel;
  final int flightAccessScore;
  final String flightRangeLabel;
  final String flightPressureLabel;
  final int arrivalEaseScore;
  final String arrivalEaseLabel;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  static _ComparisonCityData fromCity(
    BuildContext context,
    City city,
    CityWeather? weather, {
    required CopilotExchangeRates? exchangeRates,
    required String? preferredCountryId,
    required dynamic detectedLocation,
    required String? originAirportIata,
    required TravelRouteInsight? routeInsight,
    required _ComparisonLens lens,
  }) {
    final budget = city.budgetSnapshot;
    final monthlyBase = budget?.singlePersonExcludingRent ?? _monthlyBaseEstimate(city);
    final flightPressure = routeInsight == null
        ? '—'
        : _flightPressureLabel(
            context,
            FlightRoutePriceInsightService.classifyPressure(
              route: routeInsight,
              baseArrivalBudgetBrl: budget?.fairLivingTotal,
            ).label,
          );
    final distanceKm = _distanceFromDetected(city, detectedLocation);
    final seasonality = CitySeasonalityProfile.of(city);
    final jobStabilityScore = _jobStabilityScore(city, seasonality);
    final arrivalEaseScore = _arrivalEaseScore(
      city,
      routeInsight: routeInsight,
      budget: budget,
    );
    final averageNetSalaryBrl = budget?.averageMonthlyNetSalary ?? 0;
    final salaryFitScore = budget == null
        ? 0
        : _salaryFitScore(
            averageNetSalaryBrl: averageNetSalaryBrl,
            fairLivingTotal: budget.fairLivingTotal,
          );
    return _ComparisonCityData(
      city: city,
      cityCode: _cityCode(city),
      hasBudgetSnapshot: budget != null,
      rentEstimateBrl: budget?.cheaperRent ??
          (monthlyBase * 0.42).round().clamp(1200, 4200),
      monthlyFoodCostBrl: budget?.singlePersonExcludingRent ??
          (monthlyBase * 0.24).round().clamp(650, 1700),
      monthlyTransportCostBrl: budget?.monthlyTransportPass ??
          (monthlyBase * 0.09).round().clamp(180, 520),
      hdiScore: city.idhmScore,
      currentTempC: weather?.temperatureCelsius,
      safetyLevelScore: city.safetyScore,
      safetyLabel: _safetyLabel(context, city.safetyScore),
      jobMarketScore: city.jobMarketScore,
      jobMarketLabel: _jobLabel(context, city.jobMarketScore),
      economicActivityScore: city.economicActivityScore,
      averageNetSalaryBrl: averageNetSalaryBrl,
      baseLivingCostBrl: budget?.fairLivingTotal ??
          (budget?.cheaperRent ??
              (monthlyBase * 0.42).round().clamp(1200, 4200)) +
              (budget?.singlePersonExcludingRent ?? monthlyBase),
      salaryFitScore: salaryFitScore,
      salaryCoverageLabel: budget == null
          ? _localizedText(
              context,
              pt: 'Sem leitura',
              es: 'Sin lectura',
              en: 'No read',
            )
          : _salaryCoverageLabel(
              context,
              averageNetSalaryBrl: averageNetSalaryBrl,
              fairLivingTotal: budget.fairLivingTotal,
            ),
      salaryBalanceLabel: budget == null
          ? _localizedText(
              context,
              pt: 'Sem leitura',
              es: 'Sin lectura',
              en: 'No read',
            )
          : _salaryBalanceLabel(
              context,
              averageNetSalaryBrl: averageNetSalaryBrl,
              fairLivingTotal: budget.fairLivingTotal,
            ),
      jobStabilityScore: jobStabilityScore,
      jobStabilityLabel: _jobStabilityLabel(context, jobStabilityScore),
      communityScore: city.argentinaPopularityScore,
      communityLabel: _communityLabel(context, city.argentinaPopularityScore),
      languageScore: city.movaroScores.languageAdaptation,
      languageLabel: _languageLabel(context, city.movaroScores.languageAdaptation),
      costScore: city.costOfLivingScore,
      distanceKm: distanceKm,
      distanceLabel: _distanceLabel(context, distanceKm),
      sizeScore: _sizeScore(city),
      sizeLabel: _sizeLabel(context, city.population),
      flightAccessScore: _flightAccessScore(routeInsight),
      flightRangeLabel: routeInsight == null
          ? _localizedText(context, pt: 'Sem leitura', es: 'Sin lectura', en: 'No route read')
          : MultiCurrencyAmount.formatRangeFromUsd(
              context: context,
              minUsd: routeInsight.lowUsdMin,
              maxUsd: routeInsight.lowUsdMax,
            ),
      flightPressureLabel: flightPressure,
      arrivalEaseScore: arrivalEaseScore,
      arrivalEaseLabel: _arrivalEaseLabel(context, arrivalEaseScore, lens),
      exchangeRates: exchangeRates,
      preferredCountryId: preferredCountryId,
    );
  }

  static int _monthlyBaseEstimate(City city) {
    final monthlyFromScores =
        2300 +
        ((100 - city.costOfLivingScore) * 24) +
        ((100 - city.rentScore) * 18);

    final regionalFactor = switch (city.regionName?.toLowerCase()) {
      'sudeste' => 1.10,
      'sul' => 1.03,
      'centro-oeste' => 1.01,
      'nordeste' => 0.95,
      'norte' => 0.97,
      _ => 1.0,
    };

    return (monthlyFromScores * regionalFactor).round().clamp(2800, 6800);
  }

  static String _cityCode(City city) {
    final initials = city.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();
    if (initials.length >= 3) {
      return initials.substring(0, 3);
    }
    final normalized = city.name
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase();
    if (normalized.length >= 3) {
      return normalized.substring(0, 3);
    }
    return (normalized.isNotEmpty ? normalized : city.stateCode).padRight(
      3,
      city.stateCode,
    );
  }

  static String _safetyLabel(BuildContext context, int score) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (score >= 70) {
      return switch (languageCode) {
        'es' => 'Alta',
        'en' => 'High',
        _ => 'Alta',
      };
    }
    if (score >= 55) {
      return switch (languageCode) {
        'es' => 'Moderada',
        'en' => 'Moderate',
        _ => 'Moderada',
      };
    }
    return switch (languageCode) {
      'es' => 'Baja',
      'en' => 'Low',
      _ => 'Baixa',
    };
  }

  static String _jobLabel(BuildContext context, int score) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (score >= 78) {
      return switch (languageCode) {
        'es' => 'Fuerte',
        'en' => 'Strong',
        _ => 'Forte',
      };
    }
    if (score >= 62) {
      return switch (languageCode) {
        'es' => 'Moderado',
        'en' => 'Moderate',
        _ => 'Moderado',
      };
    }
    return switch (languageCode) {
      'es' => 'Limitado',
      'en' => 'Limited',
      _ => 'Limitado',
    };
  }

  static String _communityLabel(BuildContext context, int score) {
    if (score >= 72) {
      return context.l10n.cityComparisonCommunityLarge;
    }
    if (score >= 52) {
      return context.l10n.cityComparisonCommunityMedium;
    }
    return context.l10n.cityComparisonCommunitySmall;
  }

  static int _salaryFitScore({
    required int averageNetSalaryBrl,
    required int fairLivingTotal,
  }) {
    if (fairLivingTotal <= 0) {
      return 50;
    }
    final ratio = averageNetSalaryBrl / fairLivingTotal;
    if (ratio >= 1.25) return 84;
    if (ratio >= 1.0) return 68;
    if (ratio >= 0.8) return 52;
    return 34;
  }

  static String _salaryCoverageLabel(
    BuildContext context, {
    required int averageNetSalaryBrl,
    required int fairLivingTotal,
  }) {
    if (fairLivingTotal <= 0) {
      return _localizedText(
        context,
        pt: 'sem leitura',
        es: 'sin lectura',
        en: 'no read',
      );
    }
    final ratio = (averageNetSalaryBrl / fairLivingTotal) * 100;
    return '${ratio.round()}%';
  }

  static String _salaryBalanceLabel(
    BuildContext context, {
    required int averageNetSalaryBrl,
    required int fairLivingTotal,
  }) {
    final diff = averageNetSalaryBrl - fairLivingTotal;
    final absolute = diff.abs();
    final money = MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: absolute,
      exchangeRates: null,
      preferredCountryId: null,
    );
    if (diff >= 0) {
      return _localizedText(
        context,
        pt: 'sobra $money',
        es: 'sobran $money',
        en: '$money left',
      );
    }
    return _localizedText(
      context,
      pt: 'falta $money',
      es: 'faltan $money',
      en: '$money short',
    );
  }

  static int? _distanceFromDetected(City city, dynamic detectedLocation) {
    if (detectedLocation?.latitude == null || detectedLocation?.longitude == null) {
      return null;
    }
    return const Distance()
        .as(
          LengthUnit.Kilometer,
          LatLng(detectedLocation.latitude as double, detectedLocation.longitude as double),
          LatLng(city.latitude, city.longitude),
        )
        .round();
  }

  static String _distanceLabel(BuildContext context, int? distanceKm) {
    if (distanceKm == null) {
      return _localizedText(
        context,
        pt: 'Sem GPS',
        es: 'Sin GPS',
        en: 'No GPS',
      );
    }
    return '$distanceKm km';
  }

  static int _flightAccessScore(TravelRouteInsight? route) {
    if (route == null) return 55;
    final avg = route.lowUsdAverage;
    if (avg <= 170) return 82;
    if (avg <= 220) return 65;
    return 42;
  }

  static String _flightPressureLabel(BuildContext context, String level) {
    switch (level) {
      case 'high':
        return _localizedText(context, pt: 'Pesado', es: 'Pesado', en: 'Heavy');
      case 'medium':
        return _localizedText(context, pt: 'Atenção', es: 'Atención', en: 'Watch');
      default:
        return _localizedText(context, pt: 'Leve', es: 'Leve', en: 'Light');
    }
  }

  static int _jobStabilityScore(City city, CitySeasonalityData? seasonality) {
    final seasonalityPenalty = switch (seasonality?.severity) {
      CitySeasonalitySeverity.high => 18,
      CitySeasonalitySeverity.medium => 8,
      _ => 0,
    };
    return (city.jobMarketScore - seasonalityPenalty).clamp(0, 100);
  }

  static String _jobStabilityLabel(BuildContext context, int score) {
    if (score >= 72) {
      return _localizedText(context, pt: 'Equilibrado', es: 'Equilibrado', en: 'Year-round');
    }
    if (score >= 55) {
      return _localizedText(context, pt: 'Oscila', es: 'Oscila', en: 'Mixed');
    }
    return _localizedText(context, pt: 'Sazonal', es: 'Estacional', en: 'Seasonal');
  }

  static String _languageLabel(BuildContext context, int score) {
    if (score >= 72) {
      return _localizedText(context, pt: 'Fácil', es: 'Fácil', en: 'Easy');
    }
    if (score >= 55) {
      return _localizedText(context, pt: 'Média', es: 'Media', en: 'Medium');
    }
    return _localizedText(context, pt: 'Difícil', es: 'Difícil', en: 'Hard');
  }

  static int _sizeScore(City city) {
    final pop = city.population;
    if (pop >= 500000 && pop <= 2000000) return 80;
    if (pop >= 200000) return 68;
    return 54;
  }

  static String _sizeLabel(BuildContext context, int population) {
    if (population >= 2000000) {
      return _localizedText(context, pt: 'Muito grande', es: 'Muy grande', en: 'Very large');
    }
    if (population >= 500000) {
      return _localizedText(context, pt: 'Grande', es: 'Grande', en: 'Large');
    }
    if (population >= 200000) {
      return _localizedText(context, pt: 'Média', es: 'Media', en: 'Mid-size');
    }
    return _localizedText(context, pt: 'Compacta', es: 'Compacta', en: 'Compact');
  }

  static int _arrivalEaseScore(
    City city, {
    required TravelRouteInsight? routeInsight,
    required CityBudgetSnapshot? budget,
  }) {
    final flightPenalty = routeInsight == null
        ? 0
        : switch (FlightRoutePriceInsightService.classifyPressure(
            route: routeInsight,
            baseArrivalBudgetBrl: budget?.fairLivingTotal,
          ).label) {
            'high' => 16,
            'medium' => 8,
            _ => 0,
          };
    final score =
        ((city.rentScore +
                    city.movaroScores.languageAdaptation +
                    city.safetyScore +
                    city.costOfLivingScore) /
                4) -
            flightPenalty;
    return score.round().clamp(0, 100);
  }

  static String _arrivalEaseLabel(
    BuildContext context,
    int score,
    _ComparisonLens lens,
  ) {
    if (score >= 74) {
      return _localizedText(context, pt: 'Entrada leve', es: 'Entrada liviana', en: 'Easy start');
    }
    if (score >= 58) {
      return _localizedText(context, pt: 'Exige atenção', es: 'Exige atención', en: 'Needs attention');
    }
    return _localizedText(context, pt: 'Entrada pesada', es: 'Entrada pesada', en: 'Heavy start');
  }
}

class _MetricDefinition {
  const _MetricDefinition._({
    required this.key,
    required this.isCompetitive,
    required this.lowerIsBetter,
    required this.numericValue,
    required this.displayValue,
    required this.label,
  });

  final String key;
  final bool isCompetitive;
  final bool lowerIsBetter;
  final double? Function(_ComparisonCityData city) numericValue;
  final String Function(BuildContext context, _ComparisonCityData city)
  displayValue;
  final String Function(BuildContext context) label;

  static const rent = _MetricDefinition._(
    key: 'rent',
    isCompetitive: true,
    lowerIsBetter: true,
    numericValue: _rentNumeric,
    displayValue: _rentDisplay,
    label: _rentLabel,
  );
  static const food = _MetricDefinition._(
    key: 'food',
    isCompetitive: true,
    lowerIsBetter: true,
    numericValue: _foodNumeric,
    displayValue: _foodDisplay,
    label: _foodLabel,
  );
  static const transport = _MetricDefinition._(
    key: 'transport',
    isCompetitive: true,
    lowerIsBetter: true,
    numericValue: _transportNumeric,
    displayValue: _transportDisplay,
    label: _transportLabel,
  );
  static const salary = _MetricDefinition._(
    key: 'salary',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _salaryNumeric,
    displayValue: _salaryDisplay,
    label: _salaryLabel,
  );
  static const salaryCoverage = _MetricDefinition._(
    key: 'salary_coverage',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _salaryCoverageNumeric,
    displayValue: _salaryCoverageDisplay,
    label: _salaryCoverageLabelMetric,
  );
  static const hdi = _MetricDefinition._(
    key: 'hdi',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _hdiNumeric,
    displayValue: _hdiDisplay,
    label: _hdiLabel,
  );
  static const safety = _MetricDefinition._(
    key: 'safety',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _safetyNumeric,
    displayValue: _safetyDisplay,
    label: _safetyLabel,
  );
  static const language = _MetricDefinition._(
    key: 'language',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _languageNumeric,
    displayValue: _languageDisplay,
    label: _languageLabel,
  );
  static const job = _MetricDefinition._(
    key: 'job',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _jobNumeric,
    displayValue: _jobDisplay,
    label: _jobLabel,
  );
  static const jobStability = _MetricDefinition._(
    key: 'job_stability',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _jobStabilityNumeric,
    displayValue: _jobStabilityDisplay,
    label: _jobStabilityLabel,
  );
  static const community = _MetricDefinition._(
    key: 'community',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _communityNumeric,
    displayValue: _communityDisplay,
    label: _communityLabel,
  );

  List<String> bestCityIds(List<_ComparisonCityData> cities) {
    if (direction == MetricDirection.neutral) {
      return const [];
    }
    final values = <String, double>{
      for (final city in cities)
        if (numericValue(city) != null) city.city.id: numericValue(city)!,
    };
    if (values.isEmpty) {
      return const [];
    }
    final best = direction == MetricDirection.lowerIsBetter
        ? values.values.reduce((a, b) => a < b ? a : b)
        : values.values.reduce((a, b) => a > b ? a : b);
    return values.entries
        .where((entry) => entry.value == best)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  List<String> worstCityIds(List<_ComparisonCityData> cities) {
    if (direction == MetricDirection.neutral) {
      return const [];
    }
    final values = <String, double>{
      for (final city in cities)
        if (numericValue(city) != null) city.city.id: numericValue(city)!,
    };
    if (values.isEmpty) {
      return const [];
    }
    final worst = direction == MetricDirection.lowerIsBetter
        ? values.values.reduce((a, b) => a > b ? a : b)
        : values.values.reduce((a, b) => a < b ? a : b);
    return values.entries
        .where((entry) => entry.value == worst)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  static double? _rentNumeric(_ComparisonCityData city) =>
      city.rentEstimateBrl.toDouble();
  static String _rentDisplay(BuildContext context, _ComparisonCityData city) =>
      _formatMoney(context, city.rentEstimateBrl, city);
  static String _rentLabel(BuildContext context) =>
      context.l10n.cityComparisonRentLabel;

  static double? _foodNumeric(_ComparisonCityData city) =>
      city.monthlyFoodCostBrl.toDouble();
  static String _foodDisplay(BuildContext context, _ComparisonCityData city) =>
      _formatMoney(context, city.monthlyFoodCostBrl, city);
  static String _foodLabel(BuildContext context) =>
      context.l10n.cityComparisonFoodLabel;

  static double? _transportNumeric(_ComparisonCityData city) =>
      city.monthlyTransportCostBrl.toDouble();
  static String _transportDisplay(
    BuildContext context,
    _ComparisonCityData city,
  ) => _formatMoney(context, city.monthlyTransportCostBrl, city);
  static String _transportLabel(BuildContext context) =>
      context.l10n.cityComparisonTransportLabel;

  static double? _salaryNumeric(_ComparisonCityData city) =>
      city.hasBudgetSnapshot ? city.averageNetSalaryBrl.toDouble() : null;
  static String _salaryDisplay(BuildContext context, _ComparisonCityData city) =>
      city.hasBudgetSnapshot
      ? _formatMoney(context, city.averageNetSalaryBrl, city)
      : _localizedText(
          context,
          pt: 'Sem leitura',
          es: 'Sin lectura',
          en: 'No read',
        );
  static String _salaryLabel(BuildContext context) => _localizedText(
    context,
    pt: 'Salário',
    es: 'Salario',
    en: 'Net salary',
  );

  static double? _salaryCoverageNumeric(_ComparisonCityData city) =>
      city.hasBudgetSnapshot ? city.salaryFitScore.toDouble() : null;
  static String _salaryCoverageDisplay(
    BuildContext _,
    _ComparisonCityData city,
  ) => '${city.salaryCoverageLabel} · ${city.salaryBalanceLabel}';
  static String _salaryCoverageLabelMetric(BuildContext context) => _localizedText(
    context,
    pt: 'Peso no mês',
    es: 'Peso mensual',
    en: 'Monthly fit',
  );

  static double? _hdiNumeric(_ComparisonCityData city) => city.hdiScore;
  static String _hdiDisplay(BuildContext _, _ComparisonCityData city) =>
      city.hdiScore.toStringAsFixed(3);
  static String _hdiLabel(BuildContext context) =>
      context.l10n.cityComparisonHdiLabel;

  static double? _safetyNumeric(_ComparisonCityData city) =>
      city.safetyLevelScore.toDouble();
  static String _safetyDisplay(BuildContext _, _ComparisonCityData city) =>
      city.safetyLabel;
  static String _safetyLabel(BuildContext context) =>
      context.l10n.cityComparisonSafetyLabel;

  static double? _languageNumeric(_ComparisonCityData city) =>
      city.languageScore.toDouble();
  static String _languageDisplay(BuildContext _, _ComparisonCityData city) =>
      city.languageLabel;
  static String _languageLabel(BuildContext context) => _localizedText(
    context,
    pt: 'Português',
    es: 'Portugués',
    en: 'Portuguese',
  );

  static double? _jobNumeric(_ComparisonCityData city) =>
      city.jobMarketScore.toDouble();
  static String _jobDisplay(BuildContext _, _ComparisonCityData city) =>
      city.jobMarketLabel;
  static String _jobLabel(BuildContext context) =>
      context.l10n.cityComparisonJobLabel;

  static double? _jobStabilityNumeric(_ComparisonCityData city) =>
      city.jobStabilityScore.toDouble();
  static String _jobStabilityDisplay(BuildContext _, _ComparisonCityData city) =>
      city.jobStabilityLabel;
  static String _jobStabilityLabel(BuildContext context) => _localizedText(
    context,
    pt: 'Ano inteiro',
    es: 'Todo el año',
    en: 'Year-round',
  );

  static double? _communityNumeric(_ComparisonCityData city) =>
      city.communityScore.toDouble();
  static String _communityDisplay(BuildContext _, _ComparisonCityData city) =>
      city.communityLabel;
  static String _communityLabel(BuildContext context) =>
      context.l10n.cityComparisonCommunityLabel;

  MetricDirection get direction => switch (key) {
    'rent' || 'food' || 'transport' || 'distance' => MetricDirection.lowerIsBetter,
    'salary' ||
    'salary_coverage' ||
    'flight' ||
    'hdi' ||
    'safety' ||
    'language' ||
    'job' ||
    'job_stability' ||
    'community' => MetricDirection.higherIsBetter,
    _ => MetricDirection.neutral,
  };

  _MetricCellState cellStateFor({
    required String cityId,
    required List<String> winners,
    required List<String> losers,
  }) {
    if (winners.contains(cityId) && winners.length == 1) {
      return _MetricCellState.best;
    }
    if (losers.contains(cityId) && losers.length == 1) {
      return _MetricCellState.worst;
    }
    return _MetricCellState.neutral;
  }

  _MetricCellColors? semanticColors(
    BuildContext context,
    _ComparisonCityData city,
  ) {
    switch (key) {
      case 'safety':
        if (city.safetyLevelScore >= 70) {
          return _MetricCellColors.semanticSuccess(context);
        }
        if (city.safetyLevelScore >= 55) {
          return _MetricCellColors.semanticWarning(context);
        }
        return _MetricCellColors.semanticDanger(context);
      case 'job':
        if (city.jobMarketScore >= 78) {
          return _MetricCellColors.semanticSuccess(context);
        }
        if (city.jobMarketScore >= 62) {
          return _MetricCellColors.semanticWarning(context);
        }
        return _MetricCellColors.semanticDanger(context);
      case 'job_stability':
        if (city.jobStabilityScore >= 72) {
          return _MetricCellColors.semanticSuccess(context);
        }
        if (city.jobStabilityScore >= 55) {
          return _MetricCellColors.semanticWarning(context);
        }
        return _MetricCellColors.semanticDanger(context);
      case 'flight':
        if (city.flightAccessScore >= 78) {
          return _MetricCellColors.semanticSuccess(context);
        }
        if (city.flightAccessScore >= 58) {
          return _MetricCellColors.semanticWarning(context);
        }
        return _MetricCellColors.semanticDanger(context);
      case 'salary_coverage':
        if (city.salaryFitScore >= 80) {
          return _MetricCellColors.semanticSuccess(context);
        }
        if (city.salaryFitScore >= 55) {
          return _MetricCellColors.semanticWarning(context);
        }
        return _MetricCellColors.semanticDanger(context);
      default:
        return null;
    }
  }

  static String _formatMoney(
    BuildContext context,
    num amountInBrl,
    _ComparisonCityData city,
  ) {
    return MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: amountInBrl,
      exchangeRates: city.exchangeRates,
      preferredCountryId: city.preferredCountryId,
    );
  }
}

enum MetricDirection { lowerIsBetter, higherIsBetter, neutral }

enum _MetricCellState { best, worst, neutral }

class _MetricCellColors {
  const _MetricCellColors({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;

  static _MetricCellColors semanticSuccess(BuildContext context) =>
      _MetricCellColors(
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFF1F8F3),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFBBDCC6),
        ),
        text: AppColors.success,
      );

  static _MetricCellColors semanticWarning(BuildContext context) =>
      _MetricCellColors(
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFFFF8E7),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFEFCF84),
        ),
        text: AppColors.warning,
      );

  static _MetricCellColors semanticDanger(BuildContext context) =>
      _MetricCellColors(
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.danger,
          lightColor: const Color(0xFFFDEEE8),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: AppColors.danger,
          lightColor: const Color(0xFFF1C3B2),
        ),
        text: AppColors.danger,
      );

  static _MetricCellColors resolve(
    BuildContext context,
    _MetricCellState state,
  ) {
    switch (state) {
      case _MetricCellState.best:
        return const _MetricCellColors(
          background: Color.fromRGBO(63, 185, 80, 0.15),
          border: Color.fromRGBO(63, 185, 80, 0.4),
          text: Color(0xFF3FB950),
        );
      case _MetricCellState.worst:
        return const _MetricCellColors(
          background: Color.fromRGBO(226, 75, 74, 0.15),
          border: Color.fromRGBO(226, 75, 74, 0.3),
          text: Color(0xFFE24B4A),
        );
      case _MetricCellState.neutral:
        return _MetricCellColors(
          background: AppColors.surfaceMutedFor(context),
          border: AppColors.borderFor(context),
          text: AppColors.textPrimaryFor(context),
        );
    }
  }
}

const _scoredMetricDefinitions = <_MetricDefinition>[
  _MetricDefinition.salary,
  _MetricDefinition.salaryCoverage,
  _MetricDefinition.rent,
  _MetricDefinition.food,
  _MetricDefinition.transport,
  _MetricDefinition.hdi,
  _MetricDefinition.safety,
  _MetricDefinition.job,
  _MetricDefinition.community,
];

class _DashedPainter extends CustomPainter {
  const _DashedPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
