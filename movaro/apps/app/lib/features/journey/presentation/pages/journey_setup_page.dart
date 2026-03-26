import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/features/journey/country_coverage.dart';
import 'package:movaro_app/features/journey/detected_location.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/journey/journey_country_metadata.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';

class JourneySetupPage extends StatefulWidget {
  const JourneySetupPage({
    required this.catalogRepository,
    required this.journeyContextController,
    required this.locationController,
    super.key,
  });

  final CatalogRepository catalogRepository;
  final JourneyContextController journeyContextController;
  final LocationController locationController;

  @override
  State<JourneySetupPage> createState() => _JourneySetupPageState();
}

class _JourneySetupPageState extends State<JourneySetupPage> {
  static const _helpPreferenceKey = 'journey_setup';
  String? _originId;
  String? _destinationId;
  bool _didTryAutoHelp = false;

  @override
  void initState() {
    super.initState();
    _originId = widget.journeyContextController.originCountryId;
    _destinationId = widget.journeyContextController.destinationCountryId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.catalogRepository.getCountries();
      await widget.journeyContextController.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _originId = widget.journeyContextController.originCountryId;
        _destinationId = widget.journeyContextController.destinationCountryId;
      });
      await _maybeAutoSelectSingleRoute();
      await _maybeShowHelp();
    });
  }

  Future<void> _maybeAutoSelectSingleRoute() async {
    final controller = widget.journeyContextController;
    final availableOrigins = controller.availableOrigins
        .where((country) => country.coverage.canPlanAsOrigin)
        .toList(growable: false);
    final availableDestinations = controller.availableDestinations
        .where((country) => country.coverage.canPlanAsDestination)
        .toList(growable: false);

    if (availableOrigins.length != 1 || availableDestinations.length != 1) {
      return;
    }

    final origin = availableOrigins.first;
    final destination = availableDestinations.first;
    final supportsRoute = origin.coverage.supportsDestination(destination.id);
    if (!supportsRoute) {
      return;
    }

    await controller.completeJourney(
      originCountryId: origin.id,
      destinationCountryId: destination.id,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _originId = origin.id;
      _destinationId = destination.id;
    });
    Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
  }

  Future<void> _maybeShowHelp() async {
    if (_didTryAutoHelp) {
      return;
    }
    _didTryAutoHelp = true;
    await maybeShowContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _helpContent(context),
    );
  }

  Future<void> _showHelp() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _helpContent(context),
    );
  }

  Future<void> _openCountryPicker({
    required String title,
    required List<CatalogCountry> countries,
    required String? selectedCountryId,
    required String Function(CatalogCountry country) availabilityLabelFor,
    required bool Function(CatalogCountry country) isSelectable,
    required ValueChanged<CatalogCountry> onSelect,
  }) async {
    final selected = await showModalBottomSheet<CatalogCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CountryPickerSheet(
        title: title,
        countries: countries,
        selectedCountryId: selectedCountryId,
        availabilityLabelFor: availabilityLabelFor,
        isSelectable: isSelectable,
      ),
    );

    if (selected == null) {
      return;
    }

    onSelect(selected);
  }

  ContextualHelpContent _helpContent(BuildContext context) {
    final l10n = context.l10n;
    return ContextualHelpContent(
      eyebrow: l10n.journeySetupPageTitle,
      contextIcon: Icons.route_outlined,
      title: l10n.journeySetupGuideTitle(),
      body: l10n.journeySetupGuideBody(),
      steps: [
        FeatureGuideStep(
          number: '1',
          title: l10n.journeySetupGuideStepOneTitle(),
          body: l10n.journeySetupGuideStepOneBody(),
        ),
        FeatureGuideStep(
          number: '2',
          title: l10n.journeySetupGuideStepTwoTitle(),
          body: l10n.journeySetupGuideStepTwoBody(),
        ),
        FeatureGuideStep(
          number: '3',
          title: l10n.journeySetupGuideStepThreeTitle(),
          body: l10n.journeySetupGuideStepThreeBody(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.journeyContextController;
    final l10n = context.l10n;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final origins = controller.availableOrigins
            .where((country) => country.coverage.canPlanAsOrigin)
            .toList(growable: false);
        final destinations = controller.availableDestinations
            .where((country) => country.coverage.canPlanAsDestination)
            .toList(growable: false);
        final selectedOrigin = origins
            .where((c) => c.id == _originId)
            .firstOrNull;
        final selectedDestination = destinations
            .where((c) => c.id == _destinationId)
            .firstOrNull;
        final canContinue = controller.canEnterQuestionnaire;
        final routeSupported = controller.isRouteSupported(
          originCountryId: _originId,
          destinationCountryId: _destinationId,
        );

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Column(
                  children: [
                    AppGlassHeader(
                      title: l10n.journeySetupPageTitle,
                      onBack: Navigator.canPop(context)
                          ? () => Navigator.maybePop(context)
                          : null,
                      onHelp: _showHelp,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          12,
                          context.pageHorizontalPadding,
                          24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _IntroHero(
                                  selectedDestination: selectedDestination,
                                  selectedOrigin: selectedOrigin,
                                ),
                                const SizedBox(height: 16),
                                _SelectorPanel(
                                  title: l10n.journeyDestinationSectionTitle,
                                  body: l10n.journeyDestinationSectionBody,
                                  pickerTitle:
                                      l10n.journeyPickerChooseDestinationTitle,
                                  countries: destinations,
                                  selectedCountryId: _destinationId,
                                  availabilityLabelFor: (country) =>
                                      _coverageLabel(
                                        context,
                                        country.coverage.destinationStatus,
                                      ),
                                  isSelectable:
                                      controller.canChooseAsDestination,
                                  useQuickChoices: destinations.length <= 4,
                                  onOpenPicker: () => _openCountryPicker(
                                    title: l10n
                                        .journeyPickerChooseDestinationTitle,
                                    countries: destinations,
                                    selectedCountryId: _destinationId,
                                    availabilityLabelFor: (country) =>
                                        _coverageLabel(
                                          context,
                                          country.coverage.destinationStatus,
                                        ),
                                    isSelectable:
                                        controller.canChooseAsDestination,
                                    onSelect: (country) async {
                                      setState(() {
                                        _destinationId = country.id;
                                      });
                                      await controller.setDestinationCountry(
                                        country.id,
                                      );
                                    },
                                  ),
                                  onTap: (country) async {
                                    setState(() {
                                      _destinationId = country.id;
                                    });
                                    await controller.setDestinationCountry(
                                      country.id,
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                _SelectorPanel(
                                  title: l10n.journeyOriginSectionTitle,
                                  body: l10n.journeyOriginSectionBody,
                                  pickerTitle:
                                      l10n.journeyPickerChooseOriginTitle,
                                  countries: origins,
                                  selectedCountryId: _originId,
                                  onClear: _originId == null
                                      ? null
                                      : () async {
                                          await controller.clearOriginCountry();
                                          if (!mounted) {
                                            return;
                                          }
                                          setState(() {
                                            _originId = null;
                                          });
                                        },
                                  availabilityLabelFor: (country) =>
                                      _coverageLabel(
                                        context,
                                        country.coverage.originStatus,
                                      ),
                                  isSelectable: controller.canChooseAsOrigin,
                                  onOpenPicker: () => _openCountryPicker(
                                    title: l10n.journeyPickerChooseOriginTitle,
                                    countries: origins,
                                    selectedCountryId: _originId,
                                    availabilityLabelFor: (country) =>
                                        _coverageLabel(
                                          context,
                                          country.coverage.originStatus,
                                        ),
                                    isSelectable: controller.canChooseAsOrigin,
                                    onSelect: (country) async {
                                      setState(() {
                                        _originId = country.id;
                                      });
                                      await controller.setOriginCountry(
                                        country.id,
                                      );
                                    },
                                  ),
                                  onTap: (country) async {
                                    setState(() {
                                      _originId = country.id;
                                    });
                                    await controller.setOriginCountry(
                                      country.id,
                                    );
                                  },
                                  footer: _OriginAssistSection(
                                    controller: controller,
                                    onOpenPicker: () => _openCountryPicker(
                                      title:
                                          l10n.journeyPickerChooseOriginTitle,
                                      countries: origins,
                                      selectedCountryId: _originId,
                                      availabilityLabelFor: (country) =>
                                          _coverageLabel(
                                            context,
                                            country.coverage.originStatus,
                                          ),
                                      isSelectable:
                                          controller.canChooseAsOrigin,
                                      onSelect: (country) async {
                                        setState(() {
                                          _originId = country.id;
                                        });
                                        await controller.setOriginCountry(
                                          country.id,
                                        );
                                      },
                                    ),
                                    onConfirmDetectedOrigin: () async {
                                      await controller
                                          .confirmDetectedCountryAsOrigin();
                                      if (!mounted) {
                                        return;
                                      }
                                      setState(() {
                                        _originId = controller.originCountryId;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _CoveragePanel(
                                  selectedOrigin: selectedOrigin,
                                  selectedDestination: selectedDestination,
                                  detectedLocation: controller.detectedLocation,
                                  routeSupported: routeSupported,
                                  onChooseSupportedRoute: () {
                                    setState(() {
                                      _originId = null;
                                    });
                                    controller.clearOriginCountry();
                                  },
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: canContinue
                                        ? () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              AppRoutes.migrationQuestionnaire,
                                            );
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    label: Text(
                                      canContinue
                                          ? l10n.journeyEntryContinueAction
                                          : l10n.journeyEntryStartAction,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.explore,
                                        ),
                                        child: Text(
                                          l10n.journeyCoverageBrowseAction,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.documentationGuide,
                                          arguments: DocumentationGuideSection
                                              .documents,
                                        ),
                                        child: Text(
                                          l10n.journeyCoverageContentAction,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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

  String _coverageLabel(BuildContext context, CoverageStatus status) {
    return switch (status) {
      CoverageStatus.full => context.l10n.journeyCoverageFull,
      CoverageStatus.partial => context.l10n.journeyCoveragePartial,
      CoverageStatus.unsupported => context.l10n.journeyCoverageUnsupported,
    };
  }
}

class _IntroHero extends StatelessWidget {
  const _IntroHero({
    required this.selectedDestination,
    required this.selectedOrigin,
  });

  final CatalogCountry? selectedDestination;
  final CatalogCountry? selectedOrigin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MovaroLogo(markSize: 24),
          const SizedBox(height: 18),
          Text(
            l10n.journeyEntryDynamicTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatusChip(
                icon: Icons.flag_rounded,
                label: selectedDestination == null
                    ? l10n.journeyEntryDestinationLabel
                    : l10n.journeyEntrySelectedDestination(
                        selectedDestination!.name,
                      ),
              ),
              _HeroStatusChip(
                icon: Icons.my_location_rounded,
                label: selectedOrigin == null
                    ? l10n.journeyEntryOriginPending
                    : '${l10n.journeyOriginSectionTitle}: ${selectedOrigin!.name}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatusChip extends StatelessWidget {
  const _HeroStatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OriginAssistSection extends StatelessWidget {
  const _OriginAssistSection({
    required this.controller,
    required this.onOpenPicker,
    required this.onConfirmDetectedOrigin,
  });

  final JourneyContextController controller;
  final VoidCallback onOpenPicker;
  final Future<void> Function() onConfirmDetectedOrigin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.locationPermission,
                arguments: const LocationPermissionScreenArgs(
                  returnToPrevious: true,
                ),
              ),
              icon: const Icon(Icons.my_location_rounded),
              label: Text(context.l10n.journeyEntryUseLocationAction),
            ),
            TextButton(
              onPressed: onOpenPicker,
              child: Text(context.l10n.journeyEntryManualAction),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LocationAssistState(
          controller: controller,
          onConfirmDetectedOrigin: onConfirmDetectedOrigin,
        ),
      ],
    );
  }
}

class _LocationAssistState extends StatelessWidget {
  const _LocationAssistState({
    required this.controller,
    required this.onConfirmDetectedOrigin,
  });

  final JourneyContextController controller;
  final Future<void> Function() onConfirmDetectedOrigin;

  @override
  Widget build(BuildContext context) {
    final detected = controller.detectedLocation;

    if (!controller.hasDetectedLocation && !controller.isDetectingLocation) {
      return const SizedBox.shrink();
    }

    if (controller.isDetectingLocation) {
      return const LinearProgressIndicator();
    }

    if (detected != null) {
      return _DetectedLocationCard(
        location: detected,
        canConfirmOrigin: detected.hasMatchedCountry,
        onConfirmOrigin: onConfirmDetectedOrigin,
      );
    }

    return _LocationErrorState(
      state: controller.detectedLocationState,
      onRetry: controller.requestDetectedLocation,
    );
  }
}

class _DetectedLocationCard extends StatelessWidget {
  const _DetectedLocationCard({
    required this.location,
    required this.canConfirmOrigin,
    required this.onConfirmOrigin,
  });

  final DetectedLocation location;
  final bool canConfirmOrigin;
  final Future<void> Function() onConfirmOrigin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parts = [
      if ((location.city ?? '').isNotEmpty) location.city!,
      if ((location.region ?? '').isNotEmpty) location.region!,
      location.countryName,
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.journeyDetectedLocationLabel(parts.join(' · ')),
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (canConfirmOrigin)
                FilledButton(
                  onPressed: onConfirmOrigin,
                  child: Text(
                    l10n.journeyDetectedConfirmAction(location.countryName),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationErrorState extends StatelessWidget {
  const _LocationErrorState({required this.state, required this.onRetry});

  final DetectedLocationRequestState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.journeyLocationFallbackTitle,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: onRetry,
                child: Text(l10n.journeyLocationRetryAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectorPanel extends StatelessWidget {
  const _SelectorPanel({
    required this.title,
    required this.body,
    required this.pickerTitle,
    required this.countries,
    required this.selectedCountryId,
    required this.availabilityLabelFor,
    required this.isSelectable,
    required this.onOpenPicker,
    required this.onTap,
    this.onClear,
    this.useQuickChoices = false,
    this.footer,
  });

  final String title;
  final String body;
  final String pickerTitle;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final String Function(CatalogCountry country) availabilityLabelFor;
  final bool Function(CatalogCountry country) isSelectable;
  final VoidCallback onOpenPicker;
  final ValueChanged<CatalogCountry> onTap;
  final VoidCallback? onClear;
  final bool useQuickChoices;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    CatalogCountry? selectedCountry;
    for (final country in countries) {
      if (country.id == selectedCountryId) {
        selectedCountry = country;
        break;
      }
    }

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (onClear != null)
                TextButton(
                  onPressed: onClear,
                  child: Text(context.l10n.journeyOriginSkipAction),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 16),
          if (useQuickChoices)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: countries
                  .map(
                    (country) => _InlineCountryChoiceCard(
                      country: country,
                      isSelected: selectedCountryId == country.id,
                      isEnabled: isSelectable(country),
                      availabilityLabel: availabilityLabelFor(country),
                      onTap: isSelectable(country)
                          ? () => onTap(country)
                          : null,
                    ),
                  )
                  .toList(growable: false),
            )
          else
            _PickerSummaryCard(
              title: pickerTitle,
              selectedCountry: selectedCountry,
              placeholder: title,
              availabilityLabel: selectedCountry == null
                  ? null
                  : availabilityLabelFor(selectedCountry),
              onTap: onOpenPicker,
            ),
          if (footer != null) ...[const SizedBox(height: 16), footer!],
        ],
      ),
    );
  }
}

class _InlineCountryChoiceCard extends StatelessWidget {
  const _InlineCountryChoiceCard({
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
    final background = isSelected
        ? AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFF4F8FF),
          )
        : AppColors.surfaceMutedFor(context);
    final border = isSelected
        ? AppColors.primary.withValues(alpha: 0.28)
        : AppColors.borderFor(context);

    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  country.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  availabilityLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isEnabled
                        ? AppColors.textSoftFor(context)
                        : AppColors.textSoftFor(
                            context,
                          ).withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerSummaryCard extends StatelessWidget {
  const _PickerSummaryCard({
    required this.title,
    required this.placeholder,
    required this.selectedCountry,
    required this.availabilityLabel,
    required this.onTap,
  });

  final String title;
  final String placeholder;
  final CatalogCountry? selectedCountry;
  final String? availabilityLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final country = selectedCountry;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  country?.flagEmoji ?? '🌎',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country?.name ?? placeholder,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (availabilityLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        availabilityLabel!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.title,
    required this.countries,
    required this.selectedCountryId,
    required this.availabilityLabelFor,
    required this.isSelectable,
  });

  final String title;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final String Function(CatalogCountry country) availabilityLabelFor;
  final bool Function(CatalogCountry country) isSelectable;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filtered =
        widget.countries
            .where((country) {
              final normalizedQuery = _query.trim().toLowerCase();
              if (normalizedQuery.isEmpty) {
                return true;
              }
              return country.name.toLowerCase().contains(normalizedQuery);
            })
            .toList(growable: false)
          ..sort((left, right) {
            final leftSelected = left.id == widget.selectedCountryId ? 1 : 0;
            final rightSelected = right.id == widget.selectedCountryId ? 1 : 0;
            if (leftSelected != rightSelected) {
              return rightSelected.compareTo(leftSelected);
            }

            final leftSelectable = widget.isSelectable(left) ? 1 : 0;
            final rightSelectable = widget.isSelectable(right) ? 1 : 0;
            if (leftSelectable != rightSelectable) {
              return rightSelectable.compareTo(leftSelectable);
            }

            return left.name.compareTo(right.name);
          });

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return FrostedPanel(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSoftFor(
                      context,
                    ).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: l10n.journeyPickerSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          l10n.journeyPickerNoResults,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSoftFor(context)),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final country = filtered[index];
                          return _CountryChoiceCard(
                            country: country,
                            isSelected: widget.selectedCountryId == country.id,
                            isEnabled: widget.isSelectable(country),
                            availabilityLabel: widget.availabilityLabelFor(
                              country,
                            ),
                            onTap: widget.isSelectable(country)
                                ? () => Navigator.of(context).pop(country)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoveragePanel extends StatelessWidget {
  const _CoveragePanel({
    required this.selectedOrigin,
    required this.selectedDestination,
    required this.detectedLocation,
    required this.routeSupported,
    required this.onChooseSupportedRoute,
  });

  final CatalogCountry? selectedOrigin;
  final CatalogCountry? selectedDestination;
  final DetectedLocation? detectedLocation;
  final bool routeSupported;
  final VoidCallback onChooseSupportedRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = _title(context);
    final body = _body(context);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (selectedOrigin != null &&
                  selectedDestination != null &&
                  !routeSupported)
                OutlinedButton(
                  onPressed: onChooseSupportedRoute,
                  child: Text(l10n.journeyCoverageChooseRouteAction),
                ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.journeyCoverageWaitlistStub)),
                    );
                },
                child: Text(l10n.journeyCoverageWaitlistAction),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;
    if (selectedOrigin != null &&
        selectedDestination != null &&
        routeSupported) {
      return l10n.journeyCoverageReadyTitle;
    }
    if (selectedDestination != null &&
        !selectedDestination!.coverage.canPlanAsDestination) {
      return l10n.journeyCoverageDestinationLimitedTitle;
    }
    if (selectedOrigin != null && !selectedOrigin!.coverage.canPlanAsOrigin) {
      return l10n.journeyCoverageOriginLimitedTitle;
    }
    if (detectedLocation != null && detectedLocation!.countryId == null) {
      return l10n.journeyCoverageDetectedUnknownTitle;
    }
    return l10n.journeyCoverageUnsupportedTitle;
  }

  String _body(BuildContext context) {
    final l10n = context.l10n;
    if (selectedOrigin != null &&
        selectedDestination != null &&
        routeSupported) {
      return l10n.journeyCoverageReadyBody(
        selectedOrigin!.name,
        selectedDestination!.name,
      );
    }
    if (selectedDestination != null &&
        !selectedDestination!.coverage.canPlanAsDestination) {
      return l10n.journeyCoverageDestinationLimitedBody(
        selectedDestination!.name,
      );
    }
    if (selectedOrigin != null && !selectedOrigin!.coverage.canPlanAsOrigin) {
      return l10n.journeyCoverageOriginLimitedBody(selectedOrigin!.name);
    }
    if (detectedLocation != null && detectedLocation!.countryId == null) {
      return l10n.journeyCoverageDetectedUnknownBody(
        detectedLocation!.countryName,
      );
    }
    return l10n.journeyCoverageUnsupportedBody;
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
    final background = isSelected
        ? AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFF4F8FF),
          )
        : AppColors.surfaceMutedFor(context);
    final border = isSelected
        ? AppColors.primary.withValues(alpha: 0.28)
        : AppColors.borderFor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      availabilityLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isEnabled
                            ? AppColors.textSoftFor(context)
                            : AppColors.textSoftFor(
                                context,
                              ).withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
