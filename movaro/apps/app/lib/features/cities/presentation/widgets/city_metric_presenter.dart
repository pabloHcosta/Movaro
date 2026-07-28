import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

enum CityMetricKind { cost, safety, language, work }

class CityIdhmPresentation {
  const CityIdhmPresentation({
    required this.headline,
    required this.supporting,
    required this.tint,
    required this.background,
    required this.border,
  });

  final String headline;
  final String supporting;
  final Color tint;
  final Color background;
  final Color border;

  static CityIdhmPresentation resolve(
    BuildContext context, {
    required double value,
  }) {
    final l10n = context.l10n;

    if (value >= 0.800) {
      return CityIdhmPresentation(
        headline: l10n.cityIdhmVeryHigh,
        supporting: l10n.cityIdhmVeryHighSupporting,
        tint: AppColors.success,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFF1F8F3),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFBBDCC6),
        ),
      );
    }
    if (value >= 0.700) {
      return CityIdhmPresentation(
        headline: l10n.cityIdhmHigh,
        supporting: l10n.cityIdhmHighSupporting,
        tint: const Color(0xFF2D7E67),
        background: AppColors.tintedSurfaceFor(
          context,
          tint: const Color(0xFF2D7E67),
          lightColor: const Color(0xFFEFF8F5),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: const Color(0xFF2D7E67),
          lightColor: const Color(0xFFB8DCCE),
        ),
      );
    }
    if (value >= 0.600) {
      return CityIdhmPresentation(
        headline: l10n.cityIdhmMedium,
        supporting: l10n.cityIdhmMediumSupporting,
        tint: AppColors.warning,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFFFF8E7),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFEFCF84),
        ),
      );
    }
    if (value >= 0.500) {
      return CityIdhmPresentation(
        headline: l10n.cityIdhmLow,
        supporting: l10n.cityIdhmLowSupporting,
        tint: AppColors.caution,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.caution,
          lightColor: const Color(0xFFFFF1E8),
        ),
        border: AppColors.tintedBorderFor(
          context,
          tint: AppColors.caution,
          lightColor: const Color(0xFFF2C8A2),
        ),
      );
    }
    return CityIdhmPresentation(
      headline: l10n.cityIdhmVeryLow,
      supporting: l10n.cityIdhmVeryLowSupporting,
      tint: AppColors.danger,
      background: AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.danger,
        lightColor: const Color(0xFFFDEEE8),
      ),
      border: AppColors.tintedBorderFor(
        context,
        tint: AppColors.danger,
        lightColor: const Color(0xFFF1C3B2),
      ),
    );
  }
}

class CityMetricPresentation {
  const CityMetricPresentation({
    required this.headline,
    required this.supporting,
    required this.badge,
    required this.icon,
    required this.tint,
    required this.background,
    required this.border,
  });

  final String headline;
  final String supporting;
  final String badge;
  final IconData icon;
  final Color tint;
  final Color background;
  final Color border;

