import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/arrival_execution_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/arrival_execution_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/landing_budget_estimator_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/migration_document_readiness_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/migration_readiness_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_structure_widgets.dart';

enum _PreparationSection { overview, documents, housing, work, arrival }

class MigrationPlanCopilotPage extends StatefulWidget {
  const MigrationPlanCopilotPage({
    required this.controller,
    required this.exchangeRatesService,
    required this.citiesController,
    required this.journeyContextController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CopilotExchangeRatesService exchangeRatesService;
  final CitiesController citiesController;
  final JourneyContextController journeyContextController;

  @override
  State<MigrationPlanCopilotPage> createState() =>
      _MigrationPlanCopilotPageState();
}

class _MigrationPlanCopilotPageState extends State<MigrationPlanCopilotPage> {
  static const _helpPreferenceKey = 'migration_plan_copilot';
  late final Future<CopilotExchangeRates?> _exchangeRatesFuture;
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();
  Set<String> _readinessCompletedIds = <String>{};
  Set<String> _documentCompletedIds = <String>{};
  Set<String> _arrivalCompletedIds = <String>{};
  String? _loadedProgressKey;
  bool _didTryAutoHelp = false;

  @override
  void initState() {
    super.initState();
    _exchangeRatesFuture = widget.exchangeRatesService.fetchLatest();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowHelp();
    });
  }

