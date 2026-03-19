import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/journey/country_coverage.dart';
import 'package:movaro_app/core/journey/detected_location.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';

enum _JourneyEntryMode { none, useLocation, manual }

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
  _JourneyEntryMode _entryMode = _JourneyEntryMode.none;

  @override
  void initState() {
    super.initState();
    _originId = widget.journeyContextController.originCountryId;
    _destinationId = widget.journeyContextController.destinationCountryId;
    _entryMode = widget.journeyContextController.hasDetectedLocation
        ? _JourneyEntryMode.useLocation
        : (widget.journeyContextController.hasJourneyDraft
              ? _JourneyEntryMode.manual
              : _JourneyEntryMode.none);

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.journeyContextController;
    final l10n = context.l10n;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final origins = controller.availableOrigins;
        final destinations = controller.availableDestinations;
        final selectedOrigin = origins.where((c) => c.id == _originId).firstOrNull;
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
                                  onUseLocation: () {
                                    setState(() {
                                      _entryMode = _JourneyEntryMode.useLocation;
                                    });
                                  },
                                  onChooseManual: () {
                                    setState(() {
                                      _entryMode = _JourneyEntryMode.manual;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (_entryMode == _JourneyEntryMode.useLocation)
                                  _LocationHintPanel(
                                    controller: controller,
                                    onFallbackManual: () {
                                      setState(() {
                                        _entryMode = _JourneyEntryMode.manual;
                                      });
                                    },
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
                                if (_entryMode != _JourneyEntryMode.none) ...[
                                  if (_entryMode == _JourneyEntryMode.useLocation)
                                    const SizedBox(height: 16),
                                  _SelectorPanel(
                                    title: l10n.journeyOriginSectionTitle,
                                    subtitle: l10n.journeyOriginSectionBody,
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
                                    onTap: (country) async {
                                      setState(() {
                                        _originId = country.id;
                                      });
                                      await controller.setOriginCountry(
                                        country.id,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _SelectorPanel(
                                    title: l10n.journeyDestinationSectionTitle,
                                    subtitle: l10n.journeyDestinationSectionBody,
                                    countries: destinations,
                                    selectedCountryId: _destinationId,
                                    availabilityLabelFor: (country) =>
                                        _coverageLabel(
                                          context,
                                          country.coverage.destinationStatus,
                                        ),
                                    isSelectable: controller.canChooseAsDestination,
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
                                  _CoveragePanel(
                                    selectedOrigin: selectedOrigin,
                                    selectedDestination: selectedDestination,
                                    detectedLocation: controller.detectedLocation,
                                    routeSupported: routeSupported,
                                    onChooseSupportedRoute: () {
                                      setState(() {
                                        _entryMode = _JourneyEntryMode.manual;
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
                                        l10n.journeyEntryContinueAction,
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
                                            arguments:
                                                DocumentationGuideSection.documents,
                                          ),
                                          child: Text(
                                            l10n.journeyCoverageContentAction,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
    required this.onUseLocation,
    required this.onChooseManual,
  });

  final VoidCallback onUseLocation;
  final VoidCallback onChooseManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MovaroLogo(markSize: 24),
          const SizedBox(height: 20),
          Text(
            l10n.journeyEntryDynamicTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.journeyEntryDynamicBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final cardWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _EntryChoiceCard(
                      icon: Icons.my_location_rounded,
                      title: l10n.journeyEntryUseLocationTitle,
                      body: l10n.journeyEntryUseLocationBody,
                      actionLabel: l10n.journeyEntryUseLocationAction,
                      onTap: onUseLocation,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _EntryChoiceCard(
                      icon: Icons.tune_rounded,
                      title: l10n.journeyEntryManualTitle,
                      body: l10n.journeyEntryManualBody,
                      actionLabel: l10n.journeyEntryManualAction,
                      onTap: onChooseManual,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationHintPanel extends StatelessWidget {
  const _LocationHintPanel({
    required this.controller,
    required this.onFallbackManual,
    required this.onConfirmDetectedOrigin,
  });

  final JourneyContextController controller;
  final VoidCallback onFallbackManual;
  final Future<void> Function() onConfirmDetectedOrigin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detected = controller.detectedLocation;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.journeyLocationPanelTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.journeyLocationPanelBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (!controller.hasDetectedLocation &&
              !controller.isDetectingLocation) ...[
            FilledButton.icon(
              onPressed: controller.requestDetectedLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: Text(l10n.journeyEntryUseLocationAction),
            ),
          ] else if (controller.isDetectingLocation) ...[
            const LinearProgressIndicator(),
          ] else if (detected != null) ...[
            _DetectedLocationCard(
              location: detected,
              canConfirmOrigin: detected.hasMatchedCountry,
              onConfirmOrigin: onConfirmDetectedOrigin,
              onChooseManual: onFallbackManual,
            ),
          ] else ...[
            _LocationErrorState(
              state: controller.detectedLocationState,
              onRetry: controller.requestDetectedLocation,
              onChooseManual: onFallbackManual,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetectedLocationCard extends StatelessWidget {
  const _DetectedLocationCard({
    required this.location,
    required this.canConfirmOrigin,
    required this.onConfirmOrigin,
    required this.onChooseManual,
  });

  final DetectedLocation location;
  final bool canConfirmOrigin;
  final Future<void> Function() onConfirmOrigin;
  final VoidCallback onChooseManual;

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
          ),
          const SizedBox(height: 8),
          Text(
            canConfirmOrigin
                ? l10n.journeyDetectedConfirmBody(location.countryName)
                : l10n.journeyDetectedUnknownBody(location.countryName),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
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
              OutlinedButton(
                onPressed: onChooseManual,
                child: Text(l10n.journeyDetectedManualAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationErrorState extends StatelessWidget {
  const _LocationErrorState({
    required this.state,
    required this.onRetry,
    required this.onChooseManual,
  });

  final DetectedLocationRequestState state;
  final Future<void> Function() onRetry;
  final VoidCallback onChooseManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = switch (state) {
      DetectedLocationRequestState.denied =>
        l10n.journeyLocationDeniedBody,
      DetectedLocationRequestState.deniedForever =>
        l10n.journeyLocationDeniedForeverBody,
      DetectedLocationRequestState.unavailable =>
        l10n.journeyLocationUnavailableBody,
      _ => l10n.journeyLocationFailedBody,
    };

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
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: onRetry,
                child: Text(l10n.journeyLocationRetryAction),
              ),
              TextButton(
                onPressed: onChooseManual,
                child: Text(l10n.journeyDetectedManualAction),
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
    required this.subtitle,
    required this.countries,
    required this.selectedCountryId,
    required this.availabilityLabelFor,
    required this.isSelectable,
    required this.onTap,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final String Function(CatalogCountry country) availabilityLabelFor;
  final bool Function(CatalogCountry country) isSelectable;
  final ValueChanged<CatalogCountry> onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                TextButton(
                  onPressed: onClear,
                  child: Text(context.l10n.journeyOriginSkipAction),
                ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
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
                availabilityLabel: availabilityLabelFor(country),
                onTap: isSelectable(country) ? () => onTap(country) : null,
              );
            },
          ),
        ],
      ),
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
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
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

class _EntryChoiceCard extends StatelessWidget {
  const _EntryChoiceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                actionLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
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
              Text(
                country.flagEmoji,
                style: const TextStyle(fontSize: 24),
              ),
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
                            : AppColors.textSoftFor(context).withValues(
                                alpha: 0.72,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
