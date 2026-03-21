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
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/guide_gps_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/arrival_execution_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/document_checklist_adapter.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/housing_selection_screen.dart';
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
  Map<String, String> _completedAtById = <String, String>{};
  String? _loadedProgressKey;
  String? _loadedActiveItemId;
  GuideGpsController? _gpsController;
  String? _gpsControllerKey;
  bool _didTryAutoHelp = false;
  bool _showCelebration = false;
  bool _showExpandedContent = false;

  @override
  void initState() {
    super.initState();
    _exchangeRatesFuture = widget.exchangeRatesService.fetchLatest();
    unawaited(PlanNotificationService.instance.cancelPlanReminders());
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

  // ignore: unused_element
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
      _loadedActiveItemId = snapshot.activeItemId;
      _completedAtById = Map<String, String>.from(snapshot.completedAtById);
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

  void _ensureGpsController(
    BuildContext context,
    MigrationPlan plan,
    List<GuideActionItem> items,
  ) {
    final signature = [
      _planKey(plan),
      _readinessCompletedIds.length,
      _documentCompletedIds.length,
      _arrivalCompletedIds.length,
      _loadedActiveItemId ?? 'none',
      items.length,
      _completedAtById.length,
    ].join('::');

    if (_gpsControllerKey == signature && _gpsController != null) {
      return;
    }

    _gpsController = GuideGpsController(
      plan: plan,
      progressStore: _progressStore,
      items: items,
      readinessCompletedIds: _readinessCompletedIds,
      documentCompletedIds: _documentCompletedIds,
      arrivalCompletedIds: _arrivalCompletedIds,
      completedAtById: _completedAtById,
      activeItemId: _loadedActiveItemId,
    );
    _gpsControllerKey = signature;
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

  List<GuideActionItem> _buildGuideActionItems(
    BuildContext context,
    MigrationPlan plan,
  ) {
    if (plan.originCountry.toUpperCase() == 'AR' &&
        plan.destinationCountry.toUpperCase() == 'BR') {
      final completedIds = <String>{
        ..._readinessCompletedIds,
        ..._documentCompletedIds,
        ..._arrivalCompletedIds,
      };
      return ArgentinaBrazilGuideDataSource.build(plan)
          .map(
            (item) =>
                item.copyWith(isCompleted: completedIds.contains(item.id)),
          )
          .toList(growable: false);
    }

    final l10n = context.l10n;
    final readinessChecklist = MigrationReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );
    final documentChecklist = MigrationDocumentReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );
    final adaptedDocumentItems = DocumentChecklistAdapter.getItems(
      l10n: l10n,
      originCountry: plan.originCountry,
      destinationCountry: plan.destinationCountry,
      goal: plan.goal,
      travelGroup: plan.travelGroup,
      fallbackChecklist: documentChecklist,
    );
    final arrivalChecklist = ArrivalExecutionBuilder.build(
      l10n: l10n,
      plan: plan,
    );

    var orderIndex = 0;
    final items = <GuideActionItem>[];

    for (final item in readinessChecklist.items) {
      items.add(
        GuideActionItem(
          id: item.id,
          title: item.title,
          shortDescription: item.description,
          fullContent: item.description,
          type: switch (item.id) {
            'landing_budget' => GuideActionType.tool,
            'housing' => GuideActionType.tool,
            _ => GuideActionType.informative,
          },
          toolType: switch (item.id) {
            'landing_budget' => GuideToolType.budget,
            'housing' => GuideToolType.housing,
            _ => null,
          },
          phase: switch (item.id) {
            'housing' => GuidePhase.housing,
            'goal_layer' || 'cpf_bank' => GuidePhase.work,
            'arrival_plan' => GuidePhase.arrival,
            _ => GuidePhase.preparation,
          },
          orderIndex: orderIndex++,
          isCompleted: _readinessCompletedIds.contains(item.id),
          icon: item.icon,
        ),
      );
    }

    for (final item in adaptedDocumentItems) {
      items.add(
        GuideActionItem(
          id: item.id,
          title: item.title,
          shortDescription: item.description,
          fullContent: [
            item.description,
            if (item.tip != null) item.tip!,
            item.timeEstimate,
          ].join('\n\n'),
          type: item.link != null
              ? GuideActionType.external
              : GuideActionType.informative,
          externalUrl: item.link,
          externalLabel: _localizedText(
            context,
            pt: 'site oficial',
            es: 'sitio oficial',
            en: 'official site',
          ),
          phase: GuidePhase.documents,
          orderIndex: orderIndex++,
          isCompleted: _documentCompletedIds.contains(item.id),
        ),
      );
    }

    items.addAll([
      GuideActionItem(
        id: 'housing_temporary_base',
        title: _localizedText(
          context,
          pt: 'Reservar moradia temporaria',
          es: 'Reservar vivienda temporal',
          en: 'Book temporary housing',
        ),
        shortDescription: _localizedText(
          context,
          pt: 'Comece pela chegada segura: 1 a 3 meses em moradia temporaria.',
          es: 'Empeza por una llegada segura: 1 a 3 meses en vivienda temporal.',
          en: 'Start with a safer arrival: 1 to 3 months in temporary housing.',
        ),
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.housing,
        orderIndex: orderIndex++,
        isCompleted: _readinessCompletedIds.contains('housing_temporary_base'),
        icon: Icons.bed_outlined,
      ),
      GuideActionItem(
        id: 'housing_long_term_search',
        title: _localizedText(
          context,
          pt: 'Pesquisar aluguel fixo',
          es: 'Buscar alquiler fijo',
          en: 'Search long-term rent',
        ),
        shortDescription: _localizedText(
          context,
          pt: 'Depois de conhecer os bairros, avance para o aluguel definitivo.',
          es: 'Despues de conocer los barrios, avanza al alquiler definitivo.',
          en: 'After knowing the neighborhoods, move to a long-term rental.',
        ),
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.housing,
        orderIndex: orderIndex++,
        isCompleted: _readinessCompletedIds.contains(
          'housing_long_term_search',
        ),
        icon: Icons.home_work_outlined,
      ),
    ]);

    for (final item in arrivalChecklist.items) {
      items.add(
        GuideActionItem(
          id: item.id,
          title: item.title,
          shortDescription: item.description,
          fullContent: item.description,
          type: GuideActionType.informative,
          phase: GuidePhase.arrival,
          orderIndex: orderIndex++,
          isCompleted: _arrivalCompletedIds.contains(item.id),
          icon: item.icon,
        ),
      );
    }

    return items;
  }

  Future<void> _handleCurrentActionTap(
    GuideGpsController controller,
    GuideActionItem item,
    MigrationPlan plan,
    City? city,
  ) async {
    switch (item.type) {
      case GuideActionType.informative:
        if (!_showExpandedContent) {
          controller.startCurrentItem();
          setState(() {
            _showExpandedContent = true;
          });
          return;
        }
        await _completeGuideItem(controller, item.id);
      case GuideActionType.external:
        if (!controller.awaitingConfirmation) {
          controller.startCurrentItem();
          if (item.externalUrl != null) {
            await _openExternalPreparationLink(
              title: item.title,
              uri: Uri.parse(item.externalUrl!),
            );
          }
          controller.markNeedsConfirmation();
          setState(() {});
          return;
        }
        await _completeGuideItem(controller, item.id);
      case GuideActionType.tool:
        if (!controller.awaitingConfirmation) {
          controller.startCurrentItem();
          await _openToolForItem(item, plan, city);
          controller.markNeedsConfirmation();
          setState(() {});
          return;
        }
        await _completeGuideItem(controller, item.id);
      case GuideActionType.checklist:
        return;
    }
  }

  Future<void> _openToolForItem(
    GuideActionItem item,
    MigrationPlan plan,
    City? city,
  ) async {
    switch (item.toolType) {
      case GuideToolType.budget:
        await _showPreparationSheet(
          context,
          title: item.title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<CopilotExchangeRates?>(
                future: _exchangeRatesFuture,
                builder: (context, snapshot) {
                  return LandingBudgetEstimatorSection(
                    plan: plan,
                    exchangeRates: snapshot.data,
                  );
                },
              ),
            ],
          ),
        );
      case GuideToolType.flight:
        await _showPreparationSheet(
          context,
          title: item.title,
          child: _FlightSearchPlannerCard(
            destinationCityName: city?.name ?? '',
          ),
        );
      case GuideToolType.housing:
        if (city == null) {
          return;
        }
        final preselectedType =
            item.id == 'item_3_2_aluguel_fixo' ||
                item.id == 'housing_long_term_search'
            ? HousingType.permanent
            : HousingType.temporary;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HousingSelectionScreen(
              city: city,
              onOpenRentalSearch: _openRentalSearch,
              onHelp: _showHelp,
              skipTypeSelection: true,
              preselectedType: preselectedType,
            ),
          ),
        );
      case null:
        break;
    }
  }

  Future<void> _completeGuideItem(
    GuideGpsController controller,
    String itemId,
  ) async {
    await controller.completeActionItem(itemId);
    if (!mounted) {
      return;
    }
    setState(() {
      _showCelebration = true;
      _showExpandedContent = false;
      _readinessCompletedIds = Set<String>.from(
        controller.readinessCompletedIds,
      );
      _documentCompletedIds = Set<String>.from(controller.documentCompletedIds);
      _arrivalCompletedIds = Set<String>.from(controller.arrivalCompletedIds);
      _loadedActiveItemId = controller.activeItemId;
      _completedAtById = Map<String, String>.from(controller.completedAtById);
    });
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) {
      return;
    }
    setState(() {
      _showCelebration = false;
    });
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
    final actionItems = _buildGuideActionItems(context, plan);
    _ensureGpsController(context, plan, actionItems);
    final gpsController = _gpsController!;
    unawaited(_loadProgress(plan));

    return Scaffold(
      extendBody: true,
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
                  child: _GuideGpsHeader(
                    cityLabel: city == null
                        ? null
                        : '${city.name}, ${city.stateName}',
                    onBack: () => _handleBack(context),
                    onMore: () => _showGuideMoreSheet(
                      context,
                      plan: plan,
                      city: city,
                      controller: gpsController,
                    ),
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
                          20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              _GuideContextBand(controller: gpsController),
                              const SizedBox(height: 12),
                              _GuideUnifiedProgressBar(
                                controller: gpsController,
                              ),
                              const SizedBox(height: 16),
                              _GuideDominantActionCard(
                                item: gpsController.currentItem,
                                showCelebration: _showCelebration,
                                showExpandedContent: _showExpandedContent,
                                onPrimaryTap: (item) => _handleCurrentActionTap(
                                  gpsController,
                                  item,
                                  plan,
                                  city,
                                ),
                                onChecklistToggle: (itemId, subItemId) async {
                                  await gpsController.toggleChecklistSubItem(
                                    itemId,
                                    subItemId,
                                  );
                                  setState(() {
                                    _readinessCompletedIds = Set<String>.from(
                                      gpsController.readinessCompletedIds,
                                    );
                                    _documentCompletedIds = Set<String>.from(
                                      gpsController.documentCompletedIds,
                                    );
                                    _arrivalCompletedIds = Set<String>.from(
                                      gpsController.arrivalCompletedIds,
                                    );
                                  });
                                  final current = gpsController.currentItem;
                                  _completedAtById = Map<String, String>.from(
                                    gpsController.completedAtById,
                                  );
                                  final previous = actionItems.firstWhere(
                                    (item) => item.id == itemId,
                                    orElse: () => const GuideActionItem(
                                      id: '',
                                      title: '',
                                      shortDescription: '',
                                      type: GuideActionType.informative,
                                      phase: GuidePhase.preparation,
                                      orderIndex: -1,
                                      isCompleted: false,
                                    ),
                                  );
                                  if (previous.id.isNotEmpty &&
                                      previous.id != current?.id &&
                                      previous.hasChecklist) {
                                    await _completeGuideItem(
                                      gpsController,
                                      previous.id,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              _GuideUpcomingSection(
                                controller: gpsController,
                                onSelectItem: (itemId) async {
                                  await gpsController.jumpToItem(itemId);
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    _showExpandedContent = false;
                                  });
                                },
                              ),
                              const SizedBox(height: 18),
                              _GuidePlanCompleteBar(
                                totalItems: gpsController.totalItems,
                                onTap: () => _showFullPlanSheet(
                                  context,
                                  controller: gpsController,
                                ),
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
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 2,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController: widget.controller,
      ),
    );
  }

  Future<void> _showGuideMoreSheet(
    BuildContext context, {
    required MigrationPlan plan,
    required City? city,
    required GuideGpsController controller,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FrostedPanel(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideMenuAction(
                    icon: Icons.list_alt_rounded,
                    title: _localizedText(
                      context,
                      pt: 'Ver plano completo',
                      es: 'Ver plan completo',
                      en: 'View full plan',
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showFullPlanSheet(context, controller: controller);
                    },
                  ),
                  _GuideMenuAction(
                    icon: Icons.build_circle_outlined,
                    title: _localizedText(
                      context,
                      pt: 'Ferramentas',
                      es: 'Herramientas',
                      en: 'Tools',
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showToolsSheet(plan, city);
                    },
                  ),
                  _GuideMenuAction(
                    icon: Icons.restart_alt_rounded,
                    title: _localizedText(
                      context,
                      pt: 'Reiniciar plano',
                      es: 'Reiniciar plan',
                      en: 'Reset plan',
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _handleManagePlan();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFullPlanSheet(
    BuildContext context, {
    required GuideGpsController controller,
  }) {
    final groupedItems = <GuidePhase, List<GuideActionItem>>{};
    for (final item in controller.items) {
      groupedItems.putIfAbsent(item.phase, () => <GuideActionItem>[]).add(item);
    }
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                            _localizedText(
                              context,
                              pt: 'Plano completo',
                              es: 'Plan completo',
                              en: 'Full plan',
                            ),
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
                    for (final phase in GuidePhase.values) ...[
                      _GuidePlanGroup(
                        phaseLabel: _guidePhaseName(context, phase),
                        items: groupedItems[phase] ?? const [],
                        completedIds: controller.allCompletedIds,
                        currentItemId: controller.currentItem?.id,
                        isUnlocked: controller.isItemUnlocked,
                        onTapItem: (item) async {
                          Navigator.of(sheetContext).pop();
                          await controller.jumpToItem(item.id);
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            _showExpandedContent = false;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final didPop = await Navigator.maybePop(context);
    if (!didPop && context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
    }
  }

  Future<void> _handleManagePlan() async {
    final choice = await showPlanResetDialog(
      context,
      currentCityName: widget.controller.generatedPlan?.recommendedCity?.name,
    );
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
    title: context.l10n.copilotGuideTitle(),
    body: context.l10n.copilotGuideBody(),
    steps: [
      FeatureGuideStep(
        number: '1',
        title: context.l10n.copilotGuideStepOneTitle(),
        body: context.l10n.copilotGuideStepOneBody(),
      ),
      FeatureGuideStep(
        number: '2',
        title: context.l10n.copilotGuideStepTwoTitle(),
        body: context.l10n.copilotGuideStepTwoBody(),
      ),
      FeatureGuideStep(
        number: '3',
        title: context.l10n.copilotGuideStepThreeTitle(),
        body: context.l10n.copilotGuideStepThreeBody(),
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
    final wasCompleted = !_readinessCompletedIds.contains(id);
    setState(() {
      if (!_readinessCompletedIds.add(id)) {
        _readinessCompletedIds.remove(id);
      }
    });
    await _persist();
    if (wasCompleted && mounted) {
      _showCompletionFeedback(context, _readinessCompletedIds.length);
    }
  }

  Future<void> _toggleDocumentItem(String id) async {
    final wasCompleted = !_documentCompletedIds.contains(id);
    setState(() {
      if (!_documentCompletedIds.add(id)) {
        _documentCompletedIds.remove(id);
      }
    });
    await _persist();
    if (wasCompleted && mounted) {
      _showCompletionFeedback(context, _documentCompletedIds.length);
    }
  }

  Future<void> _toggleArrivalItem(String id) async {
    final wasCompleted = !_arrivalCompletedIds.contains(id);
    setState(() {
      if (!_arrivalCompletedIds.add(id)) {
        _arrivalCompletedIds.remove(id);
      }
    });
    await _persist();
    if (wasCompleted && mounted) {
      _showCompletionFeedback(context, _arrivalCompletedIds.length);
    }
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
                              plan: widget.plan,
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
  required Future<void> Function() onManagePlan,
}) {
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
                          _localizedText(
                            context,
                            pt: 'Ferramentas',
                            es: 'Herramientas',
                            en: 'Tools',
                          ),
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
                    title: _localizedText(
                      context,
                      pt: 'Quanto voce vai gastar nos primeiros meses',
                      es: 'Cuanto vas a gastar en los primeros meses',
                      en: 'How much you will spend in the first months',
                    ),
                    body: _localizedText(
                      context,
                      pt: 'Veja quanto voce precisa para os primeiros 30, 60 e 90 dias.',
                      es: 'Mira cuanto necesitas para los primeros 30, 60 y 90 dias.',
                      en: 'See how much you need for the first 30, 60, and 90 days.',
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showPreparationSheet(
                        context,
                        title: _localizedText(
                          context,
                          pt: 'Quanto voce vai gastar nos primeiros meses',
                          es: 'Cuanto vas a gastar en los primeros meses',
                          en: 'How much you will spend in the first months',
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ToolIntroCard(
                              icon: Icons.account_balance_wallet_outlined,
                              tint: AppColors.success,
                              title: _localizedText(
                                context,
                                pt: 'Quanto voce vai gastar nos primeiros meses',
                                es: 'Cuanto vas a gastar en los primeros meses',
                                en: 'How much you will spend in the first months',
                              ),
                              body: _localizedText(
                                context,
                                pt: 'Veja quanto voce precisa para os primeiros 30, 60 e 90 dias.',
                                es: 'Mira cuanto necesitas para los primeros 30, 60 y 90 dias.',
                                en: 'See how much you need for the first 30, 60, and 90 days.',
                              ),
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
                    title: _localizedText(
                      context,
                      pt: 'Planejar meu voo para o Brasil',
                      es: 'Planear mi vuelo a Brasil',
                      en: 'Plan my flight to Brazil',
                    ),
                    body: _localizedText(
                      context,
                      pt: 'Escolha a data e veja opcoes de voo para ${city?.name ?? "sua cidade"}.',
                      es: 'Elegi la fecha y mira opciones de vuelo para ${city?.name ?? "tu ciudad"}.',
                      en: 'Choose a date and see flight options to ${city?.name ?? "your city"}.',
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showPreparationSheet(
                        context,
                        title: _localizedText(
                          context,
                          pt: 'Planejar meu voo para o Brasil',
                          es: 'Planear mi vuelo a Brasil',
                          en: 'Plan my flight to Brazil',
                        ),
                        child: _FlightSearchPlannerCard(
                          destinationCityName: city?.name,
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
    required this.plan,
  });

  final String? cityName;
  final String? stateCode;
  final bool isOverview;
  final _PreparationSection section;
  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
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
              _HeroPill(
                label: _localizedText(
                  context,
                  pt: 'Guia de mudanca',
                  es: 'Guia de mudanza',
                  en: 'Moving guide',
                ),
              ),
              if (cityName != null && stateCode != null)
                _HeroPill(label: '$cityName ($stateCode)'),
              _HeroPill(label: sectionLabel),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _localizedText(
              context,
              pt: 'Etapa ${section.index + 1} de 5 — $sectionLabel',
              es: 'Etapa ${section.index + 1} de 5 — $sectionLabel',
              en: 'Step ${section.index + 1} of 5 — $sectionLabel',
            ),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            _localizedText(
              context,
              pt: 'Voce esta em ${cityName ?? "sua cidade"} · ${_goalLabel(context, plan.goal)}',
              es: 'Estas en ${cityName ?? "tu ciudad"} · ${_goalLabel(context, plan.goal)}',
              en: 'You are in ${cityName ?? "your city"} · ${_goalLabel(context, plan.goal)}',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(BuildContext context, _PreparationSection section) {
    return _prepSectionLabel(context, section);
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
    return _prepSectionLabel(context, section);
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
                    context.l10n.copilotStageStateLabel(selected),
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
  final adaptedDocumentItems = DocumentChecklistAdapter.getItems(
    l10n: l10n,
    originCountry: plan.originCountry,
    destinationCountry: plan.destinationCountry,
    goal: plan.goal,
    travelGroup: plan.travelGroup,
    fallbackChecklist: documentChecklist,
  );
  final documentVisibleIds = adaptedDocumentItems
      .map((item) => item.id)
      .toSet();
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
      totalItems: adaptedDocumentItems.length,
      completedItems: documentCompletedIds
          .where(documentVisibleIds.contains)
          .length,
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
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'Etapa $currentStep de 5 — ${_prepSectionLabel(context, _sectionForStep(currentStep))}',
              es: 'Etapa $currentStep de 5 — ${_prepSectionLabel(context, _sectionForStep(currentStep))}',
              en: 'Step $currentStep of 5 — ${_prepSectionLabel(context, _sectionForStep(currentStep))}',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.completedItems == 0
                ? _localizedText(
                    context,
                    pt: 'Voce ainda nao marcou nenhuma etapa — comece pela mais importante',
                    es: 'Todavia no marcaste ninguna etapa — empeza por la mas importante',
                    en: 'You have not completed any step yet — start with the most important one',
                  )
                : _localizedText(
                    context,
                    pt: '${snapshot.completedItems} de ${snapshot.totalItems} etapas concluidas · ${snapshot.percent}% do plano',
                    es: '${snapshot.completedItems} de ${snapshot.totalItems} etapas completadas · ${snapshot.percent}% del plan',
                    en: '${snapshot.completedItems} of ${snapshot.totalItems} steps completed · ${snapshot.percent}% of the plan',
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

// ignore: unused_element
class _PreparationOverview extends StatelessWidget {
  const _PreparationOverview({
    required this.snapshot,
    required this.onOpenSection,
  });

  final _PlanProgressSnapshot snapshot;
  final ValueChanged<_PreparationSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanNextActionCard(
          eyebrow: _localizedText(
            context,
            pt: 'Proximo passo',
            es: 'Proximo paso',
            en: 'Next step',
          ),
          title: _localizedText(
            context,
            pt: 'Faca isso agora',
            es: 'Hace esto ahora',
            en: 'Do this now',
          ),
          body: _localizedText(
            context,
            pt: '${_prepSectionLabel(context, snapshot.nextStage.section)} · Passo ${snapshot.nextStage.completedItems + 1} de ${snapshot.nextStage.totalItems}',
            es: '${_prepSectionLabel(context, snapshot.nextStage.section)} · Paso ${snapshot.nextStage.completedItems + 1} de ${snapshot.nextStage.totalItems}',
            en: '${_prepSectionLabel(context, snapshot.nextStage.section)} · Step ${snapshot.nextStage.completedItems + 1} of ${snapshot.nextStage.totalItems}',
          ),
          actionLabel: _openSectionCta(context, snapshot.nextStage.section),
          onTap: () => onOpenSection(snapshot.nextStage.section),
          progressLabel: snapshot.nextStage.title,
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
          label: _localizedText(
            context,
            pt: '${stage.completedItems} de ${stage.totalItems} etapas',
            es: '${stage.completedItems} de ${stage.totalItems} etapas',
            en: '${stage.completedItems} of ${stage.totalItems} steps',
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
      actionLabel: _openSectionCta(context, stage.section),
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
            title: _localizedText(
              context,
              pt: 'Escolha sua cidade para continuar',
              es: 'Elegi tu ciudad para continuar',
              en: 'Choose your city to continue',
            ),
            body: _localizedText(
              context,
              pt: 'Voce precisa escolher a cidade do seu plano antes de acessar o guia completo. Volte ao resultado e confirme a cidade recomendada.',
              es: 'Necesitas elegir la ciudad de tu plan antes de entrar a la guia completa. Volve al resultado y confirma la ciudad recomendada.',
              en: 'You need to choose your plan city before accessing the full guide. Go back to the result and confirm the recommended city.',
            ),
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenPlanResult,
            icon: const Icon(Icons.location_city_outlined),
            label: Text(
              _localizedText(
                context,
                pt: 'Ver cidades recomendadas ->',
                es: 'Ver ciudades recomendadas ->',
                en: 'See recommended cities ->',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideGpsHeader extends StatelessWidget {
  const _GuideGpsHeader({
    required this.cityLabel,
    required this.onBack,
    required this.onMore,
  });

  final String? cityLabel;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    _localizedText(
                      context,
                      pt: 'Guia de mudanca',
                      es: 'Guia de mudanza',
                      en: 'Moving guide',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cityLabel ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuideContextBand extends StatelessWidget {
  const _GuideContextBand({required this.controller});

  final GuideGpsController controller;

  @override
  Widget build(BuildContext context) {
    final phase = controller.currentPhase;
    final phaseIndex = GuidePhase.values.indexOf(phase) + 1;
    return FrostedPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedText(context, pt: 'Fase', es: 'Fase', en: 'Phase'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_guidePhaseName(context, phase)} · ${_localizedText(context, pt: 'etapa', es: 'etapa', en: 'step')} $phaseIndex ${_localizedText(context, pt: 'de', es: 'de', en: 'of')} ${GuidePhase.values.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              '${controller.completedCount} ${_localizedText(context, pt: 'de', es: 'de', en: 'of')} ${controller.totalItems} ${_localizedText(context, pt: 'feitas', es: 'hechas', en: 'done')}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideUnifiedProgressBar extends StatelessWidget {
  const _GuideUnifiedProgressBar({required this.controller});

  final GuideGpsController controller;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: controller.progress),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceMutedFor(context),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${controller.progressPercent}% ${_localizedText(context, pt: 'concluido', es: 'completado', en: 'completed')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
              const Spacer(),
              Text(
                '${controller.remainingCount} ${_localizedText(context, pt: 'restantes', es: 'restantes', en: 'remaining')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideDominantActionCard extends StatelessWidget {
  const _GuideDominantActionCard({
    required this.item,
    required this.showCelebration,
    required this.showExpandedContent,
    required this.onPrimaryTap,
    required this.onChecklistToggle,
  });

  final GuideActionItem? item;
  final bool showCelebration;
  final bool showExpandedContent;
  final Future<void> Function(GuideActionItem item) onPrimaryTap;
  final Future<void> Function(String itemId, String subItemId)
  onChecklistToggle;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return FrostedPanel(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizedText(
                context,
                pt: 'Plano concluído!',
                es: '¡Plan completado!',
                en: 'Plan completed!',
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _localizedText(
                context,
                pt: 'Você completou todas as etapas do seu guia.',
                es: 'Completaste todos los pasos de tu guía.',
                en: 'You completed every step in your guide.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: FrostedPanel(
        key: ValueKey<String>('guide-item-${item!.id}-$showCelebration'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GuideActionTag(item: item!),
            const SizedBox(height: 12),
            Text(
              item!.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              item!.shortDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
            if (item!.badgeLabel != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  item!.badgeLabel!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (showExpandedContent &&
                item!.type == GuideActionType.informative &&
                item!.fullContent != null) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderFor(context)),
                ),
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  height: 112,
                  child: SingleChildScrollView(
                    child: Text(
                      item!.fullContent!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ),
              ),
            ],
            if (item!.hasChecklist) ...[
              const SizedBox(height: 14),
              for (final subItem in item!.checklistItems!) ...[
                CheckboxListTile(
                  value: subItem.isCompleted,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(subItem.title),
                  onChanged: (_) => onChecklistToggle(item!.id, subItem.id),
                ),
              ],
            ],
            if (showCelebration) ...[
              const SizedBox(height: 14),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 8),
                    child: child,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    _localizedText(
                      context,
                      pt: 'Otimo! Proxima acao desbloqueada.',
                      es: 'Genial. Se desbloqueo la siguiente accion.',
                      en: 'Great. The next action is unlocked.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            if (!item!.hasChecklist) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => onPrimaryTap(item!),
                  child: Text(
                    _guideButtonLabel(context, item!, showExpandedContent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuideActionTag extends StatelessWidget {
  const _GuideActionTag({required this.item});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (item.type) {
      GuideActionType.external => AppColors.primary,
      GuideActionType.tool => AppColors.warning,
      GuideActionType.checklist => AppColors.success,
      GuideActionType.informative => AppColors.primary,
    };

    final label = switch (item.type) {
      GuideActionType.informative => _localizedText(
        context,
        pt: 'PROXIMA ACAO',
        es: 'PROXIMA ACCION',
        en: 'NEXT ACTION',
      ),
      GuideActionType.external => _localizedText(
        context,
        pt: 'ACAO EXTERNA',
        es: 'ACCION EXTERNA',
        en: 'EXTERNAL ACTION',
      ),
      GuideActionType.tool => _localizedText(
        context,
        pt: 'USE UMA FERRAMENTA',
        es: 'USA UNA HERRAMIENTA',
        en: 'USE A TOOL',
      ),
      GuideActionType.checklist => _localizedText(
        context,
        pt: 'PARA CONCLUIR',
        es: 'PARA COMPLETAR',
        en: 'TO COMPLETE',
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _GuideUpcomingSection extends StatelessWidget {
  const _GuideUpcomingSection({
    required this.controller,
    required this.onSelectItem,
  });

  final GuideGpsController controller;
  final Future<void> Function(String itemId) onSelectItem;

  @override
  Widget build(BuildContext context) {
    final items = controller.upcomingItems;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(
            context,
            pt: 'A SEGUIR',
            es: 'A CONTINUACION',
            en: 'UP NEXT',
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSoftFor(context),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < items.length; index++) ...[
          _UpcomingGuideItemTile(
            indexLabel: '${index + 2}',
            item: items[index],
            unlocked: controller.isItemUnlocked(items[index]),
            onTap: controller.isItemUnlocked(items[index])
                ? () => onSelectItem(items[index].id)
                : null,
          ),
          if (index != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _UpcomingGuideItemTile extends StatelessWidget {
  const _UpcomingGuideItemTile({
    required this.indexLabel,
    required this.item,
    required this.unlocked,
    required this.onTap,
  });

  final String indexLabel;
  final GuideActionItem item;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.58,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unlocked
                    ? AppColors.primary.withValues(alpha: 0.28)
                    : AppColors.borderFor(context),
              ),
            ),
            child: Row(
              children: [
                Text(
                  indexLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  unlocked
                      ? Icons.arrow_forward_rounded
                      : Icons.lock_outline_rounded,
                  size: 18,
                  color: unlocked
                      ? AppColors.primary
                      : AppColors.textSoftFor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidePlanCompleteBar extends StatelessWidget {
  const _GuidePlanCompleteBar({required this.totalItems, required this.onTap});

  final int totalItems;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _localizedText(
                    context,
                    pt: 'Ver plano completo',
                    es: 'Ver plan completo',
                    en: 'View full plan',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$totalItems ${_localizedText(context, pt: 'etapas', es: 'etapas', en: 'steps')}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideMenuAction extends StatelessWidget {
  const _GuideMenuAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _GuidePlanGroup extends StatelessWidget {
  const _GuidePlanGroup({
    required this.phaseLabel,
    required this.items,
    required this.completedIds,
    required this.currentItemId,
    required this.isUnlocked,
    required this.onTapItem,
  });

  final String phaseLabel;
  final List<GuideActionItem> items;
  final Set<String> completedIds;
  final String? currentItemId;
  final bool Function(GuideActionItem item) isUnlocked;
  final ValueChanged<GuideActionItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final completedCount = items
        .where((item) => completedIds.contains(item.id))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$phaseLabel · $completedCount ${_localizedText(context, pt: 'de', es: 'de', en: 'of')} ${items.length}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final item in items) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              completedIds.contains(item.id)
                  ? Icons.check_circle_rounded
                  : currentItemId == item.id
                  ? Icons.arrow_forward_rounded
                  : isUnlocked(item)
                  ? Icons.arrow_forward_rounded
                  : Icons.lock_outline_rounded,
              color: completedIds.contains(item.id)
                  ? AppColors.success
                  : currentItemId == item.id
                  ? AppColors.primary
                  : isUnlocked(item)
                  ? AppColors.primary
                  : AppColors.textSoftFor(context),
            ),
            title: Text(
              item.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: completedIds.contains(item.id)
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              item.badgeLabel ?? item.type.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: completedIds.contains(item.id)
                ? null
                : !isUnlocked(item)
                ? null
                : () => onTapItem(item),
          ),
        ],
      ],
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
          city: city,
          onOpenRentalSearch: onOpenRentalSearch,
          onHelp: () => showContextualHelpGuide(
            context,
            preferenceKey: _MigrationPlanCopilotPageState._helpPreferenceKey,
            content: _buildCopilotHelpContent(context),
          ),
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
                _localizedText(
                  context,
                  pt: 'Seus documentos para o Brasil',
                  es: 'Tus documentos para Brasil',
                  en: 'Your documents for Brazil',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                _localizedText(
                  context,
                  pt: 'Argentinos nao precisam de passaporte nem visto para entrar no Brasil. Veja o que voce realmente precisa.',
                  es: 'Los argentinos no necesitan pasaporte ni visa para entrar a Brasil. Mira lo que realmente hace falta.',
                  en: 'Argentine citizens do not need a passport or visa to enter Brazil. See what you actually need.',
                ),
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
          title: _localizedText(
            context,
            pt: 'CPF — seu numero no Brasil',
            es: 'CPF — tu numero en Brasil',
            en: 'CPF — your number in Brazil',
          ),
          body: _localizedText(
            context,
            pt: 'O CPF e como o CUIL argentino — voce vai precisar dele para abrir conta, alugar e trabalhar. Gratuito. Pode fazer antes de viajar no consulado.',
            es: 'El CPF es como el CUIL argentino: lo vas a necesitar para abrir cuenta, alquilar y trabajar. Es gratis y podes hacerlo antes de viajar en el consulado.',
            en: 'The CPF is like the Argentine CUIL. You will need it to open a bank account, rent, and work. It is free and can be done before travel at the consulate.',
          ),
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.perm_identity_rounded,
          tint: AppColors.secondary,
          title: _localizedText(
            context,
            pt: 'Residencia pelo Mercosul — mais simples do que parece',
            es: 'Residencia Mercosur — mas simple de lo que parece',
            en: 'Mercosur residence — simpler than it looks',
          ),
          body: _localizedText(
            context,
            pt: 'Argentinos tem direito a residencia permanente no Brasil pelo Mercosul — sem apostila, sem traducao, sem provar renda. Feito na Policia Federal depois de chegar.',
            es: 'Los argentinos tienen derecho a residencia permanente en Brasil por Mercosur, sin apostilla, sin traduccion ni prueba de ingresos. Se hace en la Policia Federal despues de llegar.',
            en: 'Argentine citizens can get permanent residence in Brazil through Mercosur without apostilles, translations, or proof of income. It is done after arrival at the Federal Police.',
          ),
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
    required this.city,
    required this.onOpenRentalSearch,
    required this.onHelp,
    required this.onOpenExternalPreparationLink,
  });

  final MigrationPlan plan;
  final City? city;
  final Future<void> Function(City city, RentalProvider provider)
  onOpenRentalSearch;
  final Future<void> Function() onHelp;
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
                _localizedText(
                  context,
                  pt: 'Como encontrar onde morar em ${city?.name ?? "sua cidade"}',
                  es: 'Como encontrar donde vivir en ${city?.name ?? "tu ciudad"}',
                  en: 'How to find a place to live in ${city?.name ?? "your city"}',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                _localizedText(
                  context,
                  pt: 'Para comecar com seguranca, escolha primeiro entre moradia temporaria e aluguel fixo.',
                  es: 'Para empezar con seguridad, elegi primero entre vivienda temporal y alquiler fijo.',
                  en: 'To start safely, first choose between temporary housing and a long-term rental.',
                ),
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
        ] else ...[
          const SizedBox(height: 14),
          _HousingFlowEntryCard(
            city: city!,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HousingSelectionScreen(
                    city: city!,
                    onOpenRentalSearch: onOpenRentalSearch,
                    onHelp: onHelp,
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 14),
        _ExternalToolCard(
          icon: Icons.warning_amber_rounded,
          tint: AppColors.caution,
          title: _localizedText(
            context,
            pt: '⚠️ Cuidado com golpes de aluguel — como se proteger',
            es: '⚠️ Cuidado con estafas de alquiler — como protegerte',
            en: '⚠️ Rental scams — how to protect yourself',
          ),
          body: _localizedText(
            context,
            pt: 'Sempre visite o imovel pessoalmente antes de pagar qualquer valor. Nunca transfira dinheiro por Pix antes de assinar contrato e receber as chaves.',
            es: 'Visita siempre la propiedad en persona antes de pagar cualquier monto. Nunca transfieras dinero antes de firmar el contrato y recibir las llaves.',
            en: 'Always visit the property in person before paying anything. Never transfer money before signing the contract and receiving the keys.',
          ),
          uri: PreparationResourceLinks.rentalScamAlert,
          onOpenExternalPreparationLink: onOpenExternalPreparationLink,
        ),
      ],
    );
  }
}

class _HousingFlowEntryCard extends StatelessWidget {
  const _HousingFlowEntryCard({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.heroStart,
              AppColors.heroMiddle,
              AppColors.heroEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.home_work_outlined, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedText(
                      context,
                      pt: 'Como funciona alugar em ${city.name} sendo estrangeiro',
                      es: 'Como funciona alquilar en ${city.name} siendo extranjero',
                      en: 'How renting works in ${city.name} as a foreigner',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _localizedText(
                      context,
                      pt: 'Para chegar com mais seguranca, escolha entre uma base temporaria e um aluguel definitivo depois de conhecer melhor a cidade.',
                      es: 'Para llegar con mas seguridad, elegi entre una base temporal y un alquiler definitivo despues de conocer mejor la ciudad.',
                      en: 'To arrive more safely, choose between a temporary base and a long-term rental after getting to know the city.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _localizedText(
                        context,
                        pt: 'Ver opcoes de moradia',
                        es: 'Ver opciones de vivienda',
                        en: 'See housing options',
                      ),
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
                _localizedText(
                  context,
                  pt: 'Trabalho e vida pratica em ${cityData?.name ?? "sua cidade"}',
                  es: 'Trabajo y vida practica en ${cityData?.name ?? "tu ciudad"}',
                  en: 'Work and daily life in ${cityData?.name ?? "your city"}',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                _localizedText(
                  context,
                  pt: 'Para construir renda e rotina no Brasil, veja onde buscar vagas, saude, dinheiro e os primeiros ajustes da vida pratica.',
                  es: 'Para construir ingresos y rutina en Brasil, mira donde buscar trabajo, salud, dinero y los primeros ajustes de la vida diaria.',
                  en: 'To build income and daily structure in Brazil, see where to search for jobs, health, money, and early practical steps.',
                ),
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
            title: _localizedText(
              context,
              pt: 'Buscar vagas em ${cityData?.name ?? "sua cidade"}',
              es: 'Buscar vagas en ${cityData?.name ?? "tu ciudad"}',
              en: 'Search jobs in ${cityData?.name ?? "your city"}',
            ),
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
                  _localizedText(
                    context,
                    pt: 'Mercado de trabalho em ${cityData.name}: ${_jobMarketLabel(context, cityData.jobMarketScore / 100)}',
                    es: 'Mercado laboral en ${cityData.name}: ${_jobMarketLabel(context, cityData.jobMarketScore / 100)}',
                    en: 'Job market in ${cityData.name}: ${_jobMarketLabel(context, cityData.jobMarketScore / 100)}',
                  ),
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
          title: _localizedText(
            context,
            pt: 'Saude no Brasil: SUS, plano e o que voce precisa saber',
            es: 'Salud en Brasil: SUS, prepaga y lo que necesitas saber',
            en: 'Healthcare in Brazil: SUS, insurance, and what you need to know',
          ),
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
          title: _localizedText(
            context,
            pt: 'Revalidar seu diploma no Brasil — quando e como',
            es: 'Revalidar tu titulo en Brasil — cuando y como',
            en: 'Validate your degree in Brazil — when and how',
          ),
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
                _localizedText(
                  context,
                  pt: 'Sua primeira semana em ${destinationCityName ?? "sua cidade"}',
                  es: 'Tu primera semana en ${destinationCityName ?? "tu ciudad"}',
                  en: 'Your first week in ${destinationCityName ?? "your city"}',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                _localizedText(
                  context,
                  pt: 'Para se instalar com menos estresse, foque primeiro no que resolve sua base nos primeiros dias.',
                  es: 'Para instalarte con menos estres, enfocate primero en lo que te da base en los primeros dias.',
                  en: 'To settle with less stress, focus first on what gives you a stable base in the first days.',
                ),
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
          title: _localizedText(
            context,
            pt: 'PRIMEIRA SEMANA — prioridade maxima',
            es: 'PRIMERA SEMANA — prioridad maxima',
            en: 'FIRST WEEK — top priority',
          ),
          body: l10n.migrationPlanPrepArrivalWeekBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.housing),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.calendar_month_outlined,
          tint: AppColors.secondary,
          title: _localizedText(
            context,
            pt: 'PRIMEIRO MES — consolidar a base',
            es: 'PRIMER MES — consolidar la base',
            en: 'FIRST MONTH — build your base',
          ),
          body: l10n.migrationPlanPrepArrivalMonthBody,
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.timeline_rounded,
          tint: AppColors.success,
          title: _localizedText(
            context,
            pt: 'PRIMEIROS 3 MESES — estabilizar a vida',
            es: 'PRIMEROS 3 MESES — estabilizar la vida',
            en: 'FIRST 3 MONTHS — stabilize life',
          ),
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
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
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
          Icon(Icons.arrow_forward_rounded, color: tint),
        ],
      ),
    );

    if (onTap == null) {
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

void _showCompletionFeedback(BuildContext context, int completedCount) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Text('✓', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _completionMessage(context, completedCount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0D2818),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

String _completionMessage(BuildContext context, int count) {
  if (count == 1) {
    return _localizedText(
      context,
      pt: 'Primeiro passo dado. Continue assim!',
      es: 'Primer paso hecho. Segui asi.',
      en: 'First step done. Keep going.',
    );
  }
  if (count <= 3) {
    return _localizedText(
      context,
      pt: 'Otimo ritmo! $count etapas feitas.',
      es: 'Buen ritmo. $count etapas hechas.',
      en: 'Great pace. $count steps done.',
    );
  }
  if (count <= 7) {
    return _localizedText(
      context,
      pt: '$count etapas concluidas. Voce esta avancando.',
      es: '$count etapas completadas. Estas avanzando.',
      en: '$count steps completed. You are moving forward.',
    );
  }
  return _localizedText(
    context,
    pt: 'Incrivel — $count etapas prontas!',
    es: 'Increible: $count etapas listas.',
    en: 'Amazing — $count steps ready.',
  );
}

String _prepSectionLabel(BuildContext context, _PreparationSection section) {
  return _localizedText(
    context,
    pt: switch (section) {
      _PreparationSection.overview => 'Visao geral',
      _PreparationSection.documents => 'Ver meus documentos',
      _PreparationSection.housing => 'Ver moradia',
      _PreparationSection.work => 'Ver trabalho e preparo',
      _PreparationSection.arrival => 'Ver chegada',
    },
    es: switch (section) {
      _PreparationSection.overview => 'Vista general',
      _PreparationSection.documents => 'Ver mis documentos',
      _PreparationSection.housing => 'Ver vivienda',
      _PreparationSection.work => 'Ver trabajo y preparacion',
      _PreparationSection.arrival => 'Ver llegada',
    },
    en: switch (section) {
      _PreparationSection.overview => 'Plan overview',
      _PreparationSection.documents => 'View my documents',
      _PreparationSection.housing => 'View housing',
      _PreparationSection.work => 'View work and prep',
      _PreparationSection.arrival => 'View arrival',
    },
  );
}

_PreparationSection _sectionForStep(int step) {
  return switch (step) {
    1 => _PreparationSection.overview,
    2 => _PreparationSection.documents,
    3 => _PreparationSection.housing,
    4 => _PreparationSection.work,
    _ => _PreparationSection.arrival,
  };
}

String _goalLabel(BuildContext context, String goal) {
  return switch (goal) {
    'find_job_br' => _localizedText(
      context,
      pt: 'buscando emprego no Brasil',
      es: 'buscando trabajo en Brasil',
      en: 'looking for work in Brazil',
    ),
    'remote_income' => _localizedText(
      context,
      pt: 'trabalhando remotamente',
      es: 'trabajando de forma remota',
      en: 'working remotely',
    ),
    'study' => _localizedText(
      context,
      pt: 'indo estudar',
      es: 'yendo a estudiar',
      en: 'moving to study',
    ),
    'family_partner' => _localizedText(
      context,
      pt: 'reunindo a familia',
      es: 'reuniendo a la familia',
      en: 'bringing family together',
    ),
    'fresh_start' => _localizedText(
      context,
      pt: 'recomecando do zero',
      es: 'empezando de cero',
      en: 'starting over',
    ),
    _ => _localizedText(
      context,
      pt: 'planejando a mudanca',
      es: 'planeando la mudanza',
      en: 'planning the move',
    ),
  };
}

String _openSectionCta(BuildContext context, _PreparationSection section) {
  return _localizedText(
    context,
    pt: 'Abrir: ${_prepSectionLabel(context, section)}',
    es: 'Abrir: ${_prepSectionLabel(context, section)}',
    en: 'Open: ${_prepSectionLabel(context, section)}',
  );
}

String _jobMarketLabel(BuildContext context, double score) {
  if (score >= 0.7) {
    return _localizedText(
      context,
      pt: 'aquecido — boa demanda por profissionais',
      es: 'activo — buena demanda de profesionales',
      en: 'active — good demand for professionals',
    );
  }
  if (score >= 0.4) {
    return _localizedText(
      context,
      pt: 'moderado — oportunidades em areas especificas',
      es: 'moderado — oportunidades en areas especificas',
      en: 'moderate — opportunities in specific areas',
    );
  }
  return _localizedText(
    context,
    pt: 'em desenvolvimento — vale pesquisar antes de chegar',
    es: 'en desarrollo — conviene investigar antes de llegar',
    en: 'developing — research before you arrive',
  );
}

String _guidePhaseName(BuildContext context, GuidePhase phase) {
  return switch (phase) {
    GuidePhase.preparation => _localizedText(
      context,
      pt: 'Antes de viajar',
      es: 'Antes de viajar',
      en: 'Before travel',
    ),
    GuidePhase.housing => _localizedText(
      context,
      pt: 'Primeiros dias',
      es: 'Primeros días',
      en: 'First days',
    ),
    GuidePhase.documents => _localizedText(
      context,
      pt: 'Documentação',
      es: 'Documentación',
      en: 'Documentation',
    ),
    GuidePhase.work => _localizedText(
      context,
      pt: 'Vida funcionando',
      es: 'Vida funcionando',
      en: 'Life working',
    ),
    GuidePhase.arrival => _localizedText(
      context,
      pt: 'Integração',
      es: 'Integración',
      en: 'Integration',
    ),
  };
}

String _guideButtonLabel(
  BuildContext context,
  GuideActionItem item,
  bool showExpandedContent,
) {
  if (item.type == GuideActionType.informative) {
    if (showExpandedContent) {
      return _localizedText(
        context,
        pt: 'Marcar como concluido',
        es: 'Marcar como completado',
        en: 'Mark as completed',
      );
    }
    return _localizedText(context, pt: 'Comecar', es: 'Empezar', en: 'Start');
  }
  if (item.type == GuideActionType.external) {
    return _localizedText(
      context,
      pt: 'Abrir ${item.externalLabel ?? 'link'}',
      es: 'Abrir ${item.externalLabel ?? 'link'}',
      en: 'Open ${item.externalLabel ?? 'link'}',
    );
  }
  if (item.type == GuideActionType.tool) {
    return _localizedText(
      context,
      pt: 'Abrir ferramenta',
      es: 'Abrir herramienta',
      en: 'Open tool',
    );
  }
  return _localizedText(
    context,
    pt: 'Concluir',
    es: 'Completar',
    en: 'Complete',
  );
}

String _localizedText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
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