  Future<void> _maybeShowHelp() async {
    if (_didTryAutoHelp) {
      return;
    }
    _didTryAutoHelp = true;
    await maybeShowContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _buildCopilotHelpContent(context),
    );
  }

  Future<void> _showHelp() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _buildCopilotHelpContent(context),
    );
  }

  void _openSection(
    _PreparationSection section,
    MigrationPlan plan,
    City? city,
  ) {
    if (section == _PreparationSection.overview) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PlanStageScreen(
          section: section,
          plan: plan,
          city: city,
          citiesController: widget.citiesController,
          migrationQuestionnaireController: widget.controller,
          exchangeRatesFuture: _exchangeRatesFuture,
          initialReadinessCompletedIds: _readinessCompletedIds,
          initialDocumentCompletedIds: _documentCompletedIds,
          initialArrivalCompletedIds: _arrivalCompletedIds,
          onProgressChanged: _syncProgressFromStage,
          onPersistProgress:
              (
                readinessCompletedIds,
                documentCompletedIds,
                arrivalCompletedIds,
              ) => _persistStageProgress(
                plan,
                readinessCompletedIds: readinessCompletedIds,
                documentCompletedIds: documentCompletedIds,
                arrivalCompletedIds: arrivalCompletedIds,
              ),
          onOpenGuide: _openDocumentationGuide,
          onOpenTopic: _openDocumentationTopic,
          onOpenIbgePanorama: _openIbgePanorama,
          onOpenRentalSearch: _openRentalSearch,
          onOpenExternalPreparationLink: _openExternalPreparationLink,
          onManagePlan: _handleManagePlan,
        ),
      ),
    );
  }

  Future<void> _loadProgress(MigrationPlan plan) async {
    final key = _planKey(plan);
    if (_loadedProgressKey == key) {
      return;
    }

    final snapshot = await _progressStore.read(plan);
    if (!mounted) {
      return;
    }

    setState(() {
      _loadedProgressKey = key;
      _readinessCompletedIds = Set<String>.from(snapshot.readinessCompletedIds);
      _documentCompletedIds = Set<String>.from(snapshot.documentCompletedIds);
      _arrivalCompletedIds = Set<String>.from(snapshot.arrivalCompletedIds);
    });
  }

  Future<void> _persistStageProgress(
    MigrationPlan plan, {
    required Set<String> readinessCompletedIds,
    required Set<String> documentCompletedIds,
    required Set<String> arrivalCompletedIds,
  }) {
    return _progressStore.write(
      plan: plan,
      readinessCompletedIds: readinessCompletedIds,
      documentCompletedIds: documentCompletedIds,
      arrivalCompletedIds: arrivalCompletedIds,
    );
  }

  void _syncProgressFromStage(
    Set<String> readinessCompletedIds,
    Set<String> documentCompletedIds,
    Set<String> arrivalCompletedIds,
  ) {
    setState(() {
      _readinessCompletedIds = Set<String>.from(readinessCompletedIds);
      _documentCompletedIds = Set<String>.from(documentCompletedIds);
      _arrivalCompletedIds = Set<String>.from(arrivalCompletedIds);
    });
  }

  String _planKey(MigrationPlan plan) {
    return [
      plan.originCountry,
      plan.destinationCountry,
      plan.goal,
      plan.timeline,
      plan.recommendedCity?.id ?? 'no-city',
    ].join('::');
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

  Future<void> _showToolsSheet(MigrationPlan plan, City? city) {
    return _showPlanToolsSheet(
      context,
      plan: plan,
      city: city,
      exchangeRatesFuture: _exchangeRatesFuture,
      onOpenRentalSearch: _openRentalSearch,
      onManagePlan: _handleManagePlan,
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

    final hasConfirmedCity = plan.isCityConfirmed && city != null;
    final progressSnapshot = _buildPlanProgressSnapshot(
      context,
      plan: plan,
      readinessCompletedIds: _readinessCompletedIds,
      documentCompletedIds: _documentCompletedIds,
      arrivalCompletedIds: _arrivalCompletedIds,
    );
    unawaited(_loadProgress(plan));

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
                    onBack: () => _handleBack(context),
                    onHelp: _showHelp,
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
                                    isOverview: true,
                                    section: _PreparationSection.overview,
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
                                    _PlanProgressBar(
                                      snapshot: progressSnapshot,
                                      currentStep: 1,
                                    ),
                                    const SizedBox(height: 16),
                                    _PreparationSectionRail(
                                      selectedSection:
                                          _PreparationSection.overview,
                                      onSelected: (section) =>
                                          _openSection(section, plan, city),
                                    ),
                                    const SizedBox(height: 16),
                                    _PreparationOverview(
                                      snapshot: progressSnapshot,
                                      onOpenSection: (section) =>
                                          _openSection(section, plan, city),
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
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController: widget.controller,
      ),
      floatingActionButton: hasConfirmedCity
          ? FloatingActionButton.extended(
              onPressed: () => _showToolsSheet(plan, city),
              icon: const Icon(Icons.build_circle_outlined),
              label: Text(l10n.migrationPlanCopilotToolsButton),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final didPop = await Navigator.maybePop(context);
    if (!didPop && context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
    }
  }

  Future<void> _handleManagePlan() async {
    final choice = await showPlanResetDialog(context);
    if (!mounted || choice == null) {
      return;
    }

    await widget.controller.clearCurrentPlan();
    if (!mounted) {
      return;
    }

    if (choice == PlanResetChoice.rebuild) {
      Navigator.pushReplacementNamed(context, AppRoutes.migrationQuestionnaire);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
  }
}

ContextualHelpContent _buildCopilotHelpContent(BuildContext context) {
  return ContextualHelpContent(
    eyebrow: context.l10n.migrationPlanCopilotTitle,
    contextIcon: Icons.task_alt_outlined,
    title: 'Use the plan one stage at a time',
    body:
        'Copilot turns the recommendation into a working checklist so you can focus on the next stage instead of the full move at once.',
    steps: const [
      FeatureGuideStep(
        number: '1',
        title: 'Watch the current stage',
        body:
            'The overview highlights the most important step and your overall progress.',
      ),
      FeatureGuideStep(
        number: '2',
        title: 'Open the right section',
        body:
            'Jump between documents, housing, work, and arrival without losing checklist state.',
      ),
      FeatureGuideStep(
        number: '3',
        title: 'Complete items as you go',
        body: 'Checklist progress is saved locally so you can resume later.',
      ),
    ],
  );
}

class _PlanStageScreen extends StatefulWidget {
  const _PlanStageScreen({
    required this.section,
    required this.plan,
    required this.city,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.exchangeRatesFuture,
    required this.initialReadinessCompletedIds,
    required this.initialDocumentCompletedIds,
    required this.initialArrivalCompletedIds,
    required this.onProgressChanged,
    required this.onPersistProgress,
    required this.onOpenGuide,
    required this.onOpenTopic,
    required this.onOpenIbgePanorama,
    required this.onOpenRentalSearch,
    required this.onOpenExternalPreparationLink,
    required this.onManagePlan,
  });

  final _PreparationSection section;
  final MigrationPlan plan;
  final City? city;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final Future<CopilotExchangeRates?> exchangeRatesFuture;
  final Set<String> initialReadinessCompletedIds;
  final Set<String> initialDocumentCompletedIds;
  final Set<String> initialArrivalCompletedIds;
  final void Function(Set<String>, Set<String>, Set<String>) onProgressChanged;
  final Future<void> Function(Set<String>, Set<String>, Set<String>)
  onPersistProgress;
  final VoidCallback onOpenGuide;
  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final Future<void> Function(City city) onOpenIbgePanorama;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;
  final Future<void> Function() onManagePlan;

  @override
  State<_PlanStageScreen> createState() => _PlanStageScreenState();
}

class _PlanStageScreenState extends State<_PlanStageScreen> {
  late Set<String> _readinessCompletedIds;
  late Set<String> _documentCompletedIds;
  late Set<String> _arrivalCompletedIds;

  @override
  void initState() {
    super.initState();
    _readinessCompletedIds = Set<String>.from(
      widget.initialReadinessCompletedIds,
    );
    _documentCompletedIds = Set<String>.from(
      widget.initialDocumentCompletedIds,
    );
    _arrivalCompletedIds = Set<String>.from(widget.initialArrivalCompletedIds);
  }

  Future<void> _persist() async {
    widget.onProgressChanged(
      _readinessCompletedIds,
      _documentCompletedIds,
      _arrivalCompletedIds,
    );
    await widget.onPersistProgress(
      _readinessCompletedIds,
      _documentCompletedIds,
      _arrivalCompletedIds,
    );
  }

  Future<void> _toggleReadinessItem(String id) async {
    setState(() {
      if (!_readinessCompletedIds.add(id)) {
        _readinessCompletedIds.remove(id);
      }
    });
    await _persist();
  }

  Future<void> _toggleDocumentItem(String id) async {
    setState(() {
      if (!_documentCompletedIds.add(id)) {
        _documentCompletedIds.remove(id);
      }
    });
    await _persist();
  }

  Future<void> _toggleArrivalItem(String id) async {
    setState(() {
      if (!_arrivalCompletedIds.add(id)) {
        _arrivalCompletedIds.remove(id);
      }
    });
    await _persist();
  }

  void _navigateToSection(_PreparationSection section) {
    if (section == _PreparationSection.overview) {
      Navigator.of(context).pop();
      return;
    }
    if (section == widget.section) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _PlanStageScreen(
          section: section,
          plan: widget.plan,
          city: widget.city,
          citiesController: widget.citiesController,
          migrationQuestionnaireController:
              widget.migrationQuestionnaireController,
          exchangeRatesFuture: widget.exchangeRatesFuture,
          initialReadinessCompletedIds: _readinessCompletedIds,
          initialDocumentCompletedIds: _documentCompletedIds,
          initialArrivalCompletedIds: _arrivalCompletedIds,
          onProgressChanged: widget.onProgressChanged,
          onPersistProgress: widget.onPersistProgress,
          onOpenGuide: widget.onOpenGuide,
          onOpenTopic: widget.onOpenTopic,
          onOpenIbgePanorama: widget.onOpenIbgePanorama,
          onOpenRentalSearch: widget.onOpenRentalSearch,
          onOpenExternalPreparationLink: widget.onOpenExternalPreparationLink,
          onManagePlan: widget.onManagePlan,
        ),
      ),
    );
  }

  Future<void> _showHelp() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _MigrationPlanCopilotPageState._helpPreferenceKey,
      content: _buildCopilotHelpContent(context),
    );
  }

  Future<void> _showToolsSheet() {
    return _showPlanToolsSheet(
      context,
      plan: widget.plan,
      city: widget.city,
      exchangeRatesFuture: widget.exchangeRatesFuture,
      onOpenRentalSearch: widget.onOpenRentalSearch,
      onManagePlan: widget.onManagePlan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _buildPlanProgressSnapshot(
      context,
      plan: widget.plan,
      readinessCompletedIds: _readinessCompletedIds,
      documentCompletedIds: _documentCompletedIds,
      arrivalCompletedIds: _arrivalCompletedIds,
    );

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
                    title: context.l10n.migrationPlanCopilotTitle,
                    onBack: () => Navigator.of(context).pop(),
                    onHelp: _showHelp,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          18,
                          context.pageHorizontalPadding,
                          28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PreparationHero(
                              cityName: widget.city?.name,
                              stateCode: widget.city?.stateCode,
                              isOverview: false,
                              section: widget.section,
                            ),
                            const SizedBox(height: 16),
                            _PlanProgressBar(
                              snapshot: snapshot,
                              currentStep: widget.section.index + 1,
                            ),
                            const SizedBox(height: 16),
                            _PreparationSectionRail(
                              selectedSection: widget.section,
                              onSelected: _navigateToSection,
                            ),
                            const SizedBox(height: 16),
                            _PreparationSectionContent(
                              section: widget.section,
                              readinessCompletedIds: _readinessCompletedIds,
                              documentCompletedIds: _documentCompletedIds,
                              arrivalCompletedIds: _arrivalCompletedIds,
                              onToggleReadinessItem: _toggleReadinessItem,
                              onToggleDocumentItem: _toggleDocumentItem,
                              onToggleArrivalItem: _toggleArrivalItem,
                              onOpenGuide: widget.onOpenGuide,
                              onOpenTopic: widget.onOpenTopic,
                              onOpenIbgePanorama: widget.onOpenIbgePanorama,
                              onOpenRentalSearch: widget.onOpenRentalSearch,
                              onOpenExternalPreparationLink:
                                  widget.onOpenExternalPreparationLink,
                              plan: widget.plan,
                              city: widget.city,
                              citiesController: widget.citiesController,
                              migrationQuestionnaireController:
                                  widget.migrationQuestionnaireController,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showToolsSheet,
        icon: const Icon(Icons.build_circle_outlined),
        label: Text(context.l10n.migrationPlanCopilotToolsButton),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Future<void> _showPlanToolsSheet(
  BuildContext context, {
  required MigrationPlan plan,
  required City? city,
  required Future<CopilotExchangeRates?> exchangeRatesFuture,
  required Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch,
  required Future<void> Function() onManagePlan,
}) {
  final l10n = context.l10n;
  final planResetCopy = PlanResetDialogCopy.fromContext(context);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: FrostedPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.migrationPlanCopilotToolsButton,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ToolMenuCard(
                    icon: Icons.account_balance_wallet_outlined,
                    tint: AppColors.success,
                    title: l10n.migrationPlanPrepQuestionMoneyTitle,
                    body: l10n.migrationPlanPrepQuestionMoneyBody,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showPreparationSheet(
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
                                  preferredCountryId: plan.originCountry,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ToolMenuCard(
                    icon: Icons.flight_takeoff_rounded,
                    tint: AppColors.caution,
                    title: l10n.migrationPlanPrepQuestionFlightsTitle,
                    body: l10n.migrationPlanPrepQuestionFlightsBody,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showPreparationSheet(
                        context,
                        title: l10n.migrationPlanPrepQuestionFlightsTitle,
                        child: _FlightSearchPlannerCard(
                          destinationCityName: city?.name,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ToolMenuCard(
                    icon: Icons.home_work_outlined,
                    tint: AppColors.secondary,
                    title: l10n.migrationPlanPrepRentalSearchTitle,
                    body: city == null
                        ? l10n.migrationPlanCopilotCityRequiredHint
                        : l10n.migrationPlanPrepRentalSearchBody(
                            city.name,
                            city.stateCode,
                          ),
                    enabled: city != null,
                    onTap: city == null
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            _showPreparationSheet(
                              context,
                              title: l10n.migrationPlanPrepRentalSearchTitle,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ToolIntroCard(
                                    icon: Icons.home_work_outlined,
                                    tint: AppColors.secondary,
                                    title:
                                        l10n.migrationPlanPrepRentalSearchTitle,
                                    body: l10n
                                        .migrationPlanPrepRentalSearchBody(
                                          city.name,
                                          city.stateCode,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  _RentalSearchCard(
                                    city: city,
                                    onOpenRentalSearch: onOpenRentalSearch,
                                  ),
                                ],
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 12),
                  _ToolMenuCard(
                    icon: Icons.delete_outline_rounded,
                    tint: AppColors.danger,
                    title: planResetCopy.manageActionLabel,
                    body: planResetCopy.manageActionBody,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await onManagePlan();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
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
    final sectionLabel = _sectionLabel(context, section);

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
              _HeroPill(
                label: isOverview
                    ? l10n.migrationPlanPrepTabOverview
                    : sectionLabel,
              ),
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PrepHeroStat(
                label: l10n.migrationPlanCopilotTitle,
                value: isOverview
                    ? l10n.migrationPlanPrepTabOverview
                    : sectionLabel,
                icon: Icons.flag_rounded,
              ),
              if (cityName != null)
                _PrepHeroStat(
                  label: l10n.migrationPlanDecisionLabel,
                  value: cityName!,
                  icon: Icons.location_city_rounded,
                ),
            ],
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
}

class _PrepHeroStat extends StatelessWidget {
  const _PrepHeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.74),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 680;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final section in sections)
              SizedBox(
                width: itemWidth,
                child: _SectionChip(
                  label: _label(context, section),
                  icon: _icon(section),
                  selected: selectedSection == section,
                  onTap: () => onSelected(section),
                ),
              ),
          ],
        );
      },
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
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.28)
                : AppColors.borderFor(context),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                    (selected
                            ? AppColors.primary
                            : AppColors.textSoftFor(context))
                        .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSoftFor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimaryFor(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selected ? 'Current stage' : 'Open stage',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_rounded,
              size: 18,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSoftFor(context),
            ),
          ],
        ),
      ),
    );
  }
}

