import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';

class CityScoreBadge extends StatelessWidget {
  const CityScoreBadge({
    required this.label,
    required this.value,
    required this.kind,
    this.compact = false,
    super.key,
  });

  final String label;
  final int value;
  final CityMetricKind kind;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = compact
        ? (isDark ? Colors.white : const Color(0xFF10233F))
        : AppColors.textPrimaryFor(context);
    final textSoft = compact
        ? (isDark
              ? Colors.white.withValues(alpha: 0.72)
              : const Color(0xCC28476D))
        : AppColors.textSoftFor(context);
    final badgeBackground = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.6);
    final metric = CityMetricPresentation.resolve(
      context,
      kind: kind,
      value: value,
    );
    final compactBackground = isDark
        ? Color.alphaBlend(
            metric.tint.withValues(alpha: 0.18),
            const Color(0xFF09121F),
          )
        : Color.alphaBlend(
            Colors.white.withValues(alpha: 0.92),
            metric.background,
          );
    final compactBorder = isDark
        ? metric.tint.withValues(alpha: 0.34)
        : metric.border.withValues(alpha: 0.94);
    final minWidth = compact ? 0.0 : 172.0;
    final iconSize = compact ? 16.0 : 18.0;
    final iconBoxSize = compact ? 34.0 : 30.0;
    final trendIcon = _trendIcon(metric.badge, context);

    if (compact) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: compactBackground,
          border: Border.all(color: compactBorder),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: metric.tint.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(metric.icon, size: iconSize, color: metric.tint),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textSoft,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.headline,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ScoreValuePill(
                        value: value,
                        tint: metric.tint,
                        trendIcon: trendIcon,
                        compact: true,
                      ),
                      Text(
                        metric.supporting,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSoft,
                          height: 1.15,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: 220),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 9 : 12,
      ),
      decoration: BoxDecoration(
        color: compact ? compactBackground : metric.background,
        border: Border.all(color: compact ? compactBorder : metric.border),
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        gradient: compact
            ? LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.05 : 0.18),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: compact
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: metric.tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(metric.icon, size: iconSize, color: metric.tint),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: textSoft,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            metric.headline,
            style: (compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleSmall)
                ?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            metric.supporting,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textSoft, height: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScoreValuePill(
                value: value,
                tint: metric.tint,
                trendIcon: trendIcon,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  metric.badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: metric.tint,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _trendIcon(String badge, BuildContext context) {
    if (badge == context.l10n.cityMetricBadgePositive) {
      return Icons.trending_up_rounded;
    }
    if (badge == context.l10n.cityMetricBadgeNeutral) {
      return Icons.remove_rounded;
    }
    return Icons.trending_down_rounded;
  }
}

class _ScoreValuePill extends StatelessWidget {
  const _ScoreValuePill({
    required this.value,
    required this.tint,
    required this.trendIcon,
    this.compact = false,
  });

  final int value;
  final Color tint;
  final IconData trendIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: compact ? 13 : 14, color: tint),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tint,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
