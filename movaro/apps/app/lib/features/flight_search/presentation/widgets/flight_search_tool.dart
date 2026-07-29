import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/flight_search/data/airport_database.dart';
import 'package:movaro_app/features/flight_search/domain/models/airport.dart';
import 'package:movaro_app/features/flight_search/domain/models/flight_search_params.dart';
import 'package:movaro_app/features/flight_search/domain/services/airport_finder_service.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_price_insight_service.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_url_builder.dart';
import 'package:movaro_app/app/currency/currency_scope.dart';
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
    this.destinationLatitude,
    this.destinationLongitude,
    super.key,
  });

  final LocationController locationController;

  /// ISO code of the user's origin country (e.g. 'AR').
  final String originCountryIso;

  /// ISO code of the destination country (e.g. 'BR').
  final String destinationCountryIso;

  /// Optional city name used to pre-select the nearest destination airport.
  final String? destinationCityName;
  final double? destinationLatitude;
  final double? destinationLongitude;

  @override
  State<FlightSearchTool> createState() => _FlightSearchToolState();
}

class _FlightSearchToolState extends State<FlightSearchTool> {
  static const _finder = AirportFinderService();

  // ── State ────────────────────────────────────────────────────────────────

  List<Airport> _suggestedOrigins = [];
  List<Airport> _originAirports = [];
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
    final originCountryIso = FlightRouteContextResolver.normalizeCountryIso(
      widget.originCountryIso,
    );
    final destinationCountryIso =
        FlightRouteContextResolver.normalizeCountryIso(
          widget.destinationCountryIso,
        );

    if (originCountryIso == null || destinationCountryIso == null) {
      _suggestedOrigins = const [];
      _originAirports = const [];
      _destinationAirports = const [];
      _selectedOrigin = null;
      _selectedDestination = null;
      return;
    }

    _originAirports = AirportDatabase.forCountry(originCountryIso);

    // ── Origin airports (GPS-aware) ──────────────────────────────────────
    if (loc != null &&
        FlightRouteContextResolver.normalizeCountryIso(loc.countryCode) ==
            originCountryIso) {
      _suggestedOrigins = _finder.findNearest(
        latitude: loc.latitude,
        longitude: loc.longitude,
        countryIso: originCountryIso,
        maxResults: 3,
      );
    } else {
      // GPS unavailable or user is outside origin country — show all airports.
      _suggestedOrigins = _originAirports;
    }

    // Pre-select: nearest airport (or main hub if empty list)
    if (_suggestedOrigins.isNotEmpty) {
      _selectedOrigin = _suggestedOrigins.first;
    } else {
      _selectedOrigin = AirportDatabase.mainHubFor(originCountryIso);
    }

    // ── Destination airports ────────────────────────────────────────────
    if (widget.destinationLatitude != null &&
        widget.destinationLongitude != null) {
      _destinationAirports = _finder.findNearest(
        latitude: widget.destinationLatitude!,
        longitude: widget.destinationLongitude!,
        countryIso: destinationCountryIso,
        maxResults: AirportDatabase.forCountry(destinationCountryIso).length,
      );
    } else {
      _destinationAirports = AirportDatabase.forCountry(destinationCountryIso);
    }

    _selectedDestination = FlightRouteContextResolver.resolveDestinationAirport(
      destinationCityName: widget.destinationCityName,
      destinationCountryIso: destinationCountryIso,
      destinationLatitude: widget.destinationLatitude,
      destinationLongitude: widget.destinationLongitude,
    );
    _selectedDestination ??= _destinationAirports.isNotEmpty
        ? _destinationAirports.first
        : AirportDatabase.mainHubFor(destinationCountryIso);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today.add(const Duration(days: 30)),
      firstDate: today.add(const Duration(days: 7)),
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
    final uri = FlightUrlBuilder.build(
      params,
      currencyCode: context.preferredCurrencyCode,
    );
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

