import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/info/application/guide_toolkit_engine.dart';
import 'package:movaro_app/features/info/domain/entities/guide_toolkit.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

class GuideToolkitPage extends StatefulWidget {
  const GuideToolkitPage({
    required this.request,
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final GuideToolkitRequest request;
  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  State<GuideToolkitPage> createState() => _GuideToolkitPageState();
}

class _GuideToolkitPageState extends State<GuideToolkitPage> {
  final _engine = const GuideToolkitEngine();
  final Set<String> _answers = {};
  final Map<String, TextEditingController> _amountControllers = {};
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    for (final id in const [
      'rent',
      'housingFees',
      'living',
      'travel',
      'setup',
    ]) {
      _amountControllers[id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, double> get _amounts {
    final values = <String, double>{};
    for (final entry in _amountControllers.entries) {
      final normalized = entry.value.text
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      values[entry.key] = double.tryParse(normalized) ?? 0;
    }
    values['months'] = _answers.contains('reserve90')
        ? 3
        : _answers.contains('reserve60')
        ? 2
        : 1;
    values['guaranteeMonths'] = _answers.contains('deposit') ? 3 : 0;
    return values;
  }

  void _toggle(_ToolOption option) {
    HapticFeedback.selectionClick();
    setState(() {
      if (option.group != null) {
        _answers.removeWhere(
          (value) => _config.options.any(
            (candidate) =>
                candidate.id == value && candidate.group == option.group,
          ),
        );
        _answers.add(option.id);
      } else if (!_answers.add(option.id)) {
        _answers.remove(option.id);
      }
      _showResult = false;
    });
  }

  _ToolConfig get _config => _toolConfig(context, widget.request.kind);

  void _calculate() {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final result = _engine.evaluate(
      kind: widget.request.kind,
      answers: _answers,
      amounts: _amounts,
    );
    final city = widget
        .migrationQuestionnaireController
        .generatedPlan
        ?.currentPlanCity
        ?.name;
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
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
                    title: config.shortTitle,
                    subtitle: _t(
                      context,
                      pt: 'Ferramenta independente · não altera o plano',
                      es: 'Herramienta independiente · no cambia el plan',
                      en: 'Standalone tool · does not change your plan',
                    ),
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: ListView(
                        key: const Key('guide-toolkit-scroll'),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          20,
                          context.pageHorizontalPadding,
                          132,
                        ),
                        children: [
                          _ToolkitHero(config: config, cityName: city),
                          const SizedBox(height: 18),
                          if (config.amountFields.isNotEmpty)
                            _AmountsCard(
                              fields: config.amountFields,
                              controllers: _amountControllers,
                              onChanged: () =>
                                  setState(() => _showResult = false),
                            ),
                          if (config.amountFields.isNotEmpty)
                            const SizedBox(height: 14),
                          if (config.options.isNotEmpty)
                            _OptionsCard(
                              title: config.question,
                              help: config.questionHelp,
                              options: config.options,
                              selected: _answers,
                              onToggle: _toggle,
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              key: const Key('guide-toolkit-calculate'),
                              onPressed: _calculate,
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: Text(config.cta),
                            ),
                          ),
                          if (_showResult) ...[
                            const SizedBox(height: 20),
                            _ResultCard(
                              config: config,
                              result: result,
                              actionLabels: _actionLabels(context),
                            ),
                            const SizedBox(height: 14),
                            _TrustCard(
                              requiresProfessional: result.requiresProfessional,
                              riskNotice: config.riskNotice,
                              sources: config.sources,
                              onSource: _openSource,
                            ),
                          ],
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
        currentIndex: 3,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController:
            widget.migrationQuestionnaireController,
      ),
    );
  }

  void _openSource(_ToolSource source) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: source.publisher,
          uri: Uri.parse(source.url),
        ),
      ),
    );
  }
}

