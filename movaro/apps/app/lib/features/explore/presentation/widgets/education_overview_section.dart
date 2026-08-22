import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

class EducationOverviewSection extends StatelessWidget {
  const EducationOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    String tr({required String pt, required String es, required String en}) =>
        switch (locale) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };

    final cards = [
      _EducationCardData(
        icon: Icons.child_care_rounded,
        title: tr(
          pt: 'Escola pública para filhos',
          es: 'Escuela pública para hijos',
          en: 'Public school for children',
        ),
        status: tr(
          pt: 'Sem mensalidade',
          es: 'Sin mensualidad',
          en: 'No tuition',
        ),
        body: tr(
          pt: 'Crianças e adolescentes migrantes têm direito à matrícula sem discriminação. A falta de histórico escolar ou documento migratório não deve impedir o acesso; a rede define classificação e vaga.',
          es: 'Los niños y adolescentes migrantes tienen derecho a matricularse sin discriminación. La falta de historial escolar o documento migratorio no debe impedir el acceso; la red define nivel y vacante.',
          en: 'Migrant children and adolescents have a right to enrollment without discrimination. Missing school or migration records should not block access; the school network determines placement and availability.',
        ),
        bullets: [
          tr(
            pt: 'Ensino obrigatório dos 4 aos 17 anos',
            es: 'Educación obligatoria de 4 a 17 años',
            en: 'Compulsory education from ages 4 to 17',
          ),
          tr(
            pt: 'Leve identidade, histórico e comprovantes disponíveis',
            es: 'Lleva identidad, historial y comprobantes disponibles',
            en: 'Bring available identity, school, and address records',
          ),
          tr(
            pt: 'Transporte, uniforme e material variam por rede',
            es: 'Transporte, uniforme y materiales varían por red',
            en: 'Transport, uniforms, and supplies vary by school network',
          ),
        ],
        sourceLabel: 'CNE · Resolução nº 1/2020',
        sourceUrl:
            'https://portal.mec.gov.br/docman/novembro-2020-pdf/165271-rceb001-20/file',
      ),
      _EducationCardData(
        icon: Icons.school_outlined,
        title: tr(
          pt: 'Escola particular',
          es: 'Escuela privada',
          en: 'Private school',
        ),
        status: tr(
          pt: 'Mensalidade variável',
          es: 'Mensualidad variable',
          en: 'Variable tuition',
        ),
        body: tr(
          pt: 'A instituição define mensalidade, calendário, material, uniforme e critérios de admissão. Compare o custo anual completo e confirme autorização junto à Secretaria de Educação.',
          es: 'La institución define mensualidad, calendario, materiales, uniforme y admisión. Compara el costo anual completo y confirma la autorización ante la Secretaría de Educación.',
          en: 'The institution sets tuition, calendar, supplies, uniforms, and admissions. Compare the full annual cost and confirm authorization with the Education Department.',
        ),
        bullets: [
          tr(
            pt: 'Peça contrato e tabela anual',
            es: 'Solicita contrato y tabla anual',
            en: 'Request the contract and annual fee schedule',
          ),
          tr(
            pt: 'Verifique turno, idioma de apoio e transporte',
            es: 'Verifica turno, apoyo lingüístico y transporte',
            en: 'Check schedule, language support, and transport',
          ),
        ],
        sourceLabel: 'MEC · Educação básica',
        sourceUrl: 'https://www.gov.br/mec/pt-br/assuntos/eb',
      ),
      _EducationCardData(
        icon: Icons.account_balance_rounded,
        title: tr(
          pt: 'Universidade pública',
          es: 'Universidad pública',
          en: 'Public university',
        ),
        status: tr(
          pt: 'Sem mensalidade',
          es: 'Sin mensualidad',
          en: 'No tuition',
        ),
        body: tr(
          pt: 'O ingresso pode ocorrer por Enem/Sisu, vestibular próprio, transferência ou edital internacional. Ser estrangeiro não cria uma vaga automática: confira o edital da instituição e os documentos exigidos.',
          es: 'El ingreso puede ser por Enem/Sisu, examen propio, transferencia o convocatoria internacional. Ser extranjero no crea una vacante automática: revisa la convocatoria y los documentos.',
          en: 'Admission may use Enem/Sisu, an institution exam, transfer, or an international call. Foreign status does not guarantee a place: check the institution’s rules and documents.',
        ),
        bullets: [
          tr(
            pt: 'Enem é a principal porta para o Sisu',
            es: 'Enem es la principal vía hacia Sisu',
            en: 'Enem is the main route into Sisu',
          ),
          tr(
            pt: 'PEC-G oferece vagas gratuitas a candidatos elegíveis',
            es: 'PEC-G ofrece plazas gratuitas a candidatos elegibles',
            en: 'PEC-G offers tuition-free places to eligible applicants',
          ),
          tr(
            pt: 'Moradia, alimentação e material continuam no orçamento',
            es: 'Vivienda, alimentación y materiales siguen en el presupuesto',
            en: 'Housing, food, and supplies still require a budget',
          ),
        ],
        sourceLabel: 'MEC · Sisu',
        sourceUrl:
            'https://www.gov.br/mec/pt-br/assuntos/es/sistema-de-selecao-unificada-sisu',
      ),
      _EducationCardData(
        icon: Icons.apartment_rounded,
        title: tr(
          pt: 'Universidade particular',
          es: 'Universidad privada',
          en: 'Private university',
        ),
        status: tr(
          pt: 'Mensalidade variável',
          es: 'Mensualidad variable',
          en: 'Variable tuition',
        ),
        body: tr(
          pt: 'Pode usar vestibular, nota do Enem ou processo próprio. Antes de pagar, confirme no e-MEC se a instituição e o curso estão regulares e leia regras de reajuste, bolsa e cancelamento.',
          es: 'Puede usar examen, nota del Enem o proceso propio. Antes de pagar, confirma en e-MEC que la institución y el curso estén regulares y revisa reajustes, becas y cancelación.',
          en: 'Admission may use an exam, Enem score, or an institution process. Before paying, verify the institution and course in e-MEC and review adjustment, scholarship, and cancellation rules.',
        ),
        bullets: [
          tr(
            pt: 'Confira instituição e curso no e-MEC',
            es: 'Verifica institución y carrera en e-MEC',
            en: 'Verify the institution and course in e-MEC',
          ),
          tr(
            pt: 'Use no orçamento o valor informado pela instituição',
            es: 'Usa en el presupuesto el valor informado por la institución',
            en: 'Budget with the amount quoted by the institution',
          ),
        ],
        sourceLabel: 'MEC · e-MEC',
        sourceUrl: 'https://emec.mec.gov.br/',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(
                  pt: 'Como funciona a educação no Brasil',
                  es: 'Cómo funciona la educación en Brasil',
                  en: 'How education works in Brazil',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  pt: 'Escolha primeiro o nível e a rota de ingresso. “Público” significa sem mensalidade, mas não elimina custos de moradia, transporte, alimentação, material ou documentação.',
                  es: 'Primero elige el nivel y la vía de ingreso. “Público” significa sin mensualidad, pero no elimina vivienda, transporte, comida, materiales o documentos.',
                  en: 'First choose the level and admission route. “Public” means no tuition, but housing, transport, food, supplies, and documentation still cost money.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 760
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: width,
                    child: _EducationCard(data: card),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        _EducationSocialSnapshot(locale: locale),
      ],
    );
  }
}