  Future<void> _chooseAirport({
    required BuildContext context,
    required String title,
    required List<Airport> airports,
    required Airport? selected,
    required ValueChanged<Airport> onSelected,
  }) async {
    if (airports.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_noAirportOptionsLabel(context))),
        );
      }
      return;
    }
    final picked = await showModalBottomSheet<Airport>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: FrostedPanel(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.72,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectorHint(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: airports.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final airport = airports[index];
                          final isSelected = airport == selected;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected ? AppColors.primary : null,
                            ),
                            title: Text(airport.chipLabel),
                            subtitle: Text(airport.name),
                            trailing: airport.isMainHub
                                ? _SelectorTag(label: _mainHubLabel(context))
                                : null,
                            onTap: () => Navigator.of(context).pop(airport),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (picked == null) {
      return;
    }
    setState(() {
      onSelected(picked);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final savedLocation = widget.locationController.savedLocation;
    final destinationLabel =
        widget.destinationCityName?.trim().isNotEmpty == true
        ? widget.destinationCityName!.trim()
        : l10n.flightDestinationFallback(widget.destinationCountryIso);
    final originCityLabel = savedLocation?.cityName.trim().isNotEmpty == true
        ? savedLocation!.cityName.trim()
        : savedLocation?.stateName.trim().isNotEmpty == true
        ? savedLocation!.stateName.trim()
        : null;
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
            l10n.flightPlannerBody(destinationLabel),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          _PrefilledRouteCard(
            originLabel: _selectedOrigin?.city ?? originCityLabel ?? '...',
            destinationLabel: _selectedDestination?.city ?? destinationLabel,
            helperText: _autofillHint(
              context,
              originCity: originCityLabel,
              destinationCity: destinationLabel,
            ),
          ),
          const SizedBox(height: 20),

          // ── Seasonality card ──────────────────────────────────────────
          if (_selectedDestination != null) ...[
            FlightSeasonalityCard(
              originCountryIso: widget.originCountryIso,
              originIata: _selectedOrigin?.iataCode,
              destIata: _selectedDestination?.iataCode,
            ),
            const SizedBox(height: 20),
          ],

          // ── Origin section ───────────────────────────────────────────
          _SectionLabel(l10n.migrationPlanPrepFlightsOriginLabel),
          if (originCityLabel != null) ...[
            const SizedBox(height: 4),
            _SelectionStatusPill(
              icon: Icons.my_location_rounded,
              label: _originPrefillLabel(context, originCityLabel),
            ),
          ],
          const SizedBox(height: 8),
          _AirportSelectorTile(
            label: _selectedOrigin?.chipLabel ?? _originFallbackLabel(context),
            onTap: () => _chooseAirport(
              context: context,
              title: _originSelectorTitle(context),
              airports: _originAirports.isNotEmpty
                  ? _originAirports
                  : _suggestedOrigins,
              selected: _selectedOrigin,
              onSelected: (airport) => _selectedOrigin = airport,
            ),
          ),
          const SizedBox(height: 8),
          _AirportChips(
            airports: _originAirports.isNotEmpty
                ? _originAirports
                : _suggestedOrigins,
            selected: _selectedOrigin,
            onSelect: (a) => setState(() => _selectedOrigin = a),
            maxVisible: 4,
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
          // ── Season alert (shown after date is chosen) ────────────────
          if (_selectedDate != null && _selectedDestination != null) ...[
            const SizedBox(height: 10),
            _SeasonDateAlert(
              date: _selectedDate!,
              originIata: _selectedOrigin?.iataCode,
              destIata: _selectedDestination!.iataCode,
              destCity: _selectedDestination!.city,
            ),
          ],
          const SizedBox(height: 18),

          // ── Destination section ───────────────────────────────────────
          _SectionLabel(l10n.flightSearchDestinationLabel()),
          if (widget.destinationCityName?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            _SelectionStatusPill(
              icon: Icons.flag_rounded,
              label: _destinationPrefillLabel(
                context,
                widget.destinationCityName!.trim(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          _AirportSelectorTile(
            label:
                _selectedDestination?.chipLabel ??
                _destinationFallbackLabel(context, destinationLabel),
            onTap: () => _chooseAirport(
              context: context,
              title: _destinationSelectorTitle(context),
              airports: _destinationAirports,
              selected: _selectedDestination,
              onSelected: (airport) => _selectedDestination = airport,
            ),
          ),
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

  String _autofillHint(
    BuildContext context, {
    required String? originCity,
    required String destinationCity,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final originLabel = originCity ?? _selectedOrigin?.city ?? 'origem';
    return switch (languageCode) {
      'pt' =>
        'Preenchemos a rota inicial com origem em $originLabel e destino em $destinationCity. Se quiser, ajuste abaixo.',
      'es' =>
        'Completamos la ruta inicial con origen en $originLabel y destino en $destinationCity. Si quieres, ajustala abajo.',
      _ =>
        'We prefilled the initial route with origin in $originLabel and destination in $destinationCity. Adjust it below if needed.',
    };
  }

  String _originPrefillLabel(BuildContext context, String city) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Origem detectada: $city',
      'es' => 'Origen detectado: $city',
      _ => 'Detected origin: $city',
    };
  }

  String _destinationPrefillLabel(BuildContext context, String city) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Destino preenchido: $city',
      'es' => 'Destino cargado: $city',
      _ => 'Prefilled destination: $city',
    };
  }

  String _selectorHint(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Escolha o aeroporto que faz mais sentido para sua rota.',
      'es' => 'Elige el aeropuerto que tenga mas sentido para tu ruta.',
      _ => 'Choose the airport that makes the most sense for your route.',
    };
  }

  String _originSelectorTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Escolher aeroporto de saída',
      'es' => 'Elegir aeropuerto de salida',
      _ => 'Choose departure airport',
    };
  }

  String _destinationSelectorTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Escolher aeroporto de destino',
      'es' => 'Elegir aeropuerto de destino',
      _ => 'Choose destination airport',
    };
  }

  String _originFallbackLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Selecionar origem',
      'es' => 'Seleccionar origen',
      _ => 'Select origin',
    };
  }

  String _destinationFallbackLabel(BuildContext context, String destination) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Selecionar destino em $destination',
      'es' => 'Seleccionar destino en $destination',
      _ => 'Select destination in $destination',
    };
  }

  String _mainHubLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'principal',
      'es' => 'principal',
      _ => 'main',
    };
  }

  String _noAirportOptionsLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Não encontramos aeroportos para essa origem agora.',
      'es' => 'No encontramos aeropuertos para ese origen ahora.',
      _ => 'We could not find airports for that origin right now.',
    };
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _PrefilledRouteCard extends StatelessWidget {
  const _PrefilledRouteCard({
    required this.originLabel,
    required this.destinationLabel,
    required this.helperText,
  });

  final String originLabel;
  final String destinationLabel;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$originLabel → $destinationLabel',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            helperText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionStatusPill extends StatelessWidget {
  const _SelectionStatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSoftFor(context)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AirportSelectorTile extends StatelessWidget {
  const _AirportSelectorTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              _changeLabel(context),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }

  String _changeLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Alterar',
      'es' => 'Cambiar',
      _ => 'Change',
    };
  }
}

