import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_decision_support_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_entry_cost_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_soft_landing_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/practical_cost_estimator.dart';

enum DocumentationGuideSection {
  documents,
  housing,
  health,
  work,
  driving,
  costs,
}

class DocumentationGuidePage extends StatelessWidget {
  const DocumentationGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.documentationPageTitle,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      padding: const EdgeInsets.all(32),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.heroStart,
                          AppColors.heroMiddle,
                          AppColors.heroEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      backgroundColor: const Color(0xB30B1320),
                      borderColor: const Color(0x1AFFFFFF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.documentationHeroEyebrow,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.documentationHeroTitle,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Text(
                              l10n.documentationHeroDescription,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _QuickStepChip(
                                label: l10n.documentationQuickStepCpf,
                                icon: Icons.badge_outlined,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepRegistration,
                                icon: Icons.perm_identity_rounded,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepStay,
                                icon: Icons.schedule_rounded,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepWorkBank,
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepCitizenship,
                                icon: Icons.flag_outlined,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepHealth,
                                icon: Icons.health_and_safety_outlined,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepDriving,
                                icon: Icons.directions_car_outlined,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepWork,
                                icon: Icons.work_outline_rounded,
                              ),
                              _QuickStepChip(
                                label: l10n.documentationQuickStepRetirement,
                                icon: Icons.savings_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GuidePathsSection(
                      l10n: l10n,
                      onOpenSection: (section) => Navigator.pushNamed(
                        context,
                        AppRoutes.documentationTopic,
                        arguments: section,
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

  List<_DocumentationTopic> _topics(BuildContext context) {
    final l10n = context.l10n;

    return [
      _DocumentationTopic(
        icon: Icons.badge_outlined,
        title: l10n.documentationCpfTitle,
        summary: l10n.documentationCpfSummary,
        bullets: [
          l10n.documentationCpfBulletOne,
          l10n.documentationCpfBulletTwo,
          l10n.documentationCpfBulletThree,
        ],
        sourceNameKey: 'receita_federal_govbr',
        sourceUrl:
            'https://www.gov.br/pt-br/servicos/inscrever-no-cpf-no-exterior',
      ),
      _DocumentationTopic(
        icon: Icons.perm_identity_rounded,
        title: l10n.documentationRegistrationTitle,
        summary: l10n.documentationRegistrationSummary,
        bullets: [
          l10n.documentationRegistrationBulletOne,
          l10n.documentationRegistrationBulletTwo,
          l10n.documentationRegistrationBulletThree,
        ],
        sourceNameKey: 'policia_federal',
        sourceUrl:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/duvidas-frequentes/autorizacao-de-residencia-e-registro-nacional-migratorio-rnm/como-devo-realizar-o-registro-de-rnm',
      ),
      _DocumentationTopic(
        icon: Icons.schedule_rounded,
        title: l10n.documentationStayTitle,
        summary: l10n.documentationStaySummary,
        bullets: [
          l10n.documentationStayBulletOne,
          l10n.documentationStayBulletTwo,
          l10n.documentationStayBulletThree,
        ],
        sourceNameKey: 'mre_policia_federal',
        sourceUrl:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia-resolucao-mercosul',
      ),
      _DocumentationTopic(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.documentationWorkBankTitle,
        summary: l10n.documentationWorkBankSummary,
        bullets: [
          l10n.documentationWorkBankBulletOne,
          l10n.documentationWorkBankBulletTwo,
          l10n.documentationWorkBankBulletThree,
        ],
        sourceNameKey: 'mre_banco_central',
        sourceUrl:
            'https://www.bcb.gov.br/content/cidadaniafinanceira/documentos_cidadania/Cartilha_Migrantes_Refugiados/cartilha_BC_PORTUGUES.pdf',
      ),
      _DocumentationTopic(
        icon: Icons.flag_outlined,
        title: l10n.documentationCitizenshipTitle,
        summary: l10n.documentationCitizenshipSummary,
        bullets: [
          l10n.documentationCitizenshipBulletOne,
          l10n.documentationCitizenshipBulletTwo,
          l10n.documentationCitizenshipBulletThree,
        ],
        sourceNameKey: 'ministerio_justica',
        sourceUrl:
            'https://www.gov.br/mj/pt-br/assuntos/seus-direitos/migracoes/naturalizacao/o-que-e-naturalizacao/naturalizacao-ordinaria',
      ),
      _DocumentationTopic(
        icon: Icons.health_and_safety_outlined,
        title: l10n.documentationHealthPublicTitle,
        summary: l10n.documentationHealthPublicSummary,
        bullets: [
          l10n.documentationHealthPublicBulletOne,
          l10n.documentationHealthPublicBulletTwo,
          l10n.documentationHealthPublicBulletThree,
        ],
        sourceNameKey: 'ministerio_saude',
        sourceUrl:
            'https://www.gov.br/saude/pt-br/assuntos/noticias/2025/marco/sus-estrangeiros-podem-contar-com-acesso-ao-sistema-publico-de-saude',
      ),
      _DocumentationTopic(
        icon: Icons.local_hospital_outlined,
        title: l10n.documentationHealthFlowTitle,
        summary: l10n.documentationHealthFlowSummary,
        bullets: [
          l10n.documentationHealthFlowBulletOne,
          l10n.documentationHealthFlowBulletTwo,
          l10n.documentationHealthFlowBulletThree,
        ],
        sourceNameKey: 'meu_sus_digital',
        sourceUrl:
            'https://www.gov.br/saude/pt-br/acesso-a-informacao/acoes-e-programas/meu-sus-digital',
      ),
      _DocumentationTopic(
        icon: Icons.favorite_outline_rounded,
        title: l10n.documentationHealthPrivateTitle,
        summary: l10n.documentationHealthPrivateSummary,
        bullets: [
          l10n.documentationHealthPrivateBulletOne,
          l10n.documentationHealthPrivateBulletTwo,
          l10n.documentationHealthPrivateBulletThree,
        ],
        sourceNameKey: 'ans',
        sourceUrl:
            'https://www.gov.br/ans/pt-br/assuntos/consumidor/guia-de-contratacao-de-planos-de-saude',
      ),
      _DocumentationTopic(
        icon: Icons.directions_car_outlined,
        title: l10n.documentationDrivingTitle,
        summary: l10n.documentationDrivingSummary,
        bullets: [
          l10n.documentationDrivingBulletOne,
          l10n.documentationDrivingBulletTwo,
          l10n.documentationDrivingBulletThree,
        ],
        sourceNameKey: 'detran_es_mg_gov',
        sourceUrl: 'https://www.detran.es.gov.br/primeira-habilitacao',
      ),
      _DocumentationTopic(
        icon: Icons.drive_eta_outlined,
        title: l10n.documentationForeignLicenseTitle,
        summary: l10n.documentationForeignLicenseSummary,
        bullets: [
          l10n.documentationForeignLicenseBulletOne,
          l10n.documentationForeignLicenseBulletTwo,
          l10n.documentationForeignLicenseBulletThree,
        ],
        sourceNameKey: 'senatran_mg_gov',
        sourceUrl:
            'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-Senatran/dirigir-no-brasil',
      ),
      _DocumentationTopic(
        icon: Icons.badge_outlined,
        title: l10n.documentationWorkCltTitle,
        summary: l10n.documentationWorkCltSummary,
        bullets: [
          l10n.documentationWorkCltBulletOne,
          l10n.documentationWorkCltBulletTwo,
          l10n.documentationWorkCltBulletThree,
        ],
        sourceNameKey: 'mte_ctps',
        sourceUrl: 'https://www.gov.br/pt-br/apps/ctps-digital',
      ),
      _DocumentationTopic(
        icon: Icons.business_center_outlined,
        title: l10n.documentationWorkPjTitle,
        summary: l10n.documentationWorkPjSummary,
        bullets: [
          l10n.documentationWorkPjBulletOne,
          l10n.documentationWorkPjBulletTwo,
          l10n.documentationWorkPjBulletThree,
        ],
        sourceNameKey: 'portal_empreendedor_inss',
        sourceUrl:
            'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor/quero-ser-mei/passo-a-passo-para-se-formalizar',
      ),
      _DocumentationTopic(
        icon: Icons.savings_outlined,
        title: l10n.documentationRetirementTitle,
        summary: l10n.documentationRetirementSummary,
        bullets: [
          l10n.documentationRetirementBulletOne,
          l10n.documentationRetirementBulletTwo,
          l10n.documentationRetirementBulletThree,
        ],
        sourceNameKey: 'ministerio_previdencia_inss',
        sourceUrl:
            'https://www.gov.br/previdencia/pt-br/noticias/2026/janeiro/guia-de-aposentadoria-2026-entenda-as-regras-de-transicao-da-reforma-da-previdencia-de-2019',
      ),
    ];
  }
}

class DocumentationTopicPage extends StatelessWidget {
  const DocumentationTopicPage({required this.section, super.key});

  final DocumentationGuideSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = _sectionDetails(context, section);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: details.title,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.documentationHeroEyebrow,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            details.title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            details.description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...details.sections,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DocumentationSectionDetails _sectionDetails(
    BuildContext context,
    DocumentationGuideSection section,
  ) {
    final l10n = context.l10n;
    final guidePage = const DocumentationGuidePage();
    final topics = guidePage._topics(context);

    switch (section) {
      case DocumentationGuideSection.documents:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathDocumentsTitle,
          description: l10n.documentationPathDocumentsBody,
          sections: [
            _QuickAnswersSection(l10n: l10n),
            const SizedBox(height: 12),
            _DeepDiveIntro(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationCpfTitle ||
                    topic.title == l10n.documentationRegistrationTitle ||
                    topic.title == l10n.documentationStayTitle ||
                    topic.title == l10n.documentationWorkBankTitle ||
                    topic.title == l10n.documentationCitizenshipTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.housing:
        return _DocumentationSectionDetails(
          title: l10n.documentationHousingArrivalSectionTitle,
          description: l10n.documentationHousingArrivalSectionBody,
          sections: const [
            HousingDecisionSupportSection(),
            SizedBox(height: 12),
            HousingEntryCostSection(),
            SizedBox(height: 12),
            HousingSoftLandingSection(),
          ],
        );
      case DocumentationGuideSection.health:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathHealthTitle,
          description: l10n.documentationPathHealthBody,
          sections: [
            _HealthDecisionsSection(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationHealthPublicTitle ||
                    topic.title == l10n.documentationHealthFlowTitle ||
                    topic.title == l10n.documentationHealthPrivateTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.work:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathWorkTitle,
          description: l10n.documentationPathWorkBody,
          sections: [
            _WorkModelsSection(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationWorkCltTitle ||
                    topic.title == l10n.documentationWorkPjTitle ||
                    topic.title == l10n.documentationRetirementTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.driving:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathDrivingTitle,
          description: l10n.documentationPathDrivingBody,
          sections: [
            _DrivingJourneySection(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationDrivingTitle ||
                    topic.title == l10n.documentationForeignLicenseTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.costs:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathCostsTitle,
          description: l10n.documentationPathCostsBody,
          sections: const [
            PracticalCostEstimator(),
          ],
        );
    }
  }
}

class _DocumentationSectionDetails {
  const _DocumentationSectionDetails({
    required this.title,
    required this.description,
    required this.sections,
  });

  final String title;
  final String description;
  final List<Widget> sections;
}

class _QuickAnswersSection extends StatelessWidget {
  const _QuickAnswersSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final cardWidth = wide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.work_outline_rounded,
                question: l10n.documentationAnswerWorkQuestion,
                answer: l10n.documentationAnswerWorkAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.badge_outlined,
                question: l10n.documentationAnswerCpfQuestion,
                answer: l10n.documentationAnswerCpfAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.perm_identity_rounded,
                question: l10n.documentationAnswerRegistrationQuestion,
                answer: l10n.documentationAnswerRegistrationAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.schedule_rounded,
                question: l10n.documentationAnswerStayQuestion,
                answer: l10n.documentationAnswerStayAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.health_and_safety_outlined,
                question: l10n.documentationAnswerSusQuestion,
                answer: l10n.documentationAnswerSusAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.local_hospital_outlined,
                question: l10n.documentationAnswerSusCardQuestion,
                answer: l10n.documentationAnswerSusCardAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.drive_eta_outlined,
                question: l10n.documentationAnswerForeignLicenseQuestion,
                answer: l10n.documentationAnswerForeignLicenseAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.badge_rounded,
                question: l10n.documentationAnswerBrazilianLicenseQuestion,
                answer: l10n.documentationAnswerBrazilianLicenseAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.badge_outlined,
                question: l10n.documentationAnswerWorkCardQuestion,
                answer: l10n.documentationAnswerWorkCardAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.business_center_outlined,
                question: l10n.documentationAnswerPjQuestion,
                answer: l10n.documentationAnswerPjAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.savings_outlined,
                question: l10n.documentationAnswerInssQuestion,
                answer: l10n.documentationAnswerInssAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.calendar_month_outlined,
                question: l10n.documentationAnswerRetirementQuestion,
                answer: l10n.documentationAnswerRetirementAnswer,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GuidePathsSection extends StatelessWidget {
  const _GuidePathsSection({
    required this.l10n,
    required this.onOpenSection,
  });

  final dynamic l10n;
  final ValueChanged<DocumentationGuideSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationPathsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationPathsBody,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
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
                  SizedBox(
                    width: cardWidth,
                    child: _PathCard(
                      icon: Icons.badge_outlined,
                      title: l10n.documentationPathDocumentsTitle,
                      description: l10n.documentationPathDocumentsBody,
                      accent: const Color(0xFFE7F0FF),
                      actionLabel: l10n.documentationOpenTopicAction,
                      onTap: () =>
                          onOpenSection(DocumentationGuideSection.documents),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PathCard(
                      icon: Icons.home_work_outlined,
                      title: l10n.documentationHousingArrivalSectionTitle,
                      description: l10n.documentationHousingArrivalSectionBody,
                      accent: const Color(0xFFFFF5E7),
                      actionLabel: l10n.documentationOpenTopicAction,
                      onTap: () =>
                          onOpenSection(DocumentationGuideSection.housing),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PathCard(
                      icon: Icons.health_and_safety_outlined,
                      title: l10n.documentationPathHealthTitle,
                      description: l10n.documentationPathHealthBody,
                      accent: const Color(0xFFEAF7EF),
                      actionLabel: l10n.documentationOpenTopicAction,
                      onTap: () =>
                          onOpenSection(DocumentationGuideSection.health),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PathCard(
                      icon: Icons.directions_car_outlined,
                      title: l10n.documentationPathDrivingTitle,
                      description: l10n.documentationPathDrivingBody,
                      accent: const Color(0xFFFFF5E7),
                      actionLabel: l10n.documentationOpenTopicAction,
                      onTap: () =>
                          onOpenSection(DocumentationGuideSection.driving),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PathCard(
                      icon: Icons.work_outline_rounded,
                      title: l10n.documentationPathWorkTitle,
                      description: l10n.documentationPathWorkBody,
                      accent: const Color(0xFFEFF5EA),
                      actionLabel: l10n.documentationOpenTopicAction,
                      onTap: () =>
                          onOpenSection(DocumentationGuideSection.work),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PathCard(
                      icon: Icons.wallet_outlined,
                      title: l10n.documentationPathCostsTitle,
                      description: l10n.documentationPathCostsBody,
                      accent: const Color(0xFFF5ECFF),
                      actionLabel: l10n.documentationOpenTopicAction,
                      onTap: () =>
                          onOpenSection(DocumentationGuideSection.costs),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HealthDecisionsSection extends StatelessWidget {
  const _HealthDecisionsSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final iconSurface = AppColors.isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationHealthSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationHealthSectionBody,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final cardWidth = wide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.local_hospital_outlined,
                      title: l10n.documentationHealthPublicTitle,
                      summary: l10n.documentationHealthPublicSummary,
                      highlights: [
                        l10n.documentationHealthPublicBulletOne,
                        l10n.documentationHealthPublicBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFF1F8F3),
                      iconTint: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.favorite_outline_rounded,
                      title: l10n.documentationHealthPrivateTitle,
                      summary: l10n.documentationHealthPrivateSummary,
                      highlights: [
                        l10n.documentationHealthPrivateBulletOne,
                        l10n.documentationHealthPrivateBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFFFF8E7),
                      iconTint: AppColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.route_outlined,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.documentationHealthFlowTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.documentationHealthFlowSummary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
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

class _DrivingJourneySection extends StatelessWidget {
  const _DrivingJourneySection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationDrivingSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationDrivingSectionBody,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final cardWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _JourneyStepCard(
                      step: '01',
                      title: l10n.documentationAnswerForeignLicenseQuestion,
                      description: l10n.documentationAnswerForeignLicenseAnswer,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _JourneyStepCard(
                      step: '02',
                      title: l10n.documentationForeignLicenseTitle,
                      description: l10n.documentationForeignLicenseBulletThree,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _JourneyStepCard(
                      step: '03',
                      title: l10n.documentationDrivingTitle,
                      description: l10n.documentationDrivingSummary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkModelsSection extends StatelessWidget {
  const _WorkModelsSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final iconSurface = AppColors.isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationWorkSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationWorkSectionBody,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final cardWidth = wide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.badge_outlined,
                      title: l10n.documentationWorkCltTitle,
                      summary: l10n.documentationWorkCltSummary,
                      highlights: [
                        l10n.documentationWorkCltBulletOne,
                        l10n.documentationWorkCltBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFEAF0FF),
                      iconTint: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.business_center_outlined,
                      title: l10n.documentationWorkPjTitle,
                      summary: l10n.documentationWorkPjSummary,
                      highlights: [
                        l10n.documentationWorkPjBulletOne,
                        l10n.documentationWorkPjBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFFFF5E7),
                      iconTint: AppColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.savings_outlined,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.documentationRetirementTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.documentationRetirementSummary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
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

class _DeepDiveIntro extends StatelessWidget {
  const _DeepDiveIntro({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark
          ? const Color(0xCC111927)
          : Colors.white.withValues(alpha: 0.62),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.layers_outlined,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.documentationDeepDiveTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.documentationDeepDiveBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: textSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicGrid extends StatelessWidget {
  const _TopicGrid({required this.topics});

  final List<_DocumentationTopic> topics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final panelWidth = wide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final topic in topics)
              SizedBox(
                width: panelWidth,
                child: _DocumentationCard(topic: topic),
              ),
          ],
        );
      },
    );
  }
}

class _QuickStepChip extends StatelessWidget {
  const _QuickStepChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final resolvedBackground = isDark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.12),
            const Color(0xFF101823),
          )
        : accent;
    final resolvedBorder = isDark
        ? accent.withValues(alpha: 0.24)
        : accent.withValues(alpha: 0.7);
    final iconSurface = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.82);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: resolvedBackground,
      borderColor: resolvedBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({
    required this.icon,
    required this.title,
    required this.summary,
    required this.highlights,
    required this.backgroundColor,
    required this.iconTint,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> highlights;
  final Color backgroundColor;
  final Color iconTint;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final resolvedBackground = isDark
        ? Color.alphaBlend(
            backgroundColor.withValues(alpha: 0.12),
            const Color(0xFF101823),
          )
        : backgroundColor;
    final resolvedBorder = isDark
        ? iconTint.withValues(alpha: 0.22)
        : backgroundColor.withValues(alpha: 0.7);
    final iconSurface = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.9);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      backgroundColor: resolvedBackground,
      borderColor: resolvedBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconTint),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
          const SizedBox(height: 14),
          for (final highlight in highlights) ...[
            _InlineHighlight(text: highlight),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({
    required this.step,
    required this.title,
    required this.description,
  });

  final String step;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: isDark
          ? const Color(0xCC111927)
          : Colors.white.withValues(alpha: 0.62),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(step, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
        ],
      ),
    );
  }
}

class _InlineHighlight extends StatelessWidget {
  const _InlineHighlight({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentationCard extends StatelessWidget {
  const _DocumentationCard({required this.topic});

  final _DocumentationTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(topic.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            topic.summary,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: textSoft),
          ),
          const SizedBox(height: 16),
          for (final bullet in topic.bullets) ...[
            _DocumentationBullet(text: bullet),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.documentationOfficialSourceLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: textSoft),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.referenceSourceName(topic.sourceNameKey),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  topic.sourceUrl,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentationBullet extends StatelessWidget {
  const _DocumentationBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAnswerCard extends StatelessWidget {
  const _QuickAnswerCard({
    required this.icon,
    required this.question,
    required this.answer,
  });

  final IconData icon;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: isDark
          ? const Color(0xCC111927)
          : Colors.white.withValues(alpha: 0.62),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textPrimary),
          ),
          const SizedBox(height: 16),
          Text(question, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
        ],
      ),
    );
  }
}

class _DocumentationTopic {
  const _DocumentationTopic({
    required this.icon,
    required this.title,
    required this.summary,
    required this.bullets,
    required this.sourceNameKey,
    required this.sourceUrl,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> bullets;
  final String sourceNameKey;
  final String sourceUrl;
}
