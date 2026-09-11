import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mudavi_app/app/theme/app_colors.dart';

class MudaviLogo extends StatelessWidget {
  const MudaviLogo({
    this.markSize = 28,
    this.showWordmark = true,
    this.markColor,
    this.textColor,
    this.spacing = 12,
    super.key,
  });

  final double markSize;
  final bool showWordmark;
  final Color? markColor;
  final Color? textColor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final resolvedTextColor = textColor ?? AppColors.textPrimaryFor(context);
    final resolvedMarkColor = markColor ?? resolvedTextColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/brand/mudavi_mark_light.svg'
        : 'assets/brand/mudavi_mark_dark.svg';

    final mark = SvgPicture.asset(
      assetPath,
      width: markSize,
      height: markSize,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(resolvedMarkColor, BlendMode.srcIn),
      semanticsLabel: 'Mudavi logo',
    );

    if (!showWordmark) {
      return mark;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: spacing),
        Text(
          'Mudavi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: resolvedTextColor,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