class _EducationSocialSnapshot extends StatelessWidget {
  const _EducationSocialSnapshot({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    String tr({required String pt, required String es, required String en}) =>
        switch (locale) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(
              pt: 'Panorama social oficial',
              es: 'Panorama social oficial',
              en: 'Official social snapshot',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SocialMetric(
                value: '46 mi',
                label: tr(
                  pt: 'matrículas na educação básica em 2025',
                  es: 'matrículas en educación básica en 2025',
                  en: 'basic-education enrollments in 2025',
                ),
              ),
              _SocialMetric(
                value: '178,8 mil',
                label: tr(
                  pt: 'escolas de educação básica',
                  es: 'escuelas de educación básica',
                  en: 'basic-education schools',
                ),
              ),
              _SocialMetric(
                value: '97,2%',
                label: tr(
                  pt: 'frequência a escolas e creches em 2025',
                  es: 'asistencia a escuelas y guarderías en 2025',
                  en: 'school and daycare attendance in 2025',
                ),
              ),
              _SocialMetric(
                value: '10,2 mi',
                label: tr(
                  pt: 'matrículas de graduação no Censo Superior 2024',
                  es: 'matrículas de grado en el Censo Superior 2024',
                  en: 'undergraduate enrollments in the 2024 Higher Education Census',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _openSource(
                  context,
                  title: 'Inep · Censo Escolar 2025',
                  url:
                      'https://www.gov.br/inep/pt-br/centrais-de-conteudo/noticias/censo-escolar/brasil-atingiu-maior-percentual-de-estudantes-em-tempo-integral',
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Inep · Censo Escolar 2025'),
              ),
              TextButton.icon(
                onPressed: () => _openSource(
                  context,
                  title: 'Inep · Censo Superior 2024',
                  url:
                      'https://www.gov.br/inep/pt-br/relatorio-anual-de-atividades-e-gestao-do-inep-2025/pesquisas-estatisticas-e-indicadores-educacionais/censo-da-educaca-superior',
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Inep · Censo Superior 2024'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSource(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PreparationWebViewPage(title: title, uri: Uri.parse(url)),
      ),
    );
  }
}

class _SocialMetric extends StatelessWidget {
  const _SocialMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.data});

  final _EducationCardData data;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(data.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            data.status,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            data.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          for (final bullet in data.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(bullet)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PreparationWebViewPage(
                  title: data.sourceLabel,
                  uri: Uri.parse(data.sourceUrl),
                ),
              ),
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(switch (locale) {
              'pt' => 'Fonte oficial · ${data.sourceLabel}',
              'es' => 'Fuente oficial · ${data.sourceLabel}',
              _ => 'Official source · ${data.sourceLabel}',
            }),
          ),
        ],
      ),
    );
  }
}

class _EducationCardData {
  const _EducationCardData({
    required this.icon,
    required this.title,
    required this.status,
    required this.body,
    required this.bullets,
    required this.sourceLabel,
    required this.sourceUrl,
  });

  final IconData icon;
  final String title;
  final String status;
  final String body;
  final List<String> bullets;
  final String sourceLabel;
  final String sourceUrl;
}
