import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/trust/source_freshness_policy.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/practical_info_disclaimer.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/journey_stage_banner.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/presentation/widgets/flight_search_tool.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/guide_gps_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/criminal_record_decision_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/arrival_execution_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/calendar_event_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/document_checklist_adapter.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_event_suggestion_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_event_suggestion_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_personalization_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_identity.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_folder_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_event_suggestion.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/housing_selection_screen.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/arrival_execution_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/guide_event_suggestion_sheet.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/landing_budget_estimator_section.dart';
import 'package:movaro_app/features/language/presentation/widgets/contextual_phrase_support_card.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/migration_document_readiness_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/migration_readiness_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_structure_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum _PreparationSection { overview, documents, housing, work, arrival }

class MigrationPlanCopilotPage extends StatefulWidget {
  const MigrationPlanCopilotPage({
    required this.controller,
    required this.exchangeRatesService,
    required this.citiesController,
    required this.journeyContextController,
    required this.locationController,
    this.initialGuideItemId,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CopilotExchangeRatesService exchangeRatesService;
  final CitiesController citiesController;
  final JourneyContextController journeyContextController;
  final LocationController locationController;
  final String? initialGuideItemId;

  @override
  State<MigrationPlanCopilotPage> createState() =>
      _MigrationPlanCopilotPageState();
}

class _MigrationPlanCopilotPageState extends State<MigrationPlanCopilotPage> {
  static const _helpPreferenceKey = 'migration_plan_copilot';
  late final Future<CopilotExchangeRates?> _exchangeRatesFuture;
  CopilotExchangeRates? _exchangeRates;
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();
  final GuideEventSuggestionStore _eventSuggestionStore =
      GuideEventSuggestionStore();
  final GuideEventSuggestionEngine _eventSuggestionEngine =
      GuideEventSuggestionEngine();
  final CalendarEventService _calendarEventService = CalendarEventService();
  Set<String> _readinessCompletedIds = <String>{};
  Set<String> _documentCompletedIds = <String>{};
  Set<String> _arrivalCompletedIds = <String>{};
  Map<String, String> _completedAtById = <String, String>{};
  Set<String> _prioritizedItemIds = <String>{};
  Map<String, GuideDismissReason> _dismissedReasonsById =
      <String, GuideDismissReason>{};
  Map<String, GuideTaskState> _taskStatesById = <String, GuideTaskState>{};
  Map<String, Map<String, dynamic>> _taskDecisionDataById =
      <String, Map<String, dynamic>>{};
  String? _loadedProgressKey;
  String? _loadedActiveItemId;
  GuideGpsController? _gpsController;
  String? _gpsControllerKey;
  bool _didTryAutoHelp = false;
  bool _showCelebration = false;
  bool _showExpandedContent = false;
  bool _isPresentingCalendarAssistant = false;
  String? _pendingPreviewGuideItemId;
  bool _didAutoOpenPreview = false;
  final Set<GuidePhase> _celebratedPhases = <GuidePhase>{};

  @override
  void initState() {
    super.initState();
    _pendingPreviewGuideItemId = widget.initialGuideItemId;
    _exchangeRatesFuture = widget.exchangeRatesService.fetchLatest();
    unawaited(_loadExchangeRates());
    unawaited(PlanNotificationService.instance.cancelPlanReminders());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowHelp();
    });
  }

  Future<void> _loadExchangeRates() async {
    final exchangeRates = await _exchangeRatesFuture;
    if (!mounted) {
      return;
    }
    setState(() {
      _exchangeRates = exchangeRates;
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
          locationController: widget.locationController,
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
      _prioritizedItemIds = Set<String>.from(snapshot.prioritizedItemIds);
      _dismissedReasonsById = Map<String, GuideDismissReason>.from(
        snapshot.dismissedReasonsById,
      );
      _taskStatesById = Map<String, GuideTaskState>.from(
        snapshot.taskStatesById,
      );
      _taskDecisionDataById = {
        for (final entry in snapshot.taskDecisionDataById.entries)
          entry.key: Map<String, dynamic>.from(entry.value),
      };
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
      (_readinessCompletedIds.toList()..sort()).join(','),
      (_documentCompletedIds.toList()..sort()).join(','),
      (_arrivalCompletedIds.toList()..sort()).join(','),
      _loadedActiveItemId ?? 'none',
      items
          .map(
            (item) =>
                '${item.id}:${item.orderIndex}:${item.isCompleted}:${item.dismissReason?.name ?? 'active'}',
          )
          .join('|'),
      _completedAtById.length,
      (_prioritizedItemIds.toList()..sort()).join(','),
      (_dismissedReasonsById.entries
              .map((entry) => '${entry.key}:${entry.value.name}')
              .toList()
            ..sort())
          .join(','),
      (_taskStatesById.entries
              .map((entry) => '${entry.key}:${entry.value.name}')
              .toList()
            ..sort())
          .join(','),
      (_taskDecisionDataById.keys.toList()..sort()).join(','),
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
      prioritizedItemIds: _prioritizedItemIds,
      dismissedReasonsById: _dismissedReasonsById,
      taskStatesById: _taskStatesById,
      taskDecisionDataById: _taskDecisionDataById,
      activeItemId: _loadedActiveItemId,
    );
    _gpsControllerKey = signature;
    _maybeOpenPreviewItem(plan);
  }

  void _maybeOpenPreviewItem(MigrationPlan plan) {
    if (_didAutoOpenPreview) {
      return;
    }
    final previewItemId = _pendingPreviewGuideItemId;
    final controller = _gpsController;
    if (previewItemId == null || controller == null) {
      return;
    }
    final previewItem = controller.items.cast<GuideActionItem?>().firstWhere(
      (item) => item?.id == previewItemId,
      orElse: () => null,
    );
    if (previewItem == null) {
      _pendingPreviewGuideItemId = null;
      _didAutoOpenPreview = true;
      return;
    }
    _pendingPreviewGuideItemId = null;
    _didAutoOpenPreview = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final city = plan.confirmedCity;
      unawaited(
        _showExecutionPage(
          controller,
          previewItem,
          plan,
          city,
          isPreview: true,
          currentPriorityItem: controller.currentItem,
        ),
      );
    });
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

  void _syncFromGpsController(GuideGpsController controller) {
    _readinessCompletedIds = Set<String>.from(controller.readinessCompletedIds);
    _documentCompletedIds = Set<String>.from(controller.documentCompletedIds);
    _arrivalCompletedIds = Set<String>.from(controller.arrivalCompletedIds);
    _loadedActiveItemId = controller.activeItemId;
    _completedAtById = Map<String, String>.from(controller.completedAtById);
    _prioritizedItemIds = Set<String>.from(controller.prioritizedItemIds);
    _dismissedReasonsById = Map<String, GuideDismissReason>.from(
      controller.dismissedReasonsById,
    );
    _taskStatesById = Map<String, GuideTaskState>.from(
      controller.taskStatesById,
    );
    _taskDecisionDataById = {
      for (final entry in controller.taskDecisionDataById.entries)
        entry.key: Map<String, dynamic>.from(entry.value),
    };
  }

