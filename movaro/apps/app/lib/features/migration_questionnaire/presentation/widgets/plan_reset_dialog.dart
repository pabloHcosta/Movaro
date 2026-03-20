import 'package:flutter/material.dart';

enum PlanResetChoice { deleteOnly, rebuild }

Future<PlanResetChoice?> showPlanResetDialog(
  BuildContext context, {
  String? currentCityName,
}) {
  final copy = PlanResetDialogCopy.fromContext(context);
  final cityName = currentCityName ?? copy.currentPlanFallbackLabel;

  return showDialog<PlanResetChoice>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            border: Border.all(color: const Color(0xFF1E2636)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 48,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C0000),
                        border: Border.all(color: const Color(0xFF4A0000)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF87171),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      copy.manageActionLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF0F6FC),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.dialogBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C0000),
                        border: Border.all(color: const Color(0xFF3D0000)),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFF87171),
                            size: 13,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              copy.cityWarning(cityName),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFFF87171),
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: const Color(0xFF0D1117)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(
                        dialogContext,
                      ).pop(PlanResetChoice.rebuild),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F6FEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              copy.rebuildLabel,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2128),
                          border: Border.all(color: const Color(0xFF2D333B)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          copy.cancelWithCity(cityName),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
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
    },
  );
}

class PlanResetDialogCopy {
  const PlanResetDialogCopy({
    required this.manageActionLabel,
    required this.manageActionBody,
    required this.dialogBody,
    required this.rebuildLabel,
    required this.cancelLabel,
    required this.currentPlanFallbackLabel,
  });

  final String manageActionLabel;
  final String manageActionBody;
  final String dialogBody;
  final String rebuildLabel;
  final String cancelLabel;
  final String currentPlanFallbackLabel;

  String cityWarning(String cityName) {
    return switch (currentPlanFallbackLabel) {
      'plano atual' =>
        'Seu progresso em $cityName e todos os itens marcados serão apagados.',
      'plan actual' =>
        'Tu progreso en $cityName y todos los items marcados se borrarán.',
      _ => 'Your progress in $cityName and all checked items will be erased.',
    };
  }

  String cancelWithCity(String cityName) {
    return switch (currentPlanFallbackLabel) {
      'plano atual' => 'Cancelar — manter $cityName',
      'plan actual' => 'Cancelar — mantener $cityName',
      _ => 'Cancel — keep $cityName',
    };
  }

  static PlanResetDialogCopy fromContext(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    switch (languageCode) {
      case 'pt':
        return const PlanResetDialogCopy(
          manageActionLabel: 'Começar um novo plano',
          manageActionBody:
              'Se quiser recomeçar, você pode apagar o progresso atual e montar um novo plano desde o início.',
          dialogBody:
              'Você vai recomeçar o questionário e escolher uma nova cidade. Isso não pode ser desfeito.',
          rebuildLabel: 'Sim, começar do zero',
          cancelLabel: 'Cancelar',
          currentPlanFallbackLabel: 'plano atual',
        );
      case 'es':
        return const PlanResetDialogCopy(
          manageActionLabel: 'Empezar un plan nuevo',
          manageActionBody:
              'Si querés recomenzar, podés borrar tu progreso actual y armar un nuevo plan desde el principio.',
          dialogBody:
              'Vas a reiniciar el cuestionario y elegir una nueva ciudad. Esto no se puede deshacer.',
          rebuildLabel: 'Sí, empezar de cero',
          cancelLabel: 'Cancelar',
          currentPlanFallbackLabel: 'plan actual',
        );
      default:
        return const PlanResetDialogCopy(
          manageActionLabel: 'Start a new plan',
          manageActionBody:
              'If you want to restart, you can clear your current progress and build a new plan from the beginning.',
          dialogBody:
              'You will restart the questionnaire and choose a new city. This cannot be undone.',
          rebuildLabel: 'Yes, start from scratch',
          cancelLabel: 'Cancel',
          currentPlanFallbackLabel: 'current plan',
        );
    }
  }
}
