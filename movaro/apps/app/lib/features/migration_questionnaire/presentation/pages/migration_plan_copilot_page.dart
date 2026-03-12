import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/landing_budget_estimator_section.dart';

enum _PreparationSection { overview, documents, housing, work, arrival }

class MigrationPlanCopilotPage extends StatefulWidget {
  const MigrationPlanCopilotPage({
    required this.controller,
    required this.exchangeRatesService,
    required this.citiesController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CopilotExchangeRatesService exchangeRatesService;
  final CitiesController citiesController;

  @override
  State<MigrationPlanCopilotPage> createState() =>
      _MigrationPlanCopilotPageState();
}

class _MigrationPlanCopilotPageState extends State<MigrationPlanCopilotPage> {
  late final Future<CopilotExchangeRates?> _exchangeRatesFuture;
  _PreparationSection _selectedSection = _PreparationSection.overview;

  @override
  void initState() {
    super.initState();
    _exchangeRatesFuture = widget.exchangeRatesService.fetchLatest();
  }

  void _openSection(_PreparationSection section) {
    setState(() => _selectedSection = section);
  }

  void _openDocumentationTopic(DocumentationGuideSection section) {
    Navigator.pushNamed(
      context,
      AppRoutes.documentationTopic,
      arguments: section,
    );
  }

  void _openDocumentationGuide() {
    Navigator.pushNamed(context, AppRoutes.documentationGuide);
  }

  Future<void> _openFlightsSearch() async {
    final city = widget.controller.generatedPlan?.recommendedCity;
    final destination = city?.name ?? 'Brazil';
    final uri = PreparationResourceLinks.buildFlightsSearch(
      originCity: 'Buenos Aires',
      destinationCity: destination,
    );
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.migrationPlanPrepQuestionFlightsTitle,
          uri: uri,
        ),
      ),
    );
  }

  Future<void> _openIbgePanorama(City city) async {
    final uri = PreparationResourceLinks.buildIbgePanorama(city);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.migrationPlanPrepOfficialIncomeTitle,
          uri: uri,
        ),
      ),
    );
  }

  Future<void> _openRentalSearch(City city, RentalProvider provider) async {
    final uri = PreparationResourceLinks.buildRentalSearch(city, provider);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.migrationPlanPrepRentalSearchTitle,
          uri: uri,
        ),
      ),
    );
  }

  Future<void> _openExternalPreparationLink({
    required String title,
    required Uri uri,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(title: title, uri: uri),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = widget.controller.generatedPlan;
    final city = plan?.recommendedCity;

    if (plan == null) {
      return Scaffold(
        body: Stack(
          children: [
            const AmbientBackground(),
            PageSkeleton(
              label: l10n.migrationPlanCopilotTitle,
              maxWidth: 1040,
              padding: EdgeInsets.fromLTRB(
                context.pageHorizontalPadding,
                context.pageVerticalPadding,
                context.pageHorizontalPadding,
                context.pageVerticalPadding + 20,
              ),
              children: const [DetailSkeleton()],
            ),
          ],
        ),
      );
    }

    final isOverview = _selectedSection == _PreparationSection.overview;
    final hasConfirmedCity = plan.isCityConfirmed && city != null;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    0,
                  ),
                  child: AppGlassHeader(
                    title: l10n.migrationPlanCopilotTitle,
                    onBack: isOverview
                        ? () => Navigator.maybePop(context)
                        : () => _openSection(_PreparationSection.overview),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                context.pageHorizontalPadding,
                                18,
                                context.pageHorizontalPadding,
                                20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _PreparationHero(
                                    cityName: city?.name,
                                    stateCode: city?.stateCode,
                                    isOverview: isOverview,
                                    section: _selectedSection,
                                  ),
                                  const SizedBox(height: 16),
                                  if (!hasConfirmedCity)
                                    _PreparationNeedsCityState(
                                      onOpenPlanResult: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.migrationPlanResult,
                                        );
                                      },
                                    )
                                  else ...[
                                    _PreparationSectionRail(
                                      selectedSection: _selectedSection,
                                      onSelected: _openSection,
                                    ),
                                    const SizedBox(height: 16),
                                    if (isOverview)
                                      _PreparationOverview(
                                        onOpenSection: _openSection,
                                        onOpenGuide: _openDocumentationGuide,
                                        onOpenFlights: _openFlightsSearch,
                                      )
                                    else
                                      _PreparationSectionContent(
                                        section: _selectedSection,
                                        onOpenGuide: _openDocumentationGuide,
                                        onOpenTopic: _openDocumentationTopic,
                                        onOpenIbgePanorama: _openIbgePanorama,
                                        onOpenRentalSearch: _openRentalSearch,
                                        onOpenExternalPreparationLink:
                                            _openExternalPreparationLink,
                                        exchangeRatesFuture:
                                            _exchangeRatesFuture,
                                        plan: plan,
                                        city: city,
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 2,
        citiesController: widget.citiesController,
        migrationQuestionnaireController: widget.controller,
      ),
    );
  }
}

