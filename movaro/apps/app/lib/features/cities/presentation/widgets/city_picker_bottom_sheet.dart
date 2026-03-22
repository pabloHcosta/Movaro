import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_search_matcher.dart';

/// A reusable bottom-sheet city picker with **Map** and **List** tabs.
///
/// Usage:
/// ```dart
/// final city = await CityPickerBottomSheet.show(
///   context: context,
///   cities: allCities,
///   title: 'Choose your city',
/// );
/// ```
class CityPickerBottomSheet extends StatefulWidget {
  const CityPickerBottomSheet({
    required this.cities,
    required this.title,
    this.subtitle,
    this.showSkipOption = false,
    this.onSkip,
    this.initialSelection,
    this.confirmLabel,
    super.key,
  });

  final List<City> cities;
  final String title;
  final String? subtitle;
  final bool showSkipOption;
  final VoidCallback? onSkip;
  final City? initialSelection;
  final String? confirmLabel;

  /// Show the picker and return the selected [City], or `null` if dismissed.
  static Future<City?> show({
    required BuildContext context,
    required List<City> cities,
    required String title,
    String? subtitle,
    bool showSkipOption = false,
    VoidCallback? onSkip,
    City? initialSelection,
    String? confirmLabel,
  }) {
    return showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.90,
          child: CityPickerBottomSheet(
            cities: cities,
            title: title,
            subtitle: subtitle,
            showSkipOption: showSkipOption,
            onSkip: onSkip,
            initialSelection: initialSelection,
            confirmLabel: confirmLabel,
          ),
        );
      },
    );
  }

  @override
  State<CityPickerBottomSheet> createState() => _CityPickerBottomSheetState();
}

class _CityPickerBottomSheetState extends State<CityPickerBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late City _selectedCity;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCity = widget.initialSelection ?? widget.cities.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value;
      });
    });
  }

  List<City> get _filteredCities {
    var cities = widget.cities;

    // State filter
    if (_selectedState != null) {
      cities =
          cities.where((c) => c.stateCode == _selectedState).toList();
    }

    // Search filter
    if (_searchQuery.isEmpty) return cities;

    final scored = <(City, int)>[];
    for (final city in cities) {
      final s = CitySearchMatcher.score(
        _searchQuery,
        city.name,
        city.stateName,
      );
      if (s > 0) scored.add((city, s));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }

  List<String> get _availableStates {
    final states = <String>{};
    for (final city in widget.cities) {
      states.add(city.stateCode);
    }
    final sorted = states.toList()..sort();
    return sorted;
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedCity);
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
            // Drag handle
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

            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            // Subtitle
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textSoft),
              ),
            ],

            const SizedBox(height: 16),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: textSoft,
                labelStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text(context.l10n.cityPickerMapTab()),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.list_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(context.l10n.cityPickerListTab()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MapTab(
                    cities: widget.cities,
                    selectedCity: _selectedCity,
                    onCitySelected: (city) {
                      setState(() => _selectedCity = city);
                    },
                  ),
                  _ListTab(
                    filteredCities: _filteredCities,
                    availableStates: _availableStates,
                    selectedCity: _selectedCity,
                    selectedState: _selectedState,
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onStateSelected: (state) {
                      setState(() {
                        _selectedState =
                            _selectedState == state ? null : state;
                      });
                    },
                    onCitySelected: (city) {
                      setState(() => _selectedCity = city);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Preview card + confirm
            _PreviewCard(
              city: _selectedCity,
              confirmLabel: widget.confirmLabel ??
                  context.l10n.cityPickerConfirmLabel(),
              onConfirm: _confirmSelection,
            ),

            // Skip option
            if (widget.showSkipOption) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    widget.onSkip?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    context.l10n.cityPickerSkipLabel(),
                    style: TextStyle(color: textSoft),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Tab
// ─────────────────────────────────────────────────────────────────────────────

class _MapTab extends StatelessWidget {
  const _MapTab({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  final List<City> cities;
  final City selectedCity;
  final ValueChanged<City> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
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
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.movaro.app',
          ),
          MarkerLayer(
            markers: [
              for (final city in cities)
                Marker(
                  point: LatLng(city.latitude, city.longitude),
                  width: 44,
                  height: 44,
                  child: _MapCityMarker(
                    selected: city.id == selectedCity.id,
                    onTap: () => onCitySelected(city),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ListTab extends StatelessWidget {
  const _ListTab({
    required this.filteredCities,
    required this.availableStates,
    required this.selectedCity,
    required this.selectedState,
    required this.searchController,
    required this.onSearchChanged,
    required this.onStateSelected,
    required this.onCitySelected,
  });

  final List<City> filteredCities;
  final List<String> availableStates;
  final City selectedCity;
  final String? selectedState;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStateSelected;
  final ValueChanged<City> onCitySelected;

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);

    return Column(
      children: [
        // Search bar
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: context.l10n.cityPickerSearchHint(),
            hintStyle: TextStyle(color: textSoft),
            prefixIcon: Icon(Icons.search, color: textSoft, size: 20),
            filled: true,
            fillColor: AppColors.surfaceMutedFor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // State filter chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availableStates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final state = availableStates[index];
              final isSelected = selectedState == state;
              return GestureDetector(
                onTap: () => onStateSelected(state),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surfaceMutedFor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          )
                        : null,
                  ),
                  child: Text(
                    state,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? AppColors.primary : textSoft,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // City list
        Expanded(
          child: filteredCities.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.cityPickerNoResults(),
                    style: TextStyle(color: textSoft),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredCities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    final isSelected = city.id == selectedCity.id;
                    return _CityListTile(
                      city: city,
                      selected: isSelected,
                      onTap: () => onCitySelected(city),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Sub-Widgets
// ─────────────────────────────────────────────────────────────────────────────

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

class _CityListTile extends StatelessWidget {
  const _CityListTile({
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
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${city.stateName} (${city.stateCode})',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSoftFor(context),
                          ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.city,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final City city;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: Theme.of(context).textTheme.titleMedium,
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
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onConfirm,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
