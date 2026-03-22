import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/flight_search/data/airport_database.dart';
import 'package:movaro_app/features/flight_search/domain/models/airport.dart';
import 'package:movaro_app/features/flight_search/domain/models/flight_search_params.dart';
import 'package:movaro_app/features/flight_search/domain/services/airport_finder_service.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_url_builder.dart';
import 'package:movaro_app/features/flight_search/presentation/widgets/flight_seasonality_card.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

// ── Public entry-point widget ─────────────────────────────────────────────────

/// Intelligent flight-search card shown inside the Movaro migration guide.
///
/// Reads the user's GPS via [locationController] to pre-select the nearest
/// departure airport. The destination is pre-filled from [destinationCityName]
/// and [destinationCountryIso].
class FlightSearchTool extends StatefulWidget {
  const FlightSearchTool({
    required this.locationController,
    required this.originCountryIso,
    required this.destinationCountryIso,
    this.destinationCityName,
    super.key,
  });

  final LocationController locationController;

  /// ISO code of the user's origin country (e.g. 'AR').
  final String originCountryIso;

  /// ISO code of the destination country (e.g. 'BR').
  final String destinationCountryIso;

  /// Optional city name used to pre-select the nearest destination airport.
  final String? destinationCityName;

  @override
  State<FlightSearchTool> createState() => _FlightSearchToolState();
}

class _FlightSearchToolState extends State<FlightSearchTool> {
  static const _finder = AirportFinderService();

  // ── State ────────────────────────────────────────────────────────────────