_PlanProgressSnapshot _buildPlanProgressSnapshot(
  BuildContext context, {
  required MigrationPlan plan,
  required Set<String> readinessCompletedIds,
  required Set<String> documentCompletedIds,
  required Set<String> arrivalCompletedIds,
}) {
  final l10n = context.l10n;
  final readinessChecklist = MigrationReadinessBuilder.build(
    l10n: l10n,
    plan: plan,
  );
  final documentChecklist = MigrationDocumentReadinessBuilder.build(
    l10n: l10n,
    plan: plan,
  );
  final arrivalChecklist = ArrivalExecutionBuilder.build(
    l10n: l10n,
    plan: plan,
  );

  final macroStages = <_PlanStageState>[
    _PlanStageState(
      title: l10n.migrationPlanCopilotStepStartTitle,
      body: l10n.migrationPlanCopilotStepStartBody,
      section: _PreparationSection.documents,
      totalItems: readinessChecklist.items.length,
      completedItems: readinessCompletedIds.length,
    ),
    _PlanStageState(
      title: l10n.migrationPlanCopilotStepDocumentsTitle,
      body: l10n.migrationPlanCopilotStepDocumentsBody,
      section: _PreparationSection.documents,
      totalItems: documentChecklist.items.length,
      completedItems: documentCompletedIds.length,
    ),
    _PlanStageState(
      title: l10n.migrationPlanCopilotStepArrivalTitle,
      body: l10n.migrationPlanCopilotStepArrivalBody,
      section: _PreparationSection.arrival,
      totalItems: arrivalChecklist.items.length,
      completedItems: arrivalCompletedIds.length,
    ),
  ];

  final totalItems = macroStages.fold<int>(
    0,
    (sum, item) => sum + item.totalItems,
  );
  final completedItems = macroStages.fold<int>(
    0,
    (sum, item) => sum + item.completedItems,
  );
  final currentIndex = macroStages.indexWhere((item) => !item.isComplete);

  return _PlanProgressSnapshot(
    completedItems: completedItems,
    totalItems: totalItems,
    macroStages: macroStages,
    nextStage: currentIndex == -1
        ? macroStages.last
        : macroStages[currentIndex],
  );
}