  static CityMetricPresentation resolve(
    BuildContext context, {
    required CityMetricKind kind,
    required int value,
  }) {
    final l10n = context.l10n;

    switch (kind) {
      case CityMetricKind.cost:
        if (value >= 70) {
          return CityMetricPresentation(
            headline: l10n.cityMetricCostLowHeadline,
            supporting: l10n.cityMetricCostLowSupporting,
            badge: l10n.cityMetricBadgePositive,
            icon: Icons.savings_outlined,
            tint: AppColors.success,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFF1F8F3),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFBBDCC6),
            ),
          );
        }
        if (value >= 50) {
          return CityMetricPresentation(
            headline: l10n.cityMetricCostMediumHeadline,
            supporting: l10n.cityMetricCostMediumSupporting,
            badge: l10n.cityMetricBadgeNeutral,
            icon: Icons.account_balance_wallet_outlined,
            tint: AppColors.warning,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFFFF8E7),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFEFCF84),
            ),
          );
        }
        return CityMetricPresentation(
          headline: l10n.cityMetricCostHighHeadline,
          supporting: l10n.cityMetricCostHighSupporting,
          badge: l10n.cityMetricBadgeAttention,
          icon: Icons.payments_outlined,
          tint: AppColors.danger,
          background: AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFFDEEE8),
          ),
          border: AppColors.tintedBorderFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFF1C3B2),
          ),
        );
      case CityMetricKind.safety:
        if (value >= 70) {
          return CityMetricPresentation(
            headline: l10n.cityMetricSafetyHighHeadline,
            supporting: l10n.cityMetricSafetyHighSupporting,
            badge: l10n.cityMetricBadgePositive,
            icon: Icons.shield_outlined,
            tint: AppColors.success,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFF1F8F3),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFBBDCC6),
            ),
          );
        }
        if (value >= 50) {
          return CityMetricPresentation(
            headline: l10n.cityMetricSafetyMediumHeadline,
            supporting: l10n.cityMetricSafetyMediumSupporting,
            badge: l10n.cityMetricBadgeNeutral,
            icon: Icons.shield_moon_outlined,
            tint: AppColors.warning,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFFFF8E7),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFEFCF84),
            ),
          );
        }
        return CityMetricPresentation(
          headline: l10n.cityMetricSafetyLowHeadline,
          supporting: l10n.cityMetricSafetyLowSupporting,
          badge: l10n.cityMetricBadgeAttention,
          icon: Icons.gpp_maybe_outlined,
          tint: AppColors.danger,
          background: AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFFDEEE8),
          ),
          border: AppColors.tintedBorderFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFF1C3B2),
          ),
        );
      case CityMetricKind.language:
        if (value >= 70) {
          return CityMetricPresentation(
            headline: l10n.cityMetricLanguageEasyHeadline,
            supporting: l10n.cityMetricLanguageEasySupporting,
            badge: l10n.cityMetricBadgePositive,
            icon: Icons.translate_rounded,
            tint: AppColors.success,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFF1F8F3),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFBBDCC6),
            ),
          );
        }
        if (value >= 50) {
          return CityMetricPresentation(
            headline: l10n.cityMetricLanguageMediumHeadline,
            supporting: l10n.cityMetricLanguageMediumSupporting,
            badge: l10n.cityMetricBadgeNeutral,
            icon: Icons.forum_outlined,
            tint: AppColors.warning,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFFFF8E7),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFEFCF84),
            ),
          );
        }
        return CityMetricPresentation(
          headline: l10n.cityMetricLanguageHardHeadline,
          supporting: l10n.cityMetricLanguageHardSupporting,
          badge: l10n.cityMetricBadgeAttention,
          icon: Icons.record_voice_over_outlined,
          tint: AppColors.danger,
          background: AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFFDEEE8),
          ),
          border: AppColors.tintedBorderFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFF1C3B2),
          ),
        );
      case CityMetricKind.work:
        if (value >= 78) {
          return CityMetricPresentation(
            headline: l10n.cityMetricWorkStrongHeadline,
            supporting: l10n.cityMetricWorkStrongSupporting,
            badge: l10n.cityMetricBadgePositive,
            icon: Icons.trending_up_rounded,
            tint: AppColors.success,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFF1F8F3),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.success,
              lightColor: const Color(0xFFBBDCC6),
            ),
          );
        }
        if (value >= 62) {
          return CityMetricPresentation(
            headline: l10n.cityMetricWorkMediumHeadline,
            supporting: l10n.cityMetricWorkMediumSupporting,
            badge: l10n.cityMetricBadgeNeutral,
            icon: Icons.work_outline_rounded,
            tint: AppColors.warning,
            background: AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFFFF8E7),
            ),
            border: AppColors.tintedBorderFor(
              context,
              tint: AppColors.warning,
              lightColor: const Color(0xFFEFCF84),
            ),
          );
        }
        return CityMetricPresentation(
          headline: l10n.cityMetricWorkLowHeadline,
          supporting: l10n.cityMetricWorkLowSupporting,
          badge: l10n.cityMetricBadgeAttention,
          icon: Icons.work_history_outlined,
          tint: AppColors.danger,
          background: AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFFDEEE8),
          ),
          border: AppColors.tintedBorderFor(
            context,
            tint: AppColors.danger,
            lightColor: const Color(0xFFF1C3B2),
          ),
        );
    }
  }

  static CityMetricPresentation preliminaryWork(BuildContext context) {
    final l10n = context.l10n;
    return CityMetricPresentation(
      headline: l10n.cityMetricWorkPreliminaryHeadline,
      supporting: l10n.cityMetricWorkPreliminarySupporting,
      badge: l10n.cityMetricBadgeAttention,
      icon: Icons.pending_actions_outlined,
      tint: AppColors.warning,
      background: AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      ),
      border: AppColors.tintedBorderFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFEFCF84),
      ),
    );
  }
}