  List<Airport> _suggestedOrigins = [];
  List<Airport> _destinationAirports = [];
  Airport? _selectedOrigin;
  Airport? _selectedDestination;
  DateTime? _selectedDate;
  bool _showDateError = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  void _loadAirports() {
    final loc = widget.locationController.savedLocation;

    // ── Origin airports (GPS-aware) ──────────────────────────────────────
    if (loc != null &&
        loc.countryCode.toUpperCase() == widget.originCountryIso.toUpperCase()) {
      _suggestedOrigins = _finder.findNearest(
        latitude: loc.latitude,
        longitude: loc.longitude,
        countryIso: widget.originCountryIso,
        maxResults: 3,
      );
    } else {
      // GPS unavailable or user is outside origin country — show all airports.
      _suggestedOrigins = AirportDatabase.forCountry(widget.originCountryIso);
    }

    // Pre-select: nearest airport (or main hub if empty list)
    if (_suggestedOrigins.isNotEmpty) {
      _selectedOrigin = _suggestedOrigins.first;
    } else {
      _selectedOrigin = AirportDatabase.mainHubFor(widget.originCountryIso);
    }

    // ── Destination airports ────────────────────────────────────────────
    _destinationAirports = AirportDatabase.forCountry(
      widget.destinationCountryIso,
    );

    // Pre-select: airport matching the plan city, or the main hub
    if (widget.destinationCityName != null &&
        widget.destinationCityName!.isNotEmpty) {
      _selectedDestination = AirportDatabase.forCityName(
            widget.destinationCityName!,
            widget.destinationCountryIso,
          ) ??
          AirportDatabase.mainHubFor(widget.destinationCountryIso);
    } else {
      _selectedDestination = AirportDatabase.mainHubFor(
        widget.destinationCountryIso,
      );
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _showDateError = false;
    });
  }

  Future<void> _search(BuildContext context) async {
    if (_selectedDate == null) {
      setState(() => _showDateError = true);
      return;
    }
    if (_selectedOrigin == null || _selectedDestination == null) return;

    final params = FlightSearchParams(
      origin: _selectedOrigin!,
      destination: _selectedDestination!,
      departureDate: _selectedDate!,
    );
    final uri = FlightUrlBuilder.build(params);
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.flightSearchButtonLabel(),
          uri: uri,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canSearch =
        _selectedOrigin != null &&
        _selectedDestination != null &&
        _selectedDate != null;

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Text(
            l10n.migrationPlanPrepFlightsPlannerTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.migrationPlanPrepFlightsPlannerBody(
              widget.destinationCityName ?? l10n.questionOptionBrazil,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // ── Seasonality card ──────────────────────────────────────────
          if (_selectedDestination != null) ...[
            FlightSeasonalityCard(
              originCountryIso: widget.originCountryIso,
              destIata: _selectedDestination?.iataCode,
            ),
            const SizedBox(height: 20),
          ],

          // ── Origin section ───────────────────────────────────────────
          _SectionLabel(l10n.migrationPlanPrepFlightsOriginLabel),
          const SizedBox(height: 8),
          _AirportChips(
            airports: _suggestedOrigins.isNotEmpty
                ? _suggestedOrigins
                : AirportDatabase.forCountry(widget.originCountryIso),
            selected: _selectedOrigin,
            onSelect: (a) => setState(() => _selectedOrigin = a),
          ),
          const SizedBox(height: 18),

          // ── Date section ─────────────────────────────────────────────
          _SectionLabel(l10n.flightSearchDepartureDateLabel()),
          const SizedBox(height: 8),
          _DatePickerTile(
            selectedDate: _selectedDate,
            hasError: _showDateError,
            onTap: () => _pickDate(context),
          ),
          if (_showDateError) ...[
            const SizedBox(height: 6),
            Text(
              l10n.flightSearchDateRequired(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 18),

          // ── Destination section ───────────────────────────────────────
          _SectionLabel(l10n.flightSearchDestinationLabel()),
          const SizedBox(height: 8),
          _AirportChips(
            airports: _destinationAirports,
            selected: _selectedDestination,
            onSelect: (a) => setState(() => _selectedDestination = a),
            maxVisible: 4,
          ),
          const SizedBox(height: 20),

          // ── Route summary ─────────────────────────────────────────────
          if (_selectedOrigin != null && _selectedDestination != null) ...[
            _RouteSummaryTile(
              origin: _selectedOrigin!,
              destination: _selectedDestination!,
              date: _selectedDate,
            ),
            const SizedBox(height: 16),
          ],

          // ── Disclaimer ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Text(
              l10n.migrationPlanPrepFlightsDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Search button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSearch ? () => _search(context) : null,
              icon: const Icon(Icons.flight_takeoff_rounded),
              label: Text(l10n.flightSearchButtonLabel()),
            ),
          ),
          if (!canSearch && _selectedDate == null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.flightSearchSelectDateHint(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}

/// Horizontal chip list for airport selection.
class _AirportChips extends StatelessWidget {
  const _AirportChips({
    required this.airports,
    required this.selected,
    required this.onSelect,
    this.maxVisible = 3,
  });

  final List<Airport> airports;
  final Airport? selected;
  final ValueChanged<Airport> onSelect;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visible = airports.take(maxVisible).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final airport in visible)
          ChoiceChip(
            label: Text(airport.chipLabel),
            selected: airport == selected,
            onSelected: (_) => onSelect(airport),
          ),
      ],
    );
  }
}

/// Tappable tile that shows the selected departure date.
class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.selectedDate,
    required this.hasError,
    required this.onTap,
  });

  final DateTime? selectedDate;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = selectedDate == null
        ? l10n.migrationPlanPrepFlightsDatePlaceholder
        : MaterialLocalizations.of(context).formatMediumDate(selectedDate!);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasError
                ? Theme.of(context).colorScheme.error
                : AppColors.borderFor(context),
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              size: 18,
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.flightSearchDepartureDateLabel(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(label),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

/// Summary tile showing the selected route and date.
class _RouteSummaryTile extends StatelessWidget {
  const _RouteSummaryTile({
    required this.origin,
    required this.destination,
    required this.date,
  });

  final Airport origin;
  final Airport destination;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateLabel = date == null
        ? l10n.migrationPlanPrepFlightsDatePlaceholder
        : MaterialLocalizations.of(context).formatMediumDate(date!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${origin.iataCode} → ${destination.iataCode}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${origin.city} → ${destination.city} · $dateLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
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
