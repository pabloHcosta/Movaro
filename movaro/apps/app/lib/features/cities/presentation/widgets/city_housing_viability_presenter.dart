import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class CityHousingViabilityPresentation {
  const CityHousingViabilityPresentation({
    required this.headline,
    required this.supporting,
    required this.badge,
    required this.tint,
    required this.background,
  });

  final String headline;
  final String supporting;
  final String badge;
  final Color tint;
  final Color background;
}

class CityHousingViabilityPresenter {
  const CityHousingViabilityPresenter._();

  static CityHousingViabilityPresentation resolve(
    BuildContext context, {
    required int rentScore,
  }) {
    final l10n = context.l10n;

    if (rentScore >= 72) {
      return CityHousingViabilityPresentation(
        headline: l10n.cityHousingViabilityEasyHeadline,
        supporting: l10n.cityHousingViabilityEasySupporting,
        badge: l10n.cityHousingViabilityEasyBadge,
        tint: AppColors.success,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.success,
          lightColor: const Color(0xFFF1F8F3),
        ),
      );
    }

    if (rentScore >= 55) {
      return CityHousingViabilityPresentation(
        headline: l10n.cityHousingViabilityBalancedHeadline,
        supporting: l10n.cityHousingViabilityBalancedSupporting,
        badge: l10n.cityHousingViabilityBalancedBadge,
        tint: AppColors.warning,
        background: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFFFF8E7),
        ),
      );
    }

    return CityHousingViabilityPresentation(
      headline: l10n.cityHousingViabilityHardHeadline,
      supporting: l10n.cityHousingViabilityHardSupporting,
      badge: l10n.cityHousingViabilityHardBadge,
      tint: AppColors.danger,
      background: AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.danger,
        lightColor: const Color(0xFFFDEEE8),
      ),
    );
  }
}