  String _planKey(MigrationPlan plan) {
    return MigrationPlanIdentity.storageKeyFor(plan);
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
      locationController: widget.locationController,
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
    var failureRecorded = false;
    void recordFailure() {
      if (failureRecorded) {
        return;
      }
      failureRecorded = true;
      unawaited(
        GuideFlowMetricsStore.instance.record(
          GuideFlowMetric.officialLinkFailed,
          referenceId: uri.host,
        ),
      );
    }

    unawaited(
      GuideFlowMetricsStore.instance.record(
        GuideFlowMetric.officialLinkOpened,
        referenceId: uri.host,
      ),
    );
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PreparationWebViewPage(
            title: title,
            uri: uri,
            onMainFrameError: recordFailure,
          ),
        ),
      );
      unawaited(
        GuideFlowMetricsStore.instance.record(
          GuideFlowMetric.officialLinkReturned,
          referenceId: uri.host,
        ),
      );
    } on Object {
      recordFailure();
      rethrow;
    }
  }

  String _externalLinksChooserTitle(
    BuildContext context,
    GuideActionItem item,
  ) {
    switch (item.id) {
      case 'item_1_3_money':
        return _localizedText(
          context,
          pt: 'Escolha como quer organizar o dinheiro',
          es: 'Elige como quieres organizar el dinero',
          en: 'Choose how you want to set up money',
        );
      case 'item_3_1_conta_bancaria':
        return _localizedText(
          context,
          pt: 'Escolha qual banco quer abrir',
          es: 'Elige que banco quieres abrir',
          en: 'Choose which bank to open',
        );
      case 'item_0_5_mercado_trabalho':
        return _localizedText(
          context,
          pt: 'Escolha onde quer pesquisar vagas',
          es: 'Elige donde quieres buscar vacantes',
          en: 'Choose where you want to search for jobs',
        );
      case 'item_1_1_chip':
        return _localizedText(
          context,
          pt: 'Compare operadoras e escolha seu chip',
          es: 'Compara operadoras y elige tu chip',
          en: 'Compare carriers and choose your SIM',
        );
      default:
        return _localizedText(
          context,
          pt: 'Escolha uma opção',
          es: 'Elige una opcion',
          en: 'Choose an option',
        );
    }
  }

  String _externalLinksChooserBody(BuildContext context, GuideActionItem item) {
    switch (item.id) {
      case 'item_1_3_money':
        return _localizedText(
          context,
          pt: 'Abra a opção que faz mais sentido para o seu caso.',
          es: 'Abre la opcion que tenga mas sentido para tu caso.',
          en: 'Open the option that makes the most sense for your case.',
        );
      case 'item_3_1_conta_bancaria':
        return _localizedText(
          context,
          pt: 'Compare os bancos digitais e abra o que fizer mais sentido para você.',
          es: 'Compara los bancos digitales y abre el que tenga mas sentido para ti.',
          en: 'Compare the digital banks and open the one that makes the most sense for you.',
        );
      case 'item_0_5_mercado_trabalho':
        return _localizedText(
          context,
          pt: 'Abra a plataforma que faz mais sentido para o seu perfil e para o tipo de vaga que você quer buscar.',
          es: 'Abre la plataforma que tenga mas sentido para tu perfil y para el tipo de vacante que quieres buscar.',
          en: 'Open the platform that best fits your profile and the type of role you want to search for.',
        );
      case 'item_1_1_chip':
        return _localizedText(
          context,
          pt: 'Veja os planos das principais operadoras. Antes de comprar, compare a cobertura da Anatel no endereço onde você vai morar e confirme os documentos de ativação.',
          es: 'Mira los planes de las principales operadoras. Antes de comprar, compara la cobertura de Anatel en tu domicilio y confirma los documentos de activación.',
          en: 'Review plans from the main carriers. Before buying, compare Anatel coverage at your address and confirm activation documents.',
        );
      default:
        return _localizedText(
          context,
          pt: 'Abra a opção que faz mais sentido para o seu caso.',
          es: 'Abre la opcion que tenga mas sentido para tu caso.',
          en: 'Open the option that makes the most sense for your case.',
        );
    }
  }

  Future<GuideSupportLink?> _showExternalLinksChooser(
    BuildContext pageContext,
    GuideActionItem item,
  ) {
    return Navigator.of(pageContext).push<GuideSupportLink>(
      MaterialPageRoute<GuideSupportLink>(
        settings: const RouteSettings(name: '/plan/step/resources'),
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.backgroundFor(context),
            body: Stack(
              children: [
                const Positioned.fill(child: AmbientBackground()),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.isMobileLayout ? 16 : 24,
                          8,
                          context.isMobileLayout ? 16 : 24,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _GuidePageHeader(
                              title: _externalLinksChooserTitle(context, item),
                              onBack: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _externalLinksChooserBody(context, item),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSoftFor(context),
                                    height: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: ListView.separated(
                                itemCount: item.externalOfficialLinks!.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final link =
                                      item.externalOfficialLinks![index];
                                  return _GuideResourceChoiceCard(
                                    link: link,
                                    onTap: () =>
                                        Navigator.of(context).pop(link),
                                  );
                                },
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
        },
      ),
    );
  }

  Future<void> _showTaskGuidanceSheet(
    BuildContext sheetContext,
    GuideActionItem item,
    List<GuideActionItem> allItems,
  ) {
    final pendingDependencies = <String>[];
    for (final dependencyId in item.dependencies) {
      final dependency = allItems.cast<GuideActionItem?>().firstWhere(
        (candidate) => candidate?.id == dependencyId,
        orElse: () => null,
      );
      if (dependency != null && !dependency.isCompleted) {
        pendingDependencies.add(dependency.title);
      }
    }

    return showModalBottomSheet<void>(
      context: sheetContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final preparationText = pendingDependencies.isNotEmpty
            ? _localizedText(
                context,
                pt: 'Primeiro conclua: ${pendingDependencies.join(' • ')}.',
                es: 'Primero completa: ${pendingDependencies.join(' • ')}.',
                en: 'Complete these first: ${pendingDependencies.join(' • ')}.',
              )
            : item.hasRequirements
            ? item.requirements!.take(3).join(' • ')
            : _localizedText(
                context,
                pt: 'Você pode começar agora. O progresso fica salvo se precisar pausar.',
                es: 'Puedes empezar ahora. El progreso queda guardado si necesitas pausar.',
                en: 'You can start now. Your progress is saved if you need to pause.',
              );
        final completionText =
            item.doneCriteria ??
            (item.hasChecklist
                ? _localizedText(
                    context,
                    pt: 'Finalize os ${item.checklistItems!.length} itens do checklist.',
                    es: 'Completa los ${item.checklistItems!.length} elementos de la lista.',
                    en: 'Complete all ${item.checklistItems!.length} checklist items.',
                  )
                : _localizedText(
                    context,
                    pt: 'Conclua a ação indicada e confirme a etapa no botão final.',
                    es: 'Completa la acción indicada y confirma la etapa en el botón final.',
                    en: 'Complete the indicated action and confirm it with the final button.',
                  ));
        final recoveryText = [
          if (item.blockingReason != null) item.blockingReason!,
          if (item.hasTips) item.tips!.first,
        ].join(' ');

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: FrostedPanel(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.82,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GuideUtilitySheetHeader(
                      title: _localizedText(
                        context,
                        pt: 'Guia rápido desta etapa',
                        es: 'Guía rápida de esta etapa',
                        en: 'Quick guide for this step',
                      ),
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            _GuideTaskGuidanceSection(
                              number: 1,
                              icon: Icons.flag_outlined,
                              title: _localizedText(
                                context,
                                pt: 'O que você vai resolver',
                                es: 'Qué vas a resolver',
                                en: 'What you will accomplish',
                              ),
                              body: item.whyItMatters ?? item.shortDescription,
                            ),
                            _GuideTaskGuidanceSection(
                              number: 2,
                              icon: pendingDependencies.isNotEmpty
                                  ? Icons.lock_clock_outlined
                                  : Icons.inventory_2_outlined,
                              title: pendingDependencies.isNotEmpty
                                  ? _localizedText(
                                      context,
                                      pt: 'Antes de continuar',
                                      es: 'Antes de continuar',
                                      en: 'Before you continue',
                                    )
                                  : _localizedText(
                                      context,
                                      pt: 'Antes de começar',
                                      es: 'Antes de empezar',
                                      en: 'Before you start',
                                    ),
                              body: preparationText,
                              tone: pendingDependencies.isNotEmpty
                                  ? AppColors.warning
                                  : AppColors.primary,
                            ),
                            _GuideTaskGuidanceSection(
                              number: 3,
                              icon: Icons.task_alt_rounded,
                              title: _localizedText(
                                context,
                                pt: 'Como saber que terminou',
                                es: 'Cómo saber que terminaste',
                                en: 'How to know you are done',
                              ),
                              body: completionText,
                              tone: AppColors.success,
                            ),
                            if (recoveryText.isNotEmpty)
                              _GuideTaskGuidanceSection(
                                icon: Icons.support_agent_rounded,
                                title: _localizedText(
                                  context,
                                  pt: 'Se você travar',
                                  es: 'Si te bloqueas',
                                  en: 'If you get stuck',
                                ),
                                body: recoveryText,
                                tone: AppColors.warning,
                              ),
                            if (item.hasSupportLinks) ...[
                              const SizedBox(height: 4),
                              for (final link in item.supportLinks!)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  minTileHeight: 52,
                                  leading: const Icon(
                                    Icons.help_outline_rounded,
                                  ),
                                  title: Text(link.label),
                                  trailing: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 18,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    unawaited(
                                      _openExternalPreparationLink(
                                        title: link.label,
                                        uri: Uri.parse(link.url),
                                      ),
                                    );
                                  },
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
        );
      },
    );
  }

  List<GuideActionItem> _buildGuideActionItems(
    BuildContext context,
    MigrationPlan plan,
  ) {
    final explicitCompletedIds = <String>{
      ..._readinessCompletedIds,
      ..._documentCompletedIds,
      ..._arrivalCompletedIds,
    };
    if (MigrationGuideRegistry.supportsPlan(plan)) {
      return GuidePersonalizationService.personalize(
        plan: plan,
        items: MigrationGuideRegistry.build(
          l10n: context.l10n,
          plan: plan,
          currentLocation: widget.locationController.savedLocation,
          localeCode: Localizations.localeOf(context).languageCode,
          exchangeRates: _exchangeRates,
          completedIds: explicitCompletedIds,
        ),
        explicitCompletedIds: explicitCompletedIds,
        explicitDismissedReasons: _dismissedReasonsById,
        localeCode: Localizations.localeOf(context).languageCode,
      );
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
          applicabilityConditions: switch (item.id) {
            'goal_layer' ||
            'cpf_bank' => const <String>['income_strategy_goal'],
            _ => const <String>[],
          },
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
          applicabilityConditions: switch (item.id) {
            'carteira_trabalho' => const <String>['formal_work_goal'],
            'docs_criancas' => const <String>['family_with_kids'],
            _ => const <String>[],
          },
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

    return GuidePersonalizationService.personalize(
      plan: plan,
      items: items,
      explicitCompletedIds: explicitCompletedIds,
      explicitDismissedReasons: _dismissedReasonsById,
      localeCode: Localizations.localeOf(context).languageCode,
    );
  }

  Future<void> _handleCurrentActionTap(
    GuideGpsController controller,
    GuideActionItem item,
    MigrationPlan plan,
    City? city,
  ) async {
    if (controller.stateFor(item.id) == GuideTaskState.waiting) {
      await controller.resumeCurrentItem();
    } else {
      controller.startCurrentItem();
    }
    await _showExecutionPage(controller, item, plan, city);
  }

  /// Confirms the city and transitions the copilot from preview to execution
  /// mode. Called from the preview banner and from the execution sheet when
  /// the user is browsing in read-only mode.
  Future<void> _confirmCity(City city) async {
    await widget.controller.confirmPlanCity(city);
    if (!mounted) return;
    setState(() {}); // triggers rebuild — hasConfirmedCity is now true
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
        if (widget.locationController.savedLocation == null) {
          final granted = await Navigator.pushNamed(
            context,
            AppRoutes.locationPermission,
            arguments: const LocationPermissionScreenArgs(
              returnToPrevious: true,
              isRequired: true,
            ),
          );
          if (!mounted || granted != true) {
            return;
          }
        }
        final originCountryIso =
            FlightRouteContextResolver.resolveOriginCountryIso(
              savedCountryCode:
                  widget.locationController.savedLocation?.countryCode,
              planOriginCountry: plan.originCountry,
            );
        final destinationCountryIso =
            FlightRouteContextResolver.resolveDestinationCountryIso(
              cityCountryCode: city?.countryCode,
              planDestinationCountry: plan.destinationCountry,
            );
        await _showPreparationSheet(
          context,
          title: item.title,
          child: FlightSearchTool(
            locationController: widget.locationController,
            originCountryIso: originCountryIso,
            destinationCountryIso: destinationCountryIso,
            destinationCityName: city?.name,
            destinationLatitude: city?.latitude,
            destinationLongitude: city?.longitude,
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

  Future<void> _showExecutionPage(
    GuideGpsController controller,
    GuideActionItem item,
    MigrationPlan plan,
    City? city, {
    bool isPreview = false,
    GuideActionItem? currentPriorityItem,
  }) async {
    var sheetItem = item;
    var actionOpened = false;
    var criminalRecordProfile = item.id == 'item_0_2_antecedentes'
        ? CriminalRecordProfile.fromJson(
            controller.taskDecisionDataFor(item.id),
          )
        : null;
    var documentFolderProfile = item.id == 'item_0_2_document_folder'
        ? MigrationDocumentFolderProfile.fromJson(
            controller.taskDecisionDataFor(item.id),
          )
        : null;
    var selectedCpfRouteIndex =
        item.decisionOptions?.indexWhere((option) => option.recommended) ?? 0;
    if (selectedCpfRouteIndex < 0) {
      selectedCpfRouteIndex = 0;
    }
    final eventSuggestion = _buildEventSuggestion(
      plan: plan,
      item: item,
      allItems: controller.items,
    );

    if (!isPreview) {
      unawaited(
        GuideFlowMetricsStore.instance.record(
          GuideFlowMetric.taskSheetOpened,
          referenceId: item.id,
        ),
      );
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/plan/step/${item.id}'),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              final isCriminalRecordStep =
                  sheetItem.id == 'item_0_2_antecedentes';
              final isDocumentFolderStep =
                  sheetItem.id == 'item_0_2_document_folder';
              final criminalRecordCalendarSuggestion = isCriminalRecordStep
                  ? _buildCriminalRecordCalendarSuggestion(
                      sheetContext,
                      criminalRecordProfile,
                    )
                  : null;
              final criminalOutcomes =
                  criminalRecordProfile?.outcomes ??
                  const <CriminalRecordOutcome>[];
              final criminalCompletedCount = criminalOutcomes
                  .where(
                    (outcome) => criminalRecordProfile!.completedOutcomeIds
                        .contains(outcome.id),
                  )
                  .length;
              final folderActionIds =
                  documentFolderProfile?.requiredActionIds ?? const <String>[];
              final folderCompletedCount = folderActionIds
                  .where(
                    documentFolderProfile?.completedActionIds.contains ??
                        (_) => false,
                  )
                  .length;
              final documentFolderCalendarSuggestion = isDocumentFolderStep
                  ? _buildDocumentFolderCalendarSuggestion(
                      sheetContext,
                      documentFolderProfile,
                    )
                  : null;
              final allChecklistDone =
                  sheetItem.checklistItems?.every((sub) => sub.isCompleted) ??
                  false;
              final canComplete = isCriminalRecordStep
                  ? (criminalRecordProfile?.isExempt == true ||
                        criminalRecordProfile?.allOutcomesCompleted == true)
                  : isDocumentFolderStep
                  ? documentFolderProfile?.allActionsCompleted == true
                  : !sheetItem.hasChecklist || allChecklistDone;
              final checklistCompletedCount = isCriminalRecordStep
                  ? criminalCompletedCount
                  : isDocumentFolderStep
                  ? folderCompletedCount
                  : sheetItem.checklistItems
                            ?.where((sub) => sub.isCompleted)
                            .length ??
                        0;
              final checklistTotalCount = isCriminalRecordStep
                  ? criminalOutcomes.length
                  : isDocumentFolderStep
                  ? folderActionIds.length
                  : sheetItem.checklistItems?.length ?? 0;
              final hasOutcomeChecklist = isCriminalRecordStep
                  ? criminalOutcomes.isNotEmpty
                  : isDocumentFolderStep
                  ? folderActionIds.isNotEmpty
                  : sheetItem.hasChecklist;
              final isInProgress =
                  hasOutcomeChecklist &&
                  checklistCompletedCount > 0 &&
                  !sheetItem.isCompleted;
              final isCpfStep = sheetItem.id == 'item_2_1_cpf';
              final isBankAccountStep =
                  sheetItem.id == 'item_3_1_conta_bancaria' &&
                  (sheetItem.externalOfficialLinks?.isNotEmpty ?? false);
              final isMoneySetupStep =
                  sheetItem.id == 'item_1_3_money' &&
                  (sheetItem.externalOfficialLinks?.isNotEmpty ?? false);
              final hasPrimaryExecutionAction =
                  !isPreview &&
                  ((sheetItem.resolvedPrimaryActionType !=
                              GuidePrimaryActionType.none &&
                          sheetItem.resolvedPrimaryActionType !=
                              GuidePrimaryActionType.checklist) ||
                      isBankAccountStep ||
                      isMoneySetupStep);

              Future<void> handlePrimaryAction() async {
                if ((isBankAccountStep || isMoneySetupStep) &&
                    (sheetItem.externalOfficialLinks?.isNotEmpty ?? false)) {
                  final links = sheetItem.externalOfficialLinks!;
                  final selected = links.length == 1
                      ? links.first
                      : await _showExternalLinksChooser(
                          sheetContext,
                          sheetItem,
                        );
                  if (selected != null) {
                    await _openExternalPreparationLink(
                      title: selected.label,
                      uri: Uri.parse(selected.url),
                    );
                    setSheetState(() {
                      actionOpened = true;
                    });
                  }
                  return;
                }
                switch (sheetItem.resolvedPrimaryActionType) {
                  case GuidePrimaryActionType.external:
                    final target = sheetItem.resolvedPrimaryActionTarget;
                    if (target != null) {
                      await _openExternalPreparationLink(
                        title: sheetItem.title,
                        uri: Uri.parse(target),
                      );
                    } else if ((sheetItem.externalOfficialLinks?.length ?? 0) >
                        1) {
                      final selected = await _showExternalLinksChooser(
                        sheetContext,
                        sheetItem,
                      );
                      if (selected != null) {
                        await _openExternalPreparationLink(
                          title: selected.label,
                          uri: Uri.parse(selected.url),
                        );
                      }
                    }
                    setSheetState(() {
                      actionOpened = true;
                    });
                  case GuidePrimaryActionType.tool:
                    await _openToolForItem(sheetItem, plan, city);
                    setSheetState(() {
                      actionOpened = true;
                    });
                  case GuidePrimaryActionType.none:
                  case GuidePrimaryActionType.checklist:
                    break;
                }
              }

              Future<void> handleChecklistToggle(
                ChecklistSubItem subItem,
              ) async {
                await controller.toggleChecklistSubItem(
                  sheetItem.id,
                  subItem.id,
                );
                final updatedSubItems = (sheetItem.checklistItems ?? const [])
                    .map(
                      (entry) => entry.id == subItem.id
                          ? entry.copyWith(isCompleted: !entry.isCompleted)
                          : entry,
                    )
                    .toList(growable: false);
                final done = updatedSubItems.every(
                  (entry) => entry.isCompleted,
                );
                setSheetState(() {
                  sheetItem = sheetItem.copyWith(
                    checklistItems: updatedSubItems,
                    isCompleted: done,
                  );
                });
                if (done) {
                  unawaited(HapticFeedback.mediumImpact());
                } else {
                  unawaited(HapticFeedback.selectionClick());
                }
                setState(() {
                  _syncFromGpsController(controller);
                });
              }

              Future<void> updateCriminalRecordProfile(
                CriminalRecordProfile profile,
              ) async {
                setSheetState(() {
                  criminalRecordProfile = profile;
                });
                await controller.saveTaskDecisionData(
                  sheetItem.id,
                  profile.toJson(),
                );
                if (mounted) {
                  setState(() {
                    _syncFromGpsController(controller);
                  });
                }
              }

              Future<void> toggleCriminalRecordOutcome(
                CriminalRecordOutcome outcome,
              ) async {
                final profile = criminalRecordProfile;
                if (profile == null) return;
                final completed = Set<String>.from(profile.completedOutcomeIds);
                if (!completed.add(outcome.id)) {
                  completed.remove(outcome.id);
                }
                await updateCriminalRecordProfile(
                  profile.copyWith(completedOutcomeIds: completed),
                );
              }

              Future<void> updateDocumentFolderProfile(
                MigrationDocumentFolderProfile profile,
              ) async {
                setSheetState(() {
                  documentFolderProfile = profile;
                });
                await controller.saveTaskDecisionData(
                  sheetItem.id,
                  profile.toJson(),
                );
                if (mounted) {
                  setState(() {
                    _syncFromGpsController(controller);
                  });
                }
              }

              Future<void> toggleDocumentFolderAction(String actionId) async {
                final profile = documentFolderProfile;
                if (profile == null) return;
                final completed = Set<String>.from(profile.completedActionIds);
                if (!completed.add(actionId)) completed.remove(actionId);
                await updateDocumentFolderProfile(
                  profile.copyWith(completedActionIds: completed),
                );
                unawaited(HapticFeedback.selectionClick());
              }

              void syncUpdatedItem() {
                final updated = controller.items.firstWhere(
                  (entry) => entry.id == sheetItem.id,
                );
                setSheetState(() {
                  sheetItem = updated;
                });
                if (mounted) {
                  setState(() {
                    _syncFromGpsController(controller);
                  });
                }
              }

              Future<void> handlePrioritize() async {
                await controller.togglePrioritizeItem(sheetItem.id);
                syncUpdatedItem();
              }

              Future<void> handleRestore() async {
                await controller.restoreDismissedItem(sheetItem.id);
                syncUpdatedItem();
              }

              Future<void> handleDismiss(GuideDismissReason reason) async {
                final completedPhasesBefore = _completedGuidePhases(controller);
                await controller.dismissItem(sheetItem.id, reason);
                syncUpdatedItem();
                await _maybeShowPhaseCelebration(
                  completedPhasesBefore: completedPhasesBefore,
                  controller: controller,
                );
              }

              Future<void> handleComplete() async {
                unawaited(HapticFeedback.mediumImpact());
                Navigator.of(sheetContext).pop();
                if (!sheetItem.hasChecklist) {
                  await _completeGuideItem(controller, sheetItem.id);
                  return;
                }
                if (canComplete) {
                  setState(() {
                    _showCelebration = true;
                    _readinessCompletedIds = Set<String>.from(
                      controller.readinessCompletedIds,
                    );
                    _documentCompletedIds = Set<String>.from(
                      controller.documentCompletedIds,
                    );
                    _arrivalCompletedIds = Set<String>.from(
                      controller.arrivalCompletedIds,
                    );
                    _completedAtById = Map<String, String>.from(
                      controller.completedAtById,
                    );
                    _loadedActiveItemId = controller.activeItemId;
                  });
                  await Future<void>.delayed(
                    const Duration(milliseconds: 1800),
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _showCelebration = false;
                  });
                }
              }

              Future<void> handleCriminalRecordComplete() async {
                if (!canComplete) return;
                unawaited(HapticFeedback.mediumImpact());
                Navigator.of(sheetContext).pop();
                if (criminalRecordProfile?.isExempt == true) {
                  await controller.dismissItem(
                    sheetItem.id,
                    GuideDismissReason.notApplicable,
                  );
                } else {
                  await _completeGuideItem(controller, sheetItem.id);
                }
                if (!mounted) return;
                setState(() {
                  _syncFromGpsController(controller);
                });
              }

              Future<void> handleDocumentFolderComplete() async {
                if (!canComplete) return;
                unawaited(HapticFeedback.mediumImpact());
                Navigator.of(sheetContext).pop();
                await _completeGuideItem(controller, sheetItem.id);
                if (!mounted) return;
                setState(() {
                  _syncFromGpsController(controller);
                });
              }

              return Scaffold(
                backgroundColor: AppColors.backgroundFor(sheetContext),
                body: Stack(
                  children: [
                    const Positioned.fill(child: AmbientBackground()),
                    SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              sheetContext.isMobileLayout ? 16 : 24,
                              8,
                              sheetContext.isMobileLayout ? 16 : 24,
                              12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _GuideTaskPageHeader(
                                  item: sheetItem,
                                  overallProgress: controller.progress,
                                  completedChecklistItems:
                                      checklistCompletedCount,
                                  totalChecklistItems: checklistTotalCount,
                                  isPreview: isPreview,
                                  onClose: () =>
                                      Navigator.of(sheetContext).pop(),
                                  onHelp: () => _showTaskGuidanceSheet(
                                    sheetContext,
                                    sheetItem,
                                    controller.items,
                                  ),
                                  onPrioritize: handlePrioritize,
                                  onRestore: handleRestore,
                                  onDismiss: handleDismiss,
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── CPF Unlock Chain Banner ──
                                        if (sheetItem.id == 'item_2_1_cpf')
                                          _CpfUnlockBanner(
                                            allItems: controller.items,
                                          ),
                                        if (isPreview) ...[
                                          _FocusedTipPreviewBanner(
                                            item: sheetItem,
                                            currentPriorityItem:
                                                currentPriorityItem,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        // ── Urgency Signal Banner ──
                                        if (sheetItem.urgencySignal !=
                                            null) ...[
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _urgencyBannerColor(
                                                sheetContext,
                                                sheetItem.urgencyLevel,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 16,
                                                  color: _urgencyTextColor(
                                                    sheetContext,
                                                    sheetItem.urgencyLevel,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    sheetItem.urgencySignal!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _urgencyTextColor(
                                                        sheetContext,
                                                        sheetItem.urgencyLevel,
                                                      ),
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        if (!isPreview &&
                                            sheetItem.preArrivalRequired &&
                                            !sheetItem.isCompleted) ...[
                                          _PreArrivalTimingBanner(
                                            timeline: plan.timeline,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        _GuideWorkflowSection(
                                          number: 1,
                                          icon: Icons.inventory_2_outlined,
                                          title: _localizedText(
                                            sheetContext,
                                            pt: 'Prepare o necessário',
                                            es: 'Prepara lo necesario',
                                            en: 'Prepare what you need',
                                          ),
                                          description: _localizedText(
                                            sheetContext,
                                            pt: 'Separe o que será necessário antes de começar.',
                                            es: 'Separa lo que necesitarás antes de comenzar.',
                                            en: 'Gather what you need before starting.',
                                          ),
                                          child: isCriminalRecordStep
                                              ? Column(
                                                  children: [
                                                    _CriminalRecordDecisionAssistant(
                                                      profile:
                                                          criminalRecordProfile ??
                                                          const CriminalRecordProfile(),
                                                      onChanged:
                                                          updateCriminalRecordProfile,
                                                    ),
                                                    if (criminalRecordCalendarSuggestion !=
                                                        null) ...[
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      _buildCalendarPrompt(
                                                        plan: plan,
                                                        suggestion:
                                                            criminalRecordCalendarSuggestion,
                                                      ),
                                                    ],
                                                  ],
                                                )
                                              : isDocumentFolderStep
                                              ? Column(
                                                  children: [
                                                    _MigrationFolderDecisionAssistant(
                                                      profile:
                                                          documentFolderProfile ??
                                                          const MigrationDocumentFolderProfile(),
                                                      onChanged:
                                                          updateDocumentFolderProfile,
                                                    ),
                                                    if (documentFolderCalendarSuggestion !=
                                                        null) ...[
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      _buildCalendarPrompt(
                                                        plan: plan,
                                                        suggestion:
                                                            documentFolderCalendarSuggestion,
                                                      ),
                                                    ],
                                                  ],
                                                )
                                              : sheetItem.hasSurvivalPhrases ||
                                                    sheetItem.hasRequirements
                                              ? _QuickReferenceCard(
                                                  item: sheetItem,
                                                )
                                              : _GuideWorkflowMessage(
                                                  text: _localizedText(
                                                    sheetContext,
                                                    pt: 'Esta etapa não exige preparação adicional. Você pode seguir para a execução.',
                                                    es: 'Esta etapa no exige preparación adicional. Puedes seguir con la ejecución.',
                                                    en: 'This step needs no additional preparation. You can continue to execution.',
                                                  ),
                                                ),
                                        ),
                                        _GuideWorkflowSection(
                                          number: 2,
                                          icon: Icons.play_arrow_rounded,
                                          title: isInProgress
                                              ? _localizedText(
                                                  sheetContext,
                                                  pt: 'Continue a execução',
                                                  es: 'Continúa la ejecución',
                                                  en: 'Continue execution',
                                                )
                                              : _localizedText(
                                                  sheetContext,
                                                  pt: 'Execute a etapa',
                                                  es: 'Ejecuta la etapa',
                                                  en: 'Execute the step',
                                                ),
                                          description: _localizedText(
                                            sheetContext,
                                            pt: 'Siga a ordem abaixo e use a ação indicada quando necessário.',
                                            es: 'Sigue el orden de abajo y usa la acción indicada cuando sea necesario.',
                                            en: 'Follow the order below and use the indicated action when needed.',
                                          ),
                                          child: Column(
                                            children: [
                                              if (isCriminalRecordStep)
                                                _CriminalRecordExecutionPlan(
                                                  profile:
                                                      criminalRecordProfile ??
                                                      const CriminalRecordProfile(),
                                                  onLinkTap: (url, label) =>
                                                      _openExternalPreparationLink(
                                                        title: label,
                                                        uri: Uri.parse(url),
                                                      ),
                                                )
                                              else if (isDocumentFolderStep)
                                                _MigrationFolderActionRunner(
                                                  profile:
                                                      documentFolderProfile ??
                                                      const MigrationDocumentFolderProfile(),
                                                  onToggle:
                                                      toggleDocumentFolderAction,
                                                  onOpenOfficial: () => _openExternalPreparationLink(
                                                    title: _localizedText(
                                                      sheetContext,
                                                      pt: 'Lista oficial da Polícia Federal',
                                                      es: 'Lista oficial de la Policía Federal',
                                                      en: 'Federal Police official checklist',
                                                    ),
                                                    uri: PreparationResourceLinks
                                                        .argentinaResidenceAgreement,
                                                  ),
                                                  onCopyStructure: () async {
                                                    await Clipboard.setData(
                                                      ClipboardData(
                                                        text:
                                                            _migrationFolderStructureText(
                                                              sheetContext,
                                                            ),
                                                      ),
                                                    );
                                                    if (!sheetContext.mounted) {
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(
                                                      sheetContext,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          _localizedText(
                                                            sheetContext,
                                                            pt: 'Estrutura copiada. Use os nomes para criar suas pastas.',
                                                            es: 'Estructura copiada. Usa los nombres para crear tus carpetas.',
                                                            en: 'Structure copied. Use the names to create your folders.',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              else if (isCpfStep &&
                                                  (sheetItem
                                                          .hasDecisionOptions ||
                                                      sheetItem
                                                          .hasLocationAwareOptions)) ...[
                                                _CpfDecisionContent(
                                                  item: sheetItem,
                                                  selectedIndex:
                                                      selectedCpfRouteIndex,
                                                  onSelected: (index) {
                                                    setSheetState(() {
                                                      selectedCpfRouteIndex =
                                                          index;
                                                    });
                                                    unawaited(
                                                      HapticFeedback.selectionClick(),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 12),
                                                _CpfExecutionBlock(
                                                  item: sheetItem,
                                                  selectedIndex:
                                                      selectedCpfRouteIndex,
                                                  onLinkTap: (url, label) =>
                                                      _openExternalPreparationLink(
                                                        title: label,
                                                        uri: Uri.parse(url),
                                                      ),
                                                ),
                                              ] else if (sheetItem
                                                      .hasDecisionOptions ||
                                                  sheetItem.hasSteps ||
                                                  sheetItem
                                                      .hasLocationAwareOptions) ...[
                                                if (sheetItem
                                                    .hasLocationAwareOptions)
                                                  _GuideExecutionBlock(
                                                    item: sheetItem,
                                                    onLinkTap: (url, label) =>
                                                        _openExternalPreparationLink(
                                                          title: label,
                                                          uri: Uri.parse(url),
                                                        ),
                                                  ),
                                                if (sheetItem
                                                        .hasLocationAwareOptions &&
                                                    (sheetItem
                                                            .hasDecisionOptions ||
                                                        sheetItem.hasSteps))
                                                  const SizedBox(height: 12),
                                                if (sheetItem
                                                        .hasDecisionOptions ||
                                                    sheetItem.hasSteps)
                                                  _GuideExecutionContent(
                                                    item: sheetItem,
                                                    onLinkTap: (url, label) =>
                                                        _openExternalPreparationLink(
                                                          title: label,
                                                          uri: Uri.parse(url),
                                                        ),
                                                  ),
                                              ] else
                                                _GuideWorkflowMessage(
                                                  text:
                                                      sheetItem.context ??
                                                      sheetItem
                                                          .shortDescription,
                                                ),
                                              if (hasPrimaryExecutionAction &&
                                                  !isDocumentFolderStep &&
                                                  (!isCriminalRecordStep ||
                                                      (criminalRecordProfile
                                                                  ?.isComplete ==
                                                              true &&
                                                          criminalRecordProfile
                                                                  ?.isExempt !=
                                                              true))) ...[
                                                const SizedBox(height: 14),
                                                _GuideNextMoveCard(
                                                  actionType: sheetItem
                                                      .resolvedPrimaryActionType,
                                                  actionLabel: actionOpened
                                                      ? _localizedText(
                                                          sheetContext,
                                                          pt: 'Abrir novamente',
                                                          es: 'Abrir de novo',
                                                          en: 'Open again',
                                                        )
                                                      : isCriminalRecordStep &&
                                                            criminalRecordProfile
                                                                    ?.protocolWindow !=
                                                                CriminalRecordProtocolWindow
                                                                    .withinThirtyDays
                                                      ? _localizedText(
                                                          sheetContext,
                                                          pt: 'Ver requisitos no RNR',
                                                          es: 'Ver requisitos del RNR',
                                                          en: 'Review RNR requirements',
                                                        )
                                                      : (sheetItem
                                                                .primaryActionLabel ??
                                                            _localizedText(
                                                              sheetContext,
                                                              pt: 'Abrir ação principal',
                                                              es: 'Abrir acción principal',
                                                              en: 'Open primary action',
                                                            )),
                                                  actionOpened: actionOpened,
                                                  description:
                                                      isCriminalRecordStep &&
                                                          criminalRecordProfile
                                                                  ?.protocolWindow !=
                                                              CriminalRecordProtocolWindow
                                                                  .withinThirtyDays
                                                      ? _localizedText(
                                                          sheetContext,
                                                          pt: 'Abra a fonte para validar acesso, documentos e preços. Emita somente quando o protocolo estiver mais próximo.',
                                                          es: 'Abrí la fuente para validar acceso, documentos y precios. Emitilo solo cuando la presentación esté más cerca.',
                                                          en: 'Open the source to confirm access, documents, and prices. Request only when filing is closer.',
                                                        )
                                                      : null,
                                                  onPressed:
                                                      handlePrimaryAction,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        _GuideWorkflowSection(
                                          number: 3,
                                          icon: Icons.fact_check_outlined,
                                          title: _localizedText(
                                            sheetContext,
                                            pt: 'Confirme o resultado',
                                            es: 'Confirma el resultado',
                                            en: 'Confirm the result',
                                          ),
                                          description: isDocumentFolderStep
                                              ? _localizedText(
                                                  sheetContext,
                                                  pt: 'Confira o resumo. A etapa é liberada quando a estrutura da pasta estiver pronta.',
                                                  es: 'Revisa el resumen. La etapa se habilita cuando la estructura esté lista.',
                                                  en: 'Review the summary. The step unlocks when the folder structure is ready.',
                                                )
                                              : hasOutcomeChecklist
                                              ? _localizedText(
                                                  sheetContext,
                                                  pt: 'Marque cada resultado abaixo. A etapa será liberada quando todos estiverem concluídos.',
                                                  es: 'Marca cada resultado abajo. La etapa se habilitará cuando todos estén completos.',
                                                  en: 'Check each result below. The step will unlock when all are complete.',
                                                )
                                              : _localizedText(
                                                  sheetContext,
                                                  pt: 'Confira o critério e use o botão “Concluir etapa” no final da tela.',
                                                  es: 'Revisa el criterio y usa el botón “Completar etapa” al final de la pantalla.',
                                                  en: 'Review the criterion and use the “Complete step” button at the bottom.',
                                                ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (isCriminalRecordStep &&
                                                  criminalRecordProfile
                                                          ?.isComplete !=
                                                      true)
                                                _GuideWorkflowMessage(
                                                  text: _localizedText(
                                                    sheetContext,
                                                    pt: 'Responda às perguntas da primeira parte para gerar a confirmação certa para o seu caso.',
                                                    es: 'Responde las preguntas de la primera parte para generar la confirmación correcta para tu caso.',
                                                    en: 'Answer the questions in the first section to generate the right confirmation for your case.',
                                                  ),
                                                )
                                              else if (isDocumentFolderStep &&
                                                  documentFolderProfile
                                                          ?.isComplete !=
                                                      true)
                                                _GuideWorkflowMessage(
                                                  text: _localizedText(
                                                    sheetContext,
                                                    pt: 'Responda às perguntas iniciais para gerar uma pasta adequada ao seu caso.',
                                                    es: 'Responde las preguntas iniciales para generar una carpeta adecuada a tu caso.',
                                                    en: 'Answer the initial questions to generate a folder suited to your case.',
                                                  ),
                                                )
                                              else if (isCriminalRecordStep &&
                                                  criminalRecordProfile
                                                          ?.isExempt ==
                                                      true)
                                                _CriminalRecordExemptionCard()
                                              else if (isDocumentFolderStep)
                                                _MigrationFolderCompletionSummary(
                                                  profile:
                                                      documentFolderProfile!,
                                                )
                                              else if (sheetItem.doneCriteria !=
                                                  null)
                                                _GuideDoneCriteriaContent(
                                                  item: sheetItem,
                                                )
                                              else
                                                _GuideWorkflowMessage(
                                                  text: sheetItem.hasChecklist
                                                      ? _localizedText(
                                                          sheetContext,
                                                          pt: 'Considere a etapa concluída quando todos os resultados abaixo estiverem confirmados.',
                                                          es: 'Considera la etapa terminada cuando todos los resultados de abajo estén confirmados.',
                                                          en: 'Consider the step complete when all results below are confirmed.',
                                                        )
                                                      : _localizedText(
                                                          sheetContext,
                                                          pt: 'Considere a etapa concluída depois de executar a ação indicada.',
                                                          es: 'Considera la etapa terminada después de ejecutar la acción indicada.',
                                                          en: 'Consider the step complete after carrying out the indicated action.',
                                                        ),
                                                ),
                                              if (isCriminalRecordStep &&
                                                  criminalOutcomes
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                _CriminalRecordOutcomeChecklist(
                                                  outcomes: criminalOutcomes,
                                                  completedIds:
                                                      criminalRecordProfile!
                                                          .completedOutcomeIds,
                                                  onToggle:
                                                      toggleCriminalRecordOutcome,
                                                ),
                                              ] else if (!isDocumentFolderStep &&
                                                  sheetItem.hasChecklist) ...[
                                                const SizedBox(height: 12),
                                                _GuideOutcomeProgress(
                                                  key: const ValueKey<String>(
                                                    'guide-confirmation-checklist',
                                                  ),
                                                  items:
                                                      sheetItem.checklistItems!,
                                                  enabled: !isPreview,
                                                  onToggle:
                                                      handleChecklistToggle,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (!isDocumentFolderStep)
                                          _GuideSupplementaryDetails(
                                            item: sheetItem,
                                            quickReferenceShown:
                                                !sheetItem.isCompleted &&
                                                (sheetItem.hasSurvivalPhrases ||
                                                    sheetItem.hasRequirements),
                                            onLinkTap: (url, label) =>
                                                _openExternalPreparationLink(
                                                  title: label,
                                                  uri: Uri.parse(url),
                                                ),
                                          ),
                                        // ── Warning Flags (protective, after reassurance) ──
                                        if (sheetItem.hasWarningFlags) ...[
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.tintedSurfaceFor(
                                                sheetContext,
                                                tint: AppColors.danger,
                                                lightColor: const Color(
                                                  0xFFFFF1F0,
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color:
                                                    AppColors.tintedBorderFor(
                                                      sheetContext,
                                                      tint: AppColors.danger,
                                                      lightColor: const Color(
                                                        0xFFF2B8B5,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.gpp_bad_rounded,
                                                      size: 14,
                                                      color: AppColors.danger,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _localizedText(
                                                        sheetContext,
                                                        pt: 'Alertas importantes',
                                                        es: 'Alertas importantes',
                                                        en: 'Important warnings',
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors.danger,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                for (final flag
                                                    in sheetItem
                                                        .warningFlags!) ...[
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 5,
                                                              right: 6,
                                                            ),
                                                        child: Icon(
                                                          Icons.circle,
                                                          size: 5,
                                                          color:
                                                              AppColors.danger,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          flag,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                AppColors.textPrimaryFor(
                                                                  sheetContext,
                                                                ),
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        if (!isPreview &&
                                            !isCriminalRecordStep &&
                                            !isDocumentFolderStep &&
                                            !sheetItem.isCompleted &&
                                            eventSuggestion != null) ...[
                                          const SizedBox(height: 12),
                                          _GuideCalendarSuggestionCard(
                                            suggestion: eventSuggestion,
                                            onTap: () =>
                                                _showCalendarSuggestionSheet(
                                                  plan: plan,
                                                  suggestion: eventSuggestion,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (isPreview && city != null)
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () async {
                                        Navigator.of(sheetContext).pop();
                                        await _confirmCity(city);
                                      },
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _localizedText(
                                          sheetContext,
                                          pt: 'Confirmar ${city.name} e começar',
                                          es: 'Confirmar ${city.name} y comenzar',
                                          en: 'Confirm ${city.name} and start',
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  _GuideTaskFooter(
                                    primaryLabel: sheetItem.isDismissed
                                        ? _localizedText(
                                            sheetContext,
                                            pt: 'Etapa dispensada',
                                            es: 'Etapa descartada',
                                            en: 'Step dismissed',
                                          )
                                        : isCriminalRecordStep &&
                                              criminalRecordProfile?.isExempt ==
                                                  true
                                        ? _localizedText(
                                            sheetContext,
                                            pt: 'Concluir como dispensado',
                                            es: 'Completar como exento',
                                            en: 'Complete as exempt',
                                          )
                                        : isCriminalRecordStep &&
                                              criminalRecordProfile
                                                      ?.isComplete !=
                                                  true
                                        ? _localizedText(
                                            sheetContext,
                                            pt: 'Complete as perguntas acima',
                                            es: 'Completa las preguntas de arriba',
                                            en: 'Complete the questions above',
                                          )
                                        : isCriminalRecordStep && !canComplete
                                        ? _localizedText(
                                            sheetContext,
                                            pt: '$criminalCompletedCount de ${criminalOutcomes.length} confirmações',
                                            es: '$criminalCompletedCount de ${criminalOutcomes.length} confirmaciones',
                                            en: '$criminalCompletedCount of ${criminalOutcomes.length} confirmations',
                                          )
                                        : isDocumentFolderStep &&
                                              documentFolderProfile
                                                      ?.isComplete !=
                                                  true
                                        ? _localizedText(
                                            sheetContext,
                                            pt: 'Complete as perguntas acima',
                                            es: 'Completa las preguntas de arriba',
                                            en: 'Complete the questions above',
                                          )
                                        : isDocumentFolderStep && !canComplete
                                        ? _localizedText(
                                            sheetContext,
                                            pt: '$folderCompletedCount de ${folderActionIds.length} peças preparadas',
                                            es: '$folderCompletedCount de ${folderActionIds.length} piezas preparadas',
                                            en: '$folderCompletedCount of ${folderActionIds.length} pieces prepared',
                                          )
                                        : canComplete && sheetItem.hasChecklist
                                        ? _localizedText(
                                            sheetContext,
                                            pt: 'Continuar para a próxima etapa',
                                            es: 'Continuar al siguiente paso',
                                            en: 'Continue to the next step',
                                          )
                                        : canComplete
                                        ? _localizedText(
                                            sheetContext,
                                            pt: 'Concluir etapa',
                                            es: 'Completar etapa',
                                            en: 'Complete step',
                                          )
                                        : _localizedText(
                                            sheetContext,
                                            pt: '$checklistCompletedCount de ${sheetItem.checklistItems?.length ?? 0} itens concluídos',
                                            es: '$checklistCompletedCount de ${sheetItem.checklistItems?.length ?? 0} elementos completados',
                                            en: '$checklistCompletedCount of ${sheetItem.checklistItems?.length ?? 0} items complete',
                                          ),
                                    helperText:
                                        hasOutcomeChecklist && !canComplete
                                        ? isDocumentFolderStep
                                              ? _localizedText(
                                                  sheetContext,
                                                  pt: 'Seu progresso fica salvo. Prepare uma peça por vez na seção acima.',
                                                  es: 'Tu progreso queda guardado. Prepara una pieza por vez arriba.',
                                                  en: 'Your progress is saved. Prepare one piece at a time above.',
                                                )
                                              : _localizedText(
                                                  sheetContext,
                                                  pt: 'Seu progresso fica salvo. Confirme cada resultado quando acontecer.',
                                                  es: 'Tu progreso queda guardado. Confirma cada resultado cuando ocurra.',
                                                  en: 'Your progress is saved. Confirm each outcome as it happens.',
                                                )
                                        : null,
                                    primaryEnabled:
                                        !sheetItem.isDismissed && canComplete,
                                    onPrimary: isCriminalRecordStep
                                        ? handleCriminalRecordComplete
                                        : isDocumentFolderStep
                                        ? handleDocumentFolderComplete
                                        : handleComplete,
                                    onWaiting:
                                        !sheetItem.isDismissed &&
                                            !sheetItem.isCompleted
                                        ? () async {
                                            Navigator.of(sheetContext).pop();
                                            await controller
                                                .markCurrentItemWaiting();
                                            if (!mounted) return;
                                            setState(() {
                                              _syncFromGpsController(
                                                controller,
                                              );
                                            });
                                          }
                                        : null,
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
            },
          );
        },
      ),
    );
    if (!isPreview) {
      final latestItem = controller.items.cast<GuideActionItem?>().firstWhere(
        (candidate) => candidate?.id == item.id,
        orElse: () => null,
      );
      if (latestItem != null &&
          !latestItem.isCompleted &&
          latestItem.dismissReason == null) {
        unawaited(
          GuideFlowMetricsStore.instance.record(
            GuideFlowMetric.taskSheetClosedIncomplete,
            referenceId: item.id,
          ),
        );
      }
    }
  }

  Future<void> _completeGuideItem(
    GuideGpsController controller,
    String itemId,
  ) async {
    final completedPhasesBefore = _completedGuidePhases(controller);
    await controller.completeActionItem(itemId);
    if (!mounted) {
      return;
    }
    setState(() {
      _showCelebration = true;
      _showExpandedContent = false;
      _syncFromGpsController(controller);
    });
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) {
      return;
    }
    setState(() {
      _showCelebration = false;
    });
    await _maybeShowPhaseCelebration(
      completedPhasesBefore: completedPhasesBefore,
      controller: controller,
    );
  }

  Set<GuidePhase> _completedGuidePhases(GuideGpsController controller) {
    return {
      for (final phase in GuidePhase.values)
        if (controller.itemsForPhase(phase).isNotEmpty &&
            controller.itemsForPhase(phase).every((item) => item.isCompleted))
          phase,
    };
  }

  Future<void> _maybeShowPhaseCelebration({
    required Set<GuidePhase> completedPhasesBefore,
    required GuideGpsController controller,
  }) async {
    final completedPhasesAfter = _completedGuidePhases(controller);
    final newlyCompleted = completedPhasesAfter.difference(
      completedPhasesBefore,
    );
    newlyCompleted.removeAll(_celebratedPhases);
    if (newlyCompleted.isEmpty || !mounted) {
      return;
    }

    final phase = newlyCompleted.first;
    _celebratedPhases.addAll(newlyCompleted);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FrostedPanel(
              padding: const EdgeInsets.all(22),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.celebration_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _localizedText(
                      context,
                      pt: 'Fase concluída',
                      es: 'Fase completada',
                      en: 'Phase completed',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _guidePhaseName(context, phase),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _phaseCelebrationBody(context, phase),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        _localizedText(
                          context,
                          pt: 'Continuar',
                          es: 'Continuar',
                          en: 'Continue',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  GuideEventSuggestion? _buildEventSuggestion({
    required MigrationPlan plan,
    required GuideActionItem item,
    required List<GuideActionItem> allItems,
  }) {
    return _eventSuggestionEngine.buildForItem(
      plan: plan,
      item: item,
      completedAtById: _completedAtById,
      completedSteps: _completedAtById.length,
      totalSteps: allItems.length,
      localeCode: Localizations.localeOf(context).languageCode,
    );
  }

  GuideEventSuggestion? _buildCriminalRecordCalendarSuggestion(
    BuildContext context,
    CriminalRecordProfile? profile,
  ) {
    if (profile?.isComplete != true || profile?.isExempt == true) {
      return null;
    }

    final window = profile!.protocolWindow!;
    final now = DateTime.now();
    final daysUntilReminder = switch (window) {
      CriminalRecordProtocolWindow.withinThirtyDays => 1,
      CriminalRecordProtocolWindow.oneToThreeMonths => 30,
      CriminalRecordProtocolWindow.moreThanThreeMonths => 60,
      CriminalRecordProtocolWindow.unknown => 14,
    };
    final start = _nextReminderBusinessDay(
      now.add(Duration(days: daysUntilReminder)),
    );
    final (title, description, assistantCopy) = switch (window) {
      CriminalRecordProtocolWindow.withinThirtyDays => (
        _localizedText(
          context,
          pt: 'Emitir certificado de antecedentes',
          es: 'Emitir certificado de antecedentes',
          en: 'Request criminal record certificate',
        ),
        _localizedText(
          context,
          pt: 'Abrir o RNR, escolher a modalidade, pagar e guardar os dados de acompanhamento.',
          es: 'Abrir el RNR, elegir la modalidad, pagar y guardar los datos de seguimiento.',
          en: 'Open RNR, select the service speed, pay, and save the tracking details.',
        ),
        _localizedText(
          context,
          pt: 'Seu protocolo está próximo. Quer reservar um horário para emitir sem deixar para a última hora?',
          es: 'Tu presentación está próxima. ¿Querés reservar un horario para emitirlo sin dejarlo para último momento?',
          en: 'Your filing date is close. Would you like to reserve time to request it without leaving it until the last minute?',
        ),
      ),
      CriminalRecordProtocolWindow.oneToThreeMonths => (
        _localizedText(
          context,
          pt: 'Revisar data e emitir antecedentes',
          es: 'Revisar fecha y emitir antecedentes',
          en: 'Review timing and request records',
        ),
        _localizedText(
          context,
          pt: 'Confirmar se a data do protocolo já está firme e, se estiver, emitir os certificados aplicáveis.',
          es: 'Confirmar si la fecha de presentación ya está definida y, si lo está, emitir los certificados aplicables.',
          en: 'Confirm whether the filing date is firm and, if it is, request the applicable certificates.',
        ),
        _localizedText(
          context,
          pt: 'Como ainda falta algum tempo, faz mais sentido lembrar de revisar a janela antes de emitir.',
          es: 'Como todavía falta tiempo, conviene recordar revisar el plazo antes de emitir.',
          en: 'Because there is still time, it makes more sense to schedule a timing review before requesting.',
        ),
      ),
      CriminalRecordProtocolWindow.moreThanThreeMonths => (
        _localizedText(
          context,
          pt: 'Reavaliar janela dos antecedentes',
          es: 'Reevaluar el plazo de antecedentes',
          en: 'Reassess the criminal-record timing',
        ),
        _localizedText(
          context,
          pt: 'Reabrir esta etapa, revisar a previsão do protocolo e decidir se já chegou o momento de emitir.',
          es: 'Reabrir esta etapa, revisar la previsión de presentación y decidir si ya es momento de emitir.',
          en: 'Reopen this step, review the filing estimate, and decide whether it is time to request.',
        ),
        _localizedText(
          context,
          pt: 'Emitir agora seria cedo. Posso colocar uma revisão futura no calendário para você não precisar lembrar sozinho.',
          es: 'Emitir ahora sería pronto. Puedo agregar una revisión futura al calendario para que no tengas que recordarlo solo.',
          en: 'Requesting now would be early. I can add a future review so you do not have to remember it yourself.',
        ),
      ),
      CriminalRecordProtocolWindow.unknown => (
        _localizedText(
          context,
          pt: 'Definir previsão do protocolo na PF',
          es: 'Definir previsión de presentación ante la PF',
          en: 'Set a Federal Police filing estimate',
        ),
        _localizedText(
          context,
          pt: 'Escolher uma previsão de protocolo para calcular o momento seguro de emitir os antecedentes.',
          es: 'Elegir una previsión de presentación para calcular el momento seguro de emitir los antecedentes.',
          en: 'Choose a filing estimate to calculate a safer time to request the records.',
        ),
        _localizedText(
          context,
          pt: 'Sem uma data aproximada, o melhor lembrete é voltar aqui e definir a janela antes de emitir.',
          es: 'Sin una fecha aproximada, el mejor recordatorio es volver aquí y definir el plazo antes de emitir.',
          en: 'Without an approximate date, the best reminder is to return here and set the timing before requesting.',
        ),
      ),
    };

    return GuideEventSuggestion(
      id: 'event_item_0_2_antecedentes_${window.name}',
      sourceItemId: 'item_0_2_antecedentes',
      type: GuideEventType.reminder,
      title: title,
      description: description,
      assistantCopy: assistantCopy,
      startAt: start,
      endAt: start.add(const Duration(minutes: 30)),
      suggestedDurationMinutes: 30,
      defaultReminderOption: GuideEventReminderOption.oneDayBefore,
      isHighPriority: window == CriminalRecordProtocolWindow.withinThirtyDays,
    );
  }

  GuideEventSuggestion? _buildDocumentFolderCalendarSuggestion(
    BuildContext context,
    MigrationDocumentFolderProfile? profile,
  ) {
    if (profile?.isComplete != true) return null;
    final window = profile!.protocolWindow!;
    final days = switch (window) {
      CriminalRecordProtocolWindow.withinThirtyDays => 1,
      CriminalRecordProtocolWindow.oneToThreeMonths => 14,
      CriminalRecordProtocolWindow.moreThanThreeMonths => 45,
      CriminalRecordProtocolWindow.unknown => 14,
    };
    final start = _nextReminderBusinessDay(
      DateTime.now().add(Duration(days: days)),
    );
    final isNear = window == CriminalRecordProtocolWindow.withinThirtyDays;
    return GuideEventSuggestion(
      id: 'event_item_0_2_document_folder_${window.name}',
      sourceItemId: 'item_0_2_document_folder',
      type: GuideEventType.reminder,
      title: _localizedText(
        context,
        pt: isNear ? 'Finalizar pasta migratória' : 'Revisar pasta migratória',
        es: isNear
            ? 'Finalizar carpeta migratoria'
            : 'Revisar carpeta migratoria',
        en: isNear
            ? 'Finish migration document folder'
            : 'Review migration document folder',
      ),
      description: _localizedText(
        context,
        pt: isNear
            ? 'Conferir as peças preparadas, os documentos pendentes e a lista oficial antes do protocolo.'
            : 'Voltar à pasta, revisar a previsão do protocolo e atualizar os documentos que faltam.',
        es: isNear
            ? 'Revisar las piezas preparadas, los documentos pendientes y la lista oficial antes de la presentación.'
            : 'Volver a la carpeta, revisar la fecha prevista y actualizar los documentos pendientes.',
        en: isNear
            ? 'Check prepared pieces, pending documents, and the official list before filing.'
            : 'Return to the folder, review the filing estimate, and update pending documents.',
      ),
      assistantCopy: _localizedText(
        context,
        pt: isNear
            ? 'Seu protocolo está próximo. Reserve um bloco curto para a conferência final.'
            : 'Como ainda há tempo, agende uma revisão sem emitir documentos cedo demais.',
        es: isNear
            ? 'Tu presentación está próxima. Reserva un bloque corto para la revisión final.'
            : 'Como todavía hay tiempo, agenda una revisión sin emitir documentos demasiado pronto.',
        en: isNear
            ? 'Your filing is close. Reserve a short block for the final review.'
            : 'There is still time, so schedule a review without requesting documents too early.',
      ),
      startAt: start,
      endAt: start.add(const Duration(minutes: 35)),
      suggestedDurationMinutes: 35,
      defaultReminderOption: GuideEventReminderOption.oneDayBefore,
      isHighPriority: isNear,
    );
  }

  String _migrationFolderStructureText(BuildContext context) {
    return _localizedText(
      context,
      pt: '''Pasta migratória — Brasil
01_identidade_e_filiacao
02_antecedentes
03_formulario_e_declaracoes
04_entrada_no_brasil
05_taxas_e_comprovantes
06_protocolos_e_recibos''',
      es: '''Carpeta migratoria — Brasil
01_identidad_y_filiacion
02_antecedentes
03_formulario_y_declaraciones
04_entrada_a_brasil
05_tasas_y_comprobantes
06_protocolos_y_recibos''',
      en: '''Migration folder — Brazil
01_identity_and_parentage
02_criminal_records
03_form_and_declarations
04_entry_into_brazil
05_fees_and_receipts
06_protocols_and_receipts''',
    );
  }

  DateTime _nextReminderBusinessDay(DateTime date) {
    var result = DateTime(date.year, date.month, date.day, 10);
    while (result.weekday == DateTime.saturday ||
        result.weekday == DateTime.sunday) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  Widget _buildCalendarPrompt({
    required MigrationPlan plan,
    required GuideEventSuggestion suggestion,
  }) {
    return FutureBuilder<GuideEventSuggestionPreference>(
      future: _eventSuggestionStore.readPreference(
        plan: plan,
        suggestionId: suggestion.id,
      ),
      builder: (context, snapshot) {
        final preference = snapshot.data;
        if (preference == null) {
          return const SizedBox.shrink();
        }
        if (preference.isAdded) {
          return _GuideCalendarScheduledCard(title: suggestion.title);
        }
        if (preference.isSkipped ||
            !preference.shouldAutoPrompt(DateTime.now())) {
          return const SizedBox.shrink();
        }
        return _GuideCalendarSuggestionCard(
          suggestion: suggestion,
          actionLabel: _localizedText(
            context,
            pt: 'Escolher data e lembrete',
            es: 'Elegir fecha y recordatorio',
            en: 'Choose date and reminder',
          ),
          onTap: () =>
              _showCalendarSuggestionSheet(plan: plan, suggestion: suggestion),
        );
      },
    );
  }

  Future<void> _showCalendarSuggestionSheet({
    required MigrationPlan plan,
    required GuideEventSuggestion suggestion,
  }) async {
    if (_isPresentingCalendarAssistant) {
      return;
    }
    _isPresentingCalendarAssistant = true;
    if (!context.mounted) {
      _isPresentingCalendarAssistant = false;
      return;
    }
    final sheetContext = context;

    final result = await showGuideEventSuggestionSheet(
      sheetContext,
      suggestion: suggestion,
      onAddToCalendar: (updatedSuggestion, reminderOption, notes) {
        return _calendarEventService.addEvent(
          suggestion: updatedSuggestion,
          reminderOption: reminderOption,
          notes: notes,
        );
      },
    );
    if (!mounted) {
      _isPresentingCalendarAssistant = false;
      return;
    }

    if (result != null) {
      final messenger = ScaffoldMessenger.of(context);
      final addedMessage = _localizedText(
        context,
        pt: 'Evento pronto no seu calendário.',
        es: 'Evento listo en tu calendario.',
        en: 'Event added to your calendar.',
      );
      final laterMessage = _localizedText(
        context,
        pt: 'Vamos lembrar você mais tarde.',
        es: 'Te lo recordaremos más tarde.',
        en: 'We will remind you later.',
      );
      switch (result.action) {
        case GuideEventSuggestionAction.added:
          await _eventSuggestionStore.markAdded(
            plan: plan,
            suggestionId: suggestion.id,
          );
          messenger.showSnackBar(SnackBar(content: Text(addedMessage)));
        case GuideEventSuggestionAction.later:
          await _eventSuggestionStore.remindLater(
            plan: plan,
            suggestionId: suggestion.id,
          );
          messenger.showSnackBar(SnackBar(content: Text(laterMessage)));
        case GuideEventSuggestionAction.skipped:
          await _eventSuggestionStore.markSkipped(
            plan: plan,
            suggestionId: suggestion.id,
          );
      }
    }

    _isPresentingCalendarAssistant = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = widget.controller.generatedPlan;
    final city = plan?.confirmedCity;

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

    final hasConfirmedCity = city != null;
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
                            const PracticalInfoDisclaimer(compact: true),
                            const SizedBox(height: 16),
                            if (!hasConfirmedCity) ...[
                              JourneyStageBanner(
                                title: l10n.stageDecisionTitle,
                                body: l10n.stageDecisionBody,
                                action: l10n.stageDecisionAction,
                                icon: Icons.explore_rounded,
                                accent: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (!hasConfirmedCity) ...[
                              // Preview mode — full guide visible, execution locked.
                              // Confirm CTA activates execution mode in-place.
                              _GuidePreviewBanner(
                                cityName: city?.name ?? '',
                                totalItems: gpsController.totalItems,
                                onConfirm: city != null
                                    ? () => _confirmCity(city)
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              _GuideAllItemsList(
                                items: gpsController.items,
                                onSelectItem: (item) => _showExecutionPage(
                                  gpsController,
                                  item,
                                  plan,
                                  city,
                                  isPreview: true,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ] else ...[
                              _GuideUnifiedProgressBar(
                                controller: gpsController,
                              ),
                              const SizedBox(height: 16),
                              _GuideDominantActionCard(
                                item: gpsController.currentItem,
                                showCelebration: _showCelebration,
                                showExpandedContent: _showExpandedContent,
                                awaitingConfirmation:
                                    gpsController.awaitingConfirmation,
                                taskState: gpsController.currentTaskState,
                                cityName: city.name,
                                onPrimaryTap: (item) => _handleCurrentActionTap(
                                  gpsController,
                                  item,
                                  plan,
                                  city,
                                ),
                                onLinkTap: (url, label) =>
                                    _openExternalPreparationLink(
                                      title: label,
                                      uri: Uri.parse(url),
                                    ),
                                onChecklistToggle: (itemId, subItemId) async {
                                  await gpsController.toggleChecklistSubItem(
                                    itemId,
                                    subItemId,
                                  );
                                  setState(() {
                                    _syncFromGpsController(gpsController);
                                  });
                                  final current = gpsController.currentItem;
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
                                onPrioritizeToggle: (item) async {
                                  await gpsController.togglePrioritizeItem(
                                    item.id,
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    _syncFromGpsController(gpsController);
                                  });
                                },
                                onDismiss: (item, reason) async {
                                  final completedPhasesBefore =
                                      _completedGuidePhases(gpsController);
                                  await gpsController.dismissItem(
                                    item.id,
                                    reason,
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    _showExpandedContent = false;
                                    _syncFromGpsController(gpsController);
                                  });
                                  await _maybeShowPhaseCelebration(
                                    completedPhasesBefore:
                                        completedPhasesBefore,
                                    controller: gpsController,
                                  );
                                },
                                onRestoreDismissed: (item) async {
                                  await gpsController.restoreDismissedItem(
                                    item.id,
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    _syncFromGpsController(gpsController);
                                  });
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
    unawaited(
      GuideFlowMetricsStore.instance.record(GuideFlowMetric.fullPlanOpened),
    );
    final focus = controller.focusSnapshot;
    final pending = controller.items
        .where(
          (item) =>
              (!item.isCompleted ||
                  item.dismissReason == GuideDismissReason.later) &&
              item.dismissReason != GuideDismissReason.notApplicable &&
              !item.id.startsWith('questionnaire_'),
        )
        .toList(growable: false);

    List<GuideActionItem> scheduled(GuideExecutionWindow window) => pending
        .where(
          (item) =>
              item.resolvedExecutionWindow == window &&
              item.resolvedTier != GuideItemTier.optional,
        )
        .toList(growable: false);

    final groups =
        <
          ({
            String label,
            List<GuideActionItem> items,
            bool collapsed,
            int visibleCount,
          })
        >[
          (
            label: _localizedText(
              context,
              pt: 'Antes de viajar',
              es: 'Antes de viajar',
              en: 'Before travel',
            ),
            items: scheduled(GuideExecutionWindow.beforeTravel),
            collapsed: false,
            visibleCount: 5,
          ),
          (
            label: _localizedText(
              context,
              pt: 'No dia da chegada',
              es: 'El día de llegada',
              en: 'Arrival day',
            ),
            items: scheduled(GuideExecutionWindow.arrivalDay),
            collapsed: false,
            visibleCount: 4,
          ),
          (
            label: _localizedText(
              context,
              pt: 'Na primeira semana',
              es: 'En la primera semana',
              en: 'First week',
            ),
            items: scheduled(GuideExecutionWindow.firstWeek),
            collapsed: false,
            visibleCount: 5,
          ),
          (
            label: _localizedText(
              context,
              pt: 'No primeiro mês',
              es: 'En el primer mes',
              en: 'First month',
            ),
            items: scheduled(GuideExecutionWindow.firstMonth),
            collapsed: false,
            visibleCount: 5,
          ),
          (
            label: _localizedText(
              context,
              pt: 'Consolidação',
              es: 'Consolidación',
              en: 'Later consolidation',
            ),
            items: scheduled(GuideExecutionWindow.later),
            collapsed: true,
            visibleCount: 4,
          ),
          (
            label: _localizedText(
              context,
              pt: 'Se fizer sentido',
              es: 'Si tiene sentido',
              en: 'If it applies',
            ),
            items: pending
                .where((item) => item.resolvedTier == GuideItemTier.optional)
                .toList(growable: false),
            collapsed: true,
            visibleCount: 4,
          ),
          (
            label: _localizedText(
              context,
              pt: 'Concluídos',
              es: 'Completados',
              en: 'Completed',
            ),
            items: focus.completed,
            collapsed: true,
            visibleCount: 4,
          ),
        ];
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
                    _GuideUtilitySheetHeader(
                      title: _localizedText(
                        context,
                        pt: 'Plano completo',
                        es: 'Plan completo',
                        en: 'Full plan',
                      ),
                      onClose: () => Navigator.of(sheetContext).pop(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _localizedText(
                        context,
                        pt: 'O plano inteiro continua aqui, organizado pelo momento certo de agir.',
                        es: 'El plan completo sigue aquí, organizado por el momento adecuado para actuar.',
                        en: 'Your full plan remains here, organized by the right time to act.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final group in groups)
                      if (group.items.isNotEmpty) ...[
                        _GuidePlanGroup(
                          phaseLabel: group.label,
                          items: group.items,
                          completedIds: controller.allCompletedIds,
                          currentItemId: controller.currentItem?.id,
                          isUnlocked: controller.isItemUnlocked,
                          unmetDependencyTitles:
                              controller.unmetDependencyTitles,
                          visibleItemCount: group.visibleCount,
                          initiallyCollapsed: group.collapsed,
                          onBlockedItem: (item) {
                            unawaited(
                              GuideFlowMetricsStore.instance.record(
                                GuideFlowMetric.taskBlocked,
                                referenceId: item.id,
                              ),
                            );
                            final unmet = controller.unmetDependencyTitles(
                              item,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _unlockRequirementLabel(context, unmet),
                                ),
                              ),
                            );
                          },
                          onTapItem: (item) async {
                            Navigator.of(sheetContext).pop();
                            if (item.dismissReason ==
                                GuideDismissReason.later) {
                              await controller.restoreDismissedItem(item.id);
                            }
                            if (!item.isCompleted) {
                              await controller.jumpToItem(item.id);
                            }
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
      currentCityName: widget.controller.generatedPlan?.currentPlanCity?.name,
    );
    if (!mounted || choice == null) {
      return;
    }

    if (choice == PlanResetChoice.changeCityKeepProgress) {
      Navigator.pushNamed(context, AppRoutes.citiesSearch);
      return;
    }

    await widget.controller.clearCurrentPlan();
    if (!mounted) {
      return;
    }

    if (choice == PlanResetChoice.rebuild) {
      Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
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

class _GuideCalendarSuggestionCard extends StatelessWidget {
  const _GuideCalendarSuggestionCard({
    required this.suggestion,
    required this.onTap,
    this.actionLabel,
  });

  final GuideEventSuggestion suggestion;
  final VoidCallback onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final start = suggestion.startAt;
    final dateLabel =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}';
    final timeLabel = TimeOfDay.fromDateTime(start).format(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFF0FAF5),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: AppColors.success,
            lightColor: const Color(0xFFB9E5CF),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 18,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.assistantCopy,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryFor(context),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            suggestion.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateLabel • $timeLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.calendar_month_outlined, size: 16),
              label: Text(
                actionLabel ??
                    _localizedText(
                      context,
                      pt: 'Adicionar ao calendário',
                      es: 'Agregar al calendario',
                      en: 'Add to calendar',
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCalendarScheduledCard extends StatelessWidget {
  const _GuideCalendarScheduledCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedText(
                    context,
                    pt: 'Lembrete adicionado',
                    es: 'Recordatorio agregado',
                    en: 'Reminder added',
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusedTipPreviewBanner extends StatelessWidget {
  const _FocusedTipPreviewBanner({
    required this.item,
    required this.currentPriorityItem,
  });

  final GuideActionItem item;
  final GuideActionItem? currentPriorityItem;

  @override
  Widget build(BuildContext context) {
    final sameAsCurrent = currentPriorityItem?.id == item.id;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.visibility_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sameAsCurrent
                  ? _localizedText(
                      context,
                      pt: 'Você abriu esta etapa a partir de uma dica da home. Seu fluxo continua igual.',
                      es: 'Abriste esta etapa desde una sugerencia de la home. Tu flujo sigue igual.',
                      en: 'You opened this step from a home tip. Your flow stays the same.',
                    )
                  : _localizedText(
                      context,
                      pt: 'Você está vendo uma dica relacionada. Seu passo principal continua em "${currentPriorityItem?.title ?? item.title}".',
                      es: 'Estas viendo una sugerencia relacionada. Tu paso principal sigue en "${currentPriorityItem?.title ?? item.title}".',
                      en: 'You are viewing a related tip. Your main step remains "${currentPriorityItem?.title ?? item.title}".',
                    ),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanStageScreen extends StatefulWidget {
  const _PlanStageScreen({
    required this.section,
    required this.plan,
    required this.city,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.locationController,
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
  final LocationController locationController;
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
          locationController: widget.locationController,
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
      locationController: widget.locationController,
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
  required LocationController locationController,
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
                  _GuideUtilitySheetHeader(
                    title: _localizedText(
                      context,
                      pt: 'Ferramentas',
                      es: 'Herramientas',
                      en: 'Tools',
                    ),
                    onClose: () => Navigator.of(sheetContext).pop(),
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
                    title: context.l10n.flightPlannerTitle(),
                    body: _localizedText(
                      context,
                      pt: 'Escolha a data e veja opcoes de voo para ${city?.name ?? "sua cidade"}.',
                      es: 'Elegi la fecha y mira opciones de vuelo para ${city?.name ?? "tu ciudad"}.',
                      en: 'Choose a date and see flight options to ${city?.name ?? "your city"}.',
                    ),
                    onTap: () {
                      final originCountryIso =
                          FlightRouteContextResolver.resolveOriginCountryIso(
                            savedCountryCode:
                                locationController.savedLocation?.countryCode,
                            planOriginCountry: plan.originCountry,
                          );
                      final destinationCountryIso =
                          FlightRouteContextResolver.resolveDestinationCountryIso(
                            cityCountryCode: city?.countryCode,
                            planDestinationCountry: plan.destinationCountry,
                          );
                      Navigator.of(sheetContext).pop();
                      _showPreparationSheet(
                        context,
                        title: context.l10n.flightPlannerTitle(),
                        child: FlightSearchTool(
                          locationController: locationController,
                          originCountryIso: originCountryIso,
                          destinationCountryIso: destinationCountryIso,
                          destinationCityName: city?.name,
                          destinationLatitude: city?.latitude,
                          destinationLongitude: city?.longitude,
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
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/plan/tool'),
      builder: (pageContext) {
        return Scaffold(
          backgroundColor: AppColors.backgroundFor(pageContext),
          body: Stack(
            children: [
              const Positioned.fill(child: AmbientBackground()),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        pageContext.isMobileLayout ? 16 : 24,
                        8,
                        pageContext.isMobileLayout ? 16 : 24,
                        16,
                      ),
                      child: Column(
                        children: [
                          _GuidePageHeader(
                            title: title,
                            onBack: () => Navigator.of(pageContext).pop(),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: child,
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
      },
    ),
  );
}

class _GuidePageHeader extends StatelessWidget {
  const _GuidePageHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideResourceChoiceCard extends StatelessWidget {
  const _GuideResourceChoiceCard({required this.link, required this.onTap});

  final GuideSupportLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceFor(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  link.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
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
                  pt: 'Minha Jornada',
                  es: 'Mi Camino',
                  en: '    My Journey',
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

// ─── Guide preview mode widgets ───────────────────────────────────────────────

/// Sticky banner shown when the guide is in preview (city not yet confirmed).
/// Communicates the mode clearly and offers a direct confirm CTA.
class _GuidePreviewBanner extends StatelessWidget {
  const _GuidePreviewBanner({
    required this.cityName,
    required this.totalItems,
    required this.onConfirm,
  });

  final String cityName;
  final int totalItems;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final accentColor = AppColors.primary;
    final locale = Localizations.localeOf(context).languageCode;

    final title = switch (locale) {
      'pt' =>
        cityName.isNotEmpty
            ? 'Visualizando o plano para $cityName'
            : 'Visualizando o plano de migração',
      'es' =>
        cityName.isNotEmpty
            ? 'Visualizando el plan para $cityName'
            : 'Visualizando el plan de migración',
      _ =>
        cityName.isNotEmpty
            ? 'Previewing the plan for $cityName'
            : 'Previewing your migration plan',
    };
    final body = switch (locale) {
      'pt' =>
        'Explore os $totalItems passos antes de confirmar. Nenhuma ação será executada no modo de visualização.',
      'es' =>
        'Explora los $totalItems pasos antes de confirmar. Ninguna acción se ejecutará en modo vista previa.',
      _ =>
        'Explore all $totalItems steps before committing. No actions will run in preview mode.',
    };
    final ctaLabel = switch (locale) {
      'pt' => cityName.isNotEmpty ? 'Confirmar $cityName' : 'Confirmar cidade',
      'es' => cityName.isNotEmpty ? 'Confirmar $cityName' : 'Confirmar ciudad',
      _ => cityName.isNotEmpty ? 'Confirm $cityName' : 'Confirm city',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.30 : 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.preview_rounded,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 3),
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
          if (onConfirm != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_circle_rounded, size: 17),
                label: Text(
                  ctaLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Groups all guide items by phase and renders them as tappable rows.
/// Used when the guide is in preview mode (city not yet confirmed).
class _GuideAllItemsList extends StatelessWidget {
  const _GuideAllItemsList({required this.items, required this.onSelectItem});

  final List<GuideActionItem> items;
  final void Function(GuideActionItem item) onSelectItem;

  // Phase accent colors — matches _GuidePreviewSection in result page.
  static const _phaseColor = {
    GuidePhase.preparation: Color(0xFF4F46E5),
    GuidePhase.housing: Color(0xFF0891B2),
    GuidePhase.documents: Color(0xFF2563EB),
    GuidePhase.work: Color(0xFF16A34A),
    GuidePhase.arrival: Color(0xFFEA580C),
  };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Group items by phase while preserving phase order.
    final Map<GuidePhase, List<GuideActionItem>> grouped = {};
    for (final phase in GuidePhase.values) {
      final phaseItems = items.where((i) => i.phase == phase).toList();
      if (phaseItems.isNotEmpty) grouped[phase] = phaseItems;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.expand<Widget>((entry) {
        final phase = entry.key;
        final phaseItems = entry.value;
        final color = _phaseColor[phase] ?? AppColors.primary;
        final phaseLabel = _phaseLabel(context, phase);

        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  phaseLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${phaseItems.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          ...phaseItems.indexed.map((entry) {
            final (index, item) = entry;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < phaseItems.length - 1 ? 6 : 16,
              ),
              child: _PreviewItemTile(
                item: item,
                phaseColor: color,
                onTap: () => onSelectItem(item),
              ),
            );
          }),
        ];
      }).toList(),
    );
  }

  String _phaseLabel(BuildContext context, GuidePhase phase) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (phase) {
      GuidePhase.preparation => switch (locale) {
        'pt' => 'Preparação',
        'es' => 'Preparación',
        _ => 'Preparation',
      },
      GuidePhase.housing => switch (locale) {
        'pt' => 'Moradia',
        'es' => 'Vivienda',
        _ => 'Housing',
      },
      GuidePhase.documents => switch (locale) {
        'pt' => 'Documentos',
        'es' => 'Documentos',
        _ => 'Documents',
      },
      GuidePhase.work => switch (locale) {
        'pt' => 'Trabalho',
        'es' => 'Trabajo',
        _ => 'Work',
      },
      GuidePhase.arrival => switch (locale) {
        'pt' => 'Chegada',
        'es' => 'Llegada',
        _ => 'Arrival',
      },
    };
  }
}

/// Compact tappable row for a single guide item in the preview list.
class _PreviewItemTile extends StatelessWidget {
  const _PreviewItemTile({
    required this.item,
    required this.phaseColor,
    required this.onTap,
  });

  final GuideActionItem item;
  final Color phaseColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              // Phase dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: isDark ? 0.80 : 0.70),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              // Icon (if present)
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: AppColors.textSoftFor(context),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Pre-arrival badge
              if (item.preArrivalRequired) ...[
                Icon(
                  Icons.flight_takeoff_rounded,
                  size: 13,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textSoftFor(context),
              ),
            ],
          ),
        ),
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
                      pt: 'Minha Jornada',
                      es: 'Mi Camino',
                      en: 'My Journey',
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

class _GuideUnifiedProgressBar extends StatelessWidget {
  const _GuideUnifiedProgressBar({required this.controller});

  final GuideGpsController controller;

  @override
  Widget build(BuildContext context) {
    final focus = controller.focusSnapshot;
    return FrostedPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _localizedText(
                    context,
                    pt: 'Prioridades essenciais',
                    es: 'Prioridades esenciales',
                    en: 'Essential priorities',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (focus.pendingBeforeTravelCount > 0)
                Text(
                  _localizedText(
                    context,
                    pt: '${focus.pendingBeforeTravelCount} antes da viagem',
                    es: '${focus.pendingBeforeTravelCount} antes del viaje',
                    en: '${focus.pendingBeforeTravelCount} before travel',
                  ),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
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
                '${controller.completedCount} ${_localizedText(context, pt: 'resolvidas', es: 'resueltas', en: 'resolved')}',
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
    required this.awaitingConfirmation,
    required this.taskState,
    required this.onPrimaryTap,
    required this.onChecklistToggle,
    required this.onPrioritizeToggle,
    required this.onDismiss,
    required this.onRestoreDismissed,
    required this.onLinkTap,
    this.cityName = '',
  });

  final GuideActionItem? item;
  final bool showCelebration;
  final bool showExpandedContent;
  final bool awaitingConfirmation;
  final GuideTaskState taskState;
  final Future<void> Function(GuideActionItem item) onPrimaryTap;
  final Future<void> Function(String itemId, String subItemId)
  onChecklistToggle;
  final Future<void> Function(GuideActionItem item) onPrioritizeToggle;
  final Future<void> Function(GuideActionItem item, GuideDismissReason reason)
  onDismiss;
  final Future<void> Function(GuideActionItem item) onRestoreDismissed;
  final void Function(String url, String label) onLinkTap;

  /// Name of the confirmed destination city — used in the completion share text.
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final Widget cardChild = item == null
        ? FrostedPanel(
            key: const ValueKey<String>('guide-item-completed'),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 28,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.copilotPlanCompletedTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.copilotPlanCompletedBody,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      final locale = Localizations.localeOf(
                        context,
                      ).languageCode;
                      final city = cityName.isNotEmpty
                          ? cityName
                          : _localizedText(
                              context,
                              pt: 'minha nova cidade',
                              es: 'mi nueva ciudad',
                              en: 'my new city',
                            );
                      final text = switch (locale) {
                        'pt' =>
                          'Completei todos os passos do meu plano de migração para $city com o Movaro! 🇧🇷🏆',
                        'es' =>
                          '¡Completé todos los pasos de mi plan de migración a $city con Movaro! 🇧🇷🏆',
                        _ =>
                          'I completed all steps of my migration plan to $city with Movaro! 🇧🇷🏆',
                      };
                      unawaited(
                        SharePlus.instance.share(ShareParams(text: text)),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(
                      _localizedText(
                        context,
                        pt: 'Compartilhar conquista',
                        es: 'Compartir logro',
                        en: 'Share achievement',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : FrostedPanel(
            key: ValueKey<String>('guide-item-${item!.id}-$showCelebration'),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GuideActionTag(item: item!),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GuideMetaChip(
                      label: _guideTierLabel(context, item!.resolvedTier),
                    ),
                    _GuideMetaChip(
                      label: _guidePhaseShortName(context, item!.phase),
                    ),
                    if (taskState != GuideTaskState.notStarted)
                      _GuideMetaChip(
                        label: switch (taskState) {
                          GuideTaskState.inProgress => _localizedText(
                            context,
                            pt: 'Em andamento',
                            es: 'En progreso',
                            en: 'In progress',
                          ),
                          GuideTaskState.waiting => _localizedText(
                            context,
                            pt: 'Aguardando resposta',
                            es: 'Esperando respuesta',
                            en: 'Waiting for response',
                          ),
                          GuideTaskState.completed => _localizedText(
                            context,
                            pt: 'Concluído',
                            es: 'Completado',
                            en: 'Completed',
                          ),
                          GuideTaskState.notStarted => '',
                        },
                      ),
                    if (item!.estimatedTimeLabel != null)
                      _GuideMetaChip(label: item!.estimatedTimeLabel!),
                    if (item!.estimatedEffort != null)
                      _GuideMetaChip(
                        label: _guideEffortLabel(
                          context,
                          item!.estimatedEffort!,
                        ),
                      ),
                    if (item!.preArrivalRequired)
                      _GuideUrgencyChip(
                        label: _localizedText(
                          context,
                          pt: '✈ Antes de viajar',
                          es: '✈ Antes de viajar',
                          en: '✈ Before traveling',
                        ),
                        color: const Color(0xFF3B7CC8),
                      ),
                    if (item!.urgencyLevel != null &&
                        item!.urgencyLevel != GuideUrgencyLevel.normal)
                      _GuideUrgencyChip(
                        label: _urgencyLabel(context, item!.urgencyLevel!),
                        color: _urgencyTextColor(context, item!.urgencyLevel),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item!.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item!.summaryText,
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
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: item!.isDismissed
                        ? null
                        : () => onPrimaryTap(item!),
                    child: Text(
                      taskState == GuideTaskState.waiting
                          ? _localizedText(
                              context,
                              pt: 'Retomar etapa',
                              es: 'Retomar etapa',
                              en: 'Resume step',
                            )
                          : _guideButtonLabel(
                              context,
                              item!,
                              showExpandedContent,
                              awaitingConfirmation: awaitingConfirmation,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!item!.isDismissed &&
                        item!.resolvedTier != GuideItemTier.critical)
                      OutlinedButton.icon(
                        onPressed: () => onPrioritizeToggle(item!),
                        icon: Icon(
                          item!.isUserPrioritized
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 18,
                        ),
                        label: Text(
                          item!.isUserPrioritized
                              ? _localizedText(
                                  context,
                                  pt: 'Priorizado',
                                  es: 'Priorizado',
                                  en: 'Prioritized',
                                )
                              : _localizedText(
                                  context,
                                  pt: 'Priorizar',
                                  es: 'Priorizar',
                                  en: 'Prioritize',
                                ),
                        ),
                      ),
                    if (item!.isDismissed)
                      OutlinedButton.icon(
                        onPressed: () => onRestoreDismissed(item!),
                        icon: const Icon(Icons.undo_rounded, size: 18),
                        label: Text(
                          _localizedText(
                            context,
                            pt: 'Restaurar etapa',
                            es: 'Restaurar paso',
                            en: 'Restore step',
                          ),
                        ),
                      )
                    else if (item!.isDismissible)
                      PopupMenuButton<GuideDismissReason>(
                        tooltip: _localizedText(
                          context,
                          pt: 'Dispensar etapa',
                          es: 'Descartar paso',
                          en: 'Dismiss step',
                        ),
                        onSelected: (reason) => onDismiss(item!, reason),
                        itemBuilder: (context) => [
                          for (final reason in GuideDismissReason.values)
                            PopupMenuItem<GuideDismissReason>(
                              value: reason,
                              child: Text(_dismissReasonLabel(context, reason)),
                            ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.borderFor(context),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.more_horiz_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _localizedText(
                                  context,
                                  pt: 'Dispensar',
                                  es: 'Descartar',
                                  en: 'Dismiss',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (item!.isDismissed) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      _localizedText(
                        context,
                        pt: 'Etapa dispensada: ${_dismissReasonLabel(context, item!.dismissReason!)}',
                        es: 'Paso descartado: ${_dismissReasonLabel(context, item!.dismissReason!)}',
                        en: 'Dismissed step: ${_dismissReasonLabel(context, item!.dismissReason!)}',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (item!.whyItMatters != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localizedText(
                            context,
                            pt: 'Por que isso importa',
                            es: 'Por qué importa',
                            en: 'Why this matters',
                          ),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item!.whyItMatters!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimaryFor(context),
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
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
                        context.l10n.copilotNextActionUnlocked,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          final children = <Widget>[...previousChildren];
          if (currentChild != null) {
            children.add(currentChild);
          }
          return Stack(alignment: Alignment.topCenter, children: children);
        },
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved);
          return ClipRect(
            child: SizeTransition(
              sizeFactor: curved,
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(position: offsetAnimation, child: child),
              ),
            ),
          );
        },
        child: cardChild,
      ),
    );
  }
}

class _GuideActionTag extends StatelessWidget {
  const _GuideActionTag({required this.item});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (item.resolvedPrimaryActionType) {
      GuidePrimaryActionType.external => AppColors.primary,
      GuidePrimaryActionType.tool => AppColors.warning,
      GuidePrimaryActionType.checklist => AppColors.success,
      GuidePrimaryActionType.none => AppColors.primary,
    };

    final scheduledLabel = switch (item.resolvedExecutionWindow) {
      GuideExecutionWindow.arrivalDay => _localizedText(
        context,
        pt: 'NO DIA DA CHEGADA',
        es: 'EL DÍA DE LLEGADA',
        en: 'ARRIVAL DAY',
      ),
      GuideExecutionWindow.firstWeek => _localizedText(
        context,
        pt: 'NA PRIMEIRA SEMANA',
        es: 'EN LA PRIMERA SEMANA',
        en: 'FIRST WEEK',
      ),
      GuideExecutionWindow.firstMonth => _localizedText(
        context,
        pt: 'NO PRIMEIRO MÊS',
        es: 'EN EL PRIMER MES',
        en: 'FIRST MONTH',
      ),
      GuideExecutionWindow.later => _localizedText(
        context,
        pt: 'MAIS ADIANTE',
        es: 'MÁS ADELANTE',
        en: 'LATER',
      ),
      GuideExecutionWindow.beforeTravel => null,
    };
    final label =
        scheduledLabel ??
        switch (item.resolvedPrimaryActionType) {
          GuidePrimaryActionType.external => _localizedText(
            context,
            pt: 'AÇÃO RECOMENDADA',
            es: 'ACCION RECOMENDADA',
            en: 'RECOMMENDED ACTION',
          ),
          GuidePrimaryActionType.tool => _localizedText(
            context,
            pt: 'FAÇA AGORA',
            es: 'HAZLO AHORA',
            en: 'DO THIS NOW',
          ),
          GuidePrimaryActionType.checklist => _localizedText(
            context,
            pt: 'RESOLVA AGORA',
            es: 'RESUELVELO AHORA',
            en: 'RESOLVE NOW',
          ),
          GuidePrimaryActionType.none =>
            item.hasDecisionOptions
                ? _localizedText(
                    context,
                    pt: 'DECISÃO IMPORTANTE',
                    es: 'DECISION IMPORTANTE',
                    en: 'IMPORTANT DECISION',
                  )
                : _localizedText(
                    context,
                    pt: 'PRÓXIMO PASSO',
                    es: 'SIGUIENTE PASO',
                    en: 'NEXT STEP',
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

class _GuideMetaChip extends StatelessWidget {
  const _GuideMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSoftFor(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GuideUtilitySheetHeader extends StatelessWidget {
  const _GuideUtilitySheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderFor(context),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuideTaskGuidanceSection extends StatelessWidget {
  const _GuideTaskGuidanceSection({
    required this.icon,
    required this.title,
    required this.body,
    this.number,
    this.tone = AppColors.primary,
  });

  final int? number;
  final IconData icon;
  final String title;
  final String body;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: tone,
          lightColor: tone.withValues(alpha: 0.06),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: tone,
            lightColor: tone.withValues(alpha: 0.20),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: number == null
                ? Icon(icon, color: tone, size: 19)
                : Text(
                    '$number',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: tone, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
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

class _GuideTaskPageHeader extends StatelessWidget {
  const _GuideTaskPageHeader({
    required this.item,
    required this.overallProgress,
    required this.completedChecklistItems,
    required this.totalChecklistItems,
    required this.isPreview,
    required this.onClose,
    required this.onHelp,
    required this.onPrioritize,
    required this.onRestore,
    required this.onDismiss,
  });

  final GuideActionItem item;
  final double overallProgress;
  final int completedChecklistItems;
  final int totalChecklistItems;
  final bool isPreview;
  final VoidCallback onClose;
  final VoidCallback onHelp;
  final Future<void> Function() onPrioritize;
  final Future<void> Function() onRestore;
  final Future<void> Function(GuideDismissReason reason) onDismiss;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (overallProgress * 100).round();
    final hasMenu =
        !isPreview &&
        (item.isDismissed ||
            item.isDismissible ||
            item.resolvedTier != GuideItemTier.critical);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClose,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                item.icon ?? Icons.route_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedText(
                      context,
                      pt: 'ETAPA DO PLANO',
                      es: 'ETAPA DEL PLAN',
                      en: 'PLAN STEP',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _guidePhaseShortName(context, item.phase),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onHelp,
              tooltip: _localizedText(
                context,
                pt: 'Como executar esta etapa',
                es: 'Cómo ejecutar esta etapa',
                en: 'How to complete this step',
              ),
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(Icons.help_outline_rounded),
            ),
            if (hasMenu)
              PopupMenuButton<Object>(
                tooltip: _localizedText(
                  context,
                  pt: 'Opções da etapa',
                  es: 'Opciones de la etapa',
                  en: 'Step options',
                ),
                icon: const Icon(Icons.more_horiz_rounded),
                constraints: const BoxConstraints(minWidth: 220),
                onSelected: (value) {
                  if (value == 'prioritize') {
                    unawaited(onPrioritize());
                  } else if (value == 'restore') {
                    unawaited(onRestore());
                  } else if (value is GuideDismissReason) {
                    unawaited(onDismiss(value));
                  }
                },
                itemBuilder: (context) => [
                  if (item.isDismissed)
                    PopupMenuItem<Object>(
                      value: 'restore',
                      child: _GuideMenuRow(
                        icon: Icons.undo_rounded,
                        label: _localizedText(
                          context,
                          pt: 'Restaurar etapa',
                          es: 'Restaurar etapa',
                          en: 'Restore step',
                        ),
                      ),
                    )
                  else ...[
                    if (item.resolvedTier != GuideItemTier.critical)
                      PopupMenuItem<Object>(
                        value: 'prioritize',
                        child: _GuideMenuRow(
                          icon: item.isUserPrioritized
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          label: item.isUserPrioritized
                              ? _localizedText(
                                  context,
                                  pt: 'Remover prioridade',
                                  es: 'Quitar prioridad',
                                  en: 'Remove priority',
                                )
                              : _localizedText(
                                  context,
                                  pt: 'Priorizar esta etapa',
                                  es: 'Priorizar esta etapa',
                                  en: 'Prioritize this step',
                                ),
                        ),
                      ),
                    if (item.isDismissible)
                      for (final reason in GuideDismissReason.values)
                        PopupMenuItem<Object>(
                          value: reason,
                          child: _GuideMenuRow(
                            icon: reason == GuideDismissReason.later
                                ? Icons.schedule_rounded
                                : reason == GuideDismissReason.alreadyDone
                                ? Icons.check_circle_outline_rounded
                                : Icons.remove_circle_outline_rounded,
                            label: _dismissReasonLabel(context, reason),
                          ),
                        ),
                  ],
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.summaryText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _GuideMetaChip(label: _guideTierLabel(context, item.resolvedTier)),
            if (item.estimatedTimeLabel != null)
              _GuideMetaChip(label: item.estimatedTimeLabel!)
            else if (item.estimatedEffort != null)
              _GuideMetaChip(
                label: _guideEffortLabel(context, item.estimatedEffort!),
              ),
            if (item.preArrivalRequired)
              _GuideMetaChip(
                label: _localizedText(
                  context,
                  pt: 'Antes de viajar',
                  es: 'Antes de viajar',
                  en: 'Before travel',
                ),
              ),
            if (totalChecklistItems > 0)
              _GuideMetaChip(
                label: '$completedChecklistItems/$totalChecklistItems',
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: _localizedText(
            context,
            pt: '$progressPercent por cento do plano essencial concluído',
            es: '$progressPercent por ciento del plan esencial completado',
            en: '$progressPercent percent of the essential plan complete',
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: overallProgress,
              backgroundColor: AppColors.surfaceMutedFor(context),
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideMenuRow extends StatelessWidget {
  const _GuideMenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _GuideNextMoveCard extends StatelessWidget {
  const _GuideNextMoveCard({
    required this.actionType,
    required this.actionLabel,
    required this.actionOpened,
    required this.onPressed,
    this.description,
  });

  final GuidePrimaryActionType actionType;
  final String actionLabel;
  final bool actionOpened;
  final Future<void> Function() onPressed;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final isTool = actionType == GuidePrimaryActionType.tool;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: const Color(0xFFF2F7FF),
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFCFE2FF),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'SEU PRÓXIMO MOVIMENTO',
              es: 'TU PRÓXIMO MOVIMIENTO',
              en: 'YOUR NEXT MOVE',
            ),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description ??
                (isTool
                    ? _localizedText(
                        context,
                        pt: 'Use a ferramenta com seus dados. O plano continua salvo aqui.',
                        es: 'Usa la herramienta con tus datos. El plan seguirá guardado aquí.',
                        en: 'Use the tool with your details. Your plan stays saved here.',
                      )
                    : _localizedText(
                        context,
                        pt: 'Abra a fonte indicada, execute a ação e volte para confirmar.',
                        es: 'Abre la fuente indicada, realiza la acción y vuelve para confirmar.',
                        en: 'Open the indicated source, take action, and return to confirm.',
                      )),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(
                actionOpened
                    ? Icons.refresh_rounded
                    : isTool
                    ? Icons.tune_rounded
                    : Icons.open_in_new_rounded,
                size: 18,
              ),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideOutcomeProgress extends StatelessWidget {
  const _GuideOutcomeProgress({
    super.key,
    required this.items,
    required this.enabled,
    required this.onToggle,
  });

  final List<ChecklistSubItem> items;
  final bool enabled;
  final Future<void> Function(ChecklistSubItem item) onToggle;

  @override
  Widget build(BuildContext context) {
    final completed = items.where((item) => item.isCompleted).toList();
    final pending = items.where((item) => !item.isCompleted).toList();
    final current = pending.isEmpty ? null : pending.first;
    final upcoming = pending.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (completed.isNotEmpty) ...[
          for (final item in completed)
            Semantics(
              button: enabled,
              checked: true,
              child: InkWell(
                onTap: enabled ? () => onToggle(item) : null,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 22,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSoftFor(context),
                                decoration: TextDecoration.lineThrough,
                              ),
                        ),
                      ),
                      if (enabled)
                        Icon(
                          Icons.undo_rounded,
                          size: 17,
                          color: AppColors.textSoftFor(context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (current != null) const SizedBox(height: 8),
        ],
        if (current != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tintedSurfaceFor(
                context,
                tint: AppColors.primary,
                lightColor: const Color(0xFFF2F7FF),
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.tintedBorderFor(
                  context,
                  tint: AppColors.primary,
                  lightColor: const Color(0xFFCFE2FF),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedText(context, pt: 'AGORA', es: 'AHORA', en: 'NOW'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  current.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => onToggle(current),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        _localizedText(
                          context,
                          pt: 'Confirmar que fiz',
                          es: 'Confirmar que lo hice',
                          en: 'Confirm I did this',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _localizedText(
                      context,
                      pt: 'Tudo confirmado. Esta etapa está pronta.',
                      es: 'Todo confirmado. Esta etapa está lista.',
                      en: 'Everything is confirmed. This step is ready.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            _localizedText(context, pt: 'Depois', es: 'Después', en: 'Next'),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (var index = 0; index < upcoming.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceFor(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderFor(context)),
                    ),
                    child: Text(
                      '${completed.length + index + 2}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      upcoming[index].title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.35,
                      ),
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

class _GuideTaskFooter extends StatelessWidget {
  const _GuideTaskFooter({
    required this.primaryLabel,
    required this.primaryEnabled,
    required this.onPrimary,
    this.helperText,
    this.onWaiting,
  });

  final String primaryLabel;
  final bool primaryEnabled;
  final Future<void> Function() onPrimary;
  final String? helperText;
  final Future<void> Function()? onWaiting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Column(
        children: [
          if (helperText != null) ...[
            Text(
              helperText!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 9),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: primaryEnabled ? onPrimary : null,
              icon: const Icon(Icons.check_rounded, size: 19),
              label: Text(primaryLabel),
            ),
          ),
          if (onWaiting != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onWaiting,
                icon: const Icon(Icons.hourglass_top_rounded, size: 18),
                label: Text(
                  _localizedText(
                    context,
                    pt: 'Pausar: estou aguardando retorno',
                    es: 'Pausar: estoy esperando respuesta',
                    en: 'Pause: I am waiting for a response',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuideWorkflowSection extends StatelessWidget {
  const _GuideWorkflowSection({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final int number;
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('guide-workflow-section-$number'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '$number',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GuideWorkflowMessage extends StatelessWidget {
  const _GuideWorkflowMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundFor(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }
}

class _GuideExpandableSection extends StatelessWidget {
  const _GuideExpandableSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          if (expanded) {
            unawaited(
              GuideFlowMetricsStore.instance.record(
                GuideFlowMetric.detailsExpanded,
              ),
            );
          }
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        initiallyExpanded: initiallyExpanded,
        children: [child],
      ),
    );
  }
}

class _GuideSupplementaryDetails extends StatelessWidget {
  const _GuideSupplementaryDetails({
    required this.item,
    required this.onLinkTap,
    this.quickReferenceShown = false,
  });

  final GuideActionItem item;
  final void Function(String url, String label) onLinkTap;
  final bool quickReferenceShown;

  bool get _hasContent =>
      item.costInfo != null ||
      item.estimatedTime != null ||
      item.evidence != null ||
      item.hasTips ||
      item.blockingReason != null ||
      item.hasSupportLinks ||
      item.hasCommunityTips ||
      (item.hasSurvivalPhrases && !quickReferenceShown);

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) {
      return const SizedBox.shrink();
    }

    final sections = <Widget>[
      if (item.costInfo != null || item.estimatedTime != null) ...[
        _heading(
          context,
          _localizedText(
            context,
            pt: 'Custo e tempo',
            es: 'Costo y tiempo',
            en: 'Cost and time',
          ),
        ),
        if (item.costInfo != null)
          _GuideDetailRow(
            label: _localizedText(
              context,
              pt: 'Custo',
              es: 'Costo',
              en: 'Cost',
            ),
            value: item.costInfo!,
          ),
        if (item.estimatedTime != null)
          _GuideDetailRow(
            label: _localizedText(
              context,
              pt: 'Tempo',
              es: 'Tiempo',
              en: 'Time',
            ),
            value: item.estimatedTime!,
          ),
      ],
      if (item.evidence != null) ...[
        _divider(context),
        _heading(
          context,
          _localizedText(
            context,
            pt: 'Fonte oficial',
            es: 'Fuente oficial',
            en: 'Official source',
          ),
        ),
        _GuideEvidenceCard(evidence: item.evidence!, onOpen: onLinkTap),
      ],
      if (item.hasTips ||
          item.blockingReason != null ||
          item.hasSupportLinks) ...[
        _divider(context),
        _heading(
          context,
          _localizedText(
            context,
            pt: 'Conselhos e alertas',
            es: 'Consejos y alertas',
            en: 'Tips and warnings',
          ),
        ),
        _GuideTipsContent(item: item, onLinkTap: onLinkTap),
      ],
      if (item.hasCommunityTips) ...[
        _divider(context),
        _heading(
          context,
          _localizedText(
            context,
            pt: 'Situações práticas',
            es: 'Situaciones prácticas',
            en: 'Practical situations',
          ),
        ),
        _GuideCommunityTipsContent(item: item),
      ],
      if (item.hasSurvivalPhrases && !quickReferenceShown) ...[
        _divider(context),
        _heading(
          context,
          _localizedText(
            context,
            pt: 'Como falar isso em português',
            es: 'Cómo decirlo en portugués',
            en: 'How to say it in Portuguese',
          ),
        ),
        _GuideSurvivalPhrasesContent(item: item),
      ],
    ];

    return _GuideExpandableSection(
      title: _localizedText(
        context,
        pt: 'Mais detalhes',
        es: 'Más detalles',
        en: 'More details',
      ),
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  Widget _heading(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: AppColors.borderFor(context)),
    );
  }
}

class _GuideEvidenceCard extends StatelessWidget {
  const _GuideEvidenceCard({required this.evidence, required this.onOpen});

  final GuideEvidence evidence;
  final void Function(String url, String label) onOpen;

  @override
  Widget build(BuildContext context) {
    final official = evidence.type == GuideEvidenceType.official;
    final freshness = SourceFreshnessPolicy.assessEvidence(evidence);
    final needsReview = freshness.requiresWarning;
    final color = needsReview
        ? AppColors.warning
        : official
        ? AppColors.success
        : AppColors.warning;
    final date = evidence.lastVerified;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    final typeLabel = switch (evidence.type) {
      GuideEvidenceType.official => _localizedText(
        context,
        pt: 'Fonte oficial',
        es: 'Fuente oficial',
        en: 'Official source',
      ),
      GuideEvidenceType.derived => _localizedText(
        context,
        pt: 'Dado derivado',
        es: 'Dato derivado',
        en: 'Derived data',
      ),
      GuideEvidenceType.marketReference => _localizedText(
        context,
        pt: 'Referência de mercado',
        es: 'Referencia de mercado',
        en: 'Market reference',
      ),
      GuideEvidenceType.movaroGuidance => _localizedText(
        context,
        pt: 'Orientação geral não oficial',
        es: 'Orientación general no oficial',
        en: 'General non-official guidance',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                official ? Icons.verified_rounded : Icons.analytics_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$typeLabel · $dateLabel',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            evidence.sourceLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (evidence.scopeNote != null) ...[
            const SizedBox(height: 4),
            Text(
              evidence.scopeNote!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          ],
          if (freshness.status != SourceFreshnessStatus.current) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  needsReview
                      ? Icons.warning_amber_rounded
                      : Icons.update_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    needsReview
                        ? _localizedText(
                            context,
                            pt: 'Esta informação passou da janela de revisão. Use-a apenas como orientação e confirme a regra vigente na fonte.',
                            es: 'Esta información superó la ventana de revisión. Usala solo como orientación y confirmá la regla vigente en la fuente.',
                            en: 'This information is past its review window. Use it only as orientation and confirm the current rule at the source.',
                          )
                        : _localizedText(
                            context,
                            pt: 'Revisão editorial próxima. Confirme a página original antes de agir.',
                            es: 'Revisión editorial próxima. Confirmá la página original antes de actuar.',
                            en: 'Editorial review is due soon. Confirm the original page before acting.',
                          ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => onOpen(evidence.sourceUrl, evidence.sourceLabel),
            icon: const Icon(Icons.open_in_new_rounded, size: 15),
            label: Text(
              _localizedText(
                context,
                pt: 'Confirmar na fonte',
                es: 'Confirmar en la fuente',
                en: 'Confirm at source',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideExecutionContent extends StatelessWidget {
  const _GuideExecutionContent({required this.item, required this.onLinkTap});

  final GuideActionItem item;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.hasSteps) ...[
          for (var index = 0; index < item.steps!.length; index++) ...[
            _GuideNumberedRow(number: index + 1, text: item.steps![index]),
            if (index < item.steps!.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (item.hasDecisionOptions) ...[
          if (item.hasSteps) const SizedBox(height: 14),
          // Surface the recommended path before the full comparison cards.
          if (item.decisionOptions!.any((o) => o.recommended)) ...[
            _GuideBestOptionBanner(
              item: item,
              option: item.decisionOptions!.firstWhere((o) => o.recommended),
              onLinkTap: onLinkTap,
            ),
            const SizedBox(height: 10),
          ],
          for (final option in item.decisionOptions!) ...[
            _GuideDecisionOptionCard(option: option),
            const SizedBox(height: 10),
          ],
        ],
        if (!item.hasSteps &&
            !item.hasDecisionOptions &&
            item.externalOfficialLinks != null)
          for (final link in item.externalOfficialLinks!)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => onLinkTap(link.url, link.label),
                child: Text(
                  link.label,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _CpfDecisionContent extends StatelessWidget {
  const _CpfDecisionContent({
    required this.item,
    required this.selectedIndex,
    required this.onSelected,
  });

  final GuideActionItem item;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(
            context,
            pt: 'Escolha um caminho. O Movaro mostra apenas as instruções dessa rota e você pode trocar quando quiser.',
            es: 'Elige un camino. Movaro muestra solo las instrucciones de esa ruta y puedes cambiar cuando quieras.',
            en: 'Choose one path. Movaro shows only that route’s instructions, and you can switch at any time.',
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < item.decisionOptions!.length; index++) ...[
          _CpfRouteChoiceCard(
            option: item.decisionOptions![index],
            selected: selectedIndex == index,
            onTap: () => onSelected(index),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CpfRouteChoiceCard extends StatelessWidget {
  const _CpfRouteChoiceCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final GuideDecisionOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.borderFor(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 22,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSoftFor(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (option.recommended)
                            _GuideMetaChip(
                              label: _localizedText(
                                context,
                                pt: 'Sugerida',
                                es: 'Sugerida',
                                en: 'Suggested',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        option.description,
                        maxLines: selected ? 4 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.4,
                        ),
                      ),
                      if (selected &&
                          (option.pros.isNotEmpty ||
                              option.cons.isNotEmpty)) ...[
                        const SizedBox(height: 9),
                        if (option.pros.isNotEmpty)
                          _CpfRouteSignal(
                            icon: Icons.add_circle_outline_rounded,
                            color: AppColors.success,
                            text: option.pros.first,
                          ),
                        if (option.cons.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _CpfRouteSignal(
                            icon: Icons.info_outline_rounded,
                            color: AppColors.warning,
                            text: option.cons.first,
                          ),
                        ],
                      ],
                    ],
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

class _CpfRouteSignal extends StatelessWidget {
  const _CpfRouteSignal({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _GuideExecutionBlock extends StatelessWidget {
  const _GuideExecutionBlock({required this.item, required this.onLinkTap});

  final GuideActionItem item;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'Execução agora',
              es: 'Ejecucion ahora',
              en: 'Execution now',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (
            var index = 0;
            index < item.locationAwareOptions!.length;
            index++
          ) ...[
            _GuideLocationOptionCard(
              option: item.locationAwareOptions![index],
              onLinkTap: onLinkTap,
            ),
            if (index < item.locationAwareOptions!.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CpfExecutionBlock extends StatelessWidget {
  const _CpfExecutionBlock({
    required this.item,
    required this.selectedIndex,
    required this.onLinkTap,
  });

  final GuideActionItem item;
  final int selectedIndex;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    final routes = item.locationAwareOptions!;
    final decisionCount = item.decisionOptions?.length ?? 0;
    final safeIndex = selectedIndex < 0
        ? 0
        : selectedIndex >= decisionCount
        ? decisionCount - 1
        : selectedIndex;
    final selectedRoutes = safeIndex == 0
        ? routes.take(routes.length - 1).toList(growable: false)
        : <GuideLocationAwareOption>[routes.last];
    final selectedDecision = decisionCount > safeIndex
        ? item.decisionOptions![safeIndex]
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText(
              context,
              pt: 'Abra a rota escolhida',
              es: 'Abre la ruta elegida',
              en: 'Open the chosen route',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            _localizedText(
              context,
              pt: 'Abra a fonte oficial da rota escolhida. As exigências da outra rota ficam ocultas para não misturar orientações.',
              es: 'Abre la fuente oficial de la ruta elegida. Los requisitos de la otra ruta quedan ocultos para no mezclar orientaciones.',
              en: 'Open the official source for your chosen route. The other route stays hidden so the guidance does not get mixed.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          if (selectedDecision != null) ...[
            const SizedBox(height: 10),
            _GuideMetaChip(
              label: _localizedText(
                context,
                pt: 'Rota ativa: ${selectedDecision.title}',
                es: 'Ruta activa: ${selectedDecision.title}',
                en: 'Active route: ${selectedDecision.title}',
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (var index = 0; index < selectedRoutes.length; index++) ...[
            _GuideLocationOptionCard(
              option: selectedRoutes[index],
              onLinkTap: onLinkTap,
            ),
            if (index < selectedRoutes.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _GuideLocationOptionCard extends StatelessWidget {
  const _GuideLocationOptionCard({
    required this.option,
    required this.onLinkTap,
  });

  final GuideLocationAwareOption option;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (option.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              option.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          ],
          if (option.address != null || option.distanceKm != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (option.address != null)
                  _GuideMetaChip(label: option.address!),
                if (option.distanceKm != null)
                  _GuideMetaChip(label: '${option.distanceKm} km'),
              ],
            ),
          ],
          if (option.mapUrl != null || option.officialUrl != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (option.mapUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => _openExternal(option.mapUrl!),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: Text(
                      _localizedText(
                        context,
                        pt: 'Abrir mapa',
                        es: 'Abrir mapa',
                        en: 'Open map',
                      ),
                    ),
                  ),
                if (option.officialUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => onLinkTap(
                      option.officialUrl!,
                      option.officialLabel ?? option.title,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(
                      option.officialLabel ??
                          _localizedText(
                            context,
                            pt: 'Link oficial',
                            es: 'Enlace oficial',
                            en: 'Official link',
                          ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class _GuideDetailRow extends StatelessWidget {
  const _GuideDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _GuideTipsContent extends StatelessWidget {
  const _GuideTipsContent({required this.item, required this.onLinkTap});

  final GuideActionItem item;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.blockingReason != null) ...[
          Text(
            item.blockingReason!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          if (item.hasTips || item.hasSupportLinks) const SizedBox(height: 12),
        ],
        if (item.hasTips) ...[
          for (var index = 0; index < item.tips!.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textSoftFor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.tips![index],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
            if (index < item.tips!.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (item.hasSupportLinks) ...[
          if (item.hasTips) const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final link in item.supportLinks!)
                OutlinedButton(
                  onPressed: () => onLinkTap(link.url, link.label),
                  child: Text(link.label),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GuideDoneCriteriaContent extends StatelessWidget {
  const _GuideDoneCriteriaContent({required this.item});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: Text(
        item.doneCriteria!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
      ),
    );
  }
}

// ─── Bank Intelligence: suggested-option banner ───────────────────────────────

class _GuideBestOptionBanner extends StatelessWidget {
  const _GuideBestOptionBanner({
    required this.item,
    required this.option,
    required this.onLinkTap,
  });

  final GuideActionItem item;
  final GuideDecisionOption option;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    final isCpf = item.id == 'item_2_1_cpf';
    final title = isCpf
        ? _localizedText(
            context,
            pt: 'Caminho que pode fazer mais sentido agora',
            es: 'Camino que puede tener mas sentido ahora',
            en: 'Path that may make more sense right now',
          )
        : _localizedText(
            context,
            pt: 'Opção que pode combinar com seu contexto',
            es: 'Opcion que puede encajar con tu contexto',
            en: 'Option that may fit your context',
          );
    final helper = isCpf
        ? _localizedText(
            context,
            pt: option.title.toLowerCase().contains('argentina')
                ? 'Pelo seu contexto atual, vale tentar resolver o CPF antes de embarcar.'
                : 'Pelo seu contexto atual, faz mais sentido deixar o CPF para os primeiros dias no Brasil.',
            es: option.title.toLowerCase().contains('argentina')
                ? 'Por tu contexto actual, vale la pena intentar resolver el CPF antes de viajar.'
                : 'Por tu contexto actual, tiene mas sentido dejar el CPF para los primeros dias en Brasil.',
            en: option.title.toLowerCase().contains('argentina')
                ? 'Given your current context, it is worth trying to solve CPF before you travel.'
                : 'Given your current context, it makes more sense to leave CPF for your first days in Brazil.',
          )
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Color(0xFF3B7CC8)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B7CC8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (helper != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    helper,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.35,
                    ),
                  ),
                ],
                if (option.helperLabel != null) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: option.helperUrl == null
                              ? null
                              : () => onLinkTap(
                                  option.helperUrl!,
                                  option.helperLabel!,
                                ),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    option.helperLabel!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: const Color(0xFF275D9D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                if (option.helperUrl != null) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 12,
                                    color: Color(0xFF275D9D),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isCpf && option.helperUrl != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onLinkTap(
                              PreparationResourceLinks.cpfInExterior.toString(),
                              _localizedText(
                                context,
                                pt: 'CPF no exterior',
                                es: 'CPF en el exterior',
                                en: 'CPF abroad',
                              ),
                            ),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.40),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _localizedText(
                                      context,
                                      pt: 'CPF no exterior',
                                      es: 'CPF en el exterior',
                                      en: 'CPF abroad',
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: const Color(0xFF275D9D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 12,
                                    color: Color(0xFF275D9D),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (option.pros.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    option.pros.take(2).map((p) => '✓ $p').join('  '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Practical scenarios content ─────────────────────────────────────────────

class _GuideCommunityTipsContent extends StatelessWidget {
  const _GuideCommunityTipsContent({required this.item});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tip in item.communityTips!) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_localizedText(context, pt: 'Cenário ilustrativo — não é depoimento: ', es: 'Escenario ilustrativo — no es testimonio: ', en: 'Illustrative scenario — not a testimonial: ')}${tip.replaceAll('"', '')}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ─── Survival Phrases content ─────────────────────────────────────────────────

class _GuideSurvivalPhrasesContent extends StatelessWidget {
  const _GuideSurvivalPhrasesContent({required this.item});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final phrase in item.survivalPhrases!) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${phrase.phrase}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),
                if (phrase.translation != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    phrase.translation!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _GuideDecisionOptionCard extends StatelessWidget {
  const _GuideDecisionOptionCard({required this.option});

  final GuideDecisionOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: option.recommended
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: option.recommended
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.borderFor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  option.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (option.recommended)
                _GuideMetaChip(
                  label: _localizedText(
                    context,
                    pt: 'Pode combinar com seu contexto',
                    es: 'Puede encajar con tu contexto',
                    en: 'May fit your context',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            option.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (option.pros.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _localizedText(
                context,
                pt: 'Vantagens',
                es: 'Ventajas',
                en: 'Pros',
              ),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            for (final pro in option.pros)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $pro'),
              ),
          ],
          if (option.cons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _localizedText(
                context,
                pt: 'Atenção',
                es: 'Atencion',
                en: 'Watch out',
              ),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            for (final con in option.cons)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $con'),
              ),
          ],
        ],
      ),
    );
  }
}

class _GuideNumberedRow extends StatelessWidget {
  const _GuideNumberedRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
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
            pt: 'DEPOIS DISSO',
            es: 'DESPUÉS DE ESTO',
            en: 'AFTER THIS',
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSoftFor(context),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < items.length; i++) ...[
          _UpcomingGuideItemTile(
            indexLabel: '${i + 2}',
            item: items[i],
            unlocked: controller.isItemUnlocked(items[i]),
            unmetDependencyTitles: controller.unmetDependencyTitles(items[i]),
            onTap: controller.isItemUnlocked(items[i])
                ? () => onSelectItem(items[i].id)
                : null,
          ),
          if (i != items.length - 1) const SizedBox(height: 8),
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
    required this.unmetDependencyTitles,
    required this.onTap,
  });

  final String indexLabel;
  final GuideActionItem item;
  final bool unlocked;
  final List<String> unmetDependencyTitles;
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
                if (item.icon != null) ...[
                  Icon(
                    unlocked ? item.icon : Icons.lock_outline_rounded,
                    size: 18,
                    color: unlocked
                        ? AppColors.primary
                        : AppColors.textSoftFor(context),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  Text(
                    indexLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!unlocked && unmetDependencyTitles.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          _unlockRequirementLabel(
                            context,
                            unmetDependencyTitles,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSoftFor(context),
                                height: 1.3,
                              ),
                        ),
                      ],
                    ],
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
                  '$totalItems ${_localizedText(context, pt: 'marcos', es: 'hitos', en: 'milestones')}',
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

class _GuideUrgencyChip extends StatelessWidget {
  const _GuideUrgencyChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _GuideItemSubtitle extends StatelessWidget {
  const _GuideItemSubtitle({required this.item, required BuildContext context});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    parts.add(_guideTierLabel(context, item.resolvedTier));
    if (item.preArrivalRequired) {
      parts.add(
        _localizedText(
          context,
          pt: '✈ Antes de viajar',
          es: '✈ Antes de viajar',
          en: '✈ Before traveling',
        ),
      );
    }
    if (item.urgencyLevel != null &&
        item.urgencyLevel != GuideUrgencyLevel.normal) {
      parts.add(_urgencyLabel(context, item.urgencyLevel!));
    }
    if (item.isUserPrioritized) {
      parts.add(
        _localizedText(
          context,
          pt: '★ Priorizado',
          es: '★ Priorizado',
          en: '★ Prioritized',
        ),
      );
    }
    if (item.isDismissed && item.dismissReason != null) {
      parts.add(_dismissReasonLabel(context, item.dismissReason!));
    }
    final typeLabel = item.badgeLabel ?? _guideActionTypeLabel(context, item);
    if (parts.isEmpty) {
      return Text(typeLabel, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Text(
      '${parts.join(' · ')}  $typeLabel',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: item.urgencyLevel == GuideUrgencyLevel.critical
            ? const Color(0xFFE24B4A)
            : item.urgencyLevel == GuideUrgencyLevel.urgent
            ? const Color(0xFFE8873A)
            : null,
      ),
    );
  }
}

class _GuidePlanGroup extends StatefulWidget {
  const _GuidePlanGroup({
    required this.phaseLabel,
    required this.items,
    required this.completedIds,
    required this.currentItemId,
    required this.isUnlocked,
    required this.unmetDependencyTitles,
    this.visibleItemCount = 5,
    this.initiallyCollapsed = false,
    required this.onBlockedItem,
    required this.onTapItem,
  });

  final String phaseLabel;
  final List<GuideActionItem> items;
  final Set<String> completedIds;
  final String? currentItemId;
  final bool Function(GuideActionItem item) isUnlocked;
  final List<String> Function(GuideActionItem item) unmetDependencyTitles;
  final int visibleItemCount;
  final bool initiallyCollapsed;
  final ValueChanged<GuideActionItem> onBlockedItem;
  final ValueChanged<GuideActionItem> onTapItem;

  @override
  State<_GuidePlanGroup> createState() => _GuidePlanGroupState();
}

class _GuidePlanGroupState extends State<_GuidePlanGroup> {
  bool _showAll = false;
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.items
        .where((item) => widget.completedIds.contains(item.id))
        .length;
    final visibleItems =
        _showAll || widget.items.length <= widget.visibleItemCount
        ? widget.items
        : widget.items.take(widget.visibleItemCount).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.phaseLabel} · ${widget.items.length}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _isCollapsed
                        ? Icons.expand_more_rounded
                        : Icons.expand_less_rounded,
                    color: AppColors.textSoftFor(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!_isCollapsed) ...[
          const SizedBox(height: 6),
          if (completedCount == widget.items.length &&
              widget.items.isNotEmpty) ...[
            Text(
              _localizedText(
                context,
                pt: 'Tudo resolvido neste grupo',
                es: 'Todo resuelto en este grupo',
                en: 'Everything in this group is resolved',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          for (final item in visibleItems) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item.isDismissed
                    ? Icons.remove_circle_outline_rounded
                    : widget.completedIds.contains(item.id)
                    ? Icons.check_circle_rounded
                    : widget.currentItemId == item.id
                    ? Icons.arrow_forward_rounded
                    : widget.isUnlocked(item)
                    ? Icons.arrow_forward_rounded
                    : Icons.lock_outline_rounded,
                color: item.isDismissed
                    ? AppColors.warning
                    : widget.completedIds.contains(item.id)
                    ? AppColors.success
                    : widget.currentItemId == item.id
                    ? AppColors.primary
                    : widget.isUnlocked(item)
                    ? AppColors.primary
                    : AppColors.textSoftFor(context),
              ),
              title: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration:
                      widget.completedIds.contains(item.id) && !item.isDismissed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: !widget.isUnlocked(item) && !item.isDismissed
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _unlockRequirementLabel(
                            context,
                            widget.unmetDependencyTitles(item),
                          ),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSoftFor(context),
                                height: 1.3,
                              ),
                        ),
                        _GuideItemSubtitle(item: item, context: context),
                      ],
                    )
                  : _GuideItemSubtitle(item: item, context: context),
              onTap: widget.completedIds.contains(item.id) && !item.isDismissed
                  ? null
                  : !widget.isUnlocked(item) && !item.isDismissed
                  ? () => widget.onBlockedItem(item)
                  : () => widget.onTapItem(item),
            ),
          ],
          if (!_showAll && widget.items.length > widget.visibleItemCount)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                child: Text(
                  _localizedText(
                    context,
                    pt: 'Ver todos (${widget.items.length})',
                    es: 'Ver todos (${widget.items.length})',
                    en: 'View all (${widget.items.length})',
                  ),
                ),
              ),
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
            const ContextualPhraseSupportCard(groupKey: 'documents'),
            const SizedBox(height: 16),
            _DocumentsGuideSection(
              onOpenGuide: onOpenGuide,
              onOpenTopic: onOpenTopic,
              onOpenExternalPreparationLink: onOpenExternalPreparationLink,
            ),
          ],
        );
      case _PreparationSection.housing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HousingGuideSection(
              plan: plan,
              city: city,
              onOpenRentalSearch: onOpenRentalSearch,
              onHelp: () => showContextualHelpGuide(
                context,
                preferenceKey:
                    _MigrationPlanCopilotPageState._helpPreferenceKey,
                content: _buildCopilotHelpContent(context),
              ),
              onOpenExternalPreparationLink: onOpenExternalPreparationLink,
            ),
            const SizedBox(height: 16),
            const ContextualPhraseSupportCard(groupKey: 'rental'),
          ],
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
            const ContextualPhraseSupportCard(groupKey: 'work'),
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
            const ContextualPhraseSupportCard(groupKey: 'health'),
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
            pt: 'O CPF e como o CUIL argentino — voce vai precisar dele para abrir conta, alugar e trabalhar. Pode fazer antes de viajar no consulado ou resolver nos primeiros dias no Brasil.',
            es: 'El CPF es como el CUIL argentino: lo vas a necesitar para abrir cuenta, alquilar y trabajar. Podes hacerlo antes de viajar en el consulado o resolverlo en los primeros dias en Brasil.',
            en: 'The CPF is like the Argentine CUIL. You will need it to open a bank account, rent, and work. You can do it before travel at the consulate or handle it in your first days in Brazil.',
          ),
          onTap: () => onOpenTopic(DocumentationGuideSection.documents),
        ),
        const SizedBox(height: 12),
        _InfoGuideCard(
          icon: Icons.perm_identity_rounded,
          tint: AppColors.secondary,
          title: _localizedText(
            context,
            pt: 'Residência pelo acordo Brasil–Argentina',
            es: 'Residencia por el acuerdo Brasil–Argentina',
            en: 'Residence under the Brazil–Argentina agreement',
          ),
          body: _localizedText(
            context,
            pt: 'Argentinos elegíveis podem solicitar residência permanente pela rota bilateral. Confirme a base legal e os requisitos atuais na Polícia Federal; o registro RNM/CRNM é uma etapa própria.',
            es: 'Argentinos elegibles pueden solicitar residencia permanente por la ruta bilateral. Confirmá la base legal y los requisitos vigentes en la Policía Federal; el RNM/CRNM es una etapa propia.',
            en: 'Eligible Argentines may request permanent residence through the bilateral route. Confirm the legal basis and current requirements with Federal Police; RNM/CRNM registration is a separate step.',
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
            pt: 'Saúde no Brasil: SUS, plano e pontos para entender',
            es: 'Salud en Brasil: SUS, prepaga y puntos para entender',
            en: 'Healthcare in Brazil: SUS, insurance, and points to understand',
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
    final destination = widget.destinationCityName?.trim().isNotEmpty == true
        ? widget.destinationCityName!.trim()
        : context.l10n.flightDestinationFallback('BR');
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
    final destination = widget.destinationCityName?.trim().isNotEmpty == true
        ? widget.destinationCityName!.trim()
        : l10n.flightDestinationFallback('BR');
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
            l10n.flightPlannerBody(destination),
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
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFEAF7EF),
        darkAlpha: 0.24,
      ),
      action: SnackBarAction(
        label: _localizedText(context, pt: 'OK', es: 'OK', en: 'OK'),
        textColor: AppColors.success,
        onPressed: () {},
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

String _completionMessage(BuildContext context, int count) {
  if (count == 1) {
    return context.l10n.copilotCompletionMessageFirst;
  }
  if (count <= 3) {
    return context.l10n.copilotCompletionMessageFew(count);
  }
  if (count <= 7) {
    return context.l10n.copilotCompletionMessageMid(count);
  }
  return context.l10n.copilotCompletionMessageHigh(count);
}

String _prepSectionLabel(BuildContext context, _PreparationSection section) {
  return switch (section) {
    _PreparationSection.overview => context.l10n.copilotPrepOverview,
    _PreparationSection.documents => context.l10n.copilotPrepDocuments,
    _PreparationSection.housing => context.l10n.copilotPrepHousing,
    _PreparationSection.work => context.l10n.copilotPrepWork,
    _PreparationSection.arrival => context.l10n.copilotPrepArrival,
  };
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
    'find_job_br' => context.l10n.copilotGoalFindJob,
    'remote_income' => context.l10n.copilotGoalRemoteIncome,
    'study' => context.l10n.copilotGoalStudy,
    'family_partner' => context.l10n.copilotGoalFamily,
    'fresh_start' => context.l10n.copilotGoalFreshStart,
    _ => context.l10n.copilotGoalDefault,
  };
}

String _openSectionCta(BuildContext context, _PreparationSection section) {
  return context.l10n.copilotOpenSection(_prepSectionLabel(context, section));
}

String _jobMarketLabel(BuildContext context, double score) {
  if (score >= 0.7) {
    return context.l10n.copilotJobMarketHigh;
  }
  if (score >= 0.4) {
    return context.l10n.copilotJobMarketMid;
  }
  return context.l10n.copilotJobMarketLow;
}

String _guidePhaseName(BuildContext context, GuidePhase phase) {
  return switch (phase) {
    GuidePhase.preparation => _localizedText(
      context,
      pt: 'Começando',
      es: 'Empezando',
      en: 'Getting started',
    ),
    GuidePhase.housing => _localizedText(
      context,
      pt: 'Onde ficar',
      es: 'Donde quedarte',
      en: 'Where to stay',
    ),
    GuidePhase.documents => _localizedText(
      context,
      pt: 'Documentos essenciais',
      es: 'Documentos esenciales',
      en: 'Essential documents',
    ),
    GuidePhase.work => _localizedText(
      context,
      pt: 'Dinheiro e trabalho',
      es: 'Dinero y trabajo',
      en: 'Money and work',
    ),
    GuidePhase.arrival => _localizedText(
      context,
      pt: 'Estabilizando',
      es: 'Estabilizandote',
      en: 'Settling in',
    ),
  };
}

String _guidePhaseShortName(BuildContext context, GuidePhase phase) {
  return _guidePhaseName(context, phase);
}

String _phaseCelebrationBody(BuildContext context, GuidePhase phase) {
  return switch (phase) {
    GuidePhase.preparation => _localizedText(
      context,
      pt: 'A base do plano está montada. Agora vale transformar pesquisa em decisões concretas de documentos e chegada.',
      es: 'La base del plan ya está lista. Ahora toca convertir investigación en decisiones concretas de documentos y llegada.',
      en: 'The foundation of the plan is set. Now it is time to turn research into concrete document and arrival decisions.',
    ),
    GuidePhase.housing => _localizedText(
      context,
      pt: 'Moradia destravada. Isso reduz muita incerteza da chegada e dá espaço para cuidar do resto com mais clareza.',
      es: 'Vivienda destrabada. Eso reduce mucha incertidumbre de la llegada y deja espacio para resolver el resto con más claridad.',
      en: 'Housing is unlocked. That removes a lot of arrival uncertainty and gives you room to handle the rest with more clarity.',
    ),
    GuidePhase.documents => _localizedText(
      context,
      pt: 'Documentos em ordem. A parte mais sensível do caminho ficou para trás.',
      es: 'Documentos en orden. La parte más sensible del camino ya quedó atrás.',
      en: 'Documents are in order. The most sensitive part of the path is now behind you.',
    ),
    GuidePhase.work => _localizedText(
      context,
      pt: 'Sua base prática de renda e operação ficou muito mais sólida. O próximo passo tende a ser estabilização.',
      es: 'Tu base práctica de ingresos y operación quedó mucho más sólida. El próximo paso tiende a ser estabilización.',
      en: 'Your practical income and operating base is much more solid now. The next step tends to be stabilization.',
    ),
    GuidePhase.arrival => _localizedText(
      context,
      pt: 'Fase de chegada concluída. O plano saiu do papel e virou rotina.',
      es: 'Fase de llegada completada. El plan salió del papel y se volvió rutina.',
      en: 'Arrival phase completed. The plan has moved from paper into routine.',
    ),
  };
}

String _guideEffortLabel(BuildContext context, GuideEstimatedEffort effort) {
  return switch (effort) {
    GuideEstimatedEffort.fast => _localizedText(
      context,
      pt: 'rápido',
      es: 'rápido',
      en: 'fast',
    ),
    GuideEstimatedEffort.medium => _localizedText(
      context,
      pt: 'médio',
      es: 'medio',
      en: 'medium',
    ),
    GuideEstimatedEffort.longer => _localizedText(
      context,
      pt: 'mais longo',
      es: 'mas largo',
      en: 'longer',
    ),
  };
}

String _guideTierLabel(BuildContext context, GuideItemTier tier) {
  return switch (tier) {
    GuideItemTier.critical => _localizedText(
      context,
      pt: 'Obrigatório',
      es: 'Obligatorio',
      en: 'Critical path',
    ),
    GuideItemTier.recommended => _localizedText(
      context,
      pt: 'Recomendado',
      es: 'Recomendado',
      en: 'Recommended',
    ),
    GuideItemTier.optional => _localizedText(
      context,
      pt: 'Opcional',
      es: 'Opcional',
      en: 'Optional',
    ),
  };
}

String _dismissReasonLabel(BuildContext context, GuideDismissReason reason) {
  return switch (reason) {
    GuideDismissReason.alreadyDone => _localizedText(
      context,
      pt: 'Já fiz isso',
      es: 'Ya hice esto',
      en: 'Already done',
    ),
    GuideDismissReason.notApplicable => _localizedText(
      context,
      pt: 'Não se aplica',
      es: 'No aplica',
      en: 'Not applicable',
    ),
    GuideDismissReason.later => _localizedText(
      context,
      pt: 'Vou fazer depois',
      es: 'Lo hare despues',
      en: 'Do it later',
    ),
  };
}

String _guideButtonLabel(
  BuildContext context,
  GuideActionItem item,
  bool showExpandedContent, {
  bool awaitingConfirmation = false,
}) {
  return _localizedText(
    context,
    pt: 'Executar etapa',
    es: 'Ejecutar etapa',
    en: 'Run this step',
  );
}

String _guideActionTypeLabel(BuildContext context, GuideActionItem item) {
  if (item.hasDecisionOptions) {
    return _localizedText(
      context,
      pt: 'Decisão importante',
      es: 'Decision importante',
      en: 'Important decision',
    );
  }
  return switch (item.type) {
    GuideActionType.external => _localizedText(
      context,
      pt: 'Abrir recurso oficial',
      es: 'Abrir recurso oficial',
      en: 'Open official resource',
    ),
    GuideActionType.tool => _localizedText(
      context,
      pt: 'Ferramenta prática',
      es: 'Herramienta practica',
      en: 'Practical tool',
    ),
    GuideActionType.checklist => _localizedText(
      context,
      pt: 'Checklist de execução',
      es: 'Checklist de ejecucion',
      en: 'Execution checklist',
    ),
    GuideActionType.informative => _localizedText(
      context,
      pt: 'Orientação prática',
      es: 'Orientacion practica',
      en: 'Practical guidance',
    ),
  };
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

String _unlockRequirementLabel(
  BuildContext context,
  List<String> dependencyTitles,
) {
  if (dependencyTitles.isEmpty) {
    return _localizedText(
      context,
      pt: 'Conclua os pré-requisitos para liberar',
      es: 'Completa los requisitos previos para desbloquear',
      en: 'Complete the prerequisites to unlock',
    );
  }
  final visible = dependencyTitles.take(2).join(' + ');
  final extraCount = dependencyTitles.length - 2;
  final suffix = extraCount > 0 ? ' +$extraCount' : '';
  return _localizedText(
    context,
    pt: 'Conclua $visible$suffix para liberar',
    es: 'Completa $visible$suffix para desbloquear',
    en: 'Complete $visible$suffix to unlock',
  );
}

String _urgencyLabel(BuildContext context, GuideUrgencyLevel level) =>
    switch (level) {
      GuideUrgencyLevel.critical => _localizedText(
        context,
        pt: '🔴 Crítico',
        es: '🔴 Critico',
        en: '🔴 Critical',
      ),
      GuideUrgencyLevel.urgent => _localizedText(
        context,
        pt: '🟠 Urgente',
        es: '🟠 Urgente',
        en: '🟠 Urgent',
      ),
      GuideUrgencyLevel.watch => _localizedText(
        context,
        pt: '🟡 Atenção',
        es: '🟡 Atencion',
        en: '🟡 Watch',
      ),
      GuideUrgencyLevel.normal => '',
    };

Color _urgencyBannerColor(BuildContext context, GuideUrgencyLevel? level) {
  final tone = switch (level) {
    GuideUrgencyLevel.critical => AppColors.danger,
    GuideUrgencyLevel.urgent => AppColors.warning,
    GuideUrgencyLevel.watch => AppColors.warning,
    _ => AppColors.primary,
  };
  return AppColors.tintedSurfaceFor(
    context,
    tint: tone,
    lightColor: tone.withValues(alpha: 0.08),
  );
}

Color _urgencyTextColor(BuildContext context, GuideUrgencyLevel? level) =>
    switch (level) {
      GuideUrgencyLevel.critical => AppColors.danger,
      GuideUrgencyLevel.urgent => AppColors.warning,
      GuideUrgencyLevel.watch => AppColors.warning,
      _ => AppColors.primary,
    };

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

// ─── Migration-folder execution assistant ────────────────────────────────────

class _MigrationFolderDecisionAssistant extends StatelessWidget {
  const _MigrationFolderDecisionAssistant({
    required this.profile,
    required this.onChanged,
  });

  final MigrationDocumentFolderProfile profile;
  final Future<void> Function(MigrationDocumentFolderProfile profile) onChanged;

  void _update(MigrationDocumentFolderProfile value) {
    unawaited(onChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    final total = profile.needsCountryHistory ? 5 : 4;
    final answered = <bool>[
      profile.ageGroup != null,
      profile.identityShowsParentage != null,
      if (profile.needsCountryHistory) profile.livedOutsideArgentina != null,
      profile.isAlreadyInBrazil != null,
      profile.protocolWindow != null,
    ].where((value) => value).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: const Color(0xFFF3F8FF),
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFCFE2FF),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_copy_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _localizedText(
                    context,
                    pt: 'Monte somente a pasta do seu caso',
                    es: 'Arma solo la carpeta de tu caso',
                    en: 'Build only the folder your case needs',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$answered/$total',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _localizedText(
              context,
              pt: 'Uma pergunta por vez. As peças que não se aplicam desaparecem automaticamente.',
              es: 'Una pregunta por vez. Las piezas que no aplican desaparecen automáticamente.',
              en: 'One question at a time. Pieces that do not apply disappear automatically.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _CriminalRecordQuestion<MigrationFolderAgeGroup>(
            number: 1,
            title: _localizedText(
              context,
              pt: 'Qual é a faixa etária do solicitante?',
              es: '¿Cuál es la edad del solicitante?',
              en: 'What is the applicant’s age group?',
            ),
            options: [
              _DecisionChoice(
                value: MigrationFolderAgeGroup.adult,
                label: _localizedText(
                  context,
                  pt: '18 anos ou mais',
                  es: '18 años o más',
                  en: '18 or older',
                ),
              ),
              _DecisionChoice(
                value: MigrationFolderAgeGroup.under18,
                label: _localizedText(
                  context,
                  pt: 'Menor de 18 anos',
                  es: 'Menor de 18 años',
                  en: 'Under 18',
                ),
              ),
            ],
            selected: profile.ageGroup,
            onSelected: (value) => _update(profile.copyWith(ageGroup: value)),
          ),
          if (profile.ageGroup != null) ...[
            const SizedBox(height: 16),
            _CriminalRecordQuestion<bool>(
              number: 2,
              title: _localizedText(
                context,
                pt: 'Seu DNI ou passaporte mostra o nome dos seus pais?',
                es: '¿Tu DNI o pasaporte muestra el nombre de tus padres?',
                en: 'Does your ID or passport show your parents’ names?',
              ),
              helper: _localizedText(
                context,
                pt: 'A Polícia Federal chama essa informação de filiação.',
                es: 'La Policía Federal llama a esta información filiación.',
                en: 'The Federal Police refers to this as parentage information.',
              ),
              options: [
                _DecisionChoice(
                  value: true,
                  label: _localizedText(
                    context,
                    pt: 'Sim, mostra',
                    es: 'Sí, aparece',
                    en: 'Yes, it does',
                  ),
                ),
                _DecisionChoice(
                  value: false,
                  label: _localizedText(
                    context,
                    pt: 'Não mostra',
                    es: 'No aparece',
                    en: 'No, it does not',
                  ),
                ),
              ],
              selected: profile.identityShowsParentage,
              onSelected: (value) =>
                  _update(profile.copyWith(identityShowsParentage: value)),
            ),
          ],
          if (profile.identityShowsParentage != null &&
              profile.needsCountryHistory) ...[
            const SizedBox(height: 16),
            _CriminalRecordQuestion<bool>(
              number: 3,
              title: _localizedText(
                context,
                pt: 'Você viveu em outro país além da Argentina nos últimos 5 anos?',
                es: '¿Viviste en otro país además de Argentina en los últimos 5 años?',
                en: 'Have you lived outside Argentina in the last 5 years?',
              ),
              options: [
                _DecisionChoice(
                  value: false,
                  label: _localizedText(context, pt: 'Não', es: 'No', en: 'No'),
                ),
                _DecisionChoice(
                  value: true,
                  label: _localizedText(
                    context,
                    pt: 'Sim',
                    es: 'Sí',
                    en: 'Yes',
                  ),
                ),
              ],
              selected: profile.livedOutsideArgentina,
              onSelected: (value) =>
                  _update(profile.copyWith(livedOutsideArgentina: value)),
            ),
          ],
          if (profile.identityShowsParentage != null &&
              (!profile.needsCountryHistory ||
                  profile.livedOutsideArgentina != null)) ...[
            const SizedBox(height: 16),
            _CriminalRecordQuestion<bool>(
              number: profile.needsCountryHistory ? 4 : 3,
              title: _localizedText(
                context,
                pt: 'Você já entrou no Brasil?',
                es: '¿Ya ingresaste a Brasil?',
                en: 'Have you already entered Brazil?',
              ),
              helper: _localizedText(
                context,
                pt: 'Isso define se o comprovante de entrada já pode ser guardado ou ficará como pendência futura.',
                es: 'Esto define si el comprobante de ingreso ya puede guardarse o quedará pendiente.',
                en: 'This determines whether entry proof can be stored now or remains a later item.',
              ),
              options: [
                _DecisionChoice(
                  value: true,
                  label: _localizedText(
                    context,
                    pt: 'Sim, já entrei',
                    es: 'Sí, ya ingresé',
                    en: 'Yes, I have',
                  ),
                ),
                _DecisionChoice(
                  value: false,
                  label: _localizedText(
                    context,
                    pt: 'Ainda não',
                    es: 'Todavía no',
                    en: 'Not yet',
                  ),
                ),
              ],
              selected: profile.isAlreadyInBrazil,
              onSelected: (value) =>
                  _update(profile.copyWith(isAlreadyInBrazil: value)),
            ),
          ],
          if (profile.isAlreadyInBrazil != null) ...[
            const SizedBox(height: 16),
            _CriminalRecordQuestion<CriminalRecordProtocolWindow>(
              number: profile.needsCountryHistory ? 5 : 4,
              title: _localizedText(
                context,
                pt: 'Quando você pretende protocolar na Polícia Federal?',
                es: '¿Cuándo planeas presentar el trámite ante la Policía Federal?',
                en: 'When do you plan to file with the Federal Police?',
              ),
              options: [
                _DecisionChoice(
                  value: CriminalRecordProtocolWindow.withinThirtyDays,
                  label: _localizedText(
                    context,
                    pt: 'Nos próximos 30 dias',
                    es: 'En los próximos 30 días',
                    en: 'Within 30 days',
                  ),
                ),
                _DecisionChoice(
                  value: CriminalRecordProtocolWindow.oneToThreeMonths,
                  label: _localizedText(
                    context,
                    pt: 'Entre 1 e 3 meses',
                    es: 'Entre 1 y 3 meses',
                    en: 'In 1–3 months',
                  ),
                ),
                _DecisionChoice(
                  value: CriminalRecordProtocolWindow.moreThanThreeMonths,
                  label: _localizedText(
                    context,
                    pt: 'Mais de 3 meses',
                    es: 'Más de 3 meses',
                    en: 'More than 3 months',
                  ),
                ),
                _DecisionChoice(
                  value: CriminalRecordProtocolWindow.unknown,
                  label: _localizedText(
                    context,
                    pt: 'Ainda não sei',
                    es: 'Todavía no sé',
                    en: 'Not sure yet',
                  ),
                ),
              ],
              selected: profile.protocolWindow,
              onSelected: (value) =>
                  _update(profile.copyWith(protocolWindow: value)),
            ),
          ],
        ],
      ),
    );
  }
}

class _MigrationFolderActionContent {
  const _MigrationFolderActionContent({
    required this.icon,
    required this.title,
    required this.instruction,
  });

  final IconData icon;
  final String title;
  final String instruction;
}

_MigrationFolderActionContent _migrationFolderActionContent(
  BuildContext context,
  String id,
  MigrationDocumentFolderProfile profile,
) => switch (id) {
  'folder_structure' => _MigrationFolderActionContent(
    icon: Icons.create_new_folder_outlined,
    title: _localizedText(
      context,
      pt: 'Crie a estrutura da pasta',
      es: 'Crea la estructura de la carpeta',
      en: 'Create the folder structure',
    ),
    instruction: _localizedText(
      context,
      pt: 'Use uma pasta digital e, se quiser, uma cópia física. Toque em “Copiar estrutura” para usar nomes prontos.',
      es: 'Usa una carpeta digital y, si quieres, una copia física. Toca “Copiar estructura” para usar nombres listos.',
      en: 'Use a digital folder and optionally a physical copy. Tap “Copy structure” for ready-made names.',
    ),
  ),
  'official_route' => _MigrationFolderActionContent(
    icon: Icons.verified_outlined,
    title: _localizedText(
      context,
      pt: 'Salve a lista oficial correta',
      es: 'Guarda la lista oficial correcta',
      en: 'Save the correct official checklist',
    ),
    instruction: _localizedText(
      context,
      pt: 'Abra a modalidade “Acordo Brasil–Argentina” da Polícia Federal. Evite checklists genéricas.',
      es: 'Abre la modalidad “Acuerdo Brasil–Argentina” de la Policía Federal. Evita listas genéricas.',
      en: 'Open the Federal Police “Brazil–Argentina Agreement” route. Avoid generic checklists.',
    ),
  ),
  'identity_copy' => _MigrationFolderActionContent(
    icon: Icons.badge_outlined,
    title: _localizedText(
      context,
      pt: 'Adicione sua identidade',
      es: 'Agrega tu identidad',
      en: 'Add your identity document',
    ),
    instruction: _localizedText(
      context,
      pt: 'Guarde uma cópia legível do DNI ou passaporte válido usado para entrar no Brasil.',
      es: 'Guarda una copia legible del DNI o pasaporte válido usado para entrar a Brasil.',
      en: 'Store a legible copy of the valid ID or passport used to enter Brazil.',
    ),
  ),
  'parentage_evidence' => _MigrationFolderActionContent(
    icon: Icons.family_restroom_outlined,
    title: _localizedText(
      context,
      pt: 'Separe a prova de filiação',
      es: 'Separa la prueba de filiación',
      en: 'Prepare parentage evidence',
    ),
    instruction: _localizedText(
      context,
      pt: 'Como a identidade não mostra filiação, separe certidão de nascimento, casamento ou certidão consular.',
      es: 'Como la identidad no muestra filiación, separa partida de nacimiento, matrimonio o certificado consular.',
      en: 'Because the ID lacks parentage, prepare a birth, marriage, or consular certificate.',
    ),
  ),
  'criminal_records_map' => _MigrationFolderActionContent(
    icon: Icons.gpp_good_outlined,
    title: _localizedText(
      context,
      pt: 'Reserve a seção de antecedentes',
      es: 'Reserva la sección de antecedentes',
      en: 'Reserve the criminal-record section',
    ),
    instruction: _localizedText(
      context,
      pt: 'Não emita às cegas aqui. A etapa “Certificados de antecedentes” calcula os países e o melhor momento.',
      es: 'No los emitas a ciegas aquí. La etapa “Certificados de antecedentes” calcula países y momento.',
      en: 'Do not request them blindly here. The criminal-record step determines countries and timing.',
    ),
  ),
  'other_countries_map' => _MigrationFolderActionContent(
    icon: Icons.public_outlined,
    title: _localizedText(
      context,
      pt: 'Liste os outros países',
      es: 'Lista los otros países',
      en: 'List the other countries',
    ),
    instruction: _localizedText(
      context,
      pt: 'Anote cada país onde viveu nos cinco anos anteriores ao pedido. Cada um pode exigir certidão própria.',
      es: 'Anota cada país donde viviste en los cinco años anteriores. Cada uno puede exigir su certificado.',
      en: 'List each country lived in during the previous five years. Each may require its own certificate.',
    ),
  ),
  'formalities_review' => _MigrationFolderActionContent(
    icon: Icons.translate_outlined,
    title: _localizedText(
      context,
      pt: 'Marque o que exige formalidade',
      es: 'Marca lo que exige formalidad',
      en: 'Mark documents needing formalities',
    ),
    instruction: _localizedText(
      context,
      pt: 'Para cada documento estrangeiro, confirme na fonte oficial se precisa apostila, legalização ou tradução. Não presuma dispensa.',
      es: 'Para cada documento extranjero, confirma si necesita apostilla, legalización o traducción. No presumas exención.',
      en: 'For each foreign document, confirm apostille, legalization, or translation requirements. Do not assume a waiver.',
    ),
  ),
  _ => _MigrationFolderActionContent(
    icon: Icons.pending_actions_outlined,
    title: _localizedText(
      context,
      pt: 'Crie espaços para os documentos posteriores',
      es: 'Crea espacios para los documentos posteriores',
      en: 'Create slots for later documents',
    ),
    instruction: _localizedText(
      context,
      pt: profile.isAlreadyInBrazil == true
          ? 'Guarde o comprovante de entrada. Deixe formulário, declaração, taxas e protocolo em seções separadas.'
          : 'Deixe espaços para comprovante de entrada, formulário, declaração, taxas e protocolo. Você preencherá depois, no momento correto.',
      es: profile.isAlreadyInBrazil == true
          ? 'Guarda el comprobante de ingreso. Deja formulario, declaración, tasas y protocolo en secciones separadas.'
          : 'Deja espacios para ingreso, formulario, declaración, tasas y protocolo. Los completarás en el momento correcto.',
      en: profile.isAlreadyInBrazil == true
          ? 'Store entry proof. Keep form, declaration, fees, and protocol in separate sections.'
          : 'Create slots for entry proof, form, declaration, fees, and protocol. Fill them at the right time.',
    ),
  ),
};

class _MigrationFolderActionRunner extends StatelessWidget {
  const _MigrationFolderActionRunner({
    required this.profile,
    required this.onToggle,
    required this.onOpenOfficial,
    required this.onCopyStructure,
  });

  final MigrationDocumentFolderProfile profile;
  final Future<void> Function(String actionId) onToggle;
  final VoidCallback onOpenOfficial;
  final VoidCallback onCopyStructure;

  @override
  Widget build(BuildContext context) {
    if (!profile.isComplete) {
      return _GuideWorkflowMessage(
        text: _localizedText(
          context,
          pt: 'Responda às perguntas acima. A próxima ação aparecerá aqui.',
          es: 'Responde las preguntas de arriba. La próxima acción aparecerá aquí.',
          en: 'Answer the questions above. Your next action will appear here.',
        ),
      );
    }
    final ids = profile.requiredActionIds;
    final completed = profile.completedActionIds;
    final currentId = ids.where((id) => !completed.contains(id)).firstOrNull;
    if (currentId == null) {
      return _GuideWorkflowMessage(
        text: _localizedText(
          context,
          pt: 'Pasta estruturada. Faça a conferência final abaixo e conclua a etapa.',
          es: 'Carpeta estructurada. Haz la revisión final y completa la etapa.',
          en: 'Folder structured. Review the summary below and complete the step.',
        ),
      );
    }
    final current = _migrationFolderActionContent(context, currentId, profile);
    final currentIndex = ids.indexOf(currentId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _localizedText(
                  context,
                  pt: 'Próxima ação',
                  es: 'Próxima acción',
                  en: 'Next action',
                ),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${currentIndex + 1}/${ids.length}',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.primary,
              lightColor: const Color(0xFFF5F9FF),
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(current.icon, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                current.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                current.instruction,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
              if (currentId == 'folder_structure' ||
                  currentId == 'official_route') ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: currentId == 'folder_structure'
                      ? onCopyStructure
                      : onOpenOfficial,
                  icon: Icon(
                    currentId == 'folder_structure'
                        ? Icons.copy_rounded
                        : Icons.open_in_new_rounded,
                    size: 17,
                  ),
                  label: Text(
                    currentId == 'folder_structure'
                        ? _localizedText(
                            context,
                            pt: 'Copiar estrutura',
                            es: 'Copiar estructura',
                            en: 'Copy structure',
                          )
                        : _localizedText(
                            context,
                            pt: 'Abrir lista oficial',
                            es: 'Abrir lista oficial',
                            en: 'Open official checklist',
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onToggle(currentId),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    _localizedText(
                      context,
                      pt: 'Pronto, avançar',
                      es: 'Listo, avanzar',
                      en: 'Done, continue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final id in ids.where(completed.contains))
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _migrationFolderActionContent(context, id, profile).title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: _localizedText(
                      context,
                      pt: 'Reabrir',
                      es: 'Reabrir',
                      en: 'Reopen',
                    ),
                    onPressed: () => onToggle(id),
                    icon: const Icon(Icons.undo_rounded, size: 17),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _MigrationFolderCompletionSummary extends StatelessWidget {
  const _MigrationFolderCompletionSummary({required this.profile});

  final MigrationDocumentFolderProfile profile;

  @override
  Widget build(BuildContext context) {
    final total = profile.requiredActionIds.length;
    final completed = profile.requiredActionIds
        .where(profile.completedActionIds.contains)
        .length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: (completed == total ? AppColors.success : AppColors.primary)
            .withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (completed == total ? AppColors.success : AppColors.primary)
              .withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed == total
                ? Icons.task_alt_rounded
                : Icons.folder_open_rounded,
            color: completed == total ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              completed == total
                  ? _localizedText(
                      context,
                      pt: 'Estrutura pronta. Os documentos futuros estão separados das peças que já podem ser organizadas.',
                      es: 'Estructura lista. Los documentos futuros están separados de las piezas que ya pueden organizarse.',
                      en: 'Structure ready. Later documents are separated from pieces that can be organized now.',
                    )
                  : _localizedText(
                      context,
                      pt: '$completed de $total peças preparadas. Continue pela próxima ação acima.',
                      es: '$completed de $total piezas preparadas. Continúa con la próxima acción.',
                      en: '$completed of $total pieces prepared. Continue with the next action above.',
                    ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Criminal-record decision assistant ──────────────────────────────────────

class _CriminalRecordDecisionAssistant extends StatefulWidget {
  const _CriminalRecordDecisionAssistant({
    required this.profile,
    required this.onChanged,
  });

  final CriminalRecordProfile profile;
  final Future<void> Function(CriminalRecordProfile profile) onChanged;

  @override
  State<_CriminalRecordDecisionAssistant> createState() =>
      _CriminalRecordDecisionAssistantState();
}

class _CriminalRecordDecisionAssistantState
    extends State<_CriminalRecordDecisionAssistant> {
  late final TextEditingController _countriesController;

  @override
  void initState() {
    super.initState();
    _countriesController = TextEditingController(
      text: widget.profile.otherCountriesText,
    );
  }

  @override
  void didUpdateWidget(_CriminalRecordDecisionAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_countriesController.selection.isValid &&
        _countriesController.text != widget.profile.otherCountriesText) {
      _countriesController.text = widget.profile.otherCountriesText;
    }
  }

  @override
  void dispose() {
    _countriesController.dispose();
    super.dispose();
  }

  void _update(CriminalRecordProfile profile) {
    unawaited(widget.onChanged(profile));
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final answered = <bool>[
      profile.ageGroup != null,
      profile.isExempt || profile.hasArgentineDni != null,
      profile.isExempt || profile.livedOutsideArgentina != null,
      profile.isExempt || profile.protocolWindow != null,
    ].where((value) => value).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: const Color(0xFFF3F8FF),
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFCFE2FF),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _localizedText(
                    context,
                    pt: 'Descubra sua rota em até 4 respostas',
                    es: 'Descubre tu ruta en hasta 4 respuestas',
                    en: 'Find your route in up to 4 answers',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$answered/4',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _localizedText(
              context,
              pt: 'O Movaro guarda somente estas escolhas de rota. Não pedimos número do DNI nem o arquivo do certificado.',
              es: 'Movaro guarda solo estas decisiones de ruta. No pedimos el número de DNI ni el archivo del certificado.',
              en: 'Movaro stores only these route choices. We do not ask for a DNI number or certificate file.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _CriminalRecordQuestion(
            number: 1,
            title: _localizedText(
              context,
              pt: 'Qual é a sua faixa etária?',
              es: '¿Cuál es tu rango de edad?',
              en: 'What is your age range?',
            ),
            options: [
              _DecisionChoice<CriminalRecordAgeGroup>(
                value: CriminalRecordAgeGroup.adult,
                label: _localizedText(
                  context,
                  pt: '18 anos ou mais',
                  es: '18 años o más',
                  en: '18 or older',
                ),
              ),
              _DecisionChoice<CriminalRecordAgeGroup>(
                value: CriminalRecordAgeGroup.minor,
                label: _localizedText(
                  context,
                  pt: 'Menos de 18',
                  es: 'Menos de 18',
                  en: 'Under 18',
                ),
              ),
            ],
            selected: profile.ageGroup,
            onSelected: (value) =>
                _update(CriminalRecordProfile(ageGroup: value)),
          ),
          if (profile.isExempt) ...[
            const SizedBox(height: 14),
            const _CriminalRecordExemptionCard(),
          ] else if (profile.ageGroup == CriminalRecordAgeGroup.adult) ...[
            const SizedBox(height: 14),
            _CriminalRecordQuestion(
              number: 2,
              title: _localizedText(
                context,
                pt: 'Você possui DNI argentino?',
                es: '¿Tenés DNI argentino?',
                en: 'Do you have an Argentine DNI?',
              ),
              helper: _localizedText(
                context,
                pt: 'Sem DNI argentino, o RNR orienta fazer o pedido presencialmente.',
                es: 'Sin DNI argentino, el RNR indica hacer el trámite presencialmente.',
                en: 'Without an Argentine DNI, RNR directs you to the in-person route.',
              ),
              options: [
                _DecisionChoice<bool>(
                  value: true,
                  label: _localizedText(
                    context,
                    pt: 'Sim',
                    es: 'Sí',
                    en: 'Yes',
                  ),
                ),
                _DecisionChoice<bool>(
                  value: false,
                  label: _localizedText(context, pt: 'Não', es: 'No', en: 'No'),
                ),
              ],
              selected: profile.hasArgentineDni,
              onSelected: (value) => _update(
                profile.copyWith(
                  hasArgentineDni: value,
                  completedOutcomeIds: const <String>{},
                ),
              ),
            ),
            if (profile.hasArgentineDni != null) ...[
              const SizedBox(height: 14),
              _CriminalRecordQuestion(
                number: 3,
                title: _localizedText(
                  context,
                  pt: 'Você viveu fora da Argentina nos últimos 5 anos?',
                  es: '¿Viviste fuera de Argentina en los últimos 5 años?',
                  en: 'Did you live outside Argentina in the last 5 years?',
                ),
                options: [
                  _DecisionChoice<bool>(
                    value: false,
                    label: _localizedText(
                      context,
                      pt: 'Não',
                      es: 'No',
                      en: 'No',
                    ),
                  ),
                  _DecisionChoice<bool>(
                    value: true,
                    label: _localizedText(
                      context,
                      pt: 'Sim',
                      es: 'Sí',
                      en: 'Yes',
                    ),
                  ),
                ],
                selected: profile.livedOutsideArgentina,
                onSelected: (value) {
                  if (!value) _countriesController.clear();
                  _update(
                    profile.copyWith(
                      livedOutsideArgentina: value,
                      otherCountriesText: value
                          ? profile.otherCountriesText
                          : '',
                      completedOutcomeIds: const <String>{},
                    ),
                  );
                },
              ),
            ],
            if (profile.livedOutsideArgentina == true) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _countriesController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _localizedText(
                    context,
                    pt: 'Quais países?',
                    es: '¿Qué países?',
                    en: 'Which countries?',
                  ),
                  hintText: _localizedText(
                    context,
                    pt: 'Ex.: Chile, Uruguai',
                    es: 'Ej.: Chile, Uruguay',
                    en: 'E.g. Chile, Uruguay',
                  ),
                  helperText: _localizedText(
                    context,
                    pt: 'Separe mais de um país com vírgulas.',
                    es: 'Separá varios países con comas.',
                    en: 'Separate multiple countries with commas.',
                  ),
                  prefixIcon: const Icon(Icons.public_rounded),
                ),
                onChanged: (value) => _update(
                  profile.copyWith(
                    otherCountriesText: value,
                    completedOutcomeIds: const <String>{},
                  ),
                ),
              ),
            ],
            if (profile.livedOutsideArgentina == false ||
                profile.otherCountries.isNotEmpty) ...[
              const SizedBox(height: 14),
              _CriminalRecordQuestion(
                number: 4,
                title: _localizedText(
                  context,
                  pt: 'Quando pretende protocolar na Polícia Federal?',
                  es: '¿Cuándo pensás presentar ante la Policía Federal?',
                  en: 'When do you expect to file with Federal Police?',
                ),
                options: [
                  _DecisionChoice<CriminalRecordProtocolWindow>(
                    value: CriminalRecordProtocolWindow.withinThirtyDays,
                    label: _localizedText(
                      context,
                      pt: 'Até 30 dias',
                      es: 'Hasta 30 días',
                      en: 'Within 30 days',
                    ),
                  ),
                  _DecisionChoice<CriminalRecordProtocolWindow>(
                    value: CriminalRecordProtocolWindow.oneToThreeMonths,
                    label: _localizedText(
                      context,
                      pt: '1 a 3 meses',
                      es: '1 a 3 meses',
                      en: '1–3 months',
                    ),
                  ),
                  _DecisionChoice<CriminalRecordProtocolWindow>(
                    value: CriminalRecordProtocolWindow.moreThanThreeMonths,
                    label: _localizedText(
                      context,
                      pt: 'Mais de 3 meses',
                      es: 'Más de 3 meses',
                      en: 'More than 3 months',
                    ),
                  ),
                  _DecisionChoice<CriminalRecordProtocolWindow>(
                    value: CriminalRecordProtocolWindow.unknown,
                    label: _localizedText(
                      context,
                      pt: 'Ainda não sei',
                      es: 'Todavía no sé',
                      en: 'Not sure yet',
                    ),
                  ),
                ],
                selected: profile.protocolWindow,
                onSelected: (value) =>
                    _update(profile.copyWith(protocolWindow: value)),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DecisionChoice<T> {
  const _DecisionChoice({required this.value, required this.label});

  final T value;
  final String label;
}

class _CriminalRecordQuestion<T> extends StatelessWidget {
  const _CriminalRecordQuestion({
    required this.number,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.helper,
  });

  final int number;
  final String title;
  final String? helper;
  final List<_DecisionChoice<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (helper != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      helper!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option.label),
                selected: selected == option.value,
                onSelected: (_) => onSelected(option.value),
              ),
          ],
        ),
      ],
    );
  }
}

class _CriminalRecordExecutionPlan extends StatelessWidget {
  const _CriminalRecordExecutionPlan({
    required this.profile,
    required this.onLinkTap,
  });

  static const _pfUrl =
      'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina';
  static const _rnrFaqUrl =
      'https://www.argentina.gob.ar/justicia/reincidencia/antecedentespenales/preguntas-frecuentes';

  final CriminalRecordProfile profile;
  final void Function(String url, String label) onLinkTap;

  @override
  Widget build(BuildContext context) {
    if (!profile.isComplete) {
      return _GuideWorkflowMessage(
        text: _localizedText(
          context,
          pt: 'Responda às perguntas acima. A rota correta aparecerá aqui sem misturar instruções que não se aplicam a você.',
          es: 'Responde las preguntas de arriba. La ruta correcta aparecerá aquí sin mezclar instrucciones que no se aplican a tu caso.',
          en: 'Answer the questions above. Your route will appear here without mixing in instructions that do not apply to you.',
        ),
      );
    }
    if (profile.isExempt) return const _CriminalRecordExemptionCard();

    final isOnline = profile.route == CriminalRecordRoute.onlineOrInPerson;
    final timing = _timingContent(context, profile.protocolWindow!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CriminalRecordRouteCard(
          icon: isOnline ? Icons.laptop_mac_rounded : Icons.apartment_rounded,
          color: AppColors.primary,
          eyebrow: _localizedText(
            context,
            pt: 'SUA ROTA NA ARGENTINA',
            es: 'TU RUTA EN ARGENTINA',
            en: 'YOUR ARGENTINA ROUTE',
          ),
          title: isOnline
              ? _localizedText(
                  context,
                  pt: 'Pela internet ou presencialmente',
                  es: 'En línea o presencial',
                  en: 'Online or in person',
                )
              : _localizedText(
                  context,
                  pt: 'Atendimento presencial',
                  es: 'Atención presencial',
                  en: 'In-person service',
                ),
          body: isOnline
              ? _localizedText(
                  context,
                  pt: 'Com DNI argentino e mais de 18 anos, você pode usar Mi Argentina, AFIP, ANSES ou Banelco; a rota presencial continua disponível.',
                  es: 'Con DNI argentino y más de 18 años, podés usar Mi Argentina, AFIP, ANSES o Banelco; la vía presencial sigue disponible.',
                  en: 'With an Argentine DNI and age 18+, you can use Mi Argentina, AFIP, ANSES, or Banelco; the in-person route remains available.',
                )
              : _localizedText(
                  context,
                  pt: 'Sem DNI argentino, o RNR orienta maiores de 18 anos a fazer o pedido em uma unidade presencial.',
                  es: 'Sin DNI argentino, el RNR indica que los mayores de 18 años deben hacer el trámite en una sede presencial.',
                  en: 'Without an Argentine DNI, RNR directs adults to request the certificate at an in-person office.',
                ),
        ),
        const SizedBox(height: 10),
        _CriminalRecordRouteCard(
          icon: timing.$1,
          color: timing.$2,
          eyebrow: _localizedText(
            context,
            pt: 'MELHOR MOMENTO',
            es: 'MEJOR MOMENTO',
            en: 'BEST TIMING',
          ),
          title: timing.$3,
          body: timing.$4,
        ),
        if (profile.otherCountries.isNotEmpty) ...[
          const SizedBox(height: 10),
          _CriminalRecordRouteCard(
            icon: Icons.public_rounded,
            color: AppColors.warning,
            eyebrow: _localizedText(
              context,
              pt: 'OUTROS PAÍSES',
              es: 'OTROS PAÍSES',
              en: 'OTHER COUNTRIES',
            ),
            title: profile.otherCountries.join(' · '),
            body: _localizedText(
              context,
              pt: 'O certificado argentino não cobre esses países. Solicite cada documento na autoridade oficial correspondente e confirme legalização, tradução e aceitação com a PF.',
              es: 'El certificado argentino no cubre estos países. Solicitá cada documento ante la autoridad oficial correspondiente y confirmá legalización, traducción y aceptación con la PF.',
              en: 'The Argentine certificate does not cover these countries. Request each record from its official authority and confirm legalization, translation, and acceptance with Federal Police.',
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  onLinkTap(_rnrFaqUrl, 'Registro Nacional de Reincidencia'),
              icon: const Icon(Icons.verified_outlined, size: 16),
              label: Text(
                _localizedText(
                  context,
                  pt: 'Requisitos do RNR',
                  es: 'Requisitos del RNR',
                  en: 'RNR requirements',
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => onLinkTap(_pfUrl, 'Polícia Federal'),
              icon: const Icon(Icons.fact_check_outlined, size: 16),
              label: Text(
                _localizedText(
                  context,
                  pt: 'Exigências da PF',
                  es: 'Requisitos de la PF',
                  en: 'Federal Police requirements',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _CriminalRecordRecoveryCard(),
      ],
    );
  }

  (IconData, Color, String, String) _timingContent(
    BuildContext context,
    CriminalRecordProtocolWindow window,
  ) {
    return switch (window) {
      CriminalRecordProtocolWindow.withinThirtyDays => (
        Icons.play_circle_outline_rounded,
        AppColors.success,
        _localizedText(
          context,
          pt: 'Você já pode solicitar',
          es: 'Ya podés solicitarlo',
          en: 'You can request it now',
        ),
        _localizedText(
          context,
          pt: 'Como o protocolo está próximo, emita agora e confirme a regra vigente antes do atendimento.',
          es: 'Como la presentación está próxima, emitilo ahora y confirmá la regla vigente antes del turno.',
          en: 'Because filing is close, request it now and confirm the current rule before your appointment.',
        ),
      ),
      CriminalRecordProtocolWindow.oneToThreeMonths => (
        Icons.calendar_month_outlined,
        AppColors.warning,
        _localizedText(
          context,
          pt: 'Prepare agora e emita mais perto',
          es: 'Prepará ahora y emitilo más cerca',
          en: 'Prepare now, request closer to filing',
        ),
        _localizedText(
          context,
          pt: 'Confirme sua rota e os meios de acesso agora. Solicite quando a data do protocolo estiver mais firme.',
          es: 'Confirmá ahora tu ruta y medios de acceso. Solicitá cuando la fecha de presentación esté más definida.',
          en: 'Confirm your route and access methods now. Request once your filing date is firmer.',
        ),
      ),
      CriminalRecordProtocolWindow.moreThanThreeMonths => (
        Icons.hourglass_top_rounded,
        AppColors.warning,
        _localizedText(
          context,
          pt: 'Ainda não emita',
          es: 'Todavía no lo emitas',
          en: 'Do not request it yet',
        ),
        _localizedText(
          context,
          pt: 'Mapeie os países e deixe a rota pronta, mas evite emitir cedo demais. Volte quando o protocolo estiver mais próximo.',
          es: 'Mapeá los países y dejá la ruta lista, pero evitá emitir demasiado pronto. Volvé cuando la presentación esté más cerca.',
          en: 'Map the countries and prepare the route, but avoid requesting too early. Return when filing is closer.',
        ),
      ),
      CriminalRecordProtocolWindow.unknown => (
        Icons.event_note_outlined,
        AppColors.primary,
        _localizedText(
          context,
          pt: 'Defina primeiro o protocolo',
          es: 'Primero definí la presentación',
          en: 'Define your filing window first',
        ),
        _localizedText(
          context,
          pt: 'Entenda a rota agora, mas espere para emitir até ter uma previsão mais segura de atendimento na PF.',
          es: 'Entendé la ruta ahora, pero esperá para emitir hasta tener una previsión más segura del turno en la PF.',
          en: 'Understand the route now, but wait to request until you have a safer Federal Police filing estimate.',
        ),
      ),
    };
  }
}

class _CriminalRecordRouteCard extends StatelessWidget {
  const _CriminalRecordRouteCard({
    required this.icon,
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CriminalRecordExemptionCard extends StatelessWidget {
  const _CriminalRecordExemptionCard();

  @override
  Widget build(BuildContext context) {
    return _CriminalRecordRouteCard(
      icon: Icons.verified_user_outlined,
      color: AppColors.success,
      eyebrow: _localizedText(
        context,
        pt: 'DISPENSA PARA ESTA RESIDÊNCIA',
        es: 'EXENCIÓN PARA ESTA RESIDENCIA',
        en: 'EXEMPT FOR THIS RESIDENCE ROUTE',
      ),
      title: _localizedText(
        context,
        pt: 'Menores de 18 anos são dispensados',
        es: 'Los menores de 18 años están exentos',
        en: 'Applicants under 18 are exempt',
      ),
      body: _localizedText(
        context,
        pt: 'A lista atual da Polícia Federal dispensa menores de 18 anos da certidão e da declaração de antecedentes nesta rota. Confirme a página oficial antes do protocolo.',
        es: 'La lista actual de la Policía Federal exime a menores de 18 años del certificado y la declaración de antecedentes en esta vía. Confirmá la página oficial antes de presentar.',
        en: 'The current Federal Police list exempts applicants under 18 from the criminal record certificate and declaration for this route. Confirm the official page before filing.',
      ),
    );
  }
}

class _CriminalRecordRecoveryCard extends StatelessWidget {
  const _CriminalRecordRecoveryCard();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: AppColors.surfaceMutedFor(context),
      collapsedBackgroundColor: AppColors.surfaceMutedFor(context),
      leading: const Icon(Icons.support_agent_rounded, size: 19),
      title: Text(
        _localizedText(
          context,
          pt: 'Se algo der errado',
          es: 'Si algo sale mal',
          en: 'If something goes wrong',
        ),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      children: [
        Text(
          _localizedText(
            context,
            pt: '• O prazo começa após a confirmação do pagamento.\n• Se o e-mail não chegar, confira o spam.\n• O RNR permite pedir correção em até 15 dias corridos da emissão.\n• Guarde o PDF original com assinatura digital e os códigos de download.',
            es: '• El plazo comienza cuando se acredita el pago.\n• Si no llega el correo, revisá spam.\n• El RNR permite pedir correcciones dentro de los 15 días corridos desde la emisión.\n• Guardá el PDF original con firma digital y los códigos de descarga.',
            en: '• Processing starts after payment is confirmed.\n• If the email does not arrive, check spam.\n• RNR allows correction requests within 15 calendar days of issuance.\n• Keep the original digitally signed PDF and download codes.',
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.55),
        ),
      ],
    );
  }
}

class _CriminalRecordOutcomeChecklist extends StatelessWidget {
  const _CriminalRecordOutcomeChecklist({
    required this.outcomes,
    required this.completedIds,
    required this.onToggle,
  });

  final List<CriminalRecordOutcome> outcomes;
  final Set<String> completedIds;
  final Future<void> Function(CriminalRecordOutcome outcome) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final outcome in outcomes) ...[
          Semantics(
            button: true,
            checked: completedIds.contains(outcome.id),
            child: InkWell(
              onTap: () => onToggle(outcome),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: completedIds.contains(outcome.id)
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: completedIds.contains(outcome.id)
                        ? AppColors.success.withValues(alpha: 0.24)
                        : AppColors.borderFor(context),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      completedIds.contains(outcome.id)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: completedIds.contains(outcome.id)
                          ? AppColors.success
                          : AppColors.textSoftFor(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _label(context, outcome),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: completedIds.contains(outcome.id)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (outcome != outcomes.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _label(BuildContext context, CriminalRecordOutcome outcome) {
    return switch (outcome.kind) {
      CriminalRecordOutcomeKind.requested => _localizedText(
        context,
        pt: 'Solicitei o certificado de ${outcome.country}',
        es: 'Solicité el certificado de ${outcome.country}',
        en: 'Requested the ${outcome.country} certificate',
      ),
      CriminalRecordOutcomeKind.receivedAndVerified => _localizedText(
        context,
        pt: 'Recebi e guardei o documento de ${outcome.country}',
        es: 'Recibí y guardé el documento de ${outcome.country}',
        en: 'Received and saved the ${outcome.country} document',
      ),
      CriminalRecordOutcomeKind.acceptanceChecked => _localizedText(
        context,
        pt: 'Confirmei validade, legalização e tradução na Polícia Federal',
        es: 'Confirmé vigencia, legalización y traducción con la Policía Federal',
        en: 'Confirmed validity, legalization, and translation with Federal Police',
      ),
    };
  }
}

// ─── Companion Quick Reference Card ──────────────────────────────────────────

class _QuickReferenceCard extends StatelessWidget {
  const _QuickReferenceCard({required this.item});

  final GuideActionItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final locale = Localizations.localeOf(context).languageCode;

    final phrases = item.survivalPhrases ?? const <SurvivalPhrase>[];
    final requirements = item.requirements ?? const <String>[];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E35) : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1A3060) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.flash_on_rounded,
                  size: 14,
                  color: Color(0xFF3B7CC8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _headerLabel(locale),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B7CC8),
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phrases.isNotEmpty) ...[
                  _RefRow(
                    icon: Icons.record_voice_over_rounded,
                    label: _sayLabel(locale),
                    value: phrases.map((phrase) => phrase.phrase).join(' • '),
                    isDark: isDark,
                  ),
                  if (requirements.isNotEmpty) const SizedBox(height: 8),
                ],
                if (requirements.isNotEmpty)
                  _RefRow(
                    icon: Icons.inventory_2_outlined,
                    label: _bringLabel(locale),
                    value: requirements.join(' • '),
                    isDark: isDark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _headerLabel(String locale) => switch (locale) {
    'pt' => 'DOCUMENTOS E FRASES ÚTEIS',
    'es' => 'DOCUMENTOS Y FRASES ÚTILES',
    _ => 'USEFUL DOCUMENTS AND PHRASES',
  };

  String _sayLabel(String locale) => switch (locale) {
    'pt' => 'O que dizer',
    'es' => 'Que decir',
    _ => 'What to say',
  };

  String _bringLabel(String locale) => switch (locale) {
    'pt' => 'O que levar',
    'es' => 'Que llevar',
    _ => 'What to bring',
  };
}

class _RefRow extends StatelessWidget {
  const _RefRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF3B7CC8)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.textSoftFor(context),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── CPF Chain Unlock Banner ──────────────────────────────────────────────────

class _CpfUnlockBanner extends StatelessWidget {
  const _CpfUnlockBanner({required this.allItems});

  final List<GuideActionItem> allItems;

  static const _kUnlockColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final unlocked = allItems
        .where(
          (it) => it.dependencies.contains('item_2_1_cpf') && !it.isCompleted,
        )
        .toList();

    if (unlocked.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F2D18) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF1D6A35) : const Color(0xFFBBF7D0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_open_rounded, size: 14, color: _kUnlockColor),
                const SizedBox(width: 6),
                Text(
                  _unlockLabel(context, unlocked.length),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kUnlockColor,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: unlocked
                  .map((it) => _UnlockChip(item: it, isDark: isDark))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _unlockLabel(BuildContext context, int count) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (locale) {
      'pt' => 'Este passo desbloqueia $count próximos passos:',
      'es' => 'Este paso desbloquea $count próximos pasos:',
      _ => 'This step unlocks $count next steps:',
    };
  }
}

class _UnlockChip extends StatelessWidget {
  const _UnlockChip({required this.item, required this.isDark});

  final GuideActionItem item;
  final bool isDark;

  static String _emoji(GuideActionType type) => switch (type) {
    GuideActionType.informative => '📋',
    GuideActionType.external => '🔗',
    GuideActionType.tool => '🛠',
    GuideActionType.checklist => '✅',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A2015) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _emoji(item.type),
            style: const TextStyle(fontSize: 10, height: 1),
          ),
          const SizedBox(width: 4),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pre-arrival Timing Banner ─────────────────────────────────────────────────
//
// Shown in the execution sheet when an item is marked preArrivalRequired and is
// not yet complete. Gives the user a timeline-aware sense of urgency based on
// their plan's declared migration window.

class _PreArrivalTimingBanner extends StatelessWidget {
  const _PreArrivalTimingBanner({required this.timeline});

  final String timeline;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final locale = Localizations.localeOf(context).languageCode;
    final message = _message(locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A0A) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF5A4A00) : const Color(0xFFFDE68A),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.flight_takeoff_rounded,
              size: 15,
              color: Color(0xFFD97706),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97706),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _message(String locale) {
    return switch (timeline) {
      'in_0_3m' => switch (locale) {
        'pt' =>
          'Sua mudança é em menos de 3 meses — resolva isso antes de embarcar.',
        'es' =>
          'Tu mudanza es en menos de 3 meses — resuelve esto antes de viajar.',
        _ => 'Your move is within 3 months — handle this before you board.',
      },
      'in_3_6m' => switch (locale) {
        'pt' =>
          'Você ainda tem 3–6 meses — ótimo momento para resolver isso sem pressa.',
        'es' =>
          'Todavía tienes 3–6 meses — buen momento para resolverlo sin apuros.',
        _ => 'You still have 3–6 months — a good time to handle this calmly.',
      },
      'in_6_12m' => switch (locale) {
        'pt' =>
          'Você tem 6–12 meses — comece agora para não acumular no final.',
        'es' => 'Tienes 6–12 meses — empieza ahora para no acumular al final.',
        _ => 'You have 6–12 months — start now to avoid a last-minute rush.',
      },
      _ => switch (locale) {
        'pt' => 'Este passo pode precisar ser resolvido antes da viagem.',
        'es' => 'Este paso puede necesitar resolverse antes del viaje.',
        _ => 'This step may need attention before you travel.',
      },
    };
  }
}
