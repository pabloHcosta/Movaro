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
import 'package:movaro_app/features/info/application/quick_guide_question_catalog.dart';
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

double _responsiveCardWidth(
  double maxWidth, {
  int expandedColumns = 3,
  double gap = 14,
}) {
  final columns = maxWidth >= 920
      ? expandedColumns
      : maxWidth >= 620
      ? 2
      : 1;
  return (maxWidth - (gap * (columns - 1))) / columns;
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
  bool _showAllPreparation = false;
  bool _showAllRights = false;

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
                constraints: const BoxConstraints(maxWidth: 1080),
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
                    const SizedBox(height: 38),
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
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = _responsiveCardWidth(
                          constraints.maxWidth,
                        );
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _GuideCard(
                              width: cardWidth,
                              compact: true,
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
                              compact: true,
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
                              compact: true,
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
                              compact: true,
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
                              compact: true,
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
                              compact: true,
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
                    const SizedBox(height: 42),
                    _SectionHeading(
                      title: _guideText(
                        context,
                        pt: 'Resolver um problema agora',
                        es: 'Resolver un problema ahora',
                        en: 'Solve a problem now',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Comece pelo bloqueio mais urgente. Tudo é resolvido dentro da Ajuda.',
                        es: 'Empezá por el bloqueo más urgente. Todo se resuelve dentro de Ayuda.',
                        en: 'Start with the most urgent blocker. Everything stays inside Help.',
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = _responsiveCardWidth(
                          constraints.maxWidth,
                        );
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
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
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 42),
                    _SectionHeading(
                      title: _guideText(
                        context,
                        pt: 'Preparar a mudança',
                        es: 'Preparar la mudanza',
                        en: 'Prepare your move',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Organize chegada, moradia, trabalho, família e viagem sem transformar a dúvida em um plano.',
                        es: 'Organizá llegada, vivienda, trabajo, familia y viaje sin convertir la duda en un plan.',
                        en: 'Organize arrival, housing, work, family, and travel without turning the question into a plan.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = _responsiveCardWidth(
                          constraints.maxWidth,
                        );
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
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
                            if (_showAllPreparation) ...[
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
                                icon: Icons.flight_takeoff_rounded,
                                tone: const Color(0xFF326CE5),
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
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _SectionExpandButton(
                      expanded: _showAllPreparation,
                      collapsedLabel: _guideText(
                        context,
                        pt: 'Ver todos os preparativos',
                        es: 'Ver todos los preparativos',
                        en: 'See all preparation topics',
                      ),
                      expandedLabel: _guideText(
                        context,
                        pt: 'Mostrar menos',
                        es: 'Mostrar menos',
                        en: 'Show less',
                      ),
                      onPressed: () => setState(
                        () => _showAllPreparation = !_showAllPreparation,
                      ),
                    ),
                    const SizedBox(height: 42),
                    _SectionHeading(
                      title: _guideText(
                        context,
                        pt: 'Saúde, direitos e futuro',
                        es: 'Salud, derechos y futuro',
                        en: 'Health, rights, and future',
                      ),
                      body: _guideText(
                        context,
                        pt: 'Encontre cuidado, proteção, canais de reclamação e orientação de longo prazo.',
                        es: 'Encontrá cuidado, protección, canales de reclamo y orientación a largo plazo.',
                        en: 'Find care, protection, complaint channels, and long-term guidance.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = _responsiveCardWidth(
                          constraints.maxWidth,
                        );
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
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
                            if (_showAllRights)
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
                    const SizedBox(height: 12),
                    _SectionExpandButton(
                      expanded: _showAllRights,
                      collapsedLabel: _guideText(
                        context,
                        pt: 'Ver orientação de longo prazo',
                        es: 'Ver orientación a largo plazo',
                        en: 'See long-term guidance',
                      ),
                      expandedLabel: _guideText(
                        context,
                        pt: 'Mostrar menos',
                        es: 'Mostrar menos',
                        en: 'Show less',
                      ),
                      onPressed: () =>
                          setState(() => _showAllRights = !_showAllRights),
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

class _RecentQuestions extends StatefulWidget {
  const _RecentQuestions({
    required this.questions,
    required this.onQuestion,
    required this.onClear,
  });

  final List<String> questions;
  final ValueChanged<String> onQuestion;
  final VoidCallback onClear;

  @override
  State<_RecentQuestions> createState() => _RecentQuestionsState();
}

class _RecentQuestionsState extends State<_RecentQuestions> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final collapsedCount = MediaQuery.sizeOf(context).width < 600 ? 1 : 2;
    final visibleQuestions = _expanded
        ? widget.questions
        : widget.questions.take(collapsedCount).toList(growable: false);
    return FrostedPanel(
      padding: EdgeInsets.all(_expanded ? 18 : 14),
      borderRadius: BorderRadius.circular(_expanded ? 22 : 18),
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
                      pt: _expanded
                          ? 'Perguntas recentes'
                          : 'Continuar de onde parou',
                      es: _expanded
                          ? 'Preguntas recientes'
                          : 'Continuar donde lo dejaste',
                      en: _expanded
                          ? 'Recent questions'
                          : 'Continue where you left off',
                    ),
                    style:
                        (_expanded
                                ? Theme.of(context).textTheme.titleMedium
                                : Theme.of(context).textTheme.titleSmall)
                            ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    widget.questions.length > collapsedCount && !_expanded
                    ? () => setState(() => _expanded = true)
                    : widget.onClear,
                child: Text(
                  widget.questions.length > collapsedCount && !_expanded
                      ? _guideText(
                          context,
                          pt: 'Ver todas (${widget.questions.length})',
                          es: 'Ver todas (${widget.questions.length})',
                          en: 'See all (${widget.questions.length})',
                        )
                      : _guideText(
                          context,
                          pt: 'Apagar',
                          es: 'Borrar',
                          en: 'Clear',
                        ),
                ),
              ),
            ],
          ),
          if (_expanded) ...[
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
          ] else
            const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final question in visibleQuestions)
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
                  onPressed: () => widget.onQuestion(question),
                ),
            ],
          ),
          if (_expanded && widget.questions.length > collapsedCount) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _expanded = false),
              icon: const Icon(Icons.expand_less_rounded),
              label: Text(
                _guideText(
                  context,
                  pt: 'Mostrar menos',
                  es: 'Mostrar menos',
                  en: 'Show less',
                ),
              ),
            ),
          ],
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
  bool get _hasQuery => widget.controller.text.trim().isNotEmpty;

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

  void _clearSearch() {
    widget.controller.clear();
    widget.focusNode.requestFocus();
  }

  void _openQuestion(QuickGuideQuestion question, String languageCode) {
    final value = question.questionFor(languageCode);
    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    widget.focusNode.unfocus();
    widget.onAsk(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final isExpanded = MediaQuery.sizeOf(context).width >= 700;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final fieldSurface = isDark ? const Color(0xFF101F31) : Colors.white;
    final foreground = isDark ? Colors.white : const Color(0xFF10243A);
    final muted = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : const Color(0xFF52677C);
    final languageCode = Localizations.localeOf(context).languageCode;
    final searchResults = QuickGuideQuestionCatalog.search(
      widget.controller.text,
      languageCode: languageCode,
      limit: 4,
    );

    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF081827), Color(0xFF0B2430)]
              : const [Color(0xFFF8FBFF), Color(0xFFEFFAF8)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.focusNode.hasFocus
              ? const Color(0xFF25C7B7)
              : isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFDCE7F0),
          width: widget.focusNode.hasFocus ? 2.25 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF087F7A,
            ).withValues(alpha: widget.focusNode.hasFocus ? 0.18 : 0.09),
            blurRadius: widget.focusNode.hasFocus ? 34 : 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        isExpanded ? 28 : 18,
        isExpanded ? 24 : 18,
        isExpanded ? 28 : 18,
        isExpanded ? 24 : 18,
      ),
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
          SizedBox(height: isExpanded ? 18 : 14),
          Semantics(
            header: true,
            child: Text(
              _guideText(
                context,
                pt: 'O que você precisa resolver?',
                es: '¿Qué necesitás resolver?',
                en: 'What do you need to solve?',
              ),
              style:
                  (isExpanded
                          ? Theme.of(context).textTheme.headlineMedium
                          : Theme.of(context).textTheme.headlineSmall)
                      ?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.08,
                      ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _guideText(
              context,
              pt: 'Digite um assunto e escolha uma pergunta da nossa base revisada.',
              es: 'Escribí un tema y elegí una pregunta de nuestra base revisada.',
              en: 'Enter a topic and choose a question from our reviewed library.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: muted, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A9A8C).withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF0A9A8C).withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 15,
                      color: Color(0xFF0A9A8C),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _guideText(
                          context,
                          pt: '${QuickGuideQuestionCatalog.questions.length} dúvidas revisadas',
                          es: '${QuickGuideQuestionCatalog.questions.length} preguntas revisadas',
                          en: '${QuickGuideQuestionCatalog.questions.length} reviewed questions',
                        ),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? const Color(0xFF8DE9DF)
                              : const Color(0xFF08786F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _guideText(
                  context,
                  pt: 'Você escolhe antes de abrir',
                  es: 'Vos elegís antes de abrir',
                  en: 'You choose before opening',
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: isExpanded ? 18 : 15),
          if (largeText)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _guideText(
                    context,
                    pt: 'Buscar dúvidas revisadas',
                    es: 'Buscar preguntas revisadas',
                    en: 'Search reviewed questions',
                  ),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _guideText(
                    context,
                    pt: 'Digite um tema',
                    es: 'Escribí un tema',
                    en: 'Enter a topic',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    _guideText(
                      context,
                      pt: 'Buscar dúvidas revisadas',
                      es: 'Buscar preguntas revisadas',
                      en: 'Search reviewed questions',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  _guideText(
                    context,
                    pt: 'Digite um tema',
                    es: 'Escribí un tema',
                    en: 'Enter a topic',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: fieldSurface,
              borderRadius: BorderRadius.circular(18),
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
                    Icons.search_rounded,
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
                      pt: 'Buscar dúvidas revisadas',
                      es: 'Buscar preguntas revisadas',
                      en: 'Search reviewed questions',
                    ),
                    child: TextField(
                      key: const ValueKey('guide-question-field'),
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      onSubmitted: (_) => widget.focusNode.unfocus(),
                      maxLines: 1,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: foreground),
                      decoration: InputDecoration(
                        hintText: _guideText(
                          context,
                          pt: 'Ex.: aluguel, CPF ou escola',
                          es: 'Ej.: alquiler, CPF o escuela',
                          en: 'E.g. rent, CPF, or school',
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
                if (_hasQuery)
                  IconButton(
                    key: const ValueKey('guide-question-clear'),
                    onPressed: _clearSearch,
                    tooltip: _guideText(
                      context,
                      pt: 'Limpar busca',
                      es: 'Borrar búsqueda',
                      en: 'Clear search',
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 50,
                      height: 50,
                    ),
                    color: muted,
                    icon: const Icon(Icons.close_rounded),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
          if (_hasQuery) ...[
            const SizedBox(height: 10),
            if (searchResults.isNotEmpty) ...[
              Wrap(
                spacing: 10,
                runSpacing: 3,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    _guideText(
                      context,
                      pt: 'Escolha uma pergunta',
                      es: 'Elegí una pregunta',
                      en: 'Choose a question',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _guideText(
                      context,
                      pt: '${searchResults.length} resultados',
                      es: '${searchResults.length} resultados',
                      en: '${searchResults.length} results',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
            ],
            Semantics(
              liveRegion: true,
              label: searchResults.isEmpty
                  ? _guideText(
                      context,
                      pt: 'Nenhuma dúvida revisada encontrada',
                      es: 'No se encontraron preguntas revisadas',
                      en: 'No reviewed questions found',
                    )
                  : _guideText(
                      context,
                      pt: '${searchResults.length} dúvidas revisadas encontradas',
                      es: '${searchResults.length} preguntas revisadas encontradas',
                      en: '${searchResults.length} reviewed questions found',
                    ),
              child: searchResults.isEmpty
                  ? _GuideSearchEmptyState(muted: muted, isDark: isDark)
                  : _GuideSearchResults(
                      results: searchResults,
                      languageCode: languageCode,
                      foreground: foreground,
                      muted: muted,
                      isDark: isDark,
                      onSelected: (question) =>
                          _openQuestion(question, languageCode),
                    ),
            ),
          ],
          if (!_hasQuery) ...[
            const SizedBox(height: 11),
            Text(
              _guideText(
                context,
                pt: 'Dúvidas populares',
                es: 'Preguntas frecuentes',
                en: 'Popular questions',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                return Semantics(
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
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuideSearchResults extends StatelessWidget {
  const _GuideSearchResults({
    required this.results,
    required this.languageCode,
    required this.foreground,
    required this.muted,
    required this.isDark,
    required this.onSelected,
  });

  final List<QuickGuideQuestion> results;
  final String languageCode;
  final Color foreground;
  final Color muted;
  final bool isDark;
  final ValueChanged<QuickGuideQuestion> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('guide-question-results'),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.045)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : const Color(0xFFD8E5EE),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < results.length; index += 1) ...[
            _GuideSearchResultTile(
              question: results[index],
              languageCode: languageCode,
              foreground: foreground,
              muted: muted,
              onSelected: onSelected,
            ),
            if (index != results.length - 1)
              Divider(
                height: 1,
                indent: 15,
                endIndent: 15,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE3ECF2),
              ),
          ],
        ],
      ),
    );
  }
}

class _GuideSearchResultTile extends StatelessWidget {
  const _GuideSearchResultTile({
    required this.question,
    required this.languageCode,
    required this.foreground,
    required this.muted,
    required this.onSelected,
  });

  final QuickGuideQuestion question;
  final String languageCode;
  final Color foreground;
  final Color muted;
  final ValueChanged<QuickGuideQuestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final value = question.questionFor(languageCode);
    final topic = question.topicFor(languageCode);
    return Semantics(
      button: true,
      label: _guideText(
        context,
        pt: '$value. Tema $topic. Abrir resposta revisada.',
        es: '$value. Tema $topic. Abrir respuesta revisada.',
        en: '$value. $topic topic. Open reviewed answer.',
      ),
      child: ExcludeSemantics(
        child: InkWell(
          key: ValueKey('guide-question-suggestion-${question.id}'),
          onTap: () => onSelected(question),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 66),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A9A8C).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      size: 19,
                      color: Color(0xFF0A9A8C),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topic.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF0A8A7F),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.45,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: muted, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideSearchEmptyState extends StatelessWidget {
  const _GuideSearchEmptyState({required this.muted, required this.isDark});

  final Color muted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('guide-question-empty'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.045)
            : Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : const Color(0xFFD8E5EE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE58A16).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              color: Color(0xFFE58A16),
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _guideText(
                    context,
                    pt: 'Ainda não temos essa dúvida revisada',
                    es: 'Todavía no tenemos esa pregunta revisada',
                    en: 'We do not have that reviewed question yet',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  _guideText(
                    context,
                    pt: 'Tente um assunto mais curto ou explore os temas abaixo. Não mostraremos uma resposta aproximada.',
                    es: 'Probá con un tema más corto o explorá los temas de abajo. No mostraremos una respuesta aproximada.',
                    en: 'Try a shorter topic or explore the themes below. We will not show an approximate answer.',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: muted, height: 1.38),
                ),
              ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF087FE8), Color(0xFF13A697)],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.45,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionExpandButton extends StatelessWidget {
  const _SectionExpandButton({
    required this.expanded,
    required this.collapsedLabel,
    required this.expandedLabel,
    required this.onPressed,
  });

  final bool expanded;
  final String collapsedLabel;
  final String expandedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = expanded ? expandedLabel : collapsedLabel;
    return Semantics(
      button: true,
      expanded: expanded,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(
              expanded ? Icons.keyboard_arrow_up_rounded : Icons.add_rounded,
            ),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                color: AppColors.isDark(context)
                    ? Colors.white.withValues(alpha: 0.14)
                    : const Color(0xFFD4E1EC),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatefulWidget {
  const _GuideCard({
    required this.width,
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    required this.onTap,
    this.compact = false,
  });

  final double width;
  final IconData icon;
  final Color tone;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _highlighted => _hovered || _focused;

  Widget _iconTile({required bool compact}) {
    final size = compact ? 44.0 : 48.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(widget.tone, Colors.white, 0.12)!, widget.tone],
        ),
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: widget.tone.withValues(alpha: 0.24),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -9,
            right: -7,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(widget.icon, color: Colors.white, size: compact ? 22 : 24),
        ],
      ),
    );
  }

  Widget _arrow(BuildContext context, bool reduceMotion) {
    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 170),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _highlighted
            ? widget.tone.withValues(alpha: 0.18)
            : widget.tone.withValues(alpha: 0.09),
        shape: BoxShape.circle,
        border: Border.all(color: widget.tone.withValues(alpha: 0.12)),
      ),
      child: Icon(Icons.arrow_forward_rounded, size: 19, color: widget.tone),
    );
  }

  Widget _copy(BuildContext context, {required bool largeText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.18,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.body,
          maxLines: largeText ? 4 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.34,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final surface = isDark ? const Color(0xFF0E1B2A) : const Color(0xFFFFFFFF);
    return SizedBox(
      width: widget.width,
      child: Semantics(
        button: true,
        label: '${widget.title}. ${widget.body}',
        child: ExcludeSemantics(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedScale(
              scale: reduceMotion
                  ? 1
                  : _pressed
                  ? 0.986
                  : _highlighted
                  ? 1.006
                  : 1,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0, 0.48, 1],
                    colors: [
                      widget.tone.withValues(alpha: isDark ? 0.18 : 0.105),
                      surface.withValues(alpha: isDark ? 0.96 : 0.98),
                      surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _highlighted
                        ? widget.tone.withValues(alpha: 0.74)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : widget.tone.withValues(alpha: 0.18),
                    width: _focused ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tone.withValues(
                        alpha: _highlighted ? 0.17 : 0.08,
                      ),
                      blurRadius: _highlighted ? 22 : 15,
                      offset: Offset(0, _highlighted ? 9 : 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.035,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onHover: (value) {
                      if (_hovered != value) setState(() => _hovered = value);
                    },
                    onFocusChange: (value) => setState(() => _focused = value),
                    onHighlightChanged: (value) =>
                        setState(() => _pressed = value),
                    borderRadius: BorderRadius.circular(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: widget.compact ? 80 : 90,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.compact ? 12 : 14,
                          vertical: widget.compact ? 11 : 13,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _iconTile(compact: widget.compact),
                            SizedBox(width: widget.compact ? 12 : 14),
                            Expanded(
                              child: _copy(context, largeText: largeText),
                            ),
                            const SizedBox(width: 8),
                            _arrow(context, reduceMotion),
                          ],
                        ),
                      ),
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

class _PracticalToolCard extends StatefulWidget {
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
  State<_PracticalToolCard> createState() => _PracticalToolCardState();
}

class _PracticalToolCardState extends State<_PracticalToolCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _highlighted => _hovered || _focused;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.body}',
      child: ExcludeSemantics(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            scale: reduceMotion
                ? 1
                : _pressed
                ? 0.986
                : _highlighted
                ? 1.006
                : 1,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _focused
                      ? Colors.white.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.12),
                  width: _focused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.last.withValues(
                      alpha: _highlighted ? 0.28 : 0.17,
                    ),
                    blurRadius: _highlighted ? 26 : 18,
                    offset: Offset(0, _highlighted ? 11 : 7),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onHover: (value) {
                    if (_hovered != value) setState(() => _hovered = value);
                  },
                  onFocusChange: (value) => setState(() => _focused = value),
                  onHighlightChanged: (value) =>
                      setState(() => _pressed = value),
                  borderRadius: BorderRadius.circular(22),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.colors,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.eyebrow,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: const Color(0xFFB9FFF4),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.75,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      height: 1.16,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.body,
                                maxLines: largeText ? 4 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                      height: 1.34,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        AnimatedContainer(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: _highlighted ? 0.2 : 0.12,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
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
