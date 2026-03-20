import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

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
    for (var index = 0; index < widget.initialCities.length && index < _mode; index++) {
      _selectedCities[index] = widget.initialCities[index];
      unawaited(widget.citiesController.loadWeatherForCity(widget.initialCities[index].id));
    }
    _isComparing = widget.initialCities.length >= 2;
    unawaited(widget.citiesController.prefetchCatalog());
    unawaited(_loadExchangeRates());
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
        _ModeToggle(
          mode: _mode,
          onModeChanged: _changeMode,
        ),
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
                  _SearchResultTile(
                    city: city,
                    onTap: () => _addCity(city),
                  ),
                  if (city != results.take(8).last)
                    Divider(
                      height: 1,
                      color: AppColors.borderFor(context),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildComparisonState(BuildContext context) {
    final cities = _comparisonCities(context);
    final winner = _winner(cities);
    final compact = cities.length >= 3;
    final scoredMetricCount = _scoredMetricDefinitions.length;

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
              trailing: SizedBox(
                width: 92,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isComparing = false),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: context.l10n.cityComparisonEditAction,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: _showHelp,
                      icon: const Icon(Icons.help_outline_rounded),
                      tooltip: context.l10n.cityComparisonGuideTitle(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
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
              padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
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
                for (final group in _metricGroups(context)) ...[
                  _MetricSection(
                    title: group.title,
                    cities: cities,
                    metrics: group.metrics,
                    compact: compact,
                  ),
                  const SizedBox(height: 16),
                ],
                _WinnerBanner(
                  winner: winner,
                  totalMetrics: scoredMetricCount,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _startPlanWithWinner(winner.city),
                  child: Text(
                    context.l10n.cityComparisonStartPlanAction(winner.city.name),
                  ),
                ),
                if (cities.length == 2) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.cityDetail(
                        cities.firstWhere((item) => item.city.id != winner.city.id).city.id,
                      ),
                    ),
                    child: Text(
                      context.l10n.cityComparisonOtherDetailsAction(
                        cities.firstWhere((item) => item.city.id != winner.city.id).city.name,
                      ),
                    ),
                  ),
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
    unawaited(widget.citiesController.loadWeatherForCity(city.id));
  }

  void _startComparison() {
    if (_selectedCount < 2) {
      return;
    }
    setState(() => _isComparing = true);
  }

  List<City> _filteredResults(String query) {
    final selectedIds = _selectedCities.whereType<City>().map((city) => city.id).toSet();
    final catalog = widget.citiesController.catalog;
    if (query.isEmpty) {
      return const [];
    }
    return catalog
        .where(
          (city) =>
              !selectedIds.contains(city.id) &&
              ('${city.name} ${city.stateName} ${city.stateCode}')
                  .toLowerCase()
                  .contains(query),
        )
        .take(12)
        .toList(growable: false);
  }

  List<City> _quickSuggestions() {
    final selectedIds = _selectedCities.whereType<City>().map((city) => city.id).toSet();
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
    return _selectedCities
        .whereType<City>()
        .map(
          (city) => _ComparisonCityData.fromCity(
            context,
            city,
            widget.citiesController.weatherFor(city.id),
            exchangeRates: _exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
        )
        .toList(growable: false);
  }

  String? get _preferredCurrencyCountryId {
    final journeyOrigin =
        widget.migrationQuestionnaireController.journeyContextController.originCountryId;
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
      ..sort((a, b) => (scored[b.city.id] ?? 0).compareTo(scored[a.city.id] ?? 0));
    final winner = sorted.first;
    return _CityWinner(city: winner.city, score: scored[winner.city.id] ?? 0);
  }

  int _calculateScore(
    _ComparisonCityData city,
    List<_ComparisonCityData> allCities,
  ) {
    var score = 0;
    for (final metric in _scoredMetricDefinitions) {
      final current = metric.numericValue(city);
      if (current == null) {
        continue;
      }
      final values = allCities
          .map(metric.numericValue)
          .whereType<double>()
          .toList(growable: false);
      if (values.isEmpty) {
        continue;
      }
      final best = metric.lowerIsBetter
          ? values.reduce((a, b) => a < b ? a : b)
          : values.reduce((a, b) => a > b ? a : b);
      if (current == best) {
        score++;
      }
    }
    return score;
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
  const _ModeToggle({
    required this.mode,
    required this.onModeChanged,
  });

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
            color: selected ? AppColors.primary : AppColors.textPrimaryFor(context),
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
                Icon(
                  Icons.add_rounded,
                  color: AppColors.textSoftFor(context),
                ),
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

    final imageUrl = cityImageUrlFor(city!.id);

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
                        if (imageUrl != null)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            httpHeaders: const {'User-Agent': 'Movaro/1.0'},
                            placeholder: (_, _) => const SkeletonBox(height: 32),
                            errorWidget: (_, _, _) => const DecoratedBox(
                              decoration: BoxDecoration(color: Color(0xFF17345D)),
                            ),
                          )
                        else
                          const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFF17345D)),
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
  const _SearchResultTile({
    required this.city,
    required this.onTap,
  });

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
        child: const Icon(Icons.location_city_outlined, color: AppColors.primary),
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(bottom: 8),
      child: child,
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
    return FrostedPanel(
      padding: const EdgeInsets.all(14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: compact ? 74 : 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.cityComparisonHeaderLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    letterSpacing: 0.9,
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(width: compact ? 8 : 10),
            for (final city in cities) ...[
              Expanded(
                child: _CityHeaderColumn(
                  city: city,
                  isWinner: city.city.id == winner.city.id,
                  compact: compact,
                ),
              ),
              if (city != cities.last) SizedBox(width: compact ? 8 : 10),
            ],
          ],
        ),
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
    final nameStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: _nameFontSize(city.city.name),
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: 1.15,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.topCenter,
            child: isWinner
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.l10n.cityComparisonTopBadge,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            constraints: BoxConstraints(minHeight: compact ? 124 : 132),
            padding: EdgeInsets.fromLTRB(
              compact ? 8 : 10,
              compact ? 12 : 14,
              compact ? 8 : 10,
              compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isWinner
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isWinner
                    ? AppColors.primary.withValues(alpha: 0.32)
                    : AppColors.borderFor(context),
              ),
              boxShadow: isWinner
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city.city.name,
                  maxLines: compact ? 3 : 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: nameStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  '${city.city.stateCode} · ${city.cityCode}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: compact ? 7.5 : 8,
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _nameFontSize(String name) {
    if (!compact) {
      if (name.length >= 20) {
        return 10;
      }
      if (name.length >= 15) {
        return 10.5;
      }
      return 11.5;
    }

    if (name.length >= 20) {
      return 8.6;
    }
    if (name.length >= 15) {
      return 9.0;
    }
    return 9.6;
  }
}

