import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/location/argentina_locality.dart';
import 'package:movaro_app/features/location/argentina_locality_catalog.dart';
import 'package:movaro_app/features/location/location_controller.dart';

Future<bool> showOriginCityFlowSheet({
  required BuildContext context,
  required LocationController locationController,
}) async {
  await locationController.initialize();
  if (!context.mounted) return false;
  if (await locationController.hasConfirmedOriginCity()) {
    return true;
  }
  if (!context.mounted) return false;

  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _OriginCityFlowSheet(
          locationController: locationController,
          catalog: ArgentinaLocalityCatalog(),
        ),
      ) ??
      false;
}

enum _OriginCityStep { request, confirm, manual }

class _OriginCityFlowSheet extends StatefulWidget {
  const _OriginCityFlowSheet({
    required this.locationController,
    required this.catalog,
  });

  final LocationController locationController;
  final ArgentinaLocalityCatalog catalog;

  @override
  State<_OriginCityFlowSheet> createState() => _OriginCityFlowSheetState();
}

class _OriginCityFlowSheetState extends State<_OriginCityFlowSheet> {
  final _searchController = TextEditingController();
  var _step = _OriginCityStep.request;
  var _isRequesting = false;
  var _isLoadingCatalog = false;
  String? _error;
  List<ArgentinaLocality> _allLocalities = const [];
  List<ArgentinaLocality> _visibleLocalities = const [];

  bool get _hasArgentineLocation {
    final location = widget.locationController.savedLocation;
    if (location == null || location.cityName.trim().isEmpty) return false;
    final code = location.countryCode.trim().toUpperCase();
    final country = location.countryName.trim().toLowerCase();
    return code == 'AR' || country == 'argentina';
  }

