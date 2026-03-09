import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class CitySnapshotTile extends StatelessWidget {
  const CitySnapshotTile({
    required this.label,
    required this.value,
    required this.supporting,
    required this.tint,
    required this.background,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final String supporting;
  final Color tint;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: tint),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textSoft,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            supporting,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(
              color: textSoft,
              height: 1.2,
              fontSize: 11.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
