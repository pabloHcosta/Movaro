import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_search_matcher.dart';

/// A reusable bottom-sheet city picker with **Map** and **List** tabs.
///
/// The map tab shows cities as named pill labels (not generic pins).
/// Tapping a pill shows a tooltip; tapping the tooltip or long-pressing
/// the pill selects the city.
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
  City? _selectedCity;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _selectedRegion; // null = "Todas"

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCity = widget.initialSelection;
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
      setState(() => _searchQuery = value);
    });
  }

  /// Cities filtered only by region (no search) — used for the map tab.
  List<City> get _regionFilteredCities {
    if (_selectedRegion == null) return widget.cities;
    return widget.cities.where((c) {
      final r = _CityRegionHelper.regionFor(c.countryCode, c.stateCode);
      return r == _selectedRegion;
    }).toList();
  }

  /// Cities filtered by region + search — used for the list tab.
  List<City> get _filteredCities {
    final cities = _regionFilteredCities;
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

  void _confirmSelection() {
    if (_selectedCity == null) return;
    Navigator.of(context).pop(_selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);
    final regions = _RegionFilter.forContext(context);

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
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),

            // Subtitle
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textSoft),
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
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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

            const SizedBox(height: 8),

            // Region filter chips (applies to both map and list)
            _RegionFilterRow(
              regions: regions,
              selectedRegion: _selectedRegion,
              onRegionSelected: (r) => setState(() => _selectedRegion = r),
            ),

            const SizedBox(height: 8),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MapTab(
                    cities: _regionFilteredCities,
                    selectedCity: _selectedCity,
                    onCitySelected: (city) {
                      setState(() => _selectedCity = city);
                    },
                  ),
                  _ListTab(
                    filteredCities: _filteredCities,
                    selectedCity: _selectedCity,
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
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
              confirmLabel:
                  widget.confirmLabel ?? context.l10n.cityPickerConfirmLabel(),
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
// Region Filter Row
// ─────────────────────────────────────────────────────────────────────────────

class _RegionFilterRow extends StatelessWidget {
  const _RegionFilterRow({
    required this.regions,
    required this.selectedRegion,
    required this.onRegionSelected,
  });

  final List<_RegionFilter> regions;
  final String? selectedRegion;
  final ValueChanged<String?> onRegionSelected;

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final region = regions[index];
          final isSelected = region.key == selectedRegion;
          return GestureDetector(
            onTap: () => onRegionSelected(region.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                region.displayLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? AppColors.primary : textSoft,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Tab
// ─────────────────────────────────────────────────────────────────────────────

class _MapTab extends StatefulWidget {
  const _MapTab({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  final List<City> cities;
  final City? selectedCity;
  final ValueChanged<City> onCitySelected;

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  late final MapController _mapController;
  City? _tooltipCity;

  static const double _pillMarkerWidth = 110.0;
  static const double _pillMarkerHeight = 30.0;
  static const double _tooltipMarkerWidth = 196.0;
  static const double _tooltipCardSpacerHeight = 34.0;
  static const double _tooltipCardHeight = 120.0;
  static const double _tooltipMarkerHeight =
      _tooltipCardHeight + _tooltipCardSpacerHeight;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cities.length != widget.cities.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Dismiss tooltip if its city is no longer visible
        if (_tooltipCity != null &&
            !widget.cities.any((c) => c.id == _tooltipCity!.id)) {
          setState(() => _tooltipCity = null);
        }
        // Animate camera to filtered bounds
        _animateToCities(widget.cities);
      });
    }
  }

  void _animateToCities(List<City> cities) {
    if (cities.isEmpty) return;
    if (cities.length == 1) {
      _mapController.move(
        LatLng(cities.first.latitude, cities.first.longitude),
        7.0,
      );
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: cities
            .map((c) => LatLng(c.latitude, c.longitude))
            .toList(),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tooltipCity = _tooltipCity;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-14.2350, -51.9253),
              initialZoom: 4.0,
              minZoom: 3,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, _) {
                if (_tooltipCity != null) {
                  setState(() => _tooltipCity = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.movaro.app',
              ),
              // Pill markers layer
              MarkerLayer(
                markers: [
                  for (final city in widget.cities)
                    Marker(
                      point: LatLng(city.latitude, city.longitude),
                      width: _pillMarkerWidth,
                      height: _pillMarkerHeight,
                      alignment: Alignment.bottomCenter,
                      child: _PillMarker(
                        name: city.name,
                        selected: city.id == widget.selectedCity?.id,
                        onTap: () => setState(() {
                          _tooltipCity = _tooltipCity?.id == city.id
                              ? null
                              : city;
                        }),
                        onLongPress: () {
                          setState(() => _tooltipCity = null);
                          widget.onCitySelected(city);
                        },
                      ),
                    ),
                ],
              ),
              // Tooltip layer — only the active tooltip city
              if (tooltipCity != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        tooltipCity.latitude,
                        tooltipCity.longitude,
                      ),
                      width: _tooltipMarkerWidth,
                      height: _tooltipMarkerHeight,
                      alignment: Alignment.bottomCenter,
                      child: _CityTooltipMarker(
                        city: tooltipCity,
                        pillSpacerHeight: _tooltipCardSpacerHeight,
                        onSelect: () {
                          setState(() => _tooltipCity = null);
                          widget.onCitySelected(tooltipCity);
                        },
                        onDismiss: () => setState(() => _tooltipCity = null),
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
          // "Tap to select" hint overlay at bottom
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.l10n.citySelectorTapToSelect(),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill Marker
// ─────────────────────────────────────────────────────────────────────────────

class _PillMarker extends StatelessWidget {
  const _PillMarker({
    required this.name,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF3B7CC8) : const Color(0xFF1E3A5F);
    final border = selected ? const Color(0xFF90C4F8) : const Color(0xFF3B7CC8);
    final textColor = selected ? Colors.white : const Color(0xFF90C4F8);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 106),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CustomPaint(
            size: const Size(10, 5),
            painter: _DownTrianglePainter(color: bg, borderColor: border),
          ),
        ],
      ),
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  const _DownTrianglePainter({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, fill);

    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.miter;
    final strokePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(strokePath, stroke);
  }

  @override
  bool shouldRepaint(_DownTrianglePainter old) =>
      color != old.color || borderColor != old.borderColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// City Tooltip Marker
// ─────────────────────────────────────────────────────────────────────────────

class _CityTooltipMarker extends StatelessWidget {
  const _CityTooltipMarker({
    required this.city,
    required this.pillSpacerHeight,
    required this.onSelect,
    required this.onDismiss,
  });

  final City city;
  final double pillSpacerHeight;
  final VoidCallback onSelect;
  final VoidCallback onDismiss;

  String _idhmLabel(double v) {
    if (v >= 0.800) return 'IDH Muito Alto';
    if (v >= 0.700) return 'IDH Alto';
    if (v >= 0.555) return 'IDH Médio';
    return 'IDH Baixo';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Absorb taps on the card so they don't reach the map onTap handler
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1929),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B7CC8)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x77000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        city.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDismiss,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF90C4F8),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  city.stateName,
                  style: const TextStyle(
                    color: Color(0xFF90C4F8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _idhmLabel(city.idhmScore),
                  style: const TextStyle(
                    color: Color(0xFF90C4F8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onSelect,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B7CC8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Selecionar →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Spacer aligns tooltip above the pill marker at the same coordinate
        SizedBox(height: pillSpacerHeight),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ListTab extends StatelessWidget {
  const _ListTab({
    required this.filteredCities,
    required this.selectedCity,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCitySelected,
  });

  final List<City> filteredCities;
  final City? selectedCity;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
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
                    final isSelected = city.id == selectedCity?.id;
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
              if (selected)
                Icon(Icons.check_circle, color: AppColors.primary, size: 20),
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

  final City? city;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final hasSelection = city != null;
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
            child: hasSelection
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city!.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${city!.stateName} (${city!.stateCode})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  )
                : Text(
                    context.l10n.citySelectorNoSelection(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Opacity(
            opacity: hasSelection ? 1.0 : 0.4,
            child: FilledButton(
              onPressed: hasSelection ? onConfirm : null,
              child: Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Region Filter Data
// ─────────────────────────────────────────────────────────────────────────────

class _RegionFilter {
  const _RegionFilter({required this.key, required this.displayLabel});

  /// `null` means "All regions".
  final String? key;
  final String displayLabel;

  static List<_RegionFilter> forContext(BuildContext context) => [
    _RegionFilter(
      key: null,
      displayLabel: context.l10n.citySelectorRegionAll(),
    ),
    _RegionFilter(
      key: 'Sul / Sudeste',
      displayLabel: context.l10n.citySelectorRegionSouthSE(),
    ),
    _RegionFilter(
      key: 'Nordeste',
      displayLabel: context.l10n.citySelectorRegionNE(),
    ),
    _RegionFilter(
      key: 'Centro-Oeste',
      displayLabel: context.l10n.citySelectorRegionCW(),
    ),
    _RegionFilter(
      key: 'Norte',
      displayLabel: context.l10n.citySelectorRegionNorth(),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// City Region Helper
// ─────────────────────────────────────────────────────────────────────────────

class _CityRegionHelper {
  /// Maps country code → (state code → region name).
  /// Region names must match the [_RegionFilter.key] values.
  static const Map<String, Map<String, String>> _mapping = {
    'BR': {
      // Sul / Sudeste
      'RS': 'Sul / Sudeste',
      'SC': 'Sul / Sudeste',
      'PR': 'Sul / Sudeste',
      'SP': 'Sul / Sudeste',
      'RJ': 'Sul / Sudeste',
      'MG': 'Sul / Sudeste',
      'ES': 'Sul / Sudeste',
      // Nordeste
      'BA': 'Nordeste',
      'SE': 'Nordeste',
      'AL': 'Nordeste',
      'PE': 'Nordeste',
      'PB': 'Nordeste',
      'RN': 'Nordeste',
      'CE': 'Nordeste',
      'PI': 'Nordeste',
      'MA': 'Nordeste',
      // Centro-Oeste
      'MT': 'Centro-Oeste',
      'MS': 'Centro-Oeste',
      'GO': 'Centro-Oeste',
      'DF': 'Centro-Oeste',
      // Norte
      'AM': 'Norte',
      'PA': 'Norte',
      'RO': 'Norte',
      'RR': 'Norte',
      'AP': 'Norte',
      'TO': 'Norte',
      'AC': 'Norte',
    },
  };

  static String? regionFor(String countryCode, String stateCode) =>
      _mapping[countryCode]?[stateCode];
}
