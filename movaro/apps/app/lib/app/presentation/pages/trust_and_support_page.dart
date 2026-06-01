import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:url_launcher/url_launcher.dart';

String _t(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };
}

/// "Por que confiar no Movaro" (F6) + "Apoio oficial" (F5) + a categories-only
/// services scaffold (F6 monetization groundwork — no invented listings).
class TrustAndSupportPage extends StatelessWidget {
  const TrustAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                AppGlassHeader(
                  title: _t(
                    context,
                    pt: 'Confiança e apoio',
                    es: 'Confianza y apoyo',
                    en: 'Trust & support',
                  ),
                  onBack: () => Navigator.maybePop(context),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      _section(
                        context,
                        title: _t(
                          context,
                          pt: 'Por que confiar no Movaro',
                          es: 'Por qué confiar en Movaro',
                          en: 'Why trust Movaro',
                        ),
                        children: [
                          _point(
                            context,
                            icon: Icons.verified_outlined,
                            title: _t(
                              context,
                              pt: 'Dados de fontes oficiais',
                              es: 'Datos de fuentes oficiales',
                              en: 'Data from official sources',
                            ),
                            body: _t(
                              context,
                              pt: 'População, UF e indicadores vêm do IBGE; custo de vida é derivado de fontes públicas. Cada cidade mostra suas fontes.',
                              es: 'Población, estado e indicadores vienen del IBGE; el costo de vida se deriva de fuentes públicas. Cada ciudad muestra sus fuentes.',
                              en: 'Population, state and indicators come from IBGE; cost of living is derived from public sources. Each city shows its sources.',
                            ),
                          ),
                          _point(
                            context,
                            icon: Icons.insights_outlined,
                            title: _t(
                              context,
                              pt: 'Metodologia transparente',
                              es: 'Metodología transparente',
                              en: 'Transparent methodology',
                            ),
                            body: _t(
                              context,
                              pt: 'As notas são referência para comparar — não verdades absolutas. Leia sempre no contexto da sua situação.',
                              es: 'Las notas son referencia para comparar — no verdades absolutas. Léelas siempre en el contexto de tu situación.',
                              en: 'Scores are a reference for comparison — not absolute truths. Always read them in the context of your situation.',
                            ),
                          ),
                          _point(
                            context,
                            icon: Icons.gavel_outlined,
                            title: _t(
                              context,
                              pt: 'Não é aconselhamento jurídico',
                              es: 'No es asesoría legal',
                              en: 'Not legal advice',
                            ),
                            body: _t(
                              context,
                              pt: 'O Movaro é um ponto de partida prático. Para decisões oficiais, confirme sempre na fonte (Polícia Federal, gov.br).',
                              es: 'Movaro es un punto de partida práctico. Para decisiones oficiales, confirmá siempre en la fuente (Policía Federal, gov.br).',
                              en: 'Movaro is a practical starting point. For official decisions, always confirm at the source (Federal Police, gov.br).',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _section(
                        context,
                        title: _t(
                          context,
                          pt: 'Apoio oficial e gratuito',
                          es: 'Apoyo oficial y gratuito',
                          en: 'Official, free support',
                        ),
                        children: [
                          _linkTile(
                            context,
                            icon: Icons.diversity_3_outlined,
                            title: _t(
                              context,
                              pt: 'Rede de apoio a migrantes (gov.br)',
                              es: 'Red de apoyo a migrantes (gov.br)',
                              en: 'Migrant support network (gov.br)',
                            ),
                            uri: PreparationResourceLinks.migrantSupportNetwork,
                          ),
                          _linkTile(
                            context,
                            icon: Icons.account_balance_outlined,
                            title: _t(
                              context,
                              pt: 'Consulados da Argentina no Brasil',
                              es: 'Consulados de Argentina en Brasil',
                              en: 'Argentine consulates in Brazil',
                            ),
                            uri:
                                PreparationResourceLinks.argentinaConsulatesBrazil,
                          ),
                          _linkTile(
                            context,
                            icon: Icons.badge_outlined,
                            title: _t(
                              context,
                              pt: 'Polícia Federal — migração',
                              es: 'Policía Federal — migración',
                              en: 'Federal Police — migration',
                            ),
                            uri: PreparationResourceLinks.pfPortal,
                          ),
                          _linkTile(
                            context,
                            icon: Icons.school_outlined,
                            title: _t(
                              context,
                              pt: 'Direito à matrícula escolar (crianças migrantes)',
                              es: 'Derecho a matrícula escolar (niños migrantes)',
                              en: 'Right to school enrollment (migrant children)',
                            ),
                            uri: PreparationResourceLinks.familySchoolGuide,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _section(
                        context,
                        title: _t(
                          context,
                          pt: 'Serviços que você pode precisar',
                          es: 'Servicios que podés necesitar',
                          en: 'Services you may need',
                        ),
                        children: [
                          _point(
                            context,
                            icon: Icons.translate_outlined,
                            title: _t(
                              context,
                              pt: 'Tradução juramentada',
                              es: 'Traducción jurada',
                              en: 'Sworn translation',
                            ),
                            body: _t(
                              context,
                              pt: 'Para documentos oficiais. Procure um tradutor público juramentado na Junta Comercial do seu estado.',
                              es: 'Para documentos oficiales. Buscá un traductor público jurado en la Junta Comercial de tu estado.',
                              en: 'For official documents. Look for a sworn public translator at your state Board of Trade (Junta Comercial).',
                            ),
                          ),
                          _point(
                            context,
                            icon: Icons.support_agent_outlined,
                            title: _t(
                              context,
                              pt: 'Despachante / advogado migratório',
                              es: 'Gestor / abogado migratorio',
                              en: 'Immigration agent / lawyer',
                            ),
                            body: _t(
                              context,
                              pt: 'Útil para casos complexos de residência. Confirme registro (OAB, no caso de advogado).',
                              es: 'Útil para casos complejos de residencia. Verificá la matrícula (OAB, en el caso de abogados).',
                              en: 'Useful for complex residence cases. Verify credentials (OAB for lawyers).',
                            ),
                          ),
                          _point(
                            context,
                            icon: Icons.home_work_outlined,
                            title: _t(
                              context,
                              pt: 'Seguro-fiança (alternativa ao fiador)',
                              es: 'Seguro de alquiler (alternativa al garante)',
                              en: 'Rent insurance (guarantor alternative)',
                            ),
                            body: _t(
                              context,
                              pt: 'Muitas imobiliárias aceitam seguro-fiança no lugar de fiador — pergunte antes de visitar.',
                              es: 'Muchas inmobiliarias aceptan seguro de alquiler en vez de garante — preguntá antes de visitar.',
                              en: 'Many agencies accept rent insurance instead of a guarantor — ask before visiting.',
                            ),
                          ),
                          _disclaimer(
                            context,
                            _t(
                              context,
                              pt: 'Parcerias verificadas chegarão aqui. Por ora, o Movaro não recomenda empresas específicas — confirme credenciais antes de contratar.',
                              es: 'Pronto habrá alianzas verificadas. Por ahora, Movaro no recomienda empresas específicas — verificá credenciales antes de contratar.',
                              en: 'Verified partners are coming. For now, Movaro does not endorse specific companies — verify credentials before hiring.',
                            ),
                          ),
                        ],
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

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _point(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Uri uri,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(Icons.open_in_new_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _disclaimer(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
