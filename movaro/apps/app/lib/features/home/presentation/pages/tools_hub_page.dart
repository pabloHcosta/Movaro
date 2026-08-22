import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/info/presentation/pages/quick_guide_answer_page.dart';
import 'package:movaro_app/features/info/application/quick_guide_preferences_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

String _guideText(
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

/// Search-first guide hub, deliberately independent from the migration plan.
/// It shares reviewed knowledge with the journey, but never imports journey
/// state or opens journey/tool surfaces.
class ToolsHubPage extends StatefulWidget {
  const ToolsHubPage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  State<ToolsHubPage> createState() => _ToolsHubPageState();
}

class _ToolsHubPageState extends State<ToolsHubPage> {
  final TextEditingController _questionController = TextEditingController();
  final FocusNode _questionFocusNode = FocusNode();
  final QuickGuidePreferencesStore _preferencesStore =
      const QuickGuidePreferencesStore();
  List<String> _recentQuestions = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadRecentQuestions());
    unawaited(_preferencesStore.recordEvent('guideOpened'));
  }

  Future<void> _loadRecentQuestions() async {
    final recent = await _preferencesStore.loadRecentQuestions();
    if (mounted) setState(() => _recentQuestions = recent);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _questionFocusNode.dispose();
    super.dispose();
  }

  void _ask(String question) {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      _questionFocusNode.requestFocus();
      return;
    }
    setState(() {
      _recentQuestions = [
        trimmed,
        ..._recentQuestions.where(
          (item) => item.toLowerCase() != trimmed.toLowerCase(),
        ),
      ].take(5).toList(growable: false);
    });
    unawaited(
      _preferencesStore.recordQuery(trimmed, topic: _questionTopic(trimmed)),
    );
    HapticFeedback.selectionClick();
    Navigator.pushNamed(
      context,
      AppRoutes.quickGuideAnswer,
      arguments: QuickGuideAnswerRequest(question: trimmed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionSuggestions = [
      _guideText(
        context,
        pt: 'Como funciona a escola pública?',
        es: '¿Cómo funciona la escuela pública?',
        en: 'How does public school work?',
      ),
      _guideText(
        context,
        pt: 'O que preciso para alugar?',
        es: '¿Qué necesito para alquilar?',
        en: 'What do I need to rent?',
      ),
      _guideText(
        context,
        pt: 'Como procurar trabalho?',
        es: '¿Cómo busco trabajo?',
        en: 'How do I look for work?',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    132,
                  ),
                  children: [
                    AppGlassHeader(
                      title: _guideText(
                        context,
                        pt: 'Ajuda',
                        es: 'Ayuda',
                        en: 'Help',
                      ),
                      subtitle: _guideText(
                        context,
                        pt: 'Respostas e recursos sem entrar no plano',
                        es: 'Respuestas y recursos sin entrar al plan',
                        en: 'Answers and resources without entering your plan',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GuideHero(
                      controller: _questionController,
                      focusNode: _questionFocusNode,
                      cityName: null,
                      suggestions: questionSuggestions,
                      onAsk: _ask,
                    ),
                    if (_recentQuestions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _RecentQuestions(
                        questions: _recentQuestions,
                        onQuestion: _ask,
                        onClear: () async {
                          await _preferencesStore.clearRecentQuestions();
                          if (mounted) {
                            setState(() => _recentQuestions = const []);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 28),
                    _SectionHeading(
                      title: _guideText(
                        context,
                        pt: 'Explorar por tema',
                        es: 'Explorar por tema',
                        en: 'Explore by topic',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Entenda o assunto com informação organizada e fontes oficiais.',
                        es: 'Entendé el tema con información organizada y fuentes oficiales.',
                        en: 'Understand the topic with organized information and official sources.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth >= 700
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.folder_copy_outlined,
                              tone: const Color(0xFF7557E8),
                              title: _guideText(
                                context,
                                pt: 'Documentos',
                                es: 'Documentos',
                                en: 'Documents',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Residência, CPF, registros e fontes oficiais.',
                                es: 'Residencia, CPF, registros y fuentes oficiales.',
                                en: 'Residency, CPF, records, and official sources.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Qual é a diferença entre CPF, protocolo e CRNM?',
                                  es: '¿Cuál es la diferencia entre CPF, protocolo y CRNM?',
                                  en: 'What is the difference between CPF, protocol, and CRNM?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.school_outlined,
                              tone: const Color(0xFF00897B),
                              title: _guideText(
                                context,
                                pt: 'Educação',
                                es: 'Educación',
                                en: 'Education',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Escola, universidade, matrícula e validação.',
                                es: 'Escuela, universidad, matrícula y validación.',
                                en: 'School, university, enrollment, and validation.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como matriculo meu filho na escola pública?',
                                  es: '¿Cómo inscribo a mi hijo en la escuela pública?',
                                  en: 'How do I enroll my child in public school?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.home_work_outlined,
                              tone: const Color(0xFFE58A16),
                              title: _guideText(
                                context,
                                pt: 'Moradia e aluguel',
                                es: 'Vivienda y alquiler',
                                en: 'Housing and rent',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Garantias, contratos e busca mais segura.',
                                es: 'Garantías, contratos y una búsqueda más segura.',
                                en: 'Guarantees, contracts, and safer searching.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Quais garantias podem pedir no aluguel?',
                                  es: '¿Qué garantías pueden pedir para alquilar?',
                                  en: 'Which guarantees can a landlord request?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.work_outline_rounded,
                              tone: AppColors.primary,
                              title: _guideText(
                                context,
                                pt: 'Trabalho',
                                es: 'Trabajo',
                                en: 'Work',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Mercado, documentos e canais para procurar vagas.',
                                es: 'Mercado, documentos y canales para buscar empleo.',
                                en: 'Market, documents, and channels for finding jobs.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'O que preciso para trabalhar formalmente?',
                                  es: '¿Qué necesito para trabajar formalmente?',
                                  en: 'What do I need for formal employment?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.savings_outlined,
                              tone: AppColors.success,
                              title: _guideText(
                                context,
                                pt: 'Custos e dinheiro',
                                es: 'Costos y dinero',
                                en: 'Costs and money',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Reserva, primeiros gastos, contas e pagamentos.',
                                es: 'Reserva, primeros gastos, cuentas y pagos.',
                                en: 'Reserve, first expenses, accounts, and payments.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como organizo uma reserva para os primeiros meses?',
                                  es: '¿Cómo organizo una reserva para los primeros meses?',
                                  en: 'How do I organize a reserve for the first months?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.health_and_safety_outlined,
                              tone: const Color(0xFFE34B67),
                              title: _guideText(
                                context,
                                pt: 'Saúde',
                                es: 'Salud',
                                en: 'Health',
                              ),
                              body: _guideText(
                                context,
                                pt: 'SUS, atendimento, medicamentos e emergências.',
                                es: 'SUS, atención, medicamentos y emergencias.',
                                en: 'SUS, care, medicines, and emergencies.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como uma pessoa estrangeira acessa o SUS?',
                                  es: '¿Cómo accede una persona extranjera al SUS?',
                                  en: 'How can a foreign national access SUS?',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    _SectionHeading(
                      title: _guideText(
                        context,
                        pt: 'Perguntas complexas, respostas diretas',
                        es: 'Preguntas complejas, respuestas directas',
                        en: 'Complex questions, direct answers',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Cada opção abre uma resposta dentro da Ajuda. Nenhuma consulta usa ou altera seu plano.',
                        es: 'Cada opción abre una respuesta dentro de Ayuda. Ninguna consulta usa o cambia tu plan.',
                        en: 'Each option opens an answer inside Help. No query uses or changes your plan.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PracticalToolCard(
                      icon: Icons.account_tree_outlined,
                      colors: const [Color(0xFF24314D), Color(0xFF506CA8)],
                      eyebrow: _guideText(
                        context,
                        pt: 'COMECE PELO BLOQUEIO',
                        es: 'EMPEZÁ POR EL BLOQUEO',
                        en: 'START WITH THE BLOCKER',
                      ),
                      title: _guideText(
                        context,
                        pt: 'Tudo depende de tudo? Descubra por onde começar',
                        es: '¿Todo depende de todo? Descubrí por dónde empezar',
                        en: 'Everything depends on everything? Find where to start',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Ordene residência, CPF, endereço, telefone, banco, trabalho e escola sem entrar no plano.',
                        es: 'Ordená residencia, CPF, domicilio, teléfono, banco, trabajo y escuela sin entrar al plan.',
                        en: 'Order residence, CPF, address, phone, banking, work, and school without entering the plan.',
                      ),
                      onTap: () => _ask(
                        _guideText(
                          context,
                          pt: 'Tenho documentos, endereço e banco bloqueando uns aos outros. Por onde começo?',
                          es: 'Tengo documentos, domicilio y banco bloqueándose entre sí. ¿Por dónde empiezo?',
                          en: 'My documents, address, and bank account block one another. Where do I start?',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth >= 700
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.rule_folder_outlined,
                              tone: const Color(0xFF5B4DB1),
                              title: _guideText(
                                context,
                                pt: 'Destravar processo ou documento',
                                es: 'Destrabar trámite o documento',
                                en: 'Unblock a process or document',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Atraso, CRNM que não chegou e dados divergentes, com escalada rastreável.',
                                es: 'Demora, CRNM que no llegó y datos divergentes, con seguimiento rastreable.',
                                en: 'Delays, a missing CRNM, and conflicting data, with traceable escalation.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Meu processo de residência está parado. Como destravo?',
                                  es: 'Mi trámite de residencia está demorado. ¿Cómo lo destrabo?',
                                  en: 'My residence process is stalled. How do I unblock it?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.account_balance_wallet_outlined,
                              tone: const Color(0xFF008B7A),
                              title: _guideText(
                                context,
                                pt: 'Destravar banco e Pix',
                                es: 'Destrabar banco y Pix',
                                en: 'Unlock banking and Pix',
                              ),
                              body: _guideText(
                                context,
                                pt: 'CPF, telefone, endereço, conta e gov.br em uma sequência.',
                                es: 'CPF, teléfono, domicilio, cuenta y gov.br en secuencia.',
                                en: 'CPF, phone, address, account, and gov.br in sequence.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'O banco recusou minha conta. Como resolvo sem resposta genérica?',
                                  es: 'El banco rechazó mi cuenta. ¿Cómo lo resuelvo sin una respuesta genérica?',
                                  en: 'The bank refused my account. How do I resolve it without a generic answer?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.savings_outlined,
                              tone: AppColors.success,
                              title: _guideText(
                                context,
                                pt: 'Entender a reserva de chegada',
                                es: 'Entender la reserva de llegada',
                                en: 'Understand the arrival reserve',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Instalação e sobrevivência para 30, 60 ou 90 dias.',
                                es: 'Instalación y supervivencia para 30, 60 o 90 días.',
                                en: 'Setup and living reserve for 30, 60, or 90 days.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Quanto devo reservar para 30, 60 ou 90 dias?',
                                  es: '¿Cuánto debería reservar para 30, 60 o 90 días?',
                                  en: 'How much should I reserve for 30, 60, or 90 days?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.home_work_outlined,
                              tone: const Color(0xFFD47B19),
                              title: _guideText(
                                context,
                                pt: 'Analisar um aluguel',
                                es: 'Analizar un alquiler',
                                en: 'Review a rental',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Garantia, custo inicial, contrato, vistoria e cobranças.',
                                es: 'Garantía, costo inicial, contrato, inspección y cargos.',
                                en: 'Guarantee, entry cost, contract, inspection, and charges.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'O que verifico antes de assinar um aluguel?',
                                  es: '¿Qué reviso antes de firmar un alquiler?',
                                  en: 'What should I check before signing a rental?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.work_outline_rounded,
                              tone: AppColors.primary,
                              title: _guideText(
                                context,
                                pt: 'Montar caminho de trabalho',
                                es: 'Armar camino de trabajo',
                                en: 'Build a work path',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Documentos, CLT, PJ, remoto e diploma profissional.',
                                es: 'Documentos, CLT, PJ, remoto y diploma profesional.',
                                en: 'Documents, CLT, self-employment, remote work, and qualifications.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Posso trabalhar como CLT, MEI ou remoto?',
                                  es: '¿Puedo trabajar como CLT, MEI o remoto?',
                                  en: 'Can I work as an employee, MEI, or remotely?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.receipt_long_outlined,
                              tone: const Color(0xFF7650B5),
                              title: _guideText(
                                context,
                                pt: 'Organizar renda e impostos',
                                es: 'Organizar ingresos e impuestos',
                                en: 'Organize income and tax',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Triagem segura para renda, bens e empresa no exterior.',
                                es: 'Orientación segura para ingresos, bienes y empresa afuera.',
                                en: 'Safe screening for foreign income, assets, and companies.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Quando viro residente fiscal e como organizo renda do exterior?',
                                  es: '¿Cuándo paso a ser residente fiscal y cómo organizo ingresos del exterior?',
                                  en: 'When do I become a tax resident and how do I organize foreign income?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.family_restroom_rounded,
                              tone: const Color(0xFFB47A36),
                              title: _guideText(
                                context,
                                pt: 'Família, escola e diploma',
                                es: 'Familia, escuela y diploma',
                                en: 'Family, school, and qualifications',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Menores, reunião familiar, matrícula e reconhecimento.',
                                es: 'Menores, reunión familiar, matrícula y reconocimiento.',
                                en: 'Minors, family reunion, enrollment, and recognition.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como organizo residência, escola e documentos da minha família?',
                                  es: '¿Cómo organizo residencia, escuela y documentos de mi familia?',
                                  en: 'How do I organize residence, school, and documents for my family?',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    _SectionHeading(
                      title: _guideText(
                        context,
                        pt: 'Vida, proteção e futuro',
                        es: 'Vida, protección y futuro',
                        en: 'Life, protection, and future',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Resolva situações que aparecem depois da decisão de mudar.',
                        es: 'Resolvé situaciones que aparecen después de decidir mudarte.',
                        en: 'Solve situations that arise after deciding to move.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth >= 700
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.health_and_safety_outlined,
                              tone: const Color(0xFFC04468),
                              title: _guideText(
                                context,
                                pt: 'Continuar tratamento e medicamentos',
                                es: 'Continuar tratamiento y medicamentos',
                                en: 'Continue treatment and medicines',
                              ),
                              body: _guideText(
                                context,
                                pt: 'SUS, receita, vacinação, gestação e saúde mental.',
                                es: 'SUS, receta, vacunas, embarazo y salud mental.',
                                en: 'SUS, prescriptions, vaccines, pregnancy, and mental health.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como continuo tratamento, vacinas ou pré-natal no Brasil?',
                                  es: '¿Cómo continúo tratamiento, vacunas o prenatal en Brasil?',
                                  en: 'How do I continue treatment, vaccinations, or prenatal care in Brazil?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.pets_outlined,
                              tone: const Color(0xFF9A6A22),
                              title: _guideText(
                                context,
                                pt: 'Levar pets, bagagem e bens',
                                es: 'Llevar mascotas, equipaje y bienes',
                                en: 'Bring pets, baggage, and goods',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Certificados, medicamentos, alimentos, mudança e veículo.',
                                es: 'Certificados, medicamentos, alimentos, mudanza y vehículo.',
                                en: 'Certificates, medicines, food, household goods, and vehicles.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como levo pet, bagagem e bens para o Brasil?',
                                  es: '¿Cómo llevo mascota, equipaje y bienes a Brasil?',
                                  en: 'How do I bring a pet, baggage, and goods to Brazil?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.electrical_services_outlined,
                              tone: const Color(0xFF2876A8),
                              title: _guideText(
                                context,
                                pt: 'Ativar telefone, internet, água e luz',
                                es: 'Activar teléfono, internet, agua y luz',
                                en: 'Activate phone, internet, water, and power',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Documentos, titularidade, contratos e comprovante.',
                                es: 'Documentos, titularidad, contratos y comprobante.',
                                en: 'Documents, account ownership, contracts, and proof.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como ativo telefone, internet, água e energia?',
                                  es: '¿Cómo activo teléfono, internet, agua y energía?',
                                  en: 'How do I activate phone, internet, water, and electricity?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.volunteer_activism_outlined,
                              tone: const Color(0xFF9B3C61),
                              title: _guideText(
                                context,
                                pt: 'Encontrar proteção e ajuda',
                                es: 'Encontrar protección y ayuda',
                                en: 'Find protection and support',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Urgência, violência, discriminação e assistência jurídica.',
                                es: 'Urgencia, violencia, discriminación y asistencia jurídica.',
                                en: 'Emergency, violence, discrimination, and legal support.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Onde encontro proteção ou assistência jurídica e social?',
                                  es: '¿Dónde encuentro protección o asistencia jurídica y social?',
                                  en: 'Where can I find protection or legal and social support?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.gavel_outlined,
                              tone: const Color(0xFF7752B3),
                              title: _guideText(
                                context,
                                pt: 'Resolver cobrança ou problema de consumo',
                                es: 'Resolver cobro o problema de consumo',
                                en: 'Resolve a charge or consumer problem',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Protocolos, ouvidoria, regulador, Procon e Consumidor.gov.',
                                es: 'Protocolos, defensoría, regulador, Procon y Consumidor.gov.',
                                en: 'Protocols, ombudsman, regulator, Procon, and Consumidor.gov.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como faço uma reclamação contra uma empresa?',
                                  es: '¿Cómo hago un reclamo contra una empresa?',
                                  en: 'How do I file a complaint against a company?',
                                ),
                              ),
                            ),
                            _GuideCard(
                              width: cardWidth,
                              icon: Icons.timeline_rounded,
                              tone: const Color(0xFF357F73),
                              title: _guideText(
                                context,
                                pt: 'Planejar previdência e naturalização',
                                es: 'Planificar previsión y naturalización',
                                en: 'Plan pension and naturalization',
                              ),
                              body: _guideText(
                                context,
                                pt: 'Contribuições Brasil–Argentina, benefícios e futuro.',
                                es: 'Aportes Brasil–Argentina, beneficios y futuro.',
                                en: 'Brazil–Argentina contributions, benefits, and future.',
                              ),
                              onTap: () => _ask(
                                _guideText(
                                  context,
                                  pt: 'Como funcionam previdência e naturalização?',
                                  es: '¿Cómo funcionan la previsión y la naturalización?',
                                  en: 'How do social security and naturalization work?',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    _PracticalToolCard(
                      icon: Icons.radar_rounded,
                      colors: const [Color(0xFF07354B), Color(0xFF087F7A)],
                      eyebrow: _guideText(
                        context,
                        pt: 'PROTEÇÃO MOVARO',
                        es: 'PROTECCIÓN MOVARO',
                        en: 'MOVARO PROTECTION',
                      ),
                      title: _guideText(
                        context,
                        pt: 'Confira uma proposta antes de confiar',
                        es: 'Revisá una propuesta antes de confiar',
                        en: 'Check an offer before you trust it',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Cole uma oferta de aluguel, vaga ou serviço e veja sinais conhecidos de fraude.',
                        es: 'Pegá una oferta de alquiler, empleo o servicio y revisá señales conocidas de fraude.',
                        en: 'Paste a housing, job, or service offer and check known fraud signals.',
                      ),
                      onTap: () => _ask(
                        _guideText(
                          context,
                          pt: 'Como identifico sinais de golpe em aluguel ou vaga?',
                          es: '¿Cómo identifico señales de estafa en alquiler o empleo?',
                          en: 'How do I identify scam signs in a rental or job offer?',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PracticalToolCard(
                      icon: Icons.flight_takeoff_rounded,
                      colors: const [Color(0xFF244FC7), Color(0xFF087FE8)],
                      eyebrow: _guideText(
                        context,
                        pt: 'DÚVIDA DE VIAGEM',
                        es: 'DUDA DE VIAJE',
                        en: 'TRAVEL QUESTION',
                      ),
                      title: _guideText(
                        context,
                        pt: 'Entender a compra do voo',
                        es: 'Entender la compra del vuelo',
                        en: 'Understand flight booking',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Documentos, aeroportos, bagagem, datas e fatores que mudam o preço.',
                        es: 'Documentos, aeropuertos, equipaje, fechas y factores que cambian el precio.',
                        en: 'Documents, airports, baggage, dates, and factors that change prices.',
                      ),
                      onTap: () => _ask(
                        _guideText(
                          context,
                          pt: 'O que devo conferir antes de comprar um voo para o Brasil?',
                          es: '¿Qué debo revisar antes de comprar un vuelo a Brasil?',
                          en: 'What should I check before booking a flight to Brazil?',
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
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 3,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController:
            widget.migrationQuestionnaireController,
      ),
    );
  }
}

class _RecentQuestions extends StatelessWidget {
  const _RecentQuestions({
    required this.questions,
    required this.onQuestion,
    required this.onClear,
  });

  final List<String> questions;
  final ValueChanged<String> onQuestion;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    _guideText(
                      context,
                      pt: 'Perguntas recentes',
                      es: 'Preguntas recientes',
                      en: 'Recent questions',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(
                  _guideText(context, pt: 'Apagar', es: 'Borrar', en: 'Clear'),
                ),
              ),
            ],
          ),
          Text(
            _guideText(
              context,
              pt: 'Salvas somente neste dispositivo.',
              es: 'Guardadas sólo en este dispositivo.',
              en: 'Stored only on this device.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final question in questions)
                ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 18),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onPressed: () => onQuestion(question),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideHero extends StatefulWidget {
  const _GuideHero({
    required this.controller,
    required this.focusNode,
    required this.cityName,
    required this.suggestions,
    required this.onAsk,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? cityName;
  final List<String> suggestions;
  final ValueChanged<String> onAsk;

  @override
  State<_GuideHero> createState() => _GuideHeroState();
}

class _GuideHeroState extends State<_GuideHero> {
  bool get _canSubmit => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.focusNode.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant _GuideHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_refresh);
      widget.focusNode.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.focusNode.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _submit() => widget.onAsk(widget.controller.text);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final fieldSurface = isDark ? const Color(0xFF101F31) : Colors.white;
    final foreground = isDark ? Colors.white : const Color(0xFF10243A);
    final muted = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : const Color(0xFF52677C);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0A1726), Color(0xFF0B1D2B)]
              : const [Color(0xFFF8FBFF), Color(0xFFF1FAF8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.focusNode.hasFocus
              ? const Color(0xFF25C7B7)
              : isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFDCE7F0),
          width: widget.focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF087F7A,
            ).withValues(alpha: widget.focusNode.hasFocus ? 0.18 : 0.09),
            blurRadius: widget.focusNode.hasFocus ? 28 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1677E8), Color(0xFF16A99A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _guideText(
                    context,
                    pt: 'AJUDA MOVARO · CONTEÚDO REVISADO',
                    es: 'AYUDA MOVARO · CONTENIDO REVISADO',
                    en: 'MOVARO HELP · REVIEWED CONTENT',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? const Color(0xFF8DE9DF)
                        : const Color(0xFF08786F),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
              if (widget.cityName != null)
                _GuideContextPill(
                  cityName: widget.cityName!,
                  foreground: muted,
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              _guideText(
                context,
                pt: 'O que você precisa resolver?',
                es: '¿Qué necesitás resolver?',
                en: 'What do you need to solve?',
              ),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _guideText(
              context,
              pt: 'Descreva sua dúvida em uma frase. A resposta não altera seu plano.',
              es: 'Describí tu duda en una frase. La respuesta no cambia tu plan.',
              en: 'Describe your question in one sentence. The answer does not change your plan.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: muted, height: 1.35),
          ),
          const SizedBox(height: 13),
          Text(
            _guideText(
              context,
              pt: 'Faça sua pergunta',
              es: 'Hacé tu pregunta',
              en: 'Ask a question',
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: fieldSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.focusNode.hasFocus
                    ? const Color(0xFF25C7B7)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFD6E2EC),
                width: widget.focusNode.hasFocus ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: widget.focusNode.hasFocus
                        ? const Color(0xFF0A9A8C)
                        : muted,
                  ),
                ),
                Expanded(
                  child: Semantics(
                    textField: true,
                    label: _guideText(
                      context,
                      pt: 'Faça sua pergunta',
                      es: 'Hacé tu pregunta',
                      en: 'Ask a question',
                    ),
                    child: TextField(
                      key: const ValueKey('guide-question-field'),
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      onSubmitted: widget.onAsk,
                      maxLines: 1,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: foreground),
                      decoration: InputDecoration(
                        hintText: _guideText(
                          context,
                          pt: 'Ex.: Consigo alugar sem fiador?',
                          es: 'Ej.: ¿Puedo alquilar sin garantía?',
                          en: 'E.g. Can I rent without a guarantor?',
                        ),
                        hintStyle: TextStyle(color: muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  enabled: _canSubmit,
                  label: _guideText(
                    context,
                    pt: 'Perguntar',
                    es: 'Preguntar',
                    en: 'Ask',
                  ),
                  child: ExcludeSemantics(
                    child: IconButton(
                      key: const ValueKey('guide-question-submit'),
                      onPressed: _canSubmit ? _submit : null,
                      tooltip: _guideText(
                        context,
                        pt: 'Perguntar',
                        es: 'Preguntar',
                        en: 'Ask',
                      ),
                      constraints: const BoxConstraints.tightFor(
                        width: 50,
                        height: 50,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: _canSubmit
                            ? const Color(0xFF087FE8)
                            : isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE7EEF5),
                        foregroundColor: _canSubmit
                            ? Colors.white
                            : muted.withValues(alpha: 0.7),
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Text(
            _guideText(
              context,
              pt: 'Ou resolva em um toque',
              es: 'O resolvé en un toque',
              en: 'Or solve it in one tap',
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.suggestions.length, (index) {
                final question = widget.suggestions[index];
                final icons = [
                  Icons.school_outlined,
                  Icons.home_work_outlined,
                  Icons.work_outline_rounded,
                ];
                final labels = [
                  _guideText(
                    context,
                    pt: 'Escola pública',
                    es: 'Escuela pública',
                    en: 'Public school',
                  ),
                  _guideText(
                    context,
                    pt: 'Alugar sem fiador',
                    es: 'Alquilar sin garantía',
                    en: 'Rent without a guarantor',
                  ),
                  _guideText(
                    context,
                    pt: 'Trabalho e documentos',
                    es: 'Trabajo y documentos',
                    en: 'Work and documents',
                  ),
                ];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.suggestions.length - 1 ? 0 : 7,
                  ),
                  child: Semantics(
                    button: true,
                    label:
                        '$question. ${_guideText(context, pt: 'Abrir resposta', es: 'Abrir respuesta', en: 'Open answer')}',
                    child: ActionChip(
                      avatar: Icon(icons[index], size: 17),
                      label: Text(labels[index]),
                      onPressed: () => widget.onAsk(question),
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.86),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFD8E4ED),
                      ),
                      labelStyle: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideContextPill extends StatelessWidget {
  const _GuideContextPill({
    required this.cityName,
    required this.foreground,
    required this.isDark,
  });

  final String cityName;
  final Color foreground;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _guideText(
        context,
        pt: 'Contexto opcional: $cityName',
        es: 'Contexto opcional: $cityName',
        en: 'Optional context: $cityName',
      ),
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 250),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: foreground),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _guideText(
                    context,
                    pt: '$cityName · não altera o plano',
                    es: '$cityName · no cambia el plan',
                    en: '$cityName · does not change the plan',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
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

String _questionTopic(String value) {
  final normalized = value.toLowerCase();
  if (RegExp(r'escola|escuela|school|univers').hasMatch(normalized)) {
    return 'education';
  }
  if (RegExp(r'alug|alquiler|rent|moradia|vivienda').hasMatch(normalized)) {
    return 'housing';
  }
  if (RegExp(
    r'viol[eê]ncia|violencia|discrimin|xenof|explora|legal aid|defensor',
  ).hasMatch(normalized)) {
    return 'protection';
  }
  if (RegExp(
    r'consum|cobran|reclama|fraud|golpe|estafa',
  ).hasMatch(normalized)) {
    return 'consumer';
  }
  if (RegExp(r'trabal|trabaj|work|emprego|empleo').hasMatch(normalized)) {
    return 'work';
  }
  if (RegExp(r'imposto|impuest|tax|renda exterior').hasMatch(normalized)) {
    return 'tax';
  }
  if (RegExp(r'banco|bank|pix|gov.br').hasMatch(normalized)) return 'finance';
  if (RegExp(
    r'sa[uú]de|salud|health|medic|vacina|embaraz|gesta|mental',
  ).hasMatch(normalized)) {
    return 'health';
  }
  if (RegExp(
    r'pet|mascota|c[aã]o|perro|gato|aduana|alf[aâ]ndega|bagagem|equipaje',
  ).hasMatch(normalized)) {
    return 'pets_customs';
  }
  if (RegExp(
    r'internet|telefone|tel[eé]fono|energia|electric|[aá]gua|agua',
  ).hasMatch(normalized)) {
    return 'utilities';
  }
  if (RegExp(r'aposent|jubil|pension|previd|naturaliza').hasMatch(normalized)) {
    return 'long_term';
  }
  if (RegExp(r'cpf|resid|crnm|document').hasMatch(normalized)) {
    return 'documents';
  }
  return 'general';
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.width,
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final Color tone;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        label: '$title. $body',
        child: ExcludeSemantics(
          child: FrostedPanel(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 104),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: tone.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(icon, color: tone, size: 23),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSoftFor(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticalToolCard extends StatelessWidget {
  const _PracticalToolCard({
    required this.icon,
    required this.colors,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final List<Color> colors;
  final String eyebrow;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $body',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(icon, color: Colors.white, size: 27),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFFB9FFF4),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
