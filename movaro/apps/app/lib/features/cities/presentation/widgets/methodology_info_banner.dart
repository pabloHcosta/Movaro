import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class MethodologyInfoBanner extends StatelessWidget {
  const MethodologyInfoBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textSoft),
            ),
          ),
        ],
      ),
    );
  }
}
