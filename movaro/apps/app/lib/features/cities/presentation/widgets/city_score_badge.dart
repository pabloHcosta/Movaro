import 'package:flutter/material.dart';
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
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);
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
            metric.tint.withValues(alpha: 0.10),
            const Color(0xFF0C1524),
          )
        : metric.background;
    final compactBorder = isDark
        ? metric.tint.withValues(alpha: 0.22)
        : metric.border;
    final minWidth = compact ? 0.0 : 172.0;
    final iconSize = compact ? 14.0 : 18.0;
    final iconBoxSize = compact ? 24.0 : 30.0;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: 220),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 14,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: compact ? compactBackground : metric.background,
        border: Border.all(color: compact ? compactBorder : metric.border),
        borderRadius: BorderRadius.circular(compact ? 20 : 22),
        gradient: compact
            ? LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.04 : 0.25),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (compact)
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
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
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
          SizedBox(height: compact ? 8 : 10),
          Text(
            metric.headline,
            style: (compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleSmall)
                ?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w700,
              height: compact ? 1.05 : null,
              fontSize: compact ? 17 : null,
            ),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (compact) ...[
            const SizedBox(height: 5),
            Text(
              metric.supporting,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textSoft,
                height: 1.15,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(
              metric.supporting,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSoft, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}
