import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_score_badge.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_weather_badge.dart';
import 'package:movaro_app/features/home/application/city_budget_data.dart';

class CityCard extends StatelessWidget {
  const CityCard({
    required this.city,
    required this.highlightLabel,
    required this.onTap,
    required this.citiesController,
    this.isFavorite = false,
    this.onFavoriteToggle,
    super.key,
  });

  final City city;
  final String highlightLabel;
  final VoidCallback onTap;
  final CitiesController citiesController;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final budget = CityBudgetData.forCity(city.id);
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final isCoastal = CityCoastalProfile.isCoastal(city);
    final seasonality = CitySeasonalityProfile.of(city);
    final isDark = AppColors.isDark(context);
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.10);
    final cardShadow = isDark
        ? Colors.black.withValues(alpha: 0.16)
        : const Color(0x1A315A8A);
    final iconChrome = isDark ? Colors.white : const Color(0xFF183A70);
    final favoriteFill = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : const Color(0xD9FFFFFF);
    final panelText = AppColors.textPrimaryFor(context);
    final panelSoftText = AppColors.textSoftFor(context);
    final metricItems = [
      _MetricSummary(
        label: context.l10n.cityDetailCostLabel,
        value: city.movaroScores.economical,
        kind: CityMetricKind.cost,
      ),
      _MetricSummary(
        label: context.l10n.cityDetailSafetyLabel,
        value: city.safetyScore,
        kind: CityMetricKind.safety,
      ),
      _MetricSummary(
        label: context.l10n.cityDetailLanguageLabel,
        value: city.movaroScores.languageAdaptation,
        kind: CityMetricKind.language,
      ),
      _MetricSummary(
        label: context.l10n.cityDetailWorkLabel,
        value: city.movaroScores.workOpportunity,
        kind: CityMetricKind.work,
      ),
    ];
    final positiveMetrics = metricItems
        .where((item) => item.tone(context) == _MetricTone.positive)
        .toList();
    final balancedMetrics = metricItems
        .where((item) => item.tone(context) == _MetricTone.neutral)
        .toList();
    final attentionMetrics = metricItems
        .where((item) => item.tone(context) == _MetricTone.attention)
        .toList();

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: cardShadow,
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CityImageHeader(
              city: city,
              height: 176,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _GlassPill(
                            child: Text(
                              highlightLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: iconChrome,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: onFavoriteToggle,
                          style: IconButton.styleFrom(
                            backgroundColor: favoriteFill,
                            foregroundColor: isFavorite
                                ? const Color(0xFFFF8FA7)
                                : iconChrome,
                          ),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (isCoastal)
                          _GlassPill(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.waves_rounded,
                                  size: 14,
                                  color: iconChrome,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.citiesQuickFilterCoastal,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: iconChrome,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        if (isCoastal) const SizedBox(width: 8),
                        if (seasonality != null) ...[
                          _SeasonalityBadge(
                            severity: seasonality.severity,
                            isDark: isDark,
                            label: seasonality.severity ==
                                    CitySeasonalitySeverity.high
                                ? context.l10n.citySeasonalityCardBadgeHigh
                                : context.l10n.citySeasonalityCardBadgeMedium,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CityWeatherBadge(
                              cityId: city.id,
                              citiesController: citiesController,
                              compact: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: panelText,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${city.stateName} (${city.stateCode})',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: panelSoftText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CityScoreStars(score: city.movaroScores.overall),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CardSnapshotPanel(
                    city: city,
                    budget: budget,
                    seasonality: seasonality,
                    housing: housing,
                    panelText: panelText,
                    panelSoftText: panelSoftText,
                    glassFill: AppColors.surfaceMutedFor(context),
                    glassBorder: AppColors.borderFor(context),
                  ),
                  const SizedBox(height: 10),
                  if (positiveMetrics.isNotEmpty) ...[
                    _MetricGroupSection(
                      title: context.l10n.cityMetricBadgePositive,
                      tint: AppColors.success,
                      items: positiveMetrics,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (balancedMetrics.isNotEmpty) ...[
                    _MetricGroupSection(
                      title: context.l10n.cityMetricBadgeNeutral,
                      tint: AppColors.warning,
                      items: balancedMetrics,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (attentionMetrics.isNotEmpty)
                    _MetricGroupSection(
                      title: context.l10n.cityMetricBadgeAttention,
                      tint: AppColors.danger,
                      items: attentionMetrics,
                    ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(context.l10n.favoritesOpenDetailsAction),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityScoreStars extends StatelessWidget {
  const _CityScoreStars({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final rating = _normalizeCityRating(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < 5; index++)
                Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 1),
                  child: Icon(
                    _starIconFor(index, rating),
                    size: 14,
                    color: const Color(0xFFF2B94B),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${rating.toStringAsFixed(rating.truncateToDouble() == rating ? 0 : 1)}/5',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  IconData _starIconFor(int index, double rating) {
    final position = index + 1;
    if (rating >= position) {
      return Icons.star_rounded;
    }
    if (rating >= position - 0.5) {
      return Icons.star_half_rounded;
    }
    return Icons.star_border_rounded;
  }
}

double _normalizeCityRating(int rawScore) {
  final normalized = rawScore <= 5 ? rawScore.toDouble() : (rawScore / 20);
  final clamped = normalized.clamp(0.0, 5.0);
  return (clamped * 2).round() / 2;
}

class _CardSnapshotPanel extends StatelessWidget {
  const _CardSnapshotPanel({
    required this.city,
    required this.budget,
    required this.seasonality,
    required this.housing,
    required this.panelText,
    required this.panelSoftText,
    required this.glassFill,
    required this.glassBorder,
  });

  final City city;
  final CityBudget? budget;
  final CitySeasonalityData? seasonality;
  final CityHousingViabilityPresentation housing;
  final Color panelText;
  final Color panelSoftText;
  final Color glassFill;
  final Color glassBorder;

  @override
  Widget build(BuildContext context) {
    final communityTint = _communityTint(city.argentinaPopularityScore);
    final seasonalityPresentation = _seasonalityPresentation(
      context,
      seasonality,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cityDetailSnapshotTitle,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: panelText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SnapshotFactTile(
                    label: context.l10n.cityDetailAffordabilityTitle,
                    headline: _budgetHeadline(context, budget, city),
                    supporting: _budgetSupporting(context, budget),
                    tint: _budgetTint(context, budget),
                    background: _budgetBackground(context, city, budget),
                    border: _budgetTint(context, budget).withValues(
                      alpha: AppColors.isDark(context) ? 0.24 : 0.18,
                    ),
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SnapshotFactTile(
                    label: context.l10n.cityDetailCommunityTitle,
                    headline: _communityHeadline(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    supporting: _communitySupporting(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    tint: communityTint,
                    background: AppColors.tintedSurfaceFor(
                      context,
                      tint: communityTint,
                      lightColor: const Color(0xFFEEF5FF),
                    ),
                    border: communityTint.withValues(
                      alpha: AppColors.isDark(context) ? 0.24 : 0.20,
                    ),
                    icon: Icons.people_outline_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _SnapshotSupportBlock(
            title: housing.badge,
            body: housing.supporting,
            tint: housing.tint,
            background: housing.background,
            icon: Icons.house_siding_outlined,
          ),
          if (seasonalityPresentation != null) ...[
            const SizedBox(height: 10),
            _SnapshotSupportBlock(
              title: seasonalityPresentation.headline,
              body: seasonalityPresentation.supporting,
              tint: seasonalityPresentation.tint,
              background: seasonalityPresentation.background,
              icon: Icons.flight_takeoff_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _SeasonalityCardPresentation {
  const _SeasonalityCardPresentation({
    required this.headline,
    required this.supporting,
    required this.tint,
    required this.background,
  });

  final String headline;
  final String supporting;
  final Color tint;
  final Color background;
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.16)
              : AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }
}

class _SnapshotFactTile extends StatelessWidget {
  const _SnapshotFactTile({
    required this.label,
    required this.headline,
    required this.supporting,
    required this.tint,
    required this.background,
    required this.border,
    required this.icon,
  });

  final String label;
  final String headline;
  final String supporting;
  final Color tint;
  final Color background;
  final Color border;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: tint),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textSoft,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            headline,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            supporting,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textSoft, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SnapshotSupportBlock extends StatelessWidget {
  const _SnapshotSupportBlock({
    required this.title,
    required this.body,
    required this.tint,
    required this.background,
    required this.icon,
  });

  final String title;
  final String body;
  final Color tint;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tint.withValues(
            alpha: AppColors.isDark(context) ? 0.24 : 0.18,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: tint),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _budgetHeadline(
  BuildContext context,
  CityBudget? budget,
  City city,
) {
  if (budget != null) {
    return _formatBrl(context, budget.fairLivingTotal);
  }

  return CityMetricPresentation.resolve(
    context,
    kind: CityMetricKind.cost,
    value: city.movaroScores.economical,
  ).headline;
}

String _budgetSupporting(BuildContext context, CityBudget? budget) {
  if (budget == null) {
    return context.l10n.cityMetricCostMediumSupporting;
  }

  return '${context.l10n.landingBudgetBalancedTitle}: '
      '${_formatBrl(context, budget.fairLivingTotal)}–${_formatBrl(context, budget.wellLivingTotal)}';
}

Color _budgetTint(BuildContext context, CityBudget? budget) {
  if (budget == null) {
    return AppColors.warning;
  }
  if (budget.fairLivingTotal <= 4700) return AppColors.success;
  if (budget.fairLivingTotal <= 5900) return AppColors.warning;
  return AppColors.danger;
}

Color _budgetBackground(BuildContext context, City city, CityBudget? budget) {
  final tint = _budgetTint(context, budget);
  return AppColors.tintedSurfaceFor(
    context,
    tint: tint,
    lightColor: switch (tint) {
      AppColors.success => const Color(0xFFF1F8F3),
      AppColors.warning => const Color(0xFFFFF8E7),
      _ => const Color(0xFFFDEEE8),
    },
  );
}

String _communityHeadline(BuildContext context, int score) {
  if (score >= 72) return context.l10n.cityComparisonCommunityLarge;
  if (score >= 52) return context.l10n.cityComparisonCommunityMedium;
  return context.l10n.cityComparisonCommunitySmall;
}

String _communitySupporting(BuildContext context, int score) {
  if (score >= 72) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' => 'Más presencia hispanohablante y red de apoyo.',
      'en' => 'More Spanish-speaking presence and support network.',
      _ => 'Mais presença hispanohablante e rede de apoio.',
    };
  }
  if (score >= 52) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' => 'Hay referencias y algo de comunidad, pero no es dominante.',
      'en' => 'There are references and some community, but it is not dominant.',
      _ => 'Há referências e alguma comunidade, mas não é dominante.',
    };
  }
  return switch (Localizations.localeOf(context).languageCode) {
    'es' => 'Conviene contar menos con comunidad y más con adaptación propia.',
    'en' => 'Expect to rely less on community and more on your own adaptation.',
    _ => 'Vale contar menos com comunidade e mais com adaptação própria.',
  };
}

Color _communityTint(int score) {
  if (score >= 72) return AppColors.success;
  if (score >= 52) return AppColors.primary;
  return AppColors.warning;
}

_SeasonalityCardPresentation? _seasonalityPresentation(
  BuildContext context,
  CitySeasonalityData? seasonality,
) {
  if (seasonality == null) {
    return null;
  }

  final isHigh = seasonality.severity == CitySeasonalitySeverity.high;
  final tint = isHigh ? AppColors.warning : AppColors.primary;
  return _SeasonalityCardPresentation(
    headline: isHigh
        ? context.l10n.citySeasonalityCardBadgeHigh
        : context.l10n.citySeasonalityCardBadgeMedium,
    supporting: seasonality.visitorsLabel(
      Localizations.localeOf(context).languageCode,
    ),
    tint: tint,
    background: AppColors.tintedSurfaceFor(
      context,
      tint: tint,
      lightColor: isHigh ? const Color(0xFFFFF8E7) : const Color(0xFFEEF5FF),
    ),
  );
}

String _formatBrl(BuildContext context, num amount) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat.currency(
    locale: locale,
    name: 'BRL',
    symbol: 'R\$',
    decimalDigits: 0,
  ).format(amount);
}

enum _MetricTone { positive, neutral, attention }

class _MetricSummary {
  const _MetricSummary({
    required this.label,
    required this.value,
    required this.kind,
  });

  final String label;
  final int value;
  final CityMetricKind kind;

  _MetricTone tone(BuildContext context) {
    final metric = CityMetricPresentation.resolve(
      context,
      kind: kind,
      value: value,
    );
    if (metric.badge == context.l10n.cityMetricBadgePositive) {
      return _MetricTone.positive;
    }
    if (metric.badge == context.l10n.cityMetricBadgeNeutral) {
      return _MetricTone.neutral;
    }
    return _MetricTone.attention;
  }
}

class _MetricGroupSection extends StatelessWidget {
  const _MetricGroupSection({
    required this.title,
    required this.tint,
    required this.items,
  });

  final String title;
  final Color tint;
  final List<_MetricSummary> items;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: isDark ? 0.20 : 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: tint,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < items.length; index++) ...[
            CityScoreBadge(
              label: items[index].label,
              value: items[index].value,
              kind: items[index].kind,
              compact: true,
            ),
            if (index != items.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── Seasonality badge ─────────────────────────────────────────────────────────

class _SeasonalityBadge extends StatelessWidget {
  const _SeasonalityBadge({
    required this.severity,
    required this.isDark,
    required this.label,
  });

  final CitySeasonalitySeverity severity;
  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isHigh = severity == CitySeasonalitySeverity.high;
    final color = isHigh ? AppColors.danger : AppColors.caution;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.28 : 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.5 : 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHigh
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
