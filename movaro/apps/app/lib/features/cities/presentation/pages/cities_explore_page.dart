import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/language_selector_button.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/empty_state_widget.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_arrival_profile_ranker.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_highlight_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/methodology_info_banner.dart';

class CitiesExplorePage extends StatefulWidget {
  const CitiesExplorePage({required this.citiesController, super.key});

  final CitiesController citiesController;

  @override
  State<CitiesExplorePage> createState() => _CitiesExplorePageState();
}

class _CitiesExplorePageState extends State<CitiesExplorePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.citiesController.loadExplore();
      widget.citiesController.loadCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final controller = widget.citiesController;
        final highlights = controller.highlights;
        final housingFriendly = _topHousingFriendly(controller.catalog);
        final housingPressure = _topHousingPressure(controller.catalog);
        final softLanding = _topArrivalProfile(
          controller.catalog,
          CityArrivalProfile.softLanding,
        );
        final familyStability = _topArrivalProfile(
          controller.catalog,
          CityArrivalProfile.familyStability,
        );
        final incomeStart = _topArrivalProfile(
          controller.catalog,
          CityArrivalProfile.incomeStart,
        );
        final coastalCities = CityCoastalProfile.rankCoastal(controller.catalog)
            .take(3)
            .toList();
        final coastalSoftLanding = CityCoastalProfile.rankCoastalSoftLanding(
          controller.catalog,
        ).take(3).toList();
        final coastalBalanced = CityCoastalProfile.rankCoastalBalanced(
          controller.catalog,
        ).take(3).toList();
        final l10n = context.l10n;
        final isDark = AppColors.isDark(context);
        final surfaceMuted = AppColors.surfaceMutedFor(context);
        final textPrimary = AppColors.textPrimaryFor(context);
        final textSoft = AppColors.textSoftFor(context);

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.citiesExploreTitle,
                      onBack: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.publicHome,
                        (route) => false,
                      ),
                      trailing: const LanguageSelectorButton(),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1160),
                      child: FrostedPanel(
                        padding: const EdgeInsets.all(32),
                        gradient: LinearGradient(
                          colors: [
                            isDark
                                ? const Color(0xFF0F1A2A)
                                : Colors.white.withValues(alpha: 0.86),
                            isDark
                                ? const Color(0xFF13243D)
                                : const Color(0xFFF1F6FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        backgroundColor: isDark
                            ? const Color(0xD9111822)
                            : AppColors.frostedBackgroundFor(context),
                        borderColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.frostedBorderFor(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: surfaceMuted,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.citiesExploreTitle,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              l10n.citiesExploreHeadline,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: textPrimary),
                            ),
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Text(
                                l10n.citiesExploreDescription,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: textSoft),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.citiesSearch,
                              ),
                              icon: const Icon(Icons.search_rounded),
                              label: Text(l10n.citiesSearchTitle),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.sectionSpacing),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1160),
                      child: SectionLoadingOverlay(
                        isLoading:
                            controller.isLoadingHighlights &&
                            highlights != null,
                        label: l10n.citiesLoadingLabel,
                        child: MethodologyInfoBanner(
                          message:
                              controller.methodology?.note ??
                              l10n.citiesMethodologyNote,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (highlights == null && controller.isLoadingHighlights)
                      Column(
                        children: [
                          _HighlightSectionSkeleton(),
                          SizedBox(height: 24),
                          _HighlightSectionSkeleton(),
                          SizedBox(height: 24),
                          _HighlightSectionSkeleton(),
                          SizedBox(height: 24),
                          _HighlightSectionSkeleton(),
                        ],
                      )
                    else if (highlights == null &&
                        controller.exploreError != null)
                      Builder(
                        builder: (context) {
                          final error = ErrorHandler.resolve(
                            context,
                            controller.exploreError!,
                          );

                          return ErrorStateWidget(
                            title: error.title,
                            description: error.description,
                            illustrationAsset: error.illustrationAsset,
                            onRetry: error.isRetryable
                                ? widget.citiesController.loadExplore
                                : null,
                            onBack: () => Navigator.pop(context),
                          );
                        },
                      )
                    else if (highlights == null ||
                        (highlights.mostChosenByArgentinians.isEmpty &&
                            highlights.mostEconomical.isEmpty &&
                            highlights.bestForWork.isEmpty))
                      EmptyStateWidget(
                        title: l10n.citiesExploreEmptyTitle,
                        description: l10n.citiesExploreEmptyDescription,
                      )
                    else
                      AnimatedStateSwitcher(
                        child: Column(
                          key: ValueKey(
                            '${highlights.mostChosenByArgentinians.length}_${highlights.bestForWork.length}',
                          ),
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: CityHighlightSection(
                                title: l10n.citiesExplorePopularTitle,
                                cities: highlights.mostChosenByArgentinians,
                                highlightLabel:
                                    l10n.citiesHighlightPopularLabel,
                                onCityTap: _openCityDetail,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: CityHighlightSection(
                                title: l10n.citiesExploreLanguageTitle,
                                cities: highlights.easiestForSpanishSpeakers,
                                highlightLabel:
                                    l10n.citiesHighlightLanguageLabel,
                                onCityTap: _openCityDetail,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: CityHighlightSection(
                                title: l10n.citiesExploreEconomicalTitle,
                                cities: highlights.mostEconomical,
                                highlightLabel:
                                    l10n.citiesHighlightEconomicalLabel,
                                onCityTap: _openCityDetail,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: CityHighlightSection(
                                title: l10n.citiesExploreWorkTitle,
                                cities: highlights.bestForWork,
                                highlightLabel: l10n.citiesHighlightWorkLabel,
                                onCityTap: _openCityDetail,
                              ),
                            ),
                            if (housingFriendly.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreHousingEasyTitle,
                                  cities: housingFriendly,
                                  highlightLabel:
                                      l10n.citiesHighlightHousingEasyLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (housingPressure.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreHousingPressureTitle,
                                  cities: housingPressure,
                                  highlightLabel:
                                      l10n.citiesHighlightHousingPressureLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (softLanding.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreSoftLandingTitle,
                                  cities: softLanding,
                                  highlightLabel:
                                      l10n.citiesHighlightSoftLandingLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (familyStability.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreFamilyStabilityTitle,
                                  cities: familyStability,
                                  highlightLabel:
                                      l10n.citiesHighlightFamilyStabilityLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (incomeStart.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreIncomeStartTitle,
                                  cities: incomeStart,
                                  highlightLabel:
                                      l10n.citiesHighlightIncomeStartLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (coastalCities.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreCoastalTitle,
                                  cities: coastalCities,
                                  highlightLabel: l10n.citiesHighlightCoastalLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (coastalSoftLanding.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreCoastalSoftLandingTitle,
                                  cities: coastalSoftLanding,
                                  highlightLabel:
                                      l10n.citiesHighlightCoastalSoftLandingLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
                            if (coastalBalanced.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1160),
                                child: CityHighlightSection(
                                  title: l10n.citiesExploreCoastalBalancedTitle,
                                  cities: coastalBalanced,
                                  highlightLabel:
                                      l10n.citiesHighlightCoastalBalancedLabel,
                                  onCityTap: _openCityDetail,
                                ),
                              ),
                            ],
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

  void _openCityDetail(City city) {
    widget.citiesController.prefetchCityDetail(city.id);
    widget.citiesController.prefetchMethodology();
    Navigator.pushNamed(context, AppRoutes.cityDetail(city.id));
  }

  List<City> _topHousingFriendly(List<City> cities) {
    final ranked = List<City>.from(cities)
      ..sort((a, b) {
        final byRent = b.rentScore.compareTo(a.rentScore);
        if (byRent != 0) {
          return byRent;
        }
        return b.safetyScore.compareTo(a.safetyScore);
      });
    return ranked.take(3).toList();
  }

  List<City> _topHousingPressure(List<City> cities) {
    final ranked = List<City>.from(cities)
      ..sort((a, b) {
        final byRent = a.rentScore.compareTo(b.rentScore);
        if (byRent != 0) {
          return byRent;
        }
        return a.costOfLivingScore.compareTo(b.costOfLivingScore);
      });
    return ranked.take(3).toList();
  }

  List<City> _topArrivalProfile(
    List<City> cities,
    CityArrivalProfile profile,
  ) {
    return CityArrivalProfileRanker.rank(cities, profile: profile)
        .take(3)
        .toList();
  }
}

class _HighlightSectionSkeleton extends StatelessWidget {
  const _HighlightSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 220, height: 20),
          SizedBox(height: 12),
          ListSkeleton(itemCount: 3),
        ],
      ),
    );
  }
}
