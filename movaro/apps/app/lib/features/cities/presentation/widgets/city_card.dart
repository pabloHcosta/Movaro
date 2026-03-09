import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_score_badge.dart';
import 'package:movaro_app/features/cities/presentation/widgets/recommendation_reason_list.dart';

class CityCard extends StatelessWidget {
  const CityCard({
    required this.city,
    required this.highlightLabel,
    required this.onTap,
    super.key,
  });

  final City city;
  final String highlightLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final idhm = CityIdhmPresentation.resolve(context, value: city.idhmScore);
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final isCoastal = CityCoastalProfile.isCoastal(city);
    final textSoft = AppColors.textSoftFor(context);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${city.stateName} (${city.stateCode})',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: textSoft),
                          ),
                          if (isCoastal)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.waves_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.citiesQuickFilterCoastal,
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_outward_rounded, color: textSoft),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                highlightLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: idhm.background,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: idhm.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.public_rounded, size: 16, color: idhm.tint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear} · ${idhm.headline}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: idhm.tint,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            RecommendationReasonList(
              reasons: city.recommendationReasons,
              maxItems: 2,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: housing.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: housing.tint.withValues(alpha: 0.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: housing.tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.house_siding_outlined,
                      size: 16,
                      color: housing.tint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          housing.badge,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: housing.tint,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          housing.supporting,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSoft,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: crossAxisCount == 4 ? 1.55 : 0.94,
                  children: [
                    CityScoreBadge(
                      label: context.l10n.cityDetailCostLabel,
                      value: city.movaroScores.economical,
                      kind: CityMetricKind.cost,
                      compact: true,
                    ),
                    CityScoreBadge(
                      label: context.l10n.cityDetailSafetyLabel,
                      value: city.safetyScore,
                      kind: CityMetricKind.safety,
                      compact: true,
                    ),
                    CityScoreBadge(
                      label: context.l10n.cityDetailLanguageLabel,
                      value: city.movaroScores.languageAdaptation,
                      kind: CityMetricKind.language,
                      compact: true,
                    ),
                    CityScoreBadge(
                      label: context.l10n.cityDetailWorkLabel,
                      value: city.movaroScores.workOpportunity,
                      kind: CityMetricKind.work,
                      compact: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
