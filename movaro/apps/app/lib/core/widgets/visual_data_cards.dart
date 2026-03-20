import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

enum ScoreTone { positive, balanced, attention, neutral }

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    required this.label,
    this.value,
    this.icon,
    this.tint,
    this.tone = ScoreTone.neutral,
    this.inverse = false,
    super.key,
  });

  final String label;
  final String? value;
  final IconData? icon;
  final Color? tint;
  final ScoreTone tone;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? _toneColor(tone);
    final background = inverse
        ? Colors.white.withValues(alpha: 0.12)
        : color.withValues(alpha: 0.10);
    final foreground = inverse ? Colors.white : color;
    final toneIcon = _toneIcon(tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: inverse
              ? Colors.white.withValues(alpha: 0.14)
              : color.withValues(alpha: 0.12),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
            ] else if (toneIcon != null) ...[
              Icon(toneIcon, size: 16, color: foreground),
            ],
            if (value != null)
              Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: inverse
                    ? Colors.white.withValues(alpha: 0.92)
                    : AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _toneColor(ScoreTone tone) {
    return switch (tone) {
      ScoreTone.positive => AppColors.success,
      ScoreTone.balanced => AppColors.warning,
      ScoreTone.attention => AppColors.danger,
      ScoreTone.neutral => AppColors.primary,
    };
  }

  IconData? _toneIcon(ScoreTone tone) {
    return switch (tone) {
      ScoreTone.positive => Icons.trending_up_rounded,
      ScoreTone.balanced => Icons.remove_rounded,
      ScoreTone.attention => Icons.trending_down_rounded,
      ScoreTone.neutral => null,
    };
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    required this.title,
    required this.body,
    required this.icon,
    this.tint,
    this.onTap,
    super.key,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? AppColors.primary;
    final card = FrostedPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: card,
      ),
    );
  }
}

class CompareCardMetric {
  const CompareCardMetric({
    required this.label,
    required this.value,
    this.icon,
    this.tone = ScoreTone.neutral,
  });

  final String label;
  final String value;
  final IconData? icon;
  final ScoreTone tone;
}

class CompareCard extends StatelessWidget {
  const CompareCard({
    required this.title,
    required this.subtitle,
    required this.metrics,
    this.badge,
    this.onTap,
    this.actionLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final List<CompareCardMetric> metrics;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 12),
                ScoreBadge(label: badge!),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final metric in metrics)
                ScoreBadge(
                  label: metric.label,
                  value: metric.value,
                  icon: metric.icon,
                  tone: metric.tone,
                ),
            ],
          ),
          if (onTap != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
