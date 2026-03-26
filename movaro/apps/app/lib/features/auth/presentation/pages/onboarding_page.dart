import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/empty_state_widget.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.authController,
    required this.catalogRepository,
    required this.locationController,
    super.key,
  });

  final AuthController authController;
  final CatalogRepository catalogRepository;
  final LocationController locationController;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CatalogCountry> _countries = const [];
  bool _isLoading = true;
  Object? _loadError;

  String? _originCountry;
  String? _destinationCountry;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCountries());
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {});
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final countries = await widget.catalogRepository.getCountries();
      if (!mounted) {
        return;
      }

      setState(() {
        _countries = countries;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final borderColor = AppColors.borderFor(context);
    final size = MediaQuery.sizeOf(context);
    final visibleCountries = _visibleCountries(_countries);
    final titleStyle =
        (size.width < 380
                ? Theme.of(context).textTheme.headlineLarge
                : Theme.of(context).textTheme.displaySmall)
            ?.copyWith(fontWeight: FontWeight.w800, height: 1.04);
    final subtitleStyle =
        (size.width < 380
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.titleMedium)
            ?.copyWith(
              color: textSoft,
              fontWeight: FontWeight.w500,
              height: 1.35,
            );

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppGlassHeader(
                        title: l10n.onboardingPageTitle,
                        onBack: _stepIndex == 0
                            ? (Navigator.canPop(context)
                                  ? () => Navigator.maybePop(context)
                                  : null)
                            : _goBack,
                      ),
                      const SizedBox(height: 20),
                      FrostedPanel(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.onboardingHeadline, style: titleStyle),
                            const SizedBox(height: 12),
                            Text(
                              l10n.onboardingDescription,
                              style: subtitleStyle,
                            ),
                            const SizedBox(height: 18),
                            _StepMarker(
                              currentStep: _stepIndex + 1,
                              totalSteps: 2,
                              label: _currentLabel(l10n),
                            ),
                            if (_selectedValue != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceMuted,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _selectedValue!,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FrostedPanel(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _searchController,
                          enabled: !_isLoading || _countries.isNotEmpty,
                          decoration: InputDecoration(
                            labelText: _currentLabel(l10n),
                            hintText: _currentLabel(l10n),
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading && _countries.isNotEmpty)
                        LoadingStateWidget(
                          label: l10n.splashLoadingLabel,
                          compact: true,
                        ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (_isLoading && _countries.isEmpty) {
                              return const SingleChildScrollView(
                                child: FormSkeleton(fieldCount: 5),
                              );
                            }

                            if (_loadError != null && _countries.isEmpty) {
                              return ErrorStateWidget(
                                title: l10n.errorUnknownTitle,
                                description: l10n.errorUnknownDescription,
                                illustrationAsset:
                                    'assets/illustrations/error.svg',
                                onRetry: _loadCountries,
                                onBack: Navigator.canPop(context)
                                    ? () => Navigator.maybePop(context)
                                    : null,
                              );
                            }

                            if (visibleCountries.isEmpty) {
                              return EmptyStateWidget(
                                title: l10n.citiesSearchEmptyTitle,
                                description: l10n.citiesSearchEmptyDescription,
                              );
                            }

                            return AnimatedStateSwitcher(
                              child: ListView.separated(
                                key: ValueKey(
                                  '${_stepIndex}_${visibleCountries.length}',
                                ),
                                itemBuilder: (context, index) {
                                  final country = visibleCountries[index];
                                  final isSelected =
                                      country.name == _selectedValue;

                                  return InkWell(
                                    onTap: () => _selectCountry(country.name),
                                    borderRadius: BorderRadius.circular(24),
                                    child: FrostedPanel(
                                      padding: const EdgeInsets.all(18),
                                      borderRadius: BorderRadius.circular(24),
                                      borderColor: isSelected
                                          ? AppColors.primary
                                          : borderColor,
                                      backgroundColor: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.08,
                                            )
                                          : AppColors.surfaceFor(context),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.public_rounded),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              country.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                            ),
                                          ),
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle_rounded
                                                : Icons
                                                      .arrow_forward_ios_rounded,
                                            size: isSelected ? 22 : 16,
                                            color: isSelected
                                                ? AppColors.primary
                                                : textSoft,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemCount: visibleCountries.length,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      FrostedPanel(
                        padding: const EdgeInsets.all(18),
                        borderRadius: BorderRadius.circular(28),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _stepIndex == 0 ? null : _goBack,
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(l10n.backAction),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: _canAdvance
                                    ? () => _advance(context)
                                    : null,
                                icon: Icon(
                                  _stepIndex == 0
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_rounded,
                                ),
                                label: Text(l10n.onboardingContinueAction),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<CatalogCountry> _visibleCountries(List<CatalogCountry> countries) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return countries;
    }

    return countries
        .where((country) => country.name.toLowerCase().contains(query))
        .toList();
  }

  String _currentLabel(dynamic l10n) {
    return _stepIndex == 0
        ? l10n.onboardingOriginLabel
        : l10n.onboardingDestinationLabel;
  }

  String? get _selectedValue =>
      _stepIndex == 0 ? _originCountry : _destinationCountry;

  bool get _canAdvance => _stepIndex == 0
      ? _originCountry != null && _originCountry!.isNotEmpty
      : _destinationCountry != null && _destinationCountry!.isNotEmpty;

  void _selectCountry(String value) {
    setState(() {
      if (_stepIndex == 0) {
        _originCountry = value;
      } else {
        _destinationCountry = value;
      }
    });
  }

  void _goBack() {
    setState(() {
      _stepIndex = (_stepIndex - 1).clamp(0, 1);
      _searchController.clear();
    });
  }

  Future<void> _advance(BuildContext context) async {
    if (_stepIndex == 0) {
      setState(() {
        _stepIndex = 1;
        _searchController.clear();
      });
      return;
    }

    await widget.authController.completeOnboarding(
      originCountry: _originCountry!,
      destinationCountry: _destinationCountry!,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      widget.authController.resolveRouteAfterOnboarding(),
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({
    required this.currentStep,
    required this.totalSteps,
    required this.label,
  });

  final int currentStep;
  final int totalSteps;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            '$label  $currentStep/$totalSteps',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: textSoft),
          ),
        ),
        SizedBox(
          width: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              minHeight: 8,
              backgroundColor: surfaceMuted,
            ),
          ),
        ),
      ],
    );
  }
}
