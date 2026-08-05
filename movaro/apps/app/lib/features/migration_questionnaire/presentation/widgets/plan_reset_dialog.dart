import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

enum PlanResetChoice { changeCityKeepProgress, rebuild }

Future<PlanResetChoice?> showPlanResetDialog(
  BuildContext context, {
  String? currentCityName,
}) {
  final copy = PlanResetDialogCopy.fromContext(context);
  final cityName = currentCityName ?? copy.currentPlanFallbackLabel;

  return showModalBottomSheet<PlanResetChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final isDark = AppColors.isDark(sheetContext);
      final borderColor = AppColors.borderFor(sheetContext);
      final titleColor = AppColors.textPrimaryFor(sheetContext);
      final bodyColor = AppColors.textSoftFor(sheetContext);

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(sheetContext),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.52 : 0.16),
              blurRadius: 44,
              offset: const Offset(0, -14),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: bodyColor.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB648), Color(0xFFF08019)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.caution.withValues(alpha: 0.26),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                copy.manageActionLabel,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                  letterSpacing: -0.55,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                switch (Localizations.localeOf(sheetContext).languageCode) {
                  'pt' =>
                    'Você pode escolher outra cidade preservando o que ainda é válido ou criar um plano totalmente novo.',
                  'es' =>
                    'Puedes elegir otra ciudad conservando lo que todavía es válido o crear un plan completamente nuevo.',
                  _ =>
                    'You can choose another city and keep what still applies, or create a completely new plan.',
                },
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: bodyColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.tintedSurfaceFor(
                    sheetContext,
                    tint: AppColors.caution,
                    lightColor: const Color(0xFFFFF8ED),
                    darkAlpha: 0.11,
                  ),
                  border: Border.all(
                    color: AppColors.tintedBorderFor(
                      sheetContext,
                      tint: AppColors.caution,
                      lightColor: const Color(0xFFF4D7AA),
                      darkAlpha: 0.30,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.caution,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            switch (Localizations.localeOf(
                              sheetContext,
                            ).languageCode) {
                              'pt' => 'Seu plano atual está protegido',
                              'es' => 'Tu plan actual está protegido',
                              _ => 'Your current plan is protected',
                            },
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceFor(
                          sheetContext,
                        ).withValues(alpha: 0.74),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.caution,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              switch (Localizations.localeOf(
                                sheetContext,
                              ).languageCode) {
                                'pt' =>
                                  'Nada em $cityName será apagado antes de você escolher como continuar.',
                                'es' =>
                                  'Nada de $cityName se borrará antes de que elijas cómo continuar.',
                                _ =>
                                  'Nothing in $cityName is cleared before you choose how to continue.',
                              },
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: bodyColor,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      switch (Localizations.localeOf(
                        sheetContext,
                      ).languageCode) {
                        'pt' =>
                          'Na troca de cidade, documentos e processos pessoais são mantidos; tarefas locais são reabertas.',
                        'es' =>
                          'Al cambiar de ciudad, se conservan documentos y procesos personales; las tareas locales se reabren.',
                        _ =>
                          'When changing city, personal documents and processes stay completed; local tasks reopen.',
                      },
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: bodyColor,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(PlanResetChoice.changeCityKeepProgress),
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tintedSurfaceFor(
                        sheetContext,
                        tint: AppColors.success,
                        lightColor: const Color(0xFFF0FAF5),
                      ),
                      border: Border.all(
                        color: AppColors.tintedBorderFor(
                          sheetContext,
                          tint: AppColors.success,
                          lightColor: const Color(0xFFB9E5CF),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            switch (Localizations.localeOf(
                              sheetContext,
                            ).languageCode) {
                              'pt' => 'Trocar cidade mantendo o progresso',
                              'es' => 'Cambiar ciudad manteniendo el progreso',
                              _ => 'Change city and keep progress',
                            },
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(PlanResetChoice.rebuild),
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF238BFF), Color(0xFF0068E8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          copy.rebuildLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: bodyColor,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    copy.cancelWithCity(cityName),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
    required String Function(String cityName) cityWarningBuilder,
    required String Function(String cityName) cancelWithCityBuilder,
  }) : _cityWarningBuilder = cityWarningBuilder,
       _cancelWithCityBuilder = cancelWithCityBuilder;

  final String manageActionLabel;
  final String manageActionBody;
  final String dialogBody;
  final String rebuildLabel;
  final String cancelLabel;
  final String currentPlanFallbackLabel;

  String cityWarning(String cityName) {
    return _cityWarningBuilder(cityName);
  }

  String cancelWithCity(String cityName) {
    return _cancelWithCityBuilder(cityName);
  }

  final String Function(String cityName) _cityWarningBuilder;
  final String Function(String cityName) _cancelWithCityBuilder;

  static PlanResetDialogCopy fromContext(BuildContext context) {
    final l10n = context.l10n;
    return PlanResetDialogCopy(
      manageActionLabel: l10n.planResetManageAction,
      manageActionBody: l10n.planResetManageBody,
      dialogBody: l10n.planResetDialogBody,
      rebuildLabel: l10n.planResetRebuildLabel,
      cancelLabel: l10n.planResetCancelLabel,
      currentPlanFallbackLabel: l10n.planResetCurrentPlanFallbackLabel,
      cityWarningBuilder: l10n.planResetCityWarning,
      cancelWithCityBuilder: l10n.planResetCancelWithCity,
    );
  }
}