class _PlanProgressSnapshot {
  const _PlanProgressSnapshot({
    required this.completedItems,
    required this.totalItems,
    required this.macroStages,
    required this.nextStage,
  });

  final int completedItems;
  final int totalItems;
  final List<_PlanStageState> macroStages;
  final _PlanStageState nextStage;

  double get progress => totalItems == 0 ? 0 : completedItems / totalItems;
  int get percent => (progress * 100).round();
}

class _PlanStageState {
  const _PlanStageState({
    required this.title,
    required this.body,
    required this.section,
    required this.totalItems,
    required this.completedItems,
  });

  final String title;
  final String body;
  final _PreparationSection section;
  final int totalItems;
  final int completedItems;

  double get progress => totalItems == 0 ? 0 : completedItems / totalItems;
  int get percent => (progress * 100).round();
  bool get isComplete => totalItems > 0 && completedItems >= totalItems;
  bool get isNotStarted => completedItems == 0;
}

class _PlanProgressBar extends StatelessWidget {
  const _PlanProgressBar({required this.snapshot, required this.currentStep});

  final _PlanProgressSnapshot snapshot;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.migrationPlanCopilotProgressHeader(
              currentStep,
              5,
              snapshot.percent,
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.migrationPlanCopilotProgressValue(
              snapshot.completedItems,
              snapshot.totalItems,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: snapshot.progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.surfaceMutedFor(context),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (
                var index = 0;
                index < snapshot.macroStages.length;
                index++
              ) ...[
                Expanded(
                  child: _TimelineStage(
                    state: snapshot.macroStages[index],
                    isCurrent: identical(
                      snapshot.macroStages[index],
                      snapshot.nextStage,
                    ),
                  ),
                ),
                if (index != snapshot.macroStages.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.borderFor(context),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStage extends StatelessWidget {
  const _TimelineStage({required this.state, required this.isCurrent});

  final _PlanStageState state;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final tint = state.isComplete
        ? AppColors.success
        : isCurrent
        ? AppColors.primary
        : AppColors.textSoftFor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: tint.withValues(alpha: 0.22)),
          ),
          child: Icon(
            state.isComplete ? Icons.check_rounded : Icons.flag_rounded,
            size: 16,
            color: tint,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PreparationOverview extends StatelessWidget {
  const _PreparationOverview({
    required this.snapshot,
    required this.onOpenSection,
  });

  final _PlanProgressSnapshot snapshot;
  final ValueChanged<_PreparationSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanNextActionCard(
          eyebrow: l10n.migrationPlanCopilotHomeTitle,
          title: l10n.migrationPlanCopilotNextActionsTitle,
          body: l10n.migrationPlanCopilotNextActionsBody,
          actionLabel: l10n.migrationPlanCopilotRecommendedOpen,
          onTap: () => onOpenSection(snapshot.nextStage.section),
          progressLabel: l10n.migrationPlanCopilotStageCountLabel(4),
          icon: Icons.auto_awesome_rounded,
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
                for (final stage in snapshot.macroStages)
                  SizedBox(
                    width: cardWidth,
                    child: _MacroStageCard(
                      stage: stage,
                      onTap: () => onOpenSection(stage.section),
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

class _MacroStageCard extends StatelessWidget {
  const _MacroStageCard({required this.stage, required this.onTap});

  final _PlanStageState stage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CompareCard(
      title: stage.title,
      subtitle: _statusLabel(context, stage),
      metrics: [
        CompareCardMetric(
          label: context.l10n.migrationPlanCopilotProgressValue(
            stage.completedItems,
            stage.totalItems,
          ),
          value: '${stage.percent}%',
          icon: Icons.timeline_rounded,
          tone: stage.isComplete
              ? ScoreTone.positive
              : stage.isNotStarted
              ? ScoreTone.attention
              : ScoreTone.balanced,
        ),
      ],
      onTap: onTap,
      actionLabel: context.l10n.migrationPlanCopilotRecommendedOpen,
    );
  }

  String _statusLabel(BuildContext context, _PlanStageState stage) {
    final l10n = context.l10n;
    if (stage.isComplete) {
      return l10n.migrationPlanCopilotStatusDone;
    }
    if (stage.isNotStarted) {
      return l10n.migrationPlanCopilotStatusNotStarted;
    }
    return l10n.migrationPlanCopilotStatusInProgress;
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
          InsightCard(
            title: context.l10n.migrationPlanPrepChooseCityTitle,
            body: context.l10n.migrationPlanPrepChooseCityBody,
            icon: Icons.location_city_outlined,
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
    required this.readinessCompletedIds,
    required this.documentCompletedIds,
    required this.arrivalCompletedIds,
    required this.onToggleReadinessItem,
    required this.onToggleDocumentItem,
    required this.onToggleArrivalItem,
    required this.onOpenGuide,
    required this.onOpenTopic,
    required this.onOpenIbgePanorama,
    required this.onOpenRentalSearch,
    required this.onOpenExternalPreparationLink,
    required this.plan,
    required this.city,
    required this.citiesController,
    required this.migrationQuestionnaireController,
  });

  final _PreparationSection section;
  final Set<String> readinessCompletedIds;
  final Set<String> documentCompletedIds;
  final Set<String> arrivalCompletedIds;
  final ValueChanged<String> onToggleReadinessItem;
  final ValueChanged<String> onToggleDocumentItem;
  final ValueChanged<String> onToggleArrivalItem;
  final VoidCallback onOpenGuide;
  final ValueChanged<DocumentationGuideSection> onOpenTopic;
  final Future<void> Function(City city) onOpenIbgePanorama;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final Future<void> Function({required String title, required Uri uri})
  onOpenExternalPreparationLink;
  final MigrationPlan plan;
  final City? city;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case _PreparationSection.overview:
        return const SizedBox.shrink();
      case _PreparationSection.documents:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MigrationDocumentReadinessSection(
              plan: plan,
              completedItemIds: documentCompletedIds,
              onToggleItem: onToggleDocumentItem,
            ),
            const SizedBox(height: 16),
            _DocumentsGuideSection(
              onOpenGuide: onOpenGuide,
              onOpenTopic: onOpenTopic,
              onOpenExternalPreparationLink: onOpenExternalPreparationLink,
            ),
          ],
        );
      case _PreparationSection.housing:
        return _HousingGuideSection(
          plan: plan,
          cityName: city?.name,
          city: city,
          citiesController: citiesController,
          migrationQuestionnaireController: migrationQuestionnaireController,
          onOpenTopic: onOpenTopic,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        );
      case _PreparationSection.work:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MigrationReadinessSection(
              plan: plan,
              completedItemIds: readinessCompletedIds,
              onToggleItem: onToggleReadinessItem,
            ),
            const SizedBox(height: 16),
            _WorkGuideSection(
              onOpenTopic: onOpenTopic,
              plan: plan,
              city: city,
              onOpenIbgePanorama: onOpenIbgePanorama,
              onOpenExternalPreparationLink: onOpenExternalPreparationLink,
            ),
          ],
        );
      case _PreparationSection.arrival:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArrivalExecutionSection(
              plan: plan,
              completedItemIds: arrivalCompletedIds,
              onToggleItem: onToggleArrivalItem,
            ),
            const SizedBox(height: 16),
            _ArrivalGuideSection(
              onOpenTopic: onOpenTopic,
              destinationCityName: city?.name,
              onOpenExternalPreparationLink: onOpenExternalPreparationLink,
            ),
          ],
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
    required this.plan,
    required this.cityName,
    required this.city,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.onOpenTopic,
    required this.onOpenExternalPreparationLink,
  });

  final MigrationPlan plan;
  final String? cityName;
  final City? city;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
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
        if (city == null) ...[
          _AvailabilityNoteCard(
            icon: Icons.home_work_outlined,
            text: l10n.migrationPlanCopilotCityRequiredHint,
          ),
          const SizedBox(height: 12),
        ],
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
        if (city != null) ...[
          const SizedBox(height: 14),
          FrostedPanel(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_city_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.migrationPlanHousingCompareTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.migrationPlanHousingCompareBody(city!.name),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CityComparisonScreen(
                                initialCities: [city!],
                                citiesController: citiesController,
                                migrationQuestionnaireController:
                                    migrationQuestionnaireController,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: Text(l10n.migrationPlanHousingCompareAction),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        ] else if (!isStudyGoal) ...[
          const SizedBox(height: 12),
          _AvailabilityNoteCard(
            icon: Icons.flag_outlined,
            text: l10n.migrationPlanCopilotGoalRequiredHint,
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
        ] else ...[
          const SizedBox(height: 12),
          _AvailabilityNoteCard(
            icon: Icons.location_city_outlined,
            text: l10n.migrationPlanCopilotCityRequiredHint,
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
        _AvailabilityNoteCard(
          icon: Icons.flight_takeoff_rounded,
          text: l10n.migrationPlanCopilotToolsFlightsHint,
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

class _ToolMenuCard extends StatelessWidget {
  const _ToolMenuCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled
            ? tint.withValues(alpha: 0.08)
            : AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: enabled
              ? tint.withValues(alpha: 0.14)
              : AppColors.borderFor(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: enabled
                  ? tint.withValues(alpha: 0.12)
                  : AppColors.surfaceFor(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: enabled ? tint : AppColors.textSoftFor(context),
              size: 20,
            ),
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
          const SizedBox(width: 12),
          Icon(
            enabled ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
            color: enabled ? tint : AppColors.textSoftFor(context),
          ),
        ],
      ),
    );

    if (!enabled || onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: content,
    );
  }
}

class _AvailabilityNoteCard extends StatelessWidget {
  const _AvailabilityNoteCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSoftFor(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
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
