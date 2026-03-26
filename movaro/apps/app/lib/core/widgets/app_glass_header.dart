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
    final sideWidth = _headerSideWidthFor(context);
    final helpAction = onHelp == null
        ? null
        : IconButton(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline_rounded),
            visualDensity: VisualDensity.compact,
          );

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
          SizedBox(
            width: sideWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _HeaderActionSlot(
                child: onBack == null
                    ? null
                    : IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SizedBox(
            width: sideWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (helpAction != null) _HeaderActionSlot(child: helpAction),
                  if (trailing != null) _HeaderActionSlot(child: trailing),
                  if (helpAction == null && trailing == null)
                    const _HeaderActionSlot(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _headerSideWidthFor(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 380) return 80;
  if (width < 430) return 92;
  return 120;
}

class _HeaderActionSlot extends StatelessWidget {
  const _HeaderActionSlot({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: child == null
          ? const SizedBox(width: 44, height: 44)
          : Center(child: child),
    );
  }
}
