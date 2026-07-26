import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/utils/cost_estimate_formatter.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_weather_badge.dart';

/// Compact discovery card used by Explore.
///
/// It intentionally exposes only the signals needed to compare cities at a
/// glance. Detailed methodology, housing and seasonality explanations remain
/// on the city detail page.
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
    final isDark = AppColors.isDark(context);
    final seasonality = CitySeasonalityProfile.of(city);
    final cardRadius = BorderRadius.circular(24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: cardRadius,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AppColors.primary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.22)
                    : const Color(0xFF315A8A).withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CityImageHeader(
                city: city,
                height: 190,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ImagePill(
                              child: Text(
                                highlightLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _FavoriteButton(
                            selected: isFavorite,
                            onTap: onFavoriteToggle,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (seasonality != null)
                            _SeasonalityPill(
                              severity: seasonality.severity,
                              label:
                                  seasonality.severity ==
                                      CitySeasonalitySeverity.high
                                  ? context.l10n.citySeasonalityCardBadgeHigh
                                  : context.l10n.citySeasonalityCardBadgeMedium,
                            )
                          else if (CityCoastalProfile.isCoastal(city))
                            _ImagePill(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.waves_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.citiesQuickFilterCoastal,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          CityWeatherBadge(
                            cityId: city.id,
                            citiesController: citiesController,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
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
                                      color: AppColors.textPrimaryFor(context),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.35,
                                      height: 1.05,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${city.stateName} · ${city.stateCode}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _MethodPill(city: city),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.payments_outlined,
                            label: context.l10n.cityDetailCostLabel,
                            value: _costValue(context),
                            score: city.movaroScores.economical,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.shield_outlined,
                            label: context.l10n.cityDetailSafetyLabel,
                            value: city.sources.safety == null
                                ? _unsourcedLabel(context)
                                : _scoreBand(context, city.safetyScore),
                            score: city.sources.safety == null
                                ? 50
                                : city.safetyScore,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.translate_rounded,
                            label: context.l10n.cityDetailLanguageLabel,
                            value:
                                '${city.movaroScores.languageAdaptation}/100',
                            score: city.movaroScores.languageAdaptation,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Container(
                      height: 1,
                      color: AppColors.borderFor(
                        context,
                      ).withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _detailsLabel(context),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _costValue(BuildContext context) {
    final budget = city.budgetSnapshot;
    if (budget == null) return '${city.movaroScores.economical}/100';
    final locale = Localizations.localeOf(context).toString();
    return CostEstimateFormatter.brlRange(
      budget.fairLivingTotal,
      budget.wellLivingTotal,
      locale: locale,
      compact: true,
    );
  }

  String _detailsLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Explorar esta cidade',
      'es' => 'Explorar esta ciudad',
      _ => 'Explore this city',
    };
  }

  String _unsourcedLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' => 'Sin fuente',
      'en' => 'No source',
      _ => 'Sem fonte',
    };
  }

  String _scoreBand(BuildContext context, int score) {
    final language = Localizations.localeOf(context).languageCode;
    if (score >= 70) {
      return language == 'es'
          ? 'Señal alta'
          : language == 'en'
          ? 'High signal'
          : 'Sinal alto';
    }
    if (score >= 50) {
      return language == 'es'
          ? 'Señal media'
          : language == 'en'
          ? 'Medium signal'
          : 'Sinal médio';
    }
    return language == 'es'
        ? 'Revisar'
        : language == 'en'
        ? 'Review'
        : 'Revisar';
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap?.call();
            },
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.34),
        foregroundColor: selected
            ? const Color(0xFFFF7193)
            : Colors.white.withValues(alpha: 0.90),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      icon: Icon(
        selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 19,
      ),
    );
  }
}

class _ImagePill extends StatelessWidget {
  const _ImagePill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: child,
    );
  }
}

class _SeasonalityPill extends StatelessWidget {
  const _SeasonalityPill({required this.severity, required this.label});

  final CitySeasonalitySeverity severity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isHigh = severity == CitySeasonalitySeverity.high;
    final tint = isHigh ? const Color(0xFFFF7A59) : const Color(0xFFFFB84D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHigh
                ? Icons.warning_amber_rounded
                : Icons.calendar_month_outlined,
            size: 13,
            color: tint,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodPill extends StatelessWidget {
  const _MethodPill({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB84D).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB84D).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insights_rounded,
            size: 16,
            color: Color(0xFFFFB84D),
          ),
          const SizedBox(width: 4),
          Text(
            '${city.sources.all.length}/8 ${switch (Localizations.localeOf(context).languageCode) {
              'es' => 'fuentes',
              'en' => 'sources',
              _ => 'fontes',
            }}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.score,
  });

  final IconData icon;
  final String label;
  final String value;
  final int score;

  @override
  Widget build(BuildContext context) {
    final tint = switch (score) {
      >= 70 => AppColors.success,
      >= 50 => AppColors.warning,
      _ => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: AppColors.isDark(context) ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: tint),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
