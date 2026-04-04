import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

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
      final isDark = AppColors.isDark(dialogContext);
      final surfaceColor = AppColors.surfaceFor(dialogContext);
      final borderColor = AppColors.borderFor(dialogContext);
      final titleColor = AppColors.textPrimaryFor(dialogContext);
      final bodyColor = AppColors.textSoftFor(dialogContext);
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.48)
                    : Colors.black.withValues(alpha: 0.10),
                blurRadius: isDark ? 48 : 26,
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
                        color: AppColors.tintedSurfaceFor(
                          dialogContext,
                          tint: AppColors.danger,
                          lightColor: const Color(0xFFFFEFEF),
                          darkAlpha: 0.16,
                        ),
                        border: Border.all(
                          color: AppColors.tintedBorderFor(
                            dialogContext,
                            tint: AppColors.danger,
                            lightColor: const Color(0xFFF3B8B8),
                            darkAlpha: 0.30,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.danger,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      copy.manageActionLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.dialogBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: bodyColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.tintedSurfaceFor(
                          dialogContext,
                          tint: AppColors.danger,
                          lightColor: const Color(0xFFFFF4F4),
                          darkAlpha: 0.14,
                        ),
                        border: Border.all(
                          color: AppColors.tintedBorderFor(
                            dialogContext,
                            tint: AppColors.danger,
                            lightColor: const Color(0xFFF3B8B8),
                            darkAlpha: 0.24,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.danger,
                            size: 13,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              copy.cityWarning(cityName),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.danger,
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
              Container(height: 1, color: borderColor),
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
                          color: AppColors.surfaceMutedFor(dialogContext),
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          copy.cancelWithCity(cityName),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: bodyColor,
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
