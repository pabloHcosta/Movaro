import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/landing_budget_runway.dart';

class LandingBudgetRunwayCard extends StatelessWidget {
  const LandingBudgetRunwayCard({
    super.key,
    required this.availableBrl,
    required this.monthlyBrl,
    required this.setupBrl,
    required this.bufferBrl,
    required this.months,
  });
  final int availableBrl, monthlyBrl, setupBrl, bufferBrl, months;

  @override
  Widget build(BuildContext context) {
    final result = LandingBudgetRunway(
      availableBrl: availableBrl,
      monthlyBrl: monthlyBrl,
      setupBrl: setupBrl,
      bufferBrl: bufferBrl,
      months: months,
    );
    String text(String pt, String es, String en) =>
        switch (Localizations.localeOf(context).languageCode) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };
    String money(int value) => NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: 'R\$',
      decimalDigits: 0,
    ).format(value);
    return Container(
      key: const ValueKey('landing-budget-runway'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text(
              'Quanto tempo sua reserva cobre?',
              '¿Cuánto tiempo cubren tus ahorros?',
              'How long will your savings last?',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            text(
              '${result.fullMonthsCovered} meses completos sem renda, depois da instalação e mantendo a margem para imprevistos.',
              '${result.fullMonthsCovered} meses completos sin ingresos, después de la instalación y conservando el margen para imprevistos.',
              '${result.fullMonthsCovered} full months without income, after setup and keeping the emergency buffer.',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text(
              'Para $months meses: ${money(result.requiredBrl)}. Disponível: ${money(availableBrl)}.',
              'Para $months meses: ${money(result.requiredBrl)}. Disponible: ${money(availableBrl)}.',
              'For $months months: ${money(result.requiredBrl)}. Available: ${money(availableBrl)}.',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.shortfallBrl > 0
                ? text(
                    'Faltam ${money(result.shortfallBrl)} para este cenário.',
                    'Faltan ${money(result.shortfallBrl)} para este escenario.',
                    'This scenario needs ${money(result.shortfallBrl)} more.',
                  )
                : text(
                    'Sua reserva cobre este cenário com os valores informados.',
                    'Tus ahorros cubren este escenario con los valores ingresados.',
                    'Your savings cover this scenario using the values entered.',
                  ),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (result.setupShortfallBrl > 0)
            Text(
              text(
                'A instalação sozinha ainda precisa de ${money(result.setupShortfallBrl)}.',
                'La instalación sola todavía requiere ${money(result.setupShortfallBrl)}.',
                'Setup alone still needs ${money(result.setupShortfallBrl)}.',
              ),
            ),
          const SizedBox(height: 8),
          Text(
            text(
              'Não contamos salário futuro. Confirme aluguel e despesas da família; se faltar reserva, ajuste custos ou a data da mudança.',
              'No contamos un sueldo futuro. Confirmá alquiler y gastos familiares; si faltan ahorros, ajustá costos o la fecha de mudanza.',
              'Future salary is not included. Confirm rent and household costs; if savings fall short, adjust costs or the moving date.',
            ),
          ),
        ],
      ),
    );
  }
}
