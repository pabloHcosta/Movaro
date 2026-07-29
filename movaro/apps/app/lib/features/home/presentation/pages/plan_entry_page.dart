import 'package:flutter/material.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

String _planEntryText(
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

class PlanEntryPage extends StatelessWidget {
  const PlanEntryPage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    32,
                  ),
                  children: [
                    AppGlassHeader(
                      title: _planEntryText(
                        context,
                        pt: 'Seu plano',
                        es: 'Tu plan',
                        en: 'Your plan',
                      ),
                    ),
                    const SizedBox(height: 22),
                    FrostedPanel(
                      padding: const EdgeInsets.all(22),
                      borderRadius: BorderRadius.circular(26),
                      child: Column(
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.route_rounded,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _planEntryText(
                              context,
                              pt: 'Transforme uma cidade em um caminho claro',
                              es: 'Convierte una ciudad en un camino claro',
                              en: 'Turn a city into a clear path',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            _planEntryText(
                              context,
                              pt: 'O plano organiza documentos, custos, moradia, trabalho e chegada na ordem certa. Primeiro escolha uma cidade ou deixe o Movaro ajudar na decisão.',
                              es: 'El plan organiza documentos, costos, vivienda, trabajo y llegada en el orden correcto. Primero elige una ciudad o deja que Movaro te ayude a decidir.',
                              en: 'Your plan organizes documents, costs, housing, work, and arrival in the right order. First choose a city or let Movaro help you decide.',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.migrationQuestionnaire,
                              ),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: Text(
                                _planEntryText(
                                  context,
                                  pt: 'Descobrir meu melhor caminho',
                                  es: 'Descubrir mi mejor camino',
                                  en: 'Discover my best path',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.explore,
                              ),
                              icon: const Icon(Icons.location_city_outlined),
                              label: Text(
                                _planEntryText(
                                  context,
                                  pt: 'Já tenho uma cidade em mente',
                                  es: 'Ya tengo una ciudad en mente',
                                  en: 'I already have a city in mind',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PlanValueRow(
                      icon: Icons.fact_check_outlined,
                      title: _planEntryText(
                        context,
                        pt: 'Etapas personalizadas',
                        es: 'Etapas personalizadas',
                        en: 'Personalized steps',
                      ),
                      body: _planEntryText(
                        context,
                        pt: 'Você vê apenas o que faz sentido para o seu contexto.',
                        es: 'Ves solo lo que tiene sentido para tu contexto.',
                        en: 'You only see what is relevant to your context.',
                      ),
                    ),
                    _PlanValueRow(
                      icon: Icons.verified_outlined,
                      title: _planEntryText(
                        context,
                        pt: 'Fontes verificáveis',
                        es: 'Fuentes verificables',
                        en: 'Traceable sources',
                      ),
                      body: _planEntryText(
                        context,
                        pt: 'Decisões importantes apontam para a fonte oficial.',
                        es: 'Las decisiones importantes apuntan a la fuente oficial.',
                        en: 'Important decisions point to the official source.',
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
        currentIndex: 2,
        journeyContextController: journeyContextController,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }
}

class _PlanValueRow extends StatelessWidget {
  const _PlanValueRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
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
