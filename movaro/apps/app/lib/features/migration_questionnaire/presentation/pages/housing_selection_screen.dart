import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
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
                    title: context.l10n.housingSelectionTitle,
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
        name: 'Hostelworld',
        emoji: '🛏️',
        description: context.l10n.housingTemporaryPortalHostelworld,
        bgColor: const Color(0xFF0A1808),
        borderColor: const Color(0xFF1A3A10),
        urlBuilder: (city, _) =>
            PreparationResourceLinks.buildHostelworldSearch(city),
      ),
      _TemporaryPortal(
        name: 'Airbnb',
        emoji: '🏠',
        description: context.l10n.housingTemporaryPortalAirbnb,
        bgColor: const Color(0xFF1C0808),
        borderColor: const Color(0xFF4A0D0D),
        urlBuilder: (city, duration) =>
            PreparationResourceLinks.buildAirbnbSearch(city, duration),
      ),
      _TemporaryPortal(
        name: 'Booking',
        emoji: '🌐',
        description: context.l10n.housingTemporaryPortalBooking,
        bgColor: const Color(0xFF08081C),
        borderColor: const Color(0xFF0D0D4A),
        urlBuilder: (city, duration) =>
            PreparationResourceLinks.buildBookingSearch(city, duration),
      ),
      _TemporaryPortal(
        name: 'QuintoAndar',
        emoji: '⭐',
        description: context.l10n.housingLongTermPortalQuintoAndar,
        bgColor: const Color(0xFF17120A),
        borderColor: const Color(0xFF5A451B),
        urlBuilder: (city, _) => PreparationResourceLinks.buildQuintoAndarSearch(
          city,
        ),
      ),
      _TemporaryPortal(
        name: 'Viva Real',
        emoji: '🏢',
        description: context.l10n.housingTemporaryPortalVivaReal,
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
        description: context.l10n.housingTemporaryPortalZap,
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
                    title: context.l10n.housingTemporaryTitle,
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
                                  title: context.l10n.housingStayInCityTitle(
                                    widget.city.name,
                                  ),
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
                                  context.l10n.housingTemporarySearchAction(
                                    widget.city.name,
                                    _durationLabel(context, _duration),
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
                            context.l10n.housingOpenSelectedSourceHint,
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
        name: 'QuintoAndar',
        emoji: '⭐',
        description: context.l10n.housingLongTermPortalQuintoAndar,
        provider: null,
        customUrl: (city) =>
            PreparationResourceLinks.buildQuintoAndarSearch(city),
        isRecommended: true,
      ),
      _LongTermPortal(
        name: 'Flatio',
        emoji: '🌐',
        description: context.l10n.housingLongTermPortalFlatio,
        provider: null,
        customUrl: (city) => PreparationResourceLinks.buildFlatioSearch(city),
      ),
      _LongTermPortal(
        name: 'Zap Imoveis',
        emoji: '🔑',
        description: context.l10n.housingLongTermPortalZap,
        provider: RentalProvider.zapImoveis,
      ),
      _LongTermPortal(
        name: 'Viva Real',
        emoji: '🏢',
        description: context.l10n.housingLongTermPortalVivaReal,
        provider: RentalProvider.vivaReal,
      ),
      _LongTermPortal(
        name: 'Chaves na Mao',
        emoji: '🗝️',
        description: context.l10n.housingLongTermPortalChaves,
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
                    title: context.l10n.housingLongTermTitle,
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
                            onTap: () {
                              if (portal.customUrl != null) {
                                final uri = portal.customUrl!(city);
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PreparationWebViewPage(
                                      title: portal.name,
                                      uri: uri,
                                    ),
                                  ),
                                );
                              } else if (portal.provider != null) {
                                onOpenRentalSearch(city, portal.provider!);
                              }
                            },
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
                  context.l10n.housingPlanCityBanner(city.name, city.stateCode),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF3FB950),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.housingPlanCityBannerBody,
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
                        context.l10n.housingTemporaryBadge,
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
                  context.l10n.housingTemporaryCardTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFF0F6FC),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.housingTemporaryCardBody,
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
                      value: context.l10n.housingTemporaryStatDurationValue,
                      label: context.l10n.housingTemporaryStatDurationLabel,
                      color: const Color(0xFF58A6FF),
                    ),
                    const SizedBox(width: 6),
                    _buildStat(
                      context: context,
                      value: context.l10n.housingTemporaryStatNoGuarantor,
                      label: '',
                      color: const Color(0xFF58A6FF),
                    ),
                    const SizedBox(width: 6),
                    _buildStat(
                      context: context,
                      value: context.l10n.housingTemporaryStatFurnished,
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
                        context.l10n.housingTemporaryCardAction,
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
                    context.l10n.housingLongTermBadge,
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
              context.l10n.housingLongTermCardTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFF0F6FC),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              context.l10n.housingLongTermCardBody,
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
                context.l10n.housingLongTermCardAction,
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
            context.l10n.housingTemporaryHeaderTitle(city.name),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFF0F6FC),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.housingTemporaryHeaderBody,
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
                    context.l10n.housingTemporaryAirbnbTip,
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
            context.l10n.housingLongTermHeaderTitle(city.name),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFF0F6FC),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.housingLongTermHeaderBody,
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
                  label: context.l10n.housingLongTermStatBedroom,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildStatChip(
                  context: context,
                  value: context.l10n.housingLongTermStatEntryValue,
                  label: context.l10n.housingLongTermStatEntry,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildStatChip(
                  context: context,
                  value: 'CPF',
                  label: context.l10n.housingLongTermStatRequired,
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
                  context.l10n.housingLongTermAlertTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE24B4A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.housingLongTermAlertBody,
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
          color: portal.isRecommended
              ? const Color(0xFF071A2E)
              : const Color(0xFF111827),
          border: Border.all(
            color: portal.isRecommended
                ? const Color(0xFF1F6FEB).withValues(alpha: 0.5)
                : const Color(0xFF1E2636),
          ),
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
                  Row(
                    children: [
                      Text(
                        portal.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFFF0F6FC),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (portal.isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1F6FEB,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.housingLongTermForeignersBadge,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFF58A6FF),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ],
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
                  context.l10n.housingForeignTipsTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TipRow(
            text: context.l10n.housingForeignTipOne,
          ),
          _TipRow(
            text: context.l10n.housingForeignTipTwo,
          ),
          _TipRow(
            text: context.l10n.housingForeignTipThree,
          ),
          _TipRow(
            text: context.l10n.housingForeignTipFour,
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
    TemporaryHousingDuration.oneWeek => context.l10n.housingDurationOneWeek,
    TemporaryHousingDuration.oneMonth => context.l10n.housingDurationOneMonth,
    TemporaryHousingDuration.twoThreeMonths =>
      context.l10n.housingDurationTwoThreeMonths,
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
    this.provider,
    this.customUrl,
    this.isRecommended = false,
  });

  final String name;
  final String emoji;
  final String description;
  final RentalProvider? provider;
  final Uri Function(City city)? customUrl;
  final bool isRecommended;
}
