import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';

class JourneySetupPage extends StatefulWidget {
  const JourneySetupPage({
    required this.catalogRepository,
    required this.journeyContextController,
    super.key,
  });

  final CatalogRepository catalogRepository;
  final JourneyContextController journeyContextController;

  @override
  State<JourneySetupPage> createState() => _JourneySetupPageState();
}

class _JourneySetupPageState extends State<JourneySetupPage> {
  String? _originId;
  String? _destinationId;

  @override
  void initState() {
    super.initState();
    _originId = widget.journeyContextController.originCountryId;
    _destinationId = widget.journeyContextController.destinationCountryId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.journeyContextController.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _originId = widget.journeyContextController.originCountryId;
        _destinationId = widget.journeyContextController.destinationCountryId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.journeyContextController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final countries = controller.countries;
        final selectedOrigin = countries
            .where((country) => country.id == _originId)
            .toList();
        final selectedDestination = countries
            .where((country) => country.id == _destinationId)
            .toList();

        final origin = selectedOrigin.isEmpty ? null : selectedOrigin.first;
        final destination = selectedDestination.isEmpty
            ? null
            : selectedDestination.first;
        final canContinue =
            origin != null &&
            destination != null &&
            controller.canUseAsOrigin(origin) &&
            controller.canUseAsDestination(destination);

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 24,
                      ),
                      children: [
                        AppGlassHeader(
                          title: l10n.journeySetupPageTitle,
                          onBack: Navigator.canPop(context)
                              ? () => Navigator.maybePop(context)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        FrostedPanel(
                          padding: const EdgeInsets.all(32),
                          backgroundColor: const Color(0xB30B1320),
                          borderColor: Colors.white.withValues(alpha: 0.12),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.heroStart,
                              AppColors.heroMiddle,
                              AppColors.heroEnd,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MovaroLogo(
                                markSize: 20,
                                textColor: Colors.white,
                                markColor: Colors.white,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.journeySetupHeroTitle,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 700),
                                child: Text(
                                  l10n.journeySetupHeroBody,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                        height: 1.45,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 920;
                            final panelWidth = wide
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: panelWidth,
                                  child: _CountrySelectionPanel(
                                    step: '01',
                                    title: l10n.journeyOriginTitle,
                                    description: l10n.journeyOriginBody,
                                    countries: countries,
                                    selectedCountryId: _originId,
                                    isSelectable: controller.canUseAsOrigin,
                                    onSelect: (countryId) {
                                      setState(() {
                                        _originId = countryId;
                                        if (_destinationId == countryId) {
                                          _destinationId = null;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: panelWidth,
                                  child: _CountrySelectionPanel(
                                    step: '02',
                                    title: l10n.journeyDestinationTitle,
                                    description: l10n.journeyDestinationBody,
                                    countries: countries,
                                    selectedCountryId: _destinationId,
                                    isSelectable: controller.canUseAsDestination,
                                    onSelect: (countryId) {
                                      setState(() {
                                        _destinationId = countryId;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        FrostedPanel(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.journeySummaryTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                origin != null && destination != null
                                    ? l10n.journeySummaryValue(
                                        '${origin.flagEmoji} ${origin.name}',
                                        '${destination.flagEmoji} ${destination.name}',
                                      )
                                    : l10n.journeySummaryPlaceholder,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.journeyAvailabilityNote,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                      height: 1.45,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: canContinue
                                    ? () async {
                                        await controller.completeJourney(
                                          originCountryId: _originId!,
                                          destinationCountryId: _destinationId!,
                                        );
                                        if (!context.mounted) {
                                          return;
                                        }
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.publicHome,
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(l10n.journeyContinueAction),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountrySelectionPanel extends StatelessWidget {
  const _CountrySelectionPanel({
    required this.step,
    required this.title,
    required this.description,
    required this.countries,
    required this.selectedCountryId,
    required this.isSelectable,
    required this.onSelect,
  });

  final String step;
  final String title;
  final String description;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final bool Function(CatalogCountry country) isSelectable;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(step, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          for (final country in countries) ...[
            _CountryChoiceCard(
              country: country,
              isSelected: selectedCountryId == country.id,
              isEnabled: isSelectable(country),
              onTap: isSelectable(country) ? () => onSelect(country.id) : null,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _CountryChoiceCard extends StatelessWidget {
  const _CountryChoiceCard({
    required this.country,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final CatalogCountry country;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.surfaceFor(context).withValues(
                  alpha: isEnabled ? 0.62 : 0.35,
                ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderFor(context).withValues(
                    alpha: isEnabled ? 1 : 0.45,
                  ),
          ),
        ),
        child: Row(
          children: [
            Text(
              country.flagEmoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isEnabled
                          ? AppColors.textPrimaryFor(context)
                          : AppColors.textSoftFor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnabled
                        ? context.l10n.journeyAvailableNowLabel
                        : context.l10n.journeyComingSoonLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            else if (!isEnabled)
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textSoftFor(context),
              ),
          ],
        ),
      ),
    );
  }
}
