import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
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
    required this.onTap,
    required this.citiesController,
    this.isFavorite = false,
    this.onFavoriteToggle,
    super.key,
  });

  final City city;
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
                height: 228,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CityWeatherBadge(
                            cityId: city.id,
                            citiesController: citiesController,
                            compact: true,
                          ),
                          const SizedBox(width: 8),
                          _FavoriteButton(
                            selected: isFavorite,
                            onTap: onFavoriteToggle,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ImagePill(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _lifestyleIcon(),
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _lifestyleLabel(context),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (seasonality != null)
                            _SeasonalityPill(
                              severity: seasonality.severity,
                              label:
                                  seasonality.severity ==
                                      CitySeasonalitySeverity.high
                                  ? context.l10n.citySeasonalityCardBadgeHigh
                                  : context.l10n.citySeasonalityCardBadgeMedium,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        city.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              height: 1,
                              shadows: const [
                                Shadow(
                                  color: Color(0x99000000),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${city.stateName} · ${city.stateCode}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(color: Color(0x99000000), blurRadius: 10),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    Text(
                      _localized(
                        context,
                        pt: 'Visão rápida',
                        es: 'Vista rápida',
                        en: 'At a glance',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final halfWidth = (constraints.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              width: halfWidth,
                              child: _MetricTile(
                                icon: Icons.payments_outlined,
                                label: _localized(
                                  context,
                                  pt: 'Custo mensal',
                                  es: 'Costo mensual',
                                  en: 'Monthly cost',
                                ),
                                value: _costRange(context),
                                supportingText: _localized(
                                  context,
                                  pt: '1 pessoa',
                                  es: '1 persona',
                                  en: '1 person',
                                ),
                                score: null,
                              ),
                            ),
                            SizedBox(
                              width: halfWidth,
                              child: _MetricTile(
                                icon: Icons.home_work_outlined,
                                label: _localized(
                                  context,
                                  pt: 'Aluguel',
                                  es: 'Alquiler',
                                  en: 'Rent',
                                ),
                                value: _rentRange(context),
                                supportingText: _localized(
                                  context,
                                  pt: '1 quarto',
                                  es: '1 dormitorio',
                                  en: '1 bedroom',
                                ),
                                score: null,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth,
                              child: _MetricTile(
                                icon: Icons.business_center_outlined,
                                label: _localized(
                                  context,
                                  pt: 'Economia',
                                  es: 'Economía',
                                  en: 'Economy',
                                ),
                                value: city.topIndustries.isEmpty
                                    ? context.l10n.cityCardDataUnavailable
                                    : city.topIndustries
                                          .take(1)
                                          .map(context.l10n.workAreaLabel)
                                          .join(),
                                supportingText:
                                    '${_localized(context, pt: 'População', es: 'Población', en: 'Population')}: ${NumberFormat.compact(locale: Localizations.localeOf(context).toString()).format(city.population)}',
                                score: null,
                              ),
                            ),
                          ],
                        );
                      },
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

  String _costRange(BuildContext context) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return context.l10n.cityCardDataUnavailable;
    }
    return MultiCurrencyAmount.formatRangeFromBrl(
      context: context,
      minBrl: budget.fairLivingTotal,
      maxBrl: budget.wellLivingTotal,
      primaryLocale: Localizations.localeOf(context).toString(),
    );
  }

  String _rentRange(BuildContext context) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return context.l10n.cityCardDataUnavailable;
    }
    return MultiCurrencyAmount.formatRangeFromBrl(
      context: context,
      minBrl: budget.planningRentLow,
      maxBrl: budget.planningRentHigh,
      primaryLocale: Localizations.localeOf(context).toString(),
    );
  }

  String _detailsLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Ver detalhes da cidade',
      'es' => 'Ver detalles de la ciudad',
      _ => 'View city details',
    };
  }

  String _lifestyleLabel(BuildContext context) =>
      switch (CityCoastalProfile.lifestyleKind(city)) {
        CityLifestyleKind.coastal => _localized(
          context,
          pt: 'Litoral',
          es: 'Costa',
          en: 'Coastal',
        ),
        CityLifestyleKind.metropolis => _localized(
          context,
          pt: 'Metrópole',
          es: 'Metrópoli',
          en: 'Metropolis',
        ),
        CityLifestyleKind.border => _localized(
          context,
          pt: 'Fronteira',
          es: 'Frontera',
          en: 'Border',
        ),
        CityLifestyleKind.inland => _localized(
          context,
          pt: 'Interior',
          es: 'Interior',
          en: 'Inland',
        ),
      };

  IconData _lifestyleIcon() => switch (CityCoastalProfile.lifestyleKind(city)) {
    CityLifestyleKind.coastal => Icons.waves_rounded,
    CityLifestyleKind.metropolis => Icons.apartment_rounded,
    CityLifestyleKind.border => Icons.swap_horiz_rounded,
    CityLifestyleKind.inland => Icons.nature_people_outlined,
  };

  String _localized(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.score,
    this.supportingText,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? score;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final currentScore = score;
    final tint = currentScore == null
        ? AppColors.textSoftFor(context)
        : switch (currentScore) {
            >= 70 => AppColors.success,
            >= 50 => AppColors.warning,
            _ => AppColors.danger,
          };
    final semanticValue = ['$label: $value', ?supportingText].join('. ');

    return Semantics(
      container: true,
      label: semanticValue,
      child: ExcludeSemantics(
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
          decoration: BoxDecoration(
            color: tint.withValues(
              alpha: AppColors.isDark(context) ? 0.10 : 0.07,
            ),
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
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (supportingText != null) ...[
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    supportingText!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
