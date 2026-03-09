import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_decision_support_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_entry_cost_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_soft_landing_section.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/arrival_execution_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/landing_budget_estimator_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/migration_document_readiness_section.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/migration_readiness_section.dart';

class MigrationPlanCopilotPage extends StatefulWidget {
  const MigrationPlanCopilotPage({
    required this.controller,
    super.key,
  });

  final MigrationQuestionnaireController controller;

  @override
  State<MigrationPlanCopilotPage> createState() => _MigrationPlanCopilotPageState();
}

class _MigrationPlanCopilotPageState extends State<MigrationPlanCopilotPage> {
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();
  final Set<String> _completedReadinessItems = <String>{};
  final Set<String> _completedDocumentItems = <String>{};
  final Set<String> _completedArrivalItems = <String>{};
  String? _loadedPlanKey;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didUpdateWidget(covariant MigrationPlanCopilotPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPlanKey != _loadedPlanKey) {
      _loadProgress();
    }
  }

  String? get _currentPlanKey {
    final plan = widget.controller.generatedPlan;
    if (plan == null) {
      return null;
    }

    final cityId = plan.recommendedCity?.id ?? 'no-city';
    return [
      plan.originCountry,
      plan.destinationCountry,
      plan.goal,
      plan.timeline,
      cityId,
    ].join('::');
  }

  Future<void> _loadProgress() async {
    final plan = widget.controller.generatedPlan;
    if (plan == null) {
      return;
    }

    final snapshot = await _progressStore.read(plan);
    if (!mounted) {
      return;
    }

    setState(() {
      _loadedPlanKey = _currentPlanKey;
      _completedReadinessItems
        ..clear()
        ..addAll(snapshot.readinessCompletedIds);
      _completedDocumentItems
        ..clear()
        ..addAll(snapshot.documentCompletedIds);
      _completedArrivalItems
        ..clear()
        ..addAll(snapshot.arrivalCompletedIds);
    });
  }

  Future<void> _persistProgress() async {
    final plan = widget.controller.generatedPlan;
    if (plan == null) {
      return;
    }

    await _progressStore.write(
      plan: plan,
      readinessCompletedIds: _completedReadinessItems,
      documentCompletedIds: _completedDocumentItems,
      arrivalCompletedIds: _completedArrivalItems,
    );
  }

  void _toggleReadinessItem(String itemId) {
    setState(() {
      if (!_completedReadinessItems.add(itemId)) {
        _completedReadinessItems.remove(itemId);
      }
    });
    _persistProgress();
  }

  void _toggleDocumentItem(String itemId) {
    setState(() {
      if (!_completedDocumentItems.add(itemId)) {
        _completedDocumentItems.remove(itemId);
      }
    });
    _persistProgress();
  }

  void _toggleArrivalItem(String itemId) {
    setState(() {
      if (!_completedArrivalItems.add(itemId)) {
        _completedArrivalItems.remove(itemId);
      }
    });
    _persistProgress();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = widget.controller.generatedPlan;
    final recommendedCity = plan?.recommendedCity;

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

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.migrationPlanCopilotTitle,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.migrationPlanCopilotIntroTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            recommendedCity == null
                                ? l10n.migrationPlanCopilotIntroBody
                                : l10n.migrationPlanCopilotIntroBodyWithCity(
                                    recommendedCity.name,
                                    recommendedCity.stateCode,
                                  ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MigrationReadinessSection(
                      plan: plan,
                      completedItemIds: _completedReadinessItems,
                      onToggleItem: _toggleReadinessItem,
                    ),
                    const SizedBox(height: 16),
                    MigrationDocumentReadinessSection(
                      plan: plan,
                      completedItemIds: _completedDocumentItems,
                      onToggleItem: _toggleDocumentItem,
                    ),
                    const SizedBox(height: 16),
                    LandingBudgetEstimatorSection(plan: plan),
                    const SizedBox(height: 16),
                    HousingDecisionSupportSection(
                      cityName: recommendedCity?.name,
                    ),
                    const SizedBox(height: 16),
                    HousingEntryCostSection(
                      cityName: recommendedCity?.name,
                    ),
                    const SizedBox(height: 16),
                    const HousingSoftLandingSection(),
                    const SizedBox(height: 16),
                    ArrivalExecutionSection(
                      plan: plan,
                      completedItemIds: _completedArrivalItems,
                      onToggleItem: _toggleArrivalItem,
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
}
