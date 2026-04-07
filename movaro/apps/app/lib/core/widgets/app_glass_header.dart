import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

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

  static const double _height = 52;
  static const double _heightWithSubtitle = 60;

  @override
  Widget build(BuildContext context) {
    final helpAction = onHelp == null
        ? null
        : _HeaderIconButton(
            onPressed: onHelp,
            icon: Icons.help_outline_rounded,
          );
    final hasTrailingActions =
        (helpAction != null ? 1 : 0) + (trailing != null ? 1 : 0);
    final leadingWidth = _headerSideWidthFor(
      context,
      actionCount: onBack == null ? 0 : 1,
    );
    final trailingWidth = _headerSideWidthFor(
      context,
      actionCount: hasTrailingActions == 0 ? 1 : hasTrailingActions,
    );

    return SizedBox(
      height: subtitle != null ? _heightWithSubtitle : _height,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimaryFor(context),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textSoftFor(context),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                      ),
                    ],
                  )
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
          ),
          SizedBox(
            width: trailingWidth,
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
    final side = width < 380 ? 40.0 : 44.0;
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: side, height: side),
      child: child == null
          ? SizedBox(width: side, height: side)
          : Center(child: child),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.onPressed, required this.icon});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = width < 380 ? 40.0 : 44.0;
    final isDark = AppColors.isDark(context);

    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.76),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: side,
          height: side,
          child: Icon(icon, size: 20, color: AppColors.textPrimaryFor(context)),
        ),
      ),
    );
  }
}
