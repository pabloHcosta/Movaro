import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class AppGlassHeader extends StatelessWidget {
  const AppGlassHeader({
    required this.title,
    this.onBack,
    this.onHelp,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return FrostedPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(999),
      backgroundColor: isDark
          ? const Color(0xB3141B26)
          : Colors.white.withValues(alpha: 0.7),
      blurSigma: 14,
      boxShadow: const [],
      child: Row(
        children: [
          if (onBack != null)
            SizedBox(
              width: 44,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                visualDensity: VisualDensity.compact,
              ),
            )
          else
            const SizedBox(width: 44),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onHelp != null)
                SizedBox(
                  width: 44,
                  child: IconButton(
                    onPressed: onHelp,
                    icon: const Icon(Icons.help_outline_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              trailing ?? const SizedBox(width: 44),
            ],
          ),
        ],
      ),
    );
  }
}
