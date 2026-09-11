import 'package:flutter/material.dart';
import 'package:mudavi_app/features/migration_questionnaire/presentation/widgets/landing_budget_runway_card.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mudavi_app/app/localization/app_localization.dart';
import 'package:mudavi_app/app/theme/app_colors.dart';
import 'package:mudavi_app/app/theme/app_typography.dart';
import 'package:mudavi_app/core/widgets/multi_currency_amount.dart';
import 'package:mudavi_app/core/widgets/frosted_panel.dart';
import 'package:mudavi_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:mudavi_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/landing_budget_estimator.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_plan_identity.dart';
import 'package:mudavi_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class LandingBudgetEstimatorSection extends StatefulWidget {
  const LandingBudgetEstimatorSection({
    required this.plan,
    this.exchangeRates,
    this.preferredCountryId,
    this.progressStore,
    super.key,
  });

  final MigrationPlan plan;
  final MigrationCopilotProgressStore? progressStore;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  @override
  State<LandingBudgetEstimatorSection> createState() =>
      _LandingBudgetEstimatorSectionState();
}

class _LandingBudgetEstimatorSectionState
    extends State<LandingBudgetEstimatorSection> {
  late final MigrationCopilotProgressStore _progressStore =
      widget.progressStore ?? MigrationCopilotProgressStore();
  Map<String, int> _customValues = const {};

  @override
  void initState() {
    super.initState();
    _loadCustomValues();
  }

  @override
  void didUpdateWidget(LandingBudgetEstimatorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (MigrationPlanIdentity.storageKeyFor(oldWidget.plan) !=
        MigrationPlanIdentity.storageKeyFor(widget.plan)) {
      _customValues = const {};
      _loadCustomValues();
    }
  }

  Future<void> _loadCustomValues() async {
    final key = MigrationPlanIdentity.storageKeyFor(widget.plan);
    final snapshot = await _progressStore.read(widget.plan);
    if (mounted && key == MigrationPlanIdentity.storageKeyFor(widget.plan)) {
      setState(() => _customValues = snapshot.landingBudgetOverrides);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estimate = LandingBudgetEstimator.build(plan: widget.plan);
    final summary = _summaryLabel(context, estimate.summaryKey);
    final title = estimate.cityContext == null
        ? l10n.landingBudgetSectionTitle
        : l10n.landingBudgetSectionTitleWithCity(estimate.cityContext!);

    final cityBudget = widget.plan.isCityConfirmed
        ? widget.plan.confirmedCity?.budgetSnapshot
        : null;
    final customScenario = _customScenario();

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _BudgetAssumptionsNote(estimate: estimate),
          if (cityBudget != null) ...[
            const SizedBox(height: 18),
            _CityRealCostSection(
              budget: cityBudget,
              exchangeRates: widget.exchangeRates,
              preferredCountryId: widget.preferredCountryId,
            ),
          ],
          if (_hasEducationContext(widget.plan)) ...[
            const SizedBox(height: 18),
            _EducationBudgetNote(plan: widget.plan),
          ],
          const SizedBox(height: 18),
          if (widget.exchangeRates != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                l10n.landingBudgetExchangeUpdatedAt(
                  _formatUpdatedAt(context, widget.exchangeRates!.fetchedAt),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                l10n.landingBudgetExchangeUnavailable,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  customScenario == null
                      ? _text(
                          context,
                          pt: 'Use seus valores reais',
                          es: 'Usá tus valores reales',
                          en: 'Use your actual values',
                        )
                      : _text(
                          context,
                          pt: 'Seu orçamento está ativo',
                          es: 'Tu presupuesto está activo',
                          en: 'Your budget is active',
                        ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: _editCustomValues,
                icon: Icon(
                  customScenario == null
                      ? Icons.edit_outlined
                      : Icons.tune_rounded,
                  size: 18,
                ),
                label: Text(
                  customScenario == null
                      ? _text(
                          context,
                          pt: 'Preencher',
                          es: 'Completar',
                          en: 'Enter values',
                        )
                      : _text(context, pt: 'Editar', es: 'Editar', en: 'Edit'),
                ),
              ),
              if (customScenario != null)
                IconButton(
                  tooltip: _text(
                    context,
                    pt: 'Voltar às estimativas',
                    es: 'Volver a las estimaciones',
                    en: 'Use estimates again',
                  ),
                  onPressed: _clearCustomValues,
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (customScenario != null &&
              _customValues['availableBrl'] != null) ...[
            LandingBudgetRunwayCard(
              availableBrl: _customValues['availableBrl']!,
              monthlyBrl: customScenario.breakdown.monthlyBaseBrl,
              setupBrl: customScenario.breakdown.setupBrl,
              bufferBrl: customScenario.breakdown.bufferBrl,
              months: _customValues['monthsWithoutIncome'] ?? 3,
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 960;
              final medium = constraints.maxWidth >= 640;
              final cardWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : medium
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final scenario
                      in customScenario == null
                          ? estimate.scenarios
                          : [customScenario])
                    SizedBox(
                      width: cardWidth,
                      child: _ScenarioCard(
                        scenario: scenario,
                        title: customScenario == null
                            ? _scenarioTitle(context, scenario.titleKey)
                            : _text(
                                context,
                                pt: 'Meu orçamento',
                                es: 'Mi presupuesto',
                                en: 'My budget',
                              ),
                        description: _scenarioBody(
                          context,
                          scenario.descriptionKey,
                        ),
                        exchangeRates: widget.exchangeRates,
                        preferredCountryId: widget.preferredCountryId,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            l10n.landingBudgetDisclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  LandingBudgetScenarioEstimate? _customScenario() {
    final monthly = _customValues['monthlyBaseBrl'];
    final setup = _customValues['setupBrl'];
    final buffer = _customValues['bufferBrl'];
    if (monthly == null || setup == null || buffer == null) return null;
    return LandingBudgetScenarioEstimate(
      scenario: LandingBudgetScenario.balanced,
      titleKey: 'custom',
      descriptionKey: 'custom',
      breakdown: LandingBudgetBreakdown(
        monthlyBaseBrl: monthly,
        setupBrl: setup,
        bufferBrl: buffer,
        total30DaysBrl: monthly + setup + buffer,
        total90DaysBrl: (monthly * 3) + setup + buffer,
      ),
    );
  }

  Future<void> _clearCustomValues() async {
    await _progressStore.writeLandingBudgetOverrides(
      plan: widget.plan,
      values: const {},
    );
    if (mounted) setState(() => _customValues = const {});
  }

  Future<void> _editCustomValues() async {
    final generated = LandingBudgetEstimator.build(plan: widget.plan).scenarios
        .firstWhere(
          (scenario) => scenario.scenario == LandingBudgetScenario.balanced,
        )
        .breakdown;
    var monthlyText =
        (_customValues['monthlyBaseBrl'] ?? generated.monthlyBaseBrl)
            .toString();
    var setupText = (_customValues['setupBrl'] ?? generated.setupBrl)
        .toString();
    var bufferText = (_customValues['bufferBrl'] ?? generated.bufferBrl)
        .toString();
    final editingPlan = widget.plan;
    final editingKey = MigrationPlanIdentity.storageKeyFor(editingPlan);
    var availableText = _customValues['availableBrl']?.toString() ?? '';
    var months = _customValues['monthsWithoutIncome'] ?? 3;
    if (![1, 3, 6].contains(months)) months = 3;
    String? validationMessage;
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(
            _text(
              context,
              pt: 'Informe seus valores reais',
              es: 'Ingresá tus valores reales',
              en: 'Enter your actual values',
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _text(
                    context,
                    pt: 'Use valores em reais. Eles ficam salvos neste plano e substituem os cenários estimados.',
                    es: 'Usá valores en reales. Quedan guardados en este plan y reemplazan los escenarios estimados.',
                    en: 'Use values in BRL. They are saved in this plan and replace the estimated scenarios.',
                  ),
                ),
                const SizedBox(height: 16),
                _BudgetValueField(
                  key: const ValueKey('landing-budget-monthly-input'),
                  initialValue: monthlyText,
                  onChanged: (value) => monthlyText = value,
                  label: context.l10n.landingBudgetMonthlyBaseLabel,
                ),
                const SizedBox(height: 10),
                _BudgetValueField(
                  key: const ValueKey('landing-budget-setup-input'),
                  initialValue: setupText,
                  onChanged: (value) => setupText = value,
                  label: context.l10n.landingBudgetSetupLabel,
                ),
                const SizedBox(height: 10),
                _BudgetValueField(
                  key: const ValueKey('landing-budget-buffer-input'),
                  initialValue: bufferText,
                  onChanged: (value) => bufferText = value,
                  label: context.l10n.landingBudgetBufferLabel,
                ),
                const SizedBox(height: 10),
                _BudgetValueField(
                  key: const ValueKey('landing-budget-available-input'),
                  initialValue: availableText,
                  onChanged: (value) => availableText = value,
                  label: _text(
                    context,
                    pt: 'Reserva disponível em R\$ (opcional)',
                    es: 'Ahorros disponibles en R\$ (opcional)',
                    en: 'Available savings in BRL (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: months,
                  decoration: InputDecoration(
                    labelText: _text(
                      context,
                      pt: 'Planejar período sem renda',
                      es: 'Planear un período sin ingresos',
                      en: 'Plan a period without income',
                    ),
                  ),
                  items: [
                    for (final value in [1, 3, 6])
                      DropdownMenuItem(
                        value: value,
                        child: Text(
                          _text(
                            context,
                            pt: '$value mês(es)',
                            es: '$value mes(es)',
                            en: '$value month(s)',
                          ),
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => months = value ?? 3),
                ),
                if (validationMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    validationMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                _text(context, pt: 'Cancelar', es: 'Cancelar', en: 'Cancel'),
              ),
            ),
            FilledButton(
              onPressed: () {
                final normalizedAvailable = availableText.trim();
                final available = int.tryParse(normalizedAvailable);
                final monthly = int.tryParse(monthlyText);
                final setup = int.tryParse(setupText);
                final buffer = int.tryParse(bufferText);
                if (monthly == null ||
                    monthly <= 0 ||
                    setup == null ||
                    setup < 0 ||
                    buffer == null ||
                    buffer < 0 ||
                    (normalizedAvailable.isNotEmpty &&
                        (available == null || available < 0))) {
                  setDialogState(() {
                    validationMessage = _text(
                      context,
                      pt: 'Informe uma base mensal maior que zero e valores válidos para instalação e margem.',
                      es: 'Ingresá una base mensual mayor que cero y valores válidos para instalación y margen.',
                      en: 'Enter a monthly base above zero and valid setup and buffer values.',
                    );
                  });
                  return;
                }
                Navigator.pop(dialogContext, {
                  'monthlyBaseBrl': monthly,
                  'setupBrl': setup,
                  'bufferBrl': buffer,
                  'availableBrl': ?available,
                  'monthsWithoutIncome': months,
                });
              },
              child: Text(
                _text(
                  context,
                  pt: 'Salvar orçamento',
                  es: 'Guardar presupuesto',
                  en: 'Save budget',
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null ||
        !mounted ||
        editingKey != MigrationPlanIdentity.storageKeyFor(widget.plan)) {
      return;
    }
    await _progressStore.writeLandingBudgetOverrides(
      plan: editingPlan,
      values: result,
    );
    if (mounted &&
        editingKey == MigrationPlanIdentity.storageKeyFor(widget.plan)) {
      setState(() => _customValues = result);
    }
  }

  String _text(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  bool _hasEducationContext(MigrationPlan plan) {
    return plan.goal == 'study' ||
        plan.travelGroup == 'family_kids' ||
        plan.travelGroup == 'solo_parent' ||
        (plan.childrenCount ?? 0) > 0;
  }

  String _summaryLabel(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'landingBudgetSummaryAsap' => l10n.landingBudgetSummaryAsap,
      'landingBudgetSummarySixMonths' => l10n.landingBudgetSummarySixMonths,
      'landingBudgetSummaryTwelveMonths' =>
        l10n.landingBudgetSummaryTwelveMonths,
      _ => l10n.landingBudgetSummaryResearching,
    };
  }

  String _scenarioTitle(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'landingBudgetLeanTitle' => l10n.landingBudgetLeanTitle,
      'landingBudgetComfortableTitle' => l10n.landingBudgetComfortableTitle,
      _ => l10n.landingBudgetBalancedTitle,
    };
  }

  String _scenarioBody(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'landingBudgetLeanBody' => l10n.landingBudgetLeanBody,
      'landingBudgetComfortableBody' => l10n.landingBudgetComfortableBody,
      'custom' => _text(
        context,
        pt: 'Valores informados por você para planejar o primeiro mês.',
        es: 'Valores informados por vos para planificar el primer mes.',
        en: 'Values you entered to plan your first month.',
      ),
      _ => l10n.landingBudgetBalancedBody,
    };
  }

  String _formatUpdatedAt(BuildContext context, String rawValue) {
    final localeName = Localizations.localeOf(context).toString();
    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    return DateFormat('dd/MM HH:mm', localeName).format(parsed.toLocal());
  }
}

class _BudgetValueField extends StatelessWidget {
  const _BudgetValueField({
    required this.initialValue,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: '$label (BRL)'),
    );
  }
}

class _BudgetAssumptionsNote extends StatelessWidget {
  const _BudgetAssumptionsNote({required this.estimate});

  final LandingBudgetEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final factor = estimate.householdFactor.toStringAsFixed(2);
    final profile = switch (locale) {
      'pt' =>
        '${estimate.householdAdults} adulto(s), '
            '${estimate.householdChildren} criança(s)',
      'es' =>
        '${estimate.householdAdults} adulto(s), '
            '${estimate.householdChildren} niño(s)',
      _ =>
        '${estimate.householdAdults} adult(s), '
            '${estimate.householdChildren} child(ren)',
    };
    final text = estimate.usesCitySnapshot
        ? switch (locale) {
            'pt' =>
              'Como calculamos: a base local considera uma pessoa e aluguel de 1 quarto. Ajustamos para seu perfil ($profile; fator $factor). Confirme o aluguel e os gastos reais da família antes de decidir.',
            'es' =>
              'Cómo calculamos: la base local considera una persona y alquiler de 1 ambiente. La ajustamos a tu perfil ($profile; factor $factor). Confirmá el alquiler y los gastos reales de la familia antes de decidir.',
            _ =>
              'How we calculate it: the local baseline covers one person and a 1-bedroom rental. We adjust it to your profile ($profile; factor $factor). Confirm rent and actual household costs before deciding.',
          }
        : switch (locale) {
            'pt' =>
              'Como calculamos: usamos uma referência estimada de custo e ajustamos para seu perfil ($profile; fator $factor). Sem preços locais confirmados, trate o valor como ponto de partida.',
            'es' =>
              'Cómo calculamos: usamos una referencia estimada de costos y la ajustamos a tu perfil ($profile; factor $factor). Sin precios locales confirmados, tomá el valor como punto de partida.',
            _ =>
              'How we calculate it: we use an estimated cost baseline and adjust it to your profile ($profile; factor $factor). Without confirmed local prices, treat it as a starting point.',
          };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calculate_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
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

class _EducationBudgetNote extends StatelessWidget {
  const _EducationBudgetNote({required this.plan});

  final MigrationPlan plan;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final hasChildren =
        plan.travelGroup == 'family_kids' ||
        plan.travelGroup == 'solo_parent' ||
        (plan.childrenCount ?? 0) > 0;
    String tr({required String pt, required String es, required String en}) =>
        switch (locale) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr(
                    pt: 'Educação no seu orçamento',
                    es: 'Educación en tu presupuesto',
                    en: 'Education in your budget',
                  ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasChildren)
            Text(
              tr(
                pt: 'Escola pública: sem mensalidade. Escola particular, material, uniforme e transporte não entram no total porque dependem da instituição e da rede local.',
                es: 'Escuela pública: sin mensualidad. Escuela privada, materiales, uniforme y transporte no están en el total porque dependen de la institución y la red local.',
                en: 'Public school: no tuition. Private school, supplies, uniforms, and transport are not in the total because they depend on the institution and local network.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          if (hasChildren && plan.goal == 'study') const SizedBox(height: 8),
          if (plan.goal == 'study')
            Text(
              tr(
                pt: 'Universidade pública: sem mensalidade. Mensalidade particular e custos de documentação devem ser adicionados com o valor do curso e do edital escolhidos.',
                es: 'Universidad pública: sin mensualidad. La cuota privada y los documentos deben añadirse con el valor de la carrera y convocatoria elegidas.',
                en: 'Public university: no tuition. Private tuition and document costs should be added using the chosen course and admission rules.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.title,
    required this.description,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final LandingBudgetScenarioEstimate scenario;
  final String title;
  final String description;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final accent = switch (scenario.scenario) {
      LandingBudgetScenario.lean => AppColors.warning,
      LandingBudgetScenario.balanced => AppColors.primary,
      LandingBudgetScenario.comfortable => AppColors.success,
    };
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final total30 = MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: scenario.breakdown.total30DaysBrl,
      exchangeRates: exchangeRates,
      preferredCountryId: preferredCountryId,
      primaryLocale: locale,
    );
    final total90 = MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: scenario.breakdown.total90DaysBrl,
      exchangeRates: exchangeRates,
      preferredCountryId: preferredCountryId,
      primaryLocale: locale,
    );

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: accent),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            total30,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.landingBudget30DaysLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 10),
          MultiCurrencyAmount(
            amountInBrl: scenario.breakdown.total30DaysBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _BudgetLine(
            label: l10n.landingBudgetMonthlyBaseLabel,
            amountInBrl: scenario.breakdown.monthlyBaseBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          _BudgetLine(
            label: l10n.landingBudgetSetupLabel,
            amountInBrl: scenario.breakdown.setupBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          _BudgetLine(
            label: l10n.landingBudgetBufferLabel,
            amountInBrl: scenario.breakdown.bufferBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_outlined, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.landingBudget90DaysLabel(total90),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimaryFor(context),
                      fontWeight: FontWeight.w600,
                    ),
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

// ─── Real city cost breakdown ─────────────────────────────────────────────────

class _CityRealCostSection extends StatelessWidget {
  const _CityRealCostSection({
    required this.budget,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final CityBudgetSnapshot budget;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  static const _kAccent = Color(0xFF3B7CC8);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1829) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1A2840) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_city_rounded,
                size: 14,
                color: _kAccent,
              ),
              const SizedBox(width: 6),
              Text(
                _sectionTitle(locale, budget.cityLabel),
                style: AppTypography.compactBadge.copyWith(
                  color: _kAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ValueRow(
            label: _label(
              locale,
              pt: 'Sem aluguel',
              es: 'Sin alquiler',
              en: 'Excl. rent',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.singlePersonExcludingRent,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: '1 quarto fora do centro',
              es: '1 amb. fuera del centro',
              en: '1-bed outside centre',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.oneBedroomOutsideCentre,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: '1 quarto no centro',
              es: '1 amb. en el centro',
              en: '1-bed city centre',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.oneBedroomCityCentre,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: 'Passe mensal',
              es: 'Pase mensual',
              en: 'Monthly pass',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.monthlyTransportPass,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: 'Utilidades',
              es: 'Servicios',
              en: 'Utilities',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.utilities,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _totalLabel(locale),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
              ),
              Text(
                '${MultiCurrencyAmount.formatPreferredCurrency(context: context, amountInBrl: budget.fairLivingTotal, exchangeRates: exchangeRates, preferredCountryId: preferredCountryId)}–${MultiCurrencyAmount.formatPreferredCurrency(context: context, amountInBrl: budget.wellLivingTotal, exchangeRates: exchangeRates, preferredCountryId: preferredCountryId)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _kAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _sourceNote(locale, budget.sourceLabel, budget.updatedAt),
            style: AppTypography.tinyLabel.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.28)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(String locale, String cityLabel) => switch (locale) {
    'pt' => 'Custos reais em $cityLabel',
    'es' => 'Costos reales en $cityLabel',
    _ => 'Real costs in $cityLabel',
  };

  String _totalLabel(String locale) => switch (locale) {
    'pt' => 'Viver justo → viver bem',
    'es' => 'Vivir justo → vivir bien',
    _ => 'Live fair → live well',
  };

  String _sourceNote(String locale, String source, String date) =>
      switch (locale) {
        'pt' => 'Fonte: $source · atualizado em $date',
        'es' => 'Fuente: $source · actualizado en $date',
        _ => 'Source: $source · updated $date',
      };

  String _label(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) => switch (locale) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTypography.compactBadge.copyWith(
            color: AppColors.textPrimaryFor(context),
          ),
        ),
      ],
    );
  }
}

class _BudgetLine extends StatelessWidget {
  const _BudgetLine({
    required this.label,
    required this.amountInBrl,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final String label;
  final num amountInBrl;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: MultiCurrencyAmount(
                amountInBrl: amountInBrl,
                exchangeRates: exchangeRates,
                preferredCountryId: preferredCountryId,
                compact: true,
                wrapSpacing: 6,
                runSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
