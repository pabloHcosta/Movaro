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
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String? _originId;
  String? _destinationId;

  @override
  void initState() {
    super.initState();
    _originId = widget.journeyContextController.originCountryId;
    _destinationId = widget.journeyContextController.destinationCountryId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.journeyContextController.initialize();
      if (!mounted) return;
      setState(() {
        _originId = widget.journeyContextController.originCountryId;
        _destinationId = widget.journeyContextController.destinationCountryId;
      });
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.journeyContextController;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, _pageController]),
      builder: (context, _) {
        final countries = controller.countries;
        final originCountries = _originOptions(countries);
        final destinationCountries = _destinationOptions(countries);
        final origin = countries.where((c) => c.id == _originId).firstOrNull;
        final destination = countries
            .where((c) => c.id == _destinationId)
            .firstOrNull;

        final canFinish =
            origin != null &&
            destination != null &&
            _isOriginEnabled(origin) &&
            _isDestinationEnabled(destination);

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Column(
                  children: [
                    AppGlassHeader(
                      title: l10n.journeySetupPageTitle,
                      onBack: _currentStep > 0
                          ? _prevStep
                          : (Navigator.canPop(context)
                                ? () => Navigator.maybePop(context)
                                : null),
                    ),

                    // Indicador de Progresso Moderno
                    _StepIndicator(currentStep: _currentStep),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentStep = index),
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // PASSO 1: ORIGEM
                          _buildStepWrapper(
                            child: _CountrySelectionPanel(
                              title: l10n.journeyOriginTitle,
                              description: l10n.journeyOriginBody,
                              countries: originCountries,
                              selectedCountryId: _originId,
                              isSelectable: _isOriginEnabled,
                              onSelect: (id) {
                                setState(() {
                                  _originId = id;
                                  if (_destinationId == id) {
                                    _destinationId = null;
                                  }
                                });
                                Future.delayed(
                                  const Duration(milliseconds: 350),
                                  _nextStep,
                                );
                              },
                            ),
                          ),

                          // PASSO 2: DESTINO
                          _buildStepWrapper(
                            child: _CountrySelectionPanel(
                              title: l10n.journeyDestinationTitle,
                              description: l10n.journeyDestinationBody,
                              countries: destinationCountries,
                              selectedCountryId: _destinationId,
                              isSelectable: _isDestinationEnabled,
                              onSelect: (id) {
                                setState(() => _destinationId = id);
                                Future.delayed(
                                  const Duration(milliseconds: 350),
                                  _nextStep,
                                );
                              },
                            ),
                          ),

                          // PASSO 3: RESUMO FINAL
                          _buildStepWrapper(
                            child: _SummaryStep(
                              origin: origin,
                              destination: destination,
                              onConfirm: canFinish
                                  ? () async {
                                      await controller.completeJourney(
                                        originCountryId: _originId!,
                                        destinationCountryId: _destinationId!,
                                      );
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.publicHome,
                                        );
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepWrapper({required Widget child}) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.pageHorizontalPadding,
        12,
        context.pageHorizontalPadding,
        24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      ),
    );
  }

  List<CatalogCountry> _originOptions(List<CatalogCountry> countries) {
    const desiredOrder = ['argentina', 'chile', 'uruguai', 'paraguai'];
    return _orderedCountries(countries, desiredOrder);
  }

  List<CatalogCountry> _destinationOptions(List<CatalogCountry> countries) {
    const desiredOrder = [
      'brasil',
      'argentina',
      'chile',
      'uruguai',
      'paraguai',
    ];
    return _orderedCountries(
      countries,
      desiredOrder.where((countryId) => countryId != _originId).toList(),
    );
  }

  List<CatalogCountry> _orderedCountries(
    List<CatalogCountry> countries,
    List<String> ids,
  ) {
    final byId = {for (final country in countries) country.id: country};
    return ids.map((id) => byId[id]).whereType<CatalogCountry>().toList();
  }

  bool _isOriginEnabled(CatalogCountry country) => country.id == 'argentina';

  bool _isDestinationEnabled(CatalogCountry country) =>
      country.id == 'brasil' && country.id != _originId;
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final active = index <= currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: active ? 48 : 12,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  final CatalogCountry? origin;
  final CatalogCountry? destination;
  final VoidCallback? onConfirm;

  const _SummaryStep({this.origin, this.destination, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const MovaroLogo(markSize: 24),
              const SizedBox(height: 24),
              Text(
                l10n.journeySummaryTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCountryPreview(origin),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  _buildCountryPreview(destination),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.journeyAvailabilityNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.rocket_launch_rounded),
            label: Text(
              l10n.journeyContinueAction,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPreview(CatalogCountry? country) {
    return Column(
      children: [
        Text(country?.flagEmoji ?? '', style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          country?.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }
}

class _CountrySelectionPanel extends StatelessWidget {
  const _CountrySelectionPanel({
    required this.title,
    required this.description,
    required this.countries,
    required this.selectedCountryId,
    required this.isSelectable,
    required this.onSelect,
  });

  final String title;
  final String description;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final bool Function(CatalogCountry country) isSelectable;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSoftFor(context),
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            mainAxisExtent: 96,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: countries.length,
          itemBuilder: (context, index) {
            final country = countries[index];
            return _CountryChoiceCard(
              country: country,
              isSelected: selectedCountryId == country.id,
              isEnabled: isSelectable(country),
              availabilityLabel: isSelectable(country)
                  ? l10n.journeyAvailableNowLabel
                  : l10n.journeyComingSoonLabel,
              onTap: isSelectable(country) ? () => onSelect(country.id) : null,
            );
          },
        ),
      ],
    );
  }
}

class _CountryChoiceCard extends StatelessWidget {
  const _CountryChoiceCard({
    required this.country,
    required this.isSelected,
    required this.isEnabled,
    required this.availabilityLabel,
    required this.onTap,
  });

  final CatalogCountry country;
  final bool isSelected;
  final bool isEnabled;
  final String availabilityLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceFor(
                  context,
                ).withValues(alpha: isEnabled ? 0.65 : 0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderFor(context).withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(country.flagEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isEnabled
                          ? AppColors.textPrimaryFor(context)
                          : AppColors.textSoftFor(context),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    availabilityLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isEnabled
                          ? AppColors.primary
                          : AppColors.textSoftFor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            else if (!isEnabled)
              const Icon(Icons.lock_outline_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
