import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_conflict_service.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

/// Seasonality alert section for city detail pages.
///
/// Shows a severity banner, 12-month visual calendar, visitor volume callout,
/// housing impact card, and job market notes. Only renders for cities that
/// have seasonality data.
///
/// When [planTimeline] is provided the section also evaluates the user's
/// estimated arrival window against peak season and shows a personalized
/// conflict banner at the top.
class CitySeasonalitySection extends StatefulWidget {
  const CitySeasonalitySection({
    required this.city,
    this.locale = 'pt',
    this.planTimeline,
    super.key,
  });

  final City city;

  /// Locale code used to select the correct language variant ('pt', 'es', 'en').
  final String locale;

  /// Optional migration timeline string from [MigrationPlan.timeline].
  /// When set, a personalized conflict banner is shown if the estimated
  /// arrival months overlap with this city's peak season.
  final String? planTimeline;

  @override
  State<CitySeasonalitySection> createState() => _CitySeasonalitySectionState();
}

class _CitySeasonalitySectionState extends State<CitySeasonalitySection> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data = CitySeasonalityProfile.of(widget.city);
    if (data == null) return const SizedBox.shrink();

    // Evaluate plan-specific conflict (only when timeline is provided)
    final conflict = widget.planTimeline != null
        ? CitySeasonalityConflictService.evaluate(
            city: widget.city,
            timeline: widget.planTimeline,
          )
        : null;
    final hasConflict = conflict?.hasConflict == true;

    final isDark = AppColors.isDark(context);
    final isHigh = data.severity == CitySeasonalitySeverity.high;

    final bannerColor = isHigh
        ? (isDark ? const Color(0xFF8B1A1A) : const Color(0xFFFFF0F0))
        : (isDark ? const Color(0xFF6B4A00) : const Color(0xFFFFF8EC));

    final bannerBorder = isHigh
        ? (isDark ? const Color(0xFFD32F2F) : const Color(0xFFFFCDD2))
        : (isDark ? const Color(0xFFFF8F00) : const Color(0xFFFFE0B2));

    final severityColor = isHigh ? AppColors.danger : AppColors.caution;
    final severityIcon =
        isHigh ? Icons.warning_amber_rounded : Icons.info_outline_rounded;

    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: AppColors.textSoftFor(context),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.citySeasonalityTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimaryFor(context),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),

        // ── Personalized conflict banner (plan-aware) ───────────────────────
        if (hasConflict && conflict != null) ...[
          _PersonalizedConflictBanner(
            conflict: conflict,
            locale: widget.locale,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
        ],

        // ── Severity banner ─────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          decoration: BoxDecoration(
            color: bannerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bannerBorder),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(severityIcon, color: severityColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHigh
                          ? l10n.citySeasonalityHighSeverityLabel
                          : l10n.citySeasonalityMediumSeverityLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.visitorsLabel(widget.locale),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimaryFor(context),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (data.populationMultiplierNote != null) ...[
                      const SizedBox(height: 6),
                      _PopulationPill(
                        label: data.populationMultiplierNote!,
                        color: severityColor,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── 12-month calendar ───────────────────────────────────────────────
        _MonthCalendar(
          peakMonths: data.peakMonths,
          lowMonths: data.lowMonths,
          locale: widget.locale,
          severityColor: severityColor,
          isDark: isDark,
          arrivalMonths: conflict?.arrivalMonths,
        ),

        const SizedBox(height: 14),

        // ── Expandable detail cards ─────────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
          child: Row(
            children: [
              Text(
                _detailsExpanded
                    ? l10n.citySeasonalityHideDetails
                    : l10n.citySeasonalityShowDetails,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _detailsExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: _detailsExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              children: [
                // Housing impact
                _ImpactCard(
                  icon: Icons.home_outlined,
                  iconColor: AppColors.caution,
                  title: l10n.citySeasonalityHousingTitle,
                  body: data.rentNotes(widget.locale),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                // Jobs impact
                _ImpactCard(
                  icon: Icons.work_outline_rounded,
                  iconColor: AppColors.success,
                  title: l10n.citySeasonalityJobsTitle,
                  body: data.jobNotes(widget.locale),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                // Advice row
                _AdviceCard(
                  isHigh: isHigh,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Month Calendar ────────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.peakMonths,
    required this.lowMonths,
    required this.locale,
    required this.severityColor,
    required this.isDark,
    this.arrivalMonths,
  });

  final List<int> peakMonths;
  final List<int> lowMonths;
  final String locale;
  final Color severityColor;
  final bool isDark;
  /// Months the user plans to arrive, derived from their plan timeline.
  /// When set, arrival months are highlighted with a blue dot in the calendar.
  final List<int>? arrivalMonths;

  static const _monthsPt = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  static const _monthsEs = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  static const _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<String> get _months => switch (locale) {
        'es' => _monthsEs,
        'en' => _monthsEn,
        _ => _monthsPt,
      };

  @override
  Widget build(BuildContext context) {
    final months = _months;
    final arrivals = arrivalMonths ?? const <int>[];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(12, (i) {
        final monthNum = i + 1;
        final isPeak = peakMonths.contains(monthNum);
        final isLow = lowMonths.contains(monthNum);
        final isArrival = arrivals.contains(monthNum);

        return _MonthChip(
          label: months[i],
          isPeak: isPeak,
          isLow: isLow,
          isArrival: isArrival,
          peakColor: severityColor,
          isDark: isDark,
        );
      }),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.isPeak,
    required this.isLow,
    required this.peakColor,
    required this.isDark,
    this.isArrival = false,
  });

  final String label;
  final bool isPeak;
  final bool isLow;
  final Color peakColor;
  final bool isDark;
  /// True when this month falls within the user's planned arrival window.
  final bool isArrival;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final FontWeight fontWeight;

    if (isPeak) {
      bgColor = peakColor.withValues(alpha: isDark ? 0.28 : 0.12);
      textColor = peakColor;
      borderColor = peakColor.withValues(alpha: 0.6);
      fontWeight = FontWeight.w800;
    } else if (isLow) {
      bgColor = AppColors.surfaceMutedFor(context);
      textColor = AppColors.textSoftFor(context).withValues(alpha: 0.72);
      borderColor = AppColors.borderFor(context);
      fontWeight = FontWeight.w400;
    } else {
      bgColor = AppColors.surfaceMutedFor(context);
      textColor = AppColors.textSoftFor(context);
      borderColor = AppColors.borderFor(context);
      fontWeight = FontWeight.w500;
    }

    // Arrival months that also fall on peak season get a thicker accent border
    // so color-blind users still see the timing conflict at a glance.
    final resolvedBorderColor = (isArrival && isPeak)
        ? peakColor
        : isArrival
            ? AppColors.primary.withValues(alpha: 0.5)
            : borderColor;
    final borderWidth = (isArrival && isPeak) ? 1.5 : 1.0;

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: resolvedBorderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: 10,
                ),
          ),
          if (isPeak || isArrival) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPeak)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: peakColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (isPeak && isArrival) const SizedBox(width: 2),
                if (isArrival)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Population pill ───────────────────────────────────────────────────────────

class _PopulationPill extends StatelessWidget {
  const _PopulationPill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            '${context.l10n.citySeasonalityPopulationPrefix} $label',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Impact card ───────────────────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.5,
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

// ─── Advice card ───────────────────────────────────────────────────────────────

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.isHigh,
    required this.isDark,
  });

  final bool isHigh;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final advice = isHigh
        ? l10n.citySeasonalityHighAdvice
        : l10n.citySeasonalityMediumAdvice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.30 : 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              advice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Personalized conflict banner ──────────────────────────────────────────────
//
// Shown at the TOP of the seasonality section when the user's planned arrival
// window overlaps with the city's peak season.  This is the most important
// piece of information — it tells the user that THEIR specific plan has a
// timing conflict, not just that the city has a season.

class _PersonalizedConflictBanner extends StatelessWidget {
  const _PersonalizedConflictBanner({
    required this.conflict,
    required this.locale,
    required this.isDark,
  });

  final SeasonalityConflict conflict;
  final String locale;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isCritical = conflict.level == SeasonalityConflictLevel.critical;
    final color = isCritical ? AppColors.danger : AppColors.caution;
    final bgColor = isCritical
        ? (isDark ? const Color(0xFF5C0A0A) : const Color(0xFFFFEBEE))
        : (isDark ? const Color(0xFF5A3800) : const Color(0xFFFFF3E0));
    final borderColor = isCritical
        ? (isDark ? const Color(0xFFE53935) : const Color(0xFFEF9A9A))
        : (isDark ? const Color(0xFFFF8F00) : const Color(0xFFFFCC80));

    final headline = conflict.conflictHeadline(locale);
    final body = conflict.conflictMessage(locale);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCritical
                    ? Icons.warning_rounded
                    : Icons.schedule_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  headline,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? color.withValues(alpha: 0.9)
                        : AppColors.textPrimaryFor(context),
                    height: 1.55,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: _ArrivalMonthsRow(
              conflict: conflict,
              locale: locale,
              color: color,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact row showing arrival months vs peak months as colored chips.
class _ArrivalMonthsRow extends StatelessWidget {
  const _ArrivalMonthsRow({
    required this.conflict,
    required this.locale,
    required this.color,
    required this.isDark,
  });

  final SeasonalityConflict conflict;
  final String locale;
  final Color color;
  final bool isDark;

  static const _ptMonths = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  static const _esMonths = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  static const _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<String> get _names => switch (locale) {
        'es' => _esMonths,
        'en' => _enMonths,
        _ => _ptMonths,
      };

  @override
  Widget build(BuildContext context) {
    final names = _names;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: conflict.arrivalMonths.map((m) {
        final isOverlap = conflict.overlapMonths.contains(m);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isOverlap
                ? color.withValues(alpha: isDark ? 0.3 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isOverlap
                  ? color.withValues(alpha: 0.7)
                  : AppColors.borderFor(context),
            ),
          ),
          child: Text(
            names[m - 1],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isOverlap ? color : AppColors.textSoftFor(context),
                  fontWeight:
                      isOverlap ? FontWeight.w800 : FontWeight.w400,
                  fontSize: 10,
                ),
          ),
        );
      }).toList(),
    );
  }
}
