import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

enum HousingType { temporary, permanent }

class HousingSelectionScreen extends StatelessWidget {
  const HousingSelectionScreen({
    required this.city,
    required this.onOpenRentalSearch,
    required this.onHelp,
    this.skipTypeSelection = false,
    this.preselectedType,
    super.key,
  });

  final City city;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final Future<void> Function() onHelp;
  final bool skipTypeSelection;
  final HousingType? preselectedType;

  @override
  Widget build(BuildContext context) {
    if (skipTypeSelection && preselectedType != null) {
      return switch (preselectedType!) {
        HousingType.temporary => TemporaryHousingScreen(
          city: city,
          onHelp: onHelp,
        ),
        HousingType.permanent => LongTermHousingScreen(
          city: city,
          onOpenRentalSearch: onOpenRentalSearch,
          onHelp: onHelp,
        ),
      };
    }

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: AppGlassHeader(
                    title: _text(
                      context,
                      pt: 'Moradia',
                      es: 'Vivienda',
                      en: 'Housing',
                    ),
                    onBack: () => Navigator.of(context).pop(),
                    onHelp: onHelp,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SelectionBanner(city: city),
                        const SizedBox(height: 16),
                        _TemporaryCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TemporaryHousingScreen(
                                  city: city,
                                  onHelp: onHelp,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _LongTermCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LongTermHousingScreen(
                                  city: city,
                                  onOpenRentalSearch: onOpenRentalSearch,
                                  onHelp: onHelp,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

class TemporaryHousingScreen extends StatefulWidget {
  const TemporaryHousingScreen({
    required this.city,
    required this.onHelp,
    super.key,
  });

  final City city;
  final Future<void> Function() onHelp;

  @override
  State<TemporaryHousingScreen> createState() => _TemporaryHousingScreenState();
}

class _TemporaryHousingScreenState extends State<TemporaryHousingScreen> {
  TemporaryHousingDuration _duration = TemporaryHousingDuration.oneMonth;
  int _selectedPortalIndex = 0;

  @override
  Widget build(BuildContext context) {
    final portals = <_TemporaryPortal>[
      _TemporaryPortal(
        name: 'Airbnb',
        emoji: '🏠',
        description: _text(
          context,
          pt: 'Apartamentos mobiliados',
          es: 'Departamentos amoblados',
          en: 'Furnished apartments',
        ),
        bgColor: const Color(0xFF1C0808),
        borderColor: const Color(0xFF4A0D0D),
        urlBuilder: (city, duration) =>
            PreparationResourceLinks.buildAirbnbSearch(city, duration),
      ),
      _TemporaryPortal(
        name: 'Booking',
        emoji: '🌐',
        description: _text(
          context,
          pt: 'Hoteis e apart-hoteis',
          es: 'Hoteles y apart-hoteles',
          en: 'Hotels and aparthotels',
        ),
        bgColor: const Color(0xFF08081C),
        borderColor: const Color(0xFF0D0D4A),
        urlBuilder: (city, duration) =>
            PreparationResourceLinks.buildBookingSearch(city, duration),
      ),
      _TemporaryPortal(
        name: 'Viva Real',
        emoji: '🏢',
        description: _text(
          context,
          pt: 'Aluguel por temporada',
          es: 'Alquiler temporal',
          en: 'Temporary rental',
        ),
        bgColor: const Color(0xFF0D1F38),
        borderColor: const Color(0xFF1D4A70),
        urlBuilder: (city, duration) =>
            PreparationResourceLinks.buildVivaRealTemporarySearch(
              city,
              duration,
            ),
      ),
      _TemporaryPortal(
        name: 'Zap Imoveis',
        emoji: '🔑',
        description: _text(
          context,
          pt: 'Temporada e mensal',
          es: 'Temporal y mensual',
          en: 'Monthly and seasonal',
        ),
        bgColor: const Color(0xFF0D1F38),
        borderColor: const Color(0xFF1D4A70),
        urlBuilder: (city, duration) =>
            PreparationResourceLinks.buildZapTemporarySearch(city, duration),
      ),
    ];
    final selectedPortal = portals[_selectedPortalIndex];

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: AppGlassHeader(
                    title: _text(
                      context,
                      pt: 'Temporaria',
                      es: 'Temporal',
                      en: 'Temporary',
                    ),
                    onBack: () => Navigator.of(context).pop(),
                    onHelp: widget.onHelp,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TemporaryHeader(city: widget.city),
                        const SizedBox(height: 14),
                        _DurationSelector(
                          value: _duration,
                          onChanged: (value) =>
                              setState(() => _duration = value),
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: portals.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.28,
                              ),
                          itemBuilder: (context, index) {
                            final portal = portals[index];
                            final selected = index == _selectedPortalIndex;
                            return _TemporaryPortalCard(
                              portal: portal,
                              selected: selected,
                              onTap: () =>
                                  setState(() => _selectedPortalIndex = index),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            final uri = selectedPortal.urlBuilder(
                              widget.city,
                              _duration,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PreparationWebViewPage(
                                  title:
                                      '${_text(context, pt: 'Moradia em', es: 'Vivienda en', en: 'Stay in')} ${widget.city.name}',
                                  uri: uri,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F6FEB),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _text(
                                    context,
                                    pt: 'Buscar em ${widget.city.name} - ${_durationLabel(context, _duration)}',
                                    es: 'Buscar en ${widget.city.name} - ${_durationLabel(context, _duration)}',
                                    en: 'Search in ${widget.city.name} - ${_durationLabel(context, _duration)}',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _text(
                              context,
                              pt: 'Abre no app ou site selecionado',
                              es: 'Abre en la app o sitio elegido',
                              en: 'Opens in the selected app or site',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
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

class LongTermHousingScreen extends StatelessWidget {
  const LongTermHousingScreen({
    required this.city,
    required this.onOpenRentalSearch,
    required this.onHelp,
    super.key,
  });

  final City city;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final Future<void> Function() onHelp;

  @override
  Widget build(BuildContext context) {
    final portals = <_LongTermPortal>[
      _LongTermPortal(
        name: 'Zap Imoveis',
        emoji: '🔑',
        description: _text(
          context,
          pt: 'Maior base de imoveis do Brasil',
          es: 'Base grande de inmuebles en Brasil',
          en: 'Large listing base in Brazil',
        ),
        provider: RentalProvider.zapImoveis,
      ),
      _LongTermPortal(
        name: 'Viva Real',
        emoji: '🏢',
        description: _text(
          context,
          pt: 'Fotos e plantas mais detalhadas',
          es: 'Fotos y planos mas detallados',
          en: 'More detailed photos and floor plans',
        ),
        provider: RentalProvider.vivaReal,
      ),
      _LongTermPortal(
        name: 'Chaves na Mao',
        emoji: '🗝️',
        description: _text(
          context,
          pt: 'Boa cobertura em varias cidades do Sul',
          es: 'Buena cobertura en varias ciudades del sur',
          en: 'Useful coverage across southern cities',
        ),
        provider: RentalProvider.chavesNaMao,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: AppGlassHeader(
                    title: _text(
                      context,
                      pt: 'Aluguel fixo',
                      es: 'Alquiler fijo',
                      en: 'Long-term rent',
                    ),
                    onBack: () => Navigator.of(context).pop(),
                    onHelp: onHelp,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LongTermHeader(city: city),
                        const SizedBox(height: 12),
                        _LongTermAlert(),
                        const SizedBox(height: 14),
                        for (final portal in portals) ...[
                          _LongTermPortalCard(
                            portal: portal,
                            onTap: () =>
                                onOpenRentalSearch(city, portal.provider),
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 14),
                        _ForeignTipsCard(),
                      ],
                    ),
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

class _SelectionBanner extends StatelessWidget {
  const _SelectionBanner({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2818),
        border: Border.all(color: const Color(0xFF1A4428)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏠', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${city.name} (${city.stateCode}) - ${_text(context, pt: 'cidade do seu plano', es: 'ciudad de tu plan', en: 'your plan city')}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF3FB950),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _text(
                    context,
                    pt: 'A maioria dos argentinos chega com moradia temporaria e assina contrato depois de conhecer os bairros. Esse costuma ser o caminho mais seguro para começar.',
                    es: 'La mayoria de los argentinos llega con vivienda temporal y firma contrato despues de conocer los barrios. Suele ser el camino mas seguro para arrancar.',
                    en: 'Most Argentine movers start with temporary housing and only sign a long contract after learning the neighborhoods. That is usually the safest path.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.5,
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

class _TemporaryCard extends StatelessWidget {
  const _TemporaryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F38),
          border: Border.all(color: const Color(0xFF1D4A70), width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4A70).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1A2E),
                    border: Border.all(color: const Color(0xFF1D4A70)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 10,
                        color: Color(0xFF58A6FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _text(
                          context,
                          pt: 'Recomendado para chegada',
                          es: 'Recomendado para llegar',
                          en: 'Recommended for arrival',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF58A6FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _text(
                    context,
                    pt: 'Moradia temporaria',
                    es: 'Vivienda temporal',
                    en: 'Temporary housing',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFF0F6FC),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _text(
                    context,
                    pt: 'Para os primeiros 30 a 90 dias. Sem contrato longo, sem fiador e com tempo para conhecer a cidade antes de decidir.',
                    es: 'Para los primeros 30 a 90 dias. Sin contrato largo, sin garante y con tiempo para conocer la ciudad antes de decidir.',
                    en: 'For the first 30 to 90 days. No long contract, no guarantor, and time to understand the city before deciding.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B949E),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStat(
                      context: context,
                      value: _text(
                        context,
                        pt: '1-3 meses',
                        es: '1-3 meses',
                        en: '1-3 months',
                      ),
                      label: _text(
                        context,
                        pt: 'duracao',
                        es: 'duracion',
                        en: 'length',
                      ),
                      color: const Color(0xFF58A6FF),
                    ),
                    const SizedBox(width: 6),
                    _buildStat(
                      context: context,
                      value: _text(
                        context,
                        pt: 'Sem fiador',
                        es: 'Sin garante',
                        en: 'No guarantor',
                      ),
                      label: '',
                      color: const Color(0xFF58A6FF),
                    ),
                    const SizedBox(width: 6),
                    _buildStat(
                      context: context,
                      value: _text(
                        context,
                        pt: 'Mobiliado',
                        es: 'Amoblado',
                        en: 'Furnished',
                      ),
                      label: '',
                      color: const Color(0xFF58A6FF),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F6FEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _text(
                          context,
                          pt: 'Buscar moradia temporaria',
                          es: 'Buscar vivienda temporal',
                          en: 'Search temporary housing',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LongTermCard extends StatelessWidget {
  const _LongTermCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border.all(color: const Color(0xFF1E2636)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1200),
                border: Border.all(color: const Color(0xFF3D2800)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 10,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _text(
                      context,
                      pt: 'Quando voce ja conhece a cidade',
                      es: 'Cuando ya conoces la ciudad',
                      en: 'When you already know the city',
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _text(
                context,
                pt: 'Aluguel definitivo',
                es: 'Alquiler definitivo',
                en: 'Long-term rental',
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFF0F6FC),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _text(
                context,
                pt: 'Contrato de 12 a 30 meses. Fica mais barato por mes, mas costuma exigir garantia, documentos e mais cuidado na assinatura.',
                es: 'Contrato de 12 a 30 meses. Suele ser mas barato por mes, pero normalmente pide garantia, documentos y mas cuidado al firmar.',
                en: 'A 12 to 30 month contract. Usually cheaper per month, but it often requires guarantees, documents, and more care before signing.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8B949E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                border: Border.all(color: const Color(0xFF2D333B)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _text(
                  context,
                  pt: 'Ver opcoes de aluguel fixo',
                  es: 'Ver opciones de alquiler fijo',
                  en: 'See long-term rental options',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF8B949E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemporaryHeader extends StatelessWidget {
  const _TemporaryHeader({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38),
        border: Border.all(color: const Color(0xFF1D3A5E)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_text(context, pt: 'Sua base em', es: 'Tu base en', en: 'Your base in')} ${city.name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFF0F6FC),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _text(
              context,
              pt: 'Sem contrato fixo. Mobiliado. Pode ajustar quando quiser.',
              es: 'Sin contrato fijo. Amoblado. Lo ajustas cuando quieras.',
              en: 'No fixed contract. Furnished. Easy to adjust as you settle in.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1220),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _text(
                      context,
                      pt: 'Airbnb costuma oferecer descontos para estadias longas de 28 dias ou mais. E um caminho muito usado na chegada.',
                      es: 'Airbnb suele ofrecer descuentos para estadias largas de 28 dias o mas. Es un camino muy usado al llegar.',
                      en: 'Airbnb often gives discounts on 28+ day stays. It is a common soft-landing option after arrival.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF58A6FF),
                      height: 1.4,
                    ),
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

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({required this.value, required this.onChanged});

  final TemporaryHousingDuration value;
  final ValueChanged<TemporaryHousingDuration> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in TemporaryHousingDuration.values)
          GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: option == value
                    ? const Color(0xFF0D2137)
                    : const Color(0xFF111827),
                border: Border.all(
                  color: option == value
                      ? const Color(0xFF1D4A70)
                      : const Color(0xFF1E2636),
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _durationLabel(context, option),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: option == value
                      ? const Color(0xFF58A6FF)
                      : const Color(0xFF4B5563),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TemporaryPortalCard extends StatelessWidget {
  const _TemporaryPortalCard({
    required this.portal,
    required this.selected,
    required this.onTap,
  });

  final _TemporaryPortal portal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: portal.bgColor,
          border: Border.all(
            color: selected ? const Color(0xFF58A6FF) : portal.borderColor,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(portal.emoji, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Text(
              portal.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFF0F6FC),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              portal.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8B949E),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LongTermHeader extends StatelessWidget {
  const _LongTermHeader({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final estimate = _estimatedRent(city.rentScore);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(color: const Color(0xFF1E2636)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_text(context, pt: 'Aluguel em', es: 'Alquiler en', en: 'Rent in')} ${city.name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFF0F6FC),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _text(
              context,
              pt: 'Contrato de 12 a 30 meses. Mais barato no longo prazo.',
              es: 'Contrato de 12 a 30 meses. Mas barato a largo plazo.',
              en: 'A 12 to 30 month contract. Usually cheaper long term.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  context: context,
                  value: estimate,
                  label: _text(
                    context,
                    pt: '1 quarto',
                    es: '1 dormitorio',
                    en: '1 bedroom',
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildStatChip(
                  context: context,
                  value: _text(
                    context,
                    pt: '3x caucao',
                    es: '3x deposito',
                    en: '3x deposit',
                  ),
                  label: _text(
                    context,
                    pt: 'entrada',
                    es: 'entrada',
                    en: 'entry',
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildStatChip(
                  context: context,
                  value: 'CPF',
                  label: _text(
                    context,
                    pt: 'necessario',
                    es: 'necesario',
                    en: 'required',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _estimatedRent(int rentScore) {
    final estimate = (2200 + ((100 - rentScore) * 18)).round().clamp(
      1200,
      3200,
    );
    final formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    ).format(estimate);
    return '$formatted/mes';
  }
}

class _LongTermAlert extends StatelessWidget {
  const _LongTermAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C0000),
        border: Border.all(color: const Color(0xFF4A0000)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    context,
                    pt: 'Antes de assinar qualquer contrato',
                    es: 'Antes de firmar cualquier contrato',
                    en: 'Before signing any contract',
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE24B4A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _text(
                    context,
                    pt: 'Como estrangeiro, voce normalmente vai precisar de CPF e de garantia, como fiador brasileiro ou seguro fianca. Nao assine sem ler as clausulas com calma.',
                    es: 'Como extranjero, normalmente vas a necesitar CPF y alguna garantia, como garante brasileno o seguro fianza. No firmes sin leer bien las clausulas.',
                    en: 'As a foreigner, you will usually need CPF and a guarantee, such as a Brazilian guarantor or rental insurance. Do not sign without reading the clauses carefully.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.45,
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

class _LongTermPortalCard extends StatelessWidget {
  const _LongTermPortalCard({required this.portal, required this.onTap});

  final _LongTermPortal portal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border.all(color: const Color(0xFF1E2636)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(portal.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFF0F6FC),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    portal.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B949E),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF1F6FEB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ForeignTipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1200),
        border: Border.all(color: const Color(0xFF3D2800)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                _text(
                  context,
                  pt: 'Dicas para estrangeiros',
                  es: 'Consejos para extranjeros',
                  en: 'Tips for foreigners',
                ),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TipRow(
            text: _text(
              context,
              pt: 'Sem fiador? Avalie seguro fianca ou caucao antes de negociar.',
              es: 'Sin garante? Evalua seguro fianza o deposito antes de negociar.',
              en: 'No guarantor? Check rental insurance or deposit paths first.',
            ),
          ),
          _TipRow(
            text: _text(
              context,
              pt: 'Nao precisa esperar a residencia pronta para começar a entender o mercado.',
              es: 'No hace falta esperar la residencia lista para empezar a entender el mercado.',
              en: 'You do not need to wait for full residence approval to start learning the market.',
            ),
          ),
          _TipRow(
            text: _text(
              context,
              pt: 'Exija recibo e contrato assinado. Nunca pague sem registro.',
              es: 'Exigi recibo y contrato firmado. Nunca pagues sin registro.',
              en: 'Always ask for receipts and a signed contract. Never pay without records.',
            ),
          ),
          _TipRow(
            text: _text(
              context,
              pt: 'Desconfie de valores muito baixos e pressa para fechar sem visita.',
              es: 'Desconfia de valores muy bajos y de la urgencia para cerrar sin visita.',
              en: 'Be careful with prices that are too low and pressure to close without a visit.',
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 5, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8B949E),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildStat({
  required BuildContext context,
  required String value,
  required String label,
  required Color color,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: _housingTextStyle(
              context,
              base: Theme.of(context).textTheme.labelLarge,
              color: color == const Color(0xFF58A6FF)
                  ? const Color(0xFFF0F6FC)
                  : color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
            ),
        ],
      ),
    ),
  );
}

Widget _buildStatChip({
  required BuildContext context,
  required String value,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF1C2128),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF2D333B)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFFF0F6FC),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    ),
  );
}

TextStyle? _housingTextStyle(
  BuildContext context, {
  TextStyle? base,
  Color? color,
  FontWeight? fontWeight,
}) {
  return (base ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
    color: color,
    fontWeight: fontWeight,
  );
}

String _durationLabel(BuildContext context, TemporaryHousingDuration value) {
  return switch (value) {
    TemporaryHousingDuration.oneWeek => _text(
      context,
      pt: '7-14 dias',
      es: '7-14 dias',
      en: '7-14 days',
    ),
    TemporaryHousingDuration.oneMonth => _text(
      context,
      pt: '1 mes',
      es: '1 mes',
      en: '1 month',
    ),
    TemporaryHousingDuration.twoThreeMonths => _text(
      context,
      pt: '2-3 meses',
      es: '2-3 meses',
      en: '2-3 months',
    ),
  };
}

String _text(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

class _TemporaryPortal {
  const _TemporaryPortal({
    required this.name,
    required this.emoji,
    required this.description,
    required this.bgColor,
    required this.borderColor,
    required this.urlBuilder,
  });

  final String name;
  final String emoji;
  final String description;
  final Color bgColor;
  final Color borderColor;
  final Uri Function(City city, TemporaryHousingDuration duration) urlBuilder;
}

class _LongTermPortal {
  const _LongTermPortal({
    required this.name,
    required this.emoji,
    required this.description,
    required this.provider,
  });

  final String name;
  final String emoji;
  final String description;
  final RentalProvider provider;
}
