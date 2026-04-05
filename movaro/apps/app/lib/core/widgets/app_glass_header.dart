import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class AppGlassHeader extends StatelessWidget {
  const AppGlassHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    this.onHelp,
    this.trailing,
    super.key,
  });

  final String title;
  /// Optional breadcrumb line shown below [title] in a smaller muted style.
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;
  final Widget? trailing;

  static const double _height = 64;
  static const double _heightWithSubtitle = 74;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final helpAction = onHelp == null
        ? null
        : _HeaderIconButton(
            onPressed: onHelp,
            icon: Icons.help_outline_rounded,
          );
    final hasTrailingActions =
        (helpAction != null ? 1 : 0) + (trailing != null ? 1 : 0);
    final leadingWidth = _headerSideWidthFor(context, actionCount: onBack == null ? 0 : 1);
    final trailingWidth = _headerSideWidthFor(
      context,
      actionCount: hasTrailingActions == 0 ? 1 : hasTrailingActions,
    );

    return SizedBox(
      height: subtitle != null ? _heightWithSubtitle : _height,
      child: FrostedPanel(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        borderRadius: BorderRadius.circular(999),
        backgroundColor: isDark
            ? const Color(0xB3141B26)
            : Colors.white.withValues(alpha: 0.7),
        blurSigma: 14,
        boxShadow: const [],
        child: Row(
          children: [
            SizedBox(
              width: leadingWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _HeaderActionSlot(
                  child: onBack == null
                      ? null
                      : Transform.translate(
                          offset: const Offset(-2, 0),
                          child: _HeaderIconButton(
                            onPressed: onBack,
                            icon: Icons.arrow_back_rounded,
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              child: subtitle != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSoftFor(context),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
            ),
            SizedBox(
              width: trailingWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (helpAction != null)
                      _HeaderActionSlot(child: helpAction),
                    if (trailing != null) _HeaderActionSlot(child: trailing),
                    if (helpAction == null && trailing == null)
                      const _HeaderActionSlot(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _headerSideWidthFor(BuildContext context, {required int actionCount}) {
  final width = MediaQuery.sizeOf(context).width;
  final slotWidth = width < 380 ? 40.0 : 44.0;
  final horizontalPadding = width < 380 ? 0.0 : 4.0;
  return (actionCount * slotWidth) + horizontalPadding;
}

class _HeaderActionSlot extends StatelessWidget {
  const _HeaderActionSlot({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final minSide = width < 380 ? 40.0 : 44.0;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSide, minHeight: minSide),
      child: child == null
          ? SizedBox(width: minSide, height: minSide)
          : Center(child: child),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = width < 380 ? 40.0 : 44.0;
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: side, height: side),
      splashRadius: side / 2,
      iconSize: 20,
      icon: Icon(icon),
    );
  }
}
