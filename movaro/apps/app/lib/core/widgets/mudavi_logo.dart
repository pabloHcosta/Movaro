import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MudaviLogo extends StatelessWidget {
  const MudaviLogo({
    this.markSize = 28,
    this.showWordmark = true,
    this.markColor,
    this.textColor,
    super.key,
  });

  final double markSize;
  final bool showWordmark;
  final Color? markColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/brand/mudavi_mark_light.svg'
        : 'assets/brand/mudavi_mark_dark.svg';
    final useLightSignature = textColor == null
        ? isDark
        : textColor!.computeLuminance() > 0.5;
    final wordmarkPath = useLightSignature
        ? 'assets/brand/mudavi_wordmark_light.svg'
        : 'assets/brand/mudavi_wordmark_dark.svg';

    final mark = SvgPicture.asset(
      assetPath,
      width: markSize,
      height: markSize,
      fit: BoxFit.contain,
      colorFilter: markColor == null
          ? null
          : ColorFilter.mode(markColor!, BlendMode.srcIn),
      semanticsLabel: 'Mudavi logo',
    );

    if (!showWordmark) {
      return mark;
    }

    return SvgPicture.asset(
      wordmarkPath,
      height: markSize,
      fit: BoxFit.contain,
      semanticsLabel: 'Mudavi logo',
    );
  }
}