class _ToolkitHero extends StatelessWidget {
  const _ToolkitHero({required this.config, required this.cityName});
  final _ToolConfig config;
  final String? cityName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: config.colors,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: config.colors.last.withValues(alpha: 0.24),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(config.icon, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              config.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.12,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              config.body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroPill(
                  icon: Icons.lock_outline_rounded,
                  label: _t(
                    context,
                    pt: 'Não altera o plano',
                    es: 'No cambia el plan',
                    en: 'Does not change your plan',
                  ),
                ),
                if (cityName != null)
                  _HeroPill(
                    icon: Icons.location_on_outlined,
                    label: _t(
                      context,
                      pt: '$cityName como referência',
                      es: '$cityName como referencia',
                      en: '$cityName as reference',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountsCard extends StatelessWidget {
  const _AmountsCard({
    required this.fields,
    required this.controllers,
    required this.onChanged,
  });
  final List<_AmountField> fields;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              _t(
                context,
                pt: 'Valores aproximados',
                es: 'Valores aproximados',
                en: 'Approximate amounts',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _t(
              context,
              pt: 'Use valores mensais em reais. Você pode deixar campos desconhecidos em branco.',
              es: 'Usá valores mensuales en reales. Podés dejar en blanco lo que no sepas.',
              en: 'Use monthly values in reais. Leave unknown fields blank.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 16),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                key: Key('guide-toolkit-${field.id}'),
                controller: controllers[field.id],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => onChanged(),
                decoration: InputDecoration(
                  labelText: field.label,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        'BRL',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  helperText: field.help,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.title,
    required this.help,
    required this.options,
    required this.selected,
    required this.onToggle,
  });
  final String title;
  final String help;
  final List<_ToolOption> options;
  final Set<String> selected;
  final ValueChanged<_ToolOption> onToggle;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            help,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 15),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Semantics(
                button: true,
                selected: selected.contains(option.id),
                child: InkWell(
                  onTap: () => onToggle(option),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: selected.contains(option.id)
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : AppColors.surfaceMutedFor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected.contains(option.id)
                            ? AppColors.primary
                            : AppColors.borderFor(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected.contains(option.id)
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: selected.contains(option.id)
                              ? AppColors.primary
                              : AppColors.textSoftFor(context),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            option.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
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
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.config,
    required this.result,
    required this.actionLabels,
  });
  final _ToolConfig config;
  final GuideToolkitResult result;
  final Map<String, String> actionLabels;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: _t(
        context,
        pt: 'Resultado preparado',
        es: 'Resultado preparado',
        en: 'Result ready',
      ),
      child: FrostedPanel(
        padding: const EdgeInsets.all(22),
        gradient: LinearGradient(
          colors: AppColors.isDark(context)
              ? const [Color(0xFF15243B), Color(0xFF0B1524)]
              : const [Color(0xFFF5FAFF), Color(0xFFEAF4FF)],
        ),
        borderColor: AppColors.primary.withValues(alpha: 0.22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    config.resultTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            if (result.monthlyTotal != null) ...[
              const SizedBox(height: 18),
              _MoneyResult(
                label: _t(
                  context,
                  pt: 'Custo mensal informado',
                  es: 'Costo mensual informado',
                  en: 'Monthly cost entered',
                ),
                value: result.monthlyTotal!,
              ),
            ],
            if (result.entryTotal != null) ...[
              const SizedBox(height: 8),
              _MoneyResult(
                label: _t(
                  context,
                  pt: 'Custo inicial estimado',
                  es: 'Costo inicial estimado',
                  en: 'Estimated entry cost',
                ),
                value: result.entryTotal!,
              ),
            ],
            if (result.reserveTotal != null) ...[
              const SizedBox(height: 8),
              _MoneyResult(
                label: _t(
                  context,
                  pt: 'Reserva para o período',
                  es: 'Reserva para el período',
                  en: 'Reserve for the period',
                ),
                value: result.reserveTotal!,
                highlighted: true,
              ),
            ],
            const SizedBox(height: 18),
            Text(
              _t(
                context,
                pt: 'Seu caminho sugerido',
                es: 'Tu camino sugerido',
                en: 'Your suggested path',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final entry in result.actionIds.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${entry.$1 + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        actionLabels[entry.$2] ?? entry.$2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          fontWeight: FontWeight.w600,
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

class _MoneyResult extends StatelessWidget {
  const _MoneyResult({
    required this.label,
    required this.value,
    this.highlighted = false,
  });
  final String label;
  final double value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.11)
            : AppColors.surfaceFor(context).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: value,
              exchangeRates: null,
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: highlighted ? AppColors.primary : null,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.requiresProfessional,
    required this.riskNotice,
    required this.sources,
    required this.onSource,
  });
  final bool requiresProfessional;
  final String? riskNotice;
  final List<_ToolSource> sources;
  final ValueChanged<_ToolSource> onSource;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (requiresProfessional ? AppColors.caution : AppColors.success)
            .withValues(alpha: 0.08),
        border: Border.all(
          color: (requiresProfessional ? AppColors.caution : AppColors.success)
              .withValues(alpha: 0.24),
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                requiresProfessional
                    ? Icons.shield_outlined
                    : Icons.verified_outlined,
                color: requiresProfessional
                    ? AppColors.caution
                    : AppColors.success,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  requiresProfessional
                      ? riskNotice ??
                            _t(
                              context,
                              pt: 'Esta é uma triagem. Confirme a decisão com um profissional que conheça os dois países.',
                              es: 'Esto es una orientación inicial. Confirmá la decisión con un profesional que conozca ambos países.',
                              en: 'This is a screening. Confirm the decision with a professional who understands both countries.',
                            )
                      : _t(
                          context,
                          pt: 'Orientação prática baseada em fontes públicas. Exigências locais podem variar.',
                          es: 'Orientación práctica basada en fuentes públicas. Los requisitos locales pueden variar.',
                          en: 'Practical guidance based on public sources. Local requirements may vary.',
                        ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final source in sources)
            TextButton.icon(
              onPressed: () => onSource(source),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                _t(
                  context,
                  pt: 'Abrir fonte: ${source.publisher}',
                  es: 'Abrir fuente: ${source.publisher}',
                  en: 'Open source: ${source.publisher}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolConfig {
  const _ToolConfig({
    required this.shortTitle,
    required this.title,
    required this.body,
    required this.icon,
    required this.colors,
    required this.question,
    required this.questionHelp,
    required this.options,
    required this.amountFields,
    required this.cta,
    required this.resultTitle,
    required this.sources,
    this.riskNotice,
  });
  final String shortTitle;
  final String title;
  final String body;
  final IconData icon;
  final List<Color> colors;
  final String question;
  final String questionHelp;
  final List<_ToolOption> options;
  final List<_AmountField> amountFields;
  final String cta;
  final String resultTitle;
  final List<_ToolSource> sources;
  final String? riskNotice;
}

class _ToolOption {
  const _ToolOption(this.id, this.label, {this.group});
  final String id;
  final String label;
  final String? group;
}

class _AmountField {
  const _AmountField(this.id, this.label, this.help);
  final String id;
  final String label;
  final String help;
}

class _ToolSource {
  const _ToolSource(this.publisher, this.url);
  final String publisher;
  final String url;
}

_ToolConfig _toolConfig(BuildContext context, GuideToolkitKind kind) {
  String tx({required String pt, required String es, required String en}) =>
      _t(context, pt: pt, es: es, en: en);
  const pf = _ToolSource(
    'Polícia Federal',
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/duvidas-frequentes',
  );
  const acnur = _ToolSource('ACNUR Brasil', 'https://help.unhcr.org/brazil/');
  return switch (kind) {
    GuideToolkitKind.finance => _ToolConfig(
      shortTitle: tx(
        pt: 'Vida financeira',
        es: 'Vida financiera',
        en: 'Financial setup',
      ),
      title: tx(
        pt: 'Destrave sua vida financeira no Brasil',
        es: 'Destrabá tu vida financiera en Brasil',
        en: 'Unlock your financial setup in Brazil',
      ),
      body: tx(
        pt: 'Descubra uma sequência viável entre CPF, telefone, endereço, conta, Pix e gov.br.',
        es: 'Descubrí una secuencia viable entre CPF, teléfono, domicilio, cuenta, Pix y gov.br.',
        en: 'Find a viable sequence across CPF, phone, address, bank account, Pix, and gov.br.',
      ),
      icon: Icons.account_balance_wallet_outlined,
      colors: const [Color(0xFF123A56), Color(0xFF008B7A)],
      question: tx(
        pt: 'O que você já tem?',
        es: '¿Qué tenés hoy?',
        en: 'What do you already have?',
      ),
      questionHelp: tx(
        pt: 'Marque somente o que já está funcionando no seu nome.',
        es: 'Marcá sólo lo que ya funciona a tu nombre.',
        en: 'Select only what already works in your name.',
      ),
      options: [
        _ToolOption(
          'cpf',
          tx(pt: 'CPF regular', es: 'CPF regular', en: 'Active CPF'),
        ),
        _ToolOption(
          'phone',
          tx(
            pt: 'Número de telefone brasileiro',
            es: 'Número de teléfono brasileño',
            en: 'Brazilian phone number',
          ),
        ),
        _ToolOption(
          'address',
          tx(
            pt: 'Comprovante de endereço aceito',
            es: 'Comprobante de domicilio aceptado',
            en: 'Accepted proof of address',
          ),
        ),
        _ToolOption(
          'bank',
          tx(
            pt: 'Conta bancária ou de pagamento',
            es: 'Cuenta bancaria o de pago',
            en: 'Bank or payment account',
          ),
        ),
        _ToolOption(
          'pix',
          tx(pt: 'Pix habilitado', es: 'Pix habilitado', en: 'Pix enabled'),
        ),
        _ToolOption(
          'govbr',
          tx(
            pt: 'Conta gov.br com acesso',
            es: 'Cuenta gov.br con acceso',
            en: 'Accessible gov.br account',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Montar minha sequência',
        es: 'Armar mi secuencia',
        en: 'Build my sequence',
      ),
      resultTitle: tx(
        pt: 'Próximos desbloqueios',
        es: 'Próximos desbloqueos',
        en: 'Next unlocks',
      ),
      sources: const [acnur],
    ),
    GuideToolkitKind.costs => _ToolConfig(
      shortTitle: tx(
        pt: 'Reserva de chegada',
        es: 'Reserva de llegada',
        en: 'Arrival reserve',
      ),
      title: tx(
        pt: 'Estime quanto precisa para chegar com segurança',
        es: 'Estimá cuánto necesitás para llegar con seguridad',
        en: 'Estimate a safer arrival reserve',
      ),
      body: tx(
        pt: 'Separe custo mensal, instalação, garantia e reserva para 30, 60 ou 90 dias.',
        es: 'Separá costo mensual, instalación, garantía y reserva para 30, 60 o 90 días.',
        en: 'Separate monthly costs, setup, guarantee, and a 30, 60, or 90-day reserve.',
      ),
      icon: Icons.savings_outlined,
      colors: const [Color(0xFF214B32), Color(0xFF15906C)],
      question: tx(
        pt: 'Qual período quer proteger?',
        es: '¿Qué período querés cubrir?',
        en: 'Which period do you want to cover?',
      ),
      questionHelp: tx(
        pt: 'A reserva considera os valores que você informou.',
        es: 'La reserva usa los valores que ingresaste.',
        en: 'The reserve uses the amounts you entered.',
      ),
      options: [
        _ToolOption(
          'reserve30',
          tx(pt: '30 dias', es: '30 días', en: '30 days'),
          group: 'reserve',
        ),
        _ToolOption(
          'reserve60',
          tx(pt: '60 dias', es: '60 días', en: '60 days'),
          group: 'reserve',
        ),
        _ToolOption(
          'reserve90',
          tx(pt: '90 dias', es: '90 días', en: '90 days'),
          group: 'reserve',
        ),
        _ToolOption(
          'deposit',
          tx(
            pt: 'Considerar caução de até 3 aluguéis',
            es: 'Considerar depósito de hasta 3 alquileres',
            en: 'Include a deposit of up to 3 rents',
          ),
        ),
      ],
      amountFields: [
        _AmountField(
          'rent',
          tx(pt: 'Aluguel mensal', es: 'Alquiler mensual', en: 'Monthly rent'),
          '',
        ),
        _AmountField(
          'housingFees',
          tx(
            pt: 'Condomínio e moradia',
            es: 'Expensas y vivienda',
            en: 'Housing fees',
          ),
          '',
        ),
        _AmountField(
          'living',
          tx(
            pt: 'Alimentação, transporte, saúde e outros',
            es: 'Comida, transporte, salud y otros',
            en: 'Food, transport, health, and other',
          ),
          '',
        ),
        _AmountField(
          'travel',
          tx(
            pt: 'Viagem até o Brasil',
            es: 'Viaje a Brasil',
            en: 'Travel to Brazil',
          ),
          '',
        ),
        _AmountField(
          'setup',
          tx(
            pt: 'Móveis, utensílios e instalação',
            es: 'Muebles, utensilios e instalación',
            en: 'Furniture, essentials, and setup',
          ),
          '',
        ),
      ],
      cta: tx(
        pt: 'Calcular minha reserva',
        es: 'Calcular mi reserva',
        en: 'Calculate my reserve',
      ),
      resultTitle: tx(
        pt: 'Estimativa de chegada',
        es: 'Estimación de llegada',
        en: 'Arrival estimate',
      ),
      sources: const [
        _ToolSource('IBGE', 'https://www.ibge.gov.br/explica/inflacao.php'),
      ],
    ),
    GuideToolkitKind.housing => _ToolConfig(
      shortTitle: tx(
        pt: 'Assistente de aluguel',
        es: 'Asistente de alquiler',
        en: 'Rental assistant',
      ),
      title: tx(
        pt: 'Compare o custo real antes de fechar um aluguel',
        es: 'Compará el costo real antes de cerrar un alquiler',
        en: 'Compare the real cost before signing a rental',
      ),
      body: tx(
        pt: 'Veja o impacto da garantia e receba uma verificação curta de contrato, vistoria e cobrança.',
        es: 'Mirá el impacto de la garantía y revisá contrato, inspección y cobros.',
        en: 'See the guarantee impact and check the contract, inspection, and charges.',
      ),
      icon: Icons.home_work_outlined,
      colors: const [Color(0xFF563314), Color(0xFFD47B19)],
      question: tx(
        pt: 'Qual garantia está sendo proposta?',
        es: '¿Qué garantía te proponen?',
        en: 'Which guarantee is being proposed?',
      ),
      questionHelp: tx(
        pt: 'Selecione uma opção para comparar o custo inicial.',
        es: 'Elegí una opción para comparar el costo inicial.',
        en: 'Choose one option to compare the entry cost.',
      ),
      options: [
        _ToolOption(
          'deposit',
          tx(
            pt: 'Caução em dinheiro',
            es: 'Depósito en dinero',
            en: 'Cash deposit',
          ),
          group: 'guarantee',
        ),
        _ToolOption(
          'insurance',
          tx(
            pt: 'Seguro-fiança',
            es: 'Seguro de alquiler',
            en: 'Rental insurance',
          ),
          group: 'guarantee',
        ),
        _ToolOption(
          'guarantor',
          tx(pt: 'Fiador', es: 'Garante', en: 'Guarantor'),
          group: 'guarantee',
        ),
        _ToolOption(
          'unknown',
          tx(pt: 'Ainda não sei', es: 'Todavía no sé', en: 'I do not know yet'),
          group: 'guarantee',
        ),
      ],
      amountFields: [
        _AmountField(
          'rent',
          tx(pt: 'Aluguel mensal', es: 'Alquiler mensual', en: 'Monthly rent'),
          '',
        ),
        _AmountField(
          'housingFees',
          tx(
            pt: 'Condomínio e taxas mensais',
            es: 'Expensas y cargos mensuales',
            en: 'Monthly fees',
          ),
          '',
        ),
      ],
      cta: tx(
        pt: 'Analisar custo e cuidados',
        es: 'Analizar costo y cuidados',
        en: 'Review cost and safeguards',
      ),
      resultTitle: tx(
        pt: 'Antes de pagar ou assinar',
        es: 'Antes de pagar o firmar',
        en: 'Before paying or signing',
      ),
      sources: const [
        _ToolSource(
          'Lei do Inquilinato',
          'https://www.planalto.gov.br/ccivil_03/leis/l8245.htm',
        ),
      ],
    ),
    GuideToolkitKind.work => _ToolConfig(
      shortTitle: tx(
        pt: 'Assistente de trabalho',
        es: 'Asistente de trabajo',
        en: 'Work assistant',
      ),
      title: tx(
        pt: 'Descubra o que já pode fazer para trabalhar',
        es: 'Descubrí qué ya podés hacer para trabajar',
        en: 'See what you can already do to work',
      ),
      body: tx(
        pt: 'Cruze documentos, modalidade de renda e profissão sem confundir CPF com autorização para trabalhar.',
        es: 'Cruzá documentos, modalidad de ingreso y profesión sin confundir CPF con autorización para trabajar.',
        en: 'Cross-check documents, income mode, and profession without confusing CPF with work authorization.',
      ),
      icon: Icons.work_outline_rounded,
      colors: const [Color(0xFF17376E), Color(0xFF1677D2)],
      question: tx(
        pt: 'O que descreve sua situação?',
        es: '¿Qué describe tu situación?',
        en: 'What describes your situation?',
      ),
      questionHelp: tx(
        pt: 'Você pode marcar mais de uma opção.',
        es: 'Podés marcar más de una opción.',
        en: 'You can select more than one.',
      ),
      options: [
        _ToolOption(
          'cpf',
          tx(pt: 'Já tenho CPF', es: 'Ya tengo CPF', en: 'I have a CPF'),
        ),
        _ToolOption(
          'authorized',
          tx(
            pt: 'Tenho residência/visto que permite trabalhar',
            es: 'Tengo residencia/visa que permite trabajar',
            en: 'I have status that allows work',
          ),
        ),
        _ToolOption(
          'clt',
          tx(
            pt: 'Quero emprego CLT',
            es: 'Quiero empleo formal CLT',
            en: 'I want formal CLT employment',
          ),
        ),
        _ToolOption(
          'pj',
          tx(
            pt: 'Quero trabalhar como PJ/MEI',
            es: 'Quiero trabajar como PJ/MEI',
            en: 'I want PJ/MEI self-employment',
          ),
        ),
        _ToolOption(
          'remote',
          tx(
            pt: 'Recebo de empresa ou clientes do exterior',
            es: 'Cobro de empresa o clientes del exterior',
            en: 'I earn from a foreign company or clients',
          ),
        ),
        _ToolOption(
          'regulated',
          tx(
            pt: 'Minha profissão tem conselho ou licença',
            es: 'Mi profesión tiene matrícula o licencia',
            en: 'My profession is regulated',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Montar meu caminho de trabalho',
        es: 'Armar mi camino laboral',
        en: 'Build my work path',
      ),
      resultTitle: tx(
        pt: 'Seu caminho para trabalhar',
        es: 'Tu camino para trabajar',
        en: 'Your path to work',
      ),
      sources: const [
        _ToolSource(
          'Ministério do Trabalho e Emprego',
          'https://www.gov.br/trabalho-e-emprego/pt-br/acesso-a-informacao/acoes-e-programas/programas-projetos-acoes-obras-e-atividades/proteja/duvidas-frequentes',
        ),
      ],
    ),
    GuideToolkitKind.tax => _ToolConfig(
      shortTitle: tx(
        pt: 'Triagem fiscal',
        es: 'Orientación fiscal',
        en: 'Tax screening',
      ),
      title: tx(
        pt: 'Organize sua situação fiscal entre países',
        es: 'Organizá tu situación fiscal entre países',
        en: 'Organize your cross-border tax situation',
      ),
      body: tx(
        pt: 'Identifique sinais que exigem análise profissional e saia com a lista certa de documentos e perguntas.',
        es: 'Identificá señales que requieren análisis profesional y prepará documentos y preguntas.',
        en: 'Identify facts requiring professional review and prepare the right documents and questions.',
      ),
      icon: Icons.receipt_long_outlined,
      colors: const [Color(0xFF42265F), Color(0xFF7650B5)],
      question: tx(
        pt: 'Quais fatos se aplicam?',
        es: '¿Qué situaciones se aplican?',
        en: 'Which facts apply?',
      ),
      questionHelp: tx(
        pt: 'Isso não calcula imposto nem define sua residência fiscal.',
        es: 'Esto no calcula impuestos ni define tu residencia fiscal.',
        en: 'This does not calculate tax or determine tax residence.',
      ),
      options: [
        _ToolOption(
          'permanent',
          tx(
            pt: 'Mudei com intenção de morar no Brasil',
            es: 'Me mudé con intención de vivir en Brasil',
            en: 'I moved intending to live in Brazil',
          ),
        ),
        _ToolOption(
          'over183',
          tx(
            pt: 'Posso completar 183 dias no Brasil',
            es: 'Puedo completar 183 días en Brasil',
            en: 'I may reach 183 days in Brazil',
          ),
        ),
        _ToolOption(
          'foreignIncome',
          tx(
            pt: 'Recebo renda do exterior',
            es: 'Recibo ingresos del exterior',
            en: 'I receive foreign income',
          ),
        ),
        _ToolOption(
          'foreignAssets',
          tx(
            pt: 'Tenho contas, investimentos ou imóveis fora',
            es: 'Tengo cuentas, inversiones o inmuebles afuera',
            en: 'I hold foreign accounts, investments, or property',
          ),
        ),
        _ToolOption(
          'company',
          tx(
            pt: 'Tenho empresa ou participação societária',
            es: 'Tengo empresa o participación societaria',
            en: 'I own or participate in a company',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Preparar minha triagem',
        es: 'Preparar mi orientación',
        en: 'Prepare my screening',
      ),
      resultTitle: tx(
        pt: 'O que levar para uma análise fiscal',
        es: 'Qué llevar a un análisis fiscal',
        en: 'What to bring to a tax review',
      ),
      sources: const [
        _ToolSource(
          'Receita Federal',
          'https://www.gov.br/receitafederal/pt-br/assuntos/meu-imposto-de-renda/quem/quem',
        ),
      ],
    ),
    GuideToolkitKind.family => _ToolConfig(
      shortTitle: tx(
        pt: 'Família e educação',
        es: 'Familia y educación',
        en: 'Family and education',
      ),
      title: tx(
        pt: 'Organize família, escola e diploma',
        es: 'Organizá familia, escuela y diploma',
        en: 'Organize family, school, and qualifications',
      ),
      body: tx(
        pt: 'Monte um caminho para menores, reunião familiar, matrícula e reconhecimento acadêmico.',
        es: 'Armá un camino para menores, reunión familiar, matrícula y reconocimiento académico.',
        en: 'Build a path for minors, family reunion, enrollment, and academic recognition.',
      ),
      icon: Icons.family_restroom_rounded,
      colors: const [Color(0xFF594129), Color(0xFFB47A36)],
      question: tx(
        pt: 'O que faz parte da mudança?',
        es: '¿Qué forma parte de la mudanza?',
        en: 'What is part of the move?',
      ),
      questionHelp: tx(
        pt: 'Marque todas as situações relevantes.',
        es: 'Marcá todas las situaciones relevantes.',
        en: 'Select every relevant situation.',
      ),
      options: [
        _ToolOption(
          'partner',
          tx(
            pt: 'Cônjuge ou companheiro',
            es: 'Cónyuge o pareja',
            en: 'Spouse or partner',
          ),
        ),
        _ToolOption(
          'children',
          tx(
            pt: 'Filho menor de idade',
            es: 'Hijo menor de edad',
            en: 'Minor child',
          ),
        ),
        _ToolOption(
          'school',
          tx(
            pt: 'Matrícula em escola',
            es: 'Matrícula escolar',
            en: 'School enrollment',
          ),
        ),
        _ToolOption(
          'childcare',
          tx(
            pt: 'Creche ou educação infantil',
            es: 'Guardería o nivel inicial',
            en: 'Childcare or early education',
          ),
        ),
        _ToolOption(
          'diploma',
          tx(
            pt: 'Diploma obtido fora do Brasil',
            es: 'Diploma obtenido fuera de Brasil',
            en: 'Foreign diploma',
          ),
        ),
        _ToolOption(
          'regulated',
          tx(
            pt: 'Profissão regulamentada',
            es: 'Profesión regulada',
            en: 'Regulated profession',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Montar caminho da família',
        es: 'Armar camino de la familia',
        en: 'Build the family path',
      ),
      resultTitle: tx(
        pt: 'Documentos e próximos passos',
        es: 'Documentos y próximos pasos',
        en: 'Documents and next steps',
      ),
      sources: const [pf],
    ),
    GuideToolkitKind.health => _ToolConfig(
      shortTitle: tx(
        pt: 'Saúde contínua',
        es: 'Salud continua',
        en: 'Continuing healthcare',
      ),
      title: tx(
        pt: 'Continue seu cuidado sem improvisar',
        es: 'Continuá tu atención sin improvisar',
        en: 'Continue your care without improvising',
      ),
      body: tx(
        pt: 'Organize tratamento, medicamentos, vacinação, gestação e saúde mental para chegar com uma rota segura.',
        es: 'Organizá tratamiento, medicamentos, vacunas, embarazo y salud mental para llegar con una ruta segura.',
        en: 'Organize treatment, medicines, vaccination, pregnancy, and mental healthcare for a safer arrival.',
      ),
      icon: Icons.health_and_safety_outlined,
      colors: const [Color(0xFF49304B), Color(0xFFC04468)],
      question: tx(
        pt: 'Que cuidado precisa continuar?',
        es: '¿Qué atención necesitás continuar?',
        en: 'Which care needs to continue?',
      ),
      questionHelp: tx(
        pt: 'Marque tudo o que exige preparação antes ou logo após a chegada.',
        es: 'Marcá todo lo que requiere preparación antes o después de llegar.',
        en: 'Select everything requiring preparation before or soon after arrival.',
      ),
      options: [
        _ToolOption(
          'emergency',
          tx(
            pt: 'Preciso de ajuda urgente',
            es: 'Necesito ayuda urgente',
            en: 'I need urgent help',
          ),
        ),
        _ToolOption(
          'continuousMedication',
          tx(
            pt: 'Tratamento ou medicamento contínuo',
            es: 'Tratamiento o medicación continua',
            en: 'Ongoing treatment or medicine',
          ),
        ),
        _ToolOption(
          'controlledMedication',
          tx(
            pt: 'Medicamento controlado',
            es: 'Medicamento controlado',
            en: 'Controlled medicine',
          ),
        ),
        _ToolOption(
          'vaccination',
          tx(
            pt: 'Vacinação de adulto ou criança',
            es: 'Vacunación de adulto o niño',
            en: 'Adult or child vaccination',
          ),
        ),
        _ToolOption(
          'pregnancy',
          tx(
            pt: 'Gestação ou pré-natal',
            es: 'Embarazo o control prenatal',
            en: 'Pregnancy or prenatal care',
          ),
        ),
        _ToolOption(
          'mentalHealth',
          tx(pt: 'Saúde mental', es: 'Salud mental', en: 'Mental healthcare'),
        ),
        _ToolOption(
          'dental',
          tx(
            pt: 'Atendimento odontológico',
            es: 'Atención odontológica',
            en: 'Dental care',
          ),
        ),
        _ToolOption(
          'privatePlan',
          tx(
            pt: 'Comparar SUS e plano privado',
            es: 'Comparar SUS y plan privado',
            en: 'Compare SUS and private insurance',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Montar rota de cuidado',
        es: 'Armar ruta de atención',
        en: 'Build my care path',
      ),
      resultTitle: tx(
        pt: 'Sua continuidade de cuidado',
        es: 'Tu continuidad de atención',
        en: 'Your continuity-of-care path',
      ),
      sources: const [
        _ToolSource(
          'Ministério da Saúde · Migração',
          'https://www.gov.br/saude/pt-br/composicao/svsa/vigilancia-em-saude-e-migracao',
        ),
        _ToolSource(
          'Ministério da Saúde · Viajante',
          'https://www.gov.br/saude/pt-br/assuntos/saude-de-a-a-z/s/saude-do-viajante',
        ),
      ],
      riskNotice: tx(
        pt: 'Esta ferramenta organiza o acesso. Não substitui avaliação médica, receita brasileira nem atendimento de urgência.',
        es: 'Esta herramienta organiza el acceso. No reemplaza evaluación médica, receta brasileña ni urgencias.',
        en: 'This tool organizes access. It does not replace medical assessment, a Brazilian prescription, or emergency care.',
      ),
    ),
    GuideToolkitKind.petsCustoms => _ToolConfig(
      shortTitle: tx(
        pt: 'Pets e alfândega',
        es: 'Mascotas y aduana',
        en: 'Pets and customs',
      ),
      title: tx(
        pt: 'Prepare o que cruza a fronteira com você',
        es: 'Prepará lo que cruza la frontera con vos',
        en: 'Prepare everything crossing the border with you',
      ),
      body: tx(
        pt: 'Separe exigências de pets, medicamentos, alimentos, eletrônicos, mudança e veículo antes do embarque.',
        es: 'Separá requisitos de mascotas, medicamentos, alimentos, electrónicos, mudanza y vehículo antes de viajar.',
        en: 'Separate requirements for pets, medicines, food, electronics, household goods, and vehicles before travel.',
      ),
      icon: Icons.pets_outlined,
      colors: const [Color(0xFF3F321E), Color(0xFF9A6A22)],
      question: tx(
        pt: 'O que você pretende levar?',
        es: '¿Qué pensás llevar?',
        en: 'What do you plan to bring?',
      ),
      questionHelp: tx(
        pt: 'Marque todos os itens para receber verificações separadas.',
        es: 'Marcá todos los ítems para recibir controles separados.',
        en: 'Select every item to receive separate checks.',
      ),
      options: [
        _ToolOption(
          'dogCat',
          tx(pt: 'Cão ou gato', es: 'Perro o gato', en: 'Dog or cat'),
        ),
        _ToolOption(
          'otherPet',
          tx(pt: 'Outro animal', es: 'Otro animal', en: 'Another animal'),
        ),
        _ToolOption(
          'foodPlants',
          tx(
            pt: 'Alimentos, plantas ou sementes',
            es: 'Alimentos, plantas o semillas',
            en: 'Food, plants, or seeds',
          ),
        ),
        _ToolOption(
          'medicines',
          tx(pt: 'Medicamentos', es: 'Medicamentos', en: 'Medicines'),
        ),
        _ToolOption(
          'electronics',
          tx(
            pt: 'Computador ou eletrônicos',
            es: 'Computadora o electrónicos',
            en: 'Computer or electronics',
          ),
        ),
        _ToolOption(
          'householdGoods',
          tx(
            pt: 'Bagagem ou mudança doméstica',
            es: 'Equipaje o mudanza doméstica',
            en: 'Baggage or household move',
          ),
        ),
        _ToolOption(
          'vehicle',
          tx(
            pt: 'Carro ou outro veículo',
            es: 'Auto u otro vehículo',
            en: 'Car or another vehicle',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Preparar verificação de entrada',
        es: 'Preparar control de ingreso',
        en: 'Prepare my entry check',
      ),
      resultTitle: tx(
        pt: 'Antes de cruzar a fronteira',
        es: 'Antes de cruzar la frontera',
        en: 'Before crossing the border',
      ),
      sources: const [
        _ToolSource(
          'MAPA · Animais de estimação',
          'https://www.gov.br/agricultura/pt-br/assuntos/vigilancia-agropecuaria/animais-estimacao',
        ),
        _ToolSource(
          'Receita Federal · Guia do viajante',
          'https://www.gov.br/receitafederal/pt-br/assuntos/aduana-e-comercio-exterior/viagens-internacionais/guia-do-viajante/perguntas-e-respostas',
        ),
      ],
      riskNotice: tx(
        pt: 'Exigências sanitárias e aduaneiras mudam por item e data. Confirme com as autoridades antes da viagem.',
        es: 'Los requisitos sanitarios y aduaneros cambian según ítem y fecha. Confirmá antes de viajar.',
        en: 'Health and customs requirements vary by item and date. Confirm them with authorities before travel.',
      ),
    ),
    GuideToolkitKind.utilities => _ToolConfig(
      shortTitle: tx(
        pt: 'Serviços da casa',
        es: 'Servicios del hogar',
        en: 'Home services',
      ),
      title: tx(
        pt: 'Ligue sua casa sem herdar problemas',
        es: 'Conectá tu casa sin heredar problemas',
        en: 'Connect your home without inheriting problems',
      ),
      body: tx(
        pt: 'Organize telefone, internet, energia, água e comprovante de endereço na ordem certa.',
        es: 'Organizá teléfono, internet, energía, agua y comprobante de domicilio en el orden correcto.',
        en: 'Organize phone, internet, electricity, water, and proof of address in the right order.',
      ),
      icon: Icons.electrical_services_outlined,
      colors: const [Color(0xFF26364B), Color(0xFF2876A8)],
      question: tx(
        pt: 'O que precisa ativar ou corrigir?',
        es: '¿Qué necesitás activar o corregir?',
        en: 'What do you need to activate or fix?',
      ),
      questionHelp: tx(
        pt: 'As exigências podem variar por empresa e município.',
        es: 'Los requisitos pueden variar por empresa y municipio.',
        en: 'Requirements may vary by company and municipality.',
      ),
      options: [
        _ToolOption(
          'phone',
          tx(pt: 'Chip ou telefone', es: 'Chip o teléfono', en: 'SIM or phone'),
        ),
        _ToolOption(
          'internet',
          tx(
            pt: 'Internet residencial',
            es: 'Internet residencial',
            en: 'Home internet',
          ),
        ),
        _ToolOption(
          'energy',
          tx(
            pt: 'Energia elétrica',
            es: 'Energía eléctrica',
            en: 'Electricity',
          ),
        ),
        _ToolOption(
          'water',
          tx(
            pt: 'Água ou saneamento',
            es: 'Agua o saneamiento',
            en: 'Water or sanitation',
          ),
        ),
        _ToolOption(
          'address',
          tx(
            pt: 'Comprovante de endereço',
            es: 'Comprobante de domicilio',
            en: 'Proof of address',
          ),
        ),
        _ToolOption(
          'previousDebt',
          tx(
            pt: 'Dívida do morador anterior',
            es: 'Deuda del ocupante anterior',
            en: 'Previous occupant debt',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Montar sequência de ativação',
        es: 'Armar secuencia de activación',
        en: 'Build my activation sequence',
      ),
      resultTitle: tx(
        pt: 'Serviços para ativar',
        es: 'Servicios para activar',
        en: 'Services to activate',
      ),
      sources: const [
        _ToolSource(
          'ANEEL · Como resolver',
          'https://www.gov.br/aneel/pt-br/consumidores/como-resolver',
        ),
        _ToolSource(
          'Anatel · Contratação',
          'https://www.gov.br/anatel/pt-br/consumidor/destaques/principais-regras-de-contratacao',
        ),
      ],
    ),
    GuideToolkitKind.protection => _ToolConfig(
      shortTitle: tx(
        pt: 'Proteção e ajuda',
        es: 'Protección y ayuda',
        en: 'Protection and support',
      ),
      title: tx(
        pt: 'Encontre ajuda para a situação certa',
        es: 'Encontrá ayuda para la situación correcta',
        en: 'Find the right help for your situation',
      ),
      body: tx(
        pt: 'Organize canais para urgência, violência, discriminação, exploração, assistência jurídica e social.',
        es: 'Organizá canales para urgencias, violencia, discriminación, explotación y asistencia jurídica o social.',
        en: 'Organize channels for emergencies, violence, discrimination, exploitation, and legal or social support.',
      ),
      icon: Icons.volunteer_activism_outlined,
      colors: const [Color(0xFF4A2534), Color(0xFF9B3C61)],
      question: tx(
        pt: 'Que tipo de ajuda você procura?',
        es: '¿Qué tipo de ayuda buscás?',
        en: 'What kind of help are you looking for?',
      ),
      questionHelp: tx(
        pt: 'Se houver perigo imediato, priorize a opção urgente.',
        es: 'Si hay peligro inmediato, priorizá la opción urgente.',
        en: 'If there is immediate danger, prioritize urgent help.',
      ),
      options: [
        _ToolOption(
          'urgent',
          tx(
            pt: 'Perigo ou emergência agora',
            es: 'Peligro o emergencia ahora',
            en: 'Immediate danger or emergency',
          ),
        ),
        _ToolOption(
          'womenViolence',
          tx(
            pt: 'Violência contra mulher',
            es: 'Violencia contra la mujer',
            en: 'Violence against a woman',
          ),
        ),
        _ToolOption(
          'discrimination',
          tx(
            pt: 'Discriminação ou xenofobia',
            es: 'Discriminación o xenofobia',
            en: 'Discrimination or xenophobia',
          ),
        ),
        _ToolOption(
          'laborExploitation',
          tx(
            pt: 'Exploração ou abuso no trabalho',
            es: 'Explotación o abuso laboral',
            en: 'Labor exploitation or abuse',
          ),
        ),
        _ToolOption(
          'legalAid',
          tx(
            pt: 'Assistência jurídica gratuita',
            es: 'Asistencia jurídica gratuita',
            en: 'Free legal assistance',
          ),
        ),
        _ToolOption(
          'socialAid',
          tx(
            pt: 'Assistência social ou abrigo',
            es: 'Asistencia social o refugio',
            en: 'Social assistance or shelter',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Mostrar canais seguros',
        es: 'Mostrar canales seguros',
        en: 'Show safe support channels',
      ),
      resultTitle: tx(
        pt: 'Prioridade e encaminhamento',
        es: 'Prioridad y derivación',
        en: 'Priority and referral',
      ),
      sources: const [
        _ToolSource(
          'Ministério dos Direitos Humanos',
          'https://www.gov.br/mdh/pt-br/ondh',
        ),
        _ToolSource(
          'ACNUR Brasil',
          'https://help.unhcr.org/brazil/onde-encontrar-ajuda/',
        ),
      ],
      riskNotice: tx(
        pt: 'Se houver risco imediato, use os serviços de emergência. O Guia não monitora nem envia denúncias.',
        es: 'Si hay riesgo inmediato, usá los servicios de emergencia. La Guía no monitorea ni envía denuncias.',
        en: 'If there is immediate danger, use emergency services. The Guide does not monitor or file reports.',
      ),
    ),
    GuideToolkitKind.consumer => _ToolConfig(
      shortTitle: tx(
        pt: 'Direitos do consumidor',
        es: 'Derechos del consumidor',
        en: 'Consumer rights',
      ),
      title: tx(
        pt: 'Transforme o problema em uma reclamação rastreável',
        es: 'Convertí el problema en un reclamo rastreable',
        en: 'Turn the problem into a traceable complaint',
      ),
      body: tx(
        pt: 'Descubra qual canal usar e quais provas guardar para banco, operadora, energia, moradia ou compra.',
        es: 'Descubrí qué canal usar y qué pruebas guardar para banco, operadora, energía, vivienda o compra.',
        en: 'Find the right channel and evidence for banking, telecom, energy, housing, or purchase problems.',
      ),
      icon: Icons.receipt_long_outlined,
      colors: const [Color(0xFF3A2D55), Color(0xFF7752B3)],
      question: tx(
        pt: 'Onde aconteceu o problema?',
        es: '¿Dónde ocurrió el problema?',
        en: 'Where did the problem happen?',
      ),
      questionHelp: tx(
        pt: 'Marque também fraude se precisar proteger contas antes de reclamar.',
        es: 'Marcá también fraude si necesitás proteger cuentas antes de reclamar.',
        en: 'Also select fraud if accounts must be protected before complaining.',
      ),
      options: [
        _ToolOption(
          'bank',
          tx(
            pt: 'Banco, Pix ou cartão',
            es: 'Banco, Pix o tarjeta',
            en: 'Bank, Pix, or card',
          ),
        ),
        _ToolOption(
          'telecom',
          tx(
            pt: 'Telefone ou internet',
            es: 'Teléfono o internet',
            en: 'Phone or internet',
          ),
        ),
        _ToolOption(
          'energy',
          tx(
            pt: 'Energia elétrica',
            es: 'Energía eléctrica',
            en: 'Electricity',
          ),
        ),
        _ToolOption(
          'housing',
          tx(
            pt: 'Aluguel ou imobiliária',
            es: 'Alquiler o inmobiliaria',
            en: 'Rental or real estate agent',
          ),
        ),
        _ToolOption(
          'online',
          tx(
            pt: 'Compra online ou serviço',
            es: 'Compra online o servicio',
            en: 'Online purchase or service',
          ),
        ),
        _ToolOption(
          'fraud',
          tx(
            pt: 'Suspeita de fraude ou golpe',
            es: 'Sospecha de fraude o estafa',
            en: 'Suspected fraud or scam',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Montar caminho de reclamação',
        es: 'Armar camino de reclamo',
        en: 'Build my complaint path',
      ),
      resultTitle: tx(
        pt: 'Sua escalada de atendimento',
        es: 'Tu escalada de atención',
        en: 'Your complaint escalation',
      ),
      sources: const [
        _ToolSource(
          'Consumidor.gov.br',
          'https://www.consumidor.gov.br/pages/principal/',
        ),
        _ToolSource(
          'Anatel · Reclamação',
          'https://www.gov.br/anatel/pt-br/consumidor/quer-reclamar/reclamacao',
        ),
        _ToolSource(
          'ANEEL · Reclamação',
          'https://www.gov.br/aneel/pt-br/canais_atendimento/reclame-da-distribuidora/consumidor-govbr',
        ),
      ],
    ),
    GuideToolkitKind.longTerm => _ToolConfig(
      shortTitle: tx(
        pt: 'Previdência e futuro',
        es: 'Previsión y futuro',
        en: 'Pension and future',
      ),
      title: tx(
        pt: 'Organize contribuições e escolhas de longo prazo',
        es: 'Organizá aportes y decisiones de largo plazo',
        en: 'Organize contributions and long-term choices',
      ),
      body: tx(
        pt: 'Prepare registros do Brasil e da Argentina e diferencie previdência, benefícios e naturalização.',
        es: 'Prepará registros de Brasil y Argentina y diferenciá previsión, beneficios y naturalización.',
        en: 'Prepare records from Brazil and Argentina and separate pension, benefits, and naturalization.',
      ),
      icon: Icons.timeline_rounded,
      colors: const [Color(0xFF213B3B), Color(0xFF357F73)],
      question: tx(
        pt: 'Qual objetivo precisa organizar?',
        es: '¿Qué objetivo necesitás organizar?',
        en: 'Which goal do you need to organize?',
      ),
      questionHelp: tx(
        pt: 'A ferramenta prepara documentos e perguntas; cada órgão decide o direito final.',
        es: 'La herramienta prepara documentos y preguntas; cada organismo decide el derecho final.',
        en: 'The tool prepares records and questions; each authority decides final eligibility.',
      ),
      options: [
        _ToolOption(
          'brazilContributions',
          tx(
            pt: 'Tenho contribuições no Brasil',
            es: 'Tengo aportes en Brasil',
            en: 'I have contributions in Brazil',
          ),
        ),
        _ToolOption(
          'argentinaContributions',
          tx(
            pt: 'Tenho contribuições na Argentina',
            es: 'Tengo aportes en Argentina',
            en: 'I have contributions in Argentina',
          ),
        ),
        _ToolOption(
          'retirement',
          tx(
            pt: 'Quero planejar aposentadoria',
            es: 'Quiero planificar jubilación',
            en: 'I want to plan retirement',
          ),
        ),
        _ToolOption(
          'disability',
          tx(
            pt: 'Incapacidade ou afastamento',
            es: 'Incapacidad o licencia',
            en: 'Disability or leave',
          ),
        ),
        _ToolOption(
          'dependents',
          tx(
            pt: 'Benefício para dependentes',
            es: 'Beneficio para dependientes',
            en: 'Dependent benefits',
          ),
        ),
        _ToolOption(
          'naturalization',
          tx(
            pt: 'Quero avaliar naturalização',
            es: 'Quiero evaluar naturalización',
            en: 'I want to assess naturalization',
          ),
        ),
        _ToolOption(
          'childNaturalization',
          tx(
            pt: 'Naturalização de criança',
            es: 'Naturalización de niño',
            en: 'Child naturalization',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Preparar meu dossiê',
        es: 'Preparar mi carpeta',
        en: 'Prepare my records',
      ),
      resultTitle: tx(
        pt: 'Registros e próximos passos',
        es: 'Registros y próximos pasos',
        en: 'Records and next steps',
      ),
      sources: const [
        _ToolSource(
          'Previdência Social · Acordos',
          'https://www.gov.br/previdencia/pt-br/assuntos/acordos-internacionais/acordos-internacionais-em-vigor',
        ),
        _ToolSource(
          'Ministério da Justiça · Naturalizar-se',
          'https://www.gov.br/mj/pt-br/assuntos/seus-direitos/migracoes/naturalizacao/naturalizar-se',
        ),
      ],
      riskNotice: tx(
        pt: 'Isto é uma triagem previdenciária e migratória. INSS, ANSES e Ministério da Justiça decidem cada pedido.',
        es: 'Esto es una orientación previsional y migratoria. INSS, ANSES y Justicia deciden cada solicitud.',
        en: 'This is pension and migration screening. INSS, ANSES, and the Justice Ministry decide each claim.',
      ),
    ),
    GuideToolkitKind.dependencies => _ToolConfig(
      shortTitle: tx(
        pt: 'Destravar pendências',
        es: 'Destrabar pendientes',
        en: 'Unblock dependencies',
      ),
      title: tx(
        pt: 'Descubra por onde começar quando tudo parece depender de tudo',
        es: 'Descubrí por dónde empezar cuando todo parece depender de todo',
        en: 'Find where to start when everything seems interdependent',
      ),
      body: tx(
        pt: 'Selecione seus bloqueios e receba uma sequência curta que separa regra, prática e alternativa.',
        es: 'Seleccioná tus bloqueos y recibí una secuencia corta que separa regla, práctica y alternativa.',
        en: 'Select your blockers and get a short sequence separating rules, practice, and fallback.',
      ),
      icon: Icons.account_tree_outlined,
      colors: const [Color(0xFF24314D), Color(0xFF506CA8)],
      question: tx(
        pt: 'O que está bloqueado agora?',
        es: '¿Qué está bloqueado ahora?',
        en: 'What is blocked right now?',
      ),
      questionHelp: tx(
        pt: 'Marque os problemas, não o que você já concluiu.',
        es: 'Marcá los problemas, no lo que ya completaste.',
        en: 'Select problems, not completed items.',
      ),
      options: [
        _ToolOption(
          'residence',
          tx(
            pt: 'Residência ou CRNM',
            es: 'Residencia o CRNM',
            en: 'Residence or CRNM',
          ),
        ),
        _ToolOption('cpf', tx(pt: 'CPF', es: 'CPF', en: 'CPF')),
        _ToolOption(
          'phone',
          tx(
            pt: 'Telefone brasileiro',
            es: 'Teléfono brasileño',
            en: 'Brazilian phone',
          ),
        ),
        _ToolOption(
          'address',
          tx(
            pt: 'Comprovante de endereço',
            es: 'Comprobante de domicilio',
            en: 'Proof of address',
          ),
        ),
        _ToolOption(
          'bank',
          tx(pt: 'Conta ou Pix', es: 'Cuenta o Pix', en: 'Account or Pix'),
        ),
        _ToolOption(
          'work',
          tx(pt: 'Trabalho formal', es: 'Trabajo formal', en: 'Formal work'),
        ),
        _ToolOption(
          'school',
          tx(
            pt: 'Matrícula escolar',
            es: 'Matrícula escolar',
            en: 'School enrollment',
          ),
        ),
      ],
      amountFields: const [],
      cta: tx(
        pt: 'Ordenar meus desbloqueios',
        es: 'Ordenar mis desbloqueos',
        en: 'Order my unlocks',
      ),
      resultTitle: tx(
        pt: 'Sequência recomendada',
        es: 'Secuencia recomendada',
        en: 'Recommended sequence',
      ),
      sources: const [acnur],
    ),
  };
}

Map<String, String> _actionLabels(BuildContext context) {
  String tx(String pt, String es, String en) =>
      _t(context, pt: pt, es: es, en: en);
  return {
    'finance_get_cpf': tx(
      'Solicite ou regularize o CPF; ele é a chave de vários cadastros, mas não substitui residência.',
      'Solicitá o regularizá el CPF; abre varios registros, pero no reemplaza la residencia.',
      'Get or regularize CPF; it unlocks registrations but does not replace residence.',
    ),
    'finance_get_phone': tx(
      'Obtenha um número brasileiro para validações, sem entregar senha ou código a terceiros.',
      'Obtené un número brasileño para validaciones y nunca compartas claves o códigos.',
      'Get a Brazilian number for verification and never share passwords or codes.',
    ),
    'finance_address_proof': tx(
      'Prepare contrato, declaração do responsável pelo imóvel ou documento aceito pela instituição.',
      'Prepará contrato, declaración del responsable del domicilio u otro documento aceptado.',
      'Prepare a lease, host declaration, or another document accepted by the institution.',
    ),
    'finance_open_account': tx(
      'Compare conta bancária e conta de pagamento; uma recusa não significa proibição geral.',
      'Compará cuenta bancaria y cuenta de pago; un rechazo no significa prohibición general.',
      'Compare bank and payment accounts; one rejection is not a general prohibition.',
    ),
    'finance_enable_pix': tx(
      'Cadastre uma chave Pix somente em instituição autorizada e confira o nome antes de transferir.',
      'Registrá una clave Pix sólo en una institución autorizada y verificá el nombre antes de transferir.',
      'Register Pix only with an authorized institution and verify the recipient name.',
    ),
    'finance_strengthen_govbr': tx(
      'Ative a conta gov.br e consulte os métodos oficiais disponíveis para elevar o nível.',
      'Activá gov.br y revisá los métodos oficiales disponibles para subir el nivel.',
      'Activate gov.br and check official methods available to raise its level.',
    ),
    'costs_compare_income': tx(
      'Compare a reserva com sua renda líquida, não com o salário bruto anunciado.',
      'Compará la reserva con tu ingreso neto, no con el sueldo bruto anunciado.',
      'Compare the reserve with net income, not advertised gross salary.',
    ),
    'costs_keep_emergency_buffer': tx(
      'Mantenha uma reserva de emergência separada do custo calculado.',
      'Mantené una reserva de emergencia separada del costo calculado.',
      'Keep an emergency buffer separate from the calculated amount.',
    ),
    'costs_review_city_prices': tx(
      'Confirme aluguel e despesas no bairro real; a estimativa não é cotação.',
      'Confirmá alquiler y gastos en el barrio real; la estimación no es una cotización.',
      'Confirm rent and expenses in the actual neighbourhood; this is not a quote.',
    ),
    'housing_verify_owner': tx(
      'Confirme imóvel, proprietário ou representante antes de qualquer pagamento.',
      'Verificá inmueble, propietario o representante antes de pagar.',
      'Verify the property, owner, or representative before paying.',
    ),
    'housing_compare_guarantee': tx(
      'Compare uma única modalidade de garantia e seu custo total.',
      'Compará una única modalidad de garantía y su costo total.',
      'Compare one guarantee method and its full cost.',
    ),
    'housing_inspection': tx(
      'Registre a vistoria com fotos, defeitos, medidores e data.',
      'Registrá la inspección con fotos, daños, medidores y fecha.',
      'Document inspection with photos, defects, meters, and date.',
    ),
    'housing_read_charges': tx(
      'Identifique no contrato aluguel, condomínio, IPTU, seguro, reparos e multa de saída.',
      'Identificá alquiler, expensas, impuestos, seguro, reparaciones y multa de salida.',
      'Identify rent, fees, tax, insurance, repairs, and exit penalty.',
    ),
    'housing_no_advance_pix': tx(
      'Não faça Pix antecipado sob pressão sem verificar identidade e contrato.',
      'No hagas Pix anticipado bajo presión sin verificar identidad y contrato.',
      'Do not send pressured advance Pix without verifying identity and contract.',
    ),
    'work_get_cpf': tx(
      'Regularize o CPF para os cadastros trabalhistas.',
      'Regularizá el CPF para los registros laborales.',
      'Regularize CPF for employment registrations.',
    ),
    'work_confirm_status': tx(
      'Confirme se sua residência, visto ou protocolo autoriza a atividade pretendida.',
      'Confirmá si tu residencia, visa o protocolo permite la actividad.',
      'Confirm whether your status or protocol allows the intended work.',
    ),
    'work_enable_ctps': tx(
      'Crie gov.br e acesse a CTPS Digital; ela não substitui a autorização migratória.',
      'Creá gov.br y accedé a CTPS Digital; no reemplaza la autorización migratoria.',
      'Create gov.br and access Digital Work Card; it does not replace migration authorization.',
    ),
    'work_check_mei': tx(
      'Verifique atividade permitida, requisitos migratórios e efeito tributário antes de abrir MEI.',
      'Verificá actividad, requisitos migratorios e impacto fiscal antes de abrir MEI.',
      'Check permitted activity, migration requirements, and tax impact before opening MEI.',
    ),
    'work_remote_tax': tx(
      'Mapeie país do pagador, moeda, local do trabalho e datas para análise fiscal.',
      'Mapeá país del pagador, moneda, lugar de trabajo y fechas para análisis fiscal.',
      'Map payer country, currency, work location, and dates for tax review.',
    ),
    'work_validate_diploma': tx(
      'Separe revalidação acadêmica de registro no conselho profissional.',
      'Separá revalidación académica de matrícula profesional.',
      'Separate academic validation from professional-board registration.',
    ),
    'work_adapt_resume': tx(
      'Adapte o currículo ao português e destaque disponibilidade, cidade e autorização corretamente.',
      'Adaptá el CV al portugués y aclará disponibilidad, ciudad y autorización.',
      'Adapt the résumé to Portuguese and accurately state availability, city, and authorization.',
    ),
    'work_safe_search': tx(
      'Use mais de um canal e nunca pague taxa para participar de contratação.',
      'Usá más de un canal y nunca pagues para participar de una contratación.',
      'Use more than one channel and never pay to enter a hiring process.',
    ),
    'tax_record_dates': tx(
      'Registre entradas, saídas e a data em que passou a morar no Brasil.',
      'Registrá entradas, salidas y la fecha en que empezaste a vivir en Brasil.',
      'Record entries, exits, and the date you began living in Brazil.',
    ),
    'tax_list_foreign_income': tx(
      'Liste renda exterior por pagador, país, moeda e data de recebimento.',
      'Listá ingresos externos por pagador, país, moneda y fecha.',
      'List foreign income by payer, country, currency, and date.',
    ),
    'tax_list_assets': tx(
      'Liste contas, investimentos, imóveis e saldos mantidos fora do Brasil.',
      'Listá cuentas, inversiones, inmuebles y saldos fuera de Brasil.',
      'List accounts, investments, property, and balances held abroad.',
    ),
    'tax_map_company_role': tx(
      'Documente participação, função, retiradas e distribuições da empresa.',
      'Documentá participación, función, retiros y distribuciones de la empresa.',
      'Document ownership, role, withdrawals, and company distributions.',
    ),
    'tax_collect_paid_tax': tx(
      'Guarde declarações e comprovantes de imposto pago em cada país.',
      'Guardá declaraciones y comprobantes de impuestos pagados en cada país.',
      'Keep returns and proof of tax paid in each country.',
    ),
    'tax_find_cross_border_accountant': tx(
      'Leve este inventário a contador ou tributarista com experiência Brasil–país de origem.',
      'Llevá este inventario a un profesional con experiencia Brasil–país de origen.',
      'Take this inventory to an adviser experienced in Brazil and the origin country.',
    ),
    'family_relationship_docs': tx(
      'Separe certidões que comprovem casamento, união e filiação; confirme apostila e tradução.',
      'Separá partidas que prueben matrimonio, unión y filiación; confirmá apostilla y traducción.',
      'Prepare records proving marriage, partnership, and parentage; confirm apostille and translation.',
    ),
    'family_child_travel_authorization': tx(
      'Confirme autorização de viagem e guarda antes de deslocar menor.',
      'Confirmá autorización de viaje y custodia antes de trasladar a un menor.',
      'Confirm travel authorization and custody before moving a minor.',
    ),
    'family_civil_school_docs': tx(
      'Leve certidões, vacinação e histórico escolar disponíveis, sem atrasar a matrícula por falta de documento.',
      'Llevá partidas, vacunas e historial disponibles sin retrasar la matrícula por documentos faltantes.',
      'Bring available civil, vaccination, and school records without delaying enrollment over missing documents.',
    ),
    'family_school_enrollment': tx(
      'Procure a rede municipal ou estadual responsável pelo endereço.',
      'Buscá la red municipal o estadual responsable del domicilio.',
      'Contact the municipal or state school network for the address.',
    ),
    'family_childcare_city': tx(
      'Consulte inscrição e fila de creche no município; regras e vagas são locais.',
      'Consultá inscripción y lista de guardería en el municipio; las reglas son locales.',
      'Check municipal childcare registration and waitlist; rules and availability are local.',
    ),
    'family_diploma_route': tx(
      'Verifique se o uso pretendido exige revalidação ou apenas aceitação acadêmica.',
      'Verificá si el uso requiere revalidación o sólo aceptación académica.',
      'Check whether the intended use requires validation or only academic acceptance.',
    ),
    'family_professional_board': tx(
      'Consulte o conselho da profissão além da Plataforma Carolina Bori.',
      'Consultá el consejo profesional además de la Plataforma Carolina Bori.',
      'Check the professional board in addition to the Carolina Bori platform.',
    ),
    'family_check_residence_route': tx(
      'Compare a rota própria de cada familiar com a reunião familiar; não presuma que todos usam o mesmo fundamento.',
      'Compará la vía propia de cada familiar con reunión familiar; no asumas que todos usan la misma.',
      'Compare each family member’s own route with family reunion; do not assume one basis fits all.',
    ),
    'health_emergency_channel': tx(
      'Em emergência, procure UPA ou pronto-socorro; ligue 192 para o SAMU.',
      'En una emergencia, acudí a una guardia o llamá al SAMU 192.',
      'In an emergency, go to emergency care or call SAMU on 192.',
    ),
    'health_prepare_summary': tx(
      'Prepare um resumo do diagnóstico, tratamento, alergias, doses e contatos médicos.',
      'Prepará un resumen de diagnóstico, tratamiento, alergias, dosis y contactos médicos.',
      'Prepare a summary of diagnosis, treatment, allergies, doses, and medical contacts.',
    ),
    'health_carry_prescription': tx(
      'Leve receita e relatório legíveis, preferencialmente com o princípio ativo; confirme limites de entrada.',
      'Llevá receta e informe legibles, preferentemente con el principio activo; confirmá límites de ingreso.',
      'Carry a legible prescription and report, preferably naming the active ingredient; confirm entry limits.',
    ),
    'health_book_local_care': tx(
      'Procure atendimento local antes de acabar a reserva; uma receita estrangeira pode não permitir a compra.',
      'Buscá atención local antes de terminar la reserva; una receta extranjera puede no habilitar la compra.',
      'Seek local care before supplies run out; a foreign prescription may not authorize a purchase.',
    ),
    'health_check_controlled_medicine': tx(
      'Confirme com Anvisa, transportadora e profissional brasileiro as regras do medicamento controlado.',
      'Confirmá con Anvisa, transportista y profesional brasileño las reglas del medicamento controlado.',
      'Confirm controlled-medicine rules with Anvisa, the carrier, and a Brazilian professional.',
    ),
    'health_vaccine_record': tx(
      'Leve a carteira de vacinação e peça à UBS para revisar o calendário de adultos e crianças.',
      'Llevá la libreta de vacunas y pedí a la UBS revisar el calendario de adultos y niños.',
      'Bring vaccination records and ask a UBS to review the adult or child schedule.',
    ),
    'health_prenatal': tx(
      'Leve exames e data provável do parto e procure a UBS para iniciar ou continuar o pré-natal.',
      'Llevá estudios y fecha probable de parto y buscá una UBS para continuar el control prenatal.',
      'Bring tests and the expected delivery date, then contact a UBS to continue prenatal care.',
    ),
    'health_mental_health': tx(
      'Mapeie UBS, CAPS ou serviço atual e prepare um plano para evitar interrupção do cuidado.',
      'Ubicá UBS, CAPS o tu servicio actual y prepará un plan para evitar interrupciones.',
      'Identify a UBS, CAPS, or current service and prepare to avoid interrupted care.',
    ),
    'health_dental': tx(
      'Consulte a UBS sobre a porta de entrada odontológica e a rede disponível no município.',
      'Consultá en la UBS la puerta de entrada odontológica y la red del municipio.',
      'Ask the UBS about dental entry points and the municipal network.',
    ),
    'health_compare_plan': tx(
      'Compare cobertura, rede, carências, coparticipação e regras da ANS; não compare só mensalidade.',
      'Compará cobertura, red, carencias, copago y reglas de ANS; no sólo la cuota.',
      'Compare coverage, network, waiting periods, copayments, and ANS rules—not only price.',
    ),
    'health_find_ubs': tx(
      'Identifique a UBS do endereço; o SUS atende pessoas em território brasileiro independentemente da nacionalidade.',
      'Identificá la UBS del domicilio; el SUS atiende en territorio brasileño sin importar nacionalidad.',
      'Find the UBS for your address; SUS serves people in Brazil regardless of nationality.',
    ),
    'moving_pet_origin_authority': tx(
      'Comece pela autoridade veterinária do país de origem e pelos requisitos vigentes do Brasil.',
      'Empezá por la autoridad veterinaria del país de origen y los requisitos vigentes de Brasil.',
      'Start with the origin-country veterinary authority and current Brazilian requirements.',
    ),
    'moving_pet_cvi': tx(
      'Organize identificação, vacina antirrábica, exame e certificado veterinário dentro dos prazos.',
      'Organizá identificación, vacuna antirrábica, examen y certificado veterinario dentro de plazo.',
      'Organize identification, rabies vaccination, examination, and veterinary certificate on time.',
    ),
    'moving_other_pet_rules': tx(
      'Outras espécies seguem regras próprias e podem exigir autorização, GTA ou quarentena.',
      'Otras especies tienen reglas propias y pueden exigir autorización, GTA o cuarentena.',
      'Other species have separate rules and may require authorization, GTA, or quarantine.',
    ),
    'moving_check_agriculture': tx(
      'Consulte a lista do Vigiagro antes de levar alimentos, plantas, sementes ou produtos animais.',
      'Consultá la lista de Vigiagro antes de llevar alimentos, plantas, semillas o productos animales.',
      'Check the Vigiagro list before bringing food, plants, seeds, or animal products.',
    ),
    'moving_medicine_documents': tx(
      'Mantenha medicamentos na embalagem, com receita e relatório; confirme quantidade e controle sanitário.',
      'Mantené medicamentos en su envase, con receta e informe; confirmá cantidad y control sanitario.',
      'Keep medicines packaged with prescription and report; confirm quantity and health controls.',
    ),
    'moving_list_electronics': tx(
      'Liste eletrônicos, propriedade, uso e valores para separar item pessoal de bem sujeito a declaração.',
      'Listá electrónicos, propiedad, uso y valores para separar uso personal de bienes a declarar.',
      'List electronics, ownership, use, and values to separate personal items from declarable goods.',
    ),
    'moving_baggage_route': tx(
      'Diferencie bagagem acompanhada, desacompanhada e mudança; guarde inventário e comprovantes.',
      'Diferenciá equipaje acompañado, no acompañado y mudanza; guardá inventario y comprobantes.',
      'Separate accompanied baggage, unaccompanied baggage, and household moves; keep an inventory.',
    ),
    'moving_vehicle_route': tx(
      'Não trate veículo como bagagem comum; confirme importação, trânsito e registro antes de viajar.',
      'No trates el vehículo como equipaje común; confirmá importación, tránsito y registro antes de viajar.',
      'Do not treat a vehicle as ordinary baggage; confirm import, transit, and registration first.',
    ),
    'moving_check_carrier': tx(
      'Confirme também regras, reserva, caixa e limites da companhia aérea ou transportadora.',
      'Confirmá también reglas, reserva, transportadora y límites de la compañía.',
      'Also confirm booking, carrier, crate, and transport limits.',
    ),
    'moving_declare_uncertain': tx(
      'Se houver dúvida sobre declaração, use o canal oficial antes da fronteira; não esconda o item.',
      'Si dudás sobre declarar, usá el canal oficial antes de la frontera; no ocultes el ítem.',
      'If declaration is uncertain, use the official channel before the border; do not conceal the item.',
    ),
    'utilities_phone': tx(
      'Compare pré-pago e contrato, documentos aceitos, cobertura e custo total sem entregar códigos.',
      'Compará prepago y contrato, documentos aceptados, cobertura y costo total sin compartir códigos.',
      'Compare prepaid and contract options, accepted documents, coverage, and full cost without sharing codes.',
    ),
    'utilities_internet': tx(
      'Confirme cobertura no endereço, instalação, equipamento, fidelidade, velocidade e cancelamento.',
      'Confirmá cobertura, instalación, equipo, permanencia, velocidad y cancelación.',
      'Confirm address coverage, installation, equipment, commitment, speed, and cancellation.',
    ),
    'utilities_energy': tx(
      'Peça ligação ou troca de titularidade com identificação e prova de posse do imóvel.',
      'Pedí conexión o cambio de titularidad con identificación y prueba de ocupación.',
      'Request connection or ownership transfer with identification and proof of occupancy.',
    ),
    'utilities_water': tx(
      'Consulte a empresa municipal ou estadual e confirme documentos, hidrômetro e débitos da unidade.',
      'Consultá la empresa local y confirmá documentos, medidor y deudas de la unidad.',
      'Contact the local provider and confirm documents, meter status, and property debts.',
    ),
    'utilities_address_proof': tx(
      'Guarde contrato e protocolos; a primeira conta em seu nome pode virar comprovante de endereço.',
      'Guardá contrato y protocolos; la primera factura a tu nombre puede servir de comprobante.',
      'Keep the contract and protocols; the first bill in your name may become proof of address.',
    ),
    'utilities_previous_debt': tx(
      'Dívida de energia do morador anterior não pode ser imposta ao novo titular; peça a recusa por escrito.',
      'La deuda eléctrica del ocupante anterior no puede cargarse al nuevo titular; pedí la negativa por escrito.',
      'A previous occupant’s electricity debt cannot be imposed on the new account holder; request written refusal.',
    ),
    'utilities_choose_service': tx(
      'Selecione pelo menos um serviço para montar a sequência de ativação.',
      'Seleccioná al menos un servicio para armar la secuencia.',
      'Select at least one service to build an activation sequence.',
    ),
    'utilities_keep_protocol': tx(
      'Guarde oferta, contrato, fotos de medidores, protocolos e datas de instalação.',
      'Guardá oferta, contrato, fotos de medidores, protocolos y fechas.',
      'Keep the offer, contract, meter photos, protocols, and installation dates.',
    ),
    'protection_emergency': tx(
      'Em perigo imediato, vá a local seguro e acione 190; para urgência médica, 192.',
      'Ante peligro inmediato, andá a un lugar seguro y llamá al 190; urgencia médica, 192.',
      'For immediate danger, move to safety and call 190; for medical emergencies, call 192.',
    ),
    'protection_women': tx(
      'Use o Ligue 180 para orientação e denúncia; em emergência, priorize 190.',
      'Usá Ligue 180 para orientación y denuncia; en emergencia, priorizá 190.',
      'Use Ligue 180 for guidance and reporting; prioritize 190 in an emergency.',
    ),
    'protection_disque100': tx(
      'Registre violação de direitos humanos no Disque 100 ou nos canais digitais oficiais.',
      'Registrá violaciones de derechos humanos en Disque 100 o canales digitales oficiales.',
      'Report human-rights violations through Disque 100 or official digital channels.',
    ),
    'protection_labor_exploitation': tx(
      'Não entregue documento original; preserve mensagens, jornadas e pagamentos e busque inspeção ou Defensoria.',
      'No entregues documentos originales; guardá mensajes, jornadas y pagos y buscá inspección o Defensoría.',
      'Do not surrender original documents; preserve messages, hours, and payments and seek labor or legal support.',
    ),
    'protection_legal_aid': tx(
      'Procure Defensoria Pública ou organização de apoio a migrantes e leve documentos e cronologia.',
      'Buscá Defensoría Pública u organización para migrantes y llevá documentos y cronología.',
      'Contact the Public Defender or a migrant-support organization with documents and a timeline.',
    ),
    'protection_social_aid': tx(
      'Procure CRAS, CREAS ou serviço municipal para assistência, acolhimento e encaminhamento.',
      'Buscá CRAS, CREAS o servicio municipal para asistencia, refugio y derivación.',
      'Contact CRAS, CREAS, or municipal services for assistance, shelter, and referrals.',
    ),
    'protection_choose_situation': tx(
      'Selecione uma situação para receber o canal mais adequado.',
      'Seleccioná una situación para recibir el canal más adecuado.',
      'Select a situation to receive the most appropriate channel.',
    ),
    'protection_preserve_evidence': tx(
      'Quando for seguro, guarde protocolos, mensagens, nomes, datas e cópias; não confronte alguém perigoso.',
      'Cuando sea seguro, guardá protocolos, mensajes, nombres, fechas y copias; no confrontes a alguien peligroso.',
      'When safe, keep protocols, messages, names, dates, and copies; do not confront a dangerous person.',
    ),
    'consumer_contact_company': tx(
      'Contate primeiro a empresa, descreva pedido objetivo e guarde o protocolo.',
      'Contactá primero a la empresa, hacé un pedido concreto y guardá el protocolo.',
      'Contact the company first, make a specific request, and keep the protocol.',
    ),
    'consumer_bank_channel': tx(
      'Escale do atendimento para ouvidoria e regulador; em fraude, bloqueie acessos antes.',
      'Escalá de atención a defensoría del cliente y regulador; ante fraude, bloqueá accesos primero.',
      'Escalate from support to ombudsman and regulator; for fraud, block access first.',
    ),
    'consumer_anatel': tx(
      'Depois da operadora e ouvidoria, use Anatel Consumidor com os protocolos.',
      'Después de operadora y defensoría, usá Anatel Consumidor con los protocolos.',
      'After the provider and ombudsman, use Anatel Consumidor with the protocols.',
    ),
    'consumer_aneel': tx(
      'Depois da distribuidora e ouvidoria, registre na ANEEL ou Consumidor.gov.br.',
      'Después de distribuidora y defensoría, registrá en ANEEL o Consumidor.gov.br.',
      'After the distributor and ombudsman, complain to ANEEL or Consumidor.gov.br.',
    ),
    'consumer_housing_docs': tx(
      'Separe contrato, vistoria, cobranças e conversas; diferencie consumo, locação e questão judicial.',
      'Separá contrato, inspección, cobros y mensajes; diferenciá consumo, alquiler y cuestión judicial.',
      'Separate contract, inspection, charges, and messages; distinguish consumer, tenancy, and court issues.',
    ),
    'consumer_online_purchase': tx(
      'Guarde oferta, confirmação, pagamento, entrega e tentativa de cancelamento ou solução.',
      'Guardá oferta, confirmación, pago, entrega e intento de cancelación o solución.',
      'Keep the offer, confirmation, payment, delivery, and cancellation or resolution attempts.',
    ),
    'consumer_fraud_response': tx(
      'Proteja contas e senhas, avise a instituição, registre protocolos e avalie boletim de ocorrência.',
      'Protegé cuentas y claves, avisá a la institución, guardá protocolos y evaluá denuncia policial.',
      'Protect accounts and passwords, notify the institution, keep protocols, and consider a police report.',
    ),
    'consumer_escalate': tx(
      'Se não resolver, use Consumidor.gov.br, Procon ou regulador competente.',
      'Si no se resuelve, usá Consumidor.gov.br, Procon o regulador competente.',
      'If unresolved, use Consumidor.gov.br, Procon, or the relevant regulator.',
    ),
    'consumer_keep_evidence': tx(
      'Monte uma linha do tempo com valor, pedido, resposta, protocolo e solução desejada.',
      'Armá una cronología con valor, pedido, respuesta, protocolo y solución buscada.',
      'Build a timeline with amount, request, response, protocol, and desired resolution.',
    ),
    'longterm_brazil_records': tx(
      'Baixe o CNIS e confira vínculos, salários e lacunas antes de precisar do benefício.',
      'Descargá el CNIS y revisá vínculos, salarios y faltantes antes de necesitar el beneficio.',
      'Download CNIS and review jobs, earnings, and gaps before needing a benefit.',
    ),
    'longterm_argentina_records': tx(
      'Reúna história laboral, comprovantes e dados da ANSES sem presumir transferência automática.',
      'Reuní historia laboral, comprobantes y datos de ANSES sin asumir transferencia automática.',
      'Gather work history, evidence, and ANSES records without assuming automatic transfer.',
    ),
    'longterm_agreement': tx(
      'Verifique qual acordo Brasil–Argentina cobre o caso e qual organismo recebe o pedido.',
      'Verificá qué acuerdo Brasil–Argentina cubre el caso y qué organismo recibe el pedido.',
      'Check which Brazil–Argentina agreement covers the case and which body receives the claim.',
    ),
    'longterm_disability': tx(
      'Prepare laudos, datas, contribuições e vínculo; cada país aplica sua legislação ao pedido.',
      'Prepará informes, fechas, aportes y vínculo; cada país aplica su legislación.',
      'Prepare reports, dates, contributions, and employment records; each country applies its own law.',
    ),
    'longterm_dependents': tx(
      'Organize filiação, casamento ou união, dependência e registros contributivos.',
      'Organizá filiación, matrimonio o unión, dependencia y registros de aportes.',
      'Organize parentage, marriage or partnership, dependency, and contribution records.',
    ),
    'longterm_naturalization_type': tx(
      'Identifique o tipo de naturalização antes de contar prazo ou reunir documentos.',
      'Identificá el tipo de naturalización antes de contar plazo o reunir documentos.',
      'Identify the naturalization type before counting time or gathering documents.',
    ),
    'longterm_residence_evidence': tx(
      'Organize cronologia de residência efetiva, viagens, endereços e documentos migratórios.',
      'Organizá cronología de residencia efectiva, viajes, domicilios y documentos migratorios.',
      'Organize evidence of actual residence, travel, addresses, and migration documents.',
    ),
    'longterm_language_records': tx(
      'Confira as formas oficiais de demonstrar comunicação em português aplicáveis ao seu caso.',
      'Revisá las formas oficiales de demostrar comunicación en portugués aplicables a tu caso.',
      'Check official ways to demonstrate Portuguese communication for your case.',
    ),
    'longterm_naturalizarse': tx(
      'Use o sistema Naturalizar-se com gov.br e acompanhe notificações e pedidos de complemento.',
      'Usá Naturalizar-se con gov.br y seguí notificaciones y pedidos de complemento.',
      'Use Naturalizar-se with gov.br and monitor notifications and document requests.',
    ),
    'longterm_child_naturalization': tx(
      'Confirme se o caso é naturalização provisória, definitiva ou outra hipótese antes de solicitar.',
      'Confirmá si corresponde naturalización provisoria, definitiva u otra vía antes de solicitar.',
      'Confirm whether the case is provisional, definitive, or another route before applying.',
    ),
    'longterm_choose_goal': tx(
      'Selecione ao menos um objetivo para preparar os registros necessários.',
      'Seleccioná al menos un objetivo para preparar los registros necesarios.',
      'Select at least one goal to prepare the necessary records.',
    ),
    'dependency_residence': tx(
      'Primeiro, identifique a rota migratória e o documento provisório aceito enquanto a CRNM não chega.',
      'Primero identificá la vía migratoria y el documento provisional aceptado mientras llega la CRNM.',
      'First identify the migration route and interim document accepted while CRNM is pending.',
    ),
    'dependency_cpf': tx(
      'Solicite o CPF separadamente: ele não depende de ter residência concluída.',
      'Solicitá el CPF por separado: no depende de tener la residencia concluida.',
      'Request CPF separately; it does not depend on completed residence.',
    ),
    'dependency_phone': tx(
      'Busque uma modalidade de telefonia compatível com os documentos atuais e proteja códigos de validação.',
      'Buscá telefonía compatible con tus documentos actuales y protegé los códigos.',
      'Find phone service compatible with current documents and protect verification codes.',
    ),
    'dependency_address': tx(
      'Prepare alternativas de prova de endereço aceitas pelo órgão ou instituição específica.',
      'Prepará alternativas de comprobante aceptadas por el organismo específico.',
      'Prepare alternative proof of address accepted by the specific institution.',
    ),
    'dependency_bank': tx(
      'Diferencie direito de solicitar conta da análise interna do banco e compare conta de pagamento.',
      'Diferenciá el derecho a solicitar cuenta de la evaluación interna y compará cuenta de pago.',
      'Separate the right to apply from internal bank review and compare payment accounts.',
    ),
    'dependency_work': tx(
      'Cruze CPF com autorização migratória; não espere automaticamente o cartão físico se o protocolo válido for aceito.',
      'Cruzá CPF con autorización migratoria; no esperes automáticamente la tarjeta física si aceptan el protocolo.',
      'Cross-check CPF with work authorization; do not automatically wait for the physical card if a valid protocol is accepted.',
    ),
    'dependency_school': tx(
      'Solicite matrícula mesmo com documentação incompleta e peça orientação formal da rede.',
      'Solicitá matrícula aun con documentación incompleta y pedí orientación formal.',
      'Request enrollment even with incomplete documents and ask the school network for formal guidance.',
    ),
    'dependency_choose_blocker': tx(
      'Selecione pelo menos um bloqueio para receber uma sequência contextual.',
      'Seleccioná al menos un bloqueo para recibir una secuencia contextual.',
      'Select at least one blocker to receive a contextual sequence.',
    ),
  };
}

String _t(
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
