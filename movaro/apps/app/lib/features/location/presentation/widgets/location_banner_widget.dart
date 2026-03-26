import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class LocationBannerWidget extends StatelessWidget {
  const LocationBannerWidget({required this.onActivate, super.key});

  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        border: Border.all(color: AppColors.borderFor(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 18,
            color: AppColors.textSoftFor(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.locationBannerBody(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: onActivate,
            child: Text(context.l10n.locationBannerAction()),
          ),
        ],
      ),
    );
  }
}
