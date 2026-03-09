import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class RecommendationReasonList extends StatelessWidget {
  const RecommendationReasonList({
    required this.reasons,
    this.maxItems,
    super.key,
  });

  final List<String> reasons;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final background = AppColors.surfaceMutedFor(context);
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
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(context.l10n.recommendationReasonLabel(reason)),
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