Future<void> _showPreparationSheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: FrostedPanel(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _PreparationHero extends StatelessWidget {
  const _PreparationHero({
    required this.cityName,
    required this.stateCode,
    required this.isOverview,
    required this.section,
  });

  final String? cityName;
  final String? stateCode;
  final bool isOverview;
  final _PreparationSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroMiddle, AppColors.heroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xB30B1320),
      borderColor: const Color(0x1AFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(label: l10n.migrationPlanCopilotTitle),
              if (cityName != null && stateCode != null)
                _HeroPill(label: '$cityName ($stateCode)'),
              if (!isOverview)
                _HeroPill(label: _sectionLabel(context, section)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isOverview
                ? l10n.migrationPlanPrepHeroTitle
                : _sectionTitle(context, section),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            isOverview
                ? l10n.migrationPlanPrepHeroBody
                : _sectionBody(context, section),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(BuildContext context, _PreparationSection section) {
    final l10n = context.l10n;
    return switch (section) {
      _PreparationSection.overview => l10n.migrationPlanPrepTabOverview,
      _PreparationSection.documents => l10n.migrationPlanPrepTabDocuments,
      _PreparationSection.housing => l10n.migrationPlanPrepTabHousing,
      _PreparationSection.work => l10n.migrationPlanPrepTabWork,
      _PreparationSection.arrival => l10n.migrationPlanPrepTabArrival,
    };
  }

  String _sectionTitle(BuildContext context, _PreparationSection section) {
    final l10n = context.l10n;
    return switch (section) {
      _PreparationSection.overview => l10n.migrationPlanPrepHeroTitle,
      _PreparationSection.documents => l10n.migrationPlanPrepDocumentsTitle,
      _PreparationSection.housing => l10n.migrationPlanPrepHousingTitle,
      _PreparationSection.work => l10n.migrationPlanPrepWorkTitle,
      _PreparationSection.arrival => l10n.migrationPlanPrepArrivalTitle,
    };
  }

  String _sectionBody(BuildContext context, _PreparationSection section) {
    final l10n = context.l10n;
    return switch (section) {
      _PreparationSection.overview => l10n.migrationPlanPrepHeroBody,
      _PreparationSection.documents => l10n.migrationPlanPrepDocumentsBody,
      _PreparationSection.housing => l10n.migrationPlanPrepHousingBody,
      _PreparationSection.work => l10n.migrationPlanPrepWorkBody,
      _PreparationSection.arrival => l10n.migrationPlanPrepArrivalBody,
    };
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _PreparationSectionRail extends StatelessWidget {
  const _PreparationSectionRail({
    required this.selectedSection,
    required this.onSelected,
  });

  final _PreparationSection selectedSection;
  final ValueChanged<_PreparationSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final sections = <_PreparationSection>[
      _PreparationSection.overview,
      _PreparationSection.documents,
      _PreparationSection.housing,
      _PreparationSection.work,
      _PreparationSection.arrival,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final section in sections) ...[
            _SectionChip(
              label: _label(context, section),
              icon: _icon(section),
              selected: selectedSection == section,
              onTap: () => onSelected(section),
            ),
            if (section != sections.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  String _label(BuildContext context, _PreparationSection section) {
    final l10n = context.l10n;
    return switch (section) {
      _PreparationSection.overview => l10n.migrationPlanPrepTabOverview,
      _PreparationSection.documents => l10n.migrationPlanPrepTabDocuments,
      _PreparationSection.housing => l10n.migrationPlanPrepTabHousing,
      _PreparationSection.work => l10n.migrationPlanPrepTabWork,
      _PreparationSection.arrival => l10n.migrationPlanPrepTabArrival,
    };
  }

  IconData _icon(_PreparationSection section) {
    return switch (section) {
      _PreparationSection.overview => Icons.grid_view_rounded,
      _PreparationSection.documents => Icons.description_outlined,
      _PreparationSection.housing => Icons.home_work_outlined,
      _PreparationSection.work => Icons.work_outline_rounded,
      _PreparationSection.arrival => Icons.flight_land_rounded,
    };
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.28)
                : AppColors.borderFor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSoftFor(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? AppColors.primary
                    : AppColors.textPrimaryFor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparationOverview extends StatelessWidget {
  const _PreparationOverview({
    required this.onOpenSection,
    required this.onOpenGuide,
    required this.onOpenFlights,
  });

  final ValueChanged<_PreparationSection> onOpenSection;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenFlights;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.migrationPlanPrepOverviewTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.migrationPlanPrepOverviewBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 760;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _GuideEntryCard(
                    title: l10n.migrationPlanPrepDocumentsTitle,
                    body: l10n.migrationPlanPrepDocumentsBody,
                    icon: Icons.description_outlined,
                    tint: AppColors.primary,
                    onTap: () => onOpenSection(_PreparationSection.documents),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _GuideEntryCard(
                    title: l10n.migrationPlanPrepHousingTitle,
                    body: l10n.migrationPlanPrepHousingBody,
                    icon: Icons.home_work_outlined,
                    tint: AppColors.success,
                    onTap: () => onOpenSection(_PreparationSection.housing),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _GuideEntryCard(
                    title: l10n.migrationPlanPrepWorkTitle,
                    body: l10n.migrationPlanPrepWorkBody,
                    icon: Icons.work_outline_rounded,
                    tint: AppColors.caution,
                    onTap: () => onOpenSection(_PreparationSection.work),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _GuideEntryCard(
                    title: l10n.migrationPlanPrepArrivalTitle,
                    body: l10n.migrationPlanPrepArrivalBody,
                    icon: Icons.flight_land_rounded,
                    tint: AppColors.secondary,
                    onTap: () => onOpenSection(_PreparationSection.arrival),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _GuideEntryCard(
                    title: l10n.migrationPlanPrepQuestionFlightsTitle,
                    body: l10n.migrationPlanPrepQuestionFlightsBody,
                    icon: Icons.travel_explore_rounded,
                    tint: AppColors.primary,
                    onTap: onOpenFlights,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _GuideEntryCard(
                    title: l10n.publicHomeQuestionsTitle,
                    body: l10n.publicHomeQuestionsBody,
                    icon: Icons.menu_book_rounded,
                    tint: AppColors.primary,
                    onTap: onOpenGuide,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GuideEntryCard extends StatelessWidget {
  const _GuideEntryCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 176),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.isDark(context)
                ? [
                    AppColors.surfaceFor(context).withValues(alpha: 0.92),
                    AppColors.surfaceMutedFor(context).withValues(alpha: 0.88),
                  ]
                : const [Color(0xFFFBFDFF), Color(0xFFF2F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: tint.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppColors.isDark(context) ? 0.14 : 0.04,
              ),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: tint, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: AppColors.isDark(context) ? 0.08 : 0.72,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: tint.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.migrationPlanPrepOpenSection,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: tint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: tint),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(height: 1.15),
            ),
            const SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _cardTone(context, tint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cardTone(BuildContext context, Color tint) {
    final l10n = context.l10n;
    if (tint == AppColors.success) {
      return l10n.migrationPlanPrepCardTonePractical;
    }
    if (tint == AppColors.caution) {
      return l10n.migrationPlanPrepCardTonePriority;
    }
    if (tint == AppColors.secondary) {
      return l10n.migrationPlanPrepCardToneArrival;
    }
    return l10n.migrationPlanPrepCardToneGuide;
  }
}

class _PreparationNeedsCityState extends StatelessWidget {
  const _PreparationNeedsCityState({required this.onOpenPlanResult});

  final VoidCallback onOpenPlanResult;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.migrationPlanPrepChooseCityTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.migrationPlanPrepChooseCityBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenPlanResult,
            icon: const Icon(Icons.location_city_outlined),
            label: Text(context.l10n.migrationPlanPrepChooseCityAction),
          ),
        ],
      ),
    );
  }
}

class _PreparationSectionContent extends StatelessWidget {
  const _PreparationSectionContent({
    required this.section,
    required this.onOpenGuide,
    required this.onOpenTopic,
    required this.onOpenIbgePanorama,
    required this.onOpenRentalSearch,
    required this.onOpenExternalPreparationLink,
    required this.exchangeRatesFuture,
    required this.plan,
    required this.city,
  });

  final _PreparationSection section;
  final VoidCallback onOpenGuide;
  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final Future<void> Function(City city) onOpenIbgePanorama;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;
  final Future<CopilotExchangeRates?> exchangeRatesFuture;
  final MigrationPlan plan;
  final City? city;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case _PreparationSection.overview:
        return const SizedBox.shrink();
      case _PreparationSection.documents:
        return _DocumentsGuideSection(
          onOpenGuide: onOpenGuide,
          onOpenTopic: onOpenTopic,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        );
      case _PreparationSection.housing:
        return _HousingGuideSection(
          exchangeRatesFuture: exchangeRatesFuture,
          plan: plan,
          cityName: city?.name,
          city: city,
          onOpenRentalSearch: onOpenRentalSearch,
          onOpenTopic: onOpenTopic,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        );
      case _PreparationSection.work:
        return _WorkGuideSection(
          onOpenTopic: onOpenTopic,
          plan: plan,
          city: city,
          onOpenIbgePanorama: onOpenIbgePanorama,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        );
      case _PreparationSection.arrival:
        return _ArrivalGuideSection(
          onOpenTopic: onOpenTopic,
          destinationCityName: city?.name,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        );
    }
  }
}

class _DocumentsGuideSection extends StatelessWidget {
  const _DocumentsGuideSection({
    required this.onOpenGuide,
    required this.onOpenTopic,
    required this.onOpenExternalPreparationLink,
  });

  final VoidCallback onOpenGuide;
  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.migrationPlanPrepDocumentsGuideTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.migrationPlanPrepDocumentsGuideBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        onOpenTopic(DocumentationGuideSection.documents),
                    icon: const Icon(Icons.description_outlined),
                    label: Text(l10n.migrationPlanPrepOpenDocumentsTopic),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenGuide,
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(l10n.migrationPlanPrepOpenGuide),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoGuideCard(
          icon: Icons.badge_outlined,
          tint: AppColors.primary,
          title: l10n.migrationPlanPrepDocumentsCpfTitle,
          body: l10n.migrationPlanPrepDocumentsCpfBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.perm_identity_rounded,
          tint: AppColors.secondary,
          title: l10n.migrationPlanPrepDocumentsResidenceTitle,
          body: l10n.migrationPlanPrepDocumentsResidenceBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.account_balance_outlined,
          tint: AppColors.success,
          title: l10n.migrationPlanPrepDocumentsBankTitle,
          body: l10n.migrationPlanPrepDocumentsBankBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.receipt_long_outlined,
          tint: AppColors.caution,
          title: l10n.migrationPlanPrepTaxesTitle,
          body: l10n.migrationPlanPrepTaxesBody,
          uri: PreparationResourceLinks.taxEntryGuide,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.alarm_on_outlined,
          tint: AppColors.primary,
          title: l10n.migrationPlanPrepDeadlinesTitle,
          body: l10n.migrationPlanPrepDeadlinesBody,
          uri: PreparationResourceLinks.argentinaResidenceAgreement,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
      ],
    );
  }
}

class _HousingGuideSection extends StatelessWidget {
  const _HousingGuideSection({
    required this.exchangeRatesFuture,
    required this.plan,
    required this.cityName,
    required this.city,
    required this.onOpenRentalSearch,
    required this.onOpenTopic,
    required this.onOpenExternalPreparationLink,
  });

  final Future<CopilotExchangeRates?> exchangeRatesFuture;
  final MigrationPlan plan;
  final String? cityName;
  final City? city;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.migrationPlanPrepHousingGuideTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.migrationPlanPrepHousingGuideBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoGuideCard(
          icon: Icons.account_balance_wallet_outlined,
          tint: AppColors.success,
          title: l10n.migrationPlanPrepQuestionMoneyTitle,
          body: l10n.migrationPlanPrepQuestionMoneyBody,
          onTap: () => _showPreparationSheet(
            context,
            title: l10n.migrationPlanPrepQuestionMoneyTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ToolIntroCard(
                  icon: Icons.account_balance_wallet_outlined,
                  tint: AppColors.success,
                  title: l10n.migrationPlanPrepQuestionMoneyTitle,
                  body: l10n.migrationPlanPrepQuestionMoneyBody,
                ),
                const SizedBox(height: 12),
                FutureBuilder<CopilotExchangeRates?>(
                  future: exchangeRatesFuture,
                  builder: (context, snapshot) {
                    return LandingBudgetEstimatorSection(
                      plan: plan,
                      exchangeRates: snapshot.data,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (city != null)
          _InfoGuideCard(
            icon: Icons.home_work_outlined,
            tint: AppColors.secondary,
            title: l10n.migrationPlanPrepRentalSearchTitle,
            body: l10n.migrationPlanPrepRentalSearchBody(
              city!.name,
              city!.stateCode,
            ),
            onTap: () => _showPreparationSheet(
              context,
              title: l10n.migrationPlanPrepRentalSearchTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToolIntroCard(
                    icon: Icons.home_work_outlined,
                    tint: AppColors.secondary,
                    title: l10n.migrationPlanPrepRentalSearchTitle,
                    body: l10n.migrationPlanPrepRentalSearchBody(
                      city!.name,
                      city!.stateCode,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RentalSearchCard(
                    city: city!,
                    onOpenRentalSearch: onOpenRentalSearch,
                  ),
                ],
              ),
            ),
          ),
        if (city != null) const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.key_outlined,
          tint: AppColors.primary,
          title: l10n.documentationHousingArrivalSectionTitle,
          body: l10n.migrationPlanPrepQuestionRentBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.housing),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.price_check_outlined,
          tint: AppColors.secondary,
          title: l10n.documentationPathCostsTitle,
          body: l10n.housingEntryDisclaimer,
          onTap: () => onOpenTopic(DocumentationGuideSection.costs),
        ),
        const SizedBox(height: 14),
        _ExternalToolCard(
          icon: Icons.warning_amber_rounded,
          tint: AppColors.caution,
          title: l10n.migrationPlanPrepScamsTitle,
          body: l10n.migrationPlanPrepScamsBody,
          uri: PreparationResourceLinks.rentalScamAlert,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
      ],
    );
  }
}

class _ToolIntroCard extends StatelessWidget {
  const _ToolIntroCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tint.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
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

class _ExternalToolCard extends StatelessWidget {
  const _ExternalToolCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
    required this.uri,
    required this.onOpenExternalPreparationLink,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  final Uri uri;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;

  @override
  Widget build(BuildContext context) {
    return _InfoGuideCard(
      icon: icon,
      tint: tint,
      title: title,
      body: body,
      onTap: () => _showPreparationSheet(
        context,
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ToolIntroCard(icon: icon, tint: tint, title: title, body: body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Text(
                context.l10n.migrationPlanPrepExternalToolHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await onOpenExternalPreparationLink(title: title, uri: uri);
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(context.l10n.migrationPlanPrepOpenOfficialSource),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkGuideSection extends StatelessWidget {
  const _WorkGuideSection({
    required this.onOpenTopic,
    required this.plan,
    required this.city,
    required this.onOpenIbgePanorama,
    required this.onOpenExternalPreparationLink,
  });

  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final MigrationPlan plan;
  final City? city;
  final Future<void> Function(City city) onOpenIbgePanorama;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cityData = city;
    final isWorkGoal = plan.goal == 'find_job_br';
    final isStudyGoal = plan.goal == 'study';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.migrationPlanPrepWorkGuideTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.migrationPlanPrepWorkGuideBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoGuideCard(
          icon: Icons.work_outline_rounded,
          tint: AppColors.success,
          title: l10n.documentationPathWorkTitle,
          body: l10n.documentationPathWorkBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.work),
        ),
        if (isWorkGoal) ...[
          const SizedBox(height: 12),
          _ExternalToolCard(
            icon: Icons.business_center_outlined,
            tint: AppColors.caution,
            title: l10n.migrationPlanPrepOfficialJobsTitle,
            body: cityData == null
                ? l10n.migrationPlanPrepOfficialJobsBodyNoCity
                : l10n.migrationPlanPrepOfficialJobsBodyWithCity(
                    cityData.name,
                    cityData.stateCode,
                  ),
            uri: PreparationResourceLinks.officialJobsPortal,
            onOpenExternalPreparationLink: onOpenExternalPreparationLink,
          ),
        ],
        if (isStudyGoal) ...[
          const SizedBox(height: 12),
          _ExternalToolCard(
            icon: Icons.school_outlined,
            tint: AppColors.primary,
            title: l10n.migrationPlanPrepOfficialStudyCatalogTitle,
            body: cityData == null
                ? l10n.migrationPlanPrepOfficialStudyCatalogBodyNoCity
                : l10n.migrationPlanPrepOfficialStudyCatalogBodyWithCity(
                    cityData.name,
                    cityData.stateCode,
                  ),
            uri: PreparationResourceLinks.publicUniversitiesCatalog,
            onOpenExternalPreparationLink: onOpenExternalPreparationLink,
          ),
          const SizedBox(height: 12),
          _ExternalToolCard(
            icon: Icons.how_to_reg_outlined,
            tint: AppColors.secondary,
            title: l10n.migrationPlanPrepOfficialStudyForeignersTitle,
            body: l10n.migrationPlanPrepOfficialStudyForeignersBody,
            uri: PreparationResourceLinks.foreignStudentGuide,
            onOpenExternalPreparationLink: onOpenExternalPreparationLink,
          ),
        ],
        if (cityData != null) ...[
          const SizedBox(height: 12),
          FrostedPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.migrationPlanPrepWorkSignalsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.migrationPlanPrepWorkSignalsBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricPill(
                      label: l10n.migrationPlanPrepWorkSignalJobs,
                      value: '${cityData.jobMarketScore}/100',
                    ),
                    _MetricPill(
                      label: l10n.migrationPlanPrepWorkSignalEconomic,
                      value: '${cityData.economicActivityScore}/100',
                    ),
                    _MetricPill(
                      label: l10n.migrationPlanPrepWorkSignalUnemployment,
                      value: '${cityData.unemploymentRate.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoGuideCard(
            icon: Icons.insights_outlined,
            tint: AppColors.primary,
            title: l10n.migrationPlanPrepOfficialIncomeTitle,
            body: l10n.migrationPlanPrepOfficialIncomeBody,
            onTap: () => onOpenIbgePanorama(cityData),
          ),
        ],
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.health_and_safety_outlined,
          tint: AppColors.primary,
          title: l10n.documentationPathHealthTitle,
          body: l10n.documentationPathHealthBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.health),
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.account_balance_wallet_outlined,
          tint: AppColors.success,
          title: l10n.migrationPlanPrepMoneyPracticeTitle,
          body: l10n.migrationPlanPrepMoneyPracticeBody,
          uri: PreparationResourceLinks.financialGuide,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.gavel_outlined,
          tint: AppColors.secondary,
          title: l10n.migrationPlanPrepDiplomaTitle,
          body: l10n.migrationPlanPrepDiplomaBody,
          uri: PreparationResourceLinks.diplomaValidationGuide,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.directions_car_outlined,
          tint: AppColors.secondary,
          title: l10n.documentationPathDrivingTitle,
          body: l10n.documentationPathDrivingBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.driving),
        ),
      ],
    );
  }
}

class _ArrivalGuideSection extends StatelessWidget {
  const _ArrivalGuideSection({
    required this.onOpenTopic,
    required this.destinationCityName,
    required this.onOpenExternalPreparationLink,
  });

  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final String? destinationCityName;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.migrationPlanPrepArrivalGuideTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.migrationPlanPrepArrivalGuideBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoGuideCard(
          icon: Icons.calendar_view_week_outlined,
          tint: AppColors.primary,
          title: l10n.migrationPlanPrepArrivalWeekTitle,
          body: l10n.migrationPlanPrepArrivalWeekBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.housing),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.calendar_month_outlined,
          tint: AppColors.secondary,
          title: l10n.migrationPlanPrepArrivalMonthTitle,
          body: l10n.migrationPlanPrepArrivalMonthBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.timeline_rounded,
          tint: AppColors.success,
          title: l10n.migrationPlanPrepArrivalQuarterTitle,
          body: l10n.migrationPlanPrepArrivalQuarterBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.work),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.flight_takeoff_rounded,
          tint: AppColors.caution,
          title: l10n.migrationPlanPrepQuestionFlightsTitle,
          body: l10n.migrationPlanPrepQuestionFlightsBody,
          onTap: () => _showPreparationSheet(
            context,
            title: l10n.migrationPlanPrepQuestionFlightsTitle,
            child: _FlightSearchPlannerCard(
              destinationCityName: destinationCityName,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.groups_rounded,
          tint: AppColors.success,
          title: l10n.migrationPlanPrepSupportNetworkTitle,
          body: l10n.migrationPlanPrepSupportNetworkBody,
          uri: PreparationResourceLinks.migrantSupportNetwork,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.flag_outlined,
          tint: AppColors.primary,
          title: l10n.migrationPlanPrepArgentineNetworkTitle,
          body: l10n.migrationPlanPrepArgentineNetworkBody,
          uri: PreparationResourceLinks.argentinaConsulatesBrazil,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.family_restroom_outlined,
          tint: AppColors.secondary,
          title: l10n.migrationPlanPrepFamilyTitle,
          body: l10n.migrationPlanPrepFamilyBody,
          uri: PreparationResourceLinks.familySchoolGuide,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
        const SizedBox(height: 12),
        _ExternalToolCard(
          icon: Icons.shield_outlined,
          tint: AppColors.caution,
          title: l10n.migrationPlanPrepRiskAlertsTitle,
          body: l10n.migrationPlanPrepRiskAlertsBody,
          uri: PreparationResourceLinks.traffickingAlert,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
      ],
    );
  }
}

class _FlightSearchPlannerCard extends StatefulWidget {
  const _FlightSearchPlannerCard({required this.destinationCityName});

  final String? destinationCityName;

  @override
  State<_FlightSearchPlannerCard> createState() =>
      _FlightSearchPlannerCardState();
}

class _FlightSearchPlannerCardState extends State<_FlightSearchPlannerCard> {
  static const _argentinaCities = <String>[
    'Buenos Aires',
    'Cordoba',
    'Mendoza',
    'Rosario',
    'Salta',
    'Tucuman',
    'Bariloche',
    'Mar del Plata',
  ];

  String _originCity = _argentinaCities.first;
  DateTime? _departureDate;

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    setState(() => _departureDate = picked);
  }

  Future<void> _openGoogleFlights() async {
    final destination = widget.destinationCityName ?? 'Brazil';
    final uri = PreparationResourceLinks.buildFlightsSearch(
      originCity: _originCity,
      destinationCity: destination,
      departureDate: _departureDate,
    );
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.migrationPlanPrepQuestionFlightsTitle,
          uri: uri,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destination = widget.destinationCityName ?? l10n.questionOptionBrazil;
    final dateLabel = _departureDate == null
        ? l10n.migrationPlanPrepFlightsDatePlaceholder
        : MaterialLocalizations.of(context).formatMediumDate(_departureDate!);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanPrepFlightsPlannerTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.migrationPlanPrepFlightsPlannerBody(destination),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.migrationPlanPrepFlightsOriginLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final city in _argentinaCities)
                ChoiceChip(
                  label: Text(city),
                  selected: city == _originCity,
                  onSelected: (_) => setState(() => _originCity = city),
                ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.migrationPlanPrepFlightsDateLabel,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.textSoftFor(context)),
                        ),
                        const SizedBox(height: 3),
                        Text(dateLabel),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ToolStateCard(
            icon: Icons.route_rounded,
            title: '$_originCity -> $destination',
            body: dateLabel,
            tint: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Text(
              l10n.migrationPlanPrepFlightsDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openGoogleFlights,
            icon: const Icon(Icons.travel_explore_rounded),
            label: Text(l10n.migrationPlanPrepFlightsOpenGoogle),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _RentalSearchCard extends StatefulWidget {
  const _RentalSearchCard({
    required this.city,
    required this.onOpenRentalSearch,
  });

  final City city;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;

  @override
  State<_RentalSearchCard> createState() => _RentalSearchCardState();
}

class _RentalSearchCardState extends State<_RentalSearchCard> {
  RentalProvider _provider = RentalProvider.zapImoveis;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanPrepRentalProviderLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProviderChoiceChip(
                label: l10n.migrationPlanPrepRentalProviderZap,
                selected: _provider == RentalProvider.zapImoveis,
                onTap: () =>
                    setState(() => _provider = RentalProvider.zapImoveis),
              ),
              _ProviderChoiceChip(
                label: l10n.migrationPlanPrepRentalProviderVivaReal,
                selected: _provider == RentalProvider.vivaReal,
                onTap: () =>
                    setState(() => _provider = RentalProvider.vivaReal),
              ),
              _ProviderChoiceChip(
                label: l10n.migrationPlanPrepRentalProviderChaves,
                selected: _provider == RentalProvider.chavesNaMao,
                onTap: () =>
                    setState(() => _provider = RentalProvider.chavesNaMao),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ToolStateCard(
            icon: Icons.place_outlined,
            title: _providerLabel(context, _provider),
            body: '${widget.city.name} (${widget.city.stateCode})',
            tint: AppColors.secondary,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Text(
              l10n.migrationPlanPrepRentalSearchDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => widget.onOpenRentalSearch(widget.city, _provider),
            icon: const Icon(Icons.home_work_outlined),
            label: Text(l10n.migrationPlanPrepRentalSearchOpen),
          ),
        ],
      ),
    );
  }

  String _providerLabel(BuildContext context, RentalProvider provider) {
    final l10n = context.l10n;
    return switch (provider) {
      RentalProvider.zapImoveis => l10n.migrationPlanPrepRentalProviderZap,
      RentalProvider.vivaReal => l10n.migrationPlanPrepRentalProviderVivaReal,
      RentalProvider.chavesNaMao => l10n.migrationPlanPrepRentalProviderChaves,
    };
  }
}

class _ProviderChoiceChip extends StatelessWidget {
  const _ProviderChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ToolStateCard extends StatelessWidget {
  const _ToolStateCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: tint, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
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

class _InfoGuideCard extends StatelessWidget {
  const _InfoGuideCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.isDark(context)
                ? [
                    AppColors.surfaceFor(context).withValues(alpha: 0.9),
                    AppColors.surfaceMutedFor(context).withValues(alpha: 0.82),
                  ]
                : [Colors.white, tint.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: tint.withValues(alpha: 0.14)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(height: 1.15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _InlineActionTag(tint: tint),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineActionTag extends StatelessWidget {
  const _InlineActionTag({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(Icons.arrow_forward_rounded, size: 14, color: tint),
    );
  }
}