  @override
  void initState() {
    super.initState();
    _step = _hasArgentineLocation
        ? _OriginCityStep.confirm
        : _OriginCityStep.request;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isRequesting = true;
      _error = null;
    });
    final result = await widget.locationController
        .requestPermissionAndCapture();
    if (!mounted) return;

    if (result.outcome == LocationPermissionOutcome.granted &&
        _hasArgentineLocation) {
      setState(() {
        _step = _OriginCityStep.confirm;
        _isRequesting = false;
      });
      return;
    }

    setState(() {
      _isRequesting = false;
      _error = result.outcome == LocationPermissionOutcome.granted
          ? _copy(
              pt: 'Não encontramos uma cidade na Argentina. Escolha sua cidade para continuar.',
              es: 'No encontramos una ciudad en Argentina. Elegí tu ciudad para continuar.',
              en: 'We could not find a city in Argentina. Choose your city to continue.',
            )
          : _copy(
              pt: 'Não foi possível acessar sua localização. Você pode escolher a cidade manualmente.',
              es: 'No pudimos acceder a tu ubicación. Podés elegir la ciudad manualmente.',
              en: 'We could not access your location. You can choose the city manually.',
            );
    });
  }

  Future<void> _openManualPicker() async {
    setState(() {
      _step = _OriginCityStep.manual;
      _isLoadingCatalog = _allLocalities.isEmpty;
      _error = null;
    });
    if (_allLocalities.isNotEmpty) return;

    try {
      final localities = await widget.catalog.load();
      if (!mounted) return;
      setState(() {
        _allLocalities = localities;
        _visibleLocalities = localities.take(80).toList(growable: false);
        _isLoadingCatalog = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingCatalog = false;
        _error = _copy(
          pt: 'Não foi possível abrir a lista de cidades. Tente novamente.',
          es: 'No se pudo abrir la lista de ciudades. Intentá nuevamente.',
          en: 'The city list could not be opened. Please try again.',
        );
      });
    }
  }

  void _search(String query) {
    setState(() {
      _visibleLocalities = widget.catalog.search(_allLocalities, query);
    });
  }

  Future<void> _select(ArgentinaLocality locality) async {
    HapticFeedback.selectionClick();
    await widget.locationController.selectOriginLocality(locality);
    if (!mounted) return;
    setState(() => _step = _OriginCityStep.confirm);
  }

  Future<void> _confirmCurrentCity() async {
    await widget.locationController.confirmSavedOriginCity();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _copy({required String pt, required String es, required String en}) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 42,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSoftFor(context).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: switch (_step) {
                    _OriginCityStep.request => _buildRequest(),
                    _OriginCityStep.confirm => _buildConfirmation(),
                    _OriginCityStep.manual => _buildManualPicker(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequest() {
    return SingleChildScrollView(
      key: const ValueKey('origin-request'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        children: [
          const _LocationArtwork(icon: Icons.near_me_rounded),
          const SizedBox(height: 22),
          Text(
            _copy(
              pt: 'Qual é sua cidade de origem?',
              es: '¿Cuál es tu ciudad de origen?',
              en: 'What is your origin city?',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            _copy(
              pt: 'Com sua autorização, usamos a localização para sugerir a cidade. Depois guardamos somente a cidade escolhida e um ponto aproximado do município — nunca a posição GPS exata. Você pode apagar isso nos Ajustes.',
              es: 'Con tu permiso, usamos la ubicación para sugerir la ciudad. Después guardamos solo la ciudad elegida y un punto aproximado del municipio, nunca la posición GPS exacta. Podés borrarlo en Ajustes.',
              en: 'With permission, we use location to suggest a city. We then keep only the chosen city and an approximate municipal point, never the exact GPS fix. You can delete it in Settings.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _InlineMessage(message: _error!),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isRequesting ? null : _requestLocation,
              icon: _isRequesting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                _copy(
                  pt: 'Usar minha localização',
                  es: 'Usar mi ubicación',
                  en: 'Use my location',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _openManualPicker,
              icon: const Icon(Icons.search_rounded),
              label: Text(
                _copy(
                  pt: 'Escolher outra cidade',
                  es: 'Elegir otra ciudad',
                  en: 'Choose another city',
                ),
              ),
            ),
          ),
          if (widget.locationController.isPermanentlyDenied)
            TextButton(
              onPressed: widget.locationController.openAppSettings,
              child: Text(
                _copy(
                  pt: 'Abrir ajustes de localização',
                  es: 'Abrir ajustes de ubicación',
                  en: 'Open location settings',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    final location = widget.locationController.savedLocation!;
    return SingleChildScrollView(
      key: const ValueKey('origin-confirm'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        children: [
          const _LocationArtwork(icon: Icons.location_on_rounded),
          const SizedBox(height: 22),
          Text(
            _copy(
              pt: 'Encontramos sua cidade',
              es: 'Encontramos tu ciudad',
              en: 'We found your city',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.tintedSurfaceFor(
                context,
                tint: AppColors.primary,
                lightColor: const Color(0xFFEAF4FF),
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.location_city_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.cityName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (location.stateName.isNotEmpty)
                        Text(
                          '${location.stateName} · Argentina',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSoftFor(context)),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _confirmCurrentCity,
              child: Text(
                _copy(
                  pt: 'Sim, esta é minha cidade',
                  es: 'Sí, esta es mi ciudad',
                  en: 'Yes, this is my city',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openManualPicker,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text(
                _copy(
                  pt: 'Quero escolher outra',
                  es: 'Quiero elegir otra',
                  en: 'Choose a different city',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualPicker() {
    return Padding(
      key: const ValueKey('origin-manual'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _step = _hasArgentineLocation
                      ? _OriginCityStep.confirm
                      : _OriginCityStep.request;
                }),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _copy(
                    pt: 'Escolha sua cidade na Argentina',
                    es: 'Elegí tu ciudad en Argentina',
                    en: 'Choose your city in Argentina',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: _copy(
                pt: 'Buscar cidade ou província',
                es: 'Buscar ciudad o provincia',
                en: 'Search city or province',
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: AppColors.surfaceMutedFor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoadingCatalog)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(child: _InlineMessage(message: _error!)),
            )
          else if (_visibleLocalities.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _copy(
                    pt: 'Nenhuma cidade encontrada.',
                    es: 'No encontramos ninguna ciudad.',
                    en: 'No cities found.',
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: _visibleLocalities.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.borderFor(context)),
                itemBuilder: (_, index) {
                  final locality = _visibleLocalities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      locality.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      locality.department.isEmpty
                          ? locality.province
                          : '${locality.province} · ${locality.department}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _select(locality),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _copy(
              pt: 'Fonte: API Georef oficial da República Argentina',
              es: 'Fuente: API Georef oficial de la República Argentina',
              en: 'Source: official Argentina Georef API',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationArtwork extends StatelessWidget {
  const _LocationArtwork({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 138,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.07),
            ),
          ),
          Container(
            width: 102,
            height: 102,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x550071E3),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const Positioned(
            right: 10,
            top: 24,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFF74B5FF),
              foregroundColor: Colors.white,
              child: Icon(Icons.auto_awesome_rounded, size: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