class _SelectorTag extends StatelessWidget {
  const _SelectorTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
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
              color: hasError ? Theme.of(context).colorScheme.error : null,
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

/// Warns the user when the selected departure date falls in a high-price
/// season for the destination. Shows a positive nudge when the month is low.
class _SeasonDateAlert extends StatelessWidget {
  const _SeasonDateAlert({
    required this.date,
    required this.destIata,
    required this.destCity,
    this.originIata,
  });

  final DateTime date;
  final String? originIata;
  final String destIata;
  final String destCity;

  @override
  Widget build(BuildContext context) {
    final route = FlightRoutePriceInsightService.resolveRoute(
      originIata: originIata,
      destIata: destIata,
    );
    if (route == null) return const SizedBox.shrink();

    final monthIndex = date.month - 1; // 0-based index into 12-month list
    final level = route.months[monthIndex];

    return switch (level) {
      FlightRoutePriceLevel.low => _alert(
        context,
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
        message: _lowMessage(context),
      ),
      FlightRoutePriceLevel.high => _alert(
        context,
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        message: _highMessage(context, route.months),
      ),
      FlightRoutePriceLevel.mid => const SizedBox.shrink(),
    };
  }

  Widget _alert(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _monthAbbreviations(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' => const [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ],
      'en' => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ],
      _ => const [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ],
    };
  }

  String _lowMessage(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' =>
        'Buena época para volar a $destCity — los precios suelen ser más bajos en este mes.',
      'en' =>
        'Good time to fly to $destCity — prices are typically lower this month.',
      _ =>
        'Boa época para voar para $destCity — os preços costumam ser mais baixos neste mês.',
    };
  }

  String _highMessage(
    BuildContext context,
    List<FlightRoutePriceLevel> months,
  ) {
    final abbreviations = _monthAbbreviations(context);
    final cheapLabels = [
      for (var i = 0; i < months.length; i++)
        if (months[i] == FlightRoutePriceLevel.low) abbreviations[i],
    ];
    final cheaper = cheapLabels.isNotEmpty ? cheapLabels.join(', ') : '—';

    return switch (Localizations.localeOf(context).languageCode) {
      'es' =>
        'Alta temporada en $destCity — los precios suelen ser más altos en este mes. '
            'Meses más baratos: $cheaper.',
      'en' =>
        'High season in $destCity — prices are typically elevated this month. '
            'Cheaper months: $cheaper.',
      _ =>
        'Alta temporada em $destCity — os preços costumam ser mais altos neste mês. '
            'Meses mais baratos: $cheaper.',
    };
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.route_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${origin.iataCode} → ${destination.iataCode}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
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
