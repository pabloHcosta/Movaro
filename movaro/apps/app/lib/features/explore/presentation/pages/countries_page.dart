import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/empty_state_widget.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';

class CountriesPage extends StatefulWidget {
  const CountriesPage({required this.catalogRepository, super.key});

  final CatalogRepository catalogRepository;

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CatalogCountry> _countries = const [];
  bool _isLoading = true;
  Object? _loadError;

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
    final visibleCountries = _visibleCountries(_countries);
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.countriesPageTitle,
                      onBack: Navigator.canPop(context)
                          ? () => Navigator.maybePop(context)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.countriesPageTitle,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.explorePublicFeaturesDescription,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: textSoft),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _searchController,
                            enabled: !_isLoading || _countries.isNotEmpty,
                            decoration: InputDecoration(
                              labelText: l10n.countriesPageTitle,
                              hintText: l10n.countriesPageTitle,
                              prefixIcon: const Icon(Icons.search_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading && _countries.isNotEmpty)
                      LoadingStateWidget(
                        label: l10n.splashLoadingLabel,
                        compact: true,
                      ),
                    if (_isLoading && _countries.isEmpty)
                      Semantics(
                        container: true,
                        liveRegion: true,
                        label: l10n.loadingCountriesLabel,
                        child: ExcludeSemantics(
                          child: ListSkeleton(itemCount: 6),
                        ),
                      )
                    else if (_loadError != null && _countries.isEmpty)
                      ErrorStateWidget(
                        title: l10n.errorUnknownTitle,
                        description: l10n.errorUnknownDescription,
                        illustrationAsset: 'assets/illustrations/error.svg',
                        onRetry: _loadCountries,
                        onBack: Navigator.canPop(context)
                            ? () => Navigator.maybePop(context)
                            : null,
                      )
                    else if (visibleCountries.isEmpty)
                      EmptyStateWidget(
                        title: l10n.citiesSearchEmptyTitle,
                        description: l10n.citiesSearchEmptyDescription,
                      )
                    else
                      AnimatedStateSwitcher(
                        child: Column(
                          key: ValueKey(visibleCountries.length),
                          children: [
                            for (final country in visibleCountries) ...[
                              FrostedPanel(
                                padding: const EdgeInsets.all(18),
                                borderRadius: BorderRadius.circular(24),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: surfaceMuted,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.public_rounded),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            country.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.publicAccessLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: textSoft,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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
}
