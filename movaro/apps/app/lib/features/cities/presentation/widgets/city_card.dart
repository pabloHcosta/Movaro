import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_score_badge.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_weather_badge.dart';

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
    final idhm = CityIdhmPresentation.resolve(context, value: city.idhmScore);
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final isCoastal = CityCoastalProfile.isCoastal(city);
    final isDark = AppColors.isDark(context);
    final textSoft = Colors.white.withValues(alpha: 0.80);
    final textPrimary = Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.10);
    final cardShadow = isDark
        ? Colors.black.withValues(alpha: 0.16)
        : const Color(0x1A315A8A);
    final glassFill = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xF2FFFFFF);
    final glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.primary.withValues(alpha: 0.12);
    final iconChrome = isDark
        ? Colors.white
        : const Color(0xFF183A70);
    final favoriteFill = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : const Color(0xD9FFFFFF);
    final panelText = isDark ? Colors.white : const Color(0xFF10233F);
    final panelSoftText = isDark
        ? Colors.white.withValues(alpha: 0.76)
        : const Color(0xCC28476D);
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
            CityImageBackdrop(
              city: city,
              borderRadius: BorderRadius.circular(30),
              overlayOpacity: isDark ? 0.8 : 0.72,
              padding: const EdgeInsets.all(20),
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${city.stateName} (${city.stateCode})',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: textSoft),
                                ),
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: iconChrome,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_outward_rounded,
                            color: iconChrome,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _GlassPill(
                        child: Text(
                          highlightLabel,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: panelText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      CityWeatherBadge(
                        cityId: city.id,
                        citiesController: citiesController,
                        compact: true,
                      ),
                  ],
                ),
                  const SizedBox(height: 14),
                  _CardSnapshotPanel(
                    city: city,
                    idhm: idhm,
                    housing: housing,
                    panelText: panelText,
                    panelSoftText: panelSoftText,
                    glassFill: glassFill,
                    glassBorder: glassBorder,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSnapshotPanel extends StatelessWidget {
  const _CardSnapshotPanel({
    required this.city,
    required this.idhm,
    required this.housing,
    required this.panelText,
    required this.panelSoftText,
    required this.glassFill,
    required this.glassBorder,
  });

  final City city;
  final CityIdhmPresentation idhm;
  final CityHousingViabilityPresentation housing;
  final Color panelText;
  final Color panelSoftText;
  final Color glassFill;
  final Color glassBorder;

  @override
  Widget build(BuildContext context) {
    final reasons = city.recommendationReasons.take(2).toList(growable: false);
    final popularityTint = _popularityTint(city.argentinaPopularityScore);

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
                    label:
                        '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear}',
                    headline: idhm.headline,
                    supporting: idhm.supporting,
                    tint: idhm.tint,
                    background: idhm.background,
                    border: idhm.border,
                    icon: Icons.public_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SnapshotFactTile(
                    label: context.l10n.cityDetailPopularityLabel,
                    headline: _popularityHeadline(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    supporting: _popularitySupporting(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    tint: popularityTint,
                    background: _popularityBackground(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    border: popularityTint.withValues(
                      alpha: AppColors.isDark(context) ? 0.24 : 0.20,
                    ),
                    icon: Icons.favorite_border_rounded,
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
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.cityDetailReasonsTitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: panelText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < reasons.length; index++) ...[
              _SnapshotReasonRow(
                text: context.l10n.recommendationReasonLabel(reasons[index]),
                textColor: panelText,
                softTextColor: panelSoftText,
              ),
              if (index != reasons.length - 1) const SizedBox(height: 6),
            ],
          ],
        ],
      ),
    );
  }
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textSoft,
              height: 1.3,
            ),
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

class _SnapshotReasonRow extends StatelessWidget {
  const _SnapshotReasonRow({
    required this.text,
    required this.textColor,
    required this.softTextColor,
  });

  final String text;
  final Color textColor;
  final Color softTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: softTextColor,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

String _popularityHeadline(BuildContext context, int score) {
  if (score >= 80) {
    return context.l10n.citySnapshotPopularityHigh;
  }
  if (score >= 60) {
    return context.l10n.citySnapshotPopularityMedium;
  }
  return context.l10n.citySnapshotPopularityLow;
}

String _popularitySupporting(BuildContext context, int score) {
  if (score >= 80) {
    return context.l10n.citySnapshotPopularityHighSupporting;
  }
  if (score >= 60) {
    return context.l10n.citySnapshotPopularityMediumSupporting;
  }
  return context.l10n.citySnapshotPopularityLowSupporting;
}

Color _popularityTint(int score) {
  if (score >= 80) {
    return AppColors.success;
  }
  if (score >= 60) {
    return AppColors.warning;
  }
  return AppColors.caution;
}

Color _popularityBackground(BuildContext context, int score) {
  final tint = _popularityTint(score);
  return AppColors.tintedSurfaceFor(
    context,
    tint: tint,
    lightColor: score >= 80
        ? const Color(0xFFF1F8F3)
        : score >= 60
        ? const Color(0xFFFFF8E7)
        : const Color(0xFFFFF1E8),
  );
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
        border: Border.all(
          color: tint.withValues(alpha: isDark ? 0.20 : 0.14),
        ),
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