class _MetricSectionGroup {
  const _MetricSectionGroup({required this.title, required this.metrics});

  final String title;
  final List<_MetricDefinition> metrics;
}

List<_MetricSectionGroup> _metricGroups(BuildContext context) => [
  _MetricSectionGroup(
    title: context.l10n.cityComparisonGroupCost,
    metrics: const [
      _MetricDefinition.rent,
      _MetricDefinition.food,
      _MetricDefinition.transport,
    ],
  ),
  _MetricSectionGroup(
    title: context.l10n.cityComparisonGroupQuality,
    metrics: const [
      _MetricDefinition.hdi,
      _MetricDefinition.climate,
      _MetricDefinition.safety,
    ],
  ),
  _MetricSectionGroup(
    title: context.l10n.cityComparisonGroupWork,
    metrics: const [
      _MetricDefinition.job,
      _MetricDefinition.community,
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
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final metric in metrics) ...[
            _MetricRow(
              metric: metric,
              cities: cities,
              compact: compact,
            ),
            if (metric != metrics.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.cities,
    required this.compact,
  });

  final _MetricDefinition metric;
  final List<_ComparisonCityData> cities;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final winners = metric.bestCityIds(cities);
    final losers = metric.worstCityIds(cities);
    final minWidth = cities.length >= 3 ? 72.0 : 90.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              metric.label(context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSoftFor(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        for (final city in cities) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final state = metric.cellStateFor(
                  cityId: city.city.id,
                  winners: winners,
                  losers: losers,
                );
                final colors = _MetricCellColors.resolve(context, state);
                final value = metric.displayValue(context, city);

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 8,
                    vertical: compact ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: minWidth),
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: compact ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          color: colors.text,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (city != cities.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _WinnerBanner extends StatelessWidget {
  const _WinnerBanner({
    required this.winner,
    required this.totalMetrics,
  });

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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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

class _ComparisonCityData {
  const _ComparisonCityData({
    required this.city,
    required this.cityCode,
    required this.rentEstimateBrl,
    required this.monthlyFoodCostBrl,
    required this.monthlyTransportCostBrl,
    required this.hdiScore,
    required this.currentTempC,
    required this.safetyLevelScore,
    required this.safetyLabel,
    required this.jobMarketScore,
    required this.jobMarketLabel,
    required this.communityScore,
    required this.communityLabel,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final City city;
  final String cityCode;
  final int rentEstimateBrl;
  final int monthlyFoodCostBrl;
  final int monthlyTransportCostBrl;
  final double hdiScore;
  final double? currentTempC;
  final int safetyLevelScore;
  final String safetyLabel;
  final int jobMarketScore;
  final String jobMarketLabel;
  final int communityScore;
  final String communityLabel;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  static _ComparisonCityData fromCity(
    BuildContext context,
    City city,
    CityWeather? weather,
    {required CopilotExchangeRates? exchangeRates,
    required String? preferredCountryId,}
  ) {
    final monthlyBase = _monthlyBaseEstimate(city);
    return _ComparisonCityData(
      city: city,
      cityCode: _cityCode(city),
      rentEstimateBrl: (monthlyBase * 0.42).round().clamp(1200, 4200),
      monthlyFoodCostBrl: (monthlyBase * 0.24).round().clamp(650, 1700),
      monthlyTransportCostBrl: (monthlyBase * 0.09).round().clamp(180, 520),
      hdiScore: city.idhmScore,
      currentTempC: weather?.temperatureCelsius,
      safetyLevelScore: city.safetyScore,
      safetyLabel: _safetyLabel(context, city.safetyScore),
      jobMarketScore: city.jobMarketScore,
      jobMarketLabel: _jobLabel(context, city.jobMarketScore),
      communityScore: city.argentinaPopularityScore,
      communityLabel: _communityLabel(context, city.argentinaPopularityScore),
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
    final normalized = city.name.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
    if (normalized.length >= 3) {
      return normalized.substring(0, 3);
    }
    return (normalized.isNotEmpty ? normalized : city.stateCode).padRight(3, city.stateCode);
  }

  static String _safetyLabel(BuildContext context, int score) {
    final presentation = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.safety,
      value: score,
    );
    return presentation.headline;
  }

  static String _jobLabel(BuildContext context, int score) {
    final presentation = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: score,
    );
    return presentation.headline;
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
  final String Function(BuildContext context, _ComparisonCityData city) displayValue;
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
  static const hdi = _MetricDefinition._(
    key: 'hdi',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _hdiNumeric,
    displayValue: _hdiDisplay,
    label: _hdiLabel,
  );
  static const climate = _MetricDefinition._(
    key: 'climate',
    isCompetitive: false,
    lowerIsBetter: false,
    numericValue: _climateNumeric,
    displayValue: _climateDisplay,
    label: _climateLabel,
  );
  static const safety = _MetricDefinition._(
    key: 'safety',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _safetyNumeric,
    displayValue: _safetyDisplay,
    label: _safetyLabel,
  );
  static const job = _MetricDefinition._(
    key: 'job',
    isCompetitive: true,
    lowerIsBetter: false,
    numericValue: _jobNumeric,
    displayValue: _jobDisplay,
    label: _jobLabel,
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

  static double? _rentNumeric(_ComparisonCityData city) => city.rentEstimateBrl.toDouble();
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

  static double? _hdiNumeric(_ComparisonCityData city) => city.hdiScore;
  static String _hdiDisplay(BuildContext _, _ComparisonCityData city) =>
      city.hdiScore.toStringAsFixed(3);
  static String _hdiLabel(BuildContext context) =>
      context.l10n.cityComparisonHdiLabel;

  static double? _climateNumeric(_ComparisonCityData city) => city.currentTempC;
  static String _climateDisplay(BuildContext context, _ComparisonCityData city) =>
      city.currentTempC == null
          ? context.l10n.cityComparisonUnavailable
          : '${city.currentTempC!.round()}°C';
  static String _climateLabel(BuildContext context) =>
      context.l10n.cityComparisonClimateLabel;

  static double? _safetyNumeric(_ComparisonCityData city) =>
      city.safetyLevelScore.toDouble();
  static String _safetyDisplay(BuildContext _, _ComparisonCityData city) =>
      city.safetyLabel;
  static String _safetyLabel(BuildContext context) =>
      context.l10n.cityComparisonSafetyLabel;

  static double? _jobNumeric(_ComparisonCityData city) =>
      city.jobMarketScore.toDouble();
  static String _jobDisplay(BuildContext _, _ComparisonCityData city) =>
      city.jobMarketLabel;
  static String _jobLabel(BuildContext context) =>
      context.l10n.cityComparisonJobLabel;

  static double? _communityNumeric(_ComparisonCityData city) =>
      city.communityScore.toDouble();
  static String _communityDisplay(BuildContext _, _ComparisonCityData city) =>
      city.communityLabel;
  static String _communityLabel(BuildContext context) =>
      context.l10n.cityComparisonCommunityLabel;

  MetricDirection get direction => switch (key) {
    'rent' || 'food' || 'transport' => MetricDirection.lowerIsBetter,
    'hdi' || 'safety' || 'job' || 'community' => MetricDirection.higherIsBetter,
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

  static _MetricCellColors resolve(BuildContext context, _MetricCellState state) {
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
    const radius = 20.0;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth)
            .clamp(0.0, metric.length.toDouble())
            .toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
