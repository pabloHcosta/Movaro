import 'package:flutter/material.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

String _toolsText(
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

class ToolsHubPage extends StatelessWidget {
  const ToolsHubPage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  bool get _hasConfirmedCity =>
      migrationQuestionnaireController.generatedPlan?.confirmedCity != null;

  void _openGuideTask(
    BuildContext context, {
    required String itemId,
    required DocumentationGuideSection fallback,
  }) {
    if (_hasConfirmedCity) {
      Navigator.pushNamed(
        context,
        AppRoutes.migrationPlanCopilot,
        arguments: <String, dynamic>{'focusGuideItemId': itemId},
      );
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.documentationTopic,
      arguments: fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final city =
        migrationQuestionnaireController.generatedPlan?.confirmedCity?.name;
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    34,
                  ),
                  children: [
                    AppGlassHeader(
                      title: _toolsText(
                        context,
                        pt: 'Ferramentas',
                        es: 'Herramientas',
                        en: 'Tools',
                      ),
                      subtitle: city == null
                          ? _toolsText(
                              context,
                              pt: 'Recursos para decidir e se preparar',
                              es: 'Recursos para decidir y prepararte',
                              en: 'Resources to decide and prepare',
                            )
                          : _toolsText(
                              context,
                              pt: 'Preparação para $city',
                              es: 'Preparación para $city',
                              en: 'Preparing for $city',
                            ),
                    ),
                    const SizedBox(height: 18),
                    _SafetyRadarHero(
                      cityName: city,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.proposalSafetyCheck,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AssistantHero(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.info),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      _toolsText(
                        context,
                        pt: 'Resolver agora',
                        es: 'Resolver ahora',
                        en: 'Get things done',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _toolsText(
                        context,
                        pt: 'Cada ferramenta abre no contexto certo, sem misturar pesquisa com execução.',
                        es: 'Cada herramienta se abre en el contexto correcto, sin mezclar búsqueda con ejecución.',
                        en: 'Each tool opens in the right context without mixing research and execution.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth >= 680
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _ToolCard(
                              width: cardWidth,
                              icon: Icons.savings_outlined,
                              tone: AppColors.success,
                              title: _toolsText(
                                context,
                                pt: 'Custos iniciais',
                                es: 'Costos iniciales',
                                en: 'Initial costs',
                              ),
                              body: _toolsText(
                                context,
                                pt: 'Estime reserva, entrada na moradia e primeiros gastos.',
                                es: 'Estima reserva, entrada a la vivienda y primeros gastos.',
                                en: 'Estimate reserve, housing entry, and first expenses.',
                              ),
                              onTap: () => _openGuideTask(
                                context,
                                itemId: 'item_0_3_budget',
                                fallback: DocumentationGuideSection.costs,
                              ),
                            ),
                            _ToolCard(
                              width: cardWidth,
                              icon: Icons.flight_takeoff_rounded,
                              tone: const Color(0xFF536DFE),
                              title: _toolsText(
                                context,
                                pt: 'Buscar voos',
                                es: 'Buscar vuelos',
                                en: 'Search flights',
                              ),
                              body: city == null
                                  ? _toolsText(
                                      context,
                                      pt: 'Escolha uma cidade para comparar aeroportos e rotas.',
                                      es: 'Elige una ciudad para comparar aeropuertos y rutas.',
                                      en: 'Choose a city to compare airports and routes.',
                                    )
                                  : _toolsText(
                                      context,
                                      pt: 'Compare aeroportos e rotas para $city.',
                                      es: 'Compara aeropuertos y rutas para $city.',
                                      en: 'Compare airports and routes to $city.',
                                    ),
                              contextual: city != null,
                              onTap: city == null
                                  ? () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.explore,
                                    )
                                  : () => _openGuideTask(
                                      context,
                                      itemId: 'item_0_4_flight',
                                      fallback: DocumentationGuideSection.costs,
                                    ),
                            ),
                            _ToolCard(
                              width: cardWidth,
                              icon: Icons.home_work_outlined,
                              tone: AppColors.warning,
                              title: _toolsText(
                                context,
                                pt: 'Moradia e aluguel',
                                es: 'Vivienda y alquiler',
                                en: 'Housing and rent',
                              ),
                              body: _toolsText(
                                context,
                                pt: 'Entenda garantias e encontre a rota de busca mais segura.',
                                es: 'Entiende garantías y encuentra la ruta de búsqueda más segura.',
                                en: 'Understand guarantees and find a safer search route.',
                              ),
                              contextual: city != null,
                              onTap: () => _openGuideTask(
                                context,
                                itemId: 'item_1_2_housing_temporary',
                                fallback: DocumentationGuideSection.housing,
                              ),
                            ),
                            _ToolCard(
                              width: cardWidth,
                              icon: Icons.work_outline_rounded,
                              tone: AppColors.primary,
                              title: _toolsText(
                                context,
                                pt: 'Buscar trabalho',
                                es: 'Buscar trabajo',
                                en: 'Find work',
                              ),
                              body: _toolsText(
                                context,
                                pt: 'Acesse plataformas e prepare a busca para o mercado brasileiro.',
                                es: 'Accede a plataformas y prepara la búsqueda para el mercado brasileño.',
                                en: 'Open platforms and prepare for the Brazilian job market.',
                              ),
                              contextual: city != null,
                              onTap: () => _openGuideTask(
                                context,
                                itemId: 'item_0_5_mercado_trabalho',
                                fallback: DocumentationGuideSection.work,
                              ),
                            ),
                            _ToolCard(
                              width: cardWidth,
                              icon: Icons.folder_copy_outlined,
                              tone: const Color(0xFF7C4DFF),
                              title: _toolsText(
                                context,
                                pt: 'Documentos',
                                es: 'Documentos',
                                en: 'Documents',
                              ),
                              body: _toolsText(
                                context,
                                pt: 'Veja o que preparar, emitir e conferir na fonte oficial.',
                                es: 'Mira qué preparar, emitir y confirmar en la fuente oficial.',
                                en: 'See what to prepare, issue, and verify officially.',
                              ),
                              onTap: () => _openGuideTask(
                                context,
                                itemId: 'item_0_2_document_folder',
                                fallback: DocumentationGuideSection.documents,
                              ),
                            ),
                            _ToolCard(
                              width: cardWidth,
                              icon: Icons.school_outlined,
                              tone: const Color(0xFF00897B),
                              title: _toolsText(
                                context,
                                pt: 'Estudar no Brasil',
                                es: 'Estudiar en Brasil',
                                en: 'Study in Brazil',
                              ),
                              body: _toolsText(
                                context,
                                pt: 'Entenda escola, universidade e validação acadêmica.',
                                es: 'Entiende escuela, universidad y validación académica.',
                                en: 'Understand schools, universities, and academic validation.',
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.documentationTopic,
                                arguments: DocumentationGuideSection.education,
                              ),
                            ),
                          ],
                        );
                      },
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
        journeyContextController: journeyContextController,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }
}

class _SafetyRadarHero extends StatelessWidget {
  const _SafetyRadarHero({required this.cityName, required this.onTap});

  final String? cityName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF09283D), Color(0xFF075C74), Color(0xFF078A83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF087F7A).withValues(alpha: 0.22),
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
                child: const Icon(
                  Icons.radar_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toolsText(
                        context,
                        pt: 'NOVO · PROTEÇÃO MOVARO',
                        es: 'NUEVO · PROTECCIÓN MOVARO',
                        en: 'NEW · MOVARO PROTECTION',
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF7EF5E5),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _toolsText(
                        context,
                        pt: 'Confira uma proposta antes de confiar',
                        es: 'Revisa una propuesta antes de confiar',
                        en: 'Check an offer before you trust it',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _toolsText(
                        context,
                        pt: cityName == null
                            ? 'Cole uma oferta de aluguel, vaga ou serviço e veja sinais conhecidos de fraude.'
                            : 'Analise ofertas de aluguel, vagas e serviços durante sua preparação para $cityName.',
                        es: cityName == null
                            ? 'Pega una oferta de alquiler, empleo o servicio y revisa señales conocidas de fraude.'
                            : 'Analiza alquileres, empleos y servicios durante tu preparación para $cityName.',
                        en: cityName == null
                            ? 'Paste a housing, job, or service offer and check known fraud signals.'
                            : 'Check housing, job, and service offers while preparing for $cityName.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087FE8), Color(0xFF3156E8)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toolsText(
                        context,
                        pt: 'Pergunte ao assistente',
                        es: 'Pregunta al asistente',
                        en: 'Ask the assistant',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _toolsText(
                        context,
                        pt: 'Encontre a ferramenta ou orientação certa sem procurar pelo aplicativo.',
                        es: 'Encuentra la herramienta u orientación correcta sin buscar por toda la app.',
                        en: 'Find the right tool or guidance without searching the app.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.width,
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    required this.onTap,
    this.contextual = false,
  });

  final double width;
  final IconData icon;
  final Color tone;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool contextual;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FrostedPanel(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: tone, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (contextual)
                              Icon(
                                Icons.location_on_outlined,
                                color: tone,
                                size: 16,
                              ),
                          ],
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
                  const SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSoftFor(context),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
