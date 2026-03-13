import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class RecommendationReasonList extends StatelessWidget {
  const RecommendationReasonList({
    required this.reasons,
    this.maxItems,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    super.key,
  });

  final List<String> reasons;
  final int? maxItems;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? AppColors.surfaceMutedFor(context);
    final resolvedTextColor = textColor ?? AppColors.textPrimaryFor(context);
    final resolvedIconColor = iconColor ?? AppColors.accent;
    final visibleReasons = maxItems == null
        ? reasons
        : reasons.take(maxItems!).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final reason in visibleReasons) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: resolvedIconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.recommendationReasonLabel(reason),
                    style: TextStyle(color: resolvedTextColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
