import 'package:flutter/material.dart';
import 'package:movaro_app/core/responsive/app_breakpoints.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth = AppBreakpoints.readingContentMaxWidth,
    this.alignment = Alignment.topCenter,
    this.useSafeArea = true,
    this.padding,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: context.pageHorizontalPadding,
                vertical: context.pageVerticalPadding,
              ),
          child: child,
        ),
      ),
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
