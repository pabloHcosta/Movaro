import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

enum PlanResetChoice { deleteOnly, rebuild }

Future<PlanResetChoice?> showPlanResetDialog(BuildContext context) {
  final copy = PlanResetDialogCopy.fromContext(context);

  return showDialog<PlanResetChoice>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(context.l10n.publicHomePlanResetTitle),
        content: Text(copy.dialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(copy.cancelLabel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(PlanResetChoice.deleteOnly),
            child: Text(copy.deleteLabel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(PlanResetChoice.rebuild),
            child: Text(context.l10n.publicHomeRetakePlanAction),
          ),
        ],
      );
    },
  );
}

class PlanResetDialogCopy {
  const PlanResetDialogCopy({
    required this.manageActionLabel,
    required this.manageActionBody,
    required this.dialogBody,
    required this.deleteLabel,
    required this.cancelLabel,
  });

  final String manageActionLabel;
  final String manageActionBody;
  final String dialogBody;
  final String deleteLabel;
  final String cancelLabel;

  static PlanResetDialogCopy fromContext(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    switch (languageCode) {
      case 'pt':
        return const PlanResetDialogCopy(
          manageActionLabel: 'Excluir ou refazer',
          manageActionBody:
              'Remova o plano salvo deste dispositivo ou apague tudo e volte ao questionário para montar outro do zero.',
          dialogBody:
              'Seu plano atual será removido deste dispositivo. Você pode apenas excluir o plano ou apagar tudo e abrir o questionário novamente para refazer.',
          deleteLabel: 'Excluir plano',
          cancelLabel: 'Cancelar',
        );
      case 'es':
        return const PlanResetDialogCopy(
          manageActionLabel: 'Eliminar o rehacer',
          manageActionBody:
              'Quitá el plan guardado de este dispositivo o borrá todo y volvé al cuestionario para armar otro desde cero.',
          dialogBody:
              'Tu plan actual se va a eliminar de este dispositivo. Podés solo eliminarlo o borrar todo y abrir el cuestionario otra vez para rehacerlo.',
          deleteLabel: 'Eliminar plan',
          cancelLabel: 'Cancelar',
        );
      default:
        return const PlanResetDialogCopy(
          manageActionLabel: 'Delete or rebuild',
          manageActionBody:
              'Remove the saved plan from this device or clear everything and reopen the questionnaire to build a new one.',
          dialogBody:
              'Your current plan will be removed from this device. You can only delete it or clear everything and reopen the questionnaire to rebuild it.',
          deleteLabel: 'Delete plan',
          cancelLabel: 'Cancel',
        );
    }
  }
}
